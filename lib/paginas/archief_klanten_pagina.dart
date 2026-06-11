import 'package:flutter/material.dart';

import '../helpers/klanten/fiche/klantenfiche_model.dart';
import '../helpers/klanten/fiche/klantenfiche_repository.dart';
import 'klanten_fiche_pagina.dart';

class ArchiefKlantenPagina extends StatefulWidget {
  const ArchiefKlantenPagina({super.key});

  @override
  State<ArchiefKlantenPagina> createState() => _ArchiefKlantenPaginaState();
}

class _ArchiefKlantenPaginaState extends State<ArchiefKlantenPagina> {
  final zoekController = TextEditingController();

  String zoekterm = '';

  @override
  void dispose() {
    zoekController.dispose();
    super.dispose();
  }

  Future<void> heractiveerKlant(KlantenficheModel klant) async {
    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Klant terug actief maken?'),
          content: Text(
            'Bent u zeker dat u "${klant.naam.isEmpty ? 'Naamloos' : klant.naam}" uit het archief wilt halen en terug actief wilt maken?',
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
                'Terug actief',
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

    final nieuweFiche = KlantenficheModel(
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
      klantStatus: 'Actief',
      bestelStatus: klant.bestelStatus,
      taakVoorKlant: klant.taakVoorKlant,
      klantTakenAfgewerktOp: klant.klantTakenAfgewerktOp,
      datumAfgewerkt: '',
      archiefDatum: '',
      klantTaken: klant.klantTaken,
      artikelen: klant.artikelen,
      extraWerken: klant.extraWerken,
      fotos: klant.fotos,
      opvolgTaken: klant.opvolgTaken,
      notities: klant.notities,
      opvolgFicheVerstuurdNaarBureau: klant.opvolgFicheVerstuurdNaarBureau,
      klaarVoorNieuwePlanning: false,
      afgewerktMailVerstuurd: false,
    );

    await KlantenficheRepository.bewaarKlantenFiche(nieuweFiche);

    if (!mounted) return;

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Klant opnieuw actief gezet.'),
        backgroundColor: Color(0xFF0B7A3B),
      ),
    );
  }

  Future<void> verwijderKlant(KlantenficheModel klant) async {
    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Klant definitief verwijderen?'),
          content: Text(
            '${klant.naam}\n\nDeze actie verwijdert de klantenfiche, artikelen, taken en extra werk.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuleren'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Verwijderen',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (bevestigen != true) return;

    await KlantenficheRepository.verwijderKlantenFiche(klant.id);

    if (!mounted) return;

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Klant definitief verwijderd.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> openKlant(KlantenficheModel klant) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Archief klanten'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: zoekController,
              onChanged: (waarde) {
                setState(() {
                  zoekterm = waarde.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Zoeken...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<KlantenficheModel>>(
              future: KlantenficheRepository.laadKlantenFiches(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                }

                final klanten = snapshot.data!
                    .where((k) => k.archiefDatum.isNotEmpty)
                    .where(
                      (k) =>
                          zoekterm.isEmpty ||
                          k.naam.toLowerCase().contains(zoekterm),
                    )
                    .toList();

                if (klanten.isEmpty) {
                  return const Center(
                    child: Text('Geen gearchiveerde klanten gevonden.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: klanten.length,
                  itemBuilder: (context, index) {
                    final klant = klanten[index];

                    return Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(
                          color: Color(0xFFE5E7EB),
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          openKlant(klant);
                        },
                        title: Text(
                          klant.naam.isEmpty ? 'Naamloos' : klant.naam,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          klant.datumAfgewerkt.isEmpty
                              ? 'Geen datum'
                              : 'Afgewerkt op ${klant.datumAfgewerkt}',
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (keuze) async {
                            if (keuze == 'openen') {
                              await openKlant(klant);
                            }

                            if (keuze == 'heractiveren') {
                              await heractiveerKlant(klant);
                            }

                            if (keuze == 'verwijderen') {
                              await verwijderKlant(klant);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'openen',
                              child: Text('Openen'),
                            ),
                            PopupMenuItem(
                              value: 'heractiveren',
                              child: Text('Heractiveren'),
                            ),
                            PopupMenuItem(
                              value: 'verwijderen',
                              child: Text(
                                'Definitief verwijderen',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
