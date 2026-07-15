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

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'start': _offsetToJson(start),
      'einde': _offsetToJson(einde),
    };
  }

  factory OpmetingRaamLijn.fromJson(Map<String, dynamic> json) {
    return OpmetingRaamLijn(
      id: json['id']?.toString() ?? '',
      start: _offsetFromJson(json['start']),
      einde: _offsetFromJson(json['einde']),
    );
  }
}

class OpmetingRaamTStijl {
  const OpmetingRaamTStijl({
    required this.id,
    required this.richting,
    required this.start,
    required this.einde,
    this.breedteMm = 90,
    this.werkvlakId = 'kader',
    this.positieFractie,
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

  /// Relatieve positie binnen het werkvlak.
  ///
  /// Voor een verticale T-stijl is dit de X-fractie binnen het werkvlak.
  /// Voor een horizontale T-stijl is dit de Y-fractie binnen het werkvlak.
  /// Dit wordt vooral gebruikt voor T-stijlen in een deurvleugel, zodat ze
  /// automatisch blijven meegaan wanneer de dubbele deur ongelijk wordt gezet.
  final double? positieFractie;

  OpmetingRaamTStijl copyWith({
    String? id,
    String? richting,
    Offset? start,
    Offset? einde,
    double? breedteMm,
    String? werkvlakId,
    double? positieFractie,
    bool wisPositieFractie = false,
  }) {
    return OpmetingRaamTStijl(
      id: id ?? this.id,
      richting: richting ?? this.richting,
      start: start ?? this.start,
      einde: einde ?? this.einde,
      breedteMm: breedteMm ?? this.breedteMm,
      werkvlakId: werkvlakId ?? this.werkvlakId,
      positieFractie: wisPositieFractie
          ? null
          : positieFractie ?? this.positieFractie,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'richting': richting,
      'start': _offsetToJson(start),
      'einde': _offsetToJson(einde),
      'breedteMm': breedteMm,
      'werkvlakId': werkvlakId,
      if (positieFractie != null) 'positieFractie': positieFractie,
    };
  }

  factory OpmetingRaamTStijl.fromJson(Map<String, dynamic> json) {
    return OpmetingRaamTStijl(
      id: json['id']?.toString() ?? '',
      richting: json['richting']?.toString() ?? 'verticaal',
      start: _offsetFromJson(json['start']),
      einde: _offsetFromJson(json['einde']),
      breedteMm: _leesDouble(json['breedteMm'], 90),
      werkvlakId: json['werkvlakId']?.toString() ?? 'kader',
      positieFractie: _leesDoubleOfNull(json['positieFractie']),
    );
  }
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

  static OpmetingRaamVleugelType vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';

    for (final type in OpmetingRaamVleugelType.values) {
      if (type.name == tekst) {
        return type;
      }
    }

    return OpmetingRaamVleugelType.geenVleugel;
  }
}

enum OpmetingRaamDeurVleugelSoort { voordeur, achterdeur }

extension OpmetingRaamDeurVleugelSoortInfo on OpmetingRaamDeurVleugelSoort {
  String get opslagWaarde => name;

  String get label {
    switch (this) {
      case OpmetingRaamDeurVleugelSoort.voordeur:
        return 'Voordeur';
      case OpmetingRaamDeurVleugelSoort.achterdeur:
        return 'Achterdeur';
    }
  }

  static OpmetingRaamDeurVleugelSoort vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';

    for (final soort in OpmetingRaamDeurVleugelSoort.values) {
      if (soort.name == tekst) {
        return soort;
      }
    }

    return OpmetingRaamDeurVleugelSoort.voordeur;
  }
}

enum OpmetingRaamDeurVleugelKrukType { kruk, rolluikkruk }

