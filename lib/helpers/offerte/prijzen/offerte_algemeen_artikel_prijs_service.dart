// THIMACO-CONTROLE: OUDE-FICHEGEBONDEN-TECHNISCHE-PRIJSLOGICA-VERWIJDERD-STAP1-20260815
// THIMACO-CONTROLE: PRIJSARCHITECTUUR-OPRUIMEN-STAP5A-ALGEMEEN-ZONDER-LEGACY-STUBS-20260814
// THIMACO-CONTROLE: PRIJS-PER-POSITIE-ALGEMEEN-BEREKENING-20260813
import 'offerte_artikel_prijs_data_model.dart';
import 'offerte_berekening_resultaat.dart';
import 'offerte_prijs_eenheid.dart';
import 'offerte_prijsregel_model.dart';

/// Centrale algemene artikelberekening.
///
/// De oude fichegebonden technische prijsprofiel-logica is verwijderd.
/// Technische keuzes worden voortaan uitsluitend berekend via
/// `OfferteCentraleTechnischePrijsService`.
///
/// Deze service blijft verantwoordelijk voor:
/// - algemene prijsregelhoeveelheden;
/// - basisprijs per stuk;
/// - lokale prijs-per-positieregels;
/// - artikelwinstmarge en artikelkorting.
class OfferteAlgemeenArtikelPrijsService {
  const OfferteAlgemeenArtikelPrijsService._();

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
