enum OpmetingRaamTechnischeMaatKeuze { vasteMaat, volledigeRaammaat }

extension OpmetingRaamTechnischeMaatKeuzeExtension
    on OpmetingRaamTechnischeMaatKeuze {
  String get opslagWaarde {
    return name;
  }

  String get breedteWeergaveNaam {
    switch (this) {
      case OpmetingRaamTechnischeMaatKeuze.vasteMaat:
        return 'Vaste breedte in mm';

      case OpmetingRaamTechnischeMaatKeuze.volledigeRaammaat:
        return 'Volledige raambreedte';
    }
  }

  String get hoogteWeergaveNaam {
    switch (this) {
      case OpmetingRaamTechnischeMaatKeuze.vasteMaat:
        return 'Vaste hoogte in mm';

      case OpmetingRaamTechnischeMaatKeuze.volledigeRaammaat:
        return 'Volledige raamhoogte';
    }
  }

  static OpmetingRaamTechnischeMaatKeuze vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';

    for (final keuze in OpmetingRaamTechnischeMaatKeuze.values) {
      if (keuze.name == tekst) {
        return keuze;
      }
    }

    return OpmetingRaamTechnischeMaatKeuze.vasteMaat;
  }
}

enum OpmetingRaamTechnischePositie { boven, onder, links, rechts }

extension OpmetingRaamTechnischePositieExtension
    on OpmetingRaamTechnischePositie {
  String get opslagWaarde {
    return name;
  }

  String get label {
    switch (this) {
      case OpmetingRaamTechnischePositie.boven:
        return 'Boven';

      case OpmetingRaamTechnischePositie.onder:
        return 'Onder';

      case OpmetingRaamTechnischePositie.links:
        return 'Links';

      case OpmetingRaamTechnischePositie.rechts:
        return 'Rechts';
    }
  }

  static OpmetingRaamTechnischePositie vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';

    for (final positie in OpmetingRaamTechnischePositie.values) {
      if (positie.name == tekst) {
        return positie;
      }
    }

    return OpmetingRaamTechnischePositie.boven;
  }
}

enum OpmetingRaamTechnischeMaatPlaatsing { inDeRaammaat, buitenDeRaammaat }

extension OpmetingRaamTechnischeMaatPlaatsingExtension
    on OpmetingRaamTechnischeMaatPlaatsing {
  String get opslagWaarde {
    return name;
  }

  String get label {
    switch (this) {
      case OpmetingRaamTechnischeMaatPlaatsing.inDeRaammaat:
        return 'In de raammaat';

      case OpmetingRaamTechnischeMaatPlaatsing.buitenDeRaammaat:
        return 'Buiten de raammaat';
    }
  }

  static OpmetingRaamTechnischeMaatPlaatsing vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';

    for (final plaatsing in OpmetingRaamTechnischeMaatPlaatsing.values) {
      if (plaatsing.name == tekst) {
        return plaatsing;
      }
    }

    return OpmetingRaamTechnischeMaatPlaatsing.inDeRaammaat;
  }
}

enum OpmetingRaamTechnischRasterPatroon {
  horizontaleLijnen,
  verticaleLijnen,
  diagonaalRechts,
  diagonaalLinks,
  kruisarcering,
  vierkantRaster,
  punten,
  cirkels,
  ruiten,
  zigzag,
}

extension OpmetingRaamTechnischRasterPatroonExtension
    on OpmetingRaamTechnischRasterPatroon {
  String get opslagWaarde {
    return name;
  }

  String get label {
    switch (this) {
      case OpmetingRaamTechnischRasterPatroon.horizontaleLijnen:
        return 'Horizontale lijnen';

      case OpmetingRaamTechnischRasterPatroon.verticaleLijnen:
        return 'Verticale lijnen';

      case OpmetingRaamTechnischRasterPatroon.diagonaalRechts:
        return 'Diagonaal rechts';

      case OpmetingRaamTechnischRasterPatroon.diagonaalLinks:
        return 'Diagonaal links';

      case OpmetingRaamTechnischRasterPatroon.kruisarcering:
        return 'Kruisarcering';

      case OpmetingRaamTechnischRasterPatroon.vierkantRaster:
        return 'Vierkant raster';

      case OpmetingRaamTechnischRasterPatroon.punten:
        return 'Punten';

      case OpmetingRaamTechnischRasterPatroon.cirkels:
        return 'Cirkels';

      case OpmetingRaamTechnischRasterPatroon.ruiten:
        return 'Ruiten';

      case OpmetingRaamTechnischRasterPatroon.zigzag:
        return 'Zigzag';
    }
  }

  static OpmetingRaamTechnischRasterPatroon vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';

    for (final patroon in OpmetingRaamTechnischRasterPatroon.values) {
      if (patroon.name == tekst) {
        return patroon;
      }
    }

    return OpmetingRaamTechnischRasterPatroon.horizontaleLijnen;
  }
}

