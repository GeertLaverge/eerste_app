import 'package:flutter/material.dart';

import 'opmeting_raam_kader_helper.dart';
import 'opmeting_raam_model.dart';
import 'opmeting_raam_tstijl_helper.dart';

class OpmetingRaamTekenvlak extends StatefulWidget {
  const OpmetingRaamTekenvlak({
    super.key,
    required this.breedteMm,
    required this.hoogteMm,
    required this.actieveTool,
    required this.positieController,
  });

  final int breedteMm;
  final int hoogteMm;
  final String actieveTool;
  final TextEditingController positieController;

  @override
  State<OpmetingRaamTekenvlak> createState() => _OpmetingRaamTekenvlakState();
}

class _OpmetingRaamTekenvlakState extends State<OpmetingRaamTekenvlak> {
  final List<OpmetingRaamTStijl> _tStijlen = [];

  void _klikTekenvlak(TapDownDetails details) {
    if (widget.actieveTool != 'tstijl') return;

    setState(() {
      _tStijlen.clear();

      final box = context.findRenderObject() as RenderBox;
      final size = box.size;

      final buiten = OpmetingRaamKaderHelper.buitenKader(
        size: size,
        breedteMm: widget.breedteMm,
        hoogteMm: widget.hoogteMm,
      );

      final binnen = OpmetingRaamKaderHelper.binnenKader(
        buitenKader: buiten,
        breedteMm: widget.breedteMm,
        hoogteMm: widget.hoogteMm,
      );

      final x = binnen.center.dx;

      _tStijlen.add(
        OpmetingRaamTStijl(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          start: Offset(x, binnen.top),
          einde: Offset(x, binnen.bottom),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _klikTekenvlak,
        child: CustomPaint(
          painter: _BasisOpmetingPainter(
            breedteMm: widget.breedteMm,
            hoogteMm: widget.hoogteMm,
            tStijlen: _tStijlen,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _BasisOpmetingPainter extends CustomPainter {
  const _BasisOpmetingPainter({
    required this.breedteMm,
    required this.hoogteMm,
    required this.tStijlen,
  });

  final int breedteMm;
  final int hoogteMm;
  final List<OpmetingRaamTStijl> tStijlen;

  @override
  void paint(Canvas canvas, Size size) {
    _tekenRaster(canvas, size);

    final buiten = OpmetingRaamKaderHelper.buitenKader(
      size: size,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    final binnen = OpmetingRaamKaderHelper.binnenKader(
      buitenKader: buiten,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    _tekenKader(canvas, buiten, binnen);

    for (final stijl in tStijlen) {
      OpmetingRaamTStijlHelper.tekenTStijl(
        canvas: canvas,
        stijl: stijl,
        buitenKader: buiten,
        breedteMm: breedteMm,
      );
    }

    _tekenMaatlijnen(canvas, buiten);
  }

  void _tekenRaster(Canvas canvas, Size size) {
    final rasterKlein = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 0.4;

    final rasterGroot = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 0.8;

    for (double x = 0; x <= size.width; x += 10) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), rasterKlein);
    }

    for (double y = 0; y <= size.height; y += 10) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), rasterKlein);
    }

    for (double x = 0; x <= size.width; x += 100) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), rasterGroot);
    }

    for (double y = 0; y <= size.height; y += 100) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), rasterGroot);
    }
  }

  void _tekenKader(Canvas canvas, Rect buiten, Rect binnen) {
    final kaderVulling = Paint()
      ..color = Colors.white.withOpacity(0.75)
      ..style = PaintingStyle.fill;

    final kaderLijn = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final verstekLijn = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 1.0;

    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(buiten)
      ..addRect(binnen);

    canvas.drawPath(path, kaderVulling);
    canvas.drawRect(buiten, kaderLijn);
    canvas.drawRect(binnen, kaderLijn);

    canvas.drawLine(buiten.topLeft, binnen.topLeft, verstekLijn);
    canvas.drawLine(buiten.topRight, binnen.topRight, verstekLijn);
    canvas.drawLine(buiten.bottomLeft, binnen.bottomLeft, verstekLijn);
    canvas.drawLine(buiten.bottomRight, binnen.bottomRight, verstekLijn);
  }

  void _tekenMaatlijnen(Canvas canvas, Rect buiten) {
    final maatPaint = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 1.0;

    final tekstStyle = const TextStyle(
      color: Color(0xFF111827),
      fontSize: 12,
      fontWeight: FontWeight.w800,
    );

    final onderY = buiten.bottom + 28;

    canvas.drawLine(
      Offset(buiten.left, onderY),
      Offset(buiten.right, onderY),
      maatPaint,
    );

    canvas.drawLine(
      Offset(buiten.left, onderY - 5),
      Offset(buiten.left, onderY + 5),
      maatPaint,
    );

    canvas.drawLine(
      Offset(buiten.right, onderY - 5),
      Offset(buiten.right, onderY + 5),
      maatPaint,
    );

    _tekenTekst(
      canvas,
      '$breedteMm mm',
      Offset((buiten.left + buiten.right) / 2, onderY + 6),
      tekstStyle,
      center: true,
    );

    final rechtsX = buiten.right + 28;

    canvas.drawLine(
      Offset(rechtsX, buiten.top),
      Offset(rechtsX, buiten.bottom),
      maatPaint,
    );

    canvas.drawLine(
      Offset(rechtsX - 5, buiten.top),
      Offset(rechtsX + 5, buiten.top),
      maatPaint,
    );

    canvas.drawLine(
      Offset(rechtsX - 5, buiten.bottom),
      Offset(rechtsX + 5, buiten.bottom),
      maatPaint,
    );

    canvas.save();
    canvas.translate(rechtsX + 8, (buiten.top + buiten.bottom) / 2);
    canvas.rotate(-1.5708);

    _tekenTekst(canvas, '$hoogteMm mm', Offset.zero, tekstStyle, center: true);

    canvas.restore();
  }

  void _tekenTekst(
    Canvas canvas,
    String tekst,
    Offset positie,
    TextStyle style, {
    bool center = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: tekst, style: style),
      textDirection: TextDirection.ltr,
    );

    painter.layout();

    painter.paint(
      canvas,
      center ? Offset(positie.dx - painter.width / 2, positie.dy) : positie,
    );
  }

  @override
  bool shouldRepaint(covariant _BasisOpmetingPainter oldDelegate) {
    return oldDelegate.breedteMm != breedteMm ||
        oldDelegate.hoogteMm != hoogteMm ||
        oldDelegate.tStijlen.length != tStijlen.length;
  }
}
