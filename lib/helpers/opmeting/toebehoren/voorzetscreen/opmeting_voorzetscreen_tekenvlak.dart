// THIMACO-CONTROLE: VOORZETSCREEN-TEKENVLAK-FASE-1-20260730
import 'package:flutter/material.dart';

import 'opmeting_voorzetscreen_model.dart';
import 'opmeting_voorzetscreen_painter.dart';

class OpmetingVoorzetscreenTekenvlak extends StatelessWidget {
  const OpmetingVoorzetscreenTekenvlak({super.key, required this.model});

  final OpmetingVoorzetscreenModel model;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: CustomPaint(
        painter: OpmetingVoorzetscreenPainter(model: model),
        child: const SizedBox.expand(),
      ),
    );
  }
}
