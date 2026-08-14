// THIMACO-CONTROLE: PRIJSARCHITECTUUR-OPRUIMEN-STAP5A-ALGEMEEN-ZONDER-LEGACY-STUBS-20260814
// THIMACO-CONTROLE: PRIJS-PER-POSITIE-ALGEMEEN-BEREKENING-20260813
import 'dart:convert';

import '../../opmeting/raam/opmeting_raam_keuzemenu_model.dart';
import 'offerte_artikel_prijs_data_model.dart';
import 'offerte_berekening_resultaat.dart';
import 'offerte_prijs_categorie.dart';
import 'offerte_prijs_eenheid.dart';
import 'offerte_prijsprofiel_model.dart';
import 'offerte_prijsregel_model.dart';
import 'offerte_technische_keuze_resolver.dart';
import 'offerte_toegepaste_prijsregel_model.dart';

/// Centrale berekening voor de actieve prijsarchitectuur.
///
/// Alleen prijs per stuk, technische prijsregels, lokale prijs-per-positieregels,
/// artikelwinstmarge en artikelkorting worden nog verwerkt. De oude vrije-
/// artikel- en projectprijsopslag is definitief uit het prijsmodel verwijderd.
class OfferteAlgemeenArtikelPrijsService {
  const OfferteAlgemeenArtikelPrijsService._();

  static bool moetTechnischeMomentopnameBijwerken({
    required OfferteArtikelPrijsDataModel prijsData,
    required OffertePrijsprofielModel profiel,
    required Map<String, Map<String, OpmetingRaamKeuzeSelectie>>
    keuzeSelectiesPerKader,
    required int breedteMm,
    required int hoogteMm,
    bool forceer = false,
  }) {
    if (forceer) return true;
    return prijsData.technischePrijsSignatuur !=
        _maakTechnischePrijsSignatuur(
          profiel: profiel,
          keuzeSelectiesPerKader: keuzeSelectiesPerKader,
          breedteMm: breedteMm,
          hoogteMm: hoogteMm,
        );
  }

  static OfferteArtikelPrijsDataModel maakTechnischeMomentopname({
    required OfferteArtikelPrijsDataModel prijsData,
    required OffertePrijsprofielModel profiel,
    required Map<String, Map<String, OpmetingRaamKeuzeSelectie>>
    keuzeSelectiesPerKader,
    required int breedteMm,
    required int hoogteMm,
  }) {
    final berekendOp = DateTime.now().toUtc().toIso8601String();
    final toegepasteRegels = <OfferteToegepastePrijsregelModel>[];

    for (final prijsregel in _geldigeTechnischeRegels(profiel)) {
      final technischeKeuze = prijsregel.technischeKeuze;
      if (technischeKeuze == null || technischeKeuze.isLeeg) continue;
      if (!OfferteTechnischeKeuzeResolver.isGeselecteerd(
        keuze: technischeKeuze,
        keuzeSelectiesPerKader: keuzeSelectiesPerKader,
      )) {
        continue;
      }

      final hoeveelheid = _berekenHoeveelheid(
        eenheid: prijsregel.eenheid,
        breedteMm: breedteMm,
        hoogteMm: hoogteMm,
        aantal: 1,
      );
      final totaal = _rondBedragAf(hoeveelheid * prijsregel.prijsExclBtw);
      toegepasteRegels.add(
        OfferteToegepastePrijsregelModel(
          bronPrijsregelId: prijsregel.id,
          categorie: OffertePrijsCategorie.technischeKeuzePerArtikel,
          omschrijving: prijsregel.omschrijving,
          prijsExclBtw: prijsregel.prijsExclBtw,
          eenheid: prijsregel.eenheid,
          hoeveelheid: hoeveelheid,
          totaalExclBtw: totaal,
          uitschrijfmodus: prijsregel.uitschrijfmodus,
          technischeKeuze: technischeKeuze,
          bronGewijzigdOp: prijsregel.gewijzigdOp,
          berekendOp: berekendOp,
        ),
      );
    }

    return prijsData.copyWith(
      toegepasteTechnischePrijsregels: toegepasteRegels,
      technischePrijsSignatuur: _maakTechnischePrijsSignatuur(
        profiel: profiel,
        keuzeSelectiesPerKader: keuzeSelectiesPerKader,
        breedteMm: breedteMm,
        hoogteMm: hoogteMm,
      ),
    );
  }

