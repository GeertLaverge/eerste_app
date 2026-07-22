import 'dart:convert';

import '../../../offerte/prijzen/offerte_artikel_prijs_data_model.dart';
import '../../../offerte/prijzen/offerte_toegepaste_prijsregel_model.dart';
import '../../../offerte/prijzen/offerte_vrije_prijs_selectie_model.dart';
import '../../fotos/opmeting_foto_model.dart';

class OpmetingVasteInzethorModel {
  OpmetingVasteInzethorModel({
    this.stukReferentie = '',
    this.aantal = 1,
    this.soort = soortVliegenraamClassic,
    this.speling = spelingVr033Inzet,
    this.flensDiepte = flensDiepte20,
    this.flensDiepteOpMaatMm = 20,
    this.maatRandFlens = maatRandFlens8,
    this.profiel = profielVr050,
    this.maatType = maatTypeBinnen,
    this.breedteMm = 800,
    this.hoogteMm = 1100,
    this.traverseType = traverseStandaard,
    this.aantalTraversenOpMaat = 1,
    this.traversePositiesOpMaatMm = const <int>[550],
    this.populaireKleur = kleurAntraciet,
    this.ralKleurToebehorenWaarde = '',
    this.poederlakKleur = '',
    this.gaas = gaasStandaard,
    this.kleurPees = peesZwart,
    this.borstels = borstelsGeen,
    this.bevestiging = bevestigingClipsenGemonteerd,
    this.soortClipsen = clipsenStandaard,
    this.soortBevestiging = '20',
    OfferteArtikelPrijsDataModel? prijsData,
    this.notities = '',
    this.fotos = const <OpmetingFoto>[],
  }) : _prijsData = prijsData ?? const OfferteArtikelPrijsDataModel();

  static const String soortVliegenraamClassic = 'Vliegenraam classic';
  static const String soortInzetvliegenraam = 'Inzetvliegenraam';

  static const String profielVr050 = 'VR050 standaard 16 mm';
  static const String profielVr060 = 'VR060 smal 11 mm';

  static const String maatTypeBinnen = 'Binnenmaten / doorkijkmaten';
  static const String maatTypeBuiten = 'Buitenmaten';

  static const String traverseStandaard = 'Standaard traversen';
  static const String traverseOpMaat = 'Traversen op maat';

  static const String kleurAntraciet = 'Antraciet (7016 - AE70017620225)';
  static const String kleurBruin = 'Bruin (8019 - AE70058805822)';
  static const String kleurZwart = 'Zwart (9005 - YN305F)';
  static const String kleurWit = 'Wit (9016 - AE80019901620)';
  static const String kleurAnodiseNatuur = 'Anodise Natuur';
  static const String kleurPoederlak = 'Poederlak';
  static const String kleurRalToebehoren = 'RAL-kleur toebehoren';

  static const String gaasStandaard = 'Standaard gaas';
  static const String gaasPetscreen = 'Petscreen';
  static const String gaasInox = 'Inox gaas';
  static const String gaasGeen = 'Geen gaas';

  // Oude constanten blijven als alias bestaan zodat andere pagina's
  // die ze nog gebruiken zonder breuk blijven compileren.
  static const String gaasStandaardClearview = gaasStandaard;
  static const String gaasPetscreenGrijs = gaasPetscreen;
  static const String gaasPetscreenZwart = gaasPetscreen;

  static const String peesZwart = 'Zwart';
  static const String peesGrijs = 'Grijs';

  static const String borstelsGeen = 'Geen borstelprofiel';
  static const String borstelsVp1200 = 'Profiel VP1200';

  static const String bevestigingClipsenZakje = 'Clipsen in zakje';
  static const String bevestigingClipsenGemonteerd = 'Clipsen gemonteerd';
  static const String bevestigingGeenClipsen = 'Geen clipsen';

  static const String clipsenStandaard = 'Standaard';
  static const String clipsenMaritiem = 'Standaard (Maritieme omgeving)';

  static const String spelingVr033Inzet = 'VR033 (inzet)';
  static const String spelingVr033Ultra = 'VR033-ultra';

  static const String flensDiepte20 = '20 mm';
  static const String flensDiepte30 = '30 mm';
  static const String flensDiepte40 = '40 mm';
  static const String flensDiepte50 = '50 mm';
  static const String flensDiepte60 = '60 mm';
  static const String flensDiepteOpMaat = 'Op maat';

  static const String maatRandFlens8 = '8 mm';
  static const String maatRandFlens11 = '11 mm';

