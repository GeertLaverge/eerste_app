// THIMACO-CONTROLE: TOEBEHOREN-KLEURBRON-BEWAREN-20260808-1433
// THIMACO-CONTROLE: OFFERTE-WERKBRON-VERSIE-20260806
import '../../offerte/prijzen/offerte_prijsinstellingen_momentopname.dart';
import '../../offerte/prijzen/offerte_prijs_categorie.dart';
import '../../offerte/prijzen/offerte_prijsregel_model.dart';

class OpmetingProjectTitelhoofd {
  const OpmetingProjectTitelhoofd({
    this.aanspreking = '',
    this.klantNaam = '',
    this.contactpersoon = '',
    this.adres = '',
    this.huisnummer = '',
    this.busNummer = '',
    this.postcode = '',
    this.gemeente = '',
    this.gsm = '',
    this.telefoon = '',
    this.email = '',
    this.projectAdres = '',
    this.projectHuisnummer = '',
    this.projectBusNummer = '',
    this.projectPostcode = '',
    this.projectGemeente = '',
    this.projectKleurBinnen = '',
    this.projectKleurBuiten = '',
    this.ralKleurToebehoren = '',
    this.kleurBronToebehoren = standaardKleurBronToebehoren,
    this.buitenkleurGelijkAanToebehoren = false,
    this.kleurAfwijking = '',
    this.btwTarief = standaardBtwTarief,
    this.offerteJaar = standaardOfferteJaar,
    this.klantnummer = '',
    this.offerteVolgnummer = standaardOfferteVolgnummer,
    this.kortingOmschrijving = standaardKortingOmschrijving,
    this.berekenPrijzen = false,
    this.tijdelijkeProjectPrijsregels = const <OffertePrijsregelModel>[],
    this.offertePrijsinstellingenMomentopnames =
        const <String, OffertePrijsinstellingenMomentopname>{},
    this.offerteBronVersieId = '',
    this.offerteBronVersieNummer = 0,
    this.gewijzigdOp = '',
  });

  static const String standaardBtwTarief = '21 %';
  static const String standaardOfferteJaar = '26';
  static const String standaardOfferteVolgnummer = '01';
  static const String standaardKortingOmschrijving = 'Korting';

  static const String kleurBronToebehorenRal = 'ral';
  static const String kleurBronToebehorenAliplast = 'aliplast';
  static const String kleurBronToebehorenWilms = 'wilms';
  static const String kleurBronToebehorenFeneko = 'feneko';
  static const String standaardKleurBronToebehoren = kleurBronToebehorenRal;

  static const List<String> kleurBronToebehorenWaarden = <String>[
    kleurBronToebehorenRal,
    kleurBronToebehorenAliplast,
    kleurBronToebehorenWilms,
    kleurBronToebehorenFeneko,
  ];

  static String normaliseerKleurBronToebehoren(String? waarde) {
    final sleutel = waarde?.trim().toLowerCase() ?? '';
    return kleurBronToebehorenWaarden.contains(sleutel)
        ? sleutel
        : standaardKleurBronToebehoren;
  }

  static const List<String> btwTarieven = <String>[
    '6 %',
    '21 %',
    'BTW verlegd',
  ];

  final String aanspreking;
  final String klantNaam;
  final String contactpersoon;
  final String adres;
  final String huisnummer;
  final String busNummer;
  final String postcode;
  final String gemeente;
  final String gsm;
  final String telefoon;
  final String email;
  final String projectAdres;
  final String projectHuisnummer;
  final String projectBusNummer;
  final String projectPostcode;
  final String projectGemeente;
  final String projectKleurBinnen;
  final String projectKleurBuiten;
  final String ralKleurToebehoren;
  final String kleurBronToebehoren;
  final bool buitenkleurGelijkAanToebehoren;
  final String kleurAfwijking;
  final String btwTarief;
  final String offerteJaar;
  final String klantnummer;
  final String offerteVolgnummer;
  final String kortingOmschrijving;
  final bool berekenPrijzen;
  final List<OffertePrijsregelModel> tijdelijkeProjectPrijsregels;
  final Map<String, OffertePrijsinstellingenMomentopname>
  offertePrijsinstellingenMomentopnames;
  final String offerteBronVersieId;
  final int offerteBronVersieNummer;
  final String gewijzigdOp;

