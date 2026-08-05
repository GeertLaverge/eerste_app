// THIMACO-CONTROLE: BUITENJALOEZIE-KLINKER-ENKEL-MODULO-MODEL-20260804
// THIMACO-CONTROLE: BUITENJALOEZIE-STANDAARD-GELEIDER-12-20260803
// THIMACO-CONTROLE: BUITENJALOEZIE-MODEL-FASE-1-20260803

import '../../fotos/opmeting_foto_model.dart';

enum OpmetingBuitenjaloezieSysteem {
  moduloP,
  moduloXp,
  rondoP,
  rondoXp,
  pentoP,
  pentoXp,
}

extension OpmetingBuitenjaloezieSysteemExtension
    on OpmetingBuitenjaloezieSysteem {
  String get label {
    return switch (this) {
      OpmetingBuitenjaloezieSysteem.moduloP => 'MODULO.P',
      OpmetingBuitenjaloezieSysteem.moduloXp => 'MODULO.XP',
      OpmetingBuitenjaloezieSysteem.rondoP => 'RONDO.P-RS',
      OpmetingBuitenjaloezieSysteem.rondoXp => 'RONDO.XP-RS',
      OpmetingBuitenjaloezieSysteem.pentoP => 'PENTO.P-RS',
      OpmetingBuitenjaloezieSysteem.pentoXp => 'PENTO.XP-RS',
    };
  }

  String get familieLabel {
    return switch (this) {
      OpmetingBuitenjaloezieSysteem.moduloP ||
      OpmetingBuitenjaloezieSysteem.moduloXp => 'MODULO',
      OpmetingBuitenjaloezieSysteem.rondoP ||
      OpmetingBuitenjaloezieSysteem.rondoXp => 'RAFSTORE RONDO',
      OpmetingBuitenjaloezieSysteem.pentoP ||
      OpmetingBuitenjaloezieSysteem.pentoXp => 'RAFSTORE PENTO',
    };
  }

  bool get metRolhor {
    return switch (this) {
      OpmetingBuitenjaloezieSysteem.moduloXp ||
      OpmetingBuitenjaloezieSysteem.rondoXp ||
      OpmetingBuitenjaloezieSysteem.pentoXp => true,
      _ => false,
    };
  }

  bool get isModulo =>
      this == OpmetingBuitenjaloezieSysteem.moduloP ||
      this == OpmetingBuitenjaloezieSysteem.moduloXp;

  bool get isRondo =>
      this == OpmetingBuitenjaloezieSysteem.rondoP ||
      this == OpmetingBuitenjaloezieSysteem.rondoXp;

  bool get isPento =>
      this == OpmetingBuitenjaloezieSysteem.pentoP ||
      this == OpmetingBuitenjaloezieSysteem.pentoXp;

  OpmetingBuitenjaloezieSysteem get basisVariant => metRolhor
      ? OpmetingBuitenjaloezieSysteem.moduloXp
      : OpmetingBuitenjaloezieSysteem.moduloP;

  String get omschrijving {
    final rolhorTekst = metRolhor
        ? 'Met geïntegreerde insectenhor'
        : 'Zonder geïntegreerde insectenhor';
    return '$familieLabel · $rolhorTekst';
  }

  static OpmetingBuitenjaloezieSysteem vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    return switch (tekst) {
      'moduloxp' ||
      'modulo_xp' ||
      'modulo.xp' ||
      'xp' => OpmetingBuitenjaloezieSysteem.moduloXp,
      'rondop' ||
      'rondo_p' ||
      'rondo.p-rs' ||
      'rondo.p' ||
      'rondo p' ||
      'rondo-prs' ||
      'rondo.p_rs' => OpmetingBuitenjaloezieSysteem.rondoP,
      'rondoxp' ||
      'rondo_xp' ||
      'rondo.xp-rs' ||
      'rondo.xp' ||
      'rondo xp' ||
      'rondo-xp-rs' => OpmetingBuitenjaloezieSysteem.rondoXp,
      'pentop' ||
      'pento_p' ||
      'pento.p-rs' ||
      'pento.p' ||
      'pento p' ||
      'pento-prs' => OpmetingBuitenjaloezieSysteem.pentoP,
      'pentoxp' ||
      'pento_xp' ||
      'pento.xp-rs' ||
      'pento.xp' ||
      'pento xp' ||
      'pento-xp-rs' => OpmetingBuitenjaloezieSysteem.pentoXp,
      _ => OpmetingBuitenjaloezieSysteem.moduloP,
    };
  }
}

