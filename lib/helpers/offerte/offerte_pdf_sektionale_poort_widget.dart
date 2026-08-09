// THIMACO-CONTROLE: SEKTIONALE-POORTEN-PDF-R-PROFIELEN-MAATVAST-20260729-1313
// THIMACO-CONTROLE: SEKTIONALE-POORTEN-PDF-P-R-FINAAL-20260729-1214
// THIMACO-CONTROLE: SEKTIONALE-POORTEN-PDF-P-R-STOPCONTACT-20260729
// THIMACO-CONTROLE: SEKTIONALE-POORTEN-PDF-VOLLEDIG-UNIFORM-20260729
import 'dart:math' as math;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../opmeting/overzicht/opmeting_overzicht_model.dart';
import '../opmeting/toebehoren/sektionale_poort/opmeting_sektionale_poort_model.dart';
import '../opmeting/toebehoren/sektionale_poort/opmeting_sektionale_poort_technische_regels_helper.dart';
import 'offerte_pdf_artikel_layout_helper.dart';
import 'prijzen/offerte_artikel_prijs_koppeling_service.dart';
import 'prijzen/offerte_berekening_resultaat.dart';
import 'prijzen/offerte_prijsregel_weergave_service.dart';
import 'prijzen/offerte_toegepaste_prijsregel_model.dart';

class OffertePdfSektionalePoortWidget {
  const OffertePdfSektionalePoortWidget._();

  static const double _basisPrijsRegelHoogte = 34;
  static const double _basisOptiePrijsRegelHoogte = 78;

  static String _notitiesVoorPdf(
    OpmetingOverzichtRaamItem positie,
    OpmetingSektionalePoortModel model,
  ) {
    final overzichtNotities = positie.notities.trim();
    if (overzichtNotities.isNotEmpty) {
      return overzichtNotities;
    }
    return model.notities.trim();
  }

  static double berekenKolomHoogte(OpmetingOverzichtRaamItem positie) {
    final model = positie.sektionalePoortData;

    if (model == null) {
      return OffertePdfArtikelLayoutHelper.minimumKolomHoogte;
    }

    final notities = _notitiesVoorPdf(positie, model);

    final basisHoogte =
        OffertePdfArtikelLayoutHelper.berekenTechnischeKolomHoogte(
          regels: _technischeRegelsVoorOfferte(positie, model),
          notities: notities,
        );

    // Het opmerkingenblok bevat naast de tekst ook een scheidingslijn, titel en
    // tussenruimtes. Reserveer extra hoogte zodat opmerkingen bij een volle
    // technische kolom niet buiten de zichtbare PDF-zone vallen.
    final extraNotitieHoogte = notities.isEmpty ? 0.0 : 20.0;

    return (basisHoogte + extraNotitieHoogte)
        .clamp(
          OffertePdfArtikelLayoutHelper.minimumKolomHoogte,
          OffertePdfArtikelLayoutHelper.maximumKolomHoogte,
        )
        .toDouble();
  }

  static double berekenTotalePositieHoogte(
    OpmetingOverzichtRaamItem positie, {
    bool kortingToestaan = true,
    bool isOptie = false,
  }) {
    return OffertePdfArtikelLayoutHelper.berekenTotalePositieHoogte(
      kolomHoogte: berekenKolomHoogte(positie),
      prijsHoogte: _berekenPrijsSectieHoogte(isOptie: isOptie),
    );
  }

