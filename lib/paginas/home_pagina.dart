import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../helpers/app_storage.dart';
import '../modellen/agenda_actie.dart';
import '../modellen/afspraak_klant.dart';
import '../modellen/klant.dart';
import '../modellen/leverancier.dart';
import '../services/home_service.dart';

import 'afspraak_klanten_pagina.dart';
import 'agenda_pagina.dart';
import 'klanten_pagina.dart';
import 'klantenfiche_pagina.dart';
import 'leveranciers_pagina.dart';
import 'notities_bureau_pagina.dart';
import 'puinzak_pagina.dart';

class HomePagina extends StatefulWidget {
  const HomePagina({super.key});

  @override
  State<HomePagina> createState() => _HomePaginaState();
}

class _HomePaginaState extends State<HomePagina> {
  List<Klant> alleKlanten = [];
  List<Leverancier> leveranciers = [];
  List<DateTime> vakantieDagen = [];
  List<AgendaActie> agendaActies = [];
  List<AfspraakKlant> afsprakenKlanten = [];

  bool isLaden = true;

  @override
  void initState() {
    super.initState();
    laadData();
  }

  Future<void> laadData() async {
    final geladenKlanten = await AppStorage.laadKlanten();
    final geladenLeveranciers = await AppStorage.laadLeveranciers();
    final geladenVakantieDagen = await AppStorage.laadVakantieDagen();
    final geladenAgendaActies = await AppStorage.laadAgendaActies();
    final geladenAfsprakenKlanten = await AppStorage.laadAfsprakenKlanten();

    if (!mounted) return;

    setState(() {
      alleKlanten = geladenKlanten;
      leveranciers = geladenLeveranciers;
      vakantieDagen = geladenVakantieDagen;
      agendaActies = geladenAgendaActies;
      afsprakenKlanten = geladenAfsprakenKlanten;
      isLaden = false;
    });
  }

  Future<void> bewaarAlles() async {
    await AppStorage.bewaarKlanten(alleKlanten);
    await AppStorage.bewaarLeveranciers(leveranciers);
    await AppStorage.bewaarVakantieDagen(vakantieDagen);

    if (!mounted) return;
    setState(() {});
  }

