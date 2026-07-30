// THIMACO-CONTROLE: VELUX-FASE-1-2-CATALOGUS-EN-FICHEPRIJZEN-20260729-2030

class OpmetingVeluxDakraamCatalogusPrijs {
  const OpmetingVeluxDakraamCatalogusPrijs({
    required this.productCode,
    required this.maatCode,
    required this.breedteCm,
    required this.hoogteCm,
    required this.prijsExclBtw,
  });

  final String productCode;
  final String maatCode;
  final int breedteCm;
  final int hoogteCm;
  final double prijsExclBtw;

  String get id => '${productCode.trim()}|${maatCode.trim()}';

  String get afmetingLabel {
    if (breedteCm <= 0 || hoogteCm <= 0) return '';
    return '$breedteCm × $hoogteCm';
  }

  OpmetingVeluxDakraamCatalogusPrijs copyWith({
    String? productCode,
    String? maatCode,
    int? breedteCm,
    int? hoogteCm,
    double? prijsExclBtw,
  }) {
    return OpmetingVeluxDakraamCatalogusPrijs(
      productCode: productCode ?? this.productCode,
      maatCode: maatCode ?? this.maatCode,
      breedteCm: breedteCm ?? this.breedteCm,
      hoogteCm: hoogteCm ?? this.hoogteCm,
      prijsExclBtw: prijsExclBtw ?? this.prijsExclBtw,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'productCode': productCode,
    'maatCode': maatCode,
    'breedteCm': breedteCm,
    'hoogteCm': hoogteCm,
    'prijsExclBtw': prijsExclBtw,
  };

  factory OpmetingVeluxDakraamCatalogusPrijs.fromJson(
    Map<String, dynamic> json,
  ) {
    return OpmetingVeluxDakraamCatalogusPrijs(
      productCode: json['productCode']?.toString().trim() ?? '',
      maatCode: json['maatCode']?.toString().trim() ?? '',
      breedteCm: _naarInt(json['breedteCm']),
      hoogteCm: _naarInt(json['hoogteCm']),
      prijsExclBtw: _naarDouble(json['prijsExclBtw']),
    );
  }

  static int _naarInt(dynamic waarde) {
    if (waarde is int) return waarde;
    if (waarde is num) return waarde.toInt();
    return int.tryParse(waarde?.toString() ?? '') ?? 0;
  }

  static double _naarDouble(dynamic waarde) {
    if (waarde is num) return waarde.toDouble();
    return double.tryParse((waarde?.toString() ?? '').replaceAll(',', '.')) ??
        0;
  }
}

class OpmetingVeluxMuggengaasCatalogusPrijs {
  const OpmetingVeluxMuggengaasCatalogusPrijs({
    required this.productCode,
    required this.breedteMinMm,
    required this.breedteMaxMm,
    required this.hoogteMinMm,
    required this.hoogteMaxMm,
    required this.prijsExclBtw,
  });

  final String productCode;
  final int breedteMinMm;
  final int breedteMaxMm;
  final int hoogteMinMm;
  final int hoogteMaxMm;
  final double prijsExclBtw;

  String get id =>
      '${productCode.trim()}|$breedteMinMm-$breedteMaxMm|$hoogteMinMm-$hoogteMaxMm';

  String get breedteBereikLabel => '$breedteMinMm–$breedteMaxMm mm';
  String get hoogteBereikLabel => '$hoogteMinMm–$hoogteMaxMm mm';

  OpmetingVeluxMuggengaasCatalogusPrijs copyWith({
    String? productCode,
    int? breedteMinMm,
    int? breedteMaxMm,
    int? hoogteMinMm,
    int? hoogteMaxMm,
    double? prijsExclBtw,
  }) {
    return OpmetingVeluxMuggengaasCatalogusPrijs(
      productCode: productCode ?? this.productCode,
      breedteMinMm: breedteMinMm ?? this.breedteMinMm,
      breedteMaxMm: breedteMaxMm ?? this.breedteMaxMm,
      hoogteMinMm: hoogteMinMm ?? this.hoogteMinMm,
      hoogteMaxMm: hoogteMaxMm ?? this.hoogteMaxMm,
      prijsExclBtw: prijsExclBtw ?? this.prijsExclBtw,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'productCode': productCode,
    'breedteMinMm': breedteMinMm,
    'breedteMaxMm': breedteMaxMm,
    'hoogteMinMm': hoogteMinMm,
    'hoogteMaxMm': hoogteMaxMm,
    'prijsExclBtw': prijsExclBtw,
  };

  factory OpmetingVeluxMuggengaasCatalogusPrijs.fromJson(
    Map<String, dynamic> json,
  ) {
    return OpmetingVeluxMuggengaasCatalogusPrijs(
      productCode: json['productCode']?.toString().trim() ?? '',
      breedteMinMm: _naarInt(json['breedteMinMm']),
      breedteMaxMm: _naarInt(json['breedteMaxMm']),
      hoogteMinMm: _naarInt(json['hoogteMinMm']),
      hoogteMaxMm: _naarInt(json['hoogteMaxMm']),
      prijsExclBtw: _naarDouble(json['prijsExclBtw']),
    );
  }

  static int _naarInt(dynamic waarde) {
    if (waarde is int) return waarde;
    if (waarde is num) return waarde.toInt();
    return int.tryParse(waarde?.toString() ?? '') ?? 0;
  }

  static double _naarDouble(dynamic waarde) {
    if (waarde is num) return waarde.toDouble();
    return double.tryParse((waarde?.toString() ?? '').replaceAll(',', '.')) ??
        0;
  }
}

class OpmetingVeluxDakraamInstellingen {
  const OpmetingVeluxDakraamInstellingen({
    required this.catalogusJaar,
    required this.geldigVanaf,
    required this.prijzen,
    this.muggengaasPrijzen = const <OpmetingVeluxMuggengaasCatalogusPrijs>[],
    this.kux110PrijsExclBtw = 159,
    this.afwerkingMdfPrijsExclBtw = 0,
    this.afwerkingKunststofWitPrijsExclBtw = 0,
    this.gewijzigdOp = '',
  });

