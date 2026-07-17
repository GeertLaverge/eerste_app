class OpmetingProjectKleur {
  const OpmetingProjectKleur({
    required this.id,
    required this.naam,
    this.actief = true,
  });

  final String id;
  final String naam;
  final bool actief;

  OpmetingProjectKleur copyWith({String? id, String? naam, bool? actief}) {
    return OpmetingProjectKleur(
      id: id ?? this.id,
      naam: naam ?? this.naam,
      actief: actief ?? this.actief,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'naam': naam, 'actief': actief};
  }

  factory OpmetingProjectKleur.fromJson(Map<String, dynamic> json) {
    return OpmetingProjectKleur(
      id: json['id']?.toString() ?? '',
      naam: json['naam']?.toString() ?? '',
      actief: json['actief'] != false,
    );
  }
}

class OpmetingProjectKleurSubmenu {
  const OpmetingProjectKleurSubmenu({
    required this.id,
    required this.naam,
    this.kleuren = const <OpmetingProjectKleur>[],
    this.actief = true,
  });

  final String id;
  final String naam;
  final List<OpmetingProjectKleur> kleuren;
  final bool actief;

  List<OpmetingProjectKleur> get actieveKleuren {
    return kleuren.where((kleur) {
      return kleur.actief && kleur.naam.trim().isNotEmpty;
    }).toList();
  }

  OpmetingProjectKleurSubmenu copyWith({
    String? id,
    String? naam,
    List<OpmetingProjectKleur>? kleuren,
    bool? actief,
  }) {
    return OpmetingProjectKleurSubmenu(
      id: id ?? this.id,
      naam: naam ?? this.naam,
      kleuren: kleuren ?? this.kleuren,
      actief: actief ?? this.actief,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'naam': naam,
      'actief': actief,
      'kleuren': kleuren.map((kleur) => kleur.toJson()).toList(),
    };
  }

  factory OpmetingProjectKleurSubmenu.fromJson(Map<String, dynamic> json) {
    final ruweKleuren = json['kleuren'];

    return OpmetingProjectKleurSubmenu(
      id: json['id']?.toString() ?? '',
      naam: json['naam']?.toString() ?? '',
      actief: json['actief'] != false,
      kleuren: ruweKleuren is List
          ? ruweKleuren
                .whereType<Map>()
                .map((kleur) {
                  return OpmetingProjectKleur.fromJson(
                    Map<String, dynamic>.from(kleur),
                  );
                })
                .where((kleur) => kleur.id.trim().isNotEmpty)
                .toList()
          : const <OpmetingProjectKleur>[],
    );
  }
}
