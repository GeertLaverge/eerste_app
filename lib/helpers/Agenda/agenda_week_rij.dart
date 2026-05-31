import 'package:flutter/material.dart';

import 'agenda_dag_cel.dart';
import 'agenda_datum_helper.dart';
import 'agenda_item.dart';
import 'agenda_weergave_type.dart';

class AgendaWeekRij extends StatelessWidget {
  final DateTime maand;
  final DateTime weekStart;
  final DateTime geselecteerdeDag;
  final Map<String, List<AgendaItem>> itemsPerDag;
  final AgendaWeergaveType weergave;

  final Function(DateTime dag) onDagKlik;
  final Function(DateTime dag, AgendaItem item) onItemTap;
  final Function(DateTime dag, AgendaItem item) onItemSleep;

  final Function(
    DateTime nieuweDag,
    AgendaItem item,
    DateTime oudeDag,
  ) onItemDrop;

  const AgendaWeekRij({
    super.key,
    required this.maand,
    required this.weekStart,
    required this.geselecteerdeDag,
    required this.itemsPerDag,
    required this.weergave,
    required this.onDagKlik,
    required this.onItemTap,
    required this.onItemSleep,
    required this.onItemDrop,
  });

  @override
  Widget build(BuildContext context) {
    final dagen = List.generate(
      7,
      (index) => weekStart.add(
        Duration(days: index),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: dagen.map<Widget>((dag) {
          final andereMaand =
              dag.month != maand.month || dag.year != maand.year;

          if (andereMaand) {
            return Expanded(
              child: SizedBox(
                height: weergave == AgendaWeergaveType.symbolen ? 70 : 102,
              ),
            );
          }

          final geselecteerd = AgendaDatumHelper.zelfdeDag(
            dag,
            geselecteerdeDag,
          );

          final isVandaag = AgendaDatumHelper.isVandaag(dag);
          final isWeekend = dag.weekday == 6 || dag.weekday == 7;

          final key = AgendaDatumHelper.datumKey(dag);
          final items = itemsPerDag[key] ?? [];

          return AgendaDagCel(
            dag: dag,
            geselecteerd: geselecteerd,
            andereMaand: false,
            isVandaag: isVandaag,
            isWeekend: isWeekend,
            items: items,
            weergave: weergave,
            onTap: () {
              onDagKlik(dag);
            },
            onItemTap: (item) {
              onItemTap(dag, item);
            },
            onItemSleep: (item) {
              onItemSleep(dag, item);
            },
            onItemDrop: onItemDrop,
          );
        }).toList(),
      ),
    );
  }
}
