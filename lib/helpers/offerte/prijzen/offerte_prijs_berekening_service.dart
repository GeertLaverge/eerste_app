import '../../opmeting/toebehoren/vaste_inzethor/opmeting_vaste_inzethor_model.dart';
import 'offerte_algemeen_artikel_prijs_service.dart';
import 'offerte_berekening_resultaat.dart';
import 'offerte_prijsprofiel_model.dart';
import 'offerte_prijsregel_model.dart';
import 'offerte_vaste_inzethor_technische_prijs_adapter.dart';

/// Tijdelijke compatibiliteitslaag voor bestaande inzethoraanroepen.
///
/// De technische berekening wordt uitgevoerd via de inzethoradapter en de
/// gezamenlijke technische prijsmotor. Vrije artikelregels, tijdelijke regels
/// en de uiteindelijke resultaatberekening lopen via
/// [OfferteAlgemeenArtikelPrijsService].
class OffertePrijsBerekeningService {
  const OffertePrijsBerekeningService._();

  static bool moetTechnischeMomentopnameBijwerken(
    OpmetingVasteInzethorModel model, {
    OffertePrijsprofielModel? profiel,
    bool forceer = false,
  }) {
    if (profiel == null) {
      return model.technischePrijsSignatuur != model.prijsBerekeningSignatuur;
    }

    return OfferteVasteInzethorTechnischePrijsAdapter.moetMomentopnameBijwerken(
      model: model,
      profiel: profiel,
      forceer: forceer,
    );
  }

  static OpmetingVasteInzethorModel maakTechnischeMomentopname({
    required OpmetingVasteInzethorModel model,
    OffertePrijsprofielModel? profiel,
  }) {
    if (profiel == null) {
      return model;
    }

    return OfferteVasteInzethorTechnischePrijsAdapter.maakMomentopname(
      model: model,
      profiel: profiel,
    );
  }

  static bool moetVrijeArtikelMomentopnameBijwerken({
    required OpmetingVasteInzethorModel model,
    required OffertePrijsprofielModel profiel,
    bool forceer = false,
  }) {
    return OfferteAlgemeenArtikelPrijsService.moetVrijeArtikelMomentopnameBijwerken(
      prijsData: model.prijsData,
      profiel: profiel,
      artikelSignatuur: model.prijsBerekeningSignatuur,
      forceer: forceer,
    );
  }

  static OpmetingVasteInzethorModel maakVrijeArtikelMomentopname({
    required OpmetingVasteInzethorModel model,
    required OffertePrijsprofielModel profiel,
  }) {
    final prijsData =
        OfferteAlgemeenArtikelPrijsService.maakVrijeArtikelMomentopname(
          prijsData: model.prijsData,
          profiel: profiel,
          artikelSignatuur: model.prijsBerekeningSignatuur,
        );

    return model.copyWithPrijsData(prijsData);
  }

  static List<OffertePrijsregelModel> tijdelijkeVrijeArtikelPrijsregels(
    OpmetingVasteInzethorModel model, {
    String formulierType = 'vasteInzethor',
  }) {
    return OfferteAlgemeenArtikelPrijsService.tijdelijkeVrijeArtikelPrijsregels(
      model.prijsData,
      formulierType: formulierType,
    );
  }

  static OpmetingVasteInzethorModel metTijdelijkeVrijeArtikelPrijsregels({
    required OpmetingVasteInzethorModel model,
    required List<OffertePrijsregelModel> prijsregels,
  }) {
    final prijsData =
        OfferteAlgemeenArtikelPrijsService.metTijdelijkeVrijeArtikelPrijsregels(
          prijsData: model.prijsData,
          prijsregels: prijsregels,
        );

    return model.copyWithPrijsData(prijsData);
  }

  static OfferteBerekeningResultaat resultaatUitMomentopname(
    OpmetingVasteInzethorModel model, {
    bool kortingToestaan = true,
  }) {
    return OfferteAlgemeenArtikelPrijsService.resultaatUitMomentopname(
      prijsData: model.prijsData,
      aantal: model.aantal,
      breedteMm: model.breedteMm,
      hoogteMm: model.hoogteMm,
      kortingToestaan: kortingToestaan,
    );
  }
}