  String get klantNaamMetAanspreking {
    return opmetingKlantWeergaveNaam(
      aanspreking: aanspreking,
      klantNaam: klantNaam,
    );
  }

  String get plaats {
    return <String>[
      postcode.trim(),
      gemeente.trim(),
    ].where((deel) => deel.isNotEmpty).join(' ');
  }

  String get projectPlaats {
    return <String>[
      projectPostcode.trim(),
      projectGemeente.trim(),
    ].where((deel) => deel.isNotEmpty).join(' ');
  }

  String get projectAdresRegel {
    final nummer = <String>[
      projectHuisnummer.trim(),
      if (projectBusNummer.trim().isNotEmpty) 'bus ${projectBusNummer.trim()}',
    ].where((deel) => deel.isNotEmpty).join(' ');

    return <String>[
      projectAdres.trim(),
      nummer,
    ].where((deel) => deel.isNotEmpty).join(' ');
  }

  String get volledigProjectAdres {
    return <String>[
      projectAdresRegel,
      projectPlaats,
    ].where((deel) => deel.trim().isNotEmpty).join(', ');
  }

  bool get heeftProjectAdres {
    return projectAdres.trim().isNotEmpty ||
        projectHuisnummer.trim().isNotEmpty ||
        projectBusNummer.trim().isNotEmpty ||
        projectPostcode.trim().isNotEmpty ||
        projectGemeente.trim().isNotEmpty;
  }

  String get samengesteldOffertenummer {
    return '$offerteJaar$klantnummer$offerteVolgnummer';
  }

  bool get heeftKlantGegevens {
    return aanspreking.trim().isNotEmpty ||
        klantNaam.trim().isNotEmpty ||
        contactpersoon.trim().isNotEmpty ||
        adres.trim().isNotEmpty ||
        huisnummer.trim().isNotEmpty ||
        busNummer.trim().isNotEmpty ||
        plaats.trim().isNotEmpty ||
        gsm.trim().isNotEmpty ||
        telefoon.trim().isNotEmpty ||
        email.trim().isNotEmpty ||
        klantnummer.trim().isNotEmpty;
  }

  bool get heeftProjectKleuren {
    return projectKleurBinnen.trim().isNotEmpty ||
        projectKleurBuiten.trim().isNotEmpty ||
        ralKleurToebehoren.trim().isNotEmpty;
  }

  bool get heeftKleurAfwijking {
    return kleurAfwijking.trim().isNotEmpty;
  }

  bool get isLeeg {
    return !heeftKlantGegevens &&
        !heeftProjectAdres &&
        !heeftProjectKleuren &&
        kleurAfwijking.trim().isEmpty &&
        tijdelijkeProjectPrijsregels.isEmpty &&
        !berekenPrijzen;
  }

