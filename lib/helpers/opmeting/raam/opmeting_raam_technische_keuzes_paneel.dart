import 'package:flutter/material.dart';

import 'opmeting_raam_keuzemenu_model.dart';
import 'opmeting_raam_kleinhout_helper.dart';
import 'opmeting_raam_kleinhout_model.dart';
import 'opmeting_raam_vulling_helper.dart';

class OpmetingRaamTechnischeKeuzesPaneel extends StatefulWidget {
  const OpmetingRaamTechnischeKeuzesPaneel({
    super.key,
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
    required this.onBeheerSlotWisselen,
    required this.onMenuAanpassen,
    required this.onMenuOmhoog,
    required this.onMenuOmlaag,
    required this.onMenuVerwijderen,
  });

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
  final VoidCallback onBeheerSlotWisselen;
  final ValueChanged<OpmetingRaamKeuzeMenu> onMenuAanpassen;
  final ValueChanged<OpmetingRaamKeuzeMenu> onMenuOmhoog;
  final ValueChanged<OpmetingRaamKeuzeMenu> onMenuOmlaag;
  final ValueChanged<OpmetingRaamKeuzeMenu> onMenuVerwijderen;

  @override
  State<OpmetingRaamTechnischeKeuzesPaneel> createState() {
    return _OpmetingRaamTechnischeKeuzesPaneelState();
  }
}

