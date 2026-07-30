// THIMACO-CONTROLE: SEKTIONALE-POORTEN-R-PROFIELEN-POSITIE-20260729-1313
// THIMACO-CONTROLE: SEKTIONALE-POORTEN-VOLLEDIGE-UITBREIDING-20260729-1214
// THIMACO-CONTROLE: SEKTIONALE-POORTEN-P-R-STOPCONTACT-BESCHIKBAARHEID-20260729
import 'dart:math' as math;

import '../../fotos/opmeting_foto_model.dart';

enum OpmetingSektionalePoortModelType { g, w, s, r, n, v, k, p }

extension OpmetingSektionalePoortModelTypeExtension
    on OpmetingSektionalePoortModelType {
  String get label => name.toUpperCase();

  String get opslagWaarde => name;

  static OpmetingSektionalePoortModelType vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    for (final type in OpmetingSektionalePoortModelType.values) {
      if (type.name == tekst || type.label.toLowerCase() == tekst) return type;
    }
    return OpmetingSektionalePoortModelType.g;
  }
}

enum OpmetingSektionalePoortRaamZijde { links, rechts }

extension OpmetingSektionalePoortRaamZijdeExtension
    on OpmetingSektionalePoortRaamZijde {
  String get label {
    return switch (this) {
      OpmetingSektionalePoortRaamZijde.links => 'Links',
      OpmetingSektionalePoortRaamZijde.rechts => 'Rechts',
    };
  }

  String get opslagWaarde => name;

  static OpmetingSektionalePoortRaamZijde vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    return tekst == 'rechts'
        ? OpmetingSektionalePoortRaamZijde.rechts
        : OpmetingSektionalePoortRaamZijde.links;
  }
}

enum OpmetingSektionalePoortSerie { unipro, premiumPro, prime }

extension OpmetingSektionalePoortSerieExtension
    on OpmetingSektionalePoortSerie {
  String get label {
    switch (this) {
      case OpmetingSektionalePoortSerie.unipro:
        return 'Unipro';
      case OpmetingSektionalePoortSerie.premiumPro:
        return 'Premium Pro';
      case OpmetingSektionalePoortSerie.prime:
        return 'Prime';
    }
  }

  String get opslagWaarde => name;

  static OpmetingSektionalePoortSerie vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    for (final serie in OpmetingSektionalePoortSerie.values) {
      if (serie.name.toLowerCase() == tekst ||
          serie.label.toLowerCase() == tekst) {
        return serie;
      }
    }
    return OpmetingSektionalePoortSerie.unipro;
  }
}

enum OpmetingSektionalePoortStructuur { silkline, stucco, woodgrain }

extension OpmetingSektionalePoortStructuurExtension
    on OpmetingSektionalePoortStructuur {
  String get label {
    switch (this) {
      case OpmetingSektionalePoortStructuur.silkline:
        return 'Silkline';
      case OpmetingSektionalePoortStructuur.stucco:
        return 'Stucco';
      case OpmetingSektionalePoortStructuur.woodgrain:
        return 'Woodgrain';
    }
  }

  String get opslagWaarde => name;

  static OpmetingSektionalePoortStructuur vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    for (final structuur in OpmetingSektionalePoortStructuur.values) {
      if (structuur.name.toLowerCase() == tekst ||
          structuur.label.toLowerCase() == tekst) {
        return structuur;
      }
    }
    return OpmetingSektionalePoortStructuur.silkline;
  }
}

enum OpmetingSektionalePoortKorrelgrootte { d20, d50 }

extension OpmetingSektionalePoortKorrelgrootteExtension
    on OpmetingSektionalePoortKorrelgrootte {
  String get label => name.toUpperCase();

  String get opslagWaarde => name;

  static OpmetingSektionalePoortKorrelgrootte vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    return tekst == 'd50'
        ? OpmetingSektionalePoortKorrelgrootte.d50
        : OpmetingSektionalePoortKorrelgrootte.d20;
  }
}

enum OpmetingSektionalePoortMotor {
  somfyDexo600Io,
  somfySmart800Io,
  somfySmart1000Io,
}

extension OpmetingSektionalePoortMotorExtension
    on OpmetingSektionalePoortMotor {
  String get label {
    switch (this) {
      case OpmetingSektionalePoortMotor.somfyDexo600Io:
        return 'Somfy Dexxo 600 IO';
      case OpmetingSektionalePoortMotor.somfySmart800Io:
        return 'Somfy Smart 800 IO (incl. 2 handzenders)';
      case OpmetingSektionalePoortMotor.somfySmart1000Io:
        return 'Somfy Smart 1000 IO (incl. 2 handzenders)';
    }
  }

  String get opslagWaarde => name;

  static OpmetingSektionalePoortMotor vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    for (final motor in OpmetingSektionalePoortMotor.values) {
      if (motor.name.toLowerCase() == tekst ||
          motor.label.toLowerCase() == tekst) {
        return motor;
      }
    }
    return OpmetingSektionalePoortMotor.somfyDexo600Io;
  }
}