  static const String ggu0070ProductCode = 'GGU 0070';
  static const String verduisteringsGordijnProductCode = 'DKL';

  static const List<String> gootstukProductVolgorde = <String>[
    'EDW 2000',
    'EDT 2000',
    'EDP 2000',
    'EDB 2000',
  ];

  static const List<String> rolluikProductVolgorde = <String>['SSL', 'SML'];
  static const List<String> buitenschermProductVolgorde = <String>[
    'MSL',
    'MML',
  ];

  static const List<String> maatVolgorde = <String>[
    'CK02',
    'CK04',
    'MK04',
    'MK06',
    'MK08',
    'PK10',
    'SK06',
    'SK08',
    'UK04',
    'UK08',
  ];

  static const List<String> accessoireMaatVolgorde = <String>[
    'CK02',
    'CK04',
    'FK06',
    'FK08',
    'MK04',
    'MK06',
    'MK08',
    'PK06',
    'PK08',
    'PK10',
    'SK06',
    'SK08',
    'UK04',
    'UK08',
  ];

  static const List<String> manueelBuitenschermMaatVolgorde = <String>[
    'CK00',
    'FK00',
    'MK00',
    'PK00',
    'SK00',
    'UK00',
  ];

  final int catalogusJaar;
  final String geldigVanaf;
  final List<OpmetingVeluxDakraamCatalogusPrijs> prijzen;
  final List<OpmetingVeluxMuggengaasCatalogusPrijs> muggengaasPrijzen;
  final double kux110PrijsExclBtw;
  final double afwerkingMdfPrijsExclBtw;
  final double afwerkingKunststofWitPrijsExclBtw;
  final String gewijzigdOp;

