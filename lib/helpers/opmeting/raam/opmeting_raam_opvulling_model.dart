import 'package:flutter/material.dart';

class OpmetingRaamOpvullingGroepModel {
  const OpmetingRaamOpvullingGroepModel({
    required this.id,
    required this.naam,
    this.sorteerIndex = 0,
  });

  final String id;
  final String naam;
  final int sorteerIndex;

  String get label {
    final tekst = naam.trim();
    return tekst.isEmpty ? 'Zonder submenu' : tekst;
  }

  OpmetingRaamOpvullingGroepModel copyWith({
    String? id,
    String? naam,
    int? sorteerIndex,
  }) {
    return OpmetingRaamOpvullingGroepModel(
      id: id ?? this.id,
      naam: naam ?? this.naam,
      sorteerIndex: sorteerIndex ?? this.sorteerIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'naam': naam,
      'sorteerIndex': sorteerIndex,
    };
  }

  factory OpmetingRaamOpvullingGroepModel.fromJson(Map<String, dynamic> json) {
    final naam = json['naam']?.toString().trim() ?? '';
    final id = json['id']?.toString().trim() ?? maakId(naam);

    return OpmetingRaamOpvullingGroepModel(
      id: id.isEmpty ? maakId(naam) : id,
      naam: naam.isEmpty ? 'Zonder submenu' : naam,
      sorteerIndex: _leesInt(json['sorteerIndex'], 0),
    );
  }

  static List<OpmetingRaamOpvullingGroepModel> get standaardGroepen {
    return const [
      OpmetingRaamOpvullingGroepModel(
        id: 'niet_gelaagd',
        naam: 'Niet gelaagd',
        sorteerIndex: 0,
      ),
      OpmetingRaamOpvullingGroepModel(
        id: 'een_zijde_gelaagd',
        naam: '1 zijde gelaagd',
        sorteerIndex: 1,
      ),
      OpmetingRaamOpvullingGroepModel(
        id: 'twee_zijden_gelaagd',
        naam: '2 zijden gelaagd',
        sorteerIndex: 2,
      ),
    ];
  }

  static OpmetingRaamOpvullingGroepModel standaardGroepVoorWaarde(
    Object? waarde,
  ) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';

    switch (tekst) {
      case 'nietgelaagd':
      case 'niet_gelaagd':
      case 'niet gelaagd':
      case 'ongelaagd':
      case 'geen':
      case '':
        return standaardGroepen[0];

      case 'eenzijdegelaagd':
      case 'een_zijde_gelaagd':
      case '1zijdegelaagd':
      case '1_zijde_gelaagd':
      case '1 zijde gelaagd':
      case 'één zijde gelaagd':
      case 'een zijde gelaagd':
        return standaardGroepen[1];

      case 'tweezijdengelaagd':
      case 'twee_zijden_gelaagd':
      case '2zijdengelaagd':
      case '2_zijden_gelaagd':
      case '2 zijden gelaagd':
      case 'twee zijden gelaagd':
        return standaardGroepen[2];
    }

    for (final groep in standaardGroepen) {
      if (groep.id.toLowerCase() == tekst ||
          groep.naam.toLowerCase() == tekst) {
        return groep;
      }
    }

