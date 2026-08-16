// THIMACO-CONTROLE: PRIJS-PER-POSITIE-INZETHOR-EENHEID-AFMETINGEN-20260815
// THIMACO-CONTROLE: PRIJSARCHITECTUUR-OPRUIMEN-STAP5A-INZETHOR-ZONDER-LEGACY-STUBS-20260814
// THIMACO-CONTROLE: PRIJS-PER-POSITIE-INZETHOR-BEREKENING-20260813
import '../../opmeting/toebehoren/vaste_inzethor/opmeting_vaste_inzethor_model.dart';
import 'offerte_berekening_resultaat.dart';
import 'offerte_toegepaste_prijsregel_model.dart';

class OffertePrijsBerekeningService {
  const OffertePrijsBerekeningService._();

  static bool moetTechnischeMomentopnameBijwerken(
    OpmetingVasteInzethorModel model,
  ) {
    return model.toegepasteTechnischePrijsregels.isNotEmpty ||
        model.technischePrijsSignatuur != model.prijsBerekeningSignatuur;
  }

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

  static OfferteBerekeningResultaat resultaatUitMomentopname(
    OpmetingVasteInzethorModel model, {
    bool kortingToestaan = true,
  }) {
    final aantal = model.aantal < 1 ? 1 : model.aantal;
    final basisTotaal = _rondBedragAf(
      model.prijsPerStukExclBtw * aantal.toDouble(),
    );

    return OfferteBerekeningResultaat(
      basisTotaalExclBtw: basisTotaal,
      aantalArtikelen: aantal,
      basisPrijsPerStukExclBtw: model.prijsPerStukExclBtw,
      breedteMm: model.breedteMm,
      hoogteMm: model.hoogteMm,
      technischePrijsregels: model.toegepasteTechnischePrijsregels
          .where((regel) => regel.toonOpOverzicht && regel.isGeldig)
          .toList(growable: false),
      prijsPerPositieRegels: model.prijsData.prijsPerPositieRegels,
      winstmargePercentage: model.artikelWinstmargePercentage,
      winstmargeOmschrijving: model.artikelWinstmargeOmschrijving,
      kortingPercentage: kortingToestaan ? model.artikelKortingPercentage : 0.0,
      kortingOmschrijving: model.artikelKortingOmschrijving,
    );
  }

  static double _rondBedragAf(double waarde) {
    if (!waarde.isFinite || waarde <= 0.0) return 0.0;
    return (waarde * 100.0).roundToDouble() / 100.0;
  }
}
