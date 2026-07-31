// THIMACO-CONTROLE: VOORZETROLLUIK-ELEKTRISCHE-BEDIENING-COMPACT-ZONNECEL-20260731-1215
import '../../fotos/opmeting_foto_model.dart';

enum OpmetingVoorzetrolluikKastmaat { mm150, mm165, mm180, mm205, mm230 }

extension OpmetingVoorzetrolluikKastmaatExtension
    on OpmetingVoorzetrolluikKastmaat {
  int get millimeter {
    return switch (this) {
      OpmetingVoorzetrolluikKastmaat.mm150 => 150,
      OpmetingVoorzetrolluikKastmaat.mm165 => 165,
      OpmetingVoorzetrolluikKastmaat.mm180 => 180,
      OpmetingVoorzetrolluikKastmaat.mm205 => 205,
      OpmetingVoorzetrolluikKastmaat.mm230 => 230,
    };
  }

  String get label => '$millimeter × $millimeter mm';

  static OpmetingVoorzetrolluikKastmaat vanMillimeter(int waarde) {
    for (final maat in OpmetingVoorzetrolluikKastmaat.values) {
      if (maat.millimeter == waarde) return maat;
    }
    if (waarde <= 150) return OpmetingVoorzetrolluikKastmaat.mm150;
    if (waarde <= 165) return OpmetingVoorzetrolluikKastmaat.mm165;
    if (waarde <= 180) return OpmetingVoorzetrolluikKastmaat.mm180;
    if (waarde <= 205) return OpmetingVoorzetrolluikKastmaat.mm205;
    return OpmetingVoorzetrolluikKastmaat.mm230;
  }

  static OpmetingVoorzetrolluikKastmaat vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    for (final maat in OpmetingVoorzetrolluikKastmaat.values) {
      if (maat.name.toLowerCase() == tekst ||
          maat.millimeter.toString() == tekst) {
        return maat;
      }
    }
    return OpmetingVoorzetrolluikKastmaat.mm150;
  }
}

enum OpmetingVoorzetrolluikKastvorm { schuin, rond }

extension OpmetingVoorzetrolluikKastvormExtension
    on OpmetingVoorzetrolluikKastvorm {
  String get label {
    return switch (this) {
      OpmetingVoorzetrolluikKastvorm.schuin => 'Schuin',
      OpmetingVoorzetrolluikKastvorm.rond => 'Rond',
    };
  }

  static OpmetingVoorzetrolluikKastvorm vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    for (final vorm in OpmetingVoorzetrolluikKastvorm.values) {
      if (vorm.name.toLowerCase() == tekst ||
          vorm.label.toLowerCase() == tekst) {
        return vorm;
      }
    }
    return OpmetingVoorzetrolluikKastvorm.schuin;
  }
}

enum OpmetingVoorzetrolluikKleurbron { projectKleur, standaardPoederlak }

extension OpmetingVoorzetrolluikKleurbronExtension
    on OpmetingVoorzetrolluikKleurbron {
  String get label {
    return switch (this) {
      OpmetingVoorzetrolluikKleurbron.projectKleur => 'Projectkleur',
      OpmetingVoorzetrolluikKleurbron.standaardPoederlak =>
        'Standaard poederlak',
    };
  }

  static OpmetingVoorzetrolluikKleurbron vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    for (final bron in OpmetingVoorzetrolluikKleurbron.values) {
      if (bron.name.toLowerCase() == tekst ||
          bron.label.toLowerCase() == tekst) {
        return bron;
      }
    }
    return OpmetingVoorzetrolluikKleurbron.standaardPoederlak;
  }
}

enum OpmetingVoorzetrolluikBediening { elektrisch, lint }

