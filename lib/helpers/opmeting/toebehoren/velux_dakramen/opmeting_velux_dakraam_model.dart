// THIMACO-CONTROLE: VELUX-AFWERKING-NIET-MEER-IN-CATALOGUSTOTAAL-20260730
// THIMACO-CONTROLE: VELUX-STANDAARDMAAT-SK06-20260730-0531
// THIMACO-CONTROLE: VELUX-DAKRAAM-MODEL-FASE-1-2-20260729-2030
import '../../fotos/opmeting_foto_model.dart';

enum OpmetingVeluxGootstukType { geen, edw2000, edt2000, edp2000, edb2000 }

extension OpmetingVeluxGootstukTypeExtension on OpmetingVeluxGootstukType {
  String get label {
    switch (this) {
      case OpmetingVeluxGootstukType.geen:
        return 'Geen gootstuk';
      case OpmetingVeluxGootstukType.edw2000:
        return 'EDW 2000';
      case OpmetingVeluxGootstukType.edt2000:
        return 'EDT 2000';
      case OpmetingVeluxGootstukType.edp2000:
        return 'EDP 2000';
      case OpmetingVeluxGootstukType.edb2000:
        return 'EDB 2000';
    }
  }

  String get productCode => this == OpmetingVeluxGootstukType.geen ? '' : label;

  String get assetPad {
    switch (this) {
      case OpmetingVeluxGootstukType.geen:
        return '';
      case OpmetingVeluxGootstukType.edw2000:
        return 'assets/images/velux_gootstuk_edw.png';
      case OpmetingVeluxGootstukType.edt2000:
        return 'assets/images/velux_gootstuk_edt.png';
      case OpmetingVeluxGootstukType.edp2000:
        return 'assets/images/velux_gootstuk_edp.png';
      case OpmetingVeluxGootstukType.edb2000:
        return 'assets/images/velux_gootstuk_edb.png';
    }
  }

  static OpmetingVeluxGootstukType vanOpslag(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    for (final type in OpmetingVeluxGootstukType.values) {
      if (type.name.toLowerCase() == tekst ||
          type.label.toLowerCase() == tekst) {
        return type;
      }
    }
    return OpmetingVeluxGootstukType.geen;
  }
}

enum OpmetingVeluxRolluikType { geen, zonneEnergieSsl, elektrischSml }

extension OpmetingVeluxRolluikTypeExtension on OpmetingVeluxRolluikType {
  String get label {
    switch (this) {
      case OpmetingVeluxRolluikType.geen:
        return 'Geen rolluik';
      case OpmetingVeluxRolluikType.zonneEnergieSsl:
        return 'Op zonne-energie SSL';
      case OpmetingVeluxRolluikType.elektrischSml:
        return 'Elektrisch SML';
    }
  }

  String get productCode {
    switch (this) {
      case OpmetingVeluxRolluikType.geen:
        return '';
      case OpmetingVeluxRolluikType.zonneEnergieSsl:
        return 'SSL';
      case OpmetingVeluxRolluikType.elektrischSml:
        return 'SML';
    }
  }

  static OpmetingVeluxRolluikType vanOpslag(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    for (final type in OpmetingVeluxRolluikType.values) {
      if (type.name.toLowerCase() == tekst ||
          type.label.toLowerCase() == tekst) {
        return type;
      }
    }
    return OpmetingVeluxRolluikType.geen;
  }
}

enum OpmetingVeluxScreenType {
  geen,
  zonneEnergieMsl,
  elektrischMml,
  manueelMhl,
}

extension OpmetingVeluxScreenTypeExtension on OpmetingVeluxScreenType {
  String get label {
    switch (this) {
      case OpmetingVeluxScreenType.geen:
        return 'Geen buitenscreen';
      case OpmetingVeluxScreenType.zonneEnergieMsl:
        return 'Op zonne-energie MSL';
      case OpmetingVeluxScreenType.elektrischMml:
        return 'Elektrisch MML';
      case OpmetingVeluxScreenType.manueelMhl:
        return 'Manueel MHL';
    }
  }

