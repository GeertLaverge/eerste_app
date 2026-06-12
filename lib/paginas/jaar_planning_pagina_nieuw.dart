import 'package:flutter/material.dart';

import '../helpers/Agenda/agenda_bewerk_service.dart';
import '../helpers/Agenda/agenda_datum_helper.dart';
import '../helpers/Agenda/agenda_filter_popup.dart';
import '../helpers/Agenda/agenda_filter_state.dart';
import '../helpers/Agenda/agenda_in_te_plannen_knop.dart';
import '../helpers/Agenda/agenda_item.dart';
import '../helpers/Agenda/agenda_item_open_helper.dart';
import '../helpers/Agenda/agenda_onderbalk_knoppen.dart';
import '../helpers/Agenda/agenda_repository.dart';
import '../helpers/Agenda/agenda_sleep_afhandeling.dart';
import '../helpers/Agenda/agenda_toevoeg_popup.dart';
import '../helpers/Agenda/agenda_type_keuze_popup.dart';
import '../helpers/Agenda/agenda_verlof_popup.dart';
import '../helpers/Agenda/agenda_verplaats_state.dart';
import '../helpers/app_storage.dart';
import '../helpers/Agenda/agenda_jaar_maand_kolom.dart';
import '../helpers/Agenda/agenda_jaar_maand_breedte.dart';
import '../helpers/Agenda/agenda_klant_planning_tijd_helper.dart';
import '../helpers/Agenda/agenda_klant_planning_drop_service.dart';
import '../helpers/Agenda/agenda_klant_fiche_open_helper.dart';
import '../helpers/sync/sync_navigatie_helper.dart';

class JaarPlanningPaginaNieuw extends StatefulWidget {
  const JaarPlanningPaginaNieuw({super.key});

  @override
  State<JaarPlanningPaginaNieuw> createState() =>
      _JaarPlanningPaginaNieuwState();
}

class _JaarPlanningPaginaNieuwState extends State<JaarPlanningPaginaNieuw> {
  int jaar = DateTime.now().year;
  DateTime geselecteerdeDag = DateTime.now();

  final ScrollController maandBalkScroll = ScrollController();
  final ScrollController kalenderScroll = ScrollController();

  bool _scrollKoppelingActief = false;

  final ScrollController verticaleScroll = ScrollController();

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

    maandBalkScroll.addListener(() {
      if (_scrollKoppelingActief) return;
      if (!kalenderScroll.hasClients) return;

      _scrollKoppelingActief = true;
      kalenderScroll.jumpTo(maandBalkScroll.offset);
      _scrollKoppelingActief = false;
    });

    kalenderScroll.addListener(() {
      if (_scrollKoppelingActief) return;
      if (!maandBalkScroll.hasClients) return;

      _scrollKoppelingActief = true;
      maandBalkScroll.jumpTo(kalenderScroll.offset);
      _scrollKoppelingActief = false;
    });

