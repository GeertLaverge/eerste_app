// THIMACO-CONTROLE: PLOOIWERKEN-PDF-VOLLEDIG-UNIFORM-20260728
import 'dart:math' as math;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../opmeting/overzicht/opmeting_overzicht_model.dart';
import '../opmeting/toebehoren/plooiwerken/opmeting_plooiwerken_model.dart';
import '../opmeting/toebehoren/plooiwerken/opmeting_plooiwerken_technische_regels_helper.dart';
import 'offerte_pdf_artikel_layout_helper.dart';
import 'prijzen/offerte_artikel_prijs_koppeling_service.dart';
import 'prijzen/offerte_berekening_resultaat.dart';
import 'prijzen/offerte_prijsregel_weergave_service.dart';

class OffertePdfPlooiwerkenWidget {
  const OffertePdfPlooiwerkenWidget._();

  static const double _basisPrijsRegelHoogte = 34;
  static const double _basisOptiePrijsRegelHoogte = 78;

  static String _notitiesVoorPdf(
    OpmetingOverzichtRaamItem positie,
    OpmetingPlooiwerkenModel model,
  ) {
    final overzichtNotities = positie.notities.trim();
    if (overzichtNotities.isNotEmpty) {
      return overzichtNotities;
    }
    return model.notities.trim();
  }

