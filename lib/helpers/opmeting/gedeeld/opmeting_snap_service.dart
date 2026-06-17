import 'package:flutter/material.dart';

import 'opmeting_teken_model.dart';

class OpmetingSnapService {
  static List<Offset> snappuntenVanLijnen(
    List<OpmetingLijn> lijnen,
  ) {
    final punten = <Offset>[];

    for (final lijn in lijnen) {
      punten.add(lijn.start);
      punten.add(lijn.einde);
      punten.add(
        Offset(
          (lijn.start.dx + lijn.einde.dx) / 2,
          (lijn.start.dy + lijn.einde.dy) / 2,
        ),
      );
    }

    return uniekePunten(punten);
  }

  static List<Offset> uniekePunten(List<Offset> punten) {
    final uniek = <Offset>[];

    for (final punt in punten) {
      final bestaat = uniek.any((p) => (p - punt).distance < 0.5);
      if (!bestaat) uniek.add(punt);
    }

    return uniek;
  }

  static Offset? dichtsteSnappunt({
    required Offset punt,
    required List<Offset> snappunten,
    double snapAfstand = 46,
  }) {
    Offset? beste;
    var besteAfstand = double.infinity;

    for (final p in snappunten) {
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
}
