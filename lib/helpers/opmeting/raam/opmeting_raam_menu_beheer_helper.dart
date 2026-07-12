import 'package:flutter/material.dart';

import 'opmeting_raam_keuze_menu_helper.dart';
import 'opmeting_raam_keuzemenu_model.dart';
import 'opmeting_raam_niet_combineerbaar_keuzemenu.dart';
import 'opmeting_raam_technisch_menu_dialoog.dart';

class OpmetingRaamMenuBeheerHelper {
  const OpmetingRaamMenuBeheerHelper._();

  static Future<bool?> vraagBeheerSlotWissel({
    required BuildContext context,
    required bool menuBeheerOntgrendeld,
  }) async {
    const groen = Color(0xFF0B7A3B);
    const lichtGroen = Color(0xFFE7F6EC);

    if (menuBeheerOntgrendeld) {
      return false;
    }

    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final basisTheme = Theme.of(dialogContext);

        return Theme(
          data: basisTheme.copyWith(
            colorScheme: basisTheme.colorScheme.copyWith(
              primary: groen,
              secondary: groen,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: groen),
            ),
          ),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            titlePadding: EdgeInsets.zero,
            title: Container(
              padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
              decoration: const BoxDecoration(
                color: lichtGroen,
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_open, color: groen, size: 21),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Menu-beheer openen?',
                      style: TextStyle(
                        color: groen,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            content: const Text(
              'Wanneer het slot openstaat, kunnen menu’s en keuzes '
              'worden toegevoegd, gewijzigd of verwijderd.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, false);
                },
                child: const Text('Annuleren'),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: groen,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(dialogContext, true);
                },
                icon: const Icon(Icons.lock_open),
                label: const Text('Ontgrendelen'),
              ),
            ],
          ),
        );
      },
    );

    if (bevestigen != true) {
      return null;
    }

    return true;
  }

  static Future<List<OpmetingRaamKeuzeMenu>?> voegMenuToe({
    required BuildContext context,
    required List<OpmetingRaamKeuzeMenu> keuzemenus,
  }) async {
    final beschikbareKeuzes =
        OpmetingRaamKeuzeMenuHelper.beschikbareNietCombineerbareKeuzes(
          keuzemenus: keuzemenus,
        );

    final resultaat = await toonOpmetingRaamTechnischMenuDialoog(
      context: context,
      beschikbareNietCombineerbareKeuzes: beschikbareKeuzes,
    );

    if (resultaat == null) {
      return null;
    }

    final hoogsteVolgorde = keuzemenus.isEmpty
        ? -1
        : keuzemenus
              .map((menu) => menu.volgorde)
              .reduce((eerste, tweede) => eerste > tweede ? eerste : tweede);

    final menuId = 'menu_${DateTime.now().microsecondsSinceEpoch}';

    final basisMenu = OpmetingRaamKeuzeMenu.nieuw(
      id: menuId,
      titel: resultaat.titel,
      volgorde: hoogsteVolgorde + 1,
    );

    final nieuweItems = _itemsVoorOpslagVanResultaat(resultaat);
    final nieuweOpties = _optiesVanItems(
      menuId: menuId,
      geenOptie: basisMenu.geenOptie,
      items: nieuweItems,
    );

    final nieuwMenu = basisMenu.copyWith(
      actief: resultaat.actief,
      opties: nieuweOpties,
      items: nieuweItems,
    );

    return <OpmetingRaamKeuzeMenu>[...keuzemenus, nieuwMenu];
  }

  static Future<List<OpmetingRaamKeuzeMenu>?> bewerkTechnischMenu({
    required BuildContext context,
    required List<OpmetingRaamKeuzeMenu> keuzemenus,
    required OpmetingRaamKeuzeMenu menu,
  }) async {
    final bestaandeItems = menu.boomItems.where((item) {
      return !_isGeenItem(item);
    }).toList();

    final beschikbareKeuzes =
        OpmetingRaamKeuzeMenuHelper.beschikbareNietCombineerbareKeuzes(
          keuzemenus: keuzemenus,
          uitTeSluitenMenuId: menu.id,
        );

    final resultaat = await toonOpmetingRaamTechnischMenuDialoog(
      context: context,
      bestaandMenu: OpmetingRaamTechnischMenuResultaat(
        titel: menu.titel,
        soorten: _soortenVanItems(bestaandeItems),
        items: bestaandeItems,
        actief: menu.actief,
      ),
      beschikbareNietCombineerbareKeuzes: beschikbareKeuzes,
    );

    if (resultaat == null) {
      return null;
    }

    final nieuweItems = _itemsVoorOpslagVanResultaat(resultaat);
    final nieuweOpties = _optiesVanItems(
      menuId: menu.id,
      geenOptie: menu.geenOptie,
      items: nieuweItems,
    );

    return keuzemenus.map((huidigMenu) {
      if (huidigMenu.id != menu.id) {
        return huidigMenu;
      }

      return huidigMenu.copyWith(
        titel: resultaat.titel,
        actief: resultaat.actief,
        opties: nieuweOpties,
        items: nieuweItems,
      );
    }).toList();
  }

  static Future<List<OpmetingRaamKeuzeMenu>?> verwijderMenu({
    required BuildContext context,
    required List<OpmetingRaamKeuzeMenu> keuzemenus,
    required OpmetingRaamKeuzeMenu menu,
  }) async {
    const rood = Color(0xFFDC2626);
    const groen = Color(0xFF0B7A3B);
    const lichtGroen = Color(0xFFE7F6EC);

    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final basisTheme = Theme.of(dialogContext);

        return Theme(
          data: basisTheme.copyWith(
            colorScheme: basisTheme.colorScheme.copyWith(
              primary: groen,
              secondary: groen,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: groen),
            ),
          ),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            titlePadding: EdgeInsets.zero,
            title: Container(
              padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
              decoration: const BoxDecoration(
                color: lichtGroen,
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.delete_outline, color: rood, size: 21),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Menu verwijderen?',
                      style: TextStyle(
                        color: groen,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            content: Text(
              'Het menu “${menu.titel}” en alle keuzes '
              'in dit menu worden verwijderd.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, false);
                },
                child: const Text('Annuleren'),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: rood,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(dialogContext, true);
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Verwijderen'),
              ),
            ],
          ),
        );
      },
    );

    if (bevestigen != true) {
      return null;
    }

    return keuzemenus.where((huidigMenu) => huidigMenu.id != menu.id).toList();
  }

  static List<OpmetingRaamKeuzeMenu>? verplaatsMenu({
    required List<OpmetingRaamKeuzeMenu> keuzemenus,
    required OpmetingRaamKeuzeMenu menu,
    required int richting,
  }) {
    final gesorteerdeMenus = List<OpmetingRaamKeuzeMenu>.from(keuzemenus)
      ..sort((eerste, tweede) => eerste.volgorde.compareTo(tweede.volgorde));

    final huidigeIndex = gesorteerdeMenus.indexWhere(
      (huidigMenu) => huidigMenu.id == menu.id,
    );

    if (huidigeIndex < 0) {
      return null;
    }

    final nieuweIndex = huidigeIndex + richting;

    if (nieuweIndex < 0 || nieuweIndex >= gesorteerdeMenus.length) {
      return null;
    }

    final verplaatstMenu = gesorteerdeMenus.removeAt(huidigeIndex);

    gesorteerdeMenus.insert(nieuweIndex, verplaatstMenu);

    final nieuweMenus = <OpmetingRaamKeuzeMenu>[];

    for (var index = 0; index < gesorteerdeMenus.length; index++) {
      nieuweMenus.add(gesorteerdeMenus[index].copyWith(volgorde: index));
    }

    return nieuweMenus;
  }

  static bool _isGeenItem(OpmetingRaamKeuzeMenuItem item) {
    if (item.isKeuze && item.optie?.isGeenKeuze == true) {
      return true;
    }

    return false;
  }

  static List<OpmetingRaamKeuzeMenuItem> _itemsVoorOpslagVanResultaat(
    OpmetingRaamTechnischMenuResultaat resultaat,
  ) {
    if (resultaat.items.isNotEmpty) {
      return List<OpmetingRaamKeuzeMenuItem>.unmodifiable(resultaat.items);
    }

    return _itemsVanSoorten(soorten: resultaat.soorten);
  }

  static List<OpmetingRaamKeuzeMenuItem> _itemsVanSoorten({
    required List<OpmetingRaamTechnischeSoortResultaat> soorten,
  }) {
    final items = <OpmetingRaamKeuzeMenuItem>[];

    for (final soort in soorten) {
      final optie = _optieVanSoort(soort);

      items.add(OpmetingRaamKeuzeMenuItem.keuze(optie: optie, actief: true));
    }

    return List<OpmetingRaamKeuzeMenuItem>.unmodifiable(items);
  }

  static List<OpmetingRaamKeuzeOptie> _optiesVanItems({
    required String menuId,
    required OpmetingRaamKeuzeOptie geenOptie,
    required List<OpmetingRaamKeuzeMenuItem> items,
  }) {
    final gebruikteIds = <String>{};

    final opties = <OpmetingRaamKeuzeOptie>[
      geenOptie.copyWith(
        id: '${menuId}_geen',
        naam: 'Geen',
        uitvoerTekst: '',
        isGeenKeuze: true,
        tekenfunctie: OpmetingRaamTekenfunctie.geen,
        extraVelden: const <OpmetingRaamExtraVeldDefinitie>[],
        technischeTekening: null,
        technischeTekeningen:
            const <OpmetingRaamTechnischeTekeningInstelling>[],
        nietCombineerbaarMet: const <OpmetingRaamNietCombineerbareKeuze>[],
        actief: true,
      ),
    ];

    gebruikteIds.add('${menuId}_geen');

    void verzamel(OpmetingRaamKeuzeMenuItem item) {
      if (item.isKeuze && item.optie != null && !item.optie!.isGeenKeuze) {
        if (gebruikteIds.add(item.optie!.id)) {
          opties.add(item.optie!);
        }
      }

      for (final kind in item.kinderen) {
        verzamel(kind);
      }
    }

    for (final item in items) {
      verzamel(item);
    }

    return List<OpmetingRaamKeuzeOptie>.unmodifiable(opties);
  }

  static List<OpmetingRaamTechnischeSoortResultaat> _soortenVanItems(
    List<OpmetingRaamKeuzeMenuItem> items,
  ) {
    final resultaten = <OpmetingRaamTechnischeSoortResultaat>[];

    void verzamel(OpmetingRaamKeuzeMenuItem item) {
      if (item.isKeuze && item.optie != null && !item.optie!.isGeenKeuze) {
        final optie = item.optie!;

        resultaten.add(
          OpmetingRaamTechnischeSoortResultaat(
            id: optie.id,
            naam: optie.naam,
            tekeningen: optie.alleTechnischeTekeningen,
            nietCombineerbaarMet: List<OpmetingRaamNietCombineerbareKeuze>.from(
              optie.nietCombineerbaarMet,
            ),
          ),
        );
      }

      for (final kind in item.kinderen) {
        verzamel(kind);
      }
    }

    for (final item in items) {
      verzamel(item);
    }

    return List<OpmetingRaamTechnischeSoortResultaat>.unmodifiable(resultaten);
  }

  static OpmetingRaamKeuzeOptie _optieVanSoort(
    OpmetingRaamTechnischeSoortResultaat soort,
  ) {
    return OpmetingRaamKeuzeOptie(
      id: soort.id,
      naam: soort.naam,
      uitvoerTekst: '',
      isGeenKeuze: false,
      tekenfunctie: OpmetingRaamTekenfunctie.geen,
      technischeTekeningen: soort.alleTekeningen,
      nietCombineerbaarMet:
          List<OpmetingRaamNietCombineerbareKeuze>.unmodifiable(
            soort.nietCombineerbaarMet,
          ),
      actief: true,
    );
  }
}