  static double berekenKolomHoogte(OpmetingOverzichtRaamItem positie) {
    final model = positie.plooiwerkenData;

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
    final model = positie.plooiwerkenData;

    if (model == null) {
      return pw.SizedBox();
    }

    final hoogte = berekenKolomHoogte(positie);
    final regels = _technischeRegelsVoorOfferte(positie, model);

    return OffertePdfArtikelLayoutHelper.bouwArtikelLayout(
      kolomHoogte: hoogte,
      tekenvlak: OffertePdfArtikelLayoutHelper.bouwTekenvlak(
        hoogte: hoogte,
        maatTitel: 'Totale Lengte',
        maatWaarde: '${model.totaleLengteMm} mm',
        tekening: _bouwPlooiwerkenTekening(
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
    OpmetingPlooiwerkenModel model,
  ) {
    final bronRegels = OpmetingPlooiwerkenTechnischeRegelsHelper.bouw(model);
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
      _voegVrijeArtikelPrijsregelsToe(
        resultaat: resultaat,
        prijsResultaat: prijsResultaat,
      );
    }

    return OffertePdfArtikelLayoutHelper.combineerTechnischeRegels(resultaat);
  }

  static bool _isTitelRegel(String sleutel) {
    return const <String>{'totale lengte', 'lengte'}.contains(sleutel);
  }

  static void _voegVrijeArtikelPrijsregelsToe({
    required List<OffertePdfTechnischeRegel> resultaat,
    required OfferteBerekeningResultaat prijsResultaat,
  }) {
    for (final prijsregel in prijsResultaat.vrijeArtikelPrijsregels) {
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

  static pw.Widget _bouwPlooiwerkenTekening(
    OpmetingPlooiwerkenModel model, {
    required double canvasBreedte,
    required double canvasHoogte,
  }) {
    final veiligeBreedte = math.max(150.0, canvasBreedte).toDouble();
    final veiligeHoogte = math.max(130.0, canvasHoogte).toDouble();
    final geometrie = _bouwGeometrie(model);

    if (geometrie.punten.length < 2) {
      final leegSvg =
          '''
<svg xmlns="http://www.w3.org/2000/svg"
  width="$veiligeBreedte" height="$veiligeHoogte"
  viewBox="0 0 $veiligeBreedte $veiligeHoogte">
  <text x="${veiligeBreedte / 2}" y="${veiligeHoogte / 2}"
    text-anchor="middle" font-size="8" fill="#616973">
    Geen doorsnedematen ingevuld
  </text>
</svg>
''';
      return pw.SizedBox(
        width: veiligeBreedte,
        height: veiligeHoogte,
        child: pw.SvgImage(svg: leegSvg),
      );
    }

    final canvasPunten = _schaalNaarCanvas(
      geometrie.punten,
      breedte: veiligeBreedte,
      hoogte: veiligeHoogte,
    );
    final midden = _gemiddeldePunt(canvasPunten);
    final maatvoering = StringBuffer();

    for (
      var index = 0;
      index < canvasPunten.length - 1 && index < geometrie.lengtesMm.length;
      index++
    ) {
      maatvoering.write(
        _bouwMaatvoeringSvg(
          begin: canvasPunten[index],
          eind: canvasPunten[index + 1],
          middenTekening: midden,
          tekst: '${geometrie.lengtesMm[index]} mm',
        ),
      );
    }

    final hoekLabels = StringBuffer();
    final hoeken = model.actieveHoekenGraden;
    final aantalHoeken = math.min(hoeken.length, canvasPunten.length - 2);
    for (var index = 0; index < aantalHoeken; index++) {
      final hoek = hoeken[index];
      if (hoek == null) continue;
      hoekLabels.write(
        _bouwHoekLabelSvg(
          vorige: canvasPunten[index],
          hoekPunt: canvasPunten[index + 1],
          volgende: canvasPunten[index + 2],
          tekst: '$hoek°',
        ),
      );
    }

    final lijnPad = StringBuffer(
      'M ${_n(canvasPunten.first.x)} ${_n(canvasPunten.first.y)}',
    );
    for (final punt in canvasPunten.skip(1)) {
      lijnPad.write(' L ${_n(punt.x)} ${_n(punt.y)}');
    }

    final lakPaden = StringBuffer();
    if (model.toonLakAanduiding) {
      if (model.lakzijde == OpmetingPlooiwerkenLakzijde.zijde1 ||
          model.lakzijde == OpmetingPlooiwerkenLakzijde.beideZijden) {
        lakPaden.write(_bouwOffsetPadSvg(canvasPunten, zijde: 1));
      }
      if (model.lakzijde == OpmetingPlooiwerkenLakzijde.zijde2 ||
          model.lakzijde == OpmetingPlooiwerkenLakzijde.beideZijden) {
        lakPaden.write(_bouwOffsetPadSvg(canvasPunten, zijde: -1));
      }
    }

    final svg =
        '''
<svg xmlns="http://www.w3.org/2000/svg"
  width="$veiligeBreedte" height="$veiligeHoogte"
  viewBox="0 0 $veiligeBreedte $veiligeHoogte">
  $lakPaden
  <path d="$lijnPad" fill="none" stroke="#374151" stroke-width="2.1"
    stroke-linecap="round" stroke-linejoin="round"/>
  $maatvoering
  $hoekLabels
</svg>
''';

    return pw.SizedBox(
      width: veiligeBreedte,
      height: veiligeHoogte,
      child: pw.SvgImage(svg: svg),
    );
  }

  static _PlooiPdfGeometrie _bouwGeometrie(OpmetingPlooiwerkenModel model) {
    final lengtes = model.actieveLengtesMm;
    final hoeken = model.actieveHoekenGraden;
    final punten = <_PdfPunt>[const _PdfPunt(0, 0)];
    final getekendeLengtes = <int>[];
    var richting = 0.0;

    for (var index = 0; index < lengtes.length; index++) {
      final lengte = lengtes[index];
      if (lengte == null || lengte <= 0) break;

      if (index > 0) {
        final hoek = hoeken[index - 1];
        if (hoek == null) break;
        richting = richting + math.pi - _radialen(hoek.toDouble());
      }

      final vorig = punten.last;
      punten.add(
        _PdfPunt(
          vorig.x + math.cos(richting) * lengte,
          vorig.y + math.sin(richting) * lengte,
        ),
      );
      getekendeLengtes.add(lengte);
    }

    final rotatie = -_radialen(model.tekeningRotatieGraden.toDouble());
    final cosinus = math.cos(rotatie);
    final sinus = math.sin(rotatie);
    final geroteerd = punten
        .map((punt) {
          return _PdfPunt(
            punt.x * cosinus - punt.y * sinus,
            punt.x * sinus + punt.y * cosinus,
          );
        })
        .toList(growable: false);

    return _PlooiPdfGeometrie(punten: geroteerd, lengtesMm: getekendeLengtes);
  }

  static List<_PdfPunt> _schaalNaarCanvas(
    List<_PdfPunt> punten, {
    required double breedte,
    required double hoogte,
  }) {
    var minX = punten.first.x;
    var maxX = punten.first.x;
    var minY = punten.first.y;
    var maxY = punten.first.y;

    for (final punt in punten.skip(1)) {
      minX = math.min(minX, punt.x);
      maxX = math.max(maxX, punt.x);
      minY = math.min(minY, punt.y);
      maxY = math.max(maxY, punt.y);
    }

    const margeLinksRechts = 44.0;
    const margeBovenOnder = 38.0;
    final bronBreedte = math.max(1.0, maxX - minX).toDouble();
    final bronHoogte = math.max(1.0, maxY - minY).toDouble();
    final beschikbareBreedte = math.max(30.0, breedte - margeLinksRechts * 2);
    final beschikbareHoogte = math.max(30.0, hoogte - margeBovenOnder * 2);
    final schaal = math.min(
      beschikbareBreedte / bronBreedte,
      beschikbareHoogte / bronHoogte,
    );
    final getekendeBreedte = (maxX - minX) * schaal;
    final getekendeHoogte = (maxY - minY) * schaal;
    final links = (breedte - getekendeBreedte) / 2;
    final boven = (hoogte - getekendeHoogte) / 2;

    return punten
        .map((punt) {
          return _PdfPunt(
            links + (punt.x - minX) * schaal,
            boven + (maxY - punt.y) * schaal,
          );
        })
        .toList(growable: false);
  }

  static String _bouwMaatvoeringSvg({
    required _PdfPunt begin,
    required _PdfPunt eind,
    required _PdfPunt middenTekening,
    required String tekst,
  }) {
    final richting = eind - begin;
    final lengte = richting.lengte;
    if (lengte <= 0.001) return '';

    var normaal = _PdfPunt(-richting.y / lengte, richting.x / lengte);
    final segmentMidden = (begin + eind) / 2;
    final naarBuiten = segmentMidden - middenTekening;
    if (normaal.inwendigProduct(naarBuiten) < 0) {
      normaal = normaal * -1;
    }

    const maatAfstand = 23.0;
    final maatBegin = begin + normaal * maatAfstand;
    final maatEind = eind + normaal * maatAfstand;
    final labelMidden = (maatBegin + maatEind) / 2;
    final labelBreedte = math.max(36.0, tekst.length * 4.4).toDouble();

    return '''
  <line x1="${_n(maatBegin.x)}" y1="${_n(maatBegin.y)}"
    x2="${_n(maatEind.x)}" y2="${_n(maatEind.y)}"
    stroke="#475569" stroke-width="0.75"/>
  <line x1="${_n((begin + normaal * 5).x)}"
    y1="${_n((begin + normaal * 5).y)}"
    x2="${_n(maatBegin.x)}" y2="${_n(maatBegin.y)}"
    stroke="#475569" stroke-width="0.65"/>
  <line x1="${_n((eind + normaal * 5).x)}"
    y1="${_n((eind + normaal * 5).y)}"
    x2="${_n(maatEind.x)}" y2="${_n(maatEind.y)}"
    stroke="#475569" stroke-width="0.65"/>
  ${_bouwMaatPijlSvg(maatBegin, maatEind)}
  ${_bouwMaatPijlSvg(maatEind, maatBegin)}
  <rect x="${_n(labelMidden.x - labelBreedte / 2)}"
    y="${_n(labelMidden.y - 6)}" width="${_n(labelBreedte)}"
    height="12" rx="2" fill="#FFFFFF"/>
  <text x="${_n(labelMidden.x)}" y="${_n(labelMidden.y + 2.4)}"
    text-anchor="middle" font-size="7" font-weight="bold"
    fill="#475569">${_xmlEscape(tekst)}</text>
''';
  }

  static String _bouwMaatPijlSvg(_PdfPunt punt, _PdfPunt richtingNaar) {
    final richting = richtingNaar - punt;
    final lengte = richting.lengte;
    if (lengte <= 0.001) return '';

    final eenheid = richting / lengte;
    final normaal = _PdfPunt(-eenheid.y, eenheid.x);
    const pijlLengte = 5.0;
    const pijlBreedte = 2.2;
    final eerste = punt + eenheid * pijlLengte + normaal * pijlBreedte;
    final tweede = punt + eenheid * pijlLengte - normaal * pijlBreedte;

    return '''
  <path d="M ${_n(eerste.x)} ${_n(eerste.y)}
    L ${_n(punt.x)} ${_n(punt.y)}
    L ${_n(tweede.x)} ${_n(tweede.y)}"
    fill="none" stroke="#475569" stroke-width="0.75"/>
''';
  }

  static String _bouwHoekLabelSvg({
    required _PdfPunt vorige,
    required _PdfPunt hoekPunt,
    required _PdfPunt volgende,
    required String tekst,
  }) {
    final naarVorige = (vorige - hoekPunt).eenheid;
    final naarVolgende = (volgende - hoekPunt).eenheid;
    if (naarVorige == null || naarVolgende == null) return '';

    var richting = (naarVorige + naarVolgende).eenheid;
    richting ??= _PdfPunt(naarVorige.y, -naarVorige.x);
    final positie = hoekPunt + richting * 18;
    final breedte = math.max(23.0, tekst.length * 4.5).toDouble();

    return '''
  <rect x="${_n(positie.x - breedte / 2)}" y="${_n(positie.y - 6)}"
    width="${_n(breedte)}" height="12" rx="2" fill="#FFFFFF"
    fill-opacity="0.94"/>
  <text x="${_n(positie.x)}" y="${_n(positie.y + 2.4)}"
    text-anchor="middle" font-size="7" font-weight="bold"
    fill="#475569">${_xmlEscape(tekst)}</text>
''';
  }

  static String _bouwOffsetPadSvg(
    List<_PdfPunt> punten, {
    required double zijde,
  }) {
    const afstand = 7.0;
    if (punten.length < 2) return '';

    final richtingen = <_PdfPunt>[];
    final normalen = <_PdfPunt>[];
    for (var index = 0; index < punten.length - 1; index++) {
      final richting = (punten[index + 1] - punten[index]).eenheid;
      if (richting == null) return '';
      richtingen.add(richting);
      normalen.add(
        _PdfPunt(-richting.y * afstand * zijde, richting.x * afstand * zijde),
      );
    }

    final pad = StringBuffer();
    final start = punten.first + normalen.first;
    pad.write('M ${_n(start.x)} ${_n(start.y)}');

    for (var index = 1; index < punten.length - 1; index++) {
      final hoekPunt = punten[index];
      final vorigeOffset = hoekPunt + normalen[index - 1];
      final volgendeOffset = hoekPunt + normalen[index];
      final snijpunt = _snijpuntVanLijnen(
        vorigeOffset,
        richtingen[index - 1],
        volgendeOffset,
        richtingen[index],
      );

      if (snijpunt != null && (snijpunt - hoekPunt).lengte <= afstand * 4.0) {
        pad.write(' L ${_n(snijpunt.x)} ${_n(snijpunt.y)}');
      } else {
        pad.write(' L ${_n(vorigeOffset.x)} ${_n(vorigeOffset.y)}');
        pad.write(
          ' A $afstand $afstand 0 0 ${zijde > 0 ? 1 : 0} '
          '${_n(volgendeOffset.x)} ${_n(volgendeOffset.y)}',
        );
      }
    }

    final einde = punten.last + normalen.last;
    pad.write(' L ${_n(einde.x)} ${_n(einde.y)}');

    return '''
  <path d="$pad" fill="none" stroke="#DC2626" stroke-width="1.8"
    stroke-linecap="round" stroke-linejoin="round"/>
''';
  }

  static _PdfPunt? _snijpuntVanLijnen(
    _PdfPunt eerstePunt,
    _PdfPunt eersteRichting,
    _PdfPunt tweedePunt,
    _PdfPunt tweedeRichting,
  ) {
    final noemer = eersteRichting.kruisProduct(tweedeRichting);
    if (noemer.abs() <= 0.0001) return null;

    final verschil = tweedePunt - eerstePunt;
    final factor = verschil.kruisProduct(tweedeRichting) / noemer;
    return eerstePunt + eersteRichting * factor;
  }

  static _PdfPunt _gemiddeldePunt(List<_PdfPunt> punten) {
    var x = 0.0;
    var y = 0.0;
    for (final punt in punten) {
      x += punt.x;
      y += punt.y;
    }
    return _PdfPunt(x / punten.length, y / punten.length);
  }

  static double _radialen(double graden) {
    return graden * math.pi / 180.0;
  }

  static String _n(double waarde) {
    return waarde.toStringAsFixed(2);
  }

  static String _xmlEscape(String waarde) {
    return waarde
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}

class _PlooiPdfGeometrie {
  const _PlooiPdfGeometrie({required this.punten, required this.lengtesMm});

  final List<_PdfPunt> punten;
  final List<int> lengtesMm;
}

class _PdfPunt {
  const _PdfPunt(this.x, this.y);

  final double x;
  final double y;

  _PdfPunt operator +(_PdfPunt ander) => _PdfPunt(x + ander.x, y + ander.y);
  _PdfPunt operator -(_PdfPunt ander) => _PdfPunt(x - ander.x, y - ander.y);
  _PdfPunt operator *(double factor) => _PdfPunt(x * factor, y * factor);
  _PdfPunt operator /(double deler) => _PdfPunt(x / deler, y / deler);

  double get lengte => math.sqrt(x * x + y * y);

  _PdfPunt? get eenheid {
    final waarde = lengte;
    if (waarde <= 0.0001) return null;
    return this / waarde;
  }

  double inwendigProduct(_PdfPunt ander) => x * ander.x + y * ander.y;
  double kruisProduct(_PdfPunt ander) => x * ander.y - y * ander.x;
}