  final String stukReferentie;
  final int aantal;
  final String soort;
  final String speling;
  final String flensDiepte;
  final int flensDiepteOpMaatMm;
  final String maatRandFlens;
  final String profiel;
  final String maatType;
  final int breedteMm;
  final int hoogteMm;
  final String traverseType;
  final int aantalTraversenOpMaat;
  final List<int> traversePositiesOpMaatMm;
  final String populaireKleur;
  final String ralKleurToebehorenWaarde;
  final String poederlakKleur;
  final String gaas;
  final String kleurPees;
  final String borstels;
  final String bevestiging;
  final String soortClipsen;
  final String soortBevestiging;
  final OfferteArtikelPrijsDataModel _prijsData;
  final String notities;
  final List<OpmetingFoto> fotos;

  /// Gemeenschappelijk prijsmodel voor generieke offertehelpers.
  ///
  /// Nieuwe dossiers bewaren de prijsgegevens uitsluitend genest in
  /// [prijsData]. Oude losse JSON-velden worden alleen nog in [fromJson]
  /// als terugval gelezen, zodat bestaande dossiers compatibel blijven.
  OfferteArtikelPrijsDataModel get prijsData => _prijsData;

  double get prijsPerStukExclBtw => _prijsData.prijsPerStukExclBtw;

  List<OfferteToegepastePrijsregelModel> get toegepasteTechnischePrijsregels =>
      _prijsData.toegepasteTechnischePrijsregels;

  String get technischePrijsSignatuur => _prijsData.technischePrijsSignatuur;

  List<OfferteToegepastePrijsregelModel> get toegepasteVerdeeldePrijsregels =>
      _prijsData.toegepasteVerdeeldePrijsregels;

  String get verdeeldePrijsSignatuur => _prijsData.verdeeldePrijsSignatuur;

  List<OfferteVrijePrijsSelectieModel> get vrijeArtikelPrijsSelecties =>
      _prijsData.vrijeArtikelPrijsSelecties;

  String get vrijeArtikelPrijsSignatuur =>
      _prijsData.vrijeArtikelPrijsSignatuur;

  double get artikelKortingPercentage => _prijsData.artikelKortingPercentage;

  double get artikelWinstmargePercentage =>
      _prijsData.artikelWinstmargePercentage;

  bool get isInzetvliegenraam => soort == soortInzetvliegenraam;
  bool get isVr033Ultra => speling == spelingVr033Ultra;
  bool get isFlensOpMaat => flensDiepte == flensDiepteOpMaat;
  bool get isBinnenmaat => maatType == maatTypeBinnen;
  bool get isTraverseOpMaat => traverseType == traverseOpMaat;
  bool get isPoederlak => populaireKleur == kleurPoederlak;
  bool get isRalKleurToebehoren => populaireKleur == kleurRalToebehoren;
  bool get heeftClipsen => bevestiging != bevestigingGeenClipsen;
  String get gaasVoorOverzicht => _normaliseerGaas(gaas);
  bool get heeftGaas => gaasVoorOverzicht != gaasGeen;

  bool get heeftArtikelKorting => artikelKortingPercentage > 0.0;
  bool get heeftArtikelWinstmarge => artikelWinstmargePercentage > 0.0;

  String get artikelKortingOmschrijving {
    final afgerond = (artikelKortingPercentage * 100.0).roundToDouble() / 100.0;
    var tekst = afgerond.toStringAsFixed(2);
    tekst = tekst.replaceFirst(RegExp(r'0+$'), '');
    tekst = tekst.replaceFirst(RegExp(r'\.$'), '');
    return 'Korting $tekst %';
  }

  String get artikelWinstmargeOmschrijving {
    final afgerond =
        (artikelWinstmargePercentage * 100.0).roundToDouble() / 100.0;
    var tekst = afgerond.toStringAsFixed(2);
    tekst = tekst.replaceFirst(RegExp(r'0+$'), '');
    tekst = tekst.replaceFirst(RegExp(r'\.$'), '');
    return 'Winstmarge $tekst %';
  }

  String get prijsBerekeningSignatuur {
    return jsonEncode(<Object?>[
      aantal,
      soort,
      speling,
      flensDiepte,
      flensDiepteOpMaatMm,
      maatRandFlens,
      profiel,
      maatType,
      breedteMm,
      hoogteMm,
      traverseType,
      aantalTraversenOpMaat,
      traversePositiesOpMaatMm,
      populaireKleur,
      ralKleurToebehorenWaarde,
      poederlakKleur,
      gaasVoorOverzicht,
      kleurPees,
      borstels,
      bevestiging,
      soortClipsen,
      soortBevestiging,
    ]);
  }