  String get productCode {
    switch (this) {
      case OpmetingVeluxScreenType.geen:
        return '';
      case OpmetingVeluxScreenType.zonneEnergieMsl:
        return 'MSL';
      case OpmetingVeluxScreenType.elektrischMml:
        return 'MML';
      case OpmetingVeluxScreenType.manueelMhl:
        return 'MHL';
    }
  }

  static OpmetingVeluxScreenType vanOpslag(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    for (final type in OpmetingVeluxScreenType.values) {
      if (type.name.toLowerCase() == tekst ||
          type.label.toLowerCase() == tekst) {
        return type;
      }
    }
    return OpmetingVeluxScreenType.geen;
  }
}

enum OpmetingVeluxDklKleur {
  creme1085,
  blauw1100,
  grijs0705,
  wit1025,
  zwart3009,
}

extension OpmetingVeluxDklKleurExtension on OpmetingVeluxDklKleur {
  String get nummer {
    switch (this) {
      case OpmetingVeluxDklKleur.creme1085:
        return '1085';
      case OpmetingVeluxDklKleur.blauw1100:
        return '1100';
      case OpmetingVeluxDklKleur.grijs0705:
        return '0705';
      case OpmetingVeluxDklKleur.wit1025:
        return '1025';
      case OpmetingVeluxDklKleur.zwart3009:
        return '3009';
    }
  }

  String get kleurNaam {
    switch (this) {
      case OpmetingVeluxDklKleur.creme1085:
        return 'Crème';
      case OpmetingVeluxDklKleur.blauw1100:
        return 'Blauw';
      case OpmetingVeluxDklKleur.grijs0705:
        return 'Grijs';
      case OpmetingVeluxDklKleur.wit1025:
        return 'Wit';
      case OpmetingVeluxDklKleur.zwart3009:
        return 'Zwart';
    }
  }

  String get label => '$nummer · $kleurNaam';

  static OpmetingVeluxDklKleur vanOpslag(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    for (final kleur in OpmetingVeluxDklKleur.values) {
      if (kleur.name.toLowerCase() == tekst ||
          kleur.nummer.toLowerCase() == tekst ||
          kleur.label.toLowerCase() == tekst) {
        return kleur;
      }
    }
    return OpmetingVeluxDklKleur.creme1085;
  }
}

enum OpmetingVeluxAfwerkingType { geen, mdfWaterwerend, kunststofWit }

extension OpmetingVeluxAfwerkingTypeExtension on OpmetingVeluxAfwerkingType {
  String get label {
    switch (this) {
      case OpmetingVeluxAfwerkingType.geen:
        return 'Geen afwerking';
      case OpmetingVeluxAfwerkingType.mdfWaterwerend:
        return 'Chambrangs en binnenkasten in MDF waterwerend';
      case OpmetingVeluxAfwerkingType.kunststofWit:
        return 'Chambrangs en binnenkasten in kunststof kleur wit';
    }
  }

  static OpmetingVeluxAfwerkingType vanOpslag(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    for (final type in OpmetingVeluxAfwerkingType.values) {
      if (type.name.toLowerCase() == tekst ||
          type.label.toLowerCase() == tekst) {
        return type;
      }
    }
    return OpmetingVeluxAfwerkingType.geen;
  }
}

