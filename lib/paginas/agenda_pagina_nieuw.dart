import 'package:flutter/material.dart';

import '../helpers/app_storage.dart';
import '../helpers/Agenda/agenda_bewerk_service.dart';
import '../helpers/Agenda/agenda_dag_detail.dart';
import '../helpers/Agenda/agenda_datum_helper.dart';
import '../helpers/Agenda/agenda_filter_helper.dart';
import '../helpers/Agenda/agenda_filter_popup.dart';
import '../helpers/Agenda/agenda_filter_state.dart';
import '../helpers/Agenda/agenda_in_te_plannen_knop.dart';
import '../helpers/Agenda/agenda_item.dart';
import '../helpers/Agenda/agenda_maand_blok.dart';
import '../helpers/Agenda/agenda_repository.dart';
import '../helpers/Agenda/agenda_selectie_state.dart';
import '../helpers/Agenda/agenda_sleep_afhandeling.dart';
import '../helpers/Agenda/agenda_toevoeg_popup.dart';
import '../helpers/Agenda/agenda_toevoeg_service.dart';
import '../helpers/Agenda/agenda_top_balk.dart';
import '../helpers/Agenda/agenda_verplaats_balk.dart';
import '../helpers/Agenda/agenda_verplaats_service.dart';
import '../helpers/Agenda/agenda_verplaats_state.dart';
import '../helpers/Agenda/agenda_weekdag_balk.dart';
import '../helpers/Agenda/agenda_weergave_type.dart';
import 'jaar_planning_pagina_nieuw.dart';

class AgendaPaginaNieuw extends StatefulWidget {
  const AgendaPaginaNieuw({super.key});

  @override
  State<AgendaPaginaNieuw> createState() => _AgendaPaginaNieuwState();
}

class _AgendaPaginaNieuwState extends State<AgendaPaginaNieuw> {
  AgendaSelectieState selectie = AgendaSelectieState.nieuw();

  AgendaFilterState filters = const AgendaFilterState();
  AgendaVerplaatsState verplaatsState = const AgendaVerplaatsState();

  Map<String, List<AgendaItem>> agendaItems = {};

  final ScrollController agendaScroll = ScrollController();

  AgendaWeergaveType agendaWeergave = AgendaWeergaveType.symbolen;

