// THIMACO-CONTROLE: PROGRAMMABALK-ICOONLOGO-PROJECT-GATING-FASE7C-20260913
// THIMACO-CONTROLE: PROGRAMMABALK-ORANJE-TABS-ZWEVENDE-PANELEN-FASE7-20260913
// THIMACO-CONTROLE: CENTRAAL-BESTANDMENU-RUSTIGE-BOVENBALK-FASE3-20260912
// THIMACO-CONTROLE: BESTANDMENU-OPSLAAN-ALS-FASE2-20260912
// THIMACO-CONTROLE: GENEREREN-KNOP-DEFINITIEF-20260803
// THIMACO-CONTROLE: GENEREREN-MENU-MET-LAATSTE-BESTAND-EN-FICHEMENU-20260731
// THIMACO-CONTROLE: KORTE-BESTANDSLABELS-EN-FICHEKNOP-ZONDER-RAND-20260730
// THIMACO-CONTROLE: MENU-TEKST-ZWART-NORMAAL-20260730
// THIMACO-CONTROLE: UNIFORM-BESTAND-EN-TOEVOEGMENU-20260730
import 'dart:async';

import 'package:flutter/material.dart';

import '../../offerte/artikelen/offerte_artikel_register.dart';
import '../project/opmeting_project_titelhoofd_kaart.dart' show OpmetingProjectPaneel;

class OpmetingOverzichtBovenbalk extends StatelessWidget {
  const OpmetingOverzichtBovenbalk({
    super.key,
    required this.titel,
    required this.heeftOpenBestand,
    required this.heeftOndersteundeOffertePosities,
    required this.berekenPrijzen,
    required this.prijsHerberekeningBezig,
    required this.onNieuwProject,
    required this.onOpenProject,
    required this.onNieuweVariant,
    required this.onOpenHuidigProjectBestand,
    required this.onOpslaanBestand,
    required this.onOpslaanAlsBestand,
    required this.onWisBestand,
    required this.onEindeOpmeting,
    required this.onHerberekenOfferte,
    required this.onOpenPrijsOverzicht,
    required this.onOpenOffertePreview,
    required this.onOpenOpmetingPreview,
    required this.onFormulierGekozen,
    required this.actiefPaneel,
    required this.onPaneelGekozen,
  });

  static const Color _accent = Color(0xFFF15A24);
  static const Color _accentScheiding = Color(0xFFF7B08A);
  static const Color _rand = Color(0xFFE2E5E8);
  static const Color _tekstDonker = Color(0xFF22272D);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  final String titel;
  final bool heeftOpenBestand;
  final bool heeftOndersteundeOffertePosities;
  final bool berekenPrijzen;
  final bool prijsHerberekeningBezig;

