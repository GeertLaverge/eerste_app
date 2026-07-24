class AgendaItem {
  const AgendaItem({
    this.id = '',
    this.updatedAt = '',
    this.deletedAt = '',
    this.titel = '',
    this.type = 'afspraak',
    this.meldingVoorafMinuten = 60,
    this.klantNr = '',
    this.aanspreking = '',
    this.naamKlant = '',
    this.straatnaam = '',
    this.huisNr = '',
    this.busNr = '',
    this.gemeente = '',
    this.postcode = '',
    this.gsm = '',
    this.gsm2 = '',
    this.email = '',
    this.opmerkingen = '',
    this.kraanNodig = false,
    this.kraanIngepland = false,
    this.volledigeDag = false,
    this.startUur,
    this.startMinuut,
    this.eindUur,
    this.eindMinuut,
    this.homeWeergaveType = 'zelfdeDag',
    this.dagenVooraf = 0,
    this.homeDatum = '',
    this.heeftOverlap = false,
  });

  static const Object _ongewijzigd = Object();

  static const List<String> aansprekingKeuzes = <String>[
    'Dhr.',
    'Mevr.',
    'Dhr. & Mevr.',
  ];

  final String id;
  final String updatedAt;
  final String deletedAt;
  final String titel;
  final String type;
  final int meldingVoorafMinuten;

  final String klantNr;
  final String aanspreking;
  final String naamKlant;
  final String straatnaam;
  final String huisNr;
  final String busNr;
  final String gemeente;
  final String postcode;
  final String gsm;
  final String gsm2;
  final String email;
  final String opmerkingen;

  final bool kraanNodig;
  final bool kraanIngepland;

  final bool volledigeDag;
  final int? startUur;
  final int? startMinuut;
  final int? eindUur;
  final int? eindMinuut;

  /// Instelling voor de weergave van een dagtaak op de homepagina.
  /// Historische waarden zoals `dagenVooraf` en `datum` blijven tekstueel
  /// bewaard om bestaande agenda-JSON compatibel te houden.
  final String homeWeergaveType;
  final int dagenVooraf;
  final String homeDatum;

  /// Tijdelijke UI-markering die door de agenda-filtering gebruikt wordt.
  final bool heeftOverlap;

  String get syncId => id.trim().isNotEmpty ? id.trim() : _legacySyncId;

  bool get isVerwijderd => deletedAt.trim().isNotEmpty;

  String get busNummer => busNr;

  bool get heeftTijd {
    return !volledigeDag &&
        startUur != null &&
        startMinuut != null &&
        eindUur != null &&
        eindMinuut != null;
  }

  int get startMinuten {
    return (startUur ?? 0) * 60 + (startMinuut ?? 0);
  }

  int get eindMinuten {
    return (eindUur ?? 0) * 60 + (eindMinuut ?? 0);
  }

  String get tijdTekst {
    if (!heeftTijd) {
      return '';
    }

    return '${_tijdDeel(startUur!, startMinuut!)} - '
        '${_tijdDeel(eindUur!, eindMinuut!)}';
  }

  String get _legacySyncId {
    return <String>[
      type.trim(),
      titel.trim(),
      naamKlant.trim(),
      klantNr.trim(),
      kraanNodig.toString(),
      kraanIngepland.toString(),
      startUur?.toString() ?? '',
      startMinuut?.toString() ?? '',
      eindUur?.toString() ?? '',
      eindMinuut?.toString() ?? '',
    ].join('|');
  }

  AgendaItem copyWith({
    String? id,
    String? updatedAt,
    String? deletedAt,
    String? titel,
    String? type,
    int? meldingVoorafMinuten,
    String? klantNr,
    String? aanspreking,
    String? naamKlant,
    String? straatnaam,
    String? huisNr,
    String? busNr,
    String? gemeente,
    String? postcode,
    String? gsm,
    String? gsm2,
    String? email,
    String? opmerkingen,
    bool? kraanNodig,
    bool? kraanIngepland,
    bool? volledigeDag,
    Object? startUur = _ongewijzigd,
    Object? startMinuut = _ongewijzigd,
    Object? eindUur = _ongewijzigd,
    Object? eindMinuut = _ongewijzigd,
    String? homeWeergaveType,
    int? dagenVooraf,
    String? homeDatum,
    bool? heeftOverlap,
  }) {
    return AgendaItem(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      titel: titel ?? this.titel,
      type: type ?? this.type,
      meldingVoorafMinuten: meldingVoorafMinuten ?? this.meldingVoorafMinuten,
      klantNr: klantNr ?? this.klantNr,
      aanspreking: aanspreking ?? this.aanspreking,
      naamKlant: naamKlant ?? this.naamKlant,
      straatnaam: straatnaam ?? this.straatnaam,
      huisNr: huisNr ?? this.huisNr,
      busNr: busNr ?? this.busNr,
      gemeente: gemeente ?? this.gemeente,
      postcode: postcode ?? this.postcode,
      gsm: gsm ?? this.gsm,
      gsm2: gsm2 ?? this.gsm2,
      email: email ?? this.email,
      opmerkingen: opmerkingen ?? this.opmerkingen,
      kraanNodig: kraanNodig ?? this.kraanNodig,
      kraanIngepland: kraanIngepland ?? this.kraanIngepland,
      volledigeDag: volledigeDag ?? this.volledigeDag,
      startUur: identical(startUur, _ongewijzigd)
          ? this.startUur
          : startUur as int?,
      startMinuut: identical(startMinuut, _ongewijzigd)
          ? this.startMinuut
          : startMinuut as int?,
      eindUur: identical(eindUur, _ongewijzigd)
          ? this.eindUur
          : eindUur as int?,
      eindMinuut: identical(eindMinuut, _ongewijzigd)
          ? this.eindMinuut
          : eindMinuut as int?,
      homeWeergaveType: homeWeergaveType ?? this.homeWeergaveType,
      dagenVooraf: dagenVooraf ?? this.dagenVooraf,
      homeDatum: homeDatum ?? this.homeDatum,
      heeftOverlap: heeftOverlap ?? this.heeftOverlap,
    );
  }

  AgendaItem copyWithTijd({
    Object? startUur = _ongewijzigd,
    Object? startMinuut = _ongewijzigd,
    Object? eindUur = _ongewijzigd,
    Object? eindMinuut = _ongewijzigd,
    bool? volledigeDag,
  }) {
    return copyWith(
      startUur: startUur,
      startMinuut: startMinuut,
      eindUur: eindUur,
      eindMinuut: eindMinuut,
      volledigeDag: volledigeDag,
    );
  }

  AgendaItem metNieuweWijzigingsDatum({bool? isVerwijderd}) {
    final nu = DateTime.now().toUtc().toIso8601String();

    return copyWith(
      updatedAt: nu,
      deletedAt: isVerwijderd == null
          ? deletedAt
          : isVerwijderd
          ? nu
          : '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
      'titel': titel,
      'type': type,
      'meldingVoorafMinuten': meldingVoorafMinuten,
      'klantNr': klantNr,
      'aanspreking': _normaliseerAanspreking(aanspreking),
      'naamKlant': naamKlant,
      'straatnaam': straatnaam,
      'huisNr': huisNr,
      'busNr': busNr,
      'gemeente': gemeente,
      'postcode': postcode,
      'gsm': gsm,
      'gsm2': gsm2,
      'email': email,
      'opmerkingen': opmerkingen,
      'kraanNodig': kraanNodig,
      'kraanIngepland': kraanIngepland,
      'volledigeDag': volledigeDag,
      'startUur': startUur,
      'startMinuut': startMinuut,
      'eindUur': eindUur,
      'eindMinuut': eindMinuut,
      'homeWeergaveType': homeWeergaveType,
      'dagenVooraf': dagenVooraf,
      'homeDatum': homeDatum,
      'heeftOverlap': heeftOverlap,
    };
  }

  factory AgendaItem.fromJson(Map<String, dynamic> json) {
    return AgendaItem(
      id: _leesTekst(json, const <String>['id', 'itemId']),
      updatedAt: _leesTekst(json, const <String>[
        'updatedAt',
        'gewijzigdOp',
        'updated_at',
      ]),
      deletedAt: _leesDeletedAt(json),
      titel: _leesTekst(json, const <String>['titel', 'title']),
      type: _leesTekst(json, const <String>[
        'type',
        'soort',
        'agendaType',
      ], standaardWaarde: 'afspraak'),
      meldingVoorafMinuten: _leesInt(
        json['meldingVoorafMinuten'] ?? json['meldingMinuten'],
        standaardWaarde: 60,
      ),
      klantNr: _leesTekst(json, const <String>[
        'klantNr',
        'klantnummer',
        'klantNummer',
      ]),
      aanspreking: _normaliseerAanspreking(
        _leesTekst(json, const <String>['aanspreking', 'aanhef', 'salutation']),
      ),
      naamKlant: _leesTekst(json, const <String>[
        'naamKlant',
        'klantNaam',
        'naam',
      ]),
      straatnaam: _leesTekst(json, const <String>[
        'straatnaam',
        'straat',
        'adres',
      ]),
      huisNr: _leesTekst(json, const <String>[
        'huisNr',
        'huisnummer',
        'nummer',
      ]),
      busNr: _leesTekst(json, const <String>[
        'busNr',
        'busNummer',
        'busnummer',
        'bus',
      ]),
      gemeente: _leesTekst(json, const <String>['gemeente', 'plaats']),
      postcode: _leesTekst(json, const <String>['postcode', 'postCode']),
      gsm: _leesTekst(json, const <String>['gsm', 'telefoon', 'phone']),
      gsm2: _leesTekst(json, const <String>[
        'gsm2',
        'tweedeGsm',
        'telefoon2',
        'phone2',
      ]),
      email: _leesTekst(json, const <String>['email', 'eMail', 'mail']),
      opmerkingen: _leesTekst(json, const <String>[
        'opmerkingen',
        'omschrijving',
        'notities',
      ]),
      kraanNodig: _leesBool(json['kraanNodig']),
      kraanIngepland: _leesBool(json['kraanIngepland']),
      volledigeDag: _leesBool(json['volledigeDag'] ?? json['allDay']),
      startUur: _leesNullableInt(json['startUur']),
      startMinuut: _leesNullableInt(json['startMinuut']),
      eindUur: _leesNullableInt(json['eindUur']),
      eindMinuut: _leesNullableInt(json['eindMinuut']),
      homeWeergaveType: _leesTekst(json, const <String>[
        'homeWeergaveType',
        'homeType',
      ], standaardWaarde: 'zelfdeDag'),
      dagenVooraf: _leesInt(json['dagenVooraf'], standaardWaarde: 0),
      homeDatum: _leesTekst(json, const <String>['homeDatum', 'datumHome']),
      heeftOverlap: _leesBool(json['heeftOverlap']),
    );
  }

  static String _tijdDeel(int uur, int minuut) {
    return '${uur.toString().padLeft(2, '0')}:'
        '${minuut.toString().padLeft(2, '0')}';
  }

  static String _leesDeletedAt(Map<String, dynamic> json) {
    final waarde = _leesTekst(json, const <String>[
      'deletedAt',
      'verwijderdOp',
      'deleted_at',
    ]);

    if (waarde.isNotEmpty) {
      return waarde;
    }

    final verwijderd = _leesBool(
      json['isVerwijderd'] ?? json['verwijderd'] ?? json['deleted'],
    );

    return verwijderd ? 'legacy-verwijderd' : '';
  }

  static String _normaliseerAanspreking(Object? waarde) {
    final tekst = waarde?.toString().trim() ?? '';

    for (final keuze in aansprekingKeuzes) {
      if (keuze.toLowerCase() == tekst.toLowerCase()) {
        return keuze;
      }
    }

    return '';
  }

  static String _leesTekst(
    Map<String, dynamic> json,
    List<String> sleutels, {
    String standaardWaarde = '',
  }) {
    for (final sleutel in sleutels) {
      final tekst = json[sleutel]?.toString().trim() ?? '';

      if (tekst.isNotEmpty && tekst.toLowerCase() != 'null') {
        return tekst;
      }
    }

    return standaardWaarde;
  }

  static int _leesInt(Object? waarde, {required int standaardWaarde}) {
    if (waarde is int) {
      return waarde;
    }

    return int.tryParse(waarde?.toString() ?? '') ?? standaardWaarde;
  }

  static int? _leesNullableInt(Object? waarde) {
    if (waarde == null) {
      return null;
    }

    if (waarde is int) {
      return waarde;
    }

    return int.tryParse(waarde.toString());
  }

  static bool _leesBool(Object? waarde) {
    if (waarde is bool) {
      return waarde;
    }

    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    return tekst == 'true' || tekst == '1';
  }
}
