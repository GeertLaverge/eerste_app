// THIMACO-CONTROLE: VOORZETSCREEN-KASTREGELS-ZONNECEL-20260811
// THIMACO-CONTROLE: VOORZETSCREEN-MODEL-BEDIENING-20260730-2115
import '../../fotos/opmeting_foto_model.dart';

enum OpmetingVoorzetscreenKastmaat { mm85, mm95, mm120 }

extension OpmetingVoorzetscreenKastmaatExtension
    on OpmetingVoorzetscreenKastmaat {
  int get millimeter {
    switch (this) {
      case OpmetingVoorzetscreenKastmaat.mm85:
        return 85;
      case OpmetingVoorzetscreenKastmaat.mm95:
        return 95;
      case OpmetingVoorzetscreenKastmaat.mm120:
        return 120;
    }
  }

  String get label => '$millimeter × $millimeter mm';

  static OpmetingVoorzetscreenKastmaat vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    for (final maat in OpmetingVoorzetscreenKastmaat.values) {
      if (maat.name.toLowerCase() == tekst ||
          maat.millimeter.toString() == tekst) {
        return maat;
      }
    }
    return OpmetingVoorzetscreenKastmaat.mm95;
  }
}

enum OpmetingVoorzetscreenKastvorm { recht, schuin, rond }

extension OpmetingVoorzetscreenKastvormExtension
    on OpmetingVoorzetscreenKastvorm {
  String get label {
    switch (this) {
      case OpmetingVoorzetscreenKastvorm.recht:
        return 'Recht';
      case OpmetingVoorzetscreenKastvorm.schuin:
        return 'Schuin';
      case OpmetingVoorzetscreenKastvorm.rond:
        return 'Rond';
    }
  }

  static OpmetingVoorzetscreenKastvorm vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    for (final vorm in OpmetingVoorzetscreenKastvorm.values) {
      if (vorm.name.toLowerCase() == tekst ||
          vorm.label.toLowerCase() == tekst) {
        return vorm;
      }
    }
    return OpmetingVoorzetscreenKastvorm.recht;
  }
}

enum OpmetingVoorzetscreenKleurbron { projectKleur, standaardPoederlak }

extension OpmetingVoorzetscreenKleurbronExtension
    on OpmetingVoorzetscreenKleurbron {
  String get label {
    switch (this) {
      case OpmetingVoorzetscreenKleurbron.projectKleur:
        return 'Project kleur';
      case OpmetingVoorzetscreenKleurbron.standaardPoederlak:
        return 'Standaard poederlak';
    }
  }

  static OpmetingVoorzetscreenKleurbron vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    for (final bron in OpmetingVoorzetscreenKleurbron.values) {
      if (bron.name.toLowerCase() == tekst ||
          bron.label.toLowerCase() == tekst) {
        return bron;
      }
    }
    return OpmetingVoorzetscreenKleurbron.standaardPoederlak;
  }
}

