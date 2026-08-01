import '../../fotos/opmeting_foto_model.dart';
import 'opmeting_uitvalscherm_maatbeperking_helper.dart';

enum OpmetingUitvalschermType { type700LX, type700X, type500X }

extension OpmetingUitvalschermTypeExtension on OpmetingUitvalschermType {
  String get id {
    switch (this) {
      case OpmetingUitvalschermType.type700LX:
        return '700LX';
      case OpmetingUitvalschermType.type700X:
        return '700X';
      case OpmetingUitvalschermType.type500X:
        return '500X';
    }
  }

  String get label {
    switch (this) {
      case OpmetingUitvalschermType.type700LX:
        return '700 LX';
      case OpmetingUitvalschermType.type700X:
        return '700 X';
      case OpmetingUitvalschermType.type500X:
        return '500 X';
    }
  }

  bool get is700LX => this == OpmetingUitvalschermType.type700LX;
  bool get is500X => this == OpmetingUitvalschermType.type500X;

  static OpmetingUitvalschermType vanOpslagWaarde(Object? waarde) {
    final tekst =
        waarde?.toString().trim().toUpperCase().replaceAll(' ', '') ?? '';
    if (tekst == '700LX' || tekst == 'TYPE700LX') {
      return OpmetingUitvalschermType.type700LX;
    }
    if (tekst == '500X' || tekst == 'TYPE500X') {
      return OpmetingUitvalschermType.type500X;
    }
    return OpmetingUitvalschermType.type700X;
  }
}

enum OpmetingUitvalschermKleurbron { projectKleur, standaardPoederkleur }

extension OpmetingUitvalschermKleurbronExtension
    on OpmetingUitvalschermKleurbron {
  String get label => this == OpmetingUitvalschermKleurbron.projectKleur
      ? 'Projectkleur'
      : 'Standaard poederkleur';

  static OpmetingUitvalschermKleurbron vanOpslagWaarde(Object? waarde) {
    final tekst = waarde?.toString().trim().toLowerCase() ?? '';
    return tekst.contains('project')
        ? OpmetingUitvalschermKleurbron.projectKleur
        : OpmetingUitvalschermKleurbron.standaardPoederkleur;
  }
}

class OpmetingUitvalschermModel {
  const OpmetingUitvalschermModel({
    this.positie = '',
    this.aantal = 1,
    this.type = OpmetingUitvalschermType.type700X,
    this.breedteMm = 4000,
    this.uitvalMm = 3000,
    this.kleurbron = OpmetingUitvalschermKleurbron.standaardPoederkleur,
    this.projectKleurWaarde = '',
    this.draagstructuurKleur = '',
    this.draagstructuurKleurCode = '',
    this.doekCode = 'D309',
    this.doekKleur = 'Manosque Grey',
    this.doekHex = '#8C8C8A',
    this.volant = false,
    this.volantHoogteMm = 0,
    this.motorType = 'Draadloos',
    this.motorMerk = 'SOMFY',
    this.motorOmschrijving = 'Sunea 50 IO 40/17',
    this.bediening = 'Handzender Somfy Situo 1',
    this.kabellengteMeter = 5,
    this.uitgang = 'Links',
    this.eolis3D = false,
    this.notities = '',
    this.fotos = const <OpmetingFoto>[],
  });

  static const int aantalMinimum = 1;
  static const int aantalMaximum = 100;

  final String positie;
  final int aantal;
  final OpmetingUitvalschermType type;
  final int breedteMm;
  final int uitvalMm;
  final OpmetingUitvalschermKleurbron kleurbron;
  final String projectKleurWaarde;
  final String draagstructuurKleur;
  final String draagstructuurKleurCode;
  final String doekCode;
  final String doekKleur;
  final String doekHex;
  final bool volant;
  final int volantHoogteMm;
  final String motorType;
  final String motorMerk;
  final String motorOmschrijving;
  final String bediening;
  final int kabellengteMeter;
  final String uitgang;
  final bool eolis3D;
  final String notities;
  final List<OpmetingFoto> fotos;

  int get maximumBreedteMm =>
      OpmetingUitvalschermMaatbeperkingHelper.maximumBreedteMm(type.id);

  int get maximumUitvalMm =>
      OpmetingUitvalschermMaatbeperkingHelper.maximumUitvalMm(
        typeId: type.id,
        breedteMm: breedteMm,
      );

