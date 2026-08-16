// THIMACO-CONTROLE: ANALYZERFIX-ROND-HOEVEELHEID-PRIJS-PER-POSITIE-20260815
// THIMACO-CONTROLE: PRIJS-PER-POSITIE-EENHEID-HOUDT-REKENING-MET-BREEDTE-HOOGTE-20260815
// THIMACO-CONTROLE: PRIJSARCHITECTUUR-OPRUIMEN-STAP3-ZONDER-LEGACY-PRIJSVELDEN-20260814
// THIMACO-CONTROLE: PRIJS-PER-POSITIE-LOKALE-OPSLAG-20260813
import 'offerte_toegepaste_prijsregel_model.dart';

// THIMACO-CONTROLE: PRIJS-PER-POSITIE-TYPES-IN-PRIJS-DATA-MODEL-20260813

enum OffertePrijsPerPositieType {
  aankoop,
  verkoop;

  String get jsonWaarde =>
      this == OffertePrijsPerPositieType.aankoop ? 'A' : 'V';

  String get label => jsonWaarde;

  bool get isAankoop => this == OffertePrijsPerPositieType.aankoop;
  bool get isVerkoop => this == OffertePrijsPerPositieType.verkoop;

  static OffertePrijsPerPositieType fromJson(Object? waarde) {
    final sleutel = waarde?.toString().trim().toLowerCase() ?? '';
    switch (sleutel) {
      case 'a':
      case 'aankoop':
      case 'aankoopprijs':
        return OffertePrijsPerPositieType.aankoop;
      case 'v':
      case 'verkoop':
      case 'verkoopprijs':
      default:
        return OffertePrijsPerPositieType.verkoop;
    }
  }
}

enum OffertePrijsPerPositieWeergave {
  uit,
  tekst,
  prijs;

  String get jsonWaarde {
    switch (this) {
      case OffertePrijsPerPositieWeergave.uit:
        return 'uit';
      case OffertePrijsPerPositieWeergave.tekst:
        return 'tekst';
      case OffertePrijsPerPositieWeergave.prijs:
        return 'prijs';
    }
  }

  String get label {
    switch (this) {
      case OffertePrijsPerPositieWeergave.uit:
        return 'Uit';
      case OffertePrijsPerPositieWeergave.tekst:
        return 'Tekst';
      case OffertePrijsPerPositieWeergave.prijs:
        return '€';
    }
  }

  bool get toonOmschrijving => this != OffertePrijsPerPositieWeergave.uit;
  bool get toonPrijs => this == OffertePrijsPerPositieWeergave.prijs;

  static OffertePrijsPerPositieWeergave fromJson(Object? waarde) {
    final sleutel = waarde?.toString().trim().toLowerCase() ?? '';
    switch (sleutel) {
      case 'tekst':
      case 'text':
      case 'omschrijving':
        return OffertePrijsPerPositieWeergave.tekst;
      case 'prijs':
      case '€':
      case 'euro':
      case 'metprijs':
      case 'met_prijs':
        return OffertePrijsPerPositieWeergave.prijs;
      case 'uit':
      case 'off':
      case 'verborgen':
      default:
        return OffertePrijsPerPositieWeergave.uit;
    }
  }
}

class OffertePrijsPerPositieRegelModel {
  const OffertePrijsPerPositieRegelModel({
    required this.id,
    required this.omschrijving,
    this.type = OffertePrijsPerPositieType.verkoop,
    this.aantal = 1,
    this.eenheid = 'st',
    this.eenheidsPrijsExclBtw = 0,
    double winstPercentage = 0,
    this.offerteWeergave = OffertePrijsPerPositieWeergave.uit,
  }) : winstPercentage = type == OffertePrijsPerPositieType.verkoop
           ? 0
           : winstPercentage;

  final String id;
  final String omschrijving;
  final OffertePrijsPerPositieType type;
  final double aantal;
  final String eenheid;
  final double eenheidsPrijsExclBtw;
  final double winstPercentage;
  final OffertePrijsPerPositieWeergave offerteWeergave;

  bool get isAankoop => type.isAankoop;
  bool get isVerkoop => type.isVerkoop;

  double get veiligAantal => _normaliseerHoeveelheid(aantal);
  double get veiligeEenheidsPrijsExclBtw =>
      _normaliseerBedrag(eenheidsPrijsExclBtw);

  double get veiligWinstPercentage {
    if (isVerkoop) return 0.0;
    return _normaliseerPercentage(winstPercentage);
  }

  double get basisTotaalExclBtw {
    return _rondBedragAf(veiligAantal * veiligeEenheidsPrijsExclBtw);
  }

  double get winstBedragExclBtw {
    if (!isAankoop || veiligWinstPercentage <= 0.0) return 0.0;
    return _rondBedragAf(basisTotaalExclBtw * (veiligWinstPercentage / 100.0));
  }

  double get eindTotaalExclBtw {
    return _rondBedragAf(basisTotaalExclBtw + winstBedragExclBtw);
  }

