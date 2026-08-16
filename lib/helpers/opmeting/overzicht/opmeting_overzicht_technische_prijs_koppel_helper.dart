// THIMACO-CONTROLE: TECHNISCHE-PRIJS-ALLEEN-ZICHTBARE-KEUZE-20260814
// THIMACO-CONTROLE: OVERZICHT-TECHNISCHE-PRIJS-KOPPELING-20260721
import '../../offerte/prijzen/offerte_prijsregel_weergave_service.dart';
import '../../offerte/prijzen/offerte_toegepaste_prijsregel_model.dart';
import 'opmeting_overzicht_artikel_layout_helper.dart';
import 'opmeting_overzicht_model.dart';

class OpmetingOverzichtTechnischePrijsKoppelHelper {
  const OpmetingOverzichtTechnischePrijsKoppelHelper._();

  static List<OpmetingOverzichtTechnischeRegelPrijs>
  koppelTechnischePrijzenAanRegels({
    required List<OpmetingOverzichtTechnischeRegel> technischeRegels,
    required List<OfferteToegepastePrijsregelModel> technischePrijsregels,
  }) {
    final bruikbarePrijsregels = technischePrijsregels
        .where((prijsregel) {
          return prijsregel.isGeldig &&
              prijsregel.totaalExclBtw.isFinite &&
              prijsregel.totaalExclBtw > 0.0 &&
              OffertePrijsregelWeergaveService.technischeUitschrijftekst(
                prijsregel,
              ).isNotEmpty;
        })
        .toList(growable: false);
    final gebruiktePrijsregelIndexen = <int>{};
    final resultaat = <OpmetingOverzichtTechnischeRegelPrijs>[];

    for (final technischeRegel in technischeRegels) {
      var gekoppeldBedrag = 0.0;
      var heeftGekoppeldePrijs = false;

      for (var index = 0; index < bruikbarePrijsregels.length; index++) {
        if (gebruiktePrijsregelIndexen.contains(index)) {
          continue;
        }

        final prijsregel = bruikbarePrijsregels[index];
        if (!OffertePrijsregelWeergaveService.technischeRegelPastBijPrijsregel(
          prijsregel: prijsregel,
          titel: technischeRegel.titel,
          waarde: technischeRegel.waarde,
        )) {
          continue;
        }

        gebruiktePrijsregelIndexen.add(index);
        gekoppeldBedrag += prijsregel.totaalExclBtw;
        heeftGekoppeldePrijs = true;
      }

      resultaat.add(
        OpmetingOverzichtTechnischeRegelPrijs(
          regel: technischeRegel,
          bedragExclBtw: heeftGekoppeldePrijs && gekoppeldBedrag > 0.0
              ? gekoppeldBedrag
              : null,
        ),
      );
    }

    return List<OpmetingOverzichtTechnischeRegelPrijs>.unmodifiable(resultaat);
  }
}
