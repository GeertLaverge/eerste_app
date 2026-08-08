// THIMACO-CONTROLE: SCHUCO-FOLIE-KLEUR-MODEL-IMPORTFIX-20260808-1813

class SchucoFolieKleur {
  const SchucoFolieKleur({
    required this.id,
    required this.naam,
    required this.folieNummer,
    this.hex = '',
  });

  final String id;
  final String naam;
  final String folieNummer;

  /// Benaderende schermkleur. Folie, glans, structuur en lichtinval kunnen in
  /// werkelijkheid afwijken. De Dessin-/folienummers blijven de bron voor de
  /// effectieve keuze.
  final String hex;

  String get keuzeTekst {
    final nummer = folieNummer.trim();
    return nummer.isEmpty ? naam.trim() : '${naam.trim()} · $nummer';
  }

  String get zoekTekst => '${naam.trim()} ${folieNummer.trim()}'.toLowerCase();

  SchucoFolieKleur copyWith({
    String? id,
    String? naam,
    String? folieNummer,
    String? hex,
  }) {
    return SchucoFolieKleur(
      id: id ?? this.id,
      naam: naam ?? this.naam,
      folieNummer: folieNummer ?? this.folieNummer,
      hex: hex ?? this.hex,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'naam': naam,
    'folieNummer': folieNummer,
    'hex': hex,
  };

  factory SchucoFolieKleur.fromJson(Map<String, dynamic> json) {
    return SchucoFolieKleur(
      id: json['id']?.toString() ?? '',
      naam: json['naam']?.toString() ?? '',
      folieNummer: json['folieNummer']?.toString() ?? '',
      hex: json['hex']?.toString() ?? '',
    );
  }
}

class SchucoFolieKleuren {
  const SchucoFolieKleuren._();

  static const String submenuId = 'thimaco_schuco_folie_kleuren';
  static const String submenuNaam = 'Schüco folie kleuren';

