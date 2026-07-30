// THIMACO-CONTROLE: VELUX-TEKENVLAK-FASE-1-2-20260729-2030
import 'package:flutter/material.dart';

import 'opmeting_velux_dakraam_model.dart';
import 'opmeting_velux_dakraam_painter.dart';

class OpmetingVeluxDakraamTekenvlak extends StatelessWidget {
  const OpmetingVeluxDakraamTekenvlak({super.key, required this.model});

  final OpmetingVeluxDakraamModel model;

  @override
  Widget build(BuildContext context) {
    final titel = model.alleenToebehoren
        ? 'Velux accessoires'
        : 'Velux ${model.productCode} ${model.maatCode} · ${model.afmetingLabel}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Text(
              titel,
              style: const TextStyle(
                color: Color(0xFF0B7A3B),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: CustomPaint(
              painter: OpmetingVeluxDakraamPainter(model: model),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}
