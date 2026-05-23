import 'package:flutter/material.dart';

import '../../../services/home_service.dart';
import 'planning_rij.dart';

class DagplanningBlok extends StatelessWidget {
  final List<DagPlanningItem> items;
  final void Function(DagPlanningItem) onTapPlanning;
  final VoidCallback onTapAgenda;

  const DagplanningBlok({
    super.key,
    required this.items,
    required this.onTapPlanning,
    required this.onTapAgenda,
  });

  @override
  Widget build(BuildContext context) {
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
              const Icon(Icons.calendar_month, size: 18, color: Colors.green),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  'Planning plaatsers',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${items.length} gepland',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Geen planning vandaag',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            )
          else
            ...items.map(
              (item) => PlanningRij(
                item: item,
                onTapKlant: (_) => onTapPlanning(item),
              ),
            ),
        ],
      ),
    );
  }
}
