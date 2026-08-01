import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'opmeting_uitvalscherm_model.dart';
import 'opmeting_uitvalscherm_tekening_geometrie.dart';

class OpmetingUitvalschermPainter extends CustomPainter {
  const OpmetingUitvalschermPainter({required this.model});

  final OpmetingUitvalschermModel model;

  static const Color _lijn = Color(0xFF22272D);
  static const Color _maat = Color(0xFF50565D);
  static const Color _steen = Color(0xFFF7F8F9);
  static const Color _steenLijn = Color(0xFFE5E8EC);

  @override
  void paint(Canvas canvas, Size size) {
    final geometrie = OpmetingUitvalschermTekeningGeometrie.voorModel(model);
    final schaal = math.min(
      size.width / OpmetingUitvalschermTekeningGeometrie.viewBreedte,
      size.height / OpmetingUitvalschermTekeningGeometrie.viewHoogte,
    );
    final dx =
        (size.width -
            OpmetingUitvalschermTekeningGeometrie.viewBreedte * schaal) /
        2;
    final dy =
        (size.height -
            OpmetingUitvalschermTekeningGeometrie.viewHoogte * schaal) /
        2;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(schaal);

    _tekenZijaanzicht(canvas, geometrie);
    _tekenVooraanzicht(canvas, geometrie);
    _tekenDoekkleur(canvas);

    canvas.restore();
  }

  void _tekenZijaanzicht(
    Canvas canvas,
    OpmetingUitvalschermTekeningGeometrie g,
  ) {
    _tekenMetselwerk(
      canvas,
      const Rect.fromLTWH(
        OpmetingUitvalschermTekeningGeometrie.muurZijX,
        OpmetingUitvalschermTekeningGeometrie.muurZijY,
        OpmetingUitvalschermTekeningGeometrie.muurZijBreedte,
        OpmetingUitvalschermTekeningGeometrie.muurZijHoogte,
      ),
    );

    _tekenKast(canvas, g);

    final lijn = Paint()
      ..color = _lijn
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.65;

    // Het doek wordt bewust als één enkele lijn getekend.
    canvas.drawLine(
      Offset(g.doekStartX, g.doekStartY),
      Offset(g.doekEindX, g.doekEindY),
      lijn,
    );

    _tekenArm(
      canvas,
      Offset(g.armStartX, g.armStartY),
      Offset(g.armKnikX, g.armKnikY),
    );
    _tekenArm(
      canvas,
      Offset(g.armKnikX, g.armKnikY),
      Offset(g.armEindX, g.armEindY),
    );
    // Geen zichtbaar rond scharnierpunt in de kast.
    _tekenScharnier(canvas, Offset(g.armKnikX, g.armKnikY), 4.2);
    _tekenScharnier(canvas, Offset(g.armEindX, g.armEindY), 5.2);

    final voorplaat = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        g.voorplaatX,
        g.voorplaatY,
        g.voorplaatBreedte,
        g.voorplaatHoogte,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(voorplaat, Paint()..color = Colors.white);
    canvas.drawRRect(voorplaat, lijn);

    if (model.volant) {
      final volantHoogte =
          18.0 + model.volantHoogteMm.clamp(0, 500).toDouble() * 0.12;
      final x = g.voorplaatX + g.voorplaatBreedte - 2;
      canvas.drawLine(
        Offset(x, g.voorplaatY + g.voorplaatHoogte),
        Offset(x, g.voorplaatY + g.voorplaatHoogte + volantHoogte),
        lijn,
      );
      _tekst(
        canvas,
        'volant ${model.volantHoogteMm} mm',
        Offset(
          g.voorplaatX - 54,
          g.voorplaatY + g.voorplaatHoogte + volantHoogte + 18,
        ),
        12,
      );
    }

    _maatLijn(
      canvas,
      Offset(g.doekStartX, 45),
      Offset(g.doekEindX, 45),
      'uitval ${model.uitvalMm} mm',
    );
  }

  void _tekenKast(Canvas canvas, OpmetingUitvalschermTekeningGeometrie g) {
    final vulling = Paint()..color = Colors.white;
    final lijn = Paint()
      ..color = _lijn
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.65;

    switch (g.kastVorm) {
      case OpmetingUitvalschermKastVorm.rechthoekig:
        final rect = Rect.fromLTWH(
          g.kastX,
          g.kastY,
          g.kastBreedte,
          g.kastHoogte,
        );
        canvas.drawRect(rect, vulling);
        canvas.drawRect(rect, lijn);
        break;
      case OpmetingUitvalschermKastVorm.schuin500X:
        final pad = Path()
          ..moveTo(g.kastX + 3, g.kastY)
          ..lineTo(g.kastRechts, g.kastY + 7)
          ..lineTo(g.kastRechts - 2, g.kastOnder - 4)
          ..lineTo(g.kastX + 3, g.kastOnder)
          ..close();
        canvas.drawPath(pad, vulling);
        canvas.drawPath(pad, lijn);
        break;
    }

    canvas.drawLine(
      Offset(g.kastX - 3, g.kastY + 4),
      Offset(g.kastX - 3, g.kastOnder - 4),
      lijn,
    );
  }

  void _tekenArm(Canvas canvas, Offset start, Offset einde) {
    canvas.drawLine(
      start,
      einde,
      Paint()
        ..color = _lijn
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.square,
    );
    canvas.drawLine(
      start,
      einde,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 5.2
        ..strokeCap = StrokeCap.square,
    );
  }

