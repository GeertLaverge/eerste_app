// THIMACO-CONTROLE: VOORZETSCREEN-BEDIENINGEN-UITGEBREID-20260811
// THIMACO-CONTROLE: VOORZETSCREEN-INSTELLINGENMODEL-BEDIENINGEN-20260730-2115
class OpmetingVoorzetscreenPoederkleur {
  const OpmetingVoorzetscreenPoederkleur({
    required this.benaming,
    required this.poedercode,
    required this.poederlakMogelijk,
    required this.natlakMogelijk,
  });

  final String benaming;
  final String poedercode;
  final bool poederlakMogelijk;
  final bool natlakMogelijk;

  String get id =>
      '${benaming.trim().toLowerCase()}|${poedercode.trim().toLowerCase()}';

  String get samenvatting {
    final code = poedercode.trim();
    return code.isEmpty ? benaming.trim() : '${benaming.trim()} · $code';
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'benaming': benaming.trim(),
      'poedercode': poedercode.trim(),
      'poederlakMogelijk': poederlakMogelijk,
      'natlakMogelijk': natlakMogelijk,
    };
  }

  factory OpmetingVoorzetscreenPoederkleur.fromJson(Map<String, dynamic> json) {
    return OpmetingVoorzetscreenPoederkleur(
      benaming: json['benaming']?.toString() ?? '',
      poedercode: json['poedercode']?.toString() ?? '',
      poederlakMogelijk: json['poederlakMogelijk'] == true,
      natlakMogelijk: json['natlakMogelijk'] == true,
    );
  }
}

class OpmetingVoorzetscreenDoek {
  const OpmetingVoorzetscreenDoek({
    required this.code,
    required this.kleur,
    required this.voorzijdeHex,
    required this.achterzijdeHex,
  });

  final String code;
  final String kleur;
  final String voorzijdeHex;
  final String achterzijdeHex;

  String get id => code.trim().toUpperCase();

  String get samenvatting {
    final naam = kleur.trim();
    return naam.isEmpty ? code.trim() : '${code.trim()} · $naam';
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'code': code.trim(),
      'kleur': kleur.trim(),
      'voorzijdeHex': _normaliseerHex(voorzijdeHex),
      'achterzijdeHex': _normaliseerHex(achterzijdeHex),
    };
  }

  factory OpmetingVoorzetscreenDoek.fromJson(Map<String, dynamic> json) {
    final code = json['code']?.toString() ?? '';
    final standaard = standaardKleurenVoorCode(code);

    return OpmetingVoorzetscreenDoek(
      code: code,
      kleur: json['kleur']?.toString() ?? '',
      voorzijdeHex: _normaliseerHex(
        json['voorzijdeHex']?.toString() ?? standaard.$1,
      ),
      achterzijdeHex: _normaliseerHex(
        json['achterzijdeHex']?.toString() ?? standaard.$2,
      ),
    );
  }

  static (String, String) standaardKleurenVoorCode(String code) {
    switch (code.trim().toUpperCase()) {
      case 'SC0202':
        return ('#F0EFE7', '#ECEBE3');
      case 'SC0207':
        return ('#D3D2CB', '#DAD9D2');
      case 'CS3301':
        return ('#6E6966', '#74706D');
      case 'SC3006':
        return ('#4A403A', '#3E3734');
      case 'CS3333':
        return ('#A39B91', '#9A938A');
      case 'SC0606':
        return ('#6B4E3D', '#5C4437');
      case 'SC3030':
        return ('#403B3C', '#353233');
      case 'SC0707':
        return ('#D1CCC3', '#C7C2B9');
      case 'SC0011':
        return ('#7A7D7F', '#717476');
      case 'MSC6060':
        return ('#1C1B1D', '#171719');
      case 'SC0310':
        return ('#484542', '#3A3836');
      default:
        return ('#D8DADD', '#C9CDD1');
    }
  }

  static String _normaliseerHex(String waarde) {
    final tekst = waarde.trim().toUpperCase();
    final zonderHekje = tekst.startsWith('#') ? tekst.substring(1) : tekst;
    if (RegExp(r'^[0-9A-F]{6}$').hasMatch(zonderHekje)) {
      return '#$zonderHekje';
    }
    return '#D8DADD';
  }
}

class OpmetingVoorzetscreenMotor {
  const OpmetingVoorzetscreenMotor({
    required this.type,
    required this.merk,
    required this.omschrijving,
  });

  final String type;
  final String merk;
  final String omschrijving;

  String get id => <String>[
    type.trim().toLowerCase(),
    merk.trim().toLowerCase(),
    omschrijving.trim().toLowerCase(),
  ].join('|');

