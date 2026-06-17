import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'opmeting_teken_model.dart';

class OpmetingTekenPainter extends CustomPainter {
  OpmetingTekenPainter({
    required this.startPunt,
    required this.eindPunt,
    required this.rechthoek,
    required this.lijnen,
    required this.tStijlen,
    required this.tStijlKandidaten,
    required this.actieveTStijlKandidaat,
    required this.snappunten,
    required this.actiefSnappunt,
    required this.lijnStart,
    required this.driehoekPunt1,
    required this.driehoekPunt2,
    required this.breedteMm,
    required this.hoogteMm,
    required this.geselecteerdeTStijlId,
    required this.tStijlMenuOpen,
  });

  final Offset? startPunt;
  final Offset? eindPunt;
  final Rect? rechthoek;

  final List<OpmetingLijn> lijnen;
  final List<OpmetingTStijl> tStijlen;
  final List<Offset> tStijlKandidaten;
  final Offset? actieveTStijlKandidaat;

  final List<Offset> snappunten;
  final Offset? actiefSnappunt;

  final Offset? lijnStart;
  final Offset? driehoekPunt1;
  final Offset? driehoekPunt2;

  final int breedteMm;
  final int hoogteMm;
  final String? geselecteerdeTStijlId;
  final bool tStijlMenuOpen;

  static const double raster10cm = 200;
  static const double raster5mm = raster10cm / 20;
  static const double kaderOffsetMm = 70;

