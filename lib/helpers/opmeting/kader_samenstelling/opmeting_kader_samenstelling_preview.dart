import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../raam/opmeting_raam_kader_helper.dart';
import 'opmeting_kader_samenstelling_layout_helper.dart';
import 'opmeting_kader_samenstelling_model.dart';

class OpmetingKaderSamenstellingPreview extends StatelessWidget {
  const OpmetingKaderSamenstellingPreview({
    super.key,
    required this.kaders,
    this.actiefKaderId,
    this.onKaderGekozen,
    this.hoogte = 170,
    this.toonMaten = true,
  });

  final List<OpmetingKaderDeel> kaders;
  final String? actiefKaderId;
  final ValueChanged<OpmetingKaderDeel>? onKaderGekozen;

  final double hoogte;
  final bool toonMaten;

  @override
  Widget build(BuildContext context) {
    if (kaders.isEmpty) {
      return Container(
        height: hoogte,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Text(
          'Nog geen kaders beschikbaar.',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final layout = OpmetingKaderSamenstellingLayoutHelper.bereken(
      kaders: kaders,
    );

    return SizedBox(
      height: hoogte,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final breedte = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : 360.0;

          final previewGrootte = Size(breedte, hoogte);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: onKaderGekozen == null
                ? null
                : (details) {
                    final kader = _zoekKaderBijPunt(
                      punt: details.localPosition,
                      grootte: previewGrootte,
                      layout: layout,
                    );

                    if (kader == null) {
                      return;
                    }

                    onKaderGekozen!(kader);
                  },
            child: CustomPaint(
              size: previewGrootte,
              painter: _OpmetingKaderSamenstellingPreviewPainter(
                layout: layout,
                actiefKaderId: actiefKaderId,
                toonMaten: toonMaten,
              ),
            ),
          );
        },
      ),
    );
  }

  OpmetingKaderDeel? _zoekKaderBijPunt({
    required Offset punt,
    required Size grootte,
    required OpmetingKaderSamenstellingLayoutResultaat layout,
  }) {
    final transformatie = _OpmetingKaderPreviewTransformatie.maak(
      grootte: grootte,
      layout: layout,
    );

    for (final kader in layout.kaders.reversed) {
      final rect = transformatie.rectVoorKader(kader);

      if (rect.contains(punt)) {
        return kader;
      }
    }

    return null;
  }
}

class _OpmetingKaderSamenstellingPreviewPainter extends CustomPainter {
  const _OpmetingKaderSamenstellingPreviewPainter({
    required this.layout,
    required this.actiefKaderId,
    required this.toonMaten,
  });

  final OpmetingKaderSamenstellingLayoutResultaat layout;
  final String? actiefKaderId;
  final bool toonMaten;

  static const Color groen = Color(0xFF0B7A3B);
  static const Color rand = Color(0xFFE5E7EB);
  static const Color tekstDonker = Color(0xFF111827);
  static const Color tekstGrijs = Color(0xFF6B7280);

  @override
  void paint(Canvas canvas, Size size) {
    final achtergrondPaint = Paint()
      ..color = const Color(0xFFF9FAFB)
      ..style = PaintingStyle.fill;

    final achtergrondRandPaint = Paint()
      ..color = rand
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final achtergrondRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(12),
    );

    canvas.drawRRect(achtergrondRect, achtergrondPaint);
    canvas.drawRRect(achtergrondRect, achtergrondRandPaint);

    if (layout.isLeeg) {
      return;
    }

    final transformatie = _OpmetingKaderPreviewTransformatie.maak(
      grootte: size,
      layout: layout,
    );

    _tekenTotaleMaat(canvas: canvas, size: size, layout: layout);

