// THIMACO-CONTROLE: SEKTIONALE-POORTEN-TEKENVLAK-UNIFORM-20260729
import 'package:flutter/material.dart';

import '../../../ui/thimaco_huisstijl.dart';
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
              border: Border.all(color: ThimacoKleuren.rand),
            )
          : null,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (toonKop)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: toonKader
                    ? const BorderRadius.vertical(top: Radius.circular(11))
                    : BorderRadius.zero,
                border: const Border(
                  bottom: BorderSide(color: ThimacoKleuren.rand),
                ),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.straighten_rounded,
                    size: 16,
                    color: ThimacoKleuren.oranje,
                  ),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Text(
                          'Poortafmetingen ${model.breedteMm} × ${model.hoogteMm} mm',
                          style: const TextStyle(
                            color: ThimacoKleuren.antraciet,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Type ${model.modelType.label} · ${model.serie.label}',
                          style: const TextStyle(
                            color: ThimacoKleuren.tekstGrijs,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
