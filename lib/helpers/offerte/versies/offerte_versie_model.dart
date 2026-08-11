// THIMACO-CONTROLE: OFFERTEVARIANTEN-BEWERKBAAR-ONDERTEKEND-APART-20260811
// THIMACO-CONTROLE: OFFERTEVERSIE-CONCEPT-ONDERTEKEND-LIJNAGE-20260806
import '../offerte_goedkeuring_model.dart';

enum OfferteVersieStatus {
  concept,
  ondertekend;

  String get opslagWaarde => name;

  static OfferteVersieStatus fromJson(
    Object? waarde, {
    required bool heeftHandtekening,
  }) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    if (tekst == 'ondertekend' || tekst == 'signed') {
      return OfferteVersieStatus.ondertekend;
    }
    if (tekst == 'concept' || tekst == 'draft') {
      return OfferteVersieStatus.concept;
    }

    // Achterwaartse compatibiliteit: oude records hadden nog geen status.
    return heeftHandtekening
        ? OfferteVersieStatus.ondertekend
        : OfferteVersieStatus.concept;
  }
}

class OfferteVersieModel {
  const OfferteVersieModel({
    required this.id,
    required this.projectSleutel,
    required this.versieNummer,
    required this.offerteNummer,
    required this.klantNaam,
    required this.offerteDatum,
    required this.opgeslagenOp,
    required this.totaalInclusiefBtw,
    required this.inhoudSignatuur,
    required this.status,
    required this.naam,
    required this.omschrijving,
    required this.goedkeuring,
    required this.titelhoofdJson,
    required this.positiesJson,
    required this.werkPositiesJson,
    this.bronVersieId = '',
    this.bronVersieNummer = 0,
  });

  final String id;
  final String projectSleutel;
  final int versieNummer;
  final String offerteNummer;
  final String klantNaam;
  final DateTime offerteDatum;
  final DateTime opgeslagenOp;
  final double totaalInclusiefBtw;
  final String inhoudSignatuur;
  final OfferteVersieStatus status;
  final String naam;
  final String omschrijving;
  final String bronVersieId;
  final int bronVersieNummer;
  final OfferteGoedkeuring goedkeuring;
  final Map<String, dynamic> titelhoofdJson;
  final List<Map<String, dynamic>> positiesJson;
  final List<Map<String, dynamic>> werkPositiesJson;

  // `concept` blijft bewust de opslagwaarde voor achterwaartse
  // compatibiliteit. In de UI betekent dit voortaan een bewerkbare
  // offertevariant, niet meer een historische conceptmomentopname.
  bool get isConcept => status == OfferteVersieStatus.concept;

  bool get isVariant => isConcept;

  bool get isOndertekend =>
      status == OfferteVersieStatus.ondertekend && goedkeuring.isOndertekend;

  bool get isOndertekendeMomentopname => isOndertekend;

  String get weergaveNaam {
    final ingevuld = naam.trim();
    if (ingevuld.isNotEmpty) return ingevuld;
    return isOndertekend
        ? 'Ondertekende offerte $versieNummer'
        : 'Offerte $versieNummer';
  }

  String get offerteVariantLabel {
    final ingevuld = naam.trim();
    return ingevuld.isEmpty
        ? 'Offerte $versieNummer'
        : 'Offerte $versieNummer · $ingevuld';
  }

  bool hoortBijVariant(String variantId, {int? variantNummer}) {
    final sleutel = variantId.trim();
    if (!isOndertekend || sleutel.isEmpty || bronVersieId.trim() != sleutel) {
      return false;
    }
    if (variantNummer != null && variantNummer > 0) {
      return bronVersieNummer == variantNummer && versieNummer == variantNummer;
    }
    return true;
  }

  bool get isGeldig {
    return id.trim().isNotEmpty &&
        projectSleutel.trim().isNotEmpty &&
        versieNummer > 0 &&
        inhoudSignatuur.trim().isNotEmpty &&
        (isConcept || isOndertekend);
  }

