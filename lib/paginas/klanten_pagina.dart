import 'package:flutter/material.dart';

import '../helpers/app_storage.dart';
import '../helpers/status_helper.dart';
import '../modellen/klant.dart';
import '../modellen/leverancier.dart';

import 'agenda_pagina.dart';
import 'klantenfiche_pagina.dart';
import 'package:flutter/cupertino.dart';
import '../helpers/widgets/onder_navigatie_balk.dart';

enum KlantGroep { alle, actief, opvolgen, afgewerkt, nadienst }

enum KlantStatusFilter {
  alle,
  nietAllesBesteld,
  allesBesteld,
  allesGeleverd,
  geenArtikelsNodig,
}

class KlantenPagina extends StatefulWidget {
  const KlantenPagina({super.key});

  @override
  State<KlantenPagina> createState() => _KlantenPaginaState();
}

class _KlantenPaginaState extends State<KlantenPagina> {
  final TextEditingController zoekController = TextEditingController();

  List<Klant> alleKlanten = [];
  List<Leverancier> leveranciers = [];
  List<DateTime> vakantieDagen = [];

  bool isLaden = true;

  String zoekterm = '';

  bool toonZoekveld = false;

  KlantGroep gekozenGroep = KlantGroep.alle;
  KlantStatusFilter gekozenStatus = KlantStatusFilter.alle;

  @override
  void initState() {
    super.initState();
    laadData();
  }

  @override
  void dispose() {
    zoekController.dispose();
    super.dispose();
  }

  Future<void> laadData() async {
    final geladenKlanten = await AppStorage.laadKlanten();
    final geladenLeveranciers = await AppStorage.laadLeveranciers();
    final geladenVakantieDagen = await AppStorage.laadVakantieDagen();

    if (!mounted) return;

    setState(() {
      alleKlanten = geladenKlanten;
      leveranciers = geladenLeveranciers;
      vakantieDagen = geladenVakantieDagen;
      isLaden = false;
    });
  }

  Future<void> bewaarAlles() async {
    await AppStorage.bewaarAlles(
      klanten: alleKlanten,
      leveranciers: leveranciers,
      vakantieDagen: vakantieDagen,
    );
  }

  bool hoortInGroep(Klant klant, KlantGroep groep) {
    switch (groep) {
      case KlantGroep.alle:
        return true;
      case KlantGroep.actief:
        return !klant.isProjectAfgewerkt &&
            !klant.isNadienst &&
            !klant.isOpTeVolgen;
      case KlantGroep.opvolgen:
        return !klant.isProjectAfgewerkt &&
            !klant.isNadienst &&
            klant.isOpTeVolgen;
      case KlantGroep.afgewerkt:
        return klant.isProjectAfgewerkt;
      case KlantGroep.nadienst:
        return !klant.isProjectAfgewerkt && klant.isNadienst;
    }
  }

  bool hoortBijStatus(Klant klant, KlantStatusFilter filter) {
    final status = StatusHelper.bepaalStatus(klant);

    switch (filter) {
      case KlantStatusFilter.alle:
        return true;
      case KlantStatusFilter.nietAllesBesteld:
        return status == 'Nog niet alles besteld';
      case KlantStatusFilter.allesBesteld:
        return status == 'Alles besteld';
      case KlantStatusFilter.allesGeleverd:
        return status == 'Alles geleverd';
      case KlantStatusFilter.geenArtikelsNodig:
        return status == 'geen artikels nodig';
    }
  }

  int statusVolgorde(Klant klant) {
    final status = StatusHelper.bepaalStatus(klant);

    if (status == 'Nog niet alles besteld') return 1;
    if (status == 'Alles besteld') return 2;
    if (status == 'Alles geleverd') return 3;
    if (status == 'geen artikels nodig') return 4;

    return 9;
  }