class OpmetingVeluxDakraamModel {
  const OpmetingVeluxDakraamModel({
    this.alleenToebehoren = false,
    this.aantal = 1,
    this.productCode = 'GGU 0070',
    this.maatCode = 'SK06',
    this.breedteMm = 1140,
    this.hoogteMm = 1180,
    this.gootstukType = OpmetingVeluxGootstukType.geen,
    this.rolluikType = OpmetingVeluxRolluikType.geen,
    this.rolluikAantal = 1,
    this.screenType = OpmetingVeluxScreenType.geen,
    this.screenAantal = 1,
    this.verduisteringsgordijnDkl = false,
    this.dklKleur = OpmetingVeluxDklKleur.creme1085,
    this.dklAantal = 1,
    this.muggengaas = false,
    this.muggengaasAantal = 1,
    this.muggengaasBreedteMm = 1140,
    this.muggengaasHoogteMm = 1180,
    this.muggengaasProductCode = '',
    this.kux110 = false,
    this.kuxAantal = 1,
    this.afwerkingType = OpmetingVeluxAfwerkingType.geen,
    this.catalogusJaar = 2026,
    this.basisPrijsPerStukExclBtw = 0,
    this.gootstukPrijsPerStukExclBtw = 0,
    this.rolluikPrijsPerStukExclBtw = 0,
    this.screenPrijsPerStukExclBtw = 0,
    this.dklPrijsPerStukExclBtw = 0,
    this.muggengaasPrijsPerStukExclBtw = 0,
    this.kuxPrijsPerStukExclBtw = 0,
    this.afwerkingPrijsPerStukExclBtw = 0,
    this.notities = '',
    this.fotos = const <OpmetingFoto>[],
  });

  final bool alleenToebehoren;
  final int aantal;
  final String productCode;
  final String maatCode;
  final int breedteMm;
  final int hoogteMm;
  final OpmetingVeluxGootstukType gootstukType;
  final OpmetingVeluxRolluikType rolluikType;
  final int rolluikAantal;
  final OpmetingVeluxScreenType screenType;
  final int screenAantal;
  final bool verduisteringsgordijnDkl;
  final OpmetingVeluxDklKleur dklKleur;
  final int dklAantal;
  final bool muggengaas;
  final int muggengaasAantal;
  final int muggengaasBreedteMm;
  final int muggengaasHoogteMm;
  final String muggengaasProductCode;
  final bool kux110;
  final int kuxAantal;
  final OpmetingVeluxAfwerkingType afwerkingType;
  final int catalogusJaar;
  final double basisPrijsPerStukExclBtw;
  final double gootstukPrijsPerStukExclBtw;
  final double rolluikPrijsPerStukExclBtw;
  final double screenPrijsPerStukExclBtw;
  final double dklPrijsPerStukExclBtw;
  final double muggengaasPrijsPerStukExclBtw;
  final double kuxPrijsPerStukExclBtw;
  final double afwerkingPrijsPerStukExclBtw;
  final String notities;
  final List<OpmetingFoto> fotos;

  int get veiligAantal => aantal < 1 ? 1 : aantal;

  int beperkAccessoireAantal(int waarde) {
    if (alleenToebehoren) return waarde.clamp(1, 99).toInt();
    return waarde.clamp(1, veiligAantal).toInt();
  }

  int get effectiefRolluikAantal => rolluikType == OpmetingVeluxRolluikType.geen
      ? 0
      : beperkAccessoireAantal(rolluikAantal);

  int get effectiefScreenAantal => screenType == OpmetingVeluxScreenType.geen
      ? 0
      : beperkAccessoireAantal(screenAantal);

  int get effectiefDklAantal =>
      verduisteringsgordijnDkl ? beperkAccessoireAantal(dklAantal) : 0;

  int get effectiefMuggengaasAantal =>
      muggengaas ? beperkAccessoireAantal(muggengaasAantal) : 0;

  double get basisTotaalExclBtw =>
      alleenToebehoren ? 0 : basisPrijsPerStukExclBtw * veiligAantal;

  double get gootstukTotaalExclBtw =>
      alleenToebehoren ? 0 : gootstukPrijsPerStukExclBtw * veiligAantal;

  double get rolluikTotaalExclBtw =>
      rolluikPrijsPerStukExclBtw * effectiefRolluikAantal;