    final label = waarde?.toString().trim() ?? '';
    return OpmetingRaamOpvullingGroepModel(
      id: maakId(label),
      naam: label.isEmpty ? 'Zonder submenu' : label,
      sorteerIndex: 99,
    );
  }

  static String maakId(String naam) {
    final basis = naam
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    return basis.isEmpty ? 'submenu' : basis;
  }

  static List<OpmetingRaamOpvullingGroepModel> groepenUitOpvullingen(
    Iterable<OpmetingRaamOpvullingModel> opvullingen,
  ) {
    final map = <String, OpmetingRaamOpvullingGroepModel>{};

    for (final opvulling in opvullingen) {
      if (opvulling.isGroepDefinitie) {
        map[opvulling.groepId] = OpmetingRaamOpvullingGroepModel(
          id: opvulling.groepId,
          naam: opvulling.groepNaam,
          sorteerIndex: opvulling.groepSorteerIndex,
        );
        continue;
      }

      map.putIfAbsent(
        opvulling.groepId,
        () => OpmetingRaamOpvullingGroepModel(
          id: opvulling.groepId,
          naam: opvulling.groepNaam,
          sorteerIndex: opvulling.groepSorteerIndex,
        ),
      );
    }

    final lijst = map.values.toList()
      ..sort((eerste, tweede) {
        final indexVergelijking = eerste.sorteerIndex.compareTo(
          tweede.sorteerIndex,
        );
        if (indexVergelijking != 0) {
          return indexVergelijking;
        }
        return eerste.naam.toLowerCase().compareTo(tweede.naam.toLowerCase());
      });

    return lijst;
  }

  static int _leesInt(Object? waarde, int standaard) {
    if (waarde is num) {
      return waarde.toInt();
    }

    if (waarde is String) {
      return int.tryParse(waarde.trim()) ?? standaard;
    }

    return standaard;
  }
}

class OpmetingRaamOpvullingModel {
  const OpmetingRaamOpvullingModel({
    required this.id,
    required this.naam,
    required this.kleurWaarde,
    this.transparantie = 0.25,
    this.groepId = 'niet_gelaagd',
    this.groepNaam = 'Niet gelaagd',
    this.groepSorteerIndex = 0,
    this.actief = true,
    this.isGroepDefinitie = false,
  });

  final String id;
  final String naam;
  final int kleurWaarde;
  final double transparantie;
  final String groepId;
  final String groepNaam;
  final int groepSorteerIndex;
  final bool actief;
  final bool isGroepDefinitie;

  Color get kleur => Color(kleurWaarde);

  Color get weergaveKleur {
    return kleur.withOpacity(transparantie.clamp(0.05, 1.0).toDouble());
  }

  int get transparantiePercentage {
    return (transparantie.clamp(0.05, 1.0) * 100).round();
  }

  String get groepLabel {
    final tekst = groepNaam.trim();
    return tekst.isEmpty ? 'Zonder submenu' : tekst;
  }

  String get volledigeNaam {
    final typeNaam = naam.trim();
    if (typeNaam.isEmpty) {
      return groepLabel;
    }

    return '$groepLabel - $typeNaam';
  }

  OpmetingRaamOpvullingModel copyWith({
    String? id,
    String? naam,
    int? kleurWaarde,
    double? transparantie,
    String? groepId,
    String? groepNaam,
    int? groepSorteerIndex,
    bool? actief,
    bool? isGroepDefinitie,
  }) {
    return OpmetingRaamOpvullingModel(
      id: id ?? this.id,
      naam: naam ?? this.naam,
      kleurWaarde: kleurWaarde ?? this.kleurWaarde,
      transparantie: transparantie ?? this.transparantie,
      groepId: groepId ?? this.groepId,
      groepNaam: groepNaam ?? this.groepNaam,
      groepSorteerIndex: groepSorteerIndex ?? this.groepSorteerIndex,
      actief: actief ?? this.actief,
      isGroepDefinitie: isGroepDefinitie ?? this.isGroepDefinitie,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'naam': naam,
      'kleurWaarde': kleurWaarde,
      'transparantie': transparantie,
      'groep': groepId,
      'groepId': groepId,
      'groepNaam': groepNaam,
      'groepSorteerIndex': groepSorteerIndex,
      'actief': actief,
      'isGroepDefinitie': isGroepDefinitie,
    };
  }

