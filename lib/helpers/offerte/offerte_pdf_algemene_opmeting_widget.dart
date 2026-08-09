// THIMACO-CONTROLE: ALGEMENE-OPMETING-PDF-ALLEEN-TOTAAL-ZWART-20260802
// THIMACO-CONTROLE: ALGEMENE-OPMETING-PDF-UNIFORM-EN-PRIJSUITSPITSING-20260802
import 'dart:math' as math;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../opmeting/algemene_opmeting/opmeting_algemene_opmeting_model.dart';
import '../opmeting/algemene_opmeting/opmeting_algemene_opmeting_technische_regels_helper.dart';
import '../opmeting/fotos/opmeting_foto_model.dart';
import '../opmeting/overzicht/opmeting_overzicht_model.dart';
import 'offerte_pdf_artikel_layout_helper.dart';
import 'prijzen/offerte_artikel_prijs_koppeling_service.dart';
import 'prijzen/offerte_berekening_resultaat.dart';

class OffertePdfAlgemeneOpmetingWidget {
  const OffertePdfAlgemeneOpmetingWidget._();

  static const PdfColor _rand = OffertePdfArtikelLayoutHelper.rand;

  static double berekenKolomHoogte(OpmetingOverzichtRaamItem positie) {
    final model = positie.algemeneOpmetingData;
    if (model == null) {
      return OffertePdfArtikelLayoutHelper.minimumKolomHoogte;
    }

    final regels = _technischeRegelsVoorPdf(model);
    var hoogte = OffertePdfArtikelLayoutHelper.berekenTechnischeKolomHoogte(
      regels: regels,
    );
    if (model.fotos.length > 1) {
      hoogte = math.max(hoogte, 300).toDouble();
    }
    return hoogte;
  }

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
    final model = positie.algemeneOpmetingData;
    if (model == null) return pw.SizedBox();

    final hoogte = berekenKolomHoogte(positie);
    final regels = _technischeRegelsVoorPdf(model);

