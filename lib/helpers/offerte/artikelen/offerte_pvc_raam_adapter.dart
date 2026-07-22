import '../../opmeting/overzicht/opmeting_overzicht_model.dart';
import 'offerte_artikel_adapter.dart';
import 'offerte_artikel_model.dart';

/// Eerste veilige koppeling van een PVC-raampositie met de algemene
/// offertestroom.
///
/// Deze adapter levert de gemeenschappelijke basisgegevens en koppelt de
/// handmatige artikelprijs, winstmarge en korting van een PVC raam aan de
/// algemene offertestroom. Technische prijsregels worden later via hetzelfde
/// prijsdatamodel toegevoegd.
class OffertePvcRaamAdapter implements OfferteArtikelAdapter {
  const OffertePvcRaamAdapter();

  @override
  String get formulierType => 'pvcRaam';

  @override
  bool get isPdfActief => true;

  @override
  bool ondersteunt(OpmetingOverzichtRaamItem positie) {
    return !positie.isVerwijderd &&
        positie.formulierTypeGenormaliseerd == formulierType &&
        positie.vasteInzethorData == null;
  }

  @override
  OfferteArtikelModel naarOfferteArtikel(
    OpmetingOverzichtRaamItem positie, {
    required int oorspronkelijkeIndex,
  }) {
    final optiePlaatsing = !positie.isOfferteOptie
        ? OfferteArtikelOptiePlaatsing.geen
        : positie.offerteOptiePlaatsing == OfferteOptiePlaatsing.positieBehouden
        ? OfferteArtikelOptiePlaatsing.positieBehouden
        : OfferteArtikelOptiePlaatsing.apartePagina;

    return OfferteArtikelModel(
      id: positie.id,
      artikelType: formulierType,
      artikelNaam: positie.formulierTypeLabel,
      omschrijving: _bouwOmschrijving(positie),
      aantal: 1,
      prijsPerStukExclBtw: positie.offertePrijsData.prijsPerStukExclBtw,
      winstmargePercentage:
          positie.offertePrijsData.artikelWinstmargePercentage,
      kortingPercentage: positie.isOfferteOptie
          ? 0
          : positie.offertePrijsData.artikelKortingPercentage,
      isOptie: positie.isOfferteOptie,
      optiePlaatsing: optiePlaatsing,
      optieHoofdpositieId: positie.offerteOptieHoofdpositieId.trim(),
      oorspronkelijkeIndex: oorspronkelijkeIndex,
    );
  }

  String _bouwOmschrijving(OpmetingOverzichtRaamItem positie) {
    final titel = positie.titel.trim().isEmpty
        ? positie.formulierTypeLabel
        : positie.titel.trim();

    final breedte = positie.raammaatBreedteMm;
    final hoogte = positie.raammaatHoogteMm;
    if (breedte <= 0 || hoogte <= 0) {
      return titel;
    }

    return '$titel · $breedte × $hoogte mm';
  }
}
