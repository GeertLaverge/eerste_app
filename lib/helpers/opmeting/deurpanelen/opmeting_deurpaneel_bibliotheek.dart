import 'package:flutter/foundation.dart';

import 'opmeting_deurpaneel_model.dart';
import 'opmeting_deurpaneel_storage_helper.dart';

class OpmetingDeurpaneelBibliotheek {
  OpmetingDeurpaneelBibliotheek._();

  static final ValueNotifier<List<OpmetingDeurpaneel>> panelen =
      ValueNotifier<List<OpmetingDeurpaneel>>(
        List<OpmetingDeurpaneel>.unmodifiable(_testPanelen),
      );

  static bool _geladen = false;
  static bool _ladenBezig = false;

  static List<OpmetingDeurpaneel> get huidigePanelen {
    return panelen.value;
  }

  static Future<void> laad() async {
    if (_geladen || _ladenBezig) {
      return;
    }

    _ladenBezig = true;

    try {
      final opgeslagenPanelen =
          await OpmetingDeurpaneelStorageHelper.laadPanelen();

      if (opgeslagenPanelen != null && opgeslagenPanelen.isNotEmpty) {
        panelen.value = List<OpmetingDeurpaneel>.unmodifiable(
          _sorteerPanelen(opgeslagenPanelen),
        );
      } else {
        panelen.value = List<OpmetingDeurpaneel>.unmodifiable(_testPanelen);
      }

      _geladen = true;
    } finally {
      _ladenBezig = false;
    }
  }

  static Future<void> vervangPanelen(
    List<OpmetingDeurpaneel> nieuwePanelen,
  ) async {
    final opgeschoondePanelen = _sorteerPanelen(
      nieuwePanelen
          .where((paneel) {
            return paneel.id.trim().isNotEmpty &&
                paneel.naam.trim().isNotEmpty &&
                paneel.tekeningBestandsnaam.trim().isNotEmpty;
          })
          .toList(growable: false),
    );

    panelen.value = List<OpmetingDeurpaneel>.unmodifiable(opgeschoondePanelen);
    _geladen = true;

    await OpmetingDeurpaneelStorageHelper.bewaarPanelen(opgeschoondePanelen);
  }

  static Future<void> resetNaarTestPanelen() async {
    panelen.value = List<OpmetingDeurpaneel>.unmodifiable(_testPanelen);
    _geladen = true;

    await OpmetingDeurpaneelStorageHelper.bewaarPanelen(_testPanelen);
  }

  static Future<void> wisselActief(String paneelId) async {
    final id = paneelId.trim();

    final nieuwePanelen = panelen.value
        .map((paneel) {
          if (paneel.id != id) {
            return paneel;
          }

          return paneel.copyWith(actief: !paneel.actief);
        })
        .toList(growable: false);

    panelen.value = List<OpmetingDeurpaneel>.unmodifiable(nieuwePanelen);
    _geladen = true;

    await OpmetingDeurpaneelStorageHelper.bewaarPanelen(nieuwePanelen);
  }

  static List<OpmetingDeurpaneel> _sorteerPanelen(
    List<OpmetingDeurpaneel> bron,
  ) {
    final perId = <String, OpmetingDeurpaneel>{};

    for (final paneel in bron) {
      final id = paneel.id.trim();

      if (id.isEmpty) {
        continue;
      }

      perId[id] = paneel.copyWith(
        id: id,
        naam: paneel.naam.trim(),
        tekeningBestandsnaam: paneel.tekeningBestandsnaam.trim(),
      );
    }

    final resultaat = perId.values.toList()
      ..sort((eerste, tweede) {
        return eerste.id.toLowerCase().compareTo(tweede.id.toLowerCase());
      });

    return resultaat;
  }

  static const List<OpmetingDeurpaneel> _testPanelen = <OpmetingDeurpaneel>[
    OpmetingDeurpaneel(
      id: 'MI251',
      naam: 'JEF',
      tekeningBestandsnaam: 'MI2510BN.dxf',
      nietVleugelOverdekkendToegelaten: false,
      vleugelOverdekkendToegelaten: true,
      cilinderZijde: OpmetingDeurpaneelCilinderZijde.rechts,
    ),
    OpmetingDeurpaneel(
      id: 'LD121',
      naam: 'HERMITAGE',
      tekeningBestandsnaam: 'LD1211AN.dxf',
      nietVleugelOverdekkendToegelaten: true,
      vleugelOverdekkendToegelaten: true,
    ),
    OpmetingDeurpaneel(
      id: 'VF011',
      naam: 'VEDUDO',
      tekeningBestandsnaam: 'VF0110BN.dxf',
      nietVleugelOverdekkendToegelaten: true,
      vleugelOverdekkendToegelaten: false,
    ),
  ];
}
