// THIMACO-CONTROLE: SCHUIFVLIEGENDEUR-TEKENVLAK-MET-PAINTER-20260728
import 'package:flutter/material.dart';

import 'opmeting_schuifvliegendeur_model.dart';
import 'opmeting_schuifvliegendeur_painter.dart';

class OpmetingSchuifvliegendeurTekenvlak extends StatelessWidget {
  const OpmetingSchuifvliegendeurTekenvlak({
    super.key,
    required this.model,
    this.schaalFactor = 1.0,
  });

  final OpmetingSchuifvliegendeurModel model;
  final double schaalFactor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: OpmetingSchuifvliegendeurPainter(
          model: model,
          schaalFactor: schaalFactor,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
