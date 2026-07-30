// THIMACO-CONTROLE: FINALE-OPSCHONING-VOOR-VELUX-PLOOIWERKEN-20260729-1535
// THIMACO-CONTROLE: PROJECT-OPSCHONING-VOOR-VELUX-20260729-1510
// THIMACO-CONTROLE: PLOOIWERKEN-OPHANGING-VOLGENS-LEVERANCIER-20260728
import '../../fotos/opmeting_foto_model.dart';

enum OpmetingPlooiwerkenVorm { vlakkePlaat, lVorm, uVorm, zVorm, vrijeVorm }

extension OpmetingPlooiwerkenVormExtension on OpmetingPlooiwerkenVorm {
  String get label {
    switch (this) {
      case OpmetingPlooiwerkenVorm.vlakkePlaat:
        return 'Vlakke plaat';
      case OpmetingPlooiwerkenVorm.lVorm:
        return 'L';
      case OpmetingPlooiwerkenVorm.uVorm:
        return 'U';
      case OpmetingPlooiwerkenVorm.zVorm:
        return 'Z';
      case OpmetingPlooiwerkenVorm.vrijeVorm:
        return 'Vrije vorm';
    }
  }

  String get opslagWaarde => name;

  int? get vastAantalPlooien {
    switch (this) {
      case OpmetingPlooiwerkenVorm.vlakkePlaat:
        return 0;
      case OpmetingPlooiwerkenVorm.lVorm:
        return 1;
      case OpmetingPlooiwerkenVorm.uVorm:
      case OpmetingPlooiwerkenVorm.zVorm:
        return 2;
      case OpmetingPlooiwerkenVorm.vrijeVorm:
        return null;
    }
  }

  List<int> get standaardHoeken {
    switch (this) {
      case OpmetingPlooiwerkenVorm.vlakkePlaat:
        return const <int>[];
      case OpmetingPlooiwerkenVorm.lVorm:
        return const <int>[90];
      case OpmetingPlooiwerkenVorm.uVorm:
        return const <int>[90, 90];
      case OpmetingPlooiwerkenVorm.zVorm:
        return const <int>[90, 270];
      case OpmetingPlooiwerkenVorm.vrijeVorm:
        return const <int>[];
    }
  }

  static OpmetingPlooiwerkenVorm vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';

    for (final vorm in OpmetingPlooiwerkenVorm.values) {
      if (vorm.name == tekst || vorm.label == tekst) {
        return vorm;
      }
    }

    // Oudere opgeslagen Plooiwerken hadden nog geen vorm.
    // Vrije vorm behoudt hun bestaande hoeken en lengtes zonder ze te forceren.
    return OpmetingPlooiwerkenVorm.vrijeVorm;
  }
}

enum OpmetingPlooiwerkenKleursoort { brut, kleur, folie, anodise, projectKleur }

extension OpmetingPlooiwerkenKleursoortExtension
    on OpmetingPlooiwerkenKleursoort {
  String get label {
    switch (this) {
      case OpmetingPlooiwerkenKleursoort.brut:
        return 'Brut';
      case OpmetingPlooiwerkenKleursoort.kleur:
        return 'Poederlak';
      case OpmetingPlooiwerkenKleursoort.folie:
        return 'Folie (Renolit)';
      case OpmetingPlooiwerkenKleursoort.anodise:
        return 'Anodisé natuur';
      case OpmetingPlooiwerkenKleursoort.projectKleur:
        return 'Project kleur';
    }
  }

  String get opslagWaarde => name;

  bool get toontZichtzijde {
    return this != OpmetingPlooiwerkenKleursoort.brut &&
        this != OpmetingPlooiwerkenKleursoort.anodise;
  }

  static OpmetingPlooiwerkenKleursoort vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';
    final klein = tekst.toLowerCase();

    for (final soort in OpmetingPlooiwerkenKleursoort.values) {
      if (soort.name == tekst || soort.label.toLowerCase() == klein) {
        return soort;
      }
    }

    // Compatibiliteit met de eerste testversie.
    if (klein == 'kleur') {
      return OpmetingPlooiwerkenKleursoort.kleur;
    }
    if (klein == 'folie') {
      return OpmetingPlooiwerkenKleursoort.folie;
    }
    if (klein == 'anodise' || klein == 'anodisé') {
      return OpmetingPlooiwerkenKleursoort.anodise;
    }

    return OpmetingPlooiwerkenKleursoort.brut;
  }
}

