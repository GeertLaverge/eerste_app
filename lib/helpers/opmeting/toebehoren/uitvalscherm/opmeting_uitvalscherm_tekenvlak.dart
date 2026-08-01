import 'package:flutter/material.dart';

import 'opmeting_uitvalscherm_model.dart';
import 'opmeting_uitvalscherm_painter.dart';

class OpmetingUitvalschermTekenvlak extends StatelessWidget {
  const OpmetingUitvalschermTekenvlak({super.key, required this.model});

  final OpmetingUitvalschermModel model;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ColoredBox(
        color: Colors.white,
        child: CustomPaint(
          painter: OpmetingUitvalschermPainter(model: model),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