  double get verkoopPrijsPerEenheidExclBtw {
    if (veiligAantal <= 0.0) return 0.0;
    return _rondBedragAf(eindTotaalExclBtw / veiligAantal);
  }

  /// Werkelijke rekenhoeveelheid voor deze lokale prijsregel.
  ///
  /// st, uur, L/M, KM en m² gebruiken [aantal] rechtstreeks.
  /// Maatgebonden eenheden rekenen met de actuele positie-afmetingen in meter.
  /// [aantal] blijft daarbij de lokale vermenigvuldigingsfactor en wordt nooit
  /// automatisch vervangen door het artikelaantal van de positie.
  double hoeveelheidVoorMaten({required int breedteMm, required int hoogteMm}) {
    final basisAantal = veiligAantal;
    if (basisAantal <= 0.0) return 0.0;

    final breedteMeter = breedteMm <= 0 ? 0.0 : breedteMm / 1000.0;
    final hoogteMeter = hoogteMm <= 0 ? 0.0 : hoogteMm / 1000.0;
    final sleutel = _normaliseerEenheidVoorBerekening(eenheid);

    final factor = switch (sleutel) {
      '1xb' => breedteMeter,
      '1xh' => hoogteMeter,
      '2xb' => 2.0 * breedteMeter,
      '2xh' => 2.0 * hoogteMeter,
      '2xhen1xb' => (2.0 * hoogteMeter) + breedteMeter,
      '1xhen2xb' => hoogteMeter + (2.0 * breedteMeter),
      'rondom' => (2.0 * breedteMeter) + (2.0 * hoogteMeter),
      'oppervlakte' => breedteMeter * hoogteMeter,
      _ => 1.0,
    };

    return _rondHoeveelheidAf(basisAantal * factor);
  }

  double basisTotaalExclBtwVoorMaten({
    required int breedteMm,
    required int hoogteMm,
  }) {
    return _rondBedragAf(
      hoeveelheidVoorMaten(breedteMm: breedteMm, hoogteMm: hoogteMm) *
          veiligeEenheidsPrijsExclBtw,
    );
  }

  double winstBedragExclBtwVoorMaten({
    required int breedteMm,
    required int hoogteMm,
  }) {
    if (!isAankoop || veiligWinstPercentage <= 0.0) return 0.0;
    return _rondBedragAf(
      basisTotaalExclBtwVoorMaten(breedteMm: breedteMm, hoogteMm: hoogteMm) *
          (veiligWinstPercentage / 100.0),
    );
  }

  double eindTotaalExclBtwVoorMaten({
    required int breedteMm,
    required int hoogteMm,
  }) {
    return _rondBedragAf(
      basisTotaalExclBtwVoorMaten(breedteMm: breedteMm, hoogteMm: hoogteMm) +
          winstBedragExclBtwVoorMaten(breedteMm: breedteMm, hoogteMm: hoogteMm),
    );
  }

  double verkoopPrijsPerEenheidExclBtwVoorMaten({
    required int breedteMm,
    required int hoogteMm,
  }) {
    final hoeveelheid = hoeveelheidVoorMaten(
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );
    if (hoeveelheid <= 0.0) return 0.0;

    return _rondBedragAf(
      eindTotaalExclBtwVoorMaten(breedteMm: breedteMm, hoogteMm: hoogteMm) /
          hoeveelheid,
    );
  }

  bool get isGeldig {
    return id.trim().isNotEmpty &&
        omschrijving.trim().isNotEmpty &&
        veiligAantal > 0.0 &&
        veiligeEenheidsPrijsExclBtw >= 0.0;
  }

  bool get toonOmschrijvingOpOfferte => offerteWeergave.toonOmschrijving;
  bool get toonPrijsOpOfferte => offerteWeergave.toonPrijs;

  OffertePrijsPerPositieRegelModel copyWith({
    String? id,
    String? omschrijving,
    OffertePrijsPerPositieType? type,
    double? aantal,
    String? eenheid,
    double? eenheidsPrijsExclBtw,
    double? winstPercentage,
    OffertePrijsPerPositieWeergave? offerteWeergave,
  }) {
    final nieuwType = type ?? this.type;
    final nieuweWinst = nieuwType.isVerkoop
        ? 0.0
        : (winstPercentage ?? this.winstPercentage);

    return OffertePrijsPerPositieRegelModel(
      id: id ?? this.id,
      omschrijving: omschrijving ?? this.omschrijving,
      type: nieuwType,
      aantal: aantal ?? this.aantal,
      eenheid: eenheid ?? this.eenheid,
      eenheidsPrijsExclBtw: eenheidsPrijsExclBtw ?? this.eenheidsPrijsExclBtw,
      winstPercentage: nieuweWinst,
      offerteWeergave: offerteWeergave ?? this.offerteWeergave,
    );
  }

