// THIMACO-CONTROLE: SCHUIFVLIEGENDEUR-FENEKO-PROFIELSCHETSEN-20260728
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'opmeting_schuifvliegendeur_profiel_catalogus.dart';

class OpmetingSchuifvliegendeurProfielSchetsWidget extends StatelessWidget {
  const OpmetingSchuifvliegendeurProfielSchetsWidget({
    super.key,
    required this.profiel,
    this.geselecteerd = false,
    this.breedte = 82,
    this.hoogte = 54,
  });

  final OpmetingSchuifvliegendeurProfiel profiel;
  final bool geselecteerd;
  final double breedte;
  final double hoogte;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: breedte,
      height: hoogte,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: geselecteerd ? const Color(0xFFE7F6EC) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: geselecteerd
              ? const Color(0xFF0B7A3B)
              : const Color(0xFFD1D5DB),
          width: geselecteerd ? 1.4 : 1,
        ),
      ),
      child: CustomPaint(
        painter: OpmetingSchuifvliegendeurProfielPainter(
          profiel: profiel,
          geselecteerd: geselecteerd,
        ),
      ),
    );
  }
}

class OpmetingSchuifvliegendeurProfielPainter extends CustomPainter {
  const OpmetingSchuifvliegendeurProfielPainter({
    required this.profiel,
    this.geselecteerd = false,
  });

  final OpmetingSchuifvliegendeurProfiel profiel;
  final bool geselecteerd;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final accent = geselecteerd
        ? const Color(0xFF0B7A3B)
        : const Color(0xFF38517A);
    final lijn = Paint()
      ..color = const Color(0xFF475569)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final detail = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.65
      ..strokeJoin = StrokeJoin.round;
    final cirkel = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = geselecteerd ? 1.2 : 0.9;

    final labelHoogte = math.min(12.0, size.height * 0.23).toDouble();
    final tekenHoogte = math.max(12.0, size.height - labelHoogte).toDouble();
    final diameter = math
        .min(size.width - 4, tekenHoogte - 2)
        .clamp(12.0, double.infinity)
        .toDouble();
    final center = Offset(size.width / 2, (tekenHoogte - 1) / 2);
    canvas.drawCircle(center, diameter / 2, cirkel);

    final profielRect = Rect.fromCenter(
      center: center,
      width: diameter * 0.60,
      height: diameter * 0.60,
    );
    _tekenProfielVoorCode(
      canvas,
      profiel.code.trim().toUpperCase(),
      profielRect,
      lijn,
      detail,
    );

