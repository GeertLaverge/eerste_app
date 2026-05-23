class PlanningDag {
  DateTime datum;
  int startUur;
  int startMinuut;
  int eindUur;
  int eindMinuut;

  PlanningDag({
    required this.datum,
    required this.startUur,
    required this.startMinuut,
    required this.eindUur,
    required this.eindMinuut,
  });

  Map<String, dynamic> toMap() {
    return {
      'datum': datum.toIso8601String(),
      'startUur': startUur,
      'startMinuut': startMinuut,
      'eindUur': eindUur,
      'eindMinuut': eindMinuut,
    };
  }

  factory PlanningDag.fromMap(Map<String, dynamic> map) {
    return PlanningDag(
      datum: DateTime.parse(map['datum']),
      startUur: map['startUur'] ?? 8,
      startMinuut: map['startMinuut'] ?? 0,
      eindUur: map['eindUur'] ?? 17,
      eindMinuut: map['eindMinuut'] ?? 0,
    );
  }
}
