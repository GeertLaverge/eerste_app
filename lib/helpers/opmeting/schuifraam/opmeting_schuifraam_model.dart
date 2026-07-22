import 'package:flutter/foundation.dart';

enum OpmetingSchuifraamType { mono, duo }

extension OpmetingSchuifraamTypeInfo on OpmetingSchuifraamType {
  String get label {
    switch (this) {
      case OpmetingSchuifraamType.mono:
        return 'Mono schuifraam';
      case OpmetingSchuifraamType.duo:
        return 'Duo schuifraam';
    }
  }

  String get korteLabel {
    switch (this) {
      case OpmetingSchuifraamType.mono:
        return 'Mono';
      case OpmetingSchuifraamType.duo:
        return 'Duo';
    }
  }

  static OpmetingSchuifraamType vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';

    for (final type in OpmetingSchuifraamType.values) {
      if (type.name == tekst) {
        return type;
      }
    }

    return OpmetingSchuifraamType.mono;
  }
}

enum OpmetingSchuifraamSysteem {
  s150,
  ct70Hefschuif,
  xmovePvcLi82,
  hefSchuifVgVleugelBinnenzijde,
  hefSchuifUgVleugelBinnenzijde,
}

extension OpmetingSchuifraamSysteemInfo on OpmetingSchuifraamSysteem {
  String get label {
    switch (this) {
      case OpmetingSchuifraamSysteem.ct70Hefschuif:
        return 'CT70 Hefschuif';
      case OpmetingSchuifraamSysteem.s150:
        return 'S150';
      case OpmetingSchuifraamSysteem.xmovePvcLi82:
        return 'XMove PVC LI82';
      case OpmetingSchuifraamSysteem.hefSchuifVgVleugelBinnenzijde:
        return 'Hefschuif VG vleugel binnenzijde';
      case OpmetingSchuifraamSysteem.hefSchuifUgVleugelBinnenzijde:
        return 'Hefschuif UG vleugel binnenzijde';
    }
  }

  bool get isAluminiumSysteem {
    return this == OpmetingSchuifraamSysteem.hefSchuifVgVleugelBinnenzijde ||
        this == OpmetingSchuifraamSysteem.hefSchuifUgVleugelBinnenzijde;
  }

  OpmetingSchuifraamType get verplichtType {
    switch (this) {
      case OpmetingSchuifraamSysteem.ct70Hefschuif:
      case OpmetingSchuifraamSysteem.s150:
        return OpmetingSchuifraamType.duo;
      case OpmetingSchuifraamSysteem.xmovePvcLi82:
      case OpmetingSchuifraamSysteem.hefSchuifVgVleugelBinnenzijde:
      case OpmetingSchuifraamSysteem.hefSchuifUgVleugelBinnenzijde:
        return OpmetingSchuifraamType.mono;
    }
  }

  bool ondersteuntType(OpmetingSchuifraamType type) {
    return verplichtType == type;
  }

  bool pastBijFormulier(String formulierType) {
    final genormaliseerd = formulierType.trim().toLowerCase();
    final isAlu =
        genormaliseerd == 'aluschuifraam' ||
        genormaliseerd == 'alu_schuifraam' ||
        genormaliseerd == 'alu schuifraam';

    return isAlu ? isAluminiumSysteem : !isAluminiumSysteem;
  }

  static List<OpmetingSchuifraamSysteem> voorFormulier(String formulierType) {
    return OpmetingSchuifraamSysteem.values
        .where((systeem) => systeem.pastBijFormulier(formulierType))
        .toList(growable: false);
  }

  static OpmetingSchuifraamSysteem standaardVoorFormulier(
    String formulierType,
  ) {
    final beschikbareSystemen = voorFormulier(formulierType);

    if (beschikbareSystemen.isNotEmpty) {
      return beschikbareSystemen.first;
    }

    return OpmetingSchuifraamSysteem.s150;
  }