extension OpmetingVoorzetrolluikBedieningExtension
    on OpmetingVoorzetrolluikBediening {
  String get label {
    return switch (this) {
      OpmetingVoorzetrolluikBediening.elektrisch => 'Elektrisch',
      OpmetingVoorzetrolluikBediening.lint => 'Lint',
    };
  }

  static OpmetingVoorzetrolluikBediening vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    for (final bediening in OpmetingVoorzetrolluikBediening.values) {
      if (bediening.name.toLowerCase() == tekst ||
          bediening.label.toLowerCase() == tekst) {
        return bediening;
      }
    }
    return OpmetingVoorzetrolluikBediening.elektrisch;
  }
}

enum OpmetingVoorzetrolluikKantLint { c1, c2, d1, d2 }

extension OpmetingVoorzetrolluikKantLintExtension
    on OpmetingVoorzetrolluikKantLint {
  String get label {
    return switch (this) {
      OpmetingVoorzetrolluikKantLint.c1 => 'C1',
      OpmetingVoorzetrolluikKantLint.c2 => 'C2',
      OpmetingVoorzetrolluikKantLint.d1 => 'D1',
      OpmetingVoorzetrolluikKantLint.d2 => 'D2',
    };
  }

  static OpmetingVoorzetrolluikKantLint vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    for (final keuze in OpmetingVoorzetrolluikKantLint.values) {
      if (keuze.name.toLowerCase() == tekst ||
          keuze.label.toLowerCase() == tekst) {
        return keuze;
      }
    }

    // Veilige omzetting van de tijdelijke oude keuzes.
    if (tekst == 'links') return OpmetingVoorzetrolluikKantLint.c1;
    if (tekst == 'rechts') return OpmetingVoorzetrolluikKantLint.d1;
    return OpmetingVoorzetrolluikKantLint.c1;
  }
}

enum OpmetingVoorzetrolluikBorenGeleiders { neen, voorkant, zijkant }

extension OpmetingVoorzetrolluikBorenGeleidersExtension
    on OpmetingVoorzetrolluikBorenGeleiders {
  String get label {
    return switch (this) {
      OpmetingVoorzetrolluikBorenGeleiders.neen => 'Neen',
      OpmetingVoorzetrolluikBorenGeleiders.voorkant => 'Voorkant',
      OpmetingVoorzetrolluikBorenGeleiders.zijkant => 'Zijkant',
    };
  }

  static OpmetingVoorzetrolluikBorenGeleiders vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    for (final keuze in OpmetingVoorzetrolluikBorenGeleiders.values) {
      if (keuze.name.toLowerCase() == tekst ||
          keuze.label.toLowerCase() == tekst) {
        return keuze;
      }
    }
    return OpmetingVoorzetrolluikBorenGeleiders.neen;
  }
}

class OpmetingVoorzetrolluikModel {
  const OpmetingVoorzetrolluikModel({
    this.positie = '',
    this.aantal = 1,
    this.breedteMm = 1000,
    this.hoogteMm = 1200,
    this.breedteInclusiefGeleiders = true,
    this.hoogteInclusiefKast = true,
    this.kastmaatVolgensAfmetingen = true,
    this.kastmaat = OpmetingVoorzetrolluikKastmaat.mm150,
    this.kastvorm = OpmetingVoorzetrolluikKastvorm.schuin,
    this.lamelType = 'WA39',
    this.lamelKleurNaam = '',
    this.lamelKleurCode = '',
    this.lamelKleurHex = '#D1D5DB',
    this.openLamellenPercentage = 50,
    this.borstelsInGeleiders = false,
    this.kleurbron = OpmetingVoorzetrolluikKleurbron.standaardPoederlak,
    this.projectKleurWaarde = '',
    this.kleurBenaming = '',
    this.poedercode = '',
    this.poederlakMogelijk = false,
    this.natlakMogelijk = false,
    this.bediening = OpmetingVoorzetrolluikBediening.elektrisch,
    this.kantLint = OpmetingVoorzetrolluikKantLint.c1,
    this.zonnecel = false,
    this.motorType = '',
    this.motorMerk = '',
    this.motorOmschrijving = '',
    this.motorExtraInfo = '',
    this.elektrischeBediening = 'Inbouwschakelaar',
    this.uitgangKabel = '',
    this.geleiderType = 'HTF25',
    this.borenGeleiders = OpmetingVoorzetrolluikBorenGeleiders.neen,
    this.notities = '',
    this.fotos = const <OpmetingFoto>[],
  });

