// THIMACO-CONTROLE: BUITENJALOEZIE-DEFINITIEVE-PDF-WIDGET-20260803
// THIMACO-CONTROLE: BUITENJALOEZIE-PDF-WIDGET-FASE-6-20260803
import 'dart:math' as math;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../opmeting/overzicht/opmeting_overzicht_model.dart';
import '../opmeting/toebehoren/buitenjaloezie/opmeting_buitenjaloezie_model.dart';
import '../opmeting/toebehoren/buitenjaloezie/opmeting_buitenjaloezie_technische_regels_helper.dart';
import 'offerte_pdf_artikel_layout_helper.dart';
import 'prijzen/offerte_artikel_prijs_koppeling_service.dart';
import 'prijzen/offerte_prijsregel_weergave_service.dart';

class OffertePdfBuitenjaloezieWidget {
  const OffertePdfBuitenjaloezieWidget._();

  static const double _basisPrijsRegelHoogte = 34;
  static const double _basisOptiePrijsRegelHoogte = 78;

  static String _notitiesVoorPdf(
    OpmetingOverzichtRaamItem positie,
    OpmetingBuitenjaloezieModel model,
  ) {
    final overzichtNotities = positie.notities.trim();
    if (overzichtNotities.isNotEmpty) {
      return overzichtNotities;
    }
    return model.notities.trim();
  }

