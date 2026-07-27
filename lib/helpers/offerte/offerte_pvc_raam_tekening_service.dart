// THIMACO-CONTROLE: OFFERTE-TEKENING-VULT-PNG-MAATVOERING-VAST-20260727
// THIMACO-CONTROLE: OFFERTE-MAATVOERING-KLEIN-FIJN-20260726
// THIMACO-CONTROLE: OFFERTE-PVC-TEKENING-WITTE-RAND-AFGESNEDEN-20260726
// THIMACO-CONTROLE: OFFERTE-PVC-MAATVOERING-GELIJK-INZETHOR-20260720
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../opmeting/overzicht/opmeting_overzicht_model.dart';
import '../opmeting/overzicht/opmeting_overzicht_tekening.dart';
import 'prijzen/offerte_artikel_prijs_koppeling_service.dart';

/// Maakt voor de offerte een PNG van exact dezelfde algemene raam- of
/// deurtekening die op het overzichtsformulier wordt gebruikt.
///
/// De eigenlijke tekening wordt binnen de vaste PNG zo groot mogelijk gezet.
/// De maatpijlen, maattekst en maatlijnen worden vóór die vergroting omgekeerd
/// gecorrigeerd. Daardoor vullen raam en deur het tekenvlak, terwijl de
/// maatvoering klein en onafhankelijk van de raamafmetingen blijft.
class OffertePvcRaamTekeningService {
  const OffertePvcRaamTekeningService._();

  static const Size _logischeGrootte = Size(990, 600);
  static const double _pixelRatio = 2;

  // De vaste PDF-verkleining wordt vooraf gecompenseerd. Deze basismaten zijn
  // dezelfde kleine, leesbare maatvoering als voorheen.
  static const double _offerteMaatvoeringFactor = 4.25;
  static const double _offerteMaatPijlGrootte = 1.6 * _offerteMaatvoeringFactor;
  static const double _offerteMaatLettergrootte =
      6.2 * _offerteMaatvoeringFactor;
  static const double _offerteMaatLijndikte = 0.18 * _offerteMaatvoeringFactor;

  // Kleine marge rond de volledige tekening, inclusief maatvoering. De PDF
  // voegt zelf daarnaast nog zijn normale binnenmarge toe.
  static const double _doelMargeLogisch = 8;

  // Een pixel wordt als inhoud beschouwd zodra hij voldoende afwijkt van de
  // volledig witte achtergrond. Zo blijven ook lichtgrijze maatlijnen en
  // technische vlakken behouden.
  static const int _witteRandDrempel = 252;

  static Future<Map<String, Uint8List>> maakTekeningen(
    Iterable<OpmetingOverzichtRaamItem> posities,
  ) async {
    final resultaat = <String, Uint8List>{};

    for (final positie in posities) {
      if (positie.isVerwijderd ||
          !OfferteArtikelPrijsKoppelingService.isAlgemeenArtikel(positie)) {
        continue;
      }

      final id = positie.id.trim();
      if (id.isEmpty || resultaat.containsKey(id)) {
        continue;
      }

      final png = await _maakTekening(positie);
      if (png != null && png.isNotEmpty) {
        resultaat[id] = png;
      }
    }

    return Map<String, Uint8List>.unmodifiable(resultaat);
  }

  static Future<Uint8List?> _maakTekening(
    OpmetingOverzichtRaamItem positie,
  ) async {
    ui.Image? proefAfbeelding;
    ui.Image? definitieveAfbeelding;

    try {
      // Eerste render: bepaal hoeveel de eigenlijke tekening binnen de vaste
      // 990 x 600 PNG kan worden vergroot.
      proefAfbeelding = await _renderVolledigeAfbeelding(
        positie: positie,
        maatvoeringCorrectie: 1,
      );
      final proefBegrenzing = await _zoekTekeningBegrenzing(proefAfbeelding);

      if (proefBegrenzing == null) {
        return await _encodeerPng(proefAfbeelding);
      }

      final geschatteVergroting = _berekenVulschaal(
        afbeelding: proefAfbeelding,
        begrenzing: proefBegrenzing,
      );

      // Tweede render: verklein uitsluitend de maatvoering vooraf met exact
      // dezelfde factor waarmee de volledige tekening straks wordt vergroot.
      // Het raam/deur wordt dus groot, maar pijlen en tekst blijven klein.
      definitieveAfbeelding = await _renderVolledigeAfbeelding(
        positie: positie,
        maatvoeringCorrectie: geschatteVergroting,
      );
      final definitieveBegrenzing = await _zoekTekeningBegrenzing(
        definitieveAfbeelding,
      );

      if (definitieveBegrenzing == null) {
        return await _encodeerPng(definitieveAfbeelding);
      }

      return await _maakVullendePng(
        volledigeAfbeelding: definitieveAfbeelding,
        begrenzing: definitieveBegrenzing,
      );
    } catch (_) {
      // De PDF-widget heeft een veilige kadertekening als terugval.
      return null;
    } finally {
      proefAfbeelding?.dispose();
      definitieveAfbeelding?.dispose();
    }
  }