enum OpmetingRaamTechnischeInhoudType { raster, tekst }

extension OpmetingRaamTechnischeInhoudTypeExtension
    on OpmetingRaamTechnischeInhoudType {
  String get opslagWaarde {
    return name;
  }

  String get label {
    switch (this) {
      case OpmetingRaamTechnischeInhoudType.raster:
        return 'Rasterpatroon';

      case OpmetingRaamTechnischeInhoudType.tekst:
        return 'Tekst';
    }
  }

  static OpmetingRaamTechnischeInhoudType vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';

    for (final type in OpmetingRaamTechnischeInhoudType.values) {
      if (type.name == tekst) {
        return type;
      }
    }

    return OpmetingRaamTechnischeInhoudType.raster;
  }
}

class OpmetingRaamTechnischeTekeningInstelling {
  const OpmetingRaamTechnischeTekeningInstelling({
    required this.actief,
    required this.breedteKeuze,
    required this.breedteMm,
    required this.hoogteKeuze,
    required this.hoogteMm,
    required this.positie,
    required this.maatPlaatsing,
    required this.rasterPatroon,
    this.afstandMm = 0,
    this.inhoudType = OpmetingRaamTechnischeInhoudType.raster,
    this.tekst = '',
  });

  final bool actief;

  final OpmetingRaamTechnischeMaatKeuze breedteKeuze;
  final int breedteMm;

  final OpmetingRaamTechnischeMaatKeuze hoogteKeuze;
  final int hoogteMm;

  final OpmetingRaamTechnischePositie positie;
  final OpmetingRaamTechnischeMaatPlaatsing maatPlaatsing;

  final int afstandMm;
  final OpmetingRaamTechnischeInhoudType inhoudType;
  final OpmetingRaamTechnischRasterPatroon rasterPatroon;
  final String tekst;

  factory OpmetingRaamTechnischeTekeningInstelling.standaard({
    bool actief = false,
  }) {
    return OpmetingRaamTechnischeTekeningInstelling(
      actief: actief,
      breedteKeuze: OpmetingRaamTechnischeMaatKeuze.volledigeRaammaat,
      breedteMm: 100,
      hoogteKeuze: OpmetingRaamTechnischeMaatKeuze.vasteMaat,
      hoogteMm: 60,
      positie: OpmetingRaamTechnischePositie.boven,
      maatPlaatsing: OpmetingRaamTechnischeMaatPlaatsing.inDeRaammaat,
      afstandMm: 0,
      inhoudType: OpmetingRaamTechnischeInhoudType.raster,
      rasterPatroon: OpmetingRaamTechnischRasterPatroon.horizontaleLijnen,
      tekst: '',
    );
  }

  bool get staatInDeRaammaat {
    return maatPlaatsing == OpmetingRaamTechnischeMaatPlaatsing.inDeRaammaat;
  }

  bool get staatBuitenDeRaammaat {
    return maatPlaatsing ==
        OpmetingRaamTechnischeMaatPlaatsing.buitenDeRaammaat;
  }

  bool get gebruiktRaster {
    return inhoudType == OpmetingRaamTechnischeInhoudType.raster;
  }

  bool get gebruiktTekst {
    return inhoudType == OpmetingRaamTechnischeInhoudType.tekst;
  }

