// THIMACO-CONTROLE: PRIJS-VERDEELD-OVER-ACTIEF-IN-HOOFDPAGINA-20260815
// THIMACO-CONTROLE: OFFERTEPRIJZEN-HOOFDPAGINA-UNUSED-FIELDS-FIX-20260815
// THIMACO-CONTROLE: OFFERTEPRIJZEN-VIER-EENVOUDIGE-SYSTEMEN-FASE1-20260815
import 'package:flutter/material.dart';

import 'offerte_prijs_per_artikel_pagina.dart';
import 'offerte_prijs_technische_keuzes_pagina.dart';
import 'offerte_prijs_voor_alle_posities_pagina.dart';
import 'offerte_prijs_verdeeld_over_pagina.dart';

class OffertePrijzenPagina extends StatelessWidget {
  const OffertePrijzenPagina({super.key});

  static const Color _achtergrond = Color(0xFFF7F8FA);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _achtergrond,
      appBar: AppBar(
        title: const Text(
          'Offerteprijzen',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        foregroundColor: _tekstDonker,
        elevation: 0,
      ),
      body: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _rand),
                ),
                child: const Text(
                  'De offerteprijzen worden opgebouwd uit vier eenvoudige '
                  'systemen. De eerste drie zijn de dagelijkse prijsbibliotheken. '
                  'De vierde verdeelt bijvoorbeeld transport- '
                  'of leverancierskosten over gekozen soorten opmeetfiches.',
                  style: TextStyle(
                    color: _tekstGrijs,
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _PrijsTegel(
                titel: 'Prijs per positie',
                uitleg:
                    'Herbruikbare regels die u op één afzonderlijke positie invult.',
                icoon: Icons.format_list_bulleted_rounded,
                onTap: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => const OffertePrijsPerArtikelPagina(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _PrijsTegel(
                titel: 'Prijs voor alle posities',
                uitleg:
                    'Dezelfde eenvoudige A/V-regels, toepasbaar op één, meerdere of alle posities.',
                icoon: Icons.playlist_add_check_circle_outlined,
                onTap: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const OffertePrijsVoorAllePositiesPagina(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _PrijsTegel(
                titel: 'Prijs bij technische keuzes',
                uitleg:
                    'Alle aangemaakte technische keuzes één keer. Eén centrale prijs, ongeacht de opmeetfiche.',
                icoon: Icons.tune_rounded,
                onTap: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const OffertePrijsTechnischeKeuzesPagina(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _PrijsTegel(
                titel: 'Prijzen verdeeld over…',
                uitleg:
                    'Transport- en leverancierskosten als één bedrag verdelen over gekozen opmeetfiches.',
                icoon: Icons.call_split_rounded,
                onTap: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => const OffertePrijsVerdeeldOverPagina(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrijsTegel extends StatelessWidget {
  const _PrijsTegel({
    required this.titel,
    required this.uitleg,
    required this.icoon,
    this.onTap,
  });

  final String titel;
  final String uitleg;
  final IconData icoon;
  final VoidCallback? onTap;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _groen, width: 1.1),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _lichtGroen,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icoon, color: _groen, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            titel,
                            style: const TextStyle(
                              color: _tekstDonker,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      uitleg,
                      style: const TextStyle(
                        color: _tekstGrijs,
                        fontSize: 11.5,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: _groen),
            ],
          ),
        ),
      ),
    );
  }
}
