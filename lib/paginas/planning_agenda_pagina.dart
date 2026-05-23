import 'dart:async';

import 'package:flutter/material.dart';

import '../helpers/app_storage.dart';
import '../helpers/status_helper.dart';
import '../modellen/agenda_actie.dart';
import '../modellen/klant.dart';
import '../modellen/leverancier.dart';
import '../modellen/planning_dag.dart';

import 'agenda_actie_pagina.dart';
import 'klantenfiche_pagina.dart';
import 'kraan_reserveren_pagina.dart';
import '../helpers/widgets/onder_navigatie_balk.dart';

class AgendaPagina extends StatefulWidget {
  final List<Klant> alleKlanten;
  final List<Leverancier> leveranciers;
  final List<DateTime> vakantieDagen;
  final Future<void> Function() onGewijzigd;

  final DateTime? initialFocusDate;
  final bool startInMonthView;
  final Klant? highlightedKlant;

  const AgendaPagina({
    super.key,
    required this.alleKlanten,
    required this.leveranciers,
    required this.vakantieDagen,
    required this.onGewijzigd,
    this.initialFocusDate,
    this.startInMonthView = false,
    this.highlightedKlant,
  });

  @override
  State<AgendaPagina> createState() => _AgendaPaginaState();
}

class _AgendaPaginaState extends State<AgendaPagina>
    with SingleTickerProviderStateMixin {
  late DateTime huidigeFocus;
  late bool toonMaandOverzicht;

  late AnimationController _pulseController;
  Timer? _stopPulseTimer;

  List<AgendaActie> agendaActies = [];
  final List<DateTime> geselecteerdeDagen = [];
  bool selectieModus = false;

  bool toonPlaatsingAgenda = true;
  bool toonBureauAgenda = true;

  @override
  void initState() {
    super.initState();

    huidigeFocus = widget.initialFocusDate ?? DateTime.now();
    toonMaandOverzicht = widget.startInMonthView;

    laadAgendaActies();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    if (widget.highlightedKlant != null) {
      _pulseController.repeat(reverse: true);
      _stopPulseTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) {
          _pulseController.stop();
          _pulseController.value = 0.0;
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _stopPulseTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> laadAgendaActies() async {
    final geladen = await AppStorage.laadAgendaActies();

    if (mounted) {
      setState(() {
        agendaActies = geladen;
      });
    }
  }

  Future<void> bewaarAgendaActies() async {
    await AppStorage.bewaarAgendaActies(agendaActies);

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> openNieuweAgendaActie() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgendaActiePagina(
          onOpslaan: (actie) async {
            agendaActies.add(actie);
            await bewaarAgendaActies();
          },
        ),
      ),
    );

    await laadAgendaActies();
  }

  Future<void> openAgendaActie(AgendaActie actie) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgendaActiePagina(
          bestaandeActie: actie,
          onOpslaan: (nieuweActie) async {
            final index = agendaActies.indexWhere(
              (item) => item.id == nieuweActie.id,
            );

            if (index >= 0) {
              agendaActies[index] = nieuweActie;
            } else {
              agendaActies.add(nieuweActie);
            }

            await bewaarAgendaActies();
          },
          onVerwijderen: (actie) async {
            agendaActies.removeWhere((item) => item.id == actie.id);
            await bewaarAgendaActies();
          },
        ),
      ),
    );

    await laadAgendaActies();
  }

  Future<void> wisAgendaActie(AgendaActie actie) async {
    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agenda-actie wissen'),
          content: Text('Wil je "${actie.titel}" zeker verwijderen?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Nee'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ja'),
            ),
          ],
        );
      },
    );

    if (bevestigen == true) {
      agendaActies.removeWhere((item) => item.id == actie.id);
      await bewaarAgendaActies();
    }
  }

  Future<void> verplaatsAgendaActie(
    AgendaActie actie,
    DateTime nieuweDatum,
  ) async {
    final index = agendaActies.indexWhere((item) => item.id == actie.id);

    if (index < 0) return;

    agendaActies[index].datum = DateTime(
      nieuweDatum.year,
      nieuweDatum.month,
      nieuweDatum.day,
    );

    await bewaarAgendaActies();
  }

  Future<void> verplaatsKlantPlanning({
    required Klant klant,
    required PlanningDag planning,
    required DateTime nieuweDatum,
    int? nieuwStartUur,
    int? nieuwStartMinuut,
  }) async {
    final oudeDatum = planning.datum;

    final kraan = klant.kraanReservering;
    final heeftKraanReservering = kraan != null &&
        kraan.gereserveerd &&
        kraan.datum != null &&
        zelfdeDag(kraan.datum!, oudeDatum);

    final oudeStartMinuten = planning.startUur * 60 + planning.startMinuut;
    final oudeEindMinuten = planning.eindUur * 60 + planning.eindMinuut;
    final duurMinuten = oudeEindMinuten - oudeStartMinuten;

    int startUur = planning.startUur;
    int startMinuut = planning.startMinuut;

    if (nieuwStartUur != null && nieuwStartMinuut != null) {
      startUur = nieuwStartUur;
      startMinuut = nieuwStartMinuut;
    }

    final nieuweStartMinuten = startUur * 60 + startMinuut;
    final nieuweEindMinuten = nieuweStartMinuten + duurMinuten;

    setState(() {
      planning.datum = DateTime(
        nieuweDatum.year,
        nieuweDatum.month,
        nieuweDatum.day,
      );

      planning.startUur = nieuweStartMinuten ~/ 60;
      planning.startMinuut = nieuweStartMinuten % 60;
      planning.eindUur = nieuweEindMinuten ~/ 60;
      planning.eindMinuut = nieuweEindMinuten % 60;

      if (heeftKraanReservering) {
        klant.kraanReservering = KraanReservering(
          datum: DateTime(
            nieuweDatum.year,
            nieuweDatum.month,
            nieuweDatum.day,
          ),
          uur: kraan.uur,
          minuut: kraan.minuut,
          gereserveerd: true,
        );
      }
    });

    await widget.onGewijzigd();

    if (heeftKraanReservering && mounted) {
      final keuze = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Kraan reservatie nakijken'),
            content: const Text(
              'Deze klant heeft een kraanreservatie. Controleer of datum en uur nog correct zijn.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'ok'),
                child: const Text('OK'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, 'kraan'),
                child: const Text('Ga naar kraanreservatie blad'),
              ),
            ],
          );
        },
      );

      if (keuze == 'kraan' && mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => KraanReserverenPagina(
              klant: klant,
              onGewijzigd: widget.onGewijzigd,
            ),
          ),
        );

        if (mounted) setState(() {});
      }
    }
  }

  static DateTime beginVanWeek(DateTime datum) {
    final enkelDatum = DateTime(datum.year, datum.month, datum.day);
    return enkelDatum.subtract(Duration(days: enkelDatum.weekday - 1));
  }

  static DateTime beginVanMaand(DateTime datum) {
    return DateTime(datum.year, datum.month, 1);
  }

  bool zelfdeDag(DateTime a, DateTime b) {
    DateTime zonderTijd(DateTime datum) {
      return DateTime(
        datum.year,
        datum.month,
        datum.day,
      );
    }

    bool dagIsGeselecteerd(DateTime dag) {
      return geselecteerdeDagen.any(
        (item) => zelfdeDag(item, dag),
      );
    }

    void toggleDagSelectie(DateTime dag) {
      final zuivereDag = zonderTijd(dag);

      setState(() {
        if (dagIsGeselecteerd(zuivereDag)) {
          geselecteerdeDagen.removeWhere(
            (item) => zelfdeDag(item, zuivereDag),
          );
        } else {
          geselecteerdeDagen.add(zuivereDag);
        }

        selectieModus = geselecteerdeDagen.isNotEmpty;
      });
    }

    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool zelfdeKlant(Klant a, Klant b) {
    return identical(a, b) ||
        (a.klantenNr.isNotEmpty &&
            b.klantenNr.isNotEmpty &&
            a.klantenNr == b.klantenNr) ||
        (a.klantnaam == b.klantnaam &&
            a.adres == b.adres &&
            a.email == b.email &&
            a.telefoon == b.telefoon);
  }

  bool isHighlightedKlant(Klant klant) {
    final doel = widget.highlightedKlant;
    if (doel == null) return false;
    return zelfdeKlant(klant, doel);
  }

  double highlightFactor(Klant klant) {
    if (!isHighlightedKlant(klant)) return 0.0;
    return _pulseController.value;
  }

  bool actieMagGetoondWorden(AgendaActie actie) {
    if (actie.agendaCategorie == 'bureau') {
      return toonBureauAgenda;
    }

    return toonPlaatsingAgenda;
  }

  List<AgendaActie> actiesVanDag(DateTime dag) {
    final acties = agendaActies.where((actie) {
      if (!zelfdeDag(actie.datum, dag)) return false;
      if (!actieMagGetoondWorden(actie)) return false;

      return true;
    }).toList();

    acties.sort((a, b) {
      final startA = (a.startUur ?? 0) * 60 + (a.startMinuut ?? 0);
      final startB = (b.startUur ?? 0) * 60 + (b.startMinuut ?? 0);
      return startA.compareTo(startB);
    });

    return acties;
  }

  List<Klant> klantenMetKraanOpDag(DateTime dag) {
    return widget.alleKlanten.where((klant) {
      final kraan = klant.kraanReservering;
      return kraan != null &&
          kraan.gereserveerd &&
          kraan.datum != null &&
          zelfdeDag(kraan.datum!, dag);
    }).toList();
  }

  bool klantHeeftKraanOpPlanningDag(Klant klant, PlanningDag planning) {
    final kraan = klant.kraanReservering;
    return kraan != null &&
        kraan.gereserveerd &&
        kraan.datum != null &&
        zelfdeDag(kraan.datum!, planning.datum);
  }

  Widget kraanIcoon({double size = 16}) {
    return Text(
      '🏗️',
      style: TextStyle(
        fontSize: size,
        height: 1,
      ),
    );
  }

  Color kleurUitNaam(String naam) {
    switch (naam) {
      case 'blauw':
        return Colors.blue;
      case 'rood':
        return Colors.red;
      case 'paars':
        return Colors.purple;
      case 'teal':
        return Colors.teal;
      case 'grijs':
        return Colors.grey;
      case 'lime':
        return Colors.lime;
      case 'cyan':
        return Colors.cyan;
      case 'indigo':
        return Colors.indigo;
      case 'pink':
        return Colors.pink;
      case 'amber':
        return Colors.amber;
      case 'brown':
        return Colors.brown;
      case 'blueGrey':
        return Colors.blueGrey;
      case 'lightBlue':
        return Colors.lightBlue;
      case 'lightGreen':
        return Colors.lightGreen;
      case 'deepPurple':
        return Colors.deepPurple;
      case 'deepOrange':
        return Colors.deepOrange;
      case 'yellow':
        return Colors.yellow;
      case 'black':
        return Colors.black;
      case 'orange':
        return Colors.orange;
      case 'groen':
      default:
        return Colors.green;
    }
  }

  IconData icoonUitNaam(String naam) {
    switch (naam) {
      case 'puinzak':
      case 'inventory_2':
        return Icons.inventory_2_outlined;
      case 'verlof':
      case 'beach_access':
        return Icons.beach_access;
      case 'tijd':
      case 'access_time':
        return Icons.access_time;
      case 'container':
        return Icons.inventory_2_outlined;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'location_on':
        return Icons.location_on;
      case 'construction':
        return Icons.precision_manufacturing;
      case 'warning':
        return Icons.warning;
      case 'build':
        return Icons.precision_manufacturing;
      case 'task_alt':
      case 'taak':
        return Icons.task_alt;
      case 'rolcontainer':
      case 'delete_sweep':
      default:
        return Icons.delete_sweep;
    }
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

  String tijdTekst(int uur, int minuut) {
    return '${uur.toString().padLeft(2, '0')}:'
        '${minuut.toString().padLeft(2, '0')}';
  }

  int weekNummer(DateTime datum) {
    final donderdag = datum.add(
      Duration(days: 4 - (datum.weekday == 7 ? 0 : datum.weekday)),
    );
    final eersteJanuari = DateTime(donderdag.year, 1, 1);
    final verschil = donderdag.difference(eersteJanuari).inDays;
    return ((verschil + eersteJanuari.weekday - 1) / 7).floor() + 1;
  }

  List<DateTime> get weekDagen {
    final start = beginVanWeek(huidigeFocus);
    return List.generate(7, (index) => start.add(Duration(days: index)));
  }

  List<Map<String, dynamic>> planningenVanDag(DateTime dag) {
    final List<Map<String, dynamic>> resultaat = [];

    for (final klant in widget.alleKlanten) {
      for (final planning in klant.planningDagen) {
        if (zelfdeDag(planning.datum, dag)) {
          resultaat.add({
            'klant': klant,
            'planning': planning,
          });
        }
      }
    }

    resultaat.sort((a, b) {
      final planningA = a['planning'] as PlanningDag;
      final planningB = b['planning'] as PlanningDag;

      final minutenA = planningA.startUur * 60 + planningA.startMinuut;
      final minutenB = planningB.startUur * 60 + planningB.startMinuut;

      return minutenA.compareTo(minutenB);
    });

    return resultaat;
  }

  Future<void> openKlantenfiche(Klant klant) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KlantenfichePagina(
          klant: klant,
          alleKlanten: widget.alleKlanten,
          leveranciers: widget.leveranciers,
          vakantieDagen: widget.vakantieDagen,
          isNieuweKlant: false,
          onOpslaan: (_) async {
            await widget.onGewijzigd();
          },
          onGewijzigd: widget.onGewijzigd,
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }

    await widget.onGewijzigd();
  }

  Color klantGroepAchtergrond(Klant klant) {
    if (klant.isProjectAfgewerkt) {
      return Colors.grey.shade200;
    }

    if (klant.isNadienst) {
      return Colors.purple.shade50;
    }

    if (klant.isOpTeVolgen) {
      return Colors.amber.shade50;
    }

    return const Color(0xFFF5F5DC);
  }

  Color klantGroepRand(Klant klant) {
    if (klant.isProjectAfgewerkt) {
      return Colors.grey.shade400;
    }

    if (klant.isNadienst) {
      return Colors.purple.shade100;
    }

    if (klant.isOpTeVolgen) {
      return Colors.amber.shade200;
    }

    return const Color(0xFFE6D8AD);
  }

  Widget weekHeaderActieIcoon(AgendaActie actie) {
    final kleur = kleurUitNaam(actie.kleurNaam);

    return LongPressDraggable<AgendaActie>(
      data: actie,
      feedback: Material(
        color: Colors.transparent,
        child: CircleAvatar(
          radius: 22,
          backgroundColor: kleur.withValues(alpha: 0.18),
          child: Icon(
            icoonUitNaam(actie.icoonNaam),
            color: kleur,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: Icon(
          icoonUitNaam(actie.icoonNaam),
          size: 16,
          color: kleur,
        ),
      ),
      child: InkWell(
        onTap: () => openAgendaActie(actie),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: kleur.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icoonUitNaam(actie.icoonNaam),
            size: 16,
            color: kleur,
          ),
        ),
      ),
    );
  }

  Widget weekHeader() {
    const dagNamen = ['Ma', 'Di', 'Wo', 'Do', 'Vr', 'Za', 'Zo'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Center(
              child: Text(
                'W${weekNummer(beginVanWeek(huidigeFocus))}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          ...List.generate(7, (index) {
            final dag = weekDagen[index];
            final dagActies = actiesVanDag(dag);
            final kraanKlanten = klantenMetKraanOpDag(dag);

            return Expanded(
              child: DragTarget<AgendaActie>(
                onAcceptWithDetails: (details) async {
                  await verplaatsAgendaActie(details.data, dag);
                },
                builder: (context, candidateData, rejectedData) {
                  final isHover = candidateData.isNotEmpty;

                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isHover
                          ? Colors.green.withValues(alpha: 0.10)
                          : Colors.white,
                      border: Border(
                        left: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          dagNamen[index],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${dag.day}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (kraanKlanten.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          kraanIcoon(size: 17),
                        ],
                        if (dagActies.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            runSpacing: 3,
                            alignment: WrapAlignment.center,
                            children: dagActies
                                .take(5)
                                .map(weekHeaderActieIcoon)
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget tijdKolom() {
    const double uurHoogte = 80;
    const int beginUur = 7;
    const int eindUur = 18;

    return SizedBox(
      width: 56,
      child: Column(
        children: List.generate(
          eindUur - beginUur + 1,
          (index) {
            final uur = beginUur + index;

            return Container(
              height: uurHoogte,
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '${uur.toString().padLeft(2, '0')}:00',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget klantPlanningKaart({
    required Klant klant,
    required PlanningDag planning,
    required double hoogte,
    double? letterGrootte,
  }) {
    final status = StatusHelper.bepaalStatus(klant);
    final statusKleur = StatusHelper.bepaalStatusKleur(status);
    final heeftKraan = klantHeeftKraanOpPlanningDag(klant, planning);

    return GestureDetector(
      onTap: () => openKlantenfiche(klant),
      child: Container(
        height: hoogte < 110 ? 110 : hoogte,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: klantGroepAchtergrond(klant),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: klantGroepRand(klant),
            width: isHighlightedKlant(klant) ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              klant.klantnaam.isEmpty ? 'Klant zonder naam' : klant.klantnaam,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: letterGrootte ?? 11,
                fontWeight: FontWeight.bold,
                color: statusKleur,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${tijdTekst(planning.startUur, planning.startMinuut)} - '
              '${tijdTekst(planning.eindUur, planning.eindMinuut)}',
              style: const TextStyle(fontSize: 10),
            ),
            if (heeftKraan) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.brown.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.brown.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    kraanIcoon(size: 15),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'Kraan is gereserveerd en komt aan om '
                        '${klant.kraanReservering!.tijdTekst}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget klantPlanningBlok({
    required Klant klant,
    required PlanningDag planning,
    required double hoogte,
    double? letterGrootte,
  }) {
    final status = StatusHelper.bepaalStatus(klant);
    final statusKleur = StatusHelper.bepaalStatusKleur(status);

    return LongPressDraggable<_PlanningSleepData>(
      data: _PlanningSleepData(
        klant: klant,
        planning: planning,
      ),
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: klantGroepAchtergrond(klant),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: klantGroepRand(klant)),
          ),
          child: Text(
            klant.klantnaam.isEmpty ? 'Klant zonder naam' : klant.klantnaam,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: letterGrootte ?? 12,
              fontWeight: FontWeight.bold,
              color: statusKleur,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: klantPlanningKaart(
          klant: klant,
          planning: planning,
          hoogte: hoogte,
          letterGrootte: letterGrootte,
        ),
      ),
      child: klantPlanningKaart(
        klant: klant,
        planning: planning,
        hoogte: hoogte,
        letterGrootte: letterGrootte,
      ),
    );
  }

  Widget dagKolom(DateTime dag) {
    const double uurHoogte = 80;
    const int beginUur = 7;
    const int eindUur = 18;

    final planningen = planningenVanDag(dag);
    final kraanKlanten = klantenMetKraanOpDag(dag);

    return Expanded(
      child: Builder(
        builder: (targetContext) {
          return DragTarget<_PlanningSleepData>(
            onAcceptWithDetails: (details) async {
              final box = targetContext.findRenderObject() as RenderBox?;
              if (box == null) return;

              final local = box.globalToLocal(details.offset);
              final y = local.dy.clamp(0.0, box.size.height);

              final minutenVanafStart = ((y / uurHoogte) * 60).round();
              final afgerond = (minutenVanafStart / 15).round() * 15;

              final totaleMinuten =
                  (beginUur * 60 + afgerond).clamp(beginUur * 60, eindUur * 60);

              await verplaatsKlantPlanning(
                klant: details.data.klant,
                planning: details.data.planning,
                nieuweDatum: dag,
                nieuwStartUur: totaleMinuten ~/ 60,
                nieuwStartMinuut: totaleMinuten % 60,
              );
            },
            builder: (context, candidateData, rejectedData) {
              final isHover = candidateData.isNotEmpty;

              return Container(
                decoration: BoxDecoration(
                  color: isHover
                      ? Colors.green.withValues(alpha: 0.07)
                      : Colors.white,
                  border: Border(
                    left: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Stack(
                  children: [
                    ...List.generate(
                      eindUur - beginUur + 1,
                      (index) {
                        return Positioned(
                          top: index * uurHoogte,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: uurHoogte,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    ...kraanKlanten.map((klant) {
                      final kraan = klant.kraanReservering!;
                      final kraanMinuten =
                          (kraan.uur ?? beginUur) * 60 + (kraan.minuut ?? 0);

                      final top =
                          ((kraanMinuten - beginUur * 60) / 60.0) * uurHoogte;

                      return Positioned(
                        top: top,
                        left: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.brown.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.brown.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            children: [
                              kraanIcoon(size: 15),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${kraan.tijdTekst} kraan',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    ...planningen.map((item) {
                      final klant = item['klant'] as Klant;
                      final planning = item['planning'] as PlanningDag;

                      final startMinuten =
                          planning.startUur * 60 + planning.startMinuut;
                      final eindMinuten =
                          planning.eindUur * 60 + planning.eindMinuut;

                      final top =
                          ((startMinuten - beginUur * 60) / 60.0) * uurHoogte;
                      final hoogte =
                          ((eindMinuten - startMinuten) / 60.0) * uurHoogte;

                      final pulse = highlightFactor(klant);
                      final letterGrootte = 11 + (pulse * 5);

                      return Positioned(
                        top: top,
                        left: 4,
                        right: 4,
                        child: klantPlanningBlok(
                          klant: klant,
                          planning: planning,
                          hoogte: hoogte,
                          letterGrootte: letterGrootte,
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget weekOverzicht() {
    const double uurHoogte = 80;
    const int beginUur = 7;
    const int eindUur = 18;
    final totaleHoogte = (eindUur - beginUur + 1) * uurHoogte;

    return Column(
      children: [
        weekHeader(),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            child: SizedBox(
              height: totaleHoogte,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  tijdKolom(),
                  ...weekDagen.map((dag) => dagKolom(dag)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget maandActieChip(AgendaActie actie) {
    final kleur = kleurUitNaam(actie.kleurNaam);

    if (actie.weergaveType == 'volledigeDag') {
      return GestureDetector(
        onTap: () => openAgendaActie(actie),
        onLongPress: () => wisAgendaActie(actie),
        child: Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          decoration: BoxDecoration(
            color: kleur.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: kleur.withValues(alpha: 0.35)),
          ),
          child: Text(
            actie.titel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: kleur,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return LongPressDraggable<AgendaActie>(
      data: actie,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kleur.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kleur.withValues(alpha: 0.35)),
          ),
          child: Icon(
            icoonUitNaam(actie.icoonNaam),
            color: kleur,
            size: 24,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: maandActieChipZonderDrag(actie),
      ),
      child: maandActieChipZonderDrag(actie),
    );
  }

  Widget maandActieChipZonderDrag(AgendaActie actie) {
    final kleur = kleurUitNaam(actie.kleurNaam);

    return GestureDetector(
      onTap: () => openAgendaActie(actie),
      onLongPress: () => wisAgendaActie(actie),
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: kleur.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: kleur.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(
              icoonUitNaam(actie.icoonNaam),
              color: kleur,
              size: 13,
            ),
            const SizedBox(width: 3),
            Expanded(
              child: Text(
                actie.weergaveType == 'tijdsduur'
                    ? '${tijdTekst(actie.startUur ?? 0, actie.startMinuut ?? 0)} ${actie.titel}'
                    : actie.titel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: kleur,
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget maandKraanChip(Klant klant) {
    final kraan = klant.kraanReservering!;

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.brown.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.brown.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          kraanIcoon(size: 13),
          const SizedBox(width: 3),
          Expanded(
            child: Text(
              '${kraan.tijdTekst} kraan',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.brown,
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget maandKlantChip({
    required Klant klant,
    required PlanningDag planning,
  }) {
    final status = StatusHelper.bepaalStatus(klant);
    final kleur = StatusHelper.bepaalStatusKleur(status);

    final pulse = highlightFactor(klant);
    final letterGrootte = 10 + (pulse * 4);

    return LongPressDraggable<_PlanningSleepData>(
      data: _PlanningSleepData(
        klant: klant,
        planning: planning,
      ),
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 170,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: klantGroepAchtergrond(klant),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: klantGroepRand(klant)),
          ),
          child: Text(
            klant.klantnaam.isEmpty ? 'Klant zonder naam' : klant.klantnaam,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: kleur,
              fontSize: letterGrootte,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: maandKlantChipZonderDrag(
          klant: klant,
          planning: planning,
        ),
      ),
      child: maandKlantChipZonderDrag(
        klant: klant,
        planning: planning,
      ),
    );
  }

  Widget maandKlantChipZonderDrag({
    required Klant klant,
    required PlanningDag planning,
  }) {
    final status = StatusHelper.bepaalStatus(klant);
    final kleur = StatusHelper.bepaalStatusKleur(status);

    final pulse = highlightFactor(klant);
    final letterGrootte = 10 + (pulse * 4);

    return GestureDetector(
      onTap: () => openKlantenfiche(klant),
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        decoration: BoxDecoration(
          color: klantGroepAchtergrond(klant),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: klantGroepRand(klant)),
        ),
        child: Text(
          '${tijdTekst(planning.startUur, planning.startMinuut)} ${klant.klantnaam.isEmpty ? 'Klant zonder naam' : klant.klantnaam}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: letterGrootte,
            fontWeight: FontWeight.w600,
            color: kleur,
          ),
        ),
      ),
    );
  }

  Widget maandCel(DateTime dag) {
    final planningen = planningenVanDag(dag);
    final dagActies = actiesVanDag(dag);
    final kraanKlanten = klantenMetKraanOpDag(dag);

    AgendaActie? volledigeDagActie;
    for (final actie in dagActies) {
      if (actie.weergaveType == 'volledigeDag') {
        volledigeDagActie = actie;
        break;
      }
    }

    final achtergrondKleur = volledigeDagActie != null
        ? kleurUitNaam(volledigeDagActie.kleurNaam).withValues(alpha: 0.16)
        : Colors.white;

    return DragTarget<Object>(
      onAcceptWithDetails: (details) async {
        final data = details.data;

        if (data is AgendaActie) {
          await verplaatsAgendaActie(data, dag);
        }

        if (data is _PlanningSleepData) {
          await verplaatsKlantPlanning(
            klant: data.klant,
            planning: data.planning,
            nieuweDatum: dag,
          );
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHover = candidateData.isNotEmpty;

        return Container(
          margin: const EdgeInsets.all(2),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isHover
                ? Colors.green.withValues(alpha: 0.10)
                : achtergrondKleur,
            border: Border.all(
              color: isHover ? Colors.green : Colors.grey.shade300,
              width: isHover ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${dag.day}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'W${weekNummer(dag)}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ...dagActies.take(3).map(maandActieChip),
              ...kraanKlanten.take(2).map(maandKraanChip),
              ...planningen.take(3).map((item) {
                final klant = item['klant'] as Klant;
                final planning = item['planning'] as PlanningDag;

                return maandKlantChip(
                  klant: klant,
                  planning: planning,
                );
              }),
              if (dagActies.length + planningen.length + kraanKlanten.length >
                  6)
                Text(
                  '+ ${dagActies.length + planningen.length + kraanKlanten.length - 6} meer',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget maandOverzicht() {
    final eersteVanMaand = beginVanMaand(huidigeFocus);
    final laatsteVanMaand =
        DateTime(huidigeFocus.year, huidigeFocus.month + 1, 0);

    final eersteRasterDag =
        eersteVanMaand.subtract(Duration(days: eersteVanMaand.weekday - 1));
    final laatsteRasterDag =
        laatsteVanMaand.add(Duration(days: 7 - laatsteVanMaand.weekday));

    final totaalDagen = laatsteRasterDag.difference(eersteRasterDag).inDays + 1;

    final rasterDagen = List.generate(
      totaalDagen,
      (index) => eersteRasterDag.add(Duration(days: index)),
    );

    const dagNamen = ['Ma', 'Di', 'Wo', 'Do', 'Vr', 'Za', 'Zo'];

    return Column(
      children: [
        Row(
          children: List.generate(
            7,
            (index) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Text(
                    dagNamen[index],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            itemCount: rasterDagen.length,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              final dag = rasterDagen[index];

              return Opacity(
                opacity: dag.month == huidigeFocus.month ? 1.0 : 0.35,
                child: maandCel(dag),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget headerBlok() {
    final startWeek = beginVanWeek(huidigeFocus);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0B7A3B),
            Color(0xFF23B15F),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${huidigeFocus.year}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        toonMaandOverzicht
                            ? maandNaam(huidigeFocus.month)
                            : 'Week ${weekNummer(startWeek)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: toonPlaatsingAgenda,
                          activeColor: Colors.white,
                          checkColor: Colors.green,
                          onChanged: (value) {
                            setState(() {
                              toonPlaatsingAgenda = value ?? true;
                            });
                          },
                        ),
                        const Text(
                          'Plaatsers',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: toonBureauAgenda,
                          activeColor: Colors.white,
                          checkColor: Colors.green,
                          onChanged: (value) {
                            setState(() {
                              toonBureauAgenda = value ?? true;
                            });
                          },
                        ),
                        const Text(
                          'Bureau',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      huidigeFocus = toonMaandOverzicht
                          ? DateTime(
                              huidigeFocus.year,
                              huidigeFocus.month - 1,
                              1,
                            )
                          : huidigeFocus.subtract(
                              const Duration(days: 7),
                            );
                    });
                  },
                  icon: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          toonMaandOverzicht = !toonMaandOverzicht;
                        });
                      },
                      icon: Icon(
                        toonMaandOverzicht
                            ? Icons.view_week
                            : Icons.calendar_month,
                        color: Colors.white,
                      ),
                      label: Text(
                        toonMaandOverzicht ? 'Week' : 'Maand',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      huidigeFocus = toonMaandOverzicht
                          ? DateTime(
                              huidigeFocus.year,
                              huidigeFocus.month + 1,
                              1,
                            )
                          : huidigeFocus.add(
                              const Duration(days: 7),
                            );
                    });
                  },
                  icon: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      appBar: AppBar(
        title: const Text('Agenda'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: openNieuweAgendaActie,
            icon: const Icon(Icons.add_task),
            tooltip: 'Nieuwe agenda-actie',
          ),
        ],
      ),
      body: Column(
        children: [
          headerBlok(),
          Expanded(
            child: toonMaandOverzicht ? maandOverzicht() : weekOverzicht(),
          ),
          //
        ],
      ),
    );
  }
}

class _PlanningSleepData {
  final Klant klant;
  final PlanningDag planning;

  _PlanningSleepData({
    required this.klant,
    required this.planning,
  });
}