  bool get staatHorizontaal {
    return positie == OpmetingRaamTechnischePositie.boven ||
        positie == OpmetingRaamTechnischePositie.onder;
  }

  bool get staatVerticaal {
    return positie == OpmetingRaamTechnischePositie.links ||
        positie == OpmetingRaamTechnischePositie.rechts;
  }

  int effectieveBreedteMm({required int raammaatBreedte}) {
    if (breedteKeuze == OpmetingRaamTechnischeMaatKeuze.volledigeRaammaat) {
      return raammaatBreedte;
    }

    return breedteMm;
  }

  int effectieveHoogteMm({required int raammaatHoogte}) {
    if (hoogteKeuze == OpmetingRaamTechnischeMaatKeuze.volledigeRaammaat) {
      return raammaatHoogte;
    }

    return hoogteMm;
  }

  OpmetingRaamTechnischeTekeningInstelling copyWith({
    bool? actief,
    OpmetingRaamTechnischeMaatKeuze? breedteKeuze,
    int? breedteMm,
    OpmetingRaamTechnischeMaatKeuze? hoogteKeuze,
    int? hoogteMm,
    OpmetingRaamTechnischePositie? positie,
    OpmetingRaamTechnischeMaatPlaatsing? maatPlaatsing,
    int? afstandMm,
    OpmetingRaamTechnischeInhoudType? inhoudType,
    OpmetingRaamTechnischRasterPatroon? rasterPatroon,
    String? tekst,
  }) {
    return OpmetingRaamTechnischeTekeningInstelling(
      actief: actief ?? this.actief,
      breedteKeuze: breedteKeuze ?? this.breedteKeuze,
      breedteMm: breedteMm ?? this.breedteMm,
      hoogteKeuze: hoogteKeuze ?? this.hoogteKeuze,
      hoogteMm: hoogteMm ?? this.hoogteMm,
      positie: positie ?? this.positie,
      maatPlaatsing: maatPlaatsing ?? this.maatPlaatsing,
      afstandMm: afstandMm ?? this.afstandMm,
      inhoudType: inhoudType ?? this.inhoudType,
      rasterPatroon: rasterPatroon ?? this.rasterPatroon,
      tekst: tekst ?? this.tekst,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'actief': actief,
      'breedteKeuze': breedteKeuze.opslagWaarde,
      'breedteMm': breedteMm,
      'hoogteKeuze': hoogteKeuze.opslagWaarde,
      'hoogteMm': hoogteMm,
      'positie': positie.opslagWaarde,
      'maatPlaatsing': maatPlaatsing.opslagWaarde,
      'afstandMm': afstandMm,
      'inhoudType': inhoudType.opslagWaarde,
      'rasterPatroon': rasterPatroon.opslagWaarde,
      'tekst': tekst,
    };
  }

  factory OpmetingRaamTechnischeTekeningInstelling.fromJson(
    Map<String, dynamic> json,
  ) {
    return OpmetingRaamTechnischeTekeningInstelling(
      actief: json['actief'] != false,
      breedteKeuze: OpmetingRaamTechnischeMaatKeuzeExtension.vanOpslagWaarde(
        json['breedteKeuze'],
      ),
      breedteMm: _leesGeheelGetal(json['breedteMm'], standaardWaarde: 100),
      hoogteKeuze: OpmetingRaamTechnischeMaatKeuzeExtension.vanOpslagWaarde(
        json['hoogteKeuze'],
      ),
      hoogteMm: _leesGeheelGetal(json['hoogteMm'], standaardWaarde: 60),
      positie: OpmetingRaamTechnischePositieExtension.vanOpslagWaarde(
        json['positie'],
      ),
      maatPlaatsing:
          OpmetingRaamTechnischeMaatPlaatsingExtension.vanOpslagWaarde(
            json['maatPlaatsing'],
          ),
      afstandMm: _leesGeheelGetal(json['afstandMm']),
      inhoudType: OpmetingRaamTechnischeInhoudTypeExtension.vanOpslagWaarde(
        json['inhoudType'],
      ),
      rasterPatroon:
          OpmetingRaamTechnischRasterPatroonExtension.vanOpslagWaarde(
            json['rasterPatroon'],
          ),
      tekst: json['tekst']?.toString() ?? '',
    );
  }
}

