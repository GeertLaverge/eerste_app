import 'package:flutter/material.dart';

import '../../lib/helpers/app_storage.dart';
import '../../lib/modellen/agenda_actie.dart';
import '../../lib/modellen/afspraak_klant.dart';
import '../../lib/modellen/klant.dart';
import '../../lib/modellen/planning_dag.dart';
import 'agenda_actie_pagina.dart';
import 'package:flutter/cupertino.dart';
import 'afspraak_klanten_pagina.dart';
import '../../lib/modellen/agenda_actie_template.dart';

class JaarPlanningPagina extends StatefulWidget {
  final List<Klant> alleKlanten;
  final List<AgendaActie> agendaActies;
  final List<AfspraakKlant> afsprakenKlanten;
  final List<DateTime> vakantieDagen;

  const JaarPlanningPagina({
    super.key,
    required this.alleKlanten,
    required this.agendaActies,
    required this.afsprakenKlanten,
    required this.vakantieDagen,
  });

  @override
  State<JaarPlanningPagina> createState() => _JaarPlanningPaginaState();
}

class _JaarPlanningPaginaState extends State<JaarPlanningPagina> {
  int jaar = DateTime.now().year;

  List<Klant> alleKlanten = [];
  List<AgendaActie> agendaActies = [];
  List<AfspraakKlant> afsprakenKlanten = [];
  List<DateTime> vakantieDagen = [];

  bool toonPlanningKlanten = true;
  bool toonOpvolging = true;
  bool toonNadienst = true;
  bool toonDagTaken = true;
  bool toonAfspraken = true;
  bool toonVakantie = true;
  bool toonKraan = true;

  bool toonInTePlannenMenu = false;
  bool toonFilterMenu = false;
  Offset inTePlannenMenuPositie = const Offset(20, 105);

  final ScrollController horizontaleScrollController = ScrollController();

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

  final dagenKort = const ['Ma', 'Di', 'Wo', 'Do', 'Vr', 'Za', 'Zo'];

  @override
  void initState() {
    super.initState();

    alleKlanten = List.from(widget.alleKlanten);
    agendaActies = List.from(widget.agendaActies);
    afsprakenKlanten = List.from(widget.afsprakenKlanten);
    vakantieDagen = List.from(widget.vakantieDagen);

    laadData();
    laadZichtbaarheid();
  }

  @override
  void dispose() {
    horizontaleScrollController.dispose();
    super.dispose();
  }

  Future<void> laadData() async {
    final geladenKlanten = await AppStorage.laadKlanten();
    final geladenAgendaActies = await AppStorage.laadAgendaActies();
    final geladenAfsprakenKlanten = await AppStorage.laadAfsprakenKlanten();
    final geladenVakantieDagen = await AppStorage.laadVakantieDagen();

    if (!mounted) return;

    setState(() {
      alleKlanten = geladenKlanten;
      agendaActies = geladenAgendaActies;
      afsprakenKlanten = geladenAfsprakenKlanten;
      vakantieDagen = geladenVakantieDagen;
    });
  }