class OpmetingVoorzetscreenModel {
  const OpmetingVoorzetscreenModel({
    this.positie = '',
    this.aantal = 1,
    this.breedteMm = 1000,
    this.hoogteMm = 1200,
    this.breedteInclusiefGeleiders = true,
    this.hoogteInclusiefKast = true,
    this.kastmaat = OpmetingVoorzetscreenKastmaat.mm95,
    this.kastvorm = OpmetingVoorzetscreenKastvorm.recht,
    this.kleurbron = OpmetingVoorzetscreenKleurbron.standaardPoederlak,
    this.projectKleurWaarde = '',
    this.kleurBenaming = '',
    this.poedercode = '',
    this.poederlakMogelijk = false,
    this.natlakMogelijk = false,
    this.doekCode = '',
    this.doekKleur = '',
    this.doekVoorzijdeHex = '#D8DADD',
    this.doekAchterzijdeHex = '#C9CDD1',
    this.zonnecel = false,
    this.motorType = '',
    this.motorMerk = '',
    this.motorOmschrijving = '',
    this.kabellengteMeter = 2,
    this.bediening = 'Inbouwschakelaar',
    this.uitgangKabel = '',
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

  final String positie;
  final int aantal;
  final int breedteMm;
  final int hoogteMm;
  final bool breedteInclusiefGeleiders;
  final bool hoogteInclusiefKast;
  final OpmetingVoorzetscreenKastmaat kastmaat;
  final OpmetingVoorzetscreenKastvorm kastvorm;
  final OpmetingVoorzetscreenKleurbron kleurbron;
  final String projectKleurWaarde;
  final String kleurBenaming;
  final String poedercode;
  final bool poederlakMogelijk;
  final bool natlakMogelijk;
  final String doekCode;
  final String doekKleur;
  final String doekVoorzijdeHex;
  final String doekAchterzijdeHex;
  final bool zonnecel;
  final String motorType;
  final String motorMerk;
  final String motorOmschrijving;
  final int kabellengteMeter;
  final String bediening;
  final String uitgangKabel;
  final String notities;
  final List<OpmetingFoto> fotos;

  int get buitenBreedteMm => breedteInclusiefGeleiders
      ? breedteMm
      : breedteMm + (geleiderBreedteMm * 2);

  int get buitenHoogteMm =>
      hoogteInclusiefKast ? hoogteMm : hoogteMm + kastmaat.millimeter;

  bool get zonnecelBeschikbaar =>
      kastmaat != OpmetingVoorzetscreenKastmaat.mm85;

  String get maatSamenvatting => '$breedteMm × $hoogteMm mm';
  String get kastSamenvatting => '${kastmaat.label} · ${kastvorm.label}';

  String get breedteMeetwijzeTekst =>
      breedteInclusiefGeleiders ? 'Inclusief geleiders' : 'Exclusief geleiders';

  String get hoogteMeetwijzeTekst =>
      hoogteInclusiefKast ? 'Inclusief kast' : 'Exclusief kast';

  String get kleurSamenvatting {
    if (kleurbron == OpmetingVoorzetscreenKleurbron.projectKleur) {
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

  String get doekSamenvatting {
    final code = doekCode.trim();
    final kleur = doekKleur.trim();
    if (code.isEmpty && kleur.isEmpty) return 'Nog te bepalen';
    if (kleur.isEmpty) return code;
    if (code.isEmpty) return kleur;
    return '$code · $kleur';
  }

  String get kabellengteSamenvatting => '$kabellengteMeter m';

  String get bedieningSamenvatting {
    final waarde = bediening.trim();
    return waarde.isEmpty ? 'Nog te bepalen' : waarde;
  }

  String get motorSamenvatting {
    final delen = <String>[
      motorType.trim(),
      motorMerk.trim(),
      motorOmschrijving.trim(),
    ].where((deel) => deel.isNotEmpty).toList(growable: false);
    return delen.isEmpty ? 'Nog te bepalen' : delen.join(' · ');
  }

  List<OpmetingVoorzetscreenKastvorm> get beschikbareKastvormen {
    if (kastmaat == OpmetingVoorzetscreenKastmaat.mm95) {
      return const <OpmetingVoorzetscreenKastvorm>[
        OpmetingVoorzetscreenKastvorm.recht,
      ];
    }
    if (kastmaat == OpmetingVoorzetscreenKastmaat.mm120) {
      return const <OpmetingVoorzetscreenKastvorm>[
        OpmetingVoorzetscreenKastvorm.schuin,
        OpmetingVoorzetscreenKastvorm.rond,
      ];
    }
    // mm85 blijft alleen bestaan om oudere opgeslagen fiches te kunnen lezen.
    return OpmetingVoorzetscreenKastvorm.values;
  }

  OpmetingVoorzetscreenModel metKastmaat(
    OpmetingVoorzetscreenKastmaat nieuweMaat,
  ) {
    final nieuweVorm = switch (nieuweMaat) {
      OpmetingVoorzetscreenKastmaat.mm95 => OpmetingVoorzetscreenKastvorm.recht,
      OpmetingVoorzetscreenKastmaat.mm120
          when kastvorm == OpmetingVoorzetscreenKastvorm.recht =>
        OpmetingVoorzetscreenKastvorm.schuin,
      _ => kastvorm,
    };

    final zonnecelToestaan = nieuweMaat != OpmetingVoorzetscreenKastmaat.mm85;

    return copyWith(
      kastmaat: nieuweMaat,
      kastvorm: nieuweVorm,
      zonnecel: zonnecelToestaan ? zonnecel : false,
      motorType: zonnecelToestaan ? motorType : '',
      motorMerk: zonnecelToestaan ? motorMerk : '',
      motorOmschrijving: zonnecelToestaan ? motorOmschrijving : '',
    );
  }

  OpmetingVoorzetscreenModel metKastvorm(
    OpmetingVoorzetscreenKastvorm nieuweVorm,
  ) {
    if (!beschikbareKastvormen.contains(nieuweVorm)) {
      return this;
    }
    return copyWith(kastvorm: nieuweVorm);
  }

  OpmetingVoorzetscreenModel copyWith({
    String? positie,
    int? aantal,
    int? breedteMm,
    int? hoogteMm,
    bool? breedteInclusiefGeleiders,
    bool? hoogteInclusiefKast,
    OpmetingVoorzetscreenKastmaat? kastmaat,
    OpmetingVoorzetscreenKastvorm? kastvorm,
    OpmetingVoorzetscreenKleurbron? kleurbron,
    String? projectKleurWaarde,
    String? kleurBenaming,
    String? poedercode,
    bool? poederlakMogelijk,
    bool? natlakMogelijk,
    String? doekCode,
    String? doekKleur,
    String? doekVoorzijdeHex,
    String? doekAchterzijdeHex,
    bool? zonnecel,
    String? motorType,
    String? motorMerk,
    String? motorOmschrijving,
    int? kabellengteMeter,
    String? bediening,
    String? uitgangKabel,
    String? notities,
    List<OpmetingFoto>? fotos,
  }) {
    final nieuweKastmaat = kastmaat ?? this.kastmaat;
    var nieuweKastvorm = kastvorm ?? this.kastvorm;
    if (nieuweKastmaat == OpmetingVoorzetscreenKastmaat.mm95) {
      nieuweKastvorm = OpmetingVoorzetscreenKastvorm.recht;
    } else if (nieuweKastmaat == OpmetingVoorzetscreenKastmaat.mm120 &&
        nieuweKastvorm == OpmetingVoorzetscreenKastvorm.recht) {
      nieuweKastvorm = OpmetingVoorzetscreenKastvorm.schuin;
    }

    var nieuweZonnecel = zonnecel ?? this.zonnecel;
    if (nieuweKastmaat == OpmetingVoorzetscreenKastmaat.mm85) {
      nieuweZonnecel = false;
    }

    return OpmetingVoorzetscreenModel(
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
      kastmaat: nieuweKastmaat,
      kastvorm: nieuweKastvorm,
      kleurbron: kleurbron ?? this.kleurbron,
      projectKleurWaarde: projectKleurWaarde ?? this.projectKleurWaarde,
      kleurBenaming: kleurBenaming ?? this.kleurBenaming,
      poedercode: poedercode ?? this.poedercode,
      poederlakMogelijk: poederlakMogelijk ?? this.poederlakMogelijk,
      natlakMogelijk: natlakMogelijk ?? this.natlakMogelijk,
      doekCode: doekCode ?? this.doekCode,
      doekKleur: doekKleur ?? this.doekKleur,
      doekVoorzijdeHex: doekVoorzijdeHex ?? this.doekVoorzijdeHex,
      doekAchterzijdeHex: doekAchterzijdeHex ?? this.doekAchterzijdeHex,
      zonnecel: nieuweZonnecel,
      motorType: motorType ?? this.motorType,
      motorMerk: motorMerk ?? this.motorMerk,
      motorOmschrijving: motorOmschrijving ?? this.motorOmschrijving,
      kabellengteMeter: (kabellengteMeter ?? this.kabellengteMeter)
          .clamp(2, 10)
          .toInt(),
      bediening: bediening ?? this.bediening,
      uitgangKabel: uitgangKabel ?? this.uitgangKabel,
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
      'kastmaat': kastmaat.name,
      'kastvorm': kastvorm.name,
      'kleurbron': kleurbron.name,
      'projectKleurWaarde': projectKleurWaarde,
      'kleurBenaming': kleurBenaming,
      'poedercode': poedercode,
      'poederlakMogelijk': poederlakMogelijk,
      'natlakMogelijk': natlakMogelijk,
      'doekCode': doekCode,
      'doekKleur': doekKleur,
      'doekVoorzijdeHex': doekVoorzijdeHex,
      'doekAchterzijdeHex': doekAchterzijdeHex,
      'zonnecel': zonnecel,
      'motorType': motorType,
      'motorMerk': motorMerk,
      'motorOmschrijving': motorOmschrijving,
      'kabellengteMeter': kabellengteMeter,
      'bediening': bediening,
      'uitgangKabel': uitgangKabel,
      'notities': notities,
      'fotos': fotos.map((foto) => foto.toJson()).toList(growable: false),
    };
  }

  factory OpmetingVoorzetscreenModel.fromJson(Map<String, dynamic> json) {
    final model = OpmetingVoorzetscreenModel(
      positie: json['positie']?.toString() ?? '',
      aantal: _leesInt(json['aantal'], 1),
      breedteMm: _leesInt(json['breedteMm'], 1000),
      hoogteMm: _leesInt(json['hoogteMm'], 1200),
      breedteInclusiefGeleiders: json['breedteInclusiefGeleiders'] != false,
      hoogteInclusiefKast: json['hoogteInclusiefKast'] != false,
      kastmaat: OpmetingVoorzetscreenKastmaatExtension.vanOpslagWaarde(
        json['kastmaat'],
      ),
      kastvorm: OpmetingVoorzetscreenKastvormExtension.vanOpslagWaarde(
        json['kastvorm'],
      ),
      kleurbron: OpmetingVoorzetscreenKleurbronExtension.vanOpslagWaarde(
        json['kleurbron'],
      ),
      projectKleurWaarde: json['projectKleurWaarde']?.toString() ?? '',
      kleurBenaming: json['kleurBenaming']?.toString() ?? '',
      poedercode: json['poedercode']?.toString() ?? '',
      poederlakMogelijk: json['poederlakMogelijk'] == true,
      natlakMogelijk: json['natlakMogelijk'] == true,
      doekCode: json['doekCode']?.toString() ?? '',
      doekKleur: json['doekKleur']?.toString() ?? '',
      doekVoorzijdeHex: json['doekVoorzijdeHex']?.toString() ?? '#D8DADD',
      doekAchterzijdeHex: json['doekAchterzijdeHex']?.toString() ?? '#C9CDD1',
      zonnecel: json['zonnecel'] == true,
      motorType: json['motorType']?.toString() ?? '',
      motorMerk: json['motorMerk']?.toString() ?? '',
      motorOmschrijving: json['motorOmschrijving']?.toString() ?? '',
      kabellengteMeter: _leesInt(json['kabellengteMeter'], 2),
      bediening: json['bediening']?.toString() ?? 'Inbouwschakelaar',
      uitgangKabel: json['uitgangKabel']?.toString() ?? '',
      notities: json['notities']?.toString() ?? '',
      fotos: _leesFotos(json['fotos']),
    );

    return model.copyWith();
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