  bool get heeftActueleTechnischePrijsMomentopname {
    return technischePrijsSignatuur.isNotEmpty &&
        technischePrijsSignatuur == prijsBerekeningSignatuur;
  }

  // 16 mm en 11 mm zijn de dieptes van de hor.
  // In vooraanzicht hebben beide profielen een vaste zichtbreedte van 18 mm.
  int get profielAanzichtMm => 18;

  // De zichtbare hoogte van iedere horizontale traverse.
  int get middenBuisMm => 10;
  int get traverseAanzichtMm => middenBuisMm;

  int get breedteMinimumMm => isBinnenmaat ? 150 : 187;
  int get breedteMaximumMm => isBinnenmaat ? 2000 : 2037;
  int get hoogteMinimumMm => isBinnenmaat ? 150 : 187;
  int get hoogteMaximumMm => isBinnenmaat ? 3000 : 3037;

  String get breedteTitel => isBinnenmaat
      ? 'Breedte (binnenmaat/doorkijkmaat) 150 - 2000'
      : 'Breedte (buitenmaat) 187 - 2037';

  String get hoogteTitel => isBinnenmaat
      ? 'Hoogte (binnenmaat/doorkijkmaat) 150 - 3000'
      : 'Hoogte (buitenmaat) 187 - 3037';

  double get buitenBreedteMm =>
      isBinnenmaat ? breedteMm + (profielAanzichtMm * 2) : breedteMm.toDouble();

  double get buitenHoogteMm =>
      isBinnenmaat ? hoogteMm + (profielAanzichtMm * 2) : hoogteMm.toDouble();

  double get binnenBreedteMm => isBinnenmaat
      ? breedteMm.toDouble()
      : (breedteMm - (profielAanzichtMm * 2)).clamp(1, 100000).toDouble();

  double get binnenHoogteMm => isBinnenmaat
      ? hoogteMm.toDouble()
      : (hoogteMm - (profielAanzichtMm * 2)).clamp(1, 100000).toDouble();

  int get standaardAantalTraversen => hoogteMm > 1600 ? 2 : 1;

  List<double> get standaardTraversePositiesMm {
    if (standaardAantalTraversen == 1) {
      return <double>[hoogteMm / 2];
    }

    final deel = hoogteMm / 3;
    return <double>[deel, deel * 2];
  }

  List<double> get actieveTraversePositiesMm {
    if (!isTraverseOpMaat) {
      return standaardTraversePositiesMm;
    }

    final aantalGeldig = aantalTraversenOpMaat.clamp(1, 3);
    final posities = <double>[];

    for (var index = 0; index < aantalGeldig; index++) {
      final waarde = index < traversePositiesOpMaatMm.length
          ? traversePositiesOpMaatMm[index]
          : 0;

      if (waarde > 0 && waarde < hoogteMm) {
        posities.add(waarde.toDouble());
      }
    }

    return posities;
  }

  String get maatSamenvattingTitel =>
      isBinnenmaat ? 'Binnenmaat / doorkijkmaat' : 'Buitenmaat';

  String get maatSamenvatting => '$breedteMm × $hoogteMm mm';

  String get kleurVoorOverzicht {
    if (isPoederlak && poederlakKleur.trim().isNotEmpty) {
      return 'Poederlak · ${poederlakKleur.trim()}';
    }
    if (isRalKleurToebehoren) {
      final waarde = ralKleurToebehorenWaarde.trim();
      return waarde.isEmpty
          ? kleurRalToebehoren
          : '$kleurRalToebehoren · $waarde';
    }
    return populaireKleur;
  }

  String get flensDiepteVoorOverzicht {
    if (isFlensOpMaat) {
      return '$flensDiepteOpMaatMm mm';
    }
    return flensDiepte;
  }

  /// Vervangt het volledige gemeenschappelijke prijsmodel.
  OpmetingVasteInzethorModel copyWithPrijsData(
    OfferteArtikelPrijsDataModel prijsData,
  ) {
    return copyWith(prijsData: prijsData);
  }