  factory OpmetingVeluxDakraamInstellingen.standaard2026() {
    return OpmetingVeluxDakraamInstellingen(
      catalogusJaar: 2026,
      geldigVanaf: '',
      prijzen: const <OpmetingVeluxDakraamCatalogusPrijs>[
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'GGU 0070',
          maatCode: 'CK02',
          breedteCm: 55,
          hoogteCm: 78,
          prijsExclBtw: 505,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'GGU 0070',
          maatCode: 'CK04',
          breedteCm: 55,
          hoogteCm: 98,
          prijsExclBtw: 538,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'GGU 0070',
          maatCode: 'MK04',
          breedteCm: 78,
          hoogteCm: 98,
          prijsExclBtw: 611,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'GGU 0070',
          maatCode: 'MK06',
          breedteCm: 78,
          hoogteCm: 118,
          prijsExclBtw: 664,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'GGU 0070',
          maatCode: 'MK08',
          breedteCm: 78,
          hoogteCm: 140,
          prijsExclBtw: 711,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'GGU 0070',
          maatCode: 'PK10',
          breedteCm: 94,
          hoogteCm: 160,
          prijsExclBtw: 897,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'GGU 0070',
          maatCode: 'SK06',
          breedteCm: 114,
          hoogteCm: 118,
          prijsExclBtw: 817,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'GGU 0070',
          maatCode: 'SK08',
          breedteCm: 114,
          hoogteCm: 140,
          prijsExclBtw: 910,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'GGU 0070',
          maatCode: 'UK04',
          breedteCm: 134,
          hoogteCm: 98,
          prijsExclBtw: 837,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'GGU 0070',
          maatCode: 'UK08',
          breedteCm: 134,
          hoogteCm: 140,
          prijsExclBtw: 1016,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDW 2000',
          maatCode: 'CK02',
          breedteCm: 55,
          hoogteCm: 78,
          prijsExclBtw: 122,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDW 2000',
          maatCode: 'CK04',
          breedteCm: 55,
          hoogteCm: 98,
          prijsExclBtw: 125,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDW 2000',
          maatCode: 'MK04',
          breedteCm: 78,
          hoogteCm: 98,
          prijsExclBtw: 140,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDW 2000',
          maatCode: 'MK06',
          breedteCm: 78,
          hoogteCm: 118,
          prijsExclBtw: 147,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDW 2000',
          maatCode: 'MK08',
          breedteCm: 78,
          hoogteCm: 140,
          prijsExclBtw: 156,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDW 2000',
          maatCode: 'PK10',
          breedteCm: 94,
          hoogteCm: 160,
          prijsExclBtw: 181,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDW 2000',
          maatCode: 'SK06',
          breedteCm: 114,
          hoogteCm: 118,
          prijsExclBtw: 173,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDW 2000',
          maatCode: 'SK08',
          breedteCm: 114,
          hoogteCm: 140,
          prijsExclBtw: 184,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDW 2000',
          maatCode: 'UK04',
          breedteCm: 134,
          hoogteCm: 98,
          prijsExclBtw: 179,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDW 2000',
          maatCode: 'UK08',
          breedteCm: 134,
          hoogteCm: 140,
          prijsExclBtw: 198,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDT 2000',
          maatCode: 'CK02',
          breedteCm: 55,
          hoogteCm: 78,
          prijsExclBtw: 122,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDT 2000',
          maatCode: 'CK04',
          breedteCm: 55,
          hoogteCm: 98,
          prijsExclBtw: 125,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDT 2000',
          maatCode: 'MK04',
          breedteCm: 78,
          hoogteCm: 98,
          prijsExclBtw: 140,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDT 2000',
          maatCode: 'MK06',
          breedteCm: 78,
          hoogteCm: 118,
          prijsExclBtw: 147,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDT 2000',
          maatCode: 'MK08',
          breedteCm: 78,
          hoogteCm: 140,
          prijsExclBtw: 156,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDT 2000',
          maatCode: 'PK10',
          breedteCm: 94,
          hoogteCm: 160,
          prijsExclBtw: 181,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDT 2000',
          maatCode: 'SK06',
          breedteCm: 114,
          hoogteCm: 118,
          prijsExclBtw: 173,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDT 2000',
          maatCode: 'SK08',
          breedteCm: 114,
          hoogteCm: 140,
          prijsExclBtw: 184,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDT 2000',
          maatCode: 'UK04',
          breedteCm: 134,
          hoogteCm: 98,
          prijsExclBtw: 179,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDT 2000',
          maatCode: 'UK08',
          breedteCm: 134,
          hoogteCm: 140,
          prijsExclBtw: 198,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDP 2000',
          maatCode: 'CK02',
          breedteCm: 55,
          hoogteCm: 78,
          prijsExclBtw: 122,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDP 2000',
          maatCode: 'CK04',
          breedteCm: 55,
          hoogteCm: 98,
          prijsExclBtw: 125,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDP 2000',
          maatCode: 'MK04',
          breedteCm: 78,
          hoogteCm: 98,
          prijsExclBtw: 140,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDP 2000',
          maatCode: 'MK06',
          breedteCm: 78,
          hoogteCm: 118,
          prijsExclBtw: 147,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDP 2000',
          maatCode: 'MK08',
          breedteCm: 78,
          hoogteCm: 140,
          prijsExclBtw: 156,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDP 2000',
          maatCode: 'PK10',
          breedteCm: 94,
          hoogteCm: 160,
          prijsExclBtw: 181,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDP 2000',
          maatCode: 'SK06',
          breedteCm: 114,
          hoogteCm: 118,
          prijsExclBtw: 173,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDP 2000',
          maatCode: 'SK08',
          breedteCm: 114,
          hoogteCm: 140,
          prijsExclBtw: 184,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDP 2000',
          maatCode: 'UK04',
          breedteCm: 134,
          hoogteCm: 98,
          prijsExclBtw: 179,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDP 2000',
          maatCode: 'UK08',
          breedteCm: 134,
          hoogteCm: 140,
          prijsExclBtw: 198,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDB 2000',
          maatCode: 'CK02',
          breedteCm: 55,
          hoogteCm: 78,
          prijsExclBtw: 122,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDB 2000',
          maatCode: 'CK04',
          breedteCm: 55,
          hoogteCm: 98,
          prijsExclBtw: 125,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDB 2000',
          maatCode: 'MK04',
          breedteCm: 78,
          hoogteCm: 98,
          prijsExclBtw: 140,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDB 2000',
          maatCode: 'MK06',
          breedteCm: 78,
          hoogteCm: 118,
          prijsExclBtw: 147,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDB 2000',
          maatCode: 'MK08',
          breedteCm: 78,
          hoogteCm: 140,
          prijsExclBtw: 156,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDB 2000',
          maatCode: 'PK10',
          breedteCm: 94,
          hoogteCm: 160,
          prijsExclBtw: 181,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDB 2000',
          maatCode: 'SK06',
          breedteCm: 114,
          hoogteCm: 118,
          prijsExclBtw: 173,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDB 2000',
          maatCode: 'SK08',
          breedteCm: 114,
          hoogteCm: 140,
          prijsExclBtw: 184,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDB 2000',
          maatCode: 'UK04',
          breedteCm: 134,
          hoogteCm: 98,
          prijsExclBtw: 179,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDB 2000',
          maatCode: 'UK08',
          breedteCm: 134,
          hoogteCm: 140,
          prijsExclBtw: 198,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDL 2000',
          maatCode: 'CK02',
          breedteCm: 55,
          hoogteCm: 78,
          prijsExclBtw: 116,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDL 2000',
          maatCode: 'CK04',
          breedteCm: 55,
          hoogteCm: 98,
          prijsExclBtw: 119,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDL 2000',
          maatCode: 'MK04',
          breedteCm: 78,
          hoogteCm: 98,
          prijsExclBtw: 133,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDL 2000',
          maatCode: 'MK06',
          breedteCm: 78,
          hoogteCm: 118,
          prijsExclBtw: 140,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDL 2000',
          maatCode: 'MK08',
          breedteCm: 78,
          hoogteCm: 140,
          prijsExclBtw: 148,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDL 2000',
          maatCode: 'PK10',
          breedteCm: 94,
          hoogteCm: 160,
          prijsExclBtw: 172,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDL 2000',
          maatCode: 'SK06',
          breedteCm: 114,
          hoogteCm: 118,
          prijsExclBtw: 164,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDL 2000',
          maatCode: 'SK08',
          breedteCm: 114,
          hoogteCm: 140,
          prijsExclBtw: 175,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDL 2000',
          maatCode: 'UK04',
          breedteCm: 134,
          hoogteCm: 98,
          prijsExclBtw: 170,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'EDL 2000',
          maatCode: 'UK08',
          breedteCm: 134,
          hoogteCm: 140,
          prijsExclBtw: 189,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'SSL',
          maatCode: 'CK02',
          breedteCm: 55,
          hoogteCm: 78,
          prijsExclBtw: 646,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'SSL',
          maatCode: 'CK04',
          breedteCm: 55,
          hoogteCm: 98,
          prijsExclBtw: 684,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'SSL',
          maatCode: 'FK06',
          breedteCm: 66,
          hoogteCm: 118,
          prijsExclBtw: 738,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'SSL',
          maatCode: 'FK08',
          breedteCm: 66,
          hoogteCm: 140,
          prijsExclBtw: 769,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'SSL',
          maatCode: 'MK04',
          breedteCm: 78,
          hoogteCm: 98,
          prijsExclBtw: 730,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'SSL',
          maatCode: 'MK06',
          breedteCm: 78,
          hoogteCm: 118,
          prijsExclBtw: 769,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'SSL',
          maatCode: 'MK08',
          breedteCm: 78,
          hoogteCm: 140,
          prijsExclBtw: 807,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'SSL',
          maatCode: 'PK06',
          breedteCm: 94,
          hoogteCm: 118,
          prijsExclBtw: 830,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'SSL',
          maatCode: 'PK08',
          breedteCm: 94,
          hoogteCm: 140,
          prijsExclBtw: 876,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'SSL',
          maatCode: 'PK10',
          breedteCm: 94,
          hoogteCm: 160,
          prijsExclBtw: 922,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'SSL',
          maatCode: 'SK06',
          breedteCm: 114,
          hoogteCm: 118,
          prijsExclBtw: 892,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'SSL',
          maatCode: 'SK08',
          breedteCm: 114,
          hoogteCm: 140,
          prijsExclBtw: 953,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'SSL',
          maatCode: 'UK04',
          breedteCm: 134,
          hoogteCm: 98,
          prijsExclBtw: 884,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'SSL',
          maatCode: 'UK08',
          breedteCm: 134,
          hoogteCm: 140,
          prijsExclBtw: 1030,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'SML',
          maatCode: 'CK02',
          breedteCm: 55,
          hoogteCm: 78,
          prijsExclBtw: 461,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'SML',
          maatCode: 'CK04',
          breedteCm: 55,
          hoogteCm: 98,
          prijsExclBtw: 489,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'SML',
          maatCode: 'FK06',
          breedteCm: 66,
          hoogteCm: 118,
          prijsExclBtw: 527,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'SML',
          maatCode: 'FK08',
          breedteCm: 66,
          hoogteCm: 140,
          prijsExclBtw: 549,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'SML',
          maatCode: 'MK04',
          breedteCm: 78,
          hoogteCm: 98,
          prijsExclBtw: 522,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'SML',
          maatCode: 'MK06',
          breedteCm: 78,
          hoogteCm: 118,
          prijsExclBtw: 549,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'SML',
          maatCode: 'MK08',
          breedteCm: 78,
          hoogteCm: 140,
          prijsExclBtw: 576,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'SML',
          maatCode: 'PK06',
          breedteCm: 94,
          hoogteCm: 118,
          prijsExclBtw: 593,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'SML',
          maatCode: 'PK08',
          breedteCm: 94,
          hoogteCm: 140,
          prijsExclBtw: 626,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'SML',
          maatCode: 'PK10',
          breedteCm: 94,
          hoogteCm: 160,
          prijsExclBtw: 659,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'SML',
          maatCode: 'SK06',
          breedteCm: 114,
          hoogteCm: 118,
          prijsExclBtw: 637,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'SML',
          maatCode: 'SK08',
          breedteCm: 114,
          hoogteCm: 140,
          prijsExclBtw: 681,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'SML',
          maatCode: 'UK04',
          breedteCm: 134,
          hoogteCm: 98,
          prijsExclBtw: 631,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'SML',
          maatCode: 'UK08',
          breedteCm: 134,
          hoogteCm: 140,
          prijsExclBtw: 736,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MSL',
          maatCode: 'CK02',
          breedteCm: 55,
          hoogteCm: 78,
          prijsExclBtw: 300,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MSL',
          maatCode: 'CK04',
          breedteCm: 55,
          hoogteCm: 98,
          prijsExclBtw: 318,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MSL',
          maatCode: 'FK06',
          breedteCm: 66,
          hoogteCm: 118,
          prijsExclBtw: 343,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MSL',
          maatCode: 'FK08',
          breedteCm: 66,
          hoogteCm: 140,
          prijsExclBtw: 357,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MSL',
          maatCode: 'MK04',
          breedteCm: 78,
          hoogteCm: 98,
          prijsExclBtw: 339,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MSL',
          maatCode: 'MK06',
          breedteCm: 78,
          hoogteCm: 118,
          prijsExclBtw: 357,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MSL',
          maatCode: 'MK08',
          breedteCm: 78,
          hoogteCm: 140,
          prijsExclBtw: 375,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MSL',
          maatCode: 'PK06',
          breedteCm: 94,
          hoogteCm: 118,
          prijsExclBtw: 385,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MSL',
          maatCode: 'PK08',
          breedteCm: 94,
          hoogteCm: 140,
          prijsExclBtw: 407,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MSL',
          maatCode: 'PK10',
          breedteCm: 94,
          hoogteCm: 160,
          prijsExclBtw: 428,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MSL',
          maatCode: 'SK06',
          breedteCm: 114,
          hoogteCm: 118,
          prijsExclBtw: 414,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MSL',
          maatCode: 'SK08',
          breedteCm: 114,
          hoogteCm: 140,
          prijsExclBtw: 442,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MSL',
          maatCode: 'UK04',
          breedteCm: 134,
          hoogteCm: 98,
          prijsExclBtw: 410,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MSL',
          maatCode: 'UK08',
          breedteCm: 134,
          hoogteCm: 140,
          prijsExclBtw: 478,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MML',
          maatCode: 'CK02',
          breedteCm: 55,
          hoogteCm: 78,
          prijsExclBtw: 300,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MML',
          maatCode: 'CK04',
          breedteCm: 55,
          hoogteCm: 98,
          prijsExclBtw: 318,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MML',
          maatCode: 'FK06',
          breedteCm: 66,
          hoogteCm: 118,
          prijsExclBtw: 343,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MML',
          maatCode: 'FK08',
          breedteCm: 66,
          hoogteCm: 140,
          prijsExclBtw: 357,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MML',
          maatCode: 'MK04',
          breedteCm: 78,
          hoogteCm: 98,
          prijsExclBtw: 339,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MML',
          maatCode: 'MK06',
          breedteCm: 78,
          hoogteCm: 118,
          prijsExclBtw: 357,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MML',
          maatCode: 'MK08',
          breedteCm: 78,
          hoogteCm: 140,
          prijsExclBtw: 375,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MML',
          maatCode: 'PK06',
          breedteCm: 94,
          hoogteCm: 118,
          prijsExclBtw: 385,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MML',
          maatCode: 'PK08',
          breedteCm: 94,
          hoogteCm: 140,
          prijsExclBtw: 407,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MML',
          maatCode: 'PK10',
          breedteCm: 94,
          hoogteCm: 160,
          prijsExclBtw: 428,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MML',
          maatCode: 'SK06',
          breedteCm: 114,
          hoogteCm: 118,
          prijsExclBtw: 414,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MML',
          maatCode: 'SK08',
          breedteCm: 114,
          hoogteCm: 140,
          prijsExclBtw: 442,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MML',
          maatCode: 'UK04',
          breedteCm: 134,
          hoogteCm: 98,
          prijsExclBtw: 410,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MML',
          maatCode: 'UK08',
          breedteCm: 134,
          hoogteCm: 140,
          prijsExclBtw: 478,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'DKL',
          maatCode: 'CK02',
          breedteCm: 55,
          hoogteCm: 78,
          prijsExclBtw: 84,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'DKL',
          maatCode: 'CK04',
          breedteCm: 55,
          hoogteCm: 98,
          prijsExclBtw: 91,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'DKL',
          maatCode: 'FK06',
          breedteCm: 66,
          hoogteCm: 118,
          prijsExclBtw: 107,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'DKL',
          maatCode: 'FK08',
          breedteCm: 66,
          hoogteCm: 140,
          prijsExclBtw: 111,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'DKL',
          maatCode: 'MK04',
          breedteCm: 78,
          hoogteCm: 98,
          prijsExclBtw: 103,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'DKL',
          maatCode: 'MK06',
          breedteCm: 78,
          hoogteCm: 118,
          prijsExclBtw: 111,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'DKL',
          maatCode: 'MK08',
          breedteCm: 78,
          hoogteCm: 140,
          prijsExclBtw: 119,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'DKL',
          maatCode: 'PK06',
          breedteCm: 94,
          hoogteCm: 118,
          prijsExclBtw: 122,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'DKL',
          maatCode: 'PK08',
          breedteCm: 94,
          hoogteCm: 140,
          prijsExclBtw: 133,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'DKL',
          maatCode: 'PK10',
          breedteCm: 94,
          hoogteCm: 160,
          prijsExclBtw: 141,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'DKL',
          maatCode: 'SK06',
          breedteCm: 114,
          hoogteCm: 118,
          prijsExclBtw: 139,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'DKL',
          maatCode: 'SK08',
          breedteCm: 114,
          hoogteCm: 140,
          prijsExclBtw: 144,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'DKL',
          maatCode: 'UK04',
          breedteCm: 134,
          hoogteCm: 98,
          prijsExclBtw: 142,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'DKL',
          maatCode: 'UK08',
          breedteCm: 134,
          hoogteCm: 140,
          prijsExclBtw: 163,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MHL',
          maatCode: 'CK00',
          breedteCm: 0,
          hoogteCm: 0,
          prijsExclBtw: 88,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MHL',
          maatCode: 'FK00',
          breedteCm: 0,
          hoogteCm: 0,
          prijsExclBtw: 102,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MHL',
          maatCode: 'MK00',
          breedteCm: 0,
          hoogteCm: 0,
          prijsExclBtw: 110,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MHL',
          maatCode: 'PK00',
          breedteCm: 0,
          hoogteCm: 0,
          prijsExclBtw: 127,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MHL',
          maatCode: 'SK00',
          breedteCm: 0,
          hoogteCm: 0,
          prijsExclBtw: 142,
        ),
        OpmetingVeluxDakraamCatalogusPrijs(
          productCode: 'MHL',
          maatCode: 'UK00',
          breedteCm: 0,
          hoogteCm: 0,
          prijsExclBtw: 154,
        ),
      ],
      muggengaasPrijzen: const <OpmetingVeluxMuggengaasCatalogusPrijs>[
        OpmetingVeluxMuggengaasCatalogusPrijs(
          productCode: 'ZIL CK02',
          breedteMinMm: 439,
          breedteMaxMm: 530,
          hoogteMinMm: 0,
          hoogteMaxMm: 1600,
          prijsExclBtw: 118,
        ),
        OpmetingVeluxMuggengaasCatalogusPrijs(
          productCode: 'ZIL FK08',
          breedteMinMm: 531,
          breedteMaxMm: 640,
          hoogteMinMm: 0,
          hoogteMaxMm: 1600,
          prijsExclBtw: 155,
        ),
        OpmetingVeluxMuggengaasCatalogusPrijs(
          productCode: 'ZIL MK06',
          breedteMinMm: 641,
          breedteMaxMm: 760,
          hoogteMinMm: 0,
          hoogteMaxMm: 1600,
          prijsExclBtw: 155,
        ),
        OpmetingVeluxMuggengaasCatalogusPrijs(
          productCode: 'ZIL PK25',
          breedteMinMm: 761,
          breedteMaxMm: 922,
          hoogteMinMm: 0,
          hoogteMaxMm: 1600,
          prijsExclBtw: 160,
        ),
        OpmetingVeluxMuggengaasCatalogusPrijs(
          productCode: 'ZIL SK06',
          breedteMinMm: 923,
          breedteMaxMm: 1120,
          hoogteMinMm: 0,
          hoogteMaxMm: 1600,
          prijsExclBtw: 194,
        ),
        OpmetingVeluxMuggengaasCatalogusPrijs(
          productCode: 'ZIL UK04',
          breedteMinMm: 1121,
          breedteMaxMm: 1320,
          hoogteMinMm: 0,
          hoogteMaxMm: 1600,
          prijsExclBtw: 199,
        ),
        OpmetingVeluxMuggengaasCatalogusPrijs(
          productCode: 'ZIL CK06',
          breedteMinMm: 439,
          breedteMaxMm: 530,
          hoogteMinMm: 1601,
          hoogteMaxMm: 2000,
          prijsExclBtw: 140,
        ),
        OpmetingVeluxMuggengaasCatalogusPrijs(
          productCode: 'ZIL FK08',
          breedteMinMm: 531,
          breedteMaxMm: 640,
          hoogteMinMm: 1601,
          hoogteMaxMm: 2000,
          prijsExclBtw: 155,
        ),
        OpmetingVeluxMuggengaasCatalogusPrijs(
          productCode: 'ZIL MK06',
          breedteMinMm: 641,
          breedteMaxMm: 760,
          hoogteMinMm: 1601,
          hoogteMaxMm: 2000,
          prijsExclBtw: 155,
        ),
        OpmetingVeluxMuggengaasCatalogusPrijs(
          productCode: 'ZIL PK06',
          breedteMinMm: 761,
          breedteMaxMm: 922,
          hoogteMinMm: 1601,
          hoogteMaxMm: 2000,
          prijsExclBtw: 171,
        ),
        OpmetingVeluxMuggengaasCatalogusPrijs(
          productCode: 'ZIL SK06',
          breedteMinMm: 923,
          breedteMaxMm: 1120,
          hoogteMinMm: 1601,
          hoogteMaxMm: 2000,
          prijsExclBtw: 194,
        ),
        OpmetingVeluxMuggengaasCatalogusPrijs(
          productCode: 'ZIL UK10',
          breedteMinMm: 1121,
          breedteMaxMm: 1320,
          hoogteMinMm: 1601,
          hoogteMaxMm: 2000,
          prijsExclBtw: 239,
        ),
        OpmetingVeluxMuggengaasCatalogusPrijs(
          productCode: 'ZIL FK08',
          breedteMinMm: 531,
          breedteMaxMm: 640,
          hoogteMinMm: 2001,
          hoogteMaxMm: 2400,
          prijsExclBtw: 155,
        ),
        OpmetingVeluxMuggengaasCatalogusPrijs(
          productCode: 'ZIL MK10',
          breedteMinMm: 641,
          breedteMaxMm: 760,
          hoogteMinMm: 2001,
          hoogteMaxMm: 2400,
          prijsExclBtw: 186,
        ),
        OpmetingVeluxMuggengaasCatalogusPrijs(
          productCode: 'ZIL PK10',
          breedteMinMm: 761,
          breedteMaxMm: 922,
          hoogteMinMm: 2001,
          hoogteMaxMm: 2400,
          prijsExclBtw: 197,
        ),
        OpmetingVeluxMuggengaasCatalogusPrijs(
          productCode: 'ZIL SK10',
          breedteMinMm: 923,
          breedteMaxMm: 1120,
          hoogteMinMm: 2001,
          hoogteMaxMm: 2400,
          prijsExclBtw: 225,
        ),
        OpmetingVeluxMuggengaasCatalogusPrijs(
          productCode: 'ZIL UK10',
          breedteMinMm: 1121,
          breedteMaxMm: 1320,
          hoogteMinMm: 2001,
          hoogteMaxMm: 2400,
          prijsExclBtw: 239,
        ),
      ],
    );
  }