enum OpmetingBuitenjaloezieLameltype { cdl70, zl81, dbl70, gl80, fl80 }

extension OpmetingBuitenjaloezieLameltypeExtension
    on OpmetingBuitenjaloezieLameltype {
  String get label {
    return switch (this) {
      OpmetingBuitenjaloezieLameltype.cdl70 => 'CDL 70',
      OpmetingBuitenjaloezieLameltype.zl81 => 'ZL 81',
      OpmetingBuitenjaloezieLameltype.dbl70 => 'DBL 70',
      OpmetingBuitenjaloezieLameltype.gl80 => 'GL 80',
      OpmetingBuitenjaloezieLameltype.fl80 => 'FL 80',
    };
  }

  int get nominaleBreedteMm {
    return switch (this) {
      OpmetingBuitenjaloezieLameltype.cdl70 => 70,
      OpmetingBuitenjaloezieLameltype.zl81 => 81,
      OpmetingBuitenjaloezieLameltype.dbl70 => 70,
      OpmetingBuitenjaloezieLameltype.gl80 => 80,
      OpmetingBuitenjaloezieLameltype.fl80 => 80,
    };
  }

  bool get alleenStaaldraad => this == OpmetingBuitenjaloezieLameltype.fl80;

  int get maximaleBreedteMm => 4000;

  double get maximaleOppervlakteM2 {
    return switch (this) {
      OpmetingBuitenjaloezieLameltype.cdl70 ||
      OpmetingBuitenjaloezieLameltype.zl81 ||
      OpmetingBuitenjaloezieLameltype.dbl70 => 18.0,
      OpmetingBuitenjaloezieLameltype.gl80 => 20.0,
      OpmetingBuitenjaloezieLameltype.fl80 => 17.0,
    };
  }

  int get maximaleElementHoogteMm {
    return switch (this) {
      OpmetingBuitenjaloezieLameltype.cdl70 ||
      OpmetingBuitenjaloezieLameltype.zl81 ||
      OpmetingBuitenjaloezieLameltype.dbl70 => 4500,
      OpmetingBuitenjaloezieLameltype.gl80 => 5000,
      OpmetingBuitenjaloezieLameltype.fl80 => 4250,
    };
  }

  static OpmetingBuitenjaloezieLameltype vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    return switch (tekst) {
      'zl81' || 'zl_81' || 'zl 81' => OpmetingBuitenjaloezieLameltype.zl81,
      'dbl70' || 'dbl_70' || 'dbl 70' => OpmetingBuitenjaloezieLameltype.dbl70,
      'gl80' || 'gl_80' || 'gl 80' => OpmetingBuitenjaloezieLameltype.gl80,
      'fl80' || 'fl_80' || 'fl 80' => OpmetingBuitenjaloezieLameltype.fl80,
      _ => OpmetingBuitenjaloezieLameltype.cdl70,
    };
  }
}

enum OpmetingBuitenjaloezieLadderkoord { grijs, zwart }

extension OpmetingBuitenjaloezieLadderkoordExtension
    on OpmetingBuitenjaloezieLadderkoord {
  String get label =>
      this == OpmetingBuitenjaloezieLadderkoord.grijs ? 'Grijs' : 'Zwart';

  static OpmetingBuitenjaloezieLadderkoord vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    return tekst == 'zwart'
        ? OpmetingBuitenjaloezieLadderkoord.zwart
        : OpmetingBuitenjaloezieLadderkoord.grijs;
  }
}

enum OpmetingBuitenjaloezieMotorType { bekabeld, io }

