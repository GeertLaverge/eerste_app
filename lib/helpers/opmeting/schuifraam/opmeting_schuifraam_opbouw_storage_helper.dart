import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'opmeting_schuifraam_model.dart';

class OpmetingSchuifraamOpbouwStorageHelper {
  const OpmetingSchuifraamOpbouwStorageHelper._();

  static const String _sleutel = 'opmeting_schuifraam_opbouw_types';

  static Future<List<OpmetingSchuifraamOpbouwType>> laad() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonTekst = prefs.getString(_sleutel);

    if (jsonTekst == null || jsonTekst.trim().isEmpty) {
      return const <OpmetingSchuifraamOpbouwType>[];
    }

    try {
      final decoded = jsonDecode(jsonTekst);

      if (decoded is! List) {
        return const <OpmetingSchuifraamOpbouwType>[];
      }

      final resultaat = <OpmetingSchuifraamOpbouwType>[];
      final gebruikteOpbouwen = <String>{};

      for (final item in decoded) {
        if (item is! Map) {
          continue;
        }

        final opbouw = OpmetingSchuifraamOpbouwType.fromJson(
          Map<String, dynamic>.from(item),
        );

        if (!opbouw.isGeldig || !gebruikteOpbouwen.add(opbouw.opslagSleutel)) {
          continue;
        }

        resultaat.add(opbouw);
      }

      return List<OpmetingSchuifraamOpbouwType>.unmodifiable(resultaat);
    } catch (_) {
      return const <OpmetingSchuifraamOpbouwType>[];
    }
  }

  static Future<void> bewaar(
    List<OpmetingSchuifraamOpbouwType> opbouwen,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final geldigeOpbouwen = <OpmetingSchuifraamOpbouwType>[];
    final gebruikteOpbouwen = <String>{};

    for (final opbouw in opbouwen) {
      if (!opbouw.isGeldig || !gebruikteOpbouwen.add(opbouw.opslagSleutel)) {
        continue;
      }

      geldigeOpbouwen.add(opbouw);
    }

    await prefs.setString(
      _sleutel,
      jsonEncode(geldigeOpbouwen.map((opbouw) => opbouw.toJson()).toList()),
    );
  }
}