  @override
  void paint(Canvas canvas, Size size) {
    final kleineLijn = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 0.35;

    final groteLijn = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 0.75;

    final lijnPaint = Paint()
      ..color = const Color(0xFF0B7A3B)
      ..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round;

    final previewPaint = Paint()
      ..color = const Color(0xFF0B7A3B).withOpacity(0.45)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final snapPaint = Paint()
      ..color = const Color(0xFF0B7A3B)
      ..style = PaintingStyle.fill;

    final snapZacht = Paint()
      ..color = const Color(0xFF0B7A3B).withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final snapActief = Paint()
      ..color = const Color(0xFFDC2626)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;

    final gekozenPuntPaint = Paint()
      ..color = const Color(0xFFF97316)
      ..style = PaintingStyle.fill;

    for (double x = 0; x <= size.width; x += raster5mm) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), kleineLijn);
    }

    for (double y = 0; y <= size.height; y += raster5mm) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), kleineLijn);
    }

    for (double x = 0; x <= size.width; x += raster10cm) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), groteLijn);
    }

    for (double y = 0; y <= size.height; y += raster10cm) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), groteLijn);
    }

    if (rechthoek == null && startPunt == null) {
      _tekenStartTekst(canvas, size);
    }

    if (startPunt != null && eindPunt != null && rechthoek == null) {
      canvas.drawLine(startPunt!, eindPunt!, previewPaint);
      canvas.drawCircle(startPunt!, 4, previewPaint);
      canvas.drawCircle(eindPunt!, 4, previewPaint);
    }

    _tekenRaamKader(canvas);

    for (final stijl in tStijlen) {
      _tekenTStijl(
        canvas,
        stijl,
        geselecteerd: stijl.id == geselecteerdeTStijlId,
      );
    }

    for (final lijn in lijnen) {
      canvas.drawLine(lijn.start, lijn.einde, lijnPaint);
    }

    if (tStijlMenuOpen) {
      _tekenTStijlKandidaten(canvas);

      for (final punt in snappunten) {
        canvas.drawCircle(punt, 7, snapZacht);
        canvas.drawCircle(punt, 4.2, snapPaint);
      }

      if (actiefSnappunt != null) {
        canvas.drawCircle(actiefSnappunt!, 20, snapActief);
      }

      if (lijnStart != null) {
        canvas.drawCircle(lijnStart!, 6, gekozenPuntPaint);
      }

      if (driehoekPunt1 != null) {
        canvas.drawCircle(driehoekPunt1!, 6, gekozenPuntPaint);
      }

      if (driehoekPunt2 != null && driehoekPunt1 != null) {
        canvas.drawCircle(driehoekPunt2!, 6, gekozenPuntPaint);
        canvas.drawLine(driehoekPunt1!, driehoekPunt2!, previewPaint);
      }
    }

    _tekenMaatlijnen(canvas);
  }

  void _tekenRaamKader(Canvas canvas) {
    if (rechthoek == null || breedteMm <= 0 || hoogteMm <= 0) return;

    final r = rechthoek!;

    final offsetX = (r.width / breedteMm) * kaderOffsetMm;
    final offsetY = (r.height / hoogteMm) * kaderOffsetMm;

    final veiligeOffsetX = math.min(offsetX, r.width * 0.35);
    final veiligeOffsetY = math.min(offsetY, r.height * 0.35);

    final binnen = Rect.fromLTRB(
      r.left + veiligeOffsetX,
      r.top + veiligeOffsetY,
      r.right - veiligeOffsetX,
      r.bottom - veiligeOffsetY,
    );

    if (binnen.width <= 2 || binnen.height <= 2) return;

    final kaderVulling = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.72)
      ..style = PaintingStyle.fill;

    final kaderLijn = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final verstekLijn = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(r)
      ..addRect(binnen);

    canvas.drawPath(path, kaderVulling);

    canvas.drawRect(r, kaderLijn);
    canvas.drawRect(binnen, kaderLijn);

    canvas.drawLine(r.topLeft, binnen.topLeft, verstekLijn);
    canvas.drawLine(r.topRight, binnen.topRight, verstekLijn);
    canvas.drawLine(r.bottomLeft, binnen.bottomLeft, verstekLijn);
    canvas.drawLine(r.bottomRight, binnen.bottomRight, verstekLijn);
  }

  void _tekenTStijl(
    Canvas canvas,
    OpmetingTStijl stijl, {
    required bool geselecteerd,
  }) {
    if (rechthoek == null || breedteMm <= 0 || hoogteMm <= 0) return;

    final r = rechthoek!;

    final breedtePx = stijl.richting == 'verticaal'
        ? (r.width / breedteMm) * stijl.breedteMm
        : (r.height / hoogteMm) * stijl.breedteMm;

    final halveBreedte = breedtePx / 2;

    late Rect profiel;

    if (stijl.richting == 'verticaal') {
      profiel = Rect.fromLTRB(
        stijl.start.dx - halveBreedte,
        math.min(stijl.start.dy, stijl.einde.dy),
        stijl.start.dx + halveBreedte,
        math.max(stijl.start.dy, stijl.einde.dy),
      );
    } else {
      profiel = Rect.fromLTRB(
        math.min(stijl.start.dx, stijl.einde.dx),
        stijl.start.dy - halveBreedte,
        math.max(stijl.start.dx, stijl.einde.dx),
        stijl.start.dy + halveBreedte,
      );
    }

    final vulling = Paint()
      ..color = Colors.white.withOpacity(0.80)
      ..style = PaintingStyle.fill;

    final lijn = Paint()
      ..color = geselecteerd ? const Color(0xFFDC2626) : const Color(0xFF111827)
      ..strokeWidth = geselecteerd ? 2.4 : 1.3
      ..style = PaintingStyle.stroke;

    canvas.drawRect(profiel, vulling);
    canvas.drawRect(profiel, lijn);
  }

  void _tekenTStijlKandidaten(Canvas canvas) {
    if (!tStijlMenuOpen) return;

    final kandidaatPaint = Paint()
      ..color = const Color(0xFFDC2626)
      ..style = PaintingStyle.fill;

    final kandidaatRing = Paint()
      ..color = const Color(0xFFDC2626)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final punt in tStijlKandidaten) {
      final actief = actieveTStijlKandidaat != null &&
          (actieveTStijlKandidaat! - punt).distance < 0.5;

      canvas.drawCircle(punt, actief ? 8 : 5, kandidaatPaint);

      if (actief) {
        canvas.drawCircle(punt, 18, kandidaatRing);
      }
    }
  }

  void _tekenStartTekst(Canvas canvas, Size size) {
    final tekst = TextPainter(
      text: TextSpan(
        text: 'TEKENVLAK\nTeken eerst de basislijn\n$breedteMm x $hoogteMm mm',
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 18,
          fontWeight: FontWeight.w800,
          height: 1.35,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    tekst.layout();

    tekst.paint(
      canvas,
      Offset(
        (size.width - tekst.width) / 2,
        (size.height - tekst.height) / 2,
      ),
    );
  }

  void _tekenMaatlijnen(Canvas canvas) {
    if (rechthoek == null) return;

    final r = rechthoek!;

    final maatPaint = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 1;

    final tekstStyle = const TextStyle(
      color: Color(0xFF111827),
      fontSize: 12,
      fontWeight: FontWeight.w700,
    );

    final onderY = r.bottom + 28;

    canvas.drawLine(
      Offset(r.left, onderY),
      Offset(r.right, onderY),
      maatPaint,
    );

    canvas.drawLine(
      Offset(r.left, onderY - 5),
      Offset(r.left, onderY + 5),
      maatPaint,
    );

    canvas.drawLine(
      Offset(r.right, onderY - 5),
      Offset(r.right, onderY + 5),
      maatPaint,
    );

    _tekst(
      canvas,
      '$breedteMm',
      Offset((r.left + r.right) / 2, onderY + 4),
      tekstStyle,
      center: true,
    );

    final rechtsX = r.right + 28;

    canvas.drawLine(
      Offset(rechtsX, r.top),
      Offset(rechtsX, r.bottom),
      maatPaint,
    );

    canvas.drawLine(
      Offset(rechtsX - 5, r.top),
      Offset(rechtsX + 5, r.top),
      maatPaint,
    );

    canvas.drawLine(
      Offset(rechtsX - 5, r.bottom),
      Offset(rechtsX + 5, r.bottom),
      maatPaint,
    );

    canvas.save();
    canvas.translate(rechtsX + 8, (r.top + r.bottom) / 2);
    canvas.rotate(-math.pi / 2);

    _tekst(
      canvas,
      '$hoogteMm',
      Offset.zero,
      tekstStyle,
      center: true,
    );

    canvas.restore();
  }

  void _tekst(
    Canvas canvas,
    String tekst,
    Offset positie,
    TextStyle style, {
    bool center = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: tekst,
        style: style,
      ),
      textDirection: TextDirection.ltr,
    );

    painter.layout();

    painter.paint(
      canvas,
      center
          ? Offset(
              positie.dx - painter.width / 2,
              positie.dy,
            )
          : positie,
    );
  }

  @override
  bool shouldRepaint(covariant OpmetingTekenPainter oldDelegate) {
    return true;
  }
}
