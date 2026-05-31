import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class KlantenLeverancier {
  final String naam;
  final List<String> artikelen;

  const KlantenLeverancier({
    required this.naam,
    required this.artikelen,
  });

  factory KlantenLeverancier.fromJson(Map<String, dynamic> json) {
    return KlantenLeverancier(
      naam: json['naam'] ?? '',
      artikelen: List<String>.from(json['artikelen'] ?? []),
    );
  }
}

class KlantenLeverancierService {
  static Future<List<KlantenLeverancier>> laadLeveranciers() async {
    final prefs = await SharedPreferences.getInstance();

    final tekst = prefs.getString('leveranciers_lijst') ?? '[]';
    final lijst = jsonDecode(tekst) as List<dynamic>;

    final leveranciers = lijst
        .map(
          (e) => KlantenLeverancier.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .where((leverancier) => leverancier.naam.trim().isNotEmpty)
        .toList();

    leveranciers.sort(
      (a, b) => a.naam.toLowerCase().compareTo(
            b.naam.toLowerCase(),
          ),
    );

    return leveranciers;
  }
}
