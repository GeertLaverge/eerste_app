import 'package:flutter/material.dart';

import 'opmeting_raam_model.dart';
import 'opmeting_raam_opvulling_model.dart';
import 'opmeting_raam_vulling_helper.dart';

// THIMACO-CONTROLE: OPVULLING-LIJNEN-ZICHTBAAR-SCHAAL-FIX-20260805
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

      switch (toewijzing.weergave) {
        case OpmetingRaamOpvullingWeergave.horizontaleLijnen:
          _tekenHorizontaleLijnen(
            canvas: canvas,
            vlak: vulvlak.vlak,
            kleur: toewijzing.kleur,
            afstandMm: toewijzing.lijnAfstandMm,
          );
          break;
        case OpmetingRaamOpvullingWeergave.verticaleLijnen:
          _tekenVerticaleLijnen(
            canvas: canvas,
            vlak: vulvlak.vlak,
            kleur: toewijzing.kleur,
            afstandMm: toewijzing.lijnAfstandMm,
          );
          break;
        case OpmetingRaamOpvullingWeergave.effen:
        case OpmetingRaamOpvullingWeergave.tekst:
          break;
      }
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

      final heeftVrijeTekst =
          toewijzing != null &&
          toewijzing.weergave == OpmetingRaamOpvullingWeergave.tekst &&
          toewijzing.tekeningTekst.trim().isNotEmpty;

      if (heeftVrijeTekst) {
        _tekenVrijeTekst(
          canvas: canvas,
          vlak: vulvlak.vlak,
          tekst: toewijzing.tekeningTekst.trim(),
        );
      }

      if (toewijzing != null && nummer != null) {
        _tekenNummer(
          canvas: canvas,
          vlak: vulvlak.vlak,
          nummer: nummer,
          verschuifNaarBoven: heeftVrijeTekst,
        );
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
    bool verschuifNaarBoven = false,
  }) {
    final midden = verschuifNaarBoven
        ? Offset(vlak.center.dx, vlak.top + 20)
        : vlak.center;

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
        ..color = Colors.white.withValues(alpha: 0.90)
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

  static void _tekenHorizontaleLijnen({
    required Canvas canvas,
    required Rect vlak,
    required Color kleur,
    required int afstandMm,
  }) {
    final afstand = _lijnAfstandOpTekening(
      vlak: vlak,
      afstandMm: afstandMm,
      horizontaleLijnen: true,
    );
    final lijnKleur = kleur.computeLuminance() < 0.35
        ? Colors.white.withValues(alpha: 0.88)
        : const Color(0xFF111827).withValues(alpha: 0.72);

    final paint = Paint()
      ..color = lijnKleur
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.clipRect(vlak);

    for (double y = vlak.top + afstand; y < vlak.bottom; y += afstand) {
      canvas.drawLine(Offset(vlak.left, y), Offset(vlak.right, y), paint);
    }

    canvas.restore();
  }

  static void _tekenVerticaleLijnen({
    required Canvas canvas,
    required Rect vlak,
    required Color kleur,
    required int afstandMm,
  }) {
    final afstand = _lijnAfstandOpTekening(
      vlak: vlak,
      afstandMm: afstandMm,
      horizontaleLijnen: false,
    );
    final lijnKleur = kleur.computeLuminance() < 0.35
        ? Colors.white.withValues(alpha: 0.88)
        : const Color(0xFF111827).withValues(alpha: 0.72);

    final paint = Paint()
      ..color = lijnKleur
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.clipRect(vlak);

    for (double x = vlak.left + afstand; x < vlak.right; x += afstand) {
      canvas.drawLine(Offset(x, vlak.top), Offset(x, vlak.bottom), paint);
    }

    canvas.restore();
  }

  static double _lijnAfstandOpTekening({
    required Rect vlak,
    required int afstandMm,
    required bool horizontaleLijnen,
  }) {
    final beschikbareMaat = horizontaleLijnen ? vlak.height : vlak.width;

    if (beschikbareMaat <= 0) {
      return 12;
    }

    // Bij 100 mm tekenen we ongeveer vijf gelijke vakken binnen
    // het actuele vulvlak. De afstand schaalt vervolgens mee met
    // een andere ingestelde millimeterwaarde.
    final basisVoor100Mm = (beschikbareMaat / 5).clamp(10.0, 34.0).toDouble();

    return basisVoor100Mm * (afstandMm.clamp(10, 1000).toDouble() / 100);
  }

  static void _tekenVrijeTekst({
    required Canvas canvas,
    required Rect vlak,
    required String tekst,
  }) {
    final maximaleBreedte = (vlak.width - 16).clamp(30.0, 500.0).toDouble();

    final tekstPainter = TextPainter(
      text: TextSpan(
        text: tekst,
        style: const TextStyle(
          color: _tekstKleur,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 3,
      ellipsis: '…',
    )..layout(maxWidth: maximaleBreedte);

    final achtergrond = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: vlak.center,
        width: tekstPainter.width + 16,
        height: tekstPainter.height + 10,
      ),
      const Radius.circular(6),
    );

    canvas.drawRRect(
      achtergrond,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.88)
        ..style = PaintingStyle.fill,
    );

    canvas.drawRRect(
      achtergrond,
      Paint()
        ..color = _tekstKleur.withValues(alpha: 0.45)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke,
    );

    tekstPainter.paint(
      canvas,
      Offset(
        vlak.center.dx - tekstPainter.width / 2,
        vlak.center.dy - tekstPainter.height / 2,
      ),
    );
  }

  static void _tekenSelectie({required Canvas canvas, required Rect vlak}) {
    canvas.drawRect(
      vlak,
      Paint()
        ..color = _selectieKleur.withValues(alpha: 0.13)
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
