// THIMACO-CONTROLE: OPMETING-PDF-ZONDER-PRIJSBLOKKEN-20260731
// THIMACO-CONTROLE: PDF-CONST-TEXTSTYLE-NORMAAL-FIX-20260726
// THIMACO-CONTROLE: TECHNISCHE-REGELS-UNIFORM-ZONDER-SCHAALVERKLEINING-20260726
// THIMACO-CONTROLE: ALGEMENE-ARTIKEL-LAYOUT-VOLLE-BREEDTE-20260720
import 'dart:async';
import 'dart:math' as math;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class OffertePdfTechnischeRegel {
  const OffertePdfTechnischeRegel({
    required this.titel,
    required this.waarde,
    this.prijsTekst = '',
  });

  final String titel;
  final String waarde;
  final String prijsTekst;
}

class OffertePdfArtikelLayoutHelper {
  const OffertePdfArtikelLayoutHelper._();

  static const Object _toonPrijsblokkenZoneSleutel =
      #thimacoToonPdfPrijsblokken;

  static bool get toonPrijsblokken {
    return Zone.current[_toonPrijsblokkenZoneSleutel] != false;
  }

  /// Voert [actie] uit met dezelfde artikellayout, maar zonder prijszone,
  /// prijsblokken en prijsruimte. De zone blijft ook over async-grenzen actief.
  static T zonderPrijsblokken<T>(T Function() actie) {
    return runZoned<T>(
      actie,
      zoneValues: <Object?, Object?>{_toonPrijsblokkenZoneSleutel: false},
    );
  }

  static const PdfColor oranje = PdfColor.fromInt(0xFFF15A24);
  static const PdfColor tekstDonker = PdfColor.fromInt(0xFF22272D);
  static const PdfColor tekstGrijs = PdfColor.fromInt(0xFF616973);
  static const PdfColor rand = PdfColor.fromInt(0xFFE2E5E8);
  static const PdfColor lichtVlak = PdfColor.fromInt(0xFFF8F9FA);

  // Verwachte kolombreedte binnen de offerte-detailpagina.
  // De echte breedte wordt in bouwArtikelLayout flexibel verdeeld.
  static const double totaleFlexBreedte = 515.28;
  static const double kolomTussenruimte = 12;
  static const int tekenvlakFlex = 45;
  static const int technischeKolomFlex = 55;
  static const double kolomBreedte =
      totaleFlexBreedte * tekenvlakFlex / (tekenvlakFlex + technischeKolomFlex);
  static const double prijsZoneBreedte = 60;
  static const double ruimteVoorPrijsBlok = 10;
  static const double minimumKolomHoogte = 230;
  static const double maximumKolomHoogte = 650;
  static const double kopHoogte = 30;
  static const double tekenInhoudBreedte = kolomBreedte - 28;

  // De hoogteberekening en de effectieve PDF-rij gebruiken dezelfde vaste
  // waarden. Daardoor worden lange technische lijsten niet meer na enkele
  // regels afgekapt door een verschil tussen geschatte en echte rijhoogte.
  static const double technischeTekstGrootte = 8.0;
  static const double technischeRegelHoogte = 15;
  static const double technischeKolomVerticalePadding = 15;
  static const double tekenMarge = 5 * PdfPageFormat.mm;

  static List<OffertePdfTechnischeRegel> combineerTechnischeRegels(
    List<OffertePdfTechnischeRegel> regels,
  ) {
    final resultaat = <OffertePdfTechnischeRegel>[];
    final indexPerSleutel = <String, int>{};

    for (final regel in regels) {
      final netteRegel = OffertePdfTechnischeRegel(
        titel: _opEenRegel(regel.titel),
        waarde: _opEenRegel(regel.waarde),
        prijsTekst: _opEenRegel(regel.prijsTekst),
      );
      final sleutel = _technischeRegelSleutel(netteRegel);

      if (sleutel.isEmpty) {
        continue;
      }

      final bestaandIndex = indexPerSleutel[sleutel];
      if (bestaandIndex == null) {
        indexPerSleutel[sleutel] = resultaat.length;
        resultaat.add(netteRegel);
        continue;
      }

      final bestaand = resultaat[bestaandIndex];
      resultaat[bestaandIndex] = OffertePdfTechnischeRegel(
        titel: bestaand.titel,
        waarde: bestaand.waarde,
        prijsTekst: _combineerPrijsTeksten(
          bestaand.prijsTekst,
          netteRegel.prijsTekst,
        ),
      );
    }

    return List<OffertePdfTechnischeRegel>.unmodifiable(resultaat);
  }

