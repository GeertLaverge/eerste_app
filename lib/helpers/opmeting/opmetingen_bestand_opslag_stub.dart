import 'package:shared_preferences/shared_preferences.dart';

/// Browserstub: bestaande SharedPreferences-opslag blijft ongewijzigd.
class OpmetingenBestandOpslag {
  static bool get actief => false;
  static Future<void> migreer(SharedPreferences prefs, String key) async {}
  static Future<String?> lees() async => null;
  static Future<String?> versie() async => null;
  static Future<void> schrijf(String jsonTekst) async =>
      throw UnsupportedError('Alleen Windows');
}
