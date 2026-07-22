import '../../opmeting/overzicht/opmeting_overzicht_model.dart';
import 'offerte_artikel_model.dart';

abstract interface class OfferteArtikelAdapter {
  String get formulierType;

  /// Geeft aan of dit artikeltype al volledig door de huidige PDF-service
  /// ondersteund wordt. Een adapter kan al geregistreerd zijn voor de algemene
  /// offertestroom terwijl de definitieve PDF-koppeling nog in opbouw is.
  bool get isPdfActief;

  bool ondersteunt(OpmetingOverzichtRaamItem positie);

  OfferteArtikelModel naarOfferteArtikel(
    OpmetingOverzichtRaamItem positie, {
    required int oorspronkelijkeIndex,
  });
}