  static double berekenTechnischeKolomHoogte({
    required List<OffertePdfTechnischeRegel> regels,
    String notities = '',
    String bovenMelding = '',
  }) {
    final samengevoegdeRegels = combineerTechnischeRegels(regels);
    var benodigdeHoogte = technischeKolomVerticalePadding;

    if (bovenMelding.trim().isNotEmpty) {
      benodigdeHoogte += 17;
      benodigdeHoogte +=
          _geschatAantalRegels(bovenMelding, tekensPerRegel: 43) * 7.2;
    }

    if (samengevoegdeRegels.isEmpty) {
      benodigdeHoogte += 20;
    } else {
      for (final regel in samengevoegdeRegels) {
        benodigdeHoogte += _technischeRegelHoogteVoor(
          regel,
          toonPrijsZone: toonPrijsblokken,
        );
      }
    }

    if (notities.trim().isNotEmpty) {
      benodigdeHoogte += 20;
      benodigdeHoogte +=
          _geschatAantalRegels(notities, tekensPerRegel: 54) * 7.2;
    }

    return benodigdeHoogte
        .clamp(minimumKolomHoogte, maximumKolomHoogte)
        .toDouble();
  }

  static bool _gebruikCompacteTechnischeOpmaak({
    required List<OffertePdfTechnischeRegel> regels,
    required String notities,
    required String bovenMelding,
  }) {
    return regels.length >= 24 ||
        notities.trim().length > 220 ||
        bovenMelding.trim().length > 100;
  }

  static double berekenTotalePositieHoogte({
    required double kolomHoogte,
    required double prijsHoogte,
  }) {
    if (!toonPrijsblokken) return kolomHoogte;
    return kolomHoogte + ruimteVoorPrijsBlok + prijsHoogte;
  }

  static pw.Widget bouwArtikelLayout({
    required double kolomHoogte,
    required pw.Widget tekenvlak,
    required pw.Widget technischeKolom,
    required pw.Widget prijsBlok,
  }) {
    if (!toonPrijsblokken) {
      return bouwArtikelLayoutZonderPrijs(
        kolomHoogte: kolomHoogte,
        tekenvlak: tekenvlak,
        technischeKolom: technischeKolom,
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: <pw.Widget>[
        _bouwKolommen(
          kolomHoogte: kolomHoogte,
          tekenvlak: tekenvlak,
          technischeKolom: technischeKolom,
        ),
        pw.SizedBox(height: ruimteVoorPrijsBlok),
        prijsBlok,
      ],
    );
  }

  static pw.Widget bouwArtikelLayoutZonderPrijs({
    required double kolomHoogte,
    required pw.Widget tekenvlak,
    required pw.Widget technischeKolom,
  }) {
    return _bouwKolommen(
      kolomHoogte: kolomHoogte,
      tekenvlak: tekenvlak,
      technischeKolom: technischeKolom,
    );
  }

  static pw.Widget _bouwKolommen({
    required double kolomHoogte,
    required pw.Widget tekenvlak,
    required pw.Widget technischeKolom,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Expanded(
          flex: tekenvlakFlex,
          child: pw.SizedBox(height: kolomHoogte, child: tekenvlak),
        ),
        pw.SizedBox(width: kolomTussenruimte),
        pw.Expanded(
          flex: technischeKolomFlex,
          child: pw.SizedBox(height: kolomHoogte, child: technischeKolom),
        ),
      ],
    );
  }

