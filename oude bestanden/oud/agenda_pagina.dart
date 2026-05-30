import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../lib/helpers/app_storage.dart';
import '../../lib/helpers/status_helper.dart';
import '../../lib/modellen/agenda_actie.dart';
import '../../lib/modellen/klant.dart';
import '../../lib/modellen/leverancier.dart';
import '../../lib/modellen/planning_dag.dart';
import '../../lib/modellen/afspraak_klant.dart';
import 'agenda_actie_pagina.dart';
import 'klantenfiche_pagina.dart';
import '../../lib/modellen/agenda_actie_template.dart';
import '../../lib/helpers/widgets/onder_navigatie_balk.dart';
import 'klanten_pagina.dart';
import 'afspraak_klanten_pagina.dart';
import '../jaar_planning_pagina.dart';

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

  final ScrollController maandScrollController = ScrollController();
  late DateTime maandScrollStartDag;

  late AnimationController _pulseController;
  Timer? _stopPulseTimer;
  bool toonMaandOverzicht = true;

  final List<DateTime> geselecteerdeVerlofDagen = [];
  bool selectieModus = false;
  bool isVerlofAanHetSlepen = false;

  bool actieMagGetoondWorden(AgendaActie actie) {
    if (!toonFilterDagtaak) return false;
    return true;
  }

  List<AgendaActie> agendaActies = [];
  List<AfspraakKlant> afsprakenKlanten = [];

  bool toonPlaatsingAgenda = true;
  bool toonBureauAgenda = true;
  bool toonFilterMenu = false;
  bool toonInTePlannenMenu = false;

  bool toonFilterPlaatsing = true;
  bool toonFilterNadienst = true;
  bool toonFilterOpvolging = true;
  bool toonFilterAfspraakKlant = true;
  bool toonFilterDagtaak = true;
  bool toonFilterVerlof = true;
  bool toonKraan = true;

  DateTime? geselecteerdeDagVoorDetails;
  DateTime? dagVensterDag;

  bool toonDagVenster = false;

  Offset dagVensterPositie = const Offset(30, 90);
  Offset inTePlannenMenuPositie = const Offset(12, 8);
  @override
  void initState() {
    super.initState();

    huidigeFocus = widget.initialFocusDate ?? DateTime.now();
    maandScrollStartDag = beginVanWeek(huidigeFocus);

    geselecteerdeDagVoorDetails = DateTime(
      huidigeFocus.year,
      huidigeFocus.month,
      huidigeFocus.day,
    );

    laadAgendaActies();
    laadZichtbaarheid();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
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
    maandScrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> laadZichtbaarheid() async {
    final waarden = await AppStorage.laadAgendaFilters();

    if (!mounted) return;

    setState(() {
      toonFilterPlaatsing = waarden['planningKlanten'] ?? true;
      toonFilterOpvolging = waarden['opvolging'] ?? true;
      toonFilterNadienst = waarden['nadienst'] ?? true;
      toonFilterDagtaak = waarden['dagTaken'] ?? true;
      toonFilterAfspraakKlant = waarden['afspraken'] ?? true;
      toonFilterVerlof = waarden['vakantie'] ?? true;
      toonKraan = waarden['kraan'] ?? true;
    });
  }

  Future<void> bewaarZichtbaarheid() async {
    await AppStorage.bewaarAgendaFilters({
      'planningKlanten': toonFilterPlaatsing,
      'opvolging': toonFilterOpvolging,
      'nadienst': toonFilterNadienst,
      'dagTaken': toonFilterDagtaak,
      'afspraken': toonFilterAfspraakKlant,
      'vakantie': toonFilterVerlof,
      'kraan': toonKraan,
    });
  }

  Future<void> laadAgendaActies() async {
    final geladen = await AppStorage.laadAgendaActies();
    final geladenAfspraken = await AppStorage.laadAfsprakenKlanten();

    if (mounted) {
      setState(() {
        agendaActies = geladen;
        afsprakenKlanten = geladenAfspraken;
      });
    }
  }

  Future<void> bewaarAgendaActies() async {
    await AppStorage.bewaarAgendaActies(agendaActies);
    if (!toonFilterDagtaak) {
      toonVerborgenAgendaMelding(
        naam: 'Dagtaak',
        zichtbaarMaken: () {
          setState(() {
            toonFilterDagtaak = true;
          });
        },
      );
    }

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
            if (actie.startUur != null &&
                actie.startMinuut != null &&
                actie.eindUur != null &&
                actie.eindMinuut != null) {
              if (agendaActieOverlapMetPlanningOfActies(
                nieuweActie: actie,
                dag: actie.datum,
                startUur: actie.startUur!,
                startMinuut: actie.startMinuut!,
                eindUur: actie.eindUur!,
                eindMinuut: actie.eindMinuut!,
              )) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Deze planning overlapt met een planning of dagtaak die volgens de kleurregels niet samen mag.',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
            }

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
            if (nieuweActie.weergaveType == 'tijdsduur' &&
                nieuweActie.startUur != null &&
                nieuweActie.startMinuut != null &&
                nieuweActie.eindUur != null &&
                nieuweActie.eindMinuut != null) {
              if (agendaActieOverlapMetPlanningOfActies(
                nieuweActie: nieuweActie,
                dag: nieuweActie.datum,
                startUur: nieuweActie.startUur!,
                startMinuut: nieuweActie.startMinuut!,
                eindUur: nieuweActie.eindUur!,
                eindMinuut: nieuweActie.eindMinuut!,
                actieDieVerplaatstWordt: nieuweActie,
              )) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Deze planning overlapt met een planning of dagtaak die volgens de kleurregels niet samen mag.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
            }

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
          onVerwijderen: (teVerwijderenActie) async {
            agendaActies.removeWhere(
              (item) => item.id == teVerwijderenActie.id,
            );

            await bewaarAgendaActies();
          },
        ),
      ),
    );

    await laadAgendaActies();
  }

  Future<void> toonPlanningBeheerMenu({
    required Klant klant,
    required PlanningDag planning,
  }) async {
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
      klant.planningDagen.remove(planning);
      await widget.onGewijzigd();
      await laadAgendaActies();

      if (mounted) {
        setState(() {});
      }

      return;
    }

    if (keuze == 'verplaatsen' || keuze == 'kopieren') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gebruik slepen om te verplaatsen of kopiëren voegen we hierna toe.',
          ),
        ),
      );
    }
  }

  Future<void> toonAgendaActieMenu(AgendaActie actie) async {
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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

    if (keuze == 'wissen') {
      agendaActies.removeWhere((item) => item.id == actie.id);
      await bewaarAgendaActies();
      await laadAgendaActies();
      return;
    }

    if (keuze == 'verplaatsen') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Sleep de dagtaak naar een andere dag om te verplaatsen.'),
        ),
      );
      return;
    }

    if (keuze == 'kopieren') {
      final kopie = AgendaActie(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titel: actie.titel,
        typeActie: actie.typeActie,
        datum: actie.datum,
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
      );

      agendaActies.add(kopie);
      await bewaarAgendaActies();
      await laadAgendaActies();
      return;
    }
  }

  Future<void> verplaatsAgendaActie(
    AgendaActie actie,
    DateTime nieuweDatum,
  ) async {
    final index = agendaActies.indexWhere((item) => item.id == actie.id);

    if (index < 0) return;

    setState(() {
      agendaActies[index].datum = DateTime(
        nieuweDatum.year,
        nieuweDatum.month,
        nieuweDatum.day,
      );
    });

    await bewaarAgendaActies();
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

  Future<void> toonAgendaActieSleepMenu({
    required AgendaActie actie,
    required DateTime nieuweDatum,
  }) async {
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
    if (keuze == 'wissen') {
      agendaActies.removeWhere(
        (item) => item.id == actie.id,
      );

      await bewaarAgendaActies();
      await laadAgendaActies();
      return;
    }

    if (keuze == 'verplaatsen') {
      int? startUur = actie.startUur;
      int? startMinuut = actie.startMinuut;
      int? eindUur = actie.eindUur;
      int? eindMinuut = actie.eindMinuut;

      if (actie.weergaveType == 'tijdsduur') {
        final tijdKeuze = await toonTijdKeuzeMenu();

        if (tijdKeuze == null || tijdKeuze == 'annuleren') return;

        if (tijdKeuze == 'aanpassen') {
          final startTijd = await kiesPlanningTijd(
            titel: 'Nieuwe starttijd',
            startUur: actie.startUur ?? 7,
            startMinuut: actie.startMinuut ?? 0,
            datum: nieuweDatum,
          );

          if (startTijd == null) return;

          final eindTijd = await kiesPlanningTijd(
            titel: 'Nieuwe eindtijd',
            startUur: actie.eindUur ?? 15,
            startMinuut: actie.eindMinuut ?? 30,
            datum: nieuweDatum,
          );

          if (eindTijd == null) return;

          startUur = startTijd.hour;
          startMinuut = startTijd.minute;
          eindUur = eindTijd.hour;
          eindMinuut = eindTijd.minute;
        }
      }
      if (actie.weergaveType == 'tijdsduur' &&
          startUur != null &&
          startMinuut != null &&
          eindUur != null &&
          eindMinuut != null) {
        if (agendaActieOverlapMetPlanningOfActies(
          nieuweActie: actie,
          dag: nieuweDatum,
          startUur: startUur,
          startMinuut: startMinuut,
          eindUur: eindUur,
          eindMinuut: eindMinuut,
          actieDieVerplaatstWordt: actie,
        )) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Deze planning overlapt met een planning of dagtaak die volgens de kleurregels niet samen mag.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
      if (actie.weergaveType == 'tijdsduur' &&
          startUur != null &&
          startMinuut != null &&
          eindUur != null &&
          eindMinuut != null) {
        if (agendaActieOverlapMetPlanningOfActies(
          nieuweActie: actie,
          dag: nieuweDatum,
          startUur: startUur,
          startMinuut: startMinuut,
          eindUur: eindUur,
          eindMinuut: eindMinuut,
          actieDieVerplaatstWordt: actie,
        )) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Deze planning overlapt met een planning of dagtaak die volgens de kleurregels niet samen mag.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
      if (actie.weergaveType == 'tijdsduur' &&
          startUur != null &&
          startMinuut != null &&
          eindUur != null &&
          eindMinuut != null) {
        if (agendaActieOverlapMetPlanningOfActies(
          nieuweActie: actie,
          dag: nieuweDatum,
          startUur: startUur,
          startMinuut: startMinuut,
          eindUur: eindUur,
          eindMinuut: eindMinuut,
          actieDieVerplaatstWordt: actie,
        )) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Deze planning overlapt met een planning of dagtaak die volgens de kleurregels niet samen mag.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      setState(() {
        actie.datum = DateTime(
          nieuweDatum.year,
          nieuweDatum.month,
          nieuweDatum.day,
        );
        actie.startUur = startUur;
        actie.startMinuut = startMinuut;
        actie.eindUur = eindUur;
        actie.eindMinuut = eindMinuut;
      });

      await bewaarAgendaActies();
      await laadAgendaActies();
      return;
    }

    if (keuze == 'kopieren') {
      int? startUur = actie.startUur;
      int? startMinuut = actie.startMinuut;
      int? eindUur = actie.eindUur;
      int? eindMinuut = actie.eindMinuut;
      if (actie.weergaveType == 'tijdsduur' &&
          startUur != null &&
          startMinuut != null &&
          eindUur != null &&
          eindMinuut != null) {
        if (agendaActieOverlapMetPlanningOfActies(
          nieuweActie: actie,
          dag: nieuweDatum,
          startUur: startUur,
          startMinuut: startMinuut,
          eindUur: eindUur,
          eindMinuut: eindMinuut,
        )) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Deze planning overlapt met een planning of dagtaak die volgens de kleurregels niet samen mag.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      if (actie.weergaveType == 'tijdsduur') {
        final tijdKeuze = await toonTijdKeuzeMenu();

        if (tijdKeuze == null || tijdKeuze == 'annuleren') return;

        if (tijdKeuze == 'aanpassen') {
          final startTijd = await kiesPlanningTijd(
            titel: 'Nieuwe starttijd',
            startUur: actie.startUur ?? 7,
            startMinuut: actie.startMinuut ?? 0,
            datum: nieuweDatum,
          );

          if (startTijd == null) return;

          final eindTijd = await kiesPlanningTijd(
            titel: 'Nieuwe eindtijd',
            startUur: actie.eindUur ?? 15,
            startMinuut: actie.eindMinuut ?? 30,
            datum: nieuweDatum,
          );

          if (eindTijd == null) return;

          startUur = startTijd.hour;
          startMinuut = startTijd.minute;
          eindUur = eindTijd.hour;
          eindMinuut = eindTijd.minute;
        }
      }
      final nieuweActieVoorControle = AgendaActie(
        id: actie.id,
        titel: actie.titel,
        typeActie: actie.typeActie,
        datum: DateTime(
          nieuweDatum.year,
          nieuweDatum.month,
          nieuweDatum.day,
        ),
        toonOpDagtaak: actie.toonOpDagtaak,
        dagenVoorafTonen: actie.dagenVoorafTonen,
        weergaveType: actie.weergaveType,
        kleurNaam: actie.kleurNaam,
        icoonNaam: actie.icoonNaam,
        startUur: startUur,
        startMinuut: startMinuut,
        eindUur: eindUur,
        eindMinuut: eindMinuut,
        opmerkingen: actie.opmerkingen,
      );

      if (actie.weergaveType == 'tijdsduur' &&
          startUur != null &&
          startMinuut != null &&
          eindUur != null &&
          eindMinuut != null) {
        if (agendaActieOverlapMetPlanningOfActies(
          nieuweActie: nieuweActieVoorControle,
          dag: nieuweDatum,
          startUur: startUur,
          startMinuut: startMinuut,
          eindUur: eindUur,
          eindMinuut: eindMinuut,
        )) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Deze planning overlapt met een planning of dagtaak die volgens de kleurregels niet samen mag.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
      if (actie.weergaveType == 'tijdsduur' &&
          startUur != null &&
          startMinuut != null &&
          eindUur != null &&
          eindMinuut != null) {
        if (agendaActieOverlapMetPlanningOfActies(
          nieuweActie: actie,
          dag: nieuweDatum,
          startUur: startUur,
          startMinuut: startMinuut,
          eindUur: eindUur,
          eindMinuut: eindMinuut,
        )) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Deze planning overlapt met een planning of dagtaak die volgens de kleurregels niet samen mag.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      final kopie = AgendaActie(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titel: actie.titel,
        typeActie: actie.typeActie,
        datum: DateTime(
          nieuweDatum.year,
          nieuweDatum.month,
          nieuweDatum.day,
        ),
        toonOpDagtaak: actie.toonOpDagtaak,
        dagenVoorafTonen: actie.dagenVoorafTonen,
        weergaveType: actie.weergaveType,
        kleurNaam: actie.kleurNaam,
        icoonNaam: actie.icoonNaam,
        startUur: startUur,
        startMinuut: startMinuut,
        eindUur: eindUur,
        eindMinuut: eindMinuut,
        opmerkingen: actie.opmerkingen,
      );

      agendaActies.add(kopie);

      await bewaarAgendaActies();
      await laadAgendaActies();
    }
  }

  Future<void> verplaatsKlantPlanning({
    required Klant klant,
    required PlanningDag planning,
    required DateTime nieuweDatum,
    int? nieuwStartUur,
    int? nieuwStartMinuut,
    int? nieuwEindUur,
    int? nieuwEindMinuut,
  }) async {
    final oudeDatum = planning.datum;

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

    int nieuweEindMinuten;

    if (nieuwEindUur != null && nieuwEindMinuut != null) {
      nieuweEindMinuten = nieuwEindUur * 60 + nieuwEindMinuut;
    } else {
      nieuweEindMinuten = nieuweStartMinuten + duurMinuten;
    }

    final kraan = klant.kraanReservering;
    final kraanHoortBijDezePlanning = kraan != null &&
        kraan.gereserveerd &&
        kraan.datum != null &&
        zelfdeDag(kraan.datum!, oudeDatum);

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

      if (kraanHoortBijDezePlanning) {
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

    if (kraanHoortBijDezePlanning && mounted) {
      final keuze = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Kraan reservatie nakijken'),
            content: const Text(
              'Deze klant heeft een kraanreservatie. Kijk na of deze nog klopt.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('OK'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Ga naar klantfiche'),
              ),
            ],
          );
        },
      );

      if (keuze == true && mounted) {
        await openKlantenfiche(klant);
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
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<AfspraakKlant> afsprakenVanDag(DateTime dag) {
    return afsprakenKlanten.where((afspraak) {
      return afspraak.datum.year == dag.year &&
          afspraak.datum.month == dag.month &&
          afspraak.datum.day == dag.day;
    }).toList();
  }

  DateTime zonderTijd(DateTime datum) {
    return DateTime(datum.year, datum.month, datum.day);
  }

  bool isVakantieDag(DateTime dag) {
    return widget.vakantieDagen.any((item) => zelfdeDag(item, dag));
  }

  bool isVerlofDagGeselecteerd(DateTime dag) {
    return geselecteerdeVerlofDagen.any((item) => zelfdeDag(item, dag));
  }

  void wisselVerlofDagSelectie(DateTime dag) {
    final zuivereDag = zonderTijd(dag);

    setState(() {
      if (isVerlofDagGeselecteerd(zuivereDag)) {
        geselecteerdeVerlofDagen.removeWhere(
          (item) => zelfdeDag(item, zuivereDag),
        );
      } else {
        geselecteerdeVerlofDagen.add(zuivereDag);
      }

      selectieModus = geselecteerdeVerlofDagen.isNotEmpty;
    });
  }

  void selecteerVerlofDagTijdensSlepen(DateTime dag) {
    final zuivereDag = zonderTijd(dag);

    if (isVerlofDagGeselecteerd(zuivereDag)) return;

    setState(() {
      geselecteerdeVerlofDagen.add(zuivereDag);
    });
  }

  bool selectieIsAllemaalVakantie() {
    if (geselecteerdeVerlofDagen.isEmpty) return false;

    return geselecteerdeVerlofDagen.every(
      (dag) => isVakantieDag(dag),
    );
  }

  Future<void> toonPlanningSleepMenu({
    required Klant klant,
    required PlanningDag planning,
    required DateTime nieuweDatum,
    int? nieuwStartUur,
    int? nieuwStartMinuut,
  }) async {
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
      klant.planningDagen.remove(planning);
      await widget.onGewijzigd();
      await laadAgendaActies();
      if (mounted) setState(() {});
      return;
    }

    if (keuze == 'verplaatsen') {
      int startUur = planning.startUur;
      int startMinuut = planning.startMinuut;

      final tijdKeuze = await toonTijdKeuzeMenu();

      if (tijdKeuze == null || tijdKeuze == 'annuleren') return;
      TimeOfDay? eindTijd;

      if (tijdKeuze == 'aanpassen') {
        final startTijd = await kiesPlanningTijd(
          titel: 'Nieuwe starttijd',
          startUur: planning.startUur,
          startMinuut: planning.startMinuut,
          datum: nieuweDatum,
        );

        if (startTijd == null) return;
        eindTijd = await kiesPlanningTijd(
          titel: 'Nieuwe eindtijd',
          startUur: planning.eindUur,
          startMinuut: planning.eindMinuut,
          datum: nieuweDatum,
        );

        if (eindTijd == null) return;

        startUur = startTijd.hour;
        startMinuut = startTijd.minute;
      } else {
        startUur = nieuwStartUur ?? planning.startUur;
        startMinuut = nieuwStartMinuut ?? planning.startMinuut;
      }
      final oudeStart = planning.startUur * 60 + planning.startMinuut;
      final oudeEinde = planning.eindUur * 60 + planning.eindMinuut;
      final duur = oudeEinde - oudeStart;

      final nieuweStartMinuten = startUur * 60 + startMinuut;

      final nieuweEindMinuten = eindTijd != null
          ? eindTijd.hour * 60 + eindTijd.minute
          : nieuweStartMinuten + duur;

      if (planningOverlapMetPlaatsingsploeg(
        nieuweKlant: klant,
        dag: nieuweDatum,
        startUur: startUur,
        startMinuut: startMinuut,
        eindUur: nieuweEindMinuten ~/ 60,
        eindMinuut: nieuweEindMinuten % 60,
        planningDieVerplaatstWordt: planning,
      )) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Deze planning overlapt met een andere planning die volgens de kleurregels niet samen mag.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await verplaatsKlantPlanning(
        klant: klant,
        planning: planning,
        nieuweDatum: nieuweDatum,
        nieuwStartUur: startUur,
        nieuwStartMinuut: startMinuut,
        nieuwEindUur: eindTijd?.hour,
        nieuwEindMinuut: eindTijd?.minute,
      );

      return;
    }

    if (keuze == 'kopieren') {
      final oudeStart = planning.startUur * 60 + planning.startMinuut;
      final oudeEinde = planning.eindUur * 60 + planning.eindMinuut;
      final duur = oudeEinde - oudeStart;

      int startUur = planning.startUur;
      int startMinuut = planning.startMinuut;
      TimeOfDay? eindTijd;

      final tijdKeuze = await toonTijdKeuzeMenu();

      if (tijdKeuze == null || tijdKeuze == 'annuleren') return;

      if (tijdKeuze == 'aanpassen') {
        final startTijd = await kiesPlanningTijd(
          titel: 'Nieuwe starttijd',
          startUur: planning.startUur,
          startMinuut: planning.startMinuut,
          datum: nieuweDatum,
        );

        if (startTijd == null) return;

        eindTijd = await kiesPlanningTijd(
          titel: 'Nieuwe eindtijd',
          startUur: planning.eindUur,
          startMinuut: planning.eindMinuut,
          datum: nieuweDatum,
        );

        if (eindTijd == null) return;

        startUur = startTijd.hour;
        startMinuut = startTijd.minute;
      } else {
        startUur = nieuwStartUur ?? planning.startUur;
        startMinuut = nieuwStartMinuut ?? planning.startMinuut;
      }

      final startMinuten = startUur * 60 + startMinuut;
      final eindMinuten = eindTijd != null
          ? eindTijd.hour * 60 + eindTijd.minute
          : startMinuten + duur;
      klant.planningDagen.add(
        PlanningDag(
          datum: DateTime(nieuweDatum.year, nieuweDatum.month, nieuweDatum.day),
          startUur: startMinuten ~/ 60,
          startMinuut: startMinuten % 60,
          eindUur: eindMinuten ~/ 60,
          eindMinuut: eindMinuten % 60,
        ),
      );
      if (planningOverlapMetPlaatsingsploeg(
        nieuweKlant: klant,
        dag: nieuweDatum,
        startUur: startMinuten ~/ 60,
        startMinuut: startMinuten % 60,
        eindUur: eindMinuten ~/ 60,
        eindMinuut: eindMinuten % 60,
      )) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Deze planning overlapt met een andere planning die volgens de kleurregels niet samen mag.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await widget.onGewijzigd();
      await laadAgendaActies();
      if (mounted) setState(() {});
    }
  }

  Future<void> plaatsGeselecteerdeDagenInVerlof() async {
    if (geselecteerdeVerlofDagen.isEmpty) return;

    final dagenMetPlanningOfActie = geselecteerdeVerlofDagen.where((dag) {
      final heeftKlanten = planningenVanDag(dag).isNotEmpty;
      final heeftActies = actiesVanDag(dag).isNotEmpty;
      return heeftKlanten || heeftActies;
    }).toList();

    if (dagenMetPlanningOfActie.isNotEmpty) {
      final bevestigenOndanksPlanning = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Er staat al iets ingepland'),
            content: Text(
              'Op ${dagenMetPlanningOfActie.length} geselecteerde dag(en) '
              'staat al een klant of actie ingepland.\n\n'
              'Wil je toch verlof plaatsen?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuleren'),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.beach_access),
                label: const Text('Toch verlof plaatsen'),
              ),
            ],
          );
        },
      );

      if (bevestigenOndanksPlanning != true) return;
    }

    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Verlof plaatsen'),
          content: Text(
            'Wil je ${geselecteerdeVerlofDagen.length} geselecteerde dag(en) in verlof plaatsen?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Nee'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.beach_access),
              label: const Text('Ja, verlof'),
            ),
          ],
        );
      },
    );

    if (bevestigen != true) return;

    setState(() {
      for (final dag in geselecteerdeVerlofDagen) {
        final bestaatAl = widget.vakantieDagen.any(
          (item) => zelfdeDag(item, dag),
        );

        if (!bestaatAl) {
          widget.vakantieDagen.add(zonderTijd(dag));
        }
      }

      geselecteerdeVerlofDagen.clear();
    });

    await widget.onGewijzigd();
    if (!toonFilterVerlof) {
      toonVerborgenAgendaMelding(
        naam: 'Verlof',
        zichtbaarMaken: () {
          setState(() {
            toonFilterVerlof = true;
          });
        },
      );
    }
  }

  Future<void> verwijderGeselecteerdeDagenUitVerlof() async {
    if (geselecteerdeVerlofDagen.isEmpty) return;

    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Verlof verwijderen'),
          content: Text(
            'Wil je ${geselecteerdeVerlofDagen.length} geselecteerde dag(en) uit verlof halen?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Nee'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.undo),
              label: const Text('Ja, verwijderen'),
            ),
          ],
        );
      },
    );

    if (bevestigen != true) return;

    setState(() {
      widget.vakantieDagen.removeWhere(
        (vakantieDag) => geselecteerdeVerlofDagen.any(
          (geselecteerd) => zelfdeDag(vakantieDag, geselecteerd),
        ),
      );

      geselecteerdeVerlofDagen.clear();
    });

    await widget.onGewijzigd();
    await laadAgendaActies();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> toonSelectieMenu() async {
    if (geselecteerdeVerlofDagen.isEmpty) return;

    final keuze = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.list_alt, color: Colors.green),
                title: const Text('Kies hier een bestaande actie'),
                onTap: () => Navigator.pop(context, 'bestaande_actie'),
              ),
              ListTile(
                leading:
                    const Icon(Icons.add_circle_outline, color: Colors.blue),
                title: const Text('Maak een nieuwe actie aan'),
                onTap: () => Navigator.pop(context, 'nieuwe_actie'),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Verwijder een opgeslagen actie'),
                onTap: () => Navigator.pop(context, 'actie_verwijderen'),
              ),
              if (selectieIsAllemaalVakantie())
                ListTile(
                  leading: const Icon(Icons.undo, color: Colors.red),
                  title: const Text('Uit verlof halen'),
                  onTap: () => Navigator.pop(context, 'verlof_verwijderen'),
                )
              else
                ListTile(
                  leading: const Icon(Icons.beach_access, color: Colors.orange),
                  title: const Text('Verlof plaatsen'),
                  onTap: () => Navigator.pop(context, 'verlof_plaatsen'),
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

    if (keuze == 'bestaande_actie') {
      await toonActieKeuzeMenu();
    }

    if (keuze == 'nieuwe_actie') {
      await actieToevoegenVoorSelectie();
    }

    if (keuze == 'actie_verwijderen') {
      await toonVerwijderActieMenu();
    }

    if (keuze == 'verlof_plaatsen') {
      await plaatsGeselecteerdeDagenInVerlof();
    }

    if (keuze == 'verlof_verwijderen') {
      await verwijderGeselecteerdeDagenUitVerlof();
    }
  }

  String planningTypeVanKlant(Klant klant) {
    if (klant.isNadienst) return 'paars';
    if (klant.isOpTeVolgen) return 'donkergroen';
    return 'lichtgroen';
  }

  String planningTypeVanActie(AgendaActie actie) {
    final kleur = actie.kleurNaam.toLowerCase().trim();

    if (kleur == 'blauw' || kleur == 'blue') return 'blauw';
    if (kleur == 'oranje' || kleur == 'orange') return 'oranje';
    if (kleur == 'paars' || kleur == 'purple') return 'paars';
    if (kleur == 'donkergroen') return 'donkergroen';
    if (kleur == 'lichtgroen' || kleur == 'groen' || kleur == 'green') {
      return 'lichtgroen';
    }

    return kleur;
  }

  bool magOverlap(String type1, String type2) {
    // Exact dezelfde kleur/type mag NOOIT overlappen
    // Dus blauw-blauw niet, oranje-oranje niet,
    // lichtgroen-lichtgroen niet, enz.
    if (type1 == type2) return false;

    // Blauw en oranje mogen wel met andere kleuren overlappen
    // maar dus niet met zichzelf, want dat staat hierboven al geblokkeerd.
    const flexibel = ['blauw', 'oranje'];

    if (flexibel.contains(type1) || flexibel.contains(type2)) {
      return true;
    }

    // Lichtgroen, donkergroen en paars
    // mogen nooit met elkaar overlappen.
    return false;
  }

  bool tijdenOverlappen({
    required int start1,
    required int einde1,
    required int start2,
    required int einde2,
  }) {
    return start1 < einde2 && einde1 > start2;
  }

  bool planningOverlapMetPlaatsingsploeg({
    required Klant nieuweKlant,
    required DateTime dag,
    required int startUur,
    required int startMinuut,
    required int eindUur,
    required int eindMinuut,
    PlanningDag? planningDieVerplaatstWordt,
  }) {
    final nieuweStart = startUur * 60 + startMinuut;
    final nieuweEind = eindUur * 60 + eindMinuut;
    final nieuwType = planningTypeVanKlant(nieuweKlant);

    for (final klant in widget.alleKlanten) {
      final bestaandType = planningTypeVanKlant(klant);

      for (final planning in klant.planningDagen) {
        if (planningDieVerplaatstWordt != null &&
            identical(planning, planningDieVerplaatstWordt)) {
          continue;
        }

        if (!zelfdeDag(planning.datum, dag)) continue;

        final bestaandStart = planning.startUur * 60 + planning.startMinuut;
        final bestaandEind = planning.eindUur * 60 + planning.eindMinuut;

        final overlapt = tijdenOverlappen(
          start1: nieuweStart,
          einde1: nieuweEind,
          start2: bestaandStart,
          einde2: bestaandEind,
        );

        if (overlapt && !magOverlap(nieuwType, bestaandType)) {
          return true;
        }
      }
    }

    return false;
  }

  bool agendaActieOverlapMetPlanningOfActies({
    required AgendaActie nieuweActie,
    required DateTime dag,
    required int startUur,
    required int startMinuut,
    required int eindUur,
    required int eindMinuut,
    AgendaActie? actieDieVerplaatstWordt,
  }) {
    final nieuweStart = startUur * 60 + startMinuut;
    final nieuweEind = eindUur * 60 + eindMinuut;
    final nieuwType = planningTypeVanActie(nieuweActie);

    // Controle met andere agenda-acties
    for (final actie in agendaActies) {
      if (actieDieVerplaatstWordt != null &&
          actie.id == actieDieVerplaatstWordt.id) {
        continue;
      }

      if (actie.startUur == null ||
          actie.startMinuut == null ||
          actie.eindUur == null ||
          actie.eindMinuut == null) {
        continue;
      }
      if (actie.startUur == null ||
          actie.startMinuut == null ||
          actie.eindUur == null ||
          actie.eindMinuut == null) {
        continue;
      }

      if (!zelfdeDag(actie.datum, dag)) continue;

      final bestaandStart = actie.startUur! * 60 + actie.startMinuut!;
      final bestaandEind = actie.eindUur! * 60 + actie.eindMinuut!;
      final bestaandType = planningTypeVanActie(actie);

      final overlapt = tijdenOverlappen(
        start1: nieuweStart,
        einde1: nieuweEind,
        start2: bestaandStart,
        einde2: bestaandEind,
      );

      if (overlapt && !magOverlap(nieuwType, bestaandType)) {
        return true;
      }
    }

    // Controle met klantplanningen
    for (final klant in widget.alleKlanten) {
      final bestaandType = planningTypeVanKlant(klant);

      for (final planning in klant.planningDagen) {
        if (!zelfdeDag(planning.datum, dag)) continue;

        final bestaandStart = planning.startUur * 60 + planning.startMinuut;
        final bestaandEind = planning.eindUur * 60 + planning.eindMinuut;

        final overlapt = tijdenOverlappen(
          start1: nieuweStart,
          einde1: nieuweEind,
          start2: bestaandStart,
          einde2: bestaandEind,
        );

        if (overlapt && !magOverlap(nieuwType, bestaandType)) {
          return true;
        }
      }
    }

    return false;
  }

  Future<void> planKlantOpDag({
    required Klant klant,
    required DateTime dag,
  }) async {
    final datum = zonderTijd(dag);

    if (isVakantieDag(datum)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Je kan geen planning toevoegen op een verlofdag.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final startTijd = await kiesPlanningTijd(
      titel: 'Starttijd kiezen',
      startUur: 7,
      startMinuut: 0,
      datum: dag,
    );
    if (startTijd == null) return;

    final eindTijd = await kiesPlanningTijd(
      titel: 'Eindtijd kiezen',
      startUur: 15,
      startMinuut: 30,
      datum: dag,
    );

    if (eindTijd == null) return;

    final startMinuten = startTijd.hour * 60 + startTijd.minute;
    final eindMinuten = eindTijd.hour * 60 + eindTijd.minute;

    if (eindMinuten <= startMinuten) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Eindtijd moet later zijn dan starttijd.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (planningOverlapMetPlaatsingsploeg(
      nieuweKlant: klant,
      dag: dag,
      startUur: startTijd.hour,
      startMinuut: startTijd.minute,
      eindUur: eindTijd.hour,
      eindMinuut: eindTijd.minute,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Deze planning overlapt met een andere plaatsing, nadienst of opvolging.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    klant.planningDagen.add(
      PlanningDag(
        datum: DateTime(dag.year, dag.month, dag.day),
        startUur: startTijd.hour,
        startMinuut: startTijd.minute,
        eindUur: eindTijd.hour,
        eindMinuut: eindTijd.minute,
      ),
    );

    await widget.onGewijzigd();
    if (!toonFilterPlaatsing && !klant.isNadienst && !klant.isOpTeVolgen) {
      toonVerborgenAgendaMelding(
        naam: 'Plaatsing',
        zichtbaarMaken: () {
          setState(() {
            toonFilterPlaatsing = true;
          });
        },
      );
    }

    if (klant.isNadienst && !toonFilterNadienst) {
      toonVerborgenAgendaMelding(
        naam: 'Nadienst',
        zichtbaarMaken: () {
          setState(() {
            toonFilterNadienst = true;
          });
        },
      );
    }

    if (klant.isOpTeVolgen && !toonFilterOpvolging) {
      toonVerborgenAgendaMelding(
        naam: 'Op te volgen',
        zichtbaarMaken: () {
          setState(() {
            toonFilterOpvolging = true;
          });
        },
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> toonActieKeuzeMenu() async {
    final templates = await AppStorage.laadAgendaActieTemplates();

    if (templates.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Er zijn nog geen opgeslagen acties.'),
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
                  'Kies een opgeslagen actie',
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

    if (dagVensterDag == null) return;

    final nieuweActie = AgendaActie(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titel: gekozenTemplate.naam,
      typeActie: gekozenTemplate.naam,
      datum: DateTime(
        dagVensterDag!.year,
        dagVensterDag!.month,
        dagVensterDag!.day,
      ),
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
    );

    if (nieuweActie.weergaveType == 'tijdsduur' &&
        nieuweActie.startUur != null &&
        nieuweActie.startMinuut != null &&
        nieuweActie.eindUur != null &&
        nieuweActie.eindMinuut != null) {
      if (agendaActieOverlapMetPlanningOfActies(
        nieuweActie: nieuweActie,
        dag: nieuweActie.datum,
        startUur: nieuweActie.startUur!,
        startMinuut: nieuweActie.startMinuut!,
        eindUur: nieuweActie.eindUur!,
        eindMinuut: nieuweActie.eindMinuut!,
      )) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Deze planning overlapt met een planning of dagtaak die volgens de kleurregels niet samen mag.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    agendaActies.add(nieuweActie);

    await bewaarAgendaActies();
    await laadAgendaActies();
  }

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

    final nieuweActie = AgendaActie(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titel: gekozenTemplate.naam,
      typeActie: gekozenTemplate.naam,
      datum: DateTime(
        dagVensterDag!.year,
        dagVensterDag!.month,
        dagVensterDag!.day,
      ),
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
    );

    agendaActies.add(nieuweActie);

    await bewaarAgendaActies();
    await laadAgendaActies();

    if (mounted) {
      setState(() {
        toonDagVenster = false;
      });
    }
  }

  Future<void> toonVerwijderActieMenu() async {
    if (agendaActies.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Er zijn geen opgeslagen acties'),
        ),
      );

      return;
    }

    final geselecteerdeActie = await showModalBottomSheet<AgendaActie>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: agendaActies.map((actie) {
                    return ListTile(
                      leading: Icon(
                        icoonUitNaam(actie.icoonNaam),
                        color: kleurUitNaam(actie.kleurNaam),
                      ),
                      title: Text(actie.titel),
                      subtitle: Text(
                        '${actie.datum.day}/'
                        '${actie.datum.month}/'
                        '${actie.datum.year}',
                      ),
                      onTap: () {
                        Navigator.pop(context, actie);
                      },
                    );
                  }).toList(),
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Annuleren'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (geselecteerdeActie == null) return;

    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Actie verwijderen'),
          content: Text(
            'Geselecteerde actie verwijderen?\n\n'
            '${geselecteerdeActie.titel}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Nee'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Ja'),
            ),
          ],
        );
      },
    );

    if (bevestigen != true) {
      await toonVerwijderActieMenu();
      return;
    }

    setState(() {
      agendaActies.removeWhere(
        (item) => item.id == geselecteerdeActie.id,
      );
    });

    await bewaarAgendaActies();

    if (!mounted) return;

    await toonVerwijderActieMenu();
  }

  Future<void> vasteActieToevoegen({
    required String titel,
    required String typeActie,
    required String kleurNaam,
    required String icoonNaam,
  }) async {
    if (geselecteerdeVerlofDagen.isEmpty) return;

    for (final dag in geselecteerdeVerlofDagen) {
      agendaActies.add(
        AgendaActie(
          id: '${DateTime.now().millisecondsSinceEpoch}_${dag.millisecondsSinceEpoch}',
          titel: titel,
          typeActie: typeActie,
          datum: DateTime(dag.year, dag.month, dag.day),
          toonOpDagtaak: true,
          dagenVoorafTonen: 0,
          weergaveType: 'symbool',
          kleurNaam: kleurNaam,
          icoonNaam: icoonNaam,
          startUur: null,
          startMinuut: null,
          eindUur: null,
          eindMinuut: null,
          opmerkingen: '',
        ),
      );
    }

    await bewaarAgendaActies();

    if (!mounted) return;

    setState(() {
      geselecteerdeVerlofDagen.clear();
    });

    await laadAgendaActies();
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

  Widget bestaandePlanningOpDag(DateTime dag) {
    final items = planningenVanDag(dag);

    if (items.isEmpty) {
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
        border: Border.all(color: const Color(0xFF8DD0A5)),
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
          ...items.map((item) {
            final klant = item['klant'] as Klant;
            final planning = item['planning'] as PlanningDag;

            Color kleur = const Color(0xFF0B7A3B);

            if (klant.isOpTeVolgen) {
              kleur = const Color(0xFF0F766E);
            } else if (klant.isNadienst) {
              kleur = Colors.purple;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${tijdTekst(planning.startUur, planning.startMinuut)} - ${tijdTekst(planning.eindUur, planning.eindMinuut)}  ${klant.klantnaam.isEmpty ? 'Klant zonder naam' : klant.klantnaam}',
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

  Future<void> actieToevoegenVoorSelectie() async {
    if (geselecteerdeVerlofDagen.isEmpty) return;

    AgendaActie? basisActie;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgendaActiePagina(
          onOpslaan: (actie) async {
            basisActie = actie;
          },
        ),
      ),
    );

    if (basisActie == null) return;

    for (final dag in geselecteerdeVerlofDagen) {
      final nieuweActie = AgendaActie(
        id: '${DateTime.now().millisecondsSinceEpoch}_${dag.millisecondsSinceEpoch}',
        titel: basisActie!.titel,
        typeActie: basisActie!.typeActie,
        datum: DateTime(
          dag.year,
          dag.month,
          dag.day,
        ),
        toonOpDagtaak: basisActie!.toonOpDagtaak,
        dagenVoorafTonen: basisActie!.dagenVoorafTonen,
        weergaveType: basisActie!.weergaveType,
        kleurNaam: basisActie!.kleurNaam,
        icoonNaam: basisActie!.icoonNaam,
        startUur: basisActie!.startUur,
        startMinuut: basisActie!.startMinuut,
        eindUur: basisActie!.eindUur,
        eindMinuut: basisActie!.eindMinuut,
        opmerkingen: basisActie!.opmerkingen,
      );

      if (nieuweActie.weergaveType == 'tijdsduur' &&
          nieuweActie.startUur != null &&
          nieuweActie.startMinuut != null &&
          nieuweActie.eindUur != null &&
          nieuweActie.eindMinuut != null) {
        if (agendaActieOverlapMetPlanningOfActies(
          nieuweActie: nieuweActie,
          dag: nieuweActie.datum,
          startUur: nieuweActie.startUur!,
          startMinuut: nieuweActie.startMinuut!,
          eindUur: nieuweActie.eindUur!,
          eindMinuut: nieuweActie.eindMinuut!,
        )) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Dagtaak "${nieuweActie.titel}" overlapt op ${nieuweActie.datum.day}/${nieuweActie.datum.month}/${nieuweActie.datum.year}.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      agendaActies.add(nieuweActie);
    }

    await bewaarAgendaActies();

    if (!mounted) return;

    setState(() {
      geselecteerdeVerlofDagen.clear();
      selectieModus = false;
    });

    await laadAgendaActies();
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

  List<DateTime> get weekDagen {
    final start = beginVanWeek(huidigeFocus);
    return List.generate(7, (index) => start.add(Duration(days: index)));
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
    if (!toonKraan) return [];

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

  List<Map<String, dynamic>> planningenVanDag(DateTime dag) {
    final List<Map<String, dynamic>> resultaat = [];

    final zoekDag = DateTime(dag.year, dag.month, dag.day);

    for (final klant in widget.alleKlanten) {
      for (final planning in klant.planningDagen) {
        final planningDag = DateTime(
          planning.datum.year,
          planning.datum.month,
          planning.datum.day,
        );

        if (planningDag == zoekDag) {
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

  List<Klant> nogInTePlannenKlanten() {
    return widget.alleKlanten.where((klant) {
      if (klant.isProjectAfgewerkt) return false;

      if (klant.isOpTeVolgen) {
        return true;
      }

      if (klant.isNadienst) {
        return klant.planningDagen.isEmpty;
      }

      return klant.planningDagen.isEmpty;
    }).toList();
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

    await widget.onGewijzigd();

    if (mounted) {
      setState(() {});
    }
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

  String dagVoluit(DateTime dag) {
    const dagen = [
      'maandag',
      'dinsdag',
      'woensdag',
      'donderdag',
      'vrijdag',
      'zaterdag',
      'zondag',
    ];

    return dagen[dag.weekday - 1];
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

  Color klantGroepAchtergrond(Klant klant) {
    if (klant.isProjectAfgewerkt) {
      return Colors.grey.shade200;
    }

    if (klant.isNadienst && klant.isOpTeVolgen) {
      return Colors.deepPurple.shade100;
    }

    if (klant.isNadienst) {
      return Colors.purple.shade50;
    }

    if (klant.isOpTeVolgen) {
      return Colors.orange.shade50;
    }

    return const Color(0xFFF5F5DC);
  }

  Color klantGroepRand(Klant klant) {
    if (klant.isProjectAfgewerkt) {
      return Colors.grey.shade400;
    }

    if (klant.isNadienst && klant.isOpTeVolgen) {
      return Colors.deepPurple.shade300;
    }

    if (klant.isNadienst) {
      return Colors.purple.shade200;
    }

    if (klant.isOpTeVolgen) {
      return Colors.orange.shade200;
    }

    return const Color(0xFFE6D8AD);
  }

  Widget kleineAgendaFilter({
    required String tekst,
    required bool waarde,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!waarde),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Checkbox(
              value: waarde,
              onChanged: onChanged,
              activeColor: Colors.white,
              checkColor: Colors.green,
              side: const BorderSide(color: Colors.white),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            tekst,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget nogInTePlannenLijst() {
    final klanten = nogInTePlannenKlanten();

    if (klanten.isEmpty) {
      return const SizedBox.shrink();
    }

    Color kleurVoorKlant(Klant klant) {
      if (klant.isNadienst) return Colors.purple;
      if (klant.isOpTeVolgen) return const Color(0xFF0F766E);
      return Colors.green;
    }

    String labelVoorKlant(Klant klant) {
      if (klant.isNadienst) return 'Nadienst';
      if (klant.isOpTeVolgen) return 'Opvolging';
      return 'Plaatsing';
    }

    return Container(
      width: 285,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 14,
            offset: const Offset(0, 5),
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
                color: Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'In te plannen',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${klanten.length}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...klanten.map((klant) {
            final kleur = kleurVoorKlant(klant);

            final rij = Container(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: kleur,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 78,
                    child: Text(
                      labelVoorKlant(klant),
                      style: TextStyle(
                        color: kleur,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      klant.klantnaam.isEmpty
                          ? 'Klant zonder naam'
                          : klant.klantnaam,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );

            return Draggable<Klant>(
              data: klant,
              feedback: Material(
                color: Colors.transparent,
                child: Container(
                  width: 285,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kleur),
                  ),
                  child: rij,
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.35,
                child: rij,
              ),
              child: rij,
            );
          }),
        ],
      ),
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
            zichtbaar: toonFilterPlaatsing,
            onTap: () {
              setState(() {
                toonFilterPlaatsing = !toonFilterPlaatsing;
              });
              bewaarZichtbaarheid();
            },
          ),
          filterRegel(
            tekst: 'Nadienst',
            kleur: Colors.purple,
            icoon: Icons.support_agent,
            zichtbaar: toonFilterNadienst,
            onTap: () {
              setState(() {
                toonFilterNadienst = !toonFilterNadienst;
              });
              bewaarZichtbaarheid();
            },
          ),
          filterRegel(
            tekst: 'Op te volgen',
            kleur: const Color(0xFF0F766E),
            icoon: Icons.pending_actions,
            zichtbaar: toonFilterOpvolging,
            onTap: () {
              setState(() {
                toonFilterOpvolging = !toonFilterOpvolging;
              });
              bewaarZichtbaarheid();
            },
          ),
          filterRegel(
            tekst: 'Afspraak klant',
            kleur: Colors.blue,
            icoon: Icons.event_available,
            zichtbaar: toonFilterAfspraakKlant,
            onTap: () {
              setState(() {
                toonFilterAfspraakKlant = !toonFilterAfspraakKlant;
              });
              bewaarZichtbaarheid();
            },
          ),
          filterRegel(
            tekst: 'Nieuwe dagtaak maken',
            kleur: Colors.orange,
            icoon: Icons.task_alt,
            zichtbaar: toonFilterDagtaak,
            onTap: () {
              setState(() {
                toonFilterDagtaak = !toonFilterDagtaak;
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
            zichtbaar: toonFilterVerlof,
            onTap: () {
              setState(() {
                toonFilterVerlof = !toonFilterVerlof;
              });
              bewaarZichtbaarheid();
            },
          ),
        ],
      ),
    );
  }

  Widget groeneBalk() {
    final aantalInTePlannen = nogInTePlannenKlanten().length;

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
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JaarPlanningPagina(
                        alleKlanten: widget.alleKlanten,
                        agendaActies: agendaActies,
                        afsprakenKlanten: afsprakenKlanten,
                        vakantieDagen: widget.vakantieDagen,
                      ),
                    ),
                  );
                  await laadAgendaActies();

                  if (mounted) {
                    setState(() {});
                  }
                },
                icon: const Icon(
                  Icons.calendar_month,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  'Ga naarJaarkalender            ${maandNaam(huidigeFocus.month)} ${huidigeFocus.year}',
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
        onTap: () => toonAgendaActieMenu(actie),
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
            final symboolActies = dagActies.where((actie) {
              return actie.weergaveType == 'symbool';
            }).toList();
            final kraanKlanten = klantenMetKraanOpDag(dag);
            final vakantie = isVakantieDag(dag);

            return Expanded(
              child: DragTarget<AgendaActie>(
                onAcceptWithDetails: (details) async {
                  await toonAgendaActieSleepMenu(
                    actie: details.data,
                    nieuweDatum: dag,
                  );
                },
                builder: (context, candidateData, rejectedData) {
                  final isHover = candidateData.isNotEmpty;

                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: vakantie
                          ? Colors.red.withValues(alpha: 0.10)
                          : isHover
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
                        if (vakantie) ...[
                          const SizedBox(height: 4),
                          const Icon(
                            Icons.beach_access,
                            color: Colors.red,
                            size: 16,
                          ),
                        ],
                        if (kraanKlanten.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          const Icon(
                            Icons.precision_manufacturing,
                            color: Colors.brown,
                            size: 16,
                          ),
                        ],
                        if (symboolActies.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            runSpacing: 3,
                            alignment: WrapAlignment.center,
                            children: symboolActies
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

  IconData statusIcoon(Klant klant) {
    if (klant.isProjectAfgewerkt) return Icons.check_circle;
    if (klant.isNadienst && klant.isOpTeVolgen) return Icons.report_problem;
    if (klant.isNadienst) return Icons.support_agent;
    if (klant.isOpTeVolgen) return Icons.pending_actions;
    return Icons.circle;
  }

  Color statusIcoonKleur(Klant klant) {
    if (klant.isProjectAfgewerkt) return Colors.grey;
    if (klant.isNadienst && klant.isOpTeVolgen) return Colors.deepPurple;
    if (klant.isNadienst) return Colors.purple;
    if (klant.isOpTeVolgen) return Colors.orange;
    return Colors.blue;
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
      onTap: () => toonPlanningBeheerMenu(
        klant: klant,
        planning: planning,
      ),
      child: Container(
        height: hoogte < 80 ? 80 : hoogte,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  statusIcoon(klant),
                  size: 13,
                  color: statusIcoonKleur(klant),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    klant.klantnaam.isEmpty
                        ? 'Klant zonder naam'
                        : klant.klantnaam,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: letterGrootte ?? 11,
                      fontWeight: FontWeight.bold,
                      color: statusKleur,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${tijdTekst(planning.startUur, planning.startMinuut)} - '
              '${tijdTekst(planning.eindUur, planning.eindMinuut)}',
              style: const TextStyle(fontSize: 10),
            ),
            if (toonKraan && heeftKraan) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.precision_manufacturing,
                    size: 13,
                    color: Colors.brown,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Kraan ${klant.kraanReservering!.tijdTekst}',
                      maxLines: 1,
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

  Widget agendaActieTijdsblok({
    required AgendaActie actie,
    required double uurHoogte,
    required int beginUur,
  }) {
    final kleur = kleurUitNaam(actie.kleurNaam);

    final startMinuten =
        (actie.startUur ?? beginUur) * 60 + (actie.startMinuut ?? 0);
    final eindMinuten =
        (actie.eindUur ?? (actie.startUur ?? beginUur) + 1) * 60 +
            (actie.eindMinuut ?? 0);

    final top = ((startMinuten - beginUur * 60) / 60.0) * uurHoogte;
    final hoogte = ((eindMinuten - startMinuten) / 60.0) * uurHoogte;

    return Positioned(
      top: top,
      left: 6,
      right: 6,
      child: GestureDetector(
        onTap: () => toonAgendaActieMenu(actie),
        child: Container(
          height: hoogte < 44 ? 44 : hoogte,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: kleur.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kleur.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Icon(
                icoonUitNaam(actie.icoonNaam),
                size: 15,
                color: kleur,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${tijdTekst(actie.startUur ?? 0, actie.startMinuut ?? 0)} ${actie.titel}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: kleur,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget kraanTijdsblok({
    required Klant klant,
    required double uurHoogte,
    required int beginUur,
  }) {
    final kraan = klant.kraanReservering!;
    final kraanMinuten = (kraan.uur ?? beginUur) * 60 + (kraan.minuut ?? 0);
    final top = ((kraanMinuten - beginUur * 60) / 60.0) * uurHoogte;

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
            const Icon(
              Icons.precision_manufacturing,
              size: 15,
              color: Colors.brown,
            ),
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
  }

  Color achtergrondKleurVoorDag(DateTime dag) {
    if (isVakantieDag(dag)) {
      return Colors.red.withValues(alpha: 0.08);
    }

    final volledigeDagActies = actiesVanDag(dag).where((actie) {
      return actie.weergaveType == 'volledigeDag';
    }).toList();

    if (volledigeDagActies.isEmpty) {
      if (dag.weekday == DateTime.saturday || dag.weekday == DateTime.sunday) {
        return Colors.grey.shade100;
      }

      return Colors.white;
    }

    return kleurUitNaam(volledigeDagActies.first.kleurNaam)
        .withValues(alpha: 0.12);
  }

  Widget dagKolom(DateTime dag) {
    const double uurHoogte = 80;
    const int beginUur = 7;
    const int eindUur = 18;

    final planningen = planningenVanDag(dag);
    final kraanKlanten = klantenMetKraanOpDag(dag);
    final tijdsduurActies = actiesVanDag(dag).where((actie) {
      return actie.weergaveType == 'tijdsduur';
    }).toList();

    final vakantie = isVakantieDag(dag);

    return Expanded(
      child: Builder(
        builder: (targetContext) {
          return DragTarget<_PlanningSleepData>(
            onWillAcceptWithDetails: (_) => !vakantie,
            onAcceptWithDetails: (details) async {
              if (vakantie) return;

              final box = targetContext.findRenderObject() as RenderBox?;
              if (box == null) return;

              final local = box.globalToLocal(details.offset);
              final y = local.dy.clamp(0.0, box.size.height);

              final minutenVanafStart = ((y / uurHoogte) * 60).round();
              final afgerond = (minutenVanafStart / 15).round() * 15;

              final totaleMinuten = (beginUur * 60 + afgerond).clamp(
                beginUur * 60,
                eindUur * 60,
              );
              await toonPlanningSleepMenu(
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
                  color: vakantie
                      ? Colors.red.withValues(alpha: 0.08)
                      : isHover
                          ? Colors.green.withValues(alpha: 0.07)
                          : achtergrondKleurVoorDag(dag),
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
                    if (vakantie)
                      const Positioned(
                        top: 12,
                        left: 6,
                        right: 6,
                        child: Center(
                          child: Text(
                            'Verlof',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ...tijdsduurActies.map(
                      (actie) => agendaActieTijdsblok(
                        actie: actie,
                        uurHoogte: uurHoogte,
                        beginUur: beginUur,
                      ),
                    ),
                    ...kraanKlanten.map(
                      (klant) => kraanTijdsblok(
                        klant: klant,
                        uurHoogte: uurHoogte,
                        beginUur: beginUur,
                      ),
                    ),
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

  Widget maandCel(DateTime dag) {
    final planningen = planningenVanDag(dag);
    final dagActies = actiesVanDag(dag);
    final kraanKlanten = klantenMetKraanOpDag(dag);
    final afspraken = afsprakenVanDag(dag);

    final vakantie = isVakantieDag(dag);
    final verlofGeselecteerd = isVerlofDagGeselecteerd(dag);

    final geselecteerdVoorDetails = geselecteerdeDagVoorDetails != null &&
        zelfdeDag(geselecteerdeDagVoorDetails!, dag);

    Color achtergrondKleur =
        (dag.weekday == DateTime.saturday || dag.weekday == DateTime.sunday)
            ? Colors.grey.shade100
            : Colors.white;

    if (vakantie) {
      achtergrondKleur = Colors.red.withValues(alpha: 0.10);
    }

    if (verlofGeselecteerd) {
      achtergrondKleur = Colors.orange.withValues(alpha: 0.16);
    }

    if (geselecteerdVoorDetails) {
      achtergrondKleur = Colors.green.withValues(alpha: 0.10);
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          geselecteerdeDagVoorDetails = dag;
          dagVensterDag = dag;
          toonDagVenster = true;
        });
      },
      onLongPress: () {
        setState(() {
          selectieModus = true;
        });

        wisselVerlofDagSelectie(dag);
      },
      child: DragTarget<Object>(
        onAcceptWithDetails: (details) async {
          final data = details.data;

          if (data is AgendaActie) {
            await toonAgendaActieSleepMenu(
              actie: data,
              nieuweDatum: dag,
            );
          }

          if (data is _PlanningSleepData) {
            if (vakantie) return;

            verplaatsKlantPlanning(
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
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: isHover
                  ? Colors.green.withValues(alpha: 0.12)
                  : achtergrondKleur,
              border: Border.all(
                color: verlofGeselecteerd
                    ? Colors.orange
                    : geselecteerdVoorDetails
                        ? Colors.green
                        : vakantie
                            ? Colors.red
                            : isHover
                                ? Colors.green
                                : Colors.grey.shade300,
                width: verlofGeselecteerd ||
                        geselecteerdVoorDetails ||
                        vakantie ||
                        isHover
                    ? 2
                    : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${dag.day}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: vakantie ? Colors.red : Colors.black,
                      ),
                    ),
                    const Spacer(),
                    if (vakantie)
                      const Icon(
                        Icons.beach_access,
                        color: Colors.red,
                        size: 13,
                      ),
                  ],
                ),
                const Spacer(),
                Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children: [
                    if (planningen.isNotEmpty)
                      _maandBadge(
                        icoon: Icons.person,
                        tekst: '${planningen.length}',
                        kleur: Colors.green,
                      ),
                    if (dagActies.isNotEmpty)
                      _maandBadge(
                        icoon: Icons.bolt,
                        tekst: '${dagActies.length}',
                        kleur: Colors.orange,
                      ),
                    if (kraanKlanten.isNotEmpty)
                      _maandBadge(
                        icoon: Icons.precision_manufacturing,
                        tekst: '${kraanKlanten.length}',
                        kleur: Colors.brown,
                      ),
                    if (afspraken.isNotEmpty)
                      _maandBadge(
                        icoon: Icons.event_available,
                        tekst: '${afspraken.length}',
                        kleur: Colors.blue,
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _maandBadge({
    required IconData icoon,
    required String tekst,
    required Color kleur,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: kleur.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: kleur.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icoon, size: 10, color: kleur),
          const SizedBox(width: 2),
          Text(
            tekst,
            style: TextStyle(
              color: kleur,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget dagDetailPaneel() {
    final dag = geselecteerdeDagVoorDetails ?? huidigeFocus;

    final planningen = planningenVanDag(dag);
    final dagActies = actiesVanDag(dag);
    final kraanKlanten = klantenMetKraanOpDag(dag);
    final vakantie = isVakantieDag(dag);
    final afspraken = afsprakenVanDag(dag);

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month, color: Colors.green, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${dagVoluit(dag)} ${dag.day}/${dag.month}/${dag.year}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (vakantie)
                const Icon(Icons.beach_access, color: Colors.red, size: 22),
            ],
          ),
          const SizedBox(height: 10),
          if (planningen.isEmpty &&
              dagActies.isEmpty &&
              kraanKlanten.isEmpty &&
              afspraken.isEmpty)
            Text(
              vakantie ? 'Verlofdag' : 'Geen planning op deze dag.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          if (afspraken.isNotEmpty) ...[
            const Text(
              'Afspraak klanten',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            ...afspraken.map((afspraak) {
              final tijd = afspraak.ganseDag
                  ? 'Ganse dag'
                  : '${tijdTekst(afspraak.beginUur, afspraak.beginMinuut)} - '
                      '${tijdTekst(afspraak.eindUur, afspraak.eindMinuut)}';

              return InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AfspraakKlantenPagina(
                        datum: afspraak.datum,
                        bestaandeAfspraak: afspraak,
                      ),
                    ),
                  );

                  await laadAgendaActies();

                  if (mounted) {
                    setState(() {});
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: Colors.blue.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_available,
                          color: Colors.blue, size: 18),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 78,
                        child: Text(
                          tijd,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          afspraak.klantNaam.isEmpty
                              ? 'Klant zonder naam'
                              : afspraak.klantNaam,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 20),
                    ],
                  ),
                ),
              );
            }),
          ],
          if (planningen.isNotEmpty) ...[
            const Text(
              'Planning Plaatsers',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            ...planningen.map((item) {
              final klant = item['klant'] as Klant;
              final planning = item['planning'] as PlanningDag;

              return InkWell(
                onTap: () => toonPlanningBeheerMenu(
                  klant: klant,
                  planning: planning,
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: klantGroepAchtergrond(klant),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: klantGroepRand(klant)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        statusIcoon(klant),
                        color: statusIcoonKleur(klant),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 72,
                        child: Text(
                          '${tijdTekst(planning.startUur, planning.startMinuut)}\n'
                          '${tijdTekst(planning.eindUur, planning.eindMinuut)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          klant.klantnaam.isEmpty
                              ? 'Klant zonder naam'
                              : klant.klantnaam,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 20),
                    ],
                  ),
                ),
              );
            }),
          ],
          if (dagActies.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Acties',
              style: TextStyle(
                color: const Color(0xFFE8F5E9),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            ...dagActies.map((actie) {
              final kleur = kleurUitNaam(actie.kleurNaam);

              return InkWell(
                onTap: () => toonAgendaActieMenu(actie),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(icoonUitNaam(actie.icoonNaam),
                          color: kleur, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          actie.weergaveType == 'tijdsduur'
                              ? '${tijdTekst(actie.startUur ?? 0, actie.startMinuut ?? 0)} - '
                                  '${tijdTekst(actie.eindUur ?? 0, actie.eindMinuut ?? 0)}  '
                                  '${actie.titel}'
                              : actie.titel,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: kleur,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
          if (kraanKlanten.isNotEmpty) ...[
            const SizedBox(height: 6),
            const Text(
              'Kraan',
              style: TextStyle(
                color: Colors.brown,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            ...kraanKlanten.map((klant) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.brown.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: Colors.brown.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.precision_manufacturing,
                        color: Colors.brown),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${klant.kraanReservering?.tijdTekst ?? ''} '
                        '${klant.klantnaam}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget selectieActieBalk() {
    if (geselecteerdeVerlofDagen.isEmpty) {
      return const SizedBox.shrink();
    }

    final meerdereDagen = geselecteerdeVerlofDagen.length > 1;

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 4, 8, 6),
      padding: const EdgeInsets.fromLTRB(10, 6, 6, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.task_alt,
                color: Colors.green,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${geselecteerdeVerlofDagen.length} dag(en)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 13,
                  ),
                ),
              ),
              IconButton(
                onPressed: meerdereDagen ? null : actieToevoegenVoorSelectie,
                icon: const Icon(Icons.add_task),
                tooltip: 'Dagtaak plaatsers',
                color: Colors.green,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 30,
                  minHeight: 30,
                ),
              ),
              IconButton(
                onPressed: selectieIsAllemaalVakantie()
                    ? verwijderGeselecteerdeDagenUitVerlof
                    : plaatsGeselecteerdeDagenInVerlof,
                icon: Icon(
                  selectieIsAllemaalVakantie()
                      ? Icons.undo
                      : Icons.beach_access,
                ),
                tooltip: selectieIsAllemaalVakantie()
                    ? 'Verlofdag uithalen'
                    : 'Verlofdag inplannen',
                color:
                    selectieIsAllemaalVakantie() ? Colors.red : Colors.orange,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 30,
                  minHeight: 30,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    geselecteerdeVerlofDagen.clear();
                    selectieModus = false;
                  });
                },
                icon: const Icon(Icons.close),
                color: Colors.red,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 30,
                  minHeight: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: meerdereDagen
                      ? null
                      : () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AfspraakKlantenPagina(
                                datum: geselecteerdeVerlofDagen.first,
                              ),
                            ),
                          );

                          await laadAgendaActies();

                          if (mounted) {
                            setState(() {
                              geselecteerdeVerlofDagen.clear();
                              selectieModus = false;
                            });
                          }
                        },
                  child: const Text(
                    'Afspraak klanten',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ElevatedButton(
                  onPressed: meerdereDagen ? null : toonActieKeuzeMenu,
                  child: const Text(
                    'Dagtaak plaatsers',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ElevatedButton(
                  onPressed: selectieIsAllemaalVakantie()
                      ? verwijderGeselecteerdeDagenUitVerlof
                      : plaatsGeselecteerdeDagenInVerlof,
                  child: Text(
                    selectieIsAllemaalVakantie()
                        ? 'Verlofdag uithalen'
                        : 'Verlofdag inplannen',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget maandOverzicht() {
    const dagLetters = ['M', 'D', 'W', 'D', 'V', 'Z', 'Z'];
    const aantalWeken = 104;
    const geschatteWeekHoogte = 170.0;

    return Stack(
      children: [
        Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: dagLetters.map((letter) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        letter,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollUpdateNotification) {
                    final weekIndex =
                        (maandScrollController.offset / geschatteWeekHoogte)
                            .floor();

                    final zichtbareDag =
                        maandScrollStartDag.add(Duration(days: weekIndex * 7));

                    if (zichtbareDag.month != huidigeFocus.month ||
                        zichtbareDag.year != huidigeFocus.year) {
                      setState(() {
                        huidigeFocus = zichtbareDag;
                      });
                    }
                  }

                  return false;
                },
                child: ListView.builder(
                  controller: maandScrollController,
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 90),
                  itemCount: aantalWeken,
                  itemBuilder: (context, weekIndex) {
                    final weekStart =
                        maandScrollStartDag.add(Duration(days: weekIndex * 7));

                    final dagen = List.generate(
                      7,
                      (index) => weekStart.add(Duration(days: index)),
                    );

                    return maandWeekRij(dagen);
                  },
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
              child: Material(
                color: Colors.transparent,
                child: nogInTePlannenLijst(),
              ),
            ),
          ),
        if (toonFilterMenu)
          Positioned(
            top: 8,
            right: 12,
            width: 330,
            child: Material(
              color: Colors.transparent,
              child: filterUitvalMenu(),
            ),
          ),
        if (toonDagVenster) zwevendDagVenster(),
      ],
    );
  }

  Widget maandWeekRij(List<DateTime> dagen) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: dagen.map((dag) {
          return Expanded(
            child: maandDagKaart(dag),
          );
        }).toList(),
      ),
    );
  }

  Widget maandDagKaart(DateTime dag) {
    final allePlanningen = planningenVanDag(dag);

    final planningen = allePlanningen.where((item) {
      final klant = item['klant'] as Klant;

      if (klant.isNadienst) return toonFilterNadienst;
      if (klant.isOpTeVolgen) return toonFilterOpvolging;

      return toonFilterPlaatsing;
    }).toList();

    final dagActies = toonFilterDagtaak ? actiesVanDag(dag) : <AgendaActie>[];
    final afspraken =
        toonFilterAfspraakKlant ? afsprakenVanDag(dag) : <AfspraakKlant>[];
    final kraanKlanten = klantenMetKraanOpDag(dag);

    final echteVakantie = isVakantieDag(dag);
    final vakantie = toonFilterVerlof && echteVakantie;

    Color achtergrond = Colors.white;

    if (dag.weekday == DateTime.saturday || dag.weekday == DateTime.sunday) {
      achtergrond = Colors.grey.shade100;
    }

    if (vakantie) {
      achtergrond = Colors.red.withValues(alpha: 0.10);
    }

    return DragTarget<Object>(
      onAcceptWithDetails: (details) async {
        final data = details.data;

        if (data is DateTime) {
          final oudeDag = zonderTijd(data);
          final nieuweDag = zonderTijd(dag);

          if (dagHeeftPlanningOfTaken(nieuweDag)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Verlof kan niet geplaatst worden: er staat al iets ingepland.',
                ),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          setState(() {
            widget.vakantieDagen.removeWhere(
              (item) => zelfdeDag(item, oudeDag),
            );

            if (!widget.vakantieDagen
                .any((item) => zelfdeDag(item, nieuweDag))) {
              widget.vakantieDagen.add(nieuweDag);
            }
          });

          await AppStorage.bewaarVakantieDagen(widget.vakantieDagen);
          await widget.onGewijzigd();
          return;
        }

        if (isVakantieDag(dag)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Je kan niets plannen op een verlofdag.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        if (data is AgendaActie) {
          await toonAgendaActieSleepMenu(
            actie: data,
            nieuweDatum: dag,
          );
          return;
        }

        if (data is _PlanningSleepData) {
          await toonPlanningSleepMenu(
            klant: data.klant,
            planning: data.planning,
            nieuweDatum: dag,
          );
          return;
        }

        if (data is Klant) {
          await planKlantOpDag(
            klant: data,
            dag: dag,
          );
          return;
        }

        if (data is AfspraakKlant) {
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
          if (keuze == 'wissen') {
            afsprakenKlanten.removeWhere(
              (item) => item.id == data.id,
            );

            await AppStorage.bewaarAfsprakenKlanten(
              afsprakenKlanten,
            );

            await laadAgendaActies();
            return;
          }

          if (keuze == 'verplaatsen') {
            int beginUur = data.beginUur;
            int beginMinuut = data.beginMinuut;
            int eindUur = data.eindUur;
            int eindMinuut = data.eindMinuut;
            bool ganseDag = data.ganseDag;

            if (!data.ganseDag) {
              final tijdKeuze = await toonTijdKeuzeMenu();

              if (tijdKeuze == null || tijdKeuze == 'annuleren') return;

              if (tijdKeuze == 'aanpassen') {
                final startTijd = await kiesPlanningTijd(
                  titel: 'Nieuwe starttijd',
                  startUur: data.beginUur,
                  startMinuut: data.beginMinuut,
                  datum: dag,
                );

                if (startTijd == null) return;

                final eindTijd = await kiesPlanningTijd(
                  titel: 'Nieuwe eindtijd',
                  startUur: data.eindUur,
                  startMinuut: data.eindMinuut,
                  datum: dag,
                );

                if (eindTijd == null) return;

                beginUur = startTijd.hour;
                beginMinuut = startTijd.minute;
                eindUur = eindTijd.hour;
                eindMinuut = eindTijd.minute;
                ganseDag = false;
              }
            }

            setState(() {
              data.datum = DateTime(dag.year, dag.month, dag.day);
              data.ganseDag = ganseDag;
              data.beginUur = beginUur;
              data.beginMinuut = beginMinuut;
              data.eindUur = eindUur;
              data.eindMinuut = eindMinuut;
            });

            await AppStorage.bewaarAfsprakenKlanten(afsprakenKlanten);
            await laadAgendaActies();
            return;
          }

          if (keuze == 'kopieren') {
            int beginUur = data.beginUur;
            int beginMinuut = data.beginMinuut;
            int eindUur = data.eindUur;
            int eindMinuut = data.eindMinuut;
            bool ganseDag = data.ganseDag;

            if (!data.ganseDag) {
              final tijdKeuze = await toonTijdKeuzeMenu();

              if (tijdKeuze == null || tijdKeuze == 'annuleren') return;

              if (tijdKeuze == 'aanpassen') {
                final startTijd = await kiesPlanningTijd(
                  titel: 'Nieuwe starttijd',
                  startUur: data.beginUur,
                  startMinuut: data.beginMinuut,
                  datum: dag,
                );

                if (startTijd == null) return;

                final eindTijd = await kiesPlanningTijd(
                  titel: 'Nieuwe eindtijd',
                  startUur: data.eindUur,
                  startMinuut: data.eindMinuut,
                  datum: dag,
                );

                if (eindTijd == null) return;

                beginUur = startTijd.hour;
                beginMinuut = startTijd.minute;
                eindUur = eindTijd.hour;
                eindMinuut = eindTijd.minute;
                ganseDag = false;
              }
            }

            afsprakenKlanten.add(
              AfspraakKlant(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                klantNr: data.klantNr,
                klantNaam: data.klantNaam,
                adres: data.adres,
                telefoon: data.telefoon,
                email: data.email,
                datum: DateTime(dag.year, dag.month, dag.day),
                ganseDag: ganseDag,
                beginUur: beginUur,
                beginMinuut: beginMinuut,
                eindUur: eindUur,
                eindMinuut: eindMinuut,
                waarschuwing: data.waarschuwing,
                notities: data.notities,
              ),
            );

            await AppStorage.bewaarAfsprakenKlanten(afsprakenKlanten);
            await laadAgendaActies();
            return;
          }
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHover = candidateData.isNotEmpty;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              geselecteerdeDagVoorDetails = dag;
              dagVensterDag = dag;
              toonDagVenster = true;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.all(5),
            constraints: const BoxConstraints(minHeight: 105),
            decoration: BoxDecoration(
              color:
                  isHover ? Colors.green.withValues(alpha: 0.12) : achtergrond,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isHover
                    ? Colors.green
                    : vakantie
                        ? Colors.red
                        : Colors.grey.shade300,
              ),
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
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    if (vakantie)
                      const Icon(
                        Icons.beach_access,
                        color: Colors.red,
                        size: 13,
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                if (vakantie)
                  Draggable<DateTime>(
                    data: dag,
                    feedback: Material(
                      color: Colors.transparent,
                      child: SizedBox(
                        width: 120,
                        child: maandItemTegel(
                          kleur: Colors.red,
                          icoon: Icons.beach_access,
                          titel: 'Verlof',
                          tekstKleur: Colors.red,
                        ),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.35,
                      child: maandItemTegel(
                        kleur: Colors.red,
                        icoon: Icons.beach_access,
                        titel: 'Verlof',
                        tekstKleur: Colors.red,
                      ),
                    ),
                    child: maandItemTegel(
                      kleur: Colors.red,
                      icoon: Icons.beach_access,
                      titel: 'Verlof',
                      tekstKleur: Colors.red,
                    ),
                  ),
                ...planningen.map((item) {
                  final klant = item['klant'] as Klant;
                  final planning = item['planning'] as PlanningDag;

                  return maandPlanningTegel(
                    klant: klant,
                    planning: planning,
                  );
                }).toList(),
                ...afspraken.map((afspraak) {
                  final tijd = afspraak.ganseDag
                      ? 'Ganse dag'
                      : '${tijdTekst(afspraak.beginUur, afspraak.beginMinuut)} - '
                          '${tijdTekst(afspraak.eindUur, afspraak.eindMinuut)}';

                  final tegel = maandItemTegel(
                    kleur: Colors.blue,
                    icoon: Icons.event_available,
                    titel: afspraak.klantNaam.isEmpty
                        ? 'Klant zonder naam'
                        : afspraak.klantNaam,
                    subtitel: tijd,
                    tekstKleur: Colors.blue,
                  );

                  return Draggable<AfspraakKlant>(
                    data: afspraak,
                    feedback: Material(
                      color: Colors.transparent,
                      child: SizedBox(width: 160, child: tegel),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.35,
                      child: tegel,
                    ),
                    child: tegel,
                  );
                }).toList(),
                ...dagActies.map((actie) {
                  final tijd = actie.weergaveType == 'tijdsduur'
                      ? '${tijdTekst(actie.startUur ?? 0, actie.startMinuut ?? 0)} - '
                          '${tijdTekst(actie.eindUur ?? 0, actie.eindMinuut ?? 0)}'
                      : '';

                  final tegel = maandItemTegel(
                    kleur: Colors.orange,
                    icoon: icoonUitNaam(actie.icoonNaam),
                    titel: actie.titel,
                    subtitel: tijd,
                    tekstKleur: Colors.black,
                    onTap: () => toonAgendaActieMenu(actie),
                  );

                  return Draggable<AgendaActie>(
                    data: actie,
                    feedback: Material(
                      color: Colors.transparent,
                      child: SizedBox(width: 160, child: tegel),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.35,
                      child: tegel,
                    ),
                    child: tegel,
                  );
                }).toList(),
                ...kraanKlanten.map((klant) {
                  return maandItemTegel(
                    kleur: Colors.brown,
                    icoon: Icons.precision_manufacturing,
                    titel: klant.klantnaam,
                    subtitel: klant.kraanReservering?.tijdTekst ?? '',
                    tekstKleur: Colors.brown,
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget maandPlanningTegel({
    required Klant klant,
    required PlanningDag planning,
  }) {
    Color kleur = Colors.green;

    if (klant.isNadienst) {
      kleur = Colors.purple;
    }

    if (klant.isOpTeVolgen) {
      kleur = const Color(0xFF009688);
    }

    final tijd = '${tijdTekst(planning.startUur, planning.startMinuut)} - '
        '${tijdTekst(planning.eindUur, planning.eindMinuut)}';

    final tegel = maandItemTegel(
      kleur: kleur,
      icoon: Icons.construction,
      titel: klant.klantnaam,
      subtitel: tijd,
      tekstKleur: kleur,
      onTap: () => toonPlanningBeheerMenu(
        klant: klant,
        planning: planning,
      ),
    );

    return Draggable<_PlanningSleepData>(
      data: _PlanningSleepData(
        klant: klant,
        planning: planning,
      ),
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 170,
          child: tegel,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: tegel,
      ),
      child: tegel,
    );
  }

  Widget maandItemTegel({
    required Color kleur,
    required IconData icoon,
    required String titel,
    String subtitel = '',
    Color tekstKleur = Colors.black,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: kleur.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kleur.withValues(alpha: 0.30)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icoon, size: 12, color: kleur),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: tekstKleur,
                    ),
                  ),
                  if (subtitel.isNotEmpty)
                    Text(
                      subtitel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        color: tekstKleur.withValues(alpha: 0.75),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool dagHeeftPlanningOfTaken(DateTime dag) {
    final heeftPlanning = planningenVanDag(dag).isNotEmpty;
    final heeftActies = actiesVanDag(dag).isNotEmpty;
    final heeftAfspraken = afsprakenVanDag(dag).isNotEmpty;
    final heeftKraan = klantenMetKraanOpDag(dag).isNotEmpty;

    return heeftPlanning || heeftActies || heeftAfspraken || heeftKraan;
  }

  Widget zwevendDagVenster() {
    final dag = dagVensterDag ?? huidigeFocus;

    return Positioned(
      left: dagVensterPositie.dx,
      top: dagVensterPositie.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            dagVensterPositie += details.delta;
          });
        },
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 340,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${dagVoluit(dag)} ${dag.day}/${dag.month}/${dag.year}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        setState(() {
                          toonDagVenster = false;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AfspraakKlantenPagina(
                            datum: dag,
                          ),
                        ),
                      );

                      await laadAgendaActies();

                      if (mounted) {
                        setState(() {
                          toonDagVenster = false;
                        });
                      }
                    },
                    icon: const Icon(Icons.event_available),
                    label: const Text('Afspraak klant toevoegen'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await toonActieKeuzeMenu();

                      if (mounted) {
                        setState(() {
                          toonDagVenster = false;
                        });
                      }
                    },
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
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AgendaActiePagina(
                            onOpslaan: (actie) async {
                              actie.datum = DateTime(
                                dag.year,
                                dag.month,
                                dag.day,
                              );

                              agendaActies.add(actie);
                              await bewaarAgendaActies();
                            },
                          ),
                        ),
                      );

                      await laadAgendaActies();
                      if (!toonFilterAfspraakKlant) {
                        toonVerborgenAgendaMelding(
                          naam: 'Afspraak klant',
                          zichtbaarMaken: () {
                            setState(() {
                              toonFilterAfspraakKlant = true;
                            });
                          },
                        );
                      }
                      if (!toonFilterAfspraakKlant) {
                        toonVerborgenAgendaMelding(
                          naam: 'Afspraak klant',
                          zichtbaarMaken: () {
                            setState(() {
                              toonFilterAfspraakKlant = true;
                            });
                          },
                        );
                      }

                      if (mounted) {
                        setState(() {
                          toonDagVenster = false;
                        });
                      }
                    },
                    icon: const Icon(Icons.task_alt),
                    label: const Text('Nieuwe dagtaak maken'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final dagZonderTijd = zonderTijd(dag);

                      setState(() {
                        if (isVakantieDag(dagZonderTijd)) {
                          widget.vakantieDagen.removeWhere(
                            (item) => zelfdeDag(item, dagZonderTijd),
                          );
                        } else {
                          if (dagHeeftPlanningOfTaken(dagZonderTijd)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Verlof kan niet geplaatst worden: er staat al iets ingepland.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          widget.vakantieDagen.add(dagZonderTijd);
                        }
                      });

                      await widget.onGewijzigd();
                      await AppStorage.bewaarVakantieDagen(
                          widget.vakantieDagen);
                    },
                    icon: const Icon(Icons.beach_access),
                    label: Text(
                      isVakantieDag(dag)
                          ? 'Verlofdag verwijderen'
                          : 'Verlofdag plaatsen',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      bottomNavigationBar: OnderNavigatieBalk(
        huidigePagina: 'agenda',
        onKlanten: () {
          Navigator.popUntil(context, (route) => route.isFirst);
        },
      ),
      floatingActionButton: null,
      body: SafeArea(
        child: Column(
          children: [
            groeneBalk(),
            Expanded(
              child: maandOverzicht(),
            ),
          ],
        ),
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
