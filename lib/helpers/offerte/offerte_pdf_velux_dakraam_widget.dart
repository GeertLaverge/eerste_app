// THIMACO-CONTROLE: VELUX-PDF-DRAAIRICHTING-EN-GEEN-STUKPRIJS-20260730
// THIMACO-CONTROLE: VELUX-KLANTOMSCHRIJVING-VERKOOPPRIJS-20260730
// THIMACO-CONTROLE: VELUX-DAKRAAM-PDF-WIDGET-FASE-3-20260729-2212
import 'dart:math' as math;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../opmeting/overzicht/opmeting_overzicht_model.dart';
import '../opmeting/toebehoren/velux_dakramen/opmeting_velux_dakraam_model.dart';
import '../opmeting/toebehoren/velux_dakramen/opmeting_velux_dakraam_omschrijving_helper.dart';
import 'offerte_pdf_artikel_layout_helper.dart';
import 'prijzen/offerte_artikel_prijs_koppeling_service.dart';
import 'prijzen/offerte_berekening_resultaat.dart';
import 'prijzen/offerte_prijsregel_weergave_service.dart';

class OffertePdfVeluxDakraamWidget {
  const OffertePdfVeluxDakraamWidget._();

  static const double _basisPrijsRegelHoogte = 34;
  static const double _basisOptiePrijsRegelHoogte = 78;

  static String titelVoorPositie(OpmetingOverzichtRaamItem positie) {
    final model = positie.veluxDakraamData;
    if (model == null) {
      return positie.formulierTypeLabel;
    }
    if (model.alleenToebehoren) {
      return 'Velux accessoires';
    }
    return 'Velux ${model.productCode} · ${model.maatCode} · '
        '${_afmetingCm(model)}';
  }

  static String _notitiesVoorPdf(
    OpmetingOverzichtRaamItem positie,
    OpmetingVeluxDakraamModel model,
  ) {
    final overzichtNotities = positie.notities.trim();
    if (overzichtNotities.isNotEmpty) {
      return overzichtNotities;
    }
    return model.notities.trim();
  }

