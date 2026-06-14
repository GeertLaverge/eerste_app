class NotitieModel {
  NotitieModel({
    required this.id,
    required this.datumKey,
    required this.titel,
    this.detail = '',
    this.actieId = '',
    this.afgewerkt = false,
    DateTime? aangemaaktOp,
    DateTime? gewijzigdOp,
  })  : aangemaaktOp = aangemaaktOp ?? DateTime.now(),
        gewijzigdOp = gewijzigdOp ?? DateTime.now();

  final String id;

  String datumKey;
  String titel;
  String detail;
  String actieId;

  bool afgewerkt;

  DateTime aangemaaktOp;
  DateTime gewijzigdOp;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'datumKey': datumKey,
      'titel': titel,
      'detail': detail,
      'actieId': actieId,
      'afgewerkt': afgewerkt,
      'aangemaaktOp': aangemaaktOp.toIso8601String(),
      'gewijzigdOp': gewijzigdOp.toIso8601String(),
    };
  }

  factory NotitieModel.fromJson(Map<String, dynamic> json) {
    return NotitieModel(
      id: json['id'] ?? '',
      datumKey: json['datumKey'] ?? '',
      titel: json['titel'] ?? '',
      detail: json['detail'] ?? '',
      actieId: json['actieId'] ?? '',
      afgewerkt: json['afgewerkt'] ?? false,
      aangemaaktOp: DateTime.tryParse(
        json['aangemaaktOp'] ?? '',
      ),
      gewijzigdOp: DateTime.tryParse(
        json['gewijzigdOp'] ?? '',
      ),
    );
  }
}
