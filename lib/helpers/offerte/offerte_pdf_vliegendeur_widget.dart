// THIMACO-CONTROLE: VLIEGENDEUR-AFZONDERLIJKE-PDF-WIDGET-20260723
import 'dart:math' as math;

import 'package:pdf/widgets.dart' as pw;

import '../opmeting/overzicht/opmeting_overzicht_model.dart';
import '../opmeting/toebehoren/vliegendeur/opmeting_vliegendeur_model.dart';
import 'offerte_pdf_artikel_layout_helper.dart';

class OffertePdfVliegendeurWidget {
  const OffertePdfVliegendeurWidget._();

  static double berekenKolomHoogte(OpmetingOverzichtRaamItem positie) {
    final model = positie.vliegendeurData;
    if (model == null) {
      return OffertePdfArtikelLayoutHelper.minimumKolomHoogte;
    }

    return OffertePdfArtikelLayoutHelper.berekenTechnischeKolomHoogte(
      regels: _technischeRegelsVoorOfferte(positie, model),
      notities: positie.notities,
    );
  }

  static double berekenTotalePositieHoogte(OpmetingOverzichtRaamItem positie) {
    return berekenKolomHoogte(positie);
  }

  static pw.Widget bouwPositie({required OpmetingOverzichtRaamItem positie}) {
    final model = positie.vliegendeurData;
    if (model == null) return pw.SizedBox();

    final hoogte = berekenKolomHoogte(positie);
    final regels = _technischeRegelsVoorOfferte(positie, model);

    return OffertePdfArtikelLayoutHelper.bouwArtikelLayoutZonderPrijs(
      kolomHoogte: hoogte,
      tekenvlak: OffertePdfArtikelLayoutHelper.bouwTekenvlak(
        hoogte: hoogte,
        maatTitel: 'Afmetingen',
        maatWaarde: model.maatSamenvatting,
        tekening: _bouwVliegendeurTekening(
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
        notities: positie.notities,
        legeTekst: 'Geen technische keuzes ingevuld.',
        toonPrijsZone: false,
      ),
    );
  }

  static List<OffertePdfTechnischeRegel> _technischeRegelsVoorOfferte(
    OpmetingOverzichtRaamItem positie,
    OpmetingVliegendeurModel model,
  ) {
    final bronRegels = positie.zichtbareTechnischeRegels.isNotEmpty
        ? positie.zichtbareTechnischeRegels
        : _maakRegelsUitModel(model);

    final resultaat = <OffertePdfTechnischeRegel>[];

    for (final regel in bronRegels) {
      final titel = regel.titel.trim();
      final waarde = regel.waarde.trim();

      if (titel.isEmpty && waarde.isEmpty) {
        continue;
      }

      if (_isAfmetingsRegel(titel)) {
        continue;
      }

      if (_isVerborgenOpOfferte(titel: titel, waarde: waarde, model: model)) {
        continue;
      }

      resultaat.add(OffertePdfTechnischeRegel(titel: titel, waarde: waarde));
    }

    return List<OffertePdfTechnischeRegel>.unmodifiable(resultaat);
  }

  static bool _isAfmetingsRegel(String titel) {
    final sleutel = titel.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

    return const <String>{
      'afmetingen',
      'maat',
      'maten',
      'buitenmaat',
      'breedte',
      'hoogte',
      'breedte buitenmaat',
      'hoogte buitenmaat',
      'buitenmaat breedte',
      'buitenmaat hoogte',
      'binnenmaat/doorkijkmaat',
    }.contains(sleutel);
  }

  static String _normaliseerTechnischeTekst(String tekst) {
    return tekst.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  static bool _isVerborgenOpOfferte({
    required String titel,
    required String waarde,
    required OpmetingVliegendeurModel model,
  }) {
    final sleutel = _normaliseerTechnischeTekst(titel);

    if (sleutel == 'kaderuitvoering' || sleutel == 'afdekkappen') {
      return true;
    }

    if (sleutel == 'dierenluik') {
      return !model.heeftDierenluik ||
          _normaliseerTechnischeTekst(waarde) ==
              _normaliseerTechnischeTekst(
                OpmetingVliegendeurModel.dierenluikGeen,
              );
    }

    return false;
  }

  static List<OpmetingOverzichtTechnischeRegel> _maakRegelsUitModel(
    OpmetingVliegendeurModel model,
  ) {
    final regels = <OpmetingOverzichtTechnischeRegel>[];

    void voegToe(String titel, String waarde) {
      final netteWaarde = waarde.trim();
      if (netteWaarde.isEmpty) return;
      regels.add(
        OpmetingOverzichtTechnischeRegel(titel: titel, waarde: netteWaarde),
      );
    }

    voegToe('Stuk referentie', model.stukReferentie);
    voegToe('Aantal', '${model.aantal}');
    voegToe('Breedte buitenmaat', '${model.breedteMm} mm');
    voegToe('Hoogte buitenmaat', '${model.hoogteMm} mm');
    voegToe('Soort', model.soort);
    voegToe('Traverse', model.traverseType);
    voegToe('Aantal traversen', '${model.aantalTraversen}');

    final doorgangHoogtes = model.actieveDoorgangHoogtesMm;
    for (var index = 0; index < doorgangHoogtes.length; index++) {
      voegToe('Doorganghoogte ${index + 1}', '${doorgangHoogtes[index]} mm');
    }

    voegToe('Kleursoort', model.kleursoort);
    voegToe('Kleur', model.kleurVoorOverzicht);
    voegToe('Kleur PVC', model.kleurPvc);
    voegToe('Kaderuitvoering', model.kaderuitvoering);
    voegToe('Scharnierkant', model.scharnierkant);
    voegToe('Dierenluik', model.dierenluik);
    voegToe('Schopplaat', model.schopplaat);

    if (model.isSchopplaatOpMaat) {
      voegToe('Hoogte schopplaat', '${model.schopplaatHoogteOpMaatMm} mm');
    }

    voegToe('Gaas', model.gaas);
    voegToe('Gaas onder T1', model.gaasOnderT1);
    voegToe('Sluiting', model.sluiting);
    voegToe('Pomp', model.pomp);
    voegToe('Afdekkappen', model.afdekkappen);
    voegToe('Kleur pees', model.kleurPees);
    voegToe('Kleur borstel', model.kleurBorstel);
    return regels;
  }

  static pw.Widget _bouwVliegendeurTekening(
    OpmetingVliegendeurModel model, {
    required double canvasBreedte,
    required double canvasHoogte,
  }) {
    final veiligeCanvasBreedte = math.max(150.0, canvasBreedte).toDouble();
    final veiligeCanvasHoogte = math.max(150.0, canvasHoogte).toDouble();

    const margeBoven = 18.0;
    const margeRechts = 22.0;
    const margeOnder = 50.0;
    const margeLinks = 55.0;

    final buitenBreedte = model.breedteMm.clamp(1, 100000).toDouble();
    final buitenHoogte = model.hoogteMm.clamp(1, 100000).toDouble();
    final beschikbareBreedte = math
        .max(40.0, veiligeCanvasBreedte - margeLinks - margeRechts)
        .toDouble();
    final beschikbareHoogte = math
        .max(40.0, veiligeCanvasHoogte - margeBoven - margeOnder)
        .toDouble();
    final schaal = math.min(
      beschikbareBreedte / buitenBreedte,
      beschikbareHoogte / buitenHoogte,
    );

    final getekendeBreedte = buitenBreedte * schaal;
    final getekendeHoogte = buitenHoogte * schaal;
    final links = margeLinks + ((beschikbareBreedte - getekendeBreedte) / 2);
    final boven = margeBoven + ((beschikbareHoogte - getekendeHoogte) / 2);
    final rechts = links + getekendeBreedte;
    final onder = boven + getekendeHoogte;

    final buitenStijlMm = model.isZonderKader
        ? 0
        : model.isSmalleKader
        ? 11
        : OpmetingVliegendeurModel.buitenStijlAanzichtMm;
    final buitenStijl = math.max(0.0, buitenStijlMm * schaal).toDouble();
    final deurProfiel = math
        .max(1.4, OpmetingVliegendeurModel.deurProfielAanzichtMm * schaal)
        .toDouble();
    final traverseHoogte = math
        .max(2.2, OpmetingVliegendeurModel.middenregelAanzichtMm * schaal)
        .toDouble();

    final deurLinks = links + buitenStijl;
    final deurRechts = rechts - buitenStijl;
    final deurBreedte = math.max(4.0, deurRechts - deurLinks).toDouble();
    final binnenLinks = deurLinks + deurProfiel;
    final binnenRechts = deurRechts - deurProfiel;
    final binnenBoven = boven + deurProfiel;
    final binnenOnder = onder - deurProfiel;
    final binnenBreedte = math.max(2.0, binnenRechts - binnenLinks).toDouble();
    final binnenHoogte = math.max(2.0, binnenOnder - binnenBoven).toDouble();

    final rasterStap = math.max(3.5, 12 * schaal).toDouble();
    final traversen = StringBuffer();
    for (final doorgangHoogte in model.actieveDoorgangHoogtesMm) {
      final bovenkantVanafOnder =
          (doorgangHoogte +
                  OpmetingVliegendeurModel.deurProfielAanzichtMm +
                  OpmetingVliegendeurModel.middenregelAanzichtMm +
                  OpmetingVliegendeurModel.buitenStijlAanzichtMm)
              .clamp(
                150,
                model.hoogteMm -
                    OpmetingVliegendeurModel.deurProfielAanzichtMm -
                    1,
              )
              .toDouble();
      final y = onder - (bovenkantVanafOnder * schaal);
      traversen.write('''
  <rect x="$deurLinks" y="$y" width="$deurBreedte"
    height="$traverseHoogte" fill="#F3F4F6"
    stroke="#111827" stroke-width="1.0"/>
''');
    }

    final schopplaatHoogte = math
        .max(0.0, model.schopplaatBovenkantVanafOnderMm * schaal)
        .toDouble();
    final schopplaat = model.heeftSchopplaat && schopplaatHoogte > 0
        ? '''
  <rect x="$binnenLinks" y="${binnenOnder - schopplaatHoogte}"
    width="$binnenBreedte" height="$schopplaatHoogte"
    fill="#DCEAF2" stroke="#111827" stroke-width="1.0"/>
'''
        : '';

    final middenStijl = model.isDubbeleDeur
        ? '''
  <rect x="${(deurLinks + deurRechts - deurProfiel) / 2}" y="$boven"
    width="$deurProfiel" height="$getekendeHoogte"
    fill="#F3F4F6" stroke="#111827" stroke-width="1.0"/>
'''
        : '';

    final buitenKader = model.isZonderKader
        ? ''
        : '''
  <rect x="$links" y="$boven" width="$buitenStijl"
    height="$getekendeHoogte" fill="#F3F4F6" stroke="#111827"
    stroke-width="1.0"/>
  <rect x="${rechts - buitenStijl}" y="$boven" width="$buitenStijl"
    height="$getekendeHoogte" fill="#F3F4F6" stroke="#111827"
    stroke-width="1.0"/>
''';

    final onderKader =
        !model.isZonderKader &&
            model.kaderuitvoering == OpmetingVliegendeurModel.kaderRondom
        ? '''
  <rect x="$links" y="${onder - buitenStijl}" width="$getekendeBreedte"
    height="$buitenStijl" fill="#F3F4F6"
    stroke="#111827" stroke-width="1.0"/>
'''
        : '';

    final scharnierLinks =
        model.scharnierkant.trim().toLowerCase() ==
        OpmetingVliegendeurModel.scharnierLinks.toLowerCase();
    final scharnierX = scharnierLinks ? deurLinks : deurRechts;
    final scharnieren = StringBuffer();
    for (final verhouding in const <double>[0.18, 0.5, 0.82]) {
      final y = boven + (getekendeHoogte * verhouding);
      scharnieren.write('''
  <circle cx="$scharnierX" cy="$y" r="2.2"
    fill="#FFFFFF" stroke="#111827" stroke-width="0.9"/>
''');
    }

    final dierenluik = model.heeftDierenluik
        ? '''
  <rect x="${binnenLinks + (binnenBreedte * 0.32)}"
    y="${binnenOnder - math.max(22.0, binnenHoogte * 0.18)}"
    width="${binnenBreedte * 0.36}"
    height="${math.max(18.0, binnenHoogte * 0.16)}"
    rx="3" fill="#FFFFFF" stroke="#111827" stroke-width="1.0"/>
'''
        : '';

    final draairichting = scharnierLinks
        ? '''
  <path d="M ${binnenLinks + 8} ${binnenBoven + 10}
    L ${binnenRechts - 8} ${(binnenBoven + binnenOnder) / 2}
    L ${binnenLinks + 8} ${binnenOnder - 10}"
    fill="none" stroke="#6B7280" stroke-width="0.8"/>
'''
        : '''
  <path d="M ${binnenRechts - 8} ${binnenBoven + 10}
    L ${binnenLinks + 8} ${(binnenBoven + binnenOnder) / 2}
    L ${binnenRechts - 8} ${binnenOnder - 10}"
    fill="none" stroke="#6B7280" stroke-width="0.8"/>
''';

    final maatvoering = _buitenmaatSvg(
      buitenLinks: links,
      buitenRechts: rechts,
      buitenBoven: boven,
      buitenOnder: onder,
    );

    final svg =
        '''
<svg xmlns="http://www.w3.org/2000/svg"
  width="$veiligeCanvasBreedte" height="$veiligeCanvasHoogte"
  viewBox="0 0 $veiligeCanvasBreedte $veiligeCanvasHoogte">
  <defs>
    <pattern id="mesh" width="$rasterStap" height="$rasterStap"
      patternUnits="userSpaceOnUse">
      <path d="M 0 0 L $rasterStap 0 M 0 0 L 0 $rasterStap"
        fill="none" stroke="#CBD5E1" stroke-width="0.45"/>
    </pattern>
  </defs>
  <rect x="$binnenLinks" y="$binnenBoven" width="$binnenBreedte"
    height="$binnenHoogte" fill="url(#mesh)"/>
  <rect x="$deurLinks" y="$boven" width="$deurBreedte"
    height="$deurProfiel" fill="#F3F4F6" stroke="#111827"
    stroke-width="1.0"/>
  <rect x="$deurLinks" y="${onder - deurProfiel}" width="$deurBreedte"
    height="$deurProfiel" fill="#F3F4F6" stroke="#111827"
    stroke-width="1.0"/>
  <rect x="$deurLinks" y="$boven" width="$deurProfiel"
    height="$getekendeHoogte" fill="#F3F4F6" stroke="#111827"
    stroke-width="1.0"/>
  <rect x="${deurRechts - deurProfiel}" y="$boven" width="$deurProfiel"
    height="$getekendeHoogte" fill="#F3F4F6" stroke="#111827"
    stroke-width="1.0"/>
  $buitenKader
  $onderKader
  $schopplaat
  $traversen
  $middenStijl
  $dierenluik
  $draairichting
  $scharnieren
  <rect x="$links" y="$boven" width="$getekendeBreedte"
    height="$getekendeHoogte" fill="none" stroke="#111827"
    stroke-width="1.25"/>
  $maatvoering
</svg>
''';

    final breedteLabelX = (links + rechts) / 2;
    final breedteLabelY = onder + 30;
    final hoogteLabelX = links - 38;
    final hoogteLabelY = (boven + onder) / 2;

    final maatLabelsSvg =
        """
  <g>
    <rect x="${breedteLabelX - 31}" y="${breedteLabelY - 6}"
      width="62" height="12" rx="2" ry="2" fill="#FFFFFF"/>
    <text x="$breedteLabelX" y="${breedteLabelY + 2.5}"
      text-anchor="middle" font-size="7.2" font-weight="bold"
      fill="#22272D">${model.breedteMm} mm</text>
  </g>
  <g transform="translate($hoogteLabelX $hoogteLabelY) rotate(-90)">
    <rect x="-31" y="-6" width="62" height="12"
      rx="2" ry="2" fill="#FFFFFF"/>
    <text x="0" y="2.5" text-anchor="middle"
      font-size="7.2" font-weight="bold"
      fill="#22272D">${model.hoogteMm} mm</text>
  </g>
""";
    final svgMetMaatLabels = svg.replaceFirst(
      '</svg>',
      '$maatLabelsSvg\n</svg>',
    );

    // Gebruik één SVG zonder pw.Stack/pw.Positioned. Zo blijven de tekening
    // en maatlabels binnen exact dezelfde canvasconstraints.
    return pw.SizedBox(
      width: veiligeCanvasBreedte,
      height: veiligeCanvasHoogte,
      child: pw.SvgImage(svg: svgMetMaatLabels),
    );
  }

  static String _buitenmaatSvg({
    required double buitenLinks,
    required double buitenRechts,
    required double buitenBoven,
    required double buitenOnder,
  }) {
    final y = buitenOnder + 30;
    final x = buitenLinks - 38;

    return '''
  <line x1="$buitenLinks" y1="${buitenOnder + 6}" x2="$buitenLinks"
    y2="${y + 5}" stroke="#4B5563" stroke-width="0.9"/>
  <line x1="$buitenRechts" y1="${buitenOnder + 6}" x2="$buitenRechts"
    y2="${y + 5}" stroke="#4B5563" stroke-width="0.9"/>
  <line x1="$buitenLinks" y1="$y" x2="$buitenRechts" y2="$y"
    stroke="#4B5563" stroke-width="0.9"/>
  <path d="M $buitenLinks $y l 7 -4 M $buitenLinks $y l 7 4"
    stroke="#4B5563" stroke-width="0.9" fill="none"/>
  <path d="M $buitenRechts $y l -7 -4 M $buitenRechts $y l -7 4"
    stroke="#4B5563" stroke-width="0.9" fill="none"/>
  <line x1="${x - 5}" y1="$buitenBoven" x2="${buitenLinks - 6}"
    y2="$buitenBoven" stroke="#4B5563" stroke-width="0.9"/>
  <line x1="${x - 5}" y1="$buitenOnder" x2="${buitenLinks - 6}"
    y2="$buitenOnder" stroke="#4B5563" stroke-width="0.9"/>
  <line x1="$x" y1="$buitenBoven" x2="$x" y2="$buitenOnder"
    stroke="#4B5563" stroke-width="0.9"/>
  <path d="M $x $buitenBoven l -4 7 M $x $buitenBoven l 4 7"
    stroke="#4B5563" stroke-width="0.9" fill="none"/>
  <path d="M $x $buitenOnder l -4 -7 M $x $buitenOnder l 4 -7"
    stroke="#4B5563" stroke-width="0.9" fill="none"/>
''';
  }
}