enum OpmetingRaamTekenfunctie {
  geen,
  ventilatieroosterBoven,
  ventilatieroosterInGlas,
  dorpelOnderKader,
  rolluikkastBoven,
  screenkastBoven,
  tekstlabel,
}

extension OpmetingRaamTekenfunctieExtension on OpmetingRaamTekenfunctie {
  String get opslagWaarde {
    return name;
  }

  String get weergaveNaam {
    switch (this) {
      case OpmetingRaamTekenfunctie.geen:
        return 'Geen tekening';

      case OpmetingRaamTekenfunctie.ventilatieroosterBoven:
        return 'Ventilatierooster bovenaan';

      case OpmetingRaamTekenfunctie.ventilatieroosterInGlas:
        return 'Ventilatierooster in glas';

      case OpmetingRaamTekenfunctie.dorpelOnderKader:
        return 'Dorpel onder kader';

      case OpmetingRaamTekenfunctie.rolluikkastBoven:
        return 'Rolluikkast boven kader';

      case OpmetingRaamTekenfunctie.screenkastBoven:
        return 'Screenkast boven kader';

      case OpmetingRaamTekenfunctie.tekstlabel:
        return 'Tekstlabel';
    }
  }

  static OpmetingRaamTekenfunctie vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';

    for (final tekenfunctie in OpmetingRaamTekenfunctie.values) {
      if (tekenfunctie.name == tekst) {
        return tekenfunctie;
      }
    }

    return OpmetingRaamTekenfunctie.geen;
  }
}

enum OpmetingRaamExtraVeldType { tekst, getal, keuze, schakelaar }

extension OpmetingRaamExtraVeldTypeExtension on OpmetingRaamExtraVeldType {
  String get opslagWaarde {
    return name;
  }

  String get weergaveNaam {
    switch (this) {
      case OpmetingRaamExtraVeldType.tekst:
        return 'Tekst';

      case OpmetingRaamExtraVeldType.getal:
        return 'Getal';

      case OpmetingRaamExtraVeldType.keuze:
        return 'Keuzelijst';

      case OpmetingRaamExtraVeldType.schakelaar:
        return 'Ja/nee';
    }
  }

  static OpmetingRaamExtraVeldType vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';

    for (final veldType in OpmetingRaamExtraVeldType.values) {
      if (veldType.name == tekst) {
        return veldType;
      }
    }

    return OpmetingRaamExtraVeldType.tekst;
  }
}

class OpmetingRaamExtraVeldDefinitie {
  const OpmetingRaamExtraVeldDefinitie({
    required this.id,
    required this.label,
    required this.type,
    this.eenheid = '',
    this.standaardWaarde = '',
    this.keuzes = const <String>[],
    this.verplicht = false,
  });

  final String id;
  final String label;
  final OpmetingRaamExtraVeldType type;

  final String eenheid;
  final String standaardWaarde;
  final List<String> keuzes;
  final bool verplicht;

  OpmetingRaamExtraVeldDefinitie copyWith({
    String? id,
    String? label,
    OpmetingRaamExtraVeldType? type,
    String? eenheid,
    String? standaardWaarde,
    List<String>? keuzes,
    bool? verplicht,
  }) {
    return OpmetingRaamExtraVeldDefinitie(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      eenheid: eenheid ?? this.eenheid,
      standaardWaarde: standaardWaarde ?? this.standaardWaarde,
      keuzes: keuzes ?? this.keuzes,
      verplicht: verplicht ?? this.verplicht,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'type': type.opslagWaarde,
      'eenheid': eenheid,
      'standaardWaarde': standaardWaarde,
      'keuzes': keuzes,
      'verplicht': verplicht,
    };
  }

  factory OpmetingRaamExtraVeldDefinitie.fromJson(Map<String, dynamic> json) {
    final ruweKeuzes = json['keuzes'];

    final keuzes = ruweKeuzes is List
        ? ruweKeuzes
              .map((keuze) => keuze.toString())
              .where((keuze) => keuze.trim().isNotEmpty)
              .toList()
        : <String>[];

    return OpmetingRaamExtraVeldDefinitie(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      type: OpmetingRaamExtraVeldTypeExtension.vanOpslagWaarde(json['type']),
      eenheid: json['eenheid']?.toString() ?? '',
      standaardWaarde: json['standaardWaarde']?.toString() ?? '',
      keuzes: keuzes,
      verplicht: json['verplicht'] == true,
    );
  }
}