  static OpmetingSchuifraamSysteem vanOpslagWaarde(
    Object? waarde, {
    OpmetingSchuifraamType? oudType,
  }) {
    final tekst = waarde?.toString().trim() ?? '';

    for (final systeem in OpmetingSchuifraamSysteem.values) {
      if (systeem.name == tekst ||
          systeem.label.toLowerCase() == tekst.toLowerCase()) {
        return systeem;
      }
    }

    // Oude schuifraamfiches hadden nog geen systeemkeuze. We behouden hun
    // mono/duo-opbouw door daar een passend standaardsysteem voor te kiezen.
    if (oudType == OpmetingSchuifraamType.duo) {
      return OpmetingSchuifraamSysteem.ct70Hefschuif;
    }

    return OpmetingSchuifraamSysteem.xmovePvcLi82;
  }
}

enum OpmetingSchuifraamVakType { vast, schuif }

extension OpmetingSchuifraamVakTypeInfo on OpmetingSchuifraamVakType {
  String get code {
    switch (this) {
      case OpmetingSchuifraamVakType.vast:
        return 'V';
      case OpmetingSchuifraamVakType.schuif:
        return 'S';
    }
  }

  String get label {
    switch (this) {
      case OpmetingSchuifraamVakType.vast:
        return 'Vast';
      case OpmetingSchuifraamVakType.schuif:
        return 'Schuif';
    }
  }

  static OpmetingSchuifraamVakType? vanCode(Object? waarde) {
    final tekst = waarde?.toString().trim().toUpperCase() ?? '';

    if (tekst == 'V' || tekst == 'VAST') {
      return OpmetingSchuifraamVakType.vast;
    }

    if (tekst == 'S' || tekst == 'SCHUIF') {
      return OpmetingSchuifraamVakType.schuif;
    }

    return null;
  }
}

@immutable
class OpmetingSchuifraamOpbouwType {
  const OpmetingSchuifraamOpbouwType({required this.id, required this.vakken});

  final String id;
  final List<OpmetingSchuifraamVakType> vakken;

  bool get isGeldig {
    return vakken.length >= 2 &&
        vakken.length <= 4 &&
        vakken.any((vak) => vak == OpmetingSchuifraamVakType.schuif);
  }

  String get code => vakken.map((vak) => vak.code).join(' ');

  String get opslagSleutel => vakken.map((vak) => vak.code).join();

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'vakken': vakken.map((vak) => vak.code).toList(),
    };
  }

  factory OpmetingSchuifraamOpbouwType.fromJson(Map<String, dynamic> json) {
    final vakken = <OpmetingSchuifraamVakType>[];
    final ruweVakken = json['vakken'];

    if (ruweVakken is List) {
      for (final waarde in ruweVakken.take(4)) {
        final vak = OpmetingSchuifraamVakTypeInfo.vanCode(waarde);

        if (vak != null) {
          vakken.add(vak);
        }
      }
    }

    final idTekst = json['id']?.toString().trim() ?? '';
    final id = idTekst.isNotEmpty
        ? idTekst
        : 'schuifraam_opbouw_${DateTime.now().microsecondsSinceEpoch}';

    return OpmetingSchuifraamOpbouwType(
      id: id,
      vakken: List<OpmetingSchuifraamVakType>.unmodifiable(vakken),
    );
  }
}

@immutable
class OpmetingSchuifraamSamenstelling {
  const OpmetingSchuifraamSamenstelling({
    this.systeem = OpmetingSchuifraamSysteem.s150,
    this.type = OpmetingSchuifraamType.duo,
    this.vakken = const <OpmetingSchuifraamVakType>[
      OpmetingSchuifraamVakType.vast,
      OpmetingSchuifraamVakType.schuif,
    ],
    this.breedteDelen = const <double>[1, 1],
    this.scheidingVerschuivingenMm = const <double>[0],
    this.onderkantVloerpasMm,
  });

  factory OpmetingSchuifraamSamenstelling.standaardVoorFormulier(
    String formulierType,
  ) {
    final systeem = OpmetingSchuifraamSysteemInfo.standaardVoorFormulier(
      formulierType,
    );

    return OpmetingSchuifraamSamenstelling(
      systeem: systeem,
      type: systeem.verplichtType,
    );
  }

  final OpmetingSchuifraamSysteem systeem;
  final OpmetingSchuifraamType type;
  final List<OpmetingSchuifraamVakType> vakken;

