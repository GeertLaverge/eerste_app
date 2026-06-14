class NotitieActieModel {
  NotitieActieModel({
    required this.id,
    required this.naam,
    required this.kleurWaarde,
  });

  final String id;

  String naam;
  int kleurWaarde;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'naam': naam,
      'kleurWaarde': kleurWaarde,
    };
  }

  factory NotitieActieModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return NotitieActieModel(
      id: json['id'] ?? '',
      naam: json['naam'] ?? '',
      kleurWaarde: json['kleurWaarde'] ?? 0xFF0B7A3B,
    );
  }
}
