// THIMACO-CONTROLE: SEKTIONALE-POORTEN-INSTELLINGEN-MODEL-20260729
class OpmetingSektionalePoortInstellingen {
  const OpmetingSektionalePoortInstellingen({
    this.kleuren = const <String>[],
    this.gewijzigdOp = '',
  });

  final List<String> kleuren;
  final String gewijzigdOp;

  OpmetingSektionalePoortInstellingen copyWith({
    List<String>? kleuren,
    String? gewijzigdOp,
  }) {
    return OpmetingSektionalePoortInstellingen(
      kleuren: List<String>.unmodifiable(kleuren ?? this.kleuren),
      gewijzigdOp: gewijzigdOp ?? this.gewijzigdOp,
    );
  }

  OpmetingSektionalePoortInstellingen metWijzigingsDatum() {
    return copyWith(gewijzigdOp: DateTime.now().toUtc().toIso8601String());
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'kleuren': kleuren,
    'gewijzigdOp': gewijzigdOp,
  };

  factory OpmetingSektionalePoortInstellingen.fromJson(
    Map<String, dynamic> json,
  ) {
    final ruweKleuren = json['kleuren'];
    final kleuren = ruweKleuren is List
        ? ruweKleuren
              .map((waarde) => waarde?.toString().trim() ?? '')
              .where((waarde) => waarde.isNotEmpty)
              .toList(growable: false)
        : const <String>[];

    return OpmetingSektionalePoortInstellingen(
      kleuren: List<String>.unmodifiable(kleuren),
      gewijzigdOp: json['gewijzigdOp']?.toString() ?? '',
    );
  }
}
