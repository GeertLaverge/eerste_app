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

  factory KlantenficheArtikel.fromJson(Map<String, dynamic> json) {
    return KlantenficheArtikel(
      leverancier: json['leverancier'] ?? '',
      artikel: json['artikel'] ?? '',
      besteld: json['besteld'] ?? false,
      geleverd: json['geleverd'] ?? false,
    );
  }
}

class KlantenficheModel {
  final String id;

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

  final List<KlantenficheArtikel> artikelen;

  const KlantenficheModel({
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
    this.artikelen = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'artikelen': artikelen.map((artikel) => artikel.toJson()).toList(),
    };
  }

  factory KlantenficheModel.fromJson(Map<String, dynamic> json) {
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
      artikelen: (json['artikelen'] as List<dynamic>? ?? [])
          .map(
            (item) => KlantenficheArtikel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }
}
