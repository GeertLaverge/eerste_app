class NotitieActie {
  String id;
  String titel;
  bool toevoegenAanDagtaak;
  DateTime? datum;
  String kleurNaam;
  bool afgewerkt;

  NotitieActie({
    required this.id,
    required this.titel,
    required this.toevoegenAanDagtaak,
    required this.kleurNaam,
    this.datum,
    this.afgewerkt = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titel': titel,
      'toevoegenAanDagtaak': toevoegenAanDagtaak,
      'datum': datum?.toIso8601String(),
      'kleurNaam': kleurNaam,
      'afgewerkt': afgewerkt,
    };
  }

  factory NotitieActie.fromMap(Map<String, dynamic> map) {
    return NotitieActie(
      id: map['id'] ?? '',
      titel: map['titel'] ?? '',
      toevoegenAanDagtaak: map['toevoegenAanDagtaak'] ?? false,
      datum: map['datum'] == null ? null : DateTime.parse(map['datum']),
      kleurNaam: map['kleurNaam'] ?? 'groen',
      afgewerkt: map['afgewerkt'] ?? false,
    );
  }
}