  static double berekenKolomHoogte(OpmetingOverzichtRaamItem positie) {
    final model = positie.buitenjaloezieData;
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
    final model = positie.buitenjaloezieData;
    if (model == null) return pw.SizedBox();

    final hoogte = berekenKolomHoogte(positie);
    final regels = _technischeRegelsVoorOfferte(positie, model);

    return OffertePdfArtikelLayoutHelper.bouwArtikelLayout(
      kolomHoogte: hoogte,
      tekenvlak: OffertePdfArtikelLayoutHelper.bouwTekenvlak(
        hoogte: hoogte,
        maatTitel: 'Totale afmetingen',
        maatWaarde: '${model.totaleBreedteMm} × ${model.totaleHoogteMm} mm',
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
    OpmetingBuitenjaloezieModel model,
  ) {
    final resultaat = OpmetingBuitenjaloezieTechnischeRegelsHelper.bouw(model)
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
        if (!toonPrijs && !toonAlleenOmschrijving) continue;

        final omschrijving =
            OffertePrijsregelWeergaveService.omschrijvingVoorOfferte(
              prijsregel,
            ).trim();
        if (omschrijving.isEmpty) continue;

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
    OpmetingBuitenjaloezieModel model, {
    required double breedte,
    required double hoogte,
  }) {
    return pw.SizedBox(
      width: breedte,
      height: hoogte,
      child: pw.SvgImage(svg: _bouwSvg(model), fit: pw.BoxFit.contain),
    );
  }

  static String _bouwSvg(OpmetingBuitenjaloezieModel model) {
    const viewBreedte = 430.0;
    const viewHoogte = 310.0;
    const margeLinks = 62.0;
    const margeRechts = 72.0;
    const margeBoven = 38.0;
    const margeOnder = 42.0;

    final beschikbareBreedte = viewBreedte - margeLinks - margeRechts;
    final beschikbareHoogte = viewHoogte - margeBoven - margeOnder;
    final totaalBreedte = math.max(1, model.totaleBreedteMm);
    final totaalHoogte = math.max(1, model.totaleHoogteMm);

    final schaal = math.min(
      beschikbareBreedte / totaalBreedte,
      beschikbareHoogte / totaalHoogte,
    );

    final tekeningBreedte = totaalBreedte * schaal;
    final tekeningHoogte = totaalHoogte * schaal;
    final links = margeLinks + (beschikbareBreedte - tekeningBreedte) / 2;
    final boven = margeBoven + (beschikbareHoogte - tekeningHoogte) / 2;
    final kastHoogte = math.max(12.0, model.kastHoogteMm * schaal);
    final geleiderBreedte = math.max(3.0, model.geleiderBreedteMm * schaal);
    final geleiderBoven = boven + kastHoogte;
    final geleiderHoogte = math.max(1.0, tekeningHoogte - kastHoogte);
    final lamelLinks = links + geleiderBreedte;
    final lamelBreedte = math.max(1.0, tekeningBreedte - geleiderBreedte * 2);
    final lamelHoogte = math.max(
      1.2,
      OpmetingBuitenjaloezieModel.lamelTekeningHoogteMm * schaal,
    );
    final steek = math.max(
      2.5,
      OpmetingBuitenjaloezieModel.lamelSteekMm * schaal,
    );

    final lamellen = StringBuffer();
    var y = geleiderBoven + math.max(2.0, steek * 0.15);
    final ondergrens = boven + tekeningHoogte - lamelHoogte;
    while (y <= ondergrens) {
      lamellen.writeln(
        '<rect x="${_f(lamelLinks)}" y="${_f(y)}" '
        'width="${_f(lamelBreedte)}" height="${_f(lamelHoogte)}" '
        'fill="${_veiligeHex(model.lamelkleurHex)}" '
        'stroke="#252A30" stroke-width="0.65"/>',
      );
      y += steek;
    }

    final ladderKleur =
        model.ladderkoord == OpmetingBuitenjaloezieLadderkoord.zwart
        ? '#111827'
        : '#9CA3AF';
    final ladderlijnen = StringBuffer();
    for (final factor in <double>[0.24, 0.50, 0.76]) {
      final x = lamelLinks + lamelBreedte * factor;
      ladderlijnen.writeln(
        '<line x1="${_f(x)}" y1="${_f(geleiderBoven)}" '
        'x2="${_f(x)}" y2="${_f(boven + tekeningHoogte)}" '
        'stroke="$ladderKleur" stroke-width="0.8"/>',
      );
    }

    final breedteMaatY = boven - 15;
    final hoogteMaatX = links - 22;
    final kastMaatX = links + tekeningBreedte + 22;

    return '''
<svg xmlns="http://www.w3.org/2000/svg"
     width="430" height="310" viewBox="0 0 430 310">
  <rect x="0" y="0" width="430" height="310" fill="#FFFFFF"/>
  <rect x="${_f(links)}" y="${_f(boven)}"
        width="${_f(tekeningBreedte)}" height="${_f(kastHoogte)}"
        fill="#F8FAFC" stroke="#202428" stroke-width="1.2"/>
  <rect x="${_f(links)}" y="${_f(geleiderBoven)}"
        width="${_f(geleiderBreedte)}" height="${_f(geleiderHoogte)}"
        fill="#F3F4F6" stroke="#202428" stroke-width="1.1"/>
  <rect x="${_f(links + tekeningBreedte - geleiderBreedte)}"
        y="${_f(geleiderBoven)}"
        width="${_f(geleiderBreedte)}" height="${_f(geleiderHoogte)}"
        fill="#F3F4F6" stroke="#202428" stroke-width="1.1"/>
  ${lamellen.toString()}
  ${ladderlijnen.toString()}
  <line x1="${_f(links)}" y1="${_f(breedteMaatY)}"
        x2="${_f(links + tekeningBreedte)}" y2="${_f(breedteMaatY)}"
        stroke="#64748B" stroke-width="0.8"/>
  <line x1="${_f(links)}" y1="${_f(breedteMaatY - 4)}"
        x2="${_f(links)}" y2="${_f(breedteMaatY + 4)}"
        stroke="#64748B" stroke-width="0.8"/>
  <line x1="${_f(links + tekeningBreedte)}" y1="${_f(breedteMaatY - 4)}"
        x2="${_f(links + tekeningBreedte)}" y2="${_f(breedteMaatY + 4)}"
        stroke="#64748B" stroke-width="0.8"/>
  <text x="${_f(links + tekeningBreedte / 2)}"
        y="${_f(breedteMaatY - 5)}"
        text-anchor="middle" font-size="7.5" fill="#475569">
    ${model.totaleBreedteMm} mm
  </text>
  <line x1="${_f(hoogteMaatX)}" y1="${_f(boven)}"
        x2="${_f(hoogteMaatX)}" y2="${_f(boven + tekeningHoogte)}"
        stroke="#64748B" stroke-width="0.8"/>
  <line x1="${_f(hoogteMaatX - 4)}" y1="${_f(boven)}"
        x2="${_f(hoogteMaatX + 4)}" y2="${_f(boven)}"
        stroke="#64748B" stroke-width="0.8"/>
  <line x1="${_f(hoogteMaatX - 4)}" y1="${_f(boven + tekeningHoogte)}"
        x2="${_f(hoogteMaatX + 4)}" y2="${_f(boven + tekeningHoogte)}"
        stroke="#64748B" stroke-width="0.8"/>
  <text x="${_f(hoogteMaatX - 7)}"
        y="${_f(boven + tekeningHoogte / 2)}"
        text-anchor="middle" font-size="7.2" fill="#475569"
        transform="rotate(-90 ${_f(hoogteMaatX - 7)} ${_f(boven + tekeningHoogte / 2)})">
    ${model.totaleHoogteMm} mm
  </text>
  <line x1="${_f(kastMaatX)}" y1="${_f(boven)}"
        x2="${_f(kastMaatX)}" y2="${_f(boven + kastHoogte)}"
        stroke="#64748B" stroke-width="0.8"/>
  <line x1="${_f(kastMaatX - 4)}" y1="${_f(boven)}"
        x2="${_f(kastMaatX + 4)}" y2="${_f(boven)}"
        stroke="#64748B" stroke-width="0.8"/>
  <line x1="${_f(kastMaatX - 4)}" y1="${_f(boven + kastHoogte)}"
        x2="${_f(kastMaatX + 4)}" y2="${_f(boven + kastHoogte)}"
        stroke="#64748B" stroke-width="0.8"/>
  <text x="${_f(kastMaatX + 8)}"
        y="${_f(boven + kastHoogte / 2)}"
        text-anchor="middle" font-size="6.8" fill="#475569"
        transform="rotate(-90 ${_f(kastMaatX + 8)} ${_f(boven + kastHoogte / 2)})">
    kast ${model.kastHoogteMm} mm
  </text>
  <text x="${_f(links + tekeningBreedte / 2)}"
        y="${_f(boven + 10)}"
        text-anchor="middle" font-size="7.4" font-weight="700"
        fill="#374151">
    ${_xml(model.systeem.label)} · ${_xml(model.lameltype.label)}
  </text>
  <text x="${_f(links + tekeningBreedte / 2)}"
        y="${_f(boven + kastHoogte - 5)}"
        text-anchor="middle" font-size="6.3" fill="#475569">
    ${_xml(model.lamelkleurSamenvatting)}
  </text>
</svg>
''';
  }

  static String _veiligeHex(String waarde) {
    final schoon = waarde.trim().replaceAll('#', '').toUpperCase();
    return RegExp(r'^[0-9A-F]{6}$').hasMatch(schoon) ? '#$schoon' : '#B7B7B7';
  }

  static String _xml(String tekst) {
    return tekst
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  static String _f(num waarde) => waarde.toStringAsFixed(2);

  static double _rond(double waarde) {
    if (!waarde.isFinite || waarde <= 0) return 0;
    return (waarde * 100).roundToDouble() / 100;
  }
}