  factory OpmetingRaamOpvullingModel.fromJson(Map<String, dynamic> json) {
    final transparantieWaarde = _leesDouble(json['transparantie'], 0.25);
    final isGroepDefinitie =
        json['isGroepDefinitie'] == true ||
        json['type']?.toString().trim().toLowerCase() == 'groep' ||
        json['soort']?.toString().trim().toLowerCase() == 'groep';

    final ruweGroepId =
        json['groepId'] ??
        json['groep'] ??
        json['categorie'] ??
        json['submenu'];
    final ruweGroepNaam =
        json['groepNaam'] ?? json['groepLabel'] ?? json['submenuNaam'];
    final standaardGroep =
        OpmetingRaamOpvullingGroepModel.standaardGroepVoorWaarde(
          ruweGroepNaam ?? ruweGroepId,
        );

    final heeftExplicieteGroepNaam =
        ruweGroepNaam?.toString().trim().isNotEmpty ?? false;
    final heeftExplicieteGroepId =
        ruweGroepId?.toString().trim().isNotEmpty ?? false;

    final groepNaam = heeftExplicieteGroepNaam
        ? ruweGroepNaam.toString().trim()
        : standaardGroep.naam;
    final groepId =
        heeftExplicieteGroepId &&
            (heeftExplicieteGroepNaam || standaardGroep.sorteerIndex >= 99)
        ? OpmetingRaamOpvullingGroepModel.maakId(ruweGroepId.toString())
        : standaardGroep.id;

    return OpmetingRaamOpvullingModel(
      id: json['id']?.toString() ?? '',
      naam: json['naam']?.toString() ?? '',
      kleurWaarde: _leesKleurWaarde(
        json['kleurWaarde'] ?? json['kleur'] ?? json['kleurwaarde'],
      ),
      transparantie: _normaliseerTransparantie(transparantieWaarde),
      groepId: groepId,
      groepNaam: groepNaam,
      groepSorteerIndex: _leesInt(
        json['groepSorteerIndex'] ?? json['sorteerIndex'],
        standaardGroep.sorteerIndex,
      ),
      actief: json['actief'] != false,
      isGroepDefinitie: isGroepDefinitie,
    );
  }

  factory OpmetingRaamOpvullingModel.groepDefinitie(
    OpmetingRaamOpvullingGroepModel groep,
  ) {
    return OpmetingRaamOpvullingModel(
      id: '__groep__${groep.id}',
      naam: groep.naam,
      kleurWaarde: 0xFFE7F6EC,
      transparantie: 0.10,
      groepId: groep.id,
      groepNaam: groep.naam,
      groepSorteerIndex: groep.sorteerIndex,
      actief: false,
      isGroepDefinitie: true,
    );
  }

  static double _normaliseerTransparantie(double waarde) {
    if (waarde > 1) {
      return (waarde / 100).clamp(0.05, 1.0).toDouble();
    }

    return waarde.clamp(0.05, 1.0).toDouble();
  }

  static double _leesDouble(Object? waarde, double standaard) {
    if (waarde is num) {
      return waarde.toDouble();
    }

    if (waarde is String) {
      final genormaliseerd = waarde.trim().replaceAll(',', '.');
      return double.tryParse(genormaliseerd) ?? standaard;
    }

    return standaard;
  }

  static int _leesInt(Object? waarde, int standaard) {
    if (waarde is num) {
      return waarde.toInt();
    }

    if (waarde is String) {
      return int.tryParse(waarde.trim()) ?? standaard;
    }

    return standaard;
  }

  static int _leesKleurWaarde(Object? waarde) {
    if (waarde is num) {
      return waarde.toInt();
    }

    if (waarde is String) {
      var tekst = waarde.trim();

      if (tekst.isEmpty) {
        return 0xFFB3E5FC;
      }

      if (tekst.startsWith('#')) {
        tekst = tekst.substring(1);
      }

      if (tekst.toLowerCase().startsWith('0x')) {
        tekst = tekst.substring(2);
      }

      if (tekst.length == 6) {
        tekst = 'FF$tekst';
      }

      final kleur = int.tryParse(tekst, radix: 16);
      if (kleur != null) {
        return kleur;
      }
    }

    return 0xFFB3E5FC;
  }
}
