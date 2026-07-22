import 'package:flutter/material.dart';

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
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAF9),
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$maatTitel ',
                    style: const TextStyle(
                      color: Color(0xFF0B7A3B),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(
                    text: model.maatSamenvatting,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
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