  OpmetingProjectTitelhoofd copyWith({
    String? aanspreking,
    String? klantNaam,
    String? contactpersoon,
    String? adres,
    String? huisnummer,
    String? busNummer,
    String? postcode,
    String? gemeente,
    String? gsm,
    String? telefoon,
    String? email,
    String? projectAdres,
    String? projectHuisnummer,
    String? projectBusNummer,
    String? projectPostcode,
    String? projectGemeente,
    String? projectKleurBinnen,
    String? projectKleurBuiten,
    String? ralKleurToebehoren,
    String? kleurBronToebehoren,
    bool? buitenkleurGelijkAanToebehoren,
    String? kleurAfwijking,
    String? btwTarief,
    String? offerteJaar,
    String? klantnummer,
    String? offerteVolgnummer,
    String? kortingOmschrijving,
    bool? berekenPrijzen,
    List<OffertePrijsregelModel>? tijdelijkeProjectPrijsregels,
    Map<String, OffertePrijsinstellingenMomentopname>?
    offertePrijsinstellingenMomentopnames,
    String? offerteBronVersieId,
    int? offerteBronVersieNummer,
    String? gewijzigdOp,
  }) {
    return OpmetingProjectTitelhoofd(
      aanspreking: normaliseerOpmetingAanspreking(
        aanspreking ?? this.aanspreking,
      ),
      klantNaam: klantNaam ?? this.klantNaam,
      contactpersoon: contactpersoon ?? this.contactpersoon,
      adres: adres ?? this.adres,
      huisnummer: huisnummer ?? this.huisnummer,
      busNummer: busNummer ?? this.busNummer,
      postcode: postcode ?? this.postcode,
      gemeente: gemeente ?? this.gemeente,
      gsm: gsm ?? this.gsm,
      telefoon: telefoon ?? this.telefoon,
      email: email ?? this.email,
      projectAdres: projectAdres ?? this.projectAdres,
      projectHuisnummer: projectHuisnummer ?? this.projectHuisnummer,
      projectBusNummer: projectBusNummer ?? this.projectBusNummer,
      projectPostcode: projectPostcode ?? this.projectPostcode,
      projectGemeente: projectGemeente ?? this.projectGemeente,
      projectKleurBinnen: projectKleurBinnen ?? this.projectKleurBinnen,
      projectKleurBuiten: projectKleurBuiten ?? this.projectKleurBuiten,
      ralKleurToebehoren: ralKleurToebehoren ?? this.ralKleurToebehoren,
      kleurBronToebehoren: normaliseerKleurBronToebehoren(
        kleurBronToebehoren ?? this.kleurBronToebehoren,
      ),
      buitenkleurGelijkAanToebehoren:
          buitenkleurGelijkAanToebehoren ?? this.buitenkleurGelijkAanToebehoren,
      kleurAfwijking: kleurAfwijking ?? this.kleurAfwijking,
      btwTarief: btwTarief ?? this.btwTarief,
      offerteJaar: offerteJaar ?? this.offerteJaar,
      klantnummer: klantnummer ?? this.klantnummer,
      offerteVolgnummer: offerteVolgnummer ?? this.offerteVolgnummer,
      kortingOmschrijving: kortingOmschrijving ?? this.kortingOmschrijving,
      berekenPrijzen: berekenPrijzen ?? this.berekenPrijzen,
      tijdelijkeProjectPrijsregels:
          tijdelijkeProjectPrijsregels ?? this.tijdelijkeProjectPrijsregels,
      offertePrijsinstellingenMomentopnames:
          offertePrijsinstellingenMomentopnames ??
          this.offertePrijsinstellingenMomentopnames,
      offerteBronVersieId: offerteBronVersieId ?? this.offerteBronVersieId,
      offerteBronVersieNummer:
          offerteBronVersieNummer ?? this.offerteBronVersieNummer,
      gewijzigdOp: gewijzigdOp ?? this.gewijzigdOp,
    );
  }

  OpmetingProjectTitelhoofd metWijzigingsDatum() {
    return copyWith(gewijzigdOp: DateTime.now().toUtc().toIso8601String());
  }

  OffertePrijsinstellingenMomentopname? prijsinstellingenMomentopnameVoor(
    String formulierType,
  ) {
    final sleutel = _normaliseerFormulierType(formulierType);

    for (final entry in offertePrijsinstellingenMomentopnames.entries) {
      if (_normaliseerFormulierType(entry.key) == sleutel) {
        return entry.value;
      }
    }

    return null;
  }

