import 'package:flutter/material.dart';

import '../../paginas/klanten_fiche_pagina.dart';
import 'fiche/klantenfiche_model.dart';
import 'fiche/klantenfiche_repository.dart';

class KlantenLijst extends StatefulWidget {
  final String klantStatus;
  final String bestelStatus;
  final String zoekterm;

  const KlantenLijst({
    super.key,
    required this.klantStatus,
    required this.bestelStatus,
    required this.zoekterm,
  });

  @override
  State<KlantenLijst> createState() => _KlantenLijstState();
}

class _KlantenLijstState extends State<KlantenLijst> {
  static const groen = Color(0xFF0B7A3B);
  static const rand = Color(0xFFE5E7EB);

  final statusVolgorde = const [
    'Actief',
    'Opvolgen',
    'Nadienst',
    'Afgewerkt',
  ];

  Color kleurVoorKlantStatus(String status) {
    switch (status) {
      case 'Actief':
        return const Color(0xFF7BC67E);
      case 'Opvolgen':
        return Colors.amber;
      case 'Nadienst':
        return Colors.purple;
      case 'Afgewerkt':
      default:
        return groen;
    }
  }

  Color kleurVoorBestelStatus(String status) {
    switch (status) {
      case 'Te bestellen':
        return Colors.red;
      case 'Besteld':
        return Colors.blue;
      case 'Geleverd':
        return const Color(0xFF7BC67E);
      case 'Geen artikelen':
      default:
        return groen;
    }
  }

  int bestelStatusScore(String status) {
    switch (status) {
      case 'Te bestellen':
        return 0;
      case 'Besteld':
        return 1;
      case 'Geleverd':
        return 2;
      case 'Geen artikelen':
      default:
        return 3;
    }
  }

  List<KlantenficheModel> filterKlanten(
    List<KlantenficheModel> alleKlanten,
  ) {
    return alleKlanten.where((klant) {
      if (klant.archiefDatum.isNotEmpty) {
        return false;
      }
      final matchKlantStatus = widget.klantStatus == 'Alle'
          ? true
          : klant.klantStatus == widget.klantStatus;

      final matchBestelStatus = widget.bestelStatus == 'Alle' ||
          klant.bestelStatus == widget.bestelStatus;

      final zoek = widget.zoekterm.trim().toLowerCase();

      final matchZoek = zoek.isEmpty ||
          klant.naam.toLowerCase().contains(zoek) ||
          klant.straatnaam.toLowerCase().contains(zoek) ||
          klant.gemeente.toLowerCase().contains(zoek) ||
          klant.postcode.toLowerCase().contains(zoek) ||
          klant.gsm.toLowerCase().contains(zoek) ||
          klant.email.toLowerCase().contains(zoek);

      return matchKlantStatus && matchBestelStatus && matchZoek;
    }).toList();
  }

  List<KlantenficheModel> sorteerKlanten(
    List<KlantenficheModel> klanten,
  ) {
    final lijst = List<KlantenficheModel>.from(klanten);

    lijst.sort((a, b) {
      if (a.klaarVoorNieuwePlanning && !b.klaarVoorNieuwePlanning) {
        return -1;
      }

      if (!a.klaarVoorNieuwePlanning && b.klaarVoorNieuwePlanning) {
        return 1;
      }

      final statusVergelijk = bestelStatusScore(a.bestelStatus).compareTo(
        bestelStatusScore(b.bestelStatus),
      );

      if (statusVergelijk != 0) {
        return statusVergelijk;
      }

      return a.naam.toLowerCase().compareTo(
            b.naam.toLowerCase(),
          );
    });

    return lijst;
  }