extension OpmetingRaamDeurVleugelKrukTypeInfo
    on OpmetingRaamDeurVleugelKrukType {
  String get opslagWaarde => name;

  String get label {
    switch (this) {
      case OpmetingRaamDeurVleugelKrukType.kruk:
        return 'kruk';
      case OpmetingRaamDeurVleugelKrukType.rolluikkruk:
        return 'rolluikkruk';
    }
  }

  static OpmetingRaamDeurVleugelKrukType vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';

    for (final type in OpmetingRaamDeurVleugelKrukType.values) {
      if (type.name == tekst) {
        return type;
      }
    }

    return OpmetingRaamDeurVleugelKrukType.kruk;
  }
}

enum OpmetingRaamKrukZijde { links, rechts }

extension OpmetingRaamKrukZijdeInfo on OpmetingRaamKrukZijde {
  String get opslagWaarde => name;

  String get label {
    switch (this) {
      case OpmetingRaamKrukZijde.links:
        return 'Links';
      case OpmetingRaamKrukZijde.rechts:
        return 'Rechts';
    }
  }

  static OpmetingRaamKrukZijde vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';

    for (final zijde in OpmetingRaamKrukZijde.values) {
      if (zijde.name == tekst) {
        return zijde;
      }
    }

    return OpmetingRaamKrukZijde.links;
  }
}

enum OpmetingRaamDeurDraairichting { binnendraaiend, buitendraaiend }

extension OpmetingRaamDeurDraairichtingInfo on OpmetingRaamDeurDraairichting {
  String get opslagWaarde => name;

  String get label {
    switch (this) {
      case OpmetingRaamDeurDraairichting.binnendraaiend:
        return 'naar binnendraaiend';
      case OpmetingRaamDeurDraairichting.buitendraaiend:
        return 'naar buitendraaiend';
    }
  }

  static OpmetingRaamDeurDraairichting vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';

    for (final richting in OpmetingRaamDeurDraairichting.values) {
      if (richting.name == tekst) {
        return richting;
      }
    }

    return OpmetingRaamDeurDraairichting.binnendraaiend;
  }
}

enum OpmetingRaamDeurVleugelAantal { enkel, dubbel }

extension OpmetingRaamDeurVleugelAantalInfo on OpmetingRaamDeurVleugelAantal {
  String get opslagWaarde => name;

  String get label {
    switch (this) {
      case OpmetingRaamDeurVleugelAantal.enkel:
        return 'Enkele deur';
      case OpmetingRaamDeurVleugelAantal.dubbel:
        return 'Dubbele deur';
    }
  }

  static OpmetingRaamDeurVleugelAantal vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';

    for (final aantal in OpmetingRaamDeurVleugelAantal.values) {
      if (aantal.name == tekst) {
        return aantal;
      }
    }

    return OpmetingRaamDeurVleugelAantal.enkel;
  }
}

enum OpmetingRaamDeurVleugelDeel { enkel, links, rechts }

extension OpmetingRaamDeurVleugelDeelInfo on OpmetingRaamDeurVleugelDeel {
  String get opslagWaarde => name;

  static OpmetingRaamDeurVleugelDeel vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';

    for (final deel in OpmetingRaamDeurVleugelDeel.values) {
      if (deel.name == tekst) {
        return deel;
      }
    }

    return OpmetingRaamDeurVleugelDeel.enkel;
  }
}

enum OpmetingRaamDeurKrukPlaatsing { binnen, binnenEnBuiten }

extension OpmetingRaamDeurKrukPlaatsingInfo on OpmetingRaamDeurKrukPlaatsing {
  String get opslagWaarde => name;

  String get label {
    switch (this) {
      case OpmetingRaamDeurKrukPlaatsing.binnen:
        return 'kruk binnen';
      case OpmetingRaamDeurKrukPlaatsing.binnenEnBuiten:
        return 'dubbele kruk';
    }
  }

  static OpmetingRaamDeurKrukPlaatsing vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';

    for (final plaatsing in OpmetingRaamDeurKrukPlaatsing.values) {
      if (plaatsing.name == tekst) {
        return plaatsing;
      }
    }