  static const int aantalMinimum = 1;
  static const int aantalMaximum = 100;
  static const int breedteMinimumMm = 300;
  static const int breedteMaximumMm = 6000;
  static const int hoogteMinimumMm = 300;
  static const int hoogteMaximumMm = 6000;
  static const int geleiderBreedteMm = 28;
  static const int vrijeOnderruimteMm = 300;

  static const List<String> elektrischeBedieningKeuzes = <String>[
    'Inbouwschakelaar',
    'Handzender Somfy situo 1',
    'Handzender Somfy situo 5',
    'Muurzender Somfy Amy',
  ];

  final String positie;
  final int aantal;
  final int breedteMm;
  final int hoogteMm;
  final bool breedteInclusiefGeleiders;
  final bool hoogteInclusiefKast;
  final bool kastmaatVolgensAfmetingen;
  final OpmetingVoorzetrolluikKastmaat kastmaat;
  final OpmetingVoorzetrolluikKastvorm kastvorm;
  final String lamelType;
  final String lamelKleurNaam;
  final String lamelKleurCode;
  final String lamelKleurHex;
  final int openLamellenPercentage;
  final bool borstelsInGeleiders;
  final OpmetingVoorzetrolluikKleurbron kleurbron;
  final String projectKleurWaarde;
  final String kleurBenaming;
  final String poedercode;
  final bool poederlakMogelijk;
  final bool natlakMogelijk;
  final OpmetingVoorzetrolluikBediening bediening;
  final OpmetingVoorzetrolluikKantLint kantLint;
  final bool zonnecel;
  final String motorType;
  final String motorMerk;
  final String motorOmschrijving;
  final String motorExtraInfo;
  final String elektrischeBediening;
  final String uitgangKabel;
  final String geleiderType;
  final OpmetingVoorzetrolluikBorenGeleiders borenGeleiders;
  final String notities;
  final List<OpmetingFoto> fotos;

  int get buitenBreedteMm => breedteInclusiefGeleiders
      ? breedteMm
      : breedteMm + (geleiderBreedteMm * 2);

  int get buitenHoogteMm =>
      hoogteInclusiefKast ? hoogteMm : hoogteMm + kastmaat.millimeter;

  int get lamelHoogteMm {
    return switch (lamelType.trim().toUpperCase()) {
      'WP37' => 37,
      'WA55' || 'WA55H' => 55,
      _ => 39,
    };
  }

  bool get isElektrisch =>
      bediening == OpmetingVoorzetrolluikBediening.elektrisch;

  String get maatSamenvatting => '$breedteMm × $hoogteMm mm';

  String get kastSamenvatting {
    final voorvoegsel = kastmaatVolgensAfmetingen
        ? 'Volgens afmetingen · '
        : '';
    return '$voorvoegsel${kastmaat.label} · ${kastvorm.label}';
  }

  String get breedteMeetwijzeTekst =>
      breedteInclusiefGeleiders ? 'Inclusief geleiders' : 'Exclusief geleiders';

  String get hoogteMeetwijzeTekst =>
      hoogteInclusiefKast ? 'Inclusief kast' : 'Exclusief kast';

  String get lamelSamenvatting {
    final delen = <String>[
      lamelType.trim(),
      lamelKleurNaam.trim(),
      lamelKleurCode.trim(),
    ].where((deel) => deel.isNotEmpty).toList(growable: false);
    return delen.isEmpty ? 'Nog te bepalen' : delen.join(' · ');
  }

