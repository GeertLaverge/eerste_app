import 'dart:convert';

import 'offerte_prijs_categorie.dart';
import 'offerte_prijs_eenheid.dart';
import 'offerte_prijs_uitschrijfmodus.dart';
import 'offerte_prijs_verdeel_limietmodus.dart';
import 'offerte_prijsprofiel_model.dart';
import 'offerte_prijsregel_model.dart';
import 'offerte_technische_keuze_ref.dart';

enum OffertePrijsinstellingenWijzigingType { toegevoegd, verwijderd, gewijzigd }

class OffertePrijsinstellingenWijziging {
  const OffertePrijsinstellingenWijziging({
    required this.type,
    required this.titel,
    this.details = const <String>[],
  });

  final OffertePrijsinstellingenWijzigingType type;
  final String titel;
  final List<String> details;
}

class OffertePrijsregelMomentopname {
  const OffertePrijsregelMomentopname({
    required this.id,
    required this.categorie,
    required this.formulierType,
    required this.omschrijving,
    required this.prijsExclBtw,
    required this.eenheid,
    required this.uitschrijfmodus,
    this.technischeKeuze,
    required this.verdeelLimietmodus,
    required this.verdeelLimietBedragExclBtw,
    required this.actief,
    required this.volgorde,
  });

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

  factory OffertePrijsregelMomentopname.vanPrijsregel(
    OffertePrijsregelModel prijsregel,
  ) {
    return OffertePrijsregelMomentopname(
      id: prijsregel.id,
      categorie: prijsregel.categorie,
      formulierType: prijsregel.formulierType,
      omschrijving: prijsregel.omschrijving,
      prijsExclBtw: prijsregel.prijsExclBtw,
      eenheid: prijsregel.eenheid,
      uitschrijfmodus: prijsregel.uitschrijfmodus,
      technischeKeuze: prijsregel.technischeKeuze,
      verdeelLimietmodus: prijsregel.verdeelLimietmodus,
      verdeelLimietBedragExclBtw: prijsregel.verdeelLimietBedragExclBtw,
      actief: prijsregel.actief,
      volgorde: prijsregel.volgorde,
    );
  }

