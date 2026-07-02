import 'package:flutter/material.dart';

class OpmetingRaamLijn {
  const OpmetingRaamLijn({
    required this.id,
    required this.start,
    required this.einde,
  });

  final String id;
  final Offset start;
  final Offset einde;

  bool get isHorizontaal {
    return (start.dy - einde.dy).abs() < (start.dx - einde.dx).abs();
  }

  bool get isVerticaal => !isHorizontaal;
}

class OpmetingRaamTStijl {
  const OpmetingRaamTStijl({
    required this.id,
    required this.richting,
    required this.start,
    required this.einde,
    this.breedteMm = 90,
    this.werkvlakId = 'kader',
  });

  final String id;
  final String richting;
  final Offset start;
  final Offset einde;
  final double breedteMm;

  /// 'kader' voor een gewone T-stijl in het raam.
  ///
  /// Bij een T-stijl in een vleugel bevat dit de unieke
  /// identificatie van de glasopening van die vleugel.
  final String werkvlakId;
}

/// Alle beschikbare types vleugels.
///
/// Links en rechts worden bekeken vanaf de binnenzijde.
///
/// Draaikip rechts:
/// - scharnieren rechts;
/// - draait naar rechts;
/// - kiept bovenaan naar binnen.
enum OpmetingRaamVleugelType {
  geenVleugel,
  enkelOpenRechts,
  enkelOpenLinks,

  draaiKipRechts,
  draaiKipLinks,

  kipraamMetKnipslot,
  kipraamKrukBoven,
  kipraamKrukRechts,
  kipraamKrukLinks,

  dubbelOpenKrukRechts,
  dubbelOpenKrukLinks,

  dubbelDraaiKipKrukRechts,
  dubbelDraaiKipKrukLinks,

  vastDubbeleKader,
}

extension OpmetingRaamVleugelTypeInfo on OpmetingRaamVleugelType {
  String get naam {
    switch (this) {
      case OpmetingRaamVleugelType.geenVleugel:
        return 'Geen vleugel';

      case OpmetingRaamVleugelType.enkelOpenRechts:
        return 'Enkel opendraaiend kruk rechts';

      case OpmetingRaamVleugelType.enkelOpenLinks:
        return 'Enkel opendraaiend kruk links';

      case OpmetingRaamVleugelType.draaiKipRechts:
        return 'Draaikip kruk rechts';

      case OpmetingRaamVleugelType.draaiKipLinks:
        return 'Draaikip kruk links';

      case OpmetingRaamVleugelType.kipraamMetKnipslot:
        return 'Kipraam met knipslot';

      case OpmetingRaamVleugelType.kipraamKrukBoven:
        return 'Kipraam met kruk boven';

      case OpmetingRaamVleugelType.kipraamKrukRechts:
        return 'Kipraam met kruk rechts';

      case OpmetingRaamVleugelType.kipraamKrukLinks:
        return 'Kipraam met kruk links';

      case OpmetingRaamVleugelType.dubbelOpenKrukRechts:
        return 'Dubbel opendraaiend kruk rechts';

      case OpmetingRaamVleugelType.dubbelOpenKrukLinks:
        return 'Dubbel opendraaiend kruk links';

      case OpmetingRaamVleugelType.dubbelDraaiKipKrukRechts:
        return 'Dubbel opendraaiend draaikip kruk rechts';

      case OpmetingRaamVleugelType.dubbelDraaiKipKrukLinks:
        return 'Dubbel opendraaiend draaikip kruk links';

      case OpmetingRaamVleugelType.vastDubbeleKader:
        return 'Vast dubbele kader';
    }
  }

  bool get isDubbel {
    switch (this) {
      case OpmetingRaamVleugelType.dubbelOpenKrukRechts:
      case OpmetingRaamVleugelType.dubbelOpenKrukLinks:
      case OpmetingRaamVleugelType.dubbelDraaiKipKrukRechts:
      case OpmetingRaamVleugelType.dubbelDraaiKipKrukLinks:
        return true;

      default:
        return false;
    }
  }