    return OffertePdfArtikelLayoutHelper.bouwArtikelLayout(
      kolomHoogte: hoogte,
      tekenvlak: _bouwTekenvlakZonderKop(
        hoogte: hoogte,
        tekening: _bouwAfbeeldingen(model.fotos),
      ),
      technischeKolom: OffertePdfArtikelLayoutHelper.bouwTechnischeKolom(
        hoogte: hoogte,
        regels: regels,
        legeTekst: 'Geen tekst of prijsregels ingevuld.',
        toonPrijsZone: true,
      ),
      prijsBlok: _bouwPrijsBlok(
        positie,
        kortingToestaan: kortingToestaan && !isOptie,
        isOptie: isOptie,
      ),
    );
  }

  static List<OffertePdfTechnischeRegel> _technischeRegelsVoorPdf(
    OpmetingAlgemeneOpmetingModel model,
  ) {
    final toonPrijzen = OffertePdfArtikelLayoutHelper.toonPrijsblokken;
    final blokken = toonPrijzen
        ? model.blokken.where((blok) => blok.toonOpOfferte)
        : model.blokken;
    final regels = <OffertePdfTechnischeRegel>[];

    if (model.omschrijving.trim().isNotEmpty) {
      regels.add(
        OffertePdfTechnischeRegel(titel: '', waarde: model.omschrijving.trim()),
      );
    }

    for (final blok in blokken) {
      if (blok.isPrijs) {
        regels.add(
          OffertePdfTechnischeRegel(
            // A en V zijn uitsluitend interne aanduidingen en worden nooit op
            // de offerte- of opmeting-PDF afgedrukt.
            titel: blok.zichtbareTitel,
            waarde:
                OpmetingAlgemeneOpmetingTechnischeRegelsHelper.prijsSamenvatting(
                  blok,
                  toonBedrag: false,
                ),
            prijsTekst: toonPrijzen && blok.toonPrijsOpOfferte
                ? _euro(blok.totaalExclBtw)
                : '',
          ),
        );
        continue;
      }

      final titel = blok.zichtbareTitel.trim();
      final omschrijving = blok.omschrijving.trim();
      if (titel.isEmpty && omschrijving.isEmpty) continue;
      regels.add(OffertePdfTechnischeRegel(titel: titel, waarde: omschrijving));
    }

    return List<OffertePdfTechnischeRegel>.unmodifiable(regels);
  }

  static pw.Widget _bouwTekenvlakZonderKop({
    required double hoogte,
    required pw.Widget tekening,
  }) {
    return pw.Container(
      height: hoogte,
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(
          color: OffertePdfArtikelLayoutHelper.rand,
          width: 0.8,
        ),
      ),
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(
          OffertePdfArtikelLayoutHelper.tekenMarge,
        ),
        child: pw.FittedBox(
          fit: pw.BoxFit.contain,
          alignment: pw.Alignment.center,
          child: tekening,
        ),
      ),
    );
  }

  static pw.Widget _bouwAfbeeldingen(List<OpmetingFoto> fotos) {
    final geldigeFotos = fotos
        .where((foto) => foto.heeftAfbeelding && foto.bytes.isNotEmpty)
        .take(4)
        .toList(growable: false);
    if (geldigeFotos.isEmpty) {
      return _bouwLeegAfbeeldingsvlak();
    }

    pw.Widget fotoWidget(OpmetingFoto foto) {
      try {
        return pw.Container(
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            border: pw.Border.all(color: _rand, width: 0.6),
            borderRadius: pw.BorderRadius.circular(5),
          ),
          padding: const pw.EdgeInsets.all(3),
          child: pw.Image(pw.MemoryImage(foto.bytes), fit: pw.BoxFit.contain),
        );
      } catch (_) {
        return pw.Container(
          alignment: pw.Alignment.center,
          child: pw.Text(
            'Afbeelding kon niet worden weergegeven',
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(
              color: OffertePdfArtikelLayoutHelper.tekstGrijs,
              fontSize: 7,
            ),
          ),
        );
      }
    }

    if (geldigeFotos.length == 1) {
      return pw.Padding(
        padding: const pw.EdgeInsets.all(5),
        child: fotoWidget(geldigeFotos.first),
      );
    }

    final eersteRij = geldigeFotos.take(2).toList(growable: false);
    final tweedeRij = geldigeFotos.skip(2).toList(growable: false);

    pw.Widget rij(List<OpmetingFoto> rijFotos) {
      return pw.Expanded(
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: <pw.Widget>[
            for (
              var index = 0;
              index < rijFotos.length;
              index++
            ) ...<pw.Widget>[
              if (index > 0) pw.SizedBox(width: 5),
              pw.Expanded(child: fotoWidget(rijFotos[index])),
            ],
            if (rijFotos.length == 1) ...<pw.Widget>[
              pw.SizedBox(width: 5),
              pw.Expanded(child: pw.SizedBox()),
            ],
          ],
        ),
      );
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Column(
        children: <pw.Widget>[
          rij(eersteRij),
          if (tweedeRij.isNotEmpty) ...<pw.Widget>[
            pw.SizedBox(height: 5),
            rij(tweedeRij),
          ],
        ],
      ),
    );
  }

  static pw.Widget _bouwLeegAfbeeldingsvlak() {
    const breedte = 260.0;
    const hoogte = 180.0;
    const lijnKleurHex = '#D1D5DB';
    const tekstKleur = PdfColor.fromInt(0xFFB6BCC5);

    return pw.SizedBox(
      width: breedte,
      height: hoogte,
      child: pw.Stack(
        fit: pw.StackFit.expand,
        children: <pw.Widget>[
          pw.SvgImage(
            width: breedte,
            height: hoogte,
            fit: pw.BoxFit.fill,
            svg:
                '''
<svg xmlns="http://www.w3.org/2000/svg" width="260" height="180" viewBox="0 0 260 180">
  <line x1="0" y1="0" x2="260" y2="180" stroke="$lijnKleurHex" stroke-width="1.15"/>
  <line x1="260" y1="0" x2="0" y2="180" stroke="$lijnKleurHex" stroke-width="1.15"/>
</svg>
''',
          ),
          pw.Align(
            alignment: pw.Alignment.bottomCenter,
            child: pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 3),
              child: pw.Text(
                'geen afbeelding ter beschikking',
                style: const pw.TextStyle(color: tekstKleur, fontSize: 5.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static double _berekenPrijsSectieHoogte(
    OpmetingOverzichtRaamItem positie, {
    required bool kortingToestaan,
    required bool isOptie,
  }) {
    return 34.0;
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

  static pw.Widget _bouwPrijsBlok(
    OpmetingOverzichtRaamItem positie, {
    required bool kortingToestaan,
    required bool isOptie,
  }) {
    final resultaat = _prijsResultaatVoor(
      positie,
      kortingToestaan: kortingToestaan && !isOptie,
    );
    final totaal = resultaat?.offerteTotaalExclBtw ?? 0.0;

    return pw.Container(
      height: 34,
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(7),
        border: pw.Border.all(color: _rand, width: 0.8),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: <pw.Widget>[
          pw.Expanded(
            child: pw.Text(
              isOptie ? 'Totaal optie' : 'Totaal positie',
              style: const pw.TextStyle(
                color: OffertePdfArtikelLayoutHelper.tekstDonker,
                fontSize: 8.0,
              ),
            ),
          ),
          pw.Text(
            '${_euro(totaal)} excl. btw',
            style: const pw.TextStyle(
              color: OffertePdfArtikelLayoutHelper.tekstDonker,
              fontSize: 8.0,
            ),
          ),
        ],
      ),
    );
  }

  static String _euro(double waarde) {
    return '€ ${waarde.toStringAsFixed(2)}';
  }
}
