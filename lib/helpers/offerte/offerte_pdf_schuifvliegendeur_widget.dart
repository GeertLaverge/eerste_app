// THIMACO-CONTROLE: SCHUIFVLIEGENDEUR-PDF-FIJN-GAAS-VASTE-STAP-20260728-1215
// THIMACO-CONTROLE: SCHUIFVLIEGENDEUR-AFZONDERLIJKE-PDF-WIDGET-20260728
import 'dart:math' as math;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../opmeting/overzicht/opmeting_overzicht_model.dart';
import '../opmeting/toebehoren/schuifvliegendeur/opmeting_schuifvliegendeur_model.dart';
import '../opmeting/toebehoren/schuifvliegendeur/opmeting_schuifvliegendeur_technische_regels_helpers.dart';
import 'offerte_pdf_artikel_layout_helper.dart';
import 'prijzen/offerte_artikel_prijs_koppeling_service.dart';
import 'prijzen/offerte_berekening_resultaat.dart';
import 'prijzen/offerte_prijsregel_weergave_service.dart';

class OffertePdfSchuifvliegendeurWidget {
  const OffertePdfSchuifvliegendeurWidget._();

  static const double _basisPrijsRegelHoogte = 34;
  static const double _basisOptiePrijsRegelHoogte = 78;

  static double berekenKolomHoogte(OpmetingOverzichtRaamItem positie) {
    final model = positie.schuifvliegendeurData;

    if (model == null) {
      return OffertePdfArtikelLayoutHelper.minimumKolomHoogte;
    }

    final notities = _notitiesVoorPdf(positie, model);
    final basisHoogte =
        OffertePdfArtikelLayoutHelper.berekenTechnischeKolomHoogte(
          regels: _technischeRegelsVoorOfferte(positie, model),
          notities: notities,
        );

    // De gezamenlijke helper reserveert de tekstregels, maar de kop
    // “Opmerkingen” en de scheidingslijn vragen bij dit lange formulier nog
    // extra ruimte. Zonder deze reserve kon alleen de kop zichtbaar blijven.
    final extraNotitieHoogte = notities.isEmpty ? 0.0 : 20.0;
    return (basisHoogte + extraNotitieHoogte)
        .clamp(
          OffertePdfArtikelLayoutHelper.minimumKolomHoogte,
          OffertePdfArtikelLayoutHelper.maximumKolomHoogte,
        )
        .toDouble();
  }

