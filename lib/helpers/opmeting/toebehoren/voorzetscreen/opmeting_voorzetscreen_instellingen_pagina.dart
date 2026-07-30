// THIMACO-CONTROLE: VOORZETSCREEN-INSTELLINGENMODEL-FASE-1-20260730
class OpmetingVoorzetscreenPoederkleur {
  const OpmetingVoorzetscreenPoederkleur({
    required this.benaming,
    required this.poedercode,
    required this.poederlakMogelijk,
    required this.natlakMogelijk,
  });

  final String benaming;
  final String poedercode;
  final bool poederlakMogelijk;
  final bool natlakMogelijk;

  String get id =>
      '${benaming.trim().toLowerCase()}|${poedercode.trim().toLowerCase()}';

  String get samenvatting {
    final code = poedercode.trim();
    return code.isEmpty ? benaming.trim() : '${benaming.trim()} · $code';
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'benaming': benaming.trim(),
      'poedercode': poedercode.trim(),
      'poederlakMogelijk': poederlakMogelijk,
      'natlakMogelijk': natlakMogelijk,
    };
  }

  factory OpmetingVoorzetscreenPoederkleur.fromJson(Map<String, dynamic> json) {
    return OpmetingVoorzetscreenPoederkleur(
      benaming: json['benaming']?.toString() ?? '',
      poedercode: json['poedercode']?.toString() ?? '',
      poederlakMogelijk: json['poederlakMogelijk'] == true,
      natlakMogelijk: json['natlakMogelijk'] == true,
    );
  }
}

class OpmetingVoorzetscreenDoek {
  const OpmetingVoorzetscreenDoek({
    required this.code,
    required this.kleur,
    required this.voorzijdeHex,
    required this.achterzijdeHex,
  });

  final String code;
  final String kleur;
  final String voorzijdeHex;
  final String achterzijdeHex;

  String get id => code.trim().toUpperCase();

  String get samenvatting {
    final naam = kleur.trim();
    return naam.isEmpty ? code.trim() : '${code.trim()} · $naam';
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'code': code.trim(),
      'kleur': kleur.trim(),
      'voorzijdeHex': _normaliseerHex(voorzijdeHex),
      'achterzijdeHex': _normaliseerHex(achterzijdeHex),
    };
  }

  factory OpmetingVoorzetscreenDoek.fromJson(Map<String, dynamic> json) {
    final code = json['code']?.toString() ?? '';
    final standaard = standaardKleurenVoorCode(code);

    return OpmetingVoorzetscreenDoek(
      code: code,
      kleur: json['kleur']?.toString() ?? '',
      voorzijdeHex: _normaliseerHex(
        json['voorzijdeHex']?.toString() ?? standaard.$1,
      ),
      achterzijdeHex: _normaliseerHex(
        json['achterzijdeHex']?.toString() ?? standaard.$2,
      ),
    );
  }

  static (String, String) standaardKleurenVoorCode(String code) {
    switch (code.trim().toUpperCase()) {
      case 'SC0202':
        return ('#F0EFE7', '#ECEBE3');
      case 'SC0207':
        return ('#D3D2CB', '#DAD9D2');
      case 'CS3301':
        return ('#6E6966', '#74706D');
      case 'SC3006':
        return ('#4A403A', '#3E3734');
      case 'CS3333':
        return ('#A39B91', '#9A938A');
      case 'SC0606':
        return ('#6B4E3D', '#5C4437');
      case 'SC3030':
        return ('#403B3C', '#353233');
      case 'SC0707':
        return ('#D1CCC3', '#C7C2B9');
      case 'SC0011':
        return ('#7A7D7F', '#717476');
      case 'MSC6060':
        return ('#1C1B1D', '#171719');
      case 'SC0310':
        return ('#484542', '#3A3836');
      default:
        return ('#D8DADD', '#C9CDD1');
    }
  }

  static String _normaliseerHex(String waarde) {
    final tekst = waarde.trim().toUpperCase();
    final zonderHekje = tekst.startsWith('#') ? tekst.substring(1) : tekst;
    if (RegExp(r'^[0-9A-F]{6}$').hasMatch(zonderHekje)) {
      return '#$zonderHekje';
    }
    return '#D8DADD';
  }
}

class OpmetingVoorzetscreenInstellingen {
  const OpmetingVoorzetscreenInstellingen({
    this.poederkleuren = const <OpmetingVoorzetscreenPoederkleur>[],
    this.screendoeken = const <OpmetingVoorzetscreenDoek>[],
    this.gewijzigdOp = '',
  });

  final List<OpmetingVoorzetscreenPoederkleur> poederkleuren;
  final List<OpmetingVoorzetscreenDoek> screendoeken;
  final String gewijzigdOp;

  OpmetingVoorzetscreenInstellingen copyWith({
    List<OpmetingVoorzetscreenPoederkleur>? poederkleuren,
    List<OpmetingVoorzetscreenDoek>? screendoeken,
    String? gewijzigdOp,
  }) {
    return OpmetingVoorzetscreenInstellingen(
      poederkleuren: poederkleuren ?? this.poederkleuren,
      screendoeken: screendoeken ?? this.screendoeken,
      gewijzigdOp: gewijzigdOp ?? this.gewijzigdOp,
    );
  }

  OpmetingVoorzetscreenInstellingen metWijzigingsDatum() {
    return copyWith(gewijzigdOp: DateTime.now().toUtc().toIso8601String());
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'poederkleuren': _normaliseerPoederkleuren(
        poederkleuren,
      ).map((item) => item.toJson()).toList(growable: false),
      'screendoeken': _normaliseerDoeken(
        screendoeken,
      ).map((item) => item.toJson()).toList(growable: false),
      'gewijzigdOp': gewijzigdOp,
    };
  }

  factory OpmetingVoorzetscreenInstellingen.fromJson(
    Map<String, dynamic> json,
  ) {
    return OpmetingVoorzetscreenInstellingen(
      poederkleuren: _leesLijst(
        json['poederkleuren'],
        OpmetingVoorzetscreenPoederkleur.fromJson,
      ),
      screendoeken: _leesLijst(
        json['screendoeken'],
        OpmetingVoorzetscreenDoek.fromJson,
      ),
      gewijzigdOp: json['gewijzigdOp']?.toString() ?? '',
    );
  }

  static List<OpmetingVoorzetscreenPoederkleur> _normaliseerPoederkleuren(
    Iterable<OpmetingVoorzetscreenPoederkleur> waarden,
  ) {
    final resultaat = <OpmetingVoorzetscreenPoederkleur>[];
    final gebruikt = <String>{};

    for (final waarde in waarden) {
      if (waarde.benaming.trim().isEmpty || !gebruikt.add(waarde.id)) continue;
      resultaat.add(waarde);
    }

    return List<OpmetingVoorzetscreenPoederkleur>.unmodifiable(resultaat);
  }

  static List<OpmetingVoorzetscreenDoek> _normaliseerDoeken(
    Iterable<OpmetingVoorzetscreenDoek> waarden,
  ) {
    final resultaat = <OpmetingVoorzetscreenDoek>[];
    final gebruikt = <String>{};

    for (final waarde in waarden) {
      if (waarde.code.trim().isEmpty || !gebruikt.add(waarde.id)) continue;
      resultaat.add(waarde);
    }

    return List<OpmetingVoorzetscreenDoek>.unmodifiable(resultaat);
  }

  static List<T> _leesLijst<T>(
    Object? waarde,
    T Function(Map<String, dynamic> json) maker,
  ) {
    if (waarde is! List) return <T>[];

    return waarde
        .whereType<Map>()
        .map((item) => maker(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }
}