extension OpmetingBuitenjaloezieMotorTypeExtension
    on OpmetingBuitenjaloezieMotorType {
  String get label =>
      this == OpmetingBuitenjaloezieMotorType.bekabeld ? 'Bekabeld' : 'IO';

  static OpmetingBuitenjaloezieMotorType vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    return tekst == 'io'
        ? OpmetingBuitenjaloezieMotorType.io
        : OpmetingBuitenjaloezieMotorType.bekabeld;
  }
}

enum OpmetingBuitenjaloezieBedieningszijde { links, rechts }

extension OpmetingBuitenjaloezieBedieningszijdeExtension
    on OpmetingBuitenjaloezieBedieningszijde {
  String get label =>
      this == OpmetingBuitenjaloezieBedieningszijde.links ? 'Links' : 'Rechts';

  static OpmetingBuitenjaloezieBedieningszijde vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    return tekst == 'rechts'
        ? OpmetingBuitenjaloezieBedieningszijde.rechts
        : OpmetingBuitenjaloezieBedieningszijde.links;
  }
}

enum OpmetingBuitenjaloezieBoring { tegenRaam, inDag }

extension OpmetingBuitenjaloezieBoringExtension
    on OpmetingBuitenjaloezieBoring {
  String get label {
    return switch (this) {
      OpmetingBuitenjaloezieBoring.tegenRaam => 'Tegen het raam',
      OpmetingBuitenjaloezieBoring.inDag => 'In de dag',
    };
  }

  static OpmetingBuitenjaloezieBoring vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    return tekst == 'indag' || tekst == 'in_dag' || tekst == 'in de dag'
        ? OpmetingBuitenjaloezieBoring.inDag
        : OpmetingBuitenjaloezieBoring.tegenRaam;
  }
}

class OpmetingBuitenjaloezieModel {
  const OpmetingBuitenjaloezieModel({
    this.referentie = '',
    this.aantal = 1,
    this.breedteMm = 1100,
    this.hoogteMm = 1600,
    this.breedteTussenGeleiders = true,
    this.hoogteInclusiefKast = true,
    this.systeem = OpmetingBuitenjaloezieSysteem.moduloP,
    this.lameltype = OpmetingBuitenjaloezieLameltype.cdl70,
    this.kastHoogteMm = 240,
    this.lamellenpakketUitsteekMm = 0,
    this.lamelkleurCode = '301',
    this.lamelkleurNaam = 'Lichtgrau',
    this.lamelkleurHex = '#D9D9D7',
    this.ladderkoord = OpmetingBuitenjaloezieLadderkoord.grijs,
    this.motorType = OpmetingBuitenjaloezieMotorType.bekabeld,
    this.bediening = 'Inbouwschakelaar',
    this.motorkabelMeter = 5,
    this.bedieningszijde = OpmetingBuitenjaloezieBedieningszijde.links,
    this.kabeluitgang = 1,
    this.boring = OpmetingBuitenjaloezieBoring.tegenRaam,
    this.afschuiningGeleidersGraden = 0,
    this.geleiderCode = '12',
    this.geleiderOmschrijving = '53 × 69 mm',
    this.geleiderBreedteMm = 53,
    this.klinkeruitvoering = false,
    this.onderGesloten = false,
    this.notities = '',
    this.fotos = const <OpmetingFoto>[],
  });

  static const int aantalMinimum = 1;
  static const int aantalMaximum = 999;
  static const int breedteMinimumMm = 250;
  static const int breedteMaximumMm = 4000;
  static const int hoogteMinimumMm = 250;
  static const int hoogteMaximumMm = 5000;

  static const int lamelTekeningHoogteMm = 20;
  static const int vrijeRuimteTussenLamellenMm = 30;
  static const int lamelSteekMm =
      lamelTekeningHoogteMm + vrijeRuimteTussenLamellenMm;

  final String referentie;
  final int aantal;
  final int breedteMm;
  final int hoogteMm;
  final bool breedteTussenGeleiders;
  final bool hoogteInclusiefKast;
  final OpmetingBuitenjaloezieSysteem systeem;
  final OpmetingBuitenjaloezieLameltype lameltype;
  final int kastHoogteMm;

