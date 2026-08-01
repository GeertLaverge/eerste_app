// THIMACO-CONTROLE: UITVALSCHERM-POEDERKLEUREN-20260801
class OpmetingUitvalschermKleur {
  const OpmetingUitvalschermKleur({required this.naam, required this.code});

  final String naam;
  final String code;

  String get id => '${naam.trim().toLowerCase()}|${code.trim().toLowerCase()}';
  String get label =>
      code.trim().isEmpty ? naam.trim() : '${naam.trim()} · ${code.trim()}';

  Map<String, dynamic> toJson() => <String, dynamic>{
    'naam': naam.trim(),
    'code': code.trim(),
  };

  factory OpmetingUitvalschermKleur.fromJson(Map<String, dynamic> json) {
    return OpmetingUitvalschermKleur(
      naam: json['naam']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
    );
  }
}

class OpmetingUitvalschermDoek {
  const OpmetingUitvalschermDoek({
    required this.code,
    required this.kleur,
    required this.hex,
  });

  final String code;
  final String kleur;
  final String hex;

  String get id => code.trim().toUpperCase();
  String get label =>
      kleur.trim().isEmpty ? code.trim() : '${code.trim()} · ${kleur.trim()}';

  Map<String, dynamic> toJson() => <String, dynamic>{
    'code': code.trim().toUpperCase(),
    'kleur': kleur.trim(),
    'hex': normaliseerHex(hex),
  };

  factory OpmetingUitvalschermDoek.fromJson(Map<String, dynamic> json) {
    return OpmetingUitvalschermDoek(
      code: json['code']?.toString() ?? '',
      kleur: json['kleur']?.toString() ?? '',
      hex: normaliseerHex(json['hex']?.toString() ?? '#8C8C8A'),
    );
  }

  static String normaliseerHex(String waarde) {
    final zonder = waarde.trim().replaceFirst('#', '').toUpperCase();
    return RegExp(r'^[0-9A-F]{6}$').hasMatch(zonder) ? '#$zonder' : '#8C8C8A';
  }
}

class OpmetingUitvalschermMotor {
  const OpmetingUitvalschermMotor({
    required this.type,
    required this.merk,
    required this.omschrijving,
  });

  final String type;
  final String merk;
  final String omschrijving;

  String get id => <String>[
    type,
    merk,
    omschrijving,
  ].map((deel) => deel.trim().toLowerCase()).join('|');

  String get label => <String>[
    type,
    merk,
    omschrijving,
  ].map((deel) => deel.trim()).where((deel) => deel.isNotEmpty).join(' · ');

  bool get isDraadloos => type.trim().toLowerCase() == 'draadloos';

  Map<String, dynamic> toJson() => <String, dynamic>{
    'type': type.trim(),
    'merk': merk.trim(),
    'omschrijving': omschrijving.trim(),
  };

  factory OpmetingUitvalschermMotor.fromJson(Map<String, dynamic> json) {
    return OpmetingUitvalschermMotor(
      type: json['type']?.toString() ?? '',
      merk: json['merk']?.toString() ?? '',
      omschrijving: json['omschrijving']?.toString() ?? '',
    );
  }
}

class OpmetingUitvalschermInstellingen {
  const OpmetingUitvalschermInstellingen({
    this.draagstructuurKleuren = standaardDraagstructuurKleuren,
    this.doeken = standaardDoeken,
    this.motoren = standaardMotoren,
    this.bedieningen = standaardBedieningen,
    this.gewijzigdOp = '',
  });

  final List<OpmetingUitvalschermKleur> draagstructuurKleuren;
  final List<OpmetingUitvalschermDoek> doeken;
  final List<OpmetingUitvalschermMotor> motoren;
  final List<String> bedieningen;
  final String gewijzigdOp;