    return OpmetingRaamDeurKrukPlaatsing.binnen;
  }
}

class OpmetingRaamVleugel {
  const OpmetingRaamVleugel({
    required this.id,
    required this.vlak,
    required this.type,
    this.isDeurVleugel = false,
    this.deurVleugelBreedteMm = 100,
    this.deurVleugelOnderAfstandMm = 5,
    this.deurVleugelSoort = OpmetingRaamDeurVleugelSoort.voordeur,
    this.deurVleugelKrukType = OpmetingRaamDeurVleugelKrukType.kruk,
    this.deurVleugelKrukZijde = OpmetingRaamKrukZijde.links,
    this.deurDraairichting = OpmetingRaamDeurDraairichting.binnendraaiend,
    this.deurVleugelAantal = OpmetingRaamDeurVleugelAantal.enkel,
    this.deurVleugelDeel = OpmetingRaamDeurVleugelDeel.enkel,
    this.deurKrukPlaatsing = OpmetingRaamDeurKrukPlaatsing.binnen,
    this.deurVleugelMiddenVerschuivingMm = 0,
    this.deurVleugelGroepId = '',
  });

  final String id;
  final Rect vlak;
  final OpmetingRaamVleugelType type;

  /// Extra markering voor een deurvleugel.
  ///
  /// Een deurvleugel gebruikt dezelfde plaatsingslogica als een gewone
  /// vleugel, maar wordt anders getekend: U-vormig, zonder onderste regel
  /// en met de stijlen tot bijna onderaan over het kader.
  final bool isDeurVleugel;

  /// Profielbreedte van de deurvleugel.
  final double deurVleugelBreedteMm;

  /// Afstand tussen onderzijde deurvleugel en onderzijde kader.
  final double deurVleugelOnderAfstandMm;

  /// Voordeur of achterdeur.
  final OpmetingRaamDeurVleugelSoort deurVleugelSoort;

  /// Gewone kruk of rolluikkruk.
  final OpmetingRaamDeurVleugelKrukType deurVleugelKrukType;

  /// Bij een enkele deur is dit de krukkant.
  /// Bij een dubbele deur is dit het actieve deurdeel met kruk.
  final OpmetingRaamKrukZijde deurVleugelKrukZijde;

  final OpmetingRaamDeurDraairichting deurDraairichting;
  final OpmetingRaamDeurVleugelAantal deurVleugelAantal;
  final OpmetingRaamDeurVleugelDeel deurVleugelDeel;
  final OpmetingRaamDeurKrukPlaatsing deurKrukPlaatsing;
  final int deurVleugelMiddenVerschuivingMm;
  final String deurVleugelGroepId;

  bool get isDubbeleDeurVleugel {
    return deurVleugelAantal == OpmetingRaamDeurVleugelAantal.dubbel;
  }

  bool get isActiefDeurdeelMetKruk {
    if (!isDubbeleDeurVleugel) {
      return true;
    }

    return (deurVleugelDeel == OpmetingRaamDeurVleugelDeel.links &&
            deurVleugelKrukZijde == OpmetingRaamKrukZijde.links) ||
        (deurVleugelDeel == OpmetingRaamDeurVleugelDeel.rechts &&
            deurVleugelKrukZijde == OpmetingRaamKrukZijde.rechts);
  }

  String get deurVleugelSamenvatting {
    final deurTekst = isDubbeleDeurVleugel ? 'Dubbele deur' : 'Enkele deur';
    final richtingTekst =
        deurDraairichting == OpmetingRaamDeurDraairichting.binnendraaiend
        ? 'naar binnen draaiend'
        : 'naar buiten draaiend';
    final krukTekst =
        deurKrukPlaatsing == OpmetingRaamDeurKrukPlaatsing.binnenEnBuiten
        ? 'dubbele ${deurVleugelKrukType.label}'
        : deurVleugelKrukType.label;

    if (isDubbeleDeurVleugel) {
      final deelTekst = deurVleugelKrukZijde == OpmetingRaamKrukZijde.links
          ? 'linkerdeel'
          : 'rechterdeel';

      return '$deurTekst $richtingTekst $krukTekst op $deelTekst';
    }

    final zijdeTekst = deurVleugelKrukZijde == OpmetingRaamKrukZijde.links
        ? 'links'
        : 'rechts';

    return '$deurTekst $richtingTekst $krukTekst $zijdeTekst';
  }

