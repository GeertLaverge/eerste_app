import 'offerte_algemene_prijsregel_model.dart';

class OfferteAlgemenePrijsregelsModel {
  OfferteAlgemenePrijsregelsModel({
    List<OfferteAlgemenePrijsregelModel> prijsregels =
        const <OfferteAlgemenePrijsregelModel>[],
    String gewijzigdOp = '',
  }) : prijsregels = _normaliseerPrijsregels(prijsregels),
       gewijzigdOp = gewijzigdOp.trim();

  static const int huidigeSchemaVersie = 1;

  final List<OfferteAlgemenePrijsregelModel> prijsregels;
  final String gewijzigdOp;

  factory OfferteAlgemenePrijsregelsModel.leeg() {
    return OfferteAlgemenePrijsregelsModel();
  }

  bool get isLeeg => prijsregels.isEmpty;

  int get aantalActievePrijsregels {
    return prijsregels.where((prijsregel) => prijsregel.actief).length;
  }

  OfferteAlgemenePrijsregelsModel copyWith({
    List<OfferteAlgemenePrijsregelModel>? prijsregels,
    String? gewijzigdOp,
  }) {
    return OfferteAlgemenePrijsregelsModel(
      prijsregels: prijsregels ?? this.prijsregels,
      gewijzigdOp: gewijzigdOp ?? this.gewijzigdOp,
    );
  }

  OfferteAlgemenePrijsregelsModel metPrijsregel(
    OfferteAlgemenePrijsregelModel prijsregel,
  ) {
    final bijgewerkt = List<OfferteAlgemenePrijsregelModel>.from(prijsregels);
    final index = bijgewerkt.indexWhere(
      (bestaand) => bestaand.id == prijsregel.id,
    );
    final regelMetDatum = prijsregel.metWijzigingsDatum();

    if (index >= 0) {
      bijgewerkt[index] = regelMetDatum;
    } else {
      bijgewerkt.add(regelMetDatum);
    }

    return copyWith(
      prijsregels: bijgewerkt,
      gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
    );
  }

  OfferteAlgemenePrijsregelsModel zonderPrijsregel(String prijsregelId) {
    final id = prijsregelId.trim();

    if (id.isEmpty) {
      return this;
    }

    final bijgewerkt = prijsregels
        .where((prijsregel) => prijsregel.id != id)
        .toList(growable: false);

    if (bijgewerkt.length == prijsregels.length) {
      return this;
    }

    return copyWith(
      prijsregels: bijgewerkt,
      gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
    );
  }

  OfferteAlgemenePrijsregelsModel metWijzigingsDatum() {
    return copyWith(gewijzigdOp: DateTime.now().toUtc().toIso8601String());
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'schemaVersie': huidigeSchemaVersie,
      'prijsregels': prijsregels
          .map((prijsregel) => prijsregel.toJson())
          .toList(growable: false),
      'gewijzigdOp': gewijzigdOp,
    };
  }

  factory OfferteAlgemenePrijsregelsModel.fromJson(Map<String, dynamic> json) {
    final ruwePrijsregels = json['prijsregels'];

    return OfferteAlgemenePrijsregelsModel(
      prijsregels: ruwePrijsregels is List
          ? ruwePrijsregels
                .whereType<Map>()
                .map(
                  (item) => OfferteAlgemenePrijsregelModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .where((prijsregel) => prijsregel.isGeldig)
                .toList(growable: false)
          : const <OfferteAlgemenePrijsregelModel>[],
      gewijzigdOp: json['gewijzigdOp']?.toString() ?? '',
    );
  }

  static List<OfferteAlgemenePrijsregelModel> _normaliseerPrijsregels(
    Iterable<OfferteAlgemenePrijsregelModel> prijsregels,
  ) {
    final perId = <String, OfferteAlgemenePrijsregelModel>{};

    for (final prijsregel in prijsregels) {
      if (!prijsregel.isGeldig) {
        continue;
      }

      final bestaand = perId[prijsregel.id];
      if (bestaand == null ||
          _isNieuwer(prijsregel.gewijzigdOp, bestaand.gewijzigdOp)) {
        perId[prijsregel.id] = prijsregel;
      }
    }

    final resultaat = perId.values.toList(growable: false)
      ..sort((eerste, tweede) {
        final volgordeVergelijking = eerste.volgorde.compareTo(tweede.volgorde);

        if (volgordeVergelijking != 0) {
          return volgordeVergelijking;
        }

        return eerste.omschrijving.toLowerCase().compareTo(
          tweede.omschrijving.toLowerCase(),
        );
      });

    return List<OfferteAlgemenePrijsregelModel>.unmodifiable(resultaat);
  }

  static bool _isNieuwer(String eerste, String tweede) {
    final eersteDatum = DateTime.tryParse(eerste);
    final tweedeDatum = DateTime.tryParse(tweede);

    if (eersteDatum == null) {
      return false;
    }

    if (tweedeDatum == null) {
      return true;
    }

    return eersteDatum.isAfter(tweedeDatum);
  }
}
