import 'package:flutter/material.dart';

import 'agenda_item.dart';
import 'agenda_kleur_service.dart';

class AgendaItemSymbolenRij extends StatelessWidget {
  final List<AgendaItem> items;

  const AgendaItemSymbolenRij({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final zichtbaar = items.take(5).toList();
    final extra = items.length - zichtbaar.length;

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: [
        ...zichtbaar.map<Widget>((item) {
          return Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: AgendaKleurService.kleur(item.type),
              shape: BoxShape.circle,
            ),
          );
        }),
        if (extra > 0)
          Text(
            '+$extra',
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}
