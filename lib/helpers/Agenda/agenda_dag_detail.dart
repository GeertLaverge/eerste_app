import 'package:flutter/material.dart';

import 'agenda_item.dart';
import 'agenda_kleur_service.dart';

class AgendaDagDetail extends StatelessWidget {
  final DateTime dag;
  final List<AgendaItem> items;
  final Function(AgendaItem item) onItemTap;

  const AgendaDagDetail({
    super.key,
    required this.dag,
    required this.items,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 6, 10, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: items.isEmpty
          ? const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Geen taken vandaag',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: items.map((item) {
                final kleur = AgendaKleurService.kleur(item.type);

                return InkWell(
                  onTap: () => onItemTap(item),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Text(
                          item.tijdTekst.isEmpty ? '--:--' : item.tijdTekst,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: kleur,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.titel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