enum OpmetingPlooiwerkenDikte { mm15, mm2, mm3 }

extension OpmetingPlooiwerkenDikteExtension on OpmetingPlooiwerkenDikte {
  String get label {
    switch (this) {
      case OpmetingPlooiwerkenDikte.mm15:
        return '1,5 mm';
      case OpmetingPlooiwerkenDikte.mm2:
        return '2 mm';
      case OpmetingPlooiwerkenDikte.mm3:
        return '3 mm';
    }
  }

  String get opslagWaarde => name;

  static OpmetingPlooiwerkenDikte vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';
    final klein = tekst.toLowerCase().replaceAll('.', ',');

    for (final dikte in OpmetingPlooiwerkenDikte.values) {
      if (dikte.name == tekst || dikte.label.toLowerCase() == klein) {
        return dikte;
      }
    }

    return OpmetingPlooiwerkenDikte.mm15;
  }
}

enum OpmetingPlooiwerkenLakzijde { zijde1, zijde2, beideZijden }

extension OpmetingPlooiwerkenLakzijdeExtension on OpmetingPlooiwerkenLakzijde {
  String get label {
    switch (this) {
      case OpmetingPlooiwerkenLakzijde.zijde1:
        return 'Zijde 1';
      case OpmetingPlooiwerkenLakzijde.zijde2:
        return 'Zijde 2';
      case OpmetingPlooiwerkenLakzijde.beideZijden:
        return 'Beide zijden';
    }
  }

  String get opslagWaarde => name;

  static OpmetingPlooiwerkenLakzijde vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';

    for (final lakzijde in OpmetingPlooiwerkenLakzijde.values) {
      if (lakzijde.name == tekst || lakzijde.label == tekst) {
        return lakzijde;
      }
    }

    return OpmetingPlooiwerkenLakzijde.zijde1;
  }
}

class OpmetingPlooiwerkenModel {
  const OpmetingPlooiwerkenModel({
    this.stukReferentie = '',
    this.aantal = 1,
    this.vorm = OpmetingPlooiwerkenVorm.lVorm,
    this.aantalPlooien = 1,
    this.totaleLengteMm = 0,
    this.lengtesMm = const <int?>[null, null],
    this.hoekenGraden = const <int?>[90],
    this.tekeningRotatieGraden = 0,
    this.kleursoort = OpmetingPlooiwerkenKleursoort.brut,
    this.kleurWaarde = '',
    this.folieWaarde = '',
    this.projectKleurWaarde = '',
    this.dikte = OpmetingPlooiwerkenDikte.mm15,
    this.lakzijde = OpmetingPlooiwerkenLakzijde.zijde1,
    this.soortOphanging = soortOphangingGaatjes,
    this.plaatsOphanging = plaatsOphangingKopseZijdeVooraan,
    this.notities = '',
    this.fotos = const <OpmetingFoto>[],
  });

  static const int aantalMinimum = 1;
  static const int aantalMaximum = 100;
  static const int aantalPlooienMinimum = 0;
  static const int vrijeVormAantalPlooienMinimum = 1;
  static const int aantalPlooienMaximum = 7;
  static const int totaleLengteMinimumMm = 0;
  static const int totaleLengteMaximumMm = 4000;
  static const int lengteMinimumMm = 1;
  static const int lengteMaximumMm = 100000;
  static const int hoekMinimumGraden = 0;
  static const int hoekMaximumGraden = 360;
  static const int rotatieMinimumGraden = 0;
  static const int rotatieMaximumGraden = 359;

