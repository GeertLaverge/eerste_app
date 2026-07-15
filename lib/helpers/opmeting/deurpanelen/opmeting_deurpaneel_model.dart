import 'package:flutter/foundation.dart';

/// Uitvoering waarmee een deurpaneel geplaatst mag worden.
///
/// - [nietVleugelOverdekkend]: paneel start vanaf de binnenlijn van de
///   deurvleugel. De vleugel blijft zichtbaar.
/// - [vleugelOverdekkend]: paneel start vanaf de buitenlijnen van de
///   deurvleugel. De vleugel zelf wordt daardoor afgedekt.
enum OpmetingDeurpaneelUitvoering { nietVleugelOverdekkend, vleugelOverdekkend }

extension OpmetingDeurpaneelUitvoeringInfo on OpmetingDeurpaneelUitvoering {
  String get label {
    switch (this) {
      case OpmetingDeurpaneelUitvoering.nietVleugelOverdekkend:
        return 'Niet vleugeloverdekkend';
      case OpmetingDeurpaneelUitvoering.vleugelOverdekkend:
        return 'Vleugeloverdekkend';
    }
  }

  String get opslagWaarde {
    switch (this) {
      case OpmetingDeurpaneelUitvoering.nietVleugelOverdekkend:
        return 'nietVleugelOverdekkend';
      case OpmetingDeurpaneelUitvoering.vleugelOverdekkend:
        return 'vleugelOverdekkend';
    }
  }

  static OpmetingDeurpaneelUitvoering vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';

    for (final uitvoering in OpmetingDeurpaneelUitvoering.values) {
      if (uitvoering.opslagWaarde == tekst || uitvoering.name == tekst) {
        return uitvoering;
      }
    }

    return OpmetingDeurpaneelUitvoering.nietVleugelOverdekkend;
  }
}

enum OpmetingDeurpaneelCilinderZijde { geen, links, rechts }

extension OpmetingDeurpaneelCilinderZijdeInfo
    on OpmetingDeurpaneelCilinderZijde {
  String get label {
    switch (this) {
      case OpmetingDeurpaneelCilinderZijde.geen:
        return 'Geen cilinder opgegeven';
      case OpmetingDeurpaneelCilinderZijde.links:
        return 'Links';
      case OpmetingDeurpaneelCilinderZijde.rechts:
        return 'Rechts';
    }
  }

  String get opslagWaarde {
    switch (this) {
      case OpmetingDeurpaneelCilinderZijde.geen:
        return 'geen';
      case OpmetingDeurpaneelCilinderZijde.links:
        return 'links';
      case OpmetingDeurpaneelCilinderZijde.rechts:
        return 'rechts';
    }
  }

  static OpmetingDeurpaneelCilinderZijde vanTekst(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';

    if (tekst == 'links' || tekst == 'linker' || tekst == 'l') {
      return OpmetingDeurpaneelCilinderZijde.links;
    }

    if (tekst == 'rechts' || tekst == 'rechter' || tekst == 'r') {
      return OpmetingDeurpaneelCilinderZijde.rechts;
    }

    return OpmetingDeurpaneelCilinderZijde.geen;
  }
}

@immutable
class OpmetingDeurpaneel {
  const OpmetingDeurpaneel({
    required this.id,
    required this.naam,
    required this.tekeningBestandsnaam,
    required this.nietVleugelOverdekkendToegelaten,
    required this.vleugelOverdekkendToegelaten,
    this.cilinderZijde = OpmetingDeurpaneelCilinderZijde.geen,
    this.actief = true,
    this.opmerking = '',
  });

  final String id;
  final String naam;
  final String tekeningBestandsnaam;
  final bool nietVleugelOverdekkendToegelaten;
  final bool vleugelOverdekkendToegelaten;
  final OpmetingDeurpaneelCilinderZijde cilinderZijde;
  final bool actief;
  final String opmerking;

