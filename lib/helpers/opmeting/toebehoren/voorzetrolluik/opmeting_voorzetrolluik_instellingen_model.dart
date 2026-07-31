// THIMACO-CONTROLE: VOORZETROLLUIK-GELEIDERS-MIGRATIE-V3-20260731-1215
class OpmetingVoorzetrolluikLamelkleur {
  const OpmetingVoorzetrolluikLamelkleur({
    required this.naam,
    required this.code,
    required this.hexKleur,
  });

  final String naam;
  final String code;
  final String hexKleur;

  String get id => '${naam.trim().toLowerCase()}|${code.trim().toLowerCase()}';

  String get samenvatting {
    final schoonNaam = naam.trim();
    final schoonCode = code.trim();
    if (schoonCode.isEmpty) return schoonNaam;
    if (schoonNaam.isEmpty) return schoonCode;
    return '$schoonNaam · $schoonCode';
  }

  OpmetingVoorzetrolluikLamelkleur copyWith({
    String? naam,
    String? code,
    String? hexKleur,
  }) {
    return OpmetingVoorzetrolluikLamelkleur(
      naam: naam ?? this.naam,
      code: code ?? this.code,
      hexKleur: _normaliseerHex(hexKleur ?? this.hexKleur),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'naam': naam.trim(),
      'code': code.trim(),
      'hexKleur': _normaliseerHex(hexKleur),
    };
  }

  factory OpmetingVoorzetrolluikLamelkleur.fromJson(Map<String, dynamic> json) {
    return OpmetingVoorzetrolluikLamelkleur(
      naam: json['naam']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      hexKleur: _normaliseerHex(json['hexKleur']?.toString() ?? '#D1D5DB'),
    );
  }

  static String _normaliseerHex(String waarde) {
    final tekst = waarde.trim().toUpperCase();
    final zonderHekje = tekst.startsWith('#') ? tekst.substring(1) : tekst;
    return RegExp(r'^[0-9A-F]{6}$').hasMatch(zonderHekje)
        ? '#$zonderHekje'
        : '#D1D5DB';
  }
}

class OpmetingVoorzetrolluikMotor {
  const OpmetingVoorzetrolluikMotor({
    required this.type,
    required this.merk,
    required this.omschrijving,
    this.extraInfo = '',
  });

  final String type;
  final String merk;
  final String omschrijving;
  final String extraInfo;

  String get id => <String>[
    type.trim().toLowerCase(),
    merk.trim().toLowerCase(),
    omschrijving.trim().toLowerCase(),
  ].join('|');

  String get samenvatting {
    return <String>[
      type.trim(),
      merk.trim(),
      omschrijving.trim(),
      extraInfo.trim(),
    ].where((deel) => deel.isNotEmpty).join(' · ');
  }

  OpmetingVoorzetrolluikMotor copyWith({
    String? type,
    String? merk,
    String? omschrijving,
    String? extraInfo,
  }) {
    return OpmetingVoorzetrolluikMotor(
      type: type ?? this.type,
      merk: merk ?? this.merk,
      omschrijving: omschrijving ?? this.omschrijving,
      extraInfo: extraInfo ?? this.extraInfo,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type.trim(),
      'merk': merk.trim(),
      'omschrijving': omschrijving.trim(),
      'extraInfo': extraInfo.trim(),
    };
  }

  factory OpmetingVoorzetrolluikMotor.fromJson(Map<String, dynamic> json) {
    return OpmetingVoorzetrolluikMotor(
      type: json['type']?.toString() ?? '',
      merk: json['merk']?.toString() ?? '',
      omschrijving: json['omschrijving']?.toString() ?? '',
      extraInfo: json['extraInfo']?.toString() ?? '',
    );
  }
}

class OpmetingVoorzetrolluikInstellingen {
  const OpmetingVoorzetrolluikInstellingen({
    this.lamelkleuren = const <OpmetingVoorzetrolluikLamelkleur>[],
    this.motoren = const <OpmetingVoorzetrolluikMotor>[],
    this.zonnecelMotoren = const <OpmetingVoorzetrolluikMotor>[],
    this.geleiderTypes = const <String>[],
    this.gewijzigdOp = '',
  });

  final List<OpmetingVoorzetrolluikLamelkleur> lamelkleuren;
  final List<OpmetingVoorzetrolluikMotor> motoren;
  final List<OpmetingVoorzetrolluikMotor> zonnecelMotoren;
  final List<String> geleiderTypes;
  final String gewijzigdOp;

