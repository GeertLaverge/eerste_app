// THIMACO-CONTROLE: VOORZETSCREEN-PDF-ONDERLATONDER-REFERENTIE-HERSTEL-20260731-0900
// THIMACO-CONTROLE: VOORZETSCREEN-PDF-ONGEBRUIKTE-IMPORT-VERWIJDERD-20260730
import 'dart:math' as math;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../opmeting/overzicht/opmeting_overzicht_model.dart';
import '../opmeting/toebehoren/voorzetscreen/opmeting_voorzetscreen_model.dart';
import '../opmeting/toebehoren/voorzetscreen/opmeting_voorzetscreen_technische_regels_helper.dart';
import 'offerte_pdf_artikel_layout_helper.dart';
import 'prijzen/offerte_artikel_prijs_koppeling_service.dart';
import 'prijzen/offerte_prijsregel_weergave_service.dart';

class OffertePdfVoorzetscreenWidget {
  const OffertePdfVoorzetscreenWidget._();

  static const double _basisPrijsRegelHoogte = 34;
  static const double _basisOptiePrijsRegelHoogte = 78;

  static String _notitiesVoorPdf(
    OpmetingOverzichtRaamItem positie,
    OpmetingVoorzetscreenModel model,
  ) {
    final overzichtNotities = positie.notities.trim();
    if (overzichtNotities.isNotEmpty) {
      return overzichtNotities;
    }
    return model.notities.trim();
  }

