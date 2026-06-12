import 'package:flutter/material.dart';

import 'agenda_datum_helper.dart';
import 'agenda_filter_helper.dart';
import 'agenda_filter_state.dart';
import 'agenda_item.dart';
import 'agenda_jaar_item_blok.dart';
import 'agenda_sleep_data.dart';

class AgendaJaarMaandKolom extends StatelessWidget {
  const AgendaJaarMaandKolom({
    super.key,
    required this.maand,
    required this.agendaItemsData,
    required this.actieveFilters,
    required this.jaar,
    required this.geselecteerdeDag,
    required this.maandBreedte,
    required this.onDagGeselecteerd,
    required this.weekNummer,
    required this.onItemOpenen,
    required this.onDropOpDag,
  });

  final int maand;
  final Map<String, List<AgendaItem>> agendaItemsData;
  final AgendaFilterState actieveFilters;
  final int jaar;
  final DateTime geselecteerdeDag;

  final double Function(
    int maand,
    Map<String, List<AgendaItem>> agendaItemsData,
    AgendaFilterState actieveFilters,
  ) maandBreedte;

  final void Function(DateTime dag) onDagGeselecteerd;
  final int Function(DateTime datum) weekNummer;
  final void Function(DateTime dag, AgendaItem item) onItemOpenen;

  final Future<void> Function({
    required DateTime nieuweDag,
    required AgendaItem item,
    required DateTime oudeDag,
  }) onDropOpDag;

  static const List<String> maandNamen = [
    'Januari',
    'Februari',
    'Maart',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Augustus',
    'September',
    'Oktober',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: maandBreedte(
        maand,
        agendaItemsData,
        actieveFilters,
      ),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          SizedBox(
            height: 1428,
            child: Column(
              children: List.generate(42, (index) {
                final eersteDag = DateTime(jaar, maand, 1);
                final aantalDagen = DateTime(jaar, maand + 1, 0).day;

                final weekDagIndex = index % 7;
                final isWeekend = weekDagIndex == 5 || weekDagIndex == 6;

                final dagNummer = index - (eersteDag.weekday - 1) + 1;
                final bestaatDag = dagNummer >= 1 && dagNummer <= aantalDagen;

                final datum =
                    bestaatDag ? DateTime(jaar, maand, dagNummer) : null;

                final isVandaag =
                    datum != null && AgendaDatumHelper.isVandaag(datum);

                final isGeselecteerd = datum != null &&
                    AgendaDatumHelper.zelfdeDag(
                      datum,
                      geselecteerdeDag,
                    );

                final datumKey =
                    datum == null ? null : AgendaDatumHelper.datumKey(datum);

                final items = datumKey == null
                    ? <AgendaItem>[]
                    : (agendaItemsData[datumKey] ?? [])
                        .where((item) => !item.isVerwijderd)
                        .toList();

                final zichtbareItems = AgendaFilterHelper.gefilterdeItems(
                      itemsPerDag: {
                        if (datumKey != null) datumKey: items,
                      },
                      toonPlanning: actieveFilters.toonPlanning,
                      toonOpvolging: actieveFilters.toonOpvolging,
                      toonNadienst: actieveFilters.toonNadienst,
                      toonAfspraak: actieveFilters.toonAfspraak,
                      toonDagtaak: actieveFilters.toonDagtaak,
                      toonVerlof: actieveFilters.toonVerlof,
                      toonKraan: actieveFilters.toonKraan,
                    )[datumKey] ??
                    [];

                return SizedBox(
                  height: 34,
                  child: DragTarget<AgendaSleepData>(
                    onWillAcceptWithDetails: (details) {
                      return datum != null;
                    },
                    onMove: (details) {},
                    onAcceptWithDetails: (details) async {
                      if (datum == null) return;

                      await onDropOpDag(
                        nieuweDag: datum,
                        item: details.data.item,
                        oudeDag: details.data.oudeDag,
                      );
                    },
                    builder: (context, kandidaat, geweigerd) {
                      final isHover = kandidaat.isNotEmpty;

                      return InkWell(
                        onTap: datum == null
                            ? null
                            : () => onDagGeselecteerd(datum),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          color: isHover
                              ? const Color(0xFFE7F6EC)
                              : isWeekend
                                  ? const Color(0xFFEAEAEA)
                                  : Colors.white,
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: bestaatDag
                                    ? Container(
                                        width: 24,
                                        height: 24,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: isGeselecteerd
                                              ? const Color(0xFF0B7A3B)
                                              : Colors.transparent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '$dagNummer',
                                          style: TextStyle(
                                            color: isGeselecteerd
                                                ? Colors.white
                                                : isVandaag
                                                    ? const Color(0xFF0B7A3B)
                                                    : Colors.black87,
                                            fontWeight:
                                                isGeselecteerd || isVandaag
                                                    ? FontWeight.w800
                                                    : FontWeight.w700,
                                            fontSize: isGeselecteerd
                                                ? 13
                                                : isVandaag
                                                    ? 13
                                                    : 12,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              if (zichtbareItems.isNotEmpty)
                                Positioned(
                                  left: 26,
                                  right: 2,
                                  top: 4,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: zichtbareItems.map((item) {
                                        return LongPressDraggable<
                                            AgendaSleepData>(
                                          data: AgendaSleepData(
                                            oudeDag: datum!,
                                            item: item,
                                          ),
                                          feedback: Material(
                                            color: Colors.transparent,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE7F6EC),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.black26,
                                                    blurRadius: 8,
                                                    offset: Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: JaarItemBlok(
                                                item: item,
                                              ),
                                            ),
                                          ),
                                          childWhenDragging: Opacity(
                                            opacity: 0.35,
                                            child: JaarItemBlok(
                                              item: item,
                                            ),
                                          ),
                                          child: InkWell(
                                            onTap: datum == null
                                                ? null
                                                : () => onItemOpenen(
                                                      datum,
                                                      item,
                                                    ),
                                            child: JaarItemBlok(
                                              item: item,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              if (datum != null && datum.weekday == 7)
                                Positioned(
                                  right: 2,
                                  bottom: 2,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.black87,
                                        width: 1.4,
                                      ),
                                    ),
                                    child: Text(
                                      '${weekNummer(datum)}',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