  static pw.Widget bouwPositie({
    required OpmetingOverzichtRaamItem positie,
    bool kortingToestaan = true,
    bool isOptie = false,
    double btwPercentage = 0.0,
    String btwRegelLabel = 'BTW',
  }) {
    final model = positie.sektionalePoortData;

    if (model == null) {
      return pw.SizedBox();
    }

    final hoogte = berekenKolomHoogte(positie);
    final regels = _technischeRegelsVoorOfferte(positie, model);

    return OffertePdfArtikelLayoutHelper.bouwArtikelLayout(
      kolomHoogte: hoogte,
      tekenvlak: OffertePdfArtikelLayoutHelper.bouwTekenvlak(
        hoogte: hoogte,
        maatTitel: 'Poortafmetingen',
        maatWaarde: '${model.breedteMm} × ${model.hoogteMm} mm',
        tekening: _bouwSektionalePoortTekening(
          model,
          canvasBreedte: OffertePdfArtikelLayoutHelper.tekenInhoudBreedte,
          canvasHoogte: math
              .max(120.0, hoogte - OffertePdfArtikelLayoutHelper.kopHoogte - 10)
              .toDouble(),
        ),
      ),
      technischeKolom: OffertePdfArtikelLayoutHelper.bouwTechnischeKolom(
        hoogte: hoogte,
        regels: regels,
        notities: _notitiesVoorPdf(positie, model),
        legeTekst: 'Geen technische keuzes ingevuld.',
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

  static OfferteBerekeningResultaat? _prijsResultaatVoor(
    OpmetingOverzichtRaamItem positie, {
    required bool kortingToestaan,
  }) {
    return OfferteArtikelPrijsKoppelingService.resultaatVoorArtikel(
      positie,
      kortingToestaan: kortingToestaan,
    );
  }

  static double _berekenPrijsSectieHoogte({required bool isOptie}) {
    return isOptie ? _basisOptiePrijsRegelHoogte : _basisPrijsRegelHoogte;
  }

  static pw.Widget _bouwPrijsBlok(
    OpmetingOverzichtRaamItem positie, {
    required bool kortingToestaan,
    required bool isOptie,
    required double btwPercentage,
    required String btwRegelLabel,
  }) {
    final kortingToestaanEffectief = kortingToestaan && !isOptie;
    final resultaat = _prijsResultaatVoor(
      positie,
      kortingToestaan: kortingToestaanEffectief,
    );
    final totaalVoorKorting = resultaat == null
        ? 0.0
        : resultaat.offerteTotaalExclBtw +
              (kortingToestaanEffectief ? resultaat.kortingBedragExclBtw : 0.0);
    final optieTotaalExclBtw = resultaat?.offerteTotaalExclBtw ?? 0.0;
    final optieBtw = _rondBedragAf(optieTotaalExclBtw * btwPercentage);
    final optieTotaalInclBtw = _rondBedragAf(optieTotaalExclBtw + optieBtw);
    final heeftPrijsInvoer =
        resultaat != null &&
        (resultaat.basisTotaalExclBtw > 0.0 ||
            resultaat.prijsregelsVoorOfferte.isNotEmpty);

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
                  bottom: pw.BorderSide(
                    color: OffertePdfArtikelLayoutHelper.rand,
                    width: 0.5,
                  ),
                ),
        ),
        child: pw.Row(
          children: <pw.Widget>[
            pw.Expanded(
              child: pw.Text(
                omschrijving,
                maxLines: 2,
                style: pw.TextStyle(
                  color: benadrukt
                      ? OffertePdfArtikelLayoutHelper.tekstDonker
                      : OffertePdfArtikelLayoutHelper.tekstGrijs,
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
                    ? OffertePdfArtikelLayoutHelper.oranje
                    : OffertePdfArtikelLayoutHelper.tekstDonker,
                fontSize: benadrukt ? 10.8 : 7.6,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return pw.Container(
      height: _berekenPrijsSectieHoogte(isOptie: isOptie),
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(7),
        border: pw.Border.all(
          color: OffertePdfArtikelLayoutHelper.rand,
          width: 0.8,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: <pw.Widget>[
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
                    style: const pw.TextStyle(
                      color: OffertePdfArtikelLayoutHelper.tekstDonker,
                      fontSize: 8.0,
                    ),
                  ),
                ),
                pw.SizedBox(width: 8),
                if (totaalVoorKorting <= 0.0 && !heeftPrijsInvoer)
                  pw.Text(
                    'Prijs nog in te vullen',
                    textAlign: pw.TextAlign.right,
                    style: const pw.TextStyle(
                      color: OffertePdfArtikelLayoutHelper.tekstGrijs,
                      fontSize: 8.0,
                    ),
                  )
                else
                  pw.Text(
                    '€ ${_bedragMetPunt(totaalVoorKorting)} excl. btw',
                    textAlign: pw.TextAlign.right,
                    style: const pw.TextStyle(
                      color: OffertePdfArtikelLayoutHelper.tekstDonker,
                      fontSize: 8.0,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  static double _rondBedragAf(double waarde) {
    if (!waarde.isFinite || waarde <= 0.0) {
      return 0.0;
    }

    return (waarde * 100.0).roundToDouble() / 100.0;
  }

  static String _bedragMetPunt(double waarde) {
    return waarde.toStringAsFixed(2);
  }

  static List<OffertePdfTechnischeRegel> _technischeRegelsVoorOfferte(
    OpmetingOverzichtRaamItem positie,
    OpmetingSektionalePoortModel model,
  ) {
    final bronRegels = OpmetingSektionalePoortTechnischeRegelsHelper.bouw(
      model,
    );
    final resultaat = <OffertePdfTechnischeRegel>[];
    final gebruikteRegels = <String>{};

    for (final regel in bronRegels) {
      final titel = regel.titel.trim();
      final waarde = regel.waarde.trim();
      final titelSleutel = _normaliseerTitel(titel);

      if (titel.isEmpty && waarde.isEmpty) {
        continue;
      }
      if (_isTitelRegel(titelSleutel)) {
        continue;
      }

      final dubbeleSleutel = '$titelSleutel|${waarde.toLowerCase()}';
      if (!gebruikteRegels.add(dubbeleSleutel)) {
        continue;
      }

      resultaat.add(OffertePdfTechnischeRegel(titel: titel, waarde: waarde));
    }

    final prijsResultaat = _prijsResultaatVoor(positie, kortingToestaan: false);
    if (prijsResultaat != null) {
      _voegArtikelPrijsregelsToe(
        resultaat: resultaat,
        prijsResultaat: prijsResultaat,
      );
    }

    return OffertePdfArtikelLayoutHelper.combineerTechnischeRegels(resultaat);
  }

  static bool _isTitelRegel(String sleutel) {
    return const <String>{'bestelmaat', 'poortafmetingen'}.contains(sleutel);
  }

  static void _voegArtikelPrijsregelsToe({
    required List<OffertePdfTechnischeRegel> resultaat,
    required OfferteBerekeningResultaat prijsResultaat,
  }) {
    for (final prijsregel in <OfferteToegepastePrijsregelModel>[
      ...prijsResultaat.technischePrijsregels,
      ...prijsResultaat.vrijeArtikelPrijsregels,
    ]) {
      if (prijsregel.bronPrijsregelId.trim().startsWith('toegepast_project_')) {
        continue;
      }
      if (!prijsregel.isGeldig || !prijsregel.teltMeeInOfferteTotaal) {
        continue;
      }

      final toonPrijs = prijsregel.toonAfzonderlijkePrijsOpOfferte;
      final toonAlleenOmschrijving =
          prijsregel.toonOmschrijvingZonderPrijsOpOfferte;
      if (!toonPrijs && !toonAlleenOmschrijving) {
        continue;
      }

      final omschrijving =
          OffertePrijsregelWeergaveService.omschrijvingVoorOfferte(
            prijsregel,
          ).trim();
      if (omschrijving.isEmpty) {
        continue;
      }

      resultaat.add(
        OffertePdfTechnischeRegel(
          titel: omschrijving,
          waarde: '',
          prijsTekst: toonPrijs
              ? '€ ${_bedragMetPunt(prijsregel.totaalExclBtw)}'
              : '',
        ),
      );
    }
  }

  static String _normaliseerTitel(String titel) {
    return titel.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  static pw.Widget _bouwSektionalePoortTekening(
    OpmetingSektionalePoortModel model, {
    required double canvasBreedte,
    required double canvasHoogte,
  }) {
    final breedte = math.max(150.0, canvasBreedte).toDouble();
    final hoogte = math.max(130.0, canvasHoogte).toDouble();
    final svg = _bouwPoortSvg(model, breedte: breedte, hoogte: hoogte);
    return pw.SizedBox(
      width: breedte,
      height: hoogte,
      child: pw.SvgImage(svg: svg),
    );
  }

  static String _bouwPoortSvg(
    OpmetingSektionalePoortModel model, {
    required double breedte,
    required double hoogte,
  }) {
    const margeLinks = 34.0;
    const margeRechts = 44.0;
    const margeBoven = 24.0;
    const margeOnder = 34.0;
    final bronBreedte = math.max(1, model.breedteMm);
    final bronHoogte = math.max(1, model.hoogteMm);
    final schaal = math.min(
      (breedte - margeLinks - margeRechts) / bronBreedte,
      (hoogte - margeBoven - margeOnder) / bronHoogte,
    );
    final deurBreedte = bronBreedte * schaal;
    final deurHoogte = bronHoogte * schaal;
    final links =
        margeLinks + (breedte - margeLinks - margeRechts - deurBreedte) / 2;
    final boven =
        margeBoven + (hoogte - margeBoven - margeOnder - deurHoogte) / 2;
    final rechts = links + deurBreedte;
    final onder = boven + deurHoogte;
    final rubber = math.max(3.0, math.min(7.0, deurHoogte * 0.018));
    final inhoudLinks = links + 2;
    final inhoudRechts = rechts - 2;
    final inhoudBoven = boven + 2;
    final inhoudOnder = onder - rubber - 1;
    final lijnen = StringBuffer();

    void horizontaleVerdeling(
      int vakken, {
      String kleur = '#374151',
      double dikte = 1.2,
    }) {
      for (var index = 1; index < vakken; index++) {
        final y = inhoudBoven + (inhoudOnder - inhoudBoven) * index / vakken;
        lijnen.writeln(
          '<line x1="${_n(inhoudLinks)}" y1="${_n(y)}" '
          'x2="${_n(inhoudRechts)}" y2="${_n(y)}" '
          'stroke="$kleur" stroke-width="$dikte"/>',
        );
      }
    }

    switch (model.modelType) {
      case OpmetingSektionalePoortModelType.g:
        horizontaleVerdeling(4);
        break;
      case OpmetingSektionalePoortModelType.w:
        horizontaleVerdeling(8);
        break;
      case OpmetingSektionalePoortModelType.s:
        final extra = math.max(3.0, 100 * schaal);
        for (var index = 1; index < 4; index++) {
          final y = inhoudBoven + (inhoudOnder - inhoudBoven) * index / 4;
          lijnen.writeln(
            '<line x1="${_n(inhoudLinks)}" y1="${_n(y)}" '
            'x2="${_n(inhoudRechts)}" y2="${_n(y)}" '
            'stroke="#374151" stroke-width="1.2"/>',
          );
          if (y - extra > inhoudBoven + 1) {
            lijnen.writeln(
              '<line x1="${_n(inhoudLinks)}" y1="${_n(y - extra)}" '
              'x2="${_n(inhoudRechts)}" y2="${_n(y - extra)}" '
              'stroke="#374151" stroke-width="1.2"/>',
            );
          }
        }
        break;
      case OpmetingSektionalePoortModelType.r:
        horizontaleVerdeling(4);
        final afstand = math.max(4.0, 100 * schaal);
        for (
          var x = inhoudLinks + afstand;
          x < inhoudRechts - 1;
          x += afstand
        ) {
          lijnen.writeln(
            '<line x1="${_n(x)}" y1="${_n(inhoudBoven)}" '
            'x2="${_n(x)}" y2="${_n(inhoudOnder)}" '
            'stroke="#CBD5E1" stroke-width="0.55"/>',
          );
        }
        if (model.rVierkantRaamMetKleinhouten) {
          final aantalRamen = model.rAantalVierkanteRamen.clamp(
            OpmetingSektionalePoortModel.rAantalVierkanteRamenMinimum,
            OpmetingSektionalePoortModel.rAantalVierkanteRamenMaximum,
          );

          void tekenVierkantRaam({
            required OpmetingSektionalePoortRaamZijde zijde,
            required int afstandMm,
          }) {
            final bovenstePaneelHoogte = (inhoudOnder - inhoudBoven) / 4;
            final buitenmaat = math.min(
              math.min(inhoudRechts - inhoudLinks, bovenstePaneelHoogte),
              math.max(
                9.0,
                OpmetingSektionalePoortModel.rVierkantRaamBuitenmaatMm * schaal,
              ),
            );
            final maximaleAfstandPx = math.max(
              0.0,
              inhoudRechts - inhoudLinks - buitenmaat,
            );
            final afstandPx = (math.max(0, afstandMm) * schaal).clamp(
              0.0,
              maximaleAfstandPx,
            );
            final raamX = zijde == OpmetingSektionalePoortRaamZijde.links
                ? inhoudLinks + afstandPx
                : inhoudRechts - afstandPx - buitenmaat;
            final raamY = inhoudBoven + (bovenstePaneelHoogte - buitenmaat) / 2;
            final kaderDikte = math.min(
              buitenmaat / 3,
              math.max(
                1.6,
                OpmetingSektionalePoortModel.rVierkantRaamKaderdikteMm * schaal,
              ),
            );
            final glasX = raamX + kaderDikte;
            final glasY = raamY + kaderDikte;
            final glasMaat = math.max(0.0, buitenmaat - kaderDikte * 2);

            lijnen.writeln(
              '<rect x="${_n(raamX)}" y="${_n(raamY)}" '
              'width="${_n(buitenmaat)}" height="${_n(buitenmaat)}" '
              'fill="#FFFFFF" stroke="#374151" stroke-width="1.3"/>',
            );
            if (glasMaat > 0) {
              lijnen.writeln(
                '<rect x="${_n(glasX)}" y="${_n(glasY)}" '
                'width="${_n(glasMaat)}" height="${_n(glasMaat)}" '
                'fill="#E7F4FA" stroke="#374151" stroke-width="0.8"/>',
              );
              lijnen.writeln(
                '<line x1="${_n(glasX + glasMaat / 2)}" '
                'y1="${_n(glasY)}" '
                'x2="${_n(glasX + glasMaat / 2)}" '
                'y2="${_n(glasY + glasMaat)}" '
                'stroke="#374151" stroke-width="0.7"/>',
              );
              lijnen.writeln(
                '<line x1="${_n(glasX)}" '
                'y1="${_n(glasY + glasMaat / 2)}" '
                'x2="${_n(glasX + glasMaat)}" '
                'y2="${_n(glasY + glasMaat / 2)}" '
                'stroke="#374151" stroke-width="0.7"/>',
              );
            }
          }

          tekenVierkantRaam(
            zijde: model.rRaam1Zijde,
            afstandMm: model.rRaam1AfstandMm,
          );
          if (aantalRamen >= 2) {
            tekenVierkantRaam(
              zijde: model.rRaam2Zijde,
              afstandMm: model.rRaam2AfstandMm,
            );
          }
        }
        if (model.rPlintOnderaan) {
          final plintHoogte = math.min(
            inhoudOnder - inhoudBoven,
            math.max(3.0, OpmetingSektionalePoortModel.rPlintHoogteMm * schaal),
          );
          lijnen.writeln(
            '<rect x="${_n(inhoudLinks)}" '
            'y="${_n(inhoudOnder - plintHoogte)}" '
            'width="${_n(inhoudRechts - inhoudLinks)}" '
            'height="${_n(plintHoogte)}" fill="#FFFFFF" '
            'stroke="#374151" stroke-width="1.3"/>',
          );
        }
        if (model.rVoetjeMetMakelaar) {
          final makelaarBreedte = math.min(
            inhoudRechts - inhoudLinks,
            math.max(
              3.0,
              OpmetingSektionalePoortModel.rMakelaarBreedteMm * schaal,
            ),
          );
          final makelaarX = (inhoudLinks + inhoudRechts - makelaarBreedte) / 2;
          final makelaarHoogte = inhoudOnder - inhoudBoven;
          lijnen.writeln(
            '<rect x="${_n(makelaarX)}" y="${_n(inhoudBoven)}" '
            'width="${_n(makelaarBreedte)}" '
            'height="${_n(makelaarHoogte)}" fill="#FFFFFF" '
            'stroke="#374151" stroke-width="1.2"/>',
          );

          final voetHoogte = math.min(
            makelaarHoogte,
            math.max(
              4.0,
              OpmetingSektionalePoortModel.rVoetjeHoogteMm * schaal,
            ),
          );
          lijnen.writeln(
            '<rect x="${_n(makelaarX)}" '
            'y="${_n(inhoudOnder - voetHoogte)}" '
            'width="${_n(makelaarBreedte)}" '
            'height="${_n(voetHoogte)}" fill="#000000"/>',
          );
          lijnen.writeln(
            '<line x1="${_n(makelaarX)}" '
            'y1="${_n(inhoudOnder - voetHoogte)}" '
            'x2="${_n(makelaarX + makelaarBreedte)}" '
            'y2="${_n(inhoudOnder - voetHoogte)}" '
            'stroke="#374151" stroke-width="0.9"/>',
          );
        }
        break;
      case OpmetingSektionalePoortModelType.n:
        horizontaleVerdeling(12);
        break;
      case OpmetingSektionalePoortModelType.v:
        horizontaleVerdeling(4);
        final afstand = math.max(1.7, 20 * schaal);
        for (var y = inhoudBoven + afstand; y < inhoudOnder - 1; y += afstand) {
          lijnen.writeln(
            '<line x1="${_n(inhoudLinks)}" y1="${_n(y)}" '
            'x2="${_n(inhoudRechts)}" y2="${_n(y)}" '
            'stroke="#CBD5E1" stroke-width="0.45"/>',
          );
        }
        break;
      case OpmetingSektionalePoortModelType.k:
        const rijen = 4;
        const kolommen = 4;
        final rijHoogte = (inhoudOnder - inhoudBoven) / rijen;
        final kolomBreedte = (inhoudRechts - inhoudLinks) / kolommen;
        final margeX = math.max(2.2, kolomBreedte * 0.12);
        final margeY = math.max(2.2, rijHoogte * 0.18);
        for (var rij = 0; rij < rijen; rij++) {
          for (var kolom = 0; kolom < kolommen; kolom++) {
            final x = inhoudLinks + kolom * kolomBreedte + margeX;
            final y = inhoudBoven + rij * rijHoogte + margeY;
            final w = kolomBreedte - margeX * 2;
            final h = rijHoogte - margeY * 2;
            lijnen.writeln(
              '<rect x="${_n(x)}" y="${_n(y)}" '
              'width="${_n(w)}" height="${_n(h)}" rx="1" '
              'fill="none" stroke="#374151" stroke-width="0.9"/>',
            );
            lijnen.writeln(
              '<rect x="${_n(x + 2)}" y="${_n(y + 2)}" '
              'width="${_n(math.max(1, w - 4))}" '
              'height="${_n(math.max(1, h - 4))}" fill="none" '
              'stroke="#CBD5E1" stroke-width="0.45"/>',
            );
          }
        }
        break;
      case OpmetingSektionalePoortModelType.p:
        final aantalPanelen = model.aantalPanelen
            .clamp(
              OpmetingSektionalePoortModel.aantalPanelenMinimum,
              OpmetingSektionalePoortModel.aantalPanelenMaximum,
            )
            .toInt();
        horizontaleVerdeling(aantalPanelen);
        final paneelHoogte = (inhoudOnder - inhoudBoven) / aantalPanelen;
        for (final nummer in model.geldigeGlasPaneelNummers) {
          final indexVanafBoven = aantalPanelen - nummer;
          final paneelY = inhoudBoven + indexVanafBoven * paneelHoogte;
          final marge = math.max(2.0, paneelHoogte * 0.08);
          final glasX = inhoudLinks + marge;
          final glasY = paneelY + marge;
          final glasW = inhoudRechts - inhoudLinks - marge * 2;
          final glasH = paneelHoogte - marge * 2;
          lijnen.writeln(
            '<rect x="${_n(glasX)}" y="${_n(glasY)}" '
            'width="${_n(glasW)}" height="${_n(glasH)}" '
            'fill="#E7F4FA" stroke="#374151" stroke-width="1.4"/>',
          );
          for (final deel in <int>[1, 2]) {
            final stijlX = glasX + glasW * deel / 3;
            lijnen.writeln(
              '<line x1="${_n(stijlX)}" y1="${_n(glasY)}" '
              'x2="${_n(stijlX)}" y2="${_n(glasY + glasH)}" '
              'stroke="#64748B" stroke-width="0.8"/>',
            );
          }
        }
        break;
    }

    return '''
<svg xmlns="http://www.w3.org/2000/svg" width="$breedte" height="$hoogte" viewBox="0 0 $breedte $hoogte">
  <text x="${_n((links + rechts) / 2)}" y="${_n(math.max(10, boven - 8))}" text-anchor="middle" font-size="7.5" font-weight="700" fill="#374151">Type ${model.modelType.label}</text>
  <path d="M ${_n(links)} ${_n(onder)} L ${_n(links)} ${_n(boven)} L ${_n(rechts)} ${_n(boven)} L ${_n(rechts)} ${_n(onder)}" fill="none" stroke="#374151" stroke-width="1.5"/>
  $lijnen
  <rect x="${_n(links)}" y="${_n(onder - rubber)}" width="${_n(deurBreedte)}" height="${_n(rubber)}" fill="#000000"/>
  <line x1="${_n(links)}" y1="${_n(onder + 18)}" x2="${_n(rechts)}" y2="${_n(onder + 18)}" stroke="#64748B" stroke-width="0.7"/>
  <line x1="${_n(links)}" y1="${_n(onder + 3)}" x2="${_n(links)}" y2="${_n(onder + 21)}" stroke="#64748B" stroke-width="0.7"/>
  <line x1="${_n(rechts)}" y1="${_n(onder + 3)}" x2="${_n(rechts)}" y2="${_n(onder + 21)}" stroke="#64748B" stroke-width="0.7"/>
  <path d="M ${_n(links)} ${_n(onder + 18)} l 4 -2 M ${_n(links)} ${_n(onder + 18)} l 4 2 M ${_n(rechts)} ${_n(onder + 18)} l -4 -2 M ${_n(rechts)} ${_n(onder + 18)} l -4 2" stroke="#64748B" stroke-width="0.7" fill="none"/>
  <text x="${_n((links + rechts) / 2)}" y="${_n(onder + 29)}" text-anchor="middle" font-size="6.8" fill="#64748B">${model.breedteMm} mm</text>
  <line x1="${_n(rechts + 18)}" y1="${_n(boven)}" x2="${_n(rechts + 18)}" y2="${_n(onder)}" stroke="#64748B" stroke-width="0.7"/>
  <line x1="${_n(rechts + 3)}" y1="${_n(boven)}" x2="${_n(rechts + 21)}" y2="${_n(boven)}" stroke="#64748B" stroke-width="0.7"/>
  <line x1="${_n(rechts + 3)}" y1="${_n(onder)}" x2="${_n(rechts + 21)}" y2="${_n(onder)}" stroke="#64748B" stroke-width="0.7"/>
  <text x="${_n(rechts + 30)}" y="${_n((boven + onder) / 2)}" text-anchor="middle" font-size="6.8" fill="#64748B" transform="rotate(-90 ${_n(rechts + 30)} ${_n((boven + onder) / 2)})">${model.hoogteMm} mm</text>
</svg>
''';
  }

  static String _n(num waarde) => waarde.toStringAsFixed(2);
}
