// THIMACO-CONTROLE: PLOOIWERKEN-TEKENVLAK-MODEL-PARAMETER-HERSTEL-20260728-1735
import 'package:flutter/material.dart';

import 'opmeting_plooiwerken_model.dart';
import 'opmeting_plooiwerken_painter.dart';

class OpmetingPlooiwerkenTekenvlak extends StatelessWidget {
  const OpmetingPlooiwerkenTekenvlak({super.key, required this.model});

  final OpmetingPlooiwerkenModel model;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: CustomPaint(
        painter: OpmetingPlooiwerkenPainter(model: model),
        child: const SizedBox.expand(),
      ),
    );
  }
}
