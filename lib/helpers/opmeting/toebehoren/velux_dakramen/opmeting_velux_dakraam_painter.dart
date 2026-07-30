// THIMACO-CONTROLE: VELUX-TEKENING-FASE-1-2-20260729-2030
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'opmeting_velux_dakraam_model.dart';

class OpmetingVeluxDakraamPainter extends CustomPainter {
  const OpmetingVeluxDakraamPainter({required this.model});

  final OpmetingVeluxDakraamModel model;

  static const Color _lijn = Color(0xFF111827);
  static const Color _maat = Color(0xFF64748B);
  static const Color _glas = Color(0xFFAFCBF0);
  static const Color _kaderVulling = Color(0xFFF9FAFB);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 20 || size.height <= 20) return;

    if (model.alleenToebehoren) {
      _tekenAlleenToebehoren(canvas, size);
      return;
    }

    final breedte = math.max(100, model.breedteMm).toDouble();
    final hoogte = math.max(100, model.hoogteMm).toDouble();
    const margeLinks = 64.0;
    const margeRechts = 74.0;
    const margeBoven = 36.0;
    const margeOnder = 64.0;
    final beschikbareBreedte = math
        .max(20.0, size.width - margeLinks - margeRechts)
        .toDouble();
    final beschikbareHoogte = math
        .max(20.0, size.height - margeBoven - margeOnder)
        .toDouble();
    final schaal = math.min(
      beschikbareBreedte / breedte,
      beschikbareHoogte / hoogte,
    );

    final getekendeBreedte = breedte * schaal;
    final getekendeHoogte = hoogte * schaal;
    final links = margeLinks + (beschikbareBreedte - getekendeBreedte) / 2;
    final boven = margeBoven + (beschikbareHoogte - getekendeHoogte) / 2;
    final buitenRect = Rect.fromLTWH(
      links,
      boven,
      getekendeBreedte,
      getekendeHoogte,
    );

    final buitenKaderPx = math.max(4.0, 40 * schaal);
    final binnenKaderPx = math.max(6.0, 60 * schaal);
    final vleugelRect = buitenRect.deflate(buitenKaderPx);
    final glasRect = vleugelRect.deflate(binnenKaderPx);

    final lijnPaint = Paint()
      ..color = _lijn
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final dunneLijn = Paint()
      ..color = _lijn
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.05;

    canvas.drawRect(buitenRect, Paint()..color = _kaderVulling);
    canvas.drawRect(buitenRect, lijnPaint);
    canvas.drawRect(vleugelRect, lijnPaint);

    canvas.drawRect(glasRect, Paint()..color = _glas);
    canvas.drawRect(glasRect, lijnPaint);

    final middenLinks = Offset(glasRect.left, glasRect.center.dy);
    final middenRechts = Offset(glasRect.right, glasRect.center.dy);
    final middenBoven = Offset(glasRect.center.dx, glasRect.top);
    final middenOnder = Offset(glasRect.center.dx, glasRect.bottom);
    canvas.drawLine(middenLinks, middenBoven, dunneLijn);
    canvas.drawLine(middenBoven, middenRechts, dunneLijn);
    canvas.drawLine(middenRechts, middenOnder, dunneLijn);
    canvas.drawLine(middenOnder, middenLinks, dunneLijn);

    final handgreepHoogte = math.max(8.0, math.min(18.0, 24 * schaal));
    final handgreepMarge = math.max(6.0, 15 * schaal);
    final handgreepRect = Rect.fromLTWH(
      glasRect.left,
      vleugelRect.top + handgreepMarge,
      glasRect.width,
      handgreepHoogte,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(handgreepRect, const Radius.circular(2)),
      Paint()..color = const Color(0xFFF3F4F6),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(handgreepRect, const Radius.circular(2)),
      lijnPaint,
    );

    _tekenMaatvoering(
      canvas: canvas,
      buitenRect: buitenRect,
      breedteLabel: '${model.breedteMm} mm',
      hoogteLabel: '${model.hoogteMm} mm',
    );
  }

  void _tekenAlleenToebehoren(Canvas canvas, Size size) {
    final icoonPaint = Paint()
      ..color = const Color(0xFFE7F6EC)
      ..style = PaintingStyle.fill;
    final cirkel = Offset(size.width / 2, size.height / 2 - 32);
    canvas.drawCircle(cirkel, 34, icoonPaint);

    final icoon = TextPainter(
      text: const TextSpan(
        text: 'V',
        style: TextStyle(
          color: Color(0xFF0B7A3B),
          fontSize: 30,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    icoon.paint(canvas, cirkel - Offset(icoon.width / 2, icoon.height / 2));

    final tekst = TextPainter(
      text: const TextSpan(
        text: 'Velux accessoires',
        style: TextStyle(
          color: Color(0xFF0B7A3B),
          fontSize: 23,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: size.width - 60);
    tekst.paint(canvas, Offset((size.width - tekst.width) / 2, cirkel.dy + 46));
  }

  void _tekenMaatvoering({
    required Canvas canvas,
    required Rect buitenRect,
    required String breedteLabel,
    required String hoogteLabel,
  }) {
    final paint = Paint()
      ..color = _maat
      ..strokeWidth = 1;
    const pijl = 5.0;

    final maatY = buitenRect.bottom + 28;
    canvas.drawLine(
      Offset(buitenRect.left, buitenRect.bottom + 4),
      Offset(buitenRect.left, maatY + 5),
      paint,
    );
    canvas.drawLine(
      Offset(buitenRect.right, buitenRect.bottom + 4),
      Offset(buitenRect.right, maatY + 5),
      paint,
    );
    canvas.drawLine(
      Offset(buitenRect.left, maatY),
      Offset(buitenRect.right, maatY),
      paint,
    );
    canvas.drawLine(
      Offset(buitenRect.left, maatY),
      Offset(buitenRect.left + pijl, maatY - 3),
      paint,
    );
    canvas.drawLine(
      Offset(buitenRect.left, maatY),
      Offset(buitenRect.left + pijl, maatY + 3),
      paint,
    );
    canvas.drawLine(
      Offset(buitenRect.right, maatY),
      Offset(buitenRect.right - pijl, maatY - 3),
      paint,
    );
    canvas.drawLine(
      Offset(buitenRect.right, maatY),
      Offset(buitenRect.right - pijl, maatY + 3),
      paint,
    );
    _tekenTekst(
      canvas,
      breedteLabel,
      Offset(buitenRect.center.dx, maatY + 4),
      horizontaalMidden: true,
    );

    final maatX = buitenRect.right + 28;
    canvas.drawLine(
      Offset(buitenRect.right + 4, buitenRect.top),
      Offset(maatX + 5, buitenRect.top),
      paint,
    );
    canvas.drawLine(
      Offset(buitenRect.right + 4, buitenRect.bottom),
      Offset(maatX + 5, buitenRect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(maatX, buitenRect.top),
      Offset(maatX, buitenRect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(maatX, buitenRect.top),
      Offset(maatX - 3, buitenRect.top + pijl),
      paint,
    );
    canvas.drawLine(
      Offset(maatX, buitenRect.top),
      Offset(maatX + 3, buitenRect.top + pijl),
      paint,
    );
    canvas.drawLine(
      Offset(maatX, buitenRect.bottom),
      Offset(maatX - 3, buitenRect.bottom - pijl),
      paint,
    );
    canvas.drawLine(
      Offset(maatX, buitenRect.bottom),
      Offset(maatX + 3, buitenRect.bottom - pijl),
      paint,
    );

    canvas.save();
    canvas.translate(maatX + 11, buitenRect.center.dy);
    canvas.rotate(-math.pi / 2);
    _tekenTekst(canvas, hoogteLabel, Offset.zero, horizontaalMidden: true);
    canvas.restore();
  }

  void _tekenTekst(
    Canvas canvas,
    String tekst,
    Offset positie, {
    bool horizontaalMidden = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: tekst,
        style: const TextStyle(
          color: _maat,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = horizontaalMidden ? positie.dx - painter.width / 2 : positie.dx;
    painter.paint(canvas, Offset(dx, positie.dy));
  }

  @override
  bool shouldRepaint(covariant OpmetingVeluxDakraamPainter oldDelegate) {
    return oldDelegate.model.toJson().toString() != model.toJson().toString();
  }
}
