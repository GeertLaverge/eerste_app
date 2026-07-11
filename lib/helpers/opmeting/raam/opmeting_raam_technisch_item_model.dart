enum OpmetingRaamExtraTekeningPositie { boven, onder, links, rechts }

extension OpmetingRaamExtraTekeningPositieTekst
    on OpmetingRaamExtraTekeningPositie {
  String get label {
    switch (this) {
      case OpmetingRaamExtraTekeningPositie.boven:
        return 'Boven';

      case OpmetingRaamExtraTekeningPositie.onder:
        return 'Onder';

      case OpmetingRaamExtraTekeningPositie.links:
        return 'Links';

      case OpmetingRaamExtraTekeningPositie.rechts:
        return 'Rechts';
    }
  }
}

enum OpmetingRaamRasterPatroon {
  horizontaleStrepen,
  verticaleStrepen,
  diagonaalRechts,
  diagonaalLinks,
  kruisstrepen,
  vierkantRaster,
  stippen,
  bolletjes,
  ruiten,
  zigzag,
}

extension OpmetingRaamRasterPatroonTekst on OpmetingRaamRasterPatroon {
  String get label {
    switch (this) {
      case OpmetingRaamRasterPatroon.horizontaleStrepen:
        return 'Horizontale strepen';

      case OpmetingRaamRasterPatroon.verticaleStrepen:
        return 'Verticale strepen';

      case OpmetingRaamRasterPatroon.diagonaalRechts:
        return 'Diagonale strepen rechts';

      case OpmetingRaamRasterPatroon.diagonaalLinks:
        return 'Diagonale strepen links';

      case OpmetingRaamRasterPatroon.kruisstrepen:
        return 'Kruisstrepen';

      case OpmetingRaamRasterPatroon.vierkantRaster:
        return 'Vierkant raster';

      case OpmetingRaamRasterPatroon.stippen:
        return 'Stippen';

      case OpmetingRaamRasterPatroon.bolletjes:
        return 'Bolletjes';

      case OpmetingRaamRasterPatroon.ruiten:
        return 'Ruiten';

      case OpmetingRaamRasterPatroon.zigzag:
        return 'Zigzag';
    }
  }
}

class OpmetingRaamExtraTekeningModel {
  const OpmetingRaamExtraTekeningModel({
    required this.hoogteMm,
    required this.positie,
    required this.inDeMaat,
    required this.rasterPatroon,
    this.breedteMm,
  });

  /// Null betekent: gebruik de volledige raambreedte.
  ///
  /// Voor een ventilatierooster bovenaan kan dit dus null blijven.
  final int? breedteMm;

  final int hoogteMm;

  final OpmetingRaamExtraTekeningPositie positie;

  /// True:
  /// de tekening bevindt zich binnen de ingegeven raammaat.
  ///
  /// False:
  /// de tekening wordt buiten de raammaat geplaatst.
  final bool inDeMaat;

  final OpmetingRaamRasterPatroon rasterPatroon;

  bool get gebruiktVolledigeRaambreedte {
    return breedteMm == null;
  }

  OpmetingRaamExtraTekeningModel copyWith({
    int? breedteMm,
    bool breedteVolledigeRaambreedte = false,
    int? hoogteMm,
    OpmetingRaamExtraTekeningPositie? positie,
    bool? inDeMaat,
    OpmetingRaamRasterPatroon? rasterPatroon,
  }) {
    return OpmetingRaamExtraTekeningModel(
      breedteMm: breedteVolledigeRaambreedte
          ? null
          : breedteMm ?? this.breedteMm,
      hoogteMm: hoogteMm ?? this.hoogteMm,
      positie: positie ?? this.positie,
      inDeMaat: inDeMaat ?? this.inDeMaat,
      rasterPatroon: rasterPatroon ?? this.rasterPatroon,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'breedteMm': breedteMm,
      'hoogteMm': hoogteMm,
      'positie': positie.name,
      'inDeMaat': inDeMaat,
      'rasterPatroon': rasterPatroon.name,
    };
  }

