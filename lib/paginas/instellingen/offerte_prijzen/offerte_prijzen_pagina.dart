import 'package:flutter/material.dart';

import 'offerte_prijzen_fiche_pagina.dart';

class OffertePrijzenPagina extends StatelessWidget {
  const OffertePrijzenPagina({super.key});

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _achtergrond = Color(0xFFF7F8FA);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  static const List<_OffertePrijsFicheKeuze> _fiches =
      <_OffertePrijsFicheKeuze>[
        _OffertePrijsFicheKeuze(
          formulierType: 'vasteInzethor',
          naam: 'Vaste inzethor',
          icoon: Icons.grid_on,
          actief: true,
        ),
        _OffertePrijsFicheKeuze(
          formulierType: 'vliegendeur',
          naam: 'Vliegendeur',
          icoon: Icons.door_front_door_outlined,
          actief: true,
        ),
        _OffertePrijsFicheKeuze(
          formulierType: 'pvcRaam',
          naam: 'PVC raam',
          icoon: Icons.window_outlined,
          actief: true,
        ),
        _OffertePrijsFicheKeuze(
          formulierType: 'aluRaam',
          naam: 'ALU raam',
          icoon: Icons.window_outlined,
          actief: true,
        ),
        _OffertePrijsFicheKeuze(
          formulierType: 'pvcDeur',
          naam: 'PVC deur',
          icoon: Icons.door_front_door_outlined,
          actief: true,
        ),
        _OffertePrijsFicheKeuze(
          formulierType: 'aluDeur',
          naam: 'ALU deur',
          icoon: Icons.door_front_door_outlined,
          actief: true,
        ),
        _OffertePrijsFicheKeuze(
          formulierType: 'pvcSchuifraam',
          naam: 'PVC schuifraam',
          icoon: Icons.view_week_outlined,
          actief: true,
        ),
        _OffertePrijsFicheKeuze(
          formulierType: 'aluSchuifraam',
          naam: 'ALU schuifraam',
          icoon: Icons.view_week_outlined,
          actief: true,
        ),
        _OffertePrijsFicheKeuze(
          formulierType: 'zonwering',
          naam: 'Zonwering',
          icoon: Icons.wb_sunny_outlined,
        ),
      ];

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
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
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
                  'Beheer hier de offerteprijzen per soort opmeetfiche. '
                  'Vaste inzethor, Vliegendeur, PVC en ALU raam, PVC en ALU '
                  'schuifraam en PVC en ALU deur zijn actief. Iedere fiche '
                  'heeft een eigen prijsprofiel. Technische-keuzeprijzen zijn '
                  'niet van toepassing op Vaste inzethor en Vliegendeur. '
                  'U kunt prijsregels toevoegen, wijzigen, ordenen en tijdelijk '
                  'uitschakelen. Zonwering wordt later gekoppeld.',
                  style: TextStyle(
                    color: _tekstGrijs,
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ..._fiches.map((fiche) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _bouwFicheTegel(context, fiche),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bouwFicheTegel(BuildContext context, _OffertePrijsFicheKeuze fiche) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: fiche.actief
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) {
                      return OffertePrijzenFichePagina(
                        formulierType: fiche.formulierType,
                        formulierNaam: fiche.naam,
                      );
                    },
                  ),
                );
              }
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _rand),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: fiche.actief ? _lichtGroen : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  fiche.icoon,
                  color: fiche.actief ? _groen : const Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  fiche.naam,
                  style: TextStyle(
                    color: fiche.actief ? _tekstDonker : _tekstGrijs,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (fiche.actief)
                const Icon(Icons.chevron_right_rounded, color: _groen)
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Wordt later gekoppeld',
                    style: TextStyle(
                      color: _tekstGrijs,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OffertePrijsFicheKeuze {
  const _OffertePrijsFicheKeuze({
    required this.formulierType,
    required this.naam,
    required this.icoon,
    this.actief = false,
  });

  final String formulierType;
  final String naam;
  final IconData icoon;
  final bool actief;
}