  OpmetingVasteInzethorModel copyWith({
    String? stukReferentie,
    int? aantal,
    String? soort,
    String? speling,
    String? flensDiepte,
    int? flensDiepteOpMaatMm,
    String? maatRandFlens,
    String? profiel,
    String? maatType,
    int? breedteMm,
    int? hoogteMm,
    String? traverseType,
    int? aantalTraversenOpMaat,
    List<int>? traversePositiesOpMaatMm,
    String? populaireKleur,
    String? ralKleurToebehorenWaarde,
    String? poederlakKleur,
    String? gaas,
    String? kleurPees,
    String? borstels,
    String? bevestiging,
    String? soortClipsen,
    String? soortBevestiging,
    OfferteArtikelPrijsDataModel? prijsData,
    String? notities,
    List<OpmetingFoto>? fotos,
  }) {
    return OpmetingVasteInzethorModel(
      stukReferentie: stukReferentie ?? this.stukReferentie,
      aantal: aantal ?? this.aantal,
      soort: soort ?? this.soort,
      speling: speling ?? this.speling,
      flensDiepte: flensDiepte ?? this.flensDiepte,
      flensDiepteOpMaatMm: flensDiepteOpMaatMm ?? this.flensDiepteOpMaatMm,
      maatRandFlens: maatRandFlens ?? this.maatRandFlens,
      profiel: profiel ?? this.profiel,
      maatType: maatType ?? this.maatType,
      breedteMm: breedteMm ?? this.breedteMm,
      hoogteMm: hoogteMm ?? this.hoogteMm,
      traverseType: traverseType ?? this.traverseType,
      aantalTraversenOpMaat:
          aantalTraversenOpMaat ?? this.aantalTraversenOpMaat,
      traversePositiesOpMaatMm:
          traversePositiesOpMaatMm ?? this.traversePositiesOpMaatMm,
      populaireKleur: populaireKleur ?? this.populaireKleur,
      ralKleurToebehorenWaarde:
          ralKleurToebehorenWaarde ?? this.ralKleurToebehorenWaarde,
      poederlakKleur: poederlakKleur ?? this.poederlakKleur,
      gaas: gaas ?? this.gaas,
      kleurPees: kleurPees ?? this.kleurPees,
      borstels: borstels ?? this.borstels,
      bevestiging: bevestiging ?? this.bevestiging,
      soortClipsen: soortClipsen ?? this.soortClipsen,
      soortBevestiging: soortBevestiging ?? this.soortBevestiging,
      prijsData: prijsData ?? this.prijsData,
      notities: notities ?? this.notities,
      fotos: fotos ?? this.fotos,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'stukReferentie': stukReferentie,
      'aantal': aantal,
      'soort': soort,
      'speling': speling,
      'flensDiepte': flensDiepte,
      'flensDiepteOpMaatMm': flensDiepteOpMaatMm,
      'maatRandFlens': maatRandFlens,
      'profiel': profiel,
      'maatType': maatType,
      'breedteMm': breedteMm,
      'hoogteMm': hoogteMm,
      'traverseType': traverseType,
      'aantalTraversenOpMaat': aantalTraversenOpMaat,
      'traversePositiesOpMaatMm': traversePositiesOpMaatMm,
      'populaireKleur': populaireKleur,
      'ralKleurToebehorenWaarde': ralKleurToebehorenWaarde,
      'poederlakKleur': poederlakKleur,
      'gaas': gaasVoorOverzicht,
      'kleurPees': kleurPees,
      'borstels': borstels,
      'bevestiging': bevestiging,
      'soortClipsen': soortClipsen,
      'soortBevestiging': soortBevestiging,
      'prijsDataSchemaVersie': 2,
      'prijsData': prijsData.toJson(),
      'notities': notities,
      'fotos': fotos.map((foto) => foto.toJson()).toList(),
    };
  }

  factory OpmetingVasteInzethorModel.fromJson(Map<String, dynamic> json) {
    final prijsData = _leesPrijsData(json);

    return OpmetingVasteInzethorModel(
      stukReferentie: json['stukReferentie']?.toString() ?? '',
      aantal: _leesInt(json['aantal'], standaardWaarde: 1),
      soort: json['soort']?.toString() ?? soortVliegenraamClassic,
      speling: json['speling']?.toString() ?? spelingVr033Inzet,
      flensDiepte: json['flensDiepte']?.toString() ?? flensDiepte20,
      flensDiepteOpMaatMm: _leesInt(
        json['flensDiepteOpMaatMm'],
        standaardWaarde: 20,
      ),
      maatRandFlens: json['maatRandFlens']?.toString() ?? maatRandFlens8,
      profiel: json['profiel']?.toString() ?? profielVr050,
      maatType: json['maatType']?.toString() ?? maatTypeBinnen,
      breedteMm: _leesInt(json['breedteMm'], standaardWaarde: 800),
      hoogteMm: _leesInt(json['hoogteMm'], standaardWaarde: 1100),
      traverseType: json['traverseType']?.toString() ?? traverseStandaard,
      aantalTraversenOpMaat: _leesInt(
        json['aantalTraversenOpMaat'],
        standaardWaarde: 1,
      ).clamp(1, 3).toInt(),
      traversePositiesOpMaatMm: _leesIntLijst(
        json['traversePositiesOpMaatMm'],
        standaardWaarde: const <int>[550],
      ),
      populaireKleur: json['populaireKleur']?.toString() ?? kleurAntraciet,
      ralKleurToebehorenWaarde:
          json['ralKleurToebehorenWaarde']?.toString() ?? '',
      poederlakKleur: json['poederlakKleur']?.toString() ?? '',
      gaas: _normaliseerGaas(json['gaas']),
      kleurPees: json['kleurPees']?.toString() ?? peesZwart,
      borstels: json['borstels']?.toString() ?? borstelsGeen,
      bevestiging:
          json['bevestiging']?.toString() ?? bevestigingClipsenGemonteerd,
      soortClipsen: json['soortClipsen']?.toString() ?? clipsenStandaard,
      soortBevestiging: json['soortBevestiging']?.toString() ?? '20',
      prijsData: prijsData,
      notities: json['notities']?.toString() ?? '',
      fotos: _leesFotos(json['fotos']),
    );
  }