  static double berekenKolomHoogte(OpmetingOverzichtRaamItem positie) {
    final model = positie.veluxDakraamData;
    if (model == null) {
      return OffertePdfArtikelLayoutHelper.minimumKolomHoogte;
    }

    final notities = _notitiesVoorPdf(positie, model);

    final basisHoogte =
        OffertePdfArtikelLayoutHelper.berekenTechnischeKolomHoogte(
          regels: _regelsVoorOfferte(positie, model),
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
    final model = positie.veluxDakraamData;
    if (model == null) {
      return pw.SizedBox();
    }

    final hoogte = berekenKolomHoogte(positie);
    final regels = _regelsVoorOfferte(positie, model);

    return OffertePdfArtikelLayoutHelper.bouwArtikelLayout(
      kolomHoogte: hoogte,
      tekenvlak: OffertePdfArtikelLayoutHelper.bouwTekenvlak(
        hoogte: hoogte,
        maatTitel: model.alleenToebehoren
            ? 'Velux accessoires'
            : 'Velux ${model.productCode}',
        maatWaarde: model.alleenToebehoren
            ? 'Catalogus ${model.catalogusJaar}'
            : '· ${model.maatCode} · ${_afmetingCm(model)}',
        tekening: _bouwVeluxTekening(
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
        legeTekst: 'Geen Velux-catalogusartikelen gekozen.',
      ),
      prijsBlok: _bouwPrijsBlok(
        positie,
        kortingToestaan: false,
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

  static List<OffertePdfTechnischeRegel> _regelsVoorOfferte(
    OpmetingOverzichtRaamItem positie,
    OpmetingVeluxDakraamModel model,
  ) {
    final resultaat = <OffertePdfTechnischeRegel>[
      for (final regel in _catalogusRegels(model))
        OffertePdfTechnischeRegel(
          titel: OpmetingVeluxDakraamOmschrijvingHelper.metAantal(
            regel.omschrijving,
            regel.aantal,
          ),
          waarde: '',
          prijsTekst: '€ ${_bedragMetPunt(regel.totaalExclBtw)}',
        ),
    ];

    final prijsResultaat = _prijsResultaatVoor(positie, kortingToestaan: false);
    if (prijsResultaat != null) {
      _voegTechnischePrijsregelsToe(
        resultaat: resultaat,
        prijsResultaat: prijsResultaat,
        aantal: model.veiligAantal,
      );
      _voegVrijeArtikelPrijsregelsToe(
        resultaat: resultaat,
        prijsResultaat: prijsResultaat,
      );
    }

    return OffertePdfArtikelLayoutHelper.combineerTechnischeRegels(resultaat);
  }

  static List<_VeluxCatalogusRegel> _catalogusRegels(
    OpmetingVeluxDakraamModel model,
  ) {
    final regels = <_VeluxCatalogusRegel>[];

    void voegToe({
      required String omschrijving,
      required int aantal,
      required double prijsPerStukExclBtw,
    }) {
      if (omschrijving.trim().isEmpty || aantal < 1) {
        return;
      }
      regels.add(
        _VeluxCatalogusRegel(
          omschrijving: omschrijving.trim(),
          aantal: aantal,
          prijsPerStukExclBtw: prijsPerStukExclBtw,
        ),
      );
    }

    if (!model.alleenToebehoren) {
      voegToe(
        omschrijving: OpmetingVeluxDakraamOmschrijvingHelper.dakvenster(model),
        aantal: model.veiligAantal,
        prijsPerStukExclBtw: model.basisPrijsPerStukExclBtw,
      );
      if (model.gootstukType != OpmetingVeluxGootstukType.geen) {
        voegToe(
          omschrijving: OpmetingVeluxDakraamOmschrijvingHelper.gootstukken(
            model,
          ),
          aantal: model.veiligAantal,
          prijsPerStukExclBtw: model.gootstukPrijsPerStukExclBtw,
        );
      }
    }

    if (model.rolluikType != OpmetingVeluxRolluikType.geen) {
      voegToe(
        omschrijving: OpmetingVeluxDakraamOmschrijvingHelper.rolluik(model),
        aantal: model.effectiefRolluikAantal,
        prijsPerStukExclBtw: model.rolluikPrijsPerStukExclBtw,
      );
    }
    if (model.screenType != OpmetingVeluxScreenType.geen) {
      voegToe(
        omschrijving: OpmetingVeluxDakraamOmschrijvingHelper.buitenscherm(
          model,
        ),
        aantal: model.effectiefScreenAantal,
        prijsPerStukExclBtw: model.screenPrijsPerStukExclBtw,
      );
    }
    if (model.verduisteringsgordijnDkl) {
      voegToe(
        omschrijving:
            OpmetingVeluxDakraamOmschrijvingHelper.verduisteringsgordijn(model),
        aantal: model.effectiefDklAantal,
        prijsPerStukExclBtw: model.dklPrijsPerStukExclBtw,
      );
    }
    if (model.muggengaas) {
      voegToe(
        omschrijving: OpmetingVeluxDakraamOmschrijvingHelper.muggengaas(model),
        aantal: model.effectiefMuggengaasAantal,
        prijsPerStukExclBtw: model.muggengaasPrijsPerStukExclBtw,
      );
    }
    if (model.kux110) {
      voegToe(
        omschrijving:
            OpmetingVeluxDakraamOmschrijvingHelper.stroomvoorziening(),
        aantal: model.kuxAantal.clamp(1, 99).toInt(),
        prijsPerStukExclBtw: model.kuxPrijsPerStukExclBtw,
      );
    }
    return List<_VeluxCatalogusRegel>.unmodifiable(regels);
  }

  static void _voegTechnischePrijsregelsToe({
    required List<OffertePdfTechnischeRegel> resultaat,
    required OfferteBerekeningResultaat prijsResultaat,
    required int aantal,
  }) {
    for (final prijsregel in prijsResultaat.technischePrijsregels) {
      if (!prijsregel.isGeldig || prijsregel.totaalExclBtw <= 0.0) {
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
          titel: OpmetingVeluxDakraamOmschrijvingHelper.metAantal(
            omschrijving,
            aantal,
          ),
          waarde: '',
          prijsTekst: toonPrijs
              ? '€ ${_bedragMetPunt(prijsregel.totaalExclBtw)}'
              : '',
        ),
      );
    }
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

  static pw.Widget _bouwVeluxTekening(
    OpmetingVeluxDakraamModel model, {
    required double canvasBreedte,
    required double canvasHoogte,
  }) {
    final breedte = math.max(150.0, canvasBreedte).toDouble();
    final hoogte = math.max(130.0, canvasHoogte).toDouble();
    final svg = model.alleenToebehoren
        ? _bouwAccessoiresSvg(breedte: breedte, hoogte: hoogte)
        : _bouwDakraamSvg(model, breedte: breedte, hoogte: hoogte);

    return pw.SizedBox(
      width: breedte,
      height: hoogte,
      child: pw.SvgImage(svg: svg),
    );
  }

  static String _bouwAccessoiresSvg({
    required double breedte,
    required double hoogte,
  }) {
    return '''
<svg xmlns="http://www.w3.org/2000/svg" width="$breedte" height="$hoogte" viewBox="0 0 $breedte $hoogte">
  <rect x="18" y="18" width="${_n(breedte - 36)}" height="${_n(hoogte - 36)}" rx="9" fill="#F8FAFC" stroke="#CBD5E1" stroke-width="1"/>
  <path d="M ${_n(breedte / 2 - 24)} ${_n(hoogte / 2 + 6)} L ${_n(breedte / 2)} ${_n(hoogte / 2 - 18)} L ${_n(breedte / 2 + 24)} ${_n(hoogte / 2 + 6)}" fill="none" stroke="#0B7A3B" stroke-width="2"/>
  <rect x="${_n(breedte / 2 - 18)}" y="${_n(hoogte / 2 + 6)}" width="36" height="28" fill="#E7F6EC" stroke="#0B7A3B" stroke-width="1.2"/>
  <text x="${_n(breedte / 2)}" y="${_n(hoogte / 2 + 55)}" text-anchor="middle" font-size="8" font-weight="700" fill="#374151">Alleen Velux-toebehoren</text>
</svg>
''';
  }

  static String _bouwDakraamSvg(
    OpmetingVeluxDakraamModel model, {
    required double breedte,
    required double hoogte,
  }) {
    const margeLinks = 38.0;
    const margeRechts = 48.0;
    const margeBoven = 26.0;
    const margeOnder = 38.0;
    final bronBreedte = math.max(100, model.breedteMm);
    final bronHoogte = math.max(100, model.hoogteMm);
    final schaal = math.min(
      (breedte - margeLinks - margeRechts) / bronBreedte,
      (hoogte - margeBoven - margeOnder) / bronHoogte,
    );
    final raamBreedte = bronBreedte * schaal;
    final raamHoogte = bronHoogte * schaal;
    final links =
        margeLinks + (breedte - margeLinks - margeRechts - raamBreedte) / 2;
    final boven =
        margeBoven + (hoogte - margeBoven - margeOnder - raamHoogte) / 2;
    final rechts = links + raamBreedte;
    final onder = boven + raamHoogte;
    final buitenProfiel = math.max(4.0, math.min(10.0, raamBreedte * 0.075));
    final vleugelProfiel = math.max(4.0, math.min(9.0, raamBreedte * 0.065));
    final vleugelLinks = links + buitenProfiel;
    final vleugelBoven = boven + buitenProfiel;
    final vleugelRechts = rechts - buitenProfiel;
    final vleugelOnder = onder - buitenProfiel;
    final glasLinks = vleugelLinks + vleugelProfiel;
    final glasBoven = vleugelBoven + vleugelProfiel;
    final glasRechts = vleugelRechts - vleugelProfiel;
    final glasOnder = vleugelOnder - vleugelProfiel;
    final middenX = (glasLinks + glasRechts) / 2;
    final middenY = (glasBoven + glasOnder) / 2;

    return '''
<svg xmlns="http://www.w3.org/2000/svg" width="$breedte" height="$hoogte" viewBox="0 0 $breedte $hoogte">
  <rect x="${_n(links)}" y="${_n(boven)}" width="${_n(raamBreedte)}" height="${_n(raamHoogte)}" fill="#F9FAFB" stroke="#111827" stroke-width="1.4"/>
  <rect x="${_n(vleugelLinks)}" y="${_n(vleugelBoven)}" width="${_n(vleugelRechts - vleugelLinks)}" height="${_n(vleugelOnder - vleugelBoven)}" fill="#FFFFFF" stroke="#111827" stroke-width="1.1"/>
  <rect x="${_n(glasLinks)}" y="${_n(glasBoven)}" width="${_n(math.max(1, glasRechts - glasLinks))}" height="${_n(math.max(1, glasOnder - glasBoven))}" fill="#AFCBF0" stroke="#111827" stroke-width="1"/>
  <line x1="${_n(glasLinks)}" y1="${_n(middenY)}" x2="${_n(middenX)}" y2="${_n(glasBoven)}" stroke="#111827" stroke-width="0.9"/>
  <line x1="${_n(middenX)}" y1="${_n(glasBoven)}" x2="${_n(glasRechts)}" y2="${_n(middenY)}" stroke="#111827" stroke-width="0.9"/>
  <line x1="${_n(glasRechts)}" y1="${_n(middenY)}" x2="${_n(middenX)}" y2="${_n(glasOnder)}" stroke="#111827" stroke-width="0.9"/>
  <line x1="${_n(middenX)}" y1="${_n(glasOnder)}" x2="${_n(glasLinks)}" y2="${_n(middenY)}" stroke="#111827" stroke-width="0.9"/>
  <line x1="${_n(vleugelLinks + 5)}" y1="${_n(vleugelBoven + 4)}" x2="${_n(vleugelRechts - 5)}" y2="${_n(vleugelBoven + 4)}" stroke="#111827" stroke-width="2"/>
  <line x1="${_n(links)}" y1="${_n(onder + 16)}" x2="${_n(rechts)}" y2="${_n(onder + 16)}" stroke="#64748B" stroke-width="0.7"/>
  <line x1="${_n(links)}" y1="${_n(onder + 3)}" x2="${_n(links)}" y2="${_n(onder + 19)}" stroke="#64748B" stroke-width="0.7"/>
  <line x1="${_n(rechts)}" y1="${_n(onder + 3)}" x2="${_n(rechts)}" y2="${_n(onder + 19)}" stroke="#64748B" stroke-width="0.7"/>
  <path d="M ${_n(links)} ${_n(onder + 16)} l 4 -2 M ${_n(links)} ${_n(onder + 16)} l 4 2 M ${_n(rechts)} ${_n(onder + 16)} l -4 -2 M ${_n(rechts)} ${_n(onder + 16)} l -4 2" stroke="#64748B" stroke-width="0.7" fill="none"/>
  <text x="${_n((links + rechts) / 2)}" y="${_n(onder + 28)}" text-anchor="middle" font-size="6.8" fill="#64748B">${model.breedteMm} mm</text>
  <line x1="${_n(rechts + 17)}" y1="${_n(boven)}" x2="${_n(rechts + 17)}" y2="${_n(onder)}" stroke="#64748B" stroke-width="0.7"/>
  <line x1="${_n(rechts + 3)}" y1="${_n(boven)}" x2="${_n(rechts + 20)}" y2="${_n(boven)}" stroke="#64748B" stroke-width="0.7"/>
  <line x1="${_n(rechts + 3)}" y1="${_n(onder)}" x2="${_n(rechts + 20)}" y2="${_n(onder)}" stroke="#64748B" stroke-width="0.7"/>
  <text x="${_n(rechts + 29)}" y="${_n((boven + onder) / 2)}" text-anchor="middle" font-size="6.8" fill="#64748B" transform="rotate(-90 ${_n(rechts + 29)} ${_n((boven + onder) / 2)})">${model.hoogteMm} mm</text>
</svg>
''';
  }

  static String _afmetingCm(OpmetingVeluxDakraamModel model) {
    return '${_mmNaarCm(model.breedteMm)} × ${_mmNaarCm(model.hoogteMm)} cm';
  }

  static String _mmNaarCm(int millimeter) {
    final centimeter = millimeter / 10.0;
    if (centimeter == centimeter.roundToDouble()) {
      return centimeter.toInt().toString();
    }
    return centimeter.toStringAsFixed(1).replaceAll('.', ',');
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

  static String _n(num waarde) => waarde.toStringAsFixed(2);
}

class _VeluxCatalogusRegel {
  const _VeluxCatalogusRegel({
    required this.omschrijving,
    required this.aantal,
    required this.prijsPerStukExclBtw,
  });

  final String omschrijving;
  final int aantal;
  final double prijsPerStukExclBtw;

  double get totaalExclBtw => prijsPerStukExclBtw * aantal;
}
