import 'package:flutter/material.dart';

import 'opmeting_raam_kader_helper.dart';
import 'opmeting_raam_kleinhout_helper.dart';
import 'opmeting_raam_kleinhout_model.dart';
import 'opmeting_raam_model.dart';
import 'opmeting_raam_opvulling_model.dart';
import 'opmeting_raam_tstijl_helper.dart';
import 'opmeting_raam_vleugel_helper.dart';
import 'opmeting_raam_vulling_helper.dart';
import 'opmeting_raam_vulling_teken_helper.dart';

class OpmetingRaamTekenvlakPainter extends CustomPainter {
  const OpmetingRaamTekenvlakPainter({
    required this.breedteMm,
    required this.hoogteMm,
    required this.geselecteerdeLijn,
    required this.previewPunt,
    required this.tStijlen,
    required this.vleugels,
    required this.vulvlakken,
    required this.vullingToewijzingen,
    required this.geselecteerdeVulvlakIds,
    this.kleinhouten = const <OpmetingRaamKleinhout>[],
    this.geselecteerdeKleinhoutVlakIds = const <String>{},
  });

  final int breedteMm;
  final int hoogteMm;

  final OpmetingRaamLijn? geselecteerdeLijn;
  final Offset? previewPunt;

  final List<OpmetingRaamTStijl> tStijlen;
  final List<OpmetingRaamVleugel> vleugels;

  final List<OpmetingRaamVulvlak> vulvlakken;

  final List<OpmetingRaamVullingToewijzing> vullingToewijzingen;

  final Set<String> geselecteerdeVulvlakIds;

  final List<OpmetingRaamKleinhout> kleinhouten;

  final Set<String> geselecteerdeKleinhoutVlakIds;

  static const Color _maatKleur = Color(0xFF111827);
  static const double _kwartDraai = 1.5707963267948966;

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

    /*
     * Eerst wordt de achtergrond van de gekozen
     * opvullingen getekend.
     */
    OpmetingRaamVullingTekenHelper.tekenAchtergrond(
      canvas: canvas,
      vulvlakken: vulvlakken,
      toewijzingen: vullingToewijzingen,
    );

    /*
     * Vervolgens het kader, de vleugels en T-stijlen.
     */
    _tekenKader(canvas, buiten, binnen);

    for (final vleugel in vleugels) {
      OpmetingRaamVleugelHelper.tekenVleugel(
        canvas: canvas,
        vleugel: vleugel,
        buitenKader: buiten,
        breedteMm: breedteMm,
        hoogteMm: hoogteMm,
      );
    }

    for (final stijl in tStijlen) {
      OpmetingRaamTStijlHelper.tekenTStijl(
        canvas: canvas,
        stijl: stijl,
        buitenKader: buiten,
        breedteMm: breedteMm,
        hoogteMm: hoogteMm,
      );
    }

    /*
     * Kleinhouten worden boven de glasopvulling
     * getekend en blijven door de helper begrensd
     * tot het bijbehorende glasvlak.
     */
    OpmetingRaamKleinhoutHelper.tekenKleinhouten(
      canvas: canvas,
      buitenKader: buiten,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      vulvlakken: vulvlakken,
      kleinhouten: kleinhouten,
      geselecteerdeVlakIds: geselecteerdeKleinhoutVlakIds,
    );

    /*
     * De nummering en selectie van de opvullingen
     * blijft altijd boven de kleinhouten zichtbaar.
     */
    OpmetingRaamVullingTekenHelper.tekenVoorgrond(
      canvas: canvas,
      vulvlakken: vulvlakken,
      toewijzingen: vullingToewijzingen,
      geselecteerdeVulvlakIds: geselecteerdeVulvlakIds,
    );

    _tekenGeselecteerdeLijn(canvas);
    _tekenPreviewPunt(canvas);

