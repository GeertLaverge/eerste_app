// THIMACO-CONTROLE: PDF-PVC-IMPORT-UINT8LIST-FIX-20260720
// THIMACO-CONTROLE: OFFERTE-ZONDER-RAAMKADER-KOPPEN-20260720
// THIMACO-CONTROLE: UNIFORME-PVC-OFFERTE-20260720
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../opmeting/overzicht/opmeting_artikel_type_omschrijving_helper.dart';
import '../opmeting/overzicht/opmeting_overzicht_model.dart';
import 'offerte_pdf_artikel_layout_helper.dart';
import 'prijzen/offerte_algemeen_artikel_prijs_service.dart';
import 'prijzen/offerte_prijsregel_weergave_service.dart';
import 'prijzen/offerte_toegepaste_prijsregel_model.dart';

class OffertePdfPvcRaamWidget {
  const OffertePdfPvcRaamWidget._();

  static const PdfColor _tekstDonker = PdfColor.fromInt(0xFF22272D);
  static const PdfColor _tekstGrijs = PdfColor.fromInt(0xFF616973);
  static const PdfColor _rand = PdfColor.fromInt(0xFFE2E5E8);

  static double berekenTotalePositieHoogte(
    OpmetingOverzichtRaamItem positie, {
    bool kortingToestaan = true,
    bool isOptie = false,
  }) {
    final technischeRegels = _technischeRegelsVoorOfferte(positie);
    final kolomHoogte =
        OffertePdfArtikelLayoutHelper.berekenTechnischeKolomHoogte(
          regels: technischeRegels,
          notities: positie.notities,
          bovenMelding: isOptie ? 'Niet meegerekend in het eindtotaal' : '',
        );
    final prijsHoogte = _berekenPrijsSectieHoogte(
      positie,
      kortingToestaan: kortingToestaan && !isOptie,
      isOptie: isOptie,
    );

    return OffertePdfArtikelLayoutHelper.berekenTotalePositieHoogte(
      kolomHoogte: kolomHoogte,
      prijsHoogte: prijsHoogte,
    );
  }

  static pw.Widget bouwPositie({
    required OpmetingOverzichtRaamItem positie,
    required bool isOptie,
    bool kortingToestaan = true,
    double btwPercentage = 0.0,
    String btwRegelLabel = 'BTW',
    Uint8List? tekeningPng,
  }) {
    final technischeRegels = _technischeRegelsVoorOfferte(positie);
    final kolomHoogte =
        OffertePdfArtikelLayoutHelper.berekenTechnischeKolomHoogte(
          regels: technischeRegels,
          notities: positie.notities,
          bovenMelding: isOptie ? 'Niet meegerekend in het eindtotaal' : '',
        );

    return OffertePdfArtikelLayoutHelper.bouwArtikelLayout(
      kolomHoogte: kolomHoogte,
      tekenvlak: OffertePdfArtikelLayoutHelper.bouwTekenvlak(
        hoogte: kolomHoogte,
        maatTitel: 'Totale Raammaat',
        maatWaarde:
            '${positie.raammaatBreedteMm} x ${positie.raammaatHoogteMm} mm',
        tekening: _bouwTekening(
          positie: positie,
          kolomHoogte: kolomHoogte,
          tekeningPng: tekeningPng,
        ),
      ),
      technischeKolom: OffertePdfArtikelLayoutHelper.bouwTechnischeKolom(
        hoogte: kolomHoogte,
        regels: technischeRegels,
        notities: positie.notities,
        bovenMelding: isOptie ? 'Niet meegerekend in het eindtotaal' : '',
        legeTekst: 'Geen technische kenmerken ingevuld.',
      ),
      prijsBlok: _bouwPrijsBlok(
        positie,
        kortingToestaan: kortingToestaan && !isOptie,
        isOptie: isOptie,
        btwPercentage: btwPercentage,
        btwRegelLabel: btwRegelLabel,
      ),
    );
  }