  static const List<OpmetingVoorzetrolluikLamelkleur> standaardLamelkleuren =
      <OpmetingVoorzetrolluikLamelkleur>[
        OpmetingVoorzetrolluikLamelkleur(
          naam: 'Antracietgrijs 09',
          code: '+/-7016',
          hexKleur: '#383E42',
        ),
        OpmetingVoorzetrolluikLamelkleur(
          naam: 'Bruin 22',
          code: '+/-8019',
          hexKleur: '#3B2F2F',
        ),
        OpmetingVoorzetrolluikLamelkleur(
          naam: 'Creme 23',
          code: '+/-1015',
          hexKleur: '#E6D7B8',
        ),
        OpmetingVoorzetrolluikLamelkleur(
          naam: 'Creme-wit 61',
          code: '+/-9001',
          hexKleur: '#E9E0D2',
        ),
        OpmetingVoorzetrolluikLamelkleur(
          naam: 'Grafiet 83',
          code: '',
          hexKleur: '#4B4F54',
        ),
        OpmetingVoorzetrolluikLamelkleur(
          naam: 'Grijs 18',
          code: '+/-7038',
          hexKleur: '#B2B5B0',
        ),
        OpmetingVoorzetrolluikLamelkleur(
          naam: 'Kwartgrijs 33',
          code: '+/-7039',
          hexKleur: '#6C706F',
        ),
        OpmetingVoorzetrolluikLamelkleur(
          naam: 'Naturel 20',
          code: '+/-9006',
          hexKleur: '#A5A5A3',
        ),
        OpmetingVoorzetrolluikLamelkleur(
          naam: 'Wit 19',
          code: '+/-9016',
          hexKleur: '#FFFFFF',
        ),
        OpmetingVoorzetrolluikLamelkleur(
          naam: 'Wit 21',
          code: '+/-9010',
          hexKleur: '#F4F4F0',
        ),
        OpmetingVoorzetrolluikLamelkleur(
          naam: 'Zwart 44',
          code: '+/-9011',
          hexKleur: '#1D1F20',
        ),
      ];

  static const List<OpmetingVoorzetrolluikMotor> standaardMotoren =
      <OpmetingVoorzetrolluikMotor>[
        OpmetingVoorzetrolluikMotor(
          type: 'Bekabeld',
          merk: 'SOMFY',
          omschrijving: 'LT50 Meteor 20/17 noodhandbediening',
        ),
        OpmetingVoorzetrolluikMotor(
          type: 'Bekabeld',
          merk: 'SOMFY',
          omschrijving: 'Oximo 50 WT 6/17',
        ),
        OpmetingVoorzetrolluikMotor(
          type: 'Bekabeld',
          merk: 'SELVE',
          omschrijving: 'Selve SEE Plus 2/7',
        ),
        OpmetingVoorzetrolluikMotor(
          type: 'Draadloos',
          merk: 'SELVE',
          omschrijving: 'Selve SEE Plus RC 2/7',
        ),
        OpmetingVoorzetrolluikMotor(
          type: 'Draadloos',
          merk: 'SOMFY',
          omschrijving: 'S&SO RS100 IO 6/17',
        ),
        OpmetingVoorzetrolluikMotor(
          type: 'Draadloos',
          merk: 'SOMFY',
          omschrijving: 'Oximo 50 IO 6/17',
        ),
        OpmetingVoorzetrolluikMotor(
          type: 'Draadloos',
          merk: 'SOMFY',
          omschrijving: 'LT50 RTS 10/17 noodhandbediening',
          extraInfo: 'Te bestellen',
        ),
      ];

  static const List<OpmetingVoorzetrolluikMotor> standaardZonnecelMotoren =
      <OpmetingVoorzetrolluikMotor>[
        OpmetingVoorzetrolluikMotor(
          type: 'Draadloos',
          merk: 'BREL',
          omschrijving: 'Brel Solaris 35mm BLE35-13SHU (13Nm)',
        ),
        OpmetingVoorzetrolluikMotor(
          type: 'Draadloos',
          merk: 'SOMFY',
          omschrijving: 'Oximo 40 Solar IO 10/12',
        ),
      ];

  static const List<String> standaardGeleiderTypes = <String>[
    'HF',
    'FHTF12',
    'FHTF20',
    'HTF25',
    'HTF40',
    'LHF',
    'LHTF25',
    'LHTF40',
    'M-HTF',
  ];

  factory OpmetingVoorzetrolluikInstellingen.standaard() {
    return const OpmetingVoorzetrolluikInstellingen(
      lamelkleuren: standaardLamelkleuren,
      motoren: standaardMotoren,
      zonnecelMotoren: standaardZonnecelMotoren,
      geleiderTypes: standaardGeleiderTypes,
    );
  }

  OpmetingVoorzetrolluikInstellingen copyWith({
    List<OpmetingVoorzetrolluikLamelkleur>? lamelkleuren,
    List<OpmetingVoorzetrolluikMotor>? motoren,
    List<OpmetingVoorzetrolluikMotor>? zonnecelMotoren,
    List<String>? geleiderTypes,
    String? gewijzigdOp,
  }) {
    return OpmetingVoorzetrolluikInstellingen(
      lamelkleuren: _normaliseerLamelkleuren(lamelkleuren ?? this.lamelkleuren),
      motoren: _normaliseerMotoren(motoren ?? this.motoren),
      zonnecelMotoren: _normaliseerMotoren(
        zonnecelMotoren ?? this.zonnecelMotoren,
      ),
      geleiderTypes: _normaliseerTeksten(geleiderTypes ?? this.geleiderTypes),
      gewijzigdOp: gewijzigdOp ?? this.gewijzigdOp,
    );
  }