  /// Relatieve breedte per vak. Voor V/S kan bijvoorbeeld [2, 1]
  /// gebruikt worden om het vaste deel 2/3 en het schuivende deel 1/3
  /// van de binnenbreedte te geven.
  final List<double> breedteDelen;

  /// Correctie per scheiding in millimeter. Een positieve waarde verplaatst
  /// de scheiding naar rechts, een negatieve waarde naar links.
  /// Bij twee vakken bevat deze lijst dus één waarde.
  final List<double> scheidingVerschuivingenMm;

  /// Positie van de onderkant van het schuifraam onder de vloerpas.
  /// Null betekent: gelijk met vloerpas.
  final double? onderkantVloerpasMm;

  bool get isGeldig {
    return vakken.length >= 2 &&
        vakken.length <= 4 &&
        vakken.any((vak) => vak == OpmetingSchuifraamVakType.schuif) &&
        systeem.ondersteuntType(type);
  }

  String get code => vakken.map((vak) => vak.code).join(' ');

  String get opbouwTekst => vakken.map((vak) => vak.label).join('-');

  String get schuifrichtingTekst {
    final richtingen = <int>{};

    for (var index = 0; index < vakken.length; index++) {
      if (vakken[index] != OpmetingSchuifraamVakType.schuif) {
        continue;
      }

      richtingen.add(_pijlRichtingVoorVak(index));
    }

    if (richtingen.isEmpty) {
      return '';
    }

    if (richtingen.length > 1) {
      return 'Schuifrichtingen links en rechts';
    }

    return richtingen.first < 0
        ? 'Schuifrichting links'
        : 'Schuifrichting rechts';
  }

  int _pijlRichtingVoorVak(int index) {
    var afstandLinks = 999;
    var afstandRechts = 999;

    for (var linksIndex = index - 1; linksIndex >= 0; linksIndex--) {
      if (vakken[linksIndex] == OpmetingSchuifraamVakType.vast) {
        afstandLinks = index - linksIndex;
        break;
      }
    }

    for (
      var rechtsIndex = index + 1;
      rechtsIndex < vakken.length;
      rechtsIndex++
    ) {
      if (vakken[rechtsIndex] == OpmetingSchuifraamVakType.vast) {
        afstandRechts = rechtsIndex - index;
        break;
      }
    }

    if (afstandLinks < afstandRechts) {
      return -1;
    }

    if (afstandRechts < afstandLinks) {
      return 1;
    }

    return index < vakken.length / 2 ? -1 : 1;
  }

  String get samenvatting {
    final basis = '${systeem.label} ${type.korteLabel} ($opbouwTekst)';

    if (!systeem.isAluminiumSysteem) {
      return basis;
    }

    final richting = schuifrichtingTekst;
    return richting.isEmpty ? basis : '$basis · $richting';
  }

  List<double> get genormaliseerdeBreedtes {
    if (vakken.isEmpty) {
      return const <double>[];
    }

    final delen = <double>[];

    for (var index = 0; index < vakken.length; index++) {
      final waarde = index < breedteDelen.length ? breedteDelen[index] : 1.0;
      delen.add(waarde.isFinite && waarde > 0 ? waarde : 1.0);
    }

    final totaal = delen.fold<double>(0, (som, waarde) => som + waarde);

    if (totaal <= 0) {
      return List<double>.filled(vakken.length, 1 / vakken.length);
    }

    return delen.map((waarde) => waarde / totaal).toList(growable: false);
  }

  List<double> get genormaliseerdeScheidingVerschuivingenMm {
    final aantal = vakken.length > 1 ? vakken.length - 1 : 0;

    return List<double>.generate(aantal, (index) {
      final waarde = index < scheidingVerschuivingenMm.length
          ? scheidingVerschuivingenMm[index]
          : 0.0;

      return waarde.isFinite ? waarde : 0.0;
    }, growable: false);
  }

