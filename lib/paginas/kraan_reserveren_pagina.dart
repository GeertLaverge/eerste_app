import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../helpers/widgets/onder_navigatie_balk.dart';
import '../modellen/klant.dart';
import '../modellen/planning_dag.dart';
import 'klant_planning_pagina.dart';

class KraanReserverenPagina extends StatefulWidget {
  final Klant klant;
  final List<Klant> alleKlanten;
  final List<DateTime> vakantieDagen;
  final Future<void> Function() onGewijzigd;

  const KraanReserverenPagina({
    super.key,
    required this.klant,
    required this.alleKlanten,
    required this.vakantieDagen,
    required this.onGewijzigd,
  });

  @override
  State<KraanReserverenPagina> createState() => _KraanReserverenPaginaState();
}

class _KraanReserverenPaginaState extends State<KraanReserverenPagina> {
  DateTime? geselecteerdeDatum;
  int gekozenUur = 7;
  int gekozenMinuut = 0;

  @override
  void initState() {
    super.initState();

    final kraan = widget.klant.kraanReservering;

    if (kraan != null && kraan.gereserveerd) {
      geselecteerdeDatum = kraan.datum;
      gekozenUur = kraan.uur ?? 7;
      gekozenMinuut = kraan.minuut ?? 0;
    } else if (widget.klant.planningDagen.isNotEmpty) {
      final eerste = geplandeDagen().first;
      geselecteerdeDatum = eerste;
    }
  }

  bool zelfdeDag(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String datumTekst(DateTime datum) {
    return '${datum.day.toString().padLeft(2, '0')}/'
        '${datum.month.toString().padLeft(2, '0')}/'
        '${datum.year}';
  }

  String tijdTekst(int uur, int minuut) {
    return '${uur.toString().padLeft(2, '0')}:'
        '${minuut.toString().padLeft(2, '0')}';
  }

  List<DateTime> geplandeDagen() {
    final dagen = widget.klant.planningDagen.map((planning) {
      return DateTime(
        planning.datum.year,
        planning.datum.month,
        planning.datum.day,
      );
    }).toList();

    dagen.sort((a, b) => a.compareTo(b));

    final uniek = <DateTime>[];

    for (final dag in dagen) {
      if (!uniek.any((item) => zelfdeDag(item, dag))) {
        uniek.add(dag);
      }
    }

    return uniek;
  }

  List<PlanningDag> planningenOpDag(DateTime dag) {
    return widget.klant.planningDagen.where((planning) {
      return zelfdeDag(planning.datum, dag);
    }).toList();
  }

  Widget groeneBalk() {
    final naam = widget.klant.klantnaam.trim().isEmpty
        ? 'Klant zonder naam'
        : widget.klant.klantnaam.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
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
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kraan reserveren',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  naam,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.precision_manufacturing,
            color: Colors.white,
            size: 32,
          ),
        ],
      ),
    );
  }

  Future<TimeOfDay?> kiesTijdScroll() async {
    int uur = gekozenUur;
    int minuut = gekozenMinuut;

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
                      'Begintijd kiezen',
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
                          TimeOfDay(hour: uur, minute: minuut),
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
                          uur = waarde;
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
                          minuut = waarde;
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

  Future<void> kiesTijd() async {
    final gekozen = await kiesTijdScroll();

    if (gekozen == null) return;

    setState(() {
      gekozenUur = gekozen.hour;
      gekozenMinuut = gekozen.minute;
    });
  }

  Future<void> gaNaarKalender() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KlantPlanningPagina(
          klant: widget.klant,
          alleKlanten: widget.alleKlanten,
          vakantieDagen: widget.vakantieDagen,
          onBewaren: widget.onGewijzigd,
        ),
      ),
    );

    await widget.onGewijzigd();

    if (!mounted) return;

    setState(() {
      if (widget.klant.planningDagen.isNotEmpty) {
        geselecteerdeDatum = geplandeDagen().first;
      }
    });
  }

  Future<void> plaatsInAgenda() async {
    if (geselecteerdeDatum == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kies eerst een geplande datum.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      widget.klant.kraanReservering = KraanReservering(
        datum: DateTime(
          geselecteerdeDatum!.year,
          geselecteerdeDatum!.month,
          geselecteerdeDatum!.day,
        ),
        uur: gekozenUur,
        minuut: gekozenMinuut,
        gereserveerd: true,
      );
    });

    await widget.onGewijzigd();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kraan is gereserveerd.'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  Future<void> verwijderReservatie() async {
    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Kraanreservatie verwijderen'),
          content: const Text('Wil je deze kraanreservatie verwijderen?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Nee'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Ja, verwijderen'),
            ),
          ],
        );
      },
    );

    if (bevestigen != true) return;

    setState(() {
      widget.klant.kraanReservering = KraanReservering(
        gereserveerd: false,
        datum: null,
        uur: null,
        minuut: null,
      );
    });

    await widget.onGewijzigd();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kraanreservatie verwijderd.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget geenPlanningBlok() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.precision_manufacturing,
                  color: Colors.brown.shade600,
                  size: 46,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Nog geen planning',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Er kan pas een kraan gereserveerd worden wanneer deze klant ingepland is.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text('Annuleren'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: gaNaarKalender,
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Ga naar kalender'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget datumKaart(DateTime dag) {
    final geselecteerd =
        geselecteerdeDatum != null && zelfdeDag(geselecteerdeDatum!, dag);
    final planningen = planningenOpDag(dag);

    return InkWell(
      onTap: () {
        setState(() {
          geselecteerdeDatum = dag;
        });
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: geselecteerd
              ? Colors.green.withValues(alpha: 0.10)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: geselecteerd ? Colors.green : Colors.grey.shade200,
            width: geselecteerd ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              geselecteerd ? Icons.check_circle : Icons.radio_button_unchecked,
              color: geselecteerd ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    datumTekst(dag),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (planningen.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      planningen.map((planning) {
                        return '${tijdTekst(planning.startUur, planning.startMinuut)} - '
                            '${tijdTekst(planning.eindUur, planning.eindMinuut)}';
                      }).join('  •  '),
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tijdBlok() {
    return InkWell(
      onTap: kiesTijd,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              color: Colors.brown.shade600,
              size: 26,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Begintijd kraan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              tijdTekst(gekozenUur, gekozenMinuut),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.edit_outlined),
          ],
        ),
      ),
    );
  }

  Widget plaatsKnop() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: plaatsInAgenda,
        icon: const Icon(Icons.precision_manufacturing),
        label: const Text('Plaats in agenda'),
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

  Widget inhoud() {
    final dagen = geplandeDagen();

    if (dagen.isEmpty) {
      return geenPlanningBlok();
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 92),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.brown.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.brown.withValues(alpha: 0.20),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.precision_manufacturing,
                color: Colors.brown.shade600,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Kies een geplande datum en een begintijd voor de kraan.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Geplande datums',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...dagen.map(datumKaart),
        const SizedBox(height: 12),
        tijdBlok(),
        const SizedBox(height: 18),
        plaatsKnop(),
        if (widget.klant.kraanReservering?.gereserveerd == true) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: verwijderReservatie,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Kraanreservatie verwijderen'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      bottomNavigationBar: const OnderNavigatieBalk(
        huidigePagina: 'andere',
      ),
      body: SafeArea(
        child: Column(
          children: [
            groeneBalk(),
            Expanded(
              child: inhoud(),
            ),
          ],
        ),
      ),
    );
  }
}
