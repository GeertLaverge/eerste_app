// THIMACO-CONTROLE: SEKTIONALE-POORTEN-TEKENVLAK-UNIFORM-20260729
import 'package:flutter/material.dart';

import 'opmeting_sektionale_poort_model.dart';
import 'opmeting_sektionale_poort_painter.dart';

class OpmetingSektionalePoortTekenvlak extends StatelessWidget {
  const OpmetingSektionalePoortTekenvlak({
    super.key,
    required this.model,
    this.toonKop = true,
    this.toonKader = true,
  });

  final OpmetingSektionalePoortModel model;
  final bool toonKop;
  final bool toonKader;

  @override
  Widget build(BuildContext context) {
    final tekening = ClipRect(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: CustomPaint(
          painter: OpmetingSektionalePoortPainter(model: model),
          child: const SizedBox.expand(),
        ),
      ),
    );

    if (!toonKop && !toonKader) {
      return tekening;
    }

    return Container(
      decoration: toonKader
          ? BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (toonKop)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: toonKader
                    ? const BorderRadius.vertical(top: Radius.circular(11))
                    : BorderRadius.zero,
                border: const Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 3,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Text(
                    'Poortafmetingen ${model.breedteMm} × ${model.hoogteMm} mm',
                    style: const TextStyle(
                      color: Color(0xFF0B7A3B),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Type ${model.modelType.label} · ${model.serie.label}',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(child: tekening),
        ],
      ),
    );
  }
}