  OpmetingVoorzetrolluikInstellingen metWijzigingsDatum() {
    return copyWith(gewijzigdOp: DateTime.now().toUtc().toIso8601String());
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'lamelkleuren': lamelkleuren
          .map((kleur) => kleur.toJson())
          .toList(growable: false),
      'motoren': motoren.map((motor) => motor.toJson()).toList(growable: false),
      'zonnecelMotoren': zonnecelMotoren
          .map((motor) => motor.toJson())
          .toList(growable: false),
      'geleiderTypes': geleiderTypes,
      'geleiderTypesVersie': 3,
      'gewijzigdOp': gewijzigdOp,
    };
  }

  factory OpmetingVoorzetrolluikInstellingen.fromJson(
    Map<String, dynamic> json,
  ) {
    final opgeslagenGeleiders = _leesTeksten(json['geleiderTypes']);
    final geleiderTypesVersie = _leesInt(json['geleiderTypesVersie'], 1);
    final geleiders = geleiderTypesVersie >= 3
        ? opgeslagenGeleiders
        : _vulOntbrekendeStandaardGeleidersAan(opgeslagenGeleiders);

    return OpmetingVoorzetrolluikInstellingen(
      lamelkleuren: _leesLijst(
        json['lamelkleuren'],
        OpmetingVoorzetrolluikLamelkleur.fromJson,
      ),
      motoren: _leesLijst(
        json['motoren'],
        OpmetingVoorzetrolluikMotor.fromJson,
      ),
      zonnecelMotoren: _leesLijst(
        json['zonnecelMotoren'],
        OpmetingVoorzetrolluikMotor.fromJson,
      ),
      geleiderTypes: geleiders,
      gewijzigdOp: json['gewijzigdOp']?.toString() ?? '',
    ).copyWith();
  }

  static List<OpmetingVoorzetrolluikLamelkleur> _normaliseerLamelkleuren(
    Iterable<OpmetingVoorzetrolluikLamelkleur> waarden,
  ) {
    final resultaat = <OpmetingVoorzetrolluikLamelkleur>[];
    final gebruikt = <String>{};
    for (final waarde in waarden) {
      final code = waarde.code.trim();
      final schoon = waarde.copyWith(
        naam: waarde.naam.trim(),
        code: code,
        hexKleur: _isVerkeerswit(code) ? '#FFFFFF' : waarde.hexKleur,
      );
      if (schoon.naam.isEmpty || !gebruikt.add(schoon.id)) continue;
      resultaat.add(schoon);
    }
    return List<OpmetingVoorzetrolluikLamelkleur>.unmodifiable(resultaat);
  }

  static List<OpmetingVoorzetrolluikMotor> _normaliseerMotoren(
    Iterable<OpmetingVoorzetrolluikMotor> waarden,
  ) {
    final resultaat = <OpmetingVoorzetrolluikMotor>[];
    final gebruikt = <String>{};
    for (final waarde in waarden) {
      final schoon = waarde.copyWith(
        type: waarde.type.trim(),
        merk: waarde.merk.trim(),
        omschrijving: waarde.omschrijving.trim(),
        extraInfo: waarde.extraInfo.trim(),
      );
      if (schoon.omschrijving.isEmpty || !gebruikt.add(schoon.id)) continue;
      resultaat.add(schoon);
    }
    return List<OpmetingVoorzetrolluikMotor>.unmodifiable(resultaat);
  }

  static List<String> _normaliseerTeksten(Iterable<String> waarden) {
    final resultaat = <String>[];
    final gezien = <String>{};
    for (final waarde in waarden) {
      final schoon = waarde.trim();
      final sleutel = schoon.toLowerCase();
      if (schoon.isEmpty || !gezien.add(sleutel)) continue;
      resultaat.add(schoon);
    }
    return List<String>.unmodifiable(resultaat);
  }

  static List<String> _leesTeksten(Object? waarde) {
    if (waarde is! List) return standaardGeleiderTypes;
    final resultaat = waarde
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    return resultaat.isEmpty ? standaardGeleiderTypes : resultaat;
  }

  static List<String> _vulOntbrekendeStandaardGeleidersAan(
    Iterable<String> opgeslagen,
  ) {
    final resultaat = <String>[];
    final gebruikt = <String>{};

    void voegToe(String waarde) {
      final schoon = waarde.trim();
      if (schoon.isEmpty || !gebruikt.add(schoon.toLowerCase())) return;
      resultaat.add(schoon);
    }

    // Eerst de door Wilms opgegeven vaste volgorde, daarna eigen toevoegingen.
    for (final waarde in standaardGeleiderTypes) {
      voegToe(waarde);
    }
    for (final waarde in opgeslagen) {
      voegToe(waarde);
    }

    return List<String>.unmodifiable(resultaat);
  }

  static int _leesInt(Object? waarde, int standaard) {
    if (waarde is int) return waarde;
    if (waarde is num) return waarde.toInt();
    return int.tryParse(waarde?.toString() ?? '') ?? standaard;
  }

  static bool _isVerkeerswit(String code) {
    final cijfers = code.replaceAll(RegExp(r'[^0-9]'), '');
    return cijfers.contains('9016');
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