  OpmetingSchuifraamSamenstelling copyWith({
    OpmetingSchuifraamSysteem? systeem,
    OpmetingSchuifraamType? type,
    List<OpmetingSchuifraamVakType>? vakken,
    List<double>? breedteDelen,
    List<double>? scheidingVerschuivingenMm,
    double? onderkantVloerpasMm,
    bool wisOnderkantVloerpasMm = false,
  }) {
    return OpmetingSchuifraamSamenstelling(
      systeem: systeem ?? this.systeem,
      type: type ?? this.type,
      vakken: List<OpmetingSchuifraamVakType>.unmodifiable(
        vakken ?? this.vakken,
      ),
      breedteDelen: List<double>.unmodifiable(
        breedteDelen ?? this.breedteDelen,
      ),
      scheidingVerschuivingenMm: List<double>.unmodifiable(
        scheidingVerschuivingenMm ?? this.scheidingVerschuivingenMm,
      ),
      onderkantVloerpasMm: wisOnderkantVloerpasMm
          ? null
          : (onderkantVloerpasMm ?? this.onderkantVloerpasMm),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'systeem': systeem.name,
      'type': type.name,
      'vakken': vakken.map((vak) => vak.code).toList(),
      'breedteDelen': breedteDelen,
      'scheidingVerschuivingenMm': scheidingVerschuivingenMm,
      'onderkantVloerpasMm': onderkantVloerpasMm,
    };
  }

  factory OpmetingSchuifraamSamenstelling.fromJson(Map<String, dynamic> json) {
    final vakken = <OpmetingSchuifraamVakType>[];
    final ruweVakken = json['vakken'];

    if (ruweVakken is List) {
      for (final waarde in ruweVakken) {
        final vak = OpmetingSchuifraamVakTypeInfo.vanCode(waarde);
        if (vak != null && vakken.length < 4) {
          vakken.add(vak);
        }
      }
    }

    final breedteDelen = <double>[];
    final ruweDelen = json['breedteDelen'];

    if (ruweDelen is List) {
      for (final waarde in ruweDelen.take(4)) {
        if (waarde is num) {
          breedteDelen.add(waarde.toDouble());
        } else {
          breedteDelen.add(double.tryParse(waarde.toString()) ?? 1.0);
        }
      }
    }

    final verschuivingen = <double>[];
    final ruweVerschuivingen = json['scheidingVerschuivingenMm'];

    if (ruweVerschuivingen is List) {
      for (final waarde in ruweVerschuivingen.take(3)) {
        if (waarde is num) {
          verschuivingen.add(waarde.toDouble());
        } else {
          verschuivingen.add(double.tryParse(waarde.toString()) ?? 0.0);
        }
      }
    }

    double? onderkantVloerpasMm;
    final ruweOnderkantVloerpas = json['onderkantVloerpasMm'];

    if (ruweOnderkantVloerpas is num) {
      onderkantVloerpasMm = ruweOnderkantVloerpas.toDouble();
    } else if (ruweOnderkantVloerpas != null) {
      onderkantVloerpasMm = double.tryParse(
        ruweOnderkantVloerpas.toString().replaceAll(',', '.'),
      );
    }

    if (onderkantVloerpasMm != null &&
        (!onderkantVloerpasMm.isFinite || onderkantVloerpasMm < 0)) {
      onderkantVloerpasMm = null;
    }

    final geldigeVakken = vakken.length >= 2
        ? vakken
        : <OpmetingSchuifraamVakType>[
            OpmetingSchuifraamVakType.vast,
            OpmetingSchuifraamVakType.schuif,
          ];

    final oudType = OpmetingSchuifraamTypeInfo.vanOpslagWaarde(json['type']);
    final systeem = OpmetingSchuifraamSysteemInfo.vanOpslagWaarde(
      json['systeem'],
      oudType: oudType,
    );
    final type = systeem.verplichtType;
    final aantalScheidingen = geldigeVakken.length - 1;

    return OpmetingSchuifraamSamenstelling(
      systeem: systeem,
      type: type,
      vakken: List<OpmetingSchuifraamVakType>.unmodifiable(geldigeVakken),
      breedteDelen: List<double>.unmodifiable(
        breedteDelen.length == geldigeVakken.length
            ? breedteDelen
            : List<double>.filled(geldigeVakken.length, 1),
      ),
      scheidingVerschuivingenMm: List<double>.unmodifiable(
        List<double>.generate(
          aantalScheidingen,
          (index) => index < verschuivingen.length ? verschuivingen[index] : 0,
        ),
      ),
      onderkantVloerpasMm: onderkantVloerpasMm,
    );
  }
}
