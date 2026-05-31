import 'package:flutter/material.dart';

import '../helpers/klanten/klanten_boven_balk.dart';
import '../helpers/klanten/klanten_zoekbalk.dart';
import '../helpers/klanten/klanten_filter_balk.dart';
import '../helpers/klanten/klanten_lijst.dart';
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
    'Geen artikels',
  ];

  void openNieuweKlantenfiche() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const KlantenFichePagina(),
      ),
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
            padding: const EdgeInsets.symmetric(
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
              ),
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
                const Divider(
                  height: 1,
                  color: Color(0xFFE5E7EB),
                ),
                _popupKeuze(
                  context,
                  icoon: Icons.build_circle_outlined,
                  tekst: 'Nadienst',
                  onTap: () {
                    Navigator.pop(context);
                    // Later: nadienst openen
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            KlantenBovenBalk(
              onTerug: () => Navigator.pop(context),
              onNieuw: openNieuwMenu,
            ),
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
            KlantenFilterBalk(
              opties: bestelStatussen,
              geselecteerd: bestelStatus,
              onGekozen: (waarde) {
                setState(() {
                  bestelStatus = waarde;
                });
              },
            ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      child: Row(
        children: [
          Icon(
            icoon,
            size: 22,
            color: const Color(0xFF0B7A3B),
          ),
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
