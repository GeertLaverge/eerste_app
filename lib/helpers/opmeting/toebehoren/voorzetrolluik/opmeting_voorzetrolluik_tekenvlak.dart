// THIMACO-CONTROLE: VOORZETROLLUIK-TEKENVLAK-FASE-1-20260731
import 'package:flutter/material.dart';

import 'opmeting_voorzetrolluik_model.dart';
import 'opmeting_voorzetrolluik_painter.dart';

class OpmetingVoorzetrolluikTekenvlak extends StatelessWidget {
  const OpmetingVoorzetrolluikTekenvlak({super.key, required this.model});

  final OpmetingVoorzetrolluikModel model;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: OpmetingVoorzetrolluikPainter(model: model),
        child: const SizedBox.expand(),
      ),
    );
  }
}
