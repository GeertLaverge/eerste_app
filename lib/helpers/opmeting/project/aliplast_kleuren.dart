// THIMACO-CONTROLE: ALIPLAST-POEDERLIJST-2025-20260808

class AliplastKleur {
  const AliplastKleur({
    required this.product,
    required this.productOmschrijving,
    required this.productCrossreferentie,
  });

  final String product;
  final String productOmschrijving;
  final String productCrossreferentie;

  String get samenvatting {
    return <String>[
      product.trim(),
      productOmschrijving.trim(),
      productCrossreferentie.trim(),
    ].where((deel) => deel.isNotEmpty).join(' · ');
  }

  String get zoekTekst => samenvatting.toLowerCase();
}

class AliplastKleuren {
  const AliplastKleuren._();

  /// Aliplast Powder information 03-2025, geldig vanaf 01/03/2025.
  /// Alleen Product, Productomschrijving en Product crossreferentie worden
  /// bewust opgenomen, conform het beheer in de Thimaco-app.
  static const List<AliplastKleur> alle = <AliplastKleur>[
    AliplastKleur(
      product: '1000',
      productOmschrijving: 'GRUNBEIGE SATIJN',
      productCrossreferentie: 'AE70011100020',
    ),
    AliplastKleur(
      product: '1000M',
      productOmschrijving: 'GRUNBEIGE MAT',
      productCrossreferentie: 'AE30011100020T',
    ),
    AliplastKleur(
      product: '1001',
      productOmschrijving: 'BEIGE SATIJN',
      productCrossreferentie: 'AE70011960425',
    ),
    AliplastKleur(
      product: '1001M',
      productOmschrijving: 'BEIGE MAT',
      productCrossreferentie: 'AE30011100120T',
    ),
    AliplastKleur(
      product: '1002',
      productOmschrijving: 'SANDGELB SATIJN',
      productCrossreferentie: 'AE70011960525',
    ),
    AliplastKleur(
      product: '1002M',
      productOmschrijving: 'SANDGELB MAT',
      productCrossreferentie: 'AE30011100220',
    ),
    AliplastKleur(
      product: '1003',
      productOmschrijving: 'SIGNALGELB SATIJN',
      productCrossreferentie: 'AE70011440025',
    ),
    AliplastKleur(
      product: '1003M',
      productOmschrijving: 'SIGNALGELB MAT',
      productCrossreferentie: 'AE30011100320',
    ),
    AliplastKleur(
      product: '1004',
      productOmschrijving: 'GOLDGELB SATIJN',
      productCrossreferentie: 'AE70011670125',
    ),
    AliplastKleur(
      product: '1004M',
      productOmschrijving: 'GOLDGELB MAT',
      productCrossreferentie: 'AE30011100410T',
    ),
    AliplastKleur(
      product: '1005',
      productOmschrijving: 'HONIGGELB SATIJN',
      productCrossreferentie: 'AE70011770125',
    ),
    AliplastKleur(
      product: '1005M',
      productOmschrijving: 'HONIGGEEL MAT',
      productCrossreferentie: 'AE30011100520',
    ),
    AliplastKleur(
      product: '1006',
      productOmschrijving: 'MAISGELB SATIJN',
      productCrossreferentie: 'AE70011100620',
    ),
    AliplastKleur(
      product: '1006M',
      productOmschrijving: 'MAISGELB MAT',
      productCrossreferentie: 'AE30011100620',
    ),
    AliplastKleur(
      product: '1007',
      productOmschrijving: 'NARZISSENGELB SATIJN',
      productCrossreferentie: 'AE70011810125',
    ),
    AliplastKleur(
      product: '1007M',
      productOmschrijving: 'NARZISSENGELB MAT',
      productCrossreferentie: 'AE30011100720',
    ),
    AliplastKleur(
      product: '100-NT',
      productOmschrijving: 'BEIGE',
      productCrossreferentie: 'VHL1E0002 - BEIGE FUTUNA',
    ),
    AliplastKleur(
      product: '1011',
      productOmschrijving: 'BRAUNBEIGE SATIJN',
      productCrossreferentie: 'AE70018260125',
    ),
    AliplastKleur(
      product: '1011M',
      productOmschrijving: 'BRAUNBEIGE MAT',
      productCrossreferentie: 'AE300C1101120T',
    ),
    AliplastKleur(
      product: '1012',
      productOmschrijving: 'ZITRONENGELB SATIJN',
      productCrossreferentie: 'AE70011101220',
    ),
    AliplastKleur(
      product: '1013',
      productOmschrijving: 'PERLWEISS SATIJN',
      productCrossreferentie: 'AE70019420225',
    ),
    AliplastKleur(
      product: '1013M',
      productOmschrijving: 'PERLWEISS MAT',
      productCrossreferentie: 'AE30011101320',
    ),
    AliplastKleur(
      product: '1013MX',
      productOmschrijving: 'PARELWIT',
      productCrossreferentie: 'AE30009002423',
    ),
    AliplastKleur(
      product: '1013ST',
      productOmschrijving: 'CREME WIT METALLIC STRUCTUUR',
      productCrossreferentie: '029/15508',
    ),
    AliplastKleur(
      product: '1014',
      productOmschrijving: 'ELFENBEIN SATIJN',
      productCrossreferentie: 'AE70011960625',
    ),
    AliplastKleur(
      product: '1014M',
      productOmschrijving: 'ELFENBEIN MAT',
      productCrossreferentie: 'AE30011101420',
    ),
    AliplastKleur(
      product: '1015',
      productOmschrijving: 'HELL ELFENBEIN SATIJN',
      productCrossreferentie: 'AE70019920125',
    ),
    AliplastKleur(
      product: '1015LC',
      productOmschrijving: '1015',
      productCrossreferentie: '029/15518',
    ),
    AliplastKleur(
      product: '1015M',
      productOmschrijving: 'LICHT IVOOKLEUR MAT',
      productCrossreferentie: 'AE30001002523',
    ),
    AliplastKleur(
      product: '1015MT',
      productOmschrijving: 'LICHT IVOORKLEUR MAT',
      productCrossreferentie: '068/15096',
    ),
    AliplastKleur(
      product: '1015ST',
      productOmschrijving: 'LICHT IVOORKLEUR METAL STRUCTR',
      productCrossreferentie: '029/15461',
    ),
    AliplastKleur(
      product: '1015T',
      productOmschrijving: 'LICHT IVOOR SATIJN',
      productCrossreferentie: '068/10069',
    ),
    AliplastKleur(
      product: '1016',
      productOmschrijving: 'SCHWEFELGELB SATIJN',
      productCrossreferentie: 'AE70011100225',
    ),
    AliplastKleur(
      product: '1016CC',
      productOmschrijving: 'ZWAVEL GEEL MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03051101620',
    ),
    AliplastKleur(
      product: '1017',
      productOmschrijving: 'SAFRANGELB SATIJN',
      productCrossreferentie: 'AE70011101720',
    ),
    AliplastKleur(
      product: '1017M',
      productOmschrijving: 'SAFRAANGEEL MAT',
      productCrossreferentie: 'AE300C1101720',
    ),
    AliplastKleur(
      product: '1018',
      productOmschrijving: 'ZINKGELB SATIJN',
      productCrossreferentie: 'AE70011200125',
    ),
    AliplastKleur(
      product: '1018CC',
      productOmschrijving: 'ZINKGEEL MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03051101820',
    ),
    AliplastKleur(
      product: '1018M',
      productOmschrijving: 'ZINKGELB MAT',
      productCrossreferentie: 'AE30011101820',
    ),
    AliplastKleur(
      product: '1019',
      productOmschrijving: 'GRAUBEIGE SATIJN',
      productCrossreferentie: 'PE50/TR1019HR/73/180',
    ),
    AliplastKleur(
      product: '1019LC',
      productOmschrijving: 'MAT STRUCTUUR',
      productCrossreferentie: 'AE03051101920',
    ),
    AliplastKleur(
      product: '1019M',
      productOmschrijving: 'GRAUBEIGE MAT',
      productCrossreferentie: 'AE30011101920',
    ),
    AliplastKleur(
      product: '1020',
      productOmschrijving: 'OLIVGELB SATIJN',
      productCrossreferentie: 'AE70011102020',
    ),
    AliplastKleur(
      product: '1020M',
      productOmschrijving: 'OLIJFGEEL MAT',
      productCrossreferentie: 'AE30011102020',
    ),
    AliplastKleur(
      product: '1021',
      productOmschrijving: 'RAPSGELB SATIJN',
      productCrossreferentie: 'AE70011400125',
    ),
    AliplastKleur(
      product: '1021M',
      productOmschrijving: 'RAPSGELB MAT',
      productCrossreferentie: 'AE300C1102120',
    ),
    AliplastKleur(
      product: '1023',
      productOmschrijving: 'VERKEHRSGELB SATIJN',
      productCrossreferentie: 'AE70011360325',
    ),
    AliplastKleur(
      product: '1023M',
      productOmschrijving: 'VERKEERSGEEL MAT',
      productCrossreferentie: 'AE300C1102320',
    ),
    AliplastKleur(
      product: '1024',
      productOmschrijving: 'OKERGEEL',
      productCrossreferentie: 'AE70011102420',
    ),
    AliplastKleur(
      product: '1024M',
      productOmschrijving: 'OKERGEEL MAT',
      productCrossreferentie: 'AE300C1102420',
    ),
    AliplastKleur(
      product: '1028',
      productOmschrijving: 'MELONENGELB SATIJN',
      productCrossreferentie: 'AE70011102820',
    ),
    AliplastKleur(
      product: '1028CC',
      productOmschrijving: 'MELOENGEEL MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03051102820',
    ),
    AliplastKleur(
      product: '1032',
      productOmschrijving: 'GINSTERGELB SATIJN',
      productCrossreferentie: 'AE70011103220',
    ),
    AliplastKleur(
      product: '1033',
      productOmschrijving: 'DAHLIENGELB SATIJN',
      productCrossreferentie: 'AE70011610125',
    ),
    AliplastKleur(
      product: '1034',
      productOmschrijving: 'PASTELLGELB SATIJN',
      productCrossreferentie: 'AE70011103420',
    ),
    AliplastKleur(
      product: '1034M',
      productOmschrijving: 'PASTELLGELB MAT',
      productCrossreferentie: 'AE30011103420',
    ),
    AliplastKleur(
      product: '1035',
      productOmschrijving: 'PARELBEIGE METALLIC',
      productCrossreferentie: 'PE50/TRX + 1035HR/NA/180/3',
    ),
    AliplastKleur(
      product: '1036',
      productOmschrijving: 'PARELMOER GOUD',
      productCrossreferentie: '029/90012',
    ),
    AliplastKleur(
      product: '1113',
      productOmschrijving: 'GEEL',
      productCrossreferentie: 'AE70001029521',
    ),
    AliplastKleur(
      product: '1247',
      productOmschrijving: 'BRUIN',
      productCrossreferentie: 'AE70018875725',
    ),
    AliplastKleur(
      product: '1247M',
      productOmschrijving: 'BRUIN MAT',
      productCrossreferentie: 'ST882F',
    ),
    AliplastKleur(
      product: '1247MX',
      productOmschrijving: 'BROWN 1247',
      productCrossreferentie: 'AE20008008921',
    ),
    AliplastKleur(
      product: '1247SX',
      productOmschrijving: 'BRUIN 1247 MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03058124720',
    ),
    AliplastKleur(
      product: '1M15X',
      productOmschrijving: 'LIGHT IVORY',
      productCrossreferentie: 'AE30011101520',
    ),
    AliplastKleur(
      product: '1M35X',
      productOmschrijving: 'PARELMOERGRIJS',
      productCrossreferentie: 'AE20311031721',
    ),
    AliplastKleur(
      product: '1MM00X',
      productOmschrijving: 'ANODIC GOLD',
      productCrossreferentie: 'AE20111000820',
    ),
    AliplastKleur(
      product: '1MS11X',
      productOmschrijving: 'BRUINBEIGE MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03051101120',
    ),
    AliplastKleur(
      product: '1MS15X',
      productOmschrijving: 'LICHT IVOORKLEUR MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03051101520',
    ),
    AliplastKleur(
      product: '1MS35X',
      productOmschrijving: 'PEARL BEIGE',
      productCrossreferentie: 'AE03211136121',
    ),
    AliplastKleur(
      product: '1MS37A',
      productOmschrijving: 'YAZD SABLE RENSON BEIGE',
      productCrossreferentie: 'YW370F',
    ),
    AliplastKleur(
      product: '1MS96X',
      productOmschrijving: 'WBX F436-6039 YELLOW',
      productCrossreferentie: 'AE03001139627',
    ),
    AliplastKleur(
      product: '1SM13X',
      productOmschrijving: 'PARELWIT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03051101320',
    ),
    AliplastKleur(
      product: '1SY30H',
      productOmschrijving: 'S4010-Y30R BEIGE',
      productCrossreferentie: 'HT05645',
    ),
    AliplastKleur(
      product: '2000',
      productOmschrijving: 'GELBORANGE SATIJN',
      productCrossreferentie: 'AE70012220125',
    ),
    AliplastKleur(
      product: '2000M',
      productOmschrijving: 'GEEL-ORANJE MAT',
      productCrossreferentie: 'AE30012200020',
    ),
    AliplastKleur(
      product: '2001',
      productOmschrijving: 'ROTORANGE SATIJN',
      productCrossreferentie: 'AE70012200120',
    ),
    AliplastKleur(
      product: '2001M',
      productOmschrijving: 'ROODORANJE MAT',
      productCrossreferentie: 'AE30012200120',
    ),
    AliplastKleur(
      product: '2002',
      productOmschrijving: 'BLUTORANGE SATIJN',
      productCrossreferentie: 'AE70012900425',
    ),
    AliplastKleur(
      product: '2002M',
      productOmschrijving: 'BLUTORANGE MAT',
      productCrossreferentie: 'AE30012200220',
    ),
    AliplastKleur(
      product: '2003',
      productOmschrijving: 'PASTELLORANGE SATIJN',
      productCrossreferentie: 'AE70012200320',
    ),
    AliplastKleur(
      product: '2004',
      productOmschrijving: 'REINORANGE SATIJN',
      productCrossreferentie: 'AE70012700125',
    ),
    AliplastKleur(
      product: '2004CC',
      productOmschrijving: 'ORANJE MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03052200420',
    ),
    AliplastKleur(
      product: '2008',
      productOmschrijving: 'HELLROTORANGE SATIJN',
      productCrossreferentie: 'AE70012260225',
    ),
    AliplastKleur(
      product: '2009',
      productOmschrijving: 'VERKEHRSORANGE SATIJN',
      productCrossreferentie: 'AE70012600125',
    ),
    AliplastKleur(
      product: '2009M',
      productOmschrijving: '2009M VERKEERSORANJE',
      productCrossreferentie: 'AE30012200920',
    ),
    AliplastKleur(
      product: '2010',
      productOmschrijving: 'SIGNALORANGE SATIJN',
      productCrossreferentie: 'AE70012201020',
    ),
    AliplastKleur(
      product: '2011',
      productOmschrijving: 'TIEFORANGE SATIJN',
      productCrossreferentie: 'AE70012120125',
    ),
    AliplastKleur(
      product: '2011M',
      productOmschrijving: 'DIEPORANGE',
      productCrossreferentie: 'AE300C2201120',
    ),
    AliplastKleur(
      product: '2012',
      productOmschrijving: 'ZALMORANJE',
      productCrossreferentie: 'AE70012201220',
    ),
    AliplastKleur(
      product: '2013',
      productOmschrijving: 'PAREL ORANJE',
      productCrossreferentie: 'AE80312080125',
    ),
    AliplastKleur(
      product: '3000',
      productOmschrijving: 'FEUERROT SATIJN',
      productCrossreferentie: 'PE50/TR3000HR/73/180',
    ),
    AliplastKleur(
      product: '3000LC',
      productOmschrijving: 'ROOD',
      productCrossreferentie: '029/30702',
    ),
    AliplastKleur(
      product: '3000M',
      productOmschrijving: 'FEUERROT MAT',
      productCrossreferentie: 'AE30013300020',
    ),
    AliplastKleur(
      product: '3001',
      productOmschrijving: 'SIGNALROT SATIJN',
      productCrossreferentie: 'AE70013300120',
    ),
    AliplastKleur(
      product: '3001M',
      productOmschrijving: 'SIGNALROT MAT',
      productCrossreferentie: 'AE30013300120',
    ),
    AliplastKleur(
      product: '3002',
      productOmschrijving: 'KARMINROT SATIJN',
      productCrossreferentie: 'AE70013300220',
    ),
    AliplastKleur(
      product: '3002M',
      productOmschrijving: 'KARMINROT MAT',
      productCrossreferentie: 'AE30013300220',
    ),
    AliplastKleur(
      product: '3003',
      productOmschrijving: 'RUBINROT SATIJN',
      productCrossreferentie: 'PE50/TR3003HR/73/180',
    ),
    AliplastKleur(
      product: '3003M',
      productOmschrijving: 'RUBINROT MAT',
      productCrossreferentie: 'AE30013300320',
    ),
    AliplastKleur(
      product: '3004',
      productOmschrijving: 'PURPURROT SATIJN',
      productCrossreferentie: 'AE70013720125',
    ),
    AliplastKleur(
      product: '3004LC',
      productOmschrijving: 'PURPERROOD MAT FIJNSTRUCTUUR',
      productCrossreferentie: '029/30706',
    ),
    AliplastKleur(
      product: '3004M',
      productOmschrijving: 'PURPURROT MAT',
      productCrossreferentie: 'SG804F D1036 MAT',
    ),
    AliplastKleur(
      product: '3005',
      productOmschrijving: 'WEINROT SATIJN',
      productCrossreferentie: 'PE50/TR3005HR/73/180',
    ),
    AliplastKleur(
      product: '3005LC',
      productOmschrijving: 'WIJNROOD MAT STRUCTUUR',
      productCrossreferentie: '029/30709',
    ),
    AliplastKleur(
      product: '3005M',
      productOmschrijving: 'WEINROT MAT',
      productCrossreferentie: '17880',
    ),
    AliplastKleur(
      product: '3007',
      productOmschrijving: 'SCHWARZROT SATIJN',
      productCrossreferentie: 'AE70013300720',
    ),
    AliplastKleur(
      product: '3007M',
      productOmschrijving: 'SCHWARZROT MAT',
      productCrossreferentie: 'AE30013300720',
    ),
    AliplastKleur(
      product: '3009',
      productOmschrijving: '3009 OXIDROT SATIJN',
      productCrossreferentie: 'AE70018400225',
    ),
    AliplastKleur(
      product: '3009M',
      productOmschrijving: 'OXIDROT MAT',
      productCrossreferentie: 'AE30013300920',
    ),
    AliplastKleur(
      product: '3009ST',
      productOmschrijving: 'ROOSTROOD METALLIC STRUCTUUR',
      productCrossreferentie: '029/30401',
    ),
    AliplastKleur(
      product: '300-NT',
      productOmschrijving: 'ROODBRUIN',
      productCrossreferentie: 'VDL1E0017 - RUST RAME',
    ),
    AliplastKleur(
      product: '3011',
      productOmschrijving: 'BRAUNROT SATIJN',
      productCrossreferentie: 'AE70013580125',
    ),
    AliplastKleur(
      product: '3011M',
      productOmschrijving: 'BRUINROOD MAT',
      productCrossreferentie: 'AE30013301120',
    ),
    AliplastKleur(
      product: '3012',
      productOmschrijving: 'BEIGEROOD SATIJN',
      productCrossreferentie: 'AE70013301220',
    ),
    AliplastKleur(
      product: '3012M',
      productOmschrijving: 'BEIGEROOD MAT',
      productCrossreferentie: 'AE30013301220',
    ),
    AliplastKleur(
      product: '3013',
      productOmschrijving: 'TOMAATROOD SATIJN',
      productCrossreferentie: 'AE70013301320',
    ),
    AliplastKleur(
      product: '3013M',
      productOmschrijving: 'TOMAATROOD',
      productCrossreferentie: 'AE300C3301320',
    ),
    AliplastKleur(
      product: '3014',
      productOmschrijving: 'ALTROSA MAT',
      productCrossreferentie: 'AE70013301420',
    ),
    AliplastKleur(
      product: '3014M',
      productOmschrijving: 'OUDROZE MAT',
      productCrossreferentie: 'AE30013301420',
    ),
    AliplastKleur(
      product: '3015',
      productOmschrijving: 'HELLROSA SATIJN',
      productCrossreferentie: 'AE70013301520',
    ),
    AliplastKleur(
      product: '3015M',
      productOmschrijving: 'HELLROSA MAT',
      productCrossreferentie: 'SG815G',
    ),
    AliplastKleur(
      product: '3016',
      productOmschrijving: 'KORALLENROT SATIJN',
      productCrossreferentie: 'AE70013301620',
    ),
    AliplastKleur(
      product: '3016M',
      productOmschrijving: 'KORALLENROT MAT',
      productCrossreferentie: 'AE30013301620T',
    ),
    AliplastKleur(
      product: '3018M',
      productOmschrijving: 'AARDBEIROOD MAT',
      productCrossreferentie: 'AE300C3301820',
    ),
    AliplastKleur(
      product: '3020',
      productOmschrijving: 'VERKEHRSROT SATIJN',
      productCrossreferentie: 'PE50/TR3020HR/73/180',
    ),
    AliplastKleur(
      product: '3020CC',
      productOmschrijving: 'VERKEERSROOD MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03053302020',
    ),
    AliplastKleur(
      product: '3020M',
      productOmschrijving: 'VERKEHRSROT MAT',
      productCrossreferentie: 'AE30013302020',
    ),
    AliplastKleur(
      product: '3022',
      productOmschrijving: 'LACHSROT SATIJN',
      productCrossreferentie: 'AE70013302220',
    ),
    AliplastKleur(
      product: '3022M',
      productOmschrijving: 'LACHSROT MAT',
      productCrossreferentie: 'AE300C3302220',
    ),
    AliplastKleur(
      product: '3027',
      productOmschrijving: 'HIMBEERROT SATIJN',
      productCrossreferentie: 'AE70013302720',
    ),
    AliplastKleur(
      product: '3027M',
      productOmschrijving: 'HIMBEERROT MAT',
      productCrossreferentie: 'AE30013302720',
    ),
    AliplastKleur(
      product: '3031',
      productOmschrijving: 'ORIENTROT SATIJN',
      productCrossreferentie: 'AE70013303120',
    ),
    AliplastKleur(
      product: '3031M',
      productOmschrijving: 'ORIENTAALROOD MAT',
      productCrossreferentie: 'AE30013303120',
    ),
    AliplastKleur(
      product: '3032',
      productOmschrijving: 'METALLIC PARELROBIJNROOD',
      productCrossreferentie: 'AE80313030425',
    ),
    AliplastKleur(
      product: '303-PT',
      productOmschrijving: 'PURE TEXTURE RED',
      productCrossreferentie: 'RWMXD-8868',
    ),
    AliplastKleur(
      product: '3099ST',
      productOmschrijving: 'ROOD METALLIC STRUCTUUR',
      productCrossreferentie: '029/30402',
    ),
    AliplastKleur(
      product: '346-PM',
      productOmschrijving: 'DONKER ROOD METALLIC VLAK MAT',
      productCrossreferentie: '068/80476',
    ),
    AliplastKleur(
      product: '3M04D',
      productOmschrijving: 'ROOD PURPER RAL 3004',
      productCrossreferentie: 'AE03053300420',
    ),
    AliplastKleur(
      product: '3M04X',
      productOmschrijving: 'PURPERROOD MAT',
      productCrossreferentie: 'AE30013300420',
    ),
    AliplastKleur(
      product: '3M280A',
      productOmschrijving: 'MANGANESE 2525 KLASSE II',
      productCrossreferentie: 'YW280F',
    ),
    AliplastKleur(
      product: '3MS09X',
      productOmschrijving: 'RAL 3009 OXIDE RED MAT FIJNTEXTUUR',
      productCrossreferentie: 'AE03053300920',
    ),
    AliplastKleur(
      product: '3MS80A',
      productOmschrijving: 'NCS S4020-Y80R MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'S4020-Y80R',
    ),
    AliplastKleur(
      product: '3NCS90',
      productOmschrijving: 'NCS S3040-Y90R MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'HTS05440',
    ),
    AliplastKleur(
      product: '3SM35A',
      productOmschrijving: 'MARS 2525 SABLE',
      productCrossreferentie: 'YX355F',
    ),
    AliplastKleur(
      product: '4001',
      productOmschrijving: 'ROTLILA SATIJN',
      productCrossreferentie: 'AE70013400120',
    ),
    AliplastKleur(
      product: '4002',
      productOmschrijving: 'ROTVIOLETT SATIJN',
      productCrossreferentie: 'AE70013760125',
    ),
    AliplastKleur(
      product: '4002M',
      productOmschrijving: 'ROTVIOLETT MAT',
      productCrossreferentie: 'AE30013400220',
    ),
    AliplastKleur(
      product: '4003',
      productOmschrijving: 'ERIKAVIOLETT SATIJN',
      productCrossreferentie: 'AE70013400320',
    ),
    AliplastKleur(
      product: '4004',
      productOmschrijving: 'BORDEAUXVIOLETT SATIJN',
      productCrossreferentie: 'AE70013400420',
    ),
    AliplastKleur(
      product: '4004M',
      productOmschrijving: 'BORDEAUXVIOLETT MAT',
      productCrossreferentie: 'AE30013400420T',
    ),
    AliplastKleur(
      product: '4005',
      productOmschrijving: 'BLAULILA SATIJN',
      productCrossreferentie: 'AE70015411025',
    ),
    AliplastKleur(
      product: '4005CC',
      productOmschrijving: 'PAARS MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03053400520',
    ),
    AliplastKleur(
      product: '4006',
      productOmschrijving: 'VERKEHRSPURPUR SATIJN',
      productCrossreferentie: 'AE70013330225',
    ),
    AliplastKleur(
      product: '4006CC',
      productOmschrijving: 'VERKEERSPAARS MAT FIJNSTR.',
      productCrossreferentie: 'AE03053400620',
    ),
    AliplastKleur(
      product: '4006M',
      productOmschrijving: 'VERKEHRSPURPUR MAT',
      productCrossreferentie: 'AE300C3400620',
    ),
    AliplastKleur(
      product: '4007',
      productOmschrijving: 'PURPURVIOLETT SATIJN',
      productCrossreferentie: 'AE70013400720',
    ),
    AliplastKleur(
      product: '4007M',
      productOmschrijving: 'PURPERVIOLET MAT',
      productCrossreferentie: 'AE300C3400720',
    ),
    AliplastKleur(
      product: '4008',
      productOmschrijving: 'SIGNALVIOLETT SATIJN',
      productCrossreferentie: 'AE70013330425',
    ),
    AliplastKleur(
      product: '4009',
      productOmschrijving: 'PASTELLVIOLETT SATIJN',
      productCrossreferentie: 'AE70013400920',
    ),
    AliplastKleur(
      product: '4009M',
      productOmschrijving: 'PASTELVIOLET MAT',
      productCrossreferentie: 'AE300C3400920',
    ),
    AliplastKleur(
      product: '4010',
      productOmschrijving: 'TELEMAGENTA',
      productCrossreferentie: 'AE70013401020',
    ),
    AliplastKleur(
      product: '4010CC',
      productOmschrijving: 'TELEMAGENTA MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03053401020',
    ),
    AliplastKleur(
      product: '4011',
      productOmschrijving: 'PARELVIOLET',
      productCrossreferentie: 'AE80315011225',
    ),
    AliplastKleur(
      product: '4012',
      productOmschrijving: 'PARELBRAAMBES METALIC',
      productCrossreferentie: 'AE80315011125',
    ),
    AliplastKleur(
      product: '4SM21A',
      productOmschrijving: 'NOIR 2100 SABLE',
      productCrossreferentie: 'YW359F',
    ),
    AliplastKleur(
      product: '5000',
      productOmschrijving: 'VIOLETTBLAU SATIJN',
      productCrossreferentie: 'AE70015500020',
    ),
    AliplastKleur(
      product: '5000M',
      productOmschrijving: 'VIOLETTBLAU MAT',
      productCrossreferentie: 'AE30015500020',
    ),
    AliplastKleur(
      product: '5001',
      productOmschrijving: 'GRUNBLAU SATIJN',
      productCrossreferentie: 'AE70015820125',
    ),
    AliplastKleur(
      product: '5001M',
      productOmschrijving: 'GRUNBLAU MAT',
      productCrossreferentie: 'AE300C5500120',
    ),
    AliplastKleur(
      product: '5002',
      productOmschrijving: 'ULTRAMARIN BLAU SATIJN',
      productCrossreferentie: 'PE50/TR5002HR/73/180',
    ),
    AliplastKleur(
      product: '5002LC',
      productOmschrijving: 'ULTRAMARIJN BLAUW MAT STRUCT.',
      productCrossreferentie: '029/41420',
    ),
    AliplastKleur(
      product: '5002M',
      productOmschrijving: 'ULTRAMARIN BLAU MAT',
      productCrossreferentie: 'AE30015500220',
    ),
    AliplastKleur(
      product: '5003',
      productOmschrijving: 'SAPHIRBLAU SATIJN',
      productCrossreferentie: 'PE50/TR5003HR/73/180',
    ),
    AliplastKleur(
      product: '5003M',
      productOmschrijving: 'SAPHIRBLAU MAT',
      productCrossreferentie: 'SJ803G',
    ),
    AliplastKleur(
      product: '5003ST',
      productOmschrijving: 'STRUCTUUR SAFIERBLAUW',
      productCrossreferentie: 'AE03055500320',
    ),
    AliplastKleur(
      product: '5004',
      productOmschrijving: 'SCHWARZBLAU SATIJN',
      productCrossreferentie: 'AE70015500420',
    ),
    AliplastKleur(
      product: '5004M',
      productOmschrijving: 'SCHWARZBLAU MAT',
      productCrossreferentie: 'AE30015500420',
    ),
    AliplastKleur(
      product: '5004X',
      productOmschrijving: 'ZWARTBLAUW',
      productCrossreferentie: 'AE30015970325',
    ),
    AliplastKleur(
      product: '5005',
      productOmschrijving: 'SIGNALBLAU SATIJN',
      productCrossreferentie: 'AE70015500520',
    ),
    AliplastKleur(
      product: '5005M',
      productOmschrijving: 'SIGNALBLAU MAT',
      productCrossreferentie: 'AE30015500520',
    ),
    AliplastKleur(
      product: '5007',
      productOmschrijving: 'BRILLANTBLAU SAT;OPWERKEN',
      productCrossreferentie: 'AE70015470225',
    ),
    AliplastKleur(
      product: '5007M',
      productOmschrijving: 'BRILLANTBLAU MAT',
      productCrossreferentie: 'AE30015500720',
    ),
    AliplastKleur(
      product: '5008',
      productOmschrijving: 'GRAUBLAU SATIJN',
      productCrossreferentie: 'AE70017830125',
    ),
    AliplastKleur(
      product: '5008LC',
      productOmschrijving: 'GRAUBLAU MAT STRUCTUUR',
      productCrossreferentie: '029/41112',
    ),
    AliplastKleur(
      product: '5008M',
      productOmschrijving: 'BLAUW MAT',
      productCrossreferentie: 'AE300C5500820',
    ),
    AliplastKleur(
      product: '5009',
      productOmschrijving: 'AZURBLAU SATIJN',
      productCrossreferentie: 'AE70015500920',
    ),
    AliplastKleur(
      product: '5009M',
      productOmschrijving: 'AZURBLAU MAT',
      productCrossreferentie: 'AE30015500920',
    ),
    AliplastKleur(
      product: '5010',
      productOmschrijving: 'ENZIANBLAU SATIJN',
      productCrossreferentie: 'PE50/TR5010HR/73/180',
    ),
    AliplastKleur(
      product: '5010LC',
      productOmschrijving: 'ENZIANBLAUW',
      productCrossreferentie: '029/41432',
    ),
    AliplastKleur(
      product: '5010M',
      productOmschrijving: 'ENZIANBLAU MAT',
      productCrossreferentie: 'AE30015501020',
    ),
    AliplastKleur(
      product: '5011',
      productOmschrijving: 'STAHLBLAU SATIJN',
      productCrossreferentie: 'AE70015950125',
    ),
    AliplastKleur(
      product: '5011LC',
      productOmschrijving: 'MAT STRUCTUUR',
      productCrossreferentie: '029/40870',
    ),
    AliplastKleur(
      product: '5011M',
      productOmschrijving: 'STAHLBLAU MAT',
      productCrossreferentie: 'AE300C5501120',
    ),
    AliplastKleur(
      product: '5011ST',
      productOmschrijving: 'BLAUW METALLIC STRUCTUUR',
      productCrossreferentie: '029/40782',
    ),
    AliplastKleur(
      product: '5012',
      productOmschrijving: 'LICHTBLAU SATIJN',
      productCrossreferentie: 'AE70015310325',
    ),
    AliplastKleur(
      product: '5012A',
      productOmschrijving: 'LICHTBLAUW',
      productCrossreferentie: 'SJ712JR',
    ),
    AliplastKleur(
      product: '5012M',
      productOmschrijving: 'LICHTBLAU MAT',
      productCrossreferentie: 'AE30015501220',
    ),
    AliplastKleur(
      product: '5013',
      productOmschrijving: 'KOBALTBLAU SATIJN',
      productCrossreferentie: 'AE70015810225',
    ),
    AliplastKleur(
      product: '5013M',
      productOmschrijving: 'KOBALTBLAU MAT',
      productCrossreferentie: 'AE300C5501320',
    ),
    AliplastKleur(
      product: '5014',
      productOmschrijving: 'TAUBENBLAU SATIJN',
      productCrossreferentie: 'AE70015270125',
    ),
    AliplastKleur(
      product: '5014M',
      productOmschrijving: 'TAUBENBLAU MAT',
      productCrossreferentie: 'AE300C5501420',
    ),
    AliplastKleur(
      product: '5015',
      productOmschrijving: 'HIMMELBLAU SATIJN',
      productCrossreferentie: 'AE70015400225',
    ),
    AliplastKleur(
      product: '5015CC',
      productOmschrijving: 'HEMELSBLAUW MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03055501520',
    ),
    AliplastKleur(
      product: '5015LC',
      productOmschrijving: 'HEMELSBLAUW MAT FIJNSTRUCTUUR',
      productCrossreferentie: '029/41449',
    ),
    AliplastKleur(
      product: '5015M',
      productOmschrijving: 'HIMMELBLAU MAT',
      productCrossreferentie: 'AE30015501520',
    ),
    AliplastKleur(
      product: '5017',
      productOmschrijving: 'VERKEHRSBLAU SATIJN',
      productCrossreferentie: 'AE70015611025',
    ),
    AliplastKleur(
      product: '5017M',
      productOmschrijving: 'VERKEHRSBLAU MAT',
      productCrossreferentie: 'AE30015501720',
    ),
    AliplastKleur(
      product: '5018',
      productOmschrijving: 'TURKISBLAU SATIJN',
      productCrossreferentie: 'AE70015501820',
    ),
    AliplastKleur(
      product: '5018CC',
      productOmschrijving: 'TURQUOISBLAUW MAT FIJNSTRUCT.',
      productCrossreferentie: 'AE03055501820',
    ),
    AliplastKleur(
      product: '5018M',
      productOmschrijving: 'turquoise blue matt',
      productCrossreferentie: 'AE30015501820',
    ),
    AliplastKleur(
      product: '5019',
      productOmschrijving: 'CAPRIBLAU SATIJN',
      productCrossreferentie: 'PE50/TR5019HR/73/180',
    ),
    AliplastKleur(
      product: '5019M',
      productOmschrijving: 'CAPRIBLAU MAT',
      productCrossreferentie: 'AE30015501920',
    ),
    AliplastKleur(
      product: '5020',
      productOmschrijving: 'OZEANBLAU SATIJN',
      productCrossreferentie: 'AE70015502020',
    ),
    AliplastKleur(
      product: '5020M',
      productOmschrijving: 'OZEANBLAU MAT',
      productCrossreferentie: 'AE30015502020',
    ),
    AliplastKleur(
      product: '5021',
      productOmschrijving: 'WASSERBLAU SATIJN',
      productCrossreferentie: 'AE70015550125',
    ),
    AliplastKleur(
      product: '5021M',
      productOmschrijving: 'WASSERBLAU MAT',
      productCrossreferentie: 'AE30015502120',
    ),
    AliplastKleur(
      product: '5022',
      productOmschrijving: 'NACHTBLAU SATIJN',
      productCrossreferentie: 'AE70015502220',
    ),
    AliplastKleur(
      product: '5022M',
      productOmschrijving: 'NACHTBLAU MAT',
      productCrossreferentie: 'AE30015502220',
    ),
    AliplastKleur(
      product: '5023',
      productOmschrijving: 'FERNBLAU SATIJN',
      productCrossreferentie: 'AE70015610425',
    ),
    AliplastKleur(
      product: '5023M',
      productOmschrijving: 'FERNBLAU MAT',
      productCrossreferentie: 'AE300C5502320',
    ),
    AliplastKleur(
      product: '5024',
      productOmschrijving: 'PASTELLBLAU SATIJN',
      productCrossreferentie: 'AE70015370425',
    ),
    AliplastKleur(
      product: '5024M',
      productOmschrijving: 'PASTELLBLAU MAT',
      productCrossreferentie: 'AE30015502420',
    ),
    AliplastKleur(
      product: '5025',
      productOmschrijving: 'BLAUW METALLIC',
      productCrossreferentie: 'AE80315051025',
    ),
    AliplastKleur(
      product: '5026',
      productOmschrijving: 'PARELNACHTBLAUW',
      productCrossreferentie: 'AE80315011025',
    ),
    AliplastKleur(
      product: '5MS02X',
      productOmschrijving: 'ULTRAMARIJNBLAUW',
      productCrossreferentie: 'AE03055500220',
    ),
    AliplastKleur(
      product: '5MS08A',
      productOmschrijving: 'BLAUW MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'RWXZ-5563',
    ),
    AliplastKleur(
      product: '5MS10X',
      productOmschrijving: 'RAL 5010 FIJNTEXTUUR',
      productCrossreferentie: 'AE03055501020',
    ),
    AliplastKleur(
      product: '6000',
      productOmschrijving: 'PATINAGRUN SATIJN',
      productCrossreferentie: 'AE70016600020',
    ),
    AliplastKleur(
      product: '6000M',
      productOmschrijving: 'PATINAGRUN MAT',
      productCrossreferentie: 'AE30016600020',
    ),
    AliplastKleur(
      product: '6001',
      productOmschrijving: 'SMARAGDGRUN SATIJN',
      productCrossreferentie: 'AE70016520125',
    ),
    AliplastKleur(
      product: '6001M',
      productOmschrijving: 'SMARAGDEN - GROEN MAT',
      productCrossreferentie: 'AE300C6600120',
    ),
    AliplastKleur(
      product: '6002',
      productOmschrijving: 'LAUBGRUN SATIJN',
      productCrossreferentie: 'AE70016600225',
    ),
    AliplastKleur(
      product: '6002M',
      productOmschrijving: 'LAUBGRUN MAT',
      productCrossreferentie: 'AE30016600220',
    ),
    AliplastKleur(
      product: '6003',
      productOmschrijving: 'OLIVGRUN SATIJN',
      productCrossreferentie: 'AE70016380125',
    ),
    AliplastKleur(
      product: '6003M',
      productOmschrijving: 'OLIVGRUN MAT',
      productCrossreferentie: 'AE300C6600320',
    ),
    AliplastKleur(
      product: '6004',
      productOmschrijving: 'BLAUGRUN SATIJN',
      productCrossreferentie: 'AE70016670225',
    ),
    AliplastKleur(
      product: '6004M',
      productOmschrijving: 'BLAUGRUN MAT',
      productCrossreferentie: 'AE300C6600420',
    ),
    AliplastKleur(
      product: '6005',
      productOmschrijving: 'MOOSGRUN SATIJN',
      productCrossreferentie: 'AE70016830125',
    ),
    AliplastKleur(
      product: '6005LC',
      productOmschrijving: 'MAT STRUCTUUR MOSGROEN',
      productCrossreferentie: '029/50321',
    ),
    AliplastKleur(
      product: '6005M',
      productOmschrijving: 'MOOSGRUN MAT',
      productCrossreferentie: 'PE52/TRM6005HR/30/200',
    ),
    AliplastKleur(
      product: '6006',
      productOmschrijving: 'GRAUOLIV SATIJN',
      productCrossreferentie: 'AE70016880125',
    ),
    AliplastKleur(
      product: '6006M',
      productOmschrijving: 'GRAUOLIV MAT',
      productCrossreferentie: 'AE300C6600620',
    ),
    AliplastKleur(
      product: '6007',
      productOmschrijving: 'FLASCHENGRUN SATIJN',
      productCrossreferentie: 'AE70016600720',
    ),
    AliplastKleur(
      product: '6007M',
      productOmschrijving: 'FLASCHENGRUN MAT',
      productCrossreferentie: 'AE30016600720',
    ),
    AliplastKleur(
      product: '6008',
      productOmschrijving: 'BRAUNGRUN SATIJN',
      productCrossreferentie: 'AE70016980125',
    ),
    AliplastKleur(
      product: '6008M',
      productOmschrijving: 'BRUINGROEN MAT',
      productCrossreferentie: 'AE30016600820',
    ),
    AliplastKleur(
      product: '6009',
      productOmschrijving: 'DENNENGROEN SATIJN',
      productCrossreferentie: 'AE70016970425',
    ),
    AliplastKleur(
      product: '6009LC',
      productOmschrijving: 'MAT STRUCTUUR DENNENGROEN',
      productCrossreferentie: '029/50800',
    ),
    AliplastKleur(
      product: '6009M',
      productOmschrijving: 'DENNENGROEN MAT',
      productCrossreferentie: 'AE30016600920',
    ),
    AliplastKleur(
      product: '6009ST',
      productOmschrijving: 'DENNENGROEN METALLIC STRUCTUUR',
      productCrossreferentie: '029/50704',
    ),
    AliplastKleur(
      product: '600-NT',
      productOmschrijving: 'DONKER GROEN',
      productCrossreferentie: 'VGL0E0003 - MOUNTAIN MOSS',
    ),
    AliplastKleur(
      product: '6010',
      productOmschrijving: 'GRASGROEN SATIJN',
      productCrossreferentie: 'AE70016470125',
    ),
    AliplastKleur(
      product: '6010M',
      productOmschrijving: 'GRASGROEN MAT',
      productCrossreferentie: 'AE30016601020',
    ),
    AliplastKleur(
      product: '6011',
      productOmschrijving: 'RESEDAGRUN SATIJN',
      productCrossreferentie: 'AE70016270225',
    ),
    AliplastKleur(
      product: '6011LC',
      productOmschrijving: 'RESADAGROEN MAT FIJNSTRUCTUUR',
      productCrossreferentie: '029/51342',
    ),
    AliplastKleur(
      product: '6011M',
      productOmschrijving: 'RESEDAGRUN MAT',
      productCrossreferentie: 'AE300C6601120',
    ),
    AliplastKleur(
      product: '6012',
      productOmschrijving: 'SCHWARZGRUN SATIJN',
      productCrossreferentie: 'PE50/TR6012HR/73/180',
    ),
    AliplastKleur(
      product: '6012M',
      productOmschrijving: 'SCHWARZGRUN MAT',
      productCrossreferentie: 'AE30016601220',
    ),
    AliplastKleur(
      product: '6012ST',
      productOmschrijving: 'ZWARTGROEN METALLIC STRUCTUUR',
      productCrossreferentie: '029/80309',
    ),
    AliplastKleur(
      product: '6013',
      productOmschrijving: 'SCHILFGRUN SATIJN',
      productCrossreferentie: 'AE70016601320',
    ),
    AliplastKleur(
      product: '6013M',
      productOmschrijving: 'SCHILFGRUN MAT',
      productCrossreferentie: 'AE30016601320',
    ),
    AliplastKleur(
      product: '6014',
      productOmschrijving: 'GELBOLIV SATIJN',
      productCrossreferentie: 'AE70018650225',
    ),
    AliplastKleur(
      product: '6014M',
      productOmschrijving: 'GELBOLIV MAT',
      productCrossreferentie: 'AE30016601420',
    ),
    AliplastKleur(
      product: '6015',
      productOmschrijving: 'SCHWARZOLIV SATIJN',
      productCrossreferentie: 'AE70016810225',
    ),
    AliplastKleur(
      product: '6015M',
      productOmschrijving: 'SCHWARZOLIV MAT',
      productCrossreferentie: 'AE30016601520',
    ),
    AliplastKleur(
      product: '6015X',
      productOmschrijving: 'ZWART-OLIJF-GROEN',
      productCrossreferentie: 'AE70016601520',
    ),
    AliplastKleur(
      product: '6016',
      productOmschrijving: 'TURKISGRUN SATIJN',
      productCrossreferentie: 'AE70016601620',
    ),
    AliplastKleur(
      product: '6016CC',
      productOmschrijving: 'TURQUOISGROEN MAT FIJNSTRUCT.',
      productCrossreferentie: 'AE03056601620',
    ),
    AliplastKleur(
      product: '6016M',
      productOmschrijving: 'TURKS GROEN MAT',
      productCrossreferentie: 'AE30016601620',
    ),
    AliplastKleur(
      product: '6017',
      productOmschrijving: 'MAIGRUN SATIJN',
      productCrossreferentie: 'AE70016270425',
    ),
    AliplastKleur(
      product: '6017M',
      productOmschrijving: 'MAIGRUN MAT',
      productCrossreferentie: 'AE300C6601720',
    ),
    AliplastKleur(
      product: '6018',
      productOmschrijving: 'GELBGRUN SATIJN',
      productCrossreferentie: 'AE70016170325',
    ),
    AliplastKleur(
      product: '6018CC',
      productOmschrijving: 'GEELGROEN MAT FIJNSTRUCT.',
      productCrossreferentie: 'AE03056601820',
    ),
    AliplastKleur(
      product: '6018M',
      productOmschrijving: 'GELBGRUN MAT',
      productCrossreferentie: 'AE300C6601820',
    ),
    AliplastKleur(
      product: '6019',
      productOmschrijving: 'WEISSGRUN SATIJN',
      productCrossreferentie: 'AE70016601920',
    ),
    AliplastKleur(
      product: '6019M',
      productOmschrijving: 'WEISSGRUN MAT',
      productCrossreferentie: 'AE300C6601920',
    ),
    AliplastKleur(
      product: '6020',
      productOmschrijving: 'CHROMOXIDGRUN SATIJN',
      productCrossreferentie: 'AE70016710125',
    ),
    AliplastKleur(
      product: '6020M',
      productOmschrijving: 'CHROMOXIDEGROEND MAT',
      productCrossreferentie: 'AE30016602020',
    ),
    AliplastKleur(
      product: '6021',
      productOmschrijving: 'BLASSGRUN SATIJN',
      productCrossreferentie: 'AE70016170725',
    ),
    AliplastKleur(
      product: '6021LC',
      productOmschrijving: 'BLEEK GROEN MAT',
      productCrossreferentie: '029/51344',
    ),
    AliplastKleur(
      product: '6021M',
      productOmschrijving: 'BLASSGRUN MAT',
      productCrossreferentie: 'AE30016602120',
    ),
    AliplastKleur(
      product: '6021ST',
      productOmschrijving: 'LICHTGROEN STRUCTUUR',
      productCrossreferentie: 'AE03056602120',
    ),
    AliplastKleur(
      product: '6022',
      productOmschrijving: 'BRAUNOLIV SATIJN',
      productCrossreferentie: 'AE70016602220',
    ),
    AliplastKleur(
      product: '6022M',
      productOmschrijving: 'BRAUNOLIV MAT',
      productCrossreferentie: 'AE30016602220',
    ),
    AliplastKleur(
      product: '6024',
      productOmschrijving: 'VERKEHRSGRUN SATIJN',
      productCrossreferentie: 'AE70016602420',
    ),
    AliplastKleur(
      product: '6024M',
      productOmschrijving: 'VERKEHRSGRUN MAT',
      productCrossreferentie: 'AE30016602420',
    ),
    AliplastKleur(
      product: '6025',
      productOmschrijving: 'FARNGRUN SATIJN',
      productCrossreferentie: '014/50075',
    ),
    AliplastKleur(
      product: '6025M',
      productOmschrijving: 'FARM-GROEN MAT',
      productCrossreferentie: 'AE30016602520',
    ),
    AliplastKleur(
      product: '6026',
      productOmschrijving: 'OPAAL GROEN',
      productCrossreferentie: 'AE70016630125',
    ),
    AliplastKleur(
      product: '6026M',
      productOmschrijving: 'OPALGRUN MAT',
      productCrossreferentie: 'AE30016602620',
    ),
    AliplastKleur(
      product: '6027',
      productOmschrijving: 'LICHTGRUN SATIJN',
      productCrossreferentie: 'AE70015120125',
    ),
    AliplastKleur(
      product: '6027M',
      productOmschrijving: 'LICHTGRUN MAT',
      productCrossreferentie: 'AE30016602720',
    ),
    AliplastKleur(
      product: '6028',
      productOmschrijving: 'KIEFERNGRUN SATIJN',
      productCrossreferentie: 'AE70016720325',
    ),
    AliplastKleur(
      product: '6028M',
      productOmschrijving: 'KIEFERNGRUN MAT',
      productCrossreferentie: 'AE30016602820',
    ),
    AliplastKleur(
      product: '6029',
      productOmschrijving: 'MINZGRUN SATIJN',
      productCrossreferentie: 'PE50/TR6029HR/73/180',
    ),
    AliplastKleur(
      product: '6029M',
      productOmschrijving: 'MINZGRUN MAT',
      productCrossreferentie: 'AE30016602920',
    ),
    AliplastKleur(
      product: '6031M',
      productOmschrijving: '6031M',
      productCrossreferentie: 'AE30016870625',
    ),
    AliplastKleur(
      product: '6032',
      productOmschrijving: 'SIGNALGRUN SATIJN',
      productCrossreferentie: 'AE70016330425',
    ),
    AliplastKleur(
      product: '6032M',
      productOmschrijving: 'SIGNAALGROEN MAT',
      productCrossreferentie: 'AE30016603220',
    ),
    AliplastKleur(
      product: '6033',
      productOmschrijving: 'MINTTURKIS SATIJN',
      productCrossreferentie: 'AE70016230925',
    ),
    AliplastKleur(
      product: '6033M',
      productOmschrijving: 'MINTTURKIS MAT',
      productCrossreferentie: 'AE30016603320',
    ),
    AliplastKleur(
      product: '6034',
      productOmschrijving: 'PASTELLTRUKIS SATIJN',
      productCrossreferentie: 'AE70016603420',
    ),
    AliplastKleur(
      product: '6034M',
      productOmschrijving: 'PASTELLTRUKIS MAT',
      productCrossreferentie: 'AE30016603420',
    ),
    AliplastKleur(
      product: '6035',
      productOmschrijving: 'PARELGROEN METALIC',
      productCrossreferentie: 'AE80316020225',
    ),
    AliplastKleur(
      product: '6037M',
      productOmschrijving: 'PUUR GROEN MAT',
      productCrossreferentie: 'AE30016603720',
    ),
    AliplastKleur(
      product: '6064X',
      productOmschrijving: 'GRACHTENGROEN',
      productCrossreferentie: 'AE70016970225',
    ),
    AliplastKleur(
      product: '6099ST',
      productOmschrijving: 'GROEN METALLIC STRUCTUUR',
      productCrossreferentie: '029/50698',
    ),
    AliplastKleur(
      product: '609-PT',
      productOmschrijving: 'PURE TEXTURE GREEN',
      productCrossreferentie: 'RWMXD-6712',
    ),
    AliplastKleur(
      product: '609V4S',
      productOmschrijving: 'GROEN FIJNSTRUCTUUR',
      productCrossreferentie: 'POW686161/7',
    ),
    AliplastKleur(
      product: '65020X',
      productOmschrijving: 'GROEN',
      productCrossreferentie: 'AE70016611122',
    ),
    AliplastKleur(
      product: '6999ST',
      productOmschrijving: 'GROEN METALLIC STRUCTUUR',
      productCrossreferentie: '029/50759',
    ),
    AliplastKleur(
      product: '6HS10A',
      productOmschrijving: 'MONUMENTENGROEN',
      productCrossreferentie: 'SIKKENS NO.15.10',
    ),
    AliplastKleur(
      product: '6MS09X',
      productOmschrijving: 'FIR GREEN MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03056600920',
    ),
    AliplastKleur(
      product: '6MS12X',
      productOmschrijving: 'ZWARTGROEN MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03056601220',
    ),
    AliplastKleur(
      product: '6MS13X',
      productOmschrijving: 'RIETGROEN MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03056601320',
    ),
    AliplastKleur(
      product: '6MS14X',
      productOmschrijving: 'OLIJFGROEN MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03056601420',
    ),
    AliplastKleur(
      product: '6MS15X',
      productOmschrijving: 'ZWART OLIJFGROEN MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03056601520',
    ),
    AliplastKleur(
      product: '6SS10A',
      productOmschrijving: 'SIKKENS Q0.05.10 GROEN',
      productCrossreferentie: 'SN754F',
    ),
    AliplastKleur(
      product: '6TIKAL',
      productOmschrijving: 'GREEN METALLIC TIKAL 2525',
      productCrossreferentie: 'YW261I',
    ),
    AliplastKleur(
      product: '7000',
      productOmschrijving: 'FEHGRAU SATIJN',
      productCrossreferentie: 'AE70017330225',
    ),
    AliplastKleur(
      product: '7000LC',
      productOmschrijving: 'FEHGRAU MAT STRUCTUUR',
      productCrossreferentie: '1011756PX20',
    ),
    AliplastKleur(
      product: '7000M',
      productOmschrijving: 'FEHGRAU MAT',
      productCrossreferentie: 'AE30017700020',
    ),
    AliplastKleur(
      product: '7000ST',
      productOmschrijving: 'FEHGRAU STRUCTUUR',
      productCrossreferentie: '029/71358',
    ),
    AliplastKleur(
      product: '7001',
      productOmschrijving: 'SILBERGRAU SATIJN',
      productCrossreferentie: 'AE70017200225',
    ),
    AliplastKleur(
      product: '7001LC',
      productOmschrijving: '7001 FIJNSTRUCTUUR MAT',
      productCrossreferentie: '029/71909',
    ),
    AliplastKleur(
      product: '7001M',
      productOmschrijving: 'SILBERGRAU MAT',
      productCrossreferentie: 'AE30017700120',
    ),
    AliplastKleur(
      product: '7002',
      productOmschrijving: 'OLIVGRAU SATIJN',
      productCrossreferentie: 'AE70017420425',
    ),
    AliplastKleur(
      product: '7002M',
      productOmschrijving: 'OLIVGRAU MAT',
      productCrossreferentie: 'AE30017700220',
    ),
    AliplastKleur(
      product: '7003',
      productOmschrijving: 'MOOSGRAU SATIJN',
      productCrossreferentie: 'AE70017520125',
    ),
    AliplastKleur(
      product: '7003M',
      productOmschrijving: 'MOOSGRAU MAT',
      productCrossreferentie: 'AE30017700320',
    ),
    AliplastKleur(
      product: '7004',
      productOmschrijving: 'SIGNALGRAU SATIJN',
      productCrossreferentie: 'AE70017260325',
    ),
    AliplastKleur(
      product: '7004M',
      productOmschrijving: 'SIGNALGRAU MAT',
      productCrossreferentie: '18981',
    ),
    AliplastKleur(
      product: '7005',
      productOmschrijving: 'MAUSGRAU SATIJN',
      productCrossreferentie: 'AE70017420525',
    ),
    AliplastKleur(
      product: '7005M',
      productOmschrijving: 'MAUSGRAU MAT',
      productCrossreferentie: 'AE30017700520',
    ),
    AliplastKleur(
      product: '7006',
      productOmschrijving: 'BEIGEGRAU SATIJN',
      productCrossreferentie: 'AE70018170125',
    ),
    AliplastKleur(
      product: '7006LC',
      productOmschrijving: 'BEIGE GRIJS FIJNSTRUCTUUR MAT',
      productCrossreferentie: '029/73223',
    ),
    AliplastKleur(
      product: '7006M',
      productOmschrijving: 'BEIGEGRAU MAT',
      productCrossreferentie: 'AE30017700620',
    ),
    AliplastKleur(
      product: '7008',
      productOmschrijving: 'KHAKIGRAU SATIJN',
      productCrossreferentie: 'AE70018120125',
    ),
    AliplastKleur(
      product: '7008M',
      productOmschrijving: 'KHAKIGRAU MAT',
      productCrossreferentie: 'AE30017700820',
    ),
    AliplastKleur(
      product: '7009',
      productOmschrijving: 'GRUNGRAU SATIJN',
      productCrossreferentie: 'AE70017650225',
    ),
    AliplastKleur(
      product: '7009M',
      productOmschrijving: 'GRUNGRAU MAT',
      productCrossreferentie: 'AE30017700920',
    ),
    AliplastKleur(
      product: '7010',
      productOmschrijving: 'ZELTGRAU SATIJN',
      productCrossreferentie: 'AE70017650325',
    ),
    AliplastKleur(
      product: '7010LC',
      productOmschrijving: 'ZELTGRAU FIJNSTRUCTUUR MAT',
      productCrossreferentie: '029/71569',
    ),
    AliplastKleur(
      product: '7010M',
      productOmschrijving: 'ZELTGRAU MAT',
      productCrossreferentie: 'AE30017701020',
    ),
    AliplastKleur(
      product: '7011',
      productOmschrijving: 'EISENGRAU SATIJN',
      productCrossreferentie: 'AE70017620325',
    ),
    AliplastKleur(
      product: '7011LC',
      productOmschrijving: 'IJZERGRIJS FIJNSTR.MAT',
      productCrossreferentie: '029/73230',
    ),
    AliplastKleur(
      product: '7011M',
      productOmschrijving: 'IRON GREY',
      productCrossreferentie: 'AE300C7701120',
    ),
    AliplastKleur(
      product: '7012',
      productOmschrijving: 'BASALTGRAU SATIJN',
      productCrossreferentie: 'AE70017650125',
    ),
    AliplastKleur(
      product: '7012LC',
      productOmschrijving: 'BASALTGRAU MAT STRUCTUUR',
      productCrossreferentie: 'AE0305-7701220',
    ),
    AliplastKleur(
      product: '7012M',
      productOmschrijving: 'BASALTGRAU MAT',
      productCrossreferentie: 'AE30017701220',
    ),
    AliplastKleur(
      product: '7013',
      productOmschrijving: 'BRAUNGRAU SATIJN',
      productCrossreferentie: 'AE70018650125',
    ),
    AliplastKleur(
      product: '7013M',
      productOmschrijving: 'BRAUNGRAU MAT',
      productCrossreferentie: 'AE300C7701320',
    ),
    AliplastKleur(
      product: '7015',
      productOmschrijving: 'SCHIEFERGRAU SATIJN',
      productCrossreferentie: 'PE50/TR7015HR/73/180',
    ),
    AliplastKleur(
      product: '7015LC',
      productOmschrijving: 'SCHIEFERGRAU MAT STRUCTUUR',
      productCrossreferentie: '029/71719',
    ),
    AliplastKleur(
      product: '7015M',
      productOmschrijving: 'SCHIEFERGRAU MAT',
      productCrossreferentie: 'AE30017701520',
    ),
    AliplastKleur(
      product: '7016',
      productOmschrijving: 'ANTHRAZITGRAU SATIJN',
      productCrossreferentie: 'AE70017620225',
    ),
    AliplastKleur(
      product: '7016M',
      productOmschrijving: 'ANTRACITE-GRIJS MAT',
      productCrossreferentie: 'AE30017701620',
    ),
    AliplastKleur(
      product: '7016MT',
      productOmschrijving: 'ANTRACITE-GRIJS MAT',
      productCrossreferentie: '068/70153 RAL 7016',
    ),
    AliplastKleur(
      product: '7016ST',
      productOmschrijving: 'ANTRACIETGRIJS METALLIC STRUC.',
      productCrossreferentie: '029/71334',
    ),
    AliplastKleur(
      product: '7016T',
      productOmschrijving: 'ANTRACIET GRIJS SATIJN',
      productCrossreferentie: '068/70144',
    ),
    AliplastKleur(
      product: '7016TC',
      productOmschrijving: 'RAL7016 MAT FIJNSTR.KLASSE II',
      productCrossreferentie: '068/70190',
    ),
    AliplastKleur(
      product: '7016TI',
      productOmschrijving: 'ANTRACIET GRIJS',
      productCrossreferentie: '014/70019',
    ),
    AliplastKleur(
      product: '7021',
      productOmschrijving: 'SCHWARZGRAU SATIJN',
      productCrossreferentie: 'SL767F',
    ),
    AliplastKleur(
      product: '7021D',
      productOmschrijving: 'ZWART-GRIJS',
      productCrossreferentie: 'AE70017820125',
    ),
    AliplastKleur(
      product: '7021M',
      productOmschrijving: 'SCHWARZGRAU MAT',
      productCrossreferentie: 'SP868F',
    ),
    AliplastKleur(
      product: '7021MT',
      productOmschrijving: 'ZWARTGRIJS MAT',
      productCrossreferentie: '068/70206',
    ),
    AliplastKleur(
      product: '7021ST',
      productOmschrijving: 'ZWARTGRIJS METALLIC STRUCTUUR',
      productCrossreferentie: '029/71335',
    ),
    AliplastKleur(
      product: '7021T',
      productOmschrijving: 'ZWARTGRIJS SATIJN',
      productCrossreferentie: '068/70145',
    ),
    AliplastKleur(
      product: '7021TC',
      productOmschrijving: 'RAL7021 MAT FIJNSTR.KLASSE II',
      productCrossreferentie: '068/71764',
    ),
    AliplastKleur(
      product: '7022',
      productOmschrijving: 'UMBRAGRAU SATIJN',
      productCrossreferentie: 'AE70017750225',
    ),
    AliplastKleur(
      product: '7022M',
      productOmschrijving: 'UMBRAGRAU MAT',
      productCrossreferentie: '30017702220',
    ),
    AliplastKleur(
      product: '7022TC',
      productOmschrijving: 'RAL7022 MAT FIJNSTR.KLASSE II',
      productCrossreferentie: '068/71175',
    ),
    AliplastKleur(
      product: '7023',
      productOmschrijving: 'BETONGRAU SATIJN',
      productCrossreferentie: 'AE70017320625',
    ),
    AliplastKleur(
      product: '7023M',
      productOmschrijving: 'BETONGRIJS MAT',
      productCrossreferentie: 'AE30017702320',
    ),
    AliplastKleur(
      product: '7023TC',
      productOmschrijving: 'P723 GRIS BE MAT FIJNSTR.KL.II',
      productCrossreferentie: '068/71731',
    ),
    AliplastKleur(
      product: '7024',
      productOmschrijving: 'GRAPHITGRAU SATIJN',
      productCrossreferentie: 'DS311A8108',
    ),
    AliplastKleur(
      product: '7024LC',
      productOmschrijving: 'GRAFIETGRIJS STRUCTUUR',
      productCrossreferentie: '029/71795',
    ),
    AliplastKleur(
      product: '7024M',
      productOmschrijving: 'GRAPHITGRAU MAT',
      productCrossreferentie: 'AE30007004923',
    ),
    AliplastKleur(
      product: '7026',
      productOmschrijving: 'GRANITGRAU SATIJN',
      productCrossreferentie: 'AE70017850125',
    ),
    AliplastKleur(
      product: '7026M',
      productOmschrijving: 'GRANITGRAU MAT',
      productCrossreferentie: 'AE30017850325',
    ),
    AliplastKleur(
      product: '7030',
      productOmschrijving: 'STEINGRAU SATIJN',
      productCrossreferentie: 'PE50/TR7030HR/73/180',
    ),
    AliplastKleur(
      product: '7030M',
      productOmschrijving: 'STEINGRAU MAT',
      productCrossreferentie: 'AE30017703020',
    ),
    AliplastKleur(
      product: '7030TC',
      productOmschrijving: 'RAL7030 MAT FIJNSTR.KLASSE II',
      productCrossreferentie: '068/71756',
    ),
    AliplastKleur(
      product: '7031',
      productOmschrijving: 'BLAUGRAU SATIJN',
      productCrossreferentie: 'AE70017530125',
    ),
    AliplastKleur(
      product: '7031LC',
      productOmschrijving: 'BLAUWGRIJS MAT STRUCTUUR',
      productCrossreferentie: '029/73212',
    ),
    AliplastKleur(
      product: '7031M',
      productOmschrijving: 'BLAUGRAU MAT',
      productCrossreferentie: 'AE300C7703120',
    ),
    AliplastKleur(
      product: '7032',
      productOmschrijving: 'KIESELGRAU SATIJN',
      productCrossreferentie: 'AE70017120425',
    ),
    AliplastKleur(
      product: '7032M',
      productOmschrijving: 'KIESELGRAU MAT',
      productCrossreferentie: 'AE30017703220',
    ),
    AliplastKleur(
      product: '7032TC',
      productOmschrijving: 'PROFEL P 732 MAT FIJNSTR.KL.II',
      productCrossreferentie: '068/71733',
    ),
    AliplastKleur(
      product: '7033',
      productOmschrijving: 'ZEMENTGRAU SATIJN',
      productCrossreferentie: 'AE70017420325',
    ),
    AliplastKleur(
      product: '7033M',
      productOmschrijving: 'ZEMENTGRAU MAT',
      productCrossreferentie: 'AE30017703320',
    ),
    AliplastKleur(
      product: '7034',
      productOmschrijving: 'GELBGRAU SATIJN',
      productCrossreferentie: 'AE70017320525',
    ),
    AliplastKleur(
      product: '7034LC',
      productOmschrijving: 'GELBGRAU MAT STRUCTUUR',
      productCrossreferentie: '029/71666',
    ),
    AliplastKleur(
      product: '7034M',
      productOmschrijving: 'GELBGRAU MAT',
      productCrossreferentie: 'AE30017703420',
    ),
    AliplastKleur(
      product: '7035',
      productOmschrijving: 'LICHTGRAU SATIJN',
      productCrossreferentie: 'AE70019870225',
    ),
    AliplastKleur(
      product: '7035LC',
      productOmschrijving: 'LICHTGRAU MAT STRUCTUUR',
      productCrossreferentie: '029/72111',
    ),
    AliplastKleur(
      product: '7035M',
      productOmschrijving: 'LICHTGRAU MAT',
      productCrossreferentie: 'AE30017703520',
    ),
    AliplastKleur(
      product: '7036',
      productOmschrijving: 'PLATINGRAU SATIJN',
      productCrossreferentie: 'AE70017210125',
    ),
    AliplastKleur(
      product: '7036LC',
      productOmschrijving: 'PLATINGRIJS MAT STRUCTUUR',
      productCrossreferentie: '029/72859 7036 MAT STRUCTUUR',
    ),
    AliplastKleur(
      product: '7036M',
      productOmschrijving: 'PLATINGRAU MAT',
      productCrossreferentie: 'AE30017703620',
    ),
    AliplastKleur(
      product: '7037',
      productOmschrijving: 'STAUBGRAU SATIJN',
      productCrossreferentie: 'PE50/TR7037HR/73/180',
    ),
    AliplastKleur(
      product: '7037D',
      productOmschrijving: 'STAALGRIJS',
      productCrossreferentie: 'AE70017410125',
    ),
    AliplastKleur(
      product: '7037M',
      productOmschrijving: 'STAUBGRAU MAT',
      productCrossreferentie: 'AE30017703720',
    ),
    AliplastKleur(
      product: '7037TC',
      productOmschrijving: 'RAL7037 MAT FIJNSTR.KLASSE II',
      productCrossreferentie: '068/71293',
    ),
    AliplastKleur(
      product: '7038',
      productOmschrijving: 'ACHATGRAU SATIJN',
      productCrossreferentie: 'PE50/TR7038HR/73/180',
    ),
    AliplastKleur(
      product: '7038LC',
      productOmschrijving: 'ACHATGRAU MAT STRUCTUUR',
      productCrossreferentie: '029/73229',
    ),
    AliplastKleur(
      product: '7038M',
      productOmschrijving: 'ACHATGRAU MAT',
      productCrossreferentie: 'AE30017703820',
    ),
    AliplastKleur(
      product: '7039',
      productOmschrijving: 'QUARTZGRAU SATIJN',
      productCrossreferentie: 'AE70017580225',
    ),
    AliplastKleur(
      product: '7039M',
      productOmschrijving: 'QUARTZGRAU MAT',
      productCrossreferentie: 'AE30017703920',
    ),
    AliplastKleur(
      product: '7039TC',
      productOmschrijving: 'RAL7039 MAT FIJNSTR.KLASSE II',
      productCrossreferentie: '068/71291',
    ),
    AliplastKleur(
      product: '703SMX',
      productOmschrijving: 'DONKER GRIJS METALLIC FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03107070320 DB703 GREY',
    ),
    AliplastKleur(
      product: '7040',
      productOmschrijving: 'FENSTERGRAU SATIJN',
      productCrossreferentie: 'AE70017130525',
    ),
    AliplastKleur(
      product: '7040M',
      productOmschrijving: 'FENSTERGRAU MAT',
      productCrossreferentie: 'PE52/TRM7040HR/30/200',
    ),
    AliplastKleur(
      product: '7040ST',
      productOmschrijving: 'VENSTERGRIJS',
      productCrossreferentie: '029/90316',
    ),
    AliplastKleur(
      product: '7042',
      productOmschrijving: 'VERKEHRSGRAU A SATIJN',
      productCrossreferentie: 'AE70017320925',
    ),
    AliplastKleur(
      product: '7042LC',
      productOmschrijving: 'VERKEERSGRIJS FIJNSTRUCT.MAT',
      productCrossreferentie: '029/72089',
    ),
    AliplastKleur(
      product: '7042M',
      productOmschrijving: 'VERKEHRSGRAU MAT',
      productCrossreferentie: 'PE52/TRM7042HR/30/200',
    ),
    AliplastKleur(
      product: '7043',
      productOmschrijving: 'VERKEHRSGRAU B SATIJN',
      productCrossreferentie: 'AE70017720325',
    ),
    AliplastKleur(
      product: '7043LC',
      productOmschrijving: 'VERKEERSGRIJS',
      productCrossreferentie: '029/73220',
    ),
    AliplastKleur(
      product: '7043M',
      productOmschrijving: 'VERKEHRSGRAU B MAT',
      productCrossreferentie: 'AE300C7704320',
    ),
    AliplastKleur(
      product: '7044',
      productOmschrijving: 'SEIDENGRAU SATIJN',
      productCrossreferentie: 'AE70019820325',
    ),
    AliplastKleur(
      product: '7044M',
      productOmschrijving: 'SEIDENGRAU MAT',
      productCrossreferentie: 'AE30017704420',
    ),
    AliplastKleur(
      product: '7044TC',
      productOmschrijving: 'RAL7044 MAT FIJNSTR.KLASSE II',
      productCrossreferentie: '068/71732',
    ),
    AliplastKleur(
      product: '7045',
      productOmschrijving: 'TELEGRAU 1 SATIJN',
      productCrossreferentie: 'AE70017100225',
    ),
    AliplastKleur(
      product: '7045LC',
      productOmschrijving: 'TELEGRIJS FIJNSTRUCTUUR MAT',
      productCrossreferentie: '029/72360',
    ),
    AliplastKleur(
      product: '7045M',
      productOmschrijving: 'TELEGRAU 1 MAT',
      productCrossreferentie: 'AE30017704520',
    ),
    AliplastKleur(
      product: '7046',
      productOmschrijving: 'TELEGRAU 2 SATIJN',
      productCrossreferentie: 'AE70017370125',
    ),
    AliplastKleur(
      product: '7046LC',
      productOmschrijving: 'TELEGRIJS 2',
      productCrossreferentie: '029/73210',
    ),
    AliplastKleur(
      product: '7046M',
      productOmschrijving: 'TELEGRAU 2 MAT',
      productCrossreferentie: 'AE30017704620',
    ),
    AliplastKleur(
      product: '7047',
      productOmschrijving: 'TELEGRAU 4 SATIJN',
      productCrossreferentie: 'AE70019900225',
    ),
    AliplastKleur(
      product: '7047LC',
      productOmschrijving: 'RAL 7047 FIJNSTRUCTUUR MAT',
      productCrossreferentie: '029/73227',
    ),
    AliplastKleur(
      product: '7047M',
      productOmschrijving: 'TELEGRAU 4 MAT',
      productCrossreferentie: 'AE30017704720',
    ),
    AliplastKleur(
      product: '7047MT',
      productOmschrijving: 'TELEGRIJS 4 MAT',
      productCrossreferentie: '23295',
    ),
    AliplastKleur(
      product: '7047T',
      productOmschrijving: 'TELEGRIJS 4 SATIJN',
      productCrossreferentie: '068/70163',
    ),
    AliplastKleur(
      product: '7048',
      productOmschrijving: 'PERLMOUSGREY METALLIC',
      productCrossreferentie: 'AE80317021625',
    ),
    AliplastKleur(
      product: '716MSA',
      productOmschrijving: '7016 mat structuur ANTRACIETGRIJS',
      productCrossreferentie: 'SL316G',
    ),
    AliplastKleur(
      product: '716VS',
      productOmschrijving: 'VS716 ANTRACIET FIJNSTRUCTUUR',
      productCrossreferentie: 'SD030C7365921',
    ),
    AliplastKleur(
      product: '735MSA',
      productOmschrijving: 'MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'SL335G',
    ),
    AliplastKleur(
      product: '7GRANT',
      productOmschrijving: 'GRIS ANTIQUE',
      productCrossreferentie: 'AE03417101521 GRIS ANTHIQUE',
    ),
    AliplastKleur(
      product: '7H16X',
      productOmschrijving: 'ANTRACIET GRIJS HOOGGLANS',
      productCrossreferentie: 'IE80007701620',
    ),
    AliplastKleur(
      product: '7H40A',
      productOmschrijving: 'VENSTERGRIJS HOOGGLANS',
      productCrossreferentie: 'SLJ40G RAL7040 HOOGGLANS',
    ),
    AliplastKleur(
      product: '7M016D',
      productOmschrijving: 'ANTRACIET GRIJS MAT',
      productCrossreferentie: 'AE30047271921',
    ),
    AliplastKleur(
      product: '7M04X',
      productOmschrijving: 'SIGNALGRAU',
      productCrossreferentie: 'AE30017700420',
    ),
    AliplastKleur(
      product: '7M16D',
      productOmschrijving: 'RAL7016 MAT REYNAERS',
      productCrossreferentie: 'AE30007005023 GLANSGR.30%',
    ),
    AliplastKleur(
      product: '7M21A',
      productOmschrijving: 'ZWART-GRIJS MAT',
      productCrossreferentie: 'SL821G',
    ),
    AliplastKleur(
      product: '7M21D',
      productOmschrijving: 'RAL7021 MAT ZWARTGRIJS',
      productCrossreferentie: 'AE30007005123',
    ),
    AliplastKleur(
      product: '7M21X',
      productOmschrijving: 'ZWART-GRIJS MAT',
      productCrossreferentie: 'AE30017702120',
    ),
    AliplastKleur(
      product: '7M909D',
      productOmschrijving: 'BEIGEBRUIN',
      productCrossreferentie: 'AE30017012623',
    ),
    AliplastKleur(
      product: '7MM03I',
      productOmschrijving: 'PERL GLIMMER',
      productCrossreferentie: '5803E71382A10-K20',
    ),
    AliplastKleur(
      product: '7MM16I',
      productOmschrijving: 'DONKER MAT GRIJS METALLIC',
      productCrossreferentie: '5803E71387A10',
    ),
    AliplastKleur(
      product: '7MS02X',
      productOmschrijving: 'OLIJFGRIJS MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03057700220',
    ),
    AliplastKleur(
      product: '7MS04T',
      productOmschrijving: 'GRIJS FIJNSTRUCTUUR MAT SUPER DURABLE',
      productCrossreferentie: '068/70193',
    ),
    AliplastKleur(
      product: '7MS06X',
      productOmschrijving: 'BEIGE GREY MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03057700620',
    ),
    AliplastKleur(
      product: '7MS08X',
      productOmschrijving: 'KAKIGRIJS MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03057700820',
    ),
    AliplastKleur(
      product: '7MS09X',
      productOmschrijving: 'GRIJS-GROEN MAT FIJNSTUCTUUR',
      productCrossreferentie: 'AE03057700920',
    ),
    AliplastKleur(
      product: '7MS11X',
      productOmschrijving: 'IJZERGRIJS MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03057701120',
    ),
    AliplastKleur(
      product: '7MS12T',
      productOmschrijving: 'BASALTGRIJS',
      productCrossreferentie: '029/73222',
    ),
    AliplastKleur(
      product: '7MS13X',
      productOmschrijving: 'BRUINGRIJS MAT FIJNSTRUKTUUR',
      productCrossreferentie: 'AE03057701320',
    ),
    AliplastKleur(
      product: '7MS15X',
      productOmschrijving: 'LEIGRIJS FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03057701520',
    ),
    AliplastKleur(
      product: '7MS16A',
      productOmschrijving: 'ANTRACIETGRIJS FIJNSTRUCTUUR',
      productCrossreferentie: 'YL316F RAL7016 FIJNSTRUCTUUR',
    ),
    AliplastKleur(
      product: '7MS16D',
      productOmschrijving: 'GRAFIETGRIJS STRUCTUUR',
      productCrossreferentie: 'AE03057701620',
    ),
    AliplastKleur(
      product: '7MS21A',
      productOmschrijving: 'GRIJS STRUCTUUR METALLIC',
      productCrossreferentie: 'SW305I',
    ),
    AliplastKleur(
      product: '7MS21D',
      productOmschrijving: 'ZWARTGRIJS MAT STRUCTUUR',
      productCrossreferentie: 'AE03057702120',
    ),
    AliplastKleur(
      product: '7MS22D',
      productOmschrijving: 'UMBRAGRIJS MAT STRUCTUUR',
      productCrossreferentie: 'AE03057702220',
    ),
    AliplastKleur(
      product: '7MS22T',
      productOmschrijving: 'MAT STRUCTUUR UMBRAGRIJS',
      productCrossreferentie: '029/71740',
    ),
    AliplastKleur(
      product: '7MS23X',
      productOmschrijving: 'CONCRETE GREY',
      productCrossreferentie: 'AE03057702320',
    ),
    AliplastKleur(
      product: '7MS24X',
      productOmschrijving: 'GRAFIETGRIJS',
      productCrossreferentie: 'AE03057702420',
    ),
    AliplastKleur(
      product: '7MS26X',
      productOmschrijving: 'GRANIET GRIJS',
      productCrossreferentie: 'AE03057702620',
    ),
    AliplastKleur(
      product: '7MS280',
      productOmschrijving: 'GRIS 2800 SABLÉ',
      productCrossreferentie: 'YW356F',
    ),
    AliplastKleur(
      product: '7MS29A',
      productOmschrijving: 'GRIS 2900 SABLE',
      productCrossreferentie: 'YW355F',
    ),
    AliplastKleur(
      product: '7MS30X',
      productOmschrijving: 'STEENGRIJS MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03057703020',
    ),
    AliplastKleur(
      product: '7MS32X',
      productOmschrijving: 'KIEZELGRIJS',
      productCrossreferentie: 'AE03057703220',
    ),
    AliplastKleur(
      product: '7MS33X',
      productOmschrijving: 'CEMENTGRIJS MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03057703320',
    ),
    AliplastKleur(
      product: '7MS34X',
      productOmschrijving: 'GEELGRIJS MAT STRUCTUUR',
      productCrossreferentie: 'AE03057703420',
    ),
    AliplastKleur(
      product: '7MS35X',
      productOmschrijving: 'LICHTGRIJS MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03057703520',
    ),
    AliplastKleur(
      product: '7MS37X',
      productOmschrijving: 'STOFGRIJS MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03057703720',
    ),
    AliplastKleur(
      product: '7MS39D',
      productOmschrijving: 'COATEX STRUC.LAK REYNAERS',
      productCrossreferentie: 'AE0305-7703920',
    ),
    AliplastKleur(
      product: '7MS39T',
      productOmschrijving: '7039 MAT STRUCTUUR',
      productCrossreferentie: '029/72179 BELISOL P739',
    ),
    AliplastKleur(
      product: '7MS42X',
      productOmschrijving: 'VERKEERSGRIJS MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03057704220',
    ),
    AliplastKleur(
      product: '7MS43X',
      productOmschrijving: 'VERKEERSGRIJS B MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03057704320',
    ),
    AliplastKleur(
      product: '7MS48I',
      productOmschrijving: 'PARELMOERGRIJS MAT FIJNSTRUCTUUR',
      productCrossreferentie: '581ME7048A1F',
    ),
    AliplastKleur(
      product: '7PRIME',
      productOmschrijving: 'EPOXY PRIMER',
      productCrossreferentie: 'AL072F',
    ),
    AliplastKleur(
      product: '7PRIMR',
      productOmschrijving: 'RAL7035 LICHTGRIJS',
      productCrossreferentie: 'AL113D INTERPON 100 EPOXY',
    ),
    AliplastKleur(
      product: '7SM30T',
      productOmschrijving: 'FIJNSTRUCTUUR METALL. MAT',
      productCrossreferentie: '029/71720',
    ),
    AliplastKleur(
      product: '7SM39T',
      productOmschrijving: 'FIJNSTRUCT.METALL.MAT',
      productCrossreferentie: '029/71721',
    ),
    AliplastKleur(
      product: '7ST39T',
      productOmschrijving: 'QUARTZGRIJS STRUCTUUR',
      productCrossreferentie: '029/71716',
    ),
    AliplastKleur(
      product: '8000',
      productOmschrijving: 'GRUNBRAUN SATIJN',
      productCrossreferentie: 'AE70018800020',
    ),
    AliplastKleur(
      product: '8000M',
      productOmschrijving: 'GRUNBRAUN MAT',
      productCrossreferentie: 'AE30018800020T',
    ),
    AliplastKleur(
      product: '8001',
      productOmschrijving: 'OCKERBRAUN SATIJN',
      productCrossreferentie: 'AE70018120225',
    ),
    AliplastKleur(
      product: '8001M',
      productOmschrijving: 'OCKERBRAUN MAT',
      productCrossreferentie: 'AE300C8800120',
    ),
    AliplastKleur(
      product: '8002',
      productOmschrijving: 'SIGNALBRAUN SATIJN',
      productCrossreferentie: 'AE70018210825',
    ),
    AliplastKleur(
      product: '8002LC',
      productOmschrijving: 'ROOD',
      productCrossreferentie: '029/63586',
    ),
    AliplastKleur(
      product: '8002M',
      productOmschrijving: 'SIGNALBRAUN MAT',
      productCrossreferentie: 'AE30018800220',
    ),
    AliplastKleur(
      product: '8003',
      productOmschrijving: 'LEHMBRAUN SATIJN',
      productCrossreferentie: 'AE70018100325',
    ),
    AliplastKleur(
      product: '8003LC',
      productOmschrijving: 'LEEMBRUIN FIJNSTRUCTUUR MAT',
      productCrossreferentie: '029/60898',
    ),
    AliplastKleur(
      product: '8003M',
      productOmschrijving: 'LEHMBRAUN MAT',
      productCrossreferentie: 'AE30018800320',
    ),
    AliplastKleur(
      product: '8004',
      productOmschrijving: 'KUPFERBRAUN SATIJN',
      productCrossreferentie: 'PE50/TR8004HR/73/180',
    ),
    AliplastKleur(
      product: '8004M',
      productOmschrijving: 'KUPFERBRAUN MAT',
      productCrossreferentie: 'AE30018800420',
    ),
    AliplastKleur(
      product: '8007',
      productOmschrijving: 'REHBRAUN SATIJN',
      productCrossreferentie: 'AE70018300125',
    ),
    AliplastKleur(
      product: '8007M',
      productOmschrijving: 'REHBRAUN MAT',
      productCrossreferentie: 'AE30018800720',
    ),
    AliplastKleur(
      product: '8008',
      productOmschrijving: 'OLIVBRAUN SATIJN',
      productCrossreferentie: 'AE70018220125',
    ),
    AliplastKleur(
      product: '8008M',
      productOmschrijving: 'OLIVBRAUN MAT',
      productCrossreferentie: 'AE30018800820',
    ),
    AliplastKleur(
      product: '8009ST',
      productOmschrijving: 'BRUIN METALLIC STRUCTUUR',
      productCrossreferentie: '029/60731',
    ),
    AliplastKleur(
      product: '800-NT',
      productOmschrijving: 'LICHT BRUIN',
      productCrossreferentie: 'VDL1E0005 - BRONZE GLENCOE',
    ),
    AliplastKleur(
      product: '8011',
      productOmschrijving: 'NUSSBRAUN SATIJN',
      productCrossreferentie: 'AE70018510125',
    ),
    AliplastKleur(
      product: '8011LC',
      productOmschrijving: 'NOTENBRUIN FIJNSTRUCTUUR',
      productCrossreferentie: '029/61344',
    ),
    AliplastKleur(
      product: '8011M',
      productOmschrijving: 'NUSSBRAUN MAT',
      productCrossreferentie: 'AE30018801120',
    ),
    AliplastKleur(
      product: '8012',
      productOmschrijving: 'ROTBRAUN SATIJN',
      productCrossreferentie: 'AE70018801220',
    ),
    AliplastKleur(
      product: '8012LC',
      productOmschrijving: 'ROOD BRUIN FIJN STRUCTUUR MAT',
      productCrossreferentie: '029/61340',
    ),
    AliplastKleur(
      product: '8012M',
      productOmschrijving: 'ROTBRAUN MAT',
      productCrossreferentie: 'AE30018801220',
    ),
    AliplastKleur(
      product: '8014',
      productOmschrijving: 'SEPIABRAUN SATIJN',
      productCrossreferentie: 'AE70018720125',
    ),
    AliplastKleur(
      product: '8014LC',
      productOmschrijving: 'MAT STRUCTUUR',
      productCrossreferentie: '029/60488',
    ),
    AliplastKleur(
      product: '8014M',
      productOmschrijving: 'SEPIABRAUN MAT',
      productCrossreferentie: 'SM814G SEPHIA BROWN',
    ),
    AliplastKleur(
      product: '8014ST',
      productOmschrijving: 'SEPIABRUIN METALLIC STRUCTUUR',
      productCrossreferentie: '029/60740',
    ),
    AliplastKleur(
      product: '8015',
      productOmschrijving: 'KASTANIENBRAUN SATIJN',
      productCrossreferentie: 'AE70018710325',
    ),
    AliplastKleur(
      product: '8015M',
      productOmschrijving: 'KASTANIENBRAUN MAT',
      productCrossreferentie: 'AE30018801520',
    ),
    AliplastKleur(
      product: '8016',
      productOmschrijving: 'MAHAGONIBRAUN SATIJN',
      productCrossreferentie: 'PE50/TR8016HR/73/180',
    ),
    AliplastKleur(
      product: '8016LC',
      productOmschrijving: 'DONKER BRUIN',
      productCrossreferentie: '029/61311 GLANSGRAAD +/-5%',
    ),
    AliplastKleur(
      product: '8016M',
      productOmschrijving: 'MAHAGONIBRAUN MAT',
      productCrossreferentie: 'AE300C8801620',
    ),
    AliplastKleur(
      product: '8017',
      productOmschrijving: 'SCHOKOLADENBRAUN SATIJN',
      productCrossreferentie: 'PE50/TR8017HR/73/180',
    ),
    AliplastKleur(
      product: '8017LC',
      productOmschrijving: 'CHOCOLADEBR. MAT FIJNSTRUCTUUR',
      productCrossreferentie: '029/61333',
    ),
    AliplastKleur(
      product: '8017M',
      productOmschrijving: 'SCHOKOLADENBRAUN MAT',
      productCrossreferentie: 'AE300C8801720',
    ),
    AliplastKleur(
      product: '8019',
      productOmschrijving: 'GRAUBRAUN SATIJN',
      productCrossreferentie: 'AE70018879925 GLANSGRAAD 70%',
    ),
    AliplastKleur(
      product: '8019M',
      productOmschrijving: 'GRAUBRAUN MAT',
      productCrossreferentie: 'AE300C8801920',
    ),
    AliplastKleur(
      product: '8019MT',
      productOmschrijving: 'GRIJSBRUIN MAT',
      productCrossreferentie: '068/60350',
    ),
    AliplastKleur(
      product: '8019OX',
      productOmschrijving: 'GRIJSBRUIN HOOGGLANS',
      productCrossreferentie: 'DS311M8220',
    ),
    AliplastKleur(
      product: '8019ST',
      productOmschrijving: 'GRIJSBRUIN METALLIC STRUCTUUR',
      productCrossreferentie: '029/60674',
    ),
    AliplastKleur(
      product: '8019T',
      productOmschrijving: 'GRIJSBRUIN SATIJN',
      productCrossreferentie: '068/60092',
    ),
    AliplastKleur(
      product: '8019TC',
      productOmschrijving: 'MARONE 05 MAT FIJNST.KLASSE II',
      productCrossreferentie: '068/71752',
    ),
    AliplastKleur(
      product: '8019X',
      productOmschrijving: 'RAL 8019',
      productCrossreferentie: 'AE70018801920',
    ),
    AliplastKleur(
      product: '801-NT',
      productOmschrijving: 'BRUIN',
      productCrossreferentie: 'VDL1E0015 - DARK BRONZE',
    ),
    AliplastKleur(
      product: '8022',
      productOmschrijving: 'SCHWARZBRAUN SATIJN',
      productCrossreferentie: 'PE050/TR8022HR/73/180',
    ),
    AliplastKleur(
      product: '8022LC',
      productOmschrijving: 'ZWART BRUIN MAT STRUCTUUR',
      productCrossreferentie: '029/60861',
    ),
    AliplastKleur(
      product: '8022M',
      productOmschrijving: 'SCHWARZBRAUN MAT',
      productCrossreferentie: 'AE30018802220',
    ),
    AliplastKleur(
      product: '8022X',
      productOmschrijving: 'RAL8022 BLACK BROWN',
      productCrossreferentie: 'AE70014910125',
    ),
    AliplastKleur(
      product: '8023',
      productOmschrijving: 'ORANGEBRAUN SATIJN',
      productCrossreferentie: 'AE70018140625',
    ),
    AliplastKleur(
      product: '8023M',
      productOmschrijving: 'ORANGEBRAUN MAT',
      productCrossreferentie: 'AE30018802320',
    ),
    AliplastKleur(
      product: '8024',
      productOmschrijving: 'BEIGEBRAUN SATIJN',
      productCrossreferentie: 'AE70018100425',
    ),
    AliplastKleur(
      product: '8024M',
      productOmschrijving: 'BEIGEBRAUN MAT',
      productCrossreferentie: 'AE30018802420',
    ),
    AliplastKleur(
      product: '8025',
      productOmschrijving: 'BLASSBRAUN SATIJN',
      productCrossreferentie: 'AE70018802520',
    ),
    AliplastKleur(
      product: '8025LC',
      productOmschrijving: 'PALE BROWN',
      productCrossreferentie: 'AE03058802520',
    ),
    AliplastKleur(
      product: '8025M',
      productOmschrijving: 'BLEEKBRUIN MAT',
      productCrossreferentie: 'AE30018802520',
    ),
    AliplastKleur(
      product: '8027',
      productOmschrijving: 'BRUIN',
      productCrossreferentie: 'AE70018500125',
    ),
    AliplastKleur(
      product: '8027M',
      productOmschrijving: 'LEDERBRUIN',
      productCrossreferentie: 'AE30018500125',
    ),
    AliplastKleur(
      product: '8028',
      productOmschrijving: 'TERRABRAUN SATIJN',
      productCrossreferentie: 'AE70018620125',
    ),
    AliplastKleur(
      product: '8028M',
      productOmschrijving: 'TERRABRAUN MAT',
      productCrossreferentie: 'AE30018802820',
    ),
    AliplastKleur(
      product: '8029',
      productOmschrijving: 'PEARL COPPER',
      productCrossreferentie: 'AE80318010625',
    ),
    AliplastKleur(
      product: '802-NT',
      productOmschrijving: 'DONKER BRUIN',
      productCrossreferentie: 'VDL1E0012 - BRONZE BAGANA',
    ),
    AliplastKleur(
      product: '803-NT',
      productOmschrijving: 'ORANJE BRUIN',
      productCrossreferentie: 'VDL1E0013 - ANCIENT BRASS',
    ),
    AliplastKleur(
      product: '8077M',
      productOmschrijving: 'BRUIN METALLIC MAT',
      productCrossreferentie: 'RM262D',
    ),
    AliplastKleur(
      product: '819BRX',
      productOmschrijving: 'GREY BROWN',
      productCrossreferentie: 'AE70058805822',
    ),
    AliplastKleur(
      product: '8BRMET',
      productOmschrijving: 'BRUN METAL 2',
      productCrossreferentie: 'METAL 2',
    ),
    AliplastKleur(
      product: '8C04AN',
      productOmschrijving: 'GOUD ANODISATIE - METALLIC',
      productCrossreferentie: '029/90249',
    ),
    AliplastKleur(
      product: '8C31AN',
      productOmschrijving: 'MAT ZEER LICHT BRONS',
      productCrossreferentie: '029/90434',
    ),
    AliplastKleur(
      product: '8C32AN',
      productOmschrijving: 'LICHT BRONS C32',
      productCrossreferentie: '029/15400',
    ),
    AliplastKleur(
      product: '8C33AN',
      productOmschrijving: 'MIDDEL BRONS C33',
      productCrossreferentie: '029/65680',
    ),
    AliplastKleur(
      product: '8C33TI',
      productOmschrijving: 'DEORE 617 GLAD METALLIC MAT',
      productCrossreferentie: '068/60614',
    ),
    AliplastKleur(
      product: '8C34AN',
      productOmschrijving: 'BRUIN BRONS C334',
      productCrossreferentie: '029/65650',
    ),
    AliplastKleur(
      product: '8LAC36',
      productOmschrijving: 'BRONS ANODISATIE',
      productCrossreferentie: 'AE20108000320',
    ),
    AliplastKleur(
      product: '8LAC37',
      productOmschrijving: 'BRUIN ANODISATIE',
      productCrossreferentie: 'AE20108000420',
    ),
    AliplastKleur(
      product: '8M14X',
      productOmschrijving: 'SEPIABRUIN MAT',
      productCrossreferentie: 'AE30018801420',
    ),
    AliplastKleur(
      product: '8MM53X',
      productOmschrijving: 'RUSSET SCARAB',
      productCrossreferentie: 'SD201C3153320',
    ),
    AliplastKleur(
      product: '8MS04X',
      productOmschrijving: 'AE FINE TEXTURE RAL 8004 COPPER BROWN',
      productCrossreferentie: 'AE03058800420',
    ),
    AliplastKleur(
      product: '8MS08X',
      productOmschrijving: 'AE FINE TEXTURE RAL 8008 OLIVE BROWN',
      productCrossreferentie: 'AE03058800820',
    ),
    AliplastKleur(
      product: '8MS11X',
      productOmschrijving: 'NOTENBRUIN MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03058801120',
    ),
    AliplastKleur(
      product: '8MS14X',
      productOmschrijving: 'SEPIABRUIN MAT STRUCTUUR',
      productCrossreferentie: 'AE03058801420',
    ),
    AliplastKleur(
      product: '8MS15X',
      productOmschrijving: 'KASTANJEBRUIN MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03058801520',
    ),
    AliplastKleur(
      product: '8MS19A',
      productOmschrijving: 'GRIJSBRUIN MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'YM319F',
    ),
    AliplastKleur(
      product: '8MS19D',
      productOmschrijving: 'GRIJSBRUIN FIJNSTRUCTUUR 8019',
      productCrossreferentie: 'AE03058801920',
    ),
    AliplastKleur(
      product: '8MS19T',
      productOmschrijving: 'GRIJSBRUIN FIJNSTRUCTUUR MAT',
      productCrossreferentie: '029/60735',
    ),
    AliplastKleur(
      product: '8MS21X',
      productOmschrijving: 'CITY TERRACOTTA',
      productCrossreferentie: 'SD031C8021020',
    ),
    AliplastKleur(
      product: '8MS22X',
      productOmschrijving: 'BLACK BROWN MAT STRUCTUUR',
      productCrossreferentie: 'AE03058802220',
    ),
    AliplastKleur(
      product: '8MS23X',
      productOmschrijving: 'TIMELESS RUST STIPPELPOEDER',
      productCrossreferentie: 'SD034C8023020',
    ),
    AliplastKleur(
      product: '8MS24X',
      productOmschrijving: 'BEIGEBRUIN',
      productCrossreferentie: 'AE03058802420',
    ),
    AliplastKleur(
      product: '8MS25T',
      productOmschrijving: 'TAUPE MAT FIJNSTRUCTUUR',
      productCrossreferentie: '029/61692',
    ),
    AliplastKleur(
      product: '8MS28X',
      productOmschrijving: 'TERRA-BRUIN MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03058802820',
    ),
    AliplastKleur(
      product: '8MS78X',
      productOmschrijving: 'SD FINE TEXTURE POLAR DUST',
      productCrossreferentie: 'SD03078701020',
    ),
    AliplastKleur(
      product: '8MSQ2X',
      productOmschrijving: 'BRUINGRIJS',
      productCrossreferentie: 'AE03411122920',
    ),
    AliplastKleur(
      product: '8SD37X',
      productOmschrijving: 'SUPER ANODIC BROWN',
      productCrossreferentie: 'SD201C8000420',
    ),
    AliplastKleur(
      product: '8SM01X',
      productOmschrijving: 'SD FINE TEXTURE GOLD SUPREME',
      productCrossreferentie: 'SD031C1033020',
    ),
    AliplastKleur(
      product: '8SM31X',
      productOmschrijving: 'EARTH CLAY FIJNSTRUCTUUR',
      productCrossreferentie: 'SD031C8005020',
    ),
    AliplastKleur(
      product: '8SM66A',
      productOmschrijving: 'BRUM 2650 SABLE QUALICOAT II',
      productCrossreferentie: 'YW366F',
    ),
    AliplastKleur(
      product: '8SM86T',
      productOmschrijving: 'SUPER DURABLE SPARKLING IRON EFFECT',
      productCrossreferentie: '068/70186',
    ),
    AliplastKleur(
      product: '9001',
      productOmschrijving: 'HOLLANDS WIT',
      productCrossreferentie: 'SD666F',
    ),
    AliplastKleur(
      product: '9001HX',
      productOmschrijving: 'IVOOR HOOGGLANS',
      productCrossreferentie: 'AE80019900120',
    ),
    AliplastKleur(
      product: '9001I',
      productOmschrijving: 'HOLLANDS WIT',
      productCrossreferentie: '5807A90010',
    ),
    AliplastKleur(
      product: '9001M',
      productOmschrijving: 'CREMEWEISS MAT',
      productCrossreferentie: 'AE300C9900120',
    ),
    AliplastKleur(
      product: '9001MT',
      productOmschrijving: 'CREMEWIT MAT',
      productCrossreferentie: '23250.90.',
    ),
    AliplastKleur(
      product: '9001PX',
      productOmschrijving: 'IVOOR PROFEL U9001',
      productCrossreferentie: 'AE60009145727',
    ),
    AliplastKleur(
      product: '9001SX',
      productOmschrijving: 'CREAM',
      productCrossreferentie: 'AE70019220225',
    ),
    AliplastKleur(
      product: '9001T',
      productOmschrijving: 'HOLLANDS WIT',
      productCrossreferentie: '30652.90 PE/P/HD',
    ),
    AliplastKleur(
      product: '9001TC',
      productOmschrijving: 'RAL1013 MAT FIJNSTR.KLASSE II',
      productCrossreferentie: '068/15115',
    ),
    AliplastKleur(
      product: '9002',
      productOmschrijving: 'GRIJS WIT',
      productCrossreferentie: 'AE70019570225',
    ),
    AliplastKleur(
      product: '9002M',
      productOmschrijving: 'GRAUWEISS MAT',
      productCrossreferentie: 'AE300C9900220',
    ),
    AliplastKleur(
      product: '9002TC',
      productOmschrijving: 'RAL9002 MAT FIJNSTR.KLASSE II',
      productCrossreferentie: '068/10423',
    ),
    AliplastKleur(
      product: '9003',
      productOmschrijving: 'SIGNALWEISS SATIJN',
      productCrossreferentie: 'AE70019171025',
    ),
    AliplastKleur(
      product: '9003LC',
      productOmschrijving: '9003 FIJNSTRUCTUUR MAT',
      productCrossreferentie: '029/11468',
    ),
    AliplastKleur(
      product: '9003M',
      productOmschrijving: 'SIGNALWEISS MAT',
      productCrossreferentie: 'AE300C9900320',
    ),
    AliplastKleur(
      product: '9003OX',
      productOmschrijving: 'SIGNAALWIT',
      productCrossreferentie: 'PE50/TR9003HR/73/180',
    ),
    AliplastKleur(
      product: '9004',
      productOmschrijving: 'SIGNALSCHWARZ SATIJN',
      productCrossreferentie: 'AE70014902425',
    ),
    AliplastKleur(
      product: '9004M',
      productOmschrijving: 'SIGNALSCHWARZ MAT',
      productCrossreferentie: 'SN201E',
    ),
    AliplastKleur(
      product: '9004TC',
      productOmschrijving: 'RAL9004 MAT FIJNSTR.KLASSE II',
      productCrossreferentie: '068/80057',
    ),
    AliplastKleur(
      product: '9005',
      productOmschrijving: 'TIEFSCHWARZ SATIJN',
      productCrossreferentie: 'AE70014900520',
    ),
    AliplastKleur(
      product: '9005AC',
      productOmschrijving: 'ZWART',
      productCrossreferentie: 'AQ70024900520',
    ),
    AliplastKleur(
      product: '9005M',
      productOmschrijving: 'TIEFSCHWARZ MAT',
      productCrossreferentie: 'AE30014900520',
    ),
    AliplastKleur(
      product: '9005MT',
      productOmschrijving: 'DIEPZWART MAT',
      productCrossreferentie: '068/80037',
    ),
    AliplastKleur(
      product: '9005ST',
      productOmschrijving: 'DIEPZWART METALLIC STRUCTUUR',
      productCrossreferentie: '029/80081',
    ),
    AliplastKleur(
      product: '9005T',
      productOmschrijving: 'GITZWART SATIJN',
      productCrossreferentie: '068/80036',
    ),
    AliplastKleur(
      product: '9006',
      productOmschrijving: 'WEISSALUMINIUM SATIJN',
      productCrossreferentie: '029/90080',
    ),
    AliplastKleur(
      product: '9006A',
      productOmschrijving: 'ALU METALLIC GLOSS',
      productCrossreferentie: 'SW006JR',
    ),
    AliplastKleur(
      product: '9006LC',
      productOmschrijving: 'FIJNSTRUCTUUR SPRENKEL',
      productCrossreferentie: '029/71724',
    ),
    AliplastKleur(
      product: '9006MD',
      productOmschrijving: 'ALUMINIUM KLEUR METALLIC',
      productCrossreferentie: 'AE30217900620',
    ),
    AliplastKleur(
      product: '9006MT',
      productOmschrijving: 'WIT ALUMINIUM SATIJN MAT',
      productCrossreferentie: '068/90006',
    ),
    AliplastKleur(
      product: '9006ST',
      productOmschrijving: 'WITALUNIUM STRUCTUUR',
      productCrossreferentie: '029/90146',
    ),
    AliplastKleur(
      product: '9006T',
      productOmschrijving: 'WITALUMINIUM SATIJN',
      productCrossreferentie: 'QS912055SG',
    ),
    AliplastKleur(
      product: '9006TI',
      productOmschrijving: 'WIT-ALUMINIUM ZIJDEGL.METALLIC',
      productCrossreferentie: '029/90024',
    ),
    AliplastKleur(
      product: '9007',
      productOmschrijving: 'GRAUALUMINIUM SATIJN',
      productCrossreferentie: '029/90155',
    ),
    AliplastKleur(
      product: '9007LC',
      productOmschrijving: 'MAT STRUCTUUR SPRENKEL',
      productCrossreferentie: '029/72004',
    ),
    AliplastKleur(
      product: '9007MI',
      productOmschrijving: 'DONKER ALUMINIUM MAT METALLIC',
      productCrossreferentie: '5603E90070A10',
    ),
    AliplastKleur(
      product: '9007MT',
      productOmschrijving: 'GRIJSALUMINIUM MAT',
      productCrossreferentie: '068/90007',
    ),
    AliplastKleur(
      product: '9007ST',
      productOmschrijving: 'GRIJSALUMINIUM STRUCTUUR',
      productCrossreferentie: '029/90147',
    ),
    AliplastKleur(
      product: '9007T',
      productOmschrijving: 'GRIJSALUMINIUM SATIJN',
      productCrossreferentie: '43615',
    ),
    AliplastKleur(
      product: '9007TI',
      productOmschrijving: 'RAL 9007 GLAD GLANZEND',
      productCrossreferentie: '029/91560',
    ),
    AliplastKleur(
      product: '9008ST',
      productOmschrijving: 'BRUINGRIJS METALLIC STRUCTUUR',
      productCrossreferentie: '029/70786',
    ),
    AliplastKleur(
      product: '9009ST',
      productOmschrijving: 'DONKERGRIJS METALLIC STRUCTUUR',
      productCrossreferentie: '029/80077',
    ),
    AliplastKleur(
      product: '900-PT',
      productOmschrijving: 'PURE TEXTURE WHITE',
      productCrossreferentie: 'RWMXD-0634',
    ),
    AliplastKleur(
      product: '9010',
      productOmschrijving: 'BELGISCH WIT',
      productCrossreferentie: 'AE90019148021',
    ),
    AliplastKleur(
      product: '9010I',
      productOmschrijving: 'RAL9010 VSR901',
      productCrossreferentie: '5807A90100S70',
    ),
    AliplastKleur(
      product: '9010M',
      productOmschrijving: 'REINWEISS MAT',
      productCrossreferentie: 'SA880F',
    ),
    AliplastKleur(
      product: '9010MT',
      productOmschrijving: 'REINWIT MAT',
      productCrossreferentie: '23260.90 PE/P/HDM',
    ),
    AliplastKleur(
      product: '9010PS',
      productOmschrijving: 'BLANC',
      productCrossreferentie: 'AE80019107921',
    ),
    AliplastKleur(
      product: '9010PX',
      productOmschrijving: 'WIT 9010 PROFEL KLEUR V9010',
      productCrossreferentie: 'AE80009145927',
    ),
    AliplastKleur(
      product: '9010RT',
      productOmschrijving: 'ZUIVER WIT',
      productCrossreferentie: '068/10066',
    ),
    AliplastKleur(
      product: '9010T',
      productOmschrijving: '+/-85% GLANS BELGISCH WIT',
      productCrossreferentie: 'QS111798G',
    ),
    AliplastKleur(
      product: '9010TC',
      productOmschrijving: 'RAL9010 MAT FIJNSTR.KLASSE II',
      productCrossreferentie: '068/10259',
    ),
    AliplastKleur(
      product: '9011',
      productOmschrijving: 'GRAPHITSCHWARZ SATIJN',
      productCrossreferentie: 'AE70014960125',
    ),
    AliplastKleur(
      product: '9011M',
      productOmschrijving: 'GRAPHITSCHWARZ MAT',
      productCrossreferentie: 'AE30014901120',
    ),
    AliplastKleur(
      product: '9011TC',
      productOmschrijving: 'GRAFIETZWART MAT FIJNSTRUCTUIUR',
      productCrossreferentie: '068/80296',
    ),
    AliplastKleur(
      product: '9016',
      productOmschrijving: 'VERKEHRSWEISS SATIJN',
      productCrossreferentie: 'AE70019101525',
    ),
    AliplastKleur(
      product: '9016I',
      productOmschrijving: 'RAL9016',
      productCrossreferentie: '5807A90160S70-K20',
    ),
    AliplastKleur(
      product: '9016M',
      productOmschrijving: 'VERKEHRSWEISS MAT',
      productCrossreferentie: 'AE300C9901620',
    ),
    AliplastKleur(
      product: '9016MT',
      productOmschrijving: 'VERKEERSWIT MAT',
      productCrossreferentie: '068/10078',
    ),
    AliplastKleur(
      product: '9016T',
      productOmschrijving: 'VERKEERSWIT SATIJN',
      productCrossreferentie: '068/10067',
    ),
    AliplastKleur(
      product: '9016TC',
      productOmschrijving: 'RAL9016 MAT FIJNSTR.KLASSE II',
      productCrossreferentie: '068/10079',
    ),
    AliplastKleur(
      product: '9016TI',
      productOmschrijving: 'TIGER WEINOR DIE MARK',
      productCrossreferentie: '029/10950',
    ),
    AliplastKleur(
      product: '9017',
      productOmschrijving: 'VERKEHRSSCHWARZ SATIJN',
      productCrossreferentie: 'AE70014900725',
    ),
    AliplastKleur(
      product: '9017LC',
      productOmschrijving: 'VERKEERSZWART',
      productCrossreferentie: '029/88001',
    ),
    AliplastKleur(
      product: '9017M',
      productOmschrijving: 'VERKEHRSSCHWARZ MAT',
      productCrossreferentie: 'AE300C4901720',
    ),
    AliplastKleur(
      product: '9018',
      productOmschrijving: 'PAPYRUSWEISS SATIJN',
      productCrossreferentie: 'PE50/TR9018/73/180',
    ),
    AliplastKleur(
      product: '9018M',
      productOmschrijving: 'PAPYRUSWEISS MAT',
      productCrossreferentie: 'AE30019901820',
    ),
    AliplastKleur(
      product: '901-TC',
      productOmschrijving: 'RAL9001 MAT FIJNSTR.KLASSE II',
      productCrossreferentie: '068/10426',
    ),
    AliplastKleur(
      product: '9021',
      productOmschrijving: 'ZWARTGRIJS',
      productCrossreferentie: 'AE70014980325',
    ),
    AliplastKleur(
      product: '9022',
      productOmschrijving: 'PARELLICHTGRIJS',
      productCrossreferentie: 'AE80317005525',
    ),
    AliplastKleur(
      product: '9022M',
      productOmschrijving: 'PARELMOER LICHTGRIJS METALLIC',
      productCrossreferentie: 'AE20317087421',
    ),
    AliplastKleur(
      product: '9023',
      productOmschrijving: 'PARELDONKERGRIJS',
      productCrossreferentie: 'AE80317004925',
    ),
    AliplastKleur(
      product: '9023M',
      productOmschrijving: 'PARELDONKERGRIJS MAT',
      productCrossreferentie: 'AE20317087521',
    ),
    AliplastKleur(
      product: '905MSA',
      productOmschrijving: '9005 MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'SN305G',
    ),
    AliplastKleur(
      product: '905-PM',
      productOmschrijving: 'PURE BLACK',
      productCrossreferentie: 'RNM-0444',
    ),
    AliplastKleur(
      product: '905PRM',
      productOmschrijving: 'PROFEL KLEUR P905RM',
      productCrossreferentie: 'ZX641N8002',
    ),
    AliplastKleur(
      product: '905-PT',
      productOmschrijving: 'PURE TEXTURE BLACK',
      productCrossreferentie: 'RWMXD-0454',
    ),
    AliplastKleur(
      product: '905-TC',
      productOmschrijving: 'RAL9005 MAT FIJNSTR.KLASSE II',
      productCrossreferentie: '068/80456',
    ),
    AliplastKleur(
      product: '9085',
      productOmschrijving: 'WIT',
      productCrossreferentie: 'AE90009198121',
    ),
    AliplastKleur(
      product: '9147DB',
      productOmschrijving: 'MERCEDES ARCTIC WHITE',
      productCrossreferentie: 'IF90019082821',
    ),
    AliplastKleur(
      product: '9194A',
      productOmschrijving: 'WIT',
      productCrossreferentie: 'YA055F',
    ),
    AliplastKleur(
      product: '9910',
      productOmschrijving: 'HIPCA WHITE',
      productCrossreferentie: 'RA080E D1094',
    ),
    AliplastKleur(
      product: '999-TC',
      productOmschrijving: 'CARBON01 MAT FIJNSTR.KLASSE II',
      productCrossreferentie: '068/80381',
    ),
    AliplastKleur(
      product: '9AL70D',
      productOmschrijving: 'HOLLANDS WIT',
      productCrossreferentie: 'AE70019900120',
    ),
    AliplastKleur(
      product: '9C00AN',
      productOmschrijving: 'ALUMINIUM ANOD MAT METALLIC',
      productCrossreferentie: '029/91089',
    ),
    AliplastKleur(
      product: '9C01AN',
      productOmschrijving: 'NATUUR ANODISATIE',
      productCrossreferentie: 'AE20107000120',
    ),
    AliplastKleur(
      product: '9C0XAN',
      productOmschrijving: 'ALUMINIUM ANOD ZILVER METALLIC',
      productCrossreferentie: '029/90003',
    ),
    AliplastKleur(
      product: '9CTX1X',
      productOmschrijving: 'CREMEWIT STRUCTUUR',
      productCrossreferentie: 'AE03059900120',
    ),
    AliplastKleur(
      product: '9D10M',
      productOmschrijving: 'ZUIVER WIT',
      productCrossreferentie: 'AE30019901020',
    ),
    AliplastKleur(
      product: '9H016A',
      productOmschrijving: 'VERKEERSWIT',
      productCrossreferentie: 'SAJ16G QUALICOAT NR P-0143',
    ),
    AliplastKleur(
      product: '9H10G',
      productOmschrijving: 'WIT 9010',
      productCrossreferentie: 'RWB964',
    ),
    AliplastKleur(
      product: '9H16D',
      productOmschrijving: 'VERKEERSWIT HOOGGLANS',
      productCrossreferentie: 'AE80019901620',
    ),
    AliplastKleur(
      product: '9M03X',
      productOmschrijving: 'SIGNAALWIT 9003M',
      productCrossreferentie: 'AE03059900320',
    ),
    AliplastKleur(
      product: '9M04X',
      productOmschrijving: 'SIGNAALZWART MAT',
      productCrossreferentie: 'AE300C4900420',
    ),
    AliplastKleur(
      product: '9M07D',
      productOmschrijving: 'GRIJALUMINIUM',
      productCrossreferentie: 'AE30217900720',
    ),
    AliplastKleur(
      product: '9M10D',
      productOmschrijving: 'ZUIVERWIT',
      productCrossreferentie: 'AE30009002323',
    ),
    AliplastKleur(
      product: '9M10X',
      productOmschrijving: '9010M (DUITSE VERSIE)',
      productCrossreferentie: 'AE30059901022',
    ),
    AliplastKleur(
      product: '9M120X',
      productOmschrijving: 'WITGRIJS',
      productCrossreferentie: 'AE20019173125',
    ),
    AliplastKleur(
      product: '9MM07I',
      productOmschrijving: 'MAT METALLIC',
      productCrossreferentie: '581ME90070A10',
    ),
    AliplastKleur(
      product: '9MM09I',
      productOmschrijving: 'MAT METALLIC',
      productCrossreferentie: '5803E71386A10',
    ),
    AliplastKleur(
      product: '9MM09T',
      productOmschrijving: 'MATMETALLIC DB703HE',
      productCrossreferentie: '029/70271',
    ),
    AliplastKleur(
      product: '9MM09X',
      productOmschrijving: 'DB703 GREY',
      productCrossreferentie: 'AE30107070320',
    ),
    AliplastKleur(
      product: '9MM703',
      productOmschrijving: 'DB703 BU METALLIC MAT',
      productCrossreferentie: '029/70577',
    ),
    AliplastKleur(
      product: '9MM71I',
      productOmschrijving: 'CAST IRON MAT METALLIC',
      productCrossreferentie: '5803E71385A10',
    ),
    AliplastKleur(
      product: '9MM73T',
      productOmschrijving: 'DB703 GRIJS METALLIC',
      productCrossreferentie: '029/82030',
    ),
    AliplastKleur(
      product: '9MM84S',
      productOmschrijving: 'WHITE ONEGA',
      productCrossreferentie: '30884',
    ),
    AliplastKleur(
      product: '9MS04X',
      productOmschrijving: 'SIGNAALZWART',
      productCrossreferentie: 'AE03054900420',
    ),
    AliplastKleur(
      product: '9MS05T',
      productOmschrijving: '9005 MAT STRUCTUUR',
      productCrossreferentie: '029/80303',
    ),
    AliplastKleur(
      product: '9MS05X',
      productOmschrijving: 'JET BLACK STRUCTUUR RAL9005',
      productCrossreferentie: 'SD030C4900520',
    ),
    AliplastKleur(
      product: '9MS10A',
      productOmschrijving: '9010 MAT STRUCTUUR',
      productCrossreferentie: 'AE03059901020',
    ),
    AliplastKleur(
      product: '9MS10G',
      productOmschrijving: 'MAT WIT STRUCTUUR',
      productCrossreferentie: 'RWMX-0633',
    ),
    AliplastKleur(
      product: '9MS10T',
      productOmschrijving: 'RAL 9010 FIJNSTRUCTUUR MAT',
      productCrossreferentie: '029/10674',
    ),
    AliplastKleur(
      product: '9MS11X',
      productOmschrijving: '9011 MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03054901120',
    ),
    AliplastKleur(
      product: '9MS16D',
      productOmschrijving: 'VERKEERSWIT MAT STRUCTUUR',
      productCrossreferentie: 'AE03059901620',
    ),
    AliplastKleur(
      product: '9MS17X',
      productOmschrijving: 'VERKEERSZWART MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03054901720',
    ),
    AliplastKleur(
      product: '9MS18X',
      productOmschrijving: 'PAPYRUS WIT MAT FIJNSTRUCTUUR',
      productCrossreferentie: 'AE03059901820',
    ),
    AliplastKleur(
      product: '9MS20A',
      productOmschrijving: 'NOIR 200 SABLE',
      productCrossreferentie: 'SW306G',
    ),
    AliplastKleur(
      product: '9MS5TC',
      productOmschrijving: 'RAL9005 DIEPZWART MAT FIJNSTRUCTUUR',
      productCrossreferentie: '068/80241',
    ),
    AliplastKleur(
      product: '9S006A',
      productOmschrijving: 'WIT ALUMINIUM',
      productCrossreferentie: 'SW101F',
    ),
    AliplastKleur(
      product: '9S007',
      productOmschrijving: 'METALLIC ZIJDEGLANZEND',
      productCrossreferentie: '029/90035',
    ),
    AliplastKleur(
      product: '9S06X',
      productOmschrijving: '+/- RAL 9006 BG200 DRY BLEND METALLIC',
      productCrossreferentie: 'AXALTA AE70207294021',
    ),
    AliplastKleur(
      product: '9S07I',
      productOmschrijving: 'GRIJS ALUMINIUMKLEURIG',
      productCrossreferentie: '5807E90073S10',
    ),
    AliplastKleur(
      product: '9S10T',
      productOmschrijving: 'RAL 9010 ZIJDEGLANS',
      productCrossreferentie: '014/10025',
    ),
    AliplastKleur(
      product: '9S16SX',
      productOmschrijving: 'WIT',
      productCrossreferentie: 'AE70059941622',
    ),
    AliplastKleur(
      product: '9S16TI',
      productOmschrijving: 'VERKEERSWIT',
      productCrossreferentie: '014/10024',
    ),
    AliplastKleur(
      product: '9SA10D',
      productOmschrijving: 'ZUIVERWIT',
      productCrossreferentie: 'AE70019901020',
    ),
    AliplastKleur(
      product: '9SM05X',
      productOmschrijving: 'ZWART FIJNSTRUCTUUR GEBONDERDE METALLIC',
      productCrossreferentie: 'SD031C4900520',
    ),
    AliplastKleur(
      product: '9SM06D',
      productOmschrijving: '9006 FIJNSTRUCTUUR WIT ALUMIN.',
      productCrossreferentie: 'AE03257900620',
    ),
    AliplastKleur(
      product: '9SM06T',
      productOmschrijving: 'ZILVER MAT STRUCTUUR',
      productCrossreferentie: '068/90055',
    ),
    AliplastKleur(
      product: '9SM07T',
      productOmschrijving: 'GRIJS ALUMINIUM',
      productCrossreferentie: '068/90054',
    ),
    AliplastKleur(
      product: '9SM09I',
      productOmschrijving: 'DONKER GRIJS METALLIC FIJNSTRUCTUUR',
      productCrossreferentie: '71386A10581ME',
    ),
    AliplastKleur(
      product: '9SM36A',
      productOmschrijving: 'ZWART/GRIJS METALLIC STRUCTUUR',
      productCrossreferentie: 'YW360F',
    ),
    AliplastKleur(
      product: '9SM88T',
      productOmschrijving: 'GRIJS METALLIC STRUCTUUR',
      productCrossreferentie: '029/70785',
    ),
    AliplastKleur(
      product: '9ST03A',
      productOmschrijving: 'ZWART STRUCTUUR SABLE',
      productCrossreferentie: 'SW303G NOIR 100 SABLE',
    ),
    AliplastKleur(
      product: '9ST05D',
      productOmschrijving: 'DIEPZWART STRUCTUUR',
      productCrossreferentie: 'AE03054900520',
    ),
    AliplastKleur(
      product: '9ST05O',
      productOmschrijving: 'ZWART +/-5%',
      productCrossreferentie: 'PE50/TR9907/5/180/ST',
    ),
    AliplastKleur(
      product: '9ST07D',
      productOmschrijving: 'COATEX BARITON 2',
      productCrossreferentie: 'AE03257900720',
    ),
    AliplastKleur(
      product: '9ST07T',
      productOmschrijving: 'STRUCTUUR SPRENKEL 9007',
      productCrossreferentie: '029/71725',
    ),
    AliplastKleur(
      product: '9ST08D',
      productOmschrijving: 'BRUINGRIJS METALLIC STRUCTUUR',
      productCrossreferentie: 'AE03257900820',
    ),
    AliplastKleur(
      product: '9ST33A',
      productOmschrijving: 'INTERPON D1036 NOIR 100 SABLE',
      productCrossreferentie: 'SW303G',
    ),
    AliplastKleur(
      product: '9ST900',
      productOmschrijving: 'GRIS 900 SABLE',
      productCrossreferentie: 'SW302G',
    ),
    AliplastKleur(
      product: 'IC334',
      productOmschrijving: 'WIT IC334',
      productCrossreferentie: 'SC005E',
    ),
    AliplastKleur(
      product: 'RUSTTC',
      productOmschrijving: 'CORTEN STAAL FIJNSTR. METALLIC MAT',
      productCrossreferentie: '068/60116',
    ),
  ];

  static final List<String> keuzeWaarden = List<String>.unmodifiable(
    alle.map((kleur) => kleur.samenvatting),
  );

  static List<AliplastKleur> zoek(String zoekterm) {
    final zoek = zoekterm.trim().toLowerCase();
    if (zoek.isEmpty) return alle;
    return alle.where((kleur) => kleur.zoekTekst.contains(zoek)).toList();
  }
}
