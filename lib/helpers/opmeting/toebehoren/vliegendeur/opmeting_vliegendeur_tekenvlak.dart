import 'package:flutter/material.dart';

import '../../../ui/thimaco_huisstijl.dart';
import 'opmeting_vliegendeur_model.dart';
import 'opmeting_vliegendeur_painter.dart';

class OpmetingVliegendeurTekenvlak extends StatelessWidget {
  const OpmetingVliegendeurTekenvlak({
    super.key,
    required this.model,
    this.schaalFactor = 1.0,
  });

  final OpmetingVliegendeurModel model;
  final double schaalFactor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThimacoKleuren.rand),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: OpmetingVliegendeurPainter(
          model: model,
          schaalFactor: schaalFactor,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
