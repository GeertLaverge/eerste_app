// THIMACO-CONTROLE: VLIEGENDEUR-PDF-FIJN-GAAS-VASTE-STAP-20260728-1215
import 'dart:math' as math;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../opmeting/overzicht/opmeting_overzicht_model.dart';
import '../opmeting/toebehoren/vliegendeur/opmeting_vliegendeur_model.dart';
import 'offerte_pdf_artikel_layout_helper.dart';
import 'prijzen/offerte_artikel_prijs_koppeling_service.dart';
import 'prijzen/offerte_berekening_resultaat.dart';
import 'prijzen/offerte_prijsregel_weergave_service.dart';

class OffertePdfVliegendeurWidget {
  const OffertePdfVliegendeurWidget._();

  static String _notitiesVoorPdf(
    OpmetingOverzichtRaamItem positie,
    OpmetingVliegendeurModel model,
  ) {
    final overzichtNotities = positie.notities.trim();
    if (overzichtNotities.isNotEmpty) {
      return overzichtNotities;
    }
    return model.notities.trim();
  }

  static double berekenKolomHoogte(OpmetingOverzichtRaamItem positie) {
    final model = positie.vliegendeurData;
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

  static const double _basisPrijsRegelHoogte = 34;
  static const double _basisOptiePrijsRegelHoogte = 78;

  static double berekenTotalePositieHoogte(
    OpmetingOverzichtRaamItem positie, {
    bool kortingToestaan = true,
    bool isOptie = false,
  }) {
    return OffertePdfArtikelLayoutHelper.berekenTotalePositieHoogte(
      kolomHoogte: berekenKolomHoogte(positie),
      prijsHoogte: _berekenPrijsSectieHoogte(
        positie,
        kortingToestaan: kortingToestaan && !isOptie,
        isOptie: isOptie,
      ),
    );
  }

  static pw.Widget bouwPositie({
    required OpmetingOverzichtRaamItem positie,
    bool kortingToestaan = true,
    bool isOptie = false,
    double btwPercentage = 0.0,
    String btwRegelLabel = 'BTW',
  }) {
    final model = positie.vliegendeurData;
    if (model == null) return pw.SizedBox();

    final hoogte = berekenKolomHoogte(positie);
    final regels = _technischeRegelsVoorOfferte(positie, model);

    return OffertePdfArtikelLayoutHelper.bouwArtikelLayout(
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

  static double _berekenPrijsSectieHoogte(
    OpmetingOverzichtRaamItem positie, {
    required bool kortingToestaan,
    required bool isOptie,
  }) {
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
      height: _berekenPrijsSectieHoogte(
        positie,
        kortingToestaan: kortingToestaanEffectief,
        isOptie: isOptie,
      ),
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
    if (!waarde.isFinite || waarde <= 0.0) return 0.0;
    return (waarde * 100.0).roundToDouble() / 100.0;
  }

  static String _bedragMetPunt(double waarde) {
    return waarde.toStringAsFixed(2);
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
      if (titel.isEmpty && waarde.isEmpty) continue;
      if (_isAfmetingsRegel(titel)) continue;

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

    final traverseYPosities = <double>[];
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
      traverseYPosities.add(y);
      traversen.write('''
  <rect x="$deurLinks" y="$y" width="$deurBreedte"
    height="$traverseHoogte" fill="#F3F4F6"
    stroke="#111827" stroke-width="1.0"/>
''');
    }

    traverseYPosities.sort();
    final ondersteTraverseY = traverseYPosities.isEmpty
        ? null
        : traverseYPosities.last;
    final hoofdGaas = _bouwGaasRasterSvg(
      gaas: model.gaas,
      x: binnenLinks,
      y: binnenBoven,
      breedte: binnenBreedte,
      hoogte: binnenHoogte,
    );
    final onderGaas = ondersteTraverseY == null
        ? ''
        : _bouwGaasRasterSvg(
            gaas: model.gaasOnderT1,
            x: binnenLinks,
            y: ondersteTraverseY + traverseHoogte,
            breedte: binnenBreedte,
            hoogte: math
                .max(0.0, binnenOnder - ondersteTraverseY - traverseHoogte)
                .toDouble(),
          );

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
  $hoofdGaas
  $onderGaas
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

  static String _bouwGaasRasterSvg({
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

    // Zelfde fijne visuele maas als bij de Vaste inzethor. De stap is bewust
    // vast in SVG-eenheden en wordt niet uit de deurmaat of tekenschaal
    // berekend. Daardoor blijft het raster op iedere PDF even fijn.
    final stap = switch (gaas) {
      OpmetingVliegendeurModel.gaasPetscreenGrijs => 3.0,
      OpmetingVliegendeurModel.gaasPetscreenZwart => 3.0,
      _ => 3.5,
    };
    final kleur = switch (gaas) {
      OpmetingVliegendeurModel.gaasClearview => '#D6DEE7',
      OpmetingVliegendeurModel.gaasPetscreenGrijs => '#9CA3AF',
      OpmetingVliegendeurModel.gaasPetscreenZwart => '#66707C',
      _ => '#CBD5E1',
    };
    final lijnDikte = switch (gaas) {
      OpmetingVliegendeurModel.gaasClearview => 0.20,
      OpmetingVliegendeurModel.gaasPetscreenGrijs => 0.34,
      OpmetingVliegendeurModel.gaasPetscreenZwart => 0.38,
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
