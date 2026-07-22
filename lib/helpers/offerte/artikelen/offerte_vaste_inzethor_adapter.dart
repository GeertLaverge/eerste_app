import '../../opmeting/overzicht/opmeting_overzicht_model.dart';
import 'offerte_artikel_adapter.dart';
import 'offerte_artikel_model.dart';

class OfferteVasteInzethorAdapter implements OfferteArtikelAdapter {
  const OfferteVasteInzethorAdapter();

  @override
  String get formulierType => 'vasteInzethor';

  @override
  bool get isPdfActief => true;

  @override
  bool ondersteunt(OpmetingOverzichtRaamItem positie) {
    return !positie.isVerwijderd &&
        positie.formulierTypeGenormaliseerd == formulierType &&
        positie.vasteInzethorData != null;
  }

  @override
  OfferteArtikelModel naarOfferteArtikel(
    OpmetingOverzichtRaamItem positie, {
    required int oorspronkelijkeIndex,
  }) {
    final model = positie.vasteInzethorData;
    if (model == null) {
      throw StateError(
        'De vaste-inzethoradapter kreeg een positie zonder inzethormodel.',
      );
    }

    final optiePlaatsing = !positie.isOfferteOptie
        ? OfferteArtikelOptiePlaatsing.geen
        : positie.offerteOptiePlaatsing == OfferteOptiePlaatsing.positieBehouden
        ? OfferteArtikelOptiePlaatsing.positieBehouden
        : OfferteArtikelOptiePlaatsing.apartePagina;

    return OfferteArtikelModel(
      id: positie.id,
      artikelType: formulierType,
      artikelNaam: positie.formulierTypeLabel,
      omschrijving: positie.titel.trim().isEmpty
          ? positie.formulierTypeLabel
          : positie.titel.trim(),
      aantal: model.aantal,
      prijsPerStukExclBtw: model.prijsPerStukExclBtw,
      winstmargePercentage: model.artikelWinstmargePercentage,
      kortingPercentage: positie.isOfferteOptie
          ? 0
          : model.artikelKortingPercentage,
      isOptie: positie.isOfferteOptie,
      optiePlaatsing: optiePlaatsing,
      optieHoofdpositieId: positie.offerteOptieHoofdpositieId.trim(),
      oorspronkelijkeIndex: oorspronkelijkeIndex,
    );
  }
}
