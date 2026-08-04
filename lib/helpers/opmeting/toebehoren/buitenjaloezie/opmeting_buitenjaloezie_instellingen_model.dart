// THIMACO-CONTROLE: BUITENJALOEZIE-INSTELLINGEN-MODEL-FASE-1-20260803

import 'opmeting_buitenjaloezie_model.dart';

class OpmetingBuitenjaloezieLamelkleur {
  const OpmetingBuitenjaloezieLamelkleur({
    required this.code,
    required this.naam,
    required this.hexKleur,
    required this.toegestaanVoor,
    this.optioneel = false,
  });

  final String code;
  final String naam;
  final String hexKleur;
  final Set<OpmetingBuitenjaloezieLameltype> toegestaanVoor;
  final bool optioneel;

  String get id => code.trim().toLowerCase();

  String get label {
    if (code.trim().isEmpty) return naam.trim();
    if (naam.trim().isEmpty) return code.trim();
    return '${code.trim()} ${naam.trim()}';
  }

  bool isToegestaanVoor(OpmetingBuitenjaloezieLameltype lameltype) {
    return toegestaanVoor.contains(lameltype);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'code': code,
      'naam': naam,
      'hexKleur': hexKleur,
      'toegestaanVoor': toegestaanVoor
          .map((type) => type.name)
          .toList(growable: false),
      'optioneel': optioneel,
    };
  }

  factory OpmetingBuitenjaloezieLamelkleur.fromJson(Map<String, dynamic> json) {
    final ruweTypes = json['toegestaanVoor'];
    final types = <OpmetingBuitenjaloezieLameltype>{};

    if (ruweTypes is List) {
      for (final waarde in ruweTypes) {
        types.add(
          OpmetingBuitenjaloezieLameltypeExtension.vanOpslagWaarde(waarde),
        );
      }
    }

    return OpmetingBuitenjaloezieLamelkleur(
      code: json['code']?.toString() ?? '',
      naam: json['naam']?.toString() ?? '',
      hexKleur: json['hexKleur']?.toString() ?? '#B7B7B7',
      toegestaanVoor: types.isEmpty
          ? Set<OpmetingBuitenjaloezieLameltype>.from(
              OpmetingBuitenjaloezieLameltype.values,
            )
          : types,
      optioneel: json['optioneel'] == true,
    );
  }
}

class OpmetingBuitenjaloezieGeleider {
  const OpmetingBuitenjaloezieGeleider({
    required this.code,
    required this.breedteMm,
    required this.diepteMm,
    required this.toegestaanVoor,
  });

  final String code;
  final int breedteMm;
  final int diepteMm;
  final Set<OpmetingBuitenjaloezieLameltype> toegestaanVoor;

  String get id => code.trim().toLowerCase();
  String get omschrijving => '$breedteMm × $diepteMm mm';
  String get label => '${code.trim()} · $omschrijving';

  bool isToegestaanVoor(OpmetingBuitenjaloezieLameltype lameltype) {
    return toegestaanVoor.contains(lameltype);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'code': code,
      'breedteMm': breedteMm,
      'diepteMm': diepteMm,
      'toegestaanVoor': toegestaanVoor
          .map((type) => type.name)
          .toList(growable: false),
    };
  }

  factory OpmetingBuitenjaloezieGeleider.fromJson(Map<String, dynamic> json) {
    final ruweTypes = json['toegestaanVoor'];
    final types = <OpmetingBuitenjaloezieLameltype>{};

    if (ruweTypes is List) {
      for (final waarde in ruweTypes) {
        types.add(
          OpmetingBuitenjaloezieLameltypeExtension.vanOpslagWaarde(waarde),
        );
      }
    }

    return OpmetingBuitenjaloezieGeleider(
      code: json['code']?.toString() ?? '',
      breedteMm: _leesInt(json['breedteMm'], 27),
      diepteMm: _leesInt(json['diepteMm'], 69),
      toegestaanVoor: types,
    );
  }
}

class OpmetingBuitenjaloezieInstellingen {
  const OpmetingBuitenjaloezieInstellingen({
    this.lamelkleuren = standaardLamelkleuren,
    this.geleiders = standaardGeleiders,
    this.bedieningen = standaardBedieningen,
    this.motorkabelLengtes = standaardMotorkabelLengtes,
    this.afschuiningGraden = standaardAfschuiningGraden,
    this.gewijzigdOp = '',
  });