  OpmetingVeluxDakraamCatalogusPrijs? prijsVoorProductEnMaat({
    required String productCode,
    required String maatCode,
  }) {
    final productSleutel = productCode.trim().toLowerCase();
    final maatSleutel = maatCode.trim().toLowerCase();

    for (final prijs in prijzen) {
      if (prijs.productCode.trim().toLowerCase() == productSleutel &&
          prijs.maatCode.trim().toLowerCase() == maatSleutel) {
        return prijs;
      }
    }
    return null;
  }

  List<OpmetingVeluxDakraamCatalogusPrijs> prijzenVoorProduct(
    String productCode,
  ) {
    final genormaliseerdeCode = productCode.trim().toLowerCase();
    final resultaat = prijzen
        .where(
          (prijs) =>
              prijs.productCode.trim().toLowerCase() == genormaliseerdeCode,
        )
        .toList(growable: false);

    final gesorteerd = resultaat.toList()
      ..sort((eerste, tweede) {
        final eersteIndex = _maatIndex(eerste.maatCode);
        final tweedeIndex = _maatIndex(tweede.maatCode);
        return eersteIndex.compareTo(tweedeIndex);
      });

    return List<OpmetingVeluxDakraamCatalogusPrijs>.unmodifiable(gesorteerd);
  }

