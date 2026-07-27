// THIMACO-CONTROLE: ONTBREKENDE-TITELS-ANDERE-ARTIKELTYPES-FASE-4-20260727
// THIMACO-CONTROLE: COMPACTE-BOOM-KOPIEREN-VANUIT-BOOM-FASE-3-20260727
// THIMACO-CONTROLE: COMPACTE-BOOM-AANMAKEN-VANUIT-BOOM-FASE-2-20260727
// THIMACO-CONTROLE: OPLAADBARE-KEUZES-PER-ARTIKELTYPE-ZICHTBAAR-20260727
// THIMACO-CONTROLE: MENU-BEHEER-BEWAART-HOE-UITSCHRIJVEN-20260720
import 'package:flutter/material.dart';

import '../../app_storage.dart';
import 'opmeting_raam_keuze_menu_helper.dart';
import 'opmeting_raam_keuzemenu_model.dart';
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
    final oplaadbareKeuzes = await _laadOplaadbareKeuzes(
      huidigeMenus: keuzemenus,
    );

    if (!context.mounted) {
      return null;
    }

    final resultaat = await toonOpmetingRaamTechnischMenuDialoog(
      context: context,
      beschikbareNietCombineerbareKeuzes: beschikbareKeuzes,
      oplaadbareKeuzes: oplaadbareKeuzes,
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

  static Future<List<OpmetingRaamKeuzeMenu>?> laadOntbrekendeTitel({
    required BuildContext context,
    required String huidigFormulierType,
    required List<OpmetingRaamKeuzeMenu> keuzemenus,
  }) async {
    final kandidaten = await _laadOntbrekendeTitelKandidaten(
      huidigFormulierType: huidigFormulierType,
      huidigeMenus: keuzemenus,
    );

    if (!context.mounted) {
      return null;
    }

    if (kandidaten.isEmpty) {
      await _toonGeenOntbrekendeTitelsDialoog(context);
      return null;
    }

    final gekozen = await showDialog<_OpmetingRaamOntbrekendeTitelKandidaat>(
      context: context,
      builder: (dialogContext) {
        const groen = Color(0xFF0B7A3B);
        const lichtGroen = Color(0xFFE7F6EC);

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
                  Icon(Icons.file_download_outlined, color: groen, size: 21),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Titel opladen',
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
            content: SizedBox(
              width: 540,
              height: 420,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Alleen titels uit andere artikeltypes die hier nog niet '
                    'bestaan worden getoond. Submenu- en keuze-ID’s blijven '
                    'bij het opladen behouden.',
                    style: TextStyle(fontSize: 12.5, height: 1.35),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: kandidaten.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final kandidaat = kandidaten[index];

                        return ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          leading: const Icon(
                            Icons.account_tree_outlined,
                            color: groen,
                          ),
                          title: Text(
                            kandidaat.menu.titel.trim(),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(kandidaat.formulierNaam),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.pop(dialogContext, kandidaat);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Annuleren'),
              ),
            ],
          ),
        );
      },
    );

    if (!context.mounted || gekozen == null) {
      return null;
    }

    final titelSleutel = _normaliseerTitel(gekozen.menu.titel);
    final titelBestaatAl = keuzemenus.any((menu) {
      return _normaliseerTitel(menu.titel) == titelSleutel;
    });

    if (titelBestaatAl) {
      await _toonTitelBestaatAlDialoog(
        context: context,
        titel: gekozen.menu.titel,
      );
      return null;
    }

    final bronItems = gekozen.menu.boomItems
        .where((item) => !_isGeenItem(item))
        .map(_kopieerOplaadItemMetBestaandeIds)
        .toList();

    if (bronItems.isEmpty) {
      await _toonLegeTitelDialoog(context: context, titel: gekozen.menu.titel);
      return null;
    }

    final hoogsteVolgorde = keuzemenus.isEmpty
        ? -1
        : keuzemenus
              .map((menu) => menu.volgorde)
              .reduce((eerste, tweede) => eerste > tweede ? eerste : tweede);
    final nieuwMenuId = _maakUniekMenuId(keuzemenus);
    final basisMenu = OpmetingRaamKeuzeMenu.nieuw(
      id: nieuwMenuId,
      titel: gekozen.menu.titel.trim(),
      volgorde: hoogsteVolgorde + 1,
    );
    final nieuweOpties = _optiesVanItems(
      menuId: nieuwMenuId,
      geenOptie: basisMenu.geenOptie,
      items: bronItems,
    );
    final opgeladenMenu = basisMenu.copyWith(
      actief: gekozen.menu.actief,
      opties: nieuweOpties,
      items: List<OpmetingRaamKeuzeMenuItem>.unmodifiable(bronItems),
    );

    return <OpmetingRaamKeuzeMenu>[...keuzemenus, opgeladenMenu];
  }

  static Future<List<OpmetingRaamKeuzeMenu>?> kopieerMenu({
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
        );
    final oplaadbareKeuzes = await _laadOplaadbareKeuzes(
      huidigeMenus: keuzemenus,
    );

    if (!context.mounted) {
      return null;
    }

    final resultaat = await toonOpmetingRaamTechnischMenuDialoog(
      context: context,
      bestaandMenu: OpmetingRaamTechnischMenuResultaat(
        titel: menu.titel,
        soorten: _soortenVanItems(bestaandeItems),
        items: bestaandeItems,
        actief: menu.actief,
      ),
      beschikbareNietCombineerbareKeuzes: beschikbareKeuzes,
      oplaadbareKeuzes: oplaadbareKeuzes,
      kopieerAlsNieuw: true,
    );

    if (resultaat == null) {
      return null;
    }

    final gesorteerdeMenus = List<OpmetingRaamKeuzeMenu>.from(keuzemenus)
      ..sort((eerste, tweede) => eerste.volgorde.compareTo(tweede.volgorde));
    final bronIndex = gesorteerdeMenus.indexWhere(
      (bestaandMenu) => bestaandMenu.id == menu.id,
    );
    final invoegIndex = bronIndex < 0 ? gesorteerdeMenus.length : bronIndex + 1;
    final nieuwMenuId = 'menu_${DateTime.now().microsecondsSinceEpoch}';
    final basisMenu = OpmetingRaamKeuzeMenu.nieuw(
      id: nieuwMenuId,
      titel: resultaat.titel,
      volgorde: invoegIndex,
    );
    final nieuweItems = _itemsVoorOpslagVanResultaat(resultaat);
    final nieuweOpties = _optiesVanItems(
      menuId: nieuwMenuId,
      geenOptie: basisMenu.geenOptie,
      items: nieuweItems,
    );
    final gekopieerdMenu = basisMenu.copyWith(
      actief: resultaat.actief,
      opties: nieuweOpties,
      items: nieuweItems,
    );

    gesorteerdeMenus.insert(invoegIndex, gekopieerdMenu);

    return List<OpmetingRaamKeuzeMenu>.generate(
      gesorteerdeMenus.length,
      (index) => gesorteerdeMenus[index].copyWith(volgorde: index),
    );
  }

  static Future<List<OpmetingRaamKeuzeMenu>?> bewerkTechnischMenu({
    required BuildContext context,
    required List<OpmetingRaamKeuzeMenu> keuzemenus,
    required OpmetingRaamKeuzeMenu menu,
    OpmetingRaamTechnischMenuBeginToevoeging? beginToevoeging,
  }) async {
    final bestaandeItems = menu.boomItems.where((item) {
      return !_isGeenItem(item);
    }).toList();

    final beschikbareKeuzes =
        OpmetingRaamKeuzeMenuHelper.beschikbareNietCombineerbareKeuzes(
          keuzemenus: keuzemenus,
          uitTeSluitenMenuId: menu.id,
        );
    final oplaadbareKeuzes = await _laadOplaadbareKeuzes(
      huidigeMenus: keuzemenus,
      uitTeSluitenMenuId: menu.id,
    );

    if (!context.mounted) {
      return null;
    }

    final resultaat = await toonOpmetingRaamTechnischMenuDialoog(
      context: context,
      bestaandMenu: OpmetingRaamTechnischMenuResultaat(
        titel: menu.titel,
        soorten: _soortenVanItems(bestaandeItems),
        items: bestaandeItems,
        actief: menu.actief,
      ),
      beschikbareNietCombineerbareKeuzes: beschikbareKeuzes,
      oplaadbareKeuzes: oplaadbareKeuzes,
      beginToevoeging: beginToevoeging,
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

  static Future<List<OpmetingRaamKeuzeMenu>?> voegKeuzeToeAanMenu({
    required BuildContext context,
    required List<OpmetingRaamKeuzeMenu> keuzemenus,
    required OpmetingRaamKeuzeMenu menu,
    String? ouderSubmenuId,
  }) {
    return bewerkTechnischMenu(
      context: context,
      keuzemenus: keuzemenus,
      menu: menu,
      beginToevoeging: OpmetingRaamTechnischMenuBeginToevoeging(
        actie: OpmetingRaamTechnischMenuBeginActie.nieuweKeuze,
        ouderSubmenuId: ouderSubmenuId,
      ),
    );
  }

  static Future<List<OpmetingRaamKeuzeMenu>?> voegSubmenuToeAanMenu({
    required BuildContext context,
    required List<OpmetingRaamKeuzeMenu> keuzemenus,
    required OpmetingRaamKeuzeMenu menu,
    String? ouderSubmenuId,
  }) {
    return bewerkTechnischMenu(
      context: context,
      keuzemenus: keuzemenus,
      menu: menu,
      beginToevoeging: OpmetingRaamTechnischMenuBeginToevoeging(
        actie: OpmetingRaamTechnischMenuBeginActie.nieuwSubmenu,
        ouderSubmenuId: ouderSubmenuId,
      ),
    );
  }

  static Future<List<OpmetingRaamKeuzeMenu>?> kopieerItemInMenu({
    required BuildContext context,
    required List<OpmetingRaamKeuzeMenu> keuzemenus,
    required OpmetingRaamKeuzeMenu menu,
    required OpmetingRaamKeuzeMenuItem item,
  }) {
    return bewerkTechnischMenu(
      context: context,
      keuzemenus: keuzemenus,
      menu: menu,
      beginToevoeging: OpmetingRaamTechnischMenuBeginToevoeging(
        actie: OpmetingRaamTechnischMenuBeginActie.kopieerItem,
        bronItemId: item.id,
      ),
    );
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

  static Future<List<_OpmetingRaamOntbrekendeTitelKandidaat>>
  _laadOntbrekendeTitelKandidaten({
    required String huidigFormulierType,
    required List<OpmetingRaamKeuzeMenu> huidigeMenus,
  }) async {
    final huidigeTitelSleutels = huidigeMenus
        .map((menu) => _normaliseerTitel(menu.titel))
        .where((sleutel) => sleutel.isNotEmpty)
        .toSet();
    final huidigTypeSleutel = _normaliseerFormulierType(huidigFormulierType);
    final kandidaten = <_OpmetingRaamOntbrekendeTitelKandidaat>[];
    final gebruikteBronnen = <String>{};

    for (final formulier in _ondersteundeFormulieren.entries) {
      if (_normaliseerFormulierType(formulier.key) == huidigTypeSleutel) {
        continue;
      }

      try {
        final menus = await AppStorage.laadOpmetingRaamKeuzemenusVoorFormulier(
          formulier.key,
        );

        for (final menu in menus) {
          final titelSleutel = _normaliseerTitel(menu.titel);

          if (titelSleutel.isEmpty ||
              huidigeTitelSleutels.contains(titelSleutel)) {
            continue;
          }

          final items = menu.boomItems.where((item) {
            return !_isGeenItem(item);
          }).toList();

          if (items.isEmpty) {
            continue;
          }

          final bronSleutel = <String>[
            _normaliseerFormulierType(formulier.key),
            menu.id.trim(),
            titelSleutel,
          ].join('|');

          if (!gebruikteBronnen.add(bronSleutel)) {
            continue;
          }

          kandidaten.add(
            _OpmetingRaamOntbrekendeTitelKandidaat(
              formulierNaam: formulier.value,
              menu: menu,
            ),
          );
        }
      } catch (_) {
        // Als één artikeltype niet geladen kan worden, blijven de andere
        // artikeltypes beschikbaar.
      }
    }

    kandidaten.sort((eerste, tweede) {
      final titelVergelijking = eerste.menu.titel
          .trim()
          .toLowerCase()
          .compareTo(tweede.menu.titel.trim().toLowerCase());

      if (titelVergelijking != 0) {
        return titelVergelijking;
      }

      return eerste.formulierNaam.toLowerCase().compareTo(
        tweede.formulierNaam.toLowerCase(),
      );
    });

    return List<_OpmetingRaamOntbrekendeTitelKandidaat>.unmodifiable(
      kandidaten,
    );
  }

  static OpmetingRaamKeuzeMenuItem _kopieerOplaadItemMetBestaandeIds(
    OpmetingRaamKeuzeMenuItem item,
  ) {
    if (item.isSubmenu) {
      return item.copyWith(
        kinderen: item.kinderen
            .where((kind) => !_isGeenItem(kind))
            .map(_kopieerOplaadItemMetBestaandeIds)
            .toList(),
      );
    }

    final optie = item.optie;

    if (optie == null) {
      return item;
    }

    return item.copyWith(
      optie: optie.copyWith(
        nietCombineerbaarMet: const <OpmetingRaamNietCombineerbareKeuze>[],
      ),
    );
  }

  static String _maakUniekMenuId(List<OpmetingRaamKeuzeMenu> menus) {
    final gebruikteIds = menus.map((menu) => menu.id).toSet();
    var teller = 0;

    while (true) {
      teller++;
      final kandidaat = 'menu_${DateTime.now().microsecondsSinceEpoch}_$teller';

      if (!gebruikteIds.contains(kandidaat)) {
        return kandidaat;
      }
    }
  }

  static Future<void> _toonGeenOntbrekendeTitelsDialoog(
    BuildContext context,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Text(
            'Geen ontbrekende titels',
            style: TextStyle(
              color: Color(0xFF0B7A3B),
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'Alle beschikbare titels uit de andere artikeltypes zijn hier '
            'al aanwezig, of bevatten nog geen bruikbare keuzes.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Sluiten'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _toonTitelBestaatAlDialoog({
    required BuildContext context,
    required String titel,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Text(
            'Titel bestaat al',
            style: TextStyle(
              color: Color(0xFF0B7A3B),
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            'De titel “${titel.trim()}” is ondertussen al aanwezig en werd '
            'daarom niet opnieuw opgeladen.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Sluiten'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _toonLegeTitelDialoog({
    required BuildContext context,
    required String titel,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Text(
            'Titel niet opgeladen',
            style: TextStyle(
              color: Color(0xFF0B7A3B),
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            'De titel “${titel.trim()}” bevat geen bruikbare keuzes.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Sluiten'),
            ),
          ],
        );
      },
    );
  }

  static const Map<String, String> _ondersteundeFormulieren = <String, String>{
    'pvcRaam': 'PVC raam',
    'aluRaam': 'ALU raam',
    'pvcSchuifraam': 'PVC schuifraam',
    'aluSchuifraam': 'ALU schuifraam',
    'pvcDeur': 'PVC deur',
    'aluDeur': 'ALU deur',
  };

  static String _normaliseerTitel(String waarde) {
    return waarde.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String _normaliseerFormulierType(String waarde) {
    return waarde.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  static Future<List<OpmetingRaamTechnischeOplaadbareKeuze>>
  _laadOplaadbareKeuzes({
    required List<OpmetingRaamKeuzeMenu> huidigeMenus,
    String? uitTeSluitenMenuId,
  }) async {
    final resultaat = <OpmetingRaamTechnischeOplaadbareKeuze>[];
    final gebruikteSleutels = <String>{};
    final huidigeMenuIds = huidigeMenus
        .map((menu) => menu.id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();

    void verzamelMenus({
      required String bronFormulierType,
      required String formulierNaam,
      required List<OpmetingRaamKeuzeMenu> menus,
      bool pasUitsluitingToe = false,
      bool slaHuidigeMenuIdsOver = false,
    }) {
      for (final menu in menus) {
        final menuId = menu.id.trim();

        if (pasUitsluitingToe && menuId == uitTeSluitenMenuId) {
          continue;
        }

        // De huidige fiche wordt bovenaan apart toegevoegd. Wanneer daarna de
        // centrale opslag van hetzelfde artikeltype wordt gelezen, mag exact
        // hetzelfde menu niet nogmaals in de laadlijst verschijnen.
        if (slaHuidigeMenuIdsOver && huidigeMenuIds.contains(menuId)) {
          continue;
        }

        final menuTitel = menu.titel.trim();

        if (menuId.isEmpty || menuTitel.isEmpty) {
          continue;
        }

        final items = menu.boomItems.where((item) {
          return !_isGeenItem(item);
        }).toList();

        if (items.isEmpty) {
          continue;
        }

        // Niet alleen de titel gebruiken: dezelfde technische keuze mag in
        // meerdere artikeltypes bestaan en moet dan per artikeltype zichtbaar
        // blijven. Het formuliertype en menu-id vormen samen de stabiele bron.
        final sleutel = _oplaadbareKeuzeSleutel(
          bronFormulierType: bronFormulierType,
          menuId: menuId,
        );

        if (!gebruikteSleutels.add(sleutel)) {
          continue;
        }

        resultaat.add(
          OpmetingRaamTechnischeOplaadbareKeuze(
            id: sleutel,
            formulierNaam: formulierNaam,
            titel: menuTitel,
            items: List<OpmetingRaamKeuzeMenuItem>.unmodifiable(items),
          ),
        );
      }
    }

    verzamelMenus(
      bronFormulierType: 'huidigeFiche',
      formulierNaam: 'Huidige fiche',
      menus: huidigeMenus,
      pasUitsluitingToe: true,
    );

    for (final formulier in _ondersteundeFormulieren.entries) {
      try {
        final menus = await AppStorage.laadOpmetingRaamKeuzemenusVoorFormulier(
          formulier.key,
        );

        verzamelMenus(
          bronFormulierType: formulier.key,
          formulierNaam: formulier.value,
          menus: menus,
          slaHuidigeMenuIdsOver: true,
        );
      } catch (_) {
        // Als één fiche niet geladen kan worden, blijven de andere keuzes bruikbaar.
      }
    }

    resultaat.sort((eerste, tweede) {
      final titelVergelijking = eerste.titel.toLowerCase().compareTo(
        tweede.titel.toLowerCase(),
      );

      if (titelVergelijking != 0) {
        return titelVergelijking;
      }

      final formulierVergelijking = eerste.formulierNaam
          .toLowerCase()
          .compareTo(tweede.formulierNaam.toLowerCase());

      if (formulierVergelijking != 0) {
        return formulierVergelijking;
      }

      return eerste.id.compareTo(tweede.id);
    });

    return List<OpmetingRaamTechnischeOplaadbareKeuze>.unmodifiable(resultaat);
  }

  static String _oplaadbareKeuzeSleutel({
    required String bronFormulierType,
    required String menuId,
  }) {
    return <String>[
      _normaliseerOplaadbareKeuzeSleutel(bronFormulierType),
      menuId.trim(),
    ].join('|');
  }

  static String _normaliseerOplaadbareKeuzeSleutel(String waarde) {
    return waarde.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
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
            hoeUitschrijven: optie.hoeUitschrijven,
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
      uitvoerTekst: soort.effectieveUitschrijftekst,
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

class _OpmetingRaamOntbrekendeTitelKandidaat {
  const _OpmetingRaamOntbrekendeTitelKandidaat({
    required this.formulierNaam,
    required this.menu,
  });

  final String formulierNaam;
  final OpmetingRaamKeuzeMenu menu;
}
