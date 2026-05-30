import 'package:flutter/services.dart';

class PostcodeHelper {
  static final List<Map<String, String>> _gegevens = [];

  static Future<void> initialiseren() async {
    if (_gegevens.isNotEmpty) return;

    final csv = await rootBundle.loadString(
      'assets/data/zipcodes_num_nl_2025 (1).csv',
    );

    final regels = csv.split('\n');

    for (int i = 1; i < regels.length; i++) {
      final regel = regels[i].trim();
      if (regel.isEmpty) continue;

      final delen = regel.split(';');
      if (delen.length < 5) continue;

      _gegevens.add({
        'postcode': delen[0].trim(),
        'plaatsnaam': delen[1].trim(),
        'hoofdgemeente': delen[3].trim(),
        'provincie': delen[4].trim(),
      });
    }
  }

  static String _normaal(String tekst) {
    return tekst.toLowerCase().replaceAll('-', '').replaceAll(' ', '').trim();
  }

  static List<String> gemeentenVanPostcode(String postcode) {
    final resultaten = <String>{};
    final zoek = postcode.trim();

    for (final item in _gegevens) {
      if (item['postcode'] == zoek) {
        final plaats = item['plaatsnaam'] ?? '';
        if (plaats.isNotEmpty) resultaten.add(plaats);
      }
    }

    return resultaten.toList()..sort();
  }

  static String? eersteGemeenteVanPostcode(String postcode) {
    final gemeenten = gemeentenVanPostcode(postcode);
    if (gemeenten.isEmpty) return null;
    return gemeenten.first;
  }

  static String? postcodeVanGemeente(String gemeente) {
    final zoek = _normaal(gemeente);
    if (zoek.isEmpty) return null;

    for (final item in _gegevens) {
      final plaats = _normaal(item['plaatsnaam'] ?? '');
      final hoofd = _normaal(item['hoofdgemeente'] ?? '');

      if (plaats == zoek || hoofd == zoek) {
        return item['postcode'];
      }
    }

    return null;
  }

  static List<String> zoekGemeenten(String tekst) {
    final zoek = _normaal(tekst);
    if (zoek.isEmpty) return [];

    final resultaten = <String>{};

    for (final item in _gegevens) {
      final plaats = item['plaatsnaam'] ?? '';
      final hoofd = item['hoofdgemeente'] ?? '';

      if (_normaal(plaats).contains(zoek)) {
        resultaten.add(plaats);
      }

      if (_normaal(hoofd).contains(zoek)) {
        resultaten.add(hoofd);
      }
    }

    return resultaten.toList()..sort();
  }

  static List<String> zoekPostcodes(String tekst) {
    final zoek = tekst.trim();
    if (zoek.isEmpty) return [];

    final resultaten = <String>{};

    for (final item in _gegevens) {
      final postcode = item['postcode'] ?? '';

      if (postcode.startsWith(zoek)) {
        resultaten.add(postcode);
      }
    }

    return resultaten.toList()..sort();
  }

  static String postcodeUitSuggestie(String suggestie) {
    return suggestie.trim().split(' ').first;
  }
}
