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
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<KlantenficheModel>>(
      future: KlantenficheRepository.laadKlantenFiches(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final klanten = snapshot.data!.where((klant) {
          final matchKlantStatus = widget.klantStatus == 'Alle' ||
              klant.klantStatus == widget.klantStatus;

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

        if (klanten.isEmpty) {
          return const KlantenLegeLijst();
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          itemCount: klanten.length,
          itemBuilder: (context, index) {
            final klant = klanten[index];

            return InkWell(
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
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
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
                    Text(
                      '${klant.klantStatus} · ${klant.bestelStatus}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
