import 'agenda_tijd_helper.dart';

class AgendaItem {
  final String titel;
  final String type;

  final String klantNr;
  final String naamKlant;

  final String straatnaam;
  final String huisNr;

  final String gemeente;
  final String postcode;

  final String gsm;
  final String gsm2;

  final String email;

  final String opmerkingen;

  final int? startUur;
  final int? startMinuut;

  final int? eindUur;
  final int? eindMinuut;

  final bool volledigeDag;
  final bool heeftOverlap;

  final String homeWeergaveType;

  final int dagenVooraf;

  final String homeDatum;

  final int meldingVoorafMinuten;

  const AgendaItem({
    required this.titel,
    required this.type,
    this.klantNr = '',
    this.naamKlant = '',
    this.straatnaam = '',
    this.huisNr = '',
    this.gemeente = '',
    this.postcode = '',
    this.gsm = '',
    this.gsm2 = '',
    this.email = '',
    this.opmerkingen = '',
    this.startUur,
    this.startMinuut,
    this.eindUur,
    this.eindMinuut,
    this.volledigeDag = false,
    this.heeftOverlap = false,
    this.homeWeergaveType = '',
    this.dagenVooraf = 0,
    this.homeDatum = '',
    this.meldingVoorafMinuten = 60,
  });

  bool get heeftTijd {
    return startUur != null &&
        startMinuut != null &&
        eindUur != null &&
        eindMinuut != null;
  }

  int get startMinuten {
    if (volledigeDag) return -1;

    if (!heeftTijd) {
      return 99999;
    }

    return (startUur! * 60) + startMinuut!;
  }

  String get tijdTekst {
    if (volledigeDag) {
      return '';
    }

    if (!heeftTijd) {
      return '';
    }

    final start = AgendaTijdHelper.tijdTekst(
      uur: startUur!,
      minuut: startMinuut!,
    );

    final einde = AgendaTijdHelper.tijdTekst(
      uur: eindUur!,
      minuut: eindMinuut!,
    );

    return '$start\n$einde';
  }

  AgendaItem copyWith({
    bool? heeftOverlap,
    String? homeWeergaveType,
    int? dagenVooraf,
    String? homeDatum,
    int? meldingVoorafMinuten,
  }) {
    return AgendaItem(
      titel: titel,
      type: type,
      klantNr: klantNr,
      naamKlant: naamKlant,
      straatnaam: straatnaam,
      huisNr: huisNr,
      gemeente: gemeente,
      postcode: postcode,
      gsm: gsm,
      gsm2: gsm2,
      email: email,
      opmerkingen: opmerkingen,
      startUur: startUur,
      startMinuut: startMinuut,
      eindUur: eindUur,
      eindMinuut: eindMinuut,
      volledigeDag: volledigeDag,
      heeftOverlap: heeftOverlap ?? this.heeftOverlap,
      homeWeergaveType: homeWeergaveType ?? this.homeWeergaveType,
      dagenVooraf: dagenVooraf ?? this.dagenVooraf,
      homeDatum: homeDatum ?? this.homeDatum,
      meldingVoorafMinuten: meldingVoorafMinuten ?? this.meldingVoorafMinuten,
    );
  }

  AgendaItem copyWithTijd({
    required int startUur,
    required int startMinuut,
    required int eindUur,
    required int eindMinuut,
  }) {
    return AgendaItem(
      titel: titel,
      type: type,
      klantNr: klantNr,
      naamKlant: naamKlant,
      straatnaam: straatnaam,
      huisNr: huisNr,
      gemeente: gemeente,
      postcode: postcode,
      gsm: gsm,
      gsm2: gsm2,
      email: email,
      opmerkingen: opmerkingen,
      startUur: startUur,
      startMinuut: startMinuut,
      eindUur: eindUur,
      eindMinuut: eindMinuut,
      volledigeDag: false,
      heeftOverlap: heeftOverlap,
      homeWeergaveType: homeWeergaveType,
      dagenVooraf: dagenVooraf,
      homeDatum: homeDatum,
      meldingVoorafMinuten: meldingVoorafMinuten,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titel': titel,
      'type': type,
      'klantNr': klantNr,
      'naamKlant': naamKlant,
      'straatnaam': straatnaam,
      'huisNr': huisNr,
      'gemeente': gemeente,
      'postcode': postcode,
      'gsm': gsm,
      'gsm2': gsm2,
      'email': email,
      'opmerkingen': opmerkingen,
      'startUur': startUur,
      'startMinuut': startMinuut,
      'eindUur': eindUur,
      'eindMinuut': eindMinuut,
      'volledigeDag': volledigeDag,
      'homeWeergaveType': homeWeergaveType,
      'dagenVooraf': dagenVooraf,
      'homeDatum': homeDatum,
      'meldingVoorafMinuten': meldingVoorafMinuten,
    };
  }

  factory AgendaItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return AgendaItem(
      titel: json['titel'] ?? '',
      type: json['type'] ?? 'afspraak',
      klantNr: json['klantNr'] ?? '',
      naamKlant: json['naamKlant'] ?? '',
      straatnaam: json['straatnaam'] ?? '',
      huisNr: json['huisNr'] ?? '',
      gemeente: json['gemeente'] ?? '',
      postcode: json['postcode'] ?? '',
      gsm: json['gsm'] ?? '',
      gsm2: json['gsm2'] ?? '',
      email: json['email'] ?? '',
      opmerkingen: json['opmerkingen'] ?? '',
      startUur: json['startUur'],
      startMinuut: json['startMinuut'],
      eindUur: json['eindUur'],
      eindMinuut: json['eindMinuut'],
      volledigeDag: json['volledigeDag'] ?? false,
      heeftOverlap: json['heeftOverlap'] ?? false,
      homeWeergaveType: json['homeWeergaveType'] ?? '',
      dagenVooraf: json['dagenVooraf'] ?? 0,
      homeDatum: json['homeDatum'] ?? '',
      meldingVoorafMinuten: json['meldingVoorafMinuten'] ?? 0,
    );
  }
}