  OffertePrijsregelModel naarPrijsregel() {
    return OffertePrijsregelModel(
      id: id,
      categorie: categorie,
      formulierType: formulierType,
      omschrijving: omschrijving,
      prijsExclBtw: prijsExclBtw,
      eenheid: eenheid,
      uitschrijfmodus: uitschrijfmodus,
      technischeKeuze: technischeKeuze,
      verdeelLimietmodus: verdeelLimietmodus,
      verdeelLimietBedragExclBtw: verdeelLimietBedragExclBtw,
      actief: actief,
      volgorde: volgorde,
    );
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
    };
  }

  factory OffertePrijsregelMomentopname.fromJson(Map<String, dynamic> json) {
    return OffertePrijsregelMomentopname(
      id: json['id']?.toString() ?? '',
      categorie: OffertePrijsCategorie.fromJson(json['categorie']),
      formulierType: json['formulierType']?.toString() ?? '',
      omschrijving: json['omschrijving']?.toString() ?? '',
      prijsExclBtw: _leesDouble(json['prijsExclBtw']),
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
      verdeelLimietBedragExclBtw: _leesDouble(
        json['verdeelLimietBedragExclBtw'],
      ),
      actief: _leesBool(json['actief'], standaardWaarde: true),
      volgorde: _leesInt(json['volgorde']),
    );
  }

  List<String> verschillenMet(OffertePrijsregelMomentopname nieuw) {
    final verschillen = <String>[];

    if (omschrijving != nieuw.omschrijving) {
      verschillen.add(
        'Omschrijving: “$omschrijving” → “${nieuw.omschrijving}”',
      );
    }
    if (_rondBedrag(prijsExclBtw) != _rondBedrag(nieuw.prijsExclBtw)) {
      verschillen.add(
        'Prijs: ${_euro(prijsExclBtw)} → ${_euro(nieuw.prijsExclBtw)}',
      );
    }
    if (eenheid != nieuw.eenheid) {
      verschillen.add(
        'Berekening: ${eenheid.benaming} → ${nieuw.eenheid.benaming}',
      );
    }
    if (uitschrijfmodus != nieuw.uitschrijfmodus) {
      verschillen.add(
        'Uitschrijfwijze: ${uitschrijfmodus.benaming} → ${nieuw.uitschrijfmodus.benaming}',
      );
    }
    if (actief != nieuw.actief) {
      verschillen.add(
        nieuw.actief ? 'Prijsregel geactiveerd' : 'Prijsregel uitgeschakeld',
      );
    }
    if (verdeelLimietmodus != nieuw.verdeelLimietmodus) {
      verschillen.add(
        'Limiet: ${verdeelLimietmodus.benaming} → ${nieuw.verdeelLimietmodus.benaming}',
      );
    }
    if (_rondBedrag(verdeelLimietBedragExclBtw) !=
        _rondBedrag(nieuw.verdeelLimietBedragExclBtw)) {
      verschillen.add(
        'Aankooplimiet: ${_euro(verdeelLimietBedragExclBtw)} → ${_euro(nieuw.verdeelLimietBedragExclBtw)}',
      );
    }
    if (_technischeKeuzeSleutel(technischeKeuze) !=
        _technischeKeuzeSleutel(nieuw.technischeKeuze)) {
      verschillen.add('Gekoppelde technische keuze gewijzigd');
    }
    if (categorie != nieuw.categorie) {
      verschillen.add('Prijscategorie gewijzigd');
    }
    if (volgorde != nieuw.volgorde) {
      verschillen.add('Volgorde gewijzigd');
    }

    return verschillen;
  }

  String get korteSamenvatting {
    final delen = <String>[
      _euro(prijsExclBtw),
      eenheid.benaming,
      actief ? 'actief' : 'inactief',
    ];

    if (verdeelLimietmodus == OffertePrijsVerdeelLimietmodus.metAankooplimiet &&
        verdeelLimietBedragExclBtw > 0) {
      delen.add('limiet ${_euro(verdeelLimietBedragExclBtw)}');
    }

    return delen.join(' · ');
  }

  static String _technischeKeuzeSleutel(OfferteTechnischeKeuzeRef? keuze) {
    if (keuze == null) {
      return '';
    }

    return <String>[
      keuze.formulierType,
      keuze.menuId,
      keuze.submenuId,
      keuze.keuzeId,
    ].join('|');
  }
}

class OffertePrijsinstellingenMomentopname {
  const OffertePrijsinstellingenMomentopname({
    required this.formulierType,
    required this.formulierNaam,
    this.prijsregels = const <OffertePrijsregelMomentopname>[],
  });

  final String formulierType;
  final String formulierNaam;
  final List<OffertePrijsregelMomentopname> prijsregels;

  factory OffertePrijsinstellingenMomentopname.vanProfiel(
    OffertePrijsprofielModel profiel,
  ) {
    final isVasteInzethor =
        _normaliseer(profiel.formulierType) == 'vasteinzethor';
    final relevantePrijsregels = profiel.prijsregels.where((prijsregel) {
      return !isVasteInzethor ||
          prijsregel.categorie !=
              OffertePrijsCategorie.technischeKeuzePerArtikel;
    });

    return OffertePrijsinstellingenMomentopname(
      formulierType: profiel.formulierType,
      formulierNaam: profiel.formulierNaam,
      prijsregels: relevantePrijsregels
          .map(OffertePrijsregelMomentopname.vanPrijsregel)
          .toList(growable: false),
    );
  }

  OffertePrijsprofielModel naarProfiel() {
    return OffertePrijsprofielModel(
      formulierType: formulierType,
      formulierNaam: formulierNaam,
      prijsregels: prijsregels
          .map((prijsregel) => prijsregel.naarPrijsregel())
          .toList(growable: false),
    );
  }

  String get signatuur {
    return jsonEncode(<String, dynamic>{
      'formulierType': _normaliseer(formulierType),
      'prijsregels': prijsregels.map((regel) => regel.toJson()).toList(),
    });
  }

  bool heeftZelfdeInhoudAls(OffertePrijsinstellingenMomentopname ander) {
    return signatuur == ander.signatuur;
  }