enum OpmetingSektionalePoortMontageProfiel {
  geenKaderwerk,
  afwerkprofielenOverRail,
  montageProfielDc1,
  montageProfielDc2,
  kokerprofielen,
}

extension OpmetingSektionalePoortMontageProfielExtension
    on OpmetingSektionalePoortMontageProfiel {
  String get label {
    switch (this) {
      case OpmetingSektionalePoortMontageProfiel.geenKaderwerk:
        return 'Geen kaderwerk';
      case OpmetingSektionalePoortMontageProfiel.afwerkprofielenOverRail:
        return 'Afwerkprofielen over rail tot 30 mm';
      case OpmetingSektionalePoortMontageProfiel.montageProfielDc1:
        return 'Montage profiel DC1';
      case OpmetingSektionalePoortMontageProfiel.montageProfielDc2:
        return 'Montage profiel DC2';
      case OpmetingSektionalePoortMontageProfiel.kokerprofielen:
        return 'Kokerprofielen';
    }
  }

  String get opslagWaarde => name;

  static OpmetingSektionalePoortMontageProfiel vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    for (final profiel in OpmetingSektionalePoortMontageProfiel.values) {
      if (profiel.name.toLowerCase() == tekst ||
          profiel.label.toLowerCase() == tekst) {
        return profiel;
      }
    }
    return OpmetingSektionalePoortMontageProfiel.geenKaderwerk;
  }
}

class OpmetingSektionalePoortProfielMaten {
  const OpmetingSektionalePoortProfielMaten({
    this.xMm = 0,
    this.lMm = 0,
    this.rMm = 0,
    this.bMm = 0,
  });

  final int xMm;
  final int lMm;
  final int rMm;
  final int bMm;

  bool get heeftWaarden => xMm > 0 || lMm > 0 || rMm > 0 || bMm > 0;

  OpmetingSektionalePoortProfielMaten copyWith({
    int? xMm,
    int? lMm,
    int? rMm,
    int? bMm,
  }) {
    return OpmetingSektionalePoortProfielMaten(
      xMm: xMm ?? this.xMm,
      lMm: lMm ?? this.lMm,
      rMm: rMm ?? this.rMm,
      bMm: bMm ?? this.bMm,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'xMm': xMm,
    'lMm': lMm,
    'rMm': rMm,
    'bMm': bMm,
  };

  factory OpmetingSektionalePoortProfielMaten.fromJson(
    Map<String, dynamic> json,
  ) {
    return OpmetingSektionalePoortProfielMaten(
      xMm: _leesInt(json['xMm']),
      lMm: _leesInt(json['lMm']),
      rMm: _leesInt(json['rMm']),
      bMm: _leesInt(json['bMm']),
    );
  }
}

class OpmetingSektionalePoortKokerMaten {
  const OpmetingSektionalePoortKokerMaten({
    required this.profiel,
    this.lMm = 0,
    this.rMm = 0,
    this.bMm = 0,
  });

  final String profiel;
  final int lMm;
  final int rMm;
  final int bMm;

  bool get heeftWaarden => lMm > 0 || rMm > 0 || bMm > 0;

