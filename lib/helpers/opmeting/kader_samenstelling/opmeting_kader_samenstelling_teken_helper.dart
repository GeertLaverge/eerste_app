import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../raam/opmeting_raam_kader_helper.dart';
import 'opmeting_kader_samenstelling_layout_helper.dart';
import 'opmeting_kader_samenstelling_model.dart';

class OpmetingKaderSamenstellingWeergave {
  const OpmetingKaderSamenstellingWeergave({
    required this.layout,
    required this.schaal,
    required this.volledigeRect,
    required this.kaderRects,
  });

  final OpmetingKaderSamenstellingLayoutResultaat layout;
  final double schaal;
  final Rect volledigeRect;
  final Map<String, Rect> kaderRects;

  Rect? rectVoorKaderId(String kaderId) {
    return kaderRects[kaderId];
  }

  OpmetingKaderDeel? kaderVoorPunt(Offset punt) {
    for (final kader in layout.kaders.reversed) {
      final rect = kaderRects[kader.id];

      if (rect == null) {
        continue;
      }

      if (rect.contains(punt)) {
        return kader;
      }
    }

    return null;
  }
}

class OpmetingKaderSamenstellingTekenHelper {
  const OpmetingKaderSamenstellingTekenHelper._();

  static const Color groen = Color(0xFF0B7A3B);
  static const Color randDonker = Color(0xFF111827);
  static const Color randGrijs = Color(0xFF9CA3AF);
  static const Color tekstDonker = Color(0xFF111827);
  static const Color tekstGrijs = Color(0xFF6B7280);

  static OpmetingKaderSamenstellingWeergave berekenWeergave({
    required Rect tekenGebied,
    required OpmetingKaderSamenstelling samenstelling,
    EdgeInsets marge = const EdgeInsets.all(0),
  }) {
    final layout = OpmetingKaderSamenstellingLayoutHelper.bereken(
      kaders: samenstelling.kaders,
    );

    if (layout.isLeeg) {
      return OpmetingKaderSamenstellingWeergave(
        layout: layout,
        schaal: 1,
        volledigeRect: Rect.zero,
        kaderRects: const <String, Rect>{},
      );
    }

    final bruikbaarGebied = Rect.fromLTRB(
      tekenGebied.left + marge.left,
      tekenGebied.top + marge.top,
      tekenGebied.right - marge.right,
      tekenGebied.bottom - marge.bottom,
    );

    final bruikbareBreedte = math.max(1.0, bruikbaarGebied.width);
    final bruikbareHoogte = math.max(1.0, bruikbaarGebied.height);

    final layoutBreedte = math.max(1.0, layout.breedteMm.toDouble());
    final layoutHoogte = math.max(1.0, layout.hoogteMm.toDouble());

    final schaal = math.min(
      bruikbareBreedte / layoutBreedte,
      bruikbareHoogte / layoutHoogte,
    );

    final getekendeBreedte = layoutBreedte * schaal;
    final getekendeHoogte = layoutHoogte * schaal;

    final startX =
        bruikbaarGebied.left + (bruikbareBreedte - getekendeBreedte) / 2;

    final startY =
        bruikbaarGebied.top + (bruikbareHoogte - getekendeHoogte) / 2;

    final offsetX = startX - layout.minXMm * schaal;
    final offsetY = startY - layout.minYMm * schaal;

    final kaderRects = <String, Rect>{};

    for (final kader in layout.kaders) {
      kaderRects[kader.id] = Rect.fromLTWH(
        offsetX + kader.xMm * schaal,
        offsetY + kader.yMm * schaal,
        kader.breedteMm * schaal,
        kader.hoogteMm * schaal,
      );
    }

    final volledigeRect = Rect.fromLTWH(
      startX,
      startY,
      getekendeBreedte,
      getekendeHoogte,
    );

    return OpmetingKaderSamenstellingWeergave(
      layout: layout,
      schaal: schaal,
      volledigeRect: volledigeRect,
      kaderRects: Map<String, Rect>.unmodifiable(kaderRects),
    );
  }