  List<int> get toegestaneUitvallen =>
      OpmetingUitvalschermMaatbeperkingHelper.toegestaneUitvallen(
        typeId: type.id,
        breedteMm: breedteMm,
      );

  String get maatSamenvatting => '$breedteMm × $uitvalMm mm';
  String get bedieningElektrisch => 'Elektrisch';
  String get kabellengteSamenvatting => '$kabellengteMeter m';

  String get kleurSamenvatting {
    if (kleurbron == OpmetingUitvalschermKleurbron.projectKleur) {
      final waarde = projectKleurWaarde.trim();
      return waarde.isEmpty ? 'Projectkleur nog te kiezen' : waarde;
    }
    final delen = <String>[
      draagstructuurKleur.trim(),
      draagstructuurKleurCode.trim(),
    ].where((deel) => deel.isNotEmpty).toList(growable: false);
    return delen.isEmpty ? 'Nog te bepalen' : delen.join(' · ');
  }

  String get doekSamenvatting {
    final delen = <String>[
      doekCode.trim(),
      doekKleur.trim(),
    ].where((deel) => deel.isNotEmpty).toList(growable: false);
    return delen.isEmpty ? 'Nog te bepalen' : delen.join(' · ');
  }

  String get motorSamenvatting {
    final delen = <String>[
      motorType.trim(),
      motorMerk.trim(),
      motorOmschrijving.trim(),
    ].where((deel) => deel.isNotEmpty).toList(growable: false);
    return delen.isEmpty ? 'Nog te bepalen' : delen.join(' · ');
  }

  String get lxOmschrijving =>
      'Uitvalscherm met directe en indirecte verlichting, handzender Situo 5 var inbegrepen';

