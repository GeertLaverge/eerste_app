import '../../fotos/opmeting_foto_model.dart';

class OpmetingVliegendeurModel {
  const OpmetingVliegendeurModel({
    this.stukReferentie = '',
    this.aantal = 1,
    this.breedteMm = 1000,
    this.hoogteMm = 2000,
    this.soort = soortDeurMetKaderClassic,
    this.traverseType = traverseStandaard,
    this.aantalTraversen = 1,
    this.doorgangHoogtesMm = const <int>[877],
    this.kleursoort = kleursoortAntraciet,
    this.poederlakKleur = '',
    this.kleurPvc = kleurPvcZwart,
    this.kaderuitvoering = kaderDrieVierde,
    this.scharnierkant = scharnierLinks,
    this.dierenluik = dierenluikGeen,
    this.schopplaat = schopplaatHoogteOpMaat,
    this.schopplaatHoogteOpMaatMm = 344,
    this.gaas = gaasStandaard,
    this.gaasOnderT1 = gaasStandaard,
    this.sluiting = sluitingMagneet,
    this.pomp = pompMet,
    this.afdekkappen = afdekkappenMet,
    this.kleurPees = kleurPeesZwart,
    this.kleurBorstel = kleurBorstelGrijs,
    this.notities = '',
    this.fotos = const <OpmetingFoto>[],
  });

  static const int breedteMinimumMm = 600;
  static const int breedteMaximumMm = 2000;
  static const int hoogteMinimumMm = 1600;
  static const int hoogteMaximumMm = 2800;
  static const int aantalMinimum = 1;
  static const int aantalMaximum = 20;
  static const int aantalTraversenMaximum = 3;

  /// Buitenste vaste zijprofielen uit de aangeleverde principetekening.
  static const int buitenStijlAanzichtMm = 17;

  /// Zichtbreedte van de boven-, zij-, onder- en smalle tussenprofielen.
  static const int deurProfielAanzichtMm = 22;

  /// Zichtbare hoogte van een brede centrale traverse.
  static const int middenregelAanzichtMm = 75;

  static const String soortDeurMetKaderClassic = 'Deur met kader Classic';
  static const String soortDeurMetSmalleKaderClassic =
      'Deur met smalle kader Classic';
  static const String soortDeurZonderKaderClassic = 'Deur zonder kader Classic';
  static const String soortDubbeleDeurMetKaderClassic =
      'Dubbele deur met kader Classic';
  static const String soortDeurMetKaderElegance = 'Deur met kader Elegance';
  static const String soortDeurZonderKaderElegance =
      'Deur zonder kader Elegance';
  static const String soortDubbeleDeurMetKaderElegance =
      'Dubbele deur met kader Elegance';
  static const String soortDeurMetKaderElegancePlus =
      'Deur met kader Elegance Plus';
  static const String soortDubbeleDeurMetKaderElegancePlus =
      'Dubbele deur met kader Elegance Plus';
  static const String soortDeurZonderKaderElegancePlus =
      'Deur zonder kader Elegance Plus';

  static const List<String> soortKeuzes = <String>[
    soortDeurMetKaderClassic,
    soortDeurMetSmalleKaderClassic,
    soortDeurZonderKaderClassic,
    soortDubbeleDeurMetKaderClassic,
    soortDeurMetKaderElegance,
    soortDeurZonderKaderElegance,
    soortDubbeleDeurMetKaderElegance,
    soortDeurMetKaderElegancePlus,
    soortDubbeleDeurMetKaderElegancePlus,
    soortDeurZonderKaderElegancePlus,
  ];

  static const String traverseStandaard = 'Standaard traversen';
  static const String traverseOpMaat = 'Traversen op maat';
  static const List<String> traverseKeuzes = <String>[
    traverseStandaard,
    traverseOpMaat,
  ];

  static const String kleursoortAntraciet = 'Antraciet (7016 - AE70017620225)';
  static const String kleursoortBruin = 'Bruin (8019 - AE70058805822)';
  static const String kleursoortZwart = 'Zwart (9005 - YN005F)';
  static const String kleursoortWit = 'Wit (9016 - AE80019901620)';
  static const String kleursoortAnodiseNatuur = 'Anodisé natuur';
  static const String kleursoortProjectKleur = 'Project kleur';
  static const String kleursoortPoederlak = 'Poederlak';
  static const String kleurNogTeBepalen = 'Kleur nog te bepalen';