  OpmetingProjectTitelhoofd metPrijsinstellingenMomentopname(
    OffertePrijsinstellingenMomentopname momentopname,
  ) {
    final nieuweMomentopnames =
        Map<String, OffertePrijsinstellingenMomentopname>.from(
          offertePrijsinstellingenMomentopnames,
        );
    nieuweMomentopnames[momentopname.formulierType] = momentopname;

    return copyWith(offertePrijsinstellingenMomentopnames: nieuweMomentopnames);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'aanspreking': normaliseerOpmetingAanspreking(aanspreking),
      'klantNaam': klantNaam,
      'contactpersoon': contactpersoon,
      'adres': adres,
      'huisnummer': huisnummer,
      'busNummer': busNummer,
      'postcode': postcode,
      'gemeente': gemeente,
      'gsm': gsm,
      'telefoon': telefoon,
      'email': email,
      'projectAdres': projectAdres,
      'projectHuisnummer': projectHuisnummer,
      'projectBusNummer': projectBusNummer,
      'projectPostcode': projectPostcode,
      'projectGemeente': projectGemeente,
      'projectKleurBinnen': projectKleurBinnen,
      'projectKleurBuiten': projectKleurBuiten,
      'ralKleurToebehoren': ralKleurToebehoren,
      'kleurBronToebehoren': kleurBronToebehoren,
      'buitenkleurGelijkAanToebehoren': buitenkleurGelijkAanToebehoren,
      'kleurAfwijking': kleurAfwijking,
      'btwTarief': btwTarief,
      'offerteJaar': offerteJaar,
      'klantnummer': klantnummer,
      'offerteVolgnummer': offerteVolgnummer,
      'kortingOmschrijving': kortingOmschrijving,
      'berekenPrijzen': berekenPrijzen,
      'tijdelijkeProjectPrijsregels': tijdelijkeProjectPrijsregels
          .map((regel) => regel.toJson())
          .toList(),
      'offertePrijsinstellingenMomentopnames':
          offertePrijsinstellingenMomentopnames.map(
            (formulierType, momentopname) =>
                MapEntry(formulierType, momentopname.toJson()),
          ),
      'offerteBronVersieId': offerteBronVersieId,
      'offerteBronVersieNummer': offerteBronVersieNummer,
      'gewijzigdOp': gewijzigdOp,
    };
  }

  factory OpmetingProjectTitelhoofd.fromJson(Map<String, dynamic> json) {
    final ruweKlantNaam = json['klantNaam']?.toString().trim() ?? '';
    final opgeslagenAanspreking = normaliseerOpmetingAanspreking(
      json['aanspreking'] ?? json['aanhef'] ?? json['salutation'],
    );
    final aanspreking = opgeslagenAanspreking.isNotEmpty
        ? opgeslagenAanspreking
        : opmetingAansprekingUitKlantNaam(ruweKlantNaam);

    return OpmetingProjectTitelhoofd(
      aanspreking: aanspreking,
      klantNaam: aanspreking.isEmpty
          ? ruweKlantNaam
          : opmetingKlantNaamZonderAanspreking(ruweKlantNaam),
      contactpersoon: json['contactpersoon']?.toString() ?? '',
      adres: json['adres']?.toString() ?? '',
      huisnummer: json['huisnummer']?.toString() ?? '',
      busNummer: json['busNummer']?.toString() ?? '',
      postcode: json['postcode']?.toString() ?? '',
      gemeente: json['gemeente']?.toString() ?? '',
      gsm: json['gsm']?.toString() ?? '',
      telefoon: json['telefoon']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      projectAdres: json['projectAdres']?.toString() ?? '',
      projectHuisnummer: json['projectHuisnummer']?.toString() ?? '',
      projectBusNummer: json['projectBusNummer']?.toString() ?? '',
      projectPostcode: json['projectPostcode']?.toString() ?? '',
      projectGemeente: json['projectGemeente']?.toString() ?? '',
      projectKleurBinnen: json['projectKleurBinnen']?.toString() ?? '',
      projectKleurBuiten: json['projectKleurBuiten']?.toString() ?? '',
      ralKleurToebehoren:
          json['ralKleurToebehoren']?.toString() ??
          json['projectKleurToebehoren']?.toString() ??
          '',
      kleurBronToebehoren: normaliseerKleurBronToebehoren(
        json['kleurBronToebehoren']?.toString(),
      ),
      buitenkleurGelijkAanToebehoren: _leesBool(
        json['buitenkleurGelijkAanToebehoren'],
        standaardWaarde: false,
      ),
      kleurAfwijking: json['kleurAfwijking']?.toString() ?? '',
      btwTarief: _normaliseerBtwTarief(json['btwTarief']?.toString()),
      offerteJaar: _beperkTotCijfers(
        json['offerteJaar']?.toString() ?? '',
        maxLengte: 2,
        standaardWaarde: standaardOfferteJaar,
      ),
      klantnummer: _beperkTotCijfers(
        json['klantnummer']?.toString() ??
            json['klantNummer']?.toString() ??
            json['klantNr']?.toString() ??
            '',
        maxLengte: 4,
      ),
      offerteVolgnummer: _beperkTotCijfers(
        json['offerteVolgnummer']?.toString() ?? '',
        maxLengte: 2,
        standaardWaarde: standaardOfferteVolgnummer,
      ),
      kortingOmschrijving: _normaliseerKortingOmschrijving(
        json['kortingOmschrijving']?.toString(),
      ),
      berekenPrijzen: _leesBool(json['berekenPrijzen'], standaardWaarde: false),
      tijdelijkeProjectPrijsregels: _leesTijdelijkeProjectPrijsregels(
        json['tijdelijkeProjectPrijsregels'],
      ),
      offertePrijsinstellingenMomentopnames:
          _leesPrijsinstellingenMomentopnames(
            json['offertePrijsinstellingenMomentopnames'],
          ),
      offerteBronVersieId: json['offerteBronVersieId']?.toString() ?? '',
      offerteBronVersieNummer: _leesIntVeilig(json['offerteBronVersieNummer']),
      gewijzigdOp: json['gewijzigdOp']?.toString() ?? '',
    );
  }
}

