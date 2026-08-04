// THIMACO-CONTROLE: MAGAZIJN-INSTELLINGEN-LEVERANCIERS-20260804

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class InstellingenLeverancierKeuze {
  const InstellingenLeverancierKeuze({
    required this.naam,
    this.telefoon = '',
    this.gsm = '',
    this.email = '',
  });

  final String naam;
  final String telefoon;
  final String gsm;
  final String email;
}

class MagazijnInstellingenLeveranciersRepository {
  const MagazijnInstellingenLeveranciersRepository();

  Future<List<InstellingenLeverancierKeuze>> laad() async {
    final prefs = await SharedPreferences.getInstance();
    final tekst = prefs.getString('leveranciers_lijst') ?? '[]';

    try {
      final decoded = jsonDecode(tekst);
      if (decoded is! List) return const <InstellingenLeverancierKeuze>[];

      final leveranciers = decoded
          .whereType<Map>()
          .map((item) {
            final json = Map<String, dynamic>.from(item);
            return InstellingenLeverancierKeuze(
              naam: json['naam']?.toString().trim() ?? '',
              telefoon: json['telefoon']?.toString().trim() ?? '',
              gsm: json['gsm']?.toString().trim() ?? '',
              email: json['email']?.toString().trim() ?? '',
            );
          })
          .where((item) => item.naam.isNotEmpty)
          .toList(growable: false);

      leveranciers.sort(
        (a, b) => a.naam.toLowerCase().compareTo(b.naam.toLowerCase()),
      );
      return leveranciers;
    } catch (_) {
      return const <InstellingenLeverancierKeuze>[];
    }
  }
}