  bool isToegelatenVoor(OpmetingDeurpaneelUitvoering uitvoering) {
    switch (uitvoering) {
      case OpmetingDeurpaneelUitvoering.nietVleugelOverdekkend:
        return nietVleugelOverdekkendToegelaten;
      case OpmetingDeurpaneelUitvoering.vleugelOverdekkend:
        return vleugelOverdekkendToegelaten;
    }
  }

  String get typeLabel {
    if (nietVleugelOverdekkendToegelaten && vleugelOverdekkendToegelaten) {
      return 'Beide';
    }

    if (vleugelOverdekkendToegelaten) {
      return 'Vleugeloverdekkend';
    }

    return 'Niet vleugeloverdekkend';
  }

  String get zoekTekst {
    return '$id $naam $tekeningBestandsnaam $typeLabel ${cilinderZijde.label}'
        .toLowerCase();
  }

  OpmetingDeurpaneel copyWith({
    String? id,
    String? naam,
    String? tekeningBestandsnaam,
    bool? nietVleugelOverdekkendToegelaten,
    bool? vleugelOverdekkendToegelaten,
    OpmetingDeurpaneelCilinderZijde? cilinderZijde,
    bool? actief,
    String? opmerking,
  }) {
    return OpmetingDeurpaneel(
      id: id ?? this.id,
      naam: naam ?? this.naam,
      tekeningBestandsnaam: tekeningBestandsnaam ?? this.tekeningBestandsnaam,
      nietVleugelOverdekkendToegelaten:
          nietVleugelOverdekkendToegelaten ??
          this.nietVleugelOverdekkendToegelaten,
      vleugelOverdekkendToegelaten:
          vleugelOverdekkendToegelaten ?? this.vleugelOverdekkendToegelaten,
      cilinderZijde: cilinderZijde ?? this.cilinderZijde,
      actief: actief ?? this.actief,
      opmerking: opmerking ?? this.opmerking,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'naam': naam,
      'tekeningBestandsnaam': tekeningBestandsnaam,
      'nietVleugelOverdekkendToegelaten': nietVleugelOverdekkendToegelaten,
      'vleugelOverdekkendToegelaten': vleugelOverdekkendToegelaten,
      'cilinderZijde': cilinderZijde.opslagWaarde,
      'actief': actief,
      'opmerking': opmerking,
    };
  }

  factory OpmetingDeurpaneel.fromJson(Map<String, dynamic> json) {
    return OpmetingDeurpaneel(
      id: json['id']?.toString() ?? '',
      naam: json['naam']?.toString() ?? '',
      tekeningBestandsnaam:
          json['tekeningBestandsnaam']?.toString() ??
          json['tekening']?.toString() ??
          '',
      nietVleugelOverdekkendToegelaten:
          json['nietVleugelOverdekkendToegelaten'] == true,
      vleugelOverdekkendToegelaten:
          json['vleugelOverdekkendToegelaten'] == true,
      cilinderZijde: OpmetingDeurpaneelCilinderZijdeInfo.vanTekst(
        json['cilinderZijde'] ?? json['cilinder'],
      ),
      actief: json['actief'] != false,
      opmerking: json['opmerking']?.toString() ?? '',
    );
  }
}

@immutable
class OpmetingDeurpaneelKeuze {
  const OpmetingDeurpaneelKeuze({
    required this.paneel,
    required this.uitvoering,
    this.wissen = false,
  });

  factory OpmetingDeurpaneelKeuze.wissen() {
    return const OpmetingDeurpaneelKeuze(
      paneel: OpmetingDeurpaneel(
        id: '__wissen__',
        naam: 'Paneel wissen',
        tekeningBestandsnaam: '',
        nietVleugelOverdekkendToegelaten: true,
        vleugelOverdekkendToegelaten: true,
      ),
      uitvoering: OpmetingDeurpaneelUitvoering.nietVleugelOverdekkend,
      wissen: true,
    );
  }

  final OpmetingDeurpaneel paneel;
  final OpmetingDeurpaneelUitvoering uitvoering;
  final bool wissen;

  String get samenvatting {
    if (wissen) {
      return 'Deurpaneel wissen';
    }

    return '${paneel.naam} (${paneel.id}) · ${uitvoering.label}';
  }
}