  static const String soortOphangingGaatjes = 'Gaatjes';
  static const String soortOphangingHaakjes = 'Haakjes';
  static const String soortOphangingLasbouten = 'Lasbouten';

  static const List<String> soortOphangingKeuzes = <String>[
    soortOphangingGaatjes,
    soortOphangingHaakjes,
    soortOphangingLasbouten,
  ];

  static const String plaatsOphangingKopseZijdeVooraan =
      'Kopse zijde vooraan (vooraanzicht tekening)';
  static const String plaatsOphangingKopseZijdeAchteraan =
      'Kopse zijde achteraan';

  static const List<String> plaatsOphangingKeuzes = <String>[
    plaatsOphangingKopseZijdeVooraan,
    plaatsOphangingKopseZijdeAchteraan,
  ];

  final String stukReferentie;
  final int aantal;
  final OpmetingPlooiwerkenVorm vorm;
  final int aantalPlooien;

  /// Lengte van het plooiwerk in de langsrichting, los van de afmetingen
  /// van de getekende doorsnede.
  final int totaleLengteMm;

  final List<int?> lengtesMm;
  final List<int?> hoekenGraden;
  final int tekeningRotatieGraden;
  final OpmetingPlooiwerkenKleursoort kleursoort;
  final String kleurWaarde;
  final String folieWaarde;
  final String projectKleurWaarde;
  final OpmetingPlooiwerkenDikte dikte;
  final OpmetingPlooiwerkenLakzijde lakzijde;
  final String soortOphanging;
  final String plaatsOphanging;
  final String notities;
  final List<OpmetingFoto> fotos;

  int get aantalZijden => aantalPlooien + 1;
  bool get isVrijeVorm => vorm == OpmetingPlooiwerkenVorm.vrijeVorm;
  bool get toontZichtzijde => kleursoort.toontZichtzijde;
  bool get toonLakAanduiding => toontZichtzijde;
  bool get isProjectKleur =>
      kleursoort == OpmetingPlooiwerkenKleursoort.projectKleur;

  List<String> get beschikbarePlaatsOphangingKeuzes {
    return plaatsOphangingKeuzes;
  }

  String get kleurVoorOverzicht {
    switch (kleursoort) {
      case OpmetingPlooiwerkenKleursoort.brut:
        return 'Brut (BRUT)';
      case OpmetingPlooiwerkenKleursoort.kleur:
        return kleurWaarde.trim().isEmpty
            ? 'Kleur nog te bepalen'
            : kleurWaarde.trim();
      case OpmetingPlooiwerkenKleursoort.folie:
        return folieWaarde.trim().isEmpty
            ? 'Folie nog te bepalen'
            : folieWaarde.trim();
      case OpmetingPlooiwerkenKleursoort.anodise:
        return 'Anodisé natuur';
      case OpmetingPlooiwerkenKleursoort.projectKleur:
        return projectKleurWaarde.trim().isEmpty
            ? 'Project kleur nog te bepalen'
            : projectKleurWaarde.trim();
    }
  }

  String get afwerkingVoorOverzicht => kleurVoorOverzicht;

  List<int?> get actieveLengtesMm {
    return _normaliseerNullableIntLijst(
      bron: lengtesMm,
      lengte: aantalZijden,
      minimum: lengteMinimumMm,
      maximum: lengteMaximumMm,
    );
  }

  List<int?> get actieveHoekenGraden {
    return _normaliseerNullableIntLijst(
      bron: hoekenGraden,
      lengte: aantalPlooien,
      minimum: hoekMinimumGraden,
      maximum: hoekMaximumGraden,
    );
  }