class OpmetingRaamNietCombineerbareKeuze {
  const OpmetingRaamNietCombineerbareKeuze({
    required this.menuId,
    required this.optieId,
  });

  final String menuId;
  final String optieId;

  String get sleutel {
    return '$menuId::$optieId';
  }

  bool get isGeldig {
    return menuId.trim().isNotEmpty && optieId.trim().isNotEmpty;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'menuId': menuId, 'optieId': optieId};
  }

  factory OpmetingRaamNietCombineerbareKeuze.fromJson(
    Map<String, dynamic> json,
  ) {
    return OpmetingRaamNietCombineerbareKeuze(
      menuId: json['menuId']?.toString() ?? '',
      optieId: json['optieId']?.toString() ?? '',
    );
  }
}

class OpmetingRaamKeuzeOptie {
  const OpmetingRaamKeuzeOptie({
    required this.id,
    required this.naam,
    required this.uitvoerTekst,
    required this.isGeenKeuze,
    required this.tekenfunctie,
    this.extraVelden = const <OpmetingRaamExtraVeldDefinitie>[],
    OpmetingRaamTechnischeTekeningInstelling? technischeTekening,
    this.technischeTekeningen =
        const <OpmetingRaamTechnischeTekeningInstelling>[],
    this.nietCombineerbaarMet = const <OpmetingRaamNietCombineerbareKeuze>[],
    this.actief = true,
  }) : _technischeTekening = technischeTekening;

  static const Object _technischeTekeningOngewijzigd = Object();

  final String id;
  final String naam;
  final String uitvoerTekst;
  final bool isGeenKeuze;
  final OpmetingRaamTekenfunctie tekenfunctie;

  final List<OpmetingRaamExtraVeldDefinitie> extraVelden;

  final OpmetingRaamTechnischeTekeningInstelling? _technischeTekening;

  final List<OpmetingRaamTechnischeTekeningInstelling> technischeTekeningen;

  final List<OpmetingRaamNietCombineerbareKeuze> nietCombineerbaarMet;

  final bool actief;

  OpmetingRaamTechnischeTekeningInstelling? get technischeTekening {
    if (technischeTekeningen.isNotEmpty) {
      return technischeTekeningen.first;
    }

    return _technischeTekening;
  }

  List<OpmetingRaamTechnischeTekeningInstelling> get alleTechnischeTekeningen {
    if (technischeTekeningen.isNotEmpty) {
      return List<OpmetingRaamTechnischeTekeningInstelling>.unmodifiable(
        technischeTekeningen.take(4),
      );
    }

    if (_technischeTekening != null) {
      return List<OpmetingRaamTechnischeTekeningInstelling>.unmodifiable(
        <OpmetingRaamTechnischeTekeningInstelling>[_technischeTekening!],
      );
    }

    return const <OpmetingRaamTechnischeTekeningInstelling>[];
  }

  factory OpmetingRaamKeuzeOptie.geen({required String menuId}) {
    return OpmetingRaamKeuzeOptie(
      id: '${menuId}_geen',
      naam: 'Geen',
      uitvoerTekst: '',
      isGeenKeuze: true,
      tekenfunctie: OpmetingRaamTekenfunctie.geen,
      technischeTekening: null,
      technischeTekeningen: const <OpmetingRaamTechnischeTekeningInstelling>[],
      nietCombineerbaarMet: const <OpmetingRaamNietCombineerbareKeuze>[],
    );
  }

