// THIMACO-CONTROLE: VASTE-INZETHOR-PDF-GAAS-EN-LABELS-20260723
import 'dart:math' as math;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../opmeting/overzicht/opmeting_overzicht_model.dart';
import '../opmeting/toebehoren/vaste_inzethor/opmeting_vaste_inzethor_model.dart';
import 'offerte_pdf_artikel_layout_helper.dart';
import 'prijzen/offerte_prijs_berekening_service.dart';

class OffertePdfInzethorWidget {
  const OffertePdfInzethorWidget._();

  static const PdfColor oranje = OffertePdfArtikelLayoutHelper.oranje;
  static const PdfColor tekstDonker = OffertePdfArtikelLayoutHelper.tekstDonker;
  static const PdfColor tekstGrijs = OffertePdfArtikelLayoutHelper.tekstGrijs;
  static const PdfColor rand = OffertePdfArtikelLayoutHelper.rand;

  static const double basisPrijsRegelHoogte = 34;
  static const double basisOptiePrijsRegelHoogte = 78;
  static const double afzonderlijkePrijsregelHoogte = 18;

  static double berekenKolomHoogte(OpmetingOverzichtRaamItem positie) {
    final model = positie.vasteInzethorData;
    if (model == null) {
      return OffertePdfArtikelLayoutHelper.minimumKolomHoogte;
    }

    final regels = _technischeRegelsVoorOfferte(positie, model);

    return OffertePdfArtikelLayoutHelper.berekenTechnischeKolomHoogte(
      regels: regels,
      notities: positie.notities,
    );
  }

  static double berekenTotalePositieHoogte(
    OpmetingOverzichtRaamItem positie, {
    bool kortingToestaan = true,
    bool isOptie = false,
  }) {
    final model = positie.vasteInzethorData;
    final prijsHoogte = model == null
        ? basisPrijsRegelHoogte
        : _berekenPrijsSectieHoogte(
            model,
            kortingToestaan: kortingToestaan,
            isOptie: isOptie,
          );

    return OffertePdfArtikelLayoutHelper.berekenTotalePositieHoogte(
      kolomHoogte: berekenKolomHoogte(positie),
      prijsHoogte: prijsHoogte,
    );
  }

  static double _berekenPrijsSectieHoogte(
    OpmetingVasteInzethorModel model, {
    bool kortingToestaan = true,
    bool isOptie = false,
  }) {
    final resultaat = OffertePrijsBerekeningService.resultaatUitMomentopname(
      model,
      kortingToestaan: kortingToestaan,
    );
    final aantalRegels =
        resultaat.afzonderlijkePrijsregelsVoorOfferte.length +
        resultaat.omschrijvingZonderPrijsRegelsVoorOfferte.length;
    return (isOptie ? basisOptiePrijsRegelHoogte : basisPrijsRegelHoogte) +
        (aantalRegels * afzonderlijkePrijsregelHoogte);
  }

