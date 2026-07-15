import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class OpmetingDeurpaneelDxfStorageHelper {
  const OpmetingDeurpaneelDxfStorageHelper._();

  static const String opslagSleutel = 'thimaco_deurpanelen_dxf_bibliotheek';

  static Future<Map<String, String>?> laadDxfs() async {
    final prefs = await SharedPreferences.getInstance();
    final tekst = prefs.getString(opslagSleutel);

    if (tekst == null || tekst.trim().isEmpty) {
      return null;
    }

    final decoded = jsonDecode(tekst);

    if (decoded is! Map) {
      return null;
    }

    final resultaat = <String, String>{};

    decoded.forEach((key, value) {
      final bestandsnaam = key.toString().trim().toLowerCase();
      final inhoud = value?.toString() ?? '';

      if (bestandsnaam.isEmpty || inhoud.trim().isEmpty) {
        return;
      }

      resultaat[bestandsnaam] = inhoud;
    });

    return resultaat;
  }

  static Future<void> bewaarDxfs(Map<String, String> dxfs) async {
    final prefs = await SharedPreferences.getInstance();
    final opgeschoond = <String, String>{};

    dxfs.forEach((key, value) {
      final bestandsnaam = key.trim().toLowerCase();
      final inhoud = value;

      if (bestandsnaam.isEmpty || inhoud.trim().isEmpty) {
        return;
      }

      opgeschoond[bestandsnaam] = inhoud;
    });

    await prefs.setString(opslagSleutel, jsonEncode(opgeschoond));
  }

  static Future<void> wisDxfs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(opslagSleutel);
  }
}