class _OpmetingRaamTechnischeKeuzesPaneelState
    extends State<OpmetingRaamTechnischeKeuzesPaneel> {
  static const Color groen = Color(0xFF0B7A3B);
  static const Color lichtGroen = Color(0xFFE7F6EC);
  static const Color rand = Color(0xFFE5E7EB);
  static const Color tekstDonker = Color(0xFF111827);
  static const Color tekstGrijs = Color(0xFF6B7280);

  final Set<String> _openMenuIds = <String>{};
  final Set<String> _openSubmenuIds = <String>{};

  @override
  void didUpdateWidget(covariant OpmetingRaamTechnischeKeuzesPaneel oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bestaandeMenuIds = widget.keuzemenus.map((menu) => menu.id).toSet();

    _openMenuIds.removeWhere((menuId) {
      return !bestaandeMenuIds.contains(menuId);
    });

    _openSubmenuIds.removeWhere((sleutel) {
      final delen = sleutel.split('::');

      if (delen.isEmpty) {
        return true;
      }

      return !bestaandeMenuIds.contains(delen.first);
    });
  }

  @override
  Widget build(BuildContext context) {
    final zichtbareMenus = widget.keuzemenus.where((menu) {
      return widget.menuBeheerOntgrendeld || menu.actief;
    }).toList();

    zichtbareMenus.sort((eerste, tweede) {
      return eerste.volgorde.compareTo(tweede.volgorde);
    });

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: rand),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Technische keuzes',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: tekstDonker,
                    ),
                  ),
                ),
                if (widget.keuzemenusBewaren)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: groen,
                      ),
                    ),
                  ),
                SizedBox(
                  width: 34,
                  height: 34,
                  child: IconButton(
                    tooltip: 'Technisch item toevoegen',
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    onPressed: widget.onMenuToevoegen,
                    icon: const Icon(
                      Icons.add_circle_outline,
                      size: 22,
                      color: groen,
                    ),
                  ),
                ),
                SizedBox(
                  width: 34,
                  height: 34,
                  child: IconButton(
                    tooltip: widget.menuBeheerOntgrendeld
                        ? 'Menu-beheer vergrendelen'
                        : 'Menu-beheer ontgrendelen',
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    onPressed: widget.onBeheerSlotWisselen,
                    icon: Icon(
                      widget.menuBeheerOntgrendeld
                          ? Icons.lock_open
                          : Icons.lock_outline,
                      size: 19,
                      color: groen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _bouwOpvullingRij(),
            _bouwKleinhoutRij(),
            if (widget.keuzemenusLaden)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator(color: groen)),
              )
            else if (zichtbareMenus.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.menuBeheerOntgrendeld
                        ? 'Voeg een technisch item toe met +.'
                        : 'Nog geen technische keuzes toegevoegd.',
                    style: const TextStyle(color: tekstGrijs, fontSize: 12),
                  ),
                ),
              )
            else
              ...zichtbareMenus.map(_bouwTechnischKeuzemenuRij),
          ],
        ),
      ),
    );
  }

  Widget _bouwOpvullingRij() {
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

  Widget _bouwKleinhoutRij() {
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

  Widget _bouwCompacteRij({
    required String titel,
    required String waarde,
    required bool isOpen,
    required bool heeftWaarde,
    required VoidCallback onTap,
    required Widget inhoud,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.fromLTRB(4, 7, 0, 7),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: rand)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_korteTitel(titel)}   $waarde',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: heeftWaarde ? groen : tekstDonker,
                        fontSize: 12,
                        fontWeight: heeftWaarde
                            ? FontWeight.w800
                            : FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: tekstGrijs,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          if (isOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 6, 4, 8),
              child: inhoud,
            ),
        ],
      ),
    );
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
        style: TextStyle(color: tekstGrijs, fontSize: 11),
      );
    }

    return Column(
      children: widget.gekozenOpvullingen.map((opvulling) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            children: [
              Container(
                width: 17,
                height: 17,
                decoration: BoxDecoration(
                  color: opvulling.weergaveKleur,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: const Color(0xFF9CA3AF)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${opvulling.nummer}. '
                  '${opvulling.naam}',
                  style: const TextStyle(
                    color: tekstDonker,
                    fontSize: 11,
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
        style: TextStyle(color: tekstGrijs, fontSize: 11),
      );
    }

    return Column(
      children: widget.gekozenKleinhouten.map((kleinhout) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${kleinhout.nummer}. '
              '${_maakLeesbaar(kleinhout.type.name)} · '
              '${_maakLeesbaar(kleinhout.patroon.name)}',
              style: const TextStyle(
                color: tekstDonker,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _bouwTechnischKeuzemenuRij(OpmetingRaamKeuzeMenu menu) {
    final geselecteerdeOptieId =
        widget.geselecteerdeOptieIdVoorMenu(menu) ?? '';
    final waarde = _waardeVoorMenu(menu, geselecteerdeOptieId);
    final heeftWaarde = !_isGeenGekozen(menu, geselecteerdeOptieId);
    final items = _zichtbareItemsVoorMenu(menu);
    final isOpen = _openMenuIds.contains(menu.id);

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () {
              setState(() {
                if (isOpen) {
                  _sluitMenu(menu.id);
                } else {
                  _openMenuIds.add(menu.id);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(4, 7, 0, 7),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: rand)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_korteTitel(menu.titel)}   $waarde',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: heeftWaarde ? groen : tekstDonker,
                        fontSize: 12,
                        fontWeight: heeftWaarde
                            ? FontWeight.w800
                            : FontWeight.w700,
                      ),
                    ),
                  ),
                  if (widget.menuBeheerOntgrendeld)
                    _bouwKeuzemenuBeheerKnop(menu),
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: tekstGrijs,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          if (isOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(4, 2, 4, 6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Geen keuzes in dit menu.',
                          style: TextStyle(color: tekstGrijs, fontSize: 11),
                        ),
                      ),
                    )
                  else
                    ...items.map((item) {
                      return _bouwMenuItem(
                        menu: menu,
                        item: item,
                        geselecteerdeOptieId: geselecteerdeOptieId,
                        diepte: 0,
                      );
                    }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _sluitMenu(String menuId) {
    _openMenuIds.remove(menuId);
    _openSubmenuIds.removeWhere((sleutel) {
      return sleutel.startsWith('$menuId::');
    });
  }

  Future<void> _kiesOptie({
    required OpmetingRaamKeuzeMenu menu,
    required String optieId,
  }) async {
    setState(() {
      _sluitMenu(menu.id);
    });

    await widget.onOptieGekozen(menu, optieId);
  }

  String _waardeVoorMenu(
    OpmetingRaamKeuzeMenu menu,
    String geselecteerdeOptieId,
  ) {
    if (_isGeenGekozen(menu, geselecteerdeOptieId)) {
      return 'Geen gekozen';
    }

    final pad = menu.padTekstVoorOptie(geselecteerdeOptieId).trim();

    if (pad.isEmpty || pad.toLowerCase() == 'geen') {
      return 'Geen gekozen';
    }

    return pad;
  }

  bool _isGeenGekozen(OpmetingRaamKeuzeMenu menu, String geselecteerdeOptieId) {
    final id = geselecteerdeOptieId.trim();

    if (id.isEmpty) {
      return true;
    }

    if (id == menu.geenOptie.id) {
      return true;
    }

    final optie = menu.zoekOptie(id);

    if (optie == null) {
      return true;
    }

    return optie.isGeenKeuze;
  }

  List<OpmetingRaamKeuzeMenuItem> _zichtbareItemsVoorMenu(
    OpmetingRaamKeuzeMenu menu,
  ) {
    final resultaat = <OpmetingRaamKeuzeMenuItem>[];

    for (final item in menu.boomItems) {
      final zichtbaarItem = _filterZichtbaarItem(item);

      if (zichtbaarItem != null) {
        resultaat.add(zichtbaarItem);
      }
    }

    return List<OpmetingRaamKeuzeMenuItem>.unmodifiable(resultaat);
  }

  OpmetingRaamKeuzeMenuItem? _filterZichtbaarItem(
    OpmetingRaamKeuzeMenuItem item,
  ) {
    if (item.isKeuze && item.optie?.isGeenKeuze == true) {
      return null;
    }

    if (widget.menuBeheerOntgrendeld) {
      return item;
    }

    if (!item.actief) {
      return null;
    }

    if (item.isKeuze) {
      final optie = item.optie;

      if (optie == null || !optie.actief) {
        return null;
      }

      return item;
    }

    final kinderen = <OpmetingRaamKeuzeMenuItem>[];

    for (final kind in item.kinderen) {
      final zichtbaarKind = _filterZichtbaarItem(kind);

      if (zichtbaarKind != null) {
        kinderen.add(zichtbaarKind);
      }
    }

    if (kinderen.isEmpty) {
      return null;
    }

    return item.copyWith(kinderen: kinderen);
  }

  Widget _bouwMenuItem({
    required OpmetingRaamKeuzeMenu menu,
    required OpmetingRaamKeuzeMenuItem item,
    required String geselecteerdeOptieId,
    required int diepte,
  }) {
    if (item.isSubmenu) {
      return _bouwSubmenuItem(
        menu: menu,
        item: item,
        geselecteerdeOptieId: geselecteerdeOptieId,
        diepte: diepte,
      );
    }

    return _bouwKeuzeItem(
      menu: menu,
      item: item,
      geselecteerdeOptieId: geselecteerdeOptieId,
      diepte: diepte,
    );
  }

  Widget _bouwSubmenuItem({
    required OpmetingRaamKeuzeMenu menu,
    required OpmetingRaamKeuzeMenuItem item,
    required String geselecteerdeOptieId,
    required int diepte,
  }) {
    final bevatGeselecteerde = item.bevatOptieId(geselecteerdeOptieId);
    final submenuWaarde = _waardeVoorSubmenu(item, geselecteerdeOptieId);
    final submenuSleutel = '${menu.id}::${item.id}';
    final isOpen = _openSubmenuIds.contains(submenuSleutel);

    return Padding(
      padding: EdgeInsets.only(left: diepte * 10.0, bottom: 4),
      child: Container(
        decoration: BoxDecoration(
          color: bevatGeselecteerde ? lichtGroen : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: bevatGeselecteerde ? groen : rand,
            width: bevatGeselecteerde ? 1.2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(8),
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
                padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_korteTitel(item.weergaveNaam)}   $submenuWaarde',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: bevatGeselecteerde ? groen : tekstDonker,
                          fontSize: 11.5,
                          fontWeight: bevatGeselecteerde
                              ? FontWeight.w800
                              : FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      isOpen
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: bevatGeselecteerde ? groen : tekstGrijs,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
            if (isOpen)
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: item.kinderen.map((kind) {
                    return _bouwMenuItem(
                      menu: menu,
                      item: kind,
                      geselecteerdeOptieId: geselecteerdeOptieId,
                      diepte: diepte + 1,
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _waardeVoorSubmenu(
    OpmetingRaamKeuzeMenuItem item,
    String geselecteerdeOptieId,
  ) {
    if (!item.bevatOptieId(geselecteerdeOptieId)) {
      return 'Kiezen';
    }

    final pad = item
        .padNamenVoorOptie(geselecteerdeOptieId)
        .where((deel) => deel.trim().isNotEmpty)
        .toList();

    if (pad.isEmpty) {
      return 'Kiezen';
    }

    return pad.join(' > ');
  }

  Widget _bouwKeuzeItem({
    required OpmetingRaamKeuzeMenu menu,
    required OpmetingRaamKeuzeMenuItem item,
    required String geselecteerdeOptieId,
    required int diepte,
  }) {
    final optie = item.optie;

    if (optie == null || optie.isGeenKeuze) {
      return const SizedBox.shrink();
    }

    final geselecteerd = optie.id == geselecteerdeOptieId;

    return Padding(
      padding: EdgeInsets.only(left: diepte * 10.0, bottom: 4),
      child: Material(
        color: geselecteerd ? lichtGroen : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () async {
            await _kiesOptie(menu: menu, optieId: optie.id);
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: geselecteerd ? groen : rand,
                width: geselecteerd ? 1.2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  geselecteerd
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: geselecteerd ? groen : tekstGrijs,
                  size: 17,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    optie.naam,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: geselecteerd ? groen : tekstDonker,
                      fontSize: 11.5,
                      fontWeight: geselecteerd
                          ? FontWeight.w900
                          : FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bouwKeuzemenuBeheerKnop(OpmetingRaamKeuzeMenu menu) {
    return SizedBox(
      width: 30,
      height: 30,
      child: PopupMenuButton<String>(
        tooltip: 'Technische keuze aanpassen',
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.more_vert, size: 18, color: tekstGrijs),
        onSelected: (actie) {
          switch (actie) {
            case 'aanpassen':
              widget.onMenuAanpassen(menu);
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
                leading: Icon(Icons.edit_outlined, color: groen),
                title: Text('Technische keuze aanpassen'),
              ),
            ),
            PopupMenuItem<String>(
              value: 'omhoog',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(Icons.arrow_upward, color: groen),
                title: Text('Naar boven'),
              ),
            ),
            PopupMenuItem<String>(
              value: 'omlaag',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: Icon(Icons.arrow_downward, color: groen),
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

  static String _korteTitel(String tekst) {
    final waarde = tekst.trim();

    if (waarde.length <= 12) {
      return waarde;
    }

    return waarde.substring(0, 12);
  }

  static String _maakLeesbaar(String tekst) {
    if (tekst.isEmpty) {
      return tekst;
    }

    final buffer = StringBuffer();

    for (var index = 0; index < tekst.length; index++) {
      final teken = tekst[index];

      if (index > 0 &&
          teken.toUpperCase() == teken &&
          teken.toLowerCase() != teken) {
        buffer.write(' ');
      }

      buffer.write(teken);
    }

    final resultaat = buffer.toString();

    return resultaat[0].toUpperCase() + resultaat.substring(1);
  }
}
