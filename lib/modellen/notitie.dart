import 'notitie_actie.dart';

class Notitie {
  String id;
  String titel;
  String inhoud;
  List<NotitieActie> acties;
  bool afgewerkt;
  DateTime aangemaaktOp;
  DateTime? afgewerktOp;

  Notitie({
    required this.id,
    required this.titel,
    required this.inhoud,
    required this.acties,
    this.afgewerkt = false,
    DateTime? aangemaaktOp,
    this.afgewerktOp,
  }) : aangemaaktOp = aangemaaktOp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titel': titel,
      'inhoud': inhoud,
      'acties': acties.map((actie) => actie.toMap()).toList(),
      'afgewerkt': afgewerkt,
      'aangemaaktOp': aangemaaktOp.toIso8601String(),
      'afgewerktOp': afgewerktOp?.toIso8601String(),
    };
  }

  factory Notitie.fromMap(Map<String, dynamic> map) {
    return Notitie(
      id: map['id'] ?? '',
      titel: map['titel'] ?? '',
      inhoud: map['inhoud'] ?? '',
      acties: List<Map<String, dynamic>>.from(map['acties'] ?? [])
          .map((actieMap) => NotitieActie.fromMap(actieMap))
          .toList(),
      afgewerkt: map['afgewerkt'] ?? false,
      aangemaaktOp: map['aangemaaktOp'] == null
          ? DateTime.now()
          : DateTime.parse(map['aangemaaktOp']),
      afgewerktOp: map['afgewerktOp'] == null
          ? null
          : DateTime.parse(map['afgewerktOp']),
    );
  }
}