  OpmetingRaamKeuzeOptie copyWith({
    String? id,
    String? naam,
    String? uitvoerTekst,
    bool? isGeenKeuze,
    OpmetingRaamTekenfunctie? tekenfunctie,
    List<OpmetingRaamExtraVeldDefinitie>? extraVelden,
    Object? technischeTekening = _technischeTekeningOngewijzigd,
    List<OpmetingRaamTechnischeTekeningInstelling>? technischeTekeningen,
    List<OpmetingRaamNietCombineerbareKeuze>? nietCombineerbaarMet,
    bool? actief,
  }) {
    final enkeleTekeningAangepast = !identical(
      technischeTekening,
      _technischeTekeningOngewijzigd,
    );

    final explicieteEnkeleTekening = enkeleTekeningAangepast
        ? technischeTekening as OpmetingRaamTechnischeTekeningInstelling?
        : null;

    late final List<OpmetingRaamTechnischeTekeningInstelling>
    nieuweTechnischeTekeningen;

    if (technischeTekeningen != null) {
      nieuweTechnischeTekeningen =
          List<OpmetingRaamTechnischeTekeningInstelling>.unmodifiable(
            technischeTekeningen.take(4),
          );
    } else if (enkeleTekeningAangepast) {
      nieuweTechnischeTekeningen = explicieteEnkeleTekening == null
          ? const <OpmetingRaamTechnischeTekeningInstelling>[]
          : List<OpmetingRaamTechnischeTekeningInstelling>.unmodifiable(
              <OpmetingRaamTechnischeTekeningInstelling>[
                explicieteEnkeleTekening,
              ],
            );
    } else {
      nieuweTechnischeTekeningen = this.technischeTekeningen;
    }

    late final OpmetingRaamTechnischeTekeningInstelling? nieuweEnkeleTekening;

    if (enkeleTekeningAangepast) {
      nieuweEnkeleTekening = explicieteEnkeleTekening;
    } else if (technischeTekeningen != null) {
      nieuweEnkeleTekening = nieuweTechnischeTekeningen.isEmpty
          ? null
          : nieuweTechnischeTekeningen.first;
    } else {
      nieuweEnkeleTekening = _technischeTekening;
    }

    return OpmetingRaamKeuzeOptie(
      id: id ?? this.id,
      naam: naam ?? this.naam,
      uitvoerTekst: uitvoerTekst ?? this.uitvoerTekst,
      isGeenKeuze: isGeenKeuze ?? this.isGeenKeuze,
      tekenfunctie: tekenfunctie ?? this.tekenfunctie,
      extraVelden: extraVelden ?? this.extraVelden,
      technischeTekening: nieuweEnkeleTekening,
      technischeTekeningen: nieuweTechnischeTekeningen,
      nietCombineerbaarMet: nietCombineerbaarMet ?? this.nietCombineerbaarMet,
      actief: actief ?? this.actief,
    );
  }

  Map<String, dynamic> toJson() {
    final tekeningen = alleTechnischeTekeningen;

    return <String, dynamic>{
      'id': id,
      'naam': naam,
      'uitvoerTekst': uitvoerTekst,
      'isGeenKeuze': isGeenKeuze,
      'tekenfunctie': tekenfunctie.opslagWaarde,
      'extraVelden': extraVelden.map((veld) => veld.toJson()).toList(),
      'technischeTekening': tekeningen.isEmpty
          ? null
          : tekeningen.first.toJson(),
      'technischeTekeningen': tekeningen
          .map((tekening) => tekening.toJson())
          .toList(),
      'nietCombineerbaarMet': nietCombineerbaarMet
          .where((koppeling) => koppeling.isGeldig)
          .map((koppeling) => koppeling.toJson())
          .toList(),
      'actief': actief,
    };
  }

