// THIMACO-CONTROLE: MAGAZIJN-MODELLEN-BESTELBON-EENHEDEN-20260804

class MagazijnLeverancier {
  const MagazijnLeverancier({
    required this.id,
    required this.naam,
    this.contactpersoon = '',
    this.email = '',
    this.telefoon = '',
    this.gsm = '',
    this.klantnummer = '',
    this.opmerking = '',
  });

  final String id;
  final String naam;
  final String contactpersoon;
  final String email;
  final String telefoon;
  final String gsm;
  final String klantnummer;
  final String opmerking;

  String get telefoonVoorBestelbon =>
      telefoon.trim().isNotEmpty ? telefoon.trim() : gsm.trim();

  MagazijnLeverancier copyWith({
    String? id,
    String? naam,
    String? contactpersoon,
    String? email,
    String? telefoon,
    String? gsm,
    String? klantnummer,
    String? opmerking,
  }) {
    return MagazijnLeverancier(
      id: id ?? this.id,
      naam: naam ?? this.naam,
      contactpersoon: contactpersoon ?? this.contactpersoon,
      email: email ?? this.email,
      telefoon: telefoon ?? this.telefoon,
      gsm: gsm ?? this.gsm,
      klantnummer: klantnummer ?? this.klantnummer,
      opmerking: opmerking ?? this.opmerking,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'naam': naam,
    'contactpersoon': contactpersoon,
    'email': email,
    'telefoon': telefoon,
    'gsm': gsm,
    'klantnummer': klantnummer,
    'opmerking': opmerking,
  };

  factory MagazijnLeverancier.fromJson(Map<String, dynamic> json) {
    return MagazijnLeverancier(
      id: json['id']?.toString() ?? '',
      naam: json['naam']?.toString() ?? '',
      contactpersoon: json['contactpersoon']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      telefoon: json['telefoon']?.toString() ?? '',
      gsm: json['gsm']?.toString() ?? '',
      klantnummer: json['klantnummer']?.toString() ?? '',
      opmerking: json['opmerking']?.toString() ?? '',
    );
  }
}

class MagazijnArtikel {
  const MagazijnArtikel({
    required this.id,
    required this.leverancierId,
    required this.omschrijving,
    this.bestelArtikelnummer = '',
    this.leverancierArtikelnummer = '',
    this.eenheid = 'stuk',
    this.prijsPerEenheid = 0,
    this.stock = 0,
    this.minimumStock = 0,
    this.meebestelgrens = 0,
    this.maximumStock = 0,
    this.actief = true,
  });

  final String id;
  final String leverancierId;
  final String omschrijving;

  /// Het effectieve artikelnummer dat de leverancier nodig heeft.
  final String bestelArtikelnummer;

  /// Oude JSON-compatibiliteit. Nieuwe schermen gebruiken bestelArtikelnummer.
  final String leverancierArtikelnummer;

  final String eenheid;
  final double prijsPerEenheid;
  final int stock;
  final int minimumStock;
  final int meebestelgrens;
  final int maximumStock;
  final bool actief;

  String eenheidVoorAantal(num aantal) {
    if (aantal.abs() == 1) return eenheid;

    final woord = eenheid.trim();
    if (woord.isEmpty) return woord;

    final lower = woord.toLowerCase();
    const uitzonderingen = <String, String>{
      'stuk': 'stuks',
      'doos': 'dozen',
      'koker': 'kokers',
      'rol': 'rollen',
      'meter': 'meters',
      'set': 'sets',
      'pak': 'pakken',
      'bus': 'bussen',
      'plaat': 'platen',
      'zak': 'zakken',
      'paar': 'paren',
    };

    final uitzondering = uitzonderingen[lower];
    if (uitzondering != null) {
      if (woord == lower) return uitzondering;
      return '${uitzondering[0].toUpperCase()}${uitzondering.substring(1)}';
    }

    if (lower.endsWith('s') || lower.endsWith('x') || lower.endsWith('z')) {
      return woord;
    }

    if (lower.endsWith('el') || lower.endsWith('er') || lower.endsWith('en')) {
      return '${woord}s';
    }

    if (lower.endsWith('e')) {
      return '${woord}n';
    }

    return '${woord}en';
  }

  String get qrWaarde => 'THIMACO-MAGAZIJN:$id';

  bool get onderMinimum => stock <= minimumStock;

  bool get onderMeebestelgrens => stock <= meebestelgrens;

  int get aanbevolenBestelaantal =>
      (maximumStock - stock).clamp(0, 999999).toInt();

  String get effectiefBestelArtikelnummer {
    if (bestelArtikelnummer.trim().isNotEmpty) {
      return bestelArtikelnummer.trim();
    }
    return leverancierArtikelnummer.trim();
  }