  static Future<ui.Image> _renderVolledigeAfbeelding({
    required OpmetingOverzichtRaamItem positie,
    required double maatvoeringCorrectie,
  }) async {
    final veiligeCorrectie =
        maatvoeringCorrectie.isFinite && maatvoeringCorrectie > 0
        ? maatvoeringCorrectie
        : 1.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.scale(_pixelRatio, _pixelRatio);
    canvas.drawRect(
      Offset.zero & _logischeGrootte,
      Paint()..color = Colors.white,
    );

    final painter = OpmetingOverzichtTekening(
      item: positie,
      toonAchtergrondRaster: false,
      maatPijlGrootte: _offerteMaatPijlGrootte / veiligeCorrectie,
      maatLettergrootte: _offerteMaatLettergrootte / veiligeCorrectie,
      maatLijndikte: _offerteMaatLijndikte / veiligeCorrectie,
    );
    painter.paint(canvas, _logischeGrootte);

    final picture = recorder.endRecording();

    try {
      return await picture.toImage(
        (_logischeGrootte.width * _pixelRatio).round(),
        (_logischeGrootte.height * _pixelRatio).round(),
      );
    } finally {
      picture.dispose();
    }
  }

  static Future<_TekeningBegrenzing?> _zoekTekeningBegrenzing(
    ui.Image afbeelding,
  ) async {
    final ruweData = await afbeelding.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );

    if (ruweData == null) {
      return null;
    }

    final breedte = afbeelding.width;
    final hoogte = afbeelding.height;
    final pixels = ruweData.buffer.asUint8List(
      ruweData.offsetInBytes,
      ruweData.lengthInBytes,
    );

    var minimumX = breedte;
    var minimumY = hoogte;
    var maximumX = -1;
    var maximumY = -1;

    for (var y = 0; y < hoogte; y++) {
      final rijStart = y * breedte * 4;

      for (var x = 0; x < breedte; x++) {
        final index = rijStart + x * 4;
        final rood = pixels[index];
        final groen = pixels[index + 1];
        final blauw = pixels[index + 2];
        final alpha = pixels[index + 3];

        if (!_isTekeningPixel(
          rood: rood,
          groen: groen,
          blauw: blauw,
          alpha: alpha,
        )) {
          continue;
        }

        if (x < minimumX) minimumX = x;
        if (x > maximumX) maximumX = x;
        if (y < minimumY) minimumY = y;
        if (y > maximumY) maximumY = y;
      }
    }

    if (maximumX < minimumX || maximumY < minimumY) {
      return null;
    }

    return _TekeningBegrenzing(
      links: minimumX,
      boven: minimumY,
      rechts: maximumX,
      onder: maximumY,
    );
  }

  static double _berekenVulschaal({
    required ui.Image afbeelding,
    required _TekeningBegrenzing begrenzing,
  }) {
    final margePx = _doelMargeLogisch * _pixelRatio;
    final beschikbareBreedte = math.max(
      1.0,
      afbeelding.width.toDouble() - 2 * margePx,
    );
    final beschikbareHoogte = math.max(
      1.0,
      afbeelding.height.toDouble() - 2 * margePx,
    );
    final schaal = math.min(
      beschikbareBreedte / begrenzing.breedte,
      beschikbareHoogte / begrenzing.hoogte,
    );

    if (!schaal.isFinite || schaal <= 0) {
      return 1.0;
    }

    // Extreme correcties zijn niet nodig en kunnen zeer dunne lijnen geven.
    return schaal.clamp(0.5, 4.0).toDouble();
  }

  static Future<Uint8List?> _maakVullendePng({
    required ui.Image volledigeAfbeelding,
    required _TekeningBegrenzing begrenzing,
  }) async {
    final breedte = volledigeAfbeelding.width;
    final hoogte = volledigeAfbeelding.height;
    final schaal = _berekenVulschaal(
      afbeelding: volledigeAfbeelding,
      begrenzing: begrenzing,
    );
    final doelBreedte = begrenzing.breedte * schaal;
    final doelHoogte = begrenzing.hoogte * schaal;
    final doelLinks = (breedte - doelBreedte) / 2.0;
    final doelBoven = (hoogte - doelHoogte) / 2.0;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, breedte.toDouble(), hoogte.toDouble()),
      Paint()..color = Colors.white,
    );

    canvas.drawImageRect(
      volledigeAfbeelding,
      begrenzing.rect,
      Rect.fromLTWH(doelLinks, doelBoven, doelBreedte, doelHoogte),
      Paint()
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.high,
    );

    final picture = recorder.endRecording();
    final vullendeAfbeelding = await picture.toImage(breedte, hoogte);
    picture.dispose();

    try {
      return await _encodeerPng(vullendeAfbeelding);
    } finally {
      vullendeAfbeelding.dispose();
    }
  }

  static bool _isTekeningPixel({
    required int rood,
    required int groen,
    required int blauw,
    required int alpha,
  }) {
    if (alpha <= 8) {
      return false;
    }

    return rood < _witteRandDrempel ||
        groen < _witteRandDrempel ||
        blauw < _witteRandDrempel;
  }

  static Future<Uint8List?> _encodeerPng(ui.Image afbeelding) async {
    final data = await afbeelding.toByteData(format: ui.ImageByteFormat.png);

    return data?.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}

class _TekeningBegrenzing {
  const _TekeningBegrenzing({
    required this.links,
    required this.boven,
    required this.rechts,
    required this.onder,
  });

  final int links;
  final int boven;
  final int rechts;
  final int onder;

  double get breedte => (rechts - links + 1).toDouble();
  double get hoogte => (onder - boven + 1).toDouble();

  Rect get rect =>
      Rect.fromLTWH(links.toDouble(), boven.toDouble(), breedte, hoogte);
}