  static const List<String> kleursoortKeuzes = <String>[
    kleursoortAntraciet,
    kleursoortBruin,
    kleursoortZwart,
    kleursoortWit,
    kleursoortAnodiseNatuur,
    kleursoortProjectKleur,
    kleursoortPoederlak,
  ];

  static const String kleurPvcZwart = 'Zwart';
  static const String kleurPvcWit = 'Wit';
  static const String kleurPvcBruin = 'Bruin';
  static const String kleurPvcGrijs = 'Grijs';
  static const List<String> kleurPvcKeuzes = <String>[
    kleurPvcZwart,
    kleurPvcWit,
    kleurPvcBruin,
    kleurPvcGrijs,
  ];

  static const String kaderDrieVierde = 'Kader 3/4e';
  static const String kaderRondom = 'Kader rondom';
  static const List<String> kaderuitvoeringKeuzes = <String>[
    kaderDrieVierde,
    kaderRondom,
  ];

  static const String scharnierLinks = 'Links';
  static const String scharnierRechts = 'Rechts';
  static const List<String> scharnierkantKeuzes = <String>[
    scharnierLinks,
    scharnierRechts,
  ];

  static const String dierenluikGeen = 'Geen dierenluik';
  static const String dierenluikSmall = 'Dierenluik Small';
  static const String dierenluikMedium = 'Dierenluik Medium';
  static const String dierenluikXl = 'Dierenluik XL inclusief afdekplaat.';
  static const List<String> dierenluikKeuzes = <String>[
    dierenluikGeen,
    dierenluikSmall,
    dierenluikMedium,
    dierenluikXl,
  ];

  static const String schopplaatGeen = 'Geen plaat';
  static const String schopplaat300 = '300mm';
  static const String schopplaatTotTussenstijl = 'tot tussenstijl';
  static const String schopplaatHoogteOpMaat = 'hoogte op maat';
  static const List<String> schopplaatKeuzes = <String>[
    schopplaatGeen,
    schopplaat300,
    schopplaatTotTussenstijl,
    schopplaatHoogteOpMaat,
  ];

  static const String gaasStandaard = 'Standaard';
  static const String gaasClearview = 'ClearView';
  static const String gaasPetscreenGrijs = 'Petscreen grijs';
  static const String gaasPetscreenZwart = 'Petscreen Zwart';
  static const List<String> gaasKeuzes = <String>[
    gaasStandaard,
    gaasClearview,
    gaasPetscreenGrijs,
    gaasPetscreenZwart,
  ];

  static const String sluitingMagneet = 'Magneet';
  static const String sluitingGeenMagneet = 'Geen magneet';
  static const List<String> sluitingKeuzes = <String>[
    sluitingMagneet,
    sluitingGeenMagneet,
  ];

  static const String pompGeen = 'Geen pomp';
  static const String pompMet = 'Met pomp';
  static const List<String> pompKeuzes = <String>[pompGeen, pompMet];

  static const String afdekkappenGeen = 'Geen afdekkappen';
  static const String afdekkappenMet = 'Met afdekkappen';
  static const List<String> afdekkappenKeuzes = <String>[
    afdekkappenGeen,
    afdekkappenMet,
  ];

  static const String kleurPeesZwart = 'Zwart';
  static const String kleurPeesGrijs = 'Grijs';
  static const List<String> kleurPeesKeuzes = <String>[
    kleurPeesZwart,
    kleurPeesGrijs,
  ];

  static const String kleurBorstelGrijs = 'Grijs';
  static const String kleurBorstelZwart = 'Zwart';
  static const List<String> kleurBorstelKeuzes = <String>[
    kleurBorstelGrijs,
    kleurBorstelZwart,
  ];

