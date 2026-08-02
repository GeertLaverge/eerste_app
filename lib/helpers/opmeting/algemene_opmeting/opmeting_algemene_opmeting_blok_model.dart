// THIMACO-CONTROLE: ALGEMENE-OPMETING-KM-PRIJS-STANDAARD-VERBORGEN-20260802

enum OpmetingAlgemeneOpmetingBlokType {
  tekst,
  prijs;

  String get jsonWaarde => name;

  static OpmetingAlgemeneOpmetingBlokType fromJson(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase();
    return tekst == 'prijs'
        ? OpmetingAlgemeneOpmetingBlokType.prijs
        : OpmetingAlgemeneOpmetingBlokType.tekst;
  }
}

enum OpmetingAlgemenePrijsSoort {
  aankoop('aankoop', 'Aankoopprijs', 'A'),
  verkoop('verkoop', 'Verkoopprijs', 'V');

  const OpmetingAlgemenePrijsSoort(this.jsonWaarde, this.label, this.korteCode);

  final String jsonWaarde;
  final String label;
  final String korteCode;

  String get cirkelTeken => this == aankoop ? 'Ⓐ' : 'Ⓥ';

  static OpmetingAlgemenePrijsSoort fromJson(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase();
    for (final soort in values) {
      if (soort.jsonWaarde.toLowerCase() == tekst ||
          soort.name.toLowerCase() == tekst) {
        return soort;
      }
    }

    // Oude prijsblokken kregen vóór deze uitbreiding altijd de algemene
    // winstmarge. Daarom worden ze veilig als aankoopprijs ingelezen.
    return OpmetingAlgemenePrijsSoort.aankoop;
  }
}

enum OpmetingAlgemenePrijsEenheid {
  stuk('stuk', 'stuk'),
  meter('meter', 'm'),
  lopendeMeter('lopendeMeter', 'L/M'),
  kilometer('kilometer', 'KM'),
  vierkanteMeter('vierkanteMeter', 'm²'),
  uur('uur', 'uur'),
  vastBedrag('vastBedrag', 'vast bedrag');

  const OpmetingAlgemenePrijsEenheid(this.jsonWaarde, this.label);

  final String jsonWaarde;
  final String label;

  static OpmetingAlgemenePrijsEenheid fromJson(Object? waarde) {
    final tekst = waarde?.toString().trim();
    for (final eenheid in values) {
      if (eenheid.jsonWaarde == tekst || eenheid.name == tekst) {
        return eenheid;
      }
    }
    if (tekst?.toLowerCase() == 'km') {
      return OpmetingAlgemenePrijsEenheid.kilometer;
    }
    return OpmetingAlgemenePrijsEenheid.stuk;
  }
}

class OpmetingAlgemeneOpmetingBlok {
  const OpmetingAlgemeneOpmetingBlok({
    required this.id,
    required this.type,
    this.titel = '',
    this.omschrijving = '',
    this.hoeveelheid = 1,
    this.eenheid = OpmetingAlgemenePrijsEenheid.stuk,
    this.eenheidsprijsExclBtw = 0,
    this.bronPrijsregelId = '',
    this.prijsSoort = OpmetingAlgemenePrijsSoort.aankoop,
    this.toonOpOfferte = true,
    this.toonPrijsOpOfferte = false,
  });

  final String id;
  final OpmetingAlgemeneOpmetingBlokType type;
  final String titel;
  final String omschrijving;
  final double hoeveelheid;
  final OpmetingAlgemenePrijsEenheid eenheid;
  final double eenheidsprijsExclBtw;
  final String bronPrijsregelId;
  final OpmetingAlgemenePrijsSoort prijsSoort;

  /// Bepaalt of de omschrijving van dit blok op de klantofferte staat.
  final bool toonOpOfferte;

  /// Bepaalt alleen of het bedrag afzonderlijk op de klantofferte staat.
  /// Het bedrag blijft ook wanneer dit false is volledig meegerekend.
  final bool toonPrijsOpOfferte;

  bool get isPrijs => type == OpmetingAlgemeneOpmetingBlokType.prijs;

  bool get isAankoopprijs {
    return isPrijs && prijsSoort == OpmetingAlgemenePrijsSoort.aankoop;
  }

