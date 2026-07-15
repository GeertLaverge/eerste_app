import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart' show rootBundle;

class OpmetingDeurpaneelDxfTestBestanden {
  const OpmetingDeurpaneelDxfTestBestanden._();

  static const Map<String, String> assetPaden = <String, String>{
    'mi2510bn.dxf': 'assets/deurpanelen/dxf/MI2510BN.dxf',
    'ld1211an.dxf': 'assets/deurpanelen/dxf/LD1211AN.dxf',
    'vf0110bn.dxf': 'assets/deurpanelen/dxf/VF0110BN.dxf',
  };

  static const Map<String, String> aliassen = <String, String>{
    'ld121an.dxf': 'ld1211an.dxf',
  };

  static List<String> get bestandsnamen {
    final lijst = assetPaden.keys.toList()..sort();
    return List<String>.unmodifiable(lijst);
  }

  static Future<Map<String, String>> laadAlle() async {
    final resultaat = <String, String>{};

    for (final entry in assetPaden.entries) {
      try {
        final inhoud = await rootBundle.loadString(entry.value);

        if (inhoud.trim().isEmpty) {
          continue;
        }

        resultaat[entry.key] = inhoud.trimRight();
      } on FlutterError {
        /*
         * Asset staat nog niet in pubspec.yaml of bestand ontbreekt.
         * Niet crashen: beheerpagina blijft bruikbaar voor manueel DXF plakken.
         */
      } catch (_) {
        /*
         * Zelfde doel: de app mag niet blokkeren door één ontbrekend testbestand.
         */
      }
    }

    return resultaat;
  }

  static String? aliasVoorBestandsnaam(String bestandsnaam) {
    final sleutel = normaliseerBestandsnaam(bestandsnaam);

    return aliassen[sleutel];
  }

  static String normaliseerBestandsnaam(String bestandsnaam) {
    var resultaat = bestandsnaam.trim().replaceAll('\\', '/');

    if (resultaat.contains('/')) {
      resultaat = resultaat.split('/').last;
    }

    return resultaat.toLowerCase();
  }
}