  OpmetingSektionalePoortKokerMaten copyWith({
    String? profiel,
    int? lMm,
    int? rMm,
    int? bMm,
  }) {
    return OpmetingSektionalePoortKokerMaten(
      profiel: profiel ?? this.profiel,
      lMm: lMm ?? this.lMm,
      rMm: rMm ?? this.rMm,
      bMm: bMm ?? this.bMm,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'profiel': profiel,
    'lMm': lMm,
    'rMm': rMm,
    'bMm': bMm,
  };

  factory OpmetingSektionalePoortKokerMaten.fromJson(
    Map<String, dynamic> json,
  ) {
    return OpmetingSektionalePoortKokerMaten(
      profiel: json['profiel']?.toString().trim() ?? '',
      lMm: _leesInt(json['lMm']),
      rMm: _leesInt(json['rMm']),
      bMm: _leesInt(json['bMm']),
    );
  }
}

class OpmetingSektionalePoortModel {
  const OpmetingSektionalePoortModel({
    this.aantal = 1,
    this.breedteMm = 2400,
    this.hoogteMm = 2200,
    this.slagLMm = 0,
    this.slagRMm = 0,
    this.slagBMm = 0,
    this.modelType = OpmetingSektionalePoortModelType.g,
    this.serie = OpmetingSektionalePoortSerie.unipro,
    this.structuur = OpmetingSektionalePoortStructuur.silkline,
    this.kleur = projectKleurKeuze,
    this.projectKleurWaarde = '',
    this.korrelgrootte = OpmetingSektionalePoortKorrelgrootte.d20,
    this.motor = OpmetingSektionalePoortMotor.somfyDexo600Io,
    this.extraHandzenders = false,
    this.aantalExtraHandzenders = 1,
    this.muurzenderDraadloosIo = false,
    this.draadloosCodeklavier = false,
    this.bovenlatei = true,
    this.pvcAntiRoestvoetjePremiumPro = false,
    this.plaatsenEnAansluitenStopcontact = false,
    this.aantalPanelen = 4,
    this.glasPaneelNummers = const <int>[],
    this.rVierkantRaamMetKleinhouten = false,
    this.rAantalVierkanteRamen = 1,
    this.rRaam1Zijde = OpmetingSektionalePoortRaamZijde.links,
    this.rRaam1AfstandMm = 0,
    this.rRaam2Zijde = OpmetingSektionalePoortRaamZijde.rechts,
    this.rRaam2AfstandMm = 0,
    this.rPlintOnderaan = false,
    this.rVoetjeMetMakelaar = false,
    this.montageProfiel = OpmetingSektionalePoortMontageProfiel.geenKaderwerk,
    this.afwerkprofielMaten = const OpmetingSektionalePoortProfielMaten(),
    this.montageDc1Maten = const OpmetingSektionalePoortProfielMaten(),
    this.montageDc2Maten = const OpmetingSektionalePoortProfielMaten(),
    this.kokerMaten = standaardKokerMaten,
    this.notities = '',
    this.fotos = const <OpmetingFoto>[],
  });

  static const String projectKleurKeuze = 'Project kleur';
  static const String technischMenuInstallatieId = 'sektionalePoortInstallatie';
  static const String technischStopcontactKeuzeId =
      'plaatsenEnAansluitenStopcontact';

  static const int aantalMinimum = 1;
  static const int aantalMaximum = 100;
  static const int maatMinimumMm = 0;
  static const int maatMaximumMm = 10000;
  static const int extraHandzendersMinimum = 1;
  static const int extraHandzendersMaximum = 20;
  static const int aantalPanelenMinimum = 1;
  static const int aantalPanelenMaximum = 6;
  static const int rAantalVierkanteRamenMinimum = 1;
  static const int rAantalVierkanteRamenMaximum = 2;
  static const int rVierkantRaamBuitenmaatMm = 250;
  static const int rVierkantRaamKaderdikteMm = 30;
  static const int rPlintHoogteMm = 60;
  static const int rMakelaarBreedteMm = 50;
  static const int rVoetjeHoogteMm = 100;

  static const List<String> kokerProfielen = <String>[
    '60 x 20',
    '80 x 20',
    '100 x 20',
    '120 x 20',
    '40 x 40',
    '60 x 40',
    '80 x 40',
    '100 x 40',
    '120 x 40',
    '150 x 40',
    '180 x 40',
  ];

  static const List<OpmetingSektionalePoortKokerMaten> standaardKokerMaten =
      <OpmetingSektionalePoortKokerMaten>[
        OpmetingSektionalePoortKokerMaten(profiel: '60 x 20'),
        OpmetingSektionalePoortKokerMaten(profiel: '80 x 20'),
        OpmetingSektionalePoortKokerMaten(profiel: '100 x 20'),
        OpmetingSektionalePoortKokerMaten(profiel: '120 x 20'),
        OpmetingSektionalePoortKokerMaten(profiel: '40 x 40'),
        OpmetingSektionalePoortKokerMaten(profiel: '60 x 40'),
        OpmetingSektionalePoortKokerMaten(profiel: '80 x 40'),
        OpmetingSektionalePoortKokerMaten(profiel: '100 x 40'),
        OpmetingSektionalePoortKokerMaten(profiel: '120 x 40'),
        OpmetingSektionalePoortKokerMaten(profiel: '150 x 40'),
        OpmetingSektionalePoortKokerMaten(profiel: '180 x 40'),
      ];

