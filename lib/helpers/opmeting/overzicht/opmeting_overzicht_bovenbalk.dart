import 'dart:async';

import 'package:flutter/material.dart';

import '../../offerte/artikelen/offerte_artikel_register.dart';

class OpmetingOverzichtBovenbalk extends StatelessWidget {
  const OpmetingOverzichtBovenbalk({
    super.key,
    required this.titel,
    required this.heeftOpenBestand,
    required this.heeftOndersteundeOffertePosities,
    required this.berekenPrijzen,
    required this.prijsHerberekeningBezig,
    required this.onNieuwBestand,
    required this.onOpenBestand,
    required this.onOpslaanBestand,
    required this.onWisBestand,
    required this.onEindeOpmeting,
    required this.onHerberekenOfferte,
    required this.onOpenPrijsOverzicht,
    required this.onOpenOffertePreview,
    required this.onFormulierGekozen,
  });

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);

  final String titel;
  final bool heeftOpenBestand;
  final bool heeftOndersteundeOffertePosities;
  final bool berekenPrijzen;
  final bool prijsHerberekeningBezig;

  final Future<void> Function() onNieuwBestand;
  final Future<void> Function() onOpenBestand;
  final Future<void> Function() onOpslaanBestand;
  final Future<void> Function() onWisBestand;
  final Future<void> Function() onEindeOpmeting;
  final Future<void> Function() onHerberekenOfferte;
  final Future<void> Function() onOpenPrijsOverzicht;
  final Future<void> Function() onOpenOffertePreview;
  final Future<void> Function(OfferteArtikelRegistratie registratie)
  onFormulierGekozen;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _rand)),
      ),
      child: Row(
        children: [
          _bouwBestandMenu(),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              titel,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _tekstDonker,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (heeftOpenBestand && heeftOndersteundeOffertePosities) ...[
            if (berekenPrijzen) ...<Widget>[
              _bouwHerberekenKnop(),
              const SizedBox(width: 8),
            ],
            _bouwPrijsOverzichtKnop(),
            const SizedBox(width: 8),
            _bouwOfferteKnop(),
            const SizedBox(width: 10),
          ],
          if (heeftOpenBestand)
            _bouwFormulierMenu()
          else
            const SizedBox(width: 42, height: 42),
        ],
      ),
    );
  }

  Widget _bouwBestandMenu() {
    return PopupMenuButton<String>(
      tooltip: 'Bestand',
      onSelected: (waarde) {
        switch (waarde) {
          case 'nieuw':
            unawaited(onNieuwBestand());
            break;
          case 'open':
            unawaited(onOpenBestand());
            break;
          case 'opslaan':
            unawaited(onOpslaanBestand());
            break;
          case 'wissen':
            unawaited(onWisBestand());
            break;
          case 'einde':
            unawaited(onEindeOpmeting());
            break;
        }
      },
      itemBuilder: (context) {
        return const [
          PopupMenuItem(value: 'nieuw', child: Text('Nieuw bestand')),
          PopupMenuItem(value: 'open', child: Text('Open bestand')),
          PopupMenuItem(value: 'opslaan', child: Text('Opslaan bestand')),
          PopupMenuItem(
            value: 'wissen',
            child: Text(
              'Bestand wissen',
              style: TextStyle(color: Color(0xFFDC2626)),
            ),
          ),
          PopupMenuDivider(),
          PopupMenuItem(value: 'einde', child: Text('Einde')),
        ];
      },
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: _lichtGroen,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: const Color(0xFFCDEBD6)),
        ),
        child: const Row(
          children: [
            Icon(Icons.folder_open_rounded, color: _groen, size: 20),
            SizedBox(width: 8),
            Text(
              'Bestand',
              style: TextStyle(
                color: _groen,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, color: _groen, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _bouwHerberekenKnop() {
    return Tooltip(
      message: 'Offerte herberekenen met huidige prijsinstellingen',
      child: IconButton.filledTonal(
        onPressed: prijsHerberekeningBezig
            ? null
            : () => unawaited(onHerberekenOfferte()),
        icon: prijsHerberekeningBezig
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: _groen,
                ),
              )
            : const Icon(Icons.refresh_rounded),
        style: IconButton.styleFrom(
          foregroundColor: _groen,
          backgroundColor: _lichtGroen,
        ),
      ),
    );
  }

  Widget _bouwPrijsOverzichtKnop() {
    return OutlinedButton.icon(
      onPressed: () => unawaited(onOpenPrijsOverzicht()),
      icon: const Icon(Icons.assessment_outlined, size: 18),
      label: const Text('Overzicht'),
      style: OutlinedButton.styleFrom(
        foregroundColor: _groen,
        backgroundColor: _lichtGroen,
        side: const BorderSide(color: Color(0xFFCDEBD6)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
    );
  }

  Widget _bouwOfferteKnop() {
    return ElevatedButton.icon(
      onPressed: () => unawaited(onOpenOffertePreview()),
      icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
      label: const Text('Offerte'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF15A24),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
    );
  }

  Widget _bouwFormulierMenu() {
    return PopupMenuButton<String>(
      tooltip: 'Formulier toevoegen',
      onSelected: (waarde) {
        final registratie = OfferteArtikelRegister.voorMenuWaarde(waarde);
        if (registratie != null) {
          unawaited(onFormulierGekozen(registratie));
        }
      },
      itemBuilder: (context) => _bouwFormulierMenuItems(),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: _groen,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  List<PopupMenuEntry<String>> _bouwFormulierMenuItems() {
    final items = <PopupMenuEntry<String>>[];

    for (
      var categorieIndex = 0;
      categorieIndex < OfferteArtikelCategorie.values.length;
      categorieIndex++
    ) {
      final categorie = OfferteArtikelCategorie.values[categorieIndex];
      final registraties = OfferteArtikelRegister.voorCategorie(categorie);
      if (registraties.isEmpty) continue;

      items.add(
        PopupMenuItem<String>(
          enabled: false,
          child: Padding(
            padding: EdgeInsets.only(top: categorieIndex == 0 ? 0 : 8),
            child: Text(
              categorie.label,
              style: const TextStyle(
                color: _groen,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      );

      for (final registratie in registraties) {
        items.add(
          PopupMenuItem<String>(
            value: registratie.menuWaarde,
            child: Row(
              children: [
                Icon(registratie.icoon, color: _groen, size: 20),
                const SizedBox(width: 10),
                Text(registratie.formulierNaam),
              ],
            ),
          ),
        );
      }
    }

    return items;
  }
}
