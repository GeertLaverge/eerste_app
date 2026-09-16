// THIMACO-CONTROLE: RAAM-TEKENPROGRAMMA-FASE5-TECHNIEK-SAMENVATTING-20260913
// THIMACO-CONTROLE: EEN-KNOP-NAAR-ALLE-TECHNISCHE-TITELS-20260727
// THIMACO-CONTROLE: OVERZICHT-ZONDER-OVERBODIGE-STRUCTUURKNOPPEN-20260727
// THIMACO-CONTROLE: ONTBREKENDE-TITELS-ANDERE-ARTIKELTYPES-FASE-4-20260727
// THIMACO-CONTROLE: COMPACTE-BOOM-KOPIEREN-VANUIT-BOOM-FASE-3-20260727
// THIMACO-CONTROLE: COMPACTE-BOOM-AANMAKEN-VANUIT-BOOM-FASE-2-20260727
import 'package:flutter/material.dart';

import '../../ui/thimaco_huisstijl.dart';

import 'opmeting_raam_keuzemenu_model.dart';
import 'opmeting_raam_kleinhout_helper.dart';
import 'opmeting_raam_vulling_helper.dart';

class OpmetingRaamTechnischeKeuzesPaneel extends StatefulWidget {
  const OpmetingRaamTechnischeKeuzesPaneel({
    super.key,
    this.raamVleugelSamenvatting = '',
    this.deurVleugelSamenvatting = '',
    this.schuifraamSamenvatting = '',
    this.profielSamenvatting = '',
    required this.gekozenOpvullingen,
    required this.gekozenKleinhouten,
    required this.keuzemenus,
    required this.keuzemenusLaden,
    required this.keuzemenusBewaren,
    required this.menuBeheerOntgrendeld,
    required this.opvullingenOpen,
    required this.kleinhoutenOpen,
    required this.onOpvullingenOpenGewijzigd,
    required this.onKleinhoutenOpenGewijzigd,
    required this.geselecteerdeOptieIdVoorMenu,
    required this.onOptieGekozen,
    required this.onMenuToevoegen,
    this.onTitelOpladen,
    required this.onKeuzeToevoegen,
    required this.onSubmenuToevoegen,
    required this.onMenuKopieren,
    required this.onItemKopieren,
    required this.onBeheerSlotWisselen,
    required this.onMenuAanpassen,
    required this.onMenuOmhoog,
    required this.onMenuOmlaag,
    required this.onMenuVerwijderen,
    this.focusMenuId,
    this.selectieDialoog = false,
    this.samenvattingAlleen = false,
    this.samenvattingPerMenu = const <String, String>{},
  });

  final String raamVleugelSamenvatting;
  final String deurVleugelSamenvatting;
  final String schuifraamSamenvatting;
  final String profielSamenvatting;
  final List<OpmetingRaamVullingLegendaItem> gekozenOpvullingen;
  final List<OpmetingRaamKleinhoutLegendaItem> gekozenKleinhouten;
  final List<OpmetingRaamKeuzeMenu> keuzemenus;

  final bool keuzemenusLaden;
  final bool keuzemenusBewaren;
  final bool menuBeheerOntgrendeld;
  final bool opvullingenOpen;
  final bool kleinhoutenOpen;

  final ValueChanged<bool> onOpvullingenOpenGewijzigd;
  final ValueChanged<bool> onKleinhoutenOpenGewijzigd;

  final String? Function(OpmetingRaamKeuzeMenu menu)
  geselecteerdeOptieIdVoorMenu;

  final Future<void> Function(OpmetingRaamKeuzeMenu menu, String optieId)
  onOptieGekozen;