  OpmetingPlooiwerkenModel metVorm(OpmetingPlooiwerkenVorm nieuweVorm) {
    if (nieuweVorm == vorm) return this;

    final vastAantal = nieuweVorm.vastAantalPlooien;
    if (vastAantal == null) {
      final vrijAantal = aantalPlooien
          .clamp(vrijeVormAantalPlooienMinimum, aantalPlooienMaximum)
          .toInt();
      return copyWith(
        vorm: nieuweVorm,
        aantalPlooien: vrijAantal,
        lengtesMm: _normaliseerNullableIntLijst(
          bron: lengtesMm,
          lengte: vrijAantal + 1,
          minimum: lengteMinimumMm,
          maximum: lengteMaximumMm,
        ),
        hoekenGraden: _normaliseerNullableIntLijst(
          bron: hoekenGraden,
          lengte: vrijAantal,
          minimum: hoekMinimumGraden,
          maximum: hoekMaximumGraden,
        ),
        plaatsOphanging: _normaliseerPlaatsOphanging(plaatsOphanging),
      );
    }

    final nieuweLengtes = _normaliseerNullableIntLijst(
      bron: lengtesMm,
      lengte: vastAantal + 1,
      minimum: lengteMinimumMm,
      maximum: lengteMaximumMm,
    );
    final nieuweHoeken = List<int?>.filled(vastAantal, null, growable: false);
    final standaardHoeken = nieuweVorm.standaardHoeken;
    for (var index = 0; index < vastAantal; index++) {
      nieuweHoeken[index] = index < standaardHoeken.length
          ? standaardHoeken[index]
          : null;
    }

    return copyWith(
      vorm: nieuweVorm,
      aantalPlooien: vastAantal,
      lengtesMm: List<int?>.unmodifiable(nieuweLengtes),
      hoekenGraden: List<int?>.unmodifiable(nieuweHoeken),
      plaatsOphanging: _normaliseerPlaatsOphanging(plaatsOphanging),
    );
  }

  OpmetingPlooiwerkenModel metAantalPlooien(int waarde) {
    if (!isVrijeVorm) {
      final vastAantal = vorm.vastAantalPlooien;
      return vastAantal == null || vastAantal == aantalPlooien
          ? this
          : _metAantalPlooienIntern(vastAantal);
    }

    return _metAantalPlooienIntern(waarde);
  }

  OpmetingPlooiwerkenModel _metAantalPlooienIntern(int waarde) {
    final minimum = isVrijeVorm
        ? vrijeVormAantalPlooienMinimum
        : aantalPlooienMinimum;
    final nieuwAantal = waarde.clamp(minimum, aantalPlooienMaximum).toInt();

    return copyWith(
      aantalPlooien: nieuwAantal,
      lengtesMm: _normaliseerNullableIntLijst(
        bron: lengtesMm,
        lengte: nieuwAantal + 1,
        minimum: lengteMinimumMm,
        maximum: lengteMaximumMm,
      ),
      hoekenGraden: _normaliseerNullableIntLijst(
        bron: hoekenGraden,
        lengte: nieuwAantal,
        minimum: hoekMinimumGraden,
        maximum: hoekMaximumGraden,
      ),
      plaatsOphanging: _normaliseerPlaatsOphanging(plaatsOphanging),
    );
  }

  OpmetingPlooiwerkenModel metLengteMm(int index, int? waarde) {
    if (index < 0 || index >= aantalZijden) return this;

    final nieuw = List<int?>.from(actieveLengtesMm);
    nieuw[index] = waarde?.clamp(lengteMinimumMm, lengteMaximumMm).toInt();
    return copyWith(lengtesMm: List<int?>.unmodifiable(nieuw));
  }

  OpmetingPlooiwerkenModel metHoekGraden(int index, int? waarde) {
    if (index < 0 || index >= aantalPlooien) return this;

    final nieuw = List<int?>.from(actieveHoekenGraden);
    nieuw[index] = waarde?.clamp(hoekMinimumGraden, hoekMaximumGraden).toInt();
    return copyWith(hoekenGraden: List<int?>.unmodifiable(nieuw));
  }