  static double berekenKolomHoogte(OpmetingOverzichtRaamItem positie) {
    final model = positie.voorzetscreenData;
    if (model == null) return OffertePdfArtikelLayoutHelper.minimumKolomHoogte;

    final notities = _notitiesVoorPdf(positie, model);
    final basisHoogte =
        OffertePdfArtikelLayoutHelper.berekenTechnischeKolomHoogte(
          regels: _technischeRegelsVoorOfferte(positie, model),
          notities: notities,
        );

    // Het opmerkingenblok staat onder alle technische regels en bevat naast de
    // eigenlijke tekst ook een scheidingslijn, titel en tussenruimtes. De
    // gezamenlijke hoogteberekening reserveert hiervoor bij een volle
    // Voorzetscreen-kolom net te weinig ruimte, waardoor de opmerkingen onder
    // de vaste kolomhoogte konden verdwijnen. Reserveer daarom dezelfde extra
    // ruimte die ook bij de Schuifvliegendeur wordt gebruikt.
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
      prijsHoogte: isOptie
          ? _basisOptiePrijsRegelHoogte
          : _basisPrijsRegelHoogte,
    );
  }

  static pw.Widget bouwPositie({
    required OpmetingOverzichtRaamItem positie,
    bool kortingToestaan = true,
    bool isOptie = false,
    double btwPercentage = 0.0,
    String btwRegelLabel = 'BTW',
  }) {
    final model = positie.voorzetscreenData;
    if (model == null) return pw.SizedBox();

    final hoogte = berekenKolomHoogte(positie);
    final regels = _technischeRegelsVoorOfferte(positie, model);

    return OffertePdfArtikelLayoutHelper.bouwArtikelLayout(
      kolomHoogte: hoogte,
      tekenvlak: OffertePdfArtikelLayoutHelper.bouwTekenvlak(
        hoogte: hoogte,
        maatTitel: 'Afmetingen',
        maatWaarde: model.maatSamenvatting,
        tekening: _bouwTekening(
          model,
          breedte: OffertePdfArtikelLayoutHelper.tekenInhoudBreedte,
          hoogte: math
              .max(120.0, hoogte - OffertePdfArtikelLayoutHelper.kopHoogte - 10)
              .toDouble(),
        ),
      ),
      technischeKolom: OffertePdfArtikelLayoutHelper.bouwTechnischeKolom(
        hoogte: hoogte,
        regels: regels,
        notities: _notitiesVoorPdf(positie, model),
        legeTekst: 'Geen gegevens ingevuld.',
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
    OpmetingVoorzetscreenModel model,
  ) {
    final resultaat = OpmetingVoorzetscreenTechnischeRegelsHelper.bouw(model)
        .map(
          (regel) => OffertePdfTechnischeRegel(
            titel: regel.titel,
            waarde: regel.waarde,
          ),
        )
        .toList(growable: true);

    final prijsResultaat =
        OfferteArtikelPrijsKoppelingService.resultaatVoorArtikel(
          positie,
          kortingToestaan: false,
        );
    if (prijsResultaat != null) {
      for (final prijsregel in prijsResultaat.vrijeArtikelPrijsregels) {
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
                ? '€ ${prijsregel.totaalExclBtw.toStringAsFixed(2)}'
                : '',
          ),
        );
      }
    }

    return OffertePdfArtikelLayoutHelper.combineerTechnischeRegels(resultaat);
  }

  static pw.Widget _bouwPrijsBlok(
    OpmetingOverzichtRaamItem positie, {
    required bool kortingToestaan,
    required bool isOptie,
    required double btwPercentage,
    required String btwRegelLabel,
  }) {
    final resultaat = OfferteArtikelPrijsKoppelingService.resultaatVoorArtikel(
      positie,
      kortingToestaan: kortingToestaan && !isOptie,
    );
    final kortingEffectief = kortingToestaan && !isOptie;
    final totaalVoorKorting = resultaat == null
        ? 0.0
        : resultaat.offerteTotaalExclBtw +
              (kortingEffectief ? resultaat.kortingBedragExclBtw : 0.0);
    final optieTotaal = resultaat?.offerteTotaalExclBtw ?? 0.0;
    final optieBtw = _rond(optieTotaal * btwPercentage);
    final optieIncl = _rond(optieTotaal + optieBtw);
    final heeftPrijs =
        resultaat != null &&
        (resultaat.basisTotaalExclBtw > 0 ||
            resultaat.prijsregelsVoorOfferte.isNotEmpty);

    pw.Widget bedragRegel(
      String omschrijving,
      double bedrag, {
      bool benadrukt = false,
    }) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Row(
          children: <pw.Widget>[
            pw.Expanded(
              child: pw.Text(
                omschrijving,
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
            pw.Text(
              '€ ${bedrag.toStringAsFixed(2)}',
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
      height: isOptie ? _basisOptiePrijsRegelHoogte : _basisPrijsRegelHoogte,
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(7),
        border: pw.Border.all(
          color: OffertePdfArtikelLayoutHelper.rand,
          width: 0.8,
        ),
      ),
      child: isOptie
          ? pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: <pw.Widget>[
                bedragRegel('Totaal optie excl. btw', optieTotaal),
                bedragRegel(btwRegelLabel, optieBtw),
                bedragRegel(
                  'Totaal optie incl. btw',
                  optieIncl,
                  benadrukt: true,
                ),
              ],
            )
          : pw.Row(
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
                if (totaalVoorKorting <= 0 && !heeftPrijs)
                  pw.Text(
                    'Prijs nog in te vullen',
                    style: const pw.TextStyle(
                      color: OffertePdfArtikelLayoutHelper.tekstGrijs,
                      fontSize: 8.0,
                    ),
                  )
                else
                  pw.Text(
                    '€ ${totaalVoorKorting.toStringAsFixed(2)} excl. btw',
                    style: const pw.TextStyle(
                      color: OffertePdfArtikelLayoutHelper.tekstDonker,
                      fontSize: 8.0,
                    ),
                  ),
              ],
            ),
    );
  }

  static pw.Widget _bouwTekening(
    OpmetingVoorzetscreenModel model, {
    required double breedte,
    required double hoogte,
  }) {
    final doek = _svgKleur(model.doekVoorzijdeHex, '#D8DADD');
    final buitenBreedte = model.buitenBreedteMm.toDouble();
    final buitenHoogte = model.buitenHoogteMm.toDouble();
    final schaal = math.min(155 / buitenBreedte, 180 / buitenHoogte);

    final frontBreedte = buitenBreedte * schaal;
    final frontHoogte = buitenHoogte * schaal;
    final frontLinks = 35 + ((155 - frontBreedte) / 2);
    final frontBoven = 35 + ((180 - frontHoogte) / 2);
    final frontRechts = frontLinks + frontBreedte;
    final frontOnder = frontBoven + frontHoogte;

    final kastHoogte = math.max(8.0, model.kastmaat.millimeter * schaal);
    final geleiderBreedte = math.max(4.0, 28 * schaal);
    final onderlatHoogte = math.max(5.0, 22 * schaal);
    final kastOnder = frontBoven + kastHoogte;
    final onderlatBoven = math.max(
      kastOnder + 12,
      frontOnder - (300 * schaal) - onderlatHoogte,
    );
    final doekLinks = frontLinks + geleiderBreedte;
    final doekRechts = frontRechts - geleiderBreedte;

    final breedteMaatLinks = model.breedteInclusiefGeleiders
        ? frontLinks
        : doekLinks;
    final breedteMaatRechts = model.breedteInclusiefGeleiders
        ? frontRechts
        : doekRechts;
    final hoogteMaatBoven = model.hoogteInclusiefKast ? frontBoven : kastOnder;

    final zijKast = math.max(12.0, model.kastmaat.millimeter * schaal);
    final zijLinks = 274.0;
    final zijBoven = frontBoven;
    final zijRechts = zijLinks + zijKast;
    final zijOnder = zijBoven + zijKast;
    final zijGeleiderBreedte = math.max(4.0, 24 * schaal);

    String n(num waarde) => waarde.toStringAsFixed(2);

    final vormPad = switch (model.kastvorm) {
      OpmetingVoorzetscreenKastvorm.recht =>
        '<rect x="${n(zijLinks)}" y="${n(zijBoven)}" width="${n(zijKast)}" height="${n(zijKast)}" fill="#F8FAFC" stroke="#374151" stroke-width="1.3"/>',
      OpmetingVoorzetscreenKastvorm.schuin =>
        '<path d="M ${n(zijLinks)} ${n(zijBoven)} H ${n(zijRechts)} V ${n(zijOnder - (zijKast * 0.23))} L ${n(zijRechts - (zijKast * 0.23))} ${n(zijOnder)} H ${n(zijLinks)} Z" fill="#F8FAFC" stroke="#374151" stroke-width="1.3"/>',
      OpmetingVoorzetscreenKastvorm.rond =>
        '<path d="M ${n(zijLinks)} ${n(zijBoven)} H ${n(zijLinks + (zijKast / 2))} Q ${n(zijRechts)} ${n(zijBoven)} ${n(zijRechts)} ${n(zijBoven + (zijKast / 2))} V ${n(zijOnder)} H ${n(zijLinks)} Z" fill="#F8FAFC" stroke="#374151" stroke-width="1.3"/>',
    };

    final svg =
        '''
<svg xmlns="http://www.w3.org/2000/svg" width="$breedte" height="$hoogte" viewBox="0 0 350 250">
  <text x="112" y="14" text-anchor="middle" font-size="9" font-weight="700" fill="#475569">Vooraanzicht</text>
  <text x="292" y="14" text-anchor="middle" font-size="9" font-weight="700" fill="#475569">Zijaanzicht</text>

  <rect x="${n(frontLinks)}" y="${n(frontBoven)}" width="${n(frontBreedte)}" height="${n(kastHoogte)}" fill="#E5E7EB" stroke="#374151" stroke-width="1.3"/>
  <rect x="${n(doekLinks)}" y="${n(kastOnder)}" width="${n(doekRechts - doekLinks)}" height="${n(onderlatBoven - kastOnder)}" fill="$doek" stroke="#374151" stroke-width="1.0"/>
  <g opacity="0.22" stroke="#FFFFFF" stroke-width="0.7">
    <path d="M ${n(doekLinks)} ${n(onderlatBoven)} L ${n(doekRechts)} ${n(kastOnder)}"/>
    <path d="M ${n(doekLinks)} ${n(onderlatBoven - 18)} L ${n(doekRechts - 18)} ${n(kastOnder)}"/>
    <path d="M ${n(doekLinks + 18)} ${n(onderlatBoven)} L ${n(doekRechts)} ${n(kastOnder + 18)}"/>
  </g>
  <rect x="${n(frontLinks)}" y="${n(kastOnder)}" width="${n(geleiderBreedte)}" height="${n(frontOnder - kastOnder)}" fill="#F8FAFC" stroke="#374151" stroke-width="1.1"/>
  <rect x="${n(frontRechts - geleiderBreedte)}" y="${n(kastOnder)}" width="${n(geleiderBreedte)}" height="${n(frontOnder - kastOnder)}" fill="#F8FAFC" stroke="#374151" stroke-width="1.1"/>
  <rect x="${n(doekLinks)}" y="${n(onderlatBoven)}" width="${n(doekRechts - doekLinks)}" height="${n(onderlatHoogte)}" fill="#F8FAFC" stroke="#374151" stroke-width="1.1"/>

  <line x1="${n(breedteMaatLinks)}" y1="${n(frontOnder + 16)}" x2="${n(breedteMaatRechts)}" y2="${n(frontOnder + 16)}" stroke="#475569" stroke-width="0.8"/>
  <line x1="${n(breedteMaatLinks)}" y1="${n(frontOnder)}" x2="${n(breedteMaatLinks)}" y2="${n(frontOnder + 19)}" stroke="#475569" stroke-width="0.8"/>
  <line x1="${n(breedteMaatRechts)}" y1="${n(frontOnder)}" x2="${n(breedteMaatRechts)}" y2="${n(frontOnder + 19)}" stroke="#475569" stroke-width="0.8"/>
  <text x="${n((breedteMaatLinks + breedteMaatRechts) / 2)}" y="${n(frontOnder + 29)}" text-anchor="middle" font-size="8" fill="#475569">${model.breedteMm} mm</text>

  <line x1="${n(frontLinks - 16)}" y1="${n(hoogteMaatBoven)}" x2="${n(frontLinks - 16)}" y2="${n(frontOnder)}" stroke="#475569" stroke-width="0.8"/>
  <line x1="${n(frontLinks - 19)}" y1="${n(hoogteMaatBoven)}" x2="${n(frontLinks)}" y2="${n(hoogteMaatBoven)}" stroke="#475569" stroke-width="0.8"/>
  <line x1="${n(frontLinks - 19)}" y1="${n(frontOnder)}" x2="${n(frontLinks)}" y2="${n(frontOnder)}" stroke="#475569" stroke-width="0.8"/>
  <text x="${n(frontLinks - 25)}" y="${n((hoogteMaatBoven + frontOnder) / 2)}" transform="rotate(-90 ${n(frontLinks - 25)} ${n((hoogteMaatBoven + frontOnder) / 2)})" text-anchor="middle" font-size="8" fill="#475569">${model.hoogteMm} mm</text>

  $vormPad
  <rect x="${n(zijLinks)}" y="${n(zijOnder)}" width="${n(zijGeleiderBreedte)}" height="${n(frontOnder - zijOnder)}" fill="#E5E7EB" stroke="#374151" stroke-width="1.1"/>
  <text x="292" y="229" text-anchor="middle" font-size="8" font-weight="700" fill="#475569">${model.kastvorm.label}</text>
  <text x="292" y="242" text-anchor="middle" font-size="8" fill="#475569">${model.kastmaat.millimeter} × ${model.kastmaat.millimeter} mm</text>
</svg>
''';

    return pw.SizedBox(
      width: breedte,
      height: hoogte,
      child: pw.SvgImage(svg: svg),
    );
  }

  static String _svgKleur(String waarde, String standaard) {
    final tekst = waarde.trim().toUpperCase();
    return RegExp(r'^#[0-9A-F]{6}$').hasMatch(tekst) ? tekst : standaard;
  }

  static double _rond(double waarde) {
    if (!waarde.isFinite || waarde <= 0) return 0;
    return (waarde * 100).roundToDouble() / 100;
  }
}
