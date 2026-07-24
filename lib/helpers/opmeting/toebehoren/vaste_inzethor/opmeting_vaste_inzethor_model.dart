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
    this.hoogteOndersteKaderMm = 500,
    this.spelingKeuze = spelingStandaard,
    this.technischeUitbreidingActief = true,
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
  static const String soortVliegenraamDubbel = 'Vliegenraam Dubbel';
  static const String soortInzetvliegenraam = 'Inzetvliegenraam';
  static const String soortVliegenraamRv = 'Vliegenraam RV';

  static const String profielVr050 = 'VR050 standaard 16 mm';
  static const String profielVr054 = 'VR054 (doorvalbeveiliging)';
  static const String profielVr060 = 'VR060 smal 11 mm';
  static const String profielVr061 = 'VR061 (RV)';
  static const String profielVr080 = 'VR080 (breed)';
  static const String profielVr090 = 'VR090 (extra breed)';

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

  /// Bestaande opslagwaarde. In de gebruikersinterface wordt dit als
  /// "Projectkleur" weergegeven, zodat oude dossiers compatibel blijven.
  static const String kleurRalToebehoren = 'RAL-kleur toebehoren';
  static const String kleurProjectLabel = 'Projectkleur';

  static const String gaasStandaard = 'Standaard gaas';
  static const String gaasClearview = 'ClearView';

  /// Oude algemene Petscreen-waarde blijft leesbaar voor bestaande dossiers.
  /// Nieuwe keuzes kunnen grijs en zwart afzonderlijk bewaren.
  static const String gaasPetscreen = 'Petscreen';
  static const String gaasPetscreenGrijs = 'Petscreen grijs';
  static const String gaasPetscreenZwart = 'Petscreen zwart';
  static const String gaasInox = 'Inox gaas';
  static const String gaasGeen = 'Geen gaas';

  /// Historische constantenaam blijft bestaan voor bestaande aanroepen.
  static const String gaasStandaardClearview = gaasClearview;

  static const String peesZwart = 'Zwart';
  static const String peesGrijs = 'Grijs';

  static const String borstelsGeen = 'Geen borstelprofiel';
  static const String borstelsVp1200 = 'Profiel VP1200';

  static const String bevestigingClipsenZakje = 'Clipsen in zakje';
  static const String bevestigingClipsenGemonteerd = 'Clipsen gemonteerd';
  static const String bevestigingGeenClipsen = 'Geen clipsen';

  static const String clipsenStandaard = 'Standaard';
  static const String clipsenStaallook = 'Staallook';
  static const String clipsenStandaardMaritiem =
      'Standaard (Maritieme omgeving)';
  static const String clipsenStaallookMaritiem =
      'Staallook (Maritieme omgeving)';

  /// Historische naam blijft behouden voor bestaande code en dossiers.
  static const String clipsenMaritiem = clipsenStandaardMaritiem;

  /// De bestaande JSON-sleutel `speling` bewaart historisch de profielkeuze
  /// van het inzetvliegenraam. Die opslag blijft ongewijzigd.
  static const String spelingVr033Inzet = 'VR033 (inzet)';
  static const String spelingVr033Ultra = 'VR033-ultra';

  static const String profielVr033Inzet = spelingVr033Inzet;
  static const String profielVr033Ultra = spelingVr033Ultra;

  static const String spelingStandaard = 'Standaard speling';
  static const String spelingGeen = 'Geen speling';
  static const int standaardSpelingBreedteMm = 4;
  static const int standaardSpelingHoogteMm = 5;

  static const String flensDiepte20 = '20 mm';
  static const String flensDiepte30 = '30 mm';
  static const String flensDiepte40 = '40 mm';
  static const String flensDiepte50 = '50 mm';
  static const String flensDiepte60 = '60 mm';
  static const String flensDiepteOpMaat = 'Op maat';

  static const String maatRandFlens8 = '8 mm';
  static const String maatRandFlens11 = '11 mm';

  /// Centrale keuzelijsten voor de moderne rechterkolom.
  /// Nieuwe productsoorten en profielen die eigen teken- of maatlogica vereisen,
  /// zijn bewust niet opgenomen.
  static const List<String> soortOpties = <String>[
    soortVliegenraamClassic,
    soortVliegenraamDubbel,
    soortInzetvliegenraam,
    soortVliegenraamRv,
  ];

  static const List<String> profielOpties = <String>[
    profielVr050,
    profielVr054,
    profielVr060,
    profielVr080,
    profielVr090,
  ];

  static const List<String> profielOptiesDubbel = <String>[
    profielVr050,
    profielVr060,
  ];

  static const List<String> profielOptiesRv = <String>[profielVr061];

  static const List<String> inzetProfielOpties = <String>[
    profielVr033Inzet,
    profielVr033Ultra,
  ];

  static const List<String> spelingKeuzeOpties = <String>[
    spelingStandaard,
    spelingGeen,
  ];

  static const List<String> flensDiepteOpties = <String>[
    flensDiepte20,
    flensDiepte30,
    flensDiepte40,
    flensDiepte50,
    flensDiepte60,
    flensDiepteOpMaat,
  ];

  static const List<String> maatTypeOpties = <String>[
    maatTypeBinnen,
    maatTypeBuiten,
  ];

  static const List<String> traverseTypeOpties = <String>[
    traverseStandaard,
    traverseOpMaat,
  ];

  static const List<String> kleurOpties = <String>[
    kleurAntraciet,
    kleurBruin,
    kleurZwart,
    kleurWit,
    kleurAnodiseNatuur,
    kleurPoederlak,
    kleurRalToebehoren,
  ];

  static const List<String> gaasOpties = <String>[
    gaasStandaard,
    gaasClearview,
    gaasPetscreenGrijs,
    gaasPetscreenZwart,
    gaasInox,
    gaasGeen,
  ];

  static const List<String> kleurPeesOpties = <String>[peesZwart, peesGrijs];

  static const List<String> borstelOpties = <String>[
    borstelsGeen,
    borstelsVp1200,
  ];

  static const List<String> bevestigingOpties = <String>[
    bevestigingClipsenZakje,
    bevestigingClipsenGemonteerd,
    bevestigingGeenClipsen,
  ];

  static const List<String> soortClipsenOpties = <String>[
    clipsenStandaard,
    clipsenStaallook,
    clipsenStandaardMaritiem,
    clipsenStaallookMaritiem,
  ];

  /// De interne waarden "5 extra" en "7 extra" blijven ongewijzigd voor
  /// bestaande JSON-opslag. [soortBevestigingLabel] toont er een plus bij.
  static const List<String> soortBevestigingOpties = <String>[
    '4',
    '5',
    '5 extra',
    '6',
    '7',
    '7 extra',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
  ];

  static const List<String> bevestigingOptiesRv = <String>[
    bevestigingClipsenZakje,
    bevestigingGeenClipsen,
  ];

  static const List<String> soortClipsenOptiesRv = <String>[
    clipsenStandaard,
    clipsenStandaardMaritiem,
  ];

  static const List<String> soortBevestigingOptiesRv = <String>[
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
    '29',
    '30',
    '31',
    '32',
    '33',
    '34',
    '35',
    '36',
    '37',
  ];

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

  /// L5: binnenmaat/doorkijkmaat van het volledige onderste vliegenraam.
  /// Dit nieuwe veld wordt aanvullend opgeslagen zonder bestaande JSON-sleutels
  /// te wijzigen.
  final int hoogteOndersteKaderMm;

  /// Werkelijke spelingkeuze voor VR033 (inzet). De historische veldnaam
  /// [speling] blijft de inzet-profielkeuze bewaren.
  final String spelingKeuze;

  /// Houdt oude dossiers op hun bestaande prijssignatuur totdat een keuze in
  /// de uitgebreide fiche werkelijk wordt gewijzigd.
  final bool technischeUitbreidingActief;

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

  bool get isVliegenraamClassic => soort == soortVliegenraamClassic;
  bool get isVliegenraamDubbel => soort == soortVliegenraamDubbel;
  bool get isInzetvliegenraam => soort == soortInzetvliegenraam;
  bool get isVliegenraamRv => soort == soortVliegenraamRv;
  bool get isVr033Inzet => speling == spelingVr033Inzet;
  bool get isVr033Ultra => speling == spelingVr033Ultra;
  bool get isFlensOpMaat => flensDiepte == flensDiepteOpMaat;

  bool get magBuitenmaatKiezen {
    return isVliegenraamClassic && profiel != profielVr054;
  }

  bool get isBinnenmaat => !magBuitenmaatKiezen || maatType == maatTypeBinnen;
  bool get heeftStandaardSpeling {
    return isInzetvliegenraam &&
        isVr033Inzet &&
        spelingKeuze == spelingStandaard;
  }

  bool get heeftGeenSpeling {
    return isInzetvliegenraam && (isVr033Ultra || spelingKeuze == spelingGeen);
  }

  bool get isTraverseOpMaat => traverseType == traverseOpMaat;
  bool get isPoederlak => populaireKleur == kleurPoederlak;

  /// Historische getter blijft bestaan. De zichtbare benaming is Projectkleur.
  bool get isRalKleurToebehoren => populaireKleur == kleurRalToebehoren;
  bool get isProjectkleur => isRalKleurToebehoren;

  bool get heeftClipsen => bevestiging != bevestigingGeenClipsen;

  List<String> get profielOptiesVoorSoort {
    if (isVliegenraamDubbel) {
      return profielOptiesDubbel;
    }
    if (isVliegenraamRv) {
      return profielOptiesRv;
    }
    return profielOpties;
  }

  List<String> get maatTypeOptiesVoorProduct {
    return magBuitenmaatKiezen
        ? maatTypeOpties
        : const <String>[maatTypeBinnen];
  }

  List<String> get bevestigingOptiesVoorProduct {
    return isVliegenraamRv ? bevestigingOptiesRv : bevestigingOpties;
  }

  List<String> get soortClipsenOptiesVoorProduct {
    return isVliegenraamRv ? soortClipsenOptiesRv : soortClipsenOpties;
  }

  List<String> get soortBevestigingOptiesVoorProduct {
    return isVliegenraamRv ? soortBevestigingOptiesRv : soortBevestigingOpties;
  }

  String get gaasVoorOverzicht => _normaliseerGaas(gaas);
  String get gaasVoorWeergave => gaasLabel(gaasVoorOverzicht);
  bool get heeftGaas => gaasVoorOverzicht != gaasGeen;
  bool get isGaasStandaard => gaasVoorOverzicht == gaasStandaard;
  bool get isGaasClearview => gaasVoorOverzicht == gaasClearview;
  bool get isGaasPetscreen =>
      gaasVoorOverzicht == gaasPetscreen ||
      gaasVoorOverzicht == gaasPetscreenGrijs ||
      gaasVoorOverzicht == gaasPetscreenZwart;
  bool get isGaasPetscreenGrijs => gaasVoorOverzicht == gaasPetscreenGrijs;
  bool get isGaasPetscreenZwart => gaasVoorOverzicht == gaasPetscreenZwart;
  bool get isGaasInox => gaasVoorOverzicht == gaasInox;

  String get soortVoorWeergave => soortLabel(soort);
  String get profielVoorWeergave =>
      isInzetvliegenraam ? inzetProfielVoorWeergave : profielLabel(profiel);
  String get populaireKleurVoorWeergave => kleurLabel(populaireKleur);
  String get soortBevestigingVoorWeergave =>
      soortBevestigingLabel(soortBevestiging);

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
    final waarden = <Object?>[
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
      gesynchroniseerdeTraversePositiesOpMaatMm,
      populaireKleur,
      ralKleurToebehorenWaarde,
      poederlakKleur,
      gaasVoorOverzicht,
      kleurPees,
      borstels,
      bevestiging,
      soortClipsen,
      soortBevestiging,
    ];

    if (technischeUitbreidingActief) {
      waarden
        ..add(hoogteOndersteKaderMm)
        ..add(spelingKeuze);
    }

    return jsonEncode(waarden);
  }

  bool get heeftActueleTechnischePrijsMomentopname {
    return technischePrijsSignatuur.isNotEmpty &&
        technischePrijsSignatuur == prijsBerekeningSignatuur;
  }

  // 16 mm en 11 mm zijn de dieptes van de hor.
  // In vooraanzicht behouden de bestaande profielen een vaste zichtbreedte.
  int get profielAanzichtMm => 18;

  // De zichtbare hoogte van iedere horizontale traverse.
  int get middenBuisMm => 10;
  int get traverseAanzichtMm => middenBuisMm;

  int get flensUitsteekMm => isInzetvliegenraam && isVr033Inzet ? 5 : 0;

  int get spelingBreedteMm =>
      heeftStandaardSpeling ? standaardSpelingBreedteMm : 0;

  int get spelingHoogteMm =>
      heeftStandaardSpeling ? standaardSpelingHoogteMm : 0;

  int get breedteMinimumMm => isBinnenmaat ? 150 : 187;
  int get breedteMaximumMm => isBinnenmaat ? 2000 : 2037;
  int get hoogteMinimumMm => isBinnenmaat ? 150 : 187;
  int get hoogteMaximumMm => isBinnenmaat ? 3000 : 3037;

  int get hoogteOndersteKaderMinimumMm => 200;
  int get hoogteOndersteKaderMaximumMm => 800;

  String get breedteTitel => isBinnenmaat
      ? 'Breedte (binnenmaat/doorkijkmaat) 150 - 2000'
      : 'Breedte (buitenmaat) 187 - 2037';

  String get hoogteTitel {
    if (isVliegenraamDubbel) {
      return 'H · Hoogte hoofdraam (binnenmaat/doorkijkmaat) 150 - 3000';
    }
    return isBinnenmaat
        ? 'Hoogte (binnenmaat/doorkijkmaat) 150 - 3000'
        : 'Hoogte (buitenmaat) 187 - 3037';
  }

  String get hoogteOndersteKaderTitel => 'L5 · Hoogte onderste kader 200 - 800';

  double get kaderBinnenBreedteMm {
    final maat = isBinnenmaat
        ? breedteMm - spelingBreedteMm
        : breedteMm - (profielAanzichtMm * 2);
    return maat.clamp(1, 100000).toDouble();
  }

  double get hoofdKaderBinnenHoogteMm {
    final maat = isBinnenmaat
        ? hoogteMm - spelingHoogteMm
        : hoogteMm - (profielAanzichtMm * 2);
    return maat.clamp(1, 100000).toDouble();
  }

  double get ondersteKaderBinnenHoogteMm =>
      hoogteOndersteKaderMm.clamp(1, 100000).toDouble();

  double get kaderBuitenBreedteMm => isBinnenmaat
      ? kaderBinnenBreedteMm + (profielAanzichtMm * 2)
      : breedteMm.toDouble();

  double get hoofdKaderBuitenHoogteMm => isBinnenmaat
      ? hoofdKaderBinnenHoogteMm + (profielAanzichtMm * 2)
      : hoogteMm.toDouble();

  double get ondersteKaderBuitenHoogteMm =>
      ondersteKaderBinnenHoogteMm + (profielAanzichtMm * 2);

  double get buitenBreedteMm => kaderBuitenBreedteMm + (flensUitsteekMm * 2);

  double get buitenHoogteMm {
    final kaderHoogte = isVliegenraamDubbel
        ? hoofdKaderBuitenHoogteMm + ondersteKaderBuitenHoogteMm
        : hoofdKaderBuitenHoogteMm;
    return kaderHoogte + (flensUitsteekMm * 2);
  }

  double get binnenBreedteMm => isBinnenmaat
      ? breedteMm.toDouble()
      : (breedteMm - (profielAanzichtMm * 2)).clamp(1, 100000).toDouble();

  double get binnenHoogteMm {
    if (isVliegenraamDubbel) {
      return (hoogteMm + hoogteOndersteKaderMm).toDouble();
    }
    if (isBinnenmaat) {
      return hoogteMm.toDouble();
    }
    return (hoogteMm - (profielAanzichtMm * 2)).clamp(1, 100000).toDouble();
  }

  int get standaardAantalTraversen => hoogteMm > 1600 ? 2 : 1;

  List<double> get standaardTraversePositiesMm {
    if (standaardAantalTraversen == 1) {
      return <double>[hoogteMm / 2];
    }

    final deel = hoogteMm / 3;
    return <double>[deel, deel * 2];
  }

  int get maximumAantalTraversenOpMaat {
    if (!isVliegenraamRv) return 3;
    if (hoogteMm <= 500) return 1;
    if (hoogteMm <= 550) return 2;
    return 3;
  }

  int get aantalTraversenOpMaatGeldig =>
      aantalTraversenOpMaat.clamp(1, maximumAantalTraversenOpMaat).toInt();

  int traverseMinimumVoorIndex(int index) {
    if (!isVliegenraamRv) {
      return 1;
    }
    return switch (index) {
      0 => 10,
      1 => 500,
      _ => 550,
    };
  }

  int traverseMaximumVoorIndex(int index) {
    final maximumBinnenKader = (hoogteMm - 1).clamp(1, 100000).toInt();
    return isVliegenraamRv
        ? maximumBinnenKader.clamp(1, 990).toInt()
        : maximumBinnenKader;
  }

  List<int> get gesynchroniseerdeTraversePositiesOpMaatMm {
    final basis = _normaliseerTraversePosities(
      hoogteMm: hoogteMm,
      aantal: aantalTraversenOpMaatGeldig,
      posities: traversePositiesOpMaatMm,
    );

    return List<int>.unmodifiable(
      List<int>.generate(basis.length, (index) {
        final minimum = traverseMinimumVoorIndex(index);
        final maximum = traverseMaximumVoorIndex(index);
        if (maximum < minimum) {
          return maximum;
        }
        return basis[index].clamp(minimum, maximum).toInt();
      }, growable: false),
    );
  }

  List<double> get actieveTraversePositiesMm {
    if (!isTraverseOpMaat) {
      return standaardTraversePositiesMm;
    }

    return gesynchroniseerdeTraversePositiesOpMaatMm
        .map((positie) => positie.toDouble())
        .toList(growable: false);
  }

  String get maatSamenvattingTitel =>
      isBinnenmaat ? 'Binnenmaat / doorkijkmaat' : 'Buitenmaat';

  String get maatSamenvatting {
    if (isVliegenraamDubbel) {
      return 'B $breedteMm × H $hoogteMm mm · L5 $hoogteOndersteKaderMm mm';
    }
    return '$breedteMm × $hoogteMm mm';
  }

  String get inzetProfielVoorWeergave {
    return isVr033Ultra ? 'VR033 Ultra' : 'VR033 (inzet)';
  }

  String get spelingVoorOverzicht {
    if (isVr033Ultra) {
      return spelingGeen;
    }
    return spelingKeuze == spelingGeen ? spelingGeen : spelingStandaard;
  }

  String get kleurVoorOverzicht {
    if (isPoederlak && poederlakKleur.trim().isNotEmpty) {
      return 'Poederlak · ${poederlakKleur.trim()}';
    }
    if (isProjectkleur) {
      final waarde = ralKleurToebehorenWaarde.trim();
      return waarde.isEmpty
          ? kleurProjectLabel
          : '$kleurProjectLabel · $waarde';
    }
    return populaireKleurVoorWeergave;
  }

  String get flensDiepteVoorOverzicht {
    if (isFlensOpMaat) {
      return '$flensDiepteOpMaatMm mm';
    }
    return flensDiepte;
  }

  static String soortLabel(String waarde) {
    final genormaliseerd = waarde.trim().toLowerCase();

    return switch (genormaliseerd) {
      'vliegenraam classic' => 'Vliegenraam Classic',
      'vliegenraam dubbel' => 'Vliegenraam Dubbel',
      'inzetvliegenraam' => 'Inzetvliegenraam',
      'vliegenraam rv' => 'Vliegenraam RV',
      _ => waarde.trim(),
    };
  }

  static String profielLabel(String waarde) {
    final genormaliseerd = waarde.trim().toLowerCase();

    return switch (genormaliseerd) {
      'vr050 standaard 16 mm' ||
      'vr050 standaard' ||
      'vr050 (standaard)' => 'VR050 (standaard)',
      'vr054 doorvalbeveiliging' ||
      'vr054 (doorvalbeveiliging)' => 'VR054 (doorvalbeveiliging)',
      'vr060 smal 11 mm' || 'vr060 smal' || 'vr060 (smal)' => 'VR060 (smal)',
      'vr061' || 'vr061 rv' || 'vr061 (rv)' => 'VR061 (RV)',
      'vr080 breed' || 'vr080 (breed)' => 'VR080 (breed)',
      'vr090 extra breed' || 'vr090 (extra breed)' => 'VR090 (extra breed)',
      _ => waarde.trim(),
    };
  }

  static String kleurLabel(String waarde) {
    return waarde == kleurRalToebehoren ? kleurProjectLabel : waarde;
  }

  static String gaasLabel(String waarde) {
    return switch (_normaliseerGaas(waarde)) {
      gaasStandaard => 'Standaard',
      gaasClearview => 'ClearView',
      gaasPetscreen => 'Petscreen',
      gaasPetscreenGrijs => 'Petscreen grijs',
      gaasPetscreenZwart => 'Petscreen zwart',
      gaasInox => 'Inox gaas',
      gaasGeen => 'Geen gaas',
      final andereWaarde => andereWaarde,
    };
  }

  static String soortBevestigingLabel(String waarde) {
    return switch (_normaliseerSoortBevestiging(waarde)) {
      '5 extra' => '5 + extra',
      '7 extra' => '7 + extra',
      final andereWaarde => andereWaarde,
    };
  }

  /// Past hoogte, aantal en posities als één geheel aan.
  ///
  /// - Bij een gewijzigd aantal worden de posities opnieuw gelijk verdeeld.
  /// - Bij alleen een gewijzigde hoogte worden bestaande posities evenredig
  ///   meegeschaald.
  /// - Expliciet doorgegeven posities worden gecontroleerd en aangevuld.
  OpmetingVasteInzethorModel copyWithGesynchroniseerdeTraversen({
    int? hoogteMm,
    int? aantalTraversenOpMaat,
    List<int>? traversePositiesOpMaatMm,
  }) {
    final nieuweHoogte = hoogteMm ?? this.hoogteMm;
    final maximumAantal = isVliegenraamRv
        ? (nieuweHoogte <= 500
              ? 1
              : nieuweHoogte <= 550
              ? 2
              : 3)
        : 3;
    final nieuwAantal = (aantalTraversenOpMaat ?? this.aantalTraversenOpMaat)
        .clamp(1, maximumAantal)
        .toInt();
    final huidigAantal = this.aantalTraversenOpMaat
        .clamp(1, maximumAantalTraversenOpMaat)
        .toInt();
    final aantalGewijzigd = nieuwAantal != huidigAantal;
    final hoogteGewijzigd = nieuweHoogte != this.hoogteMm;

    late final List<int> bronPosities;

    if (traversePositiesOpMaatMm != null) {
      bronPosities = List<int>.from(traversePositiesOpMaatMm);
    } else if (aantalGewijzigd) {
      bronPosities = _standaardTraversePositiesVoor(
        hoogteMm: nieuweHoogte,
        aantal: nieuwAantal,
      );
    } else if (hoogteGewijzigd && this.hoogteMm > 0) {
      final schaal = nieuweHoogte / this.hoogteMm;
      bronPosities = this.traversePositiesOpMaatMm
          .map((positie) => (positie * schaal).round())
          .toList(growable: false);
    } else {
      bronPosities = List<int>.from(this.traversePositiesOpMaatMm);
    }

    final nieuwePosities = _normaliseerTraversePosities(
      hoogteMm: nieuweHoogte,
      aantal: nieuwAantal,
      posities: bronPosities,
    );

    return copyWith(
      hoogteMm: nieuweHoogte,
      aantalTraversenOpMaat: nieuwAantal,
      traversePositiesOpMaatMm: nieuwePosities,
    );
  }

  OpmetingVasteInzethorModel genormaliseerdVoorProduct() {
    // Een oud dossier zonder uitbreidingsmarkering blijft bij enkel openen en
    // opnieuw bewaren exact op zijn vroegere technische opslagwaarden staan.
    // Zodra een technische keuze wordt gewijzigd, activeert de rechterkolom
    // de uitbreiding en worden alle nieuwe productregels consequent toegepast.
    if (!technischeUitbreidingActief) {
      return this;
    }

    var resultaat = this;

    if (!resultaat.magBuitenmaatKiezen &&
        resultaat.maatType != maatTypeBinnen) {
      resultaat = resultaat.copyWith(maatType: maatTypeBinnen);
    }

    if (resultaat.isVliegenraamDubbel &&
        !profielOptiesDubbel.contains(resultaat.profiel)) {
      resultaat = resultaat.copyWith(profiel: profielVr050);
    } else if (resultaat.isVliegenraamRv &&
        !profielOptiesRv.contains(resultaat.profiel)) {
      resultaat = resultaat.copyWith(profiel: profielVr061);
    } else if (!resultaat.isInzetvliegenraam &&
        !resultaat.isVliegenraamRv &&
        !profielOpties.contains(resultaat.profiel)) {
      resultaat = resultaat.copyWith(profiel: profielVr050);
    }

    if (resultaat.isInzetvliegenraam &&
        !inzetProfielOpties.contains(resultaat.speling)) {
      resultaat = resultaat.copyWith(speling: profielVr033Inzet);
    }

    if (resultaat.isInzetvliegenraam) {
      final geldigeSpeling = spelingKeuzeOpties.contains(resultaat.spelingKeuze)
          ? resultaat.spelingKeuze
          : spelingStandaard;
      resultaat = resultaat.copyWith(
        maatType: maatTypeBinnen,
        spelingKeuze: resultaat.isVr033Ultra ? spelingGeen : geldigeSpeling,
      );
    }

    if (resultaat.isVliegenraamDubbel) {
      resultaat = resultaat.copyWith(
        hoogteOndersteKaderMm: resultaat.hoogteOndersteKaderMm
            .clamp(hoogteOndersteKaderMinimumMm, hoogteOndersteKaderMaximumMm)
            .toInt(),
      );
    }

    if (resultaat.isVliegenraamRv) {
      var bevestigingWaarde = resultaat.bevestiging;
      var clipsWaarde = resultaat.soortClipsen;
      var soortBevestigingWaarde = resultaat.soortBevestiging;

      if (!bevestigingOptiesRv.contains(bevestigingWaarde)) {
        bevestigingWaarde = bevestigingClipsenZakje;
      }
      if (!soortClipsenOptiesRv.contains(clipsWaarde)) {
        clipsWaarde = clipsenStandaard;
      }
      if (!soortBevestigingOptiesRv.contains(soortBevestigingWaarde)) {
        soortBevestigingWaarde = '20';
      }

      resultaat = resultaat.copyWith(
        bevestiging: bevestigingWaarde,
        soortClipsen: clipsWaarde,
        soortBevestiging: soortBevestigingWaarde,
      );
    }

    return resultaat;
  }

  OpmetingVasteInzethorModel activeerTechnischeUitbreiding() {
    if (technischeUitbreidingActief) return this;
    return copyWith(technischeUitbreidingActief: true);
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
    int? hoogteOndersteKaderMm,
    String? spelingKeuze,
    bool? technischeUitbreidingActief,
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
      hoogteOndersteKaderMm:
          hoogteOndersteKaderMm ?? this.hoogteOndersteKaderMm,
      spelingKeuze: spelingKeuze ?? this.spelingKeuze,
      technischeUitbreidingActief:
          technischeUitbreidingActief ?? this.technischeUitbreidingActief,
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
      'hoogteOndersteKaderMm': hoogteOndersteKaderMm,
      'spelingKeuze': spelingKeuze,
      'technischeUitbreidingActief': technischeUitbreidingActief,
      'traverseType': traverseType,
      'aantalTraversenOpMaat': aantalTraversenOpMaatGeldig,
      'traversePositiesOpMaatMm': gesynchroniseerdeTraversePositiesOpMaatMm,
      'populaireKleur': populaireKleur,
      'ralKleurToebehorenWaarde': ralKleurToebehorenWaarde,
      'poederlakKleur': poederlakKleur,
      'gaas': gaasVoorOverzicht,
      'kleurPees': kleurPees,
      'borstels': borstels,
      'bevestiging': bevestiging,
      'soortClipsen': soortClipsen,
      'soortBevestiging': _normaliseerSoortBevestiging(soortBevestiging),
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
      soort: _normaliseerSoort(json['soort']),
      speling: _normaliseerInzetProfiel(json['speling']),
      flensDiepte: json['flensDiepte']?.toString() ?? flensDiepte20,
      flensDiepteOpMaatMm: _leesInt(
        json['flensDiepteOpMaatMm'],
        standaardWaarde: 20,
      ),
      maatRandFlens: json['maatRandFlens']?.toString() ?? maatRandFlens8,
      profiel: _normaliseerProfiel(json['profiel']),
      maatType: json['maatType']?.toString() ?? maatTypeBinnen,
      breedteMm: _leesInt(json['breedteMm'], standaardWaarde: 800),
      hoogteMm: _leesInt(json['hoogteMm'], standaardWaarde: 1100),
      hoogteOndersteKaderMm: _leesInt(
        json['hoogteOndersteKaderMm'] ?? json['l5Mm'],
        standaardWaarde: 500,
      ).clamp(200, 800).toInt(),
      spelingKeuze: _normaliseerSpelingKeuze(
        json['spelingKeuze'] ?? json['spelingType'],
      ),
      technischeUitbreidingActief: json['technischeUitbreidingActief'] == true,
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
      soortClipsen: _normaliseerSoortClipsen(json['soortClipsen']),
      soortBevestiging: _normaliseerSoortBevestiging(json['soortBevestiging']),
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

  static List<int> _standaardTraversePositiesVoor({
    required int hoogteMm,
    required int aantal,
  }) {
    final veiligeHoogte = hoogteMm < 2 ? 2 : hoogteMm;
    final veiligAantal = aantal.clamp(1, 3).toInt();

    return List<int>.generate(veiligAantal, (index) {
      final positie = (veiligeHoogte * (index + 1) / (veiligAantal + 1))
          .round();
      return positie.clamp(1, veiligeHoogte - 1).toInt();
    }, growable: false);
  }

  static List<int> _normaliseerTraversePosities({
    required int hoogteMm,
    required int aantal,
    required List<int> posities,
  }) {
    final veiligeHoogte = hoogteMm < 2 ? 2 : hoogteMm;
    final veiligAantal = aantal.clamp(1, 3).toInt();
    final standaardPosities = _standaardTraversePositiesVoor(
      hoogteMm: veiligeHoogte,
      aantal: veiligAantal,
    );
    final resultaat = <int>[];

    for (var index = 0; index < veiligAantal; index++) {
      final aangeleverd = index < posities.length ? posities[index] : 0;
      final positie = aangeleverd > 0 && aangeleverd < veiligeHoogte
          ? aangeleverd
          : standaardPosities[index];
      resultaat.add(positie.clamp(1, veiligeHoogte - 1).toInt());
    }

    resultaat.sort();
    return List<int>.unmodifiable(resultaat);
  }

  static String _normaliseerSoort(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';
    final genormaliseerd = tekst.toLowerCase();

    return switch (genormaliseerd) {
      '' || 'vliegenraam classic' => soortVliegenraamClassic,
      'vliegenraam dubbel' => soortVliegenraamDubbel,
      'inzetvliegenraam' => soortInzetvliegenraam,
      'vliegenraam rv' => soortVliegenraamRv,
      _ => tekst,
    };
  }

  static String _normaliseerProfiel(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';
    final genormaliseerd = tekst.toLowerCase();

    return switch (genormaliseerd) {
      '' ||
      'vr050' ||
      'vr050 standaard' ||
      'vr050 standaard 16 mm' ||
      'vr050 (standaard)' => profielVr050,
      'vr054' ||
      'vr054 doorvalbeveiliging' ||
      'vr054 (doorvalbeveiliging)' => profielVr054,
      'vr060' ||
      'vr060 smal' ||
      'vr060 smal 11 mm' ||
      'vr060 (smal)' => profielVr060,
      'vr061' || 'vr061 rv' || 'vr061 (rv)' => profielVr061,
      'vr080' || 'vr080 breed' || 'vr080 (breed)' => profielVr080,
      'vr090' || 'vr090 extra breed' || 'vr090 (extra breed)' => profielVr090,
      _ => tekst,
    };
  }

  static String _normaliseerInzetProfiel(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';
    final genormaliseerd = tekst.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '',
    );

    return switch (genormaliseerd) {
      '' || 'vr033' || 'vr033inzet' => spelingVr033Inzet,
      'vr033ultra' => spelingVr033Ultra,
      _ => tekst,
    };
  }

  static String _normaliseerSpelingKeuze(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';
    final genormaliseerd = tekst.toLowerCase();

    return switch (genormaliseerd) {
      '' || 'standaard' || 'standaard speling' => spelingStandaard,
      'geen' || 'geen speling' => spelingGeen,
      _ => tekst,
    };
  }

  static String _normaliseerGaas(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';
    final genormaliseerd = tekst.toLowerCase();

    switch (genormaliseerd) {
      case '':
      case 'standaard':
      case 'standaard gaas':
      case 'standaard gaas petscreen':
        return gaasStandaard;
      case 'standaard clearview':
      case 'standaard clear view':
      case 'standaard clear-view':
      case 'clearview':
      case 'clear view':
      case 'clear-view':
        return gaasClearview;
      case 'petscreen':
        return gaasPetscreen;
      case 'petscreen grijs':
      case 'petscreen grey':
        return gaasPetscreenGrijs;
      case 'petscreen zwart':
      case 'petscreen black':
        return gaasPetscreenZwart;
      case 'inox':
      case 'inox gaas':
        return gaasInox;
      case 'geen':
      case 'geen gaas':
        return gaasGeen;
      default:
        return tekst.isEmpty ? gaasStandaard : tekst;
    }
  }

  static String _normaliseerSoortClipsen(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';
    final genormaliseerd = tekst.toLowerCase();

    switch (genormaliseerd) {
      case '':
      case 'standaard':
        return clipsenStandaard;
      case 'staallook':
        return clipsenStaallook;
      case 'maritiem':
      case 'standaard maritiem':
      case 'standaard (maritieme omgeving)':
        return clipsenStandaardMaritiem;
      case 'staallook maritiem':
      case 'staallook (maritieme omgeving)':
        return clipsenStaallookMaritiem;
      default:
        return tekst.isEmpty ? clipsenStandaard : tekst;
    }
  }

  static String _normaliseerSoortBevestiging(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';
    final compact = tekst.toLowerCase().replaceAll(RegExp(r'\s+'), '');

    switch (compact) {
      case '':
        return '20';
      case '5extra':
      case '5+extra':
        return '5 extra';
      case '7extra':
      case '7+extra':
        return '7 extra';
      default:
        return tekst;
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