  String get kleurSamenvatting {
    if (kleurbron == OpmetingVoorzetrolluikKleurbron.projectKleur) {
      final projectKleur = projectKleurWaarde.trim();
      return projectKleur.isEmpty ? 'Projectkleur nog te kiezen' : projectKleur;
    }

    final naam = kleurBenaming.trim();
    final code = poedercode.trim();
    if (naam.isEmpty && code.isEmpty) return 'Nog te bepalen';
    if (code.isEmpty) return naam;
    if (naam.isEmpty) return code;
    return '$naam · $code';
  }

  String get motorSamenvatting {
    final delen = <String>[
      motorType.trim(),
      motorMerk.trim(),
      motorOmschrijving.trim(),
      motorExtraInfo.trim(),
    ].where((deel) => deel.isNotEmpty).toList(growable: false);
    return delen.isEmpty ? 'Nog te bepalen' : delen.join(' · ');
  }

  OpmetingVoorzetrolluikModel copyWith({
    String? positie,
    int? aantal,
    int? breedteMm,
    int? hoogteMm,
    bool? breedteInclusiefGeleiders,
    bool? hoogteInclusiefKast,
    bool? kastmaatVolgensAfmetingen,
    OpmetingVoorzetrolluikKastmaat? kastmaat,
    OpmetingVoorzetrolluikKastvorm? kastvorm,
    String? lamelType,
    String? lamelKleurNaam,
    String? lamelKleurCode,
    String? lamelKleurHex,
    int? openLamellenPercentage,
    bool? borstelsInGeleiders,
    OpmetingVoorzetrolluikKleurbron? kleurbron,
    String? projectKleurWaarde,
    String? kleurBenaming,
    String? poedercode,
    bool? poederlakMogelijk,
    bool? natlakMogelijk,
    OpmetingVoorzetrolluikBediening? bediening,
    OpmetingVoorzetrolluikKantLint? kantLint,
    bool? zonnecel,
    String? motorType,
    String? motorMerk,
    String? motorOmschrijving,
    String? motorExtraInfo,
    String? elektrischeBediening,
    String? uitgangKabel,
    String? geleiderType,
    OpmetingVoorzetrolluikBorenGeleiders? borenGeleiders,
    String? notities,
    List<OpmetingFoto>? fotos,
  }) {
    final nieuweBediening = bediening ?? this.bediening;
    final elektrisch =
        nieuweBediening == OpmetingVoorzetrolluikBediening.elektrisch;
    return OpmetingVoorzetrolluikModel(
      positie: positie ?? this.positie,
      aantal: (aantal ?? this.aantal)
          .clamp(aantalMinimum, aantalMaximum)
          .toInt(),
      breedteMm: (breedteMm ?? this.breedteMm)
          .clamp(breedteMinimumMm, breedteMaximumMm)
          .toInt(),
      hoogteMm: (hoogteMm ?? this.hoogteMm)
          .clamp(hoogteMinimumMm, hoogteMaximumMm)
          .toInt(),
      breedteInclusiefGeleiders:
          breedteInclusiefGeleiders ?? this.breedteInclusiefGeleiders,
      hoogteInclusiefKast: hoogteInclusiefKast ?? this.hoogteInclusiefKast,
      kastmaatVolgensAfmetingen:
          kastmaatVolgensAfmetingen ?? this.kastmaatVolgensAfmetingen,
      kastmaat: kastmaat ?? this.kastmaat,
      kastvorm: kastvorm ?? this.kastvorm,
      lamelType: _normaliseerLamelType(lamelType ?? this.lamelType),
      lamelKleurNaam: lamelKleurNaam ?? this.lamelKleurNaam,
      lamelKleurCode: lamelKleurCode ?? this.lamelKleurCode,
      lamelKleurHex: _normaliseerHex(lamelKleurHex ?? this.lamelKleurHex),
      openLamellenPercentage:
          (openLamellenPercentage ?? this.openLamellenPercentage)
              .clamp(0, 100)
              .toInt(),
      borstelsInGeleiders: borstelsInGeleiders ?? this.borstelsInGeleiders,
      kleurbron: kleurbron ?? this.kleurbron,
      projectKleurWaarde: projectKleurWaarde ?? this.projectKleurWaarde,
      kleurBenaming: kleurBenaming ?? this.kleurBenaming,
      poedercode: poedercode ?? this.poedercode,
      poederlakMogelijk: poederlakMogelijk ?? this.poederlakMogelijk,
      natlakMogelijk: natlakMogelijk ?? this.natlakMogelijk,
      bediening: nieuweBediening,
      kantLint: kantLint ?? this.kantLint,
      zonnecel: elektrisch ? (zonnecel ?? this.zonnecel) : false,
      motorType: elektrisch ? (motorType ?? this.motorType) : '',
      motorMerk: elektrisch ? (motorMerk ?? this.motorMerk) : '',
      motorOmschrijving: elektrisch
          ? (motorOmschrijving ?? this.motorOmschrijving)
          : '',
      motorExtraInfo: elektrisch ? (motorExtraInfo ?? this.motorExtraInfo) : '',
      elektrischeBediening: _normaliseerElektrischeBediening(
        elektrischeBediening ?? this.elektrischeBediening,
      ),
      uitgangKabel: elektrisch ? (uitgangKabel ?? this.uitgangKabel) : '',
      geleiderType: geleiderType ?? this.geleiderType,
      borenGeleiders: borenGeleiders ?? this.borenGeleiders,
      notities: notities ?? this.notities,
      fotos: fotos ?? this.fotos,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'positie': positie,
      'aantal': aantal,
      'breedteMm': breedteMm,
      'hoogteMm': hoogteMm,
      'breedteInclusiefGeleiders': breedteInclusiefGeleiders,
      'hoogteInclusiefKast': hoogteInclusiefKast,
      'kastmaatVolgensAfmetingen': kastmaatVolgensAfmetingen,
      'kastmaat': kastmaat.name,
      'kastvorm': kastvorm.name,
      'lamelType': lamelType,
      'lamelKleurNaam': lamelKleurNaam,
      'lamelKleurCode': lamelKleurCode,
      'lamelKleurHex': lamelKleurHex,
      'openLamellenPercentage': openLamellenPercentage,
      'borstelsInGeleiders': borstelsInGeleiders,
      'kleurbron': kleurbron.name,
      'projectKleurWaarde': projectKleurWaarde,
      'kleurBenaming': kleurBenaming,
      'poedercode': poedercode,
      'poederlakMogelijk': poederlakMogelijk,
      'natlakMogelijk': natlakMogelijk,
      'bediening': bediening.name,
      'kantLint': kantLint.name,
      'zonnecel': zonnecel,
      'motorType': motorType,
      'motorMerk': motorMerk,
      'motorOmschrijving': motorOmschrijving,
      'motorExtraInfo': motorExtraInfo,
      'elektrischeBediening': elektrischeBediening,
      'uitgangKabel': uitgangKabel,
      'geleiderType': geleiderType,
      'borenGeleiders': borenGeleiders.name,
      'notities': notities,
      'fotos': fotos.map((foto) => foto.toJson()).toList(growable: false),
    };
  }