class OpmetingAgendaKlantInfo {
  const OpmetingAgendaKlantInfo({
    required this.klantNaam,
    this.aanspreking = '',
    this.klantnummer = '',
    this.contactpersoon = '',
    this.adres = '',
    this.huisnummer = '',
    this.busNummer = '',
    this.postcode = '',
    this.gemeente = '',
    this.gsm = '',
    this.telefoon = '',
    this.email = '',
    this.omschrijving = '',
    this.datumKey = '',
  });

  final String klantNaam;
  final String aanspreking;
  final String klantnummer;
  final String contactpersoon;
  final String adres;
  final String huisnummer;
  final String busNummer;
  final String postcode;
  final String gemeente;
  final String gsm;
  final String telefoon;
  final String email;
  final String omschrijving;
  final String datumKey;

  String get klantNaamMetAanspreking {
    return opmetingKlantWeergaveNaam(
      aanspreking: aanspreking,
      klantNaam: klantNaam,
    );
  }

  String get plaats {
    return <String>[
      postcode.trim(),
      gemeente.trim(),
    ].where((deel) => deel.isNotEmpty).join(' ');
  }

  String get adresRegel {
    final nummer = <String>[
      huisnummer.trim(),
      if (busNummer.trim().isNotEmpty) 'bus ${busNummer.trim()}',
    ].where((deel) => deel.isNotEmpty).join(' ');

    return <String>[
      adres.trim(),
      nummer,
    ].where((deel) => deel.isNotEmpty).join(' ');
  }

  String get zoekTekst {
    return <String>[
      aanspreking,
      klantNaam,
      klantnummer,
      contactpersoon,
      adres,
      huisnummer,
      busNummer,
      postcode,
      gemeente,
      gsm,
      telefoon,
      email,
      omschrijving,
      datumKey,
    ].join(' ').toLowerCase();
  }

