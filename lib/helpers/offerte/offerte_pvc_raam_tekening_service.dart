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
  static const double _offerteMaatPijlGrootte = 7.0 * _offerteMaatvoeringFactor;
  static const double _offerteMaatLettergrootte =
      7.2 * _offerteMaatvoeringFactor;
  static const double _offerteMaatLijndikte = 0.9 * _offerteMaatvoeringFactor;

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
      final afbeelding = await picture.toImage(
        (_logischeGrootte.width * _pixelRatio).round(),
        (_logischeGrootte.height * _pixelRatio).round(),
      );
      final data = await afbeelding.toByteData(format: ui.ImageByteFormat.png);
      afbeelding.dispose();

      return data?.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } catch (_) {
      // De PDF-widget heeft een veilige kadertekening als terugval.
      return null;
    }
  }
}
