import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../lib/modellen/klant.dart';
import '../../lib/modellen/planning_dag.dart';
import 'week_planning_pagina.dart';
import '../../lib/helpers/widgets/onder_navigatie_balk.dart';

class KlantPlanningPagina extends StatefulWidget {
  final Klant klant;
  final List<Klant> alleKlanten;
  final List<DateTime> vakantieDagen;
  final Future<void> Function() onBewaren;

  const KlantPlanningPagina({
    super.key,
    required this.klant,
    required this.alleKlanten,
    required this.vakantieDagen,
    required this.onBewaren,
  });

  @override
  State<KlantPlanningPagina> createState() => _KlantPlanningPaginaState();
}

class _KlantPlanningPaginaState extends State<KlantPlanningPagina> {
  DateTime focusMaand = DateTime(DateTime.now().year, DateTime.now().month);
  final List<DateTime> geselecteerdeDagen = [];

  int startUur = 7;
  int startMinuut = 0;
  int eindUur = 15;
  int eindMinuut = 30;

  DateTime zonderTijd(DateTime datum) {
    return DateTime(datum.year, datum.month, datum.day);
  }

  bool zelfdeDag(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool isVakantieDag(DateTime dag) {
    return widget.vakantieDagen.any((v) => zelfdeDag(v, dag));
  }

  bool isGeselecteerd(DateTime dag) {
    return geselecteerdeDagen.any((item) => zelfdeDag(item, dag));
  }

  String datumTekst(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  String tijdTekst(int uur, int minuut) {
    return '${uur.toString().padLeft(2, '0')}:'
        '${minuut.toString().padLeft(2, '0')}';
  }

  String maandNaam(int maand) {
    const maanden = [
      'januari',
      'februari',
      'maart',
      'april',
      'mei',
      'juni',
      'juli',
      'augustus',
      'september',
      'oktober',
      'november',
      'december',
    ];

    return maanden[maand - 1];
  }

  String klantNaam(Klant klant) {
    return klant.klantnaam.trim().isEmpty
        ? 'Klant zonder naam'
        : klant.klantnaam;
  }

  int minutenVanPlanningStart(PlanningDag planning) {
    return planning.startUur * 60 + planning.startMinuut;
  }

  int minutenVanPlanningEinde(PlanningDag planning) {
    return planning.eindUur * 60 + planning.eindMinuut;
  }

  int nieuweStartMinuten() {
    return startUur * 60 + startMinuut;
  }

  int nieuweEindMinuten() {
    return eindUur * 60 + eindMinuut;
  }

  bool overlaptMetNieuwePlanning(PlanningDag planning) {
    final nieuwStart = nieuweStartMinuten();
    final nieuwEind = nieuweEindMinuten();

    final bestaandStart = minutenVanPlanningStart(planning);
    final bestaandEind = minutenVanPlanningEinde(planning);

    return nieuwStart < bestaandEind && nieuwEind > bestaandStart;
  }

  String? checkOverlapMetBestaandePlanning(DateTime dag) {
    for (final klant in widget.alleKlanten) {
      for (final planning in klant.planningDagen) {
        if (!zelfdeDag(planning.datum, dag)) continue;

        if (overlaptMetNieuwePlanning(planning)) {
          return '${klantNaam(klant)} '
              '(${tijdTekst(planning.startUur, planning.startMinuut)} - '
              '${tijdTekst(planning.eindUur, planning.eindMinuut)})';
        }
      }
    }

    return null;
  }

  List<String> klantenNamenOpDag(DateTime dag) {
    final namen = <String>[];

    for (final klant in widget.alleKlanten) {
      for (final planning in klant.planningDagen) {
        if (zelfdeDag(planning.datum, dag)) {
          namen.add(
            '${klantNaam(klant)} '
            '${tijdTekst(planning.startUur, planning.startMinuut)}-'
            '${tijdTekst(planning.eindUur, planning.eindMinuut)}',
          );
        }
      }
    }

    return namen;
  }

  bool klantAlGeplandOpDag(DateTime dag) {
    return widget.klant.planningDagen.any(
      (planning) => zelfdeDag(planning.datum, dag),
    );
  }

  Future<void> wisselDagSelectie(DateTime dag) async {
    final zuivereDag = zonderTijd(dag);

    if (isVakantieDag(zuivereDag)) {
      toonFout('Niet mogelijk: verlofdag.');
      return;
    }

    setState(() {
      if (isGeselecteerd(zuivereDag)) {
        geselecteerdeDagen.removeWhere(
          (item) => zelfdeDag(item, zuivereDag),
        );
      } else {
        geselecteerdeDagen.add(zuivereDag);
      }
    });
  }

  Future<TimeOfDay?> kiesTijd({
    required int uur,
    required int minuut,
  }) async {
    int gekozenUur = uur;
    int gekozenMinuut = minuut;

    final uurController = FixedExtentScrollController(initialItem: uur);
    final minuutController = FixedExtentScrollController(initialItem: minuut);

    final resultaat = await showModalBottomSheet<TimeOfDay>(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 310,
          child: Column(
            children: [
              Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuleer'),
                    ),
                    const Spacer(),
                    const Text(
                      'Tijd kiezen',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          TimeOfDay(
                            hour: gekozenUur,
                            minute: gekozenMinuut,
                          ),
                        );
                      },
                      child: const Text('Klaar'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: uurController,
                        itemExtent: 42,
                        onSelectedItemChanged: (waarde) {
                          gekozenUur = waarde;
                        },
                        children: List.generate(
                          24,
                          (index) => Center(
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      ':',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: minuutController,
                        itemExtent: 42,
                        onSelectedItemChanged: (waarde) {
                          gekozenMinuut = waarde;
                        },
                        children: List.generate(
                          60,
                          (index) => Center(
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    uurController.dispose();
    minuutController.dispose();

    return resultaat;
  }

  Future<void> kiesStartTijd() async {
    final gekozen = await kiesTijd(
      uur: startUur,
      minuut: startMinuut,
    );

    if (gekozen == null) return;

    setState(() {
      startUur = gekozen.hour;
      startMinuut = gekozen.minute;
      geselecteerdeDagen.clear();
    });
  }

  Future<void> kiesEindTijd() async {
    final gekozen = await kiesTijd(
      uur: eindUur,
      minuut: eindMinuut,
    );

    if (gekozen == null) return;

    setState(() {
      eindUur = gekozen.hour;
      eindMinuut = gekozen.minute;
      geselecteerdeDagen.clear();
    });
  }

  void toonFout(String tekst) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tekst),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> opslaan() async {
    final start = startUur * 60 + startMinuut;
    final eind = eindUur * 60 + eindMinuut;

    if (geselecteerdeDagen.isEmpty) {
      toonFout('Selecteer minstens één dag.');
      return;
    }

    if (eind <= start) {
      toonFout('Eindtijd moet later zijn dan begintijd.');
      return;
    }

    for (final dag in geselecteerdeDagen) {
      if (isVakantieDag(dag)) {
        toonFout('Je kan geen klant inplannen op een verlofdag.');
        return;
      }

      final conflict = checkOverlapMetBestaandePlanning(dag);
      if (conflict != null) {
        toonFout('Conflict op ${datumTekst(dag)} met: $conflict');
        return;
      }
    }

    for (final dag in geselecteerdeDagen) {
      widget.klant.planningDagen.add(
        PlanningDag(
          datum: DateTime(dag.year, dag.month, dag.day),
          startUur: startUur,
          startMinuut: startMinuut,
          eindUur: eindUur,
          eindMinuut: eindMinuut,
        ),
      );
    }

    await widget.onBewaren();

    if (!mounted) return;

    setState(() {
      geselecteerdeDagen.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Klant is ingepland.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget groeneBalk() {
    return Container(
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
          const Expanded(
            child: Text(
              'Klant in agenda plaatsen',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget kaart({
    required String titel,
    required IconData icoon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icoon, color: Colors.green),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titel,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget maandHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              focusMaand = DateTime(focusMaand.year, focusMaand.month - 1);
            });
          },
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Center(
            child: Text(
              '${maandNaam(focusMaand.month)} ${focusMaand.year}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              focusMaand = DateTime(focusMaand.year, focusMaand.month + 1);
            });
          },
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget kalender() {
    final eersteVanMaand = DateTime(focusMaand.year, focusMaand.month, 1);
    final laatsteVanMaand = DateTime(focusMaand.year, focusMaand.month + 1, 0);

    final eersteRasterDag = eersteVanMaand.subtract(
      Duration(days: eersteVanMaand.weekday - 1),
    );

    final laatsteRasterDag = laatsteVanMaand.add(
      Duration(days: 7 - laatsteVanMaand.weekday),
    );

    final totaalDagen = laatsteRasterDag.difference(eersteRasterDag).inDays + 1;

    final dagen = List.generate(
      totaalDagen,
      (index) => eersteRasterDag.add(Duration(days: index)),
    );

    const dagNamen = ['Ma', 'Di', 'Wo', 'Do', 'Vr', 'Za', 'Zo'];

    return Column(
      children: [
        maandHeader(),
        const SizedBox(height: 8),
        Row(
          children: dagNamen.map((naam) {
            return Expanded(
              child: Center(
                child: Text(
                  naam,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dagen.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (context, index) {
            final dag = dagen[index];
            final inMaand = dag.month == focusMaand.month;
            final geselecteerd = isGeselecteerd(dag);
            final vakantie = isVakantieDag(dag);
            final klantAlGepland = klantAlGeplandOpDag(dag);
            final namen = klantenNamenOpDag(dag);

            Color randKleur = Colors.grey.shade300;
            Color achtergrond = Colors.white;
            Color tekstKleur = inMaand ? Colors.black : Colors.grey.shade400;

            if (namen.isNotEmpty) {
              achtergrond = Colors.orange.withValues(alpha: 0.10);
              randKleur = Colors.orange.withValues(alpha: 0.45);
            }

            if (klantAlGepland) {
              achtergrond = Colors.blue.withValues(alpha: 0.10);
              randKleur = Colors.blue;
            }

            if (vakantie) {
              achtergrond = Colors.red.withValues(alpha: 0.10);
              randKleur = Colors.red;
            }

            if (geselecteerd) {
              achtergrond = Colors.green;
              randKleur = Colors.green;
              tekstKleur = Colors.white;
            }

            return InkWell(
              onTap: () => wisselDagSelectie(dag),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                margin: const EdgeInsets.all(3),
                padding: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: achtergrond,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: randKleur),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${dag.day}',
                      style: TextStyle(
                        color: tekstKleur,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (vakantie)
                      Text(
                        'Verlof',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: geselecteerd ? Colors.white : Colors.red,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else if (namen.isNotEmpty)
                      Column(
                        children: namen.take(2).map((naam) {
                          return Text(
                            naam,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: geselecteerd
                                  ? Colors.white
                                  : klantAlGepland
                                      ? Colors.blue
                                      : Colors.orange.shade800,
                              fontSize: 7.5,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList(),
                      )
                    else
                      const SizedBox(height: 13),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget tijdBlok({
    required String titel,
    required String tijd,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              const Icon(Icons.access_time, color: Colors.green),
              const SizedBox(height: 8),
              Text(
                titel,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tijd,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget samenvatting() {
    final naam = klantNaam(widget.klant);

    if (geselecteerdeDagen.isEmpty) {
      return const Text(
        'Selecteer één of meerdere beschikbare dagen in de kalender.',
        style: TextStyle(fontSize: 16, height: 1.4),
      );
    }

    return Text(
      '$naam wordt ingepland op ${geselecteerdeDagen.length} dag(en), '
      'telkens van ${tijdTekst(startUur, startMinuut)} tot '
      '${tijdTekst(eindUur, eindMinuut)}.',
      style: const TextStyle(fontSize: 16, height: 1.4),
    );
  }

  Widget opslaanKnop() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: opslaan,
        icon: const Icon(Icons.calendar_month),
        label: const Text('In agenda plaatsen'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final naam = klantNaam(widget.klant);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            groeneBalk(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  kaart(
                    titel: 'Klant',
                    icoon: Icons.business,
                    children: [
                      Text(
                        naam,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  kaart(
                    titel: 'Dagen kiezen',
                    icoon: Icons.calendar_month,
                    children: [
                      kalender(),
                      const SizedBox(height: 12),
                      Text(
                        'Oranje = klant ingepland. Rood = verlof. Blauw = deze klant staat al ingepland.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  kaart(
                    titel: 'Tijd kiezen',
                    icoon: Icons.access_time,
                    children: [
                      Row(
                        children: [
                          tijdBlok(
                            titel: 'Starttijd',
                            tijd: tijdTekst(startUur, startMinuut),
                            onTap: kiesStartTijd,
                          ),
                          const SizedBox(width: 12),
                          tijdBlok(
                            titel: 'Eindtijd',
                            tijd: tijdTekst(eindUur, eindMinuut),
                            onTap: kiesEindTijd,
                          ),
                        ],
                      ),
                    ],
                  ),
                  kaart(
                    titel: 'Samenvatting',
                    icoon: Icons.check_circle_outline,
                    children: [
                      samenvatting(),
                    ],
                  ),
                  opslaanKnop(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