  static pw.Widget bouwTekenvlak({
    required double hoogte,
    required String maatTitel,
    required String maatWaarde,
    required pw.Widget tekening,
  }) {
    return pw.Container(
      height: hoogte,
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: rand, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: <pw.Widget>[
          pw.Container(
            height: kopHoogte,
            padding: const pw.EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: const pw.BoxDecoration(
              color: lichtVlak,
              border: pw.Border(bottom: pw.BorderSide(color: rand, width: 0.8)),
            ),
            child: pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    text: '${maatTitel.trim()}  ',
                    style: pw.TextStyle(
                      color: oranje,
                      fontSize: 8.8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.TextSpan(
                    text: maatWaarde.trim(),
                    style: pw.TextStyle(
                      color: tekstDonker,
                      fontSize: 8.8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(tekenMarge),
              child: pw.FittedBox(
                fit: pw.BoxFit.contain,
                alignment: pw.Alignment.center,
                child: tekening,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget bouwTechnischeKolom({
    required double hoogte,
    required List<OffertePdfTechnischeRegel> regels,
    String notities = '',
    String bovenMelding = '',
    String legeTekst = 'Geen bijkomende technische gegevens.',
    bool toonPrijsZone = true,
  }) {
    final effectievePrijsZone = toonPrijsZone && toonPrijsblokken;
    final samengevoegdeRegels = combineerTechnischeRegels(regels);
    final compact = _gebruikCompacteTechnischeOpmaak(
      regels: samengevoegdeRegels,
      notities: notities,
      bovenMelding: bovenMelding,
    );

    return pw.Container(
      height: hoogte,
      padding: const pw.EdgeInsets.fromLTRB(10, 7, 10, 8),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: rand, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: <pw.Widget>[
          if (bovenMelding.trim().isNotEmpty) ...<pw.Widget>[
            pw.Text(
              bovenMelding.trim(),
              style: const pw.TextStyle(
                color: tekstDonker,
                fontSize: technischeTekstGrootte,
              ),
            ),
            pw.SizedBox(height: compact ? 5 : 7),
            pw.Container(height: 0.7, color: rand),
            pw.SizedBox(height: compact ? 3 : 5),
          ],
          if (samengevoegdeRegels.isEmpty)
            pw.Text(
              legeTekst,
              style: const pw.TextStyle(
                color: tekstDonker,
                fontSize: technischeTekstGrootte,
              ),
            )
          else
            for (var index = 0; index < samengevoegdeRegels.length; index++)
              _bouwTechnischeRegel(
                regel: samengevoegdeRegels[index],
                laatste: index == samengevoegdeRegels.length - 1,
                toonPrijsZone: effectievePrijsZone,
              ),
          if (notities.trim().isNotEmpty) ...<pw.Widget>[
            pw.SizedBox(height: compact ? 5 : 7),
            pw.Container(height: 0.7, color: rand),
            pw.SizedBox(height: compact ? 5 : 7),
            pw.Text(
              'Opmerkingen',
              style: const pw.TextStyle(
                color: tekstDonker,
                fontSize: technischeTekstGrootte,
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              notities.trim(),
              style: const pw.TextStyle(
                color: tekstDonker,
                fontSize: technischeTekstGrootte,
                lineSpacing: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _bouwTechnischeRegel({
    required OffertePdfTechnischeRegel regel,
    required bool laatste,
    required bool toonPrijsZone,
  }) {
    final regelHoogte = _technischeRegelHoogteVoor(
      regel,
      toonPrijsZone: toonPrijsZone,
    );
    final regelTekst = _technischeRegelTekst(regel);
    final aantalRegels = _technischeRegelAantalRegels(
      regel,
      toonPrijsZone: toonPrijsZone,
    );

    return pw.Container(
      height: regelHoogte,
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      decoration: pw.BoxDecoration(
        border: laatste
            ? null
            : const pw.Border(bottom: pw.BorderSide(color: rand, width: 0.4)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: <pw.Widget>[
          pw.Expanded(
            child: pw.Text(
              regelTekst,
              maxLines: aantalRegels,
              style: const pw.TextStyle(
                color: tekstDonker,
                fontSize: technischeTekstGrootte,
                lineSpacing: 1.2,
              ),
            ),
          ),
          if (toonPrijsZone) ...<pw.Widget>[
            pw.SizedBox(width: 8),
            pw.SizedBox(
              width: prijsZoneBreedte,
              child: pw.Text(
                regel.prijsTekst,
                maxLines: 1,
                textAlign: pw.TextAlign.right,
                style: const pw.TextStyle(
                  color: tekstDonker,
                  fontSize: technischeTekstGrootte,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _technischeRegelTekst(OffertePdfTechnischeRegel regel) {
    final titel = regel.titel.trim();
    final waarde = regel.waarde.trim();

    if (titel.isEmpty) return waarde;
    if (waarde.isEmpty) return titel;

    return '$titel: $waarde';
  }

  static int _technischeRegelAantalRegels(
    OffertePdfTechnischeRegel regel, {
    required bool toonPrijsZone,
  }) {
    final tekst = _technischeRegelTekst(regel);
    final tekensPerRegel = toonPrijsZone ? 38 : 50;

    return _geschatAantalRegels(
      tekst,
      tekensPerRegel: tekensPerRegel,
    ).clamp(1, 3).toInt();
  }

  static double _technischeRegelHoogteVoor(
    OffertePdfTechnischeRegel regel, {
    required bool toonPrijsZone,
  }) {
    final aantalRegels = _technischeRegelAantalRegels(
      regel,
      toonPrijsZone: toonPrijsZone,
    );

    if (aantalRegels <= 1) return technischeRegelHoogte;
    if (aantalRegels == 2) return 25;

    return 35;
  }

  static String _opEenRegel(String waarde) {
    return waarde.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String _technischeRegelSleutel(OffertePdfTechnischeRegel regel) {
    final titel = regel.titel.trim().toLowerCase().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    final waarde = regel.waarde.trim().toLowerCase().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    if (titel.isEmpty && waarde.isEmpty) {
      return '';
    }
    return '$titel|$waarde';
  }

  static String _combineerPrijsTeksten(String eerste, String tweede) {
    final eersteTekst = eerste.trim();
    final tweedeTekst = tweede.trim();

    if (eersteTekst.isEmpty) return tweedeTekst;
    if (tweedeTekst.isEmpty) return eersteTekst;

    final eersteBedrag = _leesPrijsBedrag(eersteTekst);
    final tweedeBedrag = _leesPrijsBedrag(tweedeTekst);
    if (eersteBedrag == null || tweedeBedrag == null) {
      return eersteTekst;
    }

    return '€ ${(eersteBedrag + tweedeBedrag).toStringAsFixed(2)}';
  }

  static double? _leesPrijsBedrag(String prijsTekst) {
    var schoon = prijsTekst
        .replaceAll('€', '')
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'[^0-9,.\-]'), '');
    if (schoon.isEmpty || schoon == '-') {
      return null;
    }

    final laatsteKomma = schoon.lastIndexOf(',');
    final laatstePunt = schoon.lastIndexOf('.');
    if (laatsteKomma >= 0 && laatstePunt >= 0) {
      if (laatsteKomma > laatstePunt) {
        schoon = schoon.replaceAll('.', '').replaceAll(',', '.');
      } else {
        schoon = schoon.replaceAll(',', '');
      }
    } else if (laatsteKomma >= 0) {
      schoon = schoon.replaceAll(',', '.');
    }

    final bedrag = double.tryParse(schoon);
    if (bedrag == null || !bedrag.isFinite) {
      return null;
    }
    return bedrag;
  }

  static int _geschatAantalRegels(String tekst, {required int tekensPerRegel}) {
    final lengte = tekst.trim().length;
    if (lengte <= 0) return 1;
    return math.max(1, (lengte / tekensPerRegel).ceil()).toInt();
  }
}
