// THIMACO-CONTROLE: GENEREREN-MENU-MET-LAATSTE-BESTAND-EN-FICHEMENU-20260731
// THIMACO-CONTROLE: KORTE-BESTANDSLABELS-EN-FICHEKNOP-ZONDER-RAND-20260730
// THIMACO-CONTROLE: MENU-TEKST-ZWART-NORMAAL-20260730
// THIMACO-CONTROLE: UNIFORM-BESTAND-EN-TOEVOEGMENU-20260730
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
    required this.onOpenOpmetingPreview,
    required this.onFormulierGekozen,
  });

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _zachteGroeneRand = Color(0xFFB9E1C6);
  static const Color _groeneScheiding = Color(0xFF73B98B);
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
  final Future<void> Function() onOpenOpmetingPreview;
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
        children: <Widget>[
          _bouwBestandMenu(),
          if (heeftOpenBestand && heeftOndersteundeOffertePosities) ...<Widget>[
            const SizedBox(width: 8),
            _bouwGenererenMenu(),
          ],
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
          if (heeftOpenBestand && heeftOndersteundeOffertePosities) ...<Widget>[
            if (berekenPrijzen) ...<Widget>[
              _bouwHerberekenKnop(),
              const SizedBox(width: 8),
            ],
            _bouwPrijsOverzichtKnop(),
            const SizedBox(width: 8),
          ],
          if (heeftOpenBestand)
            _bouwFormulierMenu()
          else
            const SizedBox(width: 118, height: 42),
        ],
      ),
    );
  }

  Widget _bouwBestandMenu() {
    return PopupMenuButton<String>(
      tooltip: 'Bestand',
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 14,
      shadowColor: const Color(0x33000000),
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      constraints: const BoxConstraints(minWidth: 226, maxWidth: 226),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: _rand),
      ),
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
        return <PopupMenuEntry<String>>[
          _bouwBestandMenuItem(
            waarde: 'nieuw',
            icoon: Icons.note_add_outlined,
            tekst: 'Nieuw',
          ),
          _bouwBestandMenuItem(
            waarde: 'open',
            icoon: Icons.folder_open_outlined,
            tekst: 'Openen',
          ),
          _bouwBestandMenuItem(
            waarde: 'opslaan',
            icoon: Icons.save_outlined,
            tekst: 'Opslaan',
          ),
          const PopupMenuItem<String>(
            enabled: false,
            height: 9,
            padding: EdgeInsets.symmetric(horizontal: 9),
            child: Divider(height: 1, thickness: 1, color: _groeneScheiding),
          ),
          _bouwBestandMenuItem(
            waarde: 'wissen',
            icoon: Icons.delete_outline_rounded,
            tekst: 'Wissen',
          ),
          _bouwBestandMenuItem(
            waarde: 'einde',
            icoon: Icons.home_outlined,
            tekst: 'Beëindigen',
          ),
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
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.folder_open_rounded, color: _groen, size: 20),
            SizedBox(width: 8),
            Text(
              'Bestand',
              style: TextStyle(
                color: _tekstDonker,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, color: _groen, size: 20),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _bouwBestandMenuItem({
    required String waarde,
    required IconData icoon,
    required String tekst,
  }) {
    return PopupMenuItem<String>(
      value: waarde,
      height: 42,
      padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: _zachteGroeneRand),
        ),
        child: Row(
          children: <Widget>[
            Icon(icoon, color: _groen, size: 17),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                tekst,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _tekstDonker,
                  fontSize: 12.5,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: _groen, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _bouwGenererenMenu() {
    return PopupMenuButton<String>(
      tooltip: 'Offerte of opmeting genereren',
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 14,
      shadowColor: const Color(0x33000000),
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      constraints: const BoxConstraints(minWidth: 210, maxWidth: 210),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: _rand),
      ),
      onSelected: (waarde) {
        switch (waarde) {
          case 'offerte':
            unawaited(onOpenOffertePreview());
            break;
          case 'opmeting':
            unawaited(onOpenOpmetingPreview());
            break;
        }
      },
      itemBuilder: (context) {
        return <PopupMenuEntry<String>>[
          _bouwGenererenMenuItem(
            waarde: 'offerte',
            icoon: Icons.request_quote_outlined,
            tekst: 'Offerte',
          ),
          _bouwGenererenMenuItem(
            waarde: 'opmeting',
            icoon: Icons.straighten_rounded,
            tekst: 'Opmeting',
          ),
        ];
      },
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: const Color(0xFFF15A24),
          borderRadius: BorderRadius.circular(11),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.picture_as_pdf_outlined, color: Colors.white, size: 19),
            SizedBox(width: 8),
            Text(
              'Genereren',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(width: 3),
            Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _bouwGenererenMenuItem({
    required String waarde,
    required IconData icoon,
    required String tekst,
  }) {
    return PopupMenuItem<String>(
      value: waarde,
      height: 42,
      padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: _zachteGroeneRand),
        ),
        child: Row(
          children: <Widget>[
            Icon(icoon, color: _groen, size: 17),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                tekst,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _tekstDonker,
                  fontSize: 12.5,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: _groen, size: 16),
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

  Widget _bouwFormulierMenu() {
    return PopupMenuButton<String>(
      tooltip: 'Opmeetfiche toevoegen',
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 14,
      shadowColor: const Color(0x33000000),
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      constraints: const BoxConstraints(minWidth: 250, maxWidth: 250),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: _rand),
      ),
      onSelected: (waarde) {
        final registratie = OfferteArtikelRegister.voorMenuWaarde(waarde);
        if (registratie != null) {
          unawaited(onFormulierGekozen(registratie));
        }
      },
      itemBuilder: (context) => _bouwFormulierMenuItems(),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: _lichtGroen,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: const Color(0xFFCDEBD6)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.add_rounded, color: _groen, size: 20),
            SizedBox(width: 7),
            Text(
              'Toevoegen',
              style: TextStyle(
                color: _tekstDonker,
                fontSize: 13.5,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PopupMenuEntry<String>> _bouwFormulierMenuItems() {
    final items = <PopupMenuEntry<String>>[];
    final groepen = OfferteArtikelRegister.menuGroepen;

    for (var groepIndex = 0; groepIndex < groepen.length; groepIndex++) {
      final groep = groepen[groepIndex];
      final registraties = OfferteArtikelRegister.voorMenuGroep(groep);
      if (registraties.isEmpty) {
        continue;
      }

      if (items.isNotEmpty) {
        items.add(
          const PopupMenuItem<String>(
            enabled: false,
            height: 9,
            padding: EdgeInsets.symmetric(horizontal: 9),
            child: Divider(height: 1, thickness: 1, color: _groeneScheiding),
          ),
        );
      }

      for (final registratie in registraties) {
        items.add(
          PopupMenuItem<String>(
            value: registratie.menuWaarde,
            height: 42,
            padding: const EdgeInsets.fromLTRB(6, 2, 6, 2),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                children: <Widget>[
                  Icon(registratie.icoon, color: _groen, size: 17),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      registratie.formulierNaam,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _tekstDonker,
                        fontSize: 12.5,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: _groen,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return items;
  }
}
