import 'package:flutter/material.dart';

import '../helpers/Agenda/agenda_bewerk_service.dart';
import '../helpers/Agenda/agenda_dag_detail.dart';
import '../helpers/Agenda/agenda_dagtaak_popup.dart';
import '../helpers/Agenda/agenda_datum_helper.dart';
import '../helpers/Agenda/agenda_filter_helper.dart';
import '../helpers/Agenda/agenda_filter_popup.dart';
import '../helpers/Agenda/agenda_filter_state.dart';
import '../helpers/Agenda/agenda_in_te_plannen_knop.dart';
import '../helpers/Agenda/agenda_item.dart';
import '../helpers/Agenda/agenda_item_open_helper.dart';
import '../helpers/Agenda/agenda_maand_blok.dart';
import '../helpers/Agenda/agenda_onderbalk_knoppen.dart';
import '../helpers/Agenda/agenda_repository.dart';
import '../helpers/Agenda/agenda_selectie_state.dart';
import '../helpers/Agenda/agenda_sleep_afhandeling.dart';
import '../helpers/Agenda/agenda_toevoeg_popup.dart';
import '../helpers/Agenda/agenda_toevoeg_service.dart';
import '../helpers/Agenda/agenda_top_balk.dart';
import '../helpers/Agenda/agenda_type_keuze_popup.dart';
import '../helpers/Agenda/agenda_verlof_popup.dart';
import '../helpers/Agenda/agenda_verplaats_balk.dart';
import '../helpers/Agenda/agenda_verplaats_service.dart';
import '../helpers/Agenda/agenda_verplaats_state.dart';
import '../helpers/Agenda/agenda_weekdag_balk.dart';
import '../helpers/Agenda/agenda_weergave_type.dart';
import '../helpers/Agenda/agenda_melding_service.dart';
import '../helpers/app_storage.dart';
import 'jaar_planning_pagina_nieuw.dart';
import '../paginas/klanten_fiche_pagina.dart';
import '../helpers/klanten/fiche/klantenfiche_repository.dart';
import '../helpers/Agenda/agenda_tijd_picker.dart';
import '../helpers/Agenda/agenda_klant_planning_tijd_helper.dart';
import '../helpers/Agenda/agenda_klant_planning_drop_service.dart';
import '../helpers/Agenda/agenda_klant_fiche_open_helper.dart';
import '../helpers/sync/sync_navigatie_helper.dart';

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

  AgendaWeergaveType agendaWeergave = AgendaWeergaveType.details;

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
    final waarden = await AppStorage.laadAgendaFilters(
      soort: 'detail',
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

  Map<String, List<AgendaItem>> zichtbareAgendaItems(
    Map<String, List<AgendaItem>> bron,
  ) {
    final zichtbaar = <String, List<AgendaItem>>{};

    bron.forEach((datumKey, items) {
      final lijst = items.where((item) {
        return !item.isVerwijderd;
      }).toList();

      if (lijst.isNotEmpty) {
        zichtbaar[datumKey] = lijst;
      }
    });

    return zichtbaar;
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
      soort: 'detail',
    );
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

    final oudeScrollPositie =
        agendaScroll.hasClients ? agendaScroll.offset : 0.0;

    setState(() {
      selectie = selectie.kiesDag(dag);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!agendaScroll.hasClients) return;

      final veiligePositie = oudeScrollPositie.clamp(
        agendaScroll.position.minScrollExtent,
        agendaScroll.position.maxScrollExtent,
      );

      agendaScroll.jumpTo(
        veiligePositie,
      );
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

    await AgendaMeldingService.verwijderMelding(
      dag: oudeDag,
      item: item,
    );

    await AgendaMeldingService.planMelding(
      dag: nieuweDag,
      item: item,
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

    setState(() {
      selectie = selectie.kiesDag(dag);
    });

    final resultaat = await AgendaItemOpenHelper.open(
      context: context,
      item: item,
      geplandeItems: itemsVanGeselecteerdeDag(
        agendaItems,
      ),
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
      await AgendaMeldingService.verwijderMelding(
        dag: dag,
        item: item,
      );
      if (item.type == 'planning' ||
          item.type == 'opvolging' ||
          item.type == 'nadienst' ||
          item.type == 'afspraak') {
        await AgendaKlantPlanningDropService.zetOpvolgKlantTerugInWachtrij(
            item);
      }

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

      await AgendaMeldingService.verwijderMelding(
        dag: dag,
        item: item,
      );

      final nieuweItems = await AgendaRepository.bewerk(
        dag: dag,
        oudItem: item,
        nieuwItem: resultaat,
        itemsPerDag: agendaItems,
      );

      await AgendaMeldingService.planMelding(
        dag: dag,
        item: resultaat,
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

    final gekozenType = await AgendaTypeKeuzePopup.open(
      context,
    );

    if (gekozenType == null) return;

    if (gekozenType == 'verlof') {
      final nieuwItem = await showDialog<AgendaItem>(
        context: context,
        builder: (context) {
          return const AgendaVerlofPopup();
        },
      );

      if (nieuwItem == null) return;

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
          content: Text('Verlof toegevoegd.'),
          backgroundColor: Colors.green,
        ),
      );

      return;
    }

    if (gekozenType == 'dagtaak') {
      final nieuwItem = await showDialog<AgendaItem>(
        context: context,
        builder: (context) {
          return const AgendaDagtaakPopup();
        },
      );

      if (nieuwItem == null) return;

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
          content: Text('Dagtaak toegevoegd.'),
          backgroundColor: Colors.green,
        ),
      );

      return;
    }

    AgendaItem? conceptItem;

    while (true) {
      final nieuwItem = await showDialog<AgendaItem>(
        context: context,
        builder: (context) {
          return AgendaToevoegPopup(
            bestaandItem: conceptItem,
            vastType: gekozenType,
            isHeropendeNieuwePlanning: conceptItem != null,
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
        conceptItem = nieuwItem;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(foutmelding),
            backgroundColor: Colors.red,
          ),
        );

        continue;
      }

      final nieuweItems = await AgendaRepository.voegToe(
        dag: selectie.geselecteerdeDag,
        item: nieuwItem,
        itemsPerDag: agendaItems,
      );

      await AgendaMeldingService.planMelding(
        dag: selectie.geselecteerdeDag,
        item: nieuwItem,
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

      return;
    }
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

  @override
  Widget build(BuildContext context) {
    final zichtbareAgenda = zichtbareAgendaItems(
      agendaItems,
    );

    final zichtbareItems = AgendaFilterHelper.gefilterdeItems(
      itemsPerDag: zichtbareAgenda,
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
            onTerug: () async {
              await SyncNavigatieHelper.terugNaarHomeMetUpload(
                context: context,
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
              padding: const EdgeInsets.only(
                bottom: 0,
              ),
              child: ListView(
                controller: agendaScroll,
                padding: const EdgeInsets.fromLTRB(
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
                      if (AgendaKlantPlanningDropService.isNieuweKlantPlanning(
                        oudeDag,
                      )) {
                        final nieuweItems =
                            await AgendaKlantPlanningDropService.verwerk(
                          context: context,
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
                            content: Text('Klant ingepland.'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        return;
                      }
                      final nieuweItems =
                          await AgendaSleepAfhandeling.verwerkDrop(
                        context: context,
                        oudeDag: oudeDag,
                        nieuweDag: nieuweDag,
                        item: item,
                        itemsPerDag: agendaItems,
                      );

                      if (nieuweItems == null) return;

                      await AgendaMeldingService.verwijderMelding(
                        dag: oudeDag,
                        item: item,
                      );

                      await AgendaMeldingService.planMelding(
                        dag: nieuweDag,
                        item: item,
                      );

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
                onItemVerwijder: (item) async {
                  await AgendaMeldingService.verwijderMelding(
                    dag: selectie.geselecteerdeDag,
                    item: item,
                  );

                  if (item.type == 'planning' ||
                      item.type == 'opvolging' ||
                      item.type == 'nadienst' ||
                      item.type == 'afspraak') {
                    await AgendaKlantPlanningDropService
                        .zetOpvolgKlantTerugInWachtrij(item);
                  }

                  final nieuweItems = await AgendaRepository.verwijder(
                    dag: selectie.geselecteerdeDag,
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
                }),
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
                  AgendaOnderbalkKnoppen.actie(
                    icoon: Icons.filter_alt,
                    onTap: openFilterMenu,
                  ),
                  const SizedBox(width: 8),
                  AgendaInTePlannenKnop(
                    items: zichtbareAgenda.values.expand((e) => e).toList(),
                  ),
                  const Spacer(),
                  AgendaOnderbalkKnoppen.weergave(
                    tekst: 'Symbolen',
                    actief: agendaWeergave == AgendaWeergaveType.symbolen,
                    onTap: () {
                      setState(() {
                        agendaWeergave = AgendaWeergaveType.symbolen;
                        scrollNaarVandaagNaLayout();
                      });
                    },
                  ),
                  AgendaOnderbalkKnoppen.weergave(
                    tekst: 'Details',
                    actief: agendaWeergave == AgendaWeergaveType.details,
                    onTap: () {
                      setState(() {
                        agendaWeergave = AgendaWeergaveType.details;
                        scrollNaarVandaagNaLayout();
                      });
                    },
                  ),
                  AgendaOnderbalkKnoppen.weergave(
                    tekst: 'Jaaragenda',
                    actief: false,
                    onTap: () async {
                      final resultaat = await Navigator.push<Object>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const JaarPlanningPaginaNieuw(),
                        ),
                      );

                      await laadAgendaItems();

                      if (!mounted) return;

                      setState(() {
                        agendaWeergave = AgendaWeergaveType.details;
                      });

                      if (resultaat == 'symbolen') {
                        setState(() {
                          agendaWeergave = AgendaWeergaveType.symbolen;
                        });
                      }

                      if (resultaat == 'details') {
                        setState(() {
                          agendaWeergave = AgendaWeergaveType.details;
                        });
                      }
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