  static int _maatIndex(String maatCode) {
    final accessoireIndex = accessoireMaatVolgorde.indexOf(maatCode);
    if (accessoireIndex >= 0) return accessoireIndex;

    final manueelIndex = manueelBuitenschermMaatVolgorde.indexOf(maatCode);
    if (manueelIndex >= 0) {
      return accessoireMaatVolgorde.length + manueelIndex;
    }

    return 999;
  }

  OpmetingVeluxMuggengaasCatalogusPrijs? muggengaasPrijsVoorAfmetingen({
    required int breedteMm,
    required int hoogteMm,
  }) {
    for (final prijs in muggengaasPrijzen) {
      final breedtePast =
          breedteMm >= prijs.breedteMinMm && breedteMm <= prijs.breedteMaxMm;
      final hoogtePast =
          hoogteMm >= prijs.hoogteMinMm && hoogteMm <= prijs.hoogteMaxMm;
      if (breedtePast && hoogtePast) return prijs;
    }
    return null;
  }

  OpmetingVeluxDakraamInstellingen copyWith({
    int? catalogusJaar,
    String? geldigVanaf,
    List<OpmetingVeluxDakraamCatalogusPrijs>? prijzen,
    List<OpmetingVeluxMuggengaasCatalogusPrijs>? muggengaasPrijzen,
    double? kux110PrijsExclBtw,
    double? afwerkingMdfPrijsExclBtw,
    double? afwerkingKunststofWitPrijsExclBtw,
    String? gewijzigdOp,
  }) {
    return OpmetingVeluxDakraamInstellingen(
      catalogusJaar: catalogusJaar ?? this.catalogusJaar,
      geldigVanaf: geldigVanaf ?? this.geldigVanaf,
      prijzen: List<OpmetingVeluxDakraamCatalogusPrijs>.unmodifiable(
        prijzen ?? this.prijzen,
      ),
      muggengaasPrijzen:
          List<OpmetingVeluxMuggengaasCatalogusPrijs>.unmodifiable(
            muggengaasPrijzen ?? this.muggengaasPrijzen,
          ),
      kux110PrijsExclBtw: kux110PrijsExclBtw ?? this.kux110PrijsExclBtw,
      afwerkingMdfPrijsExclBtw:
          afwerkingMdfPrijsExclBtw ?? this.afwerkingMdfPrijsExclBtw,
      afwerkingKunststofWitPrijsExclBtw:
          afwerkingKunststofWitPrijsExclBtw ??
          this.afwerkingKunststofWitPrijsExclBtw,
      gewijzigdOp: gewijzigdOp ?? this.gewijzigdOp,
    );
  }

