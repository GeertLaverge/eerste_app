import 'package:flutter/material.dart';

import '../helpers/Agenda/agenda_top_balk.dart';
import '../helpers/Agenda/agenda_item.dart';
import '../helpers/Agenda/agenda_repository.dart';
import '../helpers/Agenda/agenda_filter_helper.dart';
import '../helpers/Agenda/agenda_filter_state.dart';
import '../helpers/Agenda/agenda_filter_popup.dart';
import '../helpers/Agenda/agenda_datum_helper.dart';
import '../helpers/Agenda/agenda_kleur_service.dart';
import '../helpers/Agenda/agenda_toevoeg_popup.dart';
import '../helpers/Agenda/agenda_in_te_plannen_knop.dart';
import '../helpers/Agenda/agenda_verplaats_service.dart';
import '../helpers/Agenda/agenda_verplaats_state.dart';
import '../helpers/Agenda/agenda_bewerk_service.dart';
import 'home_pagina.dart';
import '../helpers/app_storage.dart';
import '../helpers/Agenda/agenda_sleep_afhandeling.dart';
import '../helpers/Agenda/agenda_sleep_data.dart';

class JaarPlanningPaginaNieuw extends StatefulWidget {
  const JaarPlanningPaginaNieuw({super.key});

  @override
  State<JaarPlanningPaginaNieuw> createState() =>
      _JaarPlanningPaginaNieuwState();
}

class _JaarPlanningPaginaNieuwState extends State<JaarPlanningPaginaNieuw> {
  int jaar = DateTime.now().year;
  DateTime geselecteerdeDag = DateTime.now();

  final ScrollController horizontaleScroll = ScrollController();