  double get screenTotaalExclBtw =>
      screenPrijsPerStukExclBtw * effectiefScreenAantal;

  double get dklTotaalExclBtw => dklPrijsPerStukExclBtw * effectiefDklAantal;

  double get muggengaasTotaalExclBtw =>
      muggengaasPrijsPerStukExclBtw * effectiefMuggengaasAantal;

  double get kuxTotaalExclBtw =>
      kux110 ? kuxPrijsPerStukExclBtw * kuxAantal.clamp(1, 99).toInt() : 0;

  // Binnenafwerking wordt via de centrale technische prijsregels berekend.
  // Het oude veld blijft uitsluitend bestaan voor achterwaartse JSON-compatibiliteit.
  double get afwerkingTotaalExclBtw => 0;

  double get catalogusTotaalExclBtw =>
      basisTotaalExclBtw +
      gootstukTotaalExclBtw +
      rolluikTotaalExclBtw +
      screenTotaalExclBtw +
      dklTotaalExclBtw +
      muggengaasTotaalExclBtw +
      kuxTotaalExclBtw +
      afwerkingTotaalExclBtw;

  double get prijsPerArtikelEquivalentExclBtw =>
      catalogusTotaalExclBtw / veiligAantal;

  String get afmetingLabel => '$breedteMm × $hoogteMm mm';