  factory OpmetingVoorzetrolluikModel.fromJson(Map<String, dynamic> json) {
    return OpmetingVoorzetrolluikModel(
      positie: json['positie']?.toString() ?? '',
      aantal: _leesInt(json['aantal'], 1),
      breedteMm: _leesInt(json['breedteMm'], 1000),
      hoogteMm: _leesInt(json['hoogteMm'], 1200),
      breedteInclusiefGeleiders: json['breedteInclusiefGeleiders'] != false,
      hoogteInclusiefKast: json['hoogteInclusiefKast'] != false,
      kastmaatVolgensAfmetingen: json['kastmaatVolgensAfmetingen'] != false,
      kastmaat: OpmetingVoorzetrolluikKastmaatExtension.vanOpslagWaarde(
        json['kastmaat'],
      ),
      kastvorm: OpmetingVoorzetrolluikKastvormExtension.vanOpslagWaarde(
        json['kastvorm'],
      ),
      lamelType: _normaliseerLamelType(json['lamelType']?.toString() ?? 'WA39'),
      lamelKleurNaam: json['lamelKleurNaam']?.toString() ?? '',
      lamelKleurCode: json['lamelKleurCode']?.toString() ?? '',
      lamelKleurHex: _normaliseerHex(
        json['lamelKleurHex']?.toString() ?? '#D1D5DB',
      ),
      openLamellenPercentage: _leesInt(json['openLamellenPercentage'], 50),
      borstelsInGeleiders: json['borstelsInGeleiders'] == true,
      kleurbron: OpmetingVoorzetrolluikKleurbronExtension.vanOpslagWaarde(
        json['kleurbron'],
      ),
      projectKleurWaarde: json['projectKleurWaarde']?.toString() ?? '',
      kleurBenaming: json['kleurBenaming']?.toString() ?? '',
      poedercode: json['poedercode']?.toString() ?? '',
      poederlakMogelijk: json['poederlakMogelijk'] == true,
      natlakMogelijk: json['natlakMogelijk'] == true,
      bediening: OpmetingVoorzetrolluikBedieningExtension.vanOpslagWaarde(
        json['bediening'],
      ),
      kantLint: OpmetingVoorzetrolluikKantLintExtension.vanOpslagWaarde(
        json['kantLint'],
      ),
      zonnecel: json['zonnecel'] == true,
      motorType: json['motorType']?.toString() ?? '',
      motorMerk: json['motorMerk']?.toString() ?? '',
      motorOmschrijving: json['motorOmschrijving']?.toString() ?? '',
      motorExtraInfo: json['motorExtraInfo']?.toString() ?? '',
      elektrischeBediening: _normaliseerElektrischeBediening(
        json['elektrischeBediening']?.toString() ?? 'Inbouwschakelaar',
      ),
      uitgangKabel: json['uitgangKabel']?.toString() ?? '',
      geleiderType: json['geleiderType']?.toString() ?? 'HTF25',
      borenGeleiders:
          OpmetingVoorzetrolluikBorenGeleidersExtension.vanOpslagWaarde(
            json['borenGeleiders'],
          ),
      notities: json['notities']?.toString() ?? '',
      fotos: _leesFotos(json['fotos']),
    ).copyWith();
  }