  OpmetingPlooiwerkenModel copyWith({
    String? stukReferentie,
    int? aantal,
    OpmetingPlooiwerkenVorm? vorm,
    int? aantalPlooien,
    int? totaleLengteMm,
    List<int?>? lengtesMm,
    List<int?>? hoekenGraden,
    int? tekeningRotatieGraden,
    OpmetingPlooiwerkenKleursoort? kleursoort,
    String? kleurWaarde,
    String? folieWaarde,
    String? projectKleurWaarde,
    OpmetingPlooiwerkenDikte? dikte,
    OpmetingPlooiwerkenLakzijde? lakzijde,
    String? soortOphanging,
    String? plaatsOphanging,
    String? notities,
    List<OpmetingFoto>? fotos,
  }) {
    return OpmetingPlooiwerkenModel(
      stukReferentie: stukReferentie ?? this.stukReferentie,
      aantal: aantal ?? this.aantal,
      vorm: vorm ?? this.vorm,
      aantalPlooien: aantalPlooien ?? this.aantalPlooien,
      totaleLengteMm: totaleLengteMm ?? this.totaleLengteMm,
      lengtesMm: lengtesMm ?? this.lengtesMm,
      hoekenGraden: hoekenGraden ?? this.hoekenGraden,
      tekeningRotatieGraden:
          tekeningRotatieGraden ?? this.tekeningRotatieGraden,
      kleursoort: kleursoort ?? this.kleursoort,
      kleurWaarde: kleurWaarde ?? this.kleurWaarde,
      folieWaarde: folieWaarde ?? this.folieWaarde,
      projectKleurWaarde: projectKleurWaarde ?? this.projectKleurWaarde,
      dikte: dikte ?? this.dikte,
      lakzijde: lakzijde ?? this.lakzijde,
      soortOphanging: soortOphanging ?? this.soortOphanging,
      plaatsOphanging: plaatsOphanging ?? this.plaatsOphanging,
      notities: notities ?? this.notities,
      fotos: fotos ?? this.fotos,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'stukReferentie': stukReferentie,
      'aantal': aantal,
      'vorm': vorm.opslagWaarde,
      'aantalPlooien': aantalPlooien,
      'totaleLengteMm': totaleLengteMm,
      'lengtesMm': actieveLengtesMm,
      'hoekenGraden': actieveHoekenGraden,
      'tekeningRotatieGraden': tekeningRotatieGraden,
      'kleursoort': kleursoort.opslagWaarde,
      'kleurWaarde': kleurWaarde,
      'folieWaarde': folieWaarde,
      'projectKleurWaarde': projectKleurWaarde,
      'dikte': dikte.opslagWaarde,
      'lakzijde': lakzijde.opslagWaarde,
      'soortOphanging': soortOphanging,
      'plaatsOphanging': plaatsOphanging,
      'notities': notities,
      'fotos': fotos.map((foto) => foto.toJson()).toList(),
    };
  }