  bool get isVerkoopprijs {
    return isPrijs && prijsSoort == OpmetingAlgemenePrijsSoort.verkoop;
  }

  bool get isVrijePrijsPerArtikel {
    return isPrijs && bronPrijsregelId.trim().isNotEmpty;
  }

  double get veiligeHoeveelheid {
    if (!hoeveelheid.isFinite || hoeveelheid <= 0) return 0;
    return hoeveelheid;
  }

  double get veiligeEenheidsprijs {
    if (!eenheidsprijsExclBtw.isFinite || eenheidsprijsExclBtw <= 0) return 0;
    return eenheidsprijsExclBtw;
  }

  double get totaalExclBtw {
    if (!isPrijs) return 0;
    final totaal = veiligeHoeveelheid * veiligeEenheidsprijs;
    return (totaal * 100).roundToDouble() / 100;
  }

  String get zichtbareTitel {
    final waarde = titel.trim();
    if (waarde.isNotEmpty) return waarde;
    return isPrijs ? 'Prijsregel' : '';
  }

  OpmetingAlgemeneOpmetingBlok copyWith({
    String? id,
    OpmetingAlgemeneOpmetingBlokType? type,
    String? titel,
    String? omschrijving,
    double? hoeveelheid,
    OpmetingAlgemenePrijsEenheid? eenheid,
    double? eenheidsprijsExclBtw,
    String? bronPrijsregelId,
    OpmetingAlgemenePrijsSoort? prijsSoort,
    bool? toonOpOfferte,
    bool? toonPrijsOpOfferte,
  }) {
    return OpmetingAlgemeneOpmetingBlok(
      id: id ?? this.id,
      type: type ?? this.type,
      titel: titel ?? this.titel,
      omschrijving: omschrijving ?? this.omschrijving,
      hoeveelheid: hoeveelheid ?? this.hoeveelheid,
      eenheid: eenheid ?? this.eenheid,
      eenheidsprijsExclBtw: eenheidsprijsExclBtw ?? this.eenheidsprijsExclBtw,
      bronPrijsregelId: bronPrijsregelId ?? this.bronPrijsregelId,
      prijsSoort: prijsSoort ?? this.prijsSoort,
      toonOpOfferte: toonOpOfferte ?? this.toonOpOfferte,
      toonPrijsOpOfferte: toonPrijsOpOfferte ?? this.toonPrijsOpOfferte,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'type': type.jsonWaarde,
      'titel': titel,
      'omschrijving': omschrijving,
      'hoeveelheid': hoeveelheid,
      'eenheid': eenheid.jsonWaarde,
      'eenheidsprijsExclBtw': eenheidsprijsExclBtw,
      'bronPrijsregelId': bronPrijsregelId,
      'prijsSoort': prijsSoort.jsonWaarde,
      'toonOpOfferte': toonOpOfferte,
      'toonPrijsOpOfferte': toonPrijsOpOfferte,
    };
  }

  factory OpmetingAlgemeneOpmetingBlok.fromJson(Map<String, dynamic> json) {
    return OpmetingAlgemeneOpmetingBlok(
      id: json['id']?.toString() ?? '',
      type: OpmetingAlgemeneOpmetingBlokType.fromJson(json['type']),
      titel: json['titel']?.toString() ?? '',
      omschrijving: json['omschrijving']?.toString() ?? '',
      hoeveelheid: _leesDouble(json['hoeveelheid'], standaard: 1),
      eenheid: OpmetingAlgemenePrijsEenheid.fromJson(json['eenheid']),
      eenheidsprijsExclBtw: _leesDouble(json['eenheidsprijsExclBtw']),
      bronPrijsregelId: json['bronPrijsregelId']?.toString() ?? '',
      prijsSoort: OpmetingAlgemenePrijsSoort.fromJson(json['prijsSoort']),
      toonOpOfferte: json['toonOpOfferte'] != false,
      toonPrijsOpOfferte: json['toonPrijsOpOfferte'] != false,
    );
  }

  static double _leesDouble(Object? waarde, {double standaard = 0}) {
    if (waarde is num) return waarde.toDouble();
    return double.tryParse(
          waarde?.toString().trim().replaceAll(',', '.') ?? '',
        ) ??
        standaard;
  }
}