  List<Klant> get getoondeKlanten {
    int levenshteinAfstand(String a, String b) {
      if (a == b) return 0;
      if (a.isEmpty) return b.length;
      if (b.isEmpty) return a.length;

      final matrix = List.generate(
        a.length + 1,
        (i) => List<int>.filled(b.length + 1, 0),
      );

      for (int i = 0; i <= a.length; i++) {
        matrix[i][0] = i;
      }

      for (int j = 0; j <= b.length; j++) {
        matrix[0][j] = j;
      }

      for (int i = 1; i <= a.length; i++) {
        for (int j = 1; j <= b.length; j++) {
          final kost = a[i - 1] == b[j - 1] ? 0 : 1;

          matrix[i][j] = [
            matrix[i - 1][j] + 1,
            matrix[i][j - 1] + 1,
            matrix[i - 1][j - 1] + kost,
          ].reduce((a, b) => a < b ? a : b);
        }
      }

      return matrix[a.length][b.length];
    }

    bool lijktOpZoekterm(String tekst, String zoekterm) {
      final tekstLaag = tekst.toLowerCase().trim();
      final zoekLaag = zoekterm.toLowerCase().trim();

      if (zoekLaag.isEmpty) return true;
      if (tekstLaag.contains(zoekLaag)) return true;

      final woorden = tekstLaag.split(RegExp(r'\s+'));

      for (final woord in woorden) {
        final afstand = levenshteinAfstand(woord, zoekLaag);

        if (zoekLaag.length <= 4 && afstand <= 1) return true;
        if (zoekLaag.length <= 7 && afstand <= 2) return true;
        if (zoekLaag.length > 7 && afstand <= 3) return true;
      }

      return false;
    }

    var resultaat = alleKlanten.where((klant) {
      return hoortInGroep(klant, gekozenGroep) &&
          hoortBijStatus(klant, gekozenStatus);
    }).toList();

    if (zoekterm.trim().isNotEmpty) {
      resultaat = resultaat.where((klant) {
        return lijktOpZoekterm(klant.klantnaam, zoekterm) ||
            klant.adres.toLowerCase().contains(zoekterm.toLowerCase()) ||
            klant.klantenNr.toLowerCase().contains(zoekterm.toLowerCase());
      }).toList();
    }

    resultaat.sort((a, b) {
      final statusVergelijk = statusVolgorde(a).compareTo(statusVolgorde(b));
      if (statusVergelijk != 0) return statusVergelijk;

      return a.klantnaam.toLowerCase().compareTo(b.klantnaam.toLowerCase());
    });

    return resultaat;
  }

