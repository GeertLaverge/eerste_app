class KlantTaakItem {
  String tekst;
  bool isAfgewerkt;

  KlantTaakItem({
    this.tekst = '',
    this.isAfgewerkt = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'tekst': tekst,
      'isAfgewerkt': isAfgewerkt,
    };
  }

  factory KlantTaakItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return KlantTaakItem(
      tekst: json['tekst'] ?? '',
      isAfgewerkt: json['isAfgewerkt'] ?? false,
    );
  }
}

class KlantenficheExtraWerk {
  DateTime? datum;
  int? startUur;
  int? startMinuut;
  int? eindUur;
  int? eindMinuut;

  String omschrijving;
  String gebruikteMaterialen;

  KlantenficheExtraWerk({
    this.datum,
    this.startUur,
    this.startMinuut,
    this.eindUur,
    this.eindMinuut,
    this.omschrijving = '',
    this.gebruikteMaterialen = '',
  });

  int get aantalMinuten {
    if (startUur == null ||
        startMinuut == null ||
        eindUur == null ||
        eindMinuut == null) {
      return 0;
    }

    final start = (startUur! * 60) + startMinuut!;
    final eind = (eindUur! * 60) + eindMinuut!;

    if (eind <= start) return 0;

    return eind - start;
  }

  String get tijdTekst {
    if (startUur == null ||
        startMinuut == null ||
        eindUur == null ||
        eindMinuut == null) {
      return 'Geen tijd ingevuld';
    }

    final start =
        '${startUur!.toString().padLeft(2, '0')}:${startMinuut!.toString().padLeft(2, '0')}';

    final eind =
        '${eindUur!.toString().padLeft(2, '0')}:${eindMinuut!.toString().padLeft(2, '0')}';

    return '$start - $eind';
  }

  String get totaalTijdTekst {
    final minuten = aantalMinuten;

    if (minuten <= 0) return '0 min';

    final uren = minuten ~/ 60;
    final rest = minuten % 60;

    if (uren == 0) return '$rest min';
    if (rest == 0) return '$uren u';

    return '$uren u $rest min';
  }

  Map<String, dynamic> toJson() {
    return {
      'datum': datum?.toIso8601String(),
      'startUur': startUur,
      'startMinuut': startMinuut,
      'eindUur': eindUur,
      'eindMinuut': eindMinuut,
      'omschrijving': omschrijving,
      'gebruikteMaterialen': gebruikteMaterialen,
    };
  }

  factory KlantenficheExtraWerk.fromJson(
    Map<String, dynamic> json,
  ) {
    return KlantenficheExtraWerk(
      datum: json['datum'] != null ? DateTime.tryParse(json['datum']) : null,
      startUur: json['startUur'],
      startMinuut: json['startMinuut'],
      eindUur: json['eindUur'],
      eindMinuut: json['eindMinuut'],
      omschrijving: json['omschrijving'] ?? '',
      gebruikteMaterialen: json['gebruikteMaterialen'] ?? '',
    );
  }
}

class KlantenficheArtikel {
  final String leverancier;
  final String artikel;
  final bool besteld;
  final bool geleverd;

  const KlantenficheArtikel({
    required this.leverancier,
    required this.artikel,
    this.besteld = false,
    this.geleverd = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'leverancier': leverancier,
      'artikel': artikel,
      'besteld': besteld,
      'geleverd': geleverd,
    };
  }

  factory KlantenficheArtikel.fromJson(
    Map<String, dynamic> json,
  ) {
    return KlantenficheArtikel(
      leverancier: json['leverancier'] ?? '',
      artikel: json['artikel'] ?? '',
      besteld: json['besteld'] ?? false,
      geleverd: json['geleverd'] ?? false,
    );
  }
}

class KlantenficheFoto {
  final String id;
  final String bestandsNaam;
  final String beschrijving;
  final String datum;

  const KlantenficheFoto({
    required this.id,
    required this.bestandsNaam,
    this.beschrijving = '',
    this.datum = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bestandsNaam': bestandsNaam,
      'beschrijving': beschrijving,
      'datum': datum,
    };
  }

  factory KlantenficheFoto.fromJson(Map<String, dynamic> json) {
    return KlantenficheFoto(
      id: json['id'] ?? '',
      bestandsNaam: json['bestandsNaam'] ?? '',
      beschrijving: json['beschrijving'] ?? '',
      datum: json['datum'] ?? '',
    );
  }
}

class KlantenficheModel {
  final String id;

  final String updatedAt;
  final String deletedAt;

