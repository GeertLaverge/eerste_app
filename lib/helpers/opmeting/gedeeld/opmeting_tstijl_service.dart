import 'package:flutter/material.dart';

import 'opmeting_teken_model.dart';

class OpmetingTStijlService {
  static const double standaardBreedteMm = 90;

  static Rect binnenKader({
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
    double kaderOffsetMm = 70,
  }) {
    final offsetX = (buitenKader.width / breedteMm) * kaderOffsetMm;
    final offsetY = (buitenKader.height / hoogteMm) * kaderOffsetMm;

    return Rect.fromLTRB(
      buitenKader.left + offsetX,
      buitenKader.top + offsetY,
      buitenKader.right - offsetX,
      buitenKader.bottom - offsetY,
    );
  }

  static List<Offset> kandidaatSnappunten({
    required OpmetingTStijlInstellingen instellingen,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
    required List<OpmetingTStijl> bestaandeTStijlen,
  }) {
    final binnen = binnenKader(
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    final punten = <Offset>[];

    if (instellingen.richting == 'verticaal') {
      final x = _positiePx(
        instellingen: instellingen,
        buitenKader: buitenKader,
        breedteMm: breedteMm,
        hoogteMm: hoogteMm,
      );

      final horizontaleStops = _horizontaleStopLijnen(
        binnen: binnen,
        hoogteMm: hoogteMm,
        bestaandeTStijlen: bestaandeTStijlen,
      );

      for (final y in horizontaleStops) {
        punten.add(Offset(x, y));
      }
    } else {
      final y = _positiePx(
        instellingen: instellingen,
        buitenKader: buitenKader,
        breedteMm: breedteMm,
        hoogteMm: hoogteMm,
      );

      final verticaleStops = _verticaleStopLijnen(
        binnen: binnen,
        breedteMm: breedteMm,
        bestaandeTStijlen: bestaandeTStijlen,
      );

      for (final x in verticaleStops) {
        punten.add(Offset(x, y));
      }
    }

    return _uniekePunten(punten);
  }

  static OpmetingTStijl? maakTStijlVanafSnappunt({
    required Offset snappunt,
    required OpmetingTStijlInstellingen instellingen,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
    required List<OpmetingTStijl> bestaandeTStijlen,
  }) {
    final binnen = binnenKader(
      buitenKader: buitenKader,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    if (instellingen.richting == 'verticaal') {
      final horizontaleStops = _horizontaleStopLijnen(
        binnen: binnen,
        hoogteMm: hoogteMm,
        bestaandeTStijlen: bestaandeTStijlen,
      );

      final naarBeneden = _moetNaarBeneden(
        snappuntY: snappunt.dy,
        binnen: binnen,
      );

      final eindY = _volgendeStop(
        vanaf: snappunt.dy,
        vooruit: naarBeneden,
        stops: horizontaleStops,
      );

      return OpmetingTStijl(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        richting: 'verticaal',
        start: snappunt,
        einde: Offset(snappunt.dx, eindY),
      );
    }

    final verticaleStops = _verticaleStopLijnen(
      binnen: binnen,
      breedteMm: breedteMm,
      bestaandeTStijlen: bestaandeTStijlen,
    );

    final naarRechts = _moetNaarRechts(
      snappuntX: snappunt.dx,
      binnen: binnen,
    );

    final eindX = _volgendeStop(
      vanaf: snappunt.dx,
      vooruit: naarRechts,
      stops: verticaleStops,
    );

    return OpmetingTStijl(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      richting: 'horizontaal',
      start: snappunt,
      einde: Offset(eindX, snappunt.dy),
    );
  }

  static double _positiePx({
    required OpmetingTStijlInstellingen instellingen,
    required Rect buitenKader,
    required int breedteMm,
    required int hoogteMm,
  }) {
    if (instellingen.richting == 'verticaal') {
      final positieMm = _positieMm(
        instellingen: instellingen,
        totaalMm: breedteMm.toDouble(),
      );

      final afstandPx = buitenKader.width * (positieMm / breedteMm);

      return instellingen.vanaf == 'links'
          ? buitenKader.left + afstandPx
          : buitenKader.right - afstandPx;
    }

    final positieMm = _positieMm(
      instellingen: instellingen,
      totaalMm: hoogteMm.toDouble(),
    );

    final afstandPx = buitenKader.height * (positieMm / hoogteMm);

    return instellingen.vanaf == 'boven'
        ? buitenKader.top + afstandPx
        : buitenKader.bottom - afstandPx;
  }

  static double _positieMm({
    required OpmetingTStijlInstellingen instellingen,
    required double totaalMm,
  }) {
    switch (instellingen.positieType) {
      case '1/2':
      case '2/4':
        return totaalMm / 2;
      case '1/3':
        return totaalMm / 3;
      case '2/3':
        return totaalMm * 2 / 3;
      case '1/4':
        return totaalMm / 4;
      case '3/4':
        return totaalMm * 3 / 4;
      case 'mm':
      default:
        return instellingen.positieMm;
    }
  }

  static List<double> _horizontaleStopLijnen({
    required Rect binnen,
    required int hoogteMm,
    required List<OpmetingTStijl> bestaandeTStijlen,
  }) {
    final stops = <double>[
      binnen.top,
      binnen.bottom,
    ];

    for (final stijl in bestaandeTStijlen) {
      if (stijl.richting == 'horizontaal') {
        final randen = _horizontaleTStijlRanden(
          stijl: stijl,
          binnen: binnen,
          hoogteMm: hoogteMm,
        );

        stops.add(randen.$1);
        stops.add(randen.$2);
      }
    }

    stops.sort();
    return _uniekeGetallen(stops);
  }

  static List<double> _verticaleStopLijnen({
    required Rect binnen,
    required int breedteMm,
    required List<OpmetingTStijl> bestaandeTStijlen,
  }) {
    final stops = <double>[
      binnen.left,
      binnen.right,
    ];

    for (final stijl in bestaandeTStijlen) {
      if (stijl.richting == 'verticaal') {
        final randen = _verticaleTStijlRanden(
          stijl: stijl,
          binnen: binnen,
          breedteMm: breedteMm,
        );

        stops.add(randen.$1);
        stops.add(randen.$2);
      }
    }

    stops.sort();
    return _uniekeGetallen(stops);
  }

  static bool _moetNaarBeneden({
    required double snappuntY,
    required Rect binnen,
  }) {
    return (snappuntY - binnen.top).abs() < (snappuntY - binnen.bottom).abs();
  }

  static bool _moetNaarRechts({
    required double snappuntX,
    required Rect binnen,
  }) {
    return (snappuntX - binnen.left).abs() < (snappuntX - binnen.right).abs();
  }

  static double _volgendeStop({
    required double vanaf,
    required bool vooruit,
    required List<double> stops,
  }) {
    if (vooruit) {
      for (final stop in stops) {
        if (stop > vanaf + 1) return stop;
      }

      return stops.last;
    }

    for (final stop in stops.reversed) {
      if (stop < vanaf - 1) return stop;
    }

    return stops.first;
  }

  static (double, double) _horizontaleTStijlRanden({
    required OpmetingTStijl stijl,
    required Rect binnen,
    required int hoogteMm,
  }) {
    final halveBreedteMm = stijl.breedteMm / 2;
    final halveBreedtePx = (binnen.height / hoogteMm) * halveBreedteMm;

    return (
      stijl.start.dy - halveBreedtePx,
      stijl.start.dy + halveBreedtePx,
    );
  }

  static (double, double) _verticaleTStijlRanden({
    required OpmetingTStijl stijl,
    required Rect binnen,
    required int breedteMm,
  }) {
    final halveBreedteMm = stijl.breedteMm / 2;
    final halveBreedtePx = (binnen.width / breedteMm) * halveBreedteMm;

    return (
      stijl.start.dx - halveBreedtePx,
      stijl.start.dx + halveBreedtePx,
    );
  }

  static List<Offset> _uniekePunten(List<Offset> punten) {
    final uniek = <Offset>[];

    for (final punt in punten) {
      final bestaat = uniek.any((p) => (p - punt).distance < 0.5);

      if (!bestaat) {
        uniek.add(punt);
      }
    }

    return uniek;
  }

  static List<double> _uniekeGetallen(List<double> waarden) {
    final uniek = <double>[];

    for (final waarde in waarden) {
      final bestaat = uniek.any((v) => (v - waarde).abs() < 0.5);

      if (!bestaat) {
        uniek.add(waarde);
      }
    }

    return uniek;
  }
}
