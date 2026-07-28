// THIMACO-CONTROLE: SCHUIFVLIEGENDEUR-STANDAARDHOOGTE-2100-20260728
// THIMACO-CONTROLE: SCHUIFVLIEGENDEUR-MODEL-FASE-1-20260728
import '../../fotos/opmeting_foto_model.dart';
import 'opmeting_schuifvliegendeur_profiel_catalogus.dart';

class OpmetingSchuifvliegendeurModel {
  const OpmetingSchuifvliegendeurModel({
    this.stukReferentie = '',
    this.aantal = 1,
    this.breedteMm = 1200,
    this.hoogteMm = 2100,
    this.soort = soortClassic,
    this.kleursoort = kleursoortProjectKleur,
    this.ralKleurToebehorenWaarde = '',
    this.poederlakKleur = '',
    this.uitvoering = uitvoeringStandaard,
    this.onderrailCode =
        OpmetingSchuifvliegendeurProfielCatalogus.standaardOnderrailCode,
    this.bovenrailCode =
        OpmetingSchuifvliegendeurProfielCatalogus.standaardBovenrailCode,
    this.railLengteMm = 2400,
    this.traverseType = traverseStandaard,
    this.aantalTraversen = 1,
    this.traverseHoogtesMm = const <int>[955],
    this.kleurPees = kleurPeesZwart,
    this.stootrubbers = stootrubbersMet,
    this.kleurPvc = kleurPvcZwart,
    this.pomp = pompGeen,
    this.eindstoppen = eindstoppenMet,
    this.dierenluik = dierenluikGeen,
    this.dierenluikNotities = '',
    this.plaat = plaatGeen,
    this.plaatHoogteOpMaatMm = 0,
    this.gaas = gaasStandaard,
    this.gaasOnderT1 = gaasStandaard,
    this.borstelLinks = borstelGeen,
    this.borstelRechts = borstelGeen,
    this.notities = '',
    this.fotos = const <OpmetingFoto>[],
  });

  static const int aantalMinimum = 1;
  static const int aantalMaximum = 20;
  static const int breedteMinimumMm = 300;
  static const int breedteMaximumMm = 5600;
  static const int hoogteMinimumMm = 1500;
  static const int hoogteMaximumMm = 3100;
  static const int railLengteMinimumMm = 200;
  static const int railLengteMaximumMm = 12000;
  static const int aantalTraversenMaximum = 3;
  static const int plaatHoogteMinimumMm = 0;
  static const int plaatHoogteMaximumMm = 824;

  static const int kaderAanzichtClassicMm = 34;
  static const int kaderAanzichtSmalMm = 40;
  static const int kaderAanzichtElegancePlusMm = 34;
  static const int traverseAanzichtClassicMm = 75;
  static const int traverseAanzichtSmalMm = 90;

  static const String soortClassic = 'Schuifdeur Classic';
  static const String soortSmal = 'Schuifdeur Smal';
  static const String soortElegancePlus = 'Schuifdeur Elegance Plus';
  static const String soortClassicDubbel = 'Schuifdeur Classic dubbel';
  static const String soortSmalDubbel = 'Schuifdeur Smal dubbel';
  static const String soortElegancePlusDubbel =
      'Schuifdeur Elegance Plus dubbel';
  static const List<String> soortKeuzes = <String>[
    soortClassic,
    soortSmal,
    soortElegancePlus,
    soortClassicDubbel,
    soortSmalDubbel,
    soortElegancePlusDubbel,
  ];

  static const String kleursoortProjectKleur = 'Project kleur';
  static const String kleursoortAntraciet = 'Antraciet (7016 - AE70017620225)';
  static const String kleursoortBruin = 'Bruin (8019 - AE70058805822)';
  static const String kleursoortZwart = 'Zwart (9005 - YN305F)';
  static const String kleursoortWit = 'Wit (9016 - AE80019901620)';
  static const String kleursoortAnodiseNatuur = 'Anodisé natuur';
  static const String kleursoortPoederlak = 'Poederlak';
  static const List<String> kleursoortKeuzes = <String>[
    kleursoortProjectKleur,
    kleursoortAntraciet,
    kleursoortBruin,
    kleursoortZwart,
    kleursoortWit,
    kleursoortAnodiseNatuur,
    kleursoortPoederlak,
  ];

