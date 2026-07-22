import 'offerte_toegepaste_prijsregel_model.dart';
import 'offerte_vrije_prijs_selectie_model.dart';

/// Gemeenschappelijke prijsopslag voor opmeetfiches die hun prijsgegevens niet
/// in een eigen artikelspecifiek model bewaren.
///
/// De vaste inzethor behoudt voorlopig haar bestaande prijsvelden. PVC ramen
/// gebruiken vanaf nu dit model. Dezelfde structuur kan later ook voor ALU
/// ramen, deuren en schuiframen worden hergebruikt.
class OfferteArtikelPrijsDataModel {
  const OfferteArtikelPrijsDataModel({
    this.prijsPerStukExclBtw = 0,
    this.toegepasteTechnischePrijsregels =
        const <OfferteToegepastePrijsregelModel>[],
    this.technischePrijsSignatuur = '',
    this.toegepasteVerdeeldePrijsregels =
        const <OfferteToegepastePrijsregelModel>[],
    this.verdeeldePrijsSignatuur = '',
    this.vrijeArtikelPrijsSelecties = const <OfferteVrijePrijsSelectieModel>[],
    this.vrijeArtikelPrijsSignatuur = '',
    this.artikelKortingPercentage = 0,
    this.artikelWinstmargePercentage = 0,
  });

  final double prijsPerStukExclBtw;
  final List<OfferteToegepastePrijsregelModel> toegepasteTechnischePrijsregels;
  final String technischePrijsSignatuur;
  final List<OfferteToegepastePrijsregelModel> toegepasteVerdeeldePrijsregels;
  final String verdeeldePrijsSignatuur;
  final List<OfferteVrijePrijsSelectieModel> vrijeArtikelPrijsSelecties;
  final String vrijeArtikelPrijsSignatuur;
  final double artikelKortingPercentage;
  final double artikelWinstmargePercentage;

  bool get heeftPrijsPerStuk => prijsPerStukExclBtw > 0.0;
  bool get heeftArtikelKorting => artikelKortingPercentage > 0.0;
  bool get heeftArtikelWinstmarge => artikelWinstmargePercentage > 0.0;

  String get artikelKortingOmschrijving {
    return 'Korting ${_percentageTekst(artikelKortingPercentage)} %';
  }

  String get artikelWinstmargeOmschrijving {
    return 'Winstmarge ${_percentageTekst(artikelWinstmargePercentage)} %';
  }

  bool get isLeeg {
    return prijsPerStukExclBtw <= 0.0 &&
        toegepasteTechnischePrijsregels.isEmpty &&
        technischePrijsSignatuur.isEmpty &&
        toegepasteVerdeeldePrijsregels.isEmpty &&
        verdeeldePrijsSignatuur.isEmpty &&
        vrijeArtikelPrijsSelecties.isEmpty &&
        vrijeArtikelPrijsSignatuur.isEmpty &&
        artikelKortingPercentage <= 0.0 &&
        artikelWinstmargePercentage <= 0.0;
  }