  final String naam;
  final String klantNr;

  final String straatnaam;
  final String huisNr;
  final String gemeente;
  final String postcode;

  final String gsm;
  final String gsm2;
  final String email;

  final String klantStatus;
  final String bestelStatus;

  final String taakVoorKlant;
  String klantTakenAfgewerktOp;

  final String datumAfgewerkt;

  final List<KlantenficheArtikel> artikelen;
  final List<KlantTaakItem> klantTaken;
  final List<KlantenficheExtraWerk> extraWerken;
  final List<KlantenficheFoto> fotos;
  final String opvolgTaken;
  final bool opvolgFicheVerstuurdNaarBureau;
  final bool klaarVoorNieuwePlanning;

  KlantenficheModel({
    required this.id,
    required this.naam,
    this.klantNr = '',
    this.straatnaam = '',
    this.huisNr = '',
    this.gemeente = '',
    this.postcode = '',
    this.gsm = '',
    this.gsm2 = '',
    this.email = '',
    this.klantStatus = 'Actief',
    this.bestelStatus = 'Geen artikelen',
    this.taakVoorKlant = '',
    this.klantTakenAfgewerktOp = '',
    this.datumAfgewerkt = '',
    this.klantTaken = const [],
    this.artikelen = const [],
    this.extraWerken = const [],
    this.fotos = const [],
    this.opvolgTaken = '',
    this.opvolgFicheVerstuurdNaarBureau = false,
    this.klaarVoorNieuwePlanning = false,
    this.updatedAt = '',
    this.deletedAt = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
      'naam': naam,
      'klantNr': klantNr,
      'straatnaam': straatnaam,
      'huisNr': huisNr,
      'gemeente': gemeente,
      'postcode': postcode,
      'gsm': gsm,
      'gsm2': gsm2,
      'email': email,
      'klantStatus': klantStatus,
      'bestelStatus': bestelStatus,
      'taakVoorKlant': taakVoorKlant,
      'klantTakenAfgewerktOp': klantTakenAfgewerktOp,
      'datumAfgewerkt': datumAfgewerkt,
      'artikelen': artikelen.map((artikel) => artikel.toJson()).toList(),
      'klantTaken': klantTaken.map((taak) => taak.toJson()).toList(),
      'extraWerken': extraWerken.map((werk) => werk.toJson()).toList(),
      'fotos': fotos.map((foto) => foto.toJson()).toList(),
      'opvolgTaken': opvolgTaken,
      'opvolgFicheVerstuurdNaarBureau': opvolgFicheVerstuurdNaarBureau,
      'klaarVoorNieuwePlanning': klaarVoorNieuwePlanning,
    };
  }

  factory KlantenficheModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return KlantenficheModel(
      id: json['id'] ?? '',
      naam: json['naam'] ?? '',
      klantNr: json['klantNr'] ?? '',
      straatnaam: json['straatnaam'] ?? '',
      huisNr: json['huisNr'] ?? '',
      gemeente: json['gemeente'] ?? '',
      postcode: json['postcode'] ?? '',
      gsm: json['gsm'] ?? '',
      gsm2: json['gsm2'] ?? '',
      email: json['email'] ?? '',
      klantStatus: json['klantStatus'] ?? 'Actief',
      bestelStatus: json['bestelStatus'] ?? 'Geen artikelen',
      taakVoorKlant: json['taakVoorKlant'] ?? '',
      klantTakenAfgewerktOp: json['klantTakenAfgewerktOp'] ?? '',
      datumAfgewerkt: json['datumAfgewerkt'] ?? '',
      klantTaken: (json['klantTaken'] as List<dynamic>? ?? [])
          .map(
            (item) => KlantTaakItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      artikelen: (json['artikelen'] as List<dynamic>? ?? [])
          .map(
            (item) => KlantenficheArtikel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      extraWerken: (json['extraWerken'] as List<dynamic>? ?? [])
          .map(
            (item) => KlantenficheExtraWerk.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      fotos: (json['fotos'] as List<dynamic>? ?? [])
          .map(
            (item) => KlantenficheFoto.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      opvolgTaken: json['opvolgTaken'] ?? '',
      opvolgFicheVerstuurdNaarBureau:
          json['opvolgFicheVerstuurdNaarBureau'] ?? false,
      klaarVoorNieuwePlanning: json['klaarVoorNieuwePlanning'] ?? false,
      updatedAt: json['updatedAt'] ?? '',
      deletedAt: json['deletedAt'] ?? '',
    );
  }
}