  OpmetingRaamVleugel copyWith({
    String? id,
    Rect? vlak,
    OpmetingRaamVleugelType? type,
    bool? isDeurVleugel,
    double? deurVleugelBreedteMm,
    double? deurVleugelOnderAfstandMm,
    OpmetingRaamDeurVleugelSoort? deurVleugelSoort,
    OpmetingRaamDeurVleugelKrukType? deurVleugelKrukType,
    OpmetingRaamKrukZijde? deurVleugelKrukZijde,
    OpmetingRaamDeurDraairichting? deurDraairichting,
    OpmetingRaamDeurVleugelAantal? deurVleugelAantal,
    OpmetingRaamDeurVleugelDeel? deurVleugelDeel,
    OpmetingRaamDeurKrukPlaatsing? deurKrukPlaatsing,
    int? deurVleugelMiddenVerschuivingMm,
    String? deurVleugelGroepId,
  }) {
    return OpmetingRaamVleugel(
      id: id ?? this.id,
      vlak: vlak ?? this.vlak,
      type: type ?? this.type,
      isDeurVleugel: isDeurVleugel ?? this.isDeurVleugel,
      deurVleugelBreedteMm: deurVleugelBreedteMm ?? this.deurVleugelBreedteMm,
      deurVleugelOnderAfstandMm:
          deurVleugelOnderAfstandMm ?? this.deurVleugelOnderAfstandMm,
      deurVleugelSoort: deurVleugelSoort ?? this.deurVleugelSoort,
      deurVleugelKrukType: deurVleugelKrukType ?? this.deurVleugelKrukType,
      deurVleugelKrukZijde: deurVleugelKrukZijde ?? this.deurVleugelKrukZijde,
      deurDraairichting: deurDraairichting ?? this.deurDraairichting,
      deurVleugelAantal: deurVleugelAantal ?? this.deurVleugelAantal,
      deurVleugelDeel: deurVleugelDeel ?? this.deurVleugelDeel,
      deurKrukPlaatsing: deurKrukPlaatsing ?? this.deurKrukPlaatsing,
      deurVleugelMiddenVerschuivingMm:
          deurVleugelMiddenVerschuivingMm ??
          this.deurVleugelMiddenVerschuivingMm,
      deurVleugelGroepId: deurVleugelGroepId ?? this.deurVleugelGroepId,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'vlak': _rectToJson(vlak),
      'type': type.name,
      'isDeurVleugel': isDeurVleugel,
      'deurVleugelBreedteMm': deurVleugelBreedteMm,
      'deurVleugelOnderAfstandMm': deurVleugelOnderAfstandMm,
      'deurVleugelSoort': deurVleugelSoort.opslagWaarde,
      'deurVleugelKrukType': deurVleugelKrukType.opslagWaarde,
      'deurVleugelKrukZijde': deurVleugelKrukZijde.opslagWaarde,
      'deurDraairichting': deurDraairichting.opslagWaarde,
      'deurVleugelAantal': deurVleugelAantal.opslagWaarde,
      'deurVleugelDeel': deurVleugelDeel.opslagWaarde,
      'deurKrukPlaatsing': deurKrukPlaatsing.opslagWaarde,
      'deurVleugelMiddenVerschuivingMm': deurVleugelMiddenVerschuivingMm,
      'deurVleugelGroepId': deurVleugelGroepId,
    };
  }