  static OfferteArtikelPrijsDataModel _leesPrijsData(
    Map<String, dynamic> json,
  ) {
    final samengevoegdePrijsData = <String, dynamic>{
      'prijsPerStukExclBtw':
          json['prijsPerStukExclBtw'] ?? json['prijsPerStuk'],
      'toegepasteTechnischePrijsregels':
          json['toegepasteTechnischePrijsregels'],
      'technischePrijsSignatuur': json['technischePrijsSignatuur'],
      'toegepasteVerdeeldePrijsregels': json['toegepasteVerdeeldePrijsregels'],
      'verdeeldePrijsSignatuur': json['verdeeldePrijsSignatuur'],
      'vrijeArtikelPrijsSelecties': json['vrijeArtikelPrijsSelecties'],
      'vrijeArtikelPrijsSignatuur': json['vrijeArtikelPrijsSignatuur'],
      'artikelKortingPercentage': json['artikelKortingPercentage'],
      'artikelWinstmargePercentage': json['artikelWinstmargePercentage'],
    };

    final genesteWaarde = json['prijsData'];

    if (genesteWaarde is Map) {
      final genestePrijsData = Map<String, dynamic>.from(genesteWaarde);

      const prijsDataSleutels = <String>[
        'prijsPerStukExclBtw',
        'toegepasteTechnischePrijsregels',
        'technischePrijsSignatuur',
        'toegepasteVerdeeldePrijsregels',
        'verdeeldePrijsSignatuur',
        'vrijeArtikelPrijsSelecties',
        'vrijeArtikelPrijsSignatuur',
        'artikelKortingPercentage',
        'artikelWinstmargePercentage',
      ];

      for (final sleutel in prijsDataSleutels) {
        if (!genestePrijsData.containsKey(sleutel)) {
          continue;
        }

        final genesteVeldwaarde = genestePrijsData[sleutel];

        if (genesteVeldwaarde != null) {
          samengevoegdePrijsData[sleutel] = genesteVeldwaarde;
        }
      }
    }

    return OfferteArtikelPrijsDataModel.fromJson(samengevoegdePrijsData);
  }

  static String _normaliseerGaas(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';
    final genormaliseerd = tekst.toLowerCase();

    switch (genormaliseerd) {
      case '':
      case 'standaard clearview':
      case 'clearview':
      case 'standaard gaas':
      case 'standaard gaas petscreen':
        return gaasStandaard;
      case 'petscreen':
      case 'petscreen grijs':
      case 'petscreen zwart':
        return gaasPetscreen;
      case 'inox':
      case 'inox gaas':
        return gaasInox;
      case 'geen':
      case 'geen gaas':
        return gaasGeen;
      default:
        return gaasStandaard;
    }
  }
}

int _leesInt(Object? waarde, {required int standaardWaarde}) {
  if (waarde is int) {
    return waarde;
  }
  if (waarde is num) {
    return waarde.toInt();
  }
  return int.tryParse(waarde?.toString().trim() ?? '') ?? standaardWaarde;
}

List<int> _leesIntLijst(Object? waarde, {required List<int> standaardWaarde}) {
  if (waarde is! List) {
    return List<int>.from(standaardWaarde);
  }

  final resultaat = waarde
      .map((item) => _leesInt(item, standaardWaarde: 0))
      .toList();

  return resultaat.isEmpty ? List<int>.from(standaardWaarde) : resultaat;
}

List<OpmetingFoto> _leesFotos(Object? waarde) {
  if (waarde is! List) {
    return const <OpmetingFoto>[];
  }

  return waarde.whereType<Map>().map((item) {
    return OpmetingFoto.fromJson(Map<String, dynamic>.from(item));
  }).toList();
}