  final int aantal;
  final int breedteMm;
  final int hoogteMm;
  final int slagLMm;
  final int slagRMm;
  final int slagBMm;
  final OpmetingSektionalePoortModelType modelType;
  final OpmetingSektionalePoortSerie serie;
  final OpmetingSektionalePoortStructuur structuur;
  final String kleur;
  final String projectKleurWaarde;
  final OpmetingSektionalePoortKorrelgrootte korrelgrootte;
  final OpmetingSektionalePoortMotor motor;
  final bool extraHandzenders;
  final int aantalExtraHandzenders;
  final bool muurzenderDraadloosIo;
  final bool draadloosCodeklavier;
  final bool bovenlatei;
  final bool pvcAntiRoestvoetjePremiumPro;
  final bool plaatsenEnAansluitenStopcontact;
  final int aantalPanelen;
  final List<int> glasPaneelNummers;
  final bool rVierkantRaamMetKleinhouten;
  final int rAantalVierkanteRamen;
  final OpmetingSektionalePoortRaamZijde rRaam1Zijde;
  final int rRaam1AfstandMm;
  final OpmetingSektionalePoortRaamZijde rRaam2Zijde;
  final int rRaam2AfstandMm;
  final bool rPlintOnderaan;
  final bool rVoetjeMetMakelaar;
  final OpmetingSektionalePoortMontageProfiel montageProfiel;
  final OpmetingSektionalePoortProfielMaten afwerkprofielMaten;
  final OpmetingSektionalePoortProfielMaten montageDc1Maten;
  final OpmetingSektionalePoortProfielMaten montageDc2Maten;
  final List<OpmetingSektionalePoortKokerMaten> kokerMaten;
  final String notities;
  final List<OpmetingFoto> fotos;

  bool get gebruiktProjectKleur => kleur.trim() == projectKleurKeuze;

  String get kleurVoorWeergave {
    if (!gebruiktProjectKleur) return kleur.trim();
    return projectKleurWaarde.trim().isEmpty
        ? projectKleurKeuze
        : projectKleurWaarde.trim();
  }

  String get poortafmetingenTekst => '$breedteMm × $hoogteMm mm';

  List<String> get bedieningRegels {
    final regels = <String>[];
    if (extraHandzenders) {
      regels.add('Extra handzenders: $aantalExtraHandzenders');
    }
    if (muurzenderDraadloosIo) regels.add('Muurzender draadloos IO');
    if (draadloosCodeklavier) regels.add('Draadloos codeklavier');
    return List<String>.unmodifiable(regels);
  }

  List<String> get rExtraProfielRegels {
    final regels = <String>[];
    if (rVierkantRaamMetKleinhouten) {
      regels.add(
        'Vierkant raam met kleinhouten · $rAantalVierkanteRamen kader${rAantalVierkanteRamen == 1 ? '' : 's'}',
      );
    }
    if (rPlintOnderaan) regels.add('Plint onderaan');
    if (rVoetjeMetMakelaar) regels.add('Voetje met makelaar');
    return List<String>.unmodifiable(regels);
  }

  bool isModelBeschikbaar(OpmetingSektionalePoortModelType type) {
    if (serie == OpmetingSektionalePoortSerie.unipro) {
      if (type == OpmetingSektionalePoortModelType.s ||
          type == OpmetingSektionalePoortModelType.r) {
        return false;
      }
      if (structuur == OpmetingSektionalePoortStructuur.stucco &&
          (type == OpmetingSektionalePoortModelType.g ||
              type == OpmetingSektionalePoortModelType.n)) {
        return false;
      }
    }

    if (serie == OpmetingSektionalePoortSerie.premiumPro &&
        (type == OpmetingSektionalePoortModelType.v ||
            type == OpmetingSektionalePoortModelType.k)) {
      return false;
    }

    return true;
  }

  List<OpmetingSektionalePoortModelType> get beschikbareModellen {
    return List<OpmetingSektionalePoortModelType>.unmodifiable(
      OpmetingSektionalePoortModelType.values.where(isModelBeschikbaar),
    );
  }

  String redenNietBeschikbaar(OpmetingSektionalePoortModelType type) {
    if (serie == OpmetingSektionalePoortSerie.unipro &&
        (type == OpmetingSektionalePoortModelType.s ||
            type == OpmetingSektionalePoortModelType.r)) {
      return 'Niet beschikbaar bij Unipro';
    }
    if (serie == OpmetingSektionalePoortSerie.unipro &&
        structuur == OpmetingSektionalePoortStructuur.stucco &&
        (type == OpmetingSektionalePoortModelType.g ||
            type == OpmetingSektionalePoortModelType.n)) {
      return 'Niet beschikbaar bij Unipro met Stucco';
    }
    if (serie == OpmetingSektionalePoortSerie.premiumPro &&
        (type == OpmetingSektionalePoortModelType.v ||
            type == OpmetingSektionalePoortModelType.k)) {
      return 'Niet beschikbaar bij Premium Pro';
    }
    return '';
  }