  static List<OffertePdfTechnischeRegel> _technischeRegelsVoorOfferte(
    OpmetingOverzichtRaamItem positie,
  ) {
    final prijsResultaat =
        OfferteAlgemeenArtikelPrijsService.resultaatUitMomentopname(
          prijsData: positie.offertePrijsData,
          breedteMm: positie.raammaatBreedteMm,
          hoogteMm: positie.raammaatHoogteMm,
          kortingToestaan: false,
        );
    final technischePrijsregels = prijsResultaat.technischePrijsregels
        .where((prijsregel) {
          return prijsregel.isGeldig &&
              OffertePrijsregelWeergaveService.technischeUitschrijftekst(
                prijsregel,
              ).isNotEmpty;
        })
        .toList(growable: false);
    final resultaat = <OffertePdfTechnischeRegel>[];
    final gebruikteRegels = <String>{};
    final weergegevenTechnischePrijsSleutels = <String>{};
    final containers = positie.zichtbareTechnischeContainers;
    final oudeRegels = positie.zichtbareTechnischeRegels;

    List<OfferteToegepastePrijsregelModel> passendePrijsregels(
      String titel,
      String waarde,
    ) {
      return technischePrijsregels
          .where((prijsregel) {
            return OffertePrijsregelWeergaveService.technischeRegelPastBijPrijsregel(
              prijsregel: prijsregel,
              titel: titel,
              waarde: waarde,
            );
          })
          .toList(growable: false);
    }

    String prijsTekstVoor(
      Iterable<OfferteToegepastePrijsregelModel> prijsregels,
    ) {
      final zichtbarePrijsregels = prijsregels
          .where((prijsregel) => prijsregel.toonAfzonderlijkePrijsOpOfferte)
          .toList(growable: false);
      if (zichtbarePrijsregels.isEmpty) {
        return '';
      }

      final totaal = zichtbarePrijsregels.fold<double>(
        0.0,
        (som, prijsregel) => som + prijsregel.totaalExclBtw,
      );
      return '€ ${_bedragMetPunt(totaal)}';
    }

    List<OfferteToegepastePrijsregelModel> prijsregelsMetUitschrijftekst(
      String uitschrijftekst,
    ) {
      final sleutel =
          OffertePrijsregelWeergaveService.normaliseerTechnischeTekst(
            uitschrijftekst,
          );
      if (sleutel.isEmpty) {
        return const <OfferteToegepastePrijsregelModel>[];
      }

      return technischePrijsregels
          .where((prijsregel) {
            final prijsregelSleutel =
                OffertePrijsregelWeergaveService.normaliseerTechnischeTekst(
                  OffertePrijsregelWeergaveService.technischeUitschrijftekst(
                    prijsregel,
                  ),
                );
            return prijsregelSleutel == sleutel;
          })
          .toList(growable: false);
    }

    void registreerWeergegevenPrijsregels(
      Iterable<OfferteToegepastePrijsregelModel> prijsregels,
    ) {
      for (final prijsregel in prijsregels) {
        final uitschrijftekst =
            OffertePrijsregelWeergaveService.technischeUitschrijftekst(
              prijsregel,
            );
        final sleutel =
            OffertePrijsregelWeergaveService.normaliseerTechnischeTekst(
              uitschrijftekst,
            );
        if (sleutel.isNotEmpty) {
          weergegevenTechnischePrijsSleutels.add(sleutel);
        }
      }
    }

    void voegRegelToe(String titel, String waarde) {
      final netteTitel = titel.trim();
      final netteWaarde = waarde.trim();

      if (netteTitel.isEmpty && netteWaarde.isEmpty) {
        return;
      }
      if (OpmetingArtikelTypeOmschrijvingHelper.isVerplaatsteTechnischeRegelTitel(
        netteTitel,
      )) {
        return;
      }
      if (_isTotaleRaammaatTitel(netteTitel) || _isRaamkaderTitel(netteTitel)) {
        return;
      }

      final passendeRegels = passendePrijsregels(netteTitel, netteWaarde);
      final zichtbarePassendeRegels = passendeRegels
          .where(
            OffertePrijsregelWeergaveService.technischeOmschrijvingMagOpOfferte,
          )
          .toList(growable: false);
      if (passendeRegels.isNotEmpty && zichtbarePassendeRegels.isEmpty) {
        return;
      }

      if (zichtbarePassendeRegels.isNotEmpty) {
        registreerWeergegevenPrijsregels(zichtbarePassendeRegels);
      }

      final technischeUitschrijftekst = zichtbarePassendeRegels.isEmpty
          ? ''
          : OffertePrijsregelWeergaveService.technischeUitschrijftekst(
              zichtbarePassendeRegels.first,
            );
      final effectieveTitel = technischeUitschrijftekst.isNotEmpty
          ? technischeUitschrijftekst
          : netteTitel.isEmpty
          ? 'Kenmerk'
          : netteTitel;
      final prijsTekst = prijsTekstVoor(zichtbarePassendeRegels);
      final effectieveWaarde = technischeUitschrijftekst.isNotEmpty
          ? ''
          : netteWaarde;
      final sleutel = <String>[
        effectieveTitel.toLowerCase().replaceAll(RegExp(r'\s+'), ' '),
        effectieveWaarde.toLowerCase().replaceAll(RegExp(r'\s+'), ' '),
      ].join('|');

      if (!gebruikteRegels.add(sleutel)) {
        return;
      }

      resultaat.add(
        OffertePdfTechnischeRegel(
          titel: effectieveTitel,
          waarde: effectieveWaarde,
          prijsTekst: prijsTekst,
        ),
      );
    }

    if (containers.isNotEmpty) {
      for (final container in containers) {
        final titel = container.titel.trim();
        final afmeting = container.afmeting.trim();

        if (!_isTotaleRaammaatTitel(titel) &&
            !_isRaamkaderTitel(titel) &&
            (titel.isNotEmpty || afmeting.isNotEmpty)) {
          voegRegelToe(titel, afmeting);
        }

        for (final regel in container.zichtbareRegels) {
          voegRegelToe(regel.titel, regel.waarde);
        }
      }
    } else {
      for (final regel in oudeRegels) {
        voegRegelToe(regel.titel, regel.waarde);
      }
    }

    for (final prijsregel in technischePrijsregels) {
      if (!OffertePrijsregelWeergaveService.technischeOmschrijvingMagOpOfferte(
        prijsregel,
      )) {
        continue;
      }

      final uitschrijftekst =
          OffertePrijsregelWeergaveService.technischeUitschrijftekst(
            prijsregel,
          );
      if (OpmetingArtikelTypeOmschrijvingHelper.isVerplaatsteTechnischeRegelTitel(
        uitschrijftekst,
      )) {
        continue;
      }
      final uitschrijfSleutel =
          OffertePrijsregelWeergaveService.normaliseerTechnischeTekst(
            uitschrijftekst,
          );
      if (uitschrijfSleutel.isEmpty ||
          weergegevenTechnischePrijsSleutels.contains(uitschrijfSleutel)) {
        continue;
      }

      final regelSleutel = '${uitschrijfSleutel}|';
      if (!gebruikteRegels.add(regelSleutel)) {
        weergegevenTechnischePrijsSleutels.add(uitschrijfSleutel);
        continue;
      }

      final gelijkePrijsregels = prijsregelsMetUitschrijftekst(uitschrijftekst);
      resultaat.add(
        OffertePdfTechnischeRegel(
          titel: uitschrijftekst,
          waarde: '',
          prijsTekst: prijsTekstVoor(gelijkePrijsregels),
        ),
      );
      weergegevenTechnischePrijsSleutels.add(uitschrijfSleutel);
    }

    return List<OffertePdfTechnischeRegel>.unmodifiable(resultaat);
  }

