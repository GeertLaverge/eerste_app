// THIMACO-CONTROLE: PRIJS-VOOR-ALLE-POSITIES-BIBLIOTHEEK-MODEL-20260815
import 'offerte_artikel_prijs_data_model.dart';
import 'offerte_prijs_voor_alle_posities_regel_model.dart';

/// Herbruikbare bibliotheekregel voor "Prijs voor alle posities".
///
/// Net als bij "Prijs per positie" is dit alleen een sjabloon. Een gekozen
/// sjabloon wordt als onafhankelijke projectregel in de offerte opgeslagen.
class OffertePrijsVoorAllePositiesTemplateModel {
  const OffertePrijsVoorAllePositiesTemplateModel({
    required this.id,
    required this.omschrijving,
    this.type = OffertePrijsPerPositieType.verkoop,
    this.eenheid = 'st',
    double standaardWinstPercentage = 0,
    this.volgorde = 0,
    this.gewijzigdOp = '',
  }) : standaardWinstPercentage = type == OffertePrijsPerPositieType.verkoop
           ? 0
           : standaardWinstPercentage;

  final String id;
  final String omschrijving;
  final OffertePrijsPerPositieType type;
  final String eenheid;
  final double standaardWinstPercentage;
  final int volgorde;
  final String gewijzigdOp;

  bool get isAankoop => type.isAankoop;
  bool get isVerkoop => type.isVerkoop;

  double get veiligeStandaardWinstPercentage {
    if (isVerkoop) return 0.0;
    return _normaliseerPercentage(standaardWinstPercentage);
  }

  bool get isGeldig {
    return id.trim().isNotEmpty && omschrijving.trim().isNotEmpty;
  }

  OffertePrijsVoorAllePositiesTemplateModel copyWith({
    String? id,
    String? omschrijving,
    OffertePrijsPerPositieType? type,
    String? eenheid,
    double? standaardWinstPercentage,
    int? volgorde,
    String? gewijzigdOp,
  }) {
    final nieuwType = type ?? this.type;
    final nieuweWinst = nieuwType.isVerkoop
        ? 0.0
        : (standaardWinstPercentage ?? this.standaardWinstPercentage);

    return OffertePrijsVoorAllePositiesTemplateModel(
      id: id ?? this.id,
      omschrijving: omschrijving ?? this.omschrijving,
      type: nieuwType,
      eenheid: eenheid ?? this.eenheid,
      standaardWinstPercentage: nieuweWinst,
      volgorde: volgorde ?? this.volgorde,
      gewijzigdOp: gewijzigdOp ?? this.gewijzigdOp,
    );
  }

  OffertePrijsVoorAllePositiesTemplateModel metWijzigingsDatum() {
    return copyWith(gewijzigdOp: DateTime.now().toUtc().toIso8601String());
  }

  OffertePrijsVoorAllePositiesRegelModel maakProjectRegel({
    required String nieuwId,
  }) {
    return OffertePrijsVoorAllePositiesRegelModel(
      prijsregel: OffertePrijsPerPositieRegelModel(
        id: nieuwId,
        omschrijving: omschrijving.trim(),
        type: type,
        aantal: 1,
        eenheid: eenheid.trim().isEmpty ? 'st' : eenheid.trim(),
        eenheidsPrijsExclBtw: 0,
        winstPercentage: veiligeStandaardWinstPercentage,
        offerteWeergave: OffertePrijsPerPositieWeergave.uit,
      ),
      geselecteerdePositieIds: const <String>{},
      toepassenOpAllePosities: false,
      volgorde: volgorde,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id.trim(),
      'omschrijving': omschrijving.trim(),
      'type': type.jsonWaarde,
      'eenheid': eenheid.trim().isEmpty ? 'st' : eenheid.trim(),
      'standaardWinstPercentage': veiligeStandaardWinstPercentage,
      'volgorde': volgorde,
      'gewijzigdOp': gewijzigdOp,
    };
  }

  factory OffertePrijsVoorAllePositiesTemplateModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final type = OffertePrijsPerPositieType.fromJson(json['type']);

    return OffertePrijsVoorAllePositiesTemplateModel(
      id: json['id']?.toString().trim() ?? '',
      omschrijving: json['omschrijving']?.toString().trim() ?? '',
      type: type,
      eenheid: _leesEenheid(json['eenheid']),
      standaardWinstPercentage: type.isVerkoop
          ? 0.0
          : _leesDouble(json['standaardWinstPercentage']),
      volgorde: _leesInt(json['volgorde']),
      gewijzigdOp: json['gewijzigdOp']?.toString().trim() ?? '',
    );
  }

  static String _leesEenheid(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';
    return tekst.isEmpty ? 'st' : tekst;
  }

  static int _leesInt(Object? waarde) {
    if (waarde is int) return waarde;
    if (waarde is num) return waarde.toInt();
    return int.tryParse(waarde?.toString().trim() ?? '') ?? 0;
  }

  static double _leesDouble(Object? waarde) {
    if (waarde is double) return waarde.isFinite ? waarde : 0.0;
    if (waarde is num) {
      final getal = waarde.toDouble();
      return getal.isFinite ? getal : 0.0;
    }

    final gelezen = double.tryParse(
      waarde?.toString().trim().replaceAll(',', '.') ?? '',
    );
    return gelezen != null && gelezen.isFinite ? gelezen : 0.0;
  }

  static double _normaliseerPercentage(double waarde) {
    if (!waarde.isFinite || waarde <= 0.0) return 0.0;
    if (waarde >= 500.0) return 500.0;
    return (waarde * 100.0).roundToDouble() / 100.0;
  }
}