  final VoidCallback onMenuToevoegen;
  final Future<void> Function()? onTitelOpladen;
  final Future<void> Function(
    OpmetingRaamKeuzeMenu menu,
    String? ouderSubmenuId,
  )
  onKeuzeToevoegen;
  final Future<void> Function(
    OpmetingRaamKeuzeMenu menu,
    String? ouderSubmenuId,
  )
  onSubmenuToevoegen;
  final Future<void> Function(OpmetingRaamKeuzeMenu menu) onMenuKopieren;
  final Future<void> Function(
    OpmetingRaamKeuzeMenu menu,
    OpmetingRaamKeuzeMenuItem item,
  )
  onItemKopieren;
  final VoidCallback onBeheerSlotWisselen;
  final ValueChanged<OpmetingRaamKeuzeMenu> onMenuAanpassen;
  final ValueChanged<OpmetingRaamKeuzeMenu> onMenuOmhoog;
  final ValueChanged<OpmetingRaamKeuzeMenu> onMenuOmlaag;
  final ValueChanged<OpmetingRaamKeuzeMenu> onMenuVerwijderen;

  final String? focusMenuId;
  final bool selectieDialoog;
  final bool samenvattingAlleen;
  final Map<String, String> samenvattingPerMenu;

  @override
  State<OpmetingRaamTechnischeKeuzesPaneel> createState() {
    return _OpmetingRaamTechnischeKeuzesPaneelState();
  }
}

