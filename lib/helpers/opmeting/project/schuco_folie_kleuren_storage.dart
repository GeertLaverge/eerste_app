// THIMACO-CONTROLE: SCHUCO-FOLIEKLEUREN-STORAGE-MODEL-IMPORTFIX-20260808-1813

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'schuco_folie_kleur_model.dart';

class SchucoFolieKleurenStorage {
  const SchucoFolieKleurenStorage._();

  // Bewust een eigen sleutel: deze lijst wordt NIET opgeslagen tussen de
  // bestaande projectkleuren van AppStorage.
  static const String _key = 'thimaco_schuco_folie_kleuren_v1';

  static Future<List<SchucoFolieKleur>> laad() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonTekst = prefs.getString(_key);

    if (jsonTekst == null) {
      return SchucoFolieKleuren.standaardKopie();
    }

    try {
      final decoded = jsonDecode(jsonTekst);
      if (decoded is! List) {
        return SchucoFolieKleuren.standaardKopie();
      }

      final kleuren = decoded
          .whereType<Map>()
          .map(
            (item) =>
                SchucoFolieKleur.fromJson(Map<String, dynamic>.from(item)),
          )
          .where(
            (kleur) =>
                kleur.id.trim().isNotEmpty && kleur.naam.trim().isNotEmpty,
          )
          .toList(growable: true);

      // Een bewust leeg opgeslagen lijst blijft leeg. Alleen ontbrekende of
      // ongeldige opslag valt terug op de standaardlijst.
      return kleuren;
    } catch (_) {
      return SchucoFolieKleuren.standaardKopie();
    }
  }

  static Future<void> bewaar(List<SchucoFolieKleur> kleuren) async {
    final prefs = await SharedPreferences.getInstance();
    final unieke = <String, SchucoFolieKleur>{};

    for (final kleur in kleuren) {
      final id = kleur.id.trim();
      final naam = kleur.naam.trim();
      if (id.isEmpty || naam.isEmpty) continue;
      unieke[id] = kleur.copyWith(
        id: id,
        naam: naam,
        folieNummer: kleur.folieNummer.trim(),
        hex: _normaliseerHex(kleur.hex),
      );
    }

    await prefs.setString(
      _key,
      jsonEncode(unieke.values.map((kleur) => kleur.toJson()).toList()),
    );
  }

  static Future<List<SchucoFolieKleur>> herstelStandaard() async {
    final kleuren = SchucoFolieKleuren.standaardKopie();
    await bewaar(kleuren);
    return kleuren;
  }

  static String _normaliseerHex(String waarde) {
    var hex = waarde.trim().toUpperCase();
    if (hex.isEmpty) return '';
    if (!hex.startsWith('#')) hex = '#$hex';
    final geldig = RegExp(r'^#[0-9A-F]{6}$').hasMatch(hex);
    return geldig ? hex : '';
  }
}