  factory OpmetingRaamExtraTekeningModel.fromJson(Map<String, dynamic> json) {
    final positieNaam = json['positie']?.toString();

    final positie = OpmetingRaamExtraTekeningPositie.values.firstWhere(
      (waarde) => waarde.name == positieNaam,
      orElse: () => OpmetingRaamExtraTekeningPositie.boven,
    );

    final rasterNaam = json['rasterPatroon']?.toString();

    final rasterPatroon = OpmetingRaamRasterPatroon.values.firstWhere(
      (waarde) => waarde.name == rasterNaam,
      orElse: () => OpmetingRaamRasterPatroon.horizontaleStrepen,
    );

    return OpmetingRaamExtraTekeningModel(
      breedteMm: _leesIntOfNull(json['breedteMm']),
      hoogteMm: _leesInt(json['hoogteMm'], standaardWaarde: 60),
      positie: positie,
      inDeMaat: json['inDeMaat'] is bool ? json['inDeMaat'] as bool : true,
      rasterPatroon: rasterPatroon,
    );
  }

  static int _leesInt(dynamic waarde, {required int standaardWaarde}) {
    if (waarde is int) {
      return waarde;
    }

    if (waarde is num) {
      return waarde.round();
    }

    return int.tryParse(waarde?.toString() ?? '') ?? standaardWaarde;
  }

  static int? _leesIntOfNull(dynamic waarde) {
    if (waarde == null) {
      return null;
    }

    if (waarde is int) {
      return waarde;
    }

    if (waarde is num) {
      return waarde.round();
    }

    return int.tryParse(waarde.toString());
  }
}

class OpmetingRaamTechnischItemModel {
  OpmetingRaamTechnischItemModel({
    required this.id,
    required this.titel,
    required List<String> soorten,
    required this.gekozenSoort,
    this.extraTekening,
    this.isStandaard = false,
  }) : soorten = List<String>.unmodifiable(
         soorten
             .map((soort) => soort.trim())
             .where((soort) => soort.isNotEmpty)
             .toSet(),
       );

  final String id;

  /// De enige benaming van het technische item.
  ///
  /// Er is bewust geen tweede titel of omschrijving.
  final String titel;

  final List<String> soorten;

  final String gekozenSoort;

  final OpmetingRaamExtraTekeningModel? extraTekening;

  final bool isStandaard;

  bool get heeftExtraTekening {
    return extraTekening != null;
  }

  OpmetingRaamTechnischItemModel copyWith({
    String? titel,
    List<String>? soorten,
    String? gekozenSoort,
    OpmetingRaamExtraTekeningModel? extraTekening,
    bool extraTekeningVerwijderen = false,
  }) {
    final nieuweSoorten = soorten ?? this.soorten;

    final nieuweKeuze = gekozenSoort ?? this.gekozenSoort;

    return OpmetingRaamTechnischItemModel(
      id: id,
      titel: titel ?? this.titel,
      soorten: nieuweSoorten,
      gekozenSoort: nieuweSoorten.contains(nieuweKeuze)
          ? nieuweKeuze
          : nieuweSoorten.isEmpty
          ? ''
          : nieuweSoorten.first,
      extraTekening: extraTekeningVerwijderen
          ? null
          : extraTekening ?? this.extraTekening,
      isStandaard: isStandaard,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'titel': titel,
      'soorten': soorten,
      'gekozenSoort': gekozenSoort,
      'extraTekening': extraTekening?.toJson(),
      'isStandaard': isStandaard,
    };
  }

  factory OpmetingRaamTechnischItemModel.fromJson(Map<String, dynamic> json) {
    final ruweSoorten = json['soorten'];

    final soorten = ruweSoorten is List
        ? ruweSoorten
              .map((soort) => soort.toString().trim())
              .where((soort) => soort.isNotEmpty)
              .toList()
        : <String>[];

    final ruweExtraTekening = json['extraTekening'];

    final extraTekening = ruweExtraTekening is Map
        ? OpmetingRaamExtraTekeningModel.fromJson(
            Map<String, dynamic>.from(ruweExtraTekening),
          )
        : null;

    final gekozenSoort = json['gekozenSoort']?.toString() ?? '';

    return OpmetingRaamTechnischItemModel(
      id: json['id']?.toString() ?? '',
      titel: json['titel']?.toString() ?? '',
      soorten: soorten,
      gekozenSoort: soorten.contains(gekozenSoort)
          ? gekozenSoort
          : soorten.isEmpty
          ? ''
          : soorten.first,
      extraTekening: extraTekening,
      isStandaard: json['isStandaard'] is bool
          ? json['isStandaard'] as bool
          : false,
    );
  }
}