  OpmetingAgendaKlantInfo copyWith({
    String? klantNaam,
    String? aanspreking,
    String? klantnummer,
    String? contactpersoon,
    String? adres,
    String? huisnummer,
    String? busNummer,
    String? postcode,
    String? gemeente,
    String? gsm,
    String? telefoon,
    String? email,
    String? omschrijving,
    String? datumKey,
  }) {
    return OpmetingAgendaKlantInfo(
      klantNaam: klantNaam ?? this.klantNaam,
      aanspreking: normaliseerOpmetingAanspreking(
        aanspreking ?? this.aanspreking,
      ),
      klantnummer: klantnummer ?? this.klantnummer,
      contactpersoon: contactpersoon ?? this.contactpersoon,
      adres: adres ?? this.adres,
      huisnummer: huisnummer ?? this.huisnummer,
      busNummer: busNummer ?? this.busNummer,
      postcode: postcode ?? this.postcode,
      gemeente: gemeente ?? this.gemeente,
      gsm: gsm ?? this.gsm,
      telefoon: telefoon ?? this.telefoon,
      email: email ?? this.email,
      omschrijving: omschrijving ?? this.omschrijving,
      datumKey: datumKey ?? this.datumKey,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'klantNaam': klantNaam,
      'aanspreking': normaliseerOpmetingAanspreking(aanspreking),
      'klantnummer': klantnummer,
      'contactpersoon': contactpersoon,
      'adres': adres,
      'huisnummer': huisnummer,
      'busNummer': busNummer,
      'postcode': postcode,
      'gemeente': gemeente,
      'gsm': gsm,
      'telefoon': telefoon,
      'email': email,
      'omschrijving': omschrijving,
      'datumKey': datumKey,
    };
  }

  factory OpmetingAgendaKlantInfo.fromJson(Map<String, dynamic> json) {
    final ruweKlantNaam =
        json['klantNaam']?.toString().trim() ??
        json['naamKlant']?.toString().trim() ??
        json['naam']?.toString().trim() ??
        '';
    final opgeslagenAanspreking = normaliseerOpmetingAanspreking(
      json['aanspreking'] ?? json['aanhef'] ?? json['salutation'],
    );
    final aanspreking = opgeslagenAanspreking.isNotEmpty
        ? opgeslagenAanspreking
        : opmetingAansprekingUitKlantNaam(ruweKlantNaam);

    return OpmetingAgendaKlantInfo(
      klantNaam: aanspreking.isEmpty
          ? ruweKlantNaam
          : opmetingKlantNaamZonderAanspreking(ruweKlantNaam),
      aanspreking: aanspreking,
      klantnummer:
          json['klantnummer']?.toString() ??
          json['klantNummer']?.toString() ??
          json['klantNr']?.toString() ??
          '',
      contactpersoon: json['contactpersoon']?.toString() ?? '',
      adres: json['adres']?.toString() ?? json['straatnaam']?.toString() ?? '',
      huisnummer:
          json['huisnummer']?.toString() ?? json['huisNr']?.toString() ?? '',
      busNummer:
          json['busNummer']?.toString() ??
          json['busnummer']?.toString() ??
          json['busNr']?.toString() ??
          '',
      postcode: json['postcode']?.toString() ?? '',
      gemeente:
          json['gemeente']?.toString() ?? json['plaats']?.toString() ?? '',
      gsm: json['gsm']?.toString() ?? '',
      telefoon: json['telefoon']?.toString() ?? json['gsm2']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      omschrijving:
          json['omschrijving']?.toString() ??
          json['opmerkingen']?.toString() ??
          '',
      datumKey: json['datumKey']?.toString() ?? '',
    );
  }

  OpmetingAgendaKlantInfo combineerMet(OpmetingAgendaKlantInfo ander) {
    String kies(String huidig, String nieuw) {
      return huidig.trim().isNotEmpty ? huidig : nieuw;
    }

    return OpmetingAgendaKlantInfo(
      klantNaam: kies(klantNaam, ander.klantNaam),
      aanspreking: normaliseerOpmetingAanspreking(
        kies(aanspreking, ander.aanspreking),
      ),
      klantnummer: kies(klantnummer, ander.klantnummer),
      contactpersoon: kies(contactpersoon, ander.contactpersoon),
      adres: kies(adres, ander.adres),
      huisnummer: kies(huisnummer, ander.huisnummer),
      busNummer: kies(busNummer, ander.busNummer),
      postcode: kies(postcode, ander.postcode),
      gemeente: kies(gemeente, ander.gemeente),
      gsm: kies(gsm, ander.gsm),
      telefoon: kies(telefoon, ander.telefoon),
      email: kies(email, ander.email),
      omschrijving: kies(omschrijving, ander.omschrijving),
      datumKey: kies(datumKey, ander.datumKey),
    );
  }

