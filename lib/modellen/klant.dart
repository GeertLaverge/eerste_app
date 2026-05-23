import 'klant_artikel.dart';
import 'planning_dag.dart';

class ExtraWerkItem {
  DateTime? datum;
  int? startUur;
  int? startMinuut;
  int? eindUur;
  int? eindMinuut;
  String omschrijving;

  ExtraWerkItem({
    this.datum,
    this.startUur,
    this.startMinuut,
    this.eindUur,
    this.eindMinuut,
    this.omschrijving = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'datum': datum?.toIso8601String(),
      'startUur': startUur,
      'startMinuut': startMinuut,
      'eindUur': eindUur,
      'eindMinuut': eindMinuut,
      'omschrijving': omschrijving,
    };
  }

  factory ExtraWerkItem.fromMap(Map<String, dynamic> map) {
    return ExtraWerkItem(
      datum: map['datum'] != null ? DateTime.tryParse(map['datum']) : null,
      startUur: map['startUur'],
      startMinuut: map['startMinuut'],
      eindUur: map['eindUur'],
      eindMinuut: map['eindMinuut'],
      omschrijving: map['omschrijving'] ?? '',
    );
  }
}

class KlantTaakItem {
  String tekst;
  bool isAfgewerkt;

  KlantTaakItem({
    this.tekst = '',
    this.isAfgewerkt = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'tekst': tekst,
      'isAfgewerkt': isAfgewerkt,
    };
  }

  factory KlantTaakItem.fromMap(Map<String, dynamic> map) {
    return KlantTaakItem(
      tekst: map['tekst'] ?? '',
      isAfgewerkt: map['isAfgewerkt'] ?? false,
    );
  }
}

class KraanReservering {
  DateTime? datum;
  int? uur;
  int? minuut;
  bool gereserveerd;

  KraanReservering({
    this.datum,
    this.uur,
    this.minuut,
    this.gereserveerd = false,
  });

  String get tijdTekst {
    if (uur == null || minuut == null) return '';
    final u = uur.toString().padLeft(2, '0');
    final m = minuut.toString().padLeft(2, '0');
    return '$u:$m';
  }

  Map<String, dynamic> toMap() {
    return {
      'datum': datum?.toIso8601String(),
      'uur': uur,
      'minuut': minuut,
      'gereserveerd': gereserveerd,
    };
  }

  factory KraanReservering.fromMap(Map<String, dynamic> map) {
    return KraanReservering(
      datum: map['datum'] != null ? DateTime.tryParse(map['datum']) : null,
      uur: map['uur'],
      minuut: map['minuut'],
      gereserveerd: map['gereserveerd'] ?? false,
    );
  }
}

class Klant {
  String klantenNr;
  String klantnaam;
  String adres;
  String telefoon;
  String email;
  String opmerkingen;

  bool isNadienst;
  bool isProjectAfgewerkt;
  bool isOpTeVolgen;
  bool geenArtikelsNodig;

  String nogAfTeWerken;

  bool toonOpmerkingen;
  bool toonKlantTaak;
  String klantTaakTekst;
  String klantTaakMoment;
  DateTime? klantTaakVrijeDatum;
  bool klantTaakAfgewerkt;

  List<KlantTaakItem> klantTaken;

  List<KlantLeverancier> klantLeveranciers;
  List<PlanningDag> planningDagen;
  List<ExtraWerkItem> extraWerkItems;

  KraanReservering? kraanReservering;

  Klant({
    required this.klantenNr,
    required this.klantnaam,
    required this.adres,
    required this.telefoon,
    required this.email,
    this.opmerkingen = '',
    this.isNadienst = false,
    this.isProjectAfgewerkt = false,
    this.isOpTeVolgen = false,
    this.geenArtikelsNodig = false,
    this.nogAfTeWerken = '',
    this.toonOpmerkingen = false,
    this.toonKlantTaak = false,
    this.klantTaakTekst = '',
    this.klantTaakMoment = 'eerstePlaatsingsdag',
    this.klantTaakVrijeDatum,
    this.klantTaakAfgewerkt = false,
    List<KlantTaakItem>? klantTaken,
    required this.klantLeveranciers,
    required this.planningDagen,
    List<ExtraWerkItem>? extraWerkItems,
    this.kraanReservering,
  })  : klantTaken = klantTaken ?? [],
        extraWerkItems = extraWerkItems ?? [];