  @override
  void initState() {
    super.initState();

    laadAlles().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollNaarVandaag();
      });
    });
  }

  @override
  void dispose() {
    agendaScroll.dispose();
    super.dispose();
  }

  Future<void> laadAlles() async {
    await laadFilters();
    await laadAgendaItems();
  }

  void scrollNaarVandaag() {
    if (!agendaScroll.hasClients) return;

    final vorigeMaand = DateTime(
      selectie.focusMaand.year,
      selectie.focusMaand.month - 1,
    );

    final wekenVorigeMaand = AgendaDatumHelper.wekenVanMaand(
      vorigeMaand,
    ).length;

    final vandaag = DateTime.now();

    final eersteDagFocusMaand = DateTime(
      selectie.focusMaand.year,
      selectie.focusMaand.month,
      1,
    );

    final eersteRasterDag = eersteDagFocusMaand.subtract(
      Duration(
        days: eersteDagFocusMaand.weekday - 1,
      ),
    );

    final weekIndexVandaag = vandaag.difference(eersteRasterDag).inDays ~/ 7;

    final maandTitelHoogte = 36.0;
    final weekHoogte =
        agendaWeergave == AgendaWeergaveType.symbolen ? 92.0 : 118.0;

    final positie = maandTitelHoogte +
        (wekenVorigeMaand * weekHoogte) +
        maandTitelHoogte +
        (weekIndexVandaag * weekHoogte);

    agendaScroll.animateTo(
      positie < 0 ? 0 : positie,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOut,
    );
  }

  void scrollNaarVandaagNaLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollNaarVandaag();
    });
  }

  Future<void> laadAgendaItems() async {
    final geladenItems = await AgendaRepository.laadItems();

    if (!mounted) return;

    setState(() {
      agendaItems = geladenItems;
    });
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

  List<DateTime> zichtbareMaanden() {
    return [
      DateTime(
        selectie.focusMaand.year,
        selectie.focusMaand.month - 1,
      ),
      selectie.focusMaand,
      DateTime(
        selectie.focusMaand.year,
        selectie.focusMaand.month + 1,
      ),
    ];
  }

  List<AgendaItem> itemsVanGeselecteerdeDag(
    Map<String, List<AgendaItem>> zichtbareItems,
  ) {
    final key = AgendaDatumHelper.datumKey(
      selectie.geselecteerdeDag,
    );

    return zichtbareItems[key] ?? [];
  }

  void selecteerDag(DateTime dag) {
    if (verplaatsState.actief) {
      verplaatsNaarDag(dag);
      return;
    }

    setState(() {
      selectie = selectie.kiesDag(dag);
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

      selectie = selectie.kiesDag(oudeDag);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kies een nieuwe dag voor dit item.'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void annuleerVerplaatsen() {
    setState(() {
      verplaatsState = verplaatsState.stop();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verplaatsen geannuleerd.'),
      ),
    );
  }

  Future<void> verplaatsNaarDag(DateTime nieuweDag) async {
    final oudeDag = verplaatsState.oudeDag;
    final item = verplaatsState.item;

    if (oudeDag == null || item == null) return;

    final foutmelding = AgendaVerplaatsService.kanItemVerplaatsen(
      oudeDag: oudeDag,
      nieuweDag: nieuweDag,
      item: item,
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

    final nieuweItems = await AgendaRepository.verplaats(
      oudeDag: oudeDag,
      nieuweDag: nieuweDag,
      item: item,
      itemsPerDag: agendaItems,
    );

    if (!mounted) return;

    setState(() {
      agendaItems = nieuweItems;
      selectie = selectie.kiesDag(nieuweDag);
      verplaatsState = verplaatsState.stop();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item verplaatst.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> openItem(
    DateTime dag,
    AgendaItem item,
  ) async {
    if (verplaatsState.actief) return;

    setState(() {
      selectie = selectie.kiesDag(dag);
    });

    final resultaat = await showDialog<Object>(
      context: context,
      builder: (context) {
        return AgendaToevoegPopup(
          bestaandItem: item,
          geplandeItems: itemsVanGeselecteerdeDag(
            agendaItems,
          ),
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
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item verwijderd.'),
          backgroundColor: Colors.red,
        ),
      );

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
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item opgeslagen.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> openToevoegPopup() async {
    if (verplaatsState.actief) {
      annuleerVerplaatsen();
      return;
    }

    final nieuwItem = await showDialog<AgendaItem>(
      context: context,
      builder: (context) {
        return AgendaToevoegPopup(
          geplandeItems: itemsVanGeselecteerdeDag(
            agendaItems,
          ),
        );
      },
    );

    if (nieuwItem == null) return;

    final foutmelding = AgendaToevoegService.kanItemToevoegen(
      dag: selectie.geselecteerdeDag,
      nieuwItem: nieuwItem,
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

    final nieuweItems = await AgendaRepository.voegToe(
      dag: selectie.geselecteerdeDag,
      item: nieuwItem,
      itemsPerDag: agendaItems,
    );

    if (!mounted) return;

    setState(() {
      agendaItems = nieuweItems;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item toegevoegd.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> openFilterMenu() async {
    if (verplaatsState.actief) {
      annuleerVerplaatsen();
      return;
    }

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

  Widget _weergaveKnop({
    required String tekst,
    required bool actief,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        width: 86,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: actief ? const Color(0xFF0B7A3B) : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Text(
          tekst,
          style: TextStyle(
            color: actief ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget groeneActieKnop({
    required IconData icoon,
    required VoidCallback onTap,
    required bool actief,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        99,
      ),
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
          color: Color(
            0xFF0B7A3B,
          ),
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

  @override
  Widget build(BuildContext context) {
    final zichtbareItems = AgendaFilterHelper.gefilterdeItems(
      itemsPerDag: agendaItems,
      toonPlanning: filters.toonPlanning,
      toonOpvolging: filters.toonOpvolging,
      toonNadienst: filters.toonNadienst,
      toonAfspraak: filters.toonAfspraak,
      toonDagtaak: filters.toonDagtaak,
      toonVerlof: filters.toonVerlof,
      toonKraan: filters.toonKraan,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          if (verplaatsState.actief && verplaatsState.item != null)
            AgendaVerplaatsBalk(
              item: verplaatsState.item!,
            ),
          AgendaTopBalk(
            focusMaand: selectie.focusMaand,
            onTerug: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
            onVorigeMaand: () {
              setState(() {
                selectie = selectie.vorigeMaand();
              });
            },
            onVolgendeMaand: () {
              setState(() {
                selectie = selectie.volgendeMaand();
              });
            },
            onToevoegen: openToevoegPopup,
          ),
          const AgendaWeekdagBalk(),
          const SizedBox(height: 6),
          Flexible(
            fit: FlexFit.tight,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: 0,
              ),
              child: ListView(
                controller: agendaScroll,
                padding: EdgeInsets.fromLTRB(
                  8,
                  8,
                  8,
                  20,
                ),
                children: zichtbareMaanden().map((maand) {
                  return AgendaMaandBlok(
                    maand: maand,
                    geselecteerdeDag: selectie.geselecteerdeDag,
                    itemsPerDag: zichtbareItems,
                    weergave: agendaWeergave,
                    onDagKlik: selecteerDag,
                    onItemTap: openItem,
                    onItemSleep: (
                      dag,
                      item,
                    ) async {
                      // Niet meer gebruiken.
                    },
                    onItemDrop: (
                      nieuweDag,
                      item,
                      oudeDag,
                    ) async {
                      final nieuweItems =
                          await AgendaSleepAfhandeling.verwerkDrop(
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
                        selectie = selectie.kiesDag(nieuweDag);
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Agenda aangepast.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          if (agendaWeergave == AgendaWeergaveType.symbolen)
            AgendaDagDetail(
              key: ValueKey(
                selectie.geselecteerdeDag,
              ),
              dag: selectie.geselecteerdeDag,
              items: itemsVanGeselecteerdeDag(
                zichtbareItems,
              ),
              onItemTap: (item) {
                openItem(
                  selectie.geselecteerdeDag,
                  item,
                );
              },
            ),
          const SizedBox(height: 6),
          SafeArea(
            top: false,
            child: Container(
              color: const Color(0xFFF5F5F5),
              padding: const EdgeInsets.fromLTRB(
                12,
                8,
                12,
                6,
              ),
              child: Row(
                children: [
                  groeneActieKnop(
                    icoon: Icons.filter_alt,
                    actief: false,
                    onTap: openFilterMenu,
                  ),
                  const SizedBox(width: 8),
                  Stack(
                    children: [
                      groeneActieKnop(
                        icoon: Icons.schedule,
                        actief: false,
                        onTap: () {
                          AgendaInTePlannenKnop(
                            items: agendaItems.values.expand((e) => e).toList(),
                          ).openMenu(context);
                        },
                      ),
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  groeneActieKnop(
                    icoon: Icons.calendar_month,
                    actief: false,
                    onTap: () async {
                      final aangepast = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const JaarPlanningPaginaNieuw(),
                        ),
                      );

                      if (aangepast == true) {
                        await laadAgendaItems();
                      }
                    },
                  ),
                  const Spacer(),
                  _weergaveKnop(
                    tekst: 'Symbolen',
                    actief: agendaWeergave == AgendaWeergaveType.symbolen,
                    onTap: () {
                      setState(() {
                        agendaWeergave = AgendaWeergaveType.symbolen;
                        scrollNaarVandaagNaLayout();
                      });
                    },
                  ),
                  _weergaveKnop(
                    tekst: 'Details',
                    actief: agendaWeergave == AgendaWeergaveType.details,
                    onTap: () {
                      setState(() {
                        agendaWeergave = AgendaWeergaveType.details;
                        scrollNaarVandaagNaLayout();
                      });
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
