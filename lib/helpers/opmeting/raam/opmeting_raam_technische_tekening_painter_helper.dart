import 'package:flutter/material.dart';

import 'opmeting_raam_keuzemenu_model.dart';
import 'opmeting_raam_technische_layout_helper.dart';

class OpmetingRaamTechnischeTekeningPainterHelper {
  const OpmetingRaamTechnischeTekeningPainterHelper._();

  static const Color _randKleur = Color(0xFF111827);
  static const Color _patroonKleur = Color(0xFF4B5563);

  static void teken({
    required Canvas canvas,
    required OpmetingRaamTechnischeLayout layout,
  }) {
    for (final vlak in layout.technischeVlakken) {
      if (vlak.rechthoek.width <= 1 || vlak.rechthoek.height <= 1) {
        continue;
      }

      _tekenTechnischeRechthoek(
        canvas: canvas,
        rechthoek: vlak.rechthoek,
        instelling: vlak.instelling,
      );
    }
  }

  static void _tekenTechnischeRechthoek({
    required Canvas canvas,
    required Rect rechthoek,
    required OpmetingRaamTechnischeTekeningInstelling instelling,
  }) {
    canvas.drawRect(
      rechthoek,
      Paint()
        ..color = Colors.white.withOpacity(0.94)
        ..style = PaintingStyle.fill,
    );

    canvas.save();

    final clipRechthoek = rechthoek.deflate(1);

    if (clipRechthoek.width > 0 && clipRechthoek.height > 0) {
      canvas.clipRect(clipRechthoek);
    }

    if (instelling.inhoudType == OpmetingRaamTechnischeInhoudType.tekst) {
      _tekenTekst(
        canvas: canvas,
        rechthoek: rechthoek,
        tekst: instelling.tekst,
      );
    } else {
      _tekenRasterPatroon(
        canvas: canvas,
        rechthoek: rechthoek,
        patroon: instelling.rasterPatroon,
      );
    }

    canvas.restore();

    canvas.drawRect(
      rechthoek,
      Paint()
        ..color = _randKleur
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke,
    );
  }

  static void _tekenRasterPatroon({
    required Canvas canvas,
    required Rect rechthoek,
    required OpmetingRaamTechnischRasterPatroon patroon,
  }) {
    switch (patroon) {
      case OpmetingRaamTechnischRasterPatroon.horizontaleLijnen:
        _tekenHorizontaleLijnen(canvas, rechthoek);
        break;

      case OpmetingRaamTechnischRasterPatroon.verticaleLijnen:
        _tekenVerticaleLijnen(canvas, rechthoek);
        break;

      case OpmetingRaamTechnischRasterPatroon.diagonaalRechts:
        _tekenDiagonalen(
          canvas: canvas,
          rechthoek: rechthoek,
          naarRechts: true,
        );
        break;

      case OpmetingRaamTechnischRasterPatroon.diagonaalLinks:
        _tekenDiagonalen(
          canvas: canvas,
          rechthoek: rechthoek,
          naarRechts: false,
        );
        break;

      case OpmetingRaamTechnischRasterPatroon.kruisarcering:
        _tekenDiagonalen(
          canvas: canvas,
          rechthoek: rechthoek,
          naarRechts: true,
        );

        _tekenDiagonalen(
          canvas: canvas,
          rechthoek: rechthoek,
          naarRechts: false,
        );
        break;

      case OpmetingRaamTechnischRasterPatroon.vierkantRaster:
        _tekenHorizontaleLijnen(canvas, rechthoek);

        _tekenVerticaleLijnen(canvas, rechthoek);
        break;

      case OpmetingRaamTechnischRasterPatroon.punten:
        _tekenPunten(canvas, rechthoek);
        break;

      case OpmetingRaamTechnischRasterPatroon.cirkels:
        _tekenCirkels(canvas, rechthoek);
        break;

      case OpmetingRaamTechnischRasterPatroon.ruiten:
        _tekenRuiten(canvas, rechthoek);
        break;

      case OpmetingRaamTechnischRasterPatroon.zigzag:
        _tekenZigzag(canvas, rechthoek);
        break;
    }
  }

