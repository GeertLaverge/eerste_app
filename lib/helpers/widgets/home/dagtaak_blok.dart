import 'package:flutter/material.dart';

import '../../../modellen/agenda_actie.dart';
import 'dagtaak_rij.dart';

class DagtaakBlok extends StatelessWidget {
  final List<AgendaActie> taken;
  final void Function(AgendaActie actie) onTapActie;
  final void Function(AgendaActie actie) onAfvinken;
  final VoidCallback onTapAgenda;

  const DagtaakBlok({
    super.key,
    required this.taken,
    required this.onTapActie,
    required this.onAfvinken,
    required this.onTapAgenda,
  });

  @override
  Widget build(BuildContext context) {
    final openTaken = taken.where((actie) => !actie.isAfgewerkt).toList();
    final afgewerkteTaken = taken.where((actie) => actie.isAfgewerkt).toList();

    final gesorteerdeTaken = [
      ...openTaken,
      ...afgewerkteTaken,
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.task_alt, size: 18, color: Colors.green),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  'Dagtaak',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${openTaken.length} open',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (taken.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Geen dagtaken vandaag',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            )
          else
            ...gesorteerdeTaken.map(
              (actie) => DagtaakRij(
                actie: actie,
                onTap: () => onTapActie(actie),
                onAfvinken: () => onAfvinken(actie),
              ),
            ),
        ],
      ),
    );
  }
}