  Future<void> openPagina(BuildContext context, Widget pagina) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => pagina),
    );

    await laadData();
  }

  Widget agendaPagina({DateTime? focusDatum}) {
    return AgendaPagina(
      alleKlanten: alleKlanten,
      leveranciers: leveranciers,
      vakantieDagen: vakantieDagen,
      onGewijzigd: () async {
        await bewaarAlles();
        await laadData();
      },
      initialFocusDate: focusDatum,
      startInMonthView: focusDatum != null,
    );
  }

  Widget klantenfichePagina(Klant klant) {
    return KlantenfichePagina(
      klant: klant,
      alleKlanten: alleKlanten,
      leveranciers: leveranciers,
      vakantieDagen: vakantieDagen,
      isNieuweKlant: false,
      onOpslaan: (_) async {
        await bewaarAlles();
        await laadData();
      },
      onGewijzigd: () async {
        await bewaarAlles();
        await laadData();
      },
    );
  }

  List<Klant> actieveKlanten() {
    return alleKlanten.where((klant) => !klant.isProjectAfgewerkt).toList();
  }

  bool zelfdeDag(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String tijdTekst(int uur, int minuut) {
    return '${uur.toString().padLeft(2, '0')}:'
        '${minuut.toString().padLeft(2, '0')}';
  }

  List<_HomePlanningItem> planningVandaagItems() {
    final vandaag = DateTime.now();
    final List<_HomePlanningItem> items = [];

    for (final klant in alleKlanten) {
      for (final planning in klant.planningDagen) {
        if (!zelfdeDag(planning.datum, vandaag)) continue;

        int volgorde = 1;

        if (klant.isOpTeVolgen) {
          volgorde = 2;
        } else if (klant.isNadienst) {
          volgorde = 3;
        }

        items.add(
          _HomePlanningItem(
            volgorde: volgorde,
            titel:
                klant.klantnaam.isEmpty ? 'Klant zonder naam' : klant.klantnaam,
            subtitel:
                '${tijdTekst(planning.startUur, planning.startMinuut)} - ${tijdTekst(planning.eindUur, planning.eindMinuut)}',
            onTap: () => openPagina(context, klantenfichePagina(klant)),
          ),
        );
      }
    }
    for (final klant in alleKlanten) {
      final kraan = klant.kraanReservering;

      if (kraan == null) continue;
      if (!kraan.gereserveerd) continue;
      if (kraan.datum == null) continue;
      if (!zelfdeDag(kraan.datum!, vandaag)) continue;

      items.add(
        _HomePlanningItem(
          volgorde: 4,
          titel:
              klant.klantnaam.isEmpty ? 'Klant zonder naam' : klant.klantnaam,
          subtitel: kraan.tijdTekst.isEmpty
              ? 'Kraanreservatie'
              : 'Kraan ${kraan.tijdTekst}',
          onTap: () => openPagina(
            context,
            klantenfichePagina(klant),
          ),
        ),
      );
    }

    for (final afspraak in afsprakenKlanten) {
      if (!zelfdeDag(afspraak.datum, vandaag)) continue;

      items.add(
        _HomePlanningItem(
          volgorde: 5,
          titel: afspraak.klantNaam.isEmpty
              ? 'Klant zonder naam'
              : afspraak.klantNaam,
          subtitel: afspraak.ganseDag
              ? 'Ganse dag'
              : '${tijdTekst(afspraak.beginUur, afspraak.beginMinuut)} - ${tijdTekst(afspraak.eindUur, afspraak.eindMinuut)}',
          onTap: () => openPagina(
            context,
            AfspraakKlantenPagina(
              datum: afspraak.datum,
              bestaandeAfspraak: afspraak,
            ),
          ),
        ),
      );
    }

    return items;
  }

  Widget placeholderPagina(String titel) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            _GroeneBalk(
              toonTerug: true,
              onTerug: () => Navigator.pop(context),
            ),
            Expanded(
              child: Center(
                child: Text(
                  '$titel is nog in opbouw.',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String datumVandaagTekst() {
    final vandaag = DateTime.now();

    const dagen = [
      'maandag',
      'dinsdag',
      'woensdag',
      'donderdag',
      'vrijdag',
      'zaterdag',
      'zondag',
    ];

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

    return '${dagen[vandaag.weekday - 1]} ${vandaag.day} ${maanden[vandaag.month - 1]} ${vandaag.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (isLaden) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final planningVandaag = planningVandaagItems();
    final klantTakenVandaag = HomeService.klantTaakItemsVandaag(alleKlanten);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _GroeneBalk(
              subtitel: datumVandaagTekst(),
              toonMenu: true,
              onMenu: () {},
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 148,
                    margin: const EdgeInsets.fromLTRB(10, 10, 6, 10),
                    child: ListView(
                      children: [
                        _zijTegel(
                          titel: 'Agenda',
                          icoon: Icons.calendar_month,
                          kleur: const Color(0xFF0B7A3B),
                          onTap: () => openPagina(context, agendaPagina()),
                        ),
                        _zijTegel(
                          titel: 'Klanten',
                          icoon: Icons.groups,
                          kleur: const Color(0xFFF06418),
                          onTap: () => openPagina(
                            context,
                            const KlantenPagina(),
                          ),
                        ),
                        _zijTegel(
                          titel: 'Notities bureau',
                          icoon: Icons.description_outlined,
                          kleur: Colors.blue,
                          onTap: () => openPagina(
                            context,
                            const NotitiesBureauPagina(),
                          ),
                        ),
                        _zijTegel(
                          titel: 'Notities plaatsers',
                          icoon: Icons.assignment_outlined,
                          kleur: Colors.amber,
                          onTap: () => openPagina(
                            context,
                            placeholderPagina('Notities plaatsers'),
                          ),
                        ),
                        _zijTegel(
                          titel: 'Magazijn',
                          icoon: Icons.warehouse,
                          kleur: Colors.orange,
                          onTap: () => openPagina(
                            context,
                            placeholderPagina('Magazijn'),
                          ),
                        ),
                        _zijTegel(
                          titel: 'Puinzak',
                          icoon: Icons.delete_outline,
                          kleur: Colors.deepPurple,
                          onTap: () => openPagina(
                            context,
                            PuinzakPagina(
                              actieveKlanten: actieveKlanten(),
                              onGewijzigd: () async {
                                await bewaarAlles();
                                await laadData();
                              },
                            ),
                          ),
                        ),
                        _zijTegel(
                          titel: 'Leveranciers',
                          icoon: Icons.local_shipping_outlined,
                          kleur: Colors.teal,
                          onTap: () => openPagina(
                            context,
                            LeveranciersPagina(
                              leveranciers: leveranciers,
                              onGewijzigd: () async {
                                await bewaarAlles();
                                await laadData();
                              },
                            ),
                          ),
                        ),
                        _zijTegel(
                          titel: 'Instellingen',
                          icoon: Icons.settings,
                          kleur: Colors.blueGrey,
                          onTap: () => openPagina(
                            context,
                            placeholderPagina('Instellingen'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(14, 14, 18, 24),
                      children: [
                        const Text(
                          'Vandaag',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _CompactPlanningLijst(
                          titel: 'Planning vandaag',
                          kleur: Colors.green,
                          items: planningVandaag
                              .where((e) => e.volgorde == 1)
                              .toList(),
                        ),
                        _CompactPlanningLijst(
                          titel: 'Planning op te volgen',
                          kleur: const Color(0xFF0F766E),
                          items: planningVandaag
                              .where((e) => e.volgorde == 2)
                              .toList(),
                        ),
                        _CompactPlanningLijst(
                          titel: 'Nadienst',
                          kleur: Colors.purple,
                          items: planningVandaag
                              .where((e) => e.volgorde == 3)
                              .toList(),
                        ),
                        _CompactPlanningLijst(
                          titel: 'Kraanreservatie',
                          kleur: Colors.brown,
                          items: planningVandaag
                              .where((e) => e.volgorde == 4)
                              .toList(),
                        ),
                        _CompactDagtaakLijst(
                          acties: agendaActies.where((actie) {
                            final vandaag = DateTime.now();
                            final toonDatum = actie.datum.subtract(
                              Duration(days: actie.dagenVoorafTonen),
                            );

                            return zelfdeDag(toonDatum, vandaag);
                          }).toList(),
                          tijdTekst: tijdTekst,
                          onTapActie: (actie) => openPagina(
                            context,
                            agendaPagina(focusDatum: actie.datum),
                          ),
                          onAfvinken: (actie) async {
                            setState(() {
                              actie.isAfgewerkt = !actie.isAfgewerkt;
                            });

                            await AppStorage.bewaarAgendaActies(agendaActies);
                          },
                        ),
                        _CompactKlantTakenLijst(
                          taken: klantTakenVandaag,
                          onTapKlant: (item) => openPagina(
                            context,
                            klantenfichePagina(item.klant),
                          ),
                          onAfvinken: (item) async {
                            setState(() {
                              item.taak.isAfgewerkt = !item.taak.isAfgewerkt;
                            });

                            await bewaarAlles();
                            await laadData();
                          },
                        ),
                        _CompactPlanningLijst(
                          titel: 'Planning klanten',
                          kleur: Colors.blue,
                          items: planningVandaag
                              .where((e) => e.volgorde == 5)
                              .toList(),
                        ),
                      ],
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

  Widget _zijTegel({
    required String titel,
    required IconData icoon,
    required Color kleur,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 7),
            decoration: BoxDecoration(
              color: kleur.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: kleur.withValues(alpha: 0.16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 31,
                  height: 31,
                  decoration: BoxDecoration(
                    color: kleur.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    icoon,
                    color: kleur,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    titel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: kleur,
                  size: 17,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GroeneBalk extends StatelessWidget {
  final String? subtitel;
  final bool toonMenu;
  final bool toonTerug;
  final VoidCallback? onMenu;
  final VoidCallback? onTerug;

  const _GroeneBalk({
    this.subtitel,
    this.toonMenu = false,
    this.toonTerug = false,
    this.onMenu,
    this.onTerug,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF064321),
            Color(0xFF0B7A3B),
            Color(0xFF119A4A),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 4,
              color: Color(0xFFF06418),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 14, 8),
            child: Row(
              children: [
                if (toonTerug)
                  IconButton(
                    onPressed: onTerug,
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white,
                  ),
                Expanded(
                  flex: 5,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'THI',
                          style: GoogleFonts.montserrat(
                            fontSize: 26,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 2,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: 'M',
                          style: GoogleFonts.montserrat(
                            fontSize: 26,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2,
                            color: const Color(0xFFF06418),
                          ),
                        ),
                        TextSpan(
                          text: 'ACO',
                          style: GoogleFonts.montserrat(
                            fontSize: 26,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 2,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 42,
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  color: Colors.black.withValues(alpha: 0.25),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Icon(
                    Icons.calendar_month,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: Text(
                    subtitel ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (toonMenu)
                  IconButton(
                    onPressed: onMenu,
                    icon: const Icon(Icons.more_vert),
                    color: Colors.white,
                    iconSize: 28,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomePlanningItem {
  final int volgorde;
  final String titel;
  final String subtitel;
  final VoidCallback onTap;

  _HomePlanningItem({
    required this.volgorde,
    required this.titel,
    required this.subtitel,
    required this.onTap,
  });
}

class _CompactKlantTakenLijst extends StatelessWidget {
  final List<KlantTaakVandaagItem> taken;
  final ValueChanged<KlantTaakVandaagItem> onTapKlant;
  final ValueChanged<KlantTaakVandaagItem> onAfvinken;

  const _CompactKlantTakenLijst({
    required this.taken,
    required this.onTapKlant,
    required this.onAfvinken,
  });

  @override
  Widget build(BuildContext context) {
    if (taken.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.teal.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Taak voor klant',
            style: TextStyle(
              color: Colors.teal,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          ...taken.map((item) {
            final klantNaam = item.klant.klantnaam.isEmpty
                ? 'Klant zonder naam'
                : item.klant.klantnaam;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: () => onAfvinken(item),
                    icon: Icon(
                      item.taak.isAfgewerkt
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 21,
                      color: item.taak.isAfgewerkt ? Colors.green : Colors.teal,
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => onTapKlant(item),
                      child: Text(
                        '${item.taak.tekst} • $klantNaam',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: item.taak.isAfgewerkt
                              ? Colors.grey
                              : Colors.black,
                          decoration: item.taak.isAfgewerkt
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CompactPlanningLijst extends StatelessWidget {
  final String titel;
  final Color kleur;
  final List<_HomePlanningItem> items;

  const _CompactPlanningLijst({
    required this.titel,
    required this.kleur,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: kleur.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titel,
            style: TextStyle(
              color: kleur,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 105,
                    child: Text(
                      item.subtitel,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: item.onTap,
                      child: Text(
                        item.titel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CompactDagtaakLijst extends StatelessWidget {
  final List<AgendaActie> acties;
  final String Function(int uur, int minuut) tijdTekst;
  final ValueChanged<AgendaActie> onTapActie;
  final Future<void> Function(AgendaActie actie) onAfvinken;

  const _CompactDagtaakLijst({
    required this.acties,
    required this.tijdTekst,
    required this.onTapActie,
    required this.onAfvinken,
  });

  @override
  Widget build(BuildContext context) {
    if (acties.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dagtaak',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          ...acties.map((actie) {
            final tijd = actie.weergaveType == 'tijdsduur'
                ? '${tijdTekst(actie.startUur ?? 0, actie.startMinuut ?? 0)} - ${tijdTekst(actie.eindUur ?? 0, actie.eindMinuut ?? 0)}'
                : actie.dagenVoorafTonen > 0
                    ? '${actie.dagenVoorafTonen} dag(en) vooraf'
                    : 'Vandaag';

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      await onAfvinken(actie);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        actie.isAfgewerkt
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 20,
                        color: actie.isAfgewerkt ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 105,
                    child: Text(
                      tijd,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: actie.isAfgewerkt ? Colors.grey : Colors.black87,
                        decoration: actie.isAfgewerkt
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => onTapActie(actie),
                      child: Text(
                        actie.titel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: actie.isAfgewerkt ? Colors.grey : Colors.black,
                          decoration: actie.isAfgewerkt
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
