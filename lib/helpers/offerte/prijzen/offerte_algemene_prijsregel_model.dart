import 'offerte_prijs_eenheid.dart';
import 'offerte_prijs_uitschrijfmodus.dart';

class OfferteAlgemenePrijsregelModel {
  OfferteAlgemenePrijsregelModel({
    required String id,
    required String omschrijving,
    required double prijsExclBtw,
    required this.eenheid,
    required this.uitschrijfmodus,
    List<String> toepasselijkeFormulierTypes = const <String>[],
    this.altijdToepassenAlsArtikelInGebruik = false,
    double maximaleTotaleStukprijs = 0,
    this.actief = true,
    int volgorde = 0,
    String gewijzigdOp = '',
  }) : id = id.trim(),
       omschrijving = omschrijving.trim(),
       prijsExclBtw = _normaliseerBedrag(prijsExclBtw),
       toepasselijkeFormulierTypes = _normaliseerFormulierTypes(
         toepasselijkeFormulierTypes,
       ),
       maximaleTotaleStukprijs = _normaliseerBedrag(maximaleTotaleStukprijs),
       volgorde = volgorde < 0 ? 0 : volgorde,
       gewijzigdOp = gewijzigdOp.trim();

  final String id;
  final String omschrijving;
  final double prijsExclBtw;
  final OffertePrijsEenheid eenheid;
  final OffertePrijsUitschrijfmodus uitschrijfmodus;

  /// De artikeltypes waarop deze algemene prijsregel mag worden toegepast.
  final List<String> toepasselijkeFormulierTypes;

  /// Wanneer dit actief is, wordt de prijsregel automatisch toegepast zodra
  /// minstens één overeenkomstig artikel op het overzicht in gebruik is.
  final bool altijdToepassenAlsArtikelInGebruik;

  /// Maximale som van de ingevulde stukprijzen maal het aantal stuks waarop
  /// deze prijsregel mag worden toegepast.
  ///
  /// Alleen van toepassing op verdeelde algemene prijsregels.
  /// Een waarde van 0 betekent dat er geen bovengrens geldt.
  final double maximaleTotaleStukprijs;

  final bool actief;
  final int volgorde;
  final String gewijzigdOp;

  bool get isGeldig {
    return id.isNotEmpty && omschrijving.isNotEmpty;
  }

  bool get heeftMaximaleTotaleStukprijs {
    return maximaleTotaleStukprijs > 0;
  }

  OfferteAlgemenePrijsregelModel copyWith({
    String? id,
    String? omschrijving,
    double? prijsExclBtw,
    OffertePrijsEenheid? eenheid,
    OffertePrijsUitschrijfmodus? uitschrijfmodus,
    List<String>? toepasselijkeFormulierTypes,
    bool? altijdToepassenAlsArtikelInGebruik,
    double? maximaleTotaleStukprijs,
    bool? actief,
    int? volgorde,
    String? gewijzigdOp,
  }) {
    return OfferteAlgemenePrijsregelModel(
      id: id ?? this.id,
      omschrijving: omschrijving ?? this.omschrijving,
      prijsExclBtw: prijsExclBtw ?? this.prijsExclBtw,
      eenheid: eenheid ?? this.eenheid,
      uitschrijfmodus: uitschrijfmodus ?? this.uitschrijfmodus,
      toepasselijkeFormulierTypes:
          toepasselijkeFormulierTypes ?? this.toepasselijkeFormulierTypes,
      altijdToepassenAlsArtikelInGebruik:
          altijdToepassenAlsArtikelInGebruik ??
          this.altijdToepassenAlsArtikelInGebruik,
      maximaleTotaleStukprijs:
          maximaleTotaleStukprijs ?? this.maximaleTotaleStukprijs,
      actief: actief ?? this.actief,
      volgorde: volgorde ?? this.volgorde,
      gewijzigdOp: gewijzigdOp ?? this.gewijzigdOp,
    );
  }

  OfferteAlgemenePrijsregelModel metWijzigingsDatum() {
    return copyWith(gewijzigdOp: DateTime.now().toUtc().toIso8601String());
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'omschrijving': omschrijving,
      'prijsExclBtw': prijsExclBtw,
      'eenheid': eenheid.jsonWaarde,
      'uitschrijfmodus': uitschrijfmodus.jsonWaarde,
      'toepasselijkeFormulierTypes': toepasselijkeFormulierTypes,
      'altijdToepassenAlsArtikelInGebruik': altijdToepassenAlsArtikelInGebruik,
      'maximaleTotaleStukprijs': maximaleTotaleStukprijs,
      'actief': actief,
      'volgorde': volgorde,
      'gewijzigdOp': gewijzigdOp,
    };
  }

  factory OfferteAlgemenePrijsregelModel.fromJson(Map<String, dynamic> json) {
    return OfferteAlgemenePrijsregelModel(
      id: json['id']?.toString() ?? '',
      omschrijving: json['omschrijving']?.toString() ?? '',
      prijsExclBtw: _leesBedrag(json['prijsExclBtw']),
      eenheid: OffertePrijsEenheid.fromJson(json['eenheid']),
      uitschrijfmodus: OffertePrijsUitschrijfmodus.fromJson(
        json['uitschrijfmodus'],
      ),
      toepasselijkeFormulierTypes: _leesFormulierTypes(
        json['toepasselijkeFormulierTypes'],
      ),
      altijdToepassenAlsArtikelInGebruik: _leesBool(
        json['altijdToepassenAlsArtikelInGebruik'],
        standaardWaarde: false,
      ),
      maximaleTotaleStukprijs: _leesBedrag(json['maximaleTotaleStukprijs']),
      actief: _leesBool(json['actief'], standaardWaarde: true),
      volgorde: _leesInt(json['volgorde']),
      gewijzigdOp: json['gewijzigdOp']?.toString() ?? '',
    );
  }

  static List<String> _normaliseerFormulierTypes(Iterable<String> waarden) {
    final perSleutel = <String, String>{};

    for (final waarde in waarden) {
      final formulierType = waarde.trim();
      final sleutel = formulierType.toLowerCase();

      if (sleutel.isEmpty) {
        continue;
      }

      perSleutel.putIfAbsent(sleutel, () => formulierType);
    }

    return List<String>.unmodifiable(perSleutel.values);
  }

  static List<String> _leesFormulierTypes(Object? waarde) {
    if (waarde is! List) {
      return const <String>[];
    }

    return waarde
        .map((item) => item?.toString() ?? '')
        .where((item) => item.trim().isNotEmpty)
        .toList(growable: false);
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

    final getal = int.tryParse(waarde?.toString() ?? '');

    return getal == null || getal < 0 ? 0 : getal;
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
