// THIMACO-CONTROLE: FINANCIELE-COCKPIT-MODEL-FASE2A-20260807
import 'dart:math';

enum FinancieleBetalingStatus { open, gepland, betaald }

enum FinancieleOntvangstStatus { verwacht, deelsOntvangen, ontvangen }

enum FinancieleAndereOntvangstStatus { open, ontvangen }

enum FinancieleZekerheid { zeker, verwacht, onzeker }

enum FinancieleFrequentie {
  wekelijks,
  maandelijks,
  kwartaal,
  halfjaarlijks,
  jaarlijks,
}

extension FinancieleBetalingStatusLabel on FinancieleBetalingStatus {
  String get label => switch (this) {
    FinancieleBetalingStatus.open => 'Open',
    FinancieleBetalingStatus.gepland => 'Gepland',
    FinancieleBetalingStatus.betaald => 'Betaald',
  };
}

extension FinancieleOntvangstStatusLabel on FinancieleOntvangstStatus {
  String get label => switch (this) {
    FinancieleOntvangstStatus.verwacht => 'Verwacht',
    FinancieleOntvangstStatus.deelsOntvangen => 'Deels ontvangen',
    FinancieleOntvangstStatus.ontvangen => 'Ontvangen',
  };
}

extension FinancieleAndereOntvangstStatusLabel
    on FinancieleAndereOntvangstStatus {
  String get label => switch (this) {
    FinancieleAndereOntvangstStatus.open => 'Open',
    FinancieleAndereOntvangstStatus.ontvangen => 'Ontvangen',
  };
}

extension FinancieleZekerheidLabel on FinancieleZekerheid {
  String get label => switch (this) {
    FinancieleZekerheid.zeker => 'Zeker',
    FinancieleZekerheid.verwacht => 'Verwacht',
    FinancieleZekerheid.onzeker => 'Onzeker',
  };
}

extension FinancieleFrequentieLabel on FinancieleFrequentie {
  String get label => switch (this) {
    FinancieleFrequentie.wekelijks => 'Wekelijks',
    FinancieleFrequentie.maandelijks => 'Maandelijks',
    FinancieleFrequentie.kwartaal => 'Per kwartaal',
    FinancieleFrequentie.halfjaarlijks => 'Halfjaarlijks',
    FinancieleFrequentie.jaarlijks => 'Jaarlijks',
  };

  double get maandFactor => switch (this) {
    FinancieleFrequentie.wekelijks => 52 / 12,
    FinancieleFrequentie.maandelijks => 1,
    FinancieleFrequentie.kwartaal => 1 / 3,
    FinancieleFrequentie.halfjaarlijks => 1 / 6,
    FinancieleFrequentie.jaarlijks => 1 / 12,
  };
}

class FinancieleId {
  const FinancieleId._();

  static final Random _random = Random.secure();

  static String maak(String prefix) {
    final tijd = DateTime.now().microsecondsSinceEpoch;
    final willekeurig = List<int>.generate(
      8,
      (_) => _random.nextInt(256),
    ).map((waarde) => waarde.toRadixString(16).padLeft(2, '0')).join();
    return '$prefix-$tijd-$willekeurig';
  }
}

class FinancieleRekening {
  const FinancieleRekening({
    required this.id,
    required this.naam,
    required this.rekeningNummer,
    required this.saldo,
    required this.saldoDatum,
    required this.beschikbaarKrediet,
    required this.opmerking,
    required this.actief,
  });

  final String id;
  final String naam;
  final String rekeningNummer;
  final double saldo;
  final DateTime saldoDatum;
  final double beschikbaarKrediet;
  final String opmerking;
  final bool actief;

  factory FinancieleRekening.fromJson(Map<String, dynamic> json) {
    return FinancieleRekening(
      id: _tekst(json['id']).isEmpty
          ? FinancieleId.maak('rekening')
          : _tekst(json['id']),
      naam: _tekst(json['naam']),
      rekeningNummer: _tekst(json['rekeningNummer']),
      saldo: _bedrag(json['saldo']),
      saldoDatum: _datum(json['saldoDatum']) ?? DateTime.now(),
      beschikbaarKrediet: _bedrag(json['beschikbaarKrediet']),
      opmerking: _tekst(json['opmerking']),
      actief: _bool(json['actief'], standaard: true),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'naam': naam,
    'rekeningNummer': rekeningNummer,
    'saldo': saldo,
    'saldoDatum': saldoDatum.toIso8601String(),
    'beschikbaarKrediet': beschikbaarKrediet,
    'opmerking': opmerking,
    'actief': actief,
  };
}

class FinancieleTeBetalen {
  const FinancieleTeBetalen({
    required this.id,
    required this.leverancier,
    required this.omschrijving,
    required this.bedrag,
    required this.factuurNummer,
    required this.factuurDatum,
    required this.vervalDatum,
    required this.geplandOp,
    required this.status,
    required this.belangrijk,
    required this.opmerking,
  });