  List<OffertePrijsinstellingenWijziging> wijzigingenNaar(
    OffertePrijsinstellingenMomentopname nieuw,
  ) {
    final wijzigingen = <OffertePrijsinstellingenWijziging>[];
    final oudePerId = <String, OffertePrijsregelMomentopname>{
      for (final regel in prijsregels) regel.id: regel,
    };
    final nieuwePerId = <String, OffertePrijsregelMomentopname>{
      for (final regel in nieuw.prijsregels) regel.id: regel,
    };

    for (final nieuweRegel in nieuw.prijsregels) {
      final oudeRegel = oudePerId[nieuweRegel.id];
      if (oudeRegel == null) {
        wijzigingen.add(
          OffertePrijsinstellingenWijziging(
            type: OffertePrijsinstellingenWijzigingType.toegevoegd,
            titel: nieuweRegel.omschrijving,
            details: <String>['Toegevoegd · ${nieuweRegel.korteSamenvatting}'],
          ),
        );
        continue;
      }

      final verschillen = oudeRegel.verschillenMet(nieuweRegel);
      if (verschillen.isNotEmpty) {
        wijzigingen.add(
          OffertePrijsinstellingenWijziging(
            type: OffertePrijsinstellingenWijzigingType.gewijzigd,
            titel: nieuweRegel.omschrijving,
            details: verschillen,
          ),
        );
      }
    }

    for (final oudeRegel in prijsregels) {
      if (!nieuwePerId.containsKey(oudeRegel.id)) {
        wijzigingen.add(
          OffertePrijsinstellingenWijziging(
            type: OffertePrijsinstellingenWijzigingType.verwijderd,
            titel: oudeRegel.omschrijving,
            details: <String>['Verwijderd · ${oudeRegel.korteSamenvatting}'],
          ),
        );
      }
    }

    return wijzigingen;
  }

  List<OffertePrijsinstellingenWijziging> eersteKoppelingWijzigingen() {
    if (prijsregels.isEmpty) {
      return const <OffertePrijsinstellingenWijziging>[];
    }

    return prijsregels
        .map((regel) {
          return OffertePrijsinstellingenWijziging(
            type: OffertePrijsinstellingenWijzigingType.toegevoegd,
            titel: regel.omschrijving,
            details: <String>[
              'Huidige instelling · ${regel.korteSamenvatting}',
            ],
          );
        })
        .toList(growable: false);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'formulierType': formulierType,
      'formulierNaam': formulierNaam,
      'prijsregels': prijsregels.map((regel) => regel.toJson()).toList(),
    };
  }

  factory OffertePrijsinstellingenMomentopname.fromJson(
    Map<String, dynamic> json,
  ) {
    final regels = <OffertePrijsregelMomentopname>[];
    final ruweRegels = json['prijsregels'];

    if (ruweRegels is List) {
      for (final waarde in ruweRegels.whereType<Map>()) {
        try {
          final regel = OffertePrijsregelMomentopname.fromJson(
            Map<String, dynamic>.from(waarde),
          );
          if (regel.id.trim().isNotEmpty) {
            regels.add(regel);
          }
        } catch (_) {
          // Eén beschadigde regel mag de projectfiche niet blokkeren.
        }
      }
    }

    return OffertePrijsinstellingenMomentopname(
      formulierType: json['formulierType']?.toString() ?? '',
      formulierNaam: json['formulierNaam']?.toString() ?? '',
      prijsregels: regels,
    );
  }
}

String _normaliseer(String waarde) {
  return waarde.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
}

double _leesDouble(Object? waarde) {
  if (waarde is num) {
    return waarde.toDouble();
  }

  return double.tryParse(
        waarde?.toString().trim().replaceAll(',', '.') ?? '',
      ) ??
      0.0;
}

int _leesInt(Object? waarde) {
  if (waarde is num) {
    return waarde.toInt();
  }

  return int.tryParse(waarde?.toString().trim() ?? '') ?? 0;
}

bool _leesBool(Object? waarde, {required bool standaardWaarde}) {
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

double _rondBedrag(double waarde) {
  return (waarde * 100.0).roundToDouble() / 100.0;
}

String _euro(double waarde) {
  return '€ ${_rondBedrag(waarde).toStringAsFixed(2).replaceAll('.', ',')}';
}
