import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'opmeting_teken_model.dart';

class OpmetingDriehoekService {
  static Offset? berekenDriehoekPunt({
    required Offset punt1,
    required Offset punt2,
    required Offset richtingKlik,
    required List<OpmetingLijn> lijnen,
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

    for (final lijn in lijnen) {
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

  static bool _isZelfdeLijn(
    OpmetingLijn lijn,
    Offset punt1,
    Offset punt2,
  ) {
    final d1 = (lijn.start - punt1).distance + (lijn.einde - punt2).distance;
    final d2 = (lijn.start - punt2).distance + (lijn.einde - punt1).distance;

    return d1 < 1 || d2 < 1;
  }

  static bool _puntOpLijnstuk(
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

  static double _afstandTotLijnstuk({
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

  static double _dot(Offset a, Offset b) {
    return (a.dx * b.dx) + (a.dy * b.dy);
  }

  static double _kruis(Offset a, Offset b) {
    return (a.dx * b.dy) - (a.dy * b.dx);
  }
}