  static String _notitiesVoorPdf(
    OpmetingOverzichtRaamItem positie,
    OpmetingSchuifvliegendeurModel model,
  ) {
    final overzichtNotities = positie.notities.trim();
    if (overzichtNotities.isNotEmpty) {
      return overzichtNotities;
    }
    return model.notities.trim();
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
    final model = positie.schuifvliegendeurData;

    if (model == null) {
      return pw.SizedBox();
    }

    final hoogte = berekenKolomHoogte(positie);
    final regels = _technischeRegelsVoorOfferte(positie, model);
    final notities = _notitiesVoorPdf(positie, model);

    return OffertePdfArtikelLayoutHelper.bouwArtikelLayout(
      kolomHoogte: hoogte,
      tekenvlak: OffertePdfArtikelLayoutHelper.bouwTekenvlak(
        hoogte: hoogte,
        maatTitel: 'Afmetingen',
        maatWaarde: model.maatSamenvatting,
        tekening: _bouwSchuifvliegendeurTekening(
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
        notities: notities,
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
    OpmetingSchuifvliegendeurModel model,
  ) {
    final bronRegels = positie.zichtbareTechnischeRegels.isNotEmpty
        ? positie.zichtbareTechnischeRegels
        : OpmetingSchuifvliegendeurTechnischeRegelsHelper.bouw(model);
    final resultaat = <OffertePdfTechnischeRegel>[];
    final gebruikteTitels = <String>{};

    for (final regel in bronRegels) {
      final titel = regel.titel.trim();
      final waarde = regel.waarde.trim();
      final titelSleutel = _normaliseerTitel(titel);

      if (titel.isEmpty && waarde.isEmpty) {
        continue;
      }
      if (_isKopOfAfmetingsRegel(titelSleutel)) {
        continue;
      }
      if (titelSleutel.isNotEmpty && !gebruikteTitels.add(titelSleutel)) {
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

    return List<OffertePdfTechnischeRegel>.unmodifiable(resultaat);
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

  static bool _isKopOfAfmetingsRegel(String sleutel) {
    return const <String>{
      'afmetingen',
      'maat',
      'maten',
      'buitenmaat',
      'breedte',
      'hoogte',
      'breedte buitenmaat',
      'hoogte buitenmaat',
      'breedte buitenmaat vleugel',
      'hoogte inclusief rails',
      'buitenmaat breedte',
      'buitenmaat hoogte',
      'soort',
    }.contains(sleutel);
  }

  static pw.Widget _bouwSchuifvliegendeurTekening(
    OpmetingSchuifvliegendeurModel model, {
    required double canvasBreedte,
    required double canvasHoogte,
  }) {
    final veiligeCanvasBreedte = math.max(150.0, canvasBreedte).toDouble();
    final veiligeCanvasHoogte = math.max(150.0, canvasHoogte).toDouble();

    // Compactere marges dan de eerste versie: de hor komt zichtbaar dichter
    // tegen het kader van het tekenvlak, terwijl de drie maatlijnen behouden
    // blijven.
    const margeBoven = 29.0;
    const margeRechts = 34.0;
    const margeOnder = 39.0;
    const margeLinks = 8.0;

    final deurBreedteMm = model.breedteMm.clamp(1, 100000).toDouble();
    final deurHoogteMm = model.hoogteMm.clamp(1, 100000).toDouble();
    final totaleBreedteMm = model.heeftRails
        ? math.max(deurBreedteMm, model.railLengteMm.toDouble())
        : deurBreedteMm;
    final beschikbareBreedte = math
        .max(40.0, veiligeCanvasBreedte - margeLinks - margeRechts)
        .toDouble();
    final beschikbareHoogte = math
        .max(40.0, veiligeCanvasHoogte - margeBoven - margeOnder)
        .toDouble();
    final schaal = math.min(
      beschikbareBreedte / totaleBreedteMm,
      beschikbareHoogte / deurHoogteMm,
    );

    final totaleGetekendeBreedte = totaleBreedteMm * schaal;
    final getekendeHoogte = deurHoogteMm * schaal;
    final railLinks =
        margeLinks + ((beschikbareBreedte - totaleGetekendeBreedte) / 2);
    final railRechts = railLinks + totaleGetekendeBreedte;
    final boven = margeBoven + ((beschikbareHoogte - getekendeHoogte) / 2);
    final onder = boven + getekendeHoogte;

    final deurGetekendeBreedte = deurBreedteMm * schaal;
    final deurLinks =
        railLinks + ((totaleGetekendeBreedte - deurGetekendeBreedte) / 2);
    final deurRechts = deurLinks + deurGetekendeBreedte;

    final railDikte = model.heeftRails
        ? math.max(2.4, math.min(8.0, 18.0 * schaal)).toDouble()
        : 0.0;
    final frameBoven = boven + (model.heeftRails ? railDikte + 2.0 : 0.0);
    final frameOnder = onder - (model.heeftRails ? railDikte + 2.0 : 0.0);
    final frameHoogte = math.max(10.0, frameOnder - frameBoven).toDouble();

    final profielMaximum = math.min(deurGetekendeBreedte, frameHoogte) * 0.18;
    final profiel = math
        .max(2.4, model.kaderAanzichtMm * schaal)
        .clamp(2.4, profielMaximum)
        .toDouble();
    final traverseMaximum = frameHoogte * 0.12;
    final traverseDikte = math
        .max(2.2, model.traverseAanzichtMm * schaal)
        .clamp(2.2, traverseMaximum)
        .toDouble();
    final binnenLinks = deurLinks + profiel;
    final binnenRechts = deurRechts - profiel;
    final binnenBoven = frameBoven + profiel;
    final binnenOnder = frameOnder - profiel;
    final binnenBreedte = math.max(2.0, binnenRechts - binnenLinks).toDouble();
    final binnenHoogte = math.max(2.0, binnenOnder - binnenBoven).toDouble();

    final traverseData = <_SvgTraverseData>[];
    for (final hoogteMm in model.actieveTraverseHoogtesMm) {
      final yMidden = frameOnder - (hoogteMm * schaal);
      final y = (yMidden - (traverseDikte / 2))
          .clamp(binnenBoven, binnenOnder - traverseDikte)
          .toDouble();
      traverseData.add(_SvgTraverseData(y: y, hoogte: traverseDikte));
    }
    traverseData.sort((eerste, tweede) => eerste.y.compareTo(tweede.y));

    final ondersteTraverse = traverseData.isEmpty ? null : traverseData.last;
    final richtingY =
        (ondersteTraverse == null
                ? frameBoven + (frameHoogte * 0.50)
                : ondersteTraverse.y - 6.0)
            .clamp(frameBoven + 12.0, frameOnder - 12.0)
            .toDouble();
    final ondersteGaasBoven = ondersteTraverse == null
        ? null
        : (ondersteTraverse.y + ondersteTraverse.hoogte)
              .clamp(binnenBoven, binnenOnder)
              .toDouble();

    final plaatHoogte = math
        .min(
          binnenHoogte,
          math.max(0.0, model.effectievePlaatHoogteMm * schaal),
        )
        .toDouble();
    final plaatBoven = binnenOnder - plaatHoogte;

    final hoofdGaas = _gaasVulling(
      gaas: model.gaas,
      x: binnenLinks,
      y: binnenBoven,
      breedte: binnenBreedte,
      hoogte: binnenHoogte,
    );
    final onderGaas = ondersteGaasBoven == null
        ? ''
        : _gaasVulling(
            gaas: model.gaasOnderT1,
            x: binnenLinks,
            y: ondersteGaasBoven,
            breedte: binnenBreedte,
            hoogte: math.max(0.0, binnenOnder - ondersteGaasBoven).toDouble(),
          );

    final railsSvg = model.heeftRails
        ? '''
  <rect x="$railLinks" y="$boven" width="$totaleGetekendeBreedte"
    height="$railDikte" rx="1.4" fill="#D1D5DB"
    stroke="#374151" stroke-width="0.9"/>
  <line x1="${railLinks + 4}" y1="${boven + railDikte / 2}"
    x2="${railRechts - 4}" y2="${boven + railDikte / 2}"
    stroke="#6B7280" stroke-width="0.55"/>
  <rect x="$railLinks" y="${onder - railDikte}"
    width="$totaleGetekendeBreedte" height="$railDikte" rx="1.4"
    fill="#D1D5DB" stroke="#374151" stroke-width="0.9"/>
  <line x1="${railLinks + 4}" y1="${onder - railDikte / 2}"
    x2="${railRechts - 4}" y2="${onder - railDikte / 2}"
    stroke="#6B7280" stroke-width="0.55"/>
  <text x="${railRechts - 2}" y="${boven + railDikte + 7}"
    text-anchor="end" font-size="5.8"
    fill="#6B7280">${_xmlEscape(model.bovenrailCode)}</text>
  <text x="${railRechts - 2}" y="${onder - railDikte - 3}"
    text-anchor="end" font-size="5.8"
    fill="#6B7280">${_xmlEscape(model.onderrailCode)}</text>
'''
        : '';

    final traversenSvg = StringBuffer();
    for (final traverse in traverseData) {
      traversenSvg.write('''
  <rect x="$deurLinks" y="${traverse.y}" width="$deurGetekendeBreedte"
    height="${traverse.hoogte}" fill="#F3F4F6"
    stroke="#111827" stroke-width="0.9"/>
''');
    }

    final middenStijl = model.isDubbel
        ? '''
  <rect x="${((deurLinks + deurRechts) / 2) - (profiel * 0.62)}"
    y="$frameBoven" width="${profiel * 1.24}" height="$frameHoogte"
    fill="#F3F4F6" stroke="#111827" stroke-width="1.0"/>
'''
        : '';

    final plaatSvg = model.heeftPlaat && plaatHoogte > 0.0
        ? '''
  <rect x="$binnenLinks" y="$plaatBoven" width="$binnenBreedte"
    height="$plaatHoogte" fill="#DCEAF2"
    stroke="#111827" stroke-width="0.9"/>
'''
        : '';

    final dierenluikFactor = switch (model.dierenluik) {
      OpmetingSchuifvliegendeurModel.dierenluikSmall => 0.22,
      OpmetingSchuifvliegendeurModel.dierenluikMedium => 0.28,
      OpmetingSchuifvliegendeurModel.dierenluikXl => 0.36,
      _ => 0.22,
    };
    final dierenluikMaxBreedte = math.max(12.0, binnenBreedte - 8).toDouble();
    final dierenluikBreedte = math
        .min(binnenBreedte * dierenluikFactor, dierenluikMaxBreedte)
        .clamp(12.0, dierenluikMaxBreedte)
        .toDouble();
    final dierenluikHoogte = math
        .min(dierenluikBreedte * 1.18, binnenHoogte - 8)
        .clamp(14.0, math.max(14.0, binnenHoogte - 8))
        .toDouble();
    final dierenluikY = math
        .max(binnenBoven + 4, binnenOnder - dierenluikHoogte - 5)
        .toDouble();
    final dierenluikX = model.isDubbel
        ? binnenLinks + ((binnenBreedte / 2 - dierenluikBreedte) / 2)
        : ((binnenLinks + binnenRechts) / 2) - dierenluikBreedte / 2;
    final dierenluikSvg = model.heeftDierenluik
        ? '''
  <rect x="$dierenluikX" y="$dierenluikY" width="$dierenluikBreedte"
    height="$dierenluikHoogte" rx="2.8" fill="#E5E7EB"
    stroke="#111827" stroke-width="0.9"/>
  <path d="M ${dierenluikX + dierenluikBreedte * 0.18}
    ${dierenluikY + dierenluikHoogte * 0.31}
    Q ${dierenluikX + dierenluikBreedte / 2} ${dierenluikY + 1.5}
    ${dierenluikX + dierenluikBreedte * 0.82}
    ${dierenluikY + dierenluikHoogte * 0.31}"
    fill="none" stroke="#6B7280" stroke-width="0.65"/>
  <line x1="${dierenluikX + 3}" y1="${dierenluikY + dierenluikHoogte - 4}"
    x2="${dierenluikX + dierenluikBreedte - 3}"
    y2="${dierenluikY + dierenluikHoogte - 4}"
    stroke="#6B7280" stroke-width="0.65"/>
'''
        : '';

    final richtingSvg = model.isDubbel
        ? '''
  <line x1="${(deurLinks + deurRechts) / 2 - 4}"
    y1="$richtingY"
    x2="${deurLinks + profiel + 8}"
    y2="$richtingY"
    stroke="#596575" stroke-width="1.05"/>
  <path d="M ${deurLinks + profiel + 8} $richtingY
    l 6 -3.5 M ${deurLinks + profiel + 8} $richtingY
    l 6 3.5" fill="none" stroke="#596575" stroke-width="1.05"/>
  <line x1="${(deurLinks + deurRechts) / 2 + 4}"
    y1="$richtingY"
    x2="${deurRechts - profiel - 8}"
    y2="$richtingY"
    stroke="#596575" stroke-width="1.05"/>
  <path d="M ${deurRechts - profiel - 8} $richtingY
    l -6 -3.5 M ${deurRechts - profiel - 8} $richtingY
    l -6 3.5" fill="none" stroke="#596575" stroke-width="1.05"/>
'''
        : '''
  <line x1="${binnenLinks + 8}" y1="$richtingY"
    x2="${binnenRechts - 8}" y2="$richtingY"
    stroke="#596575" stroke-width="1.05"/>
  <path d="M ${binnenLinks + 8} $richtingY
    l 6 -3.5 M ${binnenLinks + 8} $richtingY
    l 6 3.5 M ${binnenRechts - 8} $richtingY
    l -6 -3.5 M ${binnenRechts - 8} $richtingY
    l -6 3.5" fill="none" stroke="#596575" stroke-width="1.05"/>
''';

    final deurMaatvoering = _buitenmaatSvg(
      buitenLinks: deurLinks,
      buitenRechts: deurRechts,
      buitenBoven: boven,
      buitenOnder: onder,
      hoogteMaatX: railRechts + 20,
    );
    final railMaatvoering = model.heeftRails
        ? _railmaatSvg(
            railLinks: railLinks,
            railRechts: railRechts,
            railBoven: boven,
          )
        : '';
    final breedteLabelX = (deurLinks + deurRechts) / 2;
    final breedteLabelY = onder + 24;
    final hoogteLabelX = railRechts + 27;
    final hoogteLabelY = (boven + onder) / 2;
    final railLabelX = (railLinks + railRechts) / 2;
    final railLabelY = boven - 16;

    final svg =
        '''
<svg xmlns="http://www.w3.org/2000/svg"
  width="$veiligeCanvasBreedte" height="$veiligeCanvasHoogte"
  viewBox="0 0 $veiligeCanvasBreedte $veiligeCanvasHoogte">
  $railsSvg
  $hoofdGaas
  $onderGaas
  <rect x="$deurLinks" y="$frameBoven" width="$deurGetekendeBreedte"
    height="$profiel" fill="#F3F4F6" stroke="#111827"
    stroke-width="1.0"/>
  <rect x="$deurLinks" y="${frameOnder - profiel}"
    width="$deurGetekendeBreedte" height="$profiel"
    fill="#F3F4F6" stroke="#111827" stroke-width="1.0"/>
  <rect x="$deurLinks" y="$frameBoven" width="$profiel"
    height="$frameHoogte" fill="#F3F4F6" stroke="#111827"
    stroke-width="1.0"/>
  <rect x="${deurRechts - profiel}" y="$frameBoven" width="$profiel"
    height="$frameHoogte" fill="#F3F4F6" stroke="#111827"
    stroke-width="1.0"/>
  $traversenSvg
  $middenStijl
  $plaatSvg
  $dierenluikSvg
  $richtingSvg
  <rect x="$deurLinks" y="$frameBoven" width="$deurGetekendeBreedte"
    height="$frameHoogte" fill="none" stroke="#111827"
    stroke-width="1.25"/>
  $deurMaatvoering
  $railMaatvoering
  <g>
    <rect x="${breedteLabelX - 27}" y="${breedteLabelY - 5}"
      width="54" height="10" rx="2" ry="2" fill="#FFFFFF"/>
    <text x="$breedteLabelX" y="${breedteLabelY + 2.2}"
      text-anchor="middle" font-size="6.7" font-weight="bold"
      fill="#22272D">${model.breedteMm} mm</text>
  </g>
  <g transform="translate($hoogteLabelX $hoogteLabelY) rotate(-90)">
    <rect x="-27" y="-5" width="54" height="10"
      rx="2" ry="2" fill="#FFFFFF"/>
    <text x="0" y="2.2" text-anchor="middle"
      font-size="6.7" font-weight="bold"
      fill="#22272D">${model.hoogteMm} mm</text>
  </g>
  ${model.heeftRails ? '''
  <g>
    <rect x="${railLabelX - 27}" y="${railLabelY - 5}"
      width="54" height="10" rx="2" ry="2" fill="#FFFFFF"/>
    <text x="$railLabelX" y="${railLabelY + 2.2}"
      text-anchor="middle" font-size="6.7" font-weight="bold"
      fill="#22272D">${model.railLengteMm} mm</text>
  </g>
''' : ''}
</svg>
''';

    return pw.SizedBox(
      width: veiligeCanvasBreedte,
      height: veiligeCanvasHoogte,
      child: pw.SvgImage(svg: svg),
    );
  }

  static String _gaasVulling({
    required String gaas,
    required double x,
    required double y,
    required double breedte,
    required double hoogte,
  }) {
    if (breedte <= 0.0 || hoogte <= 0.0) {
      return '';
    }

    final buffer = StringBuffer()
      ..writeln(
        '  <rect x="$x" y="$y" width="$breedte" height="$hoogte" '
        'fill="#FFFFFF"/>',
      );

    if (gaas == OpmetingSchuifvliegendeurModel.gaasGeen) {
      return buffer.toString();
    }

    // Zelfde fijne visuele maas als bij de Vaste inzethor. De stap is bewust
    // vast in SVG-eenheden en wordt niet uit de deurmaat of tekenschaal
    // berekend. Daardoor blijft het raster op iedere PDF even fijn.
    final stap = switch (gaas) {
      OpmetingSchuifvliegendeurModel.gaasPetscreenGrijs => 3.0,
      OpmetingSchuifvliegendeurModel.gaasPetscreenZwart => 3.0,
      _ => 3.5,
    };
    final kleur = switch (gaas) {
      OpmetingSchuifvliegendeurModel.gaasClearview => '#D6DEE7',
      OpmetingSchuifvliegendeurModel.gaasPetscreenGrijs => '#9CA3AF',
      OpmetingSchuifvliegendeurModel.gaasPetscreenZwart => '#66707C',
      OpmetingSchuifvliegendeurModel.gaasInox => '#A8B3BF',
      _ => '#CBD5E1',
    };
    final lijnDikte = switch (gaas) {
      OpmetingSchuifvliegendeurModel.gaasClearview => 0.20,
      OpmetingSchuifvliegendeurModel.gaasPetscreenGrijs => 0.34,
      OpmetingSchuifvliegendeurModel.gaasPetscreenZwart => 0.38,
      OpmetingSchuifvliegendeurModel.gaasInox => 0.28,
      _ => 0.28,
    };
    final rechts = x + breedte;
    final onder = y + hoogte;

    for (var lijnX = x + stap; lijnX < rechts; lijnX += stap) {
      buffer.writeln(
        '  <line x1="$lijnX" y1="$y" x2="$lijnX" y2="$onder" '
        'stroke="$kleur" stroke-width="$lijnDikte"/>',
      );
    }
    for (var lijnY = y + stap; lijnY < onder; lijnY += stap) {
      buffer.writeln(
        '  <line x1="$x" y1="$lijnY" x2="$rechts" y2="$lijnY" '
        'stroke="$kleur" stroke-width="$lijnDikte"/>',
      );
    }

    return buffer.toString();
  }

  static String _buitenmaatSvg({
    required double buitenLinks,
    required double buitenRechts,
    required double buitenBoven,
    required double buitenOnder,
    required double hoogteMaatX,
  }) {
    final y = buitenOnder + 24;
    final x = hoogteMaatX;

    return '''
  <line x1="$buitenLinks" y1="${buitenOnder + 5}" x2="$buitenLinks"
    y2="${y + 4}" stroke="#4B5563" stroke-width="0.8"/>
  <line x1="$buitenRechts" y1="${buitenOnder + 5}" x2="$buitenRechts"
    y2="${y + 4}" stroke="#4B5563" stroke-width="0.8"/>
  <line x1="$buitenLinks" y1="$y" x2="$buitenRechts" y2="$y"
    stroke="#4B5563" stroke-width="0.8"/>
  <path d="M $buitenLinks $y l 6 -3.5 M $buitenLinks $y l 6 3.5"
    stroke="#4B5563" stroke-width="0.8" fill="none"/>
  <path d="M $buitenRechts $y l -6 -3.5 M $buitenRechts $y l -6 3.5"
    stroke="#4B5563" stroke-width="0.8" fill="none"/>
  <line x1="${buitenRechts + 4}" y1="$buitenBoven" x2="${x + 4}"
    y2="$buitenBoven" stroke="#4B5563" stroke-width="0.8"/>
  <line x1="${buitenRechts + 4}" y1="$buitenOnder" x2="${x + 4}"
    y2="$buitenOnder" stroke="#4B5563" stroke-width="0.8"/>
  <line x1="$x" y1="$buitenBoven" x2="$x" y2="$buitenOnder"
    stroke="#4B5563" stroke-width="0.8"/>
  <path d="M $x $buitenBoven l -3.5 6 M $x $buitenBoven l 3.5 6"
    stroke="#4B5563" stroke-width="0.8" fill="none"/>
  <path d="M $x $buitenOnder l -3.5 -6 M $x $buitenOnder l 3.5 -6"
    stroke="#4B5563" stroke-width="0.8" fill="none"/>
''';
  }

  static String _railmaatSvg({
    required double railLinks,
    required double railRechts,
    required double railBoven,
  }) {
    final y = railBoven - 16;
    return '''
  <line x1="$railLinks" y1="${railBoven - 3}" x2="$railLinks"
    y2="${y - 4}" stroke="#4B5563" stroke-width="0.8"/>
  <line x1="$railRechts" y1="${railBoven - 3}" x2="$railRechts"
    y2="${y - 4}" stroke="#4B5563" stroke-width="0.8"/>
  <line x1="$railLinks" y1="$y" x2="$railRechts" y2="$y"
    stroke="#4B5563" stroke-width="0.8"/>
  <path d="M $railLinks $y l 6 -3.5 M $railLinks $y l 6 3.5"
    stroke="#4B5563" stroke-width="0.8" fill="none"/>
  <path d="M $railRechts $y l -6 -3.5 M $railRechts $y l -6 3.5"
    stroke="#4B5563" stroke-width="0.8" fill="none"/>
''';
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

class _SvgTraverseData {
  const _SvgTraverseData({required this.y, required this.hoogte});

  final double y;
  final double hoogte;
}
