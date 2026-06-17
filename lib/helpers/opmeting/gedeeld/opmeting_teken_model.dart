import 'package:flutter/material.dart';

class OpmetingLijn {
  const OpmetingLijn({
    required this.id,
    required this.start,
    required this.einde,
  });

  final String id;
  final Offset start;
  final Offset einde;
}

class OpmetingDriehoek {
  const OpmetingDriehoek({
    required this.punt1,
    required this.punt2,
    required this.punt3,
  });

  final Offset punt1;
  final Offset punt2;
  final Offset punt3;
}

class OpmetingTStijl {
  const OpmetingTStijl({
    required this.id,
    required this.richting,
    required this.start,
    required this.einde,
    this.breedteMm = 90,
  });

  final String id;

  // 'verticaal' of 'horizontaal'
  final String richting;

  final Offset start;
  final Offset einde;

  // standaard 90 mm profielbreedte
  final double breedteMm;
}

class OpmetingTStijlInstellingen {
  const OpmetingTStijlInstellingen({
    required this.richting,
    required this.vanaf,
    required this.positieType,
    required this.positieMm,
  });

  // 'verticaal' of 'horizontaal'
  final String richting;

  // bij verticaal: 'links' of 'rechts'
  // bij horizontaal: 'boven' of 'onder'
  final String vanaf;

  // 'mm', '1/2', '1/3', '2/3', '1/4', '2/4', '3/4'
  final String positieType;

  final double positieMm;
}
