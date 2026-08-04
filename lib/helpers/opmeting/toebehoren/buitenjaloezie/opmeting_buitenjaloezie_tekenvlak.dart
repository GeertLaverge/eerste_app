// THIMACO-CONTROLE: BUITENJALOEZIE-TEKENVLAK-20260803

import 'package:flutter/material.dart';

import 'opmeting_buitenjaloezie_model.dart';
import 'opmeting_buitenjaloezie_painter.dart';

class OpmetingBuitenjaloezieTekenvlak extends StatelessWidget {
  const OpmetingBuitenjaloezieTekenvlak({super.key, required this.model});

  final OpmetingBuitenjaloezieModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F4F6),
      child: ClipRect(
        child: CustomPaint(
          painter: OpmetingBuitenjaloeziePainter(model: model),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