  OfferteArtikelPrijsDataModel copyWith({
    double? prijsPerStukExclBtw,
    List<OfferteToegepastePrijsregelModel>? toegepasteTechnischePrijsregels,
    String? technischePrijsSignatuur,
    List<OfferteToegepastePrijsregelModel>? toegepasteVerdeeldePrijsregels,
    String? verdeeldePrijsSignatuur,
    List<OfferteVrijePrijsSelectieModel>? vrijeArtikelPrijsSelecties,
    String? vrijeArtikelPrijsSignatuur,
    double? artikelKortingPercentage,
    double? artikelWinstmargePercentage,
  }) {
    return OfferteArtikelPrijsDataModel(
      prijsPerStukExclBtw: prijsPerStukExclBtw ?? this.prijsPerStukExclBtw,
      toegepasteTechnischePrijsregels:
          toegepasteTechnischePrijsregels ??
          this.toegepasteTechnischePrijsregels,
      technischePrijsSignatuur:
          technischePrijsSignatuur ?? this.technischePrijsSignatuur,
      toegepasteVerdeeldePrijsregels:
          toegepasteVerdeeldePrijsregels ?? this.toegepasteVerdeeldePrijsregels,
      verdeeldePrijsSignatuur:
          verdeeldePrijsSignatuur ?? this.verdeeldePrijsSignatuur,
      vrijeArtikelPrijsSelecties:
          vrijeArtikelPrijsSelecties ?? this.vrijeArtikelPrijsSelecties,
      vrijeArtikelPrijsSignatuur:
          vrijeArtikelPrijsSignatuur ?? this.vrijeArtikelPrijsSignatuur,
      artikelKortingPercentage:
          artikelKortingPercentage ?? this.artikelKortingPercentage,
      artikelWinstmargePercentage:
          artikelWinstmargePercentage ?? this.artikelWinstmargePercentage,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'prijsPerStukExclBtw': prijsPerStukExclBtw,
      'toegepasteTechnischePrijsregels': toegepasteTechnischePrijsregels
          .map((regel) => regel.toJson())
          .toList(),
      'technischePrijsSignatuur': technischePrijsSignatuur,
      'toegepasteVerdeeldePrijsregels': toegepasteVerdeeldePrijsregels
          .map((regel) => regel.toJson())
          .toList(),
      'verdeeldePrijsSignatuur': verdeeldePrijsSignatuur,
      'vrijeArtikelPrijsSelecties': vrijeArtikelPrijsSelecties
          .map((selectie) => selectie.toJson())
          .toList(),
      'vrijeArtikelPrijsSignatuur': vrijeArtikelPrijsSignatuur,
      'artikelKortingPercentage': artikelKortingPercentage,
      'artikelWinstmargePercentage': artikelWinstmargePercentage,
    };
  }

  factory OfferteArtikelPrijsDataModel.fromJson(Map<String, dynamic> json) {
    return OfferteArtikelPrijsDataModel(
      prijsPerStukExclBtw: _leesDouble(json['prijsPerStukExclBtw']),
      toegepasteTechnischePrijsregels: _leesLijst(
        json['toegepasteTechnischePrijsregels'],
        OfferteToegepastePrijsregelModel.fromJson,
      ),
      technischePrijsSignatuur:
          json['technischePrijsSignatuur']?.toString() ?? '',
      toegepasteVerdeeldePrijsregels: _leesLijst(
        json['toegepasteVerdeeldePrijsregels'],
        OfferteToegepastePrijsregelModel.fromJson,
      ),
      verdeeldePrijsSignatuur:
          json['verdeeldePrijsSignatuur']?.toString() ?? '',
      vrijeArtikelPrijsSelecties: _leesLijst(
        json['vrijeArtikelPrijsSelecties'],
        OfferteVrijePrijsSelectieModel.fromJson,
      ),
      vrijeArtikelPrijsSignatuur:
          json['vrijeArtikelPrijsSignatuur']?.toString() ?? '',
      artikelKortingPercentage: _leesDouble(json['artikelKortingPercentage']),
      artikelWinstmargePercentage: _leesDouble(
        json['artikelWinstmargePercentage'],
      ),
    );
  }

  static String _percentageTekst(double waarde) {
    final afgerond = (waarde * 100.0).roundToDouble() / 100.0;
    var tekst = afgerond.toStringAsFixed(2);
    tekst = tekst.replaceFirst(RegExp(r'0+$'), '');
    tekst = tekst.replaceFirst(RegExp(r'\.$'), '');
    return tekst;
  }
}

List<T> _leesLijst<T>(
  Object? waarde,
  T Function(Map<String, dynamic> json) maker,
) {
  if (waarde is! List) return <T>[];

  return waarde
      .whereType<Map>()
      .map((item) {
        return maker(Map<String, dynamic>.from(item));
      })
      .toList(growable: false);
}

double _leesDouble(Object? waarde) {
  if (waarde is double) return waarde;
  if (waarde is num) return waarde.toDouble();

  return double.tryParse(
        waarde?.toString().trim().replaceAll(',', '.') ?? '',
      ) ??
      0.0;
}