  OpmetingVeluxDakraamModel copyWith({
    bool? alleenToebehoren,
    int? aantal,
    String? productCode,
    String? maatCode,
    int? breedteMm,
    int? hoogteMm,
    OpmetingVeluxGootstukType? gootstukType,
    OpmetingVeluxRolluikType? rolluikType,
    int? rolluikAantal,
    OpmetingVeluxScreenType? screenType,
    int? screenAantal,
    bool? verduisteringsgordijnDkl,
    OpmetingVeluxDklKleur? dklKleur,
    int? dklAantal,
    bool? muggengaas,
    int? muggengaasAantal,
    int? muggengaasBreedteMm,
    int? muggengaasHoogteMm,
    String? muggengaasProductCode,
    bool? kux110,
    int? kuxAantal,
    OpmetingVeluxAfwerkingType? afwerkingType,
    int? catalogusJaar,
    double? basisPrijsPerStukExclBtw,
    double? gootstukPrijsPerStukExclBtw,
    double? rolluikPrijsPerStukExclBtw,
    double? screenPrijsPerStukExclBtw,
    double? dklPrijsPerStukExclBtw,
    double? muggengaasPrijsPerStukExclBtw,
    double? kuxPrijsPerStukExclBtw,
    double? afwerkingPrijsPerStukExclBtw,
    String? notities,
    List<OpmetingFoto>? fotos,
  }) {
    return OpmetingVeluxDakraamModel(
      alleenToebehoren: alleenToebehoren ?? this.alleenToebehoren,
      aantal: aantal ?? this.aantal,
      productCode: productCode ?? this.productCode,
      maatCode: maatCode ?? this.maatCode,
      breedteMm: breedteMm ?? this.breedteMm,
      hoogteMm: hoogteMm ?? this.hoogteMm,
      gootstukType: gootstukType ?? this.gootstukType,
      rolluikType: rolluikType ?? this.rolluikType,
      rolluikAantal: rolluikAantal ?? this.rolluikAantal,
      screenType: screenType ?? this.screenType,
      screenAantal: screenAantal ?? this.screenAantal,
      verduisteringsgordijnDkl:
          verduisteringsgordijnDkl ?? this.verduisteringsgordijnDkl,
      dklKleur: dklKleur ?? this.dklKleur,
      dklAantal: dklAantal ?? this.dklAantal,
      muggengaas: muggengaas ?? this.muggengaas,
      muggengaasAantal: muggengaasAantal ?? this.muggengaasAantal,
      muggengaasBreedteMm: muggengaasBreedteMm ?? this.muggengaasBreedteMm,
      muggengaasHoogteMm: muggengaasHoogteMm ?? this.muggengaasHoogteMm,
      muggengaasProductCode:
          muggengaasProductCode ?? this.muggengaasProductCode,
      kux110: kux110 ?? this.kux110,
      kuxAantal: kuxAantal ?? this.kuxAantal,
      afwerkingType: afwerkingType ?? this.afwerkingType,
      catalogusJaar: catalogusJaar ?? this.catalogusJaar,
      basisPrijsPerStukExclBtw:
          basisPrijsPerStukExclBtw ?? this.basisPrijsPerStukExclBtw,
      gootstukPrijsPerStukExclBtw:
          gootstukPrijsPerStukExclBtw ?? this.gootstukPrijsPerStukExclBtw,
      rolluikPrijsPerStukExclBtw:
          rolluikPrijsPerStukExclBtw ?? this.rolluikPrijsPerStukExclBtw,
      screenPrijsPerStukExclBtw:
          screenPrijsPerStukExclBtw ?? this.screenPrijsPerStukExclBtw,
      dklPrijsPerStukExclBtw:
          dklPrijsPerStukExclBtw ?? this.dklPrijsPerStukExclBtw,
      muggengaasPrijsPerStukExclBtw:
          muggengaasPrijsPerStukExclBtw ?? this.muggengaasPrijsPerStukExclBtw,
      kuxPrijsPerStukExclBtw:
          kuxPrijsPerStukExclBtw ?? this.kuxPrijsPerStukExclBtw,
      afwerkingPrijsPerStukExclBtw:
          afwerkingPrijsPerStukExclBtw ?? this.afwerkingPrijsPerStukExclBtw,
      notities: notities ?? this.notities,
      fotos: List<OpmetingFoto>.unmodifiable(fotos ?? this.fotos),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'alleenToebehoren': alleenToebehoren,
    'aantal': aantal,
    'productCode': productCode,
    'maatCode': maatCode,
    'breedteMm': breedteMm,
    'hoogteMm': hoogteMm,
    'gootstukType': gootstukType.name,
    'rolluikType': rolluikType.name,
    'rolluikAantal': rolluikAantal,
    'screenType': screenType.name,
    'screenAantal': screenAantal,
    'verduisteringsgordijnDkl': verduisteringsgordijnDkl,
    'dklKleur': dklKleur.name,
    'dklAantal': dklAantal,
    'muggengaas': muggengaas,
    'muggengaasAantal': muggengaasAantal,
    'muggengaasBreedteMm': muggengaasBreedteMm,
    'muggengaasHoogteMm': muggengaasHoogteMm,
    'muggengaasProductCode': muggengaasProductCode,
    'kux110': kux110,
    'kuxAantal': kuxAantal,
    'afwerkingType': afwerkingType.name,
    'catalogusJaar': catalogusJaar,
    'basisPrijsPerStukExclBtw': basisPrijsPerStukExclBtw,
    'gootstukPrijsPerStukExclBtw': gootstukPrijsPerStukExclBtw,
    'rolluikPrijsPerStukExclBtw': rolluikPrijsPerStukExclBtw,
    'screenPrijsPerStukExclBtw': screenPrijsPerStukExclBtw,
    'dklPrijsPerStukExclBtw': dklPrijsPerStukExclBtw,
    'muggengaasPrijsPerStukExclBtw': muggengaasPrijsPerStukExclBtw,
    'kuxPrijsPerStukExclBtw': kuxPrijsPerStukExclBtw,
    'afwerkingPrijsPerStukExclBtw': afwerkingPrijsPerStukExclBtw,
    'notities': notities,
    'fotos': fotos.map((foto) => foto.toJson()).toList(growable: false),
  };

  factory OpmetingVeluxDakraamModel.fromJson(Map<String, dynamic> json) {
    return OpmetingVeluxDakraamModel(
      alleenToebehoren: json['alleenToebehoren'] == true,
      aantal: _int(json['aantal'], 1).clamp(1, 99).toInt(),
      productCode: json['productCode']?.toString().trim().isNotEmpty == true
          ? json['productCode'].toString().trim()
          : 'GGU 0070',
      maatCode: json['maatCode']?.toString().trim().isNotEmpty == true
          ? json['maatCode'].toString().trim()
          : 'SK06',
      breedteMm: _int(json['breedteMm'], 1140),
      hoogteMm: _int(json['hoogteMm'], 1180),
      gootstukType: OpmetingVeluxGootstukTypeExtension.vanOpslag(
        json['gootstukType'],
      ),
      rolluikType: OpmetingVeluxRolluikTypeExtension.vanOpslag(
        json['rolluikType'],
      ),
      rolluikAantal: _int(json['rolluikAantal'], 1).clamp(1, 99).toInt(),
      screenType: OpmetingVeluxScreenTypeExtension.vanOpslag(
        json['screenType'],
      ),
      screenAantal: _int(json['screenAantal'], 1).clamp(1, 99).toInt(),
      verduisteringsgordijnDkl: json['verduisteringsgordijnDkl'] == true,
      dklKleur: OpmetingVeluxDklKleurExtension.vanOpslag(json['dklKleur']),
      dklAantal: _int(json['dklAantal'], 1).clamp(1, 99).toInt(),
      muggengaas: json['muggengaas'] == true,
      muggengaasAantal: _int(json['muggengaasAantal'], 1).clamp(1, 99).toInt(),
      muggengaasBreedteMm: _int(json['muggengaasBreedteMm'], 1140),
      muggengaasHoogteMm: _int(json['muggengaasHoogteMm'], 1180),
      muggengaasProductCode:
          json['muggengaasProductCode']?.toString().trim() ?? '',
      kux110: json['kux110'] == true,
      kuxAantal: _int(json['kuxAantal'], 1).clamp(1, 99).toInt(),
      afwerkingType: OpmetingVeluxAfwerkingTypeExtension.vanOpslag(
        json['afwerkingType'],
      ),
      catalogusJaar: _int(json['catalogusJaar'], 2026),
      basisPrijsPerStukExclBtw: _double(json['basisPrijsPerStukExclBtw']),
      gootstukPrijsPerStukExclBtw: _double(json['gootstukPrijsPerStukExclBtw']),
      rolluikPrijsPerStukExclBtw: _double(json['rolluikPrijsPerStukExclBtw']),
      screenPrijsPerStukExclBtw: _double(json['screenPrijsPerStukExclBtw']),
      dklPrijsPerStukExclBtw: _double(json['dklPrijsPerStukExclBtw']),
      muggengaasPrijsPerStukExclBtw: _double(
        json['muggengaasPrijsPerStukExclBtw'],
      ),
      kuxPrijsPerStukExclBtw: _double(json['kuxPrijsPerStukExclBtw']),
      afwerkingPrijsPerStukExclBtw: _double(
        json['afwerkingPrijsPerStukExclBtw'],
      ),
      notities: json['notities']?.toString() ?? '',
      fotos: _leesFotos(json['fotos']),
    );
  }

  static int _int(Object? waarde, int standaard) {
    if (waarde is int) return waarde;
    if (waarde is num) return waarde.toInt();
    return int.tryParse(waarde?.toString() ?? '') ?? standaard;
  }

  static double _double(Object? waarde) {
    if (waarde is num) return waarde.toDouble();
    return double.tryParse((waarde?.toString() ?? '').replaceAll(',', '.')) ??
        0;
  }

  static List<OpmetingFoto> _leesFotos(Object? waarde) {
    if (waarde is! List) return const <OpmetingFoto>[];
    return waarde
        .whereType<Map>()
        .map((item) => OpmetingFoto.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }
}