  final List<OpmetingBuitenjaloezieLamelkleur> lamelkleuren;
  final List<OpmetingBuitenjaloezieGeleider> geleiders;
  final List<String> bedieningen;
  final List<int> motorkabelLengtes;
  final List<int> afschuiningGraden;
  final String gewijzigdOp;

  List<OpmetingBuitenjaloezieLamelkleur> kleurenVoor(
    OpmetingBuitenjaloezieLameltype lameltype,
  ) {
    return lamelkleuren
        .where((kleur) => kleur.isToegestaanVoor(lameltype))
        .toList(growable: false);
  }

  List<OpmetingBuitenjaloezieGeleider> geleidersVoor(
    OpmetingBuitenjaloezieLameltype lameltype,
  ) {
    return geleiders
        .where((geleider) => geleider.isToegestaanVoor(lameltype))
        .toList(growable: false);
  }

  OpmetingBuitenjaloezieInstellingen metWijzigingsDatum() {
    return OpmetingBuitenjaloezieInstellingen(
      lamelkleuren: lamelkleuren,
      geleiders: geleiders,
      bedieningen: bedieningen,
      motorkabelLengtes: motorkabelLengtes,
      afschuiningGraden: afschuiningGraden,
      gewijzigdOp: DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'lamelkleuren': lamelkleuren
          .map((item) => item.toJson())
          .toList(growable: false),
      'geleiders': geleiders
          .map((item) => item.toJson())
          .toList(growable: false),
      'bedieningen': bedieningen,
      'motorkabelLengtes': motorkabelLengtes,
      'afschuiningGraden': afschuiningGraden,
      'gewijzigdOp': gewijzigdOp,
    };
  }

  factory OpmetingBuitenjaloezieInstellingen.fromJson(
    Map<String, dynamic> json,
  ) {
    return OpmetingBuitenjaloezieInstellingen(
      lamelkleuren: _leesLamelkleuren(json['lamelkleuren']),
      geleiders: _leesGeleiders(json['geleiders']),
      bedieningen: _leesStrings(json['bedieningen'], standaardBedieningen),
      motorkabelLengtes: _leesIntLijst(
        json['motorkabelLengtes'],
        standaardMotorkabelLengtes,
      ),
      afschuiningGraden: _leesIntLijst(
        json['afschuiningGraden'],
        standaardAfschuiningGraden,
      ),
      gewijzigdOp: json['gewijzigdOp']?.toString() ?? '',
    );
  }

  static const Set<OpmetingBuitenjaloezieLameltype> _alle =
      <OpmetingBuitenjaloezieLameltype>{
        OpmetingBuitenjaloezieLameltype.cdl70,
        OpmetingBuitenjaloezieLameltype.zl81,
        OpmetingBuitenjaloezieLameltype.dbl70,
        OpmetingBuitenjaloezieLameltype.gl80,
        OpmetingBuitenjaloezieLameltype.fl80,
      };

  static const Set<OpmetingBuitenjaloezieLameltype> _zonderFl =
      <OpmetingBuitenjaloezieLameltype>{
        OpmetingBuitenjaloezieLameltype.cdl70,
        OpmetingBuitenjaloezieLameltype.zl81,
        OpmetingBuitenjaloezieLameltype.dbl70,
        OpmetingBuitenjaloezieLameltype.gl80,
      };

  static const Set<OpmetingBuitenjaloezieLameltype> _cdlZlDbl =
      <OpmetingBuitenjaloezieLameltype>{
        OpmetingBuitenjaloezieLameltype.cdl70,
        OpmetingBuitenjaloezieLameltype.zl81,
        OpmetingBuitenjaloezieLameltype.dbl70,
      };