    _tekenMaatvoering(canvas: canvas, buiten: buiten);
  }

  void _tekenGeselecteerdeLijn(Canvas canvas) {
    if (geselecteerdeLijn == null) {
      return;
    }

    final paint = Paint()
      ..color = const Color(0xFFF97316)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(geselecteerdeLijn!.start, geselecteerdeLijn!.einde, paint);
  }

  void _tekenPreviewPunt(Canvas canvas) {
    if (previewPunt == null) {
      return;
    }

    final paint = Paint()
      ..color = const Color(0xFFDC2626)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(previewPunt!, 6, paint);
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
      ..strokeWidth = 1;

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

  void _tekenMaatvoering({required Canvas canvas, required Rect buiten}) {
    final verticaleTStijlPosities = <double>[];
    final horizontaleTStijlPosities = <double>[];

    for (final stijl in tStijlen) {
      if (stijl.werkvlakId != 'kader') {
        continue;
      }

      if (stijl.richting == 'verticaal') {
        final x = stijl.start.dx;

        if (x > buiten.left + 1 && x < buiten.right - 1) {
          verticaleTStijlPosities.add(x);
        }
      } else if (stijl.richting == 'horizontaal') {
        final y = stijl.start.dy;

        if (y > buiten.top + 1 && y < buiten.bottom - 1) {
          horizontaleTStijlPosities.add(y);
        }
      }
    }

    final uniekeVerticalePosities = _uniekeGesorteerdeWaarden(
      verticaleTStijlPosities,
    );

    final uniekeHorizontalePosities = _uniekeGesorteerdeWaarden(
      horizontaleTStijlPosities,
    );

    final heeftBreedteKetting = uniekeVerticalePosities.isNotEmpty;

    final heeftHoogteKetting = uniekeHorizontalePosities.isNotEmpty;

    if (heeftBreedteKetting) {
      _tekenHorizontaleMaatketting(
        canvas: canvas,
        buiten: buiten,
        tStijlPosities: uniekeVerticalePosities,
        maatLijnY: buiten.bottom + 14,
      );
    }

    if (heeftHoogteKetting) {
      _tekenVerticaleMaatketting(
        canvas: canvas,
        buiten: buiten,
        tStijlPosities: uniekeHorizontalePosities,
        maatLijnX: buiten.right + 14,
      );
    }

    _tekenTotaleBreedtemaat(
      canvas: canvas,
      buiten: buiten,
      maatLijnY: buiten.bottom + (heeftBreedteKetting ? 42 : 28),
    );

    _tekenTotaleHoogtemaat(
      canvas: canvas,
      buiten: buiten,
      maatLijnX: buiten.right + (heeftHoogteKetting ? 44 : 28),
    );
  }

  List<double> _uniekeGesorteerdeWaarden(List<double> waarden) {
    final gesorteerd = <double>[...waarden]..sort();

    final uniek = <double>[];

    for (final waarde in gesorteerd) {
      if (uniek.isEmpty || (waarde - uniek.last).abs() > 2) {
        uniek.add(waarde);
      }
    }

    return uniek;
  }

  void _tekenHorizontaleMaatketting({
    required Canvas canvas,
    required Rect buiten,
    required List<double> tStijlPosities,
    required double maatLijnY,
  }) {
    final punten = <double>[buiten.left, ...tStijlPosities, buiten.right]
      ..sort();

    final hulplijnPaint = Paint()
      ..color = _maatKleur
      ..strokeWidth = 0.75
      ..style = PaintingStyle.stroke;

    for (final x in punten) {
      canvas.drawLine(
        Offset(x, buiten.bottom + 2),
        Offset(x, maatLijnY + 5),
        hulplijnPaint,
      );
    }

    for (var index = 0; index < punten.length - 1; index++) {
      final startX = punten[index];
      final eindeX = punten[index + 1];

      if (eindeX - startX < 1) {
        continue;
      }

      final maatMm = ((eindeX - startX) / buiten.width * breedteMm).round();

      _tekenHorizontaleMaat(
        canvas: canvas,
        startX: startX,
        eindeX: eindeX,
        y: maatLijnY,
        tekst: '$maatMm',
        buitenmaat: false,
      );
    }
  }

  void _tekenVerticaleMaatketting({
    required Canvas canvas,
    required Rect buiten,
    required List<double> tStijlPosities,
    required double maatLijnX,
  }) {
    final punten = <double>[buiten.top, ...tStijlPosities, buiten.bottom]
      ..sort();

    final hulplijnPaint = Paint()
      ..color = _maatKleur
      ..strokeWidth = 0.75
      ..style = PaintingStyle.stroke;

    for (final y in punten) {
      canvas.drawLine(
        Offset(buiten.right + 2, y),
        Offset(maatLijnX + 5, y),
        hulplijnPaint,
      );
    }

    for (var index = 0; index < punten.length - 1; index++) {
      final startY = punten[index];
      final eindeY = punten[index + 1];

      if (eindeY - startY < 1) {
        continue;
      }

      final maatMm = ((eindeY - startY) / buiten.height * hoogteMm).round();

      _tekenVerticaleMaat(
        canvas: canvas,
        startY: startY,
        eindeY: eindeY,
        x: maatLijnX,
        tekst: '$maatMm',
        buitenmaat: false,
      );
    }
  }

  void _tekenTotaleBreedtemaat({
    required Canvas canvas,
    required Rect buiten,
    required double maatLijnY,
  }) {
    final hulplijnPaint = Paint()
      ..color = _maatKleur
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(buiten.left, buiten.bottom + 2),
      Offset(buiten.left, maatLijnY + 6),
      hulplijnPaint,
    );

    canvas.drawLine(
      Offset(buiten.right, buiten.bottom + 2),
      Offset(buiten.right, maatLijnY + 6),
      hulplijnPaint,
    );

    _tekenHorizontaleMaat(
      canvas: canvas,
      startX: buiten.left,
      eindeX: buiten.right,
      y: maatLijnY,
      tekst: '$breedteMm mm',
      buitenmaat: true,
    );
  }

  void _tekenTotaleHoogtemaat({
    required Canvas canvas,
    required Rect buiten,
    required double maatLijnX,
  }) {
    final hulplijnPaint = Paint()
      ..color = _maatKleur
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(buiten.right + 2, buiten.top),
      Offset(maatLijnX + 6, buiten.top),
      hulplijnPaint,
    );

    canvas.drawLine(
      Offset(buiten.right + 2, buiten.bottom),
      Offset(maatLijnX + 6, buiten.bottom),
      hulplijnPaint,
    );

    _tekenVerticaleMaat(
      canvas: canvas,
      startY: buiten.top,
      eindeY: buiten.bottom,
      x: maatLijnX,
      tekst: '$hoogteMm mm',
      buitenmaat: true,
    );
  }

  void _tekenHorizontaleMaat({
    required Canvas canvas,
    required double startX,
    required double eindeX,
    required double y,
    required String tekst,
    required bool buitenmaat,
  }) {
    final lijnPaint = Paint()
      ..color = _maatKleur
      ..strokeWidth = buitenmaat ? 1 : 0.8
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(startX, y), Offset(eindeX, y), lijnPaint);

    final lengte = (eindeX - startX).abs();
    final pijlBinnen = lengte >= 16;
    final pijlGrootte = buitenmaat ? 5.5 : 4.5;

    _tekenHorizontalePijlpunt(
      canvas: canvas,
      punt: Offset(startX, y),
      isLinkerPunt: true,
      pijlBinnen: pijlBinnen,
      grootte: pijlGrootte,
    );

    _tekenHorizontalePijlpunt(
      canvas: canvas,
      punt: Offset(eindeX, y),
      isLinkerPunt: false,
      pijlBinnen: pijlBinnen,
      grootte: pijlGrootte,
    );

    final style = TextStyle(
      color: _maatKleur,
      fontSize: buitenmaat ? 11 : 9,
      fontWeight: buitenmaat ? FontWeight.w800 : FontWeight.w600,
    );

    final painter = _maakTekstPainter(tekst: tekst, style: style);

    final middenX = (startX + eindeX) / 2;

    final beschikbareBreedte = lengte - 12;

    if (painter.width <= beschikbareBreedte || buitenmaat) {
      _tekenTekstMetAchtergrond(
        canvas: canvas,
        painter: painter,
        midden: Offset(middenX, y),
      );
    } else {
      _tekenGedraaideTekstMetAchtergrond(
        canvas: canvas,
        painter: painter,
        midden: Offset(middenX, y),
        hoek: -_kwartDraai,
      );
    }
  }

  void _tekenVerticaleMaat({
    required Canvas canvas,
    required double startY,
    required double eindeY,
    required double x,
    required String tekst,
    required bool buitenmaat,
  }) {
    final lijnPaint = Paint()
      ..color = _maatKleur
      ..strokeWidth = buitenmaat ? 1 : 0.8
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(x, startY), Offset(x, eindeY), lijnPaint);

    final lengte = (eindeY - startY).abs();
    final pijlBinnen = lengte >= 16;
    final pijlGrootte = buitenmaat ? 5.5 : 4.5;

    _tekenVerticalePijlpunt(
      canvas: canvas,
      punt: Offset(x, startY),
      isBovenstePunt: true,
      pijlBinnen: pijlBinnen,
      grootte: pijlGrootte,
    );

    _tekenVerticalePijlpunt(
      canvas: canvas,
      punt: Offset(x, eindeY),
      isBovenstePunt: false,
      pijlBinnen: pijlBinnen,
      grootte: pijlGrootte,
    );

    final style = TextStyle(
      color: _maatKleur,
      fontSize: buitenmaat ? 11 : 9,
      fontWeight: buitenmaat ? FontWeight.w800 : FontWeight.w600,
    );

    final painter = _maakTekstPainter(tekst: tekst, style: style);

    final middenY = (startY + eindeY) / 2;

    final beschikbareHoogte = lengte - 12;

    if (painter.width <= beschikbareHoogte || buitenmaat) {
      _tekenGedraaideTekstMetAchtergrond(
        canvas: canvas,
        painter: painter,
        midden: Offset(x, middenY),
        hoek: -_kwartDraai,
      );
    } else {
      _tekenTekstMetAchtergrond(
        canvas: canvas,
        painter: painter,
        midden: Offset(x, middenY),
      );
    }
  }

  void _tekenHorizontalePijlpunt({
    required Canvas canvas,
    required Offset punt,
    required bool isLinkerPunt,
    required bool pijlBinnen,
    required double grootte,
  }) {
    final richting = isLinkerPunt
        ? (pijlBinnen ? 1.0 : -1.0)
        : (pijlBinnen ? -1.0 : 1.0);

    final path = Path()
      ..moveTo(punt.dx, punt.dy)
      ..lineTo(punt.dx + richting * grootte, punt.dy - grootte * 0.45)
      ..lineTo(punt.dx + richting * grootte, punt.dy + grootte * 0.45)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = _maatKleur
        ..style = PaintingStyle.fill,
    );
  }

  void _tekenVerticalePijlpunt({
    required Canvas canvas,
    required Offset punt,
    required bool isBovenstePunt,
    required bool pijlBinnen,
    required double grootte,
  }) {
    final richting = isBovenstePunt
        ? (pijlBinnen ? 1.0 : -1.0)
        : (pijlBinnen ? -1.0 : 1.0);

    final path = Path()
      ..moveTo(punt.dx, punt.dy)
      ..lineTo(punt.dx - grootte * 0.45, punt.dy + richting * grootte)
      ..lineTo(punt.dx + grootte * 0.45, punt.dy + richting * grootte)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = _maatKleur
        ..style = PaintingStyle.fill,
    );
  }

  TextPainter _maakTekstPainter({
    required String tekst,
    required TextStyle style,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: tekst, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    painter.layout();

    return painter;
  }

  void _tekenTekstMetAchtergrond({
    required Canvas canvas,
    required TextPainter painter,
    required Offset midden,
  }) {
    final tekstRect = Rect.fromCenter(
      center: midden,
      width: painter.width + 6,
      height: painter.height + 2,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(tekstRect, const Radius.circular(2)),
      Paint()
        ..color = Colors.white.withOpacity(0.96)
        ..style = PaintingStyle.fill,
    );

    painter.paint(
      canvas,
      Offset(midden.dx - painter.width / 2, midden.dy - painter.height / 2),
    );
  }

  void _tekenGedraaideTekstMetAchtergrond({
    required Canvas canvas,
    required TextPainter painter,
    required Offset midden,
    required double hoek,
  }) {
    canvas.save();

    canvas.translate(midden.dx, midden.dy);

    canvas.rotate(hoek);

    final tekstRect = Rect.fromCenter(
      center: Offset.zero,
      width: painter.width + 6,
      height: painter.height + 2,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(tekstRect, const Radius.circular(2)),
      Paint()
        ..color = Colors.white.withOpacity(0.96)
        ..style = PaintingStyle.fill,
    );

    painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant OpmetingRaamTekenvlakPainter oldDelegate) {
    return breedteMm != oldDelegate.breedteMm ||
        hoogteMm != oldDelegate.hoogteMm ||
        geselecteerdeLijn != oldDelegate.geselecteerdeLijn ||
        previewPunt != oldDelegate.previewPunt ||
        !identical(tStijlen, oldDelegate.tStijlen) ||
        !identical(vleugels, oldDelegate.vleugels) ||
        !identical(vulvlakken, oldDelegate.vulvlakken) ||
        !identical(vullingToewijzingen, oldDelegate.vullingToewijzingen) ||
        !identical(
          geselecteerdeVulvlakIds,
          oldDelegate.geselecteerdeVulvlakIds,
        ) ||
        !identical(kleinhouten, oldDelegate.kleinhouten) ||
        !identical(
          geselecteerdeKleinhoutVlakIds,
          oldDelegate.geselecteerdeKleinhoutVlakIds,
        );
  }
}
