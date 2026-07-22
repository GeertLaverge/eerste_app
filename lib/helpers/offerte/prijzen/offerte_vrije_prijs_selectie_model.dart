import 'offerte_prijs_eenheid.dart';
import 'offerte_prijs_uitschrijfmodus.dart';

/// Momentopname van een automatisch toegepaste prijsregel per artikel.
///
/// De historische klassenaam blijft behouden zodat bestaande opgeslagen
/// offertes zonder migratie geopend kunnen worden. De regel wordt niet meer
/// handmatig geselecteerd: alle actieve regels uit Instellingen worden door de
/// berekeningsservice automatisch in deze lijst geplaatst.
class OfferteVrijePrijsSelectieModel {
  OfferteVrijePrijsSelectieModel({
    required String id,
    required String bronPrijsregelId,
    required String omschrijving,
    required double bedragPerStukExclBtw,
    required this.uitschrijfmodus,
    this.eenheid = OffertePrijsEenheid.vast,
    double bronPrijsPerStukExclBtw = 0,
    String bronGewijzigdOp = '',
    String geselecteerdOp = '',
    this.actief = true,
  }) : id = id.trim(),
       bronPrijsregelId = bronPrijsregelId.trim(),
       omschrijving = omschrijving.trim(),
       bedragPerStukExclBtw = _normaliseerBedrag(bedragPerStukExclBtw),
       bronPrijsPerStukExclBtw = _normaliseerBedrag(bronPrijsPerStukExclBtw),
       bronGewijzigdOp = bronGewijzigdOp.trim(),
       geselecteerdOp = geselecteerdOp.trim();

  final String id;
  final String bronPrijsregelId;
  final String omschrijving;

  /// Prijs per gekozen berekeningseenheid. De oude veldnaam blijft behouden
  /// voor achterwaartse compatibiliteit met bestaande JSON-opslag.
  final double bedragPerStukExclBtw;
  final OffertePrijsEenheid eenheid;
  final OffertePrijsUitschrijfmodus uitschrijfmodus;
  final double bronPrijsPerStukExclBtw;
  final String bronGewijzigdOp;
  final String geselecteerdOp;
  final bool actief;

  double get prijsPerEenheidExclBtw => bedragPerStukExclBtw;

  bool get isGeldig {
    return id.isNotEmpty &&
        bronPrijsregelId.isNotEmpty &&
        omschrijving.isNotEmpty &&
        _isGeldigeUitschrijfmodus(uitschrijfmodus);
  }

  bool get heeftBedrag => bedragPerStukExclBtw > 0.0;

  bool get wordtAfzonderlijkOpOfferteGetoond {
    return uitschrijfmodus ==
            OffertePrijsUitschrijfmodus.invullenEnOfferteMetPrijs ||
        uitschrijfmodus ==
            OffertePrijsUitschrijfmodus.overzichtEnOfferteMetPrijs;
  }

  double hoeveelheidVoorMaten({
    required int aantal,
    required int breedteMm,
    required int hoogteMm,
  }) {
    final geldigAantal = aantal < 1 ? 1 : aantal;
    final breedteMeter = breedteMm < 0 ? 0.0 : breedteMm.toDouble() / 1000.0;
    final hoogteMeter = hoogteMm < 0 ? 0.0 : hoogteMm.toDouble() / 1000.0;

    final hoeveelheidPerStuk = switch (eenheid) {
      OffertePrijsEenheid.vast => 1.0,
      OffertePrijsEenheid.eenBreedte => breedteMeter,
      OffertePrijsEenheid.tweeBreedtes => breedteMeter * 2.0,
      OffertePrijsEenheid.eenHoogte => hoogteMeter,
      OffertePrijsEenheid.tweeHoogtes => hoogteMeter * 2.0,
      OffertePrijsEenheid.eenBreedteTweeHoogtes =>
        breedteMeter + (hoogteMeter * 2.0),
      OffertePrijsEenheid.omtrek => (breedteMeter * 2.0) + (hoogteMeter * 2.0),
      OffertePrijsEenheid.oppervlakte => breedteMeter * hoogteMeter,
    };

    return _rondHoeveelheidAf(hoeveelheidPerStuk * geldigAantal.toDouble());
  }

  double totaalExclBtwVoorMaten({
    required int aantal,
    required int breedteMm,
    required int hoogteMm,
  }) {
    final hoeveelheid = hoeveelheidVoorMaten(
      aantal: aantal,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
    );

    return _rondBedragAf(hoeveelheid * bedragPerStukExclBtw);
  }

  /// Oude helper blijft bestaan voor code die enkel een vaste prijs gebruikt.
  double totaalExclBtwVoorAantal(int aantal) {
    final geldigAantal = aantal < 1 ? 1 : aantal;
    return _rondBedragAf(bedragPerStukExclBtw * geldigAantal.toDouble());
  }

