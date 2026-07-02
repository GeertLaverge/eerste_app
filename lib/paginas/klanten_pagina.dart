import 'dart:async';

import 'package:flutter/material.dart';

import '../helpers/klanten/klanten_filter_balk.dart';
import '../helpers/klanten/klanten_lijst.dart';
import '../helpers/klanten/klanten_zoekbalk.dart';
import '../helpers/sync/sync_navigatie_helper.dart';
import 'klanten_fiche_pagina.dart';

class KlantenPagina extends StatefulWidget {
  const KlantenPagina({super.key});

  @override
  State<KlantenPagina> createState() {
    return _KlantenPaginaState();
  }
}

class _KlantenPaginaState extends State<KlantenPagina> {
  String zoekterm = '';
  String klantStatus = 'Alle';
  String bestelStatus = 'Alle';

  int _laatsteVerwerkteDownloadVersie = 0;
  int _klantenLijstVersie = 0;

  final klantStatussen = const [
    'Alle',
    'Actief',
    'Opvolgen',
    'Nadienst',
    'Afgewerkt',
  ];

  final bestelStatussen = const [
    'Alle',
    'Te bestellen',
    'Besteld',
    'Geleverd',
    'Geen artikelen',
  ];

  @override
  void initState() {
    super.initState();

    _laatsteVerwerkteDownloadVersie = SyncNavigatieHelper.downloadVersie.value;

    SyncNavigatieHelper.downloadVersie.addListener(_verwerkAchtergrondDownload);
  }

  @override
  void dispose() {
    SyncNavigatieHelper.downloadVersie.removeListener(
      _verwerkAchtergrondDownload,
    );

    super.dispose();
  }

  void _verwerkAchtergrondDownload() {
    final nieuweVersie = SyncNavigatieHelper.downloadVersie.value;

    if (nieuweVersie <= _laatsteVerwerkteDownloadVersie) {
      return;
    }

    _laatsteVerwerkteDownloadVersie = nieuweVersie;

    _herlaadKlantenLijst();
  }

  void _herlaadKlantenLijst() {
    if (!mounted) {
      return;
    }

    setState(() {
      /*
       * Door de versie te verhogen krijgt de KeyedSubtree
       * een nieuwe key. KlantenLijst wordt daardoor volledig
       * opnieuw opgebouwd en leest de lokale gegevens opnieuw.
       */
      _klantenLijstVersie++;
    });
  }

  Future<void> openNieuweKlantenfiche() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const KlantenFichePagina()),
    );

    if (!mounted) {
      return;
    }

    _herlaadKlantenLijst();
  }

  void openNieuwMenu() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            width: 260,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _popupKeuze(
                  icoon: Icons.person_add_alt_1_outlined,
                  tekst: 'Nieuwe klantenfiche',
                  onTap: () {
                    Navigator.pop(dialogContext);

                    unawaited(openNieuweKlantenfiche());
                  },
                ),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                _popupKeuze(
                  icoon: Icons.build_circle_outlined,
                  tekst: 'Nadienst',
                  onTap: () {
                    Navigator.pop(dialogContext);

                    unawaited(_openNieuweNadienst());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openNieuweNadienst() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const KlantenFichePagina(startStatus: 'Nadienst'),
      ),
    );

    if (!mounted) {
      return;
    }

    _herlaadKlantenLijst();
  }

  Widget bovenBalk() {
    return Container(
      height: 58,
      color: const Color(0xFF0B7A3B),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              /*
               * Niet meer wachten op de download.
               * Home wordt onmiddellijk geopend.
               */
              unawaited(
                SyncNavigatieHelper.terugNaarHomeMetDownload(context: context),
              );
            },
          ),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  /*
                   * Dit blijft een bewuste, handmatige upload.
                   * Alleen deze actie wacht op het resultaat.
                   */
                  await SyncNavigatieHelper.uploadVanafPagina(context: context);
                },
                child: const Text(
                  'Klanten',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
            onPressed: openNieuwMenu,
          ),
        ],
      ),
    );
  }

  Widget vasteKolomBalk() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0B7A3B),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: const Row(
        children: [
          Expanded(
            flex: 6,
            child: Text(
              'Naam klant',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Center(
              child: Text(
                'Status artikelen',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          SizedBox(width: 48),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            bovenBalk(),
            KlantenZoekbalk(
              onChanged: (waarde) {
                setState(() {
                  zoekterm = waarde;
                });
              },
            ),
            KlantenFilterBalk(
              opties: klantStatussen,
              geselecteerd: klantStatus,
              onGekozen: (waarde) {
                setState(() {
                  klantStatus = waarde;
                });
              },
            ),
            const SizedBox(height: 8),
            KlantenFilterBalk(
              opties: bestelStatussen,
              geselecteerd: bestelStatus,
              onGekozen: (waarde) {
                setState(() {
                  bestelStatus = waarde;
                });
              },
            ),
            const SizedBox(height: 14),
            vasteKolomBalk(),
            Expanded(
              child: KeyedSubtree(
                key: ValueKey<int>(_klantenLijstVersie),
                child: KlantenLijst(
                  klantStatus: klantStatus,
                  bestelStatus: bestelStatus,
                  zoekterm: zoekterm,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _popupKeuze({
  required IconData icoon,
  required String tekst,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    hoverColor: Colors.transparent,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icoon, size: 22, color: const Color(0xFF0B7A3B)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tekst,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