    laadAlles();
  }

  Future<void> laadAlles() async {
    await laadFilters();
    await laadAgendaItems();

    scrollNaarVandaag();
  }

  Future<void> laadFilters() async {
    final waarden = await AppStorage.laadAgendaFilters(
      soort: 'jaar',
    );

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
    await AppStorage.bewaarAgendaFilters(
      {
        'planningKlanten': filters.toonPlanning,
        'opvolging': filters.toonOpvolging,
        'nadienst': filters.toonNadienst,
        'afspraken': filters.toonAfspraak,
        'dagTaken': filters.toonDagtaak,
        'vakantie': filters.toonVerlof,
        'kraan': filters.toonKraan,
      },
      soort: 'jaar',
    );
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
    maandBalkScroll.dispose();
    kalenderScroll.dispose();
    verticaleScroll.dispose();
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
    final geopend = await AgendaKlantFicheOpenHelper.openAlsKlantPlanning(
      context: context,
      item: item,
    );

    if (geopend) {
      await laadAgendaItems();

      if (!mounted) return;

      setState(() {});

      return;
    }

    final resultaat = await AgendaItemOpenHelper.open(
      context: context,
      item: item,
      geplandeItems: agendaItems[AgendaDatumHelper.datumKey(
            dag,
          )] ??
          [],
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
        agendaItems = Map<String, List<AgendaItem>>.from(
          nieuweItems.map(
            (key, value) => MapEntry(
              key,
              List<AgendaItem>.from(value),
            ),
          ),
        );
        heeftWijzigingen = true;
      });

      await laadAgendaItems();

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
    final gekozenType = await AgendaTypeKeuzePopup.open(
      context,
    );

    if (gekozenType == null) return;

    AgendaItem? nieuwItem;

    if (gekozenType == 'afspraak') {
      nieuwItem = await showDialog<AgendaItem>(
        context: context,
        builder: (context) {
          return AgendaToevoegPopup(
            vastType: 'afspraak',
            geplandeItems:
                agendaItems[AgendaDatumHelper.datumKey(geselecteerdeDag)] ?? [],
          );
        },
      );
    }

    if (gekozenType == 'verlof') {
      nieuwItem = await showDialog<AgendaItem>(
        context: context,
        builder: (context) {
          return const AgendaVerlofPopup();
        },
      );
    }

    if (gekozenType == 'dagtaak') {
      nieuwItem = await showDialog<AgendaItem>(
        context: context,
        builder: (context) {
          return AgendaToevoegPopup(
            vastType: 'dagtaak',
            geplandeItems:
                agendaItems[AgendaDatumHelper.datumKey(geselecteerdeDag)] ?? [],
          );
        },
      );
    }

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
    if (AgendaKlantPlanningDropService.isNieuweKlantPlanning(
      oudeDag,
    )) {
      final nieuweItems = await AgendaKlantPlanningDropService.verwerk(
        context: context,
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Klant ingepland.'),
          backgroundColor: Colors.green,
        ),
      );

      return;
    }

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

  double maandBreedte(
    int maand,
    Map<String, List<AgendaItem>> agendaItemsData,
    AgendaFilterState actieveFilters,
  ) {
    return AgendaJaarMaandBreedte.bereken(
      jaar: jaar,
      maand: maand,
      agendaItemsData: agendaItemsData,
      actieveFilters: actieveFilters,
    );
  }

  void scrollNaarVandaag() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!kalenderScroll.hasClients || !maandBalkScroll.hasClients) {
        return;
      }

      final vandaag = DateTime.now();

      if (vandaag.year != jaar) return;

      double offset = 0;

      for (int maand = 1; maand < vandaag.month; maand++) {
        offset += maandBreedte(
          maand,
          agendaItems,
          filters,
        );
        offset += 8;
      }

      final schermBreedte = MediaQuery.of(context).size.width;

      final doelOffset = offset - (schermBreedte / 2) + 120;

      final veiligeOffset = doelOffset.clamp(
        0.0,
        kalenderScroll.position.maxScrollExtent,
      );

      kalenderScroll.jumpTo(veiligeOffset);
      maandBalkScroll.jumpTo(veiligeOffset);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            height: 86,
            color: const Color(0xFFF5F5F5),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  AgendaOnderbalkKnoppen.actie(
                    icoon: Icons.home,
                    onTap: () async {
                      await SyncNavigatieHelper.terugNaarHomeMetUpload(
                        context: context,
                      );
                    },
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        jaar--;
                      });
                    },
                    icon: const Icon(
                      Icons.chevron_left,
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: Center(
                      child: Text(
                        '$jaar',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0B7A3B),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        jaar++;
                      });
                    },
                    icon: const Icon(
                      Icons.chevron_right,
                    ),
                  ),
                  const Spacer(),
                  AgendaOnderbalkKnoppen.actie(
                    icoon: Icons.add,
                    onTap: openToevoegPopup,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 38,
                  color: const Color(0xFFE7F6EC),
                  child: SingleChildScrollView(
                    controller: maandBalkScroll,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        12,
                        (index) => Container(
                          width: maandBreedte(
                            index + 1,
                            agendaItems,
                            filters,
                          ),
                          margin: const EdgeInsets.only(
                            right: 8,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            maanden[index],
                            style: const TextStyle(
                              color: Color(0xFF0B7A3B),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: verticaleScroll,
                    padding: const EdgeInsets.fromLTRB(
                      10,
                      8,
                      10,
                      12,
                    ),
                    child: Scrollbar(
                      controller: kalenderScroll,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: kalenderScroll,
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            12,
                            (index) => AgendaJaarMaandKolom(
                              jaar: jaar,
                              maand: index + 1,
                              geselecteerdeDag: geselecteerdeDag,
                              agendaItemsData: agendaItems,
                              actieveFilters: filters,
                              maandBreedte: maandBreedte,
                              weekNummer: weekNummer,
                              onDagGeselecteerd: (dag) {
                                setState(() {
                                  geselecteerdeDag = dag;
                                });
                              },
                              onItemOpenen: openItem,
                              onDropOpDag: verwerkDropOpDag,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
                  AgendaOnderbalkKnoppen.actie(
                    icoon: Icons.filter_alt,
                    onTap: openFilterMenu,
                  ),
                  const SizedBox(width: 8),
                  AgendaInTePlannenKnop(
                    items: agendaItems.values.expand((e) => e).toList(),
                  ),
                  const Spacer(),
                  AgendaOnderbalkKnoppen.weergave(
                    tekst: 'Symbolen',
                    actief: false,
                    onTap: () {
                      Navigator.pop(context, 'symbolen');
                    },
                  ),
                  const SizedBox(width: 6),
                  AgendaOnderbalkKnoppen.weergave(
                    tekst: 'Details',
                    actief: false,
                    onTap: () {
                      Navigator.pop(context, 'details');
                    },
                  ),
                  const SizedBox(width: 6),
                  AgendaOnderbalkKnoppen.weergave(
                    tekst: 'Jaaragenda',
                    actief: true,
                    onTap: () {},
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