  Map<String, List<AgendaItem>> agendaItems = {};
  bool heeftWijzigingen = false;
  AgendaFilterState filters = const AgendaFilterState();
  AgendaVerplaatsState verplaatsState = const AgendaVerplaatsState();
  final maanden = const [
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
  void initState() {
    super.initState();
    laadAlles();
  }

  Future<void> laadAlles() async {
    await laadFilters();
    await laadAgendaItems();
  }

  Future<void> laadFilters() async {
    final waarden = await AppStorage.laadAgendaFilters();

    if (!mounted) return;

    setState(() {
      filters = AgendaFilterState(
        toonPlanning: waarden['planningKlanten'] ?? true,
        toonOpvolging: waarden['opvolging'] ?? true,
        toonNadienst: waarden['nadienst'] ?? true,
        toonAfspraak: waarden['afspraken'] ?? true,
        toonDagtaak: waarden['dagTaken'] ?? true,
        toonVerlof: waarden['vakantie'] ?? true,
        toonKraan: waarden['kraan'] ?? true,
      );
    });
  }

  Future<void> bewaarFilters() async {
    await AppStorage.bewaarAgendaFilters({
      'planningKlanten': filters.toonPlanning,
      'opvolging': filters.toonOpvolging,
      'nadienst': filters.toonNadienst,
      'afspraken': filters.toonAfspraak,
      'dagTaken': filters.toonDagtaak,
      'vakantie': filters.toonVerlof,
      'kraan': filters.toonKraan,
    });
  }

  Future<void> laadAgendaItems() async {
    final geladenItems = await AgendaRepository.laadItems();

    if (!mounted) return;

    setState(() {
      agendaItems = geladenItems;
    });
  }

  Future<void> openFilterMenu() async {
    final nieuweFilters = await AgendaFilterPopup.open(
      context,
      filters,
    );

    if (nieuweFilters == null) return;

    setState(() {
      filters = nieuweFilters;
    });

    await bewaarFilters();
  }

  @override
  void dispose() {
    horizontaleScroll.dispose();
    super.dispose();
  }

  DateTime focusDatum() {
    return DateTime(jaar, 1, 1);
  }

  Future<void> openItem(
    DateTime dag,
    AgendaItem item,
  ) async {
    setState(() {
      geselecteerdeDag = dag;
    });

    final resultaat = await showDialog<Object>(
      context: context,
      builder: (context) {
        return AgendaToevoegPopup(
          bestaandItem: item,
          geplandeItems: agendaItems[AgendaDatumHelper.datumKey(dag)] ?? [],
        );
      },
    );

    if (resultaat == null) return;

    if (resultaat == 'verplaatsen') {
      startVerplaatsen(
        oudeDag: dag,
        item: item,
      );
      return;
    }

    if (resultaat == 'verwijderen') {
      final nieuweItems = await AgendaRepository.verwijder(
        dag: dag,
        item: item,
        itemsPerDag: agendaItems,
      );

      if (!mounted) return;

      setState(() {
        agendaItems = nieuweItems;
        heeftWijzigingen = true;
      });

      return;
    }

    if (resultaat is AgendaItem) {
      final foutmelding = AgendaBewerkService.kanItemBewerken(
        dag: dag,
        oudItem: item,
        nieuwItem: resultaat,
        itemsPerDag: agendaItems,
      );

      if (foutmelding != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(foutmelding),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final nieuweItems = await AgendaRepository.bewerk(
        dag: dag,
        oudItem: item,
        nieuwItem: resultaat,
        itemsPerDag: agendaItems,
      );

      if (!mounted) return;

      setState(() {
        agendaItems = nieuweItems;
        heeftWijzigingen = true;
      });
    }
  }

  Future<void> openToevoegPopup() async {
    final nieuwItem = await showDialog<AgendaItem>(
      context: context,
      builder: (context) {
        return AgendaToevoegPopup(
          geplandeItems:
              agendaItems[AgendaDatumHelper.datumKey(geselecteerdeDag)] ?? [],
        );
      },
    );

    if (nieuwItem == null) return;

    final nieuweItems = await AgendaRepository.voegToe(
      dag: geselecteerdeDag,
      item: nieuwItem,
      itemsPerDag: agendaItems,
    );

    if (!mounted) return;

    setState(() {
      agendaItems = nieuweItems;
      heeftWijzigingen = true;
    });
  }

  void startVerplaatsen({
    required DateTime oudeDag,
    required AgendaItem item,
  }) {
    setState(() {
      verplaatsState = verplaatsState.start(
        oudeDag: oudeDag,
        item: item,
      );
    });
  }

  Future<void> verwerkDropOpDag({
    required DateTime nieuweDag,
    required AgendaItem item,
    required DateTime oudeDag,
  }) async {
    final nieuweItems = await AgendaSleepAfhandeling.verwerkDrop(
      context: context,
      oudeDag: oudeDag,
      nieuweDag: nieuweDag,
      item: item,
      itemsPerDag: agendaItems,
    );

    if (nieuweItems == null) return;
    if (!mounted) return;

    setState(() {
      agendaItems = nieuweItems;
      geselecteerdeDag = nieuweDag;
      heeftWijzigingen = true;
    });
  }

  Widget groeneActieKnop({
    required IconData icoon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          color: Color(0xFF0B7A3B),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icoon,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  int weekNummer(DateTime datum) {
    final donderdag = datum.add(
      Duration(days: 4 - datum.weekday),
    );

    final eersteDonderdag = DateTime(
      donderdag.year,
      1,
      4,
    );

    return 1 + donderdag.difference(eersteDonderdag).inDays ~/ 7;
  }

  double maandBreedte(int maand) {
    const minimum = 150.0;
    const maximum = 900.0;

    double breedsteDag = minimum;

    final aantalDagen = DateTime(
      jaar,
      maand + 1,
      0,
    ).day;

    for (int dag = 1; dag <= aantalDagen; dag++) {
      final datum = DateTime(
        jaar,
        maand,
        dag,
      );

      final key = AgendaDatumHelper.datumKey(datum);
      final items = agendaItems[key] ?? [];

      final zichtbaar = AgendaFilterHelper.gefilterdeItems(
            itemsPerDag: {key: items},
            toonPlanning: filters.toonPlanning,
            toonOpvolging: filters.toonOpvolging,
            toonNadienst: filters.toonNadienst,
            toonAfspraak: filters.toonAfspraak,
            toonDagtaak: filters.toonDagtaak,
            toonVerlof: filters.toonVerlof,
            toonKraan: filters.toonKraan,
          )[key] ??
          [];

      double rijBreedte = 28;

      for (final item in zichtbaar) {
        final tekst = '${item.tijdTekst} ${item.titel}';

        rijBreedte += 14 + (tekst.length * 4.4);
      }

      if (rijBreedte > breedsteDag) {
        breedsteDag = rijBreedte;
      }
    }

    return breedsteDag.clamp(
      minimum,
      maximum,
    );
  }

  Widget maandKolom(int maand) {
    final eersteDag = DateTime(jaar, maand, 1);
    final aantalDagen = DateTime(jaar, maand + 1, 0).day;

    return Container(
      width: maandBreedte(maand),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            height: 38,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFE7F6EC),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(18),
              ),
            ),
            child: Text(
              maanden[maand - 1],
              style: const TextStyle(
                color: Color(0xFF0B7A3B),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(
            height: 1428,
            child: Column(
              children: List.generate(42, (index) {
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
                    : agendaItems[datumKey] ?? [];

                final zichtbareItems = AgendaFilterHelper.gefilterdeItems(
                      itemsPerDag: {
                        if (datumKey != null) datumKey: items,
                      },
                      toonPlanning: filters.toonPlanning,
                      toonOpvolging: filters.toonOpvolging,
                      toonNadienst: filters.toonNadienst,
                      toonAfspraak: filters.toonAfspraak,
                      toonDagtaak: filters.toonDagtaak,
                      toonVerlof: filters.toonVerlof,
                      toonKraan: filters.toonKraan,
                    )[datumKey] ??
                    [];

                return SizedBox(
                  height: 34,
                  child: DragTarget<AgendaSleepData>(
                    onWillAcceptWithDetails: (details) {
                      return datum != null;
                    },
                    onAcceptWithDetails: (details) async {
                      if (datum == null) return;

                      await verwerkDropOpDag(
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
                            : () {
                                setState(() {
                                  geselecteerdeDag = datum;
                                });
                              },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                          ),
                          color: isHover
                              ? const Color(0xFFE7F6EC)
                              : isWeekend
                                  ? const Color(0xFFEAEAEA)
                                  : Colors.white,
                          child: Stack(
                            children: [
                              if (bestaatDag)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
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
                                        fontWeight: isGeselecteerd || isVandaag
                                            ? FontWeight.w800
                                            : FontWeight.w700,
                                        fontSize: isGeselecteerd
                                            ? 13
                                            : isVandaag
                                                ? 13
                                                : 12,
                                      ),
                                    ),
                                  ),
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
                                                color: AgendaKleurService
                                                    .achtergrond(
                                                  item.type,
                                                ),
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
                                              child: Text(
                                                '${item.tijdTekst.isEmpty ? '--:--' : item.tijdTekst} ${item.titel}',
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          ),
                                          childWhenDragging: Opacity(
                                            opacity: 0.35,
                                            child: jaarItemBlok(item),
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              if (datum == null) return;

                                              openItem(
                                                datum,
                                                item,
                                              );
                                            },
                                            child: jaarItemBlok(item),
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

  Widget jaarItemBlok(AgendaItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AgendaKleurService.achtergrond(item.type),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.tijdTekst.isEmpty ? '--:--' : item.tijdTekst,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            item.titel,
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          AgendaTopBalk(
            focusMaand: focusDatum(),
            onTerug: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
            onVorigeMaand: () {
              setState(() {
                jaar--;
              });
            },
            onVolgendeMaand: () {
              setState(() {
                jaar++;
              });
            },
            onToevoegen: openToevoegPopup,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
              child: Scrollbar(
                controller: horizontaleScroll,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: horizontaleScroll,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      12,
                      (index) => maandKolom(index + 1),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              color: const Color(0xFFF5F5F5),
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  groeneActieKnop(
                    icoon: Icons.filter_alt,
                    onTap: openFilterMenu,
                  ),
                  const SizedBox(width: 8),
                  groeneActieKnop(
                    icoon: Icons.schedule,
                    onTap: () {
                      AgendaInTePlannenKnop(
                        items: agendaItems.values.expand((e) => e).toList(),
                      ).openMenu(context);
                    },
                  ),
                  const SizedBox(width: 8),
                  groeneActieKnop(
                    icoon: Icons.view_agenda_outlined,
                    onTap: () {
                      Navigator.pop(context, heeftWijzigingen);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
