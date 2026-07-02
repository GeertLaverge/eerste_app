enum OpmetingRaamKleinhoutType { opGlasRecht, opGlasSteelLook, inGlas }

extension OpmetingRaamKleinhoutTypeWeergave on OpmetingRaamKleinhoutType {
  String get naam {
    switch (this) {
      case OpmetingRaamKleinhoutType.opGlasRecht:
        return 'Kleinhouten op glas recht';

      case OpmetingRaamKleinhoutType.opGlasSteelLook:
        return 'Kleinhouten op glas Steel look';

      case OpmetingRaamKleinhoutType.inGlas:
        return 'Kleinhouten in het glas';
    }
  }

  String get korteNaam {
    switch (this) {
      case OpmetingRaamKleinhoutType.opGlasRecht:
        return 'Op glas recht';

      case OpmetingRaamKleinhoutType.opGlasSteelLook:
        return 'Op glas Steel look';

      case OpmetingRaamKleinhoutType.inGlas:
        return 'In het glas';
    }
  }

  static OpmetingRaamKleinhoutType vanNaam(String? waarde) {
    for (final type in OpmetingRaamKleinhoutType.values) {
      if (type.name == waarde) {
        return type;
      }
    }

    return OpmetingRaamKleinhoutType.opGlasRecht;
  }
}

enum OpmetingRaamKleinhoutPatroon { bovenverdeling, volledigRaster }

extension OpmetingRaamKleinhoutPatroonWeergave on OpmetingRaamKleinhoutPatroon {
  String get naam {
    switch (this) {
      case OpmetingRaamKleinhoutPatroon.bovenverdeling:
        return '1 horizontaal met verticale verdeling bovenaan';

      case OpmetingRaamKleinhoutPatroon.volledigRaster:
        return 'Horizontaal en verticaal raster';
    }
  }

  String get korteNaam {
    switch (this) {
      case OpmetingRaamKleinhoutPatroon.bovenverdeling:
        return 'Bovenverdeling';

      case OpmetingRaamKleinhoutPatroon.volledigRaster:
        return 'Volledig raster';
    }
  }

  static OpmetingRaamKleinhoutPatroon vanNaam(String? waarde) {
    for (final patroon in OpmetingRaamKleinhoutPatroon.values) {
      if (patroon.name == waarde) {
        return patroon;
      }
    }

    return OpmetingRaamKleinhoutPatroon.bovenverdeling;
  }
}

class OpmetingRaamKleinhout {
  const OpmetingRaamKleinhout({
    required this.id,
    required this.vlakId,
    required this.werkvlakId,
    required this.type,
    required this.patroon,
    required this.aantalHorizontaal,
    required this.aantalVerticaal,
    this.horizontaleHoogteMm,
    this.breedteMm = standaardBreedteMm,
  });

  static const double standaardBreedteMm = 25;

  final String id;

  /// Het specifieke glas- of opvullingsvlak waarop
  /// de kleinhouten geplaatst zijn.
  final String vlakId;

  /// Het kader- of vleugelwerkvlak waartoe het glasvlak behoort.
  final String werkvlakId;

  final OpmetingRaamKleinhoutType type;
  final OpmetingRaamKleinhoutPatroon patroon;

  /// Dit is het aantal profieltjes, niet het aantal vakken.
  final int aantalHorizontaal;

  /// Dit is het aantal profieltjes, niet het aantal vakken.
  final int aantalVerticaal;

  /// Alleen gebruikt bij [OpmetingRaamKleinhoutPatroon.bovenverdeling].
  ///
  /// De maat wordt genomen vanaf de onderzijde van het glasvlak
  /// tot het midden van het horizontale kleinhout.
  final double? horizontaleHoogteMm;

  /// De werkelijke profielbreedte van het kleinhout.
  final double breedteMm;

  bool get isBovenverdeling {
    return patroon == OpmetingRaamKleinhoutPatroon.bovenverdeling;
  }

  bool get isVolledigRaster {
    return patroon == OpmetingRaamKleinhoutPatroon.volledigRaster;
  }