  static pw.Widget bouwPositie({
    required OpmetingOverzichtRaamItem positie,
    bool kortingToestaan = true,
    bool isOptie = false,
    double btwPercentage = 0.0,
    String btwRegelLabel = 'BTW',
  }) {
    final model = positie.vasteInzethorData;
    if (model == null) return pw.SizedBox();

    final regels = _technischeRegelsVoorOfferte(positie, model);
    final hoogte = berekenKolomHoogte(positie);

    return OffertePdfArtikelLayoutHelper.bouwArtikelLayout(
      kolomHoogte: hoogte,
      tekenvlak: OffertePdfArtikelLayoutHelper.bouwTekenvlak(
        hoogte: hoogte,
        maatTitel: model.maatSamenvattingTitel,
        maatWaarde: model.maatSamenvatting,
        tekening: _bouwHorTekening(
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
        legeTekst: 'Geen bijkomende technische gegevens.',
      ),
      prijsBlok: _bouwPrijsRegel(
        model,
        kortingToestaan: kortingToestaan,
        isOptie: isOptie,
        btwPercentage: btwPercentage,
        btwRegelLabel: btwRegelLabel,
      ),
    );
  }

  static pw.Widget _bouwPrijsRegel(
    OpmetingVasteInzethorModel model, {
    bool kortingToestaan = true,
    bool isOptie = false,
    double btwPercentage = 0.0,
    String btwRegelLabel = 'BTW',
  }) {
    final prijsResultaat =
        OffertePrijsBerekeningService.resultaatUitMomentopname(
          model,
          kortingToestaan: kortingToestaan,
        );
    final omschrijvingZonderPrijsRegels =
        prijsResultaat.omschrijvingZonderPrijsRegelsVoorOfferte;
    final afzonderlijkeRegels =
        prijsResultaat.afzonderlijkePrijsregelsVoorOfferte;
    final totaalVoorKorting =
        prijsResultaat.offerteTotaalExclBtw +
        (kortingToestaan ? prijsResultaat.kortingBedragExclBtw : 0.0);
    final optieTotaalExclBtw = prijsResultaat.offerteTotaalExclBtw;
    final optieBtw = _rondBedragAf(optieTotaalExclBtw * btwPercentage);
    final optieTotaalInclBtw = _rondBedragAf(optieTotaalExclBtw + optieBtw);
    final prijsSectieHoogte = _berekenPrijsSectieHoogte(
      model,
      kortingToestaan: kortingToestaan,
      isOptie: isOptie,
    );
    final heeftBijkomendeRegels =
        omschrijvingZonderPrijsRegels.isNotEmpty ||
        afzonderlijkeRegels.isNotEmpty;
    final heeftPrijsInvoer =
        prijsResultaat.basisTotaalExclBtw > 0.0 ||
        prijsResultaat.prijsregelsVoorOfferte.isNotEmpty;

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
              : const pw.Border(bottom: pw.BorderSide(color: rand, width: 0.5)),
        ),
        child: pw.Row(
          children: <pw.Widget>[
            pw.Expanded(
              child: pw.Text(
                omschrijving,
                maxLines: 2,
                style: pw.TextStyle(
                  color: benadrukt ? tekstDonker : tekstGrijs,
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
                color: benadrukt ? oranje : tekstDonker,
                fontSize: benadrukt ? 10.8 : 7.6,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return pw.Container(
      height: prijsSectieHoogte,
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(7),
        border: pw.Border.all(color: rand, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: <pw.Widget>[
          for (final prijsregel in omschrijvingZonderPrijsRegels)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Text(
                prijsregel.omschrijving,
                maxLines: 1,
                style: const pw.TextStyle(color: tekstGrijs, fontSize: 7.2),
              ),
            ),
          for (final prijsregel in afzonderlijkeRegels)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Row(
                children: <pw.Widget>[
                  pw.Expanded(
                    child: pw.Text(
                      prijsregel.omschrijving,
                      maxLines: 1,
                      style: const pw.TextStyle(
                        color: tekstGrijs,
                        fontSize: 7.2,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    '€ ${_bedragMetPunt(prijsregel.totaalExclBtw)}',
                    style: pw.TextStyle(
                      color: tekstDonker,
                      fontSize: 7.4,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          if (heeftBijkomendeRegels) ...<pw.Widget>[
            pw.Container(height: 0.5, color: rand),
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
                      color: tekstDonker,
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
                    style: const pw.TextStyle(color: tekstGrijs, fontSize: 7.4),
                  )
                else
                  pw.RichText(
                    textAlign: pw.TextAlign.right,
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text: '€ ${_bedragMetPunt(totaalVoorKorting)}',
                          style: pw.TextStyle(
                            color: tekstDonker,
                            fontSize: 12.2,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.TextSpan(
                          text: ' excl. btw',
                          style: const pw.TextStyle(
                            color: tekstGrijs,
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

  static List<OffertePdfTechnischeRegel> _technischeRegelsVoorOfferte(
    OpmetingOverzichtRaamItem positie,
    OpmetingVasteInzethorModel model,
  ) {
    const nietOpOfferte = <String>{'breedte', 'hoogte'};
    final bron = positie.zichtbareTechnischeRegels.isNotEmpty
        ? positie.zichtbareTechnischeRegels
              .map(
                (regel) => OffertePdfTechnischeRegel(
                  titel: regel.titel,
                  waarde: regel.waarde,
                ),
              )
              .toList(growable: false)
        : _maakRegelsUitModel(model);

    final resultaat = <OffertePdfTechnischeRegel>[];
    final gebruikteTitels = <String>{};

    for (final regel in bron) {
      final titelSleutel = regel.titel.trim().toLowerCase();
      if (nietOpOfferte.contains(titelSleutel)) {
        continue;
      }

      final netteRegel = _normaliseerTechnischeRegelVoorOfferte(
        regel: regel,
        model: model,
      );
      final netteTitelSleutel = netteRegel.titel.trim().toLowerCase();

      if (netteTitelSleutel.isEmpty ||
          netteRegel.waarde.trim().isEmpty ||
          !gebruikteTitels.add(netteTitelSleutel)) {
        continue;
      }

      resultaat.add(netteRegel);
    }

    return List<OffertePdfTechnischeRegel>.unmodifiable(resultaat);
  }

  static OffertePdfTechnischeRegel _normaliseerTechnischeRegelVoorOfferte({
    required OffertePdfTechnischeRegel regel,
    required OpmetingVasteInzethorModel model,
  }) {
    final titelSleutel = regel.titel.trim().toLowerCase();

    if (titelSleutel == 'kleur' ||
        titelSleutel == 'projectkleur' ||
        titelSleutel == 'ral-kleur toebehoren') {
      if (model.isProjectkleur) {
        final projectkleur = model.ralKleurToebehorenWaarde.trim();
        return OffertePdfTechnischeRegel(
          titel: OpmetingVasteInzethorModel.kleurProjectLabel,
          waarde: projectkleur.isEmpty ? 'Nog niet ingevuld' : projectkleur,
        );
      }

      return OffertePdfTechnischeRegel(
        titel: 'Kleur',
        waarde: model.kleurVoorOverzicht,
      );
    }

    if (titelSleutel == 'gaas') {
      return OffertePdfTechnischeRegel(
        titel: 'Gaas',
        waarde: model.gaasVoorWeergave,
      );
    }

    if (titelSleutel == 'soort clipsen') {
      return OffertePdfTechnischeRegel(
        titel: 'Soort clipsen',
        waarde: model.soortClipsen,
      );
    }

    if (titelSleutel == 'soort bevestiging') {
      return OffertePdfTechnischeRegel(
        titel: 'Soort bevestiging',
        waarde: model.soortBevestigingVoorWeergave,
      );
    }

    return OffertePdfTechnischeRegel(
      titel: regel.titel.trim(),
      waarde: regel.waarde.trim(),
    );
  }

  static List<OffertePdfTechnischeRegel> _maakRegelsUitModel(
    OpmetingVasteInzethorModel model,
  ) {
    final regels = <OffertePdfTechnischeRegel>[];
    void voegToe(String titel, String waarde) {
      if (waarde.trim().isNotEmpty) {
        regels.add(
          OffertePdfTechnischeRegel(titel: titel, waarde: waarde.trim()),
        );
      }
    }

    voegToe('Stuk referentie', model.stukReferentie);
    voegToe('Aantal', '${model.aantal}');
    voegToe('Soort', model.soort);
    if (model.isInzetvliegenraam) {
      voegToe('Speling', model.speling);
      if (model.isVr033Ultra) {
        voegToe('Flens diepte', model.flensDiepteVoorOverzicht);
        if (model.isFlensOpMaat) {
          voegToe('Maat rand flens', model.maatRandFlens);
        }
      }
    }
    voegToe('Profiel', model.profiel);
    voegToe('Maatsoort', model.maatType);
    voegToe('Traversen', model.traverseType);
    final posities = model.actieveTraversePositiesMm;
    voegToe('Aantal traversen', '${posities.length}');
    for (var index = 0; index < posities.length; index++) {
      voegToe('Traverse ${index + 1}', '${_formatteerMm(posities[index])} mm');
    }
    if (model.isProjectkleur) {
      final projectkleur = model.ralKleurToebehorenWaarde.trim();
      voegToe(
        OpmetingVasteInzethorModel.kleurProjectLabel,
        projectkleur.isEmpty ? 'Nog niet ingevuld' : projectkleur,
      );
    } else {
      voegToe('Kleur', model.kleurVoorOverzicht);
    }
    voegToe('Gaas', model.gaasVoorWeergave);
    voegToe('Kleur pees', model.kleurPees);
    voegToe('Borstels', model.borstels);
    voegToe('Bevestiging', model.bevestiging);
    if (model.heeftClipsen) {
      voegToe('Soort clipsen', model.soortClipsen);
      voegToe('Soort bevestiging', model.soortBevestigingVoorWeergave);
    }
    return regels;
  }

  static String _formatteerMm(double waarde) {
    if (waarde == waarde.roundToDouble()) return waarde.round().toString();
    return waarde.toStringAsFixed(1);
  }

  static pw.Widget _bouwHorTekening(
    OpmetingVasteInzethorModel model, {
    required double canvasBreedte,
    required double canvasHoogte,
  }) {
    final veiligeCanvasBreedte = math.max(150.0, canvasBreedte).toDouble();
    final veiligeCanvasHoogte = math.max(150.0, canvasHoogte).toDouble();

    const margeBoven = 20.0;
    final margeRechts = model.isBinnenmaat ? 18.0 : 29.0;
    final margeOnder = model.isBinnenmaat ? 20.0 : 54.0;
    final margeLinks = model.isBinnenmaat ? 18.0 : 58.0;

    final buitenBreedte = model.buitenBreedteMm.clamp(1, 100000).toDouble();
    final buitenHoogte = model.buitenHoogteMm.clamp(1, 100000).toDouble();

    final beschikbareBreedte = math
        .max(40.0, veiligeCanvasBreedte - margeLinks - margeRechts)
        .toDouble();
    final beschikbareHoogte = math
        .max(40.0, veiligeCanvasHoogte - margeBoven - margeOnder)
        .toDouble();
    final schaalX = beschikbareBreedte / buitenBreedte;
    final schaalY = beschikbareHoogte / buitenHoogte;
    final schaal = math.min(schaalX, schaalY);

    final getekendeBreedte = buitenBreedte * schaal;
    final getekendeHoogte = buitenHoogte * schaal;
    final links = margeLinks + ((beschikbareBreedte - getekendeBreedte) / 2);
    final boven = margeBoven + ((beschikbareHoogte - getekendeHoogte) / 2);

    final profiel = model.profielAanzichtMm * schaal;
    final traverseHoogte = math
        .max(1.2, model.traverseAanzichtMm * schaal)
        .toDouble();

    final buitenRechts = links + getekendeBreedte;
    final buitenOnder = boven + getekendeHoogte;
    final binnenLinks = links + profiel;
    final binnenBoven = boven + profiel;
    final binnenRechts = buitenRechts - profiel;
    final binnenOnder = buitenOnder - profiel;
    final binnenBreedte = math.max(2.0, binnenRechts - binnenLinks).toDouble();
    final binnenHoogte = math.max(2.0, binnenOnder - binnenBoven).toDouble();

    final gaasPatroon = _bouwGaasSvgPatroon(model: model, schaal: schaal);

    final traversen = StringBuffer();

    for (final positieMm in model.actieveTraversePositiesMm) {
      final verhouding = (positieMm / model.hoogteMm)
          .clamp(0.0, 1.0)
          .toDouble();
      final y = binnenOnder - (binnenHoogte * verhouding);

      traversen.write('''
  <rect x="$binnenLinks" y="${y - (traverseHoogte / 2)}"
    width="$binnenBreedte" height="$traverseHoogte"
    fill="#F3F4F6" stroke="#111827" stroke-width="1.0"/>
''');
    }

    final maatvoering = model.isBinnenmaat
        ? _binnenmaatSvg(
            binnenLinks: binnenLinks,
            binnenRechts: binnenRechts,
            binnenBoven: binnenBoven,
            binnenOnder: binnenOnder,
          )
        : _buitenmaatSvg(
            buitenLinks: links,
            buitenRechts: buitenRechts,
            buitenBoven: boven,
            buitenOnder: buitenOnder,
          );

    final svg =
        '''
<svg xmlns="http://www.w3.org/2000/svg"
  width="$veiligeCanvasBreedte"
  height="$veiligeCanvasHoogte"
  viewBox="0 0 $veiligeCanvasBreedte $veiligeCanvasHoogte">
  <defs>
    ${gaasPatroon.definitie}
  </defs>
  <rect x="$links" y="$boven"
    width="$getekendeBreedte" height="$getekendeHoogte"
    fill="#F3F4F6"/>
  <rect x="$binnenLinks" y="$binnenBoven"
    width="$binnenBreedte" height="$binnenHoogte"
    fill="${gaasPatroon.vulling}"/>
  $traversen
  <rect x="$links" y="$boven"
    width="$getekendeBreedte" height="$getekendeHoogte"
    fill="none" stroke="#111827" stroke-width="1.25"/>
  <rect x="$binnenLinks" y="$binnenBoven"
    width="$binnenBreedte" height="$binnenHoogte"
    fill="none" stroke="#111827" stroke-width="1.25"/>
  <line x1="$links" y1="$boven" x2="$binnenLinks" y2="$binnenBoven"
    stroke="#111827" stroke-width="0.95"/>
  <line x1="$buitenRechts" y1="$boven" x2="$binnenRechts" y2="$binnenBoven"
    stroke="#111827" stroke-width="0.95"/>
  <line x1="$links" y1="$buitenOnder" x2="$binnenLinks" y2="$binnenOnder"
    stroke="#111827" stroke-width="0.95"/>
  <line x1="$buitenRechts" y1="$buitenOnder" x2="$binnenRechts" y2="$binnenOnder"
    stroke="#111827" stroke-width="0.95"/>
  $maatvoering
</svg>
''';

    final breedteLabelY = model.isBinnenmaat
        ? binnenOnder - 18
        : buitenOnder + 30;
    final breedteLabelX = model.isBinnenmaat
        ? (binnenLinks + binnenRechts) / 2
        : (links + buitenRechts) / 2;
    final hoogteLabelX = model.isBinnenmaat ? binnenLinks + 18 : links - 38;
    final hoogteLabelY = model.isBinnenmaat
        ? (binnenBoven + binnenOnder) / 2
        : (boven + buitenOnder) / 2;

    return pw.SizedBox(
      width: veiligeCanvasBreedte,
      height: veiligeCanvasHoogte,
      child: pw.Stack(
        fit: pw.StackFit.expand,
        children: <pw.Widget>[
          pw.SvgImage(svg: svg),
          pw.Positioned(
            left: breedteLabelX - 31,
            top: breedteLabelY - 6,
            child: _maatLabel('${model.breedteMm} mm', width: 62),
          ),
          pw.Positioned(
            left: hoogteLabelX - 31,
            top: hoogteLabelY - 6,
            child: pw.Transform.rotate(
              angle: -math.pi / 2,
              child: _maatLabel('${model.hoogteMm} mm', width: 62),
            ),
          ),
        ],
      ),
    );
  }

  static _GaasSvgPatroon _bouwGaasSvgPatroon({
    required OpmetingVasteInzethorModel model,
    required double schaal,
  }) {
    if (!model.heeftGaas) {
      return const _GaasSvgPatroon(definitie: '', vulling: '#FCFCFD');
    }

    if (model.isGaasClearview) {
      final stap = math.max(5.0, 18 * schaal).toDouble();
      final stapX = stap * 1.25;
      return _GaasSvgPatroon(
        definitie:
            '''
    <pattern id="mesh" width="$stapX" height="$stap" patternUnits="userSpaceOnUse">
      <path d="M 0 0 L $stapX 0 M 0 0 L 0 $stap"
        fill="none" stroke="#AAB8C7" stroke-width="0.32"/>
    </pattern>
''',
        vulling: 'url(#mesh)',
      );
    }

    if (model.isGaasPetscreenZwart ||
        model.isGaasPetscreenGrijs ||
        model.isGaasPetscreen) {
      final stap = math.max(3.2, 9 * schaal).toDouble();
      final patroonStap = stap * 2;
      final achtergrond = model.isGaasPetscreenZwart ? '#F1F2F3' : '#F4F5F6';
      final lijnkleur = model.isGaasPetscreenZwart ? '#374151' : '#7A838F';

      return _GaasSvgPatroon(
        definitie:
            '''
    <pattern id="mesh" width="$patroonStap" height="$patroonStap" patternUnits="userSpaceOnUse">
      <rect width="$patroonStap" height="$patroonStap" fill="$achtergrond"/>
      <path d="M 0 0 L $patroonStap 0 M 0 $stap L $patroonStap $stap M 0 0 L 0 $patroonStap M $stap 0 L $stap $patroonStap"
        fill="none" stroke="$lijnkleur" stroke-width="0.72"/>
      <path d="M 0 $patroonStap L $patroonStap 0"
        fill="none" stroke="$lijnkleur" stroke-width="0.35"/>
    </pattern>
''',
        vulling: 'url(#mesh)',
      );
    }

    if (model.isGaasInox) {
      final stap = math.max(4.0, 13 * schaal).toDouble();
      return _GaasSvgPatroon(
        definitie:
            '''
    <pattern id="mesh" width="$stap" height="$stap" patternUnits="userSpaceOnUse">
      <rect width="$stap" height="$stap" fill="#F5F6F7"/>
      <path d="M 0 $stap L $stap 0"
        fill="none" stroke="#9AA3AE" stroke-width="0.55"/>
      <path d="M 0 0 L $stap $stap"
        fill="none" stroke="#66707C" stroke-width="0.48"/>
    </pattern>
''',
        vulling: 'url(#mesh)',
      );
    }

    final stap = math.max(3.5, 12 * schaal).toDouble();
    return _GaasSvgPatroon(
      definitie:
          '''
    <pattern id="mesh" width="$stap" height="$stap" patternUnits="userSpaceOnUse">
      <path d="M 0 0 L $stap 0 M 0 0 L 0 $stap"
        fill="none" stroke="#BFC8D3" stroke-width="0.45"/>
    </pattern>
''',
      vulling: 'url(#mesh)',
    );
  }

  static pw.Widget _maatLabel(String tekst, {required double width}) {
    return pw.Container(
      width: width,
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(2),
      ),
      child: pw.Text(
        tekst,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          color: tekstDonker,
          fontSize: 7.2,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static String _binnenmaatSvg({
    required double binnenLinks,
    required double binnenRechts,
    required double binnenBoven,
    required double binnenOnder,
  }) {
    final y = binnenOnder - 18;
    final x = binnenLinks + 18;

    return '''
  <line x1="${binnenLinks + 4}" y1="$y" x2="${binnenRechts - 4}" y2="$y"
    stroke="#4B5563" stroke-width="0.9"/>
  <path d="M ${binnenLinks + 4} $y l 7 -4 M ${binnenLinks + 4} $y l 7 4"
    stroke="#4B5563" stroke-width="0.9" fill="none"/>
  <path d="M ${binnenRechts - 4} $y l -7 -4 M ${binnenRechts - 4} $y l -7 4"
    stroke="#4B5563" stroke-width="0.9" fill="none"/>
  <line x1="$x" y1="${binnenBoven + 4}" x2="$x" y2="${binnenOnder - 4}"
    stroke="#4B5563" stroke-width="0.9"/>
  <path d="M $x ${binnenBoven + 4} l -4 7 M $x ${binnenBoven + 4} l 4 7"
    stroke="#4B5563" stroke-width="0.9" fill="none"/>
  <path d="M $x ${binnenOnder - 4} l -4 -7 M $x ${binnenOnder - 4} l 4 -7"
    stroke="#4B5563" stroke-width="0.9" fill="none"/>
''';
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
  <line x1="$buitenLinks" y1="${buitenOnder + 6}" x2="$buitenLinks" y2="${y + 5}"
    stroke="#4B5563" stroke-width="0.9"/>
  <line x1="$buitenRechts" y1="${buitenOnder + 6}" x2="$buitenRechts" y2="${y + 5}"
    stroke="#4B5563" stroke-width="0.9"/>
  <line x1="$buitenLinks" y1="$y" x2="$buitenRechts" y2="$y"
    stroke="#4B5563" stroke-width="0.9"/>
  <path d="M $buitenLinks $y l 7 -4 M $buitenLinks $y l 7 4"
    stroke="#4B5563" stroke-width="0.9" fill="none"/>
  <path d="M $buitenRechts $y l -7 -4 M $buitenRechts $y l -7 4"
    stroke="#4B5563" stroke-width="0.9" fill="none"/>
  <line x1="${x - 5}" y1="$buitenBoven" x2="${buitenLinks - 6}" y2="$buitenBoven"
    stroke="#4B5563" stroke-width="0.9"/>
  <line x1="${x - 5}" y1="$buitenOnder" x2="${buitenLinks - 6}" y2="$buitenOnder"
    stroke="#4B5563" stroke-width="0.9"/>
  <line x1="$x" y1="$buitenBoven" x2="$x" y2="$buitenOnder"
    stroke="#4B5563" stroke-width="0.9"/>
  <path d="M $x $buitenBoven l -4 7 M $x $buitenBoven l 4 7"
    stroke="#4B5563" stroke-width="0.9" fill="none"/>
  <path d="M $x $buitenOnder l -4 -7 M $x $buitenOnder l 4 -7"
    stroke="#4B5563" stroke-width="0.9" fill="none"/>
''';
  }
}

class _GaasSvgPatroon {
  const _GaasSvgPatroon({required this.definitie, required this.vulling});

  final String definitie;
  final String vulling;
}