  String get samenvatting => <String>[
    type.trim(),
    merk.trim(),
    omschrijving.trim(),
  ].where((deel) => deel.isNotEmpty).join(' · ');

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type.trim(),
      'merk': merk.trim(),
      'omschrijving': schoonOmschrijving(omschrijving),
    };
  }

  factory OpmetingVoorzetscreenMotor.fromJson(Map<String, dynamic> json) {
    return OpmetingVoorzetscreenMotor(
      type: json['type']?.toString() ?? '',
      merk: json['merk']?.toString() ?? '',
      omschrijving: schoonOmschrijving(json['omschrijving']?.toString() ?? ''),
    );
  }

  static String schoonOmschrijving(String waarde) {
    return waarde
        .replaceAll(RegExp(r'\b\d+\s*/\s*\d+\b'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

class OpmetingVoorzetscreenInstellingen {
  const OpmetingVoorzetscreenInstellingen({
    this.poederkleuren = const <OpmetingVoorzetscreenPoederkleur>[],
    this.screendoeken = const <OpmetingVoorzetscreenDoek>[],
    this.motoren = const <OpmetingVoorzetscreenMotor>[],
    this.zonnecelMotoren = const <OpmetingVoorzetscreenMotor>[],
    this.bedieningen = const <String>[],
    this.gewijzigdOp = '',
  });

  final List<OpmetingVoorzetscreenPoederkleur> poederkleuren;
  final List<OpmetingVoorzetscreenDoek> screendoeken;
  final List<OpmetingVoorzetscreenMotor> motoren;
  final List<OpmetingVoorzetscreenMotor> zonnecelMotoren;
  final List<String> bedieningen;
  final String gewijzigdOp;

  List<String> get beschikbareBedieningen =>
      _normaliseerTekstLijst(<String>[...standaardBedieningen, ...bedieningen]);

  static final List<OpmetingVoorzetscreenPoederkleur> standaardPoederkleuren =
      List<OpmetingVoorzetscreenPoederkleur>.unmodifiable(
        <OpmetingVoorzetscreenPoederkleur>[
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'Antracietgrijs Rolluiken',
            poedercode: '317032213',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'Bruin Rolluiken',
            poedercode: '317032222',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'Bruin Zonwering',
            poedercode: 'AE80018801920',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8012 Deceuninck',
            poedercode: '8012',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8067 Deceuninck',
            poedercode: '8067',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8068 Deceuninck',
            poedercode: '8068',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8909 Deceuninck',
            poedercode: '8909',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8934 Deceuninck',
            poedercode: '8934',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8935 Deceuninck',
            poedercode: '8935',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'Anodic Natura',
            poedercode: 'AE20107000120',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'Crme-Wit Rolluiken',
            poedercode: '317032221',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'Creme-Wit Zonwering',
            poedercode: 'DS312W8515',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'DB 702 IG 29/70588',
            poedercode: 'DB 702 IG 29/70588',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'DB 703 Tiger 29/82030',
            poedercode: 'DB 703 029/82030',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'Deuctone 6068',
            poedercode: 'Deuctone 6068',
            poederlakMogelijk: false,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'Deuctone 6070',
            poedercode: 'Deuctone 6070',
            poederlakMogelijk: false,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'Deuctone 6909 (RDS 085 60 10)',
            poedercode: 'AE30017012623',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'Grijs Rolluiken',
            poedercode: '317032203',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9005 EE00004905825 Lightning Black',
            poedercode: 'EE00004905825',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9008 Tiger 029/70787 S.I.E.D.',
            poedercode: '029/70787',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'M019',
            poedercode: 'PE50/TR9003HR/73/180',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'M071',
            poedercode: 'PE50/TR9001HR/73/180',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'M080',
            poedercode: 'PE52/TRM9003HR/30/20',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'Naturel Rolluiken',
            poedercode: '317032208',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P115 EG',
            poedercode: 'DS312H8213',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P701 EM',
            poedercode: 'DS542A8300',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P716 EM',
            poedercode: 'DS542A8107',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P716 RM',
            poedercode: 'ZX641A8010',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P721 RM',
            poedercode: 'ZX641A8005',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P723 RM',
            poedercode: 'ZX642A8009',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P732 RM',
            poedercode: 'ZX642A8006',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P737 RM',
            poedercode: 'ZX642A8008',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P739 RM',
            poedercode: 'ZX641A8007',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P899 EM',
            poedercode: 'DS542M8030',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P901 EG',
            poedercode: 'DS312W8039',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P905 RM',
            poedercode: 'ZX641N8002',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P910 EG',
            poedercode: 'DS312W8038',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P910 RM',
            poedercode: 'AE03059114327',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 1001',
            poedercode: 'AE70011960425',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 1013',
            poedercode: 'AE70019420225',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 1013 Coatex',
            poedercode: 'AE03051101320',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 1013 MAT',
            poedercode: 'AE30011101320',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 1013 Reynaers',
            poedercode: 'AE30009002423',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 1013 Tiger 29/10933',
            poedercode: 'RAL 1013 29/10933',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 1014',
            poedercode: 'AE70011960625',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 1015',
            poedercode: 'AE70019920125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 1015 Reynaers',
            poedercode: 'AE30001002523',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 1015 MAT',
            poedercode: 'AE30011101520',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 1015 Tiger 29/15461',
            poedercode: 'RAL 1015 29/15461',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 1015 Tiger 29/15508',
            poedercode: 'RAL 1015 29/15508',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 1018',
            poedercode: 'AE70011200125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 1019',
            poedercode: 'AE70018360425',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 1019 Coatex',
            poedercode: 'AE03051101920',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 1019 MAT',
            poedercode: 'AE30011101920',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 1020',
            poedercode: 'AE70011470225',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 3000',
            poedercode: 'AE70013280125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 3001',
            poedercode: 'AE70013300120',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 3003',
            poedercode: 'AE70013500125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 3004',
            poedercode: 'AE70013720125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 3004 MAT',
            poedercode: 'AE30013300420',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 3005',
            poedercode: 'AE70013860325',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 3005 MAT',
            poedercode: 'AE30013300520',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 3005 Tiger 29/30462',
            poedercode: 'RAL 3005 29/30462',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 3007',
            poedercode: 'AE70013300720',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 3009 Tiger 29/30401',
            poedercode: 'RAL 3009 29/30401',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 3011',
            poedercode: 'AE70013580125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 3011 MAT',
            poedercode: 'AE30013301120',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 3020',
            poedercode: 'AE70013120325',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 3020 MAT',
            poedercode: 'AE30013302020',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 3099 Tiger 29/30402',
            poedercode: 'RAL 3099 29/30402',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 5002',
            poedercode: 'AE70015710225',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 5003',
            poedercode: 'AE70015870225',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 5004',
            poedercode: 'AE70015500420',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 5004 MAT',
            poedercode: 'AE30015500420',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 5008',
            poedercode: 'AE70017830125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 5008 Coatex',
            poedercode: 'AE03055500820',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 5008 MAT',
            poedercode: 'AE300C5500820',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 5009',
            poedercode: 'AE70015670125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 5009 MAT',
            poedercode: 'AE30015500920',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 5010',
            poedercode: 'AE70015600225',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 5010 MAT',
            poedercode: 'AE30015501020',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 5011',
            poedercode: 'AE70015950125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 5011 Tiger 29/40782',
            poedercode: 'RAL 5011 29/40782',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 5012',
            poedercode: 'AE70015310325',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 5013',
            poedercode: 'AE70015810225',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 5014',
            poedercode: 'AE70015270125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 5020 MAT',
            poedercode: 'AE30015502020',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 5023',
            poedercode: 'AE70015610425',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 5024 MAT',
            poedercode: 'AE30015502420',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 6001',
            poedercode: 'AE70016520125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 6003 MAT',
            poedercode: 'AE300C6600320',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 6005 Axalta AE70016830125',
            poedercode: 'AE70016830125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 6005 MAT',
            poedercode: 'AE30016600520',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 6009',
            poedercode: 'AE70016970425',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 6009 Coatex',
            poedercode: 'AE03056600920',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 6009 MAT',
            poedercode: 'AE30016600920',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 6009 Tiger 29/50704',
            poedercode: 'RAL 6009 29/50704',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 6009 Tiger 29/50800',
            poedercode: 'RAL 6009 29/50800',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 6012 MAT',
            poedercode: 'AE30016601220',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 6013',
            poedercode: 'AE70016170525',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 6021 MAT',
            poedercode: 'AE30016602120',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 6064',
            poedercode: 'AE70016970225',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 6099 Tiger 29/50698',
            poedercode: 'RAL 6099 29/50698',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 6999 Tiger 29/50759',
            poedercode: 'RAL 6999 29/50759',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7000 Grau 250 S 29/71358',
            poedercode: 'GRAU 250 S 29/71358',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7001',
            poedercode: 'AE70017200225',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7001 MAT',
            poedercode: 'AE30017700120',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7002 MAT',
            poedercode: 'AE30017700220',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7003',
            poedercode: 'AE70017520125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7003 MAT',
            poedercode: 'AE30017700320',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7004',
            poedercode: 'AE70017260325',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7004 MAT',
            poedercode: 'AE30017700420',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7005',
            poedercode: 'AE70017420525',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7005 Reynaers',
            poedercode: 'AE30017420925',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7005 MAT',
            poedercode: 'AE30017700520',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7006',
            poedercode: 'AE70018170125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7006 Reynaers',
            poedercode: 'AE30018172625',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7006 Coatex',
            poedercode: 'AE03057700620',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7006 MAT',
            poedercode: 'AE30017700620',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7006 Tiger 29/73223',
            poedercode: 'RAL 7006 29/73223',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7009',
            poedercode: 'AE70017650225',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7009 MAT',
            poedercode: 'AE30017700920',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7010',
            poedercode: 'AE70017650325',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7010 MAT',
            poedercode: 'AE30017701020',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7010 Tiger 29/71569',
            poedercode: 'RAL 7010 29/71569',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7011',
            poedercode: 'AE70017620325',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7011 Reynaers',
            poedercode: 'AE30017622625',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7011 MAT',
            poedercode: 'AE30017620325',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7012',
            poedercode: 'AE70017650125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7012 Coatex',
            poedercode: 'AE03057701220',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7012 MAT',
            poedercode: 'AE30017701220',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7013',
            poedercode: 'AE70018650125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7015',
            poedercode: 'AE70017730125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7015 MAT',
            poedercode: 'AE30017701520',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7015 Tiger 29/71719',
            poedercode: 'RAL 7015 29/71719',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7015 Tiger 29/71723',
            poedercode: 'RAL 7015 29/71723',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7016',
            poedercode: 'AE70017620225',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7016 Coatex',
            poedercode: 'AE03057701620',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7016 MAT',
            poedercode: 'AE30017701620',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7016 Reynaers',
            poedercode: 'AE30007005023',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7016 Tiger 29/71289',
            poedercode: 'RAL 7016 29/71289',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7016 Tiger 29/71334',
            poedercode: 'RAL 7016 29/71334',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7016 Tiger 29/73570',
            poedercode: 'RAL 7016 29/73570',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7021',
            poedercode: 'AE70017820125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7021 Reynaers',
            poedercode: 'AE30007005123',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7021 Coatex',
            poedercode: 'AE03057702120',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7021 MAT',
            poedercode: 'AE30017702120',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7021 Tiger 29/71263',
            poedercode: 'RAL 7021 29/71263',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7021 Tiger 29/71335',
            poedercode: 'RAL 7021 29/71335',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7021 Tiger 29/72183',
            poedercode: 'RAL 7021 29/72183',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7022',
            poedercode: 'AE70017750225',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7022 Coatex',
            poedercode: 'AE03057702220',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7022 MAT',
            poedercode: 'AE30017702220',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7022 Tiger 29/72932',
            poedercode: 'RAL 7022 29/72932',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7023',
            poedercode: 'AE70017320625',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7023 Coatex',
            poedercode: 'AE03057702320',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7023 MAT',
            poedercode: 'AE30017702320',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7023 Tiger 29/72362 --> 29/7B297',
            poedercode: '29/72362 --> 29/7B297',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7024',
            poedercode: 'AE70017710125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7024 Reynaers',
            poedercode: 'AE30007004923',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7024 Coatex',
            poedercode: 'AE03057702420',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7024 MAT',
            poedercode: 'AE30017702420',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7024 Tiger 29/71795',
            poedercode: 'RAL 7024 29/71795',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7026',
            poedercode: 'AE70017850125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7026 MAT',
            poedercode: 'AE30017702620',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7030',
            poedercode: 'AE70017320325',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7030 Coatex',
            poedercode: 'AE03057703020',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7030 MAT',
            poedercode: 'AE30017703020',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7030 Tiger 29/71715',
            poedercode: 'RAL 7030 29/71715',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7030 Tiger 29/71720',
            poedercode: 'RAL 7030 29/71720',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7031',
            poedercode: 'AE70017530125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7031 MAT',
            poedercode: 'AE300C7703120',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7031 Oxyplast PE50/TR7031HR/73/180',
            poedercode: 'PE50/TR7031HR/73/180',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7032',
            poedercode: 'AE70017120425',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7032 MAT',
            poedercode: 'AE30017703220',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7032 Tiger 29/72364',
            poedercode: 'RAL 7032 29/72364',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7033',
            poedercode: 'AE70017420325',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7033 Coatex',
            poedercode: 'AE03057703320',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7033 MAT',
            poedercode: 'AE30017703320',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7034',
            poedercode: 'AE70017320525',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7034 MAT',
            poedercode: 'AE30017703420',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7035',
            poedercode: 'AE70019870225',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7035 Coatex',
            poedercode: 'AE03057703520',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7035 MAT',
            poedercode: 'AE30017703520',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7036',
            poedercode: 'AE70017210125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7036 MAT',
            poedercode: 'AE30017703620',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7037',
            poedercode: 'AE70017410125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7037 MAT',
            poedercode: 'AE30017703720',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7037 Oxyplast PE52/THM7037HR/30/200',
            poedercode: 'PE52/THM7037HR/30/20',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7037 Tiger 29/70349',
            poedercode: 'RAL 7037 029/70349',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7037 Tiger 29/72184',
            poedercode: 'RAL 7037 029/72184',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7038',
            poedercode: 'AE70017120925',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7038 MAT',
            poedercode: 'AE30017703820',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7039',
            poedercode: 'AE70017580225',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7039 Coatex',
            poedercode: 'AE03057703920',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7039 MAT',
            poedercode: 'AE30017703920',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7039 Tiger 29/71716',
            poedercode: 'RAL 7039 29/71716',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7039 Tiger 29/71721',
            poedercode: 'RAL 7039 29/71721',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7039 Tiger 29/72179',
            poedercode: 'RAL 7039 29/72179',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7039 Tiger 29/72881',
            poedercode: 'RAL 7039 29/72881',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7040',
            poedercode: 'AE70017130525',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7040 MAT',
            poedercode: 'AE30017704020',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7040 Tiger 29/72710',
            poedercode: 'RAL 7040 29/72710',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7040 Tiger 29/90316',
            poedercode: 'RAL 7040 29/90316',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7042',
            poedercode: 'AE70017320925',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7042 MAT',
            poedercode: 'AE30017704220',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7043',
            poedercode: 'AE70017720325',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7043 MAT',
            poedercode: 'AE300C7704320',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7044',
            poedercode: 'AE70019820325',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7044 Coatex',
            poedercode: 'AE03057704420',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7044 MAT',
            poedercode: 'AE30017704420',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7044 Tiger 29/71718',
            poedercode: 'RAL 7044 29/71718',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7045',
            poedercode: 'AE70017100225',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7045 MAT',
            poedercode: 'AE30017704520',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7046',
            poedercode: 'AE70017370125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7046 MAT',
            poedercode: 'AE30017704620',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7047',
            poedercode: 'AE70019900225',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7047 MAT',
            poedercode: 'AE30017704720',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8000',
            poedercode: 'AE70018800020',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8001',
            poedercode: 'AE70018120225',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8001 MAT',
            poedercode: 'AE300C8800120',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8002 MAT',
            poedercode: 'AE30018800220',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8003',
            poedercode: 'AE70018100325',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8003 MAT',
            poedercode: 'AE30018800320',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8003 Tiger 29/60898',
            poedercode: 'RAL 8003 29/60898',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8004 MAT',
            poedercode: 'AE30018800420',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8008',
            poedercode: 'AE70018220125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8009 Tiger 29/60731',
            poedercode: 'RAL 8009 29/60731',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8011',
            poedercode: 'AE70018510125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8012',
            poedercode: 'AE70018610225',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8014',
            poedercode: 'AE70018720125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8014 MAT',
            poedercode: 'AE30018801420',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8014 Tiger 29/60488',
            poedercode: 'RAL 8014 29/60488',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8014 Tiger 29/60740',
            poedercode: 'RAL 8014 29/60740',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8015 MAT',
            poedercode: 'AE30018801520',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8016',
            poedercode: 'AE70018915025',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8016 MAT',
            poedercode: 'AE300C8801620',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8017',
            poedercode: 'AE70018910325',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8017 MAT',
            poedercode: 'AE300C8801720',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8019 (Bel)',
            poedercode: 'AE70018870925',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8019 (Hol)',
            poedercode: 'AE70018870125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8019 Akzo SM 079E',
            poedercode: 'RAL 8019 AKZO SM079E',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8019 Coatex',
            poedercode: 'AE03058801920',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8019 MAT',
            poedercode: 'AE300C8801920',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8019 Tiger 29/60674',
            poedercode: 'RAL 8019 29/60674',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8019 Tiger 29/60735',
            poedercode: 'RAL 8019 29/60735',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8019 Tiger 29/70795',
            poedercode: 'RAL 8019 29/70795',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8022',
            poedercode: 'AE70014910125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8022 Coatex',
            poedercode: 'AE03058802220',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8022 MAT',
            poedercode: 'AE30018802220',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8022 Tiger 29/60861',
            poedercode: 'RAL 8022 29/60861',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8023',
            poedercode: 'AE70018140625',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8025',
            poedercode: 'AE70018360525',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8025 MAT',
            poedercode: 'AE30018802520',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8028',
            poedercode: 'AE70018620125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9001',
            poedercode: 'AE70019220225',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9001 Oxyplast PE50/TR9001HR/73/180',
            poedercode: 'PE50/TR9001HR/73/180',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9001 Coatex',
            poedercode: 'AE03059900120',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9001 Tiger 29/10553',
            poedercode: '29/10553',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9001 Tiger 29/11089',
            poedercode: 'RAL 9001 29/11089',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9002',
            poedercode: 'AE70019570225',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9002 Coatex',
            poedercode: 'AE03059900220',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9002 MAT',
            poedercode: 'AE300C9900220',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9003',
            poedercode: 'AE70019171025',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9003 MAT',
            poedercode: 'AE300C9900320',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9004',
            poedercode: 'AE70014902425',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9004 Coatex',
            poedercode: 'AE03054900420',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9004 MAT',
            poedercode: 'AE300C4900420',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9004 Tiger 029/80271',
            poedercode: 'RAL 9004 029/80271',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9005',
            poedercode: 'AE70014900520',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9005 Coatex',
            poedercode: 'AE03054900520',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9005 MAT',
            poedercode: 'AE30014900520',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9005 Tiger 29/80081',
            poedercode: 'RAL 9005 29/80081',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9005 Tiger 29/80303',
            poedercode: 'RAL 9005 29/80303',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9005 Tiger 29/80070',
            poedercode: 'RAL 9005 29/80070',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9006',
            poedercode: 'AE80157900620',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9006 Coatex',
            poedercode: 'AE03257900620',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9006 MAT',
            poedercode: 'AE30217900620',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9006 Tiger 29/71724',
            poedercode: 'RAL 9006 29/71724',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9006 Tiger 29/90024',
            poedercode: 'RAL 9006 29/90024',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9006 Tiger 029/90080',
            poedercode: '029/90080',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9006 Tiger 29/90146',
            poedercode: 'RAL 9006 29/90146',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9006 Tiger 29/90198',
            poedercode: 'RAL 9006 29/90198',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9006 Tiger 68/90006',
            poedercode: 'RAL 9006 68/90006',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9007',
            poedercode: 'AE80157900720',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9007 Coatex',
            poedercode: 'AE03257900720',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9007 MAT',
            poedercode: 'AE30217900720',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9007 Tiger 29/71725',
            poedercode: 'RAL 9007 29/71725',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9007 Tiger 29/72004',
            poedercode: 'RAL 9007 29/72004',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9007 Tiger 29/90147',
            poedercode: 'RAL 9007 29/90147',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9007 Tiger 68/90007',
            poedercode: 'RAL 9007 68/90007',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9008 Coatex',
            poedercode: 'AE03257900820',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9009 Tiger 29/80077',
            poedercode: 'RAL 9009 29/80077',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9010 Reynaers',
            poedercode: 'AE30009002323',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9010 (Bel)',
            poedercode: 'AE90019148021',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9010 (Hol)',
            poedercode: 'AE70019100125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9010 Coatex',
            poedercode: 'AE03059901020',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9010 GL Oxyplast PE50/TR9140/90/180/4',
            poedercode: 'PE50/TR9140/90/180/4',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9010 Tiger 29/10797',
            poedercode: 'RAL 9010 29/10797',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9010 Oxyplast PE50/TR9010HR/73/180',
            poedercode: 'PE50/TR9010HR/73/180',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9010 Tiger 29/11091',
            poedercode: 'RAL 9010 29/11091',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9011',
            poedercode: 'AE70014960125',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9011 Coatex',
            poedercode: 'AE03054901120',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9011 MAT',
            poedercode: 'AE30014901120',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9016',
            poedercode: 'AE70019101525',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9016 Coatex',
            poedercode: 'AE03059901620',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9016 MAT',
            poedercode: 'AE300C9901620',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9016 Tiger 29/10246',
            poedercode: 'RAL 9016 29/10246',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9017',
            poedercode: 'AE70014900725',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9017 MAT',
            poedercode: 'AE300C4901720',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9018',
            poedercode: 'AE70019820525',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9018 MAT',
            poedercode: 'AE30019901820',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9022',
            poedercode: 'AE80317005525',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'Wit Rolluiken',
            poedercode: '317032201',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'Wit Screen/Serrola',
            poedercode: 'DS112W8042',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7021 Tiger 067/71764',
            poedercode: '067/71764',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9004 Tiger 067/80057',
            poedercode: 'RAL 9004 067/80057',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7022 Tiger 067/71175',
            poedercode: 'RAL 7022 067/71175',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7023 Tiger 067/71731',
            poedercode: 'RAL 7023 067/71731',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7030 Tiger 067/71756',
            poedercode: 'RAL 7030 067/71756',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7032 Tiger 067/71733',
            poedercode: 'RAL 7032 067/71733',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7037 Tiger 067/71293',
            poedercode: 'RAL 7037 067/71293',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7039 Tiger 067/71291',
            poedercode: 'RAL 7039 067/71291',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8019 Tiger 068/71752',
            poedercode: 'RAL 8019 068/71752',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9001 Tiger 067/15115',
            poedercode: 'RAL 9001 067/15115',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9005 Tiger 067/80381',
            poedercode: 'RAL 9005 067/80381',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9010 Tiger 067/71259',
            poedercode: 'RAL 9010 067/71259',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9016 Tiger 067/10079',
            poedercode: 'RAL 9016 067/10079',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 901TC Tiger 067/10426',
            poedercode: 'RAL 901TC 067/10426',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7016 Tiger 067/70190',
            poedercode: 'RAL 7016 067/70190',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P704 RM',
            poedercode: 'ZX642A8027',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P731 RM',
            poedercode: 'AE03057357127',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P706 RM',
            poedercode: 'ZX642A8028',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P744 RM',
            poedercode: 'ZX642A8025',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9010 MAT',
            poedercode: 'AE30019901020',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P901 RM',
            poedercode: 'AE03051108327',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P119 RM',
            poedercode: 'AE03008102627',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P511 EM',
            poedercode: 'ZS542B8009',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P890 RM',
            poedercode: 'AE03058076027',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P701 RM',
            poedercode: 'AE03007495527',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P916 EG',
            poedercode: 'DS442W8091',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P305 RM',
            poedercode: 'AE03018066527',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P730 RM',
            poedercode: 'ZX642A8026',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P612RM',
            poedercode: 'AE03056135727',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P822RM',
            poedercode: 'ZX641M8010',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9011 Tiger 29/80527',
            poedercode: '9011 029/80527',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 5011 Coatex AE03055501120',
            poedercode: 'AE03055501120',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7009 Coatex',
            poedercode: 'AE03057700920',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9001 MAT',
            poedercode: 'AE300C9900120',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P906 EM',
            poedercode: 'AE20217068420',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7000 MAT',
            poedercode: 'AE30017700020',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8017 Tiger 029/61333',
            poedercode: '029/61333',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: '905 PT RWMXD-0454',
            poedercode: '905 PT RWMXD-0454',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8016 Tiger 029/61311',
            poedercode: '8016 029/61311',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P699 EM',
            poedercode: 'ZS542G8015',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 6033 MAT',
            poedercode: 'AE30016603320',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7037 Coatex',
            poedercode: 'AE03057703720',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7036 Tiger 029/72859',
            poedercode: '7036 29/72859',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9011 Tiger 067/80296',
            poedercode: '9011 067/80296',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9017 Coatex',
            poedercode: 'AE03054901720',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 5019 MAT',
            poedercode: 'AE30015501920',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7032 Tiger 029/72073',
            poedercode: '7032 029/72073',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8016 Coatex',
            poedercode: 'AE03058801620',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8011 Tiger 029/61344',
            poedercode: '8011 029/61344',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7016 Tiger 068/70153',
            poedercode: '7016 068/70153',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7044 Tiger 068/71732',
            poedercode: '7044 068/71732',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7022 Tiger 029/71740',
            poedercode: '7022 029/71740',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'IGP Grijs 5803E71387A10-K20',
            poedercode: '5803E71387A10-K20',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7034 Coatex',
            poedercode: 'AE03057703420',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7038 Coatex',
            poedercode: 'AE03057703820',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 8019 AE70018801920',
            poedercode: 'AE70018801920',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P822 EM',
            poedercode: 'DS542M8064',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P609 RM',
            poedercode: 'ZX641G8018',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7021 Tiger 68/70206',
            poedercode: 'RAL 7021 68/70206',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'SD201C8210621 Dark Bronze',
            poedercode: 'SD201C8210621',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P917 RM',
            poedercode: 'ZX641N8013',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'Anodic Brown',
            poedercode: 'AE20108000420',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9010 Tiger 029/10674',
            poedercode: '029/10674',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 6005 Coatex AE03056600520',
            poedercode: 'AE03056600520',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'Rost Matt Fs Met. 067/60116',
            poedercode: '067/60116',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'Anodic Gold',
            poedercode: 'AE20111000820',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'AE20108000320 Anodic Bronze',
            poedercode: 'AE20108000320',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7021 EF 154-0492',
            poedercode: 'AE03004058227',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL +/-1019 Fine Texture Quartz 2',
            poedercode: 'AE03411122920',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7008 MAT',
            poedercode: 'AE30017700820',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9006 Tiger 029/90434',
            poedercode: '029/90434',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'P712 RM Structuur',
            poedercode: 'ZX642A8038',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 5022 MAT',
            poedercode: 'AE30015502220',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'SuprAnodic Brown SD201C8000420',
            poedercode: 'SD201C8000420',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9005 SD030C4900520',
            poedercode: 'SD030C4900520',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'SuprAnodic Bronze Matt SD201C8000320',
            poedercode: 'SD201C8000320',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7044 Silk Grey Optimum SD030C7704420',
            poedercode: 'SD030C7704420',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9007 Tiger 029/90195',
            poedercode: '029/90195',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 1015 Tiger 29/15518',
            poedercode: '29/15518',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 6028 AE70016720325',
            poedercode: 'AE70016720325',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 6010 AE70016470125',
            poedercode: 'AE70016470125',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 1036 Tiger 29/90012',
            poedercode: '29/90012',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9001 Hollands',
            poedercode: '9001 Eigen Natlak',
            poederlakMogelijk: false,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7021 Akzo Nobel YL321F INT D2525 TEXT FN',
            poedercode: 'YL321F INT D2525',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 7016 Akzo Nobel YL316F INT D2525',
            poedercode: 'YL316F',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9004 Akzo Nobel YN304F INT D2525',
            poedercode: 'YN304F',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9005 Akzo Nobel YN305F INT D2525',
            poedercode: 'YN305F',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'RAL 9011 Akzo Nobel YN311F INT D2525',
            poedercode: 'YN311F',
            poederlakMogelijk: true,
            natlakMogelijk: true,
          ),
          OpmetingVoorzetscreenPoederkleur(
            benaming: 'Axalta AE03117049620 January 6',
            poedercode: 'AE03117049620',
            poederlakMogelijk: true,
            natlakMogelijk: false,
          ),
        ],
      );

  static final List<OpmetingVoorzetscreenDoek> standaardScreendoeken =
      List<OpmetingVoorzetscreenDoek>.unmodifiable(<OpmetingVoorzetscreenDoek>[
        OpmetingVoorzetscreenDoek(
          code: 'SC0202',
          kleur: 'White',
          voorzijdeHex: OpmetingVoorzetscreenDoek.standaardKleurenVoorCode(
            'SC0202',
          ).$1,
          achterzijdeHex: OpmetingVoorzetscreenDoek.standaardKleurenVoorCode(
            'SC0202',
          ).$2,
        ),
        OpmetingVoorzetscreenDoek(
          code: 'SC0207',
          kleur: 'White - Pearl',
          voorzijdeHex: OpmetingVoorzetscreenDoek.standaardKleurenVoorCode(
            'SC0207',
          ).$1,
          achterzijdeHex: OpmetingVoorzetscreenDoek.standaardKleurenVoorCode(
            'SC0207',
          ).$2,
        ),
        OpmetingVoorzetscreenDoek(
          code: 'CS3301',
          kleur: 'Oyster - Shell',
          voorzijdeHex: OpmetingVoorzetscreenDoek.standaardKleurenVoorCode(
            'CS3301',
          ).$1,
          achterzijdeHex: OpmetingVoorzetscreenDoek.standaardKleurenVoorCode(
            'CS3301',
          ).$2,
        ),
        OpmetingVoorzetscreenDoek(
          code: 'SC3006',
          kleur: 'Charcoal Bronze',
          voorzijdeHex: OpmetingVoorzetscreenDoek.standaardKleurenVoorCode(
            'SC3006',
          ).$1,
          achterzijdeHex: OpmetingVoorzetscreenDoek.standaardKleurenVoorCode(
            'SC3006',
          ).$2,
        ),
        OpmetingVoorzetscreenDoek(
          code: 'CS3333',
          kleur: 'Sandstone',
          voorzijdeHex: OpmetingVoorzetscreenDoek.standaardKleurenVoorCode(
            'CS3333',
          ).$1,
          achterzijdeHex: OpmetingVoorzetscreenDoek.standaardKleurenVoorCode(
            'CS3333',
          ).$2,
        ),
        OpmetingVoorzetscreenDoek(
          code: 'SC0606',
          kleur: 'Bronze',
          voorzijdeHex: OpmetingVoorzetscreenDoek.standaardKleurenVoorCode(
            'SC0606',
          ).$1,
          achterzijdeHex: OpmetingVoorzetscreenDoek.standaardKleurenVoorCode(
            'SC0606',
          ).$2,
        ),
        OpmetingVoorzetscreenDoek(
          code: 'SC3030',
          kleur: 'Charcoal',
          voorzijdeHex: OpmetingVoorzetscreenDoek.standaardKleurenVoorCode(
            'SC3030',
          ).$1,
          achterzijdeHex: OpmetingVoorzetscreenDoek.standaardKleurenVoorCode(
            'SC3030',
          ).$2,
        ),
        OpmetingVoorzetscreenDoek(
          code: 'SC0707',
          kleur: 'Pearl - Pearl',
          voorzijdeHex: OpmetingVoorzetscreenDoek.standaardKleurenVoorCode(
            'SC0707',
          ).$1,
          achterzijdeHex: OpmetingVoorzetscreenDoek.standaardKleurenVoorCode(
            'SC0707',
          ).$2,
        ),
        OpmetingVoorzetscreenDoek(
          code: 'SC0011',
          kleur: 'Grey - Grey',
          voorzijdeHex: OpmetingVoorzetscreenDoek.standaardKleurenVoorCode(
            'SC0011',
          ).$1,
          achterzijdeHex: OpmetingVoorzetscreenDoek.standaardKleurenVoorCode(
            'SC0011',
          ).$2,
        ),
        OpmetingVoorzetscreenDoek(
          code: 'MSC6060',
          kleur: 'Pure Black',
          voorzijdeHex: OpmetingVoorzetscreenDoek.standaardKleurenVoorCode(
            'MSC6060',
          ).$1,
          achterzijdeHex: OpmetingVoorzetscreenDoek.standaardKleurenVoorCode(
            'MSC6060',
          ).$2,
        ),
        OpmetingVoorzetscreenDoek(
          code: 'SC0310',
          kleur: 'Grey - Charcoal',
          voorzijdeHex: OpmetingVoorzetscreenDoek.standaardKleurenVoorCode(
            'SC0310',
          ).$1,
          achterzijdeHex: OpmetingVoorzetscreenDoek.standaardKleurenVoorCode(
            'SC0310',
          ).$2,
        ),
      ]);

  static final List<OpmetingVoorzetscreenMotor> standaardMotoren =
      List<OpmetingVoorzetscreenMotor>.unmodifiable(
        const <OpmetingVoorzetscreenMotor>[
          OpmetingVoorzetscreenMotor(
            type: 'Bekabeld',
            merk: 'SOMFY',
            omschrijving: 'Altea ZIP 50 WT',
          ),
          OpmetingVoorzetscreenMotor(
            type: 'Bekabeld',
            merk: 'SOMFY',
            omschrijving: 'LT50 Ceres',
          ),
          OpmetingVoorzetscreenMotor(
            type: 'Bekabeld',
            merk: 'SELVE',
            omschrijving: 'Selve SE PRO Short',
          ),
          OpmetingVoorzetscreenMotor(
            type: 'Bekabeld',
            merk: 'SELVE',
            omschrijving: 'Selve SE Plus',
          ),
          OpmetingVoorzetscreenMotor(
            type: 'Bekabeld',
            merk: 'SELVE',
            omschrijving: 'Selve SEZ',
          ),
          OpmetingVoorzetscreenMotor(
            type: 'Bekabeld',
            merk: 'SELVE',
            omschrijving: 'Selve SP',
          ),
          OpmetingVoorzetscreenMotor(
            type: 'Draadloos',
            merk: 'SOMFY',
            omschrijving: 'Sunea Screen 40 IO',
          ),
          OpmetingVoorzetscreenMotor(
            type: 'Draadloos',
            merk: 'SOMFY',
            omschrijving: 'Sunilus 50 IO',
          ),
          OpmetingVoorzetscreenMotor(
            type: 'Draadloos',
            merk: 'SELVE',
            omschrijving: 'Selve SE Plus RC',
          ),
          OpmetingVoorzetscreenMotor(
            type: 'Draadloos',
            merk: 'SELVE',
            omschrijving: 'Selve SEZ RC',
          ),
        ],
      );

  static final List<OpmetingVoorzetscreenMotor> standaardZonnecelMotoren =
      List<OpmetingVoorzetscreenMotor>.unmodifiable(
        const <OpmetingVoorzetscreenMotor>[
          OpmetingVoorzetscreenMotor(
            type: 'Draadloos',
            merk: 'BREL',
            omschrijving: 'Brel Solaris 35mm BLE35-13SHU (13Nm)',
          ),
          OpmetingVoorzetscreenMotor(
            type: 'Draadloos',
            merk: 'SOMFY',
            omschrijving: 'Sunea Screen 40 IO Solar',
          ),
        ],
      );

  static const List<String> standaardBedieningen = <String>[
    'Geen',
    'Inbouwschakelaar',
    'Handzender Somfy situo 1',
    'Handzender Somfy situo 5',
    'Muurzender Somfy Amy',
    'Handzender Brel 1 kanaals',
    'Handzender Brel 15 kanaals',
    'Wandzender Brel 1 kanaals',
    'Wandzender Brel 15 kanaals',
  ];

  factory OpmetingVoorzetscreenInstellingen.standaard() {
    return OpmetingVoorzetscreenInstellingen(
      poederkleuren: standaardPoederkleuren,
      screendoeken: standaardScreendoeken,
      motoren: standaardMotoren,
      zonnecelMotoren: standaardZonnecelMotoren,
      bedieningen: standaardBedieningen,
    );
  }

  OpmetingVoorzetscreenInstellingen copyWith({
    List<OpmetingVoorzetscreenPoederkleur>? poederkleuren,
    List<OpmetingVoorzetscreenDoek>? screendoeken,
    List<OpmetingVoorzetscreenMotor>? motoren,
    List<OpmetingVoorzetscreenMotor>? zonnecelMotoren,
    List<String>? bedieningen,
    String? gewijzigdOp,
  }) {
    return OpmetingVoorzetscreenInstellingen(
      poederkleuren: poederkleuren ?? this.poederkleuren,
      screendoeken: screendoeken ?? this.screendoeken,
      motoren: motoren ?? this.motoren,
      zonnecelMotoren: zonnecelMotoren ?? this.zonnecelMotoren,
      bedieningen: bedieningen ?? this.bedieningen,
      gewijzigdOp: gewijzigdOp ?? this.gewijzigdOp,
    );
  }

  OpmetingVoorzetscreenInstellingen metWijzigingsDatum() {
    return copyWith(gewijzigdOp: DateTime.now().toUtc().toIso8601String());
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'poederkleuren': _normaliseerPoederkleuren(
        poederkleuren,
      ).map((item) => item.toJson()).toList(growable: false),
      'screendoeken': _normaliseerDoeken(
        screendoeken,
      ).map((item) => item.toJson()).toList(growable: false),
      'motoren': _normaliseerMotoren(
        motoren,
      ).map((item) => item.toJson()).toList(growable: false),
      'zonnecelMotoren': _normaliseerMotoren(
        zonnecelMotoren,
      ).map((item) => item.toJson()).toList(growable: false),
      'bedieningen': _normaliseerTekstLijst(bedieningen),
      'gewijzigdOp': gewijzigdOp,
    };
  }

  factory OpmetingVoorzetscreenInstellingen.fromJson(
    Map<String, dynamic> json,
  ) {
    return OpmetingVoorzetscreenInstellingen(
      poederkleuren: _leesLijst(
        json['poederkleuren'],
        OpmetingVoorzetscreenPoederkleur.fromJson,
      ),
      screendoeken: _leesLijst(
        json['screendoeken'],
        OpmetingVoorzetscreenDoek.fromJson,
      ),
      motoren: _leesLijst(json['motoren'], OpmetingVoorzetscreenMotor.fromJson),
      zonnecelMotoren: _leesLijst(
        json['zonnecelMotoren'],
        OpmetingVoorzetscreenMotor.fromJson,
      ),
      bedieningen: _leesTekstLijst(json['bedieningen']),
      gewijzigdOp: json['gewijzigdOp']?.toString() ?? '',
    );
  }

  static List<OpmetingVoorzetscreenPoederkleur> _normaliseerPoederkleuren(
    Iterable<OpmetingVoorzetscreenPoederkleur> waarden,
  ) {
    final resultaat = <OpmetingVoorzetscreenPoederkleur>[];
    final gebruikt = <String>{};
    for (final waarde in waarden) {
      if (waarde.benaming.trim().isEmpty || !gebruikt.add(waarde.id)) continue;
      resultaat.add(waarde);
    }
    return List<OpmetingVoorzetscreenPoederkleur>.unmodifiable(resultaat);
  }

  static List<OpmetingVoorzetscreenDoek> _normaliseerDoeken(
    Iterable<OpmetingVoorzetscreenDoek> waarden,
  ) {
    final resultaat = <OpmetingVoorzetscreenDoek>[];
    final gebruikt = <String>{};
    for (final waarde in waarden) {
      if (waarde.code.trim().isEmpty || !gebruikt.add(waarde.id)) continue;
      resultaat.add(waarde);
    }
    return List<OpmetingVoorzetscreenDoek>.unmodifiable(resultaat);
  }

  static List<OpmetingVoorzetscreenMotor> _normaliseerMotoren(
    Iterable<OpmetingVoorzetscreenMotor> waarden,
  ) {
    final resultaat = <OpmetingVoorzetscreenMotor>[];
    final gebruikt = <String>{};
    for (final waarde in waarden) {
      final schoon = OpmetingVoorzetscreenMotor(
        type: waarde.type.trim(),
        merk: waarde.merk.trim(),
        omschrijving: OpmetingVoorzetscreenMotor.schoonOmschrijving(
          waarde.omschrijving,
        ),
      );
      if (schoon.omschrijving.isEmpty || !gebruikt.add(schoon.id)) continue;
      resultaat.add(schoon);
    }
    return List<OpmetingVoorzetscreenMotor>.unmodifiable(resultaat);
  }

  static List<String> _normaliseerTekstLijst(Iterable<String> waarden) {
    final resultaat = <String>[];
    final gebruikt = <String>{};
    for (final waarde in waarden) {
      final tekst = waarde.trim();
      if (tekst.isEmpty || !gebruikt.add(tekst.toLowerCase())) continue;
      resultaat.add(tekst);
    }
    return List<String>.unmodifiable(resultaat);
  }

  static List<String> _leesTekstLijst(Object? waarde) {
    if (waarde is! List) return const <String>[];
    return _normaliseerTekstLijst(waarde.map((item) => item?.toString() ?? ''));
  }

  static List<T> _leesLijst<T>(
    Object? waarde,
    T Function(Map<String, dynamic> json) maker,
  ) {
    if (waarde is! List) return <T>[];
    return waarde
        .whereType<Map>()
        .map((item) => maker(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }
}
