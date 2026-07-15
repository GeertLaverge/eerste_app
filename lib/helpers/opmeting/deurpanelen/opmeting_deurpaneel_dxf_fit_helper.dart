import 'dart:math' as math;
import 'dart:ui';

import 'opmeting_deurpaneel_dxf_model.dart';

class OpmetingDeurpaneelDxfFitHelper {
  const OpmetingDeurpaneelDxfFitHelper._();

  static List<Offset> puntenNaarCanvas({
    required List<OpmetingDeurpaneelDxfPoint> punten,
    required OpmetingDeurpaneelDxfBounds bounds,
    required Rect doelRect,
    double margePx = 0,
    bool behoudVerhouding = true,
  }) {
    return punten
        .map((punt) {
          return puntNaarCanvas(
            punt: punt,
            bounds: bounds,
            doelRect: doelRect,
            margePx: margePx,
            behoudVerhouding: behoudVerhouding,
          );
        })
        .toList(growable: false);
  }

  static Offset puntNaarCanvas({
    required OpmetingDeurpaneelDxfPoint punt,
    required OpmetingDeurpaneelDxfBounds bounds,
    required Rect doelRect,
    double margePx = 0,
    bool behoudVerhouding = true,
  }) {
    if (doelRect.width <= 0 || doelRect.height <= 0) {
      return doelRect.center;
    }

    final marge = math.max(0.0, margePx).toDouble();
    final bruikbaar = doelRect.deflate(marge);

    if (bruikbaar.width <= 0 || bruikbaar.height <= 0) {
      return doelRect.center;
    }

    final bronBreedte = bounds.width.abs();
    final bronHoogte = bounds.height.abs();

    if (bronBreedte == 0 && bronHoogte == 0) {
      return bruikbaar.center;
    }

    if (!behoudVerhouding) {
      final schaalX = bronBreedte == 0 ? 0.0 : bruikbaar.width / bronBreedte;
      final schaalY = bronHoogte == 0 ? 0.0 : bruikbaar.height / bronHoogte;

      final x = bronBreedte == 0
          ? bruikbaar.center.dx
          : bruikbaar.left + ((punt.x - bounds.minX) * schaalX);

      final y = bronHoogte == 0
          ? bruikbaar.center.dy
          : bruikbaar.top + ((bounds.maxY - punt.y) * schaalY);

      return Offset(x, y);
    }

    late final double schaal;

    if (bronBreedte == 0) {
      schaal = bruikbaar.height / bronHoogte;
    } else if (bronHoogte == 0) {
      schaal = bruikbaar.width / bronBreedte;
    } else {
      final schaalX = bruikbaar.width / bronBreedte;
      final schaalY = bruikbaar.height / bronHoogte;
      schaal = math.min(schaalX, schaalY);
    }

    final getekendeBreedte = bronBreedte * schaal;
    final getekendeHoogte = bronHoogte * schaal;

    final offsetX = bruikbaar.left + ((bruikbaar.width - getekendeBreedte) / 2);
    final offsetY = bruikbaar.top + ((bruikbaar.height - getekendeHoogte) / 2);

    final x = bronBreedte == 0
        ? bruikbaar.center.dx
        : offsetX + ((punt.x - bounds.minX) * schaal);

    /*
     * DXF werkt normaal met Y omhoog.
     * Flutter/canvas werkt met Y omlaag.
     * Daarom spiegelen we de Y-as hier.
     */
    final y = bronHoogte == 0
        ? bruikbaar.center.dy
        : offsetY + ((bounds.maxY - punt.y) * schaal);

    return Offset(x, y);
  }

  static List<Offset> entityNaarCanvasPunten({
    required OpmetingDeurpaneelDxfEntity entity,
    required OpmetingDeurpaneelDxfBounds bounds,
    required Rect doelRect,
    double margePx = 0,
    bool behoudVerhouding = true,
  }) {
    switch (entity.type) {
      case OpmetingDeurpaneelDxfEntityType.line:
      case OpmetingDeurpaneelDxfEntityType.polyline:
        return puntenNaarCanvas(
          punten: entity.points,
          bounds: bounds,
          doelRect: doelRect,
          margePx: margePx,
          behoudVerhouding: behoudVerhouding,
        );

      case OpmetingDeurpaneelDxfEntityType.circle:
        return puntenNaarCanvas(
          punten: entity.sampleCirclePunten(),
          bounds: bounds,
          doelRect: doelRect,
          margePx: margePx,
          behoudVerhouding: behoudVerhouding,
        );

      case OpmetingDeurpaneelDxfEntityType.arc:
        return puntenNaarCanvas(
          punten: entity.sampleArcPunten(),
          bounds: bounds,
          doelRect: doelRect,
          margePx: margePx,
          behoudVerhouding: behoudVerhouding,
        );
    }
  }
}