  bool zelfdeDag(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String tijdTekst(int uur, int minuut) {
    return '${uur.toString().padLeft(2, '0')}:${minuut.toString().padLeft(2, '0')}';
  }

  bool isVakantieDag(DateTime dag) {
    if (!toonVakantie) return false;
    return vakantieDagen.any((item) => zelfdeDag(item, dag));
  }

  int weekNummer(DateTime datum) {
    final donderdag = datum.add(Duration(days: 4 - datum.weekday));
    final eersteDonderdag = DateTime(donderdag.year, 1, 4);
    return 1 + donderdag.difference(eersteDonderdag).inDays ~/ 7;
  }

  List<Klant> klantenOpDag(DateTime dag) {
    return alleKlanten.where((klant) {
      return klant.planningDagen.any(
        (planning) => zelfdeDag(planning.datum, dag),
      );
    }).toList();
  }

  List<AgendaActie> dagTakenOpDag(DateTime dag) {
    return agendaActies.where((actie) {
      final toonDatum = actie.datum.subtract(
        Duration(days: actie.dagenVoorafTonen),
      );
      return zelfdeDag(toonDatum, dag);
    }).toList();
  }

  List<AfspraakKlant> afsprakenOpDag(DateTime dag) {
    return afsprakenKlanten.where((afspraak) {
      return zelfdeDag(afspraak.datum, dag);
    }).toList();
  }

  List<_JaarItem> itemsOpDag(DateTime dag) {
    if (isVakantieDag(dag)) return [];

    final List<_JaarItem> items = [];

    for (final klant in klantenOpDag(dag)) {
      if (klant.isNadienst && !toonNadienst) continue;
      if (klant.isOpTeVolgen && !toonOpvolging) continue;
      if (!klant.isNadienst && !klant.isOpTeVolgen && !toonPlanningKlanten) {
        continue;
      }

      final planningDag = klant.planningDagen.firstWhere(
        (planning) => zelfdeDag(planning.datum, dag),
      );

      final naamBasis =
          klant.klantnaam.isEmpty ? 'Klant zonder naam' : klant.klantnaam;

      final naam =
          '$naamBasis (${tijdTekst(planningDag.startUur, planningDag.startMinuut)} - ${tijdTekst(planningDag.eindUur, planningDag.eindMinuut)})';

      if (klant.isNadienst) {
        items.add(
          _JaarItem(
            tekst: naam,
            kleur: Colors.purple,
            achtergrond: const Color(0xFFF3E8FF),
            klant: klant,
            planningDag: planningDag,
          ),
        );
      } else if (klant.isOpTeVolgen) {
        items.add(
          _JaarItem(
            tekst: naam,
            kleur: const Color(0xFF0F766E),
            achtergrond: const Color(0xFFE0F2F1),
            klant: klant,
            planningDag: planningDag,
          ),
        );
      } else {
        items.add(
          _JaarItem(
            tekst: naam,
            kleur: const Color(0xFF0B7A3B),
            achtergrond: const Color(0xFFE7F6EC),
            klant: klant,
            planningDag: planningDag,
          ),
        );
      }
    }

    if (toonDagTaken) {
      for (final actie in dagTakenOpDag(dag)) {
        items.add(
          _JaarItem(
            tekst: actie.titel,
            kleur: const Color(0xFFF06418),
            achtergrond: const Color(0xFFFFF1E7),
            actie: actie,
          ),
        );
      }
    }
    if (toonKraan) {
      for (final klant in alleKlanten) {
        final kraan = klant.kraanReservering;

        if (kraan == null) continue;
        if (!kraan.gereserveerd) continue;
        if (kraan.datum == null) continue;
        if (!zelfdeDag(kraan.datum!, dag)) continue;

        items.add(
          _JaarItem(
            tekst:
                '${klant.klantnaam.isEmpty ? 'Klant zonder naam' : klant.klantnaam} kraan',
            kleur: Colors.brown,
            achtergrond: const Color(0xFFF5ECE3),
          ),
        );
      }
    }

    if (toonAfspraken) {
      for (final afspraak in afsprakenOpDag(dag)) {
        items.add(
          _JaarItem(
            tekst: afspraak.ganseDag
                ? '${afspraak.klantNaam.isEmpty ? 'Klant zonder naam' : afspraak.klantNaam} (ganse dag)'
                : '${afspraak.klantNaam.isEmpty ? 'Klant zonder naam' : afspraak.klantNaam} (${tijdTekst(afspraak.beginUur, afspraak.beginMinuut)} - ${tijdTekst(afspraak.eindUur, afspraak.eindMinuut)})',
            kleur: Colors.blue,
            achtergrond: const Color(0xFFE7F0FF),
            afspraak: afspraak,
          ),
        );
      }
    }

    return items;
  }

  double itemBreedte(_JaarItem item) {
    final breedte = 18 + (item.tekst.length * 5.2);
    if (breedte < 34) return 34;
    if (breedte > 180) return 180;
    return breedte;
  }

  double maandBreedte(int maand) {
    const minimum = 150.0;
    const maximum = 1600.0;

    double breedsteRij = minimum;
    final aantalDagen = DateTime(jaar, maand + 1, 0).day;

    for (int dag = 1; dag <= aantalDagen; dag++) {
      final datum = DateTime(jaar, maand, dag);
      if (isVakantieDag(datum)) continue;

      final items = itemsOpDag(datum);
      if (items.isEmpty) continue;

      double rijBreedte = 26 + 4 + 14;

      for (final item in items) {
        rijBreedte += itemBreedte(item) + 2;
      }

      if (rijBreedte > breedsteRij) {
        breedsteRij = rijBreedte;
      }
    }

    if (breedsteRij > maximum) return maximum;
    return breedsteRij;
  }

  Color kleurUitNaam(String naam) {
    switch (naam) {
      case 'blauw':
        return Colors.blue;
      case 'rood':
        return Colors.red;
      case 'paars':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'brown':
        return Colors.brown;
      case 'groen':
      default:
        return Colors.green;
    }
  }

  IconData icoonUitNaam(String naam) {
    switch (naam) {
      case 'task_alt':
      case 'taak':
        return Icons.task_alt;
      case 'beach_access':
      case 'verlof':
        return Icons.beach_access;
      case 'access_time':
      case 'tijd':
        return Icons.access_time;
      case 'local_shipping':
        return Icons.local_shipping;
      default:
        return Icons.delete_sweep;
    }
  }

  @override
  Widget build(BuildContext context) {
    const dagKolomBreedte = 70.0;
    const rijHoogte = 34.0;
    const headerHoogte = 40.0;

    final maandBreedtes = List.generate(
      12,
      (index) => maandBreedte(index + 1),
    );

    final totaleBreedte =
        dagKolomBreedte + maandBreedtes.fold<double>(0, (a, b) => a + b);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                groeneBalk(),
                Expanded(
                  child: Scrollbar(
                    controller: horizontaleScrollController,
                    thumbVisibility: true,
                    scrollbarOrientation: ScrollbarOrientation.bottom,
                    child: SingleChildScrollView(
                      controller: horizontaleScrollController,
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: totaleBreedte,
                        child: Column(
                          children: [
                            SizedBox(
                              height: headerHoogte,
                              child: Row(
                                children: [
                                  Container(
                                    width: dagKolomBreedte,
                                    color: const Color(0xFF8DD0A5),
                                  ),
                                  ...List.generate(12, (index) {
                                    return Container(
                                      width: maandBreedtes[index],
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF8DD0A5),
                                        border: Border(
                                          right: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        '${maanden[index]} $jaar',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: 42,
                                itemBuilder: (context, rijIndex) {
                                  final weekDagIndex = rijIndex % 7;
                                  final isWeekendRij =
                                      weekDagIndex == 5 || weekDagIndex == 6;

                                  return SizedBox(
                                    height: rijHoogte,
                                    child: Row(
                                      children: [
                                        linkerDagKolom(
                                          weekDagIndex: weekDagIndex,
                                          isWeekend: isWeekendRij,
                                        ),
                                        ...List.generate(12, (maandIndex) {
                                          final maand = maandIndex + 1;
                                          final eersteDag =
                                              DateTime(jaar, maand, 1);
                                          final aantalDagen =
                                              DateTime(jaar, maand + 1, 0).day;

                                          final dagNummer = rijIndex -
                                              (eersteDag.weekday - 1) +
                                              1;

                                          final bestaatDag = dagNummer >= 1 &&
                                              dagNummer <= aantalDagen;

                                          final datum = bestaatDag
                                              ? DateTime(jaar, maand, dagNummer)
                                              : null;

                                          final isVakantie = datum != null &&
                                              isVakantieDag(datum);

                                          final items = datum == null
                                              ? <_JaarItem>[]
                                              : itemsOpDag(datum);
                                          return GestureDetector(
                                            onTap: bestaatDag && datum != null
                                                ? () => toonDagActieMenu(datum)
                                                : null,
                                            child: Container(
                                              width: maandBreedtes[maandIndex],
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: !bestaatDag
                                                    ? Colors.grey.shade50
                                                    : isVakantie
                                                        ? const Color(
                                                            0xFFFFE5E5)
                                                        : isWeekendRij
                                                            ? Colors
                                                                .grey.shade300
                                                            : Colors.white,
                                                border: Border(
                                                  right: BorderSide(
                                                    color: Colors.grey.shade300,
                                                  ),
                                                  bottom: BorderSide(
                                                    color: Colors.grey.shade200,
                                                  ),
                                                ),
                                              ),
                                              child: bestaatDag
                                                  ? DragTarget<Object>(
                                                      onAcceptWithDetails:
                                                          (details) async {
                                                        final data =
                                                            details.data;

                                                        if (data is Klant) {
                                                          await planNieuweKlant(
                                                            klant: data,
                                                            datum: datum!,
                                                          );

                                                          return;
                                                        }

                                                        if (data is _JaarItem) {
                                                          await toonVerplaatsMenu(
                                                            item: data,
                                                            nieuweDatum: datum!,
                                                          );
                                                        }
                                                      },
                                                      builder: (
                                                        context,
                                                        candidateData,
                                                        rejectedData,
                                                      ) {
                                                        final isHover =
                                                            candidateData
                                                                .isNotEmpty;

                                                        return Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: isHover
                                                                ? const Color(
                                                                    0xFFE7F6EC,
                                                                  )
                                                                : Colors
                                                                    .transparent,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6),
                                                            border: Border.all(
                                                              color: isHover
                                                                  ? const Color(
                                                                      0xFF0B7A3B,
                                                                    )
                                                                  : Colors
                                                                      .transparent,
                                                              width: 1.4,
                                                            ),
                                                          ),
                                                          child: Stack(
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  SizedBox(
                                                                    width: 26,
                                                                    child: Text(
                                                                      dagNummer
                                                                          .toString(),
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        fontWeight:
                                                                            FontWeight.w700,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 4,
                                                                  ),
                                                                  if (!isWeekendRij &&
                                                                      !isVakantie)
                                                                    ...items.map(
                                                                        (item) {
                                                                      return Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(
                                                                          right:
                                                                              4,
                                                                        ),
                                                                        child: Draggable<
                                                                            Object>(
                                                                          data:
                                                                              item,
                                                                          feedback:
                                                                              Material(
                                                                            color:
                                                                                Colors.transparent,
                                                                            child:
                                                                                jaarItemTegel(item, datum!),
                                                                          ),
                                                                          childWhenDragging:
                                                                              Opacity(
                                                                            opacity:
                                                                                0.35,
                                                                            child:
                                                                                jaarItemTegel(item, datum!),
                                                                          ),
                                                                          child: jaarItemTegel(
                                                                              item,
                                                                              datum!),
                                                                        ),
                                                                      );
                                                                    }),
                                                                ],
                                                              ),
                                                              if (datum!
                                                                      .weekday ==
                                                                  DateTime
                                                                      .sunday)
                                                                Positioned(
                                                                  left: 70,
                                                                  bottom: 1,
                                                                  child: Text(
                                                                    'W${weekNummer(datum)}',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          10,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .black87,
                                                                    ),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    )
                                                  : null,
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (toonInTePlannenMenu)
              Positioned(
                left: inTePlannenMenuPositie.dx,
                top: inTePlannenMenuPositie.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      inTePlannenMenuPositie += details.delta;
                    });
                  },
                  child: inTePlannenMenu(),
                ),
              ),
            if (toonFilterMenu)
              Positioned(
                right: 14,
                top: 92,
                child: SizedBox(
                  width: 285,
                  child: filterUitvalMenu(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> laadZichtbaarheid() async {
    final waarden = await AppStorage.laadAgendaFilters();

    if (!mounted) return;

    setState(() {
      toonPlanningKlanten = waarden['planningKlanten'] ?? true;
      toonOpvolging = waarden['opvolging'] ?? true;
      toonNadienst = waarden['nadienst'] ?? true;
      toonDagTaken = waarden['dagTaken'] ?? true;
      toonAfspraken = waarden['afspraken'] ?? true;
      toonVakantie = waarden['vakantie'] ?? true;
      toonKraan = waarden['kraan'] ?? true;
    });
  }

  Future<void> bewaarZichtbaarheid() async {
    await AppStorage.bewaarAgendaFilters({
      'planningKlanten': toonPlanningKlanten,
      'opvolging': toonOpvolging,
      'nadienst': toonNadienst,
      'dagTaken': toonDagTaken,
      'afspraken': toonAfspraken,
      'vakantie': toonVakantie,
      'kraan': toonKraan,
    });
  }

  Future<void> toonAgendaMenu() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, menuSetState) {
            Widget keuze({
              required String titel,
              required Color kleur,
              required bool waarde,
              required ValueChanged<bool> onChanged,
            }) {
              return CheckboxListTile(
                value: waarde,
                onChanged: (nieuw) {
                  if (nieuw == null) return;

                  menuSetState(() {
                    onChanged(nieuw);
                  });

                  setState(() {});
                  bewaarZichtbaarheid();
                },
                activeColor: kleur,
                title: Text(
                  titel,
                  style: TextStyle(
                    color: kleur,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Agenda’s zichtbaar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    keuze(
                      titel: 'Planning klanten',
                      kleur: Colors.green,
                      waarde: toonPlanningKlanten,
                      onChanged: (v) => toonPlanningKlanten = v,
                    ),
                    keuze(
                      titel: 'Op te volgen',
                      kleur: const Color(0xFF0F766E),
                      waarde: toonOpvolging,
                      onChanged: (v) => toonOpvolging = v,
                    ),
                    keuze(
                      titel: 'Nadienst',
                      kleur: Colors.purple,
                      waarde: toonNadienst,
                      onChanged: (v) => toonNadienst = v,
                    ),
                    keuze(
                      titel: 'Dagtaak',
                      kleur: const Color(0xFFF06418),
                      waarde: toonDagTaken,
                      onChanged: (v) => toonDagTaken = v,
                    ),
                    keuze(
                      titel: 'Afspraken klanten',
                      kleur: Colors.blue,
                      waarde: toonAfspraken,
                      onChanged: (v) => toonAfspraken = v,
                    ),
                    keuze(
                      titel: 'Verlof',
                      kleur: Colors.red,
                      waarde: toonVakantie,
                      onChanged: (v) => toonVakantie = v,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Klant> inTePlannenKlanten() {
    return alleKlanten.where((klant) {
      if (klant.isProjectAfgewerkt) return false;
      if (klant.planningDagen.isNotEmpty) return false;
      return true;
    }).toList();
  }

  Widget inTePlannenMenu() {
    final klanten = inTePlannenKlanten();

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 260,
        constraints: const BoxConstraints(maxHeight: 420),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.playlist_add_check_circle,
                  color: Color(0xFF0B7A3B),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'In te plannen (${klanten.length})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0B7A3B),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      toonInTePlannenMenu = false;
                    });
                  },
                  icon: const Icon(Icons.close),
                  iconSize: 18,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                ),
              ],
            ),
            const Divider(height: 14),
            if (klanten.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Geen klanten in te plannen.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: klanten.length,
                  itemBuilder: (context, index) {
                    final klant = klanten[index];

                    Color kleur = const Color(0xFF0B7A3B);
                    String type = 'Planning';

                    if (klant.isOpTeVolgen) {
                      kleur = const Color(0xFF0F766E);
                      type = 'Opvolging';
                    } else if (klant.isNadienst) {
                      kleur = Colors.purple;
                      type = 'Nadienst';
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Draggable<Klant>(
                        data: klant,
                        feedback: Material(
                          color: Colors.transparent,
                          child: Container(
                            width: 220,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: kleur.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: kleur),
                            ),
                            child: Text(
                              klant.klantnaam.isEmpty
                                  ? 'Klant zonder naam'
                                  : klant.klantnaam,
                              style: TextStyle(
                                color: kleur,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.35,
                          child: inTePlannenRij(klant, kleur, type),
                        ),
                        child: inTePlannenRij(klant, kleur, type),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget inTePlannenRij(Klant klant, Color kleur, String type) {
    return Row(
      children: [
        Icon(Icons.drag_indicator, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            klant.klantnaam.isEmpty ? 'Klant zonder naam' : klant.klantnaam,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          type,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: kleur,
          ),
        ),
      ],
    );
  }

  Widget bestaandePlanningOpDag(DateTime dag) {
    final klanten = klantenOpDag(dag);

    klanten.sort((a, b) {
      final planningA = a.planningDagen.firstWhere(
        (p) => zelfdeDag(p.datum, dag),
      );

      final planningB = b.planningDagen.firstWhere(
        (p) => zelfdeDag(p.datum, dag),
      );

      final minutenA = planningA.startUur * 60 + planningA.startMinuut;
      final minutenB = planningB.startUur * 60 + planningB.startMinuut;

      return minutenA.compareTo(minutenB);
    });

    if (klanten.isEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 14),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Nog geen klantplanning op deze dag',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F6EC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF8DD0A5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reeds ingepland',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B7A3B),
            ),
          ),
          const SizedBox(height: 6),
          ...klanten.map((klant) {
            final planning = klant.planningDagen.firstWhere(
              (p) => zelfdeDag(p.datum, dag),
            );

            Color kleur = const Color(0xFF0B7A3B);

            if (klant.isOpTeVolgen) {
              kleur = const Color(0xFF0F766E);
            } else if (klant.isNadienst) {
              kleur = Colors.purple;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${tijdTekst(planning!.startUur, planning.startMinuut)} - ${tijdTekst(planning.eindUur, planning.eindMinuut)}  ${klant.klantnaam.isEmpty ? 'Klant zonder naam' : klant.klantnaam}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: kleur,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<TimeOfDay?> kiesPlanningTijd({
    required String titel,
    required int startUur,
    required int startMinuut,
    DateTime? datum,
  }) async {
    int gekozenUur = startUur;
    int gekozenMinuut = startMinuut;

    final uurController = FixedExtentScrollController(initialItem: gekozenUur);
    final minuutController =
        FixedExtentScrollController(initialItem: gekozenMinuut);

    return showDialog<TimeOfDay>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: SizedBox(
            width: 340,
            height: 360,
            child: Column(
              children: [
                const SizedBox(height: 14),
                Text(
                  titel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (datum != null) ...[
                  const SizedBox(height: 8),
                  bestaandePlanningOpDag(datum),
                ],
                const SizedBox(height: 8),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 42,
                        margin: const EdgeInsets.symmetric(horizontal: 28),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7F6EC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF8DD0A5),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: uurController,
                              itemExtent: 42,
                              magnification: 1.15,
                              useMagnifier: true,
                              selectionOverlay: const SizedBox.shrink(),
                              onSelectedItemChanged: (waarde) {
                                gekozenUur = waarde;
                              },
                              children: List.generate(24, (index) {
                                return Center(
                                  child: Text(
                                    index.toString().padLeft(2, '0'),
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          const Text(
                            ':',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: minuutController,
                              itemExtent: 42,
                              magnification: 1.15,
                              useMagnifier: true,
                              selectionOverlay: const SizedBox.shrink(),
                              onSelectedItemChanged: (waarde) {
                                gekozenMinuut = waarde;
                              },
                              children: List.generate(60, (index) {
                                return Center(
                                  child: Text(
                                    index.toString().padLeft(2, '0'),
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuleren'),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          TimeOfDay(
                            hour: gekozenUur,
                            minute: gekozenMinuut,
                          ),
                        );
                      },
                      child: const Text('Kiezen'),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String?> toonTijdKeuzeMenu() async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: SizedBox(
            width: 320,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Tijd kiezen',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Tijd behouden'),
                    onTap: () => Navigator.pop(context, 'behouden'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit_calendar),
                    title: const Text('Tijd aanpassen'),
                    onTap: () => Navigator.pop(context, 'aanpassen'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.close),
                    title: const Text('Annuleren'),
                    onTap: () => Navigator.pop(context, 'annuleren'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  int minutenVanPlanning(PlanningDag planning, bool start) {
    if (start) {
      return planning!.startUur * 60 + planning.startMinuut;
    }

    return planning.eindUur * 60 + planning.eindMinuut;
  }

  String? overlapTekst({
    required PlanningDag planning,
    required DateTime datum,
    required int startUur,
    required int startMinuut,
    required int eindUur,
    required int eindMinuut,
  }) {
    final nieuweStart = startUur * 60 + startMinuut;
    final nieuweEinde = eindUur * 60 + eindMinuut;

    for (final andereKlant in alleKlanten) {
      if (andereKlant.isProjectAfgewerkt) continue;

      for (final anderePlanning in andereKlant.planningDagen) {
        if (anderePlanning == planning) continue;
        if (!zelfdeDag(anderePlanning.datum, datum)) continue;

        final andereStart =
            anderePlanning.startUur * 60 + anderePlanning.startMinuut;
        final andereEinde =
            anderePlanning.eindUur * 60 + anderePlanning.eindMinuut;

        final overlapt = nieuweStart < andereEinde && andereStart < nieuweEinde;

        if (overlapt) {
          final naam = andereKlant.klantnaam.isEmpty
              ? 'Klant zonder naam'
              : andereKlant.klantnaam;

          return '${tijdTekst(anderePlanning.startUur, anderePlanning.startMinuut)} - ${tijdTekst(anderePlanning.eindUur, anderePlanning.eindMinuut)}  $naam';
        }
      }
    }

    return null;
  }

  bool heeftOverlap({
    required Klant klant,
    required PlanningDag planning,
    required DateTime datum,
    required int startUur,
    required int startMinuut,
    required int eindUur,
    required int eindMinuut,
  }) {
    final nieuweStart = startUur * 60 + startMinuut;
    final nieuweEinde = eindUur * 60 + eindMinuut;

    for (final andereKlant in alleKlanten) {
      if (andereKlant.isProjectAfgewerkt) continue;

      for (final anderePlanning in andereKlant.planningDagen) {
        if (anderePlanning == planning) continue;
        if (!zelfdeDag(anderePlanning.datum, datum)) continue;

        final andereStart = minutenVanPlanning(anderePlanning, true);
        final andereEinde = minutenVanPlanning(anderePlanning, false);

        final overlapt = nieuweStart < andereEinde && andereStart < nieuweEinde;

        if (overlapt) return true;
      }
    }

    return false;
  }

  Future<void> toonDagActieMenu(DateTime datum) async {
    final keuze = await showDialog<String>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: SizedBox(
            width: 330,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${datum.day}/${datum.month}/${datum.year}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context, 'annuleren'),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context, 'afspraak'),
                      icon: const Icon(Icons.event_available),
                      label: const Text('Afspraak klant toevoegen'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE7F6EC),
                        foregroundColor: const Color(0xFF0B7A3B),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.pop(context, 'bestaande_dagtaak'),
                      icon: const Icon(Icons.playlist_add_check),
                      label: const Text('Dagtaak toevoegen op planning'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE7F6EC),
                        foregroundColor: const Color(0xFF0B7A3B),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context, 'dagtaak'),
                      icon: const Icon(Icons.task_alt),
                      label: const Text('Nieuwe dagtaak maken'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE7F6EC),
                        foregroundColor: const Color(0xFF0B7A3B),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context, 'verlof'),
                      icon: const Icon(Icons.beach_access),
                      label: const Text('Verlofdag plaatsen'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    Future<void> toonActieKeuzeMenuVoorDag(DateTime dag) async {
      final templates = await AppStorage.laadAgendaActieTemplates();

      if (templates.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maak eerst een dagtaak'),
          ),
        );

        return;
      }

      final gekozenTemplate = await showModalBottomSheet<AgendaActieTemplate>(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Kies een opgeslagen dagtaak',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: templates.map((template) {
                      return ListTile(
                        leading: Icon(
                          icoonUitNaam(template.icoonNaam),
                          color: kleurUitNaam(template.kleurNaam),
                        ),
                        title: Text(template.naam),
                        onTap: () {
                          Navigator.pop(context, template);
                        },
                      );
                    }).toList(),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.close),
                  title: const Text('Annuleren'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        },
      );

      if (gekozenTemplate == null) return;

      agendaActies.add(
        AgendaActie(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          titel: gekozenTemplate.naam,
          typeActie: gekozenTemplate.naam,
          datum: DateTime(dag.year, dag.month, dag.day),
          toonOpDagtaak: true,
          dagenVoorafTonen: 0,
          weergaveType: 'symbool',
          kleurNaam: gekozenTemplate.kleurNaam,
          icoonNaam: gekozenTemplate.icoonNaam,
          startUur: null,
          startMinuut: null,
          eindUur: null,
          eindMinuut: null,
          opmerkingen: '',
        ),
      );

      await AppStorage.bewaarAgendaActies(agendaActies);
      if (!toonDagTaken) {
        toonVerborgenAgendaMelding(
          naam: 'Dagtaak',
          zichtbaarMaken: () {
            setState(() {
              toonDagTaken = true;
            });
          },
        );
      }

      if (mounted) {
        setState(() {});
      }
    }

    if (keuze == null || keuze == 'annuleren') return;

    if (keuze == 'afspraak') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AfspraakKlantenPagina(
            datum: datum,
          ),
        ),
      );

      await laadData();
      if (!toonAfspraken) {
        toonVerborgenAgendaMelding(
          naam: 'Afspraak klant',
          zichtbaarMaken: () {
            setState(() {
              toonAfspraken = true;
            });
          },
        );
      }
      return;
    }
    if (keuze == 'bestaande_dagtaak') {
      await toonActieKeuzeMenuVoorDag(datum);
      return;
    }

    if (keuze == 'dagtaak') {
      final nieuweActie = AgendaActie(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titel: '',
        typeActie: '',
        datum: DateTime(datum.year, datum.month, datum.day),
        toonOpDagtaak: true,
        dagenVoorafTonen: 0,
        weergaveType: 'symbool',
        kleurNaam: 'groen',
        icoonNaam: 'task_alt',
        startUur: null,
        startMinuut: null,
        eindUur: null,
        eindMinuut: null,
        opmerkingen: '',
      );

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AgendaActiePagina(
            bestaandeActie: nieuweActie,
            onOpslaan: (actie) async {
              agendaActies.add(actie);
              await AppStorage.bewaarAgendaActies(agendaActies);
              if (!toonDagTaken) {
                toonVerborgenAgendaMelding(
                  naam: 'Dagtaak',
                  zichtbaarMaken: () {
                    setState(() {
                      toonDagTaken = true;
                    });
                  },
                );
              }
              if (mounted) {
                setState(() {});
              }
              await laadData();
            },
          ),
        ),
      );

      return;
    }

    if (keuze == 'verlof') {
      final bestaatAl = vakantieDagen.any((d) => zelfdeDag(d, datum));

      if (!bestaatAl) {
        vakantieDagen.add(DateTime(datum.year, datum.month, datum.day));
        await AppStorage.bewaarVakantieDagen(vakantieDagen);
        await laadData();
        if (!toonVakantie) {
          toonVerborgenAgendaMelding(
            naam: 'Verlof',
            zichtbaarMaken: () {
              setState(() {
                toonVakantie = true;
              });
            },
          );
        }
        if (!toonAfspraken) {
          toonVerborgenAgendaMelding(
            naam: 'Afspraak klant',
            zichtbaarMaken: () {
              setState(() {
                toonAfspraken = true;
              });
            },
          );
        }
      }

      return;
    }
  }

  Future<void> planNieuweKlant({
    required Klant klant,
    required DateTime datum,
  }) async {
    final tijdKeuze = await toonTijdKeuzeMenu();

    if (tijdKeuze == null || tijdKeuze == 'annuleren') return;

    int startUur = 7;
    int startMinuut = 0;
    int eindUur = 15;
    int eindMinuut = 30;

    if (tijdKeuze == 'aanpassen') {
      final start = await kiesPlanningTijd(
        titel: 'Starttijd kiezen',
        startUur: startUur,
        startMinuut: startMinuut,
        datum: datum,
      );

      if (start == null) return;

      final einde = await kiesPlanningTijd(
        titel: 'Eindtijd kiezen',
        startUur: start.hour,
        startMinuut: start.minute,
        datum: datum,
      );

      if (einde == null) return;

      startUur = start.hour;
      startMinuut = start.minute;
      eindUur = einde.hour;
      eindMinuut = einde.minute;
      final startMinuten = startUur * 60 + startMinuut;
      final eindMinuten = eindUur * 60 + eindMinuut;

      if (eindMinuten <= startMinuten) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Eindtijd moet later zijn dan begintijd.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final nieuwePlanning = PlanningDag(
      datum: datum,
      startUur: startUur,
      startMinuut: startMinuut,
      eindUur: eindUur,
      eindMinuut: eindMinuut,
    );

    final overlap = overlapTekst(
      planning: nieuwePlanning,
      datum: datum,
      startUur: startUur,
      startMinuut: startMinuut,
      eindUur: eindUur,
      eindMinuut: eindMinuut,
    );

    if (overlap != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Dit tijdstip overlapt met:\n$overlap',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(14),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    final aansluitendePlanning = klant.planningDagen.where((planning) {
      if (!zelfdeDag(planning.datum, datum)) return false;

      final bestaandeStart = planning!.startUur * 60 + planning.startMinuut;
      final bestaandeEinde = planning.eindUur * 60 + planning.eindMinuut;
      final nieuweStart = startUur * 60 + startMinuut;
      final nieuweEinde = eindUur * 60 + eindMinuut;

      return bestaandeEinde == nieuweStart || nieuweEinde == bestaandeStart;
    }).toList();

    if (aansluitendePlanning.isNotEmpty) {
      final bestaande = aansluitendePlanning.first;

      final startMinuten = [
        bestaande.startUur * 60 + bestaande.startMinuut,
        startUur * 60 + startMinuut,
      ].reduce((a, b) => a < b ? a : b);

      final eindMinuten = [
        bestaande.eindUur * 60 + bestaande.eindMinuut,
        eindUur * 60 + eindMinuut,
      ].reduce((a, b) => a > b ? a : b);

      bestaande.startUur = startMinuten ~/ 60;
      bestaande.startMinuut = startMinuten % 60;
      bestaande.eindUur = eindMinuten ~/ 60;
      bestaande.eindMinuut = eindMinuten % 60;
    } else {
      klant.planningDagen.add(nieuwePlanning);
    }

    final plaatsingWasVerborgen =
        !toonPlanningKlanten && !klant.isNadienst && !klant.isOpTeVolgen;

    final nadienstWasVerborgen = klant.isNadienst && !toonNadienst;

    final opvolgingWasVerborgen = klant.isOpTeVolgen && !toonOpvolging;

    await AppStorage.bewaarKlanten(alleKlanten);
    await laadData();

    if (plaatsingWasVerborgen && mounted) {
      toonVerborgenAgendaMelding(
        naam: 'Plaatsing',
        zichtbaarMaken: () {
          setState(() {
            toonPlanningKlanten = true;
          });
        },
      );
    }

    if (nadienstWasVerborgen && mounted) {
      toonVerborgenAgendaMelding(
        naam: 'Nadienst',
        zichtbaarMaken: () {
          setState(() {
            toonNadienst = true;
          });
        },
      );
    }

    if (opvolgingWasVerborgen && mounted) {
      toonVerborgenAgendaMelding(
        naam: 'Op te volgen',
        zichtbaarMaken: () {
          setState(() {
            toonOpvolging = true;
          });
        },
      );
    }
  }

  Future<void> toonVerplaatsMenu({
    required _JaarItem item,
    required DateTime nieuweDatum,
  }) async {
    if (item.klant == null &&
        item.planningDag == null &&
        item.actie == null &&
        item.afspraak == null) {
      return;
    }

    final klant = item.klant;
    final planning = item.planningDag;
    final actie = item.actie;
    final afspraak = item.afspraak;

    final keuze = await showDialog<String>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: SizedBox(
            width: 320,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Wat wil je doen?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  ListTile(
                    leading: const Icon(Icons.open_with),
                    title: const Text('Verplaatsen'),
                    onTap: () => Navigator.pop(context, 'verplaatsen'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.copy),
                    title: const Text('Kopiëren'),
                    onTap: () => Navigator.pop(context, 'kopieren'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: const Text('Wissen'),
                    onTap: () => Navigator.pop(context, 'wissen'),
                  ),
                  if (actie == null && afspraak == null)
                    ListTile(
                      leading: const Icon(Icons.undo),
                      title: const Text('Terug naar in te plannen'),
                      onTap: () => Navigator.pop(context, 'terug'),
                    ),
                  ListTile(
                    leading: const Icon(Icons.close),
                    title: const Text('Annuleren'),
                    onTap: () => Navigator.pop(context, 'annuleren'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (keuze == null || keuze == 'annuleren') return;

    if (keuze == 'wissen' || keuze == 'terug') {
      if (klant != null && planning != null) {
        klant.planningDagen.remove(planning);
        await AppStorage.bewaarKlanten(alleKlanten);
      }

      if (actie != null) {
        agendaActies.removeWhere((a) => a.id == actie.id);
        await AppStorage.bewaarAgendaActies(agendaActies);
      }

      if (afspraak != null) {
        afsprakenKlanten.removeWhere((a) => a.id == afspraak.id);
        await AppStorage.bewaarAfsprakenKlanten(afsprakenKlanten);
      }

      await laadData();
      return;
    }

    if (actie != null) {
      if (keuze == 'verplaatsen') {
        actie.datum =
            DateTime(nieuweDatum.year, nieuweDatum.month, nieuweDatum.day);
        await AppStorage.bewaarAgendaActies(agendaActies);
        await laadData();
        return;
      }

      if (keuze == 'kopieren') {
        agendaActies.add(
          AgendaActie(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            titel: actie.titel,
            typeActie: actie.typeActie,
            datum:
                DateTime(nieuweDatum.year, nieuweDatum.month, nieuweDatum.day),
            toonOpDagtaak: actie.toonOpDagtaak,
            dagenVoorafTonen: actie.dagenVoorafTonen,
            weergaveType: actie.weergaveType,
            kleurNaam: actie.kleurNaam,
            icoonNaam: actie.icoonNaam,
            startUur: actie.startUur,
            startMinuut: actie.startMinuut,
            eindUur: actie.eindUur,
            eindMinuut: actie.eindMinuut,
            opmerkingen: actie.opmerkingen,
          ),
        );

        await AppStorage.bewaarAgendaActies(agendaActies);
        await laadData();
        return;
      }
    }

    if (afspraak != null) {
      if (keuze == 'verplaatsen') {
        int beginUur = afspraak.beginUur;
        int beginMinuut = afspraak.beginMinuut;
        int eindUur = afspraak.eindUur;
        int eindMinuut = afspraak.eindMinuut;

        final tijdKeuze = await toonTijdKeuzeMenu();

        if (tijdKeuze == null || tijdKeuze == 'annuleren') {
          return;
        }

        if (tijdKeuze == 'aanpassen') {
          final start = await kiesPlanningTijd(
            titel: 'Begintijd kiezen',
            startUur: beginUur,
            startMinuut: beginMinuut,
            datum: nieuweDatum,
          );

          if (start == null) return;

          final einde = await kiesPlanningTijd(
            titel: 'Eindtijd kiezen',
            startUur: eindUur,
            startMinuut: eindMinuut,
            datum: nieuweDatum,
          );

          if (einde == null) return;

          beginUur = start.hour;
          beginMinuut = start.minute;
          eindUur = einde.hour;
          eindMinuut = einde.minute;
        }

        afspraak.datum = DateTime(
          nieuweDatum.year,
          nieuweDatum.month,
          nieuweDatum.day,
        );

        afspraak.beginUur = beginUur;
        afspraak.beginMinuut = beginMinuut;
        afspraak.eindUur = eindUur;
        afspraak.eindMinuut = eindMinuut;

        await AppStorage.bewaarAfsprakenKlanten(afsprakenKlanten);
        await laadData();
        return;
      }

      if (keuze == 'kopieren') {
        int beginUur = afspraak.beginUur;
        int beginMinuut = afspraak.beginMinuut;
        int eindUur = afspraak.eindUur;
        int eindMinuut = afspraak.eindMinuut;

        final tijdKeuze = await toonTijdKeuzeMenu();

        if (tijdKeuze == null || tijdKeuze == 'annuleren') {
          return;
        }

        if (tijdKeuze == 'aanpassen') {
          final start = await kiesPlanningTijd(
            titel: 'Begintijd kiezen',
            startUur: beginUur,
            startMinuut: beginMinuut,
            datum: nieuweDatum,
          );

          if (start == null) return;

          final einde = await kiesPlanningTijd(
            titel: 'Eindtijd kiezen',
            startUur: eindUur,
            startMinuut: eindMinuut,
            datum: nieuweDatum,
          );

          if (einde == null) return;

          beginUur = start.hour;
          beginMinuut = start.minute;
          eindUur = einde.hour;
          eindMinuut = einde.minute;
        }

        afsprakenKlanten.add(
          AfspraakKlant(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            klantNr: afspraak.klantNr,
            klantNaam: afspraak.klantNaam,
            adres: afspraak.adres,
            telefoon: afspraak.telefoon,
            email: afspraak.email,
            datum: DateTime(
              nieuweDatum.year,
              nieuweDatum.month,
              nieuweDatum.day,
            ),
            ganseDag: afspraak.ganseDag,
            beginUur: beginUur,
            beginMinuut: beginMinuut,
            eindUur: eindUur,
            eindMinuut: eindMinuut,
            waarschuwing: afspraak.waarschuwing,
            notities: afspraak.notities,
          ),
        );

        await AppStorage.bewaarAfsprakenKlanten(afsprakenKlanten);
        await laadData();
        return;
      }
    }

    if (klant == null || planning == null) return;

    String? tijdKeuze;

    if (keuze == 'verplaatsen' || keuze == 'kopieren') {
      tijdKeuze = await toonTijdKeuzeMenu();
      if (tijdKeuze == null || tijdKeuze == 'annuleren') return;
    }

    int startUur = planning.startUur;
    int startMinuut = planning.startMinuut;
    int eindUur = planning.eindUur;
    int eindMinuut = planning.eindMinuut;

    if (tijdKeuze == 'aanpassen') {
      final start = await kiesPlanningTijd(
        titel: 'Starttijd kiezen',
        startUur: planning.startUur,
        startMinuut: planning.startMinuut,
        datum: nieuweDatum,
      );

      if (start == null) return;

      final einde = await kiesPlanningTijd(
        titel: 'Eindtijd kiezen',
        startUur: start.hour,
        startMinuut: start.minute,
        datum: nieuweDatum,
      );

      if (einde == null) return;

      startUur = start.hour;
      startMinuut = start.minute;
      eindUur = einde.hour;
      eindMinuut = einde.minute;
    }

    final controlePlanning = keuze == 'verplaatsen'
        ? planning
        : PlanningDag(
            datum: nieuweDatum,
            startUur: startUur,
            startMinuut: startMinuut,
            eindUur: eindUur,
            eindMinuut: eindMinuut,
          );

    final overlap = heeftOverlap(
      klant: klant,
      planning: controlePlanning,
      datum: nieuweDatum,
      startUur: startUur,
      startMinuut: startMinuut,
      eindUur: eindUur,
      eindMinuut: eindMinuut,
    );

    if (overlap) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Er is al een klantplanning op dit tijdstip.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (keuze == 'verplaatsen') {
      planning.datum = nieuweDatum;
      planning.startUur = startUur;
      planning.startMinuut = startMinuut;
      planning.eindUur = eindUur;
      planning.eindMinuut = eindMinuut;
    }

    if (keuze == 'kopieren') {
      klant.planningDagen.add(
        PlanningDag(
          datum: nieuweDatum,
          startUur: startUur,
          startMinuut: startMinuut,
          eindUur: eindUur,
          eindMinuut: eindMinuut,
        ),
      );
    }

    await AppStorage.bewaarKlanten(alleKlanten);
    await laadData();
  }

  void toonVerborgenAgendaMelding({
    required String naam,
    required VoidCallback zichtbaarMaken,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: SizedBox(
            width: 330,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.visibility_off,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Agenda verborgen',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$naam is toegevoegd, maar staat momenteel verborgen.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        zichtbaarMaken();
                        bewaarZichtbaarheid();
                        Navigator.pop(dialogContext);
                      },
                      icon: const Icon(Icons.visibility),
                      label: const Text('Zichtbaar maken'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE7F6EC),
                        foregroundColor: const Color(0xFF0B7A3B),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget filterRegel({
    required String tekst,
    required Color kleur,
    required IconData icoon,
    required bool zichtbaar,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: kleur,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            Icon(icoon, size: 18, color: kleur),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                tekst,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: zichtbaar ? Colors.black : Colors.grey,
                  decoration: zichtbaar
                      ? TextDecoration.none
                      : TextDecoration.lineThrough,
                ),
              ),
            ),
            Icon(
              zichtbaar ? Icons.visibility : Icons.visibility_off,
              color: zichtbaar ? Colors.green : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget filterUitvalMenu() {
    if (!toonFilterMenu) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          filterRegel(
            tekst: 'Plaatsing',
            kleur: Colors.green,
            icoon: Icons.business,
            zichtbaar: toonPlanningKlanten,
            onTap: () {
              setState(() {
                toonPlanningKlanten = !toonPlanningKlanten;
              });
              bewaarZichtbaarheid();
            },
          ),
          filterRegel(
            tekst: 'Nadienst',
            kleur: Colors.purple,
            icoon: Icons.support_agent,
            zichtbaar: toonNadienst,
            onTap: () {
              setState(() {
                toonNadienst = !toonNadienst;
              });
              bewaarZichtbaarheid();
            },
          ),
          filterRegel(
            tekst: 'Op te volgen',
            kleur: const Color(0xFF0F766E),
            icoon: Icons.pending_actions,
            zichtbaar: toonOpvolging,
            onTap: () {
              setState(() {
                toonOpvolging = !toonOpvolging;
              });
              bewaarZichtbaarheid();
            },
          ),
          filterRegel(
            tekst: 'Afspraak klant',
            kleur: Colors.blue,
            icoon: Icons.event_available,
            zichtbaar: toonAfspraken,
            onTap: () {
              setState(() {
                toonAfspraken = !toonAfspraken;
              });
              bewaarZichtbaarheid();
            },
          ),
          filterRegel(
            tekst: 'Dagtaak plaatsers',
            kleur: Colors.orange,
            icoon: Icons.task_alt,
            zichtbaar: toonDagTaken,
            onTap: () {
              setState(() {
                toonDagTaken = !toonDagTaken;
              });
              bewaarZichtbaarheid();
            },
          ),
          filterRegel(
            tekst: 'Kraanreservatie',
            kleur: Colors.brown,
            icoon: Icons.precision_manufacturing,
            zichtbaar: toonKraan,
            onTap: () {
              setState(() {
                toonKraan = !toonKraan;
              });
              bewaarZichtbaarheid();
            },
          ),
          filterRegel(
            tekst: 'Verlof',
            kleur: Colors.red,
            icoon: Icons.beach_access,
            zichtbaar: toonVakantie,
            onTap: () {
              setState(() {
                toonVakantie = !toonVakantie;
              });
              bewaarZichtbaarheid();
            },
          ),
        ],
      ),
    );
  }

  Widget groeneBalk() {
    final aantalInTePlannen = inTePlannenKlanten().length;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0B7A3B),
            Color(0xFF23B15F),
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Terug',
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            iconSize: 26,
          ),
          Expanded(
            child: Center(
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.calendar_month,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  'Ga naarWeek/maand            $jaar',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'In te plannen',
            onPressed: () {
              setState(() {
                toonInTePlannenMenu = !toonInTePlannenMenu;
              });
            },
            icon: Badge(
              label: Text('$aantalInTePlannen'),
              child: Icon(
                toonInTePlannenMenu
                    ? Icons.playlist_add_check_circle
                    : Icons.playlist_add_check,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Agenda zichtbaarheden',
            onPressed: () {
              setState(() {
                toonFilterMenu = !toonFilterMenu;
              });
            },
            icon: Icon(
              toonFilterMenu ? Icons.visibility_off : Icons.visibility,
              color: Colors.white,
              size: 25,
            ),
          ),
        ],
      ),
    );
  }

  Widget linkerDagKolom({
    required int weekDagIndex,
    required bool isWeekend,
  }) {
    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isWeekend ? Colors.grey.shade300 : Colors.grey.shade100,
        border: Border(
          right: BorderSide(color: Colors.grey.shade300),
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        dagenKort[weekDagIndex][0],
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget jaarItemTegel(_JaarItem item, DateTime datum) {
    return GestureDetector(
      onTap: () async {
        await toonVerplaatsMenu(
          item: item,
          nieuweDatum: datum,
        );
      },
      child: Container(
        height: 22,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: item.achtergrond,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: item.kleur.withValues(alpha: 0.55),
          ),
        ),
        child: Text(
          item.tekst,
          maxLines: 1,
          overflow: TextOverflow.visible,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: item.kleur,
          ),
        ),
      ),
    );
  }
}

class _JaarItem {
  final String tekst;
  final Color kleur;
  final Color achtergrond;

  final Klant? klant;
  final PlanningDag? planningDag;
  final AgendaActie? actie;
  final AfspraakKlant? afspraak;

  _JaarItem({
    required this.tekst,
    required this.kleur,
    required this.achtergrond,
    this.klant,
    this.planningDag,
    this.actie,
    this.afspraak,
  });
}
