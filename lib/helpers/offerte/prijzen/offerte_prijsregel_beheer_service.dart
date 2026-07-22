// THIMACO-CONTROLE: OFFERTE-PRIJSREGEL-BEHEER-SERVICE-20260721
import 'dart:convert';

import 'offerte_prijs_categorie.dart';
import 'offerte_prijsprofiel_model.dart';
import 'offerte_prijsregel_model.dart';

class OffertePrijsregelBeheerService {
  const OffertePrijsregelBeheerService._();

  static List<OffertePrijsregelModel> bewaardePrijsregelsVoorCategorie({
    required OffertePrijsprofielModel profiel,
    required OffertePrijsCategorie categorie,
    required String formulierType,
  }) {
    final formulierSleutel = _normaliseerPrijsFormulierType(formulierType);
    final regels = profiel
        .regelsVoorCategorie(categorie)
        .where((regel) {
          return _normaliseerPrijsFormulierType(regel.formulierType) ==
              formulierSleutel;
        })
        .map((regel) {
          return regel.copyWith(
            categorie: categorie,
            formulierType: formulierType,
          );
        })
        .toList(growable: false);

    regels.sort((eerste, tweede) {
      final volgorde = eerste.volgorde.compareTo(tweede.volgorde);
      if (volgorde != 0) return volgorde;
      return eerste.omschrijving.toLowerCase().compareTo(
        tweede.omschrijving.toLowerCase(),
      );
    });

    return List<OffertePrijsregelModel>.unmodifiable(regels);
  }

  static List<OffertePrijsregelModel> combineerBewaardeEnTijdelijkePrijsregels({
    required List<OffertePrijsregelModel> bewaardePrijsregels,
    required List<OffertePrijsregelModel> tijdelijkePrijsregels,
    required OffertePrijsCategorie categorie,
    required String formulierType,
  }) {
    final regelsPerId = <String, OffertePrijsregelModel>{};

    for (final regel in bewaardePrijsregels) {
      regelsPerId[regel.id] = regel.copyWith(
        categorie: categorie,
        formulierType: formulierType,
      );
    }
    final formulierSleutel = _normaliseerPrijsFormulierType(formulierType);
    for (final regel in tijdelijkePrijsregels) {
      if (regel.categorie != categorie ||
          _normaliseerPrijsFormulierType(regel.formulierType) !=
              formulierSleutel) {
        continue;
      }

      regelsPerId[regel.id] = regel.copyWith(
        categorie: categorie,
        formulierType: formulierType,
      );
    }

    final regels = regelsPerId.values.toList(growable: false);
    regels.sort((eerste, tweede) {
      final volgorde = eerste.volgorde.compareTo(tweede.volgorde);
      if (volgorde != 0) return volgorde;
      return eerste.omschrijving.toLowerCase().compareTo(
        tweede.omschrijving.toLowerCase(),
      );
    });
    return List<OffertePrijsregelModel>.unmodifiable(regels);
  }

  static bool _prijsregelHeeftZelfdeInhoud(
    OffertePrijsregelModel eerste,
    OffertePrijsregelModel tweede,
  ) {
    final eersteJson = Map<String, dynamic>.from(eerste.toJson())
      ..remove('gewijzigdOp');
    final tweedeJson = Map<String, dynamic>.from(tweede.toJson())
      ..remove('gewijzigdOp');
    return jsonEncode(eersteJson) == jsonEncode(tweedeJson);
  }

  static List<OffertePrijsregelModel> maakTijdelijkePrijsregelVerschillen({
    required List<OffertePrijsregelModel> prijsregels,
    required List<OffertePrijsregelModel> bewaardePrijsregels,
    required OffertePrijsCategorie categorie,
    required String formulierType,
  }) {
    final huidigeRegels = _normaliseerTijdelijkePrijsregels(
      prijsregels: prijsregels,
      categorie: categorie,
      formulierType: formulierType,
    );
    final bewaardPerId = <String, OffertePrijsregelModel>{
      for (final regel in bewaardePrijsregels) regel.id: regel,
    };
    final huidigPerId = <String, OffertePrijsregelModel>{
      for (final regel in huidigeRegels) regel.id: regel,
    };
    final verschillen = <OffertePrijsregelModel>[];

    for (final regel in huidigeRegels) {
      final bewaard = bewaardPerId[regel.id];
      if (bewaard == null || !_prijsregelHeeftZelfdeInhoud(regel, bewaard)) {
        verschillen.add(regel);
      }
    }

    final nu = DateTime.now().toUtc().toIso8601String();
    for (final bewaard in bewaardePrijsregels) {
      if (!huidigPerId.containsKey(bewaard.id) && bewaard.actief) {
        verschillen.add(
          bewaard.copyWith(
            categorie: categorie,
            formulierType: formulierType,
            actief: false,
            gewijzigdOp: nu,
          ),
        );
      }
    }

    verschillen.sort((eerste, tweede) {
      final volgorde = eerste.volgorde.compareTo(tweede.volgorde);
      if (volgorde != 0) return volgorde;
      return eerste.omschrijving.toLowerCase().compareTo(
        tweede.omschrijving.toLowerCase(),
      );
    });
    return List<OffertePrijsregelModel>.unmodifiable(verschillen);
  }

  static OffertePrijsprofielModel vervangPrijsregelsVoorCategorie({
    required OffertePrijsprofielModel profiel,
    required OffertePrijsCategorie categorie,
    required String formulierType,
    required List<OffertePrijsregelModel> prijsregels,
  }) {
    final nieuweCategorieRegels = _normaliseerTijdelijkePrijsregels(
      prijsregels: prijsregels,
      categorie: categorie,
      formulierType: formulierType,
    );
    final overigeRegels = profiel.prijsregels
        .where((regel) => regel.categorie != categorie)
        .toList(growable: false);

    return profiel.copyWith(
      prijsregels: <OffertePrijsregelModel>[
        ...overigeRegels,
        ...nieuweCategorieRegels,
      ],
      gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
    );
  }

  static List<OffertePrijsregelModel> _normaliseerTijdelijkePrijsregels({
    required List<OffertePrijsregelModel> prijsregels,
    required OffertePrijsCategorie categorie,
    required String formulierType,
  }) {
    final resultaat = <OffertePrijsregelModel>[];
    for (var index = 0; index < prijsregels.length; index++) {
      final regel = prijsregels[index];
      if (!regel.isGeldig) continue;
      resultaat.add(
        regel.copyWith(
          categorie: categorie,
          formulierType: formulierType,
          volgorde: index * 10,
          gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
        ),
      );
    }
    return List<OffertePrijsregelModel>.unmodifiable(resultaat);
  }

  static String _normaliseerPrijsFormulierType(String waarde) {
    return waarde.trim().toLowerCase().replaceAll('_', '').replaceAll(' ', '');
  }
}