  static const String uitvoeringStandaard = 'Standaard';
  static const String uitvoeringGeenRails = 'Geen rails';
  static const List<String> uitvoeringKeuzes = <String>[
    uitvoeringStandaard,
    uitvoeringGeenRails,
  ];

  static const String traverseStandaard = 'Standaard traversen';
  static const String traverseOpMaat = 'Traversen op maat';
  static const List<String> traverseKeuzes = <String>[
    traverseStandaard,
    traverseOpMaat,
  ];

  static const String kleurPeesZwart = 'Zwart';
  static const String kleurPeesGrijs = 'Grijs';
  static const List<String> kleurPeesKeuzes = <String>[
    kleurPeesZwart,
    kleurPeesGrijs,
  ];

  static const String stootrubbersMet = 'Met stootrubbers';
  static const String stootrubbersZonder = 'Zonder stootrubbers';
  static const List<String> stootrubbersKeuzes = <String>[
    stootrubbersMet,
    stootrubbersZonder,
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

  static const String pompGeen = 'Geen pomp';
  static const String pompLinks = 'Links (open naar rechts)';
  static const String pompRechts = 'Rechts (open naar links)';
  static const List<String> pompKeuzes = <String>[
    pompGeen,
    pompLinks,
    pompRechts,
  ];

  static const String eindstoppenMet = 'Met eindstoppen';
  static const String eindstoppenZonder = 'Zonder eindstoppen';
  static const List<String> eindstoppenKeuzes = <String>[
    eindstoppenMet,
    eindstoppenZonder,
  ];

  static const String dierenluikGeen = 'Geen dierenluik';
  static const String dierenluikSmall = 'Dierenluik Small';
  static const String dierenluikMedium = 'Dierenluik Medium';
  static const String dierenluikXl = 'Dierenluik XL inclusief afdekplaat';
  static const List<String> dierenluikKeuzes = <String>[
    dierenluikGeen,
    dierenluikSmall,
    dierenluikMedium,
    dierenluikXl,
  ];

  static const String plaatGeen = 'Geen plaat';
  static const String plaat300 = '300 mm';
  static const String plaatTotTussenstijl = 'Tot tussenstijl';
  static const String plaatHoogteOpMaat = 'Hoogte op maat';
  static const List<String> plaatKeuzes = <String>[
    plaatGeen,
    plaat300,
    plaatTotTussenstijl,
    plaatHoogteOpMaat,
  ];

  static const String gaasStandaard = 'Standaard';
  static const String gaasClearview = 'Clearview';
  static const String gaasPetscreenGrijs = 'Petscreen grijs';
  static const String gaasPetscreenZwart = 'Petscreen zwart';
  static const String gaasInox = 'Inox gaas';
  static const String gaasGeen = 'Geen gaas';
  static const List<String> gaasKeuzes = <String>[
    gaasStandaard,
    gaasClearview,
    gaasPetscreenGrijs,
    gaasPetscreenZwart,
    gaasInox,
    gaasGeen,
  ];

  static const String borstelGeen = 'Geen borstel';
  static const String borstel5 = '5 mm';
  static const String borstel10 = '10 mm';
  static const String borstel15 = '15 mm';
  static const String borstel20 = '20 mm';
  static const List<String> borstelKeuzes = <String>[
    borstelGeen,
    borstel5,
    borstel10,
    borstel15,
    borstel20,
  ];

  final String stukReferentie;
  final int aantal;
  final int breedteMm;
  final int hoogteMm;
  final String soort;
  final String kleursoort;
  final String ralKleurToebehorenWaarde;
  final String poederlakKleur;
  final String uitvoering;
  final String onderrailCode;
  final String bovenrailCode;
  final int railLengteMm;
  final String traverseType;
  final int aantalTraversen;
  final List<int> traverseHoogtesMm;
  final String kleurPees;
  final String stootrubbers;
  final String kleurPvc;
  final String pomp;
  final String eindstoppen;
  final String dierenluik;
  final String dierenluikNotities;
  final String plaat;
  final int plaatHoogteOpMaatMm;
  final String gaas;
  final String gaasOnderT1;
  final String borstelLinks;
  final String borstelRechts;
  final String notities;
  final List<OpmetingFoto> fotos;

  bool get isDubbel => soort.toLowerCase().contains('dubbel');
  bool get isSmal => soort == soortSmal || soort == soortSmalDubbel;
  bool get isElegancePlus {
    return soort == soortElegancePlus || soort == soortElegancePlusDubbel;
  }

  bool get isClassic => !isSmal && !isElegancePlus;
  bool get heeftRails => uitvoering != uitvoeringGeenRails;
  bool get heeftTraversen => !isElegancePlus && aantalTraversen > 0;
  bool get isTraverseOpMaat => traverseType == traverseOpMaat;
  bool get gebruiktProjectKleur => kleursoort == kleursoortProjectKleur;
  bool get isPoederlak => kleursoort == kleursoortPoederlak;
  bool get heeftDierenluik => dierenluik != dierenluikGeen;
  bool get heeftPlaat => plaat != plaatGeen;
  bool get isPlaatOpMaat => plaat == plaatHoogteOpMaat;
  bool get isPlaatTotTussenstijl => plaat == plaatTotTussenstijl;

  int get kaderAanzichtMm {
    if (isSmal) return kaderAanzichtSmalMm;
    if (isElegancePlus) return kaderAanzichtElegancePlusMm;
    return kaderAanzichtClassicMm;
  }

  int get traverseAanzichtMm {
    if (isElegancePlus) return 0;
    return isSmal ? traverseAanzichtSmalMm : traverseAanzichtClassicMm;
  }

  String get maatSamenvatting => '$breedteMm × $hoogteMm mm';

  String get kleurVoorOverzicht {
    switch (kleursoort) {
      case kleursoortProjectKleur:
        return ralKleurToebehorenWaarde.trim().isEmpty
            ? 'Kleur nog te bepalen'
            : ralKleurToebehorenWaarde.trim();
      case kleursoortAntraciet:
        return '7016-70D-STOCK (AE70017620225)';
      case kleursoortBruin:
        return '8019 (AE70058805822)';
      case kleursoortZwart:
        return '9005 (YN305F)';
      case kleursoortWit:
        return '9016 (AE80019901620)';
      case kleursoortAnodiseNatuur:
        return kleursoortAnodiseNatuur;
      case kleursoortPoederlak:
        return poederlakKleur.trim().isEmpty
            ? kleursoortPoederlak
            : poederlakKleur.trim();
      default:
        return kleursoort;
    }
  }

  List<int> get actieveTraverseHoogtesMm {
    if (!heeftTraversen) return const <int>[];

    final gewenstAantal = isTraverseOpMaat
        ? aantalTraversen.clamp(1, aantalTraversenMaximum).toInt()
        : 1;
    final resultaat = <int>[];

    for (var index = 0; index < gewenstAantal; index++) {
      final standaard = index == 0
          ? 955
          : ((hoogteMm * (index + 1)) / (gewenstAantal + 1)).round();
      final invoer = index < traverseHoogtesMm.length
          ? traverseHoogtesMm[index]
          : standaard;
      resultaat.add(invoer.clamp(100, hoogteMm - 100).toInt());
    }

    resultaat.sort();
    return resultaat;
  }

  int get effectievePlaatHoogteMm {
    switch (plaat) {
      case plaatGeen:
        return 0;
      case plaat300:
        return 300;
      case plaatTotTussenstijl:
        return actieveTraverseHoogtesMm.isEmpty
            ? 0
            : actieveTraverseHoogtesMm.first;
      case plaatHoogteOpMaat:
        return plaatHoogteOpMaatMm
            .clamp(plaatHoogteMinimumMm, plaatHoogteMaximumMm)
            .toInt();
      default:
        return 0;
    }
  }

  OpmetingSchuifvliegendeurModel copyWith({
    String? stukReferentie,
    int? aantal,
    int? breedteMm,
    int? hoogteMm,
    String? soort,
    String? kleursoort,
    String? ralKleurToebehorenWaarde,
    String? poederlakKleur,
    String? uitvoering,
    String? onderrailCode,
    String? bovenrailCode,
    int? railLengteMm,
    String? traverseType,
    int? aantalTraversen,
    List<int>? traverseHoogtesMm,
    String? kleurPees,
    String? stootrubbers,
    String? kleurPvc,
    String? pomp,
    String? eindstoppen,
    String? dierenluik,
    String? dierenluikNotities,
    String? plaat,
    int? plaatHoogteOpMaatMm,
    String? gaas,
    String? gaasOnderT1,
    String? borstelLinks,
    String? borstelRechts,
    String? notities,
    List<OpmetingFoto>? fotos,
  }) {
    return OpmetingSchuifvliegendeurModel(
      stukReferentie: stukReferentie ?? this.stukReferentie,
      aantal: aantal ?? this.aantal,
      breedteMm: breedteMm ?? this.breedteMm,
      hoogteMm: hoogteMm ?? this.hoogteMm,
      soort: soort ?? this.soort,
      kleursoort: kleursoort ?? this.kleursoort,
      ralKleurToebehorenWaarde:
          ralKleurToebehorenWaarde ?? this.ralKleurToebehorenWaarde,
      poederlakKleur: poederlakKleur ?? this.poederlakKleur,
      uitvoering: uitvoering ?? this.uitvoering,
      onderrailCode: onderrailCode ?? this.onderrailCode,
      bovenrailCode: bovenrailCode ?? this.bovenrailCode,
      railLengteMm: railLengteMm ?? this.railLengteMm,
      traverseType: traverseType ?? this.traverseType,
      aantalTraversen: aantalTraversen ?? this.aantalTraversen,
      traverseHoogtesMm: traverseHoogtesMm ?? this.traverseHoogtesMm,
      kleurPees: kleurPees ?? this.kleurPees,
      stootrubbers: stootrubbers ?? this.stootrubbers,
      kleurPvc: kleurPvc ?? this.kleurPvc,
      pomp: pomp ?? this.pomp,
      eindstoppen: eindstoppen ?? this.eindstoppen,
      dierenluik: dierenluik ?? this.dierenluik,
      dierenluikNotities: dierenluikNotities ?? this.dierenluikNotities,
      plaat: plaat ?? this.plaat,
      plaatHoogteOpMaatMm: plaatHoogteOpMaatMm ?? this.plaatHoogteOpMaatMm,
      gaas: gaas ?? this.gaas,
      gaasOnderT1: gaasOnderT1 ?? this.gaasOnderT1,
      borstelLinks: borstelLinks ?? this.borstelLinks,
      borstelRechts: borstelRechts ?? this.borstelRechts,
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
      'kleursoort': kleursoort,
      'ralKleurToebehorenWaarde': ralKleurToebehorenWaarde,
      'poederlakKleur': poederlakKleur,
      'uitvoering': uitvoering,
      'onderrailCode': onderrailCode,
      'bovenrailCode': bovenrailCode,
      'railLengteMm': railLengteMm,
      'traverseType': traverseType,
      'aantalTraversen': aantalTraversen,
      'traverseHoogtesMm': traverseHoogtesMm,
      'kleurPees': kleurPees,
      'stootrubbers': stootrubbers,
      'kleurPvc': kleurPvc,
      'pomp': pomp,
      'eindstoppen': eindstoppen,
      'dierenluik': dierenluik,
      'dierenluikNotities': dierenluikNotities,
      'plaat': plaat,
      'plaatHoogteOpMaatMm': plaatHoogteOpMaatMm,
      'gaas': gaas,
      'gaasOnderT1': gaasOnderT1,
      'borstelLinks': borstelLinks,
      'borstelRechts': borstelRechts,
      'notities': notities,
      'fotos': fotos.map((foto) => foto.toJson()).toList(),
    };
  }

  factory OpmetingSchuifvliegendeurModel.fromJson(Map<String, dynamic> json) {
    final soort = _geldigeKeuze(json['soort'], soortKeuzes, soortClassic);
    final isElegance =
        soort == soortElegancePlus || soort == soortElegancePlusDubbel;
    final ruweOnderrail = json['onderrailCode']?.toString() ?? '';
    final ruweBovenrail = json['bovenrailCode']?.toString() ?? '';

    return OpmetingSchuifvliegendeurModel(
      stukReferentie: json['stukReferentie']?.toString() ?? '',
      aantal: _leesInt(
        json['aantal'],
        standaardWaarde: 1,
      ).clamp(aantalMinimum, aantalMaximum).toInt(),
      breedteMm: _leesInt(
        json['breedteMm'],
        standaardWaarde: 1200,
      ).clamp(breedteMinimumMm, breedteMaximumMm).toInt(),
      hoogteMm: _leesInt(
        json['hoogteMm'],
        standaardWaarde: 2100,
      ).clamp(hoogteMinimumMm, hoogteMaximumMm).toInt(),
      soort: soort,
      kleursoort: _geldigeKeuze(
        json['kleursoort'],
        kleursoortKeuzes,
        kleursoortProjectKleur,
      ),
      ralKleurToebehorenWaarde:
          json['ralKleurToebehorenWaarde']?.toString() ?? '',
      poederlakKleur: json['poederlakKleur']?.toString() ?? '',
      uitvoering: _geldigeKeuze(
        json['uitvoering'],
        uitvoeringKeuzes,
        uitvoeringStandaard,
      ),
      onderrailCode:
          OpmetingSchuifvliegendeurProfielCatalogus.isGeldigeOnderrail(
            ruweOnderrail,
          )
          ? ruweOnderrail
          : OpmetingSchuifvliegendeurProfielCatalogus.standaardOnderrailCode,
      bovenrailCode:
          OpmetingSchuifvliegendeurProfielCatalogus.isGeldigeBovenrail(
            ruweBovenrail,
          )
          ? ruweBovenrail
          : OpmetingSchuifvliegendeurProfielCatalogus.standaardBovenrailCode,
      railLengteMm: _leesInt(
        json['railLengteMm'],
        standaardWaarde: 2400,
      ).clamp(railLengteMinimumMm, railLengteMaximumMm).toInt(),
      traverseType: _geldigeKeuze(
        json['traverseType'],
        traverseKeuzes,
        traverseStandaard,
      ),
      aantalTraversen: isElegance
          ? 0
          : _leesInt(
              json['aantalTraversen'],
              standaardWaarde: 1,
            ).clamp(1, aantalTraversenMaximum).toInt(),
      traverseHoogtesMm: isElegance
          ? const <int>[]
          : _leesIntLijst(
              json['traverseHoogtesMm'] ?? json['doorgangHoogtesMm'],
              standaardWaarde: const <int>[955],
            ),
      kleurPees: _geldigeKeuze(
        json['kleurPees'],
        kleurPeesKeuzes,
        kleurPeesZwart,
      ),
      stootrubbers: _geldigeKeuze(
        json['stootrubbers'],
        stootrubbersKeuzes,
        stootrubbersMet,
      ),
      kleurPvc: _geldigeKeuze(json['kleurPvc'], kleurPvcKeuzes, kleurPvcZwart),
      pomp: _geldigeKeuze(json['pomp'], pompKeuzes, pompGeen),
      eindstoppen: _geldigeKeuze(
        json['eindstoppen'],
        eindstoppenKeuzes,
        eindstoppenMet,
      ),
      dierenluik: _geldigeKeuze(
        json['dierenluik'],
        dierenluikKeuzes,
        dierenluikGeen,
      ),
      dierenluikNotities: json['dierenluikNotities']?.toString() ?? '',
      plaat: _geldigeKeuze(json['plaat'], plaatKeuzes, plaatGeen),
      plaatHoogteOpMaatMm: _leesInt(
        json['plaatHoogteOpMaatMm'],
        standaardWaarde: 0,
      ).clamp(plaatHoogteMinimumMm, plaatHoogteMaximumMm).toInt(),
      gaas: _geldigeKeuze(json['gaas'], gaasKeuzes, gaasStandaard),
      gaasOnderT1: _geldigeKeuze(
        json['gaasOnderT1'],
        gaasKeuzes,
        gaasStandaard,
      ),
      borstelLinks: _geldigeKeuze(
        json['borstelLinks'],
        borstelKeuzes,
        borstelGeen,
      ),
      borstelRechts: _geldigeKeuze(
        json['borstelRechts'],
        borstelKeuzes,
        borstelGeen,
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
