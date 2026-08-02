// THIMACO-CONTROLE: ALGEMENE-OPMETING-PRIJSVERDELING-20260802
import '../fotos/opmeting_foto_model.dart';
import 'opmeting_algemene_opmeting_blok_model.dart';

class OpmetingAlgemeneOpmetingModel {
  const OpmetingAlgemeneOpmetingModel({
    this.titel = '',
    this.omschrijving = '',
    this.blokken = const <OpmetingAlgemeneOpmetingBlok>[],
    this.fotos = const <OpmetingFoto>[],
  });

  final String titel;
  final String omschrijving;
  final List<OpmetingAlgemeneOpmetingBlok> blokken;
  final List<OpmetingFoto> fotos;

  List<OpmetingAlgemeneOpmetingBlok> get zichtbareBlokken {
    return blokken.where((blok) => blok.toonOpOfferte).toList(growable: false);
  }

  List<OpmetingAlgemeneOpmetingBlok> get prijsBlokken {
    return blokken.where((blok) => blok.isPrijs).toList(growable: false);
  }

  List<OpmetingAlgemeneOpmetingBlok> get aankoopPrijsBlokken {
    return prijsBlokken
        .where((blok) => blok.isAankoopprijs)
        .toList(growable: false);
  }

  List<OpmetingAlgemeneOpmetingBlok> get verkoopPrijsBlokken {
    return prijsBlokken
        .where((blok) => blok.isVerkoopprijs)
        .toList(growable: false);
  }

  double get aankoopPrijsTotaalExclBtw {
    return _rondBedragAf(
      aankoopPrijsBlokken.fold<double>(
        0,
        (som, blok) => som + blok.totaalExclBtw,
      ),
    );
  }

  double get verkoopPrijsTotaalExclBtw {
    return _rondBedragAf(
      verkoopPrijsBlokken.fold<double>(
        0,
        (som, blok) => som + blok.totaalExclBtw,
      ),
    );
  }

  double get prijsTotaalExclBtw {
    return _rondBedragAf(aankoopPrijsTotaalExclBtw + verkoopPrijsTotaalExclBtw);
  }

  String get effectieveTitel {
    final waarde = titel.trim();
    return waarde.isEmpty ? 'Algemene opmeting' : waarde;
  }

  OpmetingAlgemeneOpmetingModel copyWith({
    String? titel,
    String? omschrijving,
    List<OpmetingAlgemeneOpmetingBlok>? blokken,
    List<OpmetingFoto>? fotos,
  }) {
    return OpmetingAlgemeneOpmetingModel(
      titel: titel ?? this.titel,
      omschrijving: omschrijving ?? this.omschrijving,
      blokken: blokken ?? this.blokken,
      fotos: fotos ?? this.fotos,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'titel': titel,
      'omschrijving': omschrijving,
      'blokken': blokken.map((blok) => blok.toJson()).toList(growable: false),
      'fotos': fotos.map((foto) => foto.toJson()).toList(growable: false),
    };
  }

  factory OpmetingAlgemeneOpmetingModel.fromJson(Map<String, dynamic> json) {
    return OpmetingAlgemeneOpmetingModel(
      titel: json['titel']?.toString() ?? '',
      omschrijving: json['omschrijving']?.toString() ?? '',
      blokken: _leesLijst(
        json['blokken'],
        OpmetingAlgemeneOpmetingBlok.fromJson,
      ),
      fotos: _leesLijst(json['fotos'], OpmetingFoto.fromJson),
    );
  }

  static double _rondBedragAf(double waarde) {
    if (!waarde.isFinite || waarde <= 0) return 0;
    return (waarde * 100).roundToDouble() / 100;
  }
}

List<T> _leesLijst<T>(
  Object? waarde,
  T Function(Map<String, dynamic> json) maker,
) {
  if (waarde is! List) return <T>[];
  return waarde
      .whereType<Map>()
      .map((item) {
        return maker(Map<String, dynamic>.from(item));
      })
      .toList(growable: false);
}