  OffertePrijsPerPositieRegelModel kopieMetNieuwId(String nieuwId) {
    return copyWith(id: nieuwId);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id.trim(),
      'omschrijving': omschrijving.trim(),
      'type': type.jsonWaarde,
      'aantal': veiligAantal,
      'eenheid': eenheid.trim().isEmpty ? 'st' : eenheid.trim(),
      'eenheidsPrijsExclBtw': veiligeEenheidsPrijsExclBtw,
      'winstPercentage': veiligWinstPercentage,
      'offerteWeergave': offerteWeergave.jsonWaarde,
    };
  }

  factory OffertePrijsPerPositieRegelModel.fromJson(Map<String, dynamic> json) {
    final type = OffertePrijsPerPositieType.fromJson(json['type']);

    return OffertePrijsPerPositieRegelModel(
      id: json['id']?.toString().trim() ?? '',
      omschrijving: json['omschrijving']?.toString().trim() ?? '',
      type: type,
      aantal: _leesRegelDouble(json['aantal'], standaard: 1.0),
      eenheid: _leesRegelEenheid(json['eenheid']),
      eenheidsPrijsExclBtw: _leesRegelDouble(json['eenheidsPrijsExclBtw']),
      winstPercentage: type.isVerkoop
          ? 0.0
          : _leesRegelDouble(json['winstPercentage']),
      offerteWeergave: OffertePrijsPerPositieWeergave.fromJson(
        json['offerteWeergave'],
      ),
    );
  }

  static String _leesRegelEenheid(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';
    return tekst.isEmpty ? 'st' : tekst;
  }

  static double _leesRegelDouble(Object? waarde, {double standaard = 0.0}) {
    if (waarde is double) return waarde.isFinite ? waarde : standaard;
    if (waarde is num) {
      final getal = waarde.toDouble();
      return getal.isFinite ? getal : standaard;
    }

    final gelezen = double.tryParse(
      waarde?.toString().trim().replaceAll(',', '.') ?? '',
    );
    return gelezen != null && gelezen.isFinite ? gelezen : standaard;
  }

  static String _normaliseerEenheidVoorBerekening(String waarde) {
    return waarde
        .trim()
        .toLowerCase()
        .replaceAll('×', 'x')
        .replaceAll(RegExp(r'\s+'), '');
  }

  static double _normaliseerHoeveelheid(double waarde) {
    if (!waarde.isFinite || waarde <= 0.0) return 0.0;
    return (waarde * 10000.0).roundToDouble() / 10000.0;
  }

  static double _rondHoeveelheidAf(double waarde) {
    if (!waarde.isFinite || waarde <= 0.0) return 0.0;
    return (waarde * 10000.0).roundToDouble() / 10000.0;
  }

  static double _normaliseerBedrag(double waarde) {
    if (!waarde.isFinite || waarde < 0.0) return 0.0;
    return _rondBedragAf(waarde);
  }

  static double _normaliseerPercentage(double waarde) {
    if (!waarde.isFinite || waarde <= 0.0) return 0.0;
    if (waarde >= 500.0) return 500.0;
    return (waarde * 100.0).roundToDouble() / 100.0;
  }

  static double _rondBedragAf(double waarde) {
    if (!waarde.isFinite || waarde <= 0.0) return 0.0;
    return (waarde * 100.0).roundToDouble() / 100.0;
  }
}

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
    this.prijsPerPositieRegels = const <OffertePrijsPerPositieRegelModel>[],
    this.artikelKortingPercentage = 0,
    this.artikelWinstmargePercentage = 0,
  });

  final double prijsPerStukExclBtw;
  final List<OfferteToegepastePrijsregelModel> toegepasteTechnischePrijsregels;
  final String technischePrijsSignatuur;

  /// Lokale prijsregels die uitsluitend bij deze offertepositie horen.
  final List<OffertePrijsPerPositieRegelModel> prijsPerPositieRegels;

  final double artikelKortingPercentage;
  final double artikelWinstmargePercentage;

  bool get heeftPrijsPerStuk => prijsPerStukExclBtw > 0.0;
  bool get heeftPrijsPerPositieRegels => prijsPerPositieRegels.isNotEmpty;
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
        prijsPerPositieRegels.isEmpty &&
        artikelKortingPercentage <= 0.0 &&
        artikelWinstmargePercentage <= 0.0;
  }

  OfferteArtikelPrijsDataModel copyWith({
    double? prijsPerStukExclBtw,
    List<OfferteToegepastePrijsregelModel>? toegepasteTechnischePrijsregels,
    String? technischePrijsSignatuur,
    List<OffertePrijsPerPositieRegelModel>? prijsPerPositieRegels,
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
      prijsPerPositieRegels:
          prijsPerPositieRegels ?? this.prijsPerPositieRegels,
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
      'prijsPerPositieRegels': prijsPerPositieRegels
          .map((regel) => regel.toJson())
          .toList(),
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
      prijsPerPositieRegels: _leesLijst(
        json['prijsPerPositieRegels'],
        OffertePrijsPerPositieRegelModel.fromJson,
      ),
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
