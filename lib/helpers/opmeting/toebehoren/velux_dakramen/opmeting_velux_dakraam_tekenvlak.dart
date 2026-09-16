// THIMACO-CONTROLE: VELUX-HUISSTIJL-20260914
// THIMACO-CONTROLE: VELUX-TEKENVLAK-FASE-1-2-20260729-2030
import 'package:flutter/material.dart';

import '../../../ui/thimaco_huisstijl.dart';
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
        border: Border.all(color: ThimacoKleuren.rand),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: ThimacoKleuren.rand),
              ),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.roofing_outlined,
                  size: 16,
                  color: ThimacoKleuren.oranje,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    titel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ThimacoKleuren.antraciet,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
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
