import 'offerte_prijs_categorie.dart';
import 'offerte_prijsregel_model.dart';

class OffertePrijsprofielModel {
  OffertePrijsprofielModel({
    required String formulierType,
    required String formulierNaam,
    List<OffertePrijsregelModel> prijsregels = const <OffertePrijsregelModel>[],
    double standaardPrijsPerStukExclBtw = 0,
    double standaardWinstmargePercentage = 0,
    double standaardKortingPercentage = 0,
    String gewijzigdOp = '',
  }) : formulierType = formulierType.trim(),
       formulierNaam = formulierNaam.trim(),
       prijsregels = List<OffertePrijsregelModel>.unmodifiable(
         _sorteerPrijsregels(prijsregels),
       ),
       standaardPrijsPerStukExclBtw = _normaliseerBedrag(
         standaardPrijsPerStukExclBtw,
       ),
       standaardWinstmargePercentage = _normaliseerPercentage(
         standaardWinstmargePercentage,
         maximum: 500,
       ),
       standaardKortingPercentage = _normaliseerPercentage(
         standaardKortingPercentage,
         maximum: 100,
       ),
       gewijzigdOp = gewijzigdOp.trim();

  final String formulierType;
  final String formulierNaam;
  final List<OffertePrijsregelModel> prijsregels;

  /// Standaardwaarden die vanuit het zwevende artikelprijsvenster kunnen
  /// worden bewaard. Nieuwe posities van dit formuliertype starten hiermee.
  final double standaardPrijsPerStukExclBtw;
  final double standaardWinstmargePercentage;
  final double standaardKortingPercentage;

  final String gewijzigdOp;

  bool get heeftStandaardArtikelPrijsinstelling {
    return standaardPrijsPerStukExclBtw > 0 ||
        standaardWinstmargePercentage > 0 ||
        standaardKortingPercentage > 0;
  }

  factory OffertePrijsprofielModel.leeg({
    required String formulierType,
    required String formulierNaam,
  }) {
    return OffertePrijsprofielModel(
      formulierType: formulierType,
      formulierNaam: formulierNaam,
    );
  }

  List<OffertePrijsregelModel> regelsVoorCategorie(
    OffertePrijsCategorie categorie,
  ) {
    return prijsregels
        .where((prijsregel) => prijsregel.categorie == categorie)
        .toList(growable: false);
  }

  int volgendeVolgordeVoorCategorie(OffertePrijsCategorie categorie) {
    final regels = regelsVoorCategorie(categorie);

    if (regels.isEmpty) {
      return 0;
    }

    final hoogsteVolgorde = regels
        .map((regel) => regel.volgorde)
        .reduce((eerste, tweede) => eerste > tweede ? eerste : tweede);

    return hoogsteVolgorde + 10;
  }

  OffertePrijsprofielModel metPrijsregel(OffertePrijsregelModel prijsregel) {
    final bijgewerkteRegel = prijsregel.copyWith(
      formulierType: formulierType,
      gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
    );
    final nieuweRegels = List<OffertePrijsregelModel>.from(prijsregels);
    final index = nieuweRegels.indexWhere((regel) => regel.id == prijsregel.id);

    if (index >= 0) {
      nieuweRegels[index] = bijgewerkteRegel;
    } else {
      nieuweRegels.add(bijgewerkteRegel);
    }

    return copyWith(
      prijsregels: nieuweRegels,
      gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
    );
  }

  OffertePrijsprofielModel zonderPrijsregel(String prijsregelId) {
    final nieuweRegels = prijsregels
        .where((regel) => regel.id != prijsregelId)
        .toList(growable: false);

    return copyWith(
      prijsregels: nieuweRegels,
      gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
    );
  }

  OffertePrijsprofielModel metCategorieVolgorde({
    required OffertePrijsCategorie categorie,
    required List<String> prijsregelIds,
  }) {
    final volgordePerId = <String, int>{
      for (var index = 0; index < prijsregelIds.length; index++)
        prijsregelIds[index]: index * 10,
    };

    final nieuweRegels = prijsregels
        .map((regel) {
          if (regel.categorie != categorie) {
            return regel;
          }

          final nieuweVolgorde = volgordePerId[regel.id];
          if (nieuweVolgorde == null) {
            return regel;
          }

          return regel.copyWith(
            volgorde: nieuweVolgorde,
            gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
          );
        })
        .toList(growable: false);

    return copyWith(
      prijsregels: nieuweRegels,
      gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
    );
  }

  OffertePrijsprofielModel metStandaardArtikelPrijs({
    required double prijsPerStukExclBtw,
    required double winstmargePercentage,
    required double kortingPercentage,
  }) {
    return copyWith(
      standaardPrijsPerStukExclBtw: prijsPerStukExclBtw,
      standaardWinstmargePercentage: winstmargePercentage,
      standaardKortingPercentage: kortingPercentage,
      gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
    );
  }

