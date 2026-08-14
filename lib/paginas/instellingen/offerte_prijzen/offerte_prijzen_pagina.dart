// THIMACO-CONTROLE: PRIJSARCHITECTUUR-OPRUIMEN-STAP1-LEGACY-UI-20260814
// THIMACO-CONTROLE: BUITENJALOEZIE-DEFINITIEF-OFFERTEPRIJZEN-20260803
// THIMACO-CONTROLE: BUITENJALOEZIE-KOPPELING-OFFERTEPRIJZEN-20260803
// THIMACO-CONTROLE: ALGEMENE-OPMETING-ALLEEN-VRIJE-PRIJZEN-20260801
// THIMACO-CONTROLE: VOORZETSCREEN-INBOUWSCHAKELAAR-ZICHTBAAR-IN-OFFERTEPRIJZEN-20260730-2205
// THIMACO-CONTROLE: VELUX-ZICHTBAAR-BIJ-TECHNISCHE-PRIJSKEUZES-20260730
// THIMACO-CONTROLE: VELUX-OFFERTEPRIJZEN-VRIJE-PRIJZEN-FASE-4-20260729-2257
// THIMACO-CONTROLE: VRIJE-PRIJZEN-TEGEL-ALTIJD-ZICHTBAAR-20260729-1415
// THIMACO-CONTROLE: OFFERTEPRIJZEN-VRIJE-PRIJS-EN-SEKTIONALE-POORTEN-20260729-1313
// THIMACO-CONTROLE: SCHUIFVLIEGENDEUR-INSTELLINGEN-EN-PRIJZEN-20260728
// THIMACO-CONTROLE: PROJECTPRIJS-VERDEELKOST-MEERDERE-FICHES-20260726
import 'package:flutter/material.dart';

import 'offerte_prijzen_fiche_pagina.dart';
import 'offerte_prijs_per_artikel_pagina.dart';

class OffertePrijzenPagina extends StatefulWidget {
  const OffertePrijzenPagina({super.key});

  @override
  State<OffertePrijzenPagina> createState() {
    return _OffertePrijzenPaginaState();
  }
}

class _OffertePrijzenPaginaState extends State<OffertePrijzenPagina> {
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
          formulierType: 'schuifvliegendeur',
          naam: 'Schuifvliegendeur',
          icoon: Icons.view_week_outlined,
          actief: true,
        ),
        _OffertePrijsFicheKeuze(
          formulierType: 'plooiwerken',
          naam: 'Plooiwerken',
          icoon: Icons.polyline_outlined,
          actief: true,
        ),
        _OffertePrijsFicheKeuze(
          formulierType: 'voorzetscreen',
          naam: 'Voorzetscreen',
          icoon: Icons.blinds_outlined,
          actief: true,
          toonBijTechnischeKeuzes: true,
        ),
        _OffertePrijsFicheKeuze(
          formulierType: 'buitenjaloezie',
          naam: 'Buitenjaloezie',
          icoon: Icons.blinds_rounded,
          actief: true,
          toonBijTechnischeKeuzes: true,
        ),
        _OffertePrijsFicheKeuze(
          formulierType: 'sektionalePoort',
          naam: 'Sektionale poorten',
          icoon: Icons.garage_outlined,
          actief: true,
        ),
        _OffertePrijsFicheKeuze(
          formulierType: 'veluxDakraam',
          naam: 'Velux dakramen',
          icoon: Icons.roofing_outlined,
          actief: true,
          toonBijTechnischeKeuzes: true,
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
          formulierType: 'algemeneOpmeting',
          naam: 'Algemene opmeting',
          icoon: Icons.description_outlined,
          actief: true,
          toonBijTechnischeKeuzes: false,
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
                  'Beheer hier de nieuwe bibliotheek Prijs per artikel en de '
                  'bestaande prijzen volgens technische keuze. Prijs per artikel '
                  'wordt bij gebruik als zelfstandige A/V-regel naar de gekozen '
                  'offertepositie gekopieerd. De oude vrije- en projectprijsbediening '
                  'is verwijderd.',
                  style: TextStyle(
                    color: _tekstGrijs,
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // THIMACO-CONTROLE: PRIJS-PER-ARTIKEL-BIBLIOTHEEK-INGANG-20260813
              _bouwPrijsPerArtikelBibliotheekTegel(),
              const SizedBox(height: 12),
              const SizedBox(height: 18),
              const _SectieTitel(
                titel: 'Prijs volgens technische keuze',
                subtitel:
                    'Open een artikeltype en stel prijzen in bij de technische keuzes.',
              ),
              const SizedBox(height: 10),
              ..._fiches.where((fiche) => fiche.toonBijTechnischeKeuzes).map((
                fiche,
              ) {
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

  Widget _bouwPrijsPerArtikelBibliotheekTegel() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _openPrijsPerArtikelBibliotheek,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _groen, width: 1.1),
          ),
          child: const Row(
            children: <Widget>[
              _PrijsPerArtikelIcoon(),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Prijs per artikel',
                      style: TextStyle(
                        color: _tekstDonker,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Beheer herbruikbare A/V-prijsregels. Bij gebruik wordt '
                      'een onafhankelijke kopie in de offertepositie gemaakt.',
                      style: TextStyle(
                        color: _tekstGrijs,
                        fontSize: 12.2,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.chevron_right_rounded, color: _groen),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openPrijsPerArtikelBibliotheek() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const OffertePrijsPerArtikelPagina(),
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

class _PrijsPerArtikelIcoon extends StatelessWidget {
  const _PrijsPerArtikelIcoon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: _OffertePrijzenPaginaState._lichtGroen,
        borderRadius: BorderRadius.circular(11),
      ),
      child: const Icon(
        Icons.library_add_check_outlined,
        color: _OffertePrijzenPaginaState._groen,
      ),
    );
  }
}

class _SectieTitel extends StatelessWidget {
  const _SectieTitel({required this.titel, required this.subtitel});

  final String titel;
  final String subtitel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            titel,
            style: const TextStyle(
              color: _OffertePrijzenPaginaState._tekstDonker,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitel,
            style: const TextStyle(
              color: _OffertePrijzenPaginaState._tekstGrijs,
              fontSize: 11.8,
              height: 1.3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
    this.toonBijTechnischeKeuzes = true,
  });

  final String formulierType;
  final String naam;
  final IconData icoon;
  final bool actief;
  final bool toonBijTechnischeKeuzes;
}