  final String stukReferentie;
  final int aantal;
  final int breedteMm;
  final int hoogteMm;
  final String soort;
  final String traverseType;
  final int aantalTraversen;
  final List<int> doorgangHoogtesMm;
  final String kleursoort;
  final String poederlakKleur;
  final String kleurPvc;
  final String kaderuitvoering;
  final String scharnierkant;
  final String dierenluik;
  final String schopplaat;
  final int schopplaatHoogteOpMaatMm;
  final String gaas;
  final String gaasOnderT1;
  final String sluiting;
  final String pomp;
  final String afdekkappen;
  final String kleurPees;
  final String kleurBorstel;
  final String notities;
  final List<OpmetingFoto> fotos;

  bool get isTraverseOpMaat => traverseType == traverseOpMaat;
  bool get isProjectKleur => kleursoort == kleursoortProjectKleur;
  bool get isPoederlak => kleursoort == kleursoortPoederlak;
  bool get isDubbeleDeur => soort.toLowerCase().contains('dubbele deur');
  bool get isZonderKader => soort.toLowerCase().contains('zonder kader');
  bool get isSmalleKader => soort.toLowerCase().contains('smalle kader');
  bool get heeftDierenluik => dierenluik != dierenluikGeen;
  bool get heeftSchopplaat => schopplaat != schopplaatGeen;
  bool get isSchopplaatOpMaat => schopplaat == schopplaatHoogteOpMaat;

  String get maatSamenvatting => '$breedteMm × $hoogteMm mm';

  String get kleurVoorOverzicht {
    switch (kleursoort) {
      case kleursoortAntraciet:
        return '7016-700-STOCK (AE70017620225)';
      case kleursoortBruin:
        return '8019 (AE70058805822)';
      case kleursoortZwart:
        return '9005 (YN005F)';
      case kleursoortWit:
        return '9016 (AE80019901620)';
      case kleursoortAnodiseNatuur:
        return kleursoortAnodiseNatuur;
      case kleursoortProjectKleur:
        return kleurNogTeBepalen;
      case kleursoortPoederlak:
        return poederlakKleur.trim().isEmpty
            ? kleursoortPoederlak
            : poederlakKleur.trim();
      default:
        return kleursoort;
    }
  }

  List<int> get actieveDoorgangHoogtesMm {
    final gewenstAantal = aantalTraversen.clamp(1, aantalTraversenMaximum);
    final resultaat = <int>[];

    for (var index = 0; index < gewenstAantal; index++) {
      final standaard = index == 0
          ? 877
          : ((hoogteMm - (deurProfielAanzichtMm * 2)) *
                    ((index + 1) / (gewenstAantal + 1)))
                .round();
      final waarde = index < doorgangHoogtesMm.length
          ? doorgangHoogtesMm[index]
          : standaard;
      resultaat.add(waarde.clamp(100, hoogteMm - 150).toInt());
    }

    resultaat.sort();
    return resultaat;
  }

  /// Bovenkant van de eerste brede traverse, gemeten vanaf de onderzijde.
  /// De 877 mm doorgang uit het leveranciersformulier komt zo overeen met
  /// ongeveer 992 mm in de aangeleverde principetekening.
  int get middenregelBovenkantVanafOnderMm {
    final doorgang = actieveDoorgangHoogtesMm.first;
    return (doorgang +
            deurProfielAanzichtMm +
            middenregelAanzichtMm +
            buitenStijlAanzichtMm)
        .clamp(150, hoogteMm - deurProfielAanzichtMm)
        .toInt();
  }

  int get effectieveSchopplaatHoogteMm {
    switch (schopplaat) {
      case schopplaatGeen:
        return 0;
      case schopplaat300:
        return 300;
      case schopplaatTotTussenstijl:
        return actieveDoorgangHoogtesMm.first;
      case schopplaatHoogteOpMaat:
        return schopplaatHoogteOpMaatMm;
      default:
        return 0;
    }
  }

  int get schopplaatBovenkantVanafOnderMm {
    return effectieveSchopplaatHoogteMm
        .clamp(0, middenregelBovenkantVanafOnderMm - middenregelAanzichtMm - 1)
        .toInt();
  }