    final tekst = TextPainter(
      text: TextSpan(
        text: profiel.code,
        style: TextStyle(
          color: geselecteerd
              ? const Color(0xFF0B7A3B)
              : const Color(0xFF64748B),
          fontSize: 7.6,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: size.width - 2);
    tekst.paint(
      canvas,
      Offset((size.width - tekst.width) / 2, size.height - tekst.height),
    );
  }

  void _tekenProfielVoorCode(
    Canvas canvas,
    String code,
    Rect r,
    Paint lijn,
    Paint detail,
  ) {
    Offset p(double x, double y) {
      return Offset(r.left + (r.width * x), r.top + (r.height * y));
    }

    Path pad(List<(double, double)> punten) {
      final resultaat = Path();
      if (punten.isEmpty) return resultaat;
      resultaat.moveTo(
        p(punten.first.$1, punten.first.$2).dx,
        p(punten.first.$1, punten.first.$2).dy,
      );
      for (final punt in punten.skip(1)) {
        final positie = p(punt.$1, punt.$2);
        resultaat.lineTo(positie.dx, positie.dy);
      }
      return resultaat;
    }

    void teken(
      List<(double, double)> hoofd, {
      List<List<(double, double)>> details = const <List<(double, double)>>[],
    }) {
      canvas.drawPath(pad(hoofd), lijn);
      for (final deel in details) {
        canvas.drawPath(pad(deel), detail);
      }
    }

    switch (code) {
      case 'VP5087':
        teken(
          <(double, double)>[
            (0.18, 0.78),
            (0.18, 0.34),
            (0.56, 0.34),
            (0.56, 0.58),
            (0.82, 0.58),
          ],
          details: <List<(double, double)>>[
            <(double, double)>[(0.28, 0.70), (0.28, 0.44), (0.49, 0.44)],
          ],
        );
        break;
      case 'VP1011':
        teken(
          <(double, double)>[
            (0.16, 0.82),
            (0.16, 0.22),
            (0.47, 0.22),
            (0.47, 0.43),
            (0.68, 0.43),
            (0.68, 0.72),
            (0.84, 0.72),
          ],
          details: <List<(double, double)>>[
            <(double, double)>[(0.25, 0.75), (0.25, 0.31), (0.40, 0.31)],
            <(double, double)>[(0.54, 0.50), (0.61, 0.50), (0.61, 0.65)],
          ],
        );
        break;
      case 'VP5088':
        teken(
          <(double, double)>[
            (0.20, 0.18),
            (0.20, 0.82),
            (0.82, 0.82),
            (0.82, 0.64),
            (0.45, 0.64),
            (0.45, 0.18),
          ],
          details: <List<(double, double)>>[
            <(double, double)>[(0.30, 0.24), (0.30, 0.72), (0.72, 0.72)],
          ],
        );
        break;
      case 'VP4961':
        teken(
          <(double, double)>[
            (0.22, 0.17),
            (0.22, 0.82),
            (0.80, 0.82),
            (0.80, 0.64),
            (0.57, 0.64),
            (0.57, 0.39),
            (0.42, 0.39),
            (0.42, 0.17),
          ],
          details: <List<(double, double)>>[
            <(double, double)>[(0.31, 0.25), (0.31, 0.73), (0.70, 0.73)],
            <(double, double)>[(0.48, 0.45), (0.50, 0.45), (0.50, 0.58)],
          ],
        );
        break;
      case 'VP1012':
        teken(
          <(double, double)>[
            (0.15, 0.25),
            (0.62, 0.25),
            (0.62, 0.48),
            (0.43, 0.48),
            (0.43, 0.76),
            (0.84, 0.76),
          ],
          details: <List<(double, double)>>[
            <(double, double)>[(0.24, 0.33), (0.53, 0.33), (0.53, 0.57)],
          ],
        );
        break;
      case 'VP1016':
        teken(
          <(double, double)>[(0.10, 0.72), (0.88, 0.72)],
          details: <List<(double, double)>>[
            <(double, double)>[
              (0.38, 0.72),
              (0.38, 0.50),
              (0.48, 0.50),
              (0.48, 0.64),
              (0.61, 0.64),
              (0.61, 0.72),
            ],
            <(double, double)>[(0.17, 0.66), (0.82, 0.66)],
          ],
        );
        break;
      case 'VP1059/VP1060':
        teken(
          <(double, double)>[
            (0.20, 0.20),
            (0.20, 0.79),
            (0.80, 0.79),
            (0.80, 0.20),
            (0.66, 0.20),
            (0.66, 0.60),
            (0.34, 0.60),
            (0.34, 0.20),
          ],
          details: <List<(double, double)>>[
            <(double, double)>[
              (0.28, 0.29),
              (0.28, 0.69),
              (0.72, 0.69),
              (0.72, 0.29),
            ],
          ],
        );
        break;
      case 'VP1054':
        teken(
          <(double, double)>[
            (0.20, 0.20),
            (0.20, 0.78),
            (0.48, 0.78),
            (0.48, 0.53),
            (0.82, 0.53),
            (0.82, 0.20),
          ],
          details: <List<(double, double)>>[
            <(double, double)>[(0.29, 0.29), (0.29, 0.68), (0.39, 0.68)],
          ],
        );
        break;
      case 'VR073':
        teken(
          <(double, double)>[
            (0.16, 0.23),
            (0.58, 0.23),
            (0.58, 0.48),
            (0.42, 0.48),
            (0.42, 0.78),
            (0.84, 0.78),
          ],
          details: <List<(double, double)>>[
            <(double, double)>[(0.25, 0.31), (0.50, 0.31), (0.50, 0.57)],
          ],
        );
        break;
      case 'VR074':
        teken(
          <(double, double)>[
            (0.20, 0.20),
            (0.20, 0.78),
            (0.80, 0.78),
            (0.80, 0.59),
            (0.46, 0.59),
            (0.46, 0.20),
          ],
          details: <List<(double, double)>>[
            <(double, double)>[(0.29, 0.29), (0.29, 0.68), (0.70, 0.68)],
          ],
        );
        break;
      default:
        teken(<(double, double)>[
          (0.18, 0.76),
          (0.18, 0.28),
          (0.52, 0.28),
          (0.52, 0.55),
          (0.82, 0.55),
        ]);
    }
  }

  @override
  bool shouldRepaint(
    covariant OpmetingSchuifvliegendeurProfielPainter oldDelegate,
  ) {
    return oldDelegate.profiel != profiel ||
        oldDelegate.geselecteerd != geselecteerd;
  }
}
