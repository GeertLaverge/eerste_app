import 'package:flutter/material.dart';

import 'opmeting_raam_keuzemenu_model.dart';

class OpmetingRaamKeuzeConflict {
  const OpmetingRaamKeuzeConflict({required this.menu, required this.optie});

  final OpmetingRaamKeuzeMenu menu;
  final OpmetingRaamKeuzeOptie optie;
}

class OpmetingRaamKeuzeConflictHelper {
  const OpmetingRaamKeuzeConflictHelper._();

  static List<OpmetingRaamKeuzeConflict> zoekConflicten({
    required List<OpmetingRaamKeuzeMenu> keuzemenus,
    required Map<String, OpmetingRaamKeuzeSelectie> keuzeSelecties,
    required OpmetingRaamKeuzeMenu gekozenMenu,
    required OpmetingRaamKeuzeOptie gekozenOptie,
  }) {
    final conflicten = <OpmetingRaamKeuzeConflict>[];
    final gebruikteSleutels = <String>{};

    for (final anderMenu in keuzemenus) {
      /*
       * Binnen hetzelfde menu kan slechts één optie
       * tegelijk geselecteerd zijn.
       */
      if (anderMenu.id == gekozenMenu.id) {
        continue;
      }

      if (!anderMenu.actief) {
        continue;
      }

      final andereOptie = _optieVoorSelectie(
        menu: anderMenu,
        keuzeSelecties: keuzeSelecties,
      );

      if (andereOptie.isGeenKeuze || !andereOptie.actief) {
        continue;
      }

      final gekozenSluitAndereUit = gekozenOptie.nietCombineerbaarMet.any((
        koppeling,
      ) {
        return koppeling.menuId == anderMenu.id &&
            koppeling.optieId == andereOptie.id;
      });

      final andereSluitGekozenUit = andereOptie.nietCombineerbaarMet.any((
        koppeling,
      ) {
        return koppeling.menuId == gekozenMenu.id &&
            koppeling.optieId == gekozenOptie.id;
      });

      /*
       * De controle werkt in beide richtingen.
       *
       * Het is dus voldoende dat de uitsluiting bij
       * één van beide keuzes werd ingesteld.
       */
      if (!gekozenSluitAndereUit && !andereSluitGekozenUit) {
        continue;
      }

      final conflictSleutel = '${anderMenu.id}::${andereOptie.id}';

      if (!gebruikteSleutels.add(conflictSleutel)) {
        continue;
      }

      conflicten.add(
        OpmetingRaamKeuzeConflict(menu: anderMenu, optie: andereOptie),
      );
    }

    return List<OpmetingRaamKeuzeConflict>.unmodifiable(conflicten);
  }

  static Future<void> toonWaarschuwing({
    required BuildContext context,
    required OpmetingRaamKeuzeMenu gekozenMenu,
    required OpmetingRaamKeuzeOptie gekozenOptie,
    required List<OpmetingRaamKeuzeConflict> conflicten,
  }) async {
    if (conflicten.isEmpty) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFD97706),
            size: 34,
          ),
          title: const Text('Keuzes niet combineerbaar'),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'De keuze '
                  '“${gekozenMenu.titel} → '
                  '${gekozenOptie.naam}” '
                  'kan niet gecombineerd worden met:',
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFCD34D)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: conflicten.map((conflict) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2, right: 7),
                              child: Text(
                                '•',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${conflict.menu.titel} '
                                '→ '
                                '${conflict.optie.naam}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Beide keuzes blijven geselecteerd. '
                  'Pas één van de keuzes handmatig aan '
                  'wanneer deze combinatie niet gewenst is.',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0B7A3B),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static OpmetingRaamKeuzeOptie _optieVoorSelectie({
    required OpmetingRaamKeuzeMenu menu,
    required Map<String, OpmetingRaamKeuzeSelectie> keuzeSelecties,
  }) {
    final selectie = keuzeSelecties[menu.id];

    if (selectie != null) {
      for (final optie in menu.opties) {
        if (optie.id == selectie.optieId) {
          return optie;
        }
      }
    }

    return menu.geenOptie;
  }
}