  final String id;
  final String leverancier;
  final String omschrijving;
  final double bedrag;
  final String factuurNummer;
  final DateTime? factuurDatum;
  final DateTime vervalDatum;
  final DateTime? geplandOp;
  final FinancieleBetalingStatus status;
  final bool belangrijk;
  final String opmerking;

  DateTime get planningDatum => geplandOp ?? vervalDatum;
  bool get teltMee => status != FinancieleBetalingStatus.betaald;

  factory FinancieleTeBetalen.fromJson(Map<String, dynamic> json) {
    return FinancieleTeBetalen(
      id: _tekst(json['id']).isEmpty
          ? FinancieleId.maak('betalen')
          : _tekst(json['id']),
      leverancier: _tekst(json['leverancier']),
      omschrijving: _tekst(json['omschrijving']),
      bedrag: _bedrag(json['bedrag']),
      factuurNummer: _tekst(json['factuurNummer']),
      factuurDatum: _datum(json['factuurDatum']),
      vervalDatum: _datum(json['vervalDatum']) ?? DateTime.now(),
      geplandOp: _datum(json['geplandOp']),
      status: _enumVanNaam(
        FinancieleBetalingStatus.values,
        _tekst(json['status']),
        FinancieleBetalingStatus.open,
      ),
      belangrijk: _bool(json['belangrijk']),
      opmerking: _tekst(json['opmerking']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'leverancier': leverancier,
    'omschrijving': omschrijving,
    'bedrag': bedrag,
    'factuurNummer': factuurNummer,
    'factuurDatum': factuurDatum?.toIso8601String(),
    'vervalDatum': vervalDatum.toIso8601String(),
    'geplandOp': geplandOp?.toIso8601String(),
    'status': status.name,
    'belangrijk': belangrijk,
    'opmerking': opmerking,
  };
}

class FinancieleTeOntvangen {
  const FinancieleTeOntvangen({
    required this.id,
    required this.klant,
    required this.omschrijving,
    required this.bedrag,
    required this.factuurNummer,
    required this.factuurDatum,
    required this.vervalDatum,
    required this.verwachtOp,
    required this.status,
    required this.reedsOntvangen,
    required this.opmerking,
  });

  final String id;
  final String klant;
  final String omschrijving;
  final double bedrag;
  final String factuurNummer;
  final DateTime? factuurDatum;
  final DateTime vervalDatum;
  final DateTime? verwachtOp;
  final FinancieleOntvangstStatus status;
  final double reedsOntvangen;
  final String opmerking;

  DateTime get planningDatum => verwachtOp ?? vervalDatum;
  double get openstaand {
    if (status == FinancieleOntvangstStatus.ontvangen) return 0;
    return max(0.0, bedrag - reedsOntvangen).toDouble();
  }

  factory FinancieleTeOntvangen.fromJson(Map<String, dynamic> json) {
    return FinancieleTeOntvangen(
      id: _tekst(json['id']).isEmpty
          ? FinancieleId.maak('ontvangen')
          : _tekst(json['id']),
      klant: _tekst(json['klant']),
      omschrijving: _tekst(json['omschrijving']),
      bedrag: _bedrag(json['bedrag']),
      factuurNummer: _tekst(json['factuurNummer']),
      factuurDatum: _datum(json['factuurDatum']),
      vervalDatum: _datum(json['vervalDatum']) ?? DateTime.now(),
      verwachtOp: _datum(json['verwachtOp']),
      status: _enumVanNaam(
        FinancieleOntvangstStatus.values,
        _tekst(json['status']),
        FinancieleOntvangstStatus.verwacht,
      ),
      reedsOntvangen: _bedrag(json['reedsOntvangen']),
      opmerking: _tekst(json['opmerking']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'klant': klant,
    'omschrijving': omschrijving,
    'bedrag': bedrag,
    'factuurNummer': factuurNummer,
    'factuurDatum': factuurDatum?.toIso8601String(),
    'vervalDatum': vervalDatum.toIso8601String(),
    'verwachtOp': verwachtOp?.toIso8601String(),
    'status': status.name,
    'reedsOntvangen': reedsOntvangen,
    'opmerking': opmerking,
  };
}

class FinancieleAndereOntvangst {
  const FinancieleAndereOntvangst({
    required this.id,
    required this.soort,
    required this.van,
    required this.omschrijving,
    required this.bedrag,
    required this.verwachtOp,
    required this.zekerheid,
    required this.status,
    required this.opmerking,
  });

  final String id;
  final String soort;
  final String van;
  final String omschrijving;
  final double bedrag;
  final DateTime verwachtOp;
  final FinancieleZekerheid zekerheid;
  final FinancieleAndereOntvangstStatus status;
  final String opmerking;

  bool get teltMee => status != FinancieleAndereOntvangstStatus.ontvangen;

  factory FinancieleAndereOntvangst.fromJson(Map<String, dynamic> json) {
    return FinancieleAndereOntvangst(
      id: _tekst(json['id']).isEmpty
          ? FinancieleId.maak('andere-ontvangst')
          : _tekst(json['id']),
      soort: _tekst(json['soort']),
      van: _tekst(json['van']),
      omschrijving: _tekst(json['omschrijving']),
      bedrag: _bedrag(json['bedrag']),
      verwachtOp: _datum(json['verwachtOp']) ?? DateTime.now(),
      zekerheid: _enumVanNaam(
        FinancieleZekerheid.values,
        _tekst(json['zekerheid']),
        FinancieleZekerheid.verwacht,
      ),
      status: _enumVanNaam(
        FinancieleAndereOntvangstStatus.values,
        _tekst(json['status']),
        FinancieleAndereOntvangstStatus.open,
      ),
      opmerking: _tekst(json['opmerking']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'soort': soort,
    'van': van,
    'omschrijving': omschrijving,
    'bedrag': bedrag,
    'verwachtOp': verwachtOp.toIso8601String(),
    'zekerheid': zekerheid.name,
    'status': status.name,
    'opmerking': opmerking,
  };
}

class FinancieleVasteKost {
  const FinancieleVasteKost({
    required this.id,
    required this.categorie,
    required this.omschrijving,
    required this.leverancier,
    required this.bedrag,
    required this.frequentie,
    required this.betaalDag,
    required this.vanaf,
    required this.tot,
    required this.actief,
    required this.opmerking,
  });

  final String id;
  final String categorie;
  final String omschrijving;
  final String leverancier;
  final double bedrag;
  final FinancieleFrequentie frequentie;
  final int? betaalDag;
  final DateTime? vanaf;
  final DateTime? tot;
  final bool actief;
  final String opmerking;

  bool get actiefVandaag => isActiefOp(DateTime.now());

  bool isActiefOp(DateTime datum) {
    if (!actief) return false;
    final dag = DateTime(datum.year, datum.month, datum.day);
    final start = vanaf == null
        ? null
        : DateTime(vanaf!.year, vanaf!.month, vanaf!.day);
    final einde = tot == null
        ? null
        : DateTime(tot!.year, tot!.month, tot!.day);
    if (start != null && dag.isBefore(start)) return false;
    if (einde != null && dag.isAfter(einde)) return false;
    return true;
  }

  double get maandGemiddelde =>
      actiefVandaag ? bedrag * frequentie.maandFactor : 0;
  double get jaarGemiddelde => maandGemiddelde * 12;

  factory FinancieleVasteKost.fromJson(Map<String, dynamic> json) {
    final dag = _int(json['betaalDag']);
    return FinancieleVasteKost(
      id: _tekst(json['id']).isEmpty
          ? FinancieleId.maak('vaste-kost')
          : _tekst(json['id']),
      categorie: _tekst(json['categorie']),
      omschrijving: _tekst(json['omschrijving']),
      leverancier: _tekst(json['leverancier']),
      bedrag: _bedrag(json['bedrag']),
      frequentie: _enumVanNaam(
        FinancieleFrequentie.values,
        _tekst(json['frequentie']),
        FinancieleFrequentie.maandelijks,
      ),
      betaalDag: dag != null && dag >= 1 && dag <= 31 ? dag : null,
      vanaf: _datum(json['vanaf']),
      tot: _datum(json['tot']),
      actief: _bool(json['actief'], standaard: true),
      opmerking: _tekst(json['opmerking']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'categorie': categorie,
    'omschrijving': omschrijving,
    'leverancier': leverancier,
    'bedrag': bedrag,
    'frequentie': frequentie.name,
    'betaalDag': betaalDag,
    'vanaf': vanaf?.toIso8601String(),
    'tot': tot?.toIso8601String(),
    'actief': actief,
    'opmerking': opmerking,
  };
}

class FinancieleCockpitData {
  const FinancieleCockpitData({
    required this.rekeningen,
    required this.teBetalen,
    required this.teOntvangen,
    required this.andereOntvangsten,
    required this.vasteKosten,
  });

  final List<FinancieleRekening> rekeningen;
  final List<FinancieleTeBetalen> teBetalen;
  final List<FinancieleTeOntvangen> teOntvangen;
  final List<FinancieleAndereOntvangst> andereOntvangsten;
  final List<FinancieleVasteKost> vasteKosten;

  factory FinancieleCockpitData.fromKluis(Map<String, dynamic> kluis) {
    return FinancieleCockpitData(
      rekeningen: _leesObjecten(
        kluis['rekeningen'],
        FinancieleRekening.fromJson,
      ),
      teBetalen: _leesObjecten(
        kluis['teBetalenFacturen'],
        FinancieleTeBetalen.fromJson,
      ),
      teOntvangen: _leesObjecten(
        kluis['teOntvangenFacturen'],
        FinancieleTeOntvangen.fromJson,
      ),
      andereOntvangsten: _leesObjecten(
        kluis['andereOntvangsten'],
        FinancieleAndereOntvangst.fromJson,
      ),
      vasteKosten: _leesObjecten(
        kluis['vasteKosten'],
        FinancieleVasteKost.fromJson,
      ),
    );
  }

  double get totaalRekeningen => rekeningen
      .where((rekening) => rekening.actief)
      .fold(0.0, (totaal, rekening) => totaal + rekening.saldo);

  double get totaalTeBetalen => teBetalen
      .where((item) => item.teltMee)
      .fold(0.0, (totaal, item) => totaal + item.bedrag);

  double get totaalKlantOntvangsten =>
      teOntvangen.fold(0.0, (totaal, item) => totaal + item.openstaand);

  double get totaalAndereOntvangsten => andereOntvangsten
      .where((item) => item.teltMee)
      .fold(0.0, (totaal, item) => totaal + item.bedrag);

  double get totaalTeOntvangen =>
      totaalKlantOntvangsten + totaalAndereOntvangsten;

  double get verwachtePositie =>
      totaalRekeningen + totaalTeOntvangen - totaalTeBetalen;

  double get vasteMaandkost =>
      vasteKosten.fold(0.0, (totaal, item) => totaal + item.maandGemiddelde);

  double get vasteJaarkost => vasteMaandkost * 12;

  Map<String, dynamic> schrijfNaarKluis(Map<String, dynamic> basis) {
    return Map<String, dynamic>.from(basis)
      ..['rekeningen'] = rekeningen
          .map((item) => item.toJson())
          .toList(growable: false)
      ..['teBetalenFacturen'] = teBetalen
          .map((item) => item.toJson())
          .toList(growable: false)
      ..['teOntvangenFacturen'] = teOntvangen
          .map((item) => item.toJson())
          .toList(growable: false)
      ..['andereOntvangsten'] = andereOntvangsten
          .map((item) => item.toJson())
          .toList(growable: false)
      ..['vasteKosten'] = vasteKosten
          .map((item) => item.toJson())
          .toList(growable: false);
  }

  FinancieleCockpitData copyWith({
    List<FinancieleRekening>? rekeningen,
    List<FinancieleTeBetalen>? teBetalen,
    List<FinancieleTeOntvangen>? teOntvangen,
    List<FinancieleAndereOntvangst>? andereOntvangsten,
    List<FinancieleVasteKost>? vasteKosten,
  }) {
    return FinancieleCockpitData(
      rekeningen: rekeningen ?? this.rekeningen,
      teBetalen: teBetalen ?? this.teBetalen,
      teOntvangen: teOntvangen ?? this.teOntvangen,
      andereOntvangsten: andereOntvangsten ?? this.andereOntvangsten,
      vasteKosten: vasteKosten ?? this.vasteKosten,
    );
  }
}

List<T> _leesObjecten<T>(
  Object? waarde,
  T Function(Map<String, dynamic>) maker,
) {
  if (waarde is! List) return <T>[];

  final resultaat = <T>[];
  for (final item in waarde) {
    if (item is Map) {
      try {
        resultaat.add(maker(Map<String, dynamic>.from(item)));
      } catch (_) {
        // Eén beschadigd oud record mag de rest van de financiële kluis niet blokkeren.
      }
    }
  }
  return resultaat;
}

T _enumVanNaam<T extends Enum>(List<T> waarden, String naam, T standaard) {
  for (final waarde in waarden) {
    if (waarde.name == naam) return waarde;
  }
  return standaard;
}

String _tekst(Object? waarde) => waarde?.toString().trim() ?? '';

double _bedrag(Object? waarde) {
  if (waarde is num) return waarde.toDouble();
  return double.tryParse(waarde?.toString() ?? '') ?? 0;
}

int? _int(Object? waarde) {
  if (waarde is int) return waarde;
  if (waarde is num) return waarde.toInt();
  return int.tryParse(waarde?.toString() ?? '');
}

bool _bool(Object? waarde, {bool standaard = false}) {
  if (waarde is bool) return waarde;
  if (waarde == 1 || waarde?.toString().toLowerCase() == 'true') return true;
  if (waarde == 0 || waarde?.toString().toLowerCase() == 'false') return false;
  return standaard;
}

DateTime? _datum(Object? waarde) {
  if (waarde == null) return null;
  return DateTime.tryParse(waarde.toString());
}
