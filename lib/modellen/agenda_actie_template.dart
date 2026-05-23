class AgendaActieTemplate {
  String id;
  String naam;
  String icoonNaam;
  String kleurNaam;

  AgendaActieTemplate({
    required this.id,
    required this.naam,
    required this.icoonNaam,
    required this.kleurNaam,
  });

  factory AgendaActieTemplate.fromJson(Map<String, dynamic> json) {
    return AgendaActieTemplate(
      id: json['id'] ?? '',
      naam: json['naam'] ?? '',
      icoonNaam: json['icoonNaam'] ?? 'taak',
      kleurNaam: json['kleurNaam'] ?? 'groen',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'naam': naam,
      'icoonNaam': icoonNaam,
      'kleurNaam': kleurNaam,
    };
  }
}