  static int _leesInt(Object? waarde, int standaard) {
    if (waarde is int) return waarde;
    if (waarde is num) return waarde.toInt();
    return int.tryParse(waarde?.toString() ?? '') ?? standaard;
  }

  static String _normaliseerLamelType(String waarde) {
    final schoon = waarde.trim().toUpperCase();
    return switch (schoon) {
      'WA39' || 'WA39H' || 'WA55' || 'WA55H' || 'WP37' => schoon,
      'WA40' => 'WA55',
      'WA40H' => 'WA55H',
      _ => 'WA39',
    };
  }

  static String _normaliseerElektrischeBediening(String waarde) {
    final schoon = waarde.trim();
    for (final keuze in elektrischeBedieningKeuzes) {
      if (keuze.toLowerCase() == schoon.toLowerCase()) return keuze;
    }
    return elektrischeBedieningKeuzes.first;
  }

  static String _normaliseerHex(String waarde) {
    final tekst = waarde.trim().toUpperCase();
    final zonderHekje = tekst.startsWith('#') ? tekst.substring(1) : tekst;
    return RegExp(r'^[0-9A-F]{6}$').hasMatch(zonderHekje)
        ? '#$zonderHekje'
        : '#D1D5DB';
  }

  static List<OpmetingFoto> _leesFotos(Object? waarde) {
    if (waarde is! List) return const <OpmetingFoto>[];
    return waarde
        .whereType<Map>()
        .map((item) => OpmetingFoto.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }
}
