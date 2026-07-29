// THIMACO-CONTROLE: PLOOIWERKEN-INSTELLINGENMODEL-DEFINITIEF-20260728-2110
class OpmetingPlooiwerkenInstellingen {
  const OpmetingPlooiwerkenInstellingen({
    this.kleuren = const <String>[],
    this.folies = const <String>[],
    this.gewijzigdOp = '',
  });

  final List<String> kleuren;
  final List<String> folies;
  final String gewijzigdOp;

  OpmetingPlooiwerkenInstellingen copyWith({
    List<String>? kleuren,
    List<String>? folies,
    String? gewijzigdOp,
  }) {
    return OpmetingPlooiwerkenInstellingen(
      kleuren: kleuren ?? this.kleuren,
      folies: folies ?? this.folies,
      gewijzigdOp: gewijzigdOp ?? this.gewijzigdOp,
    );
  }

  OpmetingPlooiwerkenInstellingen metWijzigingsDatum() {
    return copyWith(gewijzigdOp: DateTime.now().toUtc().toIso8601String());
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'kleuren': _normaliseer(kleuren),
      'folies': _normaliseer(folies),
      'gewijzigdOp': gewijzigdOp,
    };
  }

  factory OpmetingPlooiwerkenInstellingen.fromJson(Map<String, dynamic> json) {
    return OpmetingPlooiwerkenInstellingen(
      kleuren: _leesLijst(json['kleuren']),
      folies: _leesLijst(json['folies']),
      gewijzigdOp: json['gewijzigdOp']?.toString() ?? '',
    );
  }

  static List<String> _leesLijst(Object? waarde) {
    if (waarde is! List) return const <String>[];
    return _normaliseer(waarde.map((item) => item?.toString() ?? ''));
  }

  static List<String> _normaliseer(Iterable<String> waarden) {
    final resultaat = <String>[];
    final gebruikt = <String>{};

    for (final waarde in waarden) {
      final tekst = waarde.trim();
      final sleutel = tekst.toLowerCase();
      if (tekst.isEmpty || !gebruikt.add(sleutel)) continue;
      resultaat.add(tekst);
    }

    return List<String>.unmodifiable(resultaat);
  }
}