  MagazijnArtikel copyWith({
    String? id,
    String? leverancierId,
    String? omschrijving,
    String? bestelArtikelnummer,
    String? leverancierArtikelnummer,
    String? eenheid,
    double? prijsPerEenheid,
    int? stock,
    int? minimumStock,
    int? meebestelgrens,
    int? maximumStock,
    bool? actief,
  }) {
    return MagazijnArtikel(
      id: id ?? this.id,
      leverancierId: leverancierId ?? this.leverancierId,
      omschrijving: omschrijving ?? this.omschrijving,
      bestelArtikelnummer: bestelArtikelnummer ?? this.bestelArtikelnummer,
      leverancierArtikelnummer:
          leverancierArtikelnummer ?? this.leverancierArtikelnummer,
      eenheid: eenheid ?? this.eenheid,
      prijsPerEenheid: prijsPerEenheid ?? this.prijsPerEenheid,
      stock: stock ?? this.stock,
      minimumStock: minimumStock ?? this.minimumStock,
      meebestelgrens: meebestelgrens ?? this.meebestelgrens,
      maximumStock: maximumStock ?? this.maximumStock,
      actief: actief ?? this.actief,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'leverancierId': leverancierId,
    'omschrijving': omschrijving,
    'bestelArtikelnummer': bestelArtikelnummer,
    'leverancierArtikelnummer': leverancierArtikelnummer,
    'eenheid': eenheid,
    'prijsPerEenheid': prijsPerEenheid,
    'stock': stock,
    'minimumStock': minimumStock,
    'meebestelgrens': meebestelgrens,
    'maximumStock': maximumStock,
    'actief': actief,
  };

  factory MagazijnArtikel.fromJson(Map<String, dynamic> json) {
    int leesInt(Object? waarde) {
      if (waarde is int) return waarde;
      if (waarde is num) return waarde.toInt();
      return int.tryParse(waarde?.toString() ?? '') ?? 0;
    }

    final oudEigenNummer = json['eigenArtikelnummer']?.toString() ?? '';
    final oudLeverancierNummer =
        json['leverancierArtikelnummer']?.toString() ?? '';

    return MagazijnArtikel(
      id: json['id']?.toString() ?? '',
      leverancierId: json['leverancierId']?.toString() ?? '',
      omschrijving: json['omschrijving']?.toString() ?? '',
      bestelArtikelnummer:
          json['bestelArtikelnummer']?.toString() ??
          (oudLeverancierNummer.trim().isNotEmpty
              ? oudLeverancierNummer
              : oudEigenNummer),
      leverancierArtikelnummer: oudLeverancierNummer,
      eenheid: json['eenheid']?.toString() ?? 'stuk',
      prijsPerEenheid: (json['prijsPerEenheid'] is num)
          ? (json['prijsPerEenheid'] as num).toDouble()
          : double.tryParse(
                  json['prijsPerEenheid']?.toString().replaceAll(',', '.') ??
                      '',
                ) ??
                0,
      stock: leesInt(json['stock']),
      minimumStock: leesInt(json['minimumStock']),
      meebestelgrens: leesInt(json['meebestelgrens']),
      maximumStock: leesInt(json['maximumStock']),
      actief: json['actief'] != false,
    );
  }
}

class MagazijnVoorraadMutatie {
  const MagazijnVoorraadMutatie({
    required this.id,
    required this.artikelId,
    required this.tijdstip,
    required this.verschil,
    required this.stockVoor,
    required this.stockNa,
    this.reden = '',
  });

  final String id;
  final String artikelId;
  final DateTime tijdstip;
  final int verschil;
  final int stockVoor;
  final int stockNa;
  final String reden;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'artikelId': artikelId,
    'tijdstip': tijdstip.toIso8601String(),
    'verschil': verschil,
    'stockVoor': stockVoor,
    'stockNa': stockNa,
    'reden': reden,
  };

  factory MagazijnVoorraadMutatie.fromJson(Map<String, dynamic> json) {
    int leesInt(Object? waarde) {
      if (waarde is int) return waarde;
      if (waarde is num) return waarde.toInt();
      return int.tryParse(waarde?.toString() ?? '') ?? 0;
    }

    return MagazijnVoorraadMutatie(
      id: json['id']?.toString() ?? '',
      artikelId: json['artikelId']?.toString() ?? '',
      tijdstip:
          DateTime.tryParse(json['tijdstip']?.toString() ?? '') ??
          DateTime.now(),
      verschil: leesInt(json['verschil']),
      stockVoor: leesInt(json['stockVoor']),
      stockNa: leesInt(json['stockNa']),
      reden: json['reden']?.toString() ?? '',
    );
  }
}

class MagazijnData {
  const MagazijnData({
    this.leveranciers = const <MagazijnLeverancier>[],
    this.artikelen = const <MagazijnArtikel>[],
    this.mutaties = const <MagazijnVoorraadMutatie>[],
    this.eenheden = const <String>['stuk', 'doos', 'koker', 'rol', 'meter'],
  });

  final List<MagazijnLeverancier> leveranciers;
  final List<MagazijnArtikel> artikelen;
  final List<MagazijnVoorraadMutatie> mutaties;
  final List<String> eenheden;

  MagazijnData copyWith({
    List<MagazijnLeverancier>? leveranciers,
    List<MagazijnArtikel>? artikelen,
    List<MagazijnVoorraadMutatie>? mutaties,
    List<String>? eenheden,
  }) {
    return MagazijnData(
      leveranciers: leveranciers ?? this.leveranciers,
      artikelen: artikelen ?? this.artikelen,
      mutaties: mutaties ?? this.mutaties,
      eenheden: eenheden ?? this.eenheden,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'leveranciers': leveranciers
        .map((item) => item.toJson())
        .toList(growable: false),
    'artikelen': artikelen.map((item) => item.toJson()).toList(growable: false),
    'mutaties': mutaties.map((item) => item.toJson()).toList(growable: false),
    'eenheden': eenheden,
  };

  factory MagazijnData.fromJson(Map<String, dynamic> json) {
    final opgeslagenEenheden = (json['eenheden'] as List<dynamic>? ?? const [])
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList(growable: false);

    return MagazijnData(
      leveranciers: (json['leveranciers'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (item) =>
                MagazijnLeverancier.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false),
      artikelen: (json['artikelen'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (item) => MagazijnArtikel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false),
      mutaties: (json['mutaties'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (item) => MagazijnVoorraadMutatie.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false),
      eenheden: opgeslagenEenheden.isEmpty
          ? const <String>['stuk', 'doos', 'koker', 'rol', 'meter']
          : opgeslagenEenheden,
    );
  }
}
