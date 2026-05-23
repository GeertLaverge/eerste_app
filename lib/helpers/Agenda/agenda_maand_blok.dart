import 'package:flutter/material.dart';

import 'agenda_datum_helper.dart';
import 'agenda_item.dart';
import 'agenda_week_rij.dart';
import 'agenda_weergave_type.dart';

class AgendaMaandBlok extends StatelessWidget {
  final DateTime maand;
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

  const AgendaMaandBlok({
    super.key,
    required this.maand,
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
    final weken = AgendaDatumHelper.wekenVanMaand(maand);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 8,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AgendaDatumHelper.maandTitel(maand),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        ...weken.map<Widget>((weekStart) {
          return AgendaWeekRij(
            maand: maand,
            weekStart: weekStart,
            geselecteerdeDag: geselecteerdeDag,
            itemsPerDag: itemsPerDag,
            weergave: weergave,
            onDagKlik: onDagKlik,
            onItemTap: onItemTap,
            onItemSleep: onItemSleep,
            onItemDrop: onItemDrop,
          );
        }),
      ],
    );
  }
}