class _OpmetingRaamTechnischeKeuzesPaneelState
    extends State<OpmetingRaamTechnischeKeuzesPaneel> {
  static const Color groen = ThimacoKleuren.oranje;
  static const Color lichtGroen = ThimacoKleuren.oranjeLicht;
  static const Color rand = ThimacoKleuren.rand;
  static const Color tekstDonker = ThimacoKleuren.antraciet;
  static const Color tekstGrijs = ThimacoKleuren.tekstGrijs;

  final Set<String> _openMenuIds = <String>{};
  final Set<String> _openSubmenuIds = <String>{};

  @override
  void initState() {
    super.initState();
    _openFocusMenuEnPad();
  }

  void _openFocusMenuEnPad() {
    final focusMenuId = widget.focusMenuId?.trim() ?? '';
    if (focusMenuId.isEmpty) return;

    OpmetingRaamKeuzeMenu? focusMenu;
    for (final menu in widget.keuzemenus) {
      if (menu.id == focusMenuId) {
        focusMenu = menu;
        break;
      }
    }

    if (focusMenu == null) return;

    _openMenuIds.add(focusMenu.id);

    final optieId = widget.geselecteerdeOptieIdVoorMenu(focusMenu)?.trim() ?? '';
    if (optieId.isEmpty || optieId == focusMenu.geenOptie.id) return;

    final padIds = focusMenu.padIdsVoorOptie(optieId);
    if (padIds.length <= 1) return;

    for (final submenuId in padIds.take(padIds.length - 1)) {
      _openSubmenuIds.add('${focusMenu.id}/$submenuId');
    }
  }

  @override
  void didUpdateWidget(covariant OpmetingRaamTechnischeKeuzesPaneel oldWidget) {
    super.didUpdateWidget(oldWidget);

    final geldigeMenuIds = widget.keuzemenus.map((menu) => menu.id).toSet();

    _openMenuIds.removeWhere((menuId) => !geldigeMenuIds.contains(menuId));

    _openSubmenuIds.removeWhere((submenuId) {
      final menuId = submenuId.split('/').first;
      return !geldigeMenuIds.contains(menuId);
    });

    if (oldWidget.focusMenuId != widget.focusMenuId) {
      _openFocusMenuEnPad();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.samenvattingAlleen) {
      return _bouwSamenvatting();
    }

    var zichtbareMenus = widget.keuzemenus.where((menu) {
      return widget.menuBeheerOntgrendeld || menu.actief;
    }).toList();

    final focusMenuId = widget.focusMenuId?.trim() ?? '';
    if (focusMenuId.isNotEmpty) {
      zichtbareMenus = zichtbareMenus
          .where((menu) => menu.id == focusMenuId)
          .toList();
    }

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: rand),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(9, 7, 9, 7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!widget.selectieDialoog) ...[
              _bouwKop(),
              const SizedBox(height: 3),
              if (widget.deurVleugelSamenvatting.trim().isNotEmpty)
                _bouwDeurVleugelRij(),
              if (widget.schuifraamSamenvatting.trim().isNotEmpty)
                _bouwSchuifraamRij(),
              _bouwCompacteOpvullingRij(),
              _bouwCompacteKleinhoutRij(),
              if (widget.profielSamenvatting.trim().isNotEmpty)
                _bouwProfielRij(),
            ],
            if (widget.keuzemenusLaden)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: groen,
                  ),
                ),
              )
            else if (zichtbareMenus.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.selectieDialoog
                        ? 'Deze technische keuze is niet beschikbaar.'
                        : widget.menuBeheerOntgrendeld
                        ? 'Beheer de technische titels via “Keuze toevoegen..”.'
                        : 'Nog geen technische keuzes toegevoegd.',
                    style: const TextStyle(color: tekstGrijs, fontSize: 11.5),
                  ),
                ),
              )
            else
              ...zichtbareMenus.map(_bouwKeuzemenuKaart),
          ],
        ),
      ),
    );
  }

  Widget _bouwSamenvatting() {
    final regels = <Widget>[];

    void voegRegelToe(String titel, String waarde) {
      final netteWaarde = waarde.trim();
      if (netteWaarde.isEmpty) return;

      if (regels.isNotEmpty) {
        regels.add(const SizedBox(height: 6));
      }
      regels.add(_bouwSamenvattingRij(titel: titel, waarde: netteWaarde));
    }

    if (widget.raamVleugelSamenvatting.trim().isNotEmpty) {
      voegRegelToe('Raamvleugel', widget.raamVleugelSamenvatting);
    }

    if (widget.deurVleugelSamenvatting.trim().isNotEmpty) {
      voegRegelToe('Deurvleugel', widget.deurVleugelSamenvatting);
    }

    if (widget.schuifraamSamenvatting.trim().isNotEmpty) {
      voegRegelToe('Schuifraam', widget.schuifraamSamenvatting);
    }

    if (widget.gekozenOpvullingen.isNotEmpty) {
      voegRegelToe('Opvulling', _opvullingSamenvatting());
    }

    if (widget.gekozenKleinhouten.isNotEmpty) {
      voegRegelToe('Kleinhouten', _kleinhoutSamenvatting());
    }

    if (widget.profielSamenvatting.trim().isNotEmpty) {
      voegRegelToe('Profiel', widget.profielSamenvatting);
    }

    final menus = widget.keuzemenus
        .where((menu) => widget.menuBeheerOntgrendeld || menu.actief)
        .toList()
      ..sort((eerste, tweede) {
        final volgorde = eerste.volgorde.compareTo(tweede.volgorde);
        if (volgorde != 0) return volgorde;
        return eerste.titel.toLowerCase().compareTo(tweede.titel.toLowerCase());
      });

    for (final menu in menus) {
      final samenvatting = widget.samenvattingPerMenu[menu.id]?.trim() ?? '';
      if (samenvatting.isNotEmpty) {
        voegRegelToe(menu.titel, samenvatting);
        continue;
      }

      // Als de samenvatting van alle kaders deze titel niet bevat,
      // val terug op de actieve kaderselectie. Zo verschijnt een net gekozen
      // keuze onmiddellijk rechts bij Techniek.
      final optieId = widget.geselecteerdeOptieIdVoorMenu(menu)?.trim() ?? '';
      if (optieId.isEmpty || optieId == menu.geenOptie.id) continue;

      final optie = menu.zoekOptie(optieId);
      if (optie == null || optie.isGeenKeuze) continue;

      voegRegelToe(menu.titel, _waardeVoorMenu(menu, optieId));
    }

    if (regels.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Nog geen technische keuzes geselecteerd.',
          style: TextStyle(
            color: ThimacoKleuren.tekstGrijs,
            fontSize: 11.5,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: regels,
    );
  }

  Widget _bouwSamenvattingRij({
    required String titel,
    required String waarde,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(9, 7, 9, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          top: BorderSide(color: ThimacoKleuren.rand),
          left: BorderSide(color: ThimacoKleuren.rand),
          right: BorderSide(color: ThimacoKleuren.rand),
          bottom: BorderSide(color: ThimacoKleuren.oranje, width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            titel.trim().isEmpty ? 'Technische keuze' : titel.trim(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ThimacoKleuren.tekstGrijs,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            waarde,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ThimacoKleuren.antraciet,
              fontSize: 11.5,
              height: 1.15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwDeurVleugelRij() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 5.5),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: rand)),
      ),
      child: Text(
        widget.deurVleugelSamenvatting.trim(),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.left,
        style: const TextStyle(
          color: groen,
          fontSize: 11.5,
          height: 1.1,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _bouwSchuifraamRij() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 5.5),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: rand)),
      ),
      child: Text(
        widget.schuifraamSamenvatting.trim(),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.left,
        style: const TextStyle(
          color: groen,
          fontSize: 11.5,
          height: 1.1,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _bouwProfielRij() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 5.5),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: rand)),
      ),
      child: Text(
        widget.profielSamenvatting.trim(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.left,
        style: const TextStyle(
          color: groen,
          fontSize: 11.5,
          height: 1.1,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _bouwKop() {
    return Row(
      children: <Widget>[
        const Expanded(
          child: ThimacoSectieTitel(tekst: 'Technische keuzes'),
        ),
        if (widget.keuzemenusBewaren)
          const Padding(
            padding: EdgeInsets.only(right: 7),
            child: SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: ThimacoKleuren.oranje,
              ),
            ),
          ),
        ThimacoTekstActie(
          tekst: 'Keuze toevoegen',
          onPressed: widget.onMenuToevoegen,
        ),
        const SizedBox(width: 2),
        ThimacoIcoonActie(
          icoon: widget.menuBeheerOntgrendeld
              ? Icons.lock_open
              : Icons.lock_outline,
          tooltip: widget.menuBeheerOntgrendeld
              ? 'Menu-beheer vergrendelen'
              : 'Menu-beheer ontgrendelen',
          onPressed: widget.onBeheerSlotWisselen,
          grootte: 18,
        ),
      ],
    );
  }

  Widget _bouwCompacteOpvullingRij() {
    return _bouwCompacteRij(
      titel: 'Opvulling',
      waarde: _opvullingSamenvatting(),
      isOpen: widget.opvullingenOpen,
      heeftWaarde: widget.gekozenOpvullingen.isNotEmpty,
      onTap: () {
        widget.onOpvullingenOpenGewijzigd(!widget.opvullingenOpen);
      },
      inhoud: _bouwOpvullingDetails(),
    );
  }

  Widget _bouwCompacteKleinhoutRij() {
    return _bouwCompacteRij(
      titel: 'Kleinhouten',
      waarde: _kleinhoutSamenvatting(),
      isOpen: widget.kleinhoutenOpen,
      heeftWaarde: widget.gekozenKleinhouten.isNotEmpty,
      onTap: () {
        widget.onKleinhoutenOpenGewijzigd(!widget.kleinhoutenOpen);
      },
      inhoud: _bouwKleinhoutDetails(),
    );
  }

  Widget _bouwKeuzemenuKaart(OpmetingRaamKeuzeMenu menu) {
    final geselecteerdeOptieId = widget.geselecteerdeOptieIdVoorMenu(menu);
    final heeftWaarde =
        geselecteerdeOptieId != null &&
        geselecteerdeOptieId.trim().isNotEmpty &&
        geselecteerdeOptieId != menu.geenOptie.id;

    return _bouwCompacteRij(
      titel: menu.titel,
      waarde: _waardeVoorMenu(menu, geselecteerdeOptieId),
      isOpen: _openMenuIds.contains(menu.id),
      heeftWaarde: heeftWaarde,
      onTap: () {
        setState(() {
          if (_openMenuIds.contains(menu.id)) {
            _sluitMenu(menu.id);
          } else {
            _openMenuIds.add(menu.id);
          }
        });
      },
      inhoud: _bouwMenuInhoud(menu),
      beheerKnop:
          widget.menuBeheerOntgrendeld && !widget.selectieDialoog
          ? _bouwKeuzemenuBeheerKnop(menu)
          : null,
    );
  }

  Widget _bouwCompacteRij({
    required String titel,
    required String waarde,
    required bool isOpen,
    required bool heeftWaarde,
    required VoidCallback onTap,
    required Widget inhoud,
    Widget? beheerKnop,
  }) {
    final tekst = heeftWaarde && waarde.trim().isNotEmpty
        ? waarde.trim()
        : '${titel.trim()}   ${waarde.trim()}';

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: rand)),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.5),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        tekst,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: heeftWaarde ? groen : tekstDonker,
                          fontSize: 11.5,
                          height: 1.1,
                          fontWeight: heeftWaarde
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (beheerKnop != null) ...[
                      const SizedBox(width: 3),
                      beheerKnop,
                    ],
                    Icon(
                      isOpen
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: tekstGrijs,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isOpen)
            Padding(
              padding: const EdgeInsets.only(left: 2, right: 2, bottom: 6),
              child: Align(alignment: Alignment.centerLeft, child: inhoud),
            ),
        ],
      ),
    );
  }

  Widget _bouwMenuInhoud(OpmetingRaamKeuzeMenu menu) {
    final items = _zichtbareItemsVoorMenu(menu);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _bouwGeenKeuzeItem(menu),
        ...items.map((item) {
          return _bouwMenuItem(menu: menu, item: item, niveau: 0);
        }),
      ],
    );
  }

  Widget _bouwGeenKeuzeItem(OpmetingRaamKeuzeMenu menu) {
    final geselecteerdeOptieId = widget.geselecteerdeOptieIdVoorMenu(menu);
    final geselecteerd =
        geselecteerdeOptieId == null ||
        geselecteerdeOptieId.trim().isEmpty ||
        geselecteerdeOptieId == menu.geenOptie.id;

    return _bouwOptieRegel(
      tekst: 'Geen',
      geselecteerd: geselecteerd,
      niveau: 0,
      onTap: () {
        _kiesOptie(menu, menu.geenOptie.id);
      },
    );
  }

  Widget _bouwMenuItem({
    required OpmetingRaamKeuzeMenu menu,
    required OpmetingRaamKeuzeMenuItem item,
    required int niveau,
  }) {
    if (item.isSubmenu) {
      return _bouwSubmenuItem(menu: menu, item: item, niveau: niveau);
    }

    return _bouwKeuzeItem(menu: menu, item: item, niveau: niveau);
  }

  Widget _bouwSubmenuItem({
    required OpmetingRaamKeuzeMenu menu,
    required OpmetingRaamKeuzeMenuItem item,
    required int niveau,
  }) {
    final submenuSleutel = '${menu.id}/${item.id}';
    final isOpen = _openSubmenuIds.contains(submenuSleutel);
    final geselecteerdeOptieId = widget.geselecteerdeOptieIdVoorMenu(menu);
    final bevatGeselecteerdeKeuze =
        geselecteerdeOptieId != null &&
        geselecteerdeOptieId.trim().isNotEmpty &&
        item.bevatOptieId(geselecteerdeOptieId);

    final kinderen = item.kinderen.where(_filterZichtbaarItem).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: bevatGeselecteerdeKeuze ? lichtGroen : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          child: InkWell(
            borderRadius: BorderRadius.circular(7),
            onTap: () {
              setState(() {
                if (isOpen) {
                  _openSubmenuIds.remove(submenuSleutel);
                } else {
                  _openSubmenuIds.add(submenuSleutel);
                }
              });
            },
            child: Padding(
              padding: EdgeInsets.fromLTRB(8 + (niveau * 14), 5.5, 7, 5.5),
              child: Row(
                children: [
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_right_rounded,
                    size: 17,
                    color: bevatGeselecteerdeKeuze ? groen : tekstGrijs,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      item.naam.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: bevatGeselecteerdeKeuze ? groen : tekstDonker,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isOpen)
          ...kinderen.map((kind) {
            return _bouwMenuItem(menu: menu, item: kind, niveau: niveau + 1);
          }),
      ],
    );
  }

  Widget _bouwKeuzeItem({
    required OpmetingRaamKeuzeMenu menu,
    required OpmetingRaamKeuzeMenuItem item,
    required int niveau,
  }) {
    final optie = item.optie;

    if (optie == null || optie.isGeenKeuze) {
      return const SizedBox.shrink();
    }

    final geselecteerdeOptieId = widget.geselecteerdeOptieIdVoorMenu(menu);
    final geselecteerd = geselecteerdeOptieId == optie.id;

    return _bouwOptieRegel(
      tekst: optie.naam,
      geselecteerd: geselecteerd,
      niveau: niveau,
      onTap: () {
        _kiesOptie(menu, optie.id);
      },
    );
  }

  Widget _bouwOptieRegel({
    required String tekst,
    required bool geselecteerd,
    required int niveau,
    required VoidCallback onTap,
    Widget? beheerKnop,
  }) {
    return Material(
      color: geselecteerd ? lichtGroen : Colors.transparent,
      borderRadius: BorderRadius.circular(7),
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(30 + (niveau * 14), 5.5, 7, 5.5),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  tekst.trim().isEmpty ? 'Keuze' : tekst.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: geselecteerd ? groen : tekstDonker,
                    fontSize: 11.5,
                    fontWeight: geselecteerd
                        ? FontWeight.w900
                        : FontWeight.w600,
                  ),
                ),
              ),
              if (beheerKnop != null) ...[const SizedBox(width: 3), beheerKnop],
              if (geselecteerd)
                const Icon(Icons.check_circle, size: 15, color: groen),
            ],
          ),
        ),
      ),
    );
  }

  List<OpmetingRaamKeuzeMenuItem> _zichtbareItemsVoorMenu(
    OpmetingRaamKeuzeMenu menu,
  ) {
    final items = <OpmetingRaamKeuzeMenuItem>[];

    for (final item in menu.boomItems) {
      if (_isGeenItem(item)) {
        continue;
      }

      if (_filterZichtbaarItem(item)) {
        items.add(item);
      }
    }

    return items;
  }

  bool _filterZichtbaarItem(OpmetingRaamKeuzeMenuItem item) {
    if (_isGeenItem(item)) {
      return false;
    }

    if (!widget.menuBeheerOntgrendeld && !item.actief) {
      return false;
    }

    if (item.isSubmenu) {
      return item.kinderen.any(_filterZichtbaarItem);
    }

    return true;
  }

  bool _isGeenItem(OpmetingRaamKeuzeMenuItem item) {
    return item.isKeuze && item.optie?.isGeenKeuze == true;
  }

  Future<void> _kiesOptie(OpmetingRaamKeuzeMenu menu, String optieId) async {
    setState(() {
      _sluitMenu(menu.id);
    });

    await widget.onOptieGekozen(menu, optieId);
  }

  void _sluitMenu(String menuId) {
    _openMenuIds.remove(menuId);
    _openSubmenuIds.removeWhere((submenuId) {
      return submenuId.startsWith('$menuId/');
    });
  }

  String _waardeVoorMenu(
    OpmetingRaamKeuzeMenu menu,
    String? geselecteerdeOptieId,
  ) {
    final optieId = geselecteerdeOptieId?.trim() ?? '';

    if (optieId.isEmpty || optieId == menu.geenOptie.id) {
      return 'Geen gekozen';
    }

    final optie = menu.zoekOptie(optieId);

    if (optie == null || optie.isGeenKeuze) {
      return 'Geen gekozen';
    }

    final padNamen = menu
        .padNamenVoorOptie(optieId)
        .map((naam) => naam.trim())
        .where((naam) {
          return naam.isNotEmpty && naam.toLowerCase() != 'geen';
        })
        .toList();

    if (padNamen.isNotEmpty &&
        padNamen.first.toLowerCase() == menu.titel.trim().toLowerCase()) {
      padNamen.removeAt(0);
    }

    if (padNamen.isNotEmpty) {
      return padNamen.join(' ');
    }

    return optie.naam.trim();
  }

  String _opvullingSamenvatting() {
    if (widget.gekozenOpvullingen.isEmpty) {
      return 'Geen gekozen';
    }

    if (widget.gekozenOpvullingen.length == 1) {
      return widget.gekozenOpvullingen.first.naam;
    }

    return '${widget.gekozenOpvullingen.length} gekozen';
  }

  String _kleinhoutSamenvatting() {
    if (widget.gekozenKleinhouten.isEmpty) {
      return 'Geen gekozen';
    }

    if (widget.gekozenKleinhouten.length == 1) {
      final kleinhout = widget.gekozenKleinhouten.first;

      return _maakLeesbaar(kleinhout.type.name);
    }

    return '${widget.gekozenKleinhouten.length} gekozen';
  }

  Widget _bouwOpvullingDetails() {
    if (widget.gekozenOpvullingen.isEmpty) {
      return const Text(
        'Kies de tool Opvulling en selecteer een glasvlak.',
        style: TextStyle(color: tekstGrijs, fontSize: 10.8),
      );
    }

    return Column(
      children: widget.gekozenOpvullingen.map((opvulling) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  color: opvulling.weergaveKleur,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: const Color(0xFF9CA3AF)),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  '${opvulling.nummer}. ${opvulling.naam}',
                  style: const TextStyle(
                    color: tekstDonker,
                    fontSize: 10.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _bouwKleinhoutDetails() {
    if (widget.gekozenKleinhouten.isEmpty) {
      return const Text(
        'Kies de tool Kleinhout en selecteer een gevuld glasvlak.',
        style: TextStyle(color: tekstGrijs, fontSize: 10.8),
      );
    }

    return Column(
      children: widget.gekozenKleinhouten.map((kleinhout) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${kleinhout.nummer}. '
              '${_maakLeesbaar(kleinhout.type.name)} · '
              '${_maakLeesbaar(kleinhout.patroon.name)}',
              style: const TextStyle(
                color: tekstDonker,
                fontSize: 10.8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _bouwKeuzemenuBeheerKnop(OpmetingRaamKeuzeMenu menu) {
    return SizedBox(
      width: 30,
      height: 30,
      child: PopupMenuButton<String>(
        tooltip: 'Technische keuze aanpassen',
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.more_vert, size: 17, color: tekstGrijs),
        onSelected: (actie) {
          switch (actie) {
            case 'aanpassen':
              widget.onMenuAanpassen(menu);
              break;

            case 'kopieren':
              widget.onMenuKopieren(menu);
              break;

            case 'omhoog':
              widget.onMenuOmhoog(menu);
              break;

            case 'omlaag':
              widget.onMenuOmlaag(menu);
              break;

            case 'verwijderen':
              widget.onMenuVerwijderen(menu);
              break;
          }
        },
        itemBuilder: (context) {
          return const [
            PopupMenuItem<String>(
              value: 'aanpassen',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(
                  Icons.edit_outlined,
                  color: ThimacoKleuren.antraciet,
                ),
                title: Text('Technische keuze aanpassen'),
              ),
            ),
            PopupMenuItem<String>(
              value: 'kopieren',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(
                  Icons.copy_outlined,
                  color: ThimacoKleuren.antraciet,
                ),
                title: Text('Titel kopiëren'),
              ),
            ),
            PopupMenuItem<String>(
              value: 'omhoog',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(Icons.arrow_upward),
                title: Text('Naar boven'),
              ),
            ),
            PopupMenuItem<String>(
              value: 'omlaag',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(Icons.arrow_downward),
                title: Text('Naar onder'),
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'verwijderen',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(Icons.delete_outline, color: Colors.red),
                title: Text('Verwijderen', style: TextStyle(color: Colors.red)),
              ),
            ),
          ];
        },
      ),
    );
  }

  String _maakLeesbaar(String tekst) {
    if (tekst.isEmpty) {
      return tekst;
    }

    final buffer = StringBuffer();

    for (var index = 0; index < tekst.length; index++) {
      final teken = tekst[index];
      final isHoofdletter =
          teken.toUpperCase() == teken && teken.toLowerCase() != teken;

      if (index > 0 && isHoofdletter) {
        buffer.write(' ');
      }

      buffer.write(teken);
    }

    final resultaat = buffer.toString().toLowerCase();

    if (resultaat.isEmpty) {
      return resultaat;
    }

    return resultaat[0].toUpperCase() + resultaat.substring(1);
  }
}