  OpmetingProjectTitelhoofd naarTitelhoofd({
    OpmetingProjectTitelhoofd? bestaand,
    bool overschrijfKlantnummer = false,
  }) {
    final huidige = bestaand ?? const OpmetingProjectTitelhoofd();
    final bronKlantnummer = _beperkTotCijfers(klantnummer, maxLengte: 4);

    return huidige.copyWith(
      aanspreking: aanspreking.trim().isEmpty
          ? huidige.aanspreking
          : normaliseerOpmetingAanspreking(aanspreking),
      klantNaam: klantNaam.trim().isEmpty
          ? huidige.klantNaam
          : opmetingKlantNaamZonderAanspreking(klantNaam),
      klantnummer: overschrijfKlantnummer
          ? bronKlantnummer
          : bronKlantnummer.isEmpty
          ? huidige.klantnummer
          : bronKlantnummer,
      contactpersoon: contactpersoon.trim().isEmpty
          ? huidige.contactpersoon
          : contactpersoon,
      adres: adres.trim().isEmpty ? huidige.adres : adres,
      huisnummer: huisnummer.trim().isEmpty ? huidige.huisnummer : huisnummer,
      busNummer: busNummer.trim().isEmpty ? huidige.busNummer : busNummer,
      postcode: postcode.trim().isEmpty ? huidige.postcode : postcode,
      gemeente: gemeente.trim().isEmpty ? huidige.gemeente : gemeente,
      gsm: gsm.trim().isEmpty ? huidige.gsm : gsm,
      telefoon: telefoon.trim().isEmpty ? huidige.telefoon : telefoon,
      email: email.trim().isEmpty ? huidige.email : email,
    );
  }
}

const List<String> opmetingAansprekingKeuzes = <String>[
  'Dhr.',
  'Mevr.',
  'Dhr. & Mevr.',
];

String normaliseerOpmetingAanspreking(Object? waarde) {
  final tekst = waarde?.toString().trim() ?? '';
  for (final keuze in opmetingAansprekingKeuzes) {
    if (keuze.toLowerCase() == tekst.toLowerCase()) return keuze;
  }
  return '';
}

String opmetingAansprekingUitKlantNaam(String klantNaam) {
  final naam = klantNaam.trim().replaceAll(RegExp(r'\s+'), ' ');
  for (final keuze in <String>['Dhr. & Mevr.', 'Dhr.', 'Mevr.']) {
    final patroon = RegExp(
      '^${RegExp.escape(keuze)}(?:\\s+|\$)',
      caseSensitive: false,
    );
    if (patroon.hasMatch(naam)) return keuze;
  }
  return '';
}

String opmetingKlantNaamZonderAanspreking(String klantNaam) {
  var resultaat = klantNaam.trim().replaceAll(RegExp(r'\s+'), ' ');
  for (final keuze in <String>['Dhr. & Mevr.', 'Dhr.', 'Mevr.']) {
    final patroon = RegExp(
      '^${RegExp.escape(keuze)}(?:\\s+|\$)',
      caseSensitive: false,
    );
    if (patroon.hasMatch(resultaat)) {
      resultaat = resultaat.replaceFirst(patroon, '').trim();
      break;
    }
  }
  return resultaat;
}

String opmetingKlantWeergaveNaam({
  required String aanspreking,
  required String klantNaam,
}) {
  final genormaliseerdeNaam = klantNaam.trim().replaceAll(RegExp(r'\s+'), ' ');
  final veiligeAanspreking = normaliseerOpmetingAanspreking(aanspreking);
  if (veiligeAanspreking.isEmpty) return genormaliseerdeNaam;

  final naam = opmetingKlantNaamZonderAanspreking(genormaliseerdeNaam);
  if (naam.isEmpty) return veiligeAanspreking;
  return '$veiligeAanspreking $naam';
}

String opmetingKlantNaamSleutel(String klantNaam) {
  return opmetingKlantNaamZonderAanspreking(
    klantNaam,
  ).toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
}