  factory OpmetingRaamKeuzeOptie.fromJson(Map<String, dynamic> json) {
    final ruweExtraVelden = json['extraVelden'];

    final extraVelden = ruweExtraVelden is List
        ? ruweExtraVelden
              .whereType<Map>()
              .map(
                (veld) => OpmetingRaamExtraVeldDefinitie.fromJson(
                  Map<String, dynamic>.from(veld),
                ),
              )
              .toList()
        : <OpmetingRaamExtraVeldDefinitie>[];

    final technischeTekeningen = <OpmetingRaamTechnischeTekeningInstelling>[];

    final ruweTechnischeTekeningen = json['technischeTekeningen'];

    if (ruweTechnischeTekeningen is List) {
      for (final ruweTekening in ruweTechnischeTekeningen) {
        if (ruweTekening is! Map) {
          continue;
        }

        technischeTekeningen.add(
          OpmetingRaamTechnischeTekeningInstelling.fromJson(
            Map<String, dynamic>.from(ruweTekening),
          ),
        );

        if (technischeTekeningen.length >= 4) {
          break;
        }
      }
    }

    if (technischeTekeningen.isEmpty) {
      final ruweEnkeleTekening = json['technischeTekening'];

      if (ruweEnkeleTekening is Map) {
        technischeTekeningen.add(
          OpmetingRaamTechnischeTekeningInstelling.fromJson(
            Map<String, dynamic>.from(ruweEnkeleTekening),
          ),
        );
      }
    }

    final nietCombineerbaarMet = <OpmetingRaamNietCombineerbareKeuze>[];

    final ruweNietCombineerbaarMet = json['nietCombineerbaarMet'];

    if (ruweNietCombineerbaarMet is List) {
      final gebruikteSleutels = <String>{};

      for (final ruweKoppeling in ruweNietCombineerbaarMet) {
        if (ruweKoppeling is! Map) {
          continue;
        }

        final koppeling = OpmetingRaamNietCombineerbareKeuze.fromJson(
          Map<String, dynamic>.from(ruweKoppeling),
        );

        if (!koppeling.isGeldig) {
          continue;
        }

        if (!gebruikteSleutels.add(koppeling.sleutel)) {
          continue;
        }

        nietCombineerbaarMet.add(koppeling);
      }
    }

    return OpmetingRaamKeuzeOptie(
      id: json['id']?.toString() ?? '',
      naam: json['naam']?.toString() ?? '',
      uitvoerTekst: json['uitvoerTekst']?.toString() ?? '',
      isGeenKeuze: json['isGeenKeuze'] == true,
      tekenfunctie: OpmetingRaamTekenfunctieExtension.vanOpslagWaarde(
        json['tekenfunctie'],
      ),
      extraVelden: extraVelden,
      technischeTekening: technischeTekeningen.isEmpty
          ? null
          : technischeTekeningen.first,
      technischeTekeningen:
          List<OpmetingRaamTechnischeTekeningInstelling>.unmodifiable(
            technischeTekeningen,
          ),
      nietCombineerbaarMet:
          List<OpmetingRaamNietCombineerbareKeuze>.unmodifiable(
            nietCombineerbaarMet,
          ),
      actief: json['actief'] != false,
    );
  }
}

class OpmetingRaamKeuzeMenu {
  const OpmetingRaamKeuzeMenu({
    required this.id,
    required this.titel,
    required this.volgorde,
    required this.opties,
    this.actief = true,
  });

  final String id;
  final String titel;
  final int volgorde;
  final bool actief;

  final List<OpmetingRaamKeuzeOptie> opties;

  factory OpmetingRaamKeuzeMenu.nieuw({
    required String id,
    required String titel,
    required int volgorde,
  }) {
    return OpmetingRaamKeuzeMenu(
      id: id,
      titel: titel,
      volgorde: volgorde,
      opties: <OpmetingRaamKeuzeOptie>[OpmetingRaamKeuzeOptie.geen(menuId: id)],
    );
  }

  OpmetingRaamKeuzeOptie get geenOptie {
    for (final optie in opties) {
      if (optie.isGeenKeuze) {
        return optie;
      }
    }

    return OpmetingRaamKeuzeOptie.geen(menuId: id);
  }

  List<OpmetingRaamKeuzeOptie> get actieveOpties {
    final resultaat = opties.where((optie) => optie.actief).toList();

    resultaat.sort((eerste, tweede) {
      if (eerste.isGeenKeuze && !tweede.isGeenKeuze) {
        return -1;
      }

      if (!eerste.isGeenKeuze && tweede.isGeenKeuze) {
        return 1;
      }

      return eerste.naam.toLowerCase().compareTo(tweede.naam.toLowerCase());
    });

    return resultaat;
  }