  /// Automatisch berekend resultaat uit de Raffstore-kasttabel.
  /// Dit is geen gebruikersinvoer.
  final int lamellenpakketUitsteekMm;
  final String lamelkleurCode;
  final String lamelkleurNaam;
  final String lamelkleurHex;
  final OpmetingBuitenjaloezieLadderkoord ladderkoord;
  final OpmetingBuitenjaloezieMotorType motorType;
  final String bediening;
  final int motorkabelMeter;
  final OpmetingBuitenjaloezieBedieningszijde bedieningszijde;
  final int kabeluitgang;
  final OpmetingBuitenjaloezieBoring boring;
  final int afschuiningGeleidersGraden;
  final String geleiderCode;
  final String geleiderOmschrijving;
  final int geleiderBreedteMm;
  final bool klinkeruitvoering;
  final bool onderGesloten;
  final String notities;
  final List<OpmetingFoto> fotos;

  int get totaleBreedteMm =>
      breedteTussenGeleiders ? breedteMm + geleiderBreedteMm * 2 : breedteMm;

  int get vrijeBreedteMm =>
      breedteTussenGeleiders ? breedteMm : breedteMm - geleiderBreedteMm * 2;

  int get totaleHoogteMm =>
      hoogteInclusiefKast ? hoogteMm : hoogteMm + kastHoogteMm;

  int get geleiderHoogteMm =>
      hoogteInclusiefKast ? hoogteMm - kastHoogteMm : hoogteMm;

  String get systeemSamenvatting =>
      '${systeem.label} · ${systeem.omschrijving}';

  String get breedteMeetwijzeTekst =>
      breedteTussenGeleiders ? 'Tussen de geleiders' : 'Inclusief geleiders';

  String get hoogteMeetwijzeTekst =>
      hoogteInclusiefKast ? 'Inclusief kast' : 'Exclusief kast';

  String get lamelkleurSamenvatting {
    final code = lamelkleurCode.trim();
    final naam = lamelkleurNaam.trim();
    if (code.isEmpty) return naam;
    if (naam.isEmpty) return code;
    return '$code $naam';
  }

  String get geleiderSamenvatting {
    final code = geleiderCode.trim();
    final omschrijving = geleiderOmschrijving.trim();
    if (code.isEmpty) return omschrijving;
    if (omschrijving.isEmpty) return code;
    return '$code · $omschrijving';
  }

  double get oppervlakteM2 => totaleBreedteMm * totaleHoogteMm / 1000000.0;

  bool get pastBinnenLamelGrenzen =>
      totaleBreedteMm <= lameltype.maximaleBreedteMm &&
      totaleHoogteMm <= lameltype.maximaleElementHoogteMm &&
      oppervlakteM2 <= lameltype.maximaleOppervlakteM2;