  OffertePrijsprofielModel copyWith({
    String? formulierType,
    String? formulierNaam,
    List<OffertePrijsregelModel>? prijsregels,
    double? standaardPrijsPerStukExclBtw,
    double? standaardWinstmargePercentage,
    double? standaardKortingPercentage,
    String? gewijzigdOp,
  }) {
    return OffertePrijsprofielModel(
      formulierType: formulierType ?? this.formulierType,
      formulierNaam: formulierNaam ?? this.formulierNaam,
      prijsregels: prijsregels ?? this.prijsregels,
      standaardPrijsPerStukExclBtw:
          standaardPrijsPerStukExclBtw ?? this.standaardPrijsPerStukExclBtw,
      standaardWinstmargePercentage:
          standaardWinstmargePercentage ?? this.standaardWinstmargePercentage,
      standaardKortingPercentage:
          standaardKortingPercentage ?? this.standaardKortingPercentage,
      gewijzigdOp: gewijzigdOp ?? this.gewijzigdOp,
    );
  }

  OffertePrijsprofielModel metWijzigingsDatum() {
    return copyWith(gewijzigdOp: DateTime.now().toUtc().toIso8601String());
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'formulierType': formulierType,
      'formulierNaam': formulierNaam,
      'prijsregels': prijsregels
          .map((prijsregel) => prijsregel.toJson())
          .toList(),
      'standaardPrijsPerStukExclBtw': standaardPrijsPerStukExclBtw,
      'standaardWinstmargePercentage': standaardWinstmargePercentage,
      'standaardKortingPercentage': standaardKortingPercentage,
      'gewijzigdOp': gewijzigdOp,
    };
  }

  factory OffertePrijsprofielModel.fromJson(Map<String, dynamic> json) {
    final ruwePrijsregels = json['prijsregels'];
    final prijsregels = <OffertePrijsregelModel>[];

    if (ruwePrijsregels is List) {
      for (final item in ruwePrijsregels.whereType<Map>()) {
        try {
          final prijsregel = OffertePrijsregelModel.fromJson(
            Map<String, dynamic>.from(item),
          );

          if (prijsregel.isGeldig) {
            prijsregels.add(prijsregel);
          }
        } catch (_) {
          // Een ongeldige individuele prijsregel mag het profiel niet blokkeren.
        }
      }
    }

    return OffertePrijsprofielModel(
      formulierType: json['formulierType']?.toString() ?? '',
      formulierNaam: json['formulierNaam']?.toString() ?? '',
      prijsregels: prijsregels,
      standaardPrijsPerStukExclBtw: _leesDouble(
        json['standaardPrijsPerStukExclBtw'],
      ),
      standaardWinstmargePercentage: _leesDouble(
        json['standaardWinstmargePercentage'],
      ),
      standaardKortingPercentage: _leesDouble(
        json['standaardKortingPercentage'],
      ),
      gewijzigdOp: json['gewijzigdOp']?.toString() ?? '',
    );
  }

  static List<OffertePrijsregelModel> _sorteerPrijsregels(
    List<OffertePrijsregelModel> prijsregels,
  ) {
    final resultaat = List<OffertePrijsregelModel>.from(prijsregels);

    resultaat.sort((eerste, tweede) {
      final categorieVergelijking = eerste.categorie.index.compareTo(
        tweede.categorie.index,
      );
      if (categorieVergelijking != 0) {
        return categorieVergelijking;
      }

      final volgordeVergelijking = eerste.volgorde.compareTo(tweede.volgorde);
      if (volgordeVergelijking != 0) {
        return volgordeVergelijking;
      }

      return eerste.omschrijving.toLowerCase().compareTo(
        tweede.omschrijving.toLowerCase(),
      );
    });

    return resultaat;
  }

  static double _normaliseerBedrag(double waarde) {
    if (!waarde.isFinite || waarde <= 0) {
      return 0;
    }
    return (waarde * 100).roundToDouble() / 100;
  }

  static double _normaliseerPercentage(
    double waarde, {
    required double maximum,
  }) {
    if (!waarde.isFinite || waarde <= 0) {
      return 0;
    }
    final begrensd = waarde.clamp(0, maximum).toDouble();
    return (begrensd * 100).roundToDouble() / 100;
  }

  static double _leesDouble(Object? waarde) {
    if (waarde is num) {
      return waarde.toDouble();
    }
    return double.tryParse(
          waarde?.toString().trim().replaceAll(',', '.') ?? '',
        ) ??
        0;
  }
}