  OpmetingVeluxDakraamInstellingen metWijzigingsDatum() {
    return copyWith(gewijzigdOp: DateTime.now().toUtc().toIso8601String());
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'catalogusJaar': catalogusJaar,
    'geldigVanaf': geldigVanaf,
    'prijzen': prijzen.map((prijs) => prijs.toJson()).toList(growable: false),
    'muggengaasPrijzen': muggengaasPrijzen
        .map((prijs) => prijs.toJson())
        .toList(growable: false),
    'kux110PrijsExclBtw': kux110PrijsExclBtw,
    'afwerkingMdfPrijsExclBtw': afwerkingMdfPrijsExclBtw,
    'afwerkingKunststofWitPrijsExclBtw': afwerkingKunststofWitPrijsExclBtw,
    'gewijzigdOp': gewijzigdOp,
  };

  factory OpmetingVeluxDakraamInstellingen.fromJson(Map<String, dynamic> json) {
    final standaard = OpmetingVeluxDakraamInstellingen.standaard2026();
    final opgeslagenPrijzen = _leesPrijzen(json['prijzen']);
    final opgeslagenMuggengaasPrijzen = _leesMuggengaasPrijzen(
      json['muggengaasPrijzen'],
    );

    final opgeslagenPerId = <String, OpmetingVeluxDakraamCatalogusPrijs>{
      for (final prijs in opgeslagenPrijzen) prijs.id: prijs,
    };
    final opgeslagenMuggengaasPerId =
        <String, OpmetingVeluxMuggengaasCatalogusPrijs>{
          for (final prijs in opgeslagenMuggengaasPrijzen) prijs.id: prijs,
        };

    final samengevoegdePrijzen = <OpmetingVeluxDakraamCatalogusPrijs>[
      for (final standaardPrijs in standaard.prijzen)
        opgeslagenPerId.remove(standaardPrijs.id) ?? standaardPrijs,
      ...opgeslagenPerId.values,
    ];
    final samengevoegdeMuggengaasPrijzen =
        <OpmetingVeluxMuggengaasCatalogusPrijs>[
          for (final standaardPrijs in standaard.muggengaasPrijzen)
            opgeslagenMuggengaasPerId.remove(standaardPrijs.id) ??
                standaardPrijs,
          ...opgeslagenMuggengaasPerId.values,
        ];

    return OpmetingVeluxDakraamInstellingen(
      catalogusJaar: _naarInt(json['catalogusJaar'], standaard.catalogusJaar),
      geldigVanaf: json['geldigVanaf']?.toString().trim() ?? '',
      prijzen: List<OpmetingVeluxDakraamCatalogusPrijs>.unmodifiable(
        samengevoegdePrijzen,
      ),
      muggengaasPrijzen:
          List<OpmetingVeluxMuggengaasCatalogusPrijs>.unmodifiable(
            samengevoegdeMuggengaasPrijzen,
          ),
      kux110PrijsExclBtw: _naarDouble(
        json['kux110PrijsExclBtw'],
        standaard.kux110PrijsExclBtw,
      ),
      afwerkingMdfPrijsExclBtw: _naarDouble(
        json['afwerkingMdfPrijsExclBtw'],
        standaard.afwerkingMdfPrijsExclBtw,
      ),
      afwerkingKunststofWitPrijsExclBtw: _naarDouble(
        json['afwerkingKunststofWitPrijsExclBtw'],
        standaard.afwerkingKunststofWitPrijsExclBtw,
      ),
      gewijzigdOp: json['gewijzigdOp']?.toString() ?? '',
    );
  }

