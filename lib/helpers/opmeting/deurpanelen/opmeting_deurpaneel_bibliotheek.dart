// THIMACO-CONTROLE: FRAGER-DEURPANELEN-BIBLIOTHEEK-20260816
import 'package:flutter/foundation.dart';

import 'opmeting_deurpaneel_frager_lijst.dart';
import 'opmeting_deurpaneel_model.dart';
import 'opmeting_deurpaneel_storage_helper.dart' as deurpaneel_storage;

class OpmetingDeurpaneelBibliotheek {
  OpmetingDeurpaneelBibliotheek._();

  static final ValueNotifier<List<OpmetingDeurpaneel>> panelen =
      ValueNotifier<List<OpmetingDeurpaneel>>(
        List<OpmetingDeurpaneel>.unmodifiable(
          OpmetingDeurpaneelFragerLijst.panelen,
        ),
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
      final opgeslagenPanelen = await deurpaneel_storage
          .OpmetingDeurpaneelStorageHelper.laadPanelen();

      // De drie oude testpanelen waren enkel tijdelijk voor de opbouw van
      // deurpanelen/DXF. Zodra die oude testset nog in opslag staat, vervangen
      // we ze automatisch éénmalig door de volledige Frager-lijst.
      final gebruikFragerLijst =
          opgeslagenPanelen == null || _isOudeTestlijst(opgeslagenPanelen);

      if (gebruikFragerLijst) {
        final fragerPanelen = _sorteerPanelen(
          OpmetingDeurpaneelFragerLijst.panelen,
        );

        panelen.value = List<OpmetingDeurpaneel>.unmodifiable(fragerPanelen);
        _geladen = true;

        await deurpaneel_storage.OpmetingDeurpaneelStorageHelper.bewaarPanelen(
          fragerPanelen,
        );
      } else {
        panelen.value = List<OpmetingDeurpaneel>.unmodifiable(
          _sorteerPanelen(opgeslagenPanelen),
        );
        _geladen = true;
      }
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

    await deurpaneel_storage.OpmetingDeurpaneelStorageHelper.bewaarPanelen(
      opgeschoondePanelen,
    );
  }

  static Future<void> resetNaarFragerLijst() async {
    final fragerPanelen = _sorteerPanelen(
      OpmetingDeurpaneelFragerLijst.panelen,
    );

    panelen.value = List<OpmetingDeurpaneel>.unmodifiable(fragerPanelen);
    _geladen = true;

    await deurpaneel_storage.OpmetingDeurpaneelStorageHelper.bewaarPanelen(
      fragerPanelen,
    );
  }

  // Tijdelijk behouden voor eventuele oudere aanroepen.
  static Future<void> resetNaarTestPanelen() {
    return resetNaarFragerLijst();
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

    await deurpaneel_storage.OpmetingDeurpaneelStorageHelper.bewaarPanelen(
      nieuwePanelen,
    );
  }

  static bool _isOudeTestlijst(List<OpmetingDeurpaneel> bron) {
    if (bron.length != 3) {
      return false;
    }

    final perId = <String, OpmetingDeurpaneel>{
      for (final paneel in bron) paneel.id.trim().toUpperCase(): paneel,
    };

    return perId['MI251']?.tekeningBestandsnaam.trim().toLowerCase() ==
            'mi2510bn.dxf' &&
        perId['LD121']?.tekeningBestandsnaam.trim().toLowerCase() ==
            'ld1211an.dxf' &&
        perId['VF011']?.tekeningBestandsnaam.trim().toLowerCase() ==
            'vf0110bn.dxf';
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
}
