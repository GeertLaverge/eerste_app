import 'package:flutter/material.dart';

import '../helpers/klanten/klanten_zoekbalk.dart';
import '../helpers/klanten/klanten_filter_balk.dart';
import '../helpers/klanten/klanten_lijst.dart';
import '../helpers/sync/sync_navigatie_helper.dart';
import 'klanten_fiche_pagina.dart';

class KlantenPagina extends StatefulWidget {
  const KlantenPagina({super.key});

  @override
  State<KlantenPagina> createState() => _KlantenPaginaState();
}

class _KlantenPaginaState extends State<KlantenPagina> {
  String zoekterm = '';
  String klantStatus = 'Alle';
  String bestelStatus = 'Alle';

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

  void openNieuweKlantenfiche() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const KlantenFichePagina()),
    ).then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  void openNieuwMenu() {
    showDialog(
      context: context,
      builder: (context) {
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
                  context,
                  icoon: Icons.person_add_alt_1_outlined,
                  tekst: 'Nieuwe klantenfiche',
                  onTap: () {
                    Navigator.pop(context);
                    openNieuweKlantenfiche();
                  },
                ),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                _popupKeuze(
                  context,
                  icoon: Icons.build_circle_outlined,
                  tekst: 'Nadienst',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const KlantenFichePagina(startStatus: 'Nadienst'),
                      ),
                    ).then((_) {
                      if (!mounted) return;
                      setState(() {});
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
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
            onPressed: () async {
              await SyncNavigatieHelper.terugNaarHomeMetDownload(
                context: context,
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.cloud_download_outlined,
              color: Colors.white,
            ),
            onPressed: () async {
              await SyncNavigatieHelper.downloadVanafPagina(context: context);
              if (!mounted) return;
              setState(() {});
            },
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Klanten',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white),
            onPressed: () async {
              await SyncNavigatieHelper.uploadVanafPagina(context: context);
            },
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
              child: KlantenLijst(
                klantStatus: klantStatus,
                bestelStatus: bestelStatus,
                zoekterm: zoekterm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _popupKeuze(
  BuildContext context, {
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