  Map<String, dynamic> toMap() {
    return {
      'klantenNr': klantenNr,
      'klantnaam': klantnaam,
      'adres': adres,
      'telefoon': telefoon,
      'email': email,
      'opmerkingen': opmerkingen,
      'isNadienst': isNadienst,
      'isProjectAfgewerkt': isProjectAfgewerkt,
      'isOpTeVolgen': isOpTeVolgen,
      'geenArtikelsNodig': geenArtikelsNodig,
      'nogAfTeWerken': nogAfTeWerken,
      'toonOpmerkingen': toonOpmerkingen,
      'toonKlantTaak': toonKlantTaak,
      'klantTaakTekst': klantTaakTekst,
      'klantTaakMoment': klantTaakMoment,
      'klantTaakVrijeDatum': klantTaakVrijeDatum?.toIso8601String(),
      'klantTaakAfgewerkt': klantTaakAfgewerkt,
      'klantTaken': klantTaken.map((e) => e.toMap()).toList(),
      'klantLeveranciers': klantLeveranciers.map((e) => e.toMap()).toList(),
      'planningDagen': planningDagen.map((e) => e.toMap()).toList(),
      'extraWerkItems': extraWerkItems.map((e) => e.toMap()).toList(),
      'kraanReservering': kraanReservering?.toMap(),
    };
  }

  factory Klant.fromMap(Map<String, dynamic> map) {
    final oudeTaakTekst = map['klantTaakTekst'] ?? '';

    final geladenKlantTaken = (map['klantTaken'] as List<dynamic>? ?? [])
        .map((e) => KlantTaakItem.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    if (geladenKlantTaken.isEmpty &&
        oudeTaakTekst.toString().trim().isNotEmpty) {
      geladenKlantTaken.add(
        KlantTaakItem(
          tekst: oudeTaakTekst,
          isAfgewerkt: map['klantTaakAfgewerkt'] ?? false,
        ),
      );
    }

    return Klant(
      klantenNr: map['klantenNr'] ?? '',
      klantnaam: map['klantnaam'] ?? '',
      adres: map['adres'] ?? '',
      telefoon: map['telefoon'] ?? '',
      email: map['email'] ?? '',
      opmerkingen: map['opmerkingen'] ?? '',
      isNadienst: map['isNadienst'] ?? false,
      isProjectAfgewerkt: map['isProjectAfgewerkt'] ?? false,
      isOpTeVolgen: map['isOpTeVolgen'] ?? false,
      geenArtikelsNodig: map['geenArtikelsNodig'] ?? false,
      nogAfTeWerken: map['nogAfTeWerken'] ?? '',
      toonOpmerkingen: map['toonOpmerkingen'] ?? false,
      toonKlantTaak: map['toonKlantTaak'] ?? false,
      klantTaakTekst: oudeTaakTekst,
      klantTaakMoment: map['klantTaakMoment'] ?? 'eerstePlaatsingsdag',
      klantTaakVrijeDatum: map['klantTaakVrijeDatum'] != null
          ? DateTime.tryParse(map['klantTaakVrijeDatum'])
          : null,
      klantTaakAfgewerkt: map['klantTaakAfgewerkt'] ?? false,
      klantTaken: geladenKlantTaken,
      klantLeveranciers: (map['klantLeveranciers'] as List<dynamic>? ?? [])
          .map((e) => KlantLeverancier.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      planningDagen: (map['planningDagen'] as List<dynamic>? ?? [])
          .map((e) => PlanningDag.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      extraWerkItems: (map['extraWerkItems'] as List<dynamic>? ?? [])
          .map((e) => ExtraWerkItem.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      kraanReservering: map['kraanReservering'] != null
          ? KraanReservering.fromMap(
              Map<String, dynamic>.from(map['kraanReservering']),
            )
          : null,
    );
  }
}
