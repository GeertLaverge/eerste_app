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

    final ongekoppeldeBedragenPerTekst = <String, double>{};
    final zichtbareTekstPerSleutel = <String, String>{};

    for (var index = 0; index < bruikbarePrijsregels.length; index++) {
      if (gebruiktePrijsregelIndexen.contains(index)) {
        continue;
      }

      final prijsregel = bruikbarePrijsregels[index];
      final uitschrijftekst =
          OffertePrijsregelWeergaveService.technischeUitschrijftekst(
            prijsregel,
          );
      final sleutel =
          OffertePrijsregelWeergaveService.normaliseerTechnischeTekst(
            uitschrijftekst,
          );

      if (sleutel.isEmpty) {
        continue;
      }

      zichtbareTekstPerSleutel.putIfAbsent(sleutel, () => uitschrijftekst);
      ongekoppeldeBedragenPerTekst[sleutel] =
          (ongekoppeldeBedragenPerTekst[sleutel] ?? 0.0) +
          prijsregel.totaalExclBtw;
    }

    for (final entry in ongekoppeldeBedragenPerTekst.entries) {
      final uitschrijftekst = zichtbareTekstPerSleutel[entry.key] ?? '';
      if (uitschrijftekst.isEmpty) {
        continue;
      }

      resultaat.add(
        OpmetingOverzichtTechnischeRegelPrijs(
          regel: OpmetingOverzichtTechnischeRegel(
            titel: uitschrijftekst,
            waarde: '',
          ),
          bedragExclBtw: entry.value > 0.0 ? entry.value : null,
        ),
      );
    }

    return List<OpmetingOverzichtTechnischeRegelPrijs>.unmodifiable(resultaat);
  }
}