  static void tekenSamenstelling({
    required Canvas canvas,
    required Rect tekenGebied,
    required OpmetingKaderSamenstelling samenstelling,
    String? actiefKaderId,
    EdgeInsets marge = const EdgeInsets.all(0),
    bool toonKaderLabels = false,
    bool toonTotaleMaat = false,
  }) {
    final weergave = berekenWeergave(
      tekenGebied: tekenGebied,
      samenstelling: samenstelling,
      marge: marge,
    );

    if (weergave.layout.isLeeg) {
      return;
    }

    if (toonTotaleMaat) {
      _tekenTotaleMaatLabel(
        canvas: canvas,
        rect: weergave.volledigeRect,
        breedteMm: weergave.layout.breedteMm,
        hoogteMm: weergave.layout.hoogteMm,
      );
    }

    final actieveId = actiefKaderId ?? samenstelling.actiefKaderId;
    Rect? actiefRect;

    for (final kader in weergave.layout.kaders) {
      final rect = weergave.kaderRects[kader.id];

      if (rect == null) {
        continue;
      }

      final actief = kader.id == actieveId;

      if (actief) {
        actiefRect = rect;
      }

      _tekenKader(
        canvas: canvas,
        rect: rect,
        kader: kader,
        actief: actief,
        toonLabel: toonKaderLabels,
      );
    }

    if (actiefRect != null) {
      tekenActieveKaderHoeken(canvas: canvas, rect: actiefRect);
    }
  }

  static OpmetingKaderDeel? kaderVoorPunt({
    required Offset punt,
    required Rect tekenGebied,
    required OpmetingKaderSamenstelling samenstelling,
    EdgeInsets marge = const EdgeInsets.all(0),
  }) {
    final weergave = berekenWeergave(
      tekenGebied: tekenGebied,
      samenstelling: samenstelling,
      marge: marge,
    );

    return weergave.kaderVoorPunt(punt);
  }

  static Rect? rectVoorActiefKader({
    required Rect tekenGebied,
    required OpmetingKaderSamenstelling samenstelling,
    EdgeInsets marge = const EdgeInsets.all(0),
  }) {
    final weergave = berekenWeergave(
      tekenGebied: tekenGebied,
      samenstelling: samenstelling,
      marge: marge,
    );

    return weergave.rectVoorKaderId(samenstelling.actiefKaderId);
  }

  static Rect? rectVoorKaderId({
    required Rect tekenGebied,
    required OpmetingKaderSamenstelling samenstelling,
    required String kaderId,
    EdgeInsets marge = const EdgeInsets.all(0),
  }) {
    final weergave = berekenWeergave(
      tekenGebied: tekenGebied,
      samenstelling: samenstelling,
      marge: marge,
    );

    return weergave.rectVoorKaderId(kaderId);
  }

  static void _tekenKader({
    required Canvas canvas,
    required Rect rect,
    required OpmetingKaderDeel kader,
    required bool actief,
    required bool toonLabel,
  }) {
    final binnenRect = _binnenRectVoorKader(
      buitenRect: rect,
      breedteMm: kader.breedteMm,
      hoogteMm: kader.hoogteMm,
    );

    final vullingPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final kaderPaint = Paint()
      ..color = actief ? groen : randDonker
      ..style = PaintingStyle.stroke
      ..strokeWidth = actief ? 1.8 : 1.4;

    final profielPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(rect)
      ..addRect(binnenRect);

    canvas.drawPath(profielPath, vullingPaint);

    canvas.drawRect(rect, kaderPaint);
    canvas.drawRect(binnenRect, kaderPaint);

    _tekenVerstekHoeken(
      canvas: canvas,
      buitenRect: rect,
      binnenRect: binnenRect,
      paint: kaderPaint,
    );

    if (toonLabel) {
      _tekenKaderLabel(
        canvas: canvas,
        rect: rect,
        kader: kader,
        actief: actief,
      );
    }
  }