  OpmetingBuitenjaloezieModel copyWith({
    String? referentie,
    int? aantal,
    int? breedteMm,
    int? hoogteMm,
    bool? breedteTussenGeleiders,
    bool? hoogteInclusiefKast,
    OpmetingBuitenjaloezieSysteem? systeem,
    OpmetingBuitenjaloezieLameltype? lameltype,
    int? kastHoogteMm,
    int? lamellenpakketUitsteekMm,
    String? lamelkleurCode,
    String? lamelkleurNaam,
    String? lamelkleurHex,
    OpmetingBuitenjaloezieLadderkoord? ladderkoord,
    OpmetingBuitenjaloezieMotorType? motorType,
    String? bediening,
    int? motorkabelMeter,
    OpmetingBuitenjaloezieBedieningszijde? bedieningszijde,
    int? kabeluitgang,
    OpmetingBuitenjaloezieBoring? boring,
    int? afschuiningGeleidersGraden,
    String? geleiderCode,
    String? geleiderOmschrijving,
    int? geleiderBreedteMm,
    bool? klinkeruitvoering,
    bool? onderGesloten,
    String? notities,
    List<OpmetingFoto>? fotos,
  }) {
    var nieuwSysteem = systeem ?? this.systeem;
    var nieuwLameltype = lameltype ?? this.lameltype;

    if (nieuwSysteem.metRolhor &&
        nieuwLameltype == OpmetingBuitenjaloezieLameltype.fl80) {
      nieuwLameltype = OpmetingBuitenjaloezieLameltype.cdl70;
    }

    return OpmetingBuitenjaloezieModel(
      referentie: referentie ?? this.referentie,
      aantal: (aantal ?? this.aantal)
          .clamp(aantalMinimum, aantalMaximum)
          .toInt(),
      breedteMm: (breedteMm ?? this.breedteMm)
          .clamp(breedteMinimumMm, breedteMaximumMm)
          .toInt(),
      hoogteMm: (hoogteMm ?? this.hoogteMm)
          .clamp(hoogteMinimumMm, hoogteMaximumMm)
          .toInt(),
      breedteTussenGeleiders:
          breedteTussenGeleiders ?? this.breedteTussenGeleiders,
      hoogteInclusiefKast: hoogteInclusiefKast ?? this.hoogteInclusiefKast,
      systeem: nieuwSysteem,
      lameltype: nieuwLameltype,
      kastHoogteMm: kastHoogteMm ?? this.kastHoogteMm,
      lamellenpakketUitsteekMm: _normaliseerUitsteek(
        lamellenpakketUitsteekMm ?? this.lamellenpakketUitsteekMm,
      ),
      lamelkleurCode: lamelkleurCode ?? this.lamelkleurCode,
      lamelkleurNaam: lamelkleurNaam ?? this.lamelkleurNaam,
      lamelkleurHex: lamelkleurHex ?? this.lamelkleurHex,
      ladderkoord: ladderkoord ?? this.ladderkoord,
      motorType: motorType ?? this.motorType,
      bediening: bediening ?? this.bediening,
      motorkabelMeter: motorkabelMeter ?? this.motorkabelMeter,
      bedieningszijde: bedieningszijde ?? this.bedieningszijde,
      kabeluitgang: (kabeluitgang ?? this.kabeluitgang).clamp(1, 4).toInt(),
      boring: boring ?? this.boring,
      afschuiningGeleidersGraden:
          (afschuiningGeleidersGraden ?? this.afschuiningGeleidersGraden)
              .clamp(0, 45)
              .toInt(),
      geleiderCode: geleiderCode ?? this.geleiderCode,
      geleiderOmschrijving: geleiderOmschrijving ?? this.geleiderOmschrijving,
      geleiderBreedteMm: geleiderBreedteMm ?? this.geleiderBreedteMm,
      klinkeruitvoering: nieuwSysteem.isModulo
          ? (klinkeruitvoering ?? this.klinkeruitvoering)
          : false,
      onderGesloten: onderGesloten ?? this.onderGesloten,
      notities: notities ?? this.notities,
      fotos: fotos ?? this.fotos,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'referentie': referentie,
      'aantal': aantal,
      'breedteMm': breedteMm,
      'hoogteMm': hoogteMm,
      'breedteTussenGeleiders': breedteTussenGeleiders,
      'hoogteInclusiefKast': hoogteInclusiefKast,
      'systeem': systeem.name,
      'lameltype': lameltype.name,
      'kastHoogteMm': kastHoogteMm,
      'lamellenpakketUitsteekMm': lamellenpakketUitsteekMm,
      'lamelkleurCode': lamelkleurCode,
      'lamelkleurNaam': lamelkleurNaam,
      'lamelkleurHex': lamelkleurHex,
      'ladderkoord': ladderkoord.name,
      'motorType': motorType.name,
      'bediening': bediening,
      'motorkabelMeter': motorkabelMeter,
      'bedieningszijde': bedieningszijde.name,
      'kabeluitgang': kabeluitgang,
      'boring': boring.name,
      'afschuiningGeleidersGraden': afschuiningGeleidersGraden,
      'geleiderCode': geleiderCode,
      'geleiderOmschrijving': geleiderOmschrijving,
      'geleiderBreedteMm': geleiderBreedteMm,
      'klinkeruitvoering': klinkeruitvoering,
      'onderGesloten': onderGesloten,
      'notities': notities,
      'fotos': fotos.map((foto) => foto.toJson()).toList(growable: false),
    };
  }

