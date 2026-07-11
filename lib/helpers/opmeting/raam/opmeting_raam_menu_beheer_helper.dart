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
    if (menuBeheerOntgrendeld) {
      return false;
    }

    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Menu-beheer openen?'),
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
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              icon: const Icon(Icons.lock_open),
              label: const Text('Ontgrendelen'),
            ),
          ],
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

    final nieuweOpties = <OpmetingRaamKeuzeOptie>[basisMenu.geenOptie];

    for (final soort in resultaat.soorten) {
      nieuweOpties.add(
        OpmetingRaamKeuzeOptie(
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
        ),
      );
    }

    final nieuwMenu = basisMenu.copyWith(
      actief: resultaat.actief,
      opties: nieuweOpties,
    );

    return <OpmetingRaamKeuzeMenu>[...keuzemenus, nieuwMenu];
  }

  static Future<List<OpmetingRaamKeuzeMenu>?> bewerkTechnischMenu({
    required BuildContext context,
    required List<OpmetingRaamKeuzeMenu> keuzemenus,
    required OpmetingRaamKeuzeMenu menu,
  }) async {
    final bestaandeSoorten = menu.opties
        .where((optie) => !optie.isGeenKeuze)
        .map(
          (optie) => OpmetingRaamTechnischeSoortResultaat(
            id: optie.id,
            naam: optie.naam,
            tekeningen: optie.alleTechnischeTekeningen,
            nietCombineerbaarMet: List<OpmetingRaamNietCombineerbareKeuze>.from(
              optie.nietCombineerbaarMet,
            ),
          ),
        )
        .toList();

    final beschikbareKeuzes =
        OpmetingRaamKeuzeMenuHelper.beschikbareNietCombineerbareKeuzes(
          keuzemenus: keuzemenus,
          uitTeSluitenMenuId: menu.id,
        );

    final resultaat = await toonOpmetingRaamTechnischMenuDialoog(
      context: context,
      bestaandMenu: OpmetingRaamTechnischMenuResultaat(
        titel: menu.titel,
        soorten: bestaandeSoorten,
        actief: menu.actief,
      ),
      beschikbareNietCombineerbareKeuzes: beschikbareKeuzes,
    );

    if (resultaat == null) {
      return null;
    }

    final nieuweOpties = <OpmetingRaamKeuzeOptie>[menu.geenOptie];

    for (final soort in resultaat.soorten) {
      nieuweOpties.add(
        OpmetingRaamKeuzeOptie(
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
        ),
      );
    }

    return keuzemenus.map((huidigMenu) {
      if (huidigMenu.id != menu.id) {
        return huidigMenu;
      }

      return huidigMenu.copyWith(
        titel: resultaat.titel,
        actief: resultaat.actief,
        opties: nieuweOpties,
      );
    }).toList();
  }

  static Future<List<OpmetingRaamKeuzeMenu>?> verwijderMenu({
    required BuildContext context,
    required List<OpmetingRaamKeuzeMenu> keuzemenus,
    required OpmetingRaamKeuzeMenu menu,
  }) async {
    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Menu verwijderen?'),
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
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Verwijderen'),
            ),
          ],
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
}