  static const List<SchucoFolieKleur> standaard = <SchucoFolieKleur>[
    SchucoFolieKleur(
      id: 'schuco_001',
      naam: "Massa wit",
      folieNummer: "",
      hex: '#FFFFFF',
    ),
    SchucoFolieKleur(
      id: 'schuco_002',
      naam: "Massa crème",
      folieNummer: "",
      hex: '#EFE1C5',
    ),
    SchucoFolieKleur(
      id: 'schuco_003',
      naam: "Sheffield Oak light",
      folieNummer: "456-3081",
      hex: '#D8C7A8',
    ),
    SchucoFolieKleur(
      id: 'schuco_004',
      naam: "Eiken natuur",
      folieNummer: "9.3167 011-116700",
      hex: '#C6A87B',
    ),
    SchucoFolieKleur(
      id: 'schuco_005',
      naam: "Oregon 4",
      folieNummer: "9.1192 001-116700",
      hex: '#C9953D',
    ),
    SchucoFolieKleur(
      id: 'schuco_006',
      naam: "Bergpijnboom",
      folieNummer: "9.3069 041-116700",
      hex: '#C8AA79',
    ),
    SchucoFolieKleur(
      id: 'schuco_007',
      naam: "Knoestige eiken",
      folieNummer: "436-3078",
      hex: '#CBB68E',
    ),
    SchucoFolieKleur(
      id: 'schuco_008',
      naam: "Montana 49197",
      folieNummer: "3.0178 001-101100",
      hex: '#D1C3AA',
    ),
    SchucoFolieKleur(
      id: 'schuco_009',
      naam: "Winchester XA 49240",
      folieNummer: "4.0175 004-114800",
      hex: '#B9A68C',
    ),
    SchucoFolieKleur(
      id: 'schuco_010',
      naam: "Indian 49198",
      folieNummer: "3.0178 003-101100",
      hex: '#B79B79',
    ),
    SchucoFolieKleur(
      id: 'schuco_011',
      naam: "Douglasie",
      folieNummer: "9.3152 009-116700",
      hex: '#B97A45',
    ),
    SchucoFolieKleur(
      id: 'schuco_012',
      naam: "Canadian 49195",
      folieNummer: "3.0178 002-101100",
      hex: '#A66E43',
    ),
    SchucoFolieKleur(
      id: 'schuco_013',
      naam: "Golden Oak 49158",
      folieNummer: "3.0029 005-101100",
      hex: '#B97829',
    ),
    SchucoFolieKleur(
      id: 'schuco_014',
      naam: "Macoré",
      folieNummer: "9.3162 002-116700",
      hex: '#A85E39',
    ),
    SchucoFolieKleur(
      id: 'schuco_015',
      naam: "Siena Rosso 49233",
      folieNummer: "4.0131 005-114800",
      hex: '#995D46',
    ),
    SchucoFolieKleur(
      id: 'schuco_016',
      naam: "Mahonie",
      folieNummer: "9.2097 013-116700",
      hex: '#7B3A32',
    ),
    SchucoFolieKleur(
      id: 'schuco_017',
      naam: "Notenboom",
      folieNummer: "436-2048",
      hex: '#71513F',
    ),
    SchucoFolieKleur(
      id: 'schuco_018',
      naam: "Eiken licht",
      folieNummer: "9.3167 002-116800",
      hex: '#C5A26B',
    ),
    SchucoFolieKleur(
      id: 'schuco_019',
      naam: "Eiken moeras",
      folieNummer: "9.2052 089-116700",
      hex: '#67503E',
    ),
    SchucoFolieKleur(
      id: 'schuco_020',
      naam: "Siena Noce 49237",
      folieNummer: "4.0131 003-114800",
      hex: '#7A4A3D',
    ),
    SchucoFolieKleur(
      id: 'schuco_021',
      naam: "Eiken donker",
      folieNummer: "9.3167 004-116700",
      hex: '#4A362C',
    ),
    SchucoFolieKleur(
      id: 'schuco_022',
      naam: "Eiken grijs",
      folieNummer: "9.2140 305-116700",
      hex: '#44484A',
    ),
    SchucoFolieKleur(
      id: 'schuco_023',
      naam: "Aluminium geborsteld",
      folieNummer: "436-1001",
      hex: '#C7C9C7',
    ),
    SchucoFolieKleur(
      id: 'schuco_024',
      naam: "Zilver metallic",
      folieNummer: "436-1002",
      hex: '#BFC4C6',
    ),
    SchucoFolieKleur(
      id: 'schuco_025',
      naam: "Alux wit aluminium",
      folieNummer: "436-1015",
      hex: '#D6D7D2',
    ),
    SchucoFolieKleur(
      id: 'schuco_026',
      naam: "Alux grijs aluminium",
      folieNummer: "436-1016",
      hex: '#909498',
    ),
    SchucoFolieKleur(
      id: 'schuco_027',
      naam: "Alux DB 703",
      folieNummer: "436-1014A",
      hex: '#55585A',
    ),
    SchucoFolieKleur(
      id: 'schuco_028',
      naam: "Alux antraciet",
      folieNummer: "436-1012",
      hex: '#353A3C',
    ),
    SchucoFolieKleur(
      id: 'schuco_029',
      naam: "Lichtgrijs glad, benadert RAL 7035",
      folieNummer: "02.11.71.000049-808300",
      hex: '#CBD0CC',
    ),
    SchucoFolieKleur(
      id: 'schuco_030',
      naam: "Lichtgrijs, benadert RAL 7035",
      folieNummer: "02.11.71.000049-116700",
      hex: '#CBD0CC',
    ),
    SchucoFolieKleur(
      id: 'schuco_031',
      naam: "Agaatgrijs glad",
      folieNummer: "436-7037",
      hex: '#B8B9B4',
    ),
    SchucoFolieKleur(
      id: 'schuco_032',
      naam: "Agaatgrijs",
      folieNummer: "436-5037",
      hex: '#B0B2AD',
    ),
    SchucoFolieKleur(
      id: 'schuco_033',
      naam: "Zijdegrijs, benadert RAL 7044",
      folieNummer: "436-5031",
      hex: '#CAC4B0',
    ),
    SchucoFolieKleur(
      id: 'schuco_034',
      naam: "Kiezelgrijs, benadert RAL 7032",
      folieNummer: "436-5033",
      hex: '#B8B799',
    ),
    SchucoFolieKleur(
      id: 'schuco_035',
      naam: "Signaalgrijs glad, benadert RAL 7004",
      folieNummer: "02.11.71.000038-808300",
      hex: '#999A9F',
    ),
    SchucoFolieKleur(
      id: 'schuco_036',
      naam: "Zilvergrijs glad, benadert RAL 7001",
      folieNummer: "02.11.71.000047-808300",
      hex: '#8F9695',
    ),
    SchucoFolieKleur(
      id: 'schuco_037',
      naam: "Zilvergrijs, benadert RAL 7001",
      folieNummer: "02.11.71.000047-116700",
      hex: '#8F9695',
    ),
    SchucoFolieKleur(
      id: 'schuco_038',
      naam: "Steengrijs, benadert RAL 7030",
      folieNummer: "436-5045",
      hex: '#928E85',
    ),
    SchucoFolieKleur(
      id: 'schuco_039',
      naam: "Betongrijs, benadert RAL 7023",
      folieNummer: "436-5038",
      hex: '#4E5452',
    ),
    SchucoFolieKleur(
      id: 'schuco_040',
      naam: "Kwartsgrijs glad, benadert RAL 7039",
      folieNummer: "02.11.71.000046-808300",
      hex: '#6C6960',
    ),
    SchucoFolieKleur(
      id: 'schuco_041',
      naam: "Kwartsgrijs, benadert RAL 7039",
      folieNummer: "02.11.71.000046-116700",
      hex: '#6C6960',
    ),
    SchucoFolieKleur(
      id: 'schuco_042',
      naam: "Basaltgrijs glad, benadert RAL 7012",
      folieNummer: "02.11.71.000039-808300",
      hex: '#575D5E',
    ),
    SchucoFolieKleur(
      id: 'schuco_043',
      naam: "Basaltgrijs, benadert RAL 7012",
      folieNummer: "02.11.71.000039-116700",
      hex: '#575D5E',
    ),
    SchucoFolieKleur(
      id: 'schuco_044',
      naam: "Leigrijs glad, benadert RAL 7015",
      folieNummer: "02.11.71.000040-808300",
      hex: '#51565C',
    ),
    SchucoFolieKleur(
      id: 'schuco_045',
      naam: "Antracietgrijs glad, benadert RAL 7016",
      folieNummer: "436-7003A",
      hex: '#383E42',
    ),
    SchucoFolieKleur(
      id: 'schuco_046',
      naam: "Antracietgrijs, benadert RAL 7016",
      folieNummer: "436-5003A",
      hex: '#383E42',
    ),
    SchucoFolieKleur(
      id: 'schuco_047',
      naam: "Zwartgrijs glad, benadert RAL 7021",
      folieNummer: "02.11.71.000042-808300",
      hex: '#2F3234',
    ),
    SchucoFolieKleur(
      id: 'schuco_048',
      naam: "Zwart ulti-mat",
      folieNummer: "02.20.01.000002-504700",
      hex: '#17191A',
    ),
    SchucoFolieKleur(
      id: 'schuco_049',
      naam: "Reinwit, benadert RAL 9010",
      folieNummer: "456-5053",
      hex: '#F1ECE1',
    ),
    SchucoFolieKleur(
      id: 'schuco_050',
      naam: "Crèmewit, benadert RAL 9001",
      folieNummer: "456-5054",
      hex: '#E9E0D2',
    ),
    SchucoFolieKleur(
      id: 'schuco_051',
      naam: "Lichtivoor, benadert RAL 1015",
      folieNummer: "456-5056",
      hex: '#E6D2B5',
    ),
    SchucoFolieKleur(
      id: 'schuco_052',
      naam: "Grijsbeige, benadert RAL 1019",
      folieNummer: "02.11.11.000040-116700",
      hex: '#A29480',
    ),
    SchucoFolieKleur(
      id: 'schuco_053',
      naam: "Geel, benadert RAL 1018",
      folieNummer: "02.11.11.000062-116700",
      hex: '#F3E03B',
    ),
    SchucoFolieKleur(
      id: 'schuco_054',
      naam: "Lichtrood, benadert RAL 3002",
      folieNummer: "02.11.31.000010-116700",
      hex: '#C63927',
    ),
    SchucoFolieKleur(
      id: 'schuco_055',
      naam: "Rood, benadert RAL 3011",
      folieNummer: "02.11.31.000013-116700",
      hex: '#792423',
    ),
    SchucoFolieKleur(
      id: 'schuco_056',
      naam: "Wijnrood, benadert RAL 3005",
      folieNummer: "02.11.31.000012-116700",
      hex: '#5E2028',
    ),
    SchucoFolieKleur(
      id: 'schuco_057',
      naam: "Lichtgroen, benadert RAL 6001",
      folieNummer: "02.11.61.000014-116700",
      hex: '#28713E',
    ),
    SchucoFolieKleur(
      id: 'schuco_058',
      naam: "Mosgroen, benadert RAL 6005",
      folieNummer: "02.11.61.000013-116700",
      hex: '#0F4336',
    ),
    SchucoFolieKleur(
      id: 'schuco_059',
      naam: "Spargroen, benadert RAL 6009",
      folieNummer: "436-5021",
      hex: '#27352A',
    ),
    SchucoFolieKleur(
      id: 'schuco_060',
      naam: "Monumentengroen",
      folieNummer: "9925.05-116700",
      hex: '#233B36',
    ),
    SchucoFolieKleur(
      id: 'schuco_061',
      naam: "Briljantblauw, benadert RAL 5007",
      folieNummer: "02.20.51.000002-116700",
      hex: '#3E5F8A',
    ),
    SchucoFolieKleur(
      id: 'schuco_062',
      naam: "Ultramarijnblauw, benadert RAL 5002",
      folieNummer: "02.11.51.000026-116700",
      hex: '#20214F',
    ),
    SchucoFolieKleur(
      id: 'schuco_063',
      naam: "Kobaltblauw, benadert RAL 5013",
      folieNummer: "02.11.51.000029-116700",
      hex: '#1E2460',
    ),
    SchucoFolieKleur(
      id: 'schuco_064',
      naam: "Staalblauw, benadert RAL 5011",
      folieNummer: "02.11.51.000033-116700",
      hex: '#1F3438',
    ),
    SchucoFolieKleur(
      id: 'schuco_065',
      naam: "Monumentenblauw",
      folieNummer: "5004.05-116700",
      hex: '#26364A',
    ),
    SchucoFolieKleur(
      id: 'schuco_066',
      naam: "Maron-bruin",
      folieNummer: "02.11.81.000120-116700",
      hex: '#4E302C',
    ),
    SchucoFolieKleur(
      id: 'schuco_067',
      naam: "Chocoladebruin",
      folieNummer: "02.11.81.000122-116700",
      hex: '#3A2923',
    ),
    SchucoFolieKleur(
      id: 'schuco_068',
      naam: "Bruin dekor",
      folieNummer: "02.11.81.000101-116700",
      hex: '#46362F',
    ),
    SchucoFolieKleur(
      id: 'schuco_069',
      naam: "Pyrite",
      folieNummer: "02.12.17.000001-119501",
      hex: '#A3A49D',
    ),
    SchucoFolieKleur(
      id: 'schuco_070',
      naam: "Bronze Platin",
      folieNummer: "9.1293 714-119501",
      hex: '#665A51',
    ),
    SchucoFolieKleur(
      id: 'schuco_071',
      naam: "Earl Platin",
      folieNummer: "9.1293 010-119500",
      hex: '#596064',
    ),
    SchucoFolieKleur(
      id: 'schuco_072',
      naam: "Black VLF",
      folieNummer: "02.20.01.000002-102200",
      hex: '#161A1D',
    ),
    SchucoFolieKleur(
      id: 'schuco_073',
      naam: "Zwartgrijs",
      folieNummer: "436-5023",
      hex: '#34383B',
    ),
  ];

  static List<SchucoFolieKleur> standaardKopie() {
    return standaard.map((kleur) => kleur.copyWith()).toList(growable: true);
  }
}
