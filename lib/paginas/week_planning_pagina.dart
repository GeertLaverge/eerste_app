import 'package:flutter/material.dart';

import '../modellen/klant.dart';
import '../modellen/planning_dag.dart';
import '../helpers/widgets/onder_navigatie_balk.dart';

class WeekPlanningPagina extends StatefulWidget {
  final DateTime geselecteerdeDag;
  final Klant klant;
  final List<Klant> alleKlanten;
  final List<DateTime> vakantieDagen;
  final Future<void> Function() onBewaren;

  const WeekPlanningPagina({
    super.key,
    required this.geselecteerdeDag,
    required this.klant,
    required this.alleKlanten,
    required this.vakantieDagen,
    required this.onBewaren,
  });

  @override
  State<WeekPlanningPagina> createState() => _WeekPlanningPaginaState();
}

class _PlanningInfo {
  final Klant klant;
  final PlanningDag planning;

  _PlanningInfo({
    required this.klant,
    required this.planning,
  });
}

class _WeekPlanningPaginaState extends State<WeekPlanningPagina> {
  final Set<String> geselecteerdeSlots = {};

  bool? sleepSelecteert;
  int? laatsteDagIndex;
  int? laatsteSlotIndex;

  PlanningDag? planningInWijziging;
  PlanningDag? planningInVerplaatsing;
  PlanningDag? planningInResize;

  bool resizeBovenkant = false;
  double resizeOpgespaardePixels = 0;

  static const int startUur = 6;
  static const int eindUur = 18;
  static const double slotHoogte = 34;
  static const double tijdKolomBreedte = 58;

  String slotKey(DateTime dag, int minutenVanafStart) {
    final datum = DateTime(dag.year, dag.month, dag.day);
    return '${datum.millisecondsSinceEpoch}|$minutenVanafStart';
  }

