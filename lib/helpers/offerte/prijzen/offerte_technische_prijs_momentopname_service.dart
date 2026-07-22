import 'dart:convert';

import 'offerte_artikel_prijs_data_model.dart';
import 'offerte_prijs_categorie.dart';
import 'offerte_prijs_eenheid.dart';
import 'offerte_prijsprofiel_model.dart';
import 'offerte_prijsregel_model.dart';
import 'offerte_technische_keuze_ref.dart';
import 'offerte_toegepaste_prijsregel_model.dart';

typedef OfferteTechnischeKeuzeSelectieTest =
    bool Function(OfferteTechnischeKeuzeRef keuze);

/// Gezamenlijke berekening van technische prijsregels voor alle artikeltypes.
///
/// Een artikeladapter hoeft alleen nog te bepalen:
/// - welke technische keuze geselecteerd is;
/// - welke maten en aantallen gelden;
/// - welke artikelsignatuur de actuele technische toestand beschrijft.
class OfferteTechnischePrijsMomentopnameService {
  const OfferteTechnischePrijsMomentopnameService._();

  static bool moetMomentopnameBijwerken({
    required OfferteArtikelPrijsDataModel prijsData,
    required OffertePrijsprofielModel profiel,
    required String artikelSignatuur,
    bool forceer = false,
  }) {
    if (forceer) {
      return true;
    }

    return prijsData.technischePrijsSignatuur !=
        maakSignatuur(profiel: profiel, artikelSignatuur: artikelSignatuur);
  }

  static OfferteArtikelPrijsDataModel maakMomentopname({
    required OfferteArtikelPrijsDataModel prijsData,
    required OffertePrijsprofielModel profiel,
    required int breedteMm,
    required int hoogteMm,
    required int aantal,
    required String artikelSignatuur,
    required OfferteTechnischeKeuzeSelectieTest keuzeIsGeselecteerd,
  }) {
    final berekendOp = DateTime.now().toUtc().toIso8601String();
    final toegepasteRegels = <OfferteToegepastePrijsregelModel>[];

    for (final prijsregel in _geldigeTechnischeRegels(profiel)) {
      final technischeKeuze = prijsregel.technischeKeuze;

      if (technischeKeuze == null ||
          technischeKeuze.isLeeg ||
          !keuzeIsGeselecteerd(technischeKeuze)) {
        continue;
      }

      final hoeveelheid = berekenHoeveelheid(
        eenheid: prijsregel.eenheid,
        breedteMm: breedteMm,
        hoogteMm: hoogteMm,
        aantal: aantal,
      );

      final totaalExclBtw = _rondBedragAf(
        hoeveelheid * prijsregel.prijsExclBtw,
      );

      toegepasteRegels.add(
        OfferteToegepastePrijsregelModel(
          bronPrijsregelId: prijsregel.id,
          categorie: OffertePrijsCategorie.technischeKeuzePerArtikel,
          omschrijving: prijsregel.omschrijving,
          prijsExclBtw: prijsregel.prijsExclBtw,
          eenheid: prijsregel.eenheid,
          hoeveelheid: hoeveelheid,
          totaalExclBtw: totaalExclBtw,
          uitschrijfmodus: prijsregel.uitschrijfmodus,
          technischeKeuze: technischeKeuze,
          bronGewijzigdOp: prijsregel.gewijzigdOp,
          berekendOp: berekendOp,
        ),
      );
    }

    return prijsData.copyWith(
      toegepasteTechnischePrijsregels: toegepasteRegels,
      technischePrijsSignatuur: maakSignatuur(
        profiel: profiel,
        artikelSignatuur: artikelSignatuur,
      ),
    );
  }

  static String maakSignatuur({
    required OffertePrijsprofielModel profiel,
    required String artikelSignatuur,
  }) {
    final regels = _geldigeTechnischeRegels(profiel)
        .map(
          (regel) => <String, Object?>{
            'id': regel.id,
            'omschrijving': regel.omschrijving,
            'prijsExclBtw': regel.prijsExclBtw,
            'eenheid': regel.eenheid.jsonWaarde,
            'uitschrijfmodus': regel.uitschrijfmodus.jsonWaarde,
            'technischeKeuze': regel.technischeKeuze?.toJson(),
            'actief': regel.actief,
            'volgorde': regel.volgorde,
            'gewijzigdOp': regel.gewijzigdOp,
          },
        )
        .toList(growable: false);

    return jsonEncode(<String, Object?>{
      'formulierType': profiel.formulierType,
      'artikel': artikelSignatuur,
      'regels': regels,
    });
  }

  static double berekenHoeveelheid({
    required OffertePrijsEenheid eenheid,
    required int breedteMm,
    required int hoogteMm,
    required int aantal,
  }) {
    final breedteMeter = breedteMm < 0 ? 0.0 : breedteMm / 1000.0;
    final hoogteMeter = hoogteMm < 0 ? 0.0 : hoogteMm / 1000.0;
    final geldigAantal = (aantal < 1 ? 1 : aantal).toDouble();

    final hoeveelheidPerStuk = switch (eenheid) {
      OffertePrijsEenheid.vast => 1.0,
      OffertePrijsEenheid.eenBreedte => breedteMeter,
      OffertePrijsEenheid.tweeBreedtes => 2.0 * breedteMeter,
      OffertePrijsEenheid.eenHoogte => hoogteMeter,
      OffertePrijsEenheid.tweeHoogtes => 2.0 * hoogteMeter,
      OffertePrijsEenheid.eenBreedteTweeHoogtes =>
        breedteMeter + (2.0 * hoogteMeter),
      OffertePrijsEenheid.omtrek => (2.0 * breedteMeter) + (2.0 * hoogteMeter),
      OffertePrijsEenheid.oppervlakte => breedteMeter * hoogteMeter,
    };

    return _rondHoeveelheidAf(geldigAantal * hoeveelheidPerStuk);
  }

  static List<OffertePrijsregelModel> _geldigeTechnischeRegels(
    OffertePrijsprofielModel profiel,
  ) {
    return profiel
        .regelsVoorCategorie(OffertePrijsCategorie.technischeKeuzePerArtikel)
        .where((regel) {
          final technischeKeuze = regel.technischeKeuze;

          return regel.actief &&
              regel.isGeldig &&
              regel.prijsExclBtw > 0.0 &&
              technischeKeuze != null &&
              !technischeKeuze.isLeeg &&
              _isZelfdeFormulierType(
                regel.formulierType,
                profiel.formulierType,
              ) &&
              _isZelfdeFormulierType(
                technischeKeuze.formulierType,
                profiel.formulierType,
              );
        })
        .toList(growable: false);
  }

  static bool _isZelfdeFormulierType(String eerste, String tweede) {
    return _normaliseerFormulierType(eerste) ==
        _normaliseerFormulierType(tweede);
  }

  static String _normaliseerFormulierType(String waarde) {
    return waarde.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  static double _rondHoeveelheidAf(double waarde) {
    if (!waarde.isFinite || waarde < 0.0) {
      return 0.0;
    }

    return (waarde * 10000.0).roundToDouble() / 10000.0;
  }

  static double _rondBedragAf(double waarde) {
    if (!waarde.isFinite || waarde <= 0.0) {
      return 0.0;
    }

    return (waarde * 100.0).roundToDouble() / 100.0;
  }
}
