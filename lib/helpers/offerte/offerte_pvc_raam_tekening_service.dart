// THIMACO-CONTROLE: OFFERTE-MAATVOERING-KLEIN-FIJN-20260726
// THIMACO-CONTROLE: OFFERTE-PVC-TEKENING-WITTE-RAND-AFGESNEDEN-20260726
// THIMACO-CONTROLE: OFFERTE-PVC-MAATVOERING-GELIJK-INZETHOR-20260720
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../opmeting/overzicht/opmeting_overzicht_model.dart';
import '../opmeting/overzicht/opmeting_overzicht_tekening.dart';
import 'prijzen/offerte_artikel_prijs_koppeling_service.dart';

/// Maakt voor de offerte een PNG van exact dezelfde algemene raam- of
/// deurtekening die op het overzichtsformulier wordt gebruikt.
///
/// Hierdoor hoeft de PDF geen tweede, afwijkende tekenlogica te onderhouden.
/// T-stijlen, vleugels, vullingen, kleinhouten, deurpanelen en technische
/// symbolen volgen automatisch de bestaande overzichtstekening.
class OffertePvcRaamTekeningService {
  const OffertePvcRaamTekeningService._();

  static const Size _logischeGrootte = Size(990, 600);
  static const double _pixelRatio = 2;

  // De PNG wordt in de offerte tot ongeveer een kwart van zijn logische
  // breedte verkleind. De doelmaten worden daarom vooraf vergroot. Na plaatsing
  // in de PDF zijn de pijlen, tekst en lijnen gelijk aan de vaste inzethor.
  static const double _offerteMaatvoeringFactor = 4.25;
  static const double _offerteMaatPijlGrootte = 1.6 * _offerteMaatvoeringFactor;
  static const double _offerteMaatLettergrootte =
      6.2 * _offerteMaatvoeringFactor;
  static const double _offerteMaatLijndikte = 0.18 * _offerteMaatvoeringFactor;

  // Een pixel wordt als inhoud beschouwd zodra hij voldoende afwijkt van de
  // volledig witte achtergrond. Zo blijven ook lichtgrijze maatlijnen en
  // technische vlakken behouden.
  static const int _witteRandDrempel = 252;

  // Kleine veiligheidsmarge rond de gevonden tekening, uitgedrukt in logische
  // pixels. De uniforme PDF-marge wordt afzonderlijk door de artikel-layout
  // toegepast.
  static const double _uitsnijVeiligheidsmarge = 4;

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
    ui.Image? volledigeAfbeelding;

    try {
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
        maatPijlGrootte: _offerteMaatPijlGrootte,
        maatLettergrootte: _offerteMaatLettergrootte,
        maatLijndikte: _offerteMaatLijndikte,
      );
      painter.paint(canvas, _logischeGrootte);

      final picture = recorder.endRecording();
      volledigeAfbeelding = await picture.toImage(
        (_logischeGrootte.width * _pixelRatio).round(),
        (_logischeGrootte.height * _pixelRatio).round(),
      );
      picture.dispose();

      return await _maakBijgesnedenPng(volledigeAfbeelding);
    } catch (_) {
      // De PDF-widget heeft een veilige kadertekening als terugval.
      return null;
    } finally {
      volledigeAfbeelding?.dispose();
    }
  }

  static Future<Uint8List?> _maakBijgesnedenPng(
    ui.Image volledigeAfbeelding,
  ) async {
    final ruweData = await volledigeAfbeelding.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );

    if (ruweData == null) {
      return _encodeerPng(volledigeAfbeelding);
    }

    final breedte = volledigeAfbeelding.width;
    final hoogte = volledigeAfbeelding.height;
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
      return _encodeerPng(volledigeAfbeelding);
    }

    final marge = (_uitsnijVeiligheidsmarge * _pixelRatio).round();

    minimumX = (minimumX - marge).clamp(0, breedte - 1).toInt();
    minimumY = (minimumY - marge).clamp(0, hoogte - 1).toInt();
    maximumX = (maximumX + marge).clamp(0, breedte - 1).toInt();
    maximumY = (maximumY + marge).clamp(0, hoogte - 1).toInt();

    final uitsnijBreedte = maximumX - minimumX + 1;
    final uitsnijHoogte = maximumY - minimumY + 1;

    if (uitsnijBreedte <= 1 || uitsnijHoogte <= 1) {
      return _encodeerPng(volledigeAfbeelding);
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, uitsnijBreedte.toDouble(), uitsnijHoogte.toDouble()),
      Paint()..color = Colors.white,
    );

    canvas.drawImageRect(
      volledigeAfbeelding,
      Rect.fromLTWH(
        minimumX.toDouble(),
        minimumY.toDouble(),
        uitsnijBreedte.toDouble(),
        uitsnijHoogte.toDouble(),
      ),
      Rect.fromLTWH(0, 0, uitsnijBreedte.toDouble(), uitsnijHoogte.toDouble()),
      Paint()
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.high,
    );

    final picture = recorder.endRecording();
    final bijgesnedenAfbeelding = await picture.toImage(
      uitsnijBreedte,
      uitsnijHoogte,
    );
    picture.dispose();

    try {
      return await _encodeerPng(bijgesnedenAfbeelding);
    } finally {
      bijgesnedenAfbeelding.dispose();
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