  bool zelfdeDag(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool isVakantieDag(DateTime dag) {
    return widget.vakantieDagen.any(
      (vakantieDag) => zelfdeDag(vakantieDag, dag),
    );
  }

  String klantNaam(Klant klant) {
    return klant.klantnaam.trim().isEmpty
        ? 'Klant zonder naam'
        : klant.klantnaam;
  }

  String dagNaam(int weekday) {
    const namen = ['Ma', 'Di', 'Wo', 'Do', 'Vr', 'Za', 'Zo'];
    return namen[weekday - 1];
  }

  String datumKort(DateTime datum) {
    return '${datum.day.toString().padLeft(2, '0')}/'
        '${datum.month.toString().padLeft(2, '0')}';
  }

  String tijdTekst(int uur, int minuut) {
    return '${uur.toString().padLeft(2, '0')}:'
        '${minuut.toString().padLeft(2, '0')}';
  }

  String tijdTekstVanafMinuten(int minutenVanafStart) {
    final totaalMinuten = (startUur * 60) + minutenVanafStart;
    final uur = totaalMinuten ~/ 60;
    final minuut = totaalMinuten % 60;
    return tijdTekst(uur, minuut);
  }

  int planningStartMinuten(PlanningDag planning) {
    return planning.startUur * 60 + planning.startMinuut;
  }

  int planningEindMinuten(PlanningDag planning) {
    return planning.eindUur * 60 + planning.eindMinuut;
  }

  int planningDuurMinuten(PlanningDag planning) {
    return planningEindMinuten(planning) - planningStartMinuten(planning);
  }

  bool isSlotGeselecteerd(DateTime dag, int minutenVanafStart) {
    return geselecteerdeSlots.contains(slotKey(dag, minutenVanafStart));
  }

  _PlanningInfo? planningVoorSlot(
    DateTime dag,
    int minutenVanafStart, {
    PlanningDag? negeerPlanning,
  }) {
    final slotStart = startUur * 60 + minutenVanafStart;
    final slotEind = slotStart + 30;

    for (final klant in widget.alleKlanten) {
      for (final planning in klant.planningDagen) {
        if (planning == negeerPlanning) continue;
        if (!zelfdeDag(planning.datum, dag)) continue;

        final pStart = planningStartMinuten(planning);
        final pEind = planningEindMinuten(planning);

        if (slotStart < pEind && slotEind > pStart) {
          return _PlanningInfo(
            klant: klant,
            planning: planning,
          );
        }
      }
    }

    return null;
  }

  bool isBezetVoorNieuweKeuze(DateTime dag, int minutenVanafStart) {
    final negeer = planningInVerplaatsing;

    return planningVoorSlot(
          dag,
          minutenVanafStart,
          negeerPlanning: negeer,
        ) !=
        null;
  }

  bool periodeVrijVoorPlanning({
    required DateTime dag,
    required int absoluteStart,
    required int absoluteEind,
    required PlanningDag planning,
  }) {
    if (absoluteStart < startUur * 60) return false;
    if (absoluteEind > eindUur * 60) return false;
    if (absoluteEind <= absoluteStart) return false;
    if (absoluteEind - absoluteStart < 30) return false;
    if (isVakantieDag(dag)) return false;

    for (int minuut = absoluteStart; minuut < absoluteEind; minuut += 30) {
      final minutenVanafStart = minuut - (startUur * 60);

      final bezet = planningVoorSlot(
        dag,
        minutenVanafStart,
        negeerPlanning: planning,
      );

      if (bezet != null) return false;
    }

    return true;
  }

  Future<void> resizePlanningMetSleep({
    required PlanningDag planning,
    required bool bovenkant,
    required double deltaY,
  }) async {
    resizeOpgespaardePixels += deltaY;

    if (resizeOpgespaardePixels.abs() < slotHoogte) return;

    final stappen = resizeOpgespaardePixels ~/ slotHoogte;
    resizeOpgespaardePixels -= stappen * slotHoogte;

    final huidigeStart = planningStartMinuten(planning);
    final huidigeEind = planningEindMinuten(planning);

    int nieuweStart = huidigeStart;
    int nieuweEind = huidigeEind;

    if (bovenkant) {
      nieuweStart = huidigeStart + (stappen * 30);

      if (nieuweStart >= huidigeEind - 30) return;
    } else {
      nieuweEind = huidigeEind + (stappen * 30);

      if (nieuweEind <= huidigeStart + 30) return;
    }

    final mag = periodeVrijVoorPlanning(
      dag: planning.datum,
      absoluteStart: nieuweStart,
      absoluteEind: nieuweEind,
      planning: planning,
    );

    if (!mag) return;

    setState(() {
      planning.startUur = nieuweStart ~/ 60;
      planning.startMinuut = nieuweStart % 60;
      planning.eindUur = nieuweEind ~/ 60;
      planning.eindMinuut = nieuweEind % 60;
    });
  }

  Future<void> stopResizePlanning() async {
    final planning = planningInResize;

    planningInResize = null;
    resizeOpgespaardePixels = 0;

    if (planning == null) return;

    await widget.onBewaren();

    if (mounted) {
      setState(() {});
    }
  }

  void pasSlotAan(DateTime dag, int slotIndex) {
    final minutenVanafStart = slotIndex * 30;

    if (isBezetVoorNieuweKeuze(dag, minutenVanafStart)) return;

    final key = slotKey(dag, minutenVanafStart);

    if (sleepSelecteert == true) {
      geselecteerdeSlots.add(key);
    } else {
      geselecteerdeSlots.remove(key);
    }
  }

  void vulVerplaatsPreview(DateTime dag, int startSlotIndex, int aantalSlots) {
    final nieuweSlots = <String>{};

    for (var i = 0; i < aantalSlots; i++) {
      final slotIndex = startSlotIndex + i;
      final minutenVanafStart = slotIndex * 30;

      if (slotIndex < 0) return;
      if (minutenVanafStart >= (eindUur - startUur) * 60) return;

      if (isBezetVoorNieuweKeuze(dag, minutenVanafStart)) return;

      nieuweSlots.add(slotKey(dag, minutenVanafStart));
    }

    setState(() {
      geselecteerdeSlots
        ..clear()
        ..addAll(nieuweSlots);
    });
  }

  Map<DateTime, List<int>> groepeerGeselecteerdeSlotsPerDag() {
    final Map<DateTime, List<int>> slotsPerDag = {};

    for (final key in geselecteerdeSlots) {
      final parts = key.split('|');
      final datum = DateTime.fromMillisecondsSinceEpoch(int.parse(parts[0]));
      final minuten = int.parse(parts[1]);

      final dag = DateTime(datum.year, datum.month, datum.day);

      slotsPerDag.putIfAbsent(dag, () => []);
      slotsPerDag[dag]!.add(minuten);
    }

    return slotsPerDag;
  }

  Future<void> slaSelectieOpAlsPlanning() async {
    if (geselecteerdeSlots.isEmpty) return;

    final slotsPerDag = groepeerGeselecteerdeSlotsPerDag();

    if (planningInVerplaatsing != null) {
      if (slotsPerDag.length != 1) return;

      final planning = planningInVerplaatsing!;
      final entry = slotsPerDag.entries.first;
      final dag = entry.key;
      final lijst = entry.value..sort();

      final start = lijst.first;
      final duur = planningDuurMinuten(planning);

      final absoluteStart = (startUur * 60) + start;
      final absoluteEind = absoluteStart + duur;

      setState(() {
        planning.datum = dag;
        planning.startUur = absoluteStart ~/ 60;
        planning.startMinuut = absoluteStart % 60;
        planning.eindUur = absoluteEind ~/ 60;
        planning.eindMinuut = absoluteEind % 60;

        planningInVerplaatsing = null;
        geselecteerdeSlots.clear();
      });

      await widget.onBewaren();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Planning verplaatst.'),
          backgroundColor: Colors.green,
        ),
      );

      return;
    }

