import 'package:flutter/material.dart';

import '../../../ui/thimaco_huisstijl.dart';
import 'opmeting_vaste_inzethor_model.dart';
import 'opmeting_vaste_inzethor_painter.dart';

class OpmetingVasteInzethorTekenvlak extends StatelessWidget {
  const OpmetingVasteInzethorTekenvlak({
    super.key,
    required this.model,
    this.schaalFactor = 1.0,
  });

  final OpmetingVasteInzethorModel model;
  final double schaalFactor;

  @override
  Widget build(BuildContext context) {
    final maatTitel = model.isBinnenmaat
        ? 'Binnenmaat/doorkijkmaat'
        : 'Buitenmaat';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThimacoKleuren.rand),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
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
                  Icons.straighten_rounded,
                  size: 16,
                  color: ThimacoKleuren.oranje,
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: '$maatTitel ',
                          style: const TextStyle(
                            color: ThimacoKleuren.tekstGrijs,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: model.maatSamenvatting,
                          style: const TextStyle(
                            color: ThimacoKleuren.antraciet,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomPaint(
              painter: OpmetingVasteInzethorPainter(
                model: model,
                schaalFactor: schaalFactor,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}
