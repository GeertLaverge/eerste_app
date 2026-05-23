import 'package:flutter/material.dart';

import '../helpers/status_helper.dart';
import '../modellen/klant.dart';
import '../modellen/leverancier.dart';
import 'klantenfiche_pagina.dart';
import '../helpers/widgets/onder_navigatie_balk.dart';

class KlantenLijstPagina extends StatefulWidget {
  final List<Klant> klanten;
  final List<Klant> alleKlanten;
  final List<Leverancier> leveranciers;
  final List<DateTime> vakantieDagen;
  final Future<void> Function() onGewijzigd;

  const KlantenLijstPagina({
    super.key,
    required this.klanten,
    required this.alleKlanten,
    required this.leveranciers,
    required this.vakantieDagen,
    required this.onGewijzigd,
  });

  @override
  State<KlantenLijstPagina> createState() => _KlantenLijstPaginaState();
}

class _KlantenLijstPaginaState extends State<KlantenLijstPagina> {
  final TextEditingController zoekController = TextEditingController();
  String zoekterm = '';

  @override
  void dispose() {
    zoekController.dispose();
    super.dispose();
  }

  List<Klant> get gefilterdeKlanten {
    if (zoekterm.isEmpty) {
      return widget.klanten;
    }

    return widget.klanten.where((klant) {
      return klant.klantnaam.toLowerCase().contains(
            zoekterm.toLowerCase(),
          );
    }).toList();
  }

  Future<void> openKlant(Klant klant) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Klantenlijst'),
        centerTitle: true,
      ),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: zoekController,
                onChanged: (waarde) {
                  setState(() {
                    zoekterm = waarde;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Zoek klant',
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: gefilterdeKlanten.isEmpty
                    ? const Center(
                        child: Text('Geen klanten gevonden.'),
                      )
                    : ListView.builder(
                        itemCount: gefilterdeKlanten.length,
                        itemBuilder: (context, index) {
                          final klant = gefilterdeKlanten[index];
                          final status = StatusHelper.bepaalStatus(klant);
                          final kleur = StatusHelper.bepaalStatusKleur(status);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              onTap: () => openKlant(klant),
                              title: Text(
                                klant.klantnaam,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: kleur,
                                ),
                              ),
                              subtitle: Text(status),
                              trailing: const Icon(Icons.chevron_right),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
