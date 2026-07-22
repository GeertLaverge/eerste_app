import 'offerte_prijs_categorie.dart';
import 'offerte_prijs_eenheid.dart';
import 'offerte_prijs_uitschrijfmodus.dart';
import 'offerte_prijs_verdeel_limietmodus.dart';
import 'offerte_technische_keuze_ref.dart';

class OffertePrijsregelModel {
  OffertePrijsregelModel({
    required String id,
    required this.categorie,
    required String formulierType,
    required String omschrijving,
    required double prijsExclBtw,
    required this.eenheid,
    required this.uitschrijfmodus,
    this.technischeKeuze,
    this.verdeelLimietmodus = OffertePrijsVerdeelLimietmodus.zonderLimiet,
    double verdeelLimietBedragExclBtw = 0,
    this.actief = true,
    int volgorde = 0,
    String gewijzigdOp = '',
  }) : id = id.trim(),
       formulierType = formulierType.trim(),
       omschrijving = omschrijving.trim(),
       prijsExclBtw = _normaliseerBedrag(prijsExclBtw),
       verdeelLimietBedragExclBtw = _normaliseerBedrag(
         verdeelLimietBedragExclBtw,
       ),
       volgorde = volgorde < 0 ? 0 : volgorde,
       gewijzigdOp = gewijzigdOp.trim();

  final String id;
  final OffertePrijsCategorie categorie;
  final String formulierType;
  final String omschrijving;
  final double prijsExclBtw;
  final OffertePrijsEenheid eenheid;
  final OffertePrijsUitschrijfmodus uitschrijfmodus;
  final OfferteTechnischeKeuzeRef? technischeKeuze;
  final OffertePrijsVerdeelLimietmodus verdeelLimietmodus;
  final double verdeelLimietBedragExclBtw;
  final bool actief;
  final int volgorde;
  final String gewijzigdOp;

  bool get isVerdeeldeProjectkost {
    return categorie == OffertePrijsCategorie.alleArtikelen &&
        uitschrijfmodus.isVerdeeldeInterneKost;
  }

  bool get heeftVerdeelAankooplimiet {
    return isVerdeeldeProjectkost &&
        verdeelLimietmodus == OffertePrijsVerdeelLimietmodus.metAankooplimiet &&
        verdeelLimietBedragExclBtw > 0;
  }

  bool get isGeldig {
    if (id.isEmpty || formulierType.isEmpty || omschrijving.isEmpty) {
      return false;
    }

    if (isVerdeeldeProjectkost &&
        verdeelLimietmodus == OffertePrijsVerdeelLimietmodus.metAankooplimiet &&
        verdeelLimietBedragExclBtw <= 0) {
      return false;
    }

    return true;
  }

  OffertePrijsregelModel copyWith({
    String? id,
    OffertePrijsCategorie? categorie,
    String? formulierType,
    String? omschrijving,
    double? prijsExclBtw,
    OffertePrijsEenheid? eenheid,
    OffertePrijsUitschrijfmodus? uitschrijfmodus,
    OfferteTechnischeKeuzeRef? technischeKeuze,
    bool technischeKeuzeWissen = false,
    OffertePrijsVerdeelLimietmodus? verdeelLimietmodus,
    double? verdeelLimietBedragExclBtw,
    bool? actief,
    int? volgorde,
    String? gewijzigdOp,
  }) {
    return OffertePrijsregelModel(
      id: id ?? this.id,
      categorie: categorie ?? this.categorie,
      formulierType: formulierType ?? this.formulierType,
      omschrijving: omschrijving ?? this.omschrijving,
      prijsExclBtw: prijsExclBtw ?? this.prijsExclBtw,
      eenheid: eenheid ?? this.eenheid,
      uitschrijfmodus: uitschrijfmodus ?? this.uitschrijfmodus,
      technischeKeuze: technischeKeuzeWissen
          ? null
          : technischeKeuze ?? this.technischeKeuze,
      verdeelLimietmodus: verdeelLimietmodus ?? this.verdeelLimietmodus,
      verdeelLimietBedragExclBtw:
          verdeelLimietBedragExclBtw ?? this.verdeelLimietBedragExclBtw,
      actief: actief ?? this.actief,
      volgorde: volgorde ?? this.volgorde,
      gewijzigdOp: gewijzigdOp ?? this.gewijzigdOp,
    );
  }

  OffertePrijsregelModel metWijzigingsDatum() {
    return copyWith(gewijzigdOp: DateTime.now().toUtc().toIso8601String());
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'categorie': categorie.jsonWaarde,
      'formulierType': formulierType,
      'omschrijving': omschrijving,
      'prijsExclBtw': prijsExclBtw,
      'eenheid': eenheid.jsonWaarde,
      'uitschrijfmodus': uitschrijfmodus.jsonWaarde,
      'technischeKeuze': technischeKeuze?.toJson(),
      'verdeelLimietmodus': verdeelLimietmodus.jsonWaarde,
      'verdeelLimietBedragExclBtw': verdeelLimietBedragExclBtw,
      'actief': actief,
      'volgorde': volgorde,
      'gewijzigdOp': gewijzigdOp,
    };
  }

  factory OffertePrijsregelModel.fromJson(Map<String, dynamic> json) {
    return OffertePrijsregelModel(
      id: json['id']?.toString() ?? '',
      categorie: OffertePrijsCategorie.fromJson(json['categorie']),
      formulierType: json['formulierType']?.toString() ?? '',
      omschrijving: json['omschrijving']?.toString() ?? '',
      prijsExclBtw: _leesBedrag(json['prijsExclBtw']),
      eenheid: OffertePrijsEenheid.fromJson(json['eenheid']),
      uitschrijfmodus: OffertePrijsUitschrijfmodus.fromJson(
        json['uitschrijfmodus'],
      ),
      technischeKeuze: OfferteTechnischeKeuzeRef.fromJsonWaarde(
        json['technischeKeuze'],
      ),
      verdeelLimietmodus: OffertePrijsVerdeelLimietmodus.fromJson(
        json['verdeelLimietmodus'],
      ),
      verdeelLimietBedragExclBtw: _leesBedrag(
        json['verdeelLimietBedragExclBtw'],
      ),
      actief: _leesBool(json['actief'], standaardWaarde: true),
      volgorde: _leesInt(json['volgorde']),
      gewijzigdOp: json['gewijzigdOp']?.toString() ?? '',
    );
  }

  static double _normaliseerBedrag(double waarde) {
    if (!waarde.isFinite || waarde < 0) {
      return 0;
    }

    return waarde;
  }

  static double _leesBedrag(Object? waarde) {
    if (waarde is num) {
      return _normaliseerBedrag(waarde.toDouble());
    }

    final getal = double.tryParse(
      waarde?.toString().trim().replaceAll(',', '.') ?? '',
    );

    return _normaliseerBedrag(getal ?? 0);
  }

  static int _leesInt(Object? waarde) {
    if (waarde is int) {
      return waarde < 0 ? 0 : waarde;
    }

    final getal = int.tryParse(waarde?.toString() ?? '') ?? 0;
    return getal < 0 ? 0 : getal;
  }

  static bool _leesBool(Object? waarde, {required bool standaardWaarde}) {
    if (waarde is bool) {
      return waarde;
    }

    final tekst = waarde?.toString().trim().toLowerCase();
    if (tekst == 'true' || tekst == '1') {
      return true;
    }
    if (tekst == 'false' || tekst == '0') {
      return false;
    }

    return standaardWaarde;
  }
}
