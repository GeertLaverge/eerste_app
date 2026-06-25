import 'package:flutter/material.dart';

class OpmetingRaamTStijl {
  const OpmetingRaamTStijl({
    required this.id,
    required this.start,
    required this.einde,
    this.breedteMm = 90,
  });

  final String id;
  final Offset start;
  final Offset einde;
  final double breedteMm;
}