  static const List<OpmetingBuitenjaloezieLamelkleur> standaardLamelkleuren =
      <OpmetingBuitenjaloezieLamelkleur>[
        OpmetingBuitenjaloezieLamelkleur(
          code: '301',
          naam: 'Lichtgrau',
          hexKleur: '#D9D9D7',
          toegestaanVoor: _zonderFl,
        ),
        OpmetingBuitenjaloezieLamelkleur(
          code: '303',
          naam: 'Graualuminium (~ RAL 9007)',
          hexKleur: '#8F9092',
          toegestaanVoor: _alle,
        ),
        OpmetingBuitenjaloezieLamelkleur(
          code: '304',
          naam: 'Anthrazitgrau (~ RAL 7016)',
          hexKleur: '#383E42',
          toegestaanVoor: _alle,
        ),
        OpmetingBuitenjaloezieLamelkleur(
          code: '305',
          naam: 'DB 703',
          hexKleur: '#4A4A4D',
          toegestaanVoor: _alle,
        ),
        OpmetingBuitenjaloezieLamelkleur(
          code: '306',
          naam: 'Verkehrsweiß (~ RAL 9016)',
          hexKleur: '#F1F0EA',
          toegestaanVoor: _alle,
        ),
        OpmetingBuitenjaloezieLamelkleur(
          code: '309',
          naam: 'Cremeweiß (~ RAL 9001)',
          hexKleur: '#E9E0D2',
          toegestaanVoor: _zonderFl,
        ),
        OpmetingBuitenjaloezieLamelkleur(
          code: '310',
          naam: 'Weißaluminium (~ RAL 9006)',
          hexKleur: '#A5A5A3',
          toegestaanVoor: _alle,
        ),
        OpmetingBuitenjaloezieLamelkleur(
          code: '311',
          naam: 'Beige',
          hexKleur: '#D7C6AC',
          toegestaanVoor: _zonderFl,
        ),
        OpmetingBuitenjaloezieLamelkleur(
          code: '312',
          naam: 'Sarotti',
          hexKleur: '#4B3028',
          toegestaanVoor: _alle,
        ),
        OpmetingBuitenjaloezieLamelkleur(
          code: '313',
          naam: 'Mittelbronze (~ C33)',
          hexKleur: '#6E6045',
          toegestaanVoor: _zonderFl,
        ),
        OpmetingBuitenjaloezieLamelkleur(
          code: '314',
          naam: 'Grau',
          hexKleur: '#AAA9A7',
          toegestaanVoor: _alle,
        ),
        OpmetingBuitenjaloezieLamelkleur(
          code: '315',
          naam: 'Silber - matt, gebürstet',
          hexKleur: '#B9B9B5',
          toegestaanVoor: _cdlZlDbl,
          optioneel: true,
        ),
        OpmetingBuitenjaloezieLamelkleur(
          code: '316',
          naam: 'Bronze - matt, gebürstet',
          hexKleur: '#907B5C',
          toegestaanVoor: _cdlZlDbl,
          optioneel: true,
        ),
        OpmetingBuitenjaloezieLamelkleur(
          code: '317',
          naam: 'Dunkelgrau - matt, gebürstet',
          hexKleur: '#4C5558',
          toegestaanVoor: _cdlZlDbl,
          optioneel: true,
        ),
        OpmetingBuitenjaloezieLamelkleur(
          code: '318',
          naam: 'Schwarz (~ RAL 9005)',
          hexKleur: '#111516',
          toegestaanVoor: _zonderFl,
        ),
        OpmetingBuitenjaloezieLamelkleur(
          code: '319',
          naam: 'Quarzgrau (~ RAL 7039)',
          hexKleur: '#6C706F',
          toegestaanVoor: _zonderFl,
        ),
        OpmetingBuitenjaloezieLamelkleur(
          code: 'RAL/NCS',
          naam: 'Speciale kleur',
          hexKleur: '#B7B7B7',
          toegestaanVoor: _alle,
          optioneel: true,
        ),
      ];

  static const Set<OpmetingBuitenjaloezieLameltype> _zlDblGl =
      <OpmetingBuitenjaloezieLameltype>{
        OpmetingBuitenjaloezieLameltype.zl81,
        OpmetingBuitenjaloezieLameltype.dbl70,
        OpmetingBuitenjaloezieLameltype.gl80,
      };

  static const Set<OpmetingBuitenjaloezieLameltype> _cdl =
      <OpmetingBuitenjaloezieLameltype>{OpmetingBuitenjaloezieLameltype.cdl70};