  static double berekenPrijsregelTotaalExclBtw({
    required OffertePrijsregelModel prijsregel,
    int aantal = 1,
    int breedteMm = 0,
    int hoogteMm = 0,
  }) {
    if (!prijsregel.actief ||
        !prijsregel.isGeldig ||
        prijsregel.prijsExclBtw <= 0.0) {
      return 0.0;
    }
    final hoeveelheid = _berekenHoeveelheid(
      eenheid: prijsregel.eenheid,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      aantal: aantal,
    );
    return _rondBedragAf(hoeveelheid * prijsregel.prijsExclBtw);
  }

  static OfferteBerekeningResultaat resultaatUitMomentopname({
    required OfferteArtikelPrijsDataModel prijsData,
    int aantal = 1,
    int breedteMm = 0,
    int hoogteMm = 0,
    bool kortingToestaan = true,
  }) {
    final geldigAantal = aantal < 1 ? 1 : aantal;
    final basisTotaal = _rondBedragAf(
      prijsData.prijsPerStukExclBtw * geldigAantal.toDouble(),
    );
    return OfferteBerekeningResultaat(
      basisTotaalExclBtw: basisTotaal,
      aantalArtikelen: geldigAantal,
      basisPrijsPerStukExclBtw: prijsData.prijsPerStukExclBtw,
      technischePrijsregels: prijsData.toegepasteTechnischePrijsregels
          .where((regel) => regel.toonOpOverzicht && regel.isGeldig)
          .toList(growable: false),
      prijsPerPositieRegels: prijsData.prijsPerPositieRegels,
      winstmargePercentage: prijsData.artikelWinstmargePercentage,
      winstmargeOmschrijving: prijsData.artikelWinstmargeOmschrijving,
      kortingPercentage: kortingToestaan
          ? prijsData.artikelKortingPercentage
          : 0.0,
      kortingOmschrijving: prijsData.artikelKortingOmschrijving,
    );
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

  static String _maakTechnischePrijsSignatuur({
    required OffertePrijsprofielModel profiel,
    required Map<String, Map<String, OpmetingRaamKeuzeSelectie>>
    keuzeSelectiesPerKader,
    required int breedteMm,
    required int hoogteMm,
  }) {
    final regels = _geldigeTechnischeRegels(profiel)
        .map(
          (regel) => <String, Object?>{
            'id': regel.id,
            'categorie': regel.categorie.name,
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
      'breedteMm': breedteMm < 0 ? 0 : breedteMm,
      'hoogteMm': hoogteMm < 0 ? 0 : hoogteMm,
      'selecties': OfferteTechnischeKeuzeResolver.signatuurSelecties(
        keuzeSelectiesPerKader,
      ),
      'regels': regels,
    });
  }

  static double _berekenHoeveelheid({
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
      OffertePrijsEenheid.eenBreedteEenHoogte => breedteMeter + hoogteMeter,
      OffertePrijsEenheid.tweeBreedtesEenHoogte =>
        (2.0 * breedteMeter) + hoogteMeter,
      OffertePrijsEenheid.eenBreedteTweeHoogtes =>
        breedteMeter + (2.0 * hoogteMeter),
      OffertePrijsEenheid.omtrek => (2.0 * breedteMeter) + (2.0 * hoogteMeter),
      OffertePrijsEenheid.oppervlakte => breedteMeter * hoogteMeter,
    };
    return _rondHoeveelheidAf(geldigAantal * hoeveelheidPerStuk);
  }

  static bool _isZelfdeFormulierType(String eerste, String tweede) {
    return _normaliseerFormulierType(eerste) ==
        _normaliseerFormulierType(tweede);
  }

  static String _normaliseerFormulierType(String waarde) {
    return waarde.trim().toLowerCase().replaceAll('_', '').replaceAll(' ', '');
  }

  static double _rondHoeveelheidAf(double waarde) {
    if (!waarde.isFinite || waarde < 0.0) return 0.0;
    return (waarde * 10000.0).roundToDouble() / 10000.0;
  }

  static double _rondBedragAf(double waarde) {
    if (!waarde.isFinite || waarde <= 0.0) return 0.0;
    return (waarde * 100.0).roundToDouble() / 100.0;
  }
}
