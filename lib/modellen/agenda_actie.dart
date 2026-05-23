class AgendaActie {
  String id;
  String titel;
  String typeActie;

  DateTime datum;

  bool toonOpDagtaak;
  int dagenVoorafTonen;

  String weergaveType;
  String kleurNaam;
  String icoonNaam;

  int? startUur;
  int? startMinuut;
  int? eindUur;
  int? eindMinuut;

  bool isTemplate;
  String opmerkingen;
  String agendaCategorie;

  bool isAfgewerkt;

  AgendaActie({
    required this.id,
    required this.titel,
    required this.typeActie,
    required this.datum,
    this.toonOpDagtaak = false,
    this.dagenVoorafTonen = 0,
    this.weergaveType = 'symbool',
    this.kleurNaam = 'groen',
    this.icoonNaam = 'taak',
    this.startUur,
    this.startMinuut,
    this.eindUur,
    this.eindMinuut,
    this.isTemplate = false,
    this.opmerkingen = '',
    this.agendaCategorie = 'plaatsing',
    this.isAfgewerkt = false,
  });

  factory AgendaActie.fromJson(Map<String, dynamic> json) {
    return AgendaActie(
      id: json['id'] ?? '',
      titel: json['titel'] ?? '',
      typeActie: json['typeActie'] ?? '',
      datum: DateTime.tryParse(json['datum'] ?? '') ?? DateTime.now(),
      toonOpDagtaak: json['toonOpDagtaak'] ?? false,
      dagenVoorafTonen: json['dagenVoorafTonen'] ?? 0,
      weergaveType: json['weergaveType'] ?? 'symbool',
      kleurNaam: json['kleurNaam'] ?? 'groen',
      icoonNaam: json['icoonNaam'] ?? 'taak',
      startUur: json['startUur'],
      startMinuut: json['startMinuut'],
      eindUur: json['eindUur'],
      eindMinuut: json['eindMinuut'],
      isTemplate: json['isTemplate'] ?? false,
      opmerkingen: json['opmerkingen'] ?? '',
      agendaCategorie: json['agendaCategorie'] ?? 'plaatsing',
      isAfgewerkt: json['isAfgewerkt'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titel': titel,
      'typeActie': typeActie,
      'datum': datum.toIso8601String(),
      'toonOpDagtaak': toonOpDagtaak,
      'dagenVoorafTonen': dagenVoorafTonen,
      'weergaveType': weergaveType,
      'kleurNaam': kleurNaam,
      'icoonNaam': icoonNaam,
      'startUur': startUur,
      'startMinuut': startMinuut,
      'eindUur': eindUur,
      'eindMinuut': eindMinuut,
      'isTemplate': isTemplate,
      'opmerkingen': opmerkingen,
      'agendaCategorie': agendaCategorie,
      'isAfgewerkt': isAfgewerkt,
    };
  }
}