  static void _tekenTekst({
    required Canvas canvas,
    required Rect rechthoek,
    required String tekst,
  }) {
    final inhoud = tekst.trim();

    if (inhoud.isEmpty) {
      return;
    }

    final maximaleBreedte = rechthoek.width > 12 ? rechthoek.width - 12 : 1.0;

    final maximaleHoogte = rechthoek.height > 8 ? rechthoek.height - 8 : 1.0;

    var letterGrootte = 14.0;

    late TextPainter tekstPainter;

    while (true) {
      tekstPainter = TextPainter(
        text: TextSpan(
          text: inhoud,
          style: TextStyle(
            color: _randKleur,
            fontSize: letterGrootte,
            fontWeight: FontWeight.w600,
            height: 1.1,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        maxLines: 4,
        ellipsis: '…',
      );

      tekstPainter.layout(maxWidth: maximaleBreedte);

      final pastInHoogte = tekstPainter.height <= maximaleHoogte;

      final pastInRegels = !tekstPainter.didExceedMaxLines;

      if ((pastInHoogte && pastInRegels) || letterGrootte <= 8) {
        break;
      }

      letterGrootte -= 1;
    }

    tekstPainter.paint(
      canvas,
      Offset(
        rechthoek.center.dx - tekstPainter.width / 2,
        rechthoek.center.dy - tekstPainter.height / 2,
      ),
    );
  }

  static Paint _patroonPaint() {
    return Paint()
      ..color = _patroonKleur
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
  }

  static void _tekenHorizontaleLijnen(Canvas canvas, Rect rechthoek) {
    final paint = _patroonPaint();

    for (double y = rechthoek.top + 6; y < rechthoek.bottom; y += 7) {
      canvas.drawLine(
        Offset(rechthoek.left, y),
        Offset(rechthoek.right, y),
        paint,
      );
    }
  }

  static void _tekenVerticaleLijnen(Canvas canvas, Rect rechthoek) {
    final paint = _patroonPaint();

    for (double x = rechthoek.left + 6; x < rechthoek.right; x += 7) {
      canvas.drawLine(
        Offset(x, rechthoek.top),
        Offset(x, rechthoek.bottom),
        paint,
      );
    }
  }

  static void _tekenDiagonalen({
    required Canvas canvas,
    required Rect rechthoek,
    required bool naarRechts,
  }) {
    final paint = _patroonPaint();

    for (
      double verschuiving = -rechthoek.height;
      verschuiving < rechthoek.width;
      verschuiving += 9
    ) {
      if (naarRechts) {
        canvas.drawLine(
          Offset(rechthoek.left + verschuiving, rechthoek.bottom),
          Offset(
            rechthoek.left + verschuiving + rechthoek.height,
            rechthoek.top,
          ),
          paint,
        );
      } else {
        canvas.drawLine(
          Offset(rechthoek.right - verschuiving, rechthoek.bottom),
          Offset(
            rechthoek.right - verschuiving - rechthoek.height,
            rechthoek.top,
          ),
          paint,
        );
      }
    }
  }

  static void _tekenPunten(Canvas canvas, Rect rechthoek) {
    final paint = Paint()
      ..color = _patroonKleur
      ..style = PaintingStyle.fill;

    for (double y = rechthoek.top + 6; y < rechthoek.bottom; y += 9) {
      for (double x = rechthoek.left + 6; x < rechthoek.right; x += 9) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  static void _tekenCirkels(Canvas canvas, Rect rechthoek) {
    final paint = _patroonPaint();

    for (double y = rechthoek.top + 7; y < rechthoek.bottom; y += 12) {
      for (double x = rechthoek.left + 7; x < rechthoek.right; x += 12) {
        canvas.drawCircle(Offset(x, y), 3, paint);
      }
    }
  }

  static void _tekenRuiten(Canvas canvas, Rect rechthoek) {
    final paint = _patroonPaint();

    for (double y = rechthoek.top + 7; y < rechthoek.bottom; y += 12) {
      for (double x = rechthoek.left + 7; x < rechthoek.right; x += 12) {
        final path = Path()
          ..moveTo(x, y - 4)
          ..lineTo(x + 4, y)
          ..lineTo(x, y + 4)
          ..lineTo(x - 4, y)
          ..close();

        canvas.drawPath(path, paint);
      }
    }
  }

  static void _tekenZigzag(Canvas canvas, Rect rechthoek) {
    final paint = _patroonPaint();

    for (double y = rechthoek.top + 6; y < rechthoek.bottom; y += 10) {
      final path = Path()..moveTo(rechthoek.left, y);

      var omhoog = true;

      for (double x = rechthoek.left + 5; x <= rechthoek.right + 5; x += 5) {
        path.lineTo(x, omhoog ? y - 3 : y + 3);

        omhoog = !omhoog;
      }

      canvas.drawPath(path, paint);
    }
  }
}
