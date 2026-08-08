// THIMACO-CONTROLE: ALIPLAST-STANDAARD-RAL-APARTE-OPSLAG-20260808-1902

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'opmeting_project_kleur_model.dart';

class AliplastStandaardRalKleurenStorage {
  const AliplastStandaardRalKleurenStorage._();

  static const String submenuId = 'thimaco_aliplast_standaard_ral_kleuren';
  static const String submenuNaam = 'Aliplast standaard RAL kleuren';

  // Bewust eigen opslag. Deze lijst wordt niet toegevoegd aan de bestaande
  // projectkleurenopslag en kan later onafhankelijk worden uitgebreid.
  static const String _key = 'thimaco_aliplast_standaard_ral_kleuren_v1';

  static Future<List<OpmetingProjectKleur>> laad() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonTekst = prefs.getString(_key);

    if (jsonTekst == null || jsonTekst.trim().isEmpty) {
      return <OpmetingProjectKleur>[];
    }

    try {
      final decoded = jsonDecode(jsonTekst);
      if (decoded is! List) {
        return <OpmetingProjectKleur>[];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) =>
                OpmetingProjectKleur.fromJson(Map<String, dynamic>.from(item)),
          )
          .where(
            (kleur) =>
                kleur.id.trim().isNotEmpty && kleur.naam.trim().isNotEmpty,
          )
          .toList(growable: true);
    } catch (_) {
      return <OpmetingProjectKleur>[];
    }
  }

  static Future<void> bewaar(List<OpmetingProjectKleur> kleuren) async {
    final prefs = await SharedPreferences.getInstance();
    final unieke = <String, OpmetingProjectKleur>{};

    for (final kleur in kleuren) {
      final id = kleur.id.trim();
      final naam = kleur.naam.trim();
      if (id.isEmpty || naam.isEmpty) continue;
      unieke[id] = kleur.copyWith(id: id, naam: naam);
    }

    await prefs.setString(
      _key,
      jsonEncode(unieke.values.map((kleur) => kleur.toJson()).toList()),
    );
  }
}
