// THIMACO-CONTROLE: PRIJS-VOOR-ALLE-POSITIES-PROJECTREGEL-MODEL-20260815
import 'offerte_artikel_prijs_data_model.dart';

/// Eén eenvoudige prijsregel die op één of meerdere offerteposities kan worden
/// toegepast.
///
/// De eigenlijke prijslogica blijft bewust dezelfde
/// [OffertePrijsPerPositieRegelModel] gebruiken als "Prijs per positie".
/// Alleen de doelkeuze is extra: expliciete positie-IDs of dynamisch alle
/// posities.
class OffertePrijsVoorAllePositiesRegelModel {
  const OffertePrijsVoorAllePositiesRegelModel({
    required this.prijsregel,
    this.geselecteerdePositieIds = const <String>{},
    this.toepassenOpAllePosities = false,
    this.volgorde = 0,
  });

  final OffertePrijsPerPositieRegelModel prijsregel;

  /// Expliciet gekozen posities wanneer [toepassenOpAllePosities] false is.
  final Set<String> geselecteerdePositieIds;

  /// Wanneer true geldt de regel ook automatisch voor posities die later aan
  /// dezelfde offerte worden toegevoegd.
  final bool toepassenOpAllePosities;

  final int volgorde;

  String get id => prijsregel.id;
  String get omschrijving => prijsregel.omschrijving;

  bool get heeftDoel {
    return toepassenOpAllePosities || geselecteerdePositieIds.isNotEmpty;
  }

  bool get isGeldig {
    return prijsregel.isGeldig && heeftDoel;
  }

  bool isVanToepassingOp(String positieId) {
    final sleutel = positieId.trim();
    if (sleutel.isEmpty) return false;
    return toepassenOpAllePosities || geselecteerdePositieIds.contains(sleutel);
  }

  OffertePrijsVoorAllePositiesRegelModel copyWith({
    OffertePrijsPerPositieRegelModel? prijsregel,
    Set<String>? geselecteerdePositieIds,
    bool? toepassenOpAllePosities,
    int? volgorde,
  }) {
    return OffertePrijsVoorAllePositiesRegelModel(
      prijsregel: prijsregel ?? this.prijsregel,
      geselecteerdePositieIds: Set<String>.unmodifiable(
        geselecteerdePositieIds ?? this.geselecteerdePositieIds,
      ),
      toepassenOpAllePosities:
          toepassenOpAllePosities ?? this.toepassenOpAllePosities,
      volgorde: volgorde ?? this.volgorde,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'prijsregel': prijsregel.toJson(),
      'geselecteerdePositieIds': (geselecteerdePositieIds.toList(
        growable: false,
      )..sort()),
      'toepassenOpAllePosities': toepassenOpAllePosities,
      'volgorde': volgorde,
    };
  }

  factory OffertePrijsVoorAllePositiesRegelModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final ruwePrijsregel = json['prijsregel'];
    final prijsregel = ruwePrijsregel is Map
        ? OffertePrijsPerPositieRegelModel.fromJson(
            Map<String, dynamic>.from(ruwePrijsregel),
          )
        : OffertePrijsPerPositieRegelModel.fromJson(json);

    return OffertePrijsVoorAllePositiesRegelModel(
      prijsregel: prijsregel,
      geselecteerdePositieIds: _leesStringSet(
        json['geselecteerdePositieIds'] ?? json['positieIds'],
      ),
      toepassenOpAllePosities: _leesBool(
        json['toepassenOpAllePosities'] ?? json['allePosities'],
      ),
      volgorde: _leesInt(json['volgorde']),
    );
  }

  static Set<String> _leesStringSet(Object? waarde) {
    if (waarde is! List) return const <String>{};

    final resultaat = waarde
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toSet();
    return Set<String>.unmodifiable(resultaat);
  }

  static bool _leesBool(Object? waarde) {
    if (waarde is bool) return waarde;
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    return tekst == 'true' || tekst == '1' || tekst == 'ja';
  }

  static int _leesInt(Object? waarde) {
    if (waarde is int) return waarde;
    if (waarde is num) return waarde.toInt();
    return int.tryParse(waarde?.toString().trim() ?? '') ?? 0;
  }
}