  OpmetingVliegendeurModel copyWith({
    String? stukReferentie,
    int? aantal,
    int? breedteMm,
    int? hoogteMm,
    String? soort,
    String? traverseType,
    int? aantalTraversen,
    List<int>? doorgangHoogtesMm,
    String? kleursoort,
    String? poederlakKleur,
    String? kleurPvc,
    String? kaderuitvoering,
    String? scharnierkant,
    String? dierenluik,
    String? schopplaat,
    int? schopplaatHoogteOpMaatMm,
    String? gaas,
    String? gaasOnderT1,
    String? sluiting,
    String? pomp,
    String? afdekkappen,
    String? kleurPees,
    String? kleurBorstel,
    String? notities,
    List<OpmetingFoto>? fotos,
  }) {
    return OpmetingVliegendeurModel(
      stukReferentie: stukReferentie ?? this.stukReferentie,
      aantal: aantal ?? this.aantal,
      breedteMm: breedteMm ?? this.breedteMm,
      hoogteMm: hoogteMm ?? this.hoogteMm,
      soort: soort ?? this.soort,
      traverseType: traverseType ?? this.traverseType,
      aantalTraversen: aantalTraversen ?? this.aantalTraversen,
      doorgangHoogtesMm: doorgangHoogtesMm ?? this.doorgangHoogtesMm,
      kleursoort: kleursoort ?? this.kleursoort,
      poederlakKleur: poederlakKleur ?? this.poederlakKleur,
      kleurPvc: kleurPvc ?? this.kleurPvc,
      kaderuitvoering: kaderuitvoering ?? this.kaderuitvoering,
      scharnierkant: scharnierkant ?? this.scharnierkant,
      dierenluik: dierenluik ?? this.dierenluik,
      schopplaat: schopplaat ?? this.schopplaat,
      schopplaatHoogteOpMaatMm:
          schopplaatHoogteOpMaatMm ?? this.schopplaatHoogteOpMaatMm,
      gaas: gaas ?? this.gaas,
      gaasOnderT1: gaasOnderT1 ?? this.gaasOnderT1,
      sluiting: sluiting ?? this.sluiting,
      pomp: pomp ?? this.pomp,
      afdekkappen: afdekkappen ?? this.afdekkappen,
      kleurPees: kleurPees ?? this.kleurPees,
      kleurBorstel: kleurBorstel ?? this.kleurBorstel,
      notities: notities ?? this.notities,
      fotos: fotos ?? this.fotos,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'stukReferentie': stukReferentie,
      'aantal': aantal,
      'breedteMm': breedteMm,
      'hoogteMm': hoogteMm,
      'soort': soort,
      'traverseType': traverseType,
      'aantalTraversen': aantalTraversen,
      'doorgangHoogtesMm': doorgangHoogtesMm,
      'kleursoort': kleursoort,
      'poederlakKleur': poederlakKleur,
      'kleurPvc': kleurPvc,
      'kaderuitvoering': kaderuitvoering,
      'scharnierkant': scharnierkant,
      'dierenluik': dierenluik,
      'schopplaat': schopplaat,
      'schopplaatHoogteOpMaatMm': schopplaatHoogteOpMaatMm,
      'gaas': gaas,
      'gaasOnderT1': gaasOnderT1,
      'sluiting': sluiting,
      'pomp': pomp,
      'afdekkappen': afdekkappen,
      'kleurPees': kleurPees,
      'kleurBorstel': kleurBorstel,
      'notities': notities,
      'fotos': fotos.map((foto) => foto.toJson()).toList(),
    };
  }