  static Rect _binnenRectVoorKader({
    required Rect buitenRect,
    required int breedteMm,
    required int hoogteMm,
  }) {
    if (breedteMm <= 0 || hoogteMm <= 0) {
      return buitenRect.deflate(1);
    }

    final offsetX =
        (buitenRect.width / breedteMm) * OpmetingRaamKaderHelper.kaderOffsetMm;

    final offsetY =
        (buitenRect.height / hoogteMm) * OpmetingRaamKaderHelper.kaderOffsetMm;

    final veiligeOffsetX = math.min(
      offsetX,
      math.max(1.0, buitenRect.width / 2 - 1),
    );

    final veiligeOffsetY = math.min(
      offsetY,
      math.max(1.0, buitenRect.height / 2 - 1),
    );

    return Rect.fromLTRB(
      buitenRect.left + veiligeOffsetX,
      buitenRect.top + veiligeOffsetY,
      buitenRect.right - veiligeOffsetX,
      buitenRect.bottom - veiligeOffsetY,
    );
  }

  static void _tekenVerstekHoeken({
    required Canvas canvas,
    required Rect buitenRect,
    required Rect binnenRect,
    required Paint paint,
  }) {
    canvas.drawLine(buitenRect.topLeft, binnenRect.topLeft, paint);
    canvas.drawLine(buitenRect.topRight, binnenRect.topRight, paint);
    canvas.drawLine(buitenRect.bottomLeft, binnenRect.bottomLeft, paint);
    canvas.drawLine(buitenRect.bottomRight, binnenRect.bottomRight, paint);
  }

  static void tekenActieveKaderHoeken({
    required Canvas canvas,
    required Rect rect,
  }) {
    final fillPaint = Paint()
      ..color = groen
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final radius = math.max(
      4.0,
      math.min(7.0, math.min(rect.width, rect.height) * 0.025),
    );

    final punten = <Offset>[
      rect.topLeft,
      rect.topRight,
      rect.bottomLeft,
      rect.bottomRight,
    ];

    for (final punt in punten) {
      canvas.drawCircle(punt, radius, fillPaint);
      canvas.drawCircle(punt, radius, strokePaint);
    }
  }

  static void _tekenKaderLabel({
    required Canvas canvas,
    required Rect rect,
    required OpmetingKaderDeel kader,
    required bool actief,
  }) {
    if (rect.width < 50 || rect.height < 34) {
      return;
    }

    final textPainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: kader.naam,
            style: TextStyle(
              color: actief ? groen : tekstDonker,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: '\n${kader.breedteMm} × ${kader.hoogteMm} mm',
            style: const TextStyle(
              color: tekstGrijs,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '…',
    );

    textPainter.layout(maxWidth: math.max(0, rect.width - 10));

    final positie = Offset(
      rect.left + (rect.width - textPainter.width) / 2,
      rect.top + (rect.height - textPainter.height) / 2,
    );

    textPainter.paint(canvas, positie);
  }

  static void _tekenTotaleMaatLabel({
    required Canvas canvas,
    required Rect rect,
    required int breedteMm,
    required int hoogteMm,
  }) {
    final tekst = '$breedteMm × $hoogteMm mm';

    final textPainter = TextPainter(
      text: TextSpan(
        text: tekst,
        style: const TextStyle(
          color: tekstGrijs,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );

    textPainter.layout();

    final labelRect = Rect.fromLTWH(
      rect.center.dx - textPainter.width / 2 - 7,
      rect.top - textPainter.height - 8,
      textPainter.width + 14,
      textPainter.height + 4,
    );

    final achtergrondPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final randPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final rrect = RRect.fromRectAndRadius(
      labelRect,
      const Radius.circular(999),
    );

    canvas.drawRRect(rrect, achtergrondPaint);
    canvas.drawRRect(rrect, randPaint);

    textPainter.paint(canvas, Offset(labelRect.left + 7, labelRect.top + 2));
  }
}