  factory OpmetingRaamVleugel.fromJson(Map<String, dynamic> json) {
    return OpmetingRaamVleugel(
      id: json['id']?.toString() ?? '',
      vlak: _rectFromJson(json['vlak']),
      type: OpmetingRaamVleugelTypeInfo.vanOpslagWaarde(json['type']),
      isDeurVleugel: json['isDeurVleugel'] == true,
      deurVleugelBreedteMm: _leesDouble(json['deurVleugelBreedteMm'], 100),
      deurVleugelOnderAfstandMm: _leesDouble(
        json['deurVleugelOnderAfstandMm'],
        5,
      ),
      deurVleugelSoort: OpmetingRaamDeurVleugelSoortInfo.vanOpslagWaarde(
        json['deurVleugelSoort'],
      ),
      deurVleugelKrukType: OpmetingRaamDeurVleugelKrukTypeInfo.vanOpslagWaarde(
        json['deurVleugelKrukType'],
      ),
      deurVleugelKrukZijde: OpmetingRaamKrukZijdeInfo.vanOpslagWaarde(
        json['deurVleugelKrukZijde'],
      ),
      deurDraairichting: OpmetingRaamDeurDraairichtingInfo.vanOpslagWaarde(
        json['deurDraairichting'],
      ),
      deurVleugelAantal: OpmetingRaamDeurVleugelAantalInfo.vanOpslagWaarde(
        json['deurVleugelAantal'],
      ),
      deurVleugelDeel: OpmetingRaamDeurVleugelDeelInfo.vanOpslagWaarde(
        json['deurVleugelDeel'],
      ),
      deurKrukPlaatsing: OpmetingRaamDeurKrukPlaatsingInfo.vanOpslagWaarde(
        json['deurKrukPlaatsing'],
      ),
      deurVleugelMiddenVerschuivingMm: _leesInt(
        json['deurVleugelMiddenVerschuivingMm'],
      ),
      deurVleugelGroepId: json['deurVleugelGroepId']?.toString() ?? '',
    );
  }
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

Map<String, dynamic> _offsetToJson(Offset offset) {
  return <String, dynamic>{'dx': offset.dx, 'dy': offset.dy};
}

Offset _offsetFromJson(Object? waarde) {
  if (waarde is Map) {
    return Offset(_leesDouble(waarde['dx'], 0), _leesDouble(waarde['dy'], 0));
  }

  return Offset.zero;
}

Map<String, dynamic> _rectToJson(Rect rect) {
  return <String, dynamic>{
    'left': rect.left,
    'top': rect.top,
    'right': rect.right,
    'bottom': rect.bottom,
  };
}

Rect _rectFromJson(Object? waarde) {
  if (waarde is Map) {
    return Rect.fromLTRB(
      _leesDouble(waarde['left'], 0),
      _leesDouble(waarde['top'], 0),
      _leesDouble(waarde['right'], 0),
      _leesDouble(waarde['bottom'], 0),
    );
  }

  return Rect.zero;
}

double? _leesDoubleOfNull(Object? waarde) {
  if (waarde == null) {
    return null;
  }

  if (waarde is double) {
    return waarde;
  }

  if (waarde is num) {
    return waarde.toDouble();
  }

  return double.tryParse(waarde.toString().trim().replaceAll(',', '.'));
}

double _leesDouble(Object? waarde, double standaardWaarde) {
  if (waarde is double) {
    return waarde;
  }

  if (waarde is num) {
    return waarde.toDouble();
  }

  return double.tryParse(
        waarde?.toString().trim().replaceAll(',', '.') ?? '',
      ) ??
      standaardWaarde;
}

int _leesInt(Object? waarde, {int standaardWaarde = 0}) {
  if (waarde is int) {
    return waarde;
  }

  if (waarde is num) {
    return waarde.toInt();
  }

  return int.tryParse(waarde?.toString().trim() ?? '') ?? standaardWaarde;
}