  factory OpmetingVliegendeurModel.fromJson(Map<String, dynamic> json) {
    final oudeMiddenregel = _leesInt(
      json['middenregelBovenkantVanafOnderMm'],
      standaardWaarde: 992,
    );
    final oudeDoorgang =
        (oudeMiddenregel -
                deurProfielAanzichtMm -
                middenregelAanzichtMm -
                buitenStijlAanzichtMm)
            .clamp(100, 2500)
            .toInt();

    return OpmetingVliegendeurModel(
      stukReferentie: json['stukReferentie']?.toString() ?? '',
      aantal: _leesInt(json['aantal'], standaardWaarde: 1),
      breedteMm: _leesInt(json['breedteMm'], standaardWaarde: 1000),
      hoogteMm: _leesInt(json['hoogteMm'], standaardWaarde: 2000),
      soort: _geldigeKeuze(
        json['soort'],
        soortKeuzes,
        soortDeurMetKaderClassic,
      ),
      traverseType: _geldigeKeuze(
        json['traverseType'],
        traverseKeuzes,
        traverseStandaard,
      ),
      aantalTraversen: _leesInt(
        json['aantalTraversen'],
        standaardWaarde: 1,
      ).clamp(1, aantalTraversenMaximum).toInt(),
      doorgangHoogtesMm: _leesIntLijst(
        json['doorgangHoogtesMm'],
        standaardWaarde: <int>[oudeDoorgang],
      ),
      kleursoort: _geldigeKeuze(
        json['kleursoort'],
        kleursoortKeuzes,
        kleursoortAntraciet,
      ),
      poederlakKleur: json['poederlakKleur']?.toString() ?? '',
      kleurPvc: _geldigeKeuze(json['kleurPvc'], kleurPvcKeuzes, kleurPvcZwart),
      kaderuitvoering: _geldigeKeuze(
        json['kaderuitvoering'],
        kaderuitvoeringKeuzes,
        kaderDrieVierde,
      ),
      scharnierkant: _geldigeKeuze(
        json['scharnierkant'],
        scharnierkantKeuzes,
        scharnierLinks,
      ),
      dierenluik: _geldigeKeuze(
        json['dierenluik'],
        dierenluikKeuzes,
        dierenluikGeen,
      ),
      schopplaat: _geldigeKeuze(
        json['schopplaat'],
        schopplaatKeuzes,
        json.containsKey('schopplaat')
            ? schopplaatGeen
            : schopplaatHoogteOpMaat,
      ),
      schopplaatHoogteOpMaatMm: _leesInt(
        json['schopplaatHoogteOpMaatMm'] ??
            json['schopplaatBovenkantVanafOnderMm'],
        standaardWaarde: 344,
      ),
      gaas: _geldigeKeuze(json['gaas'], gaasKeuzes, gaasStandaard),
      gaasOnderT1: _geldigeKeuze(
        json['gaasOnderT1'],
        gaasKeuzes,
        gaasStandaard,
      ),
      sluiting: _geldigeKeuze(
        json['sluiting'],
        sluitingKeuzes,
        sluitingMagneet,
      ),
      pomp: _geldigeKeuze(json['pomp'], pompKeuzes, pompMet),
      afdekkappen: _geldigeKeuze(
        json['afdekkappen'],
        afdekkappenKeuzes,
        afdekkappenMet,
      ),
      kleurPees: _geldigeKeuze(
        json['kleurPees'],
        kleurPeesKeuzes,
        kleurPeesZwart,
      ),
      kleurBorstel: _geldigeKeuze(
        json['kleurBorstel'],
        kleurBorstelKeuzes,
        kleurBorstelGrijs,
      ),
      notities: json['notities']?.toString() ?? '',
      fotos: _leesFotos(json['fotos']),
    );
  }
}

int _leesInt(Object? waarde, {required int standaardWaarde}) {
  if (waarde is int) return waarde;
  if (waarde is num) return waarde.toInt();
  return int.tryParse(waarde?.toString().trim() ?? '') ?? standaardWaarde;
}

List<int> _leesIntLijst(Object? waarde, {required List<int> standaardWaarde}) {
  if (waarde is! List) return List<int>.from(standaardWaarde);
  final resultaat = waarde
      .map((item) => _leesInt(item, standaardWaarde: 0))
      .where((item) => item > 0)
      .toList(growable: false);
  return resultaat.isEmpty ? List<int>.from(standaardWaarde) : resultaat;
}

String _geldigeKeuze(
  Object? waarde,
  List<String> keuzes,
  String standaardWaarde,
) {
  final tekst = waarde?.toString() ?? '';
  return keuzes.contains(tekst) ? tekst : standaardWaarde;
}

List<OpmetingFoto> _leesFotos(Object? waarde) {
  if (waarde is! List) return const <OpmetingFoto>[];
  return waarde
      .whereType<Map>()
      .map((item) {
        return OpmetingFoto.fromJson(Map<String, dynamic>.from(item));
      })
      .toList(growable: false);
}