class OpmetingRaamTechnischeStandaardItems {
  const OpmetingRaamTechnischeStandaardItems._();

  static List<OpmetingRaamTechnischItemModel> maak() {
    return <OpmetingRaamTechnischItemModel>[
      _item(
        id: 'vleugelprofiel',
        titel: 'Vleugelprofiel',
        gekozenSoort: 'Classic',
        soorten: <String>['Classic', 'Softline', 'Steel look', 'Renovatie'],
      ),
      _item(
        id: 'dorpel',
        titel: 'Dorpel',
        gekozenSoort: 'Standaard',
        soorten: <String>[
          'Geen',
          'Standaard',
          'Blauwe steen',
          'Aluminium dorpel',
        ],
      ),
      _item(
        id: 'binnenkastprofiel',
        titel: 'Binnenkastprofiel',
        gekozenSoort: '4047',
        soorten: <String>['Geen', '4047', '4048', '4050'],
      ),
      _item(
        id: 'rolluik',
        titel: 'Rolluik',
        gekozenSoort: 'Geen',
        soorten: <String>[
          'Geen',
          'Lintbediend',
          'Elektrisch',
          'Elektrisch IO',
          'Solar IO',
        ],
      ),
      _item(
        id: 'vliegenraam',
        titel: 'Vliegenraam',
        gekozenSoort: 'Geen',
        soorten: <String>['Geen', 'Vast', 'Schuif', 'Hordeur', 'Plissé'],
      ),
      _item(
        id: 'verbredingsprofielen',
        titel: 'Verbredingsprofielen',
        gekozenSoort: 'Niet gebruikt',
        soorten: <String>[
          'Niet gebruikt',
          'Links',
          'Rechts',
          'Boven',
          'Onder',
          'Rondom',
        ],
      ),
      _item(
        id: 'koppelprofielen',
        titel: 'Koppelprofielen',
        gekozenSoort: 'Niet gebruikt',
        soorten: <String>['Niet gebruikt', 'Links', 'Rechts', 'Boven', 'Onder'],
      ),
      _item(
        id: 'ventilatierooster',
        titel: 'Ventilatierooster',
        gekozenSoort: 'Geen',
        soorten: <String>['Geen', 'Invisivent', 'Glasrooster', 'Duco'],
      ),
      _item(
        id: 'hoekprofielen',
        titel: 'Hoekprofielen',
        gekozenSoort: 'Geen',
        soorten: <String>['Geen', 'Standaard', 'Breed', 'Speciaal'],
      ),
      _item(
        id: 'binnenafwerking',
        titel: 'Binnenafwerking',
        gekozenSoort: 'Geen',
        soorten: <String>[
          'Geen',
          'Chambrangs',
          'Binnenkast',
          'Chambrangs en binnenkasten',
        ],
      ),
      _item(
        id: 'rolluikkast',
        titel: 'Rolluikkast',
        gekozenSoort: 'Geen',
        soorten: <String>['Geen', 'Kast 155', 'Kast 180', 'Kast 205'],
      ),
      _item(
        id: 'vensterbanken',
        titel: 'Vensterbanken',
        gekozenSoort: 'Geen',
        soorten: <String>[
          'Geen',
          'Binnen PVC',
          'Binnen aluminium',
          'Buiten aluminium',
        ],
      ),
      _item(
        id: 'afwerkingslatten',
        titel: 'Afwerkingslatten buitenzijde',
        gekozenSoort: 'Geen',
        soorten: <String>[
          'Geen',
          'Links',
          'Rechts',
          'Boven',
          'Onder',
          'Rondom',
        ],
      ),
    ];
  }

  static OpmetingRaamTechnischItemModel _item({
    required String id,
    required String titel,
    required String gekozenSoort,
    required List<String> soorten,
  }) {
    return OpmetingRaamTechnischItemModel(
      id: id,
      titel: titel,
      soorten: soorten,
      gekozenSoort: gekozenSoort,
      isStandaard: true,
    );
  }
}
