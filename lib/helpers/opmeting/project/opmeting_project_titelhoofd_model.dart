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
    this.kleurAfwijking = '',
    this.opmerking = '',
    this.gewijzigdOp = '',
  });

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
  final String kleurAfwijking;
  final String opmerking;
  final String gewijzigdOp;

  String get plaats {
    return <String>[
      postcode.trim(),
      gemeente.trim(),
    ].where((deel) => deel.isNotEmpty).join(' ');
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
        email.trim().isNotEmpty;
  }

  bool get heeftProjectKleuren {
    return projectKleurBinnen.trim().isNotEmpty ||
        projectKleurBuiten.trim().isNotEmpty;
  }

  bool get heeftKleurAfwijking {
    return kleurAfwijking.trim().isNotEmpty;
  }

  bool get isLeeg {
    return !heeftKlantGegevens &&
        !heeftProjectKleuren &&
        kleurAfwijking.trim().isEmpty &&
        opmerking.trim().isEmpty;
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
    String? kleurAfwijking,
    String? opmerking,
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
      kleurAfwijking: kleurAfwijking ?? this.kleurAfwijking,
      opmerking: opmerking ?? this.opmerking,
      gewijzigdOp: gewijzigdOp ?? this.gewijzigdOp,
    );
  }

  OpmetingProjectTitelhoofd metWijzigingsDatum() {
    return copyWith(gewijzigdOp: DateTime.now().toUtc().toIso8601String());
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
      'kleurAfwijking': kleurAfwijking,
      'opmerking': opmerking,
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
      kleurAfwijking: json['kleurAfwijking']?.toString() ?? '',
      opmerking: json['opmerking']?.toString() ?? '',
      gewijzigdOp: json['gewijzigdOp']?.toString() ?? '',
    );
  }
}

class OpmetingAgendaKlantInfo {
  const OpmetingAgendaKlantInfo({
    required this.klantNaam,
    this.contactpersoon = '',
    this.adres = '',
    this.postcode = '',
    this.gemeente = '',
    this.gsm = '',
    this.telefoon = '',
    this.email = '',
    this.omschrijving = '',
    this.datumKey = '',
  });

  final String klantNaam;
  final String contactpersoon;
  final String adres;
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

  String get zoekTekst {
    return <String>[
      klantNaam,
      contactpersoon,
      adres,
      postcode,
      gemeente,
      gsm,
      telefoon,
      email,
      omschrijving,
      datumKey,
    ].join(' ').toLowerCase();
  }

  OpmetingProjectTitelhoofd naarTitelhoofd({
    OpmetingProjectTitelhoofd? bestaand,
  }) {
    final huidige = bestaand ?? const OpmetingProjectTitelhoofd();

    return huidige.copyWith(
      klantNaam: klantNaam.trim().isEmpty ? huidige.klantNaam : klantNaam,
      contactpersoon: contactpersoon.trim().isEmpty
          ? huidige.contactpersoon
          : contactpersoon,
      adres: adres.trim().isEmpty ? huidige.adres : adres,
      postcode: postcode.trim().isEmpty ? huidige.postcode : postcode,
      gemeente: gemeente.trim().isEmpty ? huidige.gemeente : gemeente,
      gsm: gsm.trim().isEmpty ? huidige.gsm : gsm,
      telefoon: telefoon.trim().isEmpty ? huidige.telefoon : telefoon,
      email: email.trim().isEmpty ? huidige.email : email,
      opmerking: omschrijving.trim().isEmpty ? huidige.opmerking : omschrijving,
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