  bool get heeftKipfunctie {
    switch (this) {
      case OpmetingRaamVleugelType.draaiKipRechts:
      case OpmetingRaamVleugelType.draaiKipLinks:
      case OpmetingRaamVleugelType.kipraamMetKnipslot:
      case OpmetingRaamVleugelType.kipraamKrukBoven:
      case OpmetingRaamVleugelType.kipraamKrukRechts:
      case OpmetingRaamVleugelType.kipraamKrukLinks:
      case OpmetingRaamVleugelType.dubbelDraaiKipKrukRechts:
      case OpmetingRaamVleugelType.dubbelDraaiKipKrukLinks:
        return true;

      default:
        return false;
    }
  }
}

class OpmetingRaamVleugel {
  const OpmetingRaamVleugel({
    required this.id,
    required this.vlak,
    required this.type,
  });

  final String id;
  final Rect vlak;
  final OpmetingRaamVleugelType type;
}

/// Koppelt één berekend vulvlak aan een opvulling.
///
/// De naam, kleur en transparantie worden mee opgeslagen.
/// Daardoor blijft een bestaande raamopmeting correct wanneer
/// de oorspronkelijke opvulling later in Instellingen wordt
/// aangepast of verwijderd.
class OpmetingRaamVullingToewijzing {
  const OpmetingRaamVullingToewijzing({
    required this.vlakId,
    required this.werkvlakId,
    required this.opvullingId,
    required this.naam,
    required this.kleurWaarde,
    required this.transparantie,
  });

  /// Unieke en reproduceerbare identificatie van het vulvlak.
  final String vlakId;

  /// Hoofdraam of glasopening van een vleugel.
  ///
  /// Voorbeelden:
  /// - kader
  /// - vleugel_123_enkel
  /// - vleugel_123_links
  /// - vleugel_123_rechts
  final String werkvlakId;

  /// Verwijzing naar de opvulling uit Instellingen.
  final String opvullingId;

  /// Momentopname van de naam.
  final String naam;

  /// Momentopname van de ARGB-kleurwaarde.
  final int kleurWaarde;

  /// Momentopname van de dekking tussen 0.05 en 1.00.
  final double transparantie;

  Color get kleur => Color(kleurWaarde);

  Color get weergaveKleur {
    return kleur.withOpacity(transparantie.clamp(0.05, 1.0).toDouble());
  }

  int get transparantiePercentage {
    return (transparantie * 100).round();
  }

  OpmetingRaamVullingToewijzing copyWith({
    String? vlakId,
    String? werkvlakId,
    String? opvullingId,
    String? naam,
    int? kleurWaarde,
    double? transparantie,
  }) {
    return OpmetingRaamVullingToewijzing(
      vlakId: vlakId ?? this.vlakId,
      werkvlakId: werkvlakId ?? this.werkvlakId,
      opvullingId: opvullingId ?? this.opvullingId,
      naam: naam ?? this.naam,
      kleurWaarde: kleurWaarde ?? this.kleurWaarde,
      transparantie: transparantie ?? this.transparantie,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vlakId': vlakId,
      'werkvlakId': werkvlakId,
      'opvullingId': opvullingId,
      'naam': naam,
      'kleurWaarde': kleurWaarde,
      'transparantie': transparantie,
    };
  }

  factory OpmetingRaamVullingToewijzing.fromJson(Map<String, dynamic> json) {
    final transparantieWaarde =
        (json['transparantie'] as num?)?.toDouble() ?? 0.25;

    return OpmetingRaamVullingToewijzing(
      vlakId: json['vlakId']?.toString() ?? '',
      werkvlakId: json['werkvlakId']?.toString() ?? 'kader',
      opvullingId: json['opvullingId']?.toString() ?? '',
      naam: json['naam']?.toString() ?? '',
      kleurWaarde: (json['kleurWaarde'] as num?)?.toInt() ?? 0xFFB3E5FC,
      transparantie: transparantieWaarde.clamp(0.05, 1.0).toDouble(),
    );
  }
}