  factory OpmetingPlooiwerkenModel.fromJson(Map<String, dynamic> json) {
    final ruweFotos = json['fotos'];
    final fotos = ruweFotos is List
        ? ruweFotos
              .whereType<Map>()
              .map(
                (foto) =>
                    OpmetingFoto.fromJson(Map<String, dynamic>.from(foto)),
              )
              .toList(growable: false)
        : const <OpmetingFoto>[];

    final vorm = OpmetingPlooiwerkenVormExtension.vanOpslagWaarde(json['vorm']);
    final ruweAantal = int.tryParse(json['aantal']?.toString() ?? '') ?? 1;
    final ruweAantalPlooien =
        int.tryParse(json['aantalPlooien']?.toString() ?? '') ??
        vorm.vastAantalPlooien ??
        vrijeVormAantalPlooienMinimum;
    final minimumPlooien = vorm == OpmetingPlooiwerkenVorm.vrijeVorm
        ? vrijeVormAantalPlooienMinimum
        : aantalPlooienMinimum;
    final aantalPlooien = (vorm.vastAantalPlooien ?? ruweAantalPlooien)
        .clamp(minimumPlooien, aantalPlooienMaximum)
        .toInt();

    final lengtes = _leesNullableIntLijst(
      json['lengtesMm'],
      lengte: aantalPlooien + 1,
      minimum: lengteMinimumMm,
      maximum: lengteMaximumMm,
    );
    final hoeken = _leesNullableIntLijst(
      json['hoekenGraden'],
      lengte: aantalPlooien,
      minimum: hoekMinimumGraden,
      maximum: hoekMaximumGraden,
    );

    final rotatie =
        int.tryParse(json['tekeningRotatieGraden']?.toString() ?? '') ?? 0;
    final totaleLengte =
        int.tryParse(json['totaleLengteMm']?.toString() ?? '') ?? 0;

    return OpmetingPlooiwerkenModel(
      stukReferentie: json['stukReferentie']?.toString() ?? '',
      aantal: ruweAantal.clamp(aantalMinimum, aantalMaximum).toInt(),
      vorm: vorm,
      aantalPlooien: aantalPlooien,
      totaleLengteMm: totaleLengte
          .clamp(totaleLengteMinimumMm, totaleLengteMaximumMm)
          .toInt(),
      lengtesMm: List<int?>.unmodifiable(lengtes),
      hoekenGraden: List<int?>.unmodifiable(hoeken),
      tekeningRotatieGraden: rotatie
          .clamp(rotatieMinimumGraden, rotatieMaximumGraden)
          .toInt(),
      kleursoort: OpmetingPlooiwerkenKleursoortExtension.vanOpslagWaarde(
        json['kleursoort'],
      ),
      kleurWaarde: json['kleurWaarde']?.toString() ?? '',
      folieWaarde: json['folieWaarde']?.toString() ?? '',
      projectKleurWaarde: json['projectKleurWaarde']?.toString() ?? '',
      dikte: OpmetingPlooiwerkenDikteExtension.vanOpslagWaarde(json['dikte']),
      lakzijde: OpmetingPlooiwerkenLakzijdeExtension.vanOpslagWaarde(
        json['lakzijde'],
      ),
      soortOphanging: _normaliseerSoortOphanging(
        json['soortOphanging']?.toString() ?? '',
      ),
      plaatsOphanging: _normaliseerPlaatsOphanging(
        json['plaatsOphanging']?.toString() ?? '',
      ),
      notities: json['notities']?.toString() ?? '',
      fotos: List<OpmetingFoto>.unmodifiable(fotos),
    );
  }

  static String _normaliseerSoortOphanging(String waarde) {
    final tekst = waarde.trim().toLowerCase();

    switch (tekst) {
      case 'gaatjes':
      case 'ophanggaatjes':
        return soortOphangingGaatjes;
      case 'haakjes':
      case 'ophanghaakjes':
        return soortOphangingHaakjes;
      case 'lasbouten':
      case 'lasbout':
        return soortOphangingLasbouten;
      default:
        return soortOphangingGaatjes;
    }
  }

  static String _normaliseerPlaatsOphanging(String waarde) {
    final tekst = waarde.trim().toLowerCase();

    if (tekst == 'kopse zijde achteraan' ||
        tekst == 'kopse zijden achteraan' ||
        tekst == 'achteraan' ||
        tekst == 'l2') {
      return plaatsOphangingKopseZijdeAchteraan;
    }

    return plaatsOphangingKopseZijdeVooraan;
  }

  static List<int?> _leesNullableIntLijst(
    Object? waarde, {
    required int lengte,
    required int minimum,
    required int maximum,
  }) {
    final bron = waarde is List
        ? waarde.map((item) => int.tryParse(item?.toString() ?? '')).toList()
        : const <int?>[];

    return _normaliseerNullableIntLijst(
      bron: bron,
      lengte: lengte,
      minimum: minimum,
      maximum: maximum,
    );
  }

  static List<int?> _normaliseerNullableIntLijst({
    required List<int?> bron,
    required int lengte,
    required int minimum,
    required int maximum,
  }) {
    final resultaat = List<int?>.filled(lengte, null, growable: false);

    for (var index = 0; index < lengte && index < bron.length; index++) {
      final waarde = bron[index];
      resultaat[index] = waarde?.clamp(minimum, maximum).toInt();
    }

    return resultaat;
  }
}