  void _tekenScharnier(Canvas canvas, Offset center, double straal) {
    canvas.drawCircle(center, straal, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      straal,
      Paint()
        ..color = _lijn
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    canvas.drawCircle(center, 1.4, Paint()..color = _lijn);
  }

  void _tekenVooraanzicht(
    Canvas canvas,
    OpmetingUitvalschermTekeningGeometrie g,
  ) {
    final muur = Rect.fromLTWH(
      g.frontLinks - 46,
      g.frontBoven - 22,
      g.frontBreedte + 92,
      g.frontHoogte + 44,
    );
    _tekenMetselwerk(canvas, muur);

    final lijn = Paint()
      ..color = _lijn
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.65;

    final cassette = RRect.fromRectAndRadius(
      Rect.fromLTWH(g.frontLinks, g.frontBoven, g.frontBreedte, g.frontHoogte),
      Radius.circular(
        g.kastVorm == OpmetingUitvalschermKastVorm.rechthoekig ? 1.5 : 5,
      ),
    );
    canvas.drawRRect(cassette, Paint()..color = Colors.white);
    canvas.drawRRect(cassette, lijn);

    // Gesloten vooraanzicht: niet opengeklapt.
    canvas.drawLine(
      Offset(g.frontLinks + 10, g.frontBoven + g.frontHoogte * 0.20),
      Offset(g.frontRechts - 10, g.frontBoven + g.frontHoogte * 0.20),
      Paint()
        ..color = _maat.withValues(alpha: 0.65)
        ..strokeWidth = 0.9,
    );
    canvas.drawLine(
      Offset(g.frontLinks + 10, g.frontOnder - g.frontHoogte * 0.18),
      Offset(g.frontRechts - 10, g.frontOnder - g.frontHoogte * 0.18),
      Paint()
        ..color = _maat.withValues(alpha: 0.65)
        ..strokeWidth = 0.9,
    );

    _maatLijn(
      canvas,
      Offset(g.frontLinks, g.frontBoven - 48),
      Offset(g.frontRechts, g.frontBoven - 48),
      'totale breedte ${model.breedteMm} mm',
    );

    if (g.toon500XLabel) {
      _gecentreerdeTekst(
        canvas,
        '500 X',
        Offset((g.frontLinks + g.frontRechts) / 2, g.frontOnder + 44),
        20,
        vet: true,
      );
    }
  }

  void _tekenDoekkleur(Canvas canvas) {
    final center = const Offset(
      OpmetingUitvalschermTekeningGeometrie.kleurCirkelX,
      OpmetingUitvalschermTekeningGeometrie.kleurCirkelY,
    );
    final kleur = _kleurVanHex(model.doekHex);
    canvas.drawCircle(center, 62, Paint()..color = kleur);
    canvas.drawCircle(
      center,
      62,
      Paint()
        ..color = _lijn
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7,
    );
    _gecentreerdeTekst(
      canvas,
      model.doekCode.trim().isEmpty ? 'kleur doek' : model.doekCode.trim(),
      center,
      13,
      kleur: kleur.computeLuminance() < 0.45 ? Colors.white : _lijn,
      vet: true,
    );
  }

  void _tekenMetselwerk(Canvas canvas, Rect rect) {
    canvas.drawRect(rect, Paint()..color = _steen);
    final lijn = Paint()
      ..color = _steenLijn
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.55;
    const rij = 12.0;
    const steen = 30.0;
    for (var y = rect.top; y <= rect.bottom; y += rij) {
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), lijn);
      final offset = (((y - rect.top) / rij).round().isEven) ? 0.0 : steen / 2;
      for (var x = rect.left + offset; x <= rect.right; x += steen) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x, math.min(y + rij, rect.bottom)),
          lijn,
        );
      }
    }
    canvas.drawRect(rect, lijn);
  }

  void _maatLijn(
    Canvas canvas,
    Offset start,
    Offset einde,
    String tekst, {
    bool verticaal = false,
    bool tekstLinks = false,
  }) {
    final paint = Paint()
      ..color = _maat
      ..strokeWidth = 1.0;
    canvas.drawLine(start, einde, paint);
    canvas.drawLine(start.translate(-5, 5), start.translate(5, -5), paint);
    canvas.drawLine(einde.translate(-5, 5), einde.translate(5, -5), paint);

    if (verticaal) {
      final x = tekstLinks ? start.dx - 52 : start.dx + 10;
      _tekst(canvas, tekst, Offset(x, (start.dy + einde.dy) / 2 + 4), 11);
      return;
    }

    _gecentreerdeTekst(
      canvas,
      tekst,
      Offset((start.dx + einde.dx) / 2, start.dy - 8),
      11,
    );
  }

  void _tekst(
    Canvas canvas,
    String tekst,
    Offset positie,
    double grootte, {
    bool vet = false,
    Color kleur = _maat,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: tekst,
        style: TextStyle(
          color: kleur,
          fontSize: grootte,
          fontWeight: vet ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, positie);
  }

  void _gecentreerdeTekst(
    Canvas canvas,
    String tekst,
    Offset center,
    double grootte, {
    bool vet = false,
    Color kleur = _maat,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: tekst,
        style: TextStyle(
          color: kleur,
          fontSize: grootte,
          fontWeight: vet ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  Color _kleurVanHex(String hex) {
    final waarde =
        int.tryParse(hex.replaceFirst('#', ''), radix: 16) ?? 0x8C8C8A;
    return Color(0xFF000000 | waarde);
  }

  @override
  bool shouldRepaint(covariant OpmetingUitvalschermPainter oldDelegate) {
    return oldDelegate.model != model;
  }
}
