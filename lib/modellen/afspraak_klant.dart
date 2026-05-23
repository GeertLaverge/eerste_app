class AfspraakKlant {
  String id;
  String klantNr;
  String klantNaam;
  String adres;
  String telefoon;
  String email;
  DateTime datum;
  bool ganseDag;
  int beginUur;
  int beginMinuut;
  int eindUur;
  int eindMinuut;
  String waarschuwing;
  String notities;

  AfspraakKlant({
    required this.id,
    required this.klantNr,
    required this.klantNaam,
    required this.adres,
    required this.telefoon,
    required this.email,
    required this.datum,
    required this.ganseDag,
    required this.beginUur,
    required this.beginMinuut,
    required this.eindUur,
    required this.eindMinuut,
    required this.waarschuwing,
    required this.notities,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'klantNr': klantNr,
      'klantNaam': klantNaam,
      'adres': adres,
      'telefoon': telefoon,
      'email': email,
      'datum': datum.toIso8601String(),
      'ganseDag': ganseDag,
      'beginUur': beginUur,
      'beginMinuut': beginMinuut,
      'eindUur': eindUur,
      'eindMinuut': eindMinuut,
      'waarschuwing': waarschuwing,
      'notities': notities,
    };
  }

  factory AfspraakKlant.fromJson(Map<String, dynamic> json) {
    return AfspraakKlant(
      id: json['id'] ?? '',
      klantNr: json['klantNr'] ?? '',
      klantNaam: json['klantNaam'] ?? '',
      adres: json['adres'] ?? '',
      telefoon: json['telefoon'] ?? '',
      email: json['email'] ?? '',
      datum: DateTime.parse(json['datum']),
      ganseDag: json['ganseDag'] ?? true,
      beginUur: json['beginUur'] ?? 8,
      beginMinuut: json['beginMinuut'] ?? 0,
      eindUur: json['eindUur'] ?? 9,
      eindMinuut: json['eindMinuut'] ?? 0,
      waarschuwing: json['waarschuwing'] ?? 'Bij aanvang',
      notities: json['notities'] ?? '',
    );
  }
}
