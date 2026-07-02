import 'package:flutter/material.dart';

import 'opmeting_raam_model.dart';
import 'opmeting_raam_vulling_helper.dart';

class OpmetingRaamVullingTekenHelper {
  const OpmetingRaamVullingTekenHelper._();

  static const Color _tekstKleur = Color(0xFF111827);
  static const Color _selectieKleur = Color(0xFFF97316);

  /// Tekent uitsluitend de kleuren van de opvullingen.
  ///
  /// Deze methode moet worden uitgevoerd vóór het kader,
  /// de vleugels en de T-stijlen worden getekend.
  static void tekenAchtergrond({
    required Canvas canvas,
    required List<OpmetingRaamVulvlak> vulvlakken,
    required List<OpmetingRaamVullingToewijzing> toewijzingen,
  }) {
    final toewijzingPerVlakId = <String, OpmetingRaamVullingToewijzing>{
      for (final toewijzing in toewijzingen) toewijzing.vlakId: toewijzing,
    };

    for (final vulvlak in vulvlakken) {
      final toewijzing = toewijzingPerVlakId[vulvlak.id];

      if (toewijzing == null) {
        continue;
      }

      canvas.drawRect(
        vulvlak.vlak,
        Paint()
          ..color = toewijzing.weergaveKleur
          ..style = PaintingStyle.fill,
      );
    }
  }

  /// Tekent de nummers en de oranje selectieranden.
  ///
  /// Deze methode moet worden uitgevoerd nadat het kader,
  /// de vleugels en de T-stijlen zijn getekend.
  static void tekenVoorgrond({
    required Canvas canvas,
    required List<OpmetingRaamVulvlak> vulvlakken,
    required List<OpmetingRaamVullingToewijzing> toewijzingen,
    required Set<String> geselecteerdeVulvlakIds,
  }) {
    final toewijzingPerVlakId = <String, OpmetingRaamVullingToewijzing>{
      for (final toewijzing in toewijzingen) toewijzing.vlakId: toewijzing,
    };

    final nummerPerVlak = OpmetingRaamVullingHelper.bepaalNummerPerVlak(
      vulvlakken: vulvlakken,
      toewijzingen: toewijzingen,
    );

    for (final vulvlak in vulvlakken) {
      final toewijzing = toewijzingPerVlakId[vulvlak.id];
      final nummer = nummerPerVlak[vulvlak.id];

      if (toewijzing != null && nummer != null) {
        _tekenNummer(canvas: canvas, vlak: vulvlak.vlak, nummer: nummer);
      }

      if (geselecteerdeVulvlakIds.contains(vulvlak.id)) {
        _tekenSelectie(canvas: canvas, vlak: vulvlak.vlak);
      }
    }
  }

  static void _tekenNummer({
    required Canvas canvas,
    required Rect vlak,
    required int nummer,
  }) {
    final midden = vlak.center;

    final tekstPainter = TextPainter(
      text: TextSpan(
        text: '$nummer',
        style: const TextStyle(
          color: _tekstKleur,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    tekstPainter.layout();

    final diameter = (tekstPainter.width + 16).clamp(26.0, 38.0).toDouble();

    canvas.drawCircle(
      midden,
      diameter / 2,
      Paint()
        ..color = Colors.white.withOpacity(0.90)
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      midden,
      diameter / 2,
      Paint()
        ..color = _tekstKleur
        ..strokeWidth = 1.1
        ..style = PaintingStyle.stroke,
    );

    tekstPainter.paint(
      canvas,
      Offset(
        midden.dx - tekstPainter.width / 2,
        midden.dy - tekstPainter.height / 2,
      ),
    );
  }

  static void _tekenSelectie({required Canvas canvas, required Rect vlak}) {
    canvas.drawRect(
      vlak,
      Paint()
        ..color = _selectieKleur.withOpacity(0.13)
        ..style = PaintingStyle.fill,
    );

    final randVlak = vlak.width > 3 && vlak.height > 3
        ? vlak.deflate(1.5)
        : vlak;

    canvas.drawRect(
      randVlak,
      Paint()
        ..color = _selectieKleur
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );
  }
}
