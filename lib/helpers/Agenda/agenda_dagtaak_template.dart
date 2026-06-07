class AgendaDagtaakTemplate {
  final String id;
  final String naam;

  final bool heeftTijd;

  final int? startUur;
  final int? startMinuut;

  final int? eindUur;
  final int? eindMinuut;

  final String homeWeergaveType;
  final int dagenVooraf;
  final String homeDatum;

  const AgendaDagtaakTemplate({
    required this.id,
    required this.naam,
    required this.heeftTijd,
    this.startUur,
    this.startMinuut,
    this.eindUur,
    this.eindMinuut,
    this.homeWeergaveType = 'zelfdeDag',
    this.dagenVooraf = 0,
    this.homeDatum = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'naam': naam,
      'heeftTijd': heeftTijd,
      'startUur': startUur,
      'startMinuut': startMinuut,
      'eindUur': eindUur,
      'eindMinuut': eindMinuut,
      'homeWeergaveType': homeWeergaveType,
      'dagenVooraf': dagenVooraf,
      'homeDatum': homeDatum,
    };
  }

  factory AgendaDagtaakTemplate.fromJson(
    Map<String, dynamic> json,
  ) {
    return AgendaDagtaakTemplate(
      id: json['id'] ?? '',
      naam: json['naam'] ?? '',
      heeftTijd: json['heeftTijd'] ?? false,
      startUur: json['startUur'],
      startMinuut: json['startMinuut'],
      eindUur: json['eindUur'],
      eindMinuut: json['eindMinuut'],
      homeWeergaveType: json['homeWeergaveType'] ?? 'zelfdeDag',
      dagenVooraf: json['dagenVooraf'] ?? 0,
      homeDatum: json['homeDatum'] ?? '',
    );
  }
}