  List<int> get geldigeGlasPaneelNummers {
    final uniek =
        glasPaneelNummers
            .where((nummer) => nummer >= 1 && nummer <= aantalPanelen)
            .toSet()
            .toList(growable: false)
          ..sort();
    return List<int>.unmodifiable(uniek);
  }

  String paneelLabel(int nummer) {
    if (nummer <= 1) return 'Onderste paneel';
    if (nummer >= aantalPanelen) return 'Bovenste paneel';
    return switch (nummer) {
      2 => 'Tweede paneel',
      3 => 'Derde paneel',
      4 => 'Vierde paneel',
      5 => 'Vijfde paneel',
      _ => 'Paneel $nummer',
    };
  }

  OpmetingSektionalePoortKokerMaten kokerVoor(String profiel) {
    for (final maten in kokerMaten) {
      if (maten.profiel == profiel) return maten;
    }
    return OpmetingSektionalePoortKokerMaten(profiel: profiel);
  }

  OpmetingSektionalePoortModel copyWith({
    int? aantal,
    int? breedteMm,
    int? hoogteMm,
    int? slagLMm,
    int? slagRMm,
    int? slagBMm,
    OpmetingSektionalePoortModelType? modelType,
    OpmetingSektionalePoortSerie? serie,
    OpmetingSektionalePoortStructuur? structuur,
    String? kleur,
    String? projectKleurWaarde,
    OpmetingSektionalePoortKorrelgrootte? korrelgrootte,
    OpmetingSektionalePoortMotor? motor,
    bool? extraHandzenders,
    int? aantalExtraHandzenders,
    bool? muurzenderDraadloosIo,
    bool? draadloosCodeklavier,
    bool? bovenlatei,
    bool? pvcAntiRoestvoetjePremiumPro,
    bool? plaatsenEnAansluitenStopcontact,
    int? aantalPanelen,
    List<int>? glasPaneelNummers,
    bool? rVierkantRaamMetKleinhouten,
    int? rAantalVierkanteRamen,
    OpmetingSektionalePoortRaamZijde? rRaam1Zijde,
    int? rRaam1AfstandMm,
    OpmetingSektionalePoortRaamZijde? rRaam2Zijde,
    int? rRaam2AfstandMm,
    bool? rPlintOnderaan,
    bool? rVoetjeMetMakelaar,
    OpmetingSektionalePoortMontageProfiel? montageProfiel,
    OpmetingSektionalePoortProfielMaten? afwerkprofielMaten,
    OpmetingSektionalePoortProfielMaten? montageDc1Maten,
    OpmetingSektionalePoortProfielMaten? montageDc2Maten,
    List<OpmetingSektionalePoortKokerMaten>? kokerMaten,
    String? notities,
    List<OpmetingFoto>? fotos,
  }) {
    final nieuweSerie = serie ?? this.serie;
    final nieuweStructuur = structuur ?? this.structuur;
    var nieuwModelType = modelType ?? this.modelType;
    final nieuwAantalPanelen = (aantalPanelen ?? this.aantalPanelen)
        .clamp(aantalPanelenMinimum, aantalPanelenMaximum)
        .toInt();
    final nieuwAantalVierkanteRamen =
        (rAantalVierkanteRamen ?? this.rAantalVierkanteRamen)
            .clamp(rAantalVierkanteRamenMinimum, rAantalVierkanteRamenMaximum)
            .toInt();
    final maximaleRaamAfstand = math.max(
      0,
      (breedteMm ?? this.breedteMm) - rVierkantRaamBuitenmaatMm,
    );

    bool beschikbaar(OpmetingSektionalePoortModelType type) {
      if (nieuweSerie == OpmetingSektionalePoortSerie.unipro) {
        if (type == OpmetingSektionalePoortModelType.s ||
            type == OpmetingSektionalePoortModelType.r) {
          return false;
        }
        if (nieuweStructuur == OpmetingSektionalePoortStructuur.stucco &&
            (type == OpmetingSektionalePoortModelType.g ||
                type == OpmetingSektionalePoortModelType.n)) {
          return false;
        }
      }
      if (nieuweSerie == OpmetingSektionalePoortSerie.premiumPro &&
          (type == OpmetingSektionalePoortModelType.v ||
              type == OpmetingSektionalePoortModelType.k)) {
        return false;
      }
      return true;
    }

    if (!beschikbaar(nieuwModelType)) {
      nieuwModelType = OpmetingSektionalePoortModelType.values.firstWhere(
        beschikbaar,
        orElse: () => OpmetingSektionalePoortModelType.p,
      );
    }

    final nieuweGlasPanelen =
        (glasPaneelNummers ?? this.glasPaneelNummers)
            .where((nummer) => nummer >= 1 && nummer <= nieuwAantalPanelen)
            .toSet()
            .toList(growable: false)
          ..sort();

    return OpmetingSektionalePoortModel(
      aantal: (aantal ?? this.aantal)
          .clamp(aantalMinimum, aantalMaximum)
          .toInt(),
      breedteMm: (breedteMm ?? this.breedteMm)
          .clamp(maatMinimumMm, maatMaximumMm)
          .toInt(),
      hoogteMm: (hoogteMm ?? this.hoogteMm)
          .clamp(maatMinimumMm, maatMaximumMm)
          .toInt(),
      slagLMm: (slagLMm ?? this.slagLMm)
          .clamp(maatMinimumMm, maatMaximumMm)
          .toInt(),
      slagRMm: (slagRMm ?? this.slagRMm)
          .clamp(maatMinimumMm, maatMaximumMm)
          .toInt(),
      slagBMm: (slagBMm ?? this.slagBMm)
          .clamp(maatMinimumMm, maatMaximumMm)
          .toInt(),
      modelType: nieuwModelType,
      serie: nieuweSerie,
      structuur: nieuweStructuur,
      kleur: kleur ?? this.kleur,
      projectKleurWaarde: projectKleurWaarde ?? this.projectKleurWaarde,
      korrelgrootte: korrelgrootte ?? this.korrelgrootte,
      motor: motor ?? this.motor,
      extraHandzenders: extraHandzenders ?? this.extraHandzenders,
      aantalExtraHandzenders:
          (aantalExtraHandzenders ?? this.aantalExtraHandzenders)
              .clamp(extraHandzendersMinimum, extraHandzendersMaximum)
              .toInt(),
      muurzenderDraadloosIo:
          muurzenderDraadloosIo ?? this.muurzenderDraadloosIo,
      draadloosCodeklavier: draadloosCodeklavier ?? this.draadloosCodeklavier,
      bovenlatei: bovenlatei ?? this.bovenlatei,
      pvcAntiRoestvoetjePremiumPro:
          pvcAntiRoestvoetjePremiumPro ?? this.pvcAntiRoestvoetjePremiumPro,
      plaatsenEnAansluitenStopcontact:
          plaatsenEnAansluitenStopcontact ??
          this.plaatsenEnAansluitenStopcontact,
      aantalPanelen: nieuwAantalPanelen,
      glasPaneelNummers: List<int>.unmodifiable(nieuweGlasPanelen),
      rVierkantRaamMetKleinhouten:
          rVierkantRaamMetKleinhouten ?? this.rVierkantRaamMetKleinhouten,
      rAantalVierkanteRamen: nieuwAantalVierkanteRamen,
      rRaam1Zijde: rRaam1Zijde ?? this.rRaam1Zijde,
      rRaam1AfstandMm: (rRaam1AfstandMm ?? this.rRaam1AfstandMm)
          .clamp(0, maximaleRaamAfstand)
          .toInt(),
      rRaam2Zijde: rRaam2Zijde ?? this.rRaam2Zijde,
      rRaam2AfstandMm: (rRaam2AfstandMm ?? this.rRaam2AfstandMm)
          .clamp(0, maximaleRaamAfstand)
          .toInt(),
      rPlintOnderaan: rPlintOnderaan ?? this.rPlintOnderaan,
      rVoetjeMetMakelaar: rVoetjeMetMakelaar ?? this.rVoetjeMetMakelaar,
      montageProfiel: montageProfiel ?? this.montageProfiel,
      afwerkprofielMaten: afwerkprofielMaten ?? this.afwerkprofielMaten,
      montageDc1Maten: montageDc1Maten ?? this.montageDc1Maten,
      montageDc2Maten: montageDc2Maten ?? this.montageDc2Maten,
      kokerMaten: List<OpmetingSektionalePoortKokerMaten>.unmodifiable(
        kokerMaten ?? this.kokerMaten,
      ),
      notities: notities ?? this.notities,
      fotos: List<OpmetingFoto>.unmodifiable(fotos ?? this.fotos),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'aantal': aantal,
    'breedteMm': breedteMm,
    'hoogteMm': hoogteMm,
    'slagLMm': slagLMm,
    'slagRMm': slagRMm,
    'slagBMm': slagBMm,
    'modelType': modelType.opslagWaarde,
    'serie': serie.opslagWaarde,
    'structuur': structuur.opslagWaarde,
    'kleur': kleur,
    'projectKleurWaarde': projectKleurWaarde,
    'korrelgrootte': korrelgrootte.opslagWaarde,
    'motor': motor.opslagWaarde,
    'extraHandzenders': extraHandzenders,
    'aantalExtraHandzenders': aantalExtraHandzenders,
    'muurzenderDraadloosIo': muurzenderDraadloosIo,
    'draadloosCodeklavier': draadloosCodeklavier,
    'bovenlatei': bovenlatei,
    'pvcAntiRoestvoetjePremiumPro': pvcAntiRoestvoetjePremiumPro,
    'plaatsenEnAansluitenStopcontact': plaatsenEnAansluitenStopcontact,
    'aantalPanelen': aantalPanelen,
    'glasPaneelNummers': glasPaneelNummers,
    'rVierkantRaamMetKleinhouten': rVierkantRaamMetKleinhouten,
    'rAantalVierkanteRamen': rAantalVierkanteRamen,
    'rRaam1Zijde': rRaam1Zijde.opslagWaarde,
    'rRaam1AfstandMm': rRaam1AfstandMm,
    'rRaam2Zijde': rRaam2Zijde.opslagWaarde,
    'rRaam2AfstandMm': rRaam2AfstandMm,
    'rPlintOnderaan': rPlintOnderaan,
    'rVoetjeMetMakelaar': rVoetjeMetMakelaar,
    'montageProfiel': montageProfiel.opslagWaarde,
    'afwerkprofielMaten': afwerkprofielMaten.toJson(),
    'montageDc1Maten': montageDc1Maten.toJson(),
    'montageDc2Maten': montageDc2Maten.toJson(),
    'kokerMaten': kokerMaten.map((maten) => maten.toJson()).toList(),
    'notities': notities,
    'fotos': fotos.map((foto) => foto.toJson()).toList(),
  };

  factory OpmetingSektionalePoortModel.fromJson(Map<String, dynamic> json) {
    final ruweKokers = json['kokerMaten'];
    final opgeslagenKokers = ruweKokers is List
        ? ruweKokers.whereType<Map>().map((item) {
            return OpmetingSektionalePoortKokerMaten.fromJson(
              Map<String, dynamic>.from(item),
            );
          }).toList()
        : <OpmetingSektionalePoortKokerMaten>[];
    final kokerMap = <String, OpmetingSektionalePoortKokerMaten>{
      for (final item in opgeslagenKokers) item.profiel: item,
    };
    final genormaliseerdeKokers = kokerProfielen
        .map((profiel) {
          return kokerMap[profiel] ??
              OpmetingSektionalePoortKokerMaten(profiel: profiel);
        })
        .toList(growable: false);

    final ruweGlasPanelen = json['glasPaneelNummers'];
    final glasPanelen = ruweGlasPanelen is List
        ? ruweGlasPanelen
              .map(_leesInt)
              .where((nummer) => nummer > 0)
              .toList(growable: false)
        : const <int>[];

    final model = OpmetingSektionalePoortModel(
      aantal: _leesInt(
        json['aantal'],
        standaard: 1,
      ).clamp(aantalMinimum, aantalMaximum).toInt(),
      breedteMm: _leesInt(
        json['breedteMm'],
        standaard: 2400,
      ).clamp(maatMinimumMm, maatMaximumMm).toInt(),
      hoogteMm: _leesInt(
        json['hoogteMm'],
        standaard: 2200,
      ).clamp(maatMinimumMm, maatMaximumMm).toInt(),
      slagLMm: _leesInt(
        json['slagLMm'],
      ).clamp(maatMinimumMm, maatMaximumMm).toInt(),
      slagRMm: _leesInt(
        json['slagRMm'],
      ).clamp(maatMinimumMm, maatMaximumMm).toInt(),
      slagBMm: _leesInt(
        json['slagBMm'],
      ).clamp(maatMinimumMm, maatMaximumMm).toInt(),
      modelType: OpmetingSektionalePoortModelTypeExtension.vanOpslagWaarde(
        json['modelType'],
      ),
      serie: OpmetingSektionalePoortSerieExtension.vanOpslagWaarde(
        json['serie'],
      ),
      structuur: OpmetingSektionalePoortStructuurExtension.vanOpslagWaarde(
        json['structuur'],
      ),
      kleur: json['kleur']?.toString().trim().isNotEmpty == true
          ? json['kleur'].toString().trim()
          : projectKleurKeuze,
      projectKleurWaarde: json['projectKleurWaarde']?.toString() ?? '',
      korrelgrootte:
          OpmetingSektionalePoortKorrelgrootteExtension.vanOpslagWaarde(
            json['korrelgrootte'],
          ),
      motor: OpmetingSektionalePoortMotorExtension.vanOpslagWaarde(
        json['motor'],
      ),
      extraHandzenders: json['extraHandzenders'] == true,
      aantalExtraHandzenders: _leesInt(
        json['aantalExtraHandzenders'],
        standaard: 1,
      ).clamp(extraHandzendersMinimum, extraHandzendersMaximum).toInt(),
      muurzenderDraadloosIo: json['muurzenderDraadloosIo'] == true,
      draadloosCodeklavier: json['draadloosCodeklavier'] == true,
      bovenlatei: json['bovenlatei'] != false,
      pvcAntiRoestvoetjePremiumPro:
          json['pvcAntiRoestvoetjePremiumPro'] == true,
      plaatsenEnAansluitenStopcontact:
          json['plaatsenEnAansluitenStopcontact'] == true,
      aantalPanelen: _leesInt(
        json['aantalPanelen'],
        standaard: 4,
      ).clamp(aantalPanelenMinimum, aantalPanelenMaximum).toInt(),
      glasPaneelNummers: glasPanelen,
      rVierkantRaamMetKleinhouten: json['rVierkantRaamMetKleinhouten'] == true,
      rAantalVierkanteRamen:
          _leesInt(json['rAantalVierkanteRamen'], standaard: 1)
              .clamp(rAantalVierkanteRamenMinimum, rAantalVierkanteRamenMaximum)
              .toInt(),
      rRaam1Zijde: OpmetingSektionalePoortRaamZijdeExtension.vanOpslagWaarde(
        json['rRaam1Zijde'],
      ),
      rRaam1AfstandMm: _leesInt(json['rRaam1AfstandMm']),
      rRaam2Zijde: OpmetingSektionalePoortRaamZijdeExtension.vanOpslagWaarde(
        json['rRaam2Zijde'] ?? 'rechts',
      ),
      rRaam2AfstandMm: _leesInt(json['rRaam2AfstandMm']),
      rPlintOnderaan: json['rPlintOnderaan'] == true,
      rVoetjeMetMakelaar: json['rVoetjeMetMakelaar'] == true,
      montageProfiel:
          OpmetingSektionalePoortMontageProfielExtension.vanOpslagWaarde(
            json['montageProfiel'],
          ),
      afwerkprofielMaten: json['afwerkprofielMaten'] is Map
          ? OpmetingSektionalePoortProfielMaten.fromJson(
              Map<String, dynamic>.from(json['afwerkprofielMaten'] as Map),
            )
          : const OpmetingSektionalePoortProfielMaten(),
      montageDc1Maten: json['montageDc1Maten'] is Map
          ? OpmetingSektionalePoortProfielMaten.fromJson(
              Map<String, dynamic>.from(json['montageDc1Maten'] as Map),
            )
          : const OpmetingSektionalePoortProfielMaten(),
      montageDc2Maten: json['montageDc2Maten'] is Map
          ? OpmetingSektionalePoortProfielMaten.fromJson(
              Map<String, dynamic>.from(json['montageDc2Maten'] as Map),
            )
          : const OpmetingSektionalePoortProfielMaten(),
      kokerMaten: List<OpmetingSektionalePoortKokerMaten>.unmodifiable(
        genormaliseerdeKokers,
      ),
      notities: json['notities']?.toString() ?? '',
      fotos: _leesFotos(json['fotos']),
    );

    return model.copyWith(
      modelType: model.modelType,
      aantalPanelen: model.aantalPanelen,
      glasPaneelNummers: model.glasPaneelNummers,
    );
  }
}

int _leesInt(Object? waarde, {int standaard = 0}) {
  if (waarde is int) return waarde;
  if (waarde is num) return waarde.round();
  return int.tryParse(waarde?.toString().trim() ?? '') ?? standaard;
}

List<OpmetingFoto> _leesFotos(Object? waarde) {
  if (waarde is! List) return const <OpmetingFoto>[];
  return List<OpmetingFoto>.unmodifiable(
    waarde.whereType<Map>().map((item) {
      return OpmetingFoto.fromJson(Map<String, dynamic>.from(item));
    }),
  );
}