  OpmetingRaamKeuzeMenu metGeldigeGeenOptie() {
    final resultaat = <OpmetingRaamKeuzeOptie>[];

    var geenOptieToegevoegd = false;

    for (final optie in opties) {
      if (optie.isGeenKeuze) {
        if (geenOptieToegevoegd) {
          continue;
        }

        resultaat.add(
          optie.copyWith(
            id: '${id}_geen',
            naam: 'Geen',
            uitvoerTekst: '',
            isGeenKeuze: true,
            tekenfunctie: OpmetingRaamTekenfunctie.geen,
            extraVelden: const <OpmetingRaamExtraVeldDefinitie>[],
            technischeTekening: null,
            technischeTekeningen:
                const <OpmetingRaamTechnischeTekeningInstelling>[],
            nietCombineerbaarMet: const <OpmetingRaamNietCombineerbareKeuze>[],
            actief: true,
          ),
        );

        geenOptieToegevoegd = true;
        continue;
      }

      resultaat.add(optie);
    }

    if (!geenOptieToegevoegd) {
      resultaat.insert(0, OpmetingRaamKeuzeOptie.geen(menuId: id));
    }

    return copyWith(opties: resultaat);
  }

  OpmetingRaamKeuzeMenu copyWith({
    String? id,
    String? titel,
    int? volgorde,
    bool? actief,
    List<OpmetingRaamKeuzeOptie>? opties,
  }) {
    return OpmetingRaamKeuzeMenu(
      id: id ?? this.id,
      titel: titel ?? this.titel,
      volgorde: volgorde ?? this.volgorde,
      actief: actief ?? this.actief,
      opties: opties ?? this.opties,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'titel': titel,
      'volgorde': volgorde,
      'actief': actief,
      'opties': opties.map((optie) => optie.toJson()).toList(),
    };
  }

  factory OpmetingRaamKeuzeMenu.fromJson(Map<String, dynamic> json) {
    final ruweOpties = json['opties'];

    final opties = ruweOpties is List
        ? ruweOpties
              .whereType<Map>()
              .map(
                (optie) => OpmetingRaamKeuzeOptie.fromJson(
                  Map<String, dynamic>.from(optie),
                ),
              )
              .toList()
        : <OpmetingRaamKeuzeOptie>[];

    final menu = OpmetingRaamKeuzeMenu(
      id: json['id']?.toString() ?? '',
      titel: json['titel']?.toString() ?? '',
      volgorde: _leesGeheelGetal(json['volgorde']),
      actief: json['actief'] != false,
      opties: opties,
    );

    return menu.metGeldigeGeenOptie();
  }
}

class OpmetingRaamKeuzeSelectie {
  const OpmetingRaamKeuzeSelectie({
    required this.menuId,
    required this.optieId,
    this.extraWaarden = const <String, dynamic>{},
  });

  final String menuId;
  final String optieId;

  final Map<String, dynamic> extraWaarden;

  OpmetingRaamKeuzeSelectie copyWith({
    String? menuId,
    String? optieId,
    Map<String, dynamic>? extraWaarden,
  }) {
    return OpmetingRaamKeuzeSelectie(
      menuId: menuId ?? this.menuId,
      optieId: optieId ?? this.optieId,
      extraWaarden: extraWaarden ?? this.extraWaarden,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'menuId': menuId,
      'optieId': optieId,
      'extraWaarden': extraWaarden,
    };
  }

  factory OpmetingRaamKeuzeSelectie.fromJson(Map<String, dynamic> json) {
    final ruweExtraWaarden = json['extraWaarden'];

    return OpmetingRaamKeuzeSelectie(
      menuId: json['menuId']?.toString() ?? '',
      optieId: json['optieId']?.toString() ?? '',
      extraWaarden: ruweExtraWaarden is Map
          ? Map<String, dynamic>.from(ruweExtraWaarden)
          : <String, dynamic>{},
    );
  }
}

int _leesGeheelGetal(Object? waarde, {int standaardWaarde = 0}) {
  if (waarde is int) {
    return waarde;
  }

  if (waarde is num) {
    return waarde.toInt();
  }

  return int.tryParse(waarde?.toString().trim() ?? '') ?? standaardWaarde;
}