    for (final entry in slotsPerDag.entries) {
      final dag = entry.key;
      final lijst = entry.value..sort();

      final start = lijst.first;
      final eind = lijst.last + 30;

      final absoluteStart = (startUur * 60) + start;
      final absoluteEind = (startUur * 60) + eind;

      widget.klant.planningDagen.add(
        PlanningDag(
          datum: dag,
          startUur: absoluteStart ~/ 60,
          startMinuut: absoluteStart % 60,
          eindUur: absoluteEind ~/ 60,
          eindMinuut: absoluteEind % 60,
        ),
      );
    }

    await widget.onBewaren();

    if (!mounted) return;

    setState(() {
      geselecteerdeSlots.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Planning opgeslagen.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> verwijderPlanning(PlanningDag planning) async {
    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Planning verwijderen'),
          content: const Text('Wil je deze planning verwijderen?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Nee'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ja, verwijderen'),
            ),
          ],
        );
      },
    );

    if (bevestigen != true) return;

    setState(() {
      for (final klant in widget.alleKlanten) {
        klant.planningDagen.removeWhere((item) {
          return item == planning ||
              (zelfdeDag(item.datum, planning.datum) &&
                  item.startUur == planning.startUur &&
                  item.startMinuut == planning.startMinuut &&
                  item.eindUur == planning.eindUur &&
                  item.eindMinuut == planning.eindMinuut);
        });
      }

      if (planningInWijziging == planning) planningInWijziging = null;
      if (planningInVerplaatsing == planning) planningInVerplaatsing = null;

      geselecteerdeSlots.clear();
    });
    await widget.onBewaren();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Planning verwijderd.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void startWijzigmodus(PlanningDag planning) {
    setState(() {
      planningInWijziging = planning;
      planningInVerplaatsing = null;
      geselecteerdeSlots.clear();
      sleepSelecteert = null;
      laatsteDagIndex = null;
      laatsteSlotIndex = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sleep de pijltjes bovenaan of onderaan het blok.'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void startVerplaatsmodus(PlanningDag planning) {
    setState(() {
      planningInVerplaatsing = planning;
      planningInWijziging = null;
      geselecteerdeSlots.clear();
      sleepSelecteert = true;
      laatsteDagIndex = null;
      laatsteSlotIndex = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sleep het blok naar een nieuwe plaats.'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void annuleerModus() {
    setState(() {
      planningInWijziging = null;
      planningInVerplaatsing = null;
      planningInResize = null;
      geselecteerdeSlots.clear();
      sleepSelecteert = null;
      laatsteDagIndex = null;
      laatsteSlotIndex = null;
      resizeOpgespaardePixels = 0;
    });
  }

  Future<void> toonPlanningMenu(PlanningDag planning) async {
    final keuze = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.open_with, color: Colors.green),
                title: const Text('Verplaatsen'),
                subtitle: const Text('Sleep daarna naar een andere plaats'),
                onTap: () => Navigator.pop(context, 'verplaatsen'),
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Tijd aanpassen'),
                subtitle: const Text('Sleep daarna boven- of onderrand'),
                onTap: () => Navigator.pop(context, 'tijd'),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Planning verwijderen'),
                onTap: () => Navigator.pop(context, 'verwijderen'),
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Annuleren'),
                onTap: () => Navigator.pop(context, 'annuleren'),
              ),
            ],
          ),
        );
      },
    );

    if (keuze == 'verwijderen') {
      await verwijderPlanning(planning);
    }

    if (keuze == 'verplaatsen') {
      startVerplaatsmodus(planning);
    }

    if (keuze == 'tijd') {
      startWijzigmodus(planning);
    }
  }

  List<_PlanningInfo> planningenVanWeek(List<DateTime> dagen) {
    final resultaat = <_PlanningInfo>[];

    for (final klant in widget.alleKlanten) {
      for (final planning in klant.planningDagen) {
        final zitInWeek = dagen.any((dag) => zelfdeDag(dag, planning.datum));

        if (zitInWeek) {
          resultaat.add(
            _PlanningInfo(
              klant: klant,
              planning: planning,
            ),
          );
        }
      }
    }

    return resultaat;
  }

  @override
  Widget build(BuildContext context) {
    final startWeek = DateTime(
      widget.geselecteerdeDag.year,
      widget.geselecteerdeDag.month,
      widget.geselecteerdeDag.day,
    ).subtract(
      Duration(days: widget.geselecteerdeDag.weekday - 1),
    );

    final dagen = List.generate(
      7,
      (index) => startWeek.add(Duration(days: index)),
    );

    final aantalSlots = (eindUur - startUur) * 2;
    final totaleHoogte = aantalSlots * slotHoogte;

    void verwerkSleepPositie(
      Offset localPosition,
      double beschikbareBreedte,
    ) {
      if (planningInWijziging != null) return;
      if (planningInResize != null) return;

      final x = localPosition.dx - tijdKolomBreedte;
      final y = localPosition.dy;

      if (x < 0 || y < 0) return;

      final dagBreedte = beschikbareBreedte / 7;
      final dagIndex = (x / dagBreedte).floor();
      final slotIndex = (y / slotHoogte).floor();

      if (dagIndex < 0 || dagIndex >= 7) return;
      if (slotIndex < 0 || slotIndex >= aantalSlots) return;

      final dag = dagen[dagIndex];
      if (isVakantieDag(dag)) return;

      if (planningInVerplaatsing != null) {
        final duur = planningDuurMinuten(planningInVerplaatsing!);
        final aantalDuurSlots = (duur / 30).ceil();

        vulVerplaatsPreview(dag, slotIndex, aantalDuurSlots);
        return;
      }

      final minutenVanafStart = slotIndex * 30;

      if (isBezetVoorNieuweKeuze(dag, minutenVanafStart)) return;

      final key = slotKey(dag, minutenVanafStart);
      sleepSelecteert ??= !geselecteerdeSlots.contains(key);

      setState(() {
        if (laatsteDagIndex != null && laatsteSlotIndex != null) {
          if (laatsteDagIndex == dagIndex) {
            final van =
                laatsteSlotIndex! < slotIndex ? laatsteSlotIndex! : slotIndex;
            final tot =
                laatsteSlotIndex! > slotIndex ? laatsteSlotIndex! : slotIndex;

            for (var i = van; i <= tot; i++) {
              pasSlotAan(dagen[dagIndex], i);
            }
          } else {
            pasSlotAan(dag, slotIndex);
          }
        } else {
          pasSlotAan(dag, slotIndex);
        }

        laatsteDagIndex = dagIndex;
        laatsteSlotIndex = slotIndex;
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      bottomNavigationBar: OnderNavigatieBalk(
        huidigePagina: 'andere',
        onAgenda: () {
          Navigator.popUntil(context, (route) => route.isFirst);
          // later eventueel rechtstreeks naar agenda
        },
        onKlanten: () {
          Navigator.popUntil(context, (route) => route.isFirst);
          // later eventueel rechtstreeks naar klanten
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
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
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      planningInVerplaatsing != null
                          ? 'Planning verplaatsen'
                          : planningInWijziging != null
                              ? 'Planning wijzigen'
                              : 'Weekplanning',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (planningInWijziging != null ||
                      planningInVerplaatsing != null)
                    TextButton(
                      onPressed: annuleerModus,
                      child: Text(
                        planningInWijziging != null ? 'Klaar' : 'Annuleer',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            if (planningInWijziging != null || planningInVerplaatsing != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.blue.withValues(alpha: 0.10),
                child: Text(
                  planningInVerplaatsing != null
                      ? 'Verplaatsmodus actief: sleep naar een vrije plaats.'
                      : 'Tijd aanpassen: sleep de pijltjes bovenaan of onderaan het blok.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(58, 10, 8, 10),
              child: Row(
                children: dagen.map((dag) {
                  final actief = dag.year == widget.geselecteerdeDag.year &&
                      dag.month == widget.geselecteerdeDag.month &&
                      dag.day == widget.geselecteerdeDag.day;

                  return Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: actief
                            ? Colors.green.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            dagNaam(dag.weekday),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: actief ? Colors.green : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            datumKort(dag),
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  actief ? Colors.green : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final beschikbareBreedte =
                      constraints.maxWidth - tijdKolomBreedte;
                  final dagBreedte = beschikbareBreedte / 7;

                  final planningBlokken = planningenVanWeek(dagen).map((info) {
                    final dagIndex = dagen.indexWhere(
                      (dag) => zelfdeDag(dag, info.planning.datum),
                    );

                    if (dagIndex < 0) return const SizedBox.shrink();

                    final absoluteStart = planningStartMinuten(info.planning);
                    final absoluteEind = planningEindMinuten(info.planning);

                    final top =
                        ((absoluteStart - (startUur * 60)) / 30) * slotHoogte;
                    final hoogte =
                        ((absoluteEind - absoluteStart) / 30) * slotHoogte;

                    final isHuidigeKlant = info.klant == widget.klant;
                    final isInWijziging = planningInWijziging == info.planning;
                    final isInVerplaatsing =
                        planningInVerplaatsing == info.planning;

                    final kleur = isHuidigeKlant
                        ? Colors.green.withValues(alpha: 0.82)
                        : Colors.orange.withValues(alpha: 0.76);

                    final rand = isInWijziging || isInVerplaatsing
                        ? Colors.blue
                        : isHuidigeKlant
                            ? Colors.green
                            : Colors.orange;

                    return Positioned(
                      top: top,
                      left: tijdKolomBreedte + (dagIndex * dagBreedte) + 3,
                      width: dagBreedte - 6,
                      height: hoogte < slotHoogte ? slotHoogte : hoogte,
                      child: GestureDetector(
                        onTap: () async {
                          if (!isHuidigeKlant) return;
                          await toonPlanningMenu(info.planning);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: kleur,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: rand,
                              width: isInWijziging || isInVerplaatsing ? 2 : 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        klantNaam(info.klant),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${tijdTekst(
                                          info.planning.startUur,
                                          info.planning.startMinuut,
                                        )} - ${tijdTekst(
                                          info.planning.eindUur,
                                          info.planning.eindMinuut,
                                        )}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (isHuidigeKlant && isInWijziging)
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onVerticalDragStart: (_) {
                                      planningInResize = info.planning;
                                      resizeBovenkant = true;
                                      resizeOpgespaardePixels = 0;
                                    },
                                    onVerticalDragUpdate: (details) async {
                                      await resizePlanningMetSleep(
                                        planning: info.planning,
                                        bovenkant: true,
                                        deltaY: details.delta.dy,
                                      );
                                    },
                                    onVerticalDragEnd: (_) async {
                                      await stopResizePlanning();
                                    },
                                    child: Container(
                                      height: 26,
                                      alignment: Alignment.topCenter,
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.keyboard_arrow_up,
                                            color: Colors.white,
                                            size: 17,
                                          ),
                                          Icon(
                                            Icons.keyboard_arrow_down,
                                            color: Colors.white,
                                            size: 17,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              if (isHuidigeKlant && isInWijziging)
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onVerticalDragStart: (_) {
                                      planningInResize = info.planning;
                                      resizeBovenkant = false;
                                      resizeOpgespaardePixels = 0;
                                    },
                                    onVerticalDragUpdate: (details) async {
                                      await resizePlanningMetSleep(
                                        planning: info.planning,
                                        bovenkant: false,
                                        deltaY: details.delta.dy,
                                      );
                                    },
                                    onVerticalDragEnd: (_) async {
                                      await stopResizePlanning();
                                    },
                                    child: Container(
                                      height: 26,
                                      alignment: Alignment.bottomCenter,
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.keyboard_arrow_up,
                                            color: Colors.white,
                                            size: 17,
                                          ),
                                          Icon(
                                            Icons.keyboard_arrow_down,
                                            color: Colors.white,
                                            size: 17,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList();

                  return SingleChildScrollView(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: (details) {
                        if (planningInWijziging != null) return;
                        if (planningInResize != null) return;

                        sleepSelecteert = null;
                        laatsteDagIndex = null;
                        laatsteSlotIndex = null;

                        verwerkSleepPositie(
                          details.localPosition,
                          beschikbareBreedte,
                        );
                      },
                      onPanUpdate: (details) {
                        if (planningInWijziging != null) return;
                        if (planningInResize != null) return;

                        verwerkSleepPositie(
                          details.localPosition,
                          beschikbareBreedte,
                        );
                      },
                      onPanEnd: (_) async {
                        if (planningInWijziging != null) return;
                        if (planningInResize != null) return;

                        sleepSelecteert = null;
                        laatsteDagIndex = null;
                        laatsteSlotIndex = null;

                        await slaSelectieOpAlsPlanning();
                      },
                      child: SizedBox(
                        height: totaleHoogte,
                        child: Stack(
                          children: [
                            Column(
                              children: List.generate(aantalSlots, (index) {
                                final minutenVanafStart = index * 30;
                                final isVolUur = minutenVanafStart % 60 == 0;

                                return SizedBox(
                                  height: slotHoogte,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: tijdKolomBreedte,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5),
                                          child: Text(
                                            isVolUur
                                                ? tijdTekstVanafMinuten(
                                                    minutenVanafStart,
                                                  )
                                                : '',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      ...dagen.map((dag) {
                                        final geselecteerd = isSlotGeselecteerd(
                                          dag,
                                          minutenVanafStart,
                                        );

                                        final vakantie = isVakantieDag(dag);

                                        Color kleur = Colors.white;
                                        Color rand = Colors.grey.shade200;

                                        if (vakantie) {
                                          kleur = Colors.red.withValues(
                                            alpha: 0.14,
                                          );
                                          rand = Colors.red.shade200;
                                        }

                                        if (geselecteerd) {
                                          kleur = Colors.green.withValues(
                                            alpha: 0.70,
                                          );
                                          rand = Colors.green;
                                        }

                                        return Expanded(
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 1.5,
                                              vertical: 1.5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: kleur,
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              border: Border.all(color: rand),
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                );
                              }),
                            ),
                            ...planningBlokken,
                          ],
                        ),
                      ),
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
}