  factory OpmetingBuitenjaloezieModel.fromJson(Map<String, dynamic> json) {
    return OpmetingBuitenjaloezieModel(
      referentie: json['referentie']?.toString() ?? '',
      aantal: _leesInt(json['aantal'], 1),
      breedteMm: _leesInt(json['breedteMm'], 1100),
      hoogteMm: _leesInt(json['hoogteMm'], 1600),
      breedteTussenGeleiders: json['breedteTussenGeleiders'] != false,
      hoogteInclusiefKast: json['hoogteInclusiefKast'] != false,
      systeem: OpmetingBuitenjaloezieSysteemExtension.vanOpslagWaarde(
        json['systeem'],
      ),
      lameltype: OpmetingBuitenjaloezieLameltypeExtension.vanOpslagWaarde(
        json['lameltype'],
      ),
      kastHoogteMm: _leesInt(json['kastHoogteMm'], 240),
      lamellenpakketUitsteekMm: _normaliseerUitsteek(
        _leesInt(json['lamellenpakketUitsteekMm'], 0),
      ),
      lamelkleurCode: json['lamelkleurCode']?.toString() ?? '301',
      lamelkleurNaam: json['lamelkleurNaam']?.toString() ?? 'Lichtgrau',
      lamelkleurHex: json['lamelkleurHex']?.toString() ?? '#D9D9D7',
      ladderkoord: OpmetingBuitenjaloezieLadderkoordExtension.vanOpslagWaarde(
        json['ladderkoord'],
      ),
      motorType: OpmetingBuitenjaloezieMotorTypeExtension.vanOpslagWaarde(
        json['motorType'],
      ),
      bediening: json['bediening']?.toString() ?? 'Inbouwschakelaar',
      motorkabelMeter: _leesInt(json['motorkabelMeter'], 5),
      bedieningszijde:
          OpmetingBuitenjaloezieBedieningszijdeExtension.vanOpslagWaarde(
            json['bedieningszijde'],
          ),
      kabeluitgang: _leesInt(json['kabeluitgang'], 1),
      boring: OpmetingBuitenjaloezieBoringExtension.vanOpslagWaarde(
        json['boring'],
      ),
      afschuiningGeleidersGraden: _leesInt(
        json['afschuiningGeleidersGraden'],
        0,
      ),
      geleiderCode: json['geleiderCode']?.toString() ?? '12',
      geleiderOmschrijving:
          json['geleiderOmschrijving']?.toString() ?? '53 × 69 mm',
      geleiderBreedteMm: _leesInt(json['geleiderBreedteMm'], 53),
      klinkeruitvoering: json['klinkeruitvoering'] == true,
      onderGesloten: json['onderGesloten'] == true,
      notities: json['notities']?.toString() ?? '',
      fotos: _leesFotos(json['fotos']),
    ).copyWith();
  }

  static const List<int> toegestaneUitstekenMm = <int>[0, 15, 30, 45];

  static int _normaliseerUitsteek(int waarde) {
    return toegestaneUitstekenMm.reduce(
      (beste, huidig) =>
          (huidig - waarde).abs() < (beste - waarde).abs() ? huidig : beste,
    );
  }

  static int _leesInt(Object? waarde, int standaard) {
    if (waarde is int) return waarde;
    if (waarde is num) return waarde.toInt();
    return int.tryParse(waarde?.toString() ?? '') ?? standaard;
  }

  static List<OpmetingFoto> _leesFotos(Object? waarde) {
    if (waarde is! List) return const <OpmetingFoto>[];
    return waarde
        .whereType<Map>()
        .map((item) => OpmetingFoto.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }
}
