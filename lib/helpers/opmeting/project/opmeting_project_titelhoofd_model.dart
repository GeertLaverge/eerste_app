import '../../offerte/prijzen/offerte_prijsinstellingen_momentopname.dart';
import '../../offerte/prijzen/offerte_prijs_categorie.dart';
import '../../offerte/prijzen/offerte_prijsregel_model.dart';

class OpmetingProjectTitelhoofd {
  const OpmetingProjectTitelhoofd({
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
    this.projectKleurBinnen = '',
    this.projectKleurBuiten = '',
    this.ralKleurToebehoren = '',
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
    this.gewijzigdOp = '',
  });

  static const String standaardBtwTarief = '21 %';
  static const String standaardOfferteJaar = '26';
  static const String standaardOfferteVolgnummer = '01';
  static const String standaardKortingOmschrijving = 'Korting';

  static const List<String> btwTarieven = <String>[
    '6 %',
    '21 %',
    'BTW verlegd',
  ];

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
  final String projectKleurBinnen;
  final String projectKleurBuiten;
  final String ralKleurToebehoren;
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
  final String gewijzigdOp;

  String get plaats {
    return <String>[
      postcode.trim(),
      gemeente.trim(),
    ].where((deel) => deel.isNotEmpty).join(' ');
  }

  String get samengesteldOffertenummer {
    return '$offerteJaar$klantnummer$offerteVolgnummer';
  }

  bool get heeftKlantGegevens {
    return klantNaam.trim().isNotEmpty ||
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
        !heeftProjectKleuren &&
        kleurAfwijking.trim().isEmpty &&
        tijdelijkeProjectPrijsregels.isEmpty &&
        !berekenPrijzen;
  }

  OpmetingProjectTitelhoofd copyWith({
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
    String? projectKleurBinnen,
    String? projectKleurBuiten,
    String? ralKleurToebehoren,
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
    String? gewijzigdOp,
  }) {
    return OpmetingProjectTitelhoofd(
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
      projectKleurBinnen: projectKleurBinnen ?? this.projectKleurBinnen,
      projectKleurBuiten: projectKleurBuiten ?? this.projectKleurBuiten,
      ralKleurToebehoren: ralKleurToebehoren ?? this.ralKleurToebehoren,
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
      'projectKleurBinnen': projectKleurBinnen,
      'projectKleurBuiten': projectKleurBuiten,
      'ralKleurToebehoren': ralKleurToebehoren,
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
      'gewijzigdOp': gewijzigdOp,
    };
  }

  factory OpmetingProjectTitelhoofd.fromJson(Map<String, dynamic> json) {
    return OpmetingProjectTitelhoofd(
      klantNaam: json['klantNaam']?.toString() ?? '',
      contactpersoon: json['contactpersoon']?.toString() ?? '',
      adres: json['adres']?.toString() ?? '',
      huisnummer: json['huisnummer']?.toString() ?? '',
      busNummer: json['busNummer']?.toString() ?? '',
      postcode: json['postcode']?.toString() ?? '',
      gemeente: json['gemeente']?.toString() ?? '',
      gsm: json['gsm']?.toString() ?? '',
      telefoon: json['telefoon']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      projectKleurBinnen: json['projectKleurBinnen']?.toString() ?? '',
      projectKleurBuiten: json['projectKleurBuiten']?.toString() ?? '',
      ralKleurToebehoren:
          json['ralKleurToebehoren']?.toString() ??
          json['projectKleurToebehoren']?.toString() ??
          '',
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
      gewijzigdOp: json['gewijzigdOp']?.toString() ?? '',
    );
  }
}

class OpmetingAgendaKlantInfo {
  const OpmetingAgendaKlantInfo({
    required this.klantNaam,
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

  OpmetingAgendaKlantInfo combineerMet(OpmetingAgendaKlantInfo ander) {
    String kies(String huidig, String nieuw) {
      return huidig.trim().isNotEmpty ? huidig : nieuw;
    }

    return OpmetingAgendaKlantInfo(
      klantNaam: kies(klantNaam, ander.klantNaam),
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
      klantNaam: klantNaam.trim().isEmpty ? huidige.klantNaam : klantNaam,
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

String opmetingProjectTitelhoofdSleutel(String klantNaam) {
  final sleutel = klantNaam.trim().toLowerCase().replaceAll(
    RegExp(r'\s+'),
    ' ',
  );

  return sleutel.isEmpty ? 'zonder_klantnaam' : sleutel;
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