  Future<void> openKlantenfiche(Klant klant) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KlantenfichePagina(
          klant: klant,
          alleKlanten: alleKlanten,
          leveranciers: leveranciers,
          vakantieDagen: vakantieDagen,
          isNieuweKlant: false,
          onOpslaan: (_) async => await bewaarAlles(),
          onGewijzigd: bewaarAlles,
        ),
      ),
    );

    await laadData();
  }

  void openNieuweKlantenfiche() {
    final nieuweKlant = Klant(
      klantenNr: '',
      klantnaam: '',
      adres: '',
      telefoon: '',
      email: '',
      opmerkingen: '',
      klantLeveranciers: [],
      planningDagen: [],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KlantenfichePagina(
          klant: nieuweKlant,
          alleKlanten: alleKlanten,
          leveranciers: leveranciers,
          vakantieDagen: vakantieDagen,
          isNieuweKlant: true,
          onOpslaan: (klant) async {
            if (!alleKlanten.contains(klant)) {
              alleKlanten.insert(0, klant);
            }

            await bewaarAlles();
          },
          onGewijzigd: bewaarAlles,
        ),
      ),
    ).then((_) async {
      await laadData();
    });
  }

  DateTime? eerstePlanningDatum(Klant klant) {
    if (klant.planningDagen.isEmpty) return null;

    final datums = klant.planningDagen.map((planning) {
      return DateTime(
        planning.datum.year,
        planning.datum.month,
        planning.datum.day,
      );
    }).toList();

    datums.sort((a, b) => a.compareTo(b));
    return datums.first;
  }

  Future<void> openAgendaVoorKlant(Klant klant) async {
    final datum = eerstePlanningDatum(klant);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgendaPagina(
          alleKlanten: alleKlanten,
          leveranciers: leveranciers,
          vakantieDagen: vakantieDagen,
          onGewijzigd: bewaarAlles,
          initialFocusDate: datum,
          startInMonthView: true,
          highlightedKlant: klant,
        ),
      ),
    );

    await laadData();
  }

  Future<void> wisKlant(Klant klant) async {
    if (!klant.isProjectAfgewerkt) return;

    final naam =
        klant.klantnaam.trim().isEmpty ? 'Klant zonder naam' : klant.klantnaam;

    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Klant verwijderen'),
          content: Text('Wil je "$naam" zeker verwijderen?'),
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
      alleKlanten.remove(klant);
    });

    await bewaarAlles();
  }

  Color groepKleur(KlantGroep groep) {
    switch (groep) {
      case KlantGroep.alle:
        return Colors.green;
      case KlantGroep.actief:
        return Colors.green;
      case KlantGroep.opvolgen:
        return Colors.orange;
      case KlantGroep.afgewerkt:
        return Colors.blueGrey;
      case KlantGroep.nadienst:
        return Colors.deepPurple;
    }
  }

  String groepNaam(KlantGroep groep) {
    switch (groep) {
      case KlantGroep.alle:
        return 'Alle';
      case KlantGroep.actief:
        return 'Actief';
      case KlantGroep.opvolgen:
        return 'Op te volgen';
      case KlantGroep.afgewerkt:
        return 'Afgewerkt';
      case KlantGroep.nadienst:
        return 'Nadienst';
    }
  }

  Color artikelFilterKleur(KlantStatusFilter filter) {
    switch (filter) {
      case KlantStatusFilter.alle:
        return Colors.green;
      case KlantStatusFilter.nietAllesBesteld:
        return Colors.red;
      case KlantStatusFilter.allesBesteld:
        return Colors.blue;
      case KlantStatusFilter.allesGeleverd:
        return Colors.green;
      case KlantStatusFilter.geenArtikelsNodig:
        return Colors.grey;
    }
  }

  String artikelFilterNaam(KlantStatusFilter filter) {
    switch (filter) {
      case KlantStatusFilter.alle:
        return 'Alle';
      case KlantStatusFilter.nietAllesBesteld:
        return 'Niet besteld';
      case KlantStatusFilter.allesBesteld:
        return 'Alles besteld';
      case KlantStatusFilter.allesGeleverd:
        return 'Alles geleverd';
      case KlantStatusFilter.geenArtikelsNodig:
        return 'Geen nodig';
    }
  }

  String korteArtikelStatus(String status) {
    switch (status) {
      case 'Nog niet alles besteld':
        return 'Niet besteld';
      case 'Alles besteld':
        return 'Alles besteld';
      case 'Alles geleverd':
        return 'Alles geleverd';
      case 'geen artikels nodig':
        return 'Geen nodig';
      default:
        return status;
    }
  }

  String projectStatusTekst(Klant klant) {
    if (klant.isProjectAfgewerkt) return 'Afgewerkt';
    if (klant.isNadienst) return 'Nadienst';
    if (klant.isOpTeVolgen) return 'Op te volgen';
    return 'Actief project';
  }

  Color projectStatusKleur(Klant klant) {
    if (klant.isProjectAfgewerkt) return Colors.blueGrey;
    if (klant.isNadienst) return Colors.deepPurple;
    if (klant.isOpTeVolgen) return Colors.orange;
    return Colors.blue;
  }

  IconData projectStatusIcoon(Klant klant) {
    if (klant.isProjectAfgewerkt) return Icons.check_circle_outline;
    if (klant.isNadienst) return Icons.folder;
    if (klant.isOpTeVolgen) return Icons.access_time;
    return Icons.circle;
  }

  IconData klantIcoon(Klant klant) {
    if (klant.isProjectAfgewerkt) return Icons.check_circle;
    if (klant.isNadienst) return Icons.precision_manufacturing;
    if (klant.isOpTeVolgen) return Icons.person;
    return Icons.business;
  }

  Widget headerBlok() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
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
            iconSize: 30,
          ),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              'Klanten',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                toonZoekveld = !toonZoekveld;

                if (!toonZoekveld) {
                  zoekterm = '';
                  zoekController.clear();
                }
              });
            },
            icon: Icon(
              toonZoekveld ? Icons.close : Icons.search,
            ),
            color: Colors.white,
            iconSize: 32,
          ),
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: IconButton(
              onPressed: openNieuweKlantenfiche,
              icon: const Icon(Icons.add),
              color: Colors.green,
              iconSize: 30,
              tooltip: 'Nieuwe klant',
            ),
          ),
        ],
      ),
    );
  }

  Widget zoekBalk() {
    return TextField(
      controller: zoekController,
      onChanged: (waarde) {
        setState(() {
          zoekterm = waarde;
        });
      },
      decoration: InputDecoration(
        hintText: 'Zoek klant...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: zoekterm.isNotEmpty
            ? IconButton(
                onPressed: () {
                  zoekController.clear();
                  setState(() {
                    zoekterm = '';
                  });
                },
                icon: const Icon(Icons.clear),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget schuifKeuze<T>({
    required List<T> waarden,
    required T gekozenWaarde,
    required String Function(T waarde) label,
    required Color Function(T waarde) kleur,
    required ValueChanged<T> onChanged,
  }) {
    final gekozenIndex = waarden.indexOf(gekozenWaarde);
    final actieveKleur = kleur(gekozenWaarde);

    void kiesDichtstbijzijnde(double dx, double breedte) {
      final segmentBreedte = breedte / waarden.length;
      final index = (dx / segmentBreedte).floor().clamp(0, waarden.length - 1);
      onChanged(waarden[index]);
    }

    return Column(
      children: [
        Container(
          height: 58,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: waarden.map((waarde) {
              final actief = waarde == gekozenWaarde;
              final itemKleur = kleur(waarde);

              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(waarde),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: actief ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: actief
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.14),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : [],
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        style: TextStyle(
                          color: actief ? itemKleur : Colors.grey.shade600,
                          fontSize: actief ? 15 : 12,
                          fontWeight:
                              actief ? FontWeight.w800 : FontWeight.w500,
                        ),
                        child: Text(
                          label(waarde),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final breedte = constraints.maxWidth;
            final segmentBreedte = breedte / waarden.length;

            double centerVoorIndex(int index) {
              return (segmentBreedte * index) + (segmentBreedte / 2);
            }

            final eersteCenter = centerVoorIndex(0);
            final laatsteCenter = centerVoorIndex(waarden.length - 1);
            final actiefCenter = centerVoorIndex(gekozenIndex);

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                kiesDichtstbijzijnde(details.localPosition.dx, breedte);
              },
              onHorizontalDragUpdate: (details) {
                kiesDichtstbijzijnde(details.localPosition.dx, breedte);
              },
              onHorizontalDragEnd: (_) {
                setState(() {});
              },
              child: SizedBox(
                height: 32,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Positioned(
                      left: eersteCenter,
                      right: breedte - laatsteCenter,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    Positioned(
                      left: eersteCenter,
                      width: actiefCenter - eersteCenter,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        height: 4,
                        decoration: BoxDecoration(
                          color: actieveKleur,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    ...List.generate(waarden.length, (index) {
                      final waarde = waarden[index];
                      final isActief = index == gekozenIndex;
                      final dotSize = isActief ? 24.0 : 16.0;
                      final center = centerVoorIndex(index);

                      return AnimatedPositioned(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        left: center - (dotSize / 2),
                        top: (32 - dotSize) / 2,
                        child: GestureDetector(
                          onTap: () => onChanged(waarde),
                          onHorizontalDragUpdate: (details) {
                            final box =
                                context.findRenderObject() as RenderBox?;
                            if (box == null) return;

                            final local =
                                box.globalToLocal(details.globalPosition);
                            kiesDichtstbijzijnde(local.dx, breedte);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            width: dotSize,
                            height: dotSize,
                            decoration: BoxDecoration(
                              color: isActief
                                  ? actieveKleur
                                  : Colors.grey.shade300,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: isActief ? 3 : 2,
                              ),
                              boxShadow: isActief
                                  ? [
                                      BoxShadow(
                                        color: actieveKleur.withValues(
                                          alpha: 0.35,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : [],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget chip({
    required String tekst,
    required IconData icoon,
    required Color kleur,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: kleur.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kleur.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icoon, color: kleur, size: 15),
          const SizedBox(width: 5),
          Text(
            tekst,
            style: TextStyle(
              color: kleur,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget klantRij(Klant klant) {
    final artikelStatus = StatusHelper.bepaalStatus(klant);
    final artikelKleur = StatusHelper.bepaalStatusKleur(artikelStatus);
    final projectKleur = projectStatusKleur(klant);

    return InkWell(
      onTap: () => openKlantenfiche(klant),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 22,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      klant.klantnaam.isEmpty
                          ? 'Klant zonder naam'
                          : klant.klantnaam,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text(
                          'Status: ',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            projectStatusTekst(klant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: projectKleur,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Text(
                          'Artikelen status: ',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            korteArtikelStatus(artikelStatus),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: artikelKleur,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 34,
                minHeight: 34,
              ),
              onPressed: () => openAgendaVoorKlant(klant),
              icon: const Icon(
                Icons.calendar_month_outlined,
                size: 19,
              ),
              color: Colors.green,
              tooltip: 'Naar planning',
            ),
            if (klant.isProjectAfgewerkt)
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 34,
                  minHeight: 34,
                ),
                onPressed: () => wisKlant(klant),
                icon: const Icon(
                  Icons.delete_outline,
                  size: 19,
                ),
                color: Colors.red,
                tooltip: 'Klant verwijderen',
              ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade500,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLaden) {
      return Scaffold(
        bottomNavigationBar: OnderNavigatieBalk(
          huidigePagina: 'klanten',
          onAgenda: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final klanten = getoondeKlanten;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      bottomNavigationBar: OnderNavigatieBalk(
        huidigePagina: 'klanten',
        onAgenda: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AgendaPagina(
                alleKlanten: alleKlanten,
                leveranciers: leveranciers,
                vakantieDagen: vakantieDagen,
                onGewijzigd: bewaarAlles,
              ),
            ),
          );
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            headerBlok(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoSlidingSegmentedControl<KlantGroep>(
                      groupValue: gekozenGroep,
                      backgroundColor: Colors.grey.shade200,
                      thumbColor: Colors.green,
                      children: const {
                        KlantGroep.alle: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          child: Text('Alle',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        KlantGroep.actief: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          child: Text('Actief',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        KlantGroep.opvolgen: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          child: Text('Opvolgen',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        KlantGroep.afgewerkt: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          child: Text('Afgewerkt',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        KlantGroep.nadienst: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          child: Text('Nadienst',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      },
                      onValueChanged: (waarde) {
                        if (waarde == null) return;

                        setState(() {
                          gekozenGroep = waarde;
                          gekozenStatus = KlantStatusFilter.alle;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Artikelen status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoSlidingSegmentedControl<KlantStatusFilter>(
                      groupValue: gekozenStatus,
                      backgroundColor: Colors.grey.shade200,
                      thumbColor: Colors.green,
                      children: const {
                        KlantStatusFilter.alle: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          child: Text('Alle',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        KlantStatusFilter.nietAllesBesteld: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          child: Text('Niet besteld',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        KlantStatusFilter.allesBesteld: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          child: Text('Besteld',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        KlantStatusFilter.allesGeleverd: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          child: Text('Geleverd',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        KlantStatusFilter.geenArtikelsNodig: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          child: Text('Geen nodig',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      },
                      onValueChanged: (waarde) {
                        if (waarde == null) return;

                        setState(() {
                          gekozenStatus = waarde;
                        });
                      },
                    ),
                  ),
                  if (toonZoekveld) ...[
                    const SizedBox(height: 18),
                    zoekBalk(),
                    const SizedBox(height: 18),
                  ],
                  if (klanten.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child:
                          const Center(child: Text('Geen klanten gevonden.')),
                    )
                  else
                    ...klanten.map(klantRij),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
