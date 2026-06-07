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
        return const Color(0xFF0B7A3B);
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
        return const Color(0xFF0B7A3B);
    }
  }

  String statusTekst(KlantenficheModel klant) {
    return klant.klantStatus;
  }

  Color kaartRandKleur(KlantenficheModel klant) {
    return const Color(0xFFE5E7EB);
  }

  Color kaartAchtergrond(KlantenficheModel klant) {
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<KlantenficheModel>>(
      future: KlantenficheRepository.laadKlantenFiches(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final klanten = snapshot.data!.where((klant) {
          final matchKlantStatus = widget.klantStatus == 'Alle'
              ? klant.klantStatus != 'Afgewerkt'
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
        }).toList()
          ..sort((a, b) {
            if (a.klaarVoorNieuwePlanning && !b.klaarVoorNieuwePlanning) {
              return -1;
            }

            if (!a.klaarVoorNieuwePlanning && b.klaarVoorNieuwePlanning) {
              return 1;
            }

            return a.naam.toLowerCase().compareTo(
                  b.naam.toLowerCase(),
                );
          });

        if (klanten.isEmpty) {
          return const KlantenLegeLijst();
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            12,
            8,
            12,
            16,
          ),
          itemCount: klanten.length,
          itemBuilder: (context, index) {
            final klant = klanten[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: kaartAchtergrond(klant),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: kaartRandKleur(klant),
                  width: klant.klaarVoorNieuwePlanning ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () async {
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
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              klant.naam.isEmpty ? 'Naamloos' : klant.naam,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  statusTekst(klant),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: kleurVoorKlantStatus(
                                      klant.klantStatus,
                                    ),
                                  ),
                                ),
                                const Text(
                                  '  •  ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                                Text(
                                  klant.bestelStatus,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: kleurVoorBestelStatus(
                                      klant.bestelStatus,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
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
                                        color: Color(0xFF0B7A3B),
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
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
            color: const Color(0xFFE5E7EB),
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