  Future<void> openFiche(
    KlantenficheModel klant,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KlantenFichePagina(
          bestaandeFiche: klant,
        ),
      ),
    );

    if (!mounted) return;

    setState(() {});
  }

  Future<void> verwijderFiche(
    KlantenficheModel klant,
  ) async {
    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Klant verwijderen?'),
          content: Text(
            'Bent u zeker dat u "${klant.naam.isEmpty ? 'Naamloos' : klant.naam}" wilt verwijderen? Dit kan niet ongedaan gemaakt worden.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Annuleren',
                style: TextStyle(
                  color: groen,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Verwijderen',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (bevestigen != true) return;

    await KlantenficheRepository.verwijderKlantenFiche(
      klant.id,
    );

    if (!mounted) return;

    setState(() {});
  }

  Future<void> archiveerKlant(
    KlantenficheModel klant,
  ) async {
    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Klant archiveren?'),
          content: Text(
            'Bent u zeker dat u "${klant.naam}" naar het archief wilt verplaatsen?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Annuleren'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Archiveren',
                style: TextStyle(
                  color: Color(0xFF0B7A3B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (bevestigen != true) return;

    final aangepasteFiche = KlantenficheModel(
      id: klant.id,
      updatedAt: DateTime.now().toIso8601String(),
      deletedAt: '',
      naam: klant.naam,
      klantNr: klant.klantNr,
      straatnaam: klant.straatnaam,
      huisNr: klant.huisNr,
      gemeente: klant.gemeente,
      postcode: klant.postcode,
      gsm: klant.gsm,
      gsm2: klant.gsm2,
      email: klant.email,
      klantStatus: klant.klantStatus,
      bestelStatus: klant.bestelStatus,
      taakVoorKlant: klant.taakVoorKlant,
      klantTakenAfgewerktOp: klant.klantTakenAfgewerktOp,
      datumAfgewerkt: klant.datumAfgewerkt,
      archiefDatum: DateTime.now().toIso8601String(),
      artikelen: klant.artikelen,
      klantTaken: klant.klantTaken,
      extraWerken: klant.extraWerken,
      fotos: klant.fotos,
      opvolgTaken: klant.opvolgTaken,
      opvolgFicheVerstuurdNaarBureau: klant.opvolgFicheVerstuurdNaarBureau,
      klaarVoorNieuwePlanning: klant.klaarVoorNieuwePlanning,
    );

    await KlantenficheRepository.bewaarKlantenFiche(
      aangepasteFiche,
    );

    if (!mounted) return;

    setState(() {});
  }

  Widget statusGroep({
    required String titel,
    required List<KlantenficheModel> klanten,
    required bool isTablet,
  }) {
    final kleur = kleurVoorKlantStatus(titel);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$titel (${klanten.length})',
            style: TextStyle(
              color: kleur,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          if (klanten.isEmpty)
            legeCategorieRij()
          else
            ...klanten.map((klant) {
              return klantRij(
                klant: klant,
                isTablet: isTablet,
              );
            }),
        ],
      ),
    );
  }

  Widget legeCategorieRij() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: rand,
        ),
      ),
      child: const Text(
        'Geen klanten in deze categorie.',
        style: TextStyle(
          fontSize: 13,
          color: Color(0xFF6B7280),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget klantRij({
    required KlantenficheModel klant,
    required bool isTablet,
  }) {
    final naam = klant.naam.isEmpty ? 'Naamloos' : klant.naam;
    final bestelKleur = kleurVoorBestelStatus(klant.bestelStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: rand,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          openFiche(klant);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 16 : 12,
            vertical: isTablet ? 13 : 11,
          ),
          child: isTablet
              ? Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(
                        naam,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Center(
                        child: statusTekstLabel(
                          tekst: klant.bestelStatus,
                          kleur: bestelKleur,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (klant.klantStatus == 'Afgewerkt')
                          SizedBox(
                            width: 42,
                            child: IconButton(
                              tooltip: 'Naar archief',
                              onPressed: () {
                                archiveerKlant(klant);
                              },
                              icon: const Icon(
                                Icons.inventory_2_outlined,
                                color: Color(0xFF0B7A3B),
                              ),
                            ),
                          ),
                        SizedBox(
                          width: 42,
                          child: IconButton(
                            onPressed: () {
                              verwijderFiche(klant);
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(
                        naam,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Center(
                        child: statusTekstLabel(
                          tekst: klant.bestelStatus,
                          kleur: bestelKleur,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (klant.klantStatus == 'Afgewerkt')
                          SizedBox(
                            width: 42,
                            child: IconButton(
                              tooltip: 'Naar archief',
                              onPressed: () {
                                archiveerKlant(klant);
                              },
                              icon: const Icon(
                                Icons.inventory_2_outlined,
                                color: Color(0xFF0B7A3B),
                              ),
                            ),
                          ),
                        SizedBox(
                          width: 42,
                          child: IconButton(
                            onPressed: () {
                              verwijderFiche(klant);
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget statusTekstLabel({
    required String tekst,
    required Color kleur,
  }) {
    return Text(
      tekst,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: kleur,
        fontSize: 13,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 700;

    return FutureBuilder<List<KlantenficheModel>>(
      future: KlantenficheRepository.laadKlantenFiches(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final klanten = filterKlanten(snapshot.data!);
        final children = <Widget>[];

        for (final status in statusVolgorde) {
          if (widget.klantStatus != 'Alle' && widget.klantStatus != status) {
            continue;
          }

          final groep = sorteerKlanten(
            klanten.where((klant) {
              return klant.klantStatus == status;
            }).toList(),
          );

          children.add(
            statusGroep(
              titel: status,
              klanten: groep,
              isTablet: isTablet,
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.only(
            bottom: 16,
          ),
          children: children,
        );
      },
    );
  }
}

class KlantenLegeLijst extends StatelessWidget {
  const KlantenLegeLijst({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Color(0xFFE5E7EB),
          ),
        ),
        child: const Text(
          'Geen klanten gevonden.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