  static List<OpmetingVeluxDakraamCatalogusPrijs> _leesPrijzen(
    dynamic ruwePrijzen,
  ) {
    if (ruwePrijzen is! List) {
      return const <OpmetingVeluxDakraamCatalogusPrijs>[];
    }

    return ruwePrijzen
        .whereType<Map>()
        .map(
          (json) => OpmetingVeluxDakraamCatalogusPrijs.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .where(
          (prijs) => prijs.productCode.isNotEmpty && prijs.maatCode.isNotEmpty,
        )
        .toList(growable: false);
  }

  static List<OpmetingVeluxMuggengaasCatalogusPrijs> _leesMuggengaasPrijzen(
    dynamic ruwePrijzen,
  ) {
    if (ruwePrijzen is! List) {
      return const <OpmetingVeluxMuggengaasCatalogusPrijs>[];
    }

    return ruwePrijzen
        .whereType<Map>()
        .map(
          (json) => OpmetingVeluxMuggengaasCatalogusPrijs.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .where((prijs) => prijs.productCode.isNotEmpty)
        .toList(growable: false);
  }

  static int _naarInt(dynamic waarde, int standaard) {
    if (waarde is int) return waarde;
    if (waarde is num) return waarde.toInt();
    return int.tryParse(waarde?.toString() ?? '') ?? standaard;
  }

  static double _naarDouble(dynamic waarde, double standaard) {
    if (waarde is num) return waarde.toDouble();
    return double.tryParse((waarde?.toString() ?? '').replaceAll(',', '.')) ??
        standaard;
  }
}