  static const List<OpmetingBuitenjaloezieGeleider> standaardGeleiders =
      <OpmetingBuitenjaloezieGeleider>[
        OpmetingBuitenjaloezieGeleider(
          code: '1',
          breedteMm: 27,
          diepteMm: 69,
          toegestaanVoor: _zlDblGl,
        ),
        OpmetingBuitenjaloezieGeleider(
          code: '2',
          breedteMm: 27,
          diepteMm: 89,
          toegestaanVoor: _zlDblGl,
        ),
        OpmetingBuitenjaloezieGeleider(
          code: '3',
          breedteMm: 27,
          diepteMm: 109,
          toegestaanVoor: _zlDblGl,
        ),
        OpmetingBuitenjaloezieGeleider(
          code: '4',
          breedteMm: 50,
          diepteMm: 69,
          toegestaanVoor: _zlDblGl,
        ),
        OpmetingBuitenjaloezieGeleider(
          code: '5',
          breedteMm: 45,
          diepteMm: 69,
          toegestaanVoor: _zlDblGl,
        ),
        OpmetingBuitenjaloezieGeleider(
          code: '6',
          breedteMm: 69,
          diepteMm: 69,
          toegestaanVoor: _zlDblGl,
        ),
        OpmetingBuitenjaloezieGeleider(
          code: '7',
          breedteMm: 53,
          diepteMm: 89,
          toegestaanVoor: _zlDblGl,
        ),
        OpmetingBuitenjaloezieGeleider(
          code: '8',
          breedteMm: 85,
          diepteMm: 89,
          toegestaanVoor: _zlDblGl,
        ),
        OpmetingBuitenjaloezieGeleider(
          code: '9',
          breedteMm: 33,
          diepteMm: 69,
          toegestaanVoor: _cdl,
        ),
        OpmetingBuitenjaloezieGeleider(
          code: '10',
          breedteMm: 33,
          diepteMm: 89,
          toegestaanVoor: _cdl,
        ),
        OpmetingBuitenjaloezieGeleider(
          code: '11',
          breedteMm: 33,
          diepteMm: 109,
          toegestaanVoor: _cdl,
        ),
        OpmetingBuitenjaloezieGeleider(
          code: '12',
          breedteMm: 53,
          diepteMm: 69,
          toegestaanVoor: _cdl,
        ),
        OpmetingBuitenjaloezieGeleider(
          code: '13',
          breedteMm: 53,
          diepteMm: 89,
          toegestaanVoor: _cdl,
        ),
        OpmetingBuitenjaloezieGeleider(
          code: '14',
          breedteMm: 53,
          diepteMm: 109,
          toegestaanVoor: _cdl,
        ),
        OpmetingBuitenjaloezieGeleider(
          code: '15',
          breedteMm: 60,
          diepteMm: 69,
          toegestaanVoor: _cdl,
        ),
      ];

  static const List<String> standaardBedieningen = <String>[
    'Inbouwschakelaar',
    'Handzender Situo 1 Var',
    'Handzender Situo 5 Var',
  ];

  static const List<int> standaardMotorkabelLengtes = <int>[5, 10];

  static const List<int> standaardAfschuiningGraden = <int>[
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
  ];

  static List<OpmetingBuitenjaloezieLamelkleur> _leesLamelkleuren(
    Object? waarde,
  ) {
    if (waarde is! List) return standaardLamelkleuren;
    final resultaat = waarde
        .whereType<Map>()
        .map(
          (item) => OpmetingBuitenjaloezieLamelkleur.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList(growable: false);
    return resultaat.isEmpty ? standaardLamelkleuren : resultaat;
  }

  static List<OpmetingBuitenjaloezieGeleider> _leesGeleiders(Object? waarde) {
    if (waarde is! List) return standaardGeleiders;
    final resultaat = waarde
        .whereType<Map>()
        .map(
          (item) => OpmetingBuitenjaloezieGeleider.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList(growable: false);
    return resultaat.isEmpty ? standaardGeleiders : resultaat;
  }

  static List<String> _leesStrings(Object? waarde, List<String> standaard) {
    if (waarde is! List) return standaard;
    final resultaat = waarde
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    return resultaat.isEmpty ? standaard : resultaat;
  }

  static List<int> _leesIntLijst(Object? waarde, List<int> standaard) {
    if (waarde is! List) return standaard;
    final resultaat =
        waarde
            .map((item) => _leesInt(item, -1))
            .where((item) => item >= 0)
            .toSet()
            .toList()
          ..sort();
    return resultaat.isEmpty ? standaard : resultaat;
  }
}

int _leesInt(Object? waarde, int standaard) {
  if (waarde is int) return waarde;
  if (waarde is num) return waarde.toInt();
  return int.tryParse(waarde?.toString() ?? '') ?? standaard;
}