  final Future<void> Function() onNieuwProject;
  final Future<void> Function() onOpenProject;
  final Future<void> Function() onNieuweVariant;
  final Future<void> Function() onOpenHuidigProjectBestand;
  final Future<void> Function() onOpslaanBestand;
  final Future<void> Function() onOpslaanAlsBestand;
  final Future<void> Function() onWisBestand;
  final Future<void> Function() onEindeOpmeting;
  final Future<void> Function() onHerberekenOfferte;
  final Future<void> Function() onOpenPrijsOverzicht;
  final Future<void> Function() onOpenOffertePreview;
  final Future<void> Function() onOpenOpmetingPreview;
  final Future<void> Function(OfferteArtikelRegistratie registratie)
  onFormulierGekozen;
  final OpmetingProjectPaneel? actiefPaneel;
  final ValueChanged<OpmetingProjectPaneel> onPaneelGekozen;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _rand)),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 42,
            height: 38,
            child: Image.asset(
              'assets/offerte/thimaco_logo_icoon.png',
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.window_rounded,
                  color: _tekstDonker,
                  size: 28,
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          const SizedBox(
            height: 28,
            child: VerticalDivider(width: 1, thickness: 1, color: _rand),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: Row(
                children: <Widget>[
                  _bouwBestandMenu(),
                  const SizedBox(width: 4),
                  _bouwPaneelTab(
                    paneel: OpmetingProjectPaneel.klantgegevens,
                    tekst: 'Klantgegevens',
                  ),
                  _bouwPaneelTab(
                    paneel: OpmetingProjectPaneel.projectkleur,
                    tekst: 'Projectkleur',
                  ),
                  _bouwPaneelTab(
                    paneel: OpmetingProjectPaneel.inhoudFiche,
                    tekst: 'Inhoud fiche',
                  ),
                  _bouwPaneelTab(
                    paneel: OpmetingProjectPaneel.offerteInstellingen,
                    tekst: 'Offerte-instellingen',
                  ),
                  _bouwFormulierMenu(),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (heeftOpenBestand &&
              heeftOndersteundeOffertePosities &&
              berekenPrijzen) ...<Widget>[
            _bouwHerberekenKnop(),
            const SizedBox(width: 6),
          ],
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 250),
            child: Text(
              titel,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _tekstDonker,
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwPaneelTab({
    required OpmetingProjectPaneel paneel,
    required String tekst,
  }) {
    final actief = actiefPaneel == paneel;
    final enabled = heeftOpenBestand;

    return Opacity(
      opacity: enabled ? 1 : 0.42,
      child: InkWell(
        onTap: enabled ? () => onPaneelGekozen(paneel) : null,
        borderRadius: BorderRadius.circular(7),
        child: Container(
          height: 46,
          padding: const EdgeInsets.fromLTRB(11, 3, 11, 0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: actief ? _accent : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            tekst,
            style: TextStyle(
              color: _tekstDonker,
              fontSize: 13.2,
              fontWeight: actief ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _bouwDropdownTab({
    required String tekst,
    required IconData icoon,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.42,
      child: SizedBox(
        height: 46,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icoon, color: enabled ? _tekstDonker : _tekstGrijs, size: 17),
              const SizedBox(width: 5),
              Text(
                tekst,
                style: const TextStyle(
                  color: _tekstDonker,
                  fontSize: 13.2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _tekstGrijs,
                size: 17,
              ),
            ],
          ),
        ),
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
      constraints: const BoxConstraints(minWidth: 268, maxWidth: 268),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: _rand),
      ),
      onSelected: (waarde) {
        switch (waarde) {
          case 'project_nieuw':
            unawaited(onNieuwProject());
            break;
          case 'project_openen':
            unawaited(onOpenProject());
            break;
          case 'variant_nieuw':
            unawaited(onNieuweVariant());
            break;
          case 'huidig_openen':
            unawaited(onOpenHuidigProjectBestand());
            break;
          case 'opslaan':
            unawaited(onOpslaanBestand());
            break;
          case 'opslaan_als':
            unawaited(onOpslaanAlsBestand());
            break;
          case 'pdf':
            unawaited(onOpenOffertePreview());
            break;
          case 'opmeting':
            unawaited(onOpenOpmetingPreview());
            break;
          case 'overzicht':
            unawaited(onOpenPrijsOverzicht());
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
        final kanGenereren =
            heeftOpenBestand && heeftOndersteundeOffertePosities;
        return <PopupMenuEntry<String>>[
          _bouwMenuSectieTitel('Nieuw project'),
          _bouwBestandMenuItem(
            waarde: 'project_nieuw',
            icoon: Icons.note_add_outlined,
            tekst: 'Nieuw',
          ),
          _bouwBestandMenuItem(
            waarde: 'project_openen',
            icoon: Icons.folder_open_outlined,
            tekst: 'Openen',
          ),
          _bouwMenuScheiding(),
          _bouwMenuSectieTitel('Huidig project'),
          _bouwBestandMenuItem(
            waarde: 'variant_nieuw',
            icoon: Icons.post_add_outlined,
            tekst: 'Nieuwe variant',
            enabled: heeftOpenBestand,
          ),
          _bouwBestandMenuItem(
            waarde: 'huidig_openen',
            icoon: Icons.folder_copy_outlined,
            tekst: 'Openen',
            enabled: heeftOpenBestand,
          ),
          _bouwBestandMenuItem(
            waarde: 'opslaan',
            icoon: Icons.save_outlined,
            tekst: 'Opslaan',
            enabled: heeftOpenBestand,
          ),
          _bouwBestandMenuItem(
            waarde: 'opslaan_als',
            icoon: Icons.save_as_outlined,
            tekst: 'Opslaan als...',
            enabled: heeftOpenBestand,
          ),
          _bouwMenuScheiding(),
          _bouwMenuSectieTitel('Genereren'),
          _bouwBestandMenuItem(
            waarde: 'pdf',
            icoon: Icons.picture_as_pdf_outlined,
            tekst: 'PDF genereren',
            enabled: kanGenereren,
          ),
          _bouwBestandMenuItem(
            waarde: 'opmeting',
            icoon: Icons.straighten_rounded,
            tekst: 'Opmeetfiche',
            enabled: kanGenereren,
          ),
          _bouwMenuScheiding(),
          _bouwMenuSectieTitel('Algemeen'),
          _bouwBestandMenuItem(
            waarde: 'overzicht',
            icoon: Icons.assessment_outlined,
            tekst: 'Overzicht',
            enabled: kanGenereren,
          ),
          _bouwBestandMenuItem(
            waarde: 'wissen',
            icoon: Icons.delete_outline_rounded,
            tekst: 'Wissen',
            enabled: heeftOpenBestand,
            destructief: true,
          ),
          _bouwBestandMenuItem(
            waarde: 'einde',
            icoon: Icons.home_outlined,
            tekst: 'Afsluiten',
          ),
        ];
      },
      child: _bouwDropdownTab(tekst: 'Bestand', icoon: Icons.folder_open_outlined),
    );
  }

  PopupMenuItem<String> _bouwMenuSectieTitel(String tekst) {
    return PopupMenuItem<String>(
      enabled: false,
      height: 25,
      padding: const EdgeInsets.fromLTRB(13, 7, 13, 2),
      child: Text(
        tekst,
        style: const TextStyle(
          color: _tekstGrijs,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  PopupMenuItem<String> _bouwMenuScheiding() {
    return const PopupMenuItem<String>(
      enabled: false,
      height: 7,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Divider(height: 1, thickness: 1, color: _accentScheiding),
    );
  }

  PopupMenuItem<String> _bouwBestandMenuItem({
    required String waarde,
    required IconData icoon,
    required String tekst,
    bool enabled = true,
    bool destructief = false,
  }) {
    final icoonKleur = destructief ? const Color(0xFFDC2626) : _tekstDonker;
    final pijlKleur = destructief ? const Color(0xFFDC2626) : _tekstGrijs;
    return PopupMenuItem<String>(
      value: waarde,
      enabled: enabled,
      height: 35,
      padding: const EdgeInsets.fromLTRB(7, 1, 7, 1),
      child: Opacity(
        opacity: enabled ? 1 : 0.38,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: <Widget>[
              Icon(icoon, color: icoonKleur, size: 16.5),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tekst,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: destructief ? icoonKleur : _tekstDonker,
                    fontSize: 12.3,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, color: pijlKleur, size: 15.5),
            ],
          ),
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
                  color: _accent,
                ),
              )
            : const Icon(Icons.refresh_rounded),
        style: IconButton.styleFrom(
          foregroundColor: _tekstDonker,
          backgroundColor: const Color(0xFFF7F8F9),
        ),
      ),
    );
  }

  Widget _bouwFormulierMenu() {
    return PopupMenuButton<String>(
      enabled: heeftOpenBestand,
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
      child: _bouwDropdownTab(
        tekst: 'Toevoegen',
        icoon: Icons.add_rounded,
        enabled: heeftOpenBestand,
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
            child: Divider(height: 1, thickness: 1, color: _accentScheiding),
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
                  Icon(registratie.icoon, color: _tekstDonker, size: 17),
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
                    color: _tekstGrijs,
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