    for (final kader in layout.kaders) {
      final actief = kader.id == actiefKaderId;
      final rect = transformatie.rectVoorKader(kader);

      _tekenKaderDeel(
        canvas: canvas,
        buitenRect: rect,
        breedteMm: kader.breedteMm,
        hoogteMm: kader.hoogteMm,
        isActief: actief,
      );

      _tekenLabel(canvas: canvas, rect: rect, kader: kader, actief: actief);
    }
  }

  void _tekenTotaleMaat({
    required Canvas canvas,
    required Size size,
    required OpmetingKaderSamenstellingLayoutResultaat layout,
  }) {
    final tekst = '${layout.breedteMm} × ${layout.hoogteMm} mm';

    final textPainter = TextPainter(
      text: TextSpan(
        text: tekst,
        style: const TextStyle(
          color: tekstGrijs,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );

    textPainter.layout(maxWidth: size.width - 20);

    textPainter.paint(canvas, Offset(10, size.height - textPainter.height - 7));
  }

  void _tekenKaderDeel({
    required Canvas canvas,
    required Rect buitenRect,
    required int breedteMm,
    required int hoogteMm,
    required bool isActief,
  }) {
    if (breedteMm <= 0 || hoogteMm <= 0) {
      return;
    }

    final offsetX =
        (buitenRect.width / breedteMm) * OpmetingRaamKaderHelper.kaderOffsetMm;

    final offsetY =
        (buitenRect.height / hoogteMm) * OpmetingRaamKaderHelper.kaderOffsetMm;

    final binnenRect = Rect.fromLTRB(
      buitenRect.left + offsetX,
      buitenRect.top + offsetY,
      buitenRect.right - offsetX,
      buitenRect.bottom - offsetY,
    );

    final vlakPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final randPaint = Paint()
      ..color = const Color(0xFF1F2937)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final kaderPad = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(buitenRect)
      ..addRect(binnenRect);

    canvas.drawPath(kaderPad, vlakPaint);

    canvas.drawRect(buitenRect, randPaint);
    canvas.drawRect(binnenRect, randPaint);

    _tekenVerstekHoeken(
      canvas: canvas,
      buitenRect: buitenRect,
      binnenRect: binnenRect,
      paint: randPaint,
    );

    if (isActief) {
      _tekenActieveKaderHoeken(canvas: canvas, rect: buitenRect);
    }
  }

  void _tekenVerstekHoeken({
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

  void _tekenActieveKaderHoeken({required Canvas canvas, required Rect rect}) {
    final fillPaint = Paint()
      ..color = groen
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const radius = 5.0;

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

  void _tekenLabel({
    required Canvas canvas,
    required Rect rect,
    required OpmetingKaderDeel kader,
    required bool actief,
  }) {
    if (rect.width < 45 || rect.height < 32) {
      return;
    }

    final regels = <String>[
      kader.naam,
      if (toonMaten) '${kader.breedteMm} × ${kader.hoogteMm}',
    ];

    final textPainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: regels.first,
            style: TextStyle(
              color: actief ? groen : tekstDonker,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (regels.length > 1)
            TextSpan(
              text: '\n${regels.last} mm',
              style: const TextStyle(
                color: tekstGrijs,
                fontSize: 10,
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

    final offset = Offset(
      rect.left + (rect.width - textPainter.width) / 2,
      rect.top + (rect.height - textPainter.height) / 2,
    );

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(
    covariant _OpmetingKaderSamenstellingPreviewPainter oldDelegate,
  ) {
    return oldDelegate.layout != layout ||
        oldDelegate.actiefKaderId != actiefKaderId ||
        oldDelegate.toonMaten != toonMaten;
  }
}

class _OpmetingKaderPreviewTransformatie {
  const _OpmetingKaderPreviewTransformatie({
    required this.schaal,
    required this.offsetX,
    required this.offsetY,
  });

  final double schaal;
  final double offsetX;
  final double offsetY;

  static _OpmetingKaderPreviewTransformatie maak({
    required Size grootte,
    required OpmetingKaderSamenstellingLayoutResultaat layout,
  }) {
    const paddingLinks = 14.0;
    const paddingRechts = 14.0;
    const paddingBoven = 16.0;
    const paddingOnder = 28.0;

    final beschikbareBreedte = math.max(
      1.0,
      grootte.width - paddingLinks - paddingRechts,
    );

    final beschikbareHoogte = math.max(
      1.0,
      grootte.height - paddingBoven - paddingOnder,
    );

    final layoutBreedte = math.max(1.0, layout.breedteMm.toDouble());

    final layoutHoogte = math.max(1.0, layout.hoogteMm.toDouble());

    final schaal = math.min(
      beschikbareBreedte / layoutBreedte,
      beschikbareHoogte / layoutHoogte,
    );

    final getekendeBreedte = layoutBreedte * schaal;
    final getekendeHoogte = layoutHoogte * schaal;

    final startX = paddingLinks + (beschikbareBreedte - getekendeBreedte) / 2;

    final startY = paddingBoven + (beschikbareHoogte - getekendeHoogte) / 2;

    return _OpmetingKaderPreviewTransformatie(
      schaal: schaal,
      offsetX: startX - layout.minXMm * schaal,
      offsetY: startY - layout.minYMm * schaal,
    );
  }

  Rect rectVoorKader(OpmetingKaderDeel kader) {
    return Rect.fromLTWH(
      offsetX + kader.xMm * schaal,
      offsetY + kader.yMm * schaal,
      kader.breedteMm * schaal,
      kader.hoogteMm * schaal,
    );
  }
}
