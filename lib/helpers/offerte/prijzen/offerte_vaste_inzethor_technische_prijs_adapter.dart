import '../../opmeting/toebehoren/vaste_inzethor/opmeting_vaste_inzethor_model.dart';
import 'offerte_prijsprofiel_model.dart';
import 'offerte_toegepaste_prijsregel_model.dart';

/// Vaste inzethorren gebruiken geen prijzen volgens technische keuzes.
///
/// Deze adapter verwijdert uitsluitend oude technische prijsmomentopnames
/// die mogelijk door een vroegere versie werden opgeslagen. Vrije prijzen,
/// verdeelde kosten, korting en winstmarge blijven volledig behouden.
class OfferteVasteInzethorTechnischePrijsAdapter {
  const OfferteVasteInzethorTechnischePrijsAdapter._();

  /// Definitieve methode voor vaste inzethorren.
  static bool moetTechnischeMomentopnameBijwerken(
    OpmetingVasteInzethorModel model,
  ) {
    return model.toegepasteTechnischePrijsregels.isNotEmpty ||
        model.technischePrijsSignatuur != model.prijsBerekeningSignatuur;
  }

  /// Definitieve methode voor vaste inzethorren.
  static OpmetingVasteInzethorModel maakTechnischeMomentopname({
    required OpmetingVasteInzethorModel model,
  }) {
    return model.copyWithPrijsData(
      model.prijsData.copyWith(
        toegepasteTechnischePrijsregels:
            const <OfferteToegepastePrijsregelModel>[],
        technischePrijsSignatuur: model.prijsBerekeningSignatuur,
      ),
    );
  }

  /// Tijdelijke compatibiliteitsnaam voor bestaande aanroepplaatsen.
  ///
  /// [profiel] wordt bewust niet gebruikt, omdat vaste inzethorren geen
  /// technische-keuzeprijzen toepassen.
  static bool moetMomentopnameBijwerken({
    required OpmetingVasteInzethorModel model,
    OffertePrijsprofielModel? profiel,
    bool forceer = false,
  }) {
    if (forceer) {
      return true;
    }

    return moetTechnischeMomentopnameBijwerken(model);
  }

  /// Tijdelijke compatibiliteitsnaam voor bestaande aanroepplaatsen.
  ///
  /// [profiel] wordt bewust niet gebruikt, omdat vaste inzethorren geen
  /// technische-keuzeprijzen toepassen.
  static OpmetingVasteInzethorModel maakMomentopname({
    required OpmetingVasteInzethorModel model,
    OffertePrijsprofielModel? profiel,
  }) {
    return maakTechnischeMomentopname(model: model);
  }
}