  OfferteVersieModel copyWith({
    String? id,
    String? projectSleutel,
    int? versieNummer,
    String? offerteNummer,
    String? klantNaam,
    DateTime? offerteDatum,
    DateTime? opgeslagenOp,
    double? totaalInclusiefBtw,
    String? inhoudSignatuur,
    OfferteVersieStatus? status,
    String? naam,
    String? omschrijving,
    String? bronVersieId,
    int? bronVersieNummer,
    OfferteGoedkeuring? goedkeuring,
    Map<String, dynamic>? titelhoofdJson,
    List<Map<String, dynamic>>? positiesJson,
    List<Map<String, dynamic>>? werkPositiesJson,
  }) {
    return OfferteVersieModel(
      id: id ?? this.id,
      projectSleutel: projectSleutel ?? this.projectSleutel,
      versieNummer: versieNummer ?? this.versieNummer,
      offerteNummer: offerteNummer ?? this.offerteNummer,
      klantNaam: klantNaam ?? this.klantNaam,
      offerteDatum: offerteDatum ?? this.offerteDatum,
      opgeslagenOp: opgeslagenOp ?? this.opgeslagenOp,
      totaalInclusiefBtw: totaalInclusiefBtw ?? this.totaalInclusiefBtw,
      inhoudSignatuur: inhoudSignatuur ?? this.inhoudSignatuur,
      status: status ?? this.status,
      naam: naam ?? this.naam,
      omschrijving: omschrijving ?? this.omschrijving,
      bronVersieId: bronVersieId ?? this.bronVersieId,
      bronVersieNummer: bronVersieNummer ?? this.bronVersieNummer,
      goedkeuring: goedkeuring ?? this.goedkeuring,
      titelhoofdJson: titelhoofdJson ?? this.titelhoofdJson,
      positiesJson: positiesJson ?? this.positiesJson,
      werkPositiesJson: werkPositiesJson ?? this.werkPositiesJson,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'projectSleutel': projectSleutel,
      'versieNummer': versieNummer,
      'offerteNummer': offerteNummer,
      'klantNaam': klantNaam,
      'offerteDatum': offerteDatum.toUtc().toIso8601String(),
      'opgeslagenOp': opgeslagenOp.toUtc().toIso8601String(),
      'totaalInclusiefBtw': totaalInclusiefBtw,
      'inhoudSignatuur': inhoudSignatuur,
      'status': status.opslagWaarde,
      'naam': naam,
      'omschrijving': omschrijving,
      'bronVersieId': bronVersieId,
      'bronVersieNummer': bronVersieNummer,
      'goedkeuring': goedkeuring.toJson(),
      'titelhoofd': Map<String, dynamic>.from(titelhoofdJson),
      'posities': positiesJson
          .map((positie) => Map<String, dynamic>.from(positie))
          .toList(),
      'werkPosities': werkPositiesJson
          .map((positie) => Map<String, dynamic>.from(positie))
          .toList(),
    };
  }

  factory OfferteVersieModel.fromJson(Map<String, dynamic> json) {
    final ruweGoedkeuring = json['goedkeuring'];
    final ruweTitelhoofd = json['titelhoofd'];
    final ruwePosities = json['posities'];
    final ruweWerkPosities = json['werkPosities'];
    final goedkeuring = ruweGoedkeuring is Map
        ? OfferteGoedkeuring.fromJson(
            Map<String, dynamic>.from(ruweGoedkeuring),
          )
        : OfferteGoedkeuring.leeg();
    final status = OfferteVersieStatus.fromJson(
      json['status'],
      heeftHandtekening: goedkeuring.isOndertekend,
    );

    return OfferteVersieModel(
      id: json['id']?.toString() ?? '',
      projectSleutel: json['projectSleutel']?.toString() ?? '',
      versieNummer: _leesInt(json['versieNummer']),
      offerteNummer: json['offerteNummer']?.toString() ?? '',
      klantNaam: json['klantNaam']?.toString() ?? '',
      offerteDatum: _leesDatum(json['offerteDatum']),
      opgeslagenOp: _leesDatum(json['opgeslagenOp']),
      totaalInclusiefBtw: _leesDouble(json['totaalInclusiefBtw']),
      inhoudSignatuur: json['inhoudSignatuur']?.toString() ?? '',
      status: status,
      naam: json['naam']?.toString() ?? '',
      omschrijving: json['omschrijving']?.toString() ?? '',
      bronVersieId: json['bronVersieId']?.toString() ?? '',
      bronVersieNummer: _leesInt(json['bronVersieNummer']),
      goedkeuring: goedkeuring,
      titelhoofdJson: ruweTitelhoofd is Map
          ? Map<String, dynamic>.from(ruweTitelhoofd)
          : <String, dynamic>{},
      positiesJson: ruwePosities is List
          ? ruwePosities
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList(growable: false)
          : const <Map<String, dynamic>>[],
      werkPositiesJson: ruweWerkPosities is List
          ? ruweWerkPosities
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList(growable: false)
          : ruwePosities is List
          ? ruwePosities
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList(growable: false)
          : const <Map<String, dynamic>>[],
    );
  }

  static int _leesInt(Object? waarde) {
    if (waarde is int) return waarde;
    if (waarde is num) return waarde.toInt();
    return int.tryParse(waarde?.toString() ?? '') ?? 0;
  }

  static double _leesDouble(Object? waarde) {
    if (waarde is num) return waarde.toDouble();
    return double.tryParse(waarde?.toString() ?? '') ?? 0.0;
  }

  static DateTime _leesDatum(Object? waarde) {
    return DateTime.tryParse(waarde?.toString() ?? '')?.toLocal() ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }
}