  int get effectiefAantalHorizontaal {
    if (isBovenverdeling) {
      return 1;
    }

    return aantalHorizontaal < 0 ? 0 : aantalHorizontaal;
  }

  int get effectiefAantalVerticaal {
    return aantalVerticaal < 0 ? 0 : aantalVerticaal;
  }

  bool get heeftKleinhouten {
    return effectiefAantalHorizontaal > 0 || effectiefAantalVerticaal > 0;
  }

  String get aantalSamenvatting {
    return 'hor $effectiefAantalHorizontaal · '
        'vert $effectiefAantalVerticaal';
  }

  String get volledigeSamenvatting {
    return '${type.korteNaam} · $aantalSamenvatting';
  }

  OpmetingRaamKleinhout copyWith({
    String? id,
    String? vlakId,
    String? werkvlakId,
    OpmetingRaamKleinhoutType? type,
    OpmetingRaamKleinhoutPatroon? patroon,
    int? aantalHorizontaal,
    int? aantalVerticaal,
    double? horizontaleHoogteMm,
    bool wisHorizontaleHoogte = false,
    double? breedteMm,
  }) {
    return OpmetingRaamKleinhout(
      id: id ?? this.id,
      vlakId: vlakId ?? this.vlakId,
      werkvlakId: werkvlakId ?? this.werkvlakId,
      type: type ?? this.type,
      patroon: patroon ?? this.patroon,
      aantalHorizontaal: aantalHorizontaal ?? this.aantalHorizontaal,
      aantalVerticaal: aantalVerticaal ?? this.aantalVerticaal,
      horizontaleHoogteMm: wisHorizontaleHoogte
          ? null
          : horizontaleHoogteMm ?? this.horizontaleHoogteMm,
      breedteMm: breedteMm ?? this.breedteMm,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'vlakId': vlakId,
      'werkvlakId': werkvlakId,
      'type': type.name,
      'patroon': patroon.name,
      'aantalHorizontaal': effectiefAantalHorizontaal,
      'aantalVerticaal': effectiefAantalVerticaal,
      'horizontaleHoogteMm': horizontaleHoogteMm,
      'breedteMm': breedteMm,
    };
  }

  factory OpmetingRaamKleinhout.fromJson(Map<String, dynamic> json) {
    final patroon = OpmetingRaamKleinhoutPatroonWeergave.vanNaam(
      json['patroon']?.toString(),
    );

    final opgeslagenAantalHorizontaal = _leesInt(json['aantalHorizontaal']);

    return OpmetingRaamKleinhout(
      id:
          json['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      vlakId: json['vlakId']?.toString() ?? '',
      werkvlakId: json['werkvlakId']?.toString() ?? 'kader',
      type: OpmetingRaamKleinhoutTypeWeergave.vanNaam(json['type']?.toString()),
      patroon: patroon,
      aantalHorizontaal: patroon == OpmetingRaamKleinhoutPatroon.bovenverdeling
          ? 1
          : opgeslagenAantalHorizontaal,
      aantalVerticaal: _leesInt(json['aantalVerticaal']),
      horizontaleHoogteMm: _leesOptioneleDouble(json['horizontaleHoogteMm']),
      breedteMm: _leesDouble(json['breedteMm'], standaardBreedteMm),
    );
  }

  static int _leesInt(dynamic waarde, [int standaardWaarde = 0]) {
    if (waarde is int) {
      return waarde;
    }

    if (waarde is num) {
      return waarde.round();
    }

    return int.tryParse(waarde?.toString() ?? '') ?? standaardWaarde;
  }

  static double _leesDouble(dynamic waarde, double standaardWaarde) {
    if (waarde is double) {
      return waarde;
    }

    if (waarde is num) {
      return waarde.toDouble();
    }

    return double.tryParse(
          waarde?.toString().trim().replaceAll(',', '.') ?? '',
        ) ??
        standaardWaarde;
  }

  static double? _leesOptioneleDouble(dynamic waarde) {
    if (waarde == null) {
      return null;
    }

    if (waarde is double) {
      return waarde;
    }

    if (waarde is num) {
      return waarde.toDouble();
    }

    return double.tryParse(waarde.toString().trim().replaceAll(',', '.'));
  }
}