String opmetingProjectTitelhoofdSleutel(String klantNaam) {
  final sleutel = opmetingKlantNaamSleutel(klantNaam);
  return sleutel.isEmpty ? 'zonder_klantnaam' : sleutel;
}

int _leesIntVeilig(Object? waarde) {
  if (waarde is int) return waarde;
  if (waarde is num) return waarde.toInt();
  return int.tryParse(waarde?.toString() ?? '') ?? 0;
}

bool _leesBool(Object? waarde, {required bool standaardWaarde}) {
  if (waarde is bool) {
    return waarde;
  }

  final tekst = waarde?.toString().trim().toLowerCase();
  if (tekst == 'true' || tekst == '1') {
    return true;
  }
  if (tekst == 'false' || tekst == '0') {
    return false;
  }

  return standaardWaarde;
}

List<OffertePrijsregelModel> _leesTijdelijkeProjectPrijsregels(Object? waarde) {
  if (waarde is! List) {
    return const <OffertePrijsregelModel>[];
  }

  final resultaat = <OffertePrijsregelModel>[];
  for (final item in waarde.whereType<Map>()) {
    try {
      final regel = OffertePrijsregelModel.fromJson(
        Map<String, dynamic>.from(item),
      );
      if (regel.isGeldig &&
          regel.categorie == OffertePrijsCategorie.alleArtikelen) {
        resultaat.add(regel);
      }
    } catch (_) {
      // Eén beschadigde tijdelijke regel mag het titelhoofd niet blokkeren.
    }
  }

  resultaat.sort(
    (eerste, tweede) => eerste.volgorde.compareTo(tweede.volgorde),
  );
  return List<OffertePrijsregelModel>.unmodifiable(resultaat);
}

Map<String, OffertePrijsinstellingenMomentopname>
_leesPrijsinstellingenMomentopnames(Object? waarde) {
  if (waarde is! Map) {
    return const <String, OffertePrijsinstellingenMomentopname>{};
  }

  final resultaat = <String, OffertePrijsinstellingenMomentopname>{};

  for (final entry in waarde.entries) {
    if (entry.value is! Map) {
      continue;
    }

    try {
      final momentopname = OffertePrijsinstellingenMomentopname.fromJson(
        Map<String, dynamic>.from(entry.value as Map),
      );
      final sleutel = momentopname.formulierType.trim().isNotEmpty
          ? momentopname.formulierType
          : entry.key.toString();

      if (sleutel.trim().isNotEmpty) {
        resultaat[sleutel] = momentopname;
      }
    } catch (_) {
      // Een beschadigde prijsinstellingenmomentopname mag de fiche niet blokkeren.
    }
  }

  return resultaat;
}

String _normaliseerFormulierType(String waarde) {
  return waarde.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
}

String _normaliseerKortingOmschrijving(String? waarde) {
  final tekst = waarde?.trim() ?? '';
  return tekst.isEmpty
      ? OpmetingProjectTitelhoofd.standaardKortingOmschrijving
      : tekst;
}

String _normaliseerBtwTarief(String? waarde) {
  final schoon = waarde?.trim() ?? '';
  final zonderSpaties = schoon.replaceAll(' ', '').toLowerCase();

  if (zonderSpaties == '6%' || zonderSpaties == '6') {
    return '6 %';
  }

  if (zonderSpaties == 'btwverlegd' || zonderSpaties == 'verlegd') {
    return 'BTW verlegd';
  }

  if (zonderSpaties == '21%' || zonderSpaties == '21') {
    return '21 %';
  }

  return OpmetingProjectTitelhoofd.standaardBtwTarief;
}

String _beperkTotCijfers(
  String waarde, {
  required int maxLengte,
  String standaardWaarde = '',
}) {
  final cijfers = waarde.replaceAll(RegExp(r'\D'), '');

  if (cijfers.isEmpty) {
    return standaardWaarde;
  }

  if (cijfers.length <= maxLengte) {
    return cijfers;
  }

  return cijfers.substring(0, maxLengte);
}