  OpmetingUitvalschermModel copyWith({
    String? positie,
    int? aantal,
    OpmetingUitvalschermType? type,
    int? breedteMm,
    int? uitvalMm,
    OpmetingUitvalschermKleurbron? kleurbron,
    String? projectKleurWaarde,
    String? draagstructuurKleur,
    String? draagstructuurKleurCode,
    String? doekCode,
    String? doekKleur,
    String? doekHex,
    bool? volant,
    int? volantHoogteMm,
    String? motorType,
    String? motorMerk,
    String? motorOmschrijving,
    String? bediening,
    int? kabellengteMeter,
    String? uitgang,
    bool? eolis3D,
    String? notities,
    List<OpmetingFoto>? fotos,
  }) {
    final nieuwType = type ?? this.type;
    final nieuweBreedte =
        OpmetingUitvalschermMaatbeperkingHelper.normaliseerBreedte(
          typeId: nieuwType.id,
          waarde: breedteMm ?? this.breedteMm,
        );
    final nieuweUitval =
        OpmetingUitvalschermMaatbeperkingHelper.normaliseerUitval(
          typeId: nieuwType.id,
          breedteMm: nieuweBreedte,
          waarde: uitvalMm ?? this.uitvalMm,
        );

    var nieuwMotorType = motorType ?? this.motorType;
    var nieuwMotorMerk = motorMerk ?? this.motorMerk;
    var nieuwMotorOmschrijving = motorOmschrijving ?? this.motorOmschrijving;
    var nieuweBediening = bediening ?? this.bediening;
    if (nieuwType.is700LX) {
      if (nieuwMotorType.trim().toLowerCase() != 'draadloos') {
        nieuwMotorType = 'Draadloos';
        nieuwMotorMerk = 'SOMFY';
        nieuwMotorOmschrijving = 'Sunea 50 IO 40/17';
      }
      nieuweBediening = 'Handzender Somfy Situo 5 Var';
    }

    final heeftVolant = volant ?? this.volant;
    return OpmetingUitvalschermModel(
      positie: positie ?? this.positie,
      aantal: (aantal ?? this.aantal)
          .clamp(aantalMinimum, aantalMaximum)
          .toInt(),
      type: nieuwType,
      breedteMm: nieuweBreedte,
      uitvalMm: nieuweUitval,
      kleurbron: kleurbron ?? this.kleurbron,
      projectKleurWaarde: projectKleurWaarde ?? this.projectKleurWaarde,
      draagstructuurKleur: draagstructuurKleur ?? this.draagstructuurKleur,
      draagstructuurKleurCode:
          draagstructuurKleurCode ?? this.draagstructuurKleurCode,
      doekCode: doekCode ?? this.doekCode,
      doekKleur: doekKleur ?? this.doekKleur,
      doekHex: _normaliseerHex(doekHex ?? this.doekHex),
      volant: heeftVolant,
      volantHoogteMm: heeftVolant
          ? (volantHoogteMm ?? this.volantHoogteMm).clamp(0, 999).toInt()
          : 0,
      motorType: nieuwMotorType,
      motorMerk: nieuwMotorMerk,
      motorOmschrijving: nieuwMotorOmschrijving,
      bediening: nieuweBediening,
      kabellengteMeter: (kabellengteMeter ?? this.kabellengteMeter) <= 5
          ? 5
          : 10,
      uitgang: uitgang ?? this.uitgang,
      eolis3D: eolis3D ?? this.eolis3D,
      notities: notities ?? this.notities,
      fotos: fotos ?? this.fotos,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'positie': positie,
    'aantal': aantal,
    'type': type.id,
    'breedteMm': breedteMm,
    'uitvalMm': uitvalMm,
    'kleurbron': kleurbron.name,
    'projectKleurWaarde': projectKleurWaarde,
    'draagstructuurKleur': draagstructuurKleur,
    'draagstructuurKleurCode': draagstructuurKleurCode,
    'doekCode': doekCode,
    'doekKleur': doekKleur,
    'doekHex': doekHex,
    'volant': volant,
    'volantHoogteMm': volantHoogteMm,
    'motorType': motorType,
    'motorMerk': motorMerk,
    'motorOmschrijving': motorOmschrijving,
    'bediening': bediening,
    'kabellengteMeter': kabellengteMeter,
    'uitgang': uitgang,
    'eolis3D': eolis3D,
    'notities': notities,
    'fotos': fotos.map((foto) => foto.toJson()).toList(growable: false),
  };

  factory OpmetingUitvalschermModel.fromJson(Map<String, dynamic> json) {
    return OpmetingUitvalschermModel(
      positie: json['positie']?.toString() ?? '',
      aantal: _leesInt(json['aantal'], 1),
      type: OpmetingUitvalschermTypeExtension.vanOpslagWaarde(json['type']),
      breedteMm: _leesInt(json['breedteMm'], 4000),
      uitvalMm: _leesInt(json['uitvalMm'], 3000),
      kleurbron: OpmetingUitvalschermKleurbronExtension.vanOpslagWaarde(
        json['kleurbron'],
      ),
      projectKleurWaarde: json['projectKleurWaarde']?.toString() ?? '',
      draagstructuurKleur: json['draagstructuurKleur']?.toString() ?? '',
      draagstructuurKleurCode:
          json['draagstructuurKleurCode']?.toString() ?? '',
      doekCode: json['doekCode']?.toString() ?? 'D309',
      doekKleur: json['doekKleur']?.toString() ?? 'Manosque Grey',
      doekHex: json['doekHex']?.toString() ?? '#8C8C8A',
      volant: json['volant'] == true,
      volantHoogteMm: _leesInt(json['volantHoogteMm'], 0),
      motorType: json['motorType']?.toString() ?? 'Draadloos',
      motorMerk: json['motorMerk']?.toString() ?? 'SOMFY',
      motorOmschrijving:
          json['motorOmschrijving']?.toString() ?? 'Sunea 50 IO 40/17',
      bediening: json['bediening']?.toString() ?? 'Handzender Somfy Situo 1',
      kabellengteMeter: _leesInt(json['kabellengteMeter'], 5),
      uitgang: json['uitgang']?.toString() ?? 'Links',
      eolis3D: json['eolis3D'] == true,
      notities: json['notities']?.toString() ?? '',
      fotos: _leesFotos(json['fotos']),
    ).copyWith();
  }

  static int _leesInt(Object? waarde, int standaard) {
    if (waarde is int) return waarde;
    if (waarde is num) return waarde.toInt();
    return int.tryParse(waarde?.toString() ?? '') ?? standaard;
  }

  static List<OpmetingFoto> _leesFotos(Object? waarde) {
    if (waarde is! List) return const <OpmetingFoto>[];
    return waarde
        .whereType<Map>()
        .map((item) => OpmetingFoto.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  static String _normaliseerHex(String waarde) {
    final zonder = waarde.trim().replaceFirst('#', '').toUpperCase();
    return RegExp(r'^[0-9A-F]{6}$').hasMatch(zonder) ? '#$zonder' : '#8C8C8A';
  }
}