  static bool _isRaamkaderTitel(String titel) {
    final genormaliseerd = titel.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9+]'),
      '',
    );

    return RegExp(r'^(raam)?kader(\d+(\+\d+)*)?$').hasMatch(genormaliseerd) ||
        genormaliseerd == 'raamkadergroep' ||
        genormaliseerd == 'kadergroep';
  }

  static bool _isTotaleRaammaatTitel(String titel) {
    final genormaliseerd = titel.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '',
    );

    return genormaliseerd == 'totaleraammaat' ||
        genormaliseerd == 'raammaattotaal';
  }

  static pw.Widget _bouwTekening({
    required OpmetingOverzichtRaamItem positie,
    required double kolomHoogte,
    Uint8List? tekeningPng,
  }) {
    if (tekeningPng != null && tekeningPng.isNotEmpty) {
      return _bouwExacteOverzichtstekening(tekeningPng);
    }

    return _bouwKaderSamenstelling(
      positie,
      beschikbareHoogte: math
          .max(
            120.0,
            kolomHoogte - OffertePdfArtikelLayoutHelper.kopHoogte - 22.0,
          )
          .toDouble(),
    );
  }

  static pw.Widget _bouwExacteOverzichtstekening(Uint8List png) {
    return pw.Container(
      alignment: pw.Alignment.center,
      color: PdfColors.white,
      child: pw.Image(pw.MemoryImage(png), fit: pw.BoxFit.contain),
    );
  }

  static pw.Widget _bouwKaderSamenstelling(
    OpmetingOverzichtRaamItem positie, {
    required double beschikbareHoogte,
  }) {
    final kaders = positie.kaderSamenstelling.kaders;
    if (kaders.isEmpty) {
      return _bouwLegeTekening(positie, beschikbareHoogte: beschikbareHoogte);
    }

    final minX = kaders
        .map((kader) => kader.xMm.toDouble())
        .reduce((a, b) => math.min(a, b).toDouble());
    final minY = kaders
        .map((kader) => kader.yMm.toDouble())
        .reduce((a, b) => math.min(a, b).toDouble());
    final maxX = kaders
        .map((kader) => kader.xMm.toDouble() + kader.breedteMm.toDouble())
        .reduce((a, b) => math.max(a, b).toDouble());
    final maxY = kaders
        .map((kader) => kader.yMm.toDouble() + kader.hoogteMm.toDouble())
        .reduce((a, b) => math.max(a, b).toDouble());

    final totaleBreedte = math.max(1.0, maxX - minX).toDouble();
    final totaleHoogte = math.max(1.0, maxY - minY).toDouble();
    final beschikbareBreedte =
        OffertePdfArtikelLayoutHelper.tekenInhoudBreedte - 14.0;
    final veiligeHoogte = math.max(80.0, beschikbareHoogte).toDouble();
    final schaal = math.min(
      beschikbareBreedte / totaleBreedte,
      veiligeHoogte / totaleHoogte,
    );

    final getekendeBreedte = totaleBreedte * schaal;
    final getekendeHoogte = totaleHoogte * schaal;
    final startLinks = (beschikbareBreedte - getekendeBreedte) / 2;
    final startBoven = (veiligeHoogte - getekendeHoogte) / 2;

    return pw.Center(
      child: pw.SizedBox(
        width: beschikbareBreedte,
        height: veiligeHoogte,
        child: pw.Stack(
          children: <pw.Widget>[
            for (final kader in kaders)
              pw.Positioned(
                left: startLinks + ((kader.xMm.toDouble() - minX) * schaal),
                top: startBoven + ((kader.yMm.toDouble() - minY) * schaal),
                child: pw.SizedBox(
                  width: math
                      .max(9.0, kader.breedteMm.toDouble() * schaal)
                      .toDouble(),
                  height: math
                      .max(9.0, kader.hoogteMm.toDouble() * schaal)
                      .toDouble(),
                  child: _bouwKader(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _bouwKader() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(3.2),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: _tekstDonker, width: 1.45),
      ),
      child: pw.Container(
        decoration: pw.BoxDecoration(
          color: const PdfColor.fromInt(0xFFF6F7F8),
          border: pw.Border.all(color: _rand, width: 0.65),
        ),
      ),
    );
  }

  static pw.Widget _bouwLegeTekening(
    OpmetingOverzichtRaamItem positie, {
    required double beschikbareHoogte,
  }) {
    final verhouding = positie.raammaatHoogteMm <= 0
        ? 1.0
        : positie.raammaatBreedteMm / positie.raammaatHoogteMm;
    final maximaleBreedte =
        OffertePdfArtikelLayoutHelper.tekenInhoudBreedte - 28.0;
    final maximaleHoogte = math.max(100.0, beschikbareHoogte - 12.0).toDouble();

    var breedte = maximaleBreedte;
    var hoogte = breedte / math.max(0.1, verhouding);
    if (hoogte > maximaleHoogte) {
      hoogte = maximaleHoogte;
      breedte = hoogte * verhouding;
    }

    return pw.Center(
      child: pw.Container(
        width: math.max(42.0, breedte).toDouble(),
        height: math.max(42.0, hoogte).toDouble(),
        padding: const pw.EdgeInsets.all(4),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: _tekstDonker, width: 1.4),
        ),
        child: pw.Container(
          decoration: pw.BoxDecoration(
            color: const PdfColor.fromInt(0xFFF6F7F8),
            border: pw.Border.all(color: _rand, width: 0.7),
          ),
        ),
      ),
    );
  }

  static double _berekenPrijsSectieHoogte(
    OpmetingOverzichtRaamItem positie, {
    required bool kortingToestaan,
    required bool isOptie,
  }) {
    final resultaat =
        OfferteAlgemeenArtikelPrijsService.resultaatUitMomentopname(
          prijsData: positie.offertePrijsData,
          breedteMm: positie.raammaatBreedteMm,
          hoogteMm: positie.raammaatHoogteMm,
          kortingToestaan: kortingToestaan && !isOptie,
        );
    final aantalRegels =
        resultaat.afzonderlijkePrijsregelsVoorOfferte
            .where(
              (prijsregel) =>
                  !OffertePrijsregelWeergaveService.isTechnischePrijsregel(
                    prijsregel,
                  ),
            )
            .length +
        resultaat.omschrijvingZonderPrijsRegelsVoorOfferte
            .where(
              (prijsregel) =>
                  !OffertePrijsregelWeergaveService.isTechnischePrijsregel(
                    prijsregel,
                  ),
            )
            .length;

    return (isOptie ? 78.0 : 34.0) + (aantalRegels * 18.0);
  }

  static pw.Widget _bouwPrijsBlok(
    OpmetingOverzichtRaamItem positie, {
    required bool kortingToestaan,
    required bool isOptie,
    required double btwPercentage,
    required String btwRegelLabel,
  }) {
    final kortingToestaanEffectief = kortingToestaan && !isOptie;
    final resultaat =
        OfferteAlgemeenArtikelPrijsService.resultaatUitMomentopname(
          prijsData: positie.offertePrijsData,
          breedteMm: positie.raammaatBreedteMm,
          hoogteMm: positie.raammaatHoogteMm,
          kortingToestaan: kortingToestaanEffectief,
        );
    final omschrijvingZonderPrijsRegels = resultaat
        .omschrijvingZonderPrijsRegelsVoorOfferte
        .where(
          (prijsregel) =>
              !OffertePrijsregelWeergaveService.isTechnischePrijsregel(
                prijsregel,
              ),
        )
        .toList(growable: false);
    final afzonderlijkeRegels = resultaat.afzonderlijkePrijsregelsVoorOfferte
        .where(
          (prijsregel) =>
              !OffertePrijsregelWeergaveService.isTechnischePrijsregel(
                prijsregel,
              ),
        )
        .toList(growable: false);
    final heeftBijkomendeRegels =
        omschrijvingZonderPrijsRegels.isNotEmpty ||
        afzonderlijkeRegels.isNotEmpty;
    final totaalVoorKorting =
        resultaat.offerteTotaalExclBtw +
        (kortingToestaanEffectief ? resultaat.kortingBedragExclBtw : 0.0);
    final optieTotaalExclBtw = resultaat.offerteTotaalExclBtw;
    final optieBtw = _rondBedragAf(optieTotaalExclBtw * btwPercentage);
    final optieTotaalInclBtw = _rondBedragAf(optieTotaalExclBtw + optieBtw);
    final heeftPrijsInvoer =
        resultaat.basisTotaalExclBtw > 0.0 ||
        resultaat.prijsregelsVoorOfferte.isNotEmpty;

    pw.Widget bedragRegel({
      required String omschrijving,
      required double bedrag,
      bool benadrukt = false,
      bool laatste = false,
    }) {
      return pw.Container(
        padding: pw.EdgeInsets.symmetric(vertical: benadrukt ? 5 : 4),
        decoration: pw.BoxDecoration(
          color: benadrukt
              ? const PdfColor.fromInt(0xFFFFF7ED)
              : PdfColors.white,
          border: laatste
              ? null
              : const pw.Border(
                  bottom: pw.BorderSide(color: _rand, width: 0.5),
                ),
        ),
        child: pw.Row(
          children: <pw.Widget>[
            pw.Expanded(
              child: pw.Text(
                omschrijving,
                maxLines: 2,
                style: pw.TextStyle(
                  color: benadrukt ? _tekstDonker : _tekstGrijs,
                  fontSize: benadrukt ? 8.4 : 7.2,
                  fontWeight: benadrukt
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal,
                ),
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Text(
              '€ ${_bedragMetPunt(bedrag)}',
              style: pw.TextStyle(
                color: benadrukt
                    ? const PdfColor.fromInt(0xFFF15A24)
                    : _tekstDonker,
                fontSize: benadrukt ? 10.8 : 7.6,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return pw.Container(
      height: _berekenPrijsSectieHoogte(
        positie,
        kortingToestaan: kortingToestaanEffectief,
        isOptie: isOptie,
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(7),
        border: pw.Border.all(color: _rand, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: <pw.Widget>[
          for (final prijsregel in omschrijvingZonderPrijsRegels)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Text(
                OffertePrijsregelWeergaveService.omschrijvingVoorOfferte(
                  prijsregel,
                ),
                maxLines: 1,
                style: const pw.TextStyle(color: _tekstGrijs, fontSize: 7.2),
              ),
            ),
          for (final prijsregel in afzonderlijkeRegels)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Row(
                children: <pw.Widget>[
                  pw.Expanded(
                    child: pw.Text(
                      OffertePrijsregelWeergaveService.omschrijvingVoorOfferte(
                        prijsregel,
                      ),
                      maxLines: 1,
                      style: const pw.TextStyle(
                        color: _tekstGrijs,
                        fontSize: 7.2,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    '€ ${_bedragMetPunt(prijsregel.totaalExclBtw)}',
                    style: pw.TextStyle(
                      color: _tekstDonker,
                      fontSize: 7.4,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          if (heeftBijkomendeRegels) ...<pw.Widget>[
            pw.Container(height: 0.5, color: _rand),
            pw.SizedBox(height: 4),
          ],
          if (isOptie) ...<pw.Widget>[
            bedragRegel(
              omschrijving: 'Totaal optie excl. btw',
              bedrag: optieTotaalExclBtw,
            ),
            bedragRegel(omschrijving: btwRegelLabel, bedrag: optieBtw),
            bedragRegel(
              omschrijving: 'Totaal optie incl. btw',
              bedrag: optieTotaalInclBtw,
              benadrukt: true,
              laatste: true,
            ),
          ] else
            pw.Row(
              children: <pw.Widget>[
                pw.Expanded(
                  child: pw.Text(
                    'Totaal positie',
                    style: pw.TextStyle(
                      color: _tekstDonker,
                      fontSize: 8.4,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(width: 8),
                if (totaalVoorKorting <= 0.0 && !heeftPrijsInvoer)
                  pw.Text(
                    'Prijs nog in te vullen',
                    textAlign: pw.TextAlign.right,
                    style: const pw.TextStyle(
                      color: _tekstGrijs,
                      fontSize: 7.4,
                    ),
                  )
                else
                  pw.RichText(
                    textAlign: pw.TextAlign.right,
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text: '€ ${_bedragMetPunt(totaalVoorKorting)}',
                          style: pw.TextStyle(
                            color: _tekstDonker,
                            fontSize: 12.2,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        const pw.TextSpan(
                          text: ' excl. btw',
                          style: pw.TextStyle(
                            color: _tekstGrijs,
                            fontSize: 6.4,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  static double _rondBedragAf(double waarde) {
    if (!waarde.isFinite || waarde <= 0.0) return 0.0;
    return (waarde * 100.0).roundToDouble() / 100.0;
  }

  static String _bedragMetPunt(double waarde) {
    return waarde.toStringAsFixed(2);
  }
}
