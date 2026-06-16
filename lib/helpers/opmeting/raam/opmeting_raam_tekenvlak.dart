import 'dart:math' as math;

import 'package:flutter/material.dart';

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
  Offset? _startPunt;
  Offset? _eindPunt;
  Rect? _rechthoek;

  final List<OpmetingRaamLijn> _lijnen = [];
  final List<OpmetingRaamDriehoek> _driehoeken = [];

  Offset? _lijnStart;
  Offset? _driehoekPunt1;
  Offset? _driehoekPunt2;
  Offset? _actiefSnappunt;

  static const double raster10cm = 200;
  static const double raster5mm = raster10cm / 20;
  static const double snapAfstand = 46;

  Offset _snapRaster(Offset punt) {
    final x = (punt.dx / raster5mm).round() * raster5mm;
    final y = (punt.dy / raster5mm).round() * raster5mm;
    return Offset(x, y);
  }

  List<OpmetingRaamLijn> _basisLijnen() {
    if (_rechthoek == null) return [];

    final r = _rechthoek!;

    return [
      OpmetingRaamLijn(id: 'boven', start: r.topLeft, einde: r.topRight),
      OpmetingRaamLijn(id: 'rechts', start: r.topRight, einde: r.bottomRight),
      OpmetingRaamLijn(id: 'onder', start: r.bottomLeft, einde: r.bottomRight),
      OpmetingRaamLijn(id: 'links', start: r.topLeft, einde: r.bottomLeft),
    ];
  }

  List<OpmetingRaamLijn> _alleLijnen() {
    final alle = <OpmetingRaamLijn>[
      ..._basisLijnen(),
      ..._lijnen,
    ];

    for (var i = 0; i < _driehoeken.length; i++) {
      final d = _driehoeken[i];

      alle.addAll([
        OpmetingRaamLijn(id: 'driehoek_${i}_1', start: d.punt1, einde: d.punt2),
        OpmetingRaamLijn(id: 'driehoek_${i}_2', start: d.punt1, einde: d.punt3),
        OpmetingRaamLijn(id: 'driehoek_${i}_3', start: d.punt2, einde: d.punt3),
      ]);
    }

    return alle;
  }

  List<Offset> _snappunten() {
    final punten = <Offset>[];

    for (final lijn in _alleLijnen()) {
      punten.add(lijn.start);
      punten.add(lijn.einde);
      punten.add(
        Offset(
          (lijn.start.dx + lijn.einde.dx) / 2,
          (lijn.start.dy + lijn.einde.dy) / 2,
        ),
      );
    }

    return _uniekePunten(punten);
  }

  List<Offset> _uniekePunten(List<Offset> punten) {
    final uniek = <Offset>[];

    for (final punt in punten) {
      final bestaat = uniek.any((p) => (p - punt).distance < 0.5);
      if (!bestaat) uniek.add(punt);
    }

    return uniek;
  }

  Offset? _dichtsteSnappunt(Offset punt) {
    Offset? beste;
    var besteAfstand = double.infinity;

    for (final p in _snappunten()) {
      final afstand = (p - punt).distance;

      if (afstand < besteAfstand) {
        besteAfstand = afstand;
        beste = p;
      }
    }

    if (beste != null && besteAfstand <= snapAfstand) {
      return beste;
    }

    return null;
  }

  Offset _snapNaarPuntOfRaster(Offset punt) {
    return _dichtsteSnappunt(punt) ?? _snapRaster(punt);
  }

  void _updateAanwijzing(Offset punt) {
    setState(() {
      _actiefSnappunt = _dichtsteSnappunt(punt);
    });
  }

  void _startRechthoek(DragStartDetails details) {
    if (_rechthoek != null) return;

    final punt = _snapRaster(details.localPosition);

    setState(() {
      _startPunt = punt;
      _eindPunt = punt;
    });
  }

  void _updateRechthoek(DragUpdateDetails details) {
    if (_rechthoek != null) return;

    setState(() {
      _eindPunt = _snapRaster(details.localPosition);
    });
  }

  void _stopRechthoek(DragEndDetails details) {
    if (_rechthoek != null) return;
    _maakRechthoek();
  }

  void _maakRechthoek() {
    if (_startPunt == null || _eindPunt == null) return;

    final breedteMm = widget.breedteMm.toDouble();
    final hoogteMm = widget.hoogteMm.toDouble();

    if (breedteMm <= 0 || hoogteMm <= 0) return;

    final dx = _eindPunt!.dx - _startPunt!.dx;
    final dy = _eindPunt!.dy - _startPunt!.dy;

    if (dx.abs() < 1 && dy.abs() < 1) return;

    final horizontaal = dx.abs() >= dy.abs();

    late double schermBreedte;
    late double schermHoogte;

    if (horizontaal) {
      schermBreedte = dx.abs();
      schermHoogte = schermBreedte * (hoogteMm / breedteMm);
    } else {
      schermHoogte = dy.abs();
      schermBreedte = schermHoogte * (breedteMm / hoogteMm);
    }

    final naarRechts = dx >= 0;
    final naarBeneden = dy >= 0;

    final left = naarRechts ? _startPunt!.dx : _startPunt!.dx - schermBreedte;
    final top = naarBeneden ? _startPunt!.dy : _startPunt!.dy - schermHoogte;

    setState(() {
      _rechthoek = Rect.fromLTWH(
        left,
        top,
        schermBreedte,
        schermHoogte,
      );
    });
  }

  void _klikCanvas(TapDownDetails details) {
    if (_rechthoek == null) return;

    final punt = _snapNaarPuntOfRaster(details.localPosition);

    if (widget.actieveTool == 'lijn') {
      _klikLijn(punt);
      return;
    }

    if (widget.actieveTool == 'driehoek') {
      _klikDriehoek(punt, details.localPosition);
      return;
    }
  }

  void _klikLijn(Offset punt) {
    setState(() {
      if (_lijnStart == null) {
        _lijnStart = punt;
        return;
      }

      if ((_lijnStart! - punt).distance < 1) return;

      _lijnen.add(
        OpmetingRaamLijn(
          id: 'lijn_${_lijnen.length}',
          start: _lijnStart!,
          einde: punt,
        ),
      );

      _lijnStart = null;
    });
  }

  void _klikDriehoek(
    Offset snapPunt,
    Offset vrijeKlik,
  ) {
    setState(() {
      if (_driehoekPunt1 == null) {
        _driehoekPunt1 = snapPunt;
        return;
      }

      if (_driehoekPunt2 == null) {
        _driehoekPunt2 = snapPunt;
        return;
      }

      final top = _berekenDriehoekPunt(
        punt1: _driehoekPunt1!,
        punt2: _driehoekPunt2!,
        richtingKlik: vrijeKlik,
      );

      if (top == null) {
        _driehoekPunt1 = null;
        _driehoekPunt2 = null;
        return;
      }

      _driehoeken.add(
        OpmetingRaamDriehoek(
          punt1: _driehoekPunt1!,
          punt2: _driehoekPunt2!,
          punt3: top,
        ),
      );

      _driehoekPunt1 = null;
      _driehoekPunt2 = null;
    });
  }

  Offset? _berekenDriehoekPunt({
    required Offset punt1,
    required Offset punt2,
    required Offset richtingKlik,
  }) {
    final basis = punt2 - punt1;
    final basisLengte = basis.distance;

    if (basisLengte < 1) return null;

    final basisUnit = Offset(
      basis.dx / basisLengte,
      basis.dy / basisLengte,
    );

    var normaal = Offset(
      -basisUnit.dy,
      basisUnit.dx,
    );

    final midden = Offset(
      (punt1.dx + punt2.dx) / 2,
      (punt1.dy + punt2.dy) / 2,
    );

    final klikVector = richtingKlik - midden;

    if (_dot(klikVector, normaal) < 0) {
      normaal = -normaal;
    }

    Offset? beste;
    var besteAfstand = double.infinity;

    for (final lijn in _alleLijnen()) {
      if (_isZelfdeLijn(lijn, punt1, punt2)) continue;

      final lijnVector = lijn.einde - lijn.start;
      final lijnLengte = lijnVector.distance;

      if (lijnLengte < 1) continue;

      final lijnUnit = Offset(
        lijnVector.dx / lijnLengte,
        lijnVector.dy / lijnLengte,
      );

      final parallel = _kruis(basisUnit, lijnUnit).abs() < 0.03;

      if (!parallel) continue;

      final afstandOpNormaal = _dot(lijn.start - midden, normaal);

      if (afstandOpNormaal <= 1) continue;

      final kandidaat = midden + (normaal * afstandOpNormaal);

      if (!_puntOpLijnstuk(kandidaat, lijn.start, lijn.einde)) continue;

      if (afstandOpNormaal < besteAfstand) {
        besteAfstand = afstandOpNormaal;
        beste = kandidaat;
      }
    }

    return beste;
  }

  bool _isZelfdeLijn(
    OpmetingRaamLijn lijn,
    Offset punt1,
    Offset punt2,
  ) {
    final d1 = (lijn.start - punt1).distance + (lijn.einde - punt2).distance;
    final d2 = (lijn.start - punt2).distance + (lijn.einde - punt1).distance;

    return d1 < 1 || d2 < 1;
  }

  bool _puntOpLijnstuk(
    Offset punt,
    Offset start,
    Offset einde,
  ) {
    final afstand = _afstandTotLijnstuk(
      punt: punt,
      start: start,
      einde: einde,
    );

    if (afstand > 1.5) return false;

    final minX = math.min(start.dx, einde.dx) - 1;
    final maxX = math.max(start.dx, einde.dx) + 1;
    final minY = math.min(start.dy, einde.dy) - 1;
    final maxY = math.max(start.dy, einde.dy) + 1;

    return punt.dx >= minX &&
        punt.dx <= maxX &&
        punt.dy >= minY &&
        punt.dy <= maxY;
  }

  double _afstandTotLijnstuk({
    required Offset punt,
    required Offset start,
    required Offset einde,
  }) {
    final dx = einde.dx - start.dx;
    final dy = einde.dy - start.dy;

    if (dx == 0 && dy == 0) {
      return (punt - start).distance;
    }

    final t = (((punt.dx - start.dx) * dx) + ((punt.dy - start.dy) * dy)) /
        ((dx * dx) + (dy * dy));

    final begrensd = t.clamp(0.0, 1.0);

    final projectie = Offset(
      start.dx + (begrensd * dx),
      start.dy + (begrensd * dy),
    );

    return (punt - projectie).distance;
  }

  double _dot(Offset a, Offset b) {
    return (a.dx * b.dx) + (a.dy * b.dy);
  }

  double _kruis(Offset a, Offset b) {
    return (a.dx * b.dy) - (a.dy * b.dx);
  }

  void _undo() {
    setState(() {
      if (_driehoeken.isNotEmpty) {
        _driehoeken.removeLast();
        return;
      }

      if (_lijnen.isNotEmpty) {
        _lijnen.removeLast();
        return;
      }

      _rechthoek = null;
      _startPunt = null;
      _eindPunt = null;
      _lijnStart = null;
      _driehoekPunt1 = null;
      _driehoekPunt2 = null;
    });
  }

  void _allesWissen() {
    setState(() {
      _startPunt = null;
      _eindPunt = null;
      _rechthoek = null;
      _lijnen.clear();
      _driehoeken.clear();
      _lijnStart = null;
      _driehoekPunt1 = null;
      _driehoekPunt2 = null;
      _actiefSnappunt = null;
    });
  }

  @override
  void didUpdateWidget(covariant OpmetingRaamTekenvlak oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.actieveTool != widget.actieveTool) {
      _lijnStart = null;
      _driehoekPunt1 = null;
      _driehoekPunt2 = null;
    }

    if (oldWidget.breedteMm != widget.breedteMm ||
        oldWidget.hoogteMm != widget.hoogteMm) {
      setState(() {
        _rechthoek = null;
        _startPunt = null;
        _eindPunt = null;
        _lijnen.clear();
        _driehoeken.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _kaartDecoratie(),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Listener(
              onPointerMove: (event) {
                _updateAanwijzing(event.localPosition);
              },
              onPointerDown: (event) {
                _updateAanwijzing(event.localPosition);
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: _klikCanvas,
                onPanStart: _startRechthoek,
                onPanUpdate: _updateRechthoek,
                onPanEnd: _stopRechthoek,
                child: CustomPaint(
                  painter: _RaamTekenvlakPainter(
                    startPunt: _startPunt,
                    eindPunt: _eindPunt,
                    rechthoek: _rechthoek,
                    lijnen: _alleLijnen(),
                    snappunten: _snappunten(),
                    actiefSnappunt: _actiefSnappunt,
                    lijnStart: _lijnStart,
                    driehoekPunt1: _driehoekPunt1,
                    driehoekPunt2: _driehoekPunt2,
                    breedteMm: widget.breedteMm,
                    hoogteMm: widget.hoogteMm,
                    actieveTool: widget.actieveTool,
                    onUndo: _undo,
                    onAllesWissen: _allesWissen,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              width: 180,
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFD1D5DB),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'Pos:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0B7A3B),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: widget.positieController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _kaartDecoratie() {
    return BoxDecoration(
      color: const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: const Color(0xFFD1D5DB),
      ),
    );
  }
}

class OpmetingRaamLijn {
  const OpmetingRaamLijn({
    required this.id,
    required this.start,
    required this.einde,
  });

  final String id;
  final Offset start;
  final Offset einde;
}

class OpmetingRaamDriehoek {
  const OpmetingRaamDriehoek({
    required this.punt1,
    required this.punt2,
    required this.punt3,
  });

  final Offset punt1;
  final Offset punt2;
  final Offset punt3;
}

class _RaamTekenvlakPainter extends CustomPainter {
  _RaamTekenvlakPainter({
    required this.startPunt,
    required this.eindPunt,
    required this.rechthoek,
    required this.lijnen,
    required this.snappunten,
    required this.actiefSnappunt,
    required this.lijnStart,
    required this.driehoekPunt1,
    required this.driehoekPunt2,
    required this.breedteMm,
    required this.hoogteMm,
    required this.actieveTool,
    required this.onUndo,
    required this.onAllesWissen,
  });

  final Offset? startPunt;
  final Offset? eindPunt;
  final Rect? rechthoek;

  final List<OpmetingRaamLijn> lijnen;
  final List<Offset> snappunten;
  final Offset? actiefSnappunt;

  final Offset? lijnStart;
  final Offset? driehoekPunt1;
  final Offset? driehoekPunt2;

  final int breedteMm;
  final int hoogteMm;
  final String actieveTool;

  final VoidCallback onUndo;
  final VoidCallback onAllesWissen;

  static const double raster10cm = 200;
  static const double raster5mm = raster10cm / 20;

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

    for (final lijn in lijnen) {
      canvas.drawLine(lijn.start, lijn.einde, lijnPaint);
    }

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

    _tekenMaatlijnen(canvas, size);
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

  void _tekenMaatlijnen(Canvas canvas, Size size) {
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
      text: TextSpan(text: tekst, style: style),
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
  bool shouldRepaint(covariant _RaamTekenvlakPainter oldDelegate) {
    return true;
  }
}