  OfferteVrijePrijsSelectieModel copyWith({
    String? id,
    String? bronPrijsregelId,
    String? omschrijving,
    double? bedragPerStukExclBtw,
    OffertePrijsEenheid? eenheid,
    OffertePrijsUitschrijfmodus? uitschrijfmodus,
    double? bronPrijsPerStukExclBtw,
    String? bronGewijzigdOp,
    String? geselecteerdOp,
    bool? actief,
  }) {
    return OfferteVrijePrijsSelectieModel(
      id: id ?? this.id,
      bronPrijsregelId: bronPrijsregelId ?? this.bronPrijsregelId,
      omschrijving: omschrijving ?? this.omschrijving,
      bedragPerStukExclBtw: bedragPerStukExclBtw ?? this.bedragPerStukExclBtw,
      eenheid: eenheid ?? this.eenheid,
      uitschrijfmodus: uitschrijfmodus ?? this.uitschrijfmodus,
      bronPrijsPerStukExclBtw:
          bronPrijsPerStukExclBtw ?? this.bronPrijsPerStukExclBtw,
      bronGewijzigdOp: bronGewijzigdOp ?? this.bronGewijzigdOp,
      geselecteerdOp: geselecteerdOp ?? this.geselecteerdOp,
      actief: actief ?? this.actief,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'bronPrijsregelId': bronPrijsregelId,
      'omschrijving': omschrijving,
      'bedragPerStukExclBtw': bedragPerStukExclBtw,
      'eenheid': eenheid.jsonWaarde,
      'uitschrijfmodus': uitschrijfmodus.jsonWaarde,
      'bronPrijsPerStukExclBtw': bronPrijsPerStukExclBtw,
      'bronGewijzigdOp': bronGewijzigdOp,
      'geselecteerdOp': geselecteerdOp,
      'actief': actief,
    };
  }

  factory OfferteVrijePrijsSelectieModel.fromJson(Map<String, dynamic> json) {
    return OfferteVrijePrijsSelectieModel(
      id: json['id']?.toString() ?? '',
      bronPrijsregelId: json['bronPrijsregelId']?.toString() ?? '',
      omschrijving: json['omschrijving']?.toString() ?? '',
      bedragPerStukExclBtw: _leesBedrag(
        json['bedragPerStukExclBtw'] ?? json['bedragExclBtw'],
      ),
      eenheid: OffertePrijsEenheid.fromJson(json['eenheid']),
      uitschrijfmodus: OffertePrijsUitschrijfmodus.fromJson(
        json['uitschrijfmodus'],
        standaardWaarde: OffertePrijsUitschrijfmodus.invullenEnOfferteMetPrijs,
      ),
      bronPrijsPerStukExclBtw: _leesBedrag(
        json['bronPrijsPerStukExclBtw'] ?? json['bronPrijsExclBtw'],
      ),
      bronGewijzigdOp: json['bronGewijzigdOp']?.toString() ?? '',
      geselecteerdOp: json['geselecteerdOp']?.toString() ?? '',
      actief: _leesBool(json['actief'], standaardWaarde: true),
    );
  }

  static bool _isGeldigeUitschrijfmodus(OffertePrijsUitschrijfmodus modus) {
    return modus == OffertePrijsUitschrijfmodus.invullenEnOfferteMetPrijs ||
        modus == OffertePrijsUitschrijfmodus.invullenEnOfferteZonderPrijs ||
        modus == OffertePrijsUitschrijfmodus.overzichtEnOfferteMetPrijs ||
        modus == OffertePrijsUitschrijfmodus.alleenOverzicht ||
        modus == OffertePrijsUitschrijfmodus.optie;
  }

  static bool _leesBool(Object? waarde, {required bool standaardWaarde}) {
    if (waarde is bool) return waarde;
    final tekst = waarde?.toString().trim().toLowerCase();
    if (tekst == 'true' || tekst == '1') return true;
    if (tekst == 'false' || tekst == '0') return false;
    return standaardWaarde;
  }

  static double _normaliseerBedrag(double waarde) {
    if (!waarde.isFinite || waarde < 0.0) {
      return 0.0;
    }

    return _rondBedragAf(waarde);
  }

  static double _leesBedrag(Object? waarde) {
    if (waarde is num) {
      return _normaliseerBedrag(waarde.toDouble());
    }

    return _normaliseerBedrag(
      double.tryParse(waarde?.toString().trim().replaceAll(',', '.') ?? '') ??
          0.0,
    );
  }

  static double _rondHoeveelheidAf(double waarde) {
    if (!waarde.isFinite || waarde < 0.0) {
      return 0.0;
    }

    return (waarde * 10000.0).roundToDouble() / 10000.0;
  }

  static double _rondBedragAf(double waarde) {
    return (waarde * 100.0).roundToDouble() / 100.0;
  }
}
