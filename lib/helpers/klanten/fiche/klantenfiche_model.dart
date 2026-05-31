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
    this.bestelStatus = 'Geen artikels',
    this.taakVoorKlant = '',
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
      bestelStatus: json['bestelStatus'] ?? 'Geen artikels',
      taakVoorKlant: json['taakVoorKlant'] ?? '',
    );
  }
}