  static const List<OpmetingUitvalschermKleur>
  standaardDraagstructuurKleuren = <OpmetingUitvalschermKleur>[
    OpmetingUitvalschermKleur(
      naam: 'Antracietgrijs Rolluiken',
      code: '317032213',
    ),
    OpmetingUitvalschermKleur(naam: 'Bruin Rolluiken', code: '317032222'),
    OpmetingUitvalschermKleur(naam: 'Bruin Zonwering', code: 'AE80018801920'),
    OpmetingUitvalschermKleur(naam: 'RAL 8012 Deceuninck', code: '8012'),
    OpmetingUitvalschermKleur(naam: 'RAL 8067 Deceuninck', code: '8067'),
    OpmetingUitvalschermKleur(naam: 'RAL 8068 Deceuninck', code: '8068'),
    OpmetingUitvalschermKleur(naam: 'RAL 8909 Deceuninck', code: '8909'),
    OpmetingUitvalschermKleur(naam: 'RAL 8934 Deceuninck', code: '8934'),
    OpmetingUitvalschermKleur(naam: 'RAL 8935 Deceuninck', code: '8935'),
    OpmetingUitvalschermKleur(naam: 'Anodic Natura', code: 'AE20107000120'),
    OpmetingUitvalschermKleur(naam: 'Crème-Wit Rolluiken', code: '317032221'),
    OpmetingUitvalschermKleur(naam: 'Creme-Wit Zonwering', code: 'DS312W8515'),
    OpmetingUitvalschermKleur(
      naam: 'DB 702 IG 29/70588',
      code: 'DB 702 IG 29/70588',
    ),
    OpmetingUitvalschermKleur(
      naam: 'DB 703 Tiger 29/82030',
      code: 'DB 703 029/82030',
    ),
    OpmetingUitvalschermKleur(naam: 'Deuctone 6068', code: 'Deuctone 6068'),
    OpmetingUitvalschermKleur(naam: 'Deuctone 6070', code: 'Deuctone 6070'),
    OpmetingUitvalschermKleur(
      naam: 'Deuctone 6909 (RDS 085 60 10)',
      code: 'AE30017012623',
    ),
    OpmetingUitvalschermKleur(naam: 'Grijs Rolluiken', code: '317032203'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9005 EE00004905825 Lightning Black',
      code: 'EE00004905825',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9008 Tiger 029/70787 S.I.E.D.',
      code: '029/70787',
    ),
    OpmetingUitvalschermKleur(naam: 'M019', code: 'PE50/TR9003HR/73/180'),
    OpmetingUitvalschermKleur(naam: 'M071', code: 'PE50/TR9001HR/73/180'),
    OpmetingUitvalschermKleur(naam: 'M080', code: 'PE52/TRM9003HR/30/20'),
    OpmetingUitvalschermKleur(naam: 'Naturel Rolluiken', code: '317032208'),
    OpmetingUitvalschermKleur(naam: 'P115 EG', code: 'DS312H8213'),
    OpmetingUitvalschermKleur(naam: 'P701 EM', code: 'DS542A8300'),
    OpmetingUitvalschermKleur(naam: 'P716 EM', code: 'DS542A8107'),
    OpmetingUitvalschermKleur(naam: 'P716 RM', code: 'ZX641A8010'),
    OpmetingUitvalschermKleur(naam: 'P721 RM', code: 'ZX641A8005'),
    OpmetingUitvalschermKleur(naam: 'P723 RM', code: 'ZX642A8009'),
    OpmetingUitvalschermKleur(naam: 'P732 RM', code: 'ZX642A8006'),
    OpmetingUitvalschermKleur(naam: 'P737 RM', code: 'ZX642A8008'),
    OpmetingUitvalschermKleur(naam: 'P739 RM', code: 'ZX641A8007'),
    OpmetingUitvalschermKleur(naam: 'P899 EM', code: 'DS542M8030'),
    OpmetingUitvalschermKleur(naam: 'P901 EG', code: 'DS312W8039'),
    OpmetingUitvalschermKleur(naam: 'P905 RM', code: 'ZX641N8002'),
    OpmetingUitvalschermKleur(naam: 'P910 EG', code: 'DS312W8038'),
    OpmetingUitvalschermKleur(naam: 'P910 RM', code: 'AE03059114327'),
    OpmetingUitvalschermKleur(naam: 'RAL 1001', code: 'AE70011960425'),
    OpmetingUitvalschermKleur(naam: 'RAL 1013', code: 'AE70019420225'),
    OpmetingUitvalschermKleur(naam: 'RAL 1013 Coatex', code: 'AE03051101320'),
    OpmetingUitvalschermKleur(naam: 'RAL 1013 MAT', code: 'AE30011101320'),
    OpmetingUitvalschermKleur(naam: 'RAL 1013 Reynaers', code: 'AE30009002423'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 1013 Tiger 29/10933',
      code: 'RAL 1013 29/10933',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 1014', code: 'AE70011960625'),
    OpmetingUitvalschermKleur(naam: 'RAL 1015', code: 'AE70019920125'),
    OpmetingUitvalschermKleur(naam: 'RAL 1015 Reynaers', code: 'AE30001002523'),
    OpmetingUitvalschermKleur(naam: 'RAL 1015 MAT', code: 'AE30011101520'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 1015 Tiger 29/15461',
      code: 'RAL 1015 29/15461',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 1015 Tiger 29/15508',
      code: 'RAL 1015 29/15508',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 1018', code: 'AE70011200125'),
    OpmetingUitvalschermKleur(naam: 'RAL 1019', code: 'AE70018360425'),
    OpmetingUitvalschermKleur(naam: 'RAL 1019 Coatex', code: 'AE03051101920'),
    OpmetingUitvalschermKleur(naam: 'RAL 1019 MAT', code: 'AE30011101920'),
    OpmetingUitvalschermKleur(naam: 'RAL 1020', code: 'AE70011470225'),
    OpmetingUitvalschermKleur(naam: 'RAL 3000', code: 'AE70013280125'),
    OpmetingUitvalschermKleur(naam: 'RAL 3001', code: 'AE70013300120'),
    OpmetingUitvalschermKleur(naam: 'RAL 3003', code: 'AE70013500125'),
    OpmetingUitvalschermKleur(naam: 'RAL 3004', code: 'AE70013720125'),
    OpmetingUitvalschermKleur(naam: 'RAL 3004 MAT', code: 'AE30013300420'),
    OpmetingUitvalschermKleur(naam: 'RAL 3005', code: 'AE70013860325'),
    OpmetingUitvalschermKleur(naam: 'RAL 3005 MAT', code: 'AE30013300520'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 3005 Tiger 29/30462',
      code: 'RAL 3005 29/30462',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 3007', code: 'AE70013300720'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 3009 Tiger 29/30401',
      code: 'RAL 3009 29/30401',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 3011', code: 'AE70013580125'),
    OpmetingUitvalschermKleur(naam: 'RAL 3011 MAT', code: 'AE30013301120'),
    OpmetingUitvalschermKleur(naam: 'RAL 3020', code: 'AE70013120325'),
    OpmetingUitvalschermKleur(naam: 'RAL 3020 MAT', code: 'AE30013302020'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 3099 Tiger 29/30402',
      code: 'RAL 3099 29/30402',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 5002', code: 'AE70015710225'),
    OpmetingUitvalschermKleur(naam: 'RAL 5003', code: 'AE70015870225'),
    OpmetingUitvalschermKleur(naam: 'RAL 5004', code: 'AE70015500420'),
    OpmetingUitvalschermKleur(naam: 'RAL 5004 MAT', code: 'AE30015500420'),
    OpmetingUitvalschermKleur(naam: 'RAL 5008', code: 'AE70017830125'),
    OpmetingUitvalschermKleur(naam: 'RAL 5008 Coatex', code: 'AE03055500820'),
    OpmetingUitvalschermKleur(naam: 'RAL 5008 MAT', code: 'AE300C5500820'),
    OpmetingUitvalschermKleur(naam: 'RAL 5009', code: 'AE70015670125'),
    OpmetingUitvalschermKleur(naam: 'RAL 5009 MAT', code: 'AE30015500920'),
    OpmetingUitvalschermKleur(naam: 'RAL 5010', code: 'AE70015600225'),
    OpmetingUitvalschermKleur(naam: 'RAL 5010 MAT', code: 'AE30015501020'),
    OpmetingUitvalschermKleur(naam: 'RAL 5011', code: 'AE70015950125'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 5011 Tiger 29/40782',
      code: 'RAL 5011 29/40782',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 5012', code: 'AE70015310325'),
    OpmetingUitvalschermKleur(naam: 'RAL 5013', code: 'AE70015810225'),
    OpmetingUitvalschermKleur(naam: 'RAL 5014', code: 'AE70015270125'),
    OpmetingUitvalschermKleur(naam: 'RAL 5020 MAT', code: 'AE30015502020'),
    OpmetingUitvalschermKleur(naam: 'RAL 5023', code: 'AE70015610425'),
    OpmetingUitvalschermKleur(naam: 'RAL 5024 MAT', code: 'AE30015502420'),
    OpmetingUitvalschermKleur(naam: 'RAL 6001', code: 'AE70016520125'),
    OpmetingUitvalschermKleur(naam: 'RAL 6003 MAT', code: 'AE300C6600320'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 6005 Axalta AE70016830125',
      code: 'AE70016830125',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 6005 MAT', code: 'AE30016600520'),
    OpmetingUitvalschermKleur(naam: 'RAL 6009', code: 'AE70016970425'),
    OpmetingUitvalschermKleur(naam: 'RAL 6009 Coatex', code: 'AE03056600920'),
    OpmetingUitvalschermKleur(naam: 'RAL 6009 MAT', code: 'AE30016600920'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 6009 Tiger 29/50704',
      code: 'RAL 6009 29/50704',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 6009 Tiger 29/50800',
      code: 'RAL 6009 29/50800',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 6012 MAT', code: 'AE30016601220'),
    OpmetingUitvalschermKleur(naam: 'RAL 6013', code: 'AE70016170525'),
    OpmetingUitvalschermKleur(naam: 'RAL 6021 MAT', code: 'AE30016602120'),
    OpmetingUitvalschermKleur(naam: 'RAL 6064', code: 'AE70016970225'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 6099 Tiger 29/50698',
      code: 'RAL 6099 29/50698',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 6999 Tiger 29/50759',
      code: 'RAL 6999 29/50759',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7000 Grau 250 S 29/71358',
      code: 'GRAU 250 S 29/71358',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 7001', code: 'AE70017200225'),
    OpmetingUitvalschermKleur(naam: 'RAL 7001 MAT', code: 'AE30017700120'),
    OpmetingUitvalschermKleur(naam: 'RAL 7002 MAT', code: 'AE30017700220'),
    OpmetingUitvalschermKleur(naam: 'RAL 7003', code: 'AE70017520125'),
    OpmetingUitvalschermKleur(naam: 'RAL 7003 MAT', code: 'AE30017700320'),
    OpmetingUitvalschermKleur(naam: 'RAL 7004', code: 'AE70017260325'),
    OpmetingUitvalschermKleur(naam: 'RAL 7004 MAT', code: 'AE30017700420'),
    OpmetingUitvalschermKleur(naam: 'RAL 7005', code: 'AE70017420525'),
    OpmetingUitvalschermKleur(naam: 'RAL 7005 Reynaers', code: 'AE30017420925'),
    OpmetingUitvalschermKleur(naam: 'RAL 7005 MAT', code: 'AE30017700520'),
    OpmetingUitvalschermKleur(naam: 'RAL 7006', code: 'AE70018170125'),
    OpmetingUitvalschermKleur(naam: 'RAL 7006 Reynaers', code: 'AE30018172625'),
    OpmetingUitvalschermKleur(naam: 'RAL 7006 Coatex', code: 'AE03057700620'),
    OpmetingUitvalschermKleur(naam: 'RAL 7006 MAT', code: 'AE30017700620'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7006 Tiger 29/73223',
      code: 'RAL 7006 29/73223',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 7009', code: 'AE70017650225'),
    OpmetingUitvalschermKleur(naam: 'RAL 7009 MAT', code: 'AE30017700920'),
    OpmetingUitvalschermKleur(naam: 'RAL 7010', code: 'AE70017650325'),
    OpmetingUitvalschermKleur(naam: 'RAL 7010 MAT', code: 'AE30017701020'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7010 Tiger 29/71569',
      code: 'RAL 7010 29/71569',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 7011', code: 'AE70017620325'),
    OpmetingUitvalschermKleur(naam: 'RAL 7011 Reynaers', code: 'AE30017622625'),
    OpmetingUitvalschermKleur(naam: 'RAL 7011 MAT', code: 'AE30017620325'),
    OpmetingUitvalschermKleur(naam: 'RAL 7012', code: 'AE70017650125'),
    OpmetingUitvalschermKleur(naam: 'RAL 7012 Coatex', code: 'AE03057701220'),
    OpmetingUitvalschermKleur(naam: 'RAL 7012 MAT', code: 'AE30017701220'),
    OpmetingUitvalschermKleur(naam: 'RAL 7013', code: 'AE70018650125'),
    OpmetingUitvalschermKleur(naam: 'RAL 7015', code: 'AE70017730125'),
    OpmetingUitvalschermKleur(naam: 'RAL 7015 MAT', code: 'AE30017701520'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7015 Tiger 29/71719',
      code: 'RAL 7015 29/71719',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7015 Tiger 29/71723',
      code: 'RAL 7015 29/71723',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 7016', code: 'AE70017620225'),
    OpmetingUitvalschermKleur(naam: 'RAL 7016 Coatex', code: 'AE03057701620'),
    OpmetingUitvalschermKleur(naam: 'RAL 7016 MAT', code: 'AE30017701620'),
    OpmetingUitvalschermKleur(naam: 'RAL 7016 Reynaers', code: 'AE30007005023'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7016 Tiger 29/71289',
      code: 'RAL 7016 29/71289',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7016 Tiger 29/71334',
      code: 'RAL 7016 29/71334',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7016 Tiger 29/73570',
      code: 'RAL 7016 29/73570',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 7021', code: 'AE70017820125'),
    OpmetingUitvalschermKleur(naam: 'RAL 7021 Reynaers', code: 'AE30007005123'),
    OpmetingUitvalschermKleur(naam: 'RAL 7021 Coatex', code: 'AE03057702120'),
    OpmetingUitvalschermKleur(naam: 'RAL 7021 MAT', code: 'AE30017702120'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7021 Tiger 29/71263',
      code: 'RAL 7021 29/71263',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7021 Tiger 29/71335',
      code: 'RAL 7021 29/71335',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7021 Tiger 29/72183',
      code: 'RAL 7021 29/72183',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 7022', code: 'AE70017750225'),
    OpmetingUitvalschermKleur(naam: 'RAL 7022 Coatex', code: 'AE03057702220'),
    OpmetingUitvalschermKleur(naam: 'RAL 7022 MAT', code: 'AE30017702220'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7022 Tiger 29/72932',
      code: 'RAL 7022 29/72932',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 7023', code: 'AE70017320625'),
    OpmetingUitvalschermKleur(naam: 'RAL 7023 Coatex', code: 'AE03057702320'),
    OpmetingUitvalschermKleur(naam: 'RAL 7023 MAT', code: 'AE30017702320'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7023 Tiger 29/72362 --> 29/7B297',
      code: '29/72362 --> 29/7B297',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 7024', code: 'AE70017710125'),
    OpmetingUitvalschermKleur(naam: 'RAL 7024 Reynaers', code: 'AE30007004923'),
    OpmetingUitvalschermKleur(naam: 'RAL 7024 Coatex', code: 'AE03057702420'),
    OpmetingUitvalschermKleur(naam: 'RAL 7024 MAT', code: 'AE30017702420'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7024 Tiger 29/71795',
      code: 'RAL 7024 29/71795',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 7026', code: 'AE70017850125'),
    OpmetingUitvalschermKleur(naam: 'RAL 7026 MAT', code: 'AE30017702620'),
    OpmetingUitvalschermKleur(naam: 'RAL 7030', code: 'AE70017320325'),
    OpmetingUitvalschermKleur(naam: 'RAL 7030 Coatex', code: 'AE03057703020'),
    OpmetingUitvalschermKleur(naam: 'RAL 7030 MAT', code: 'AE30017703020'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7030 Tiger 29/71715',
      code: 'RAL 7030 29/71715',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7030 Tiger 29/71720',
      code: 'RAL 7030 29/71720',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 7031', code: 'AE70017530125'),
    OpmetingUitvalschermKleur(naam: 'RAL 7031 MAT', code: 'AE300C7703120'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7031 Oxyplast PE50/TR7031HR/73/180',
      code: 'PE50/TR7031HR/73/180',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 7032', code: 'AE70017120425'),
    OpmetingUitvalschermKleur(naam: 'RAL 7032 MAT', code: 'AE30017703220'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7032 Tiger 29/72364',
      code: 'RAL 7032 29/72364',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 7033', code: 'AE70017420325'),
    OpmetingUitvalschermKleur(naam: 'RAL 7033 Coatex', code: 'AE03057703320'),
    OpmetingUitvalschermKleur(naam: 'RAL 7033 MAT', code: 'AE30017703320'),
    OpmetingUitvalschermKleur(naam: 'RAL 7034', code: 'AE70017320525'),
    OpmetingUitvalschermKleur(naam: 'RAL 7034 MAT', code: 'AE30017703420'),
    OpmetingUitvalschermKleur(naam: 'RAL 7035', code: 'AE70019870225'),
    OpmetingUitvalschermKleur(naam: 'RAL 7035 Coatex', code: 'AE03057703520'),
    OpmetingUitvalschermKleur(naam: 'RAL 7035 MAT', code: 'AE30017703520'),
    OpmetingUitvalschermKleur(naam: 'RAL 7036', code: 'AE70017210125'),
    OpmetingUitvalschermKleur(naam: 'RAL 7036 MAT', code: 'AE30017703620'),
    OpmetingUitvalschermKleur(naam: 'RAL 7037', code: 'AE70017410125'),
    OpmetingUitvalschermKleur(naam: 'RAL 7037 MAT', code: 'AE30017703720'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7037 Oxyplast PE52/THM7037HR/30/200',
      code: 'PE52/THM7037HR/30/20',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7037 Tiger 29/70349',
      code: 'RAL 7037 029/70349',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7037 Tiger 29/72184',
      code: 'RAL 7037 029/72184',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 7038', code: 'AE70017120925'),
    OpmetingUitvalschermKleur(naam: 'RAL 7038 MAT', code: 'AE30017703820'),
    OpmetingUitvalschermKleur(naam: 'RAL 7039', code: 'AE70017580225'),
    OpmetingUitvalschermKleur(naam: 'RAL 7039 Coatex', code: 'AE03057703920'),
    OpmetingUitvalschermKleur(naam: 'RAL 7039 MAT', code: 'AE30017703920'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7039 Tiger 29/71716',
      code: 'RAL 7039 29/71716',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7039 Tiger 29/71721',
      code: 'RAL 7039 29/71721',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7039 Tiger 29/72179',
      code: 'RAL 7039 29/72179',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7039 Tiger 29/72881',
      code: 'RAL 7039 29/72881',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 7040', code: 'AE70017130525'),
    OpmetingUitvalschermKleur(naam: 'RAL 7040 MAT', code: 'AE30017704020'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7040 Tiger 29/72710',
      code: 'RAL 7040 29/72710',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7040 Tiger 29/90316',
      code: 'RAL 7040 29/90316',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 7042', code: 'AE70017320925'),
    OpmetingUitvalschermKleur(naam: 'RAL 7042 MAT', code: 'AE30017704220'),
    OpmetingUitvalschermKleur(naam: 'RAL 7043', code: 'AE70017720325'),
    OpmetingUitvalschermKleur(naam: 'RAL 7043 MAT', code: 'AE300C7704320'),
    OpmetingUitvalschermKleur(naam: 'RAL 7044', code: 'AE70019820325'),
    OpmetingUitvalschermKleur(naam: 'RAL 7044 Coatex', code: 'AE03057704420'),
    OpmetingUitvalschermKleur(naam: 'RAL 7044 MAT', code: 'AE30017704420'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7044 Tiger 29/71718',
      code: 'RAL 7044 29/71718',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 7045', code: 'AE70017100225'),
    OpmetingUitvalschermKleur(naam: 'RAL 7045 MAT', code: 'AE30017704520'),
    OpmetingUitvalschermKleur(naam: 'RAL 7046', code: 'AE70017370125'),
    OpmetingUitvalschermKleur(naam: 'RAL 7046 MAT', code: 'AE30017704620'),
    OpmetingUitvalschermKleur(naam: 'RAL 7047', code: 'AE70019900225'),
    OpmetingUitvalschermKleur(naam: 'RAL 7047 MAT', code: 'AE30017704720'),
    OpmetingUitvalschermKleur(naam: 'RAL 8000', code: 'AE70018800020'),
    OpmetingUitvalschermKleur(naam: 'RAL 8001', code: 'AE70018120225'),
    OpmetingUitvalschermKleur(naam: 'RAL 8001 MAT', code: 'AE300C8800120'),
    OpmetingUitvalschermKleur(naam: 'RAL 8002 MAT', code: 'AE30018800220'),
    OpmetingUitvalschermKleur(naam: 'RAL 8003', code: 'AE70018100325'),
    OpmetingUitvalschermKleur(naam: 'RAL 8003 MAT', code: 'AE30018800320'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 8003 Tiger 29/60898',
      code: 'RAL 8003 29/60898',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 8004 MAT', code: 'AE30018800420'),
    OpmetingUitvalschermKleur(naam: 'RAL 8008', code: 'AE70018220125'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 8009 Tiger 29/60731',
      code: 'RAL 8009 29/60731',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 8011', code: 'AE70018510125'),
    OpmetingUitvalschermKleur(naam: 'RAL 8012', code: 'AE70018610225'),
    OpmetingUitvalschermKleur(naam: 'RAL 8014', code: 'AE70018720125'),
    OpmetingUitvalschermKleur(naam: 'RAL 8014 MAT', code: 'AE30018801420'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 8014 Tiger 29/60488',
      code: 'RAL 8014 29/60488',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 8014 Tiger 29/60740',
      code: 'RAL 8014 29/60740',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 8015 MAT', code: 'AE30018801520'),
    OpmetingUitvalschermKleur(naam: 'RAL 8016', code: 'AE70018915025'),
    OpmetingUitvalschermKleur(naam: 'RAL 8016 MAT', code: 'AE300C8801620'),
    OpmetingUitvalschermKleur(naam: 'RAL 8017', code: 'AE70018910325'),
    OpmetingUitvalschermKleur(naam: 'RAL 8017 MAT', code: 'AE300C8801720'),
    OpmetingUitvalschermKleur(naam: 'RAL 8019 (Bel)', code: 'AE70018870925'),
    OpmetingUitvalschermKleur(naam: 'RAL 8019 (Hol)', code: 'AE70018870125'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 8019 Akzo SM 079E',
      code: 'RAL 8019 AKZO SM079E',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 8019 Coatex', code: 'AE03058801920'),
    OpmetingUitvalschermKleur(naam: 'RAL 8019 MAT', code: 'AE300C8801920'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 8019 Tiger 29/60674',
      code: 'RAL 8019 29/60674',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 8019 Tiger 29/60735',
      code: 'RAL 8019 29/60735',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 8019 Tiger 29/70795',
      code: 'RAL 8019 29/70795',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 8022', code: 'AE70014910125'),
    OpmetingUitvalschermKleur(naam: 'RAL 8022 Coatex', code: 'AE03058802220'),
    OpmetingUitvalschermKleur(naam: 'RAL 8022 MAT', code: 'AE30018802220'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 8022 Tiger 29/60861',
      code: 'RAL 8022 29/60861',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 8023', code: 'AE70018140625'),
    OpmetingUitvalschermKleur(naam: 'RAL 8025', code: 'AE70018360525'),
    OpmetingUitvalschermKleur(naam: 'RAL 8025 MAT', code: 'AE30018802520'),
    OpmetingUitvalschermKleur(naam: 'RAL 8028', code: 'AE70018620125'),
    OpmetingUitvalschermKleur(naam: 'RAL 9001', code: 'AE70019220225'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9001 Oxyplast PE50/TR9001HR/73/180',
      code: 'PE50/TR9001HR/73/180',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 9001 Coatex', code: 'AE03059900120'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9001 Tiger 29/10553',
      code: '29/10553',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9001 Tiger 29/11089',
      code: 'RAL 9001 29/11089',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 9002', code: 'AE70019570225'),
    OpmetingUitvalschermKleur(naam: 'RAL 9002 Coatex', code: 'AE03059900220'),
    OpmetingUitvalschermKleur(naam: 'RAL 9002 MAT', code: 'AE300C9900220'),
    OpmetingUitvalschermKleur(naam: 'RAL 9003', code: 'AE70019171025'),
    OpmetingUitvalschermKleur(naam: 'RAL 9003 MAT', code: 'AE300C9900320'),
    OpmetingUitvalschermKleur(naam: 'RAL 9004', code: 'AE70014902425'),
    OpmetingUitvalschermKleur(naam: 'RAL 9004 Coatex', code: 'AE03054900420'),
    OpmetingUitvalschermKleur(naam: 'RAL 9004 MAT', code: 'AE300C4900420'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9004 Tiger 029/80271',
      code: 'RAL 9004 029/80271',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 9005', code: 'AE70014900520'),
    OpmetingUitvalschermKleur(naam: 'RAL 9005 Coatex', code: 'AE03054900520'),
    OpmetingUitvalschermKleur(naam: 'RAL 9005 MAT', code: 'AE30014900520'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9005 Tiger 29/80081',
      code: 'RAL 9005 29/80081',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9005 Tiger 29/80303',
      code: 'RAL 9005 29/80303',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9005 Tiger 29/80070',
      code: 'RAL 9005 29/80070',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 9006', code: 'AE80157900620'),
    OpmetingUitvalschermKleur(naam: 'RAL 9006 Coatex', code: 'AE03257900620'),
    OpmetingUitvalschermKleur(naam: 'RAL 9006 MAT', code: 'AE30217900620'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9006 Tiger 29/71724',
      code: 'RAL 9006 29/71724',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9006 Tiger 29/90024',
      code: 'RAL 9006 29/90024',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9006 Tiger 029/90080',
      code: '029/90080',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9006 Tiger 29/90146',
      code: 'RAL 9006 29/90146',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9006 Tiger 29/90198',
      code: 'RAL 9006 29/90198',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9006 Tiger 68/90006',
      code: 'RAL 9006 68/90006',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 9007', code: 'AE80157900720'),
    OpmetingUitvalschermKleur(naam: 'RAL 9007 Coatex', code: 'AE03257900720'),
    OpmetingUitvalschermKleur(naam: 'RAL 9007 MAT', code: 'AE30217900720'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9007 Tiger 29/71725',
      code: 'RAL 9007 29/71725',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9007 Tiger 29/72004',
      code: 'RAL 9007 29/72004',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9007 Tiger 29/90147',
      code: 'RAL 9007 29/90147',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9007 Tiger 68/90007',
      code: 'RAL 9007 68/90007',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 9008 Coatex', code: 'AE03257900820'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9009 Tiger 29/80077',
      code: 'RAL 9009 29/80077',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 9010 Reynaers', code: 'AE30009002323'),
    OpmetingUitvalschermKleur(naam: 'RAL 9010 (Bel)', code: 'AE90019148021'),
    OpmetingUitvalschermKleur(naam: 'RAL 9010 (Hol)', code: 'AE70019100125'),
    OpmetingUitvalschermKleur(naam: 'RAL 9010 Coatex', code: 'AE03059901020'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9010 GL Oxyplast PE50/TR9140/90/180/4',
      code: 'PE50/TR9140/90/180/4',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9010 Tiger 29/10797',
      code: 'RAL 9010 29/10797',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9010 Oxyplast PE50/TR9010HR/73/180',
      code: 'PE50/TR9010HR/73/180',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9010 Tiger 29/11091',
      code: 'RAL 9010 29/11091',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 9011', code: 'AE70014960125'),
    OpmetingUitvalschermKleur(naam: 'RAL 9011 Coatex', code: 'AE03054901120'),
    OpmetingUitvalschermKleur(naam: 'RAL 9011 MAT', code: 'AE30014901120'),
    OpmetingUitvalschermKleur(naam: 'RAL 9016', code: 'AE70019101525'),
    OpmetingUitvalschermKleur(naam: 'RAL 9016 Coatex', code: 'AE03059901620'),
    OpmetingUitvalschermKleur(naam: 'RAL 9016 MAT', code: 'AE300C9901620'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9016 Tiger 29/10246',
      code: 'RAL 9016 29/10246',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 9017', code: 'AE70014900725'),
    OpmetingUitvalschermKleur(naam: 'RAL 9017 MAT', code: 'AE300C4901720'),
    OpmetingUitvalschermKleur(naam: 'RAL 9018', code: 'AE70019820525'),
    OpmetingUitvalschermKleur(naam: 'RAL 9018 MAT', code: 'AE30019901820'),
    OpmetingUitvalschermKleur(naam: 'RAL 9022', code: 'AE80317005525'),
    OpmetingUitvalschermKleur(naam: 'Wit Rolluiken', code: '317032201'),
    OpmetingUitvalschermKleur(naam: 'Wit Screen/Serrola', code: 'DS112W8042'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7021 Tiger 067/71764',
      code: '067/71764',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9004 Tiger 067/80057',
      code: 'RAL 9004 067/80057',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7022 Tiger 067/71175',
      code: 'RAL 7022 067/71175',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7023 Tiger 067/71731',
      code: 'RAL 7023 067/71731',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7030 Tiger 067/71756',
      code: 'RAL 7030 067/71756',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7032 Tiger 067/71733',
      code: 'RAL 7032 067/71733',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7037 Tiger 067/71293',
      code: 'RAL 7037 067/71293',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7039 Tiger 067/71291',
      code: 'RAL 7039 067/71291',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 8019 Tiger 068/71752',
      code: 'RAL 8019 068/71752',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9001 Tiger 067/15115',
      code: 'RAL 9001 067/15115',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9005 Tiger 067/80381',
      code: 'RAL 9005 067/80381',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9010 Tiger 067/71259',
      code: 'RAL 9010 067/71259',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9016 Tiger 067/10079',
      code: 'RAL 9016 067/10079',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 901TC Tiger 067/10426',
      code: 'RAL 901TC 067/10426',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7016 Tiger 067/70190',
      code: 'RAL 7016 067/70190',
    ),
    OpmetingUitvalschermKleur(naam: 'P704 RM', code: 'ZX642A8027'),
    OpmetingUitvalschermKleur(naam: 'P731 RM', code: 'AE03057357127'),
    OpmetingUitvalschermKleur(naam: 'P706 RM', code: 'ZX642A8028'),
    OpmetingUitvalschermKleur(naam: 'P744 RM', code: 'ZX642A8025'),
    OpmetingUitvalschermKleur(naam: 'RAL 9010 MAT', code: 'AE30019901020'),
    OpmetingUitvalschermKleur(naam: 'P901 RM', code: 'AE03051108327'),
    OpmetingUitvalschermKleur(naam: 'P119 RM', code: 'AE03008102627'),
    OpmetingUitvalschermKleur(naam: 'P511 EM', code: 'ZS542B8009'),
    OpmetingUitvalschermKleur(naam: 'P890 RM', code: 'AE03058076027'),
    OpmetingUitvalschermKleur(naam: 'P701 RM', code: 'AE03007495527'),
    OpmetingUitvalschermKleur(naam: 'P916 EG', code: 'DS442W8091'),
    OpmetingUitvalschermKleur(naam: 'P305 RM', code: 'AE03018066527'),
    OpmetingUitvalschermKleur(naam: 'P730 RM', code: 'ZX642A8026'),
    OpmetingUitvalschermKleur(naam: 'P612RM', code: 'AE03056135727'),
    OpmetingUitvalschermKleur(naam: 'P822RM', code: 'ZX641M8010'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9011 Tiger 29/80527',
      code: '9011 029/80527',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 5011 Coatex AE03055501120',
      code: 'AE03055501120',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 7009 Coatex', code: 'AE03057700920'),
    OpmetingUitvalschermKleur(naam: 'RAL 9001 MAT', code: 'AE300C9900120'),
    OpmetingUitvalschermKleur(naam: 'P906 EM', code: 'AE20217068420'),
    OpmetingUitvalschermKleur(naam: 'RAL 7000 MAT', code: 'AE30017700020'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 8017 Tiger 029/61333',
      code: '029/61333',
    ),
    OpmetingUitvalschermKleur(
      naam: '905 PT RWMXD-0454',
      code: '905 PT RWMXD-0454',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 8016 Tiger 029/61311',
      code: '8016 029/61311',
    ),
    OpmetingUitvalschermKleur(naam: 'P699 EM', code: 'ZS542G8015'),
    OpmetingUitvalschermKleur(naam: 'RAL 6033 MAT', code: 'AE30016603320'),
    OpmetingUitvalschermKleur(naam: 'RAL 7037 Coatex', code: 'AE03057703720'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7036 Tiger 029/72859',
      code: '7036 29/72859',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9011 Tiger 067/80296',
      code: '9011 067/80296',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 9017 Coatex', code: 'AE03054901720'),
    OpmetingUitvalschermKleur(naam: 'RAL 5019 MAT', code: 'AE30015501920'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7032 Tiger 029/72073',
      code: '7032 029/72073',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 8016 Coatex', code: 'AE03058801620'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 8011 Tiger 029/61344',
      code: '8011 029/61344',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7016 Tiger 068/70153',
      code: '7016 068/70153',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7044 Tiger 068/71732',
      code: '7044 068/71732',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7022 Tiger 029/71740',
      code: '7022 029/71740',
    ),
    OpmetingUitvalschermKleur(
      naam: 'IGP Grijs 5803E71387A10-K20',
      code: '5803E71387A10-K20',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 7034 Coatex', code: 'AE03057703420'),
    OpmetingUitvalschermKleur(naam: 'RAL 7038 Coatex', code: 'AE03057703820'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 8019 AE70018801920',
      code: 'AE70018801920',
    ),
    OpmetingUitvalschermKleur(naam: 'P822 EM', code: 'DS542M8064'),
    OpmetingUitvalschermKleur(naam: 'P609 RM', code: 'ZX641G8018'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7021 Tiger 68/70206',
      code: 'RAL 7021 68/70206',
    ),
    OpmetingUitvalschermKleur(
      naam: 'SD201C8210621 Dark Bronze',
      code: 'SD201C8210621',
    ),
    OpmetingUitvalschermKleur(naam: 'P917 RM', code: 'ZX641N8013'),
    OpmetingUitvalschermKleur(naam: 'Anodic Brown', code: 'AE20108000420'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9010 Tiger 029/10674',
      code: '029/10674',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 6005 Coatex AE03056600520',
      code: 'AE03056600520',
    ),
    OpmetingUitvalschermKleur(
      naam: 'Rost Matt Fs Met. 067/60116',
      code: '067/60116',
    ),
    OpmetingUitvalschermKleur(naam: 'Anodic Gold', code: 'AE20111000820'),
    OpmetingUitvalschermKleur(
      naam: 'AE20108000320 Anodic Bronze',
      code: 'AE20108000320',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7021 EF 154-0492',
      code: 'AE03004058227',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL +/-1019 Fine Texture Quartz 2',
      code: 'AE03411122920',
    ),
    OpmetingUitvalschermKleur(naam: 'RAL 7008 MAT', code: 'AE30017700820'),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9006 Tiger 029/90434',
      code: '029/90434',
    ),
    OpmetingUitvalschermKleur(naam: 'P712 RM Structuur', code: 'ZX642A8038'),
    OpmetingUitvalschermKleur(naam: 'RAL 5022 MAT', code: 'AE30015502220'),
    OpmetingUitvalschermKleur(
      naam: 'SuprAnodic Brown SD201C8000420',
      code: 'SD201C8000420',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9005 SD030C4900520',
      code: 'SD030C4900520',
    ),
    OpmetingUitvalschermKleur(
      naam: 'SuprAnodic Bronze Matt SD201C8000320',
      code: 'SD201C8000320',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7044 Silk Grey Optimum SD030C7704420',
      code: 'SD030C7704420',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9007 Tiger 029/90195',
      code: '029/90195',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 1015 Tiger 29/15518',
      code: '29/15518',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 6028 AE70016720325',
      code: 'AE70016720325',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 6010 AE70016470125',
      code: 'AE70016470125',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 1036 Tiger 29/90012',
      code: '29/90012',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9001 Hollands',
      code: '9001 Eigen Natlak',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7021 Akzo Nobel YL321F INT D2525 TEXT FN',
      code: 'YL321F INT D2525',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 7016 Akzo Nobel YL316F INT D2525',
      code: 'YL316F',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9004 Akzo Nobel YN304F INT D2525',
      code: 'YN304F',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9005 Akzo Nobel YN305F INT D2525',
      code: 'YN305F',
    ),
    OpmetingUitvalschermKleur(
      naam: 'RAL 9011 Akzo Nobel YN311F INT D2525',
      code: 'YN311F',
    ),
    OpmetingUitvalschermKleur(
      naam: 'Axalta AE03117049620 January 6',
      code: 'AE03117049620',
    ),
  ];

  static const List<OpmetingUitvalschermMotor> standaardMotoren =
      <OpmetingUitvalschermMotor>[
        OpmetingUitvalschermMotor(
          type: 'Bekabeld',
          merk: 'SOMFY',
          omschrijving: 'Orea 50 WT 40/17',
        ),
        OpmetingUitvalschermMotor(
          type: 'Draadloos',
          merk: 'SOMFY',
          omschrijving: 'Sunea 50 IO 40/17',
        ),
      ];

  static const List<String> standaardBedieningen = <String>[
    'Inbouwschakelaar',
    'Handzender Somfy Situo 1',
    'Handzender Somfy Situo 5',
    'Handzender Somfy Situo 5 Var',
    'Muurzender IO AMY',
  ];

  static const List<OpmetingUitvalschermDoek>
  standaardDoeken = <OpmetingUitvalschermDoek>[
    OpmetingUitvalschermDoek(
      code: 'D309',
      kleur: 'Manosque Grey',
      hex: '#8A8987',
    ),
    OpmetingUitvalschermDoek(
      code: 'D308',
      kleur: 'Naples Dark Grey',
      hex: '#505054',
    ),
    OpmetingUitvalschermDoek(
      code: 'D108',
      kleur: 'Manosque Dark Grey',
      hex: '#66666A',
    ),
    OpmetingUitvalschermDoek(
      code: 'D330',
      kleur: 'Color bloc black',
      hex: '#303036',
    ),
    OpmetingUitvalschermDoek(
      code: 'D113',
      kleur: 'Naples Grey',
      hex: '#99999B',
    ),
    OpmetingUitvalschermDoek(
      code: 'D319',
      kleur: 'Pensil Dark Grey',
      hex: '#56565A',
    ),
    OpmetingUitvalschermDoek(code: '6020', kleur: 'Grège', hex: '#B7A89A'),
    OpmetingUitvalschermDoek(
      code: 'U371',
      kleur: 'Chamois Tweed',
      hex: '#8B8175',
    ),
    OpmetingUitvalschermDoek(
      code: 'U370',
      kleur: 'Papyrus Tweed',
      hex: '#B3AAA1',
    ),
    OpmetingUitvalschermDoek(code: '7559', kleur: 'Taupe', hex: '#786E67'),
    OpmetingUitvalschermDoek(code: '6088', kleur: 'Gris', hex: '#9B9998'),
    OpmetingUitvalschermDoek(
      code: '7330',
      kleur: 'Charcoal Tweed',
      hex: '#3C3C3A',
    ),
    OpmetingUitvalschermDoek(code: '6196', kleur: 'Pierre', hex: '#AFA69F'),
    OpmetingUitvalschermDoek(
      code: '8396',
      kleur: 'Souris Chiné',
      hex: '#99989B',
    ),
    OpmetingUitvalschermDoek(code: 'U190', kleur: 'Gris Tweed', hex: '#AAA9A8'),
    OpmetingUitvalschermDoek(
      code: 'U407',
      kleur: 'Platine Piqué',
      hex: '#777571',
    ),
    OpmetingUitvalschermDoek(code: '7552', kleur: 'Argent', hex: '#9DA3A0'),
    OpmetingUitvalschermDoek(
      code: 'U104',
      kleur: 'Flanelle Chiné',
      hex: '#666866',
    ),
    OpmetingUitvalschermDoek(code: '8203', kleur: 'Ardoise', hex: '#505156'),
    OpmetingUitvalschermDoek(
      code: 'U373',
      kleur: 'Macadam Tweed',
      hex: '#42423F',
    ),
    OpmetingUitvalschermDoek(
      code: 'U406',
      kleur: 'Acier Piqué',
      hex: '#464649',
    ),
    OpmetingUitvalschermDoek(code: '6028', kleur: 'Noir', hex: '#111111'),
    OpmetingUitvalschermDoek(code: 'U171', kleur: 'Carbone', hex: '#353538'),
    OpmetingUitvalschermDoek(
      code: 'U095',
      kleur: 'Basalte Chiné',
      hex: '#373735',
    ),
  ];

  OpmetingUitvalschermInstellingen copyWith({
    List<OpmetingUitvalschermKleur>? draagstructuurKleuren,
    List<OpmetingUitvalschermDoek>? doeken,
    List<OpmetingUitvalschermMotor>? motoren,
    List<String>? bedieningen,
    String? gewijzigdOp,
  }) {
    return OpmetingUitvalschermInstellingen(
      draagstructuurKleuren:
          draagstructuurKleuren ?? this.draagstructuurKleuren,
      doeken: doeken ?? this.doeken,
      motoren: motoren ?? this.motoren,
      bedieningen: bedieningen ?? this.bedieningen,
      gewijzigdOp: gewijzigdOp ?? this.gewijzigdOp,
    );
  }

  OpmetingUitvalschermInstellingen metWijzigingsDatum() =>
      copyWith(gewijzigdOp: DateTime.now().toUtc().toIso8601String());

  Map<String, dynamic> toJson() => <String, dynamic>{
    'draagstructuurKleuren': _uniekeKleuren(
      draagstructuurKleuren,
    ).map((item) => item.toJson()).toList(growable: false),
    'doeken': _uniekeDoeken(
      doeken,
    ).map((item) => item.toJson()).toList(growable: false),
    'motoren': _uniekeMotoren(
      motoren,
    ).map((item) => item.toJson()).toList(growable: false),
    'bedieningen': _uniekeTeksten(bedieningen),
    'gewijzigdOp': gewijzigdOp,
  };

  factory OpmetingUitvalschermInstellingen.fromJson(Map<String, dynamic> json) {
    final kleuren = _leesLijst(
      json['draagstructuurKleuren'],
      OpmetingUitvalschermKleur.fromJson,
    );
    final doeken = _leesLijst(
      json['doeken'],
      OpmetingUitvalschermDoek.fromJson,
    );
    final motoren = _leesLijst(
      json['motoren'],
      OpmetingUitvalschermMotor.fromJson,
    );
    final bedieningen = json['bedieningen'] is List
        ? (json['bedieningen'] as List)
              .map((item) => item.toString().trim())
              .where((item) => item.isNotEmpty)
              .toList(growable: false)
        : const <String>[];

    return OpmetingUitvalschermInstellingen(
      draagstructuurKleuren: _kleurenMetStandaard(kleuren),
      doeken: doeken.isEmpty ? standaardDoeken : _uniekeDoeken(doeken),
      motoren: motoren.isEmpty ? standaardMotoren : _uniekeMotoren(motoren),
      bedieningen: bedieningen.isEmpty
          ? standaardBedieningen
          : _uniekeTeksten(bedieningen),
      gewijzigdOp: json['gewijzigdOp']?.toString() ?? '',
    );
  }

  static List<T> _leesLijst<T>(
    Object? waarde,
    T Function(Map<String, dynamic>) maker,
  ) {
    if (waarde is! List) return <T>[];
    return waarde
        .whereType<Map>()
        .map((item) => maker(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  static List<OpmetingUitvalschermKleur> _kleurenMetStandaard(
    Iterable<OpmetingUitvalschermKleur> opgeslagenKleuren,
  ) {
    return _uniekeKleuren(<OpmetingUitvalschermKleur>[
      ...standaardDraagstructuurKleuren,
      ...opgeslagenKleuren,
    ]);
  }

  static List<OpmetingUitvalschermKleur> _uniekeKleuren(
    Iterable<OpmetingUitvalschermKleur> bron,
  ) {
    final ids = <String>{};
    return List<OpmetingUitvalschermKleur>.unmodifiable(
      bron.where((item) => item.naam.trim().isNotEmpty && ids.add(item.id)),
    );
  }

  static List<OpmetingUitvalschermDoek> _uniekeDoeken(
    Iterable<OpmetingUitvalschermDoek> bron,
  ) {
    final ids = <String>{};
    return List<OpmetingUitvalschermDoek>.unmodifiable(
      bron.where((item) => item.code.trim().isNotEmpty && ids.add(item.id)),
    );
  }

  static List<OpmetingUitvalschermMotor> _uniekeMotoren(
    Iterable<OpmetingUitvalschermMotor> bron,
  ) {
    final ids = <String>{};
    return List<OpmetingUitvalschermMotor>.unmodifiable(
      bron.where(
        (item) => item.omschrijving.trim().isNotEmpty && ids.add(item.id),
      ),
    );
  }

  static List<String> _uniekeTeksten(Iterable<String> bron) {
    final ids = <String>{};
    return List<String>.unmodifiable(
      bron
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty && ids.add(item.toLowerCase())),
    );
  }
}
