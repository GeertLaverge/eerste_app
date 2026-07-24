// THIMACO-CONTROLE: OFFERTE-VALIDATIE-ALLE-PRIJSKOPPELINGEN-20260722
import '../opmeting/overzicht/opmeting_overzicht_model.dart';
import 'artikelen/offerte_artikel_adapter.dart';
import 'artikelen/offerte_artikel_model.dart';
import 'artikelen/offerte_pvc_raam_adapter.dart';
import 'artikelen/offerte_vaste_inzethor_adapter.dart';
import 'offerte_posities_service.dart';
import 'prijzen/offerte_artikel_prijs_koppeling_service.dart';
import 'offerte_validatie_service.dart';

class OfferteController {
  OfferteController({
    required List<OfferteArtikelAdapter> adapters,
    this.positiesService = const OffertePositiesService(),
    this.validatieService = const OfferteValidatieService(),
  }) : adapters = List<OfferteArtikelAdapter>.unmodifiable(adapters);

  factory OfferteController.standaard() {
    return OfferteController(
      adapters: const <OfferteArtikelAdapter>[
        OfferteVasteInzethorAdapter(),
        OffertePvcRaamAdapter(),
      ],
    );
  }

  final List<OfferteArtikelAdapter> adapters;
  final OffertePositiesService positiesService;
  final OfferteValidatieService validatieService;

  OfferteArtikelAdapter? adapterVoor(OpmetingOverzichtRaamItem positie) {
    for (final adapter in adapters) {
      if (adapter.ondersteunt(positie)) return adapter;
    }
    return null;
  }

  List<OpmetingOverzichtRaamItem> selecteerOndersteundePosities(
    Iterable<OpmetingOverzichtRaamItem> posities,
  ) {
    return List<OpmetingOverzichtRaamItem>.unmodifiable(
      posities.where((positie) => adapterVoor(positie) != null),
    );
  }

  /// Selecteert uitsluitend posities waarvan de artikelspecifieke PDF-layout
  /// volledig gekoppeld is. Een Vliegendeur heeft een eigen PDF-widget en mag
  /// daarom mee zonder prijsadapter of koppeling met de prijsinstellingen.
  List<OpmetingOverzichtRaamItem> selecteerPdfPosities(
    Iterable<OpmetingOverzichtRaamItem> posities,
  ) {
    return List<OpmetingOverzichtRaamItem>.unmodifiable(
      posities.where((positie) {
        if (positie.isVerwijderd) return false;
        if (positie.vliegendeurData != null) return true;

        final adapter = adapterVoor(positie);
        return adapter != null && adapter.isPdfActief;
      }),
    );
  }

  List<OfferteArtikelModel> bouwArtikelen(
    Iterable<OpmetingOverzichtRaamItem> posities,
  ) {
    final resultaat = <OfferteArtikelModel>[];
    var index = 0;

    for (final positie in posities) {
      final adapter = adapterVoor(positie);
      if (adapter != null) {
        resultaat.add(
          adapter.naarOfferteArtikel(positie, oorspronkelijkeIndex: index),
        );
      }
      index++;
    }

    return List<OfferteArtikelModel>.unmodifiable(resultaat);
  }

  List<OfferteArtikelModel> bouwValidatieArtikelen(
    Iterable<OpmetingOverzichtRaamItem> posities,
  ) {
    final resultaat = <OfferteArtikelModel>[];
    var index = 0;

    for (final positie in posities) {
      if (!positie.isVerwijderd) {
        final adapter = adapterVoor(positie);
        final artikel = adapter != null
            ? adapter.naarOfferteArtikel(positie, oorspronkelijkeIndex: index)
            : _bouwGekoppeldValidatieArtikel(
                positie,
                oorspronkelijkeIndex: index,
              );

        if (artikel != null) {
          resultaat.add(artikel);
        }
      }
      index++;
    }

    return List<OfferteArtikelModel>.unmodifiable(resultaat);
  }

  OfferteValidatieResultaat valideerPrijsgegevens(
    Iterable<OpmetingOverzichtRaamItem> posities,
  ) {
    final artikelen = bouwValidatieArtikelen(posities);
    final labels = positiesService.maakPositieLabels(artikelen);
    return validatieService.valideerPrijsgegevens(
      artikelen: artikelen,
      positieLabels: labels,
    );
  }

  OfferteArtikelModel? _bouwGekoppeldValidatieArtikel(
    OpmetingOverzichtRaamItem positie, {
    required int oorspronkelijkeIndex,
  }) {
    final koppeling = OfferteArtikelPrijsKoppelingService.koppelingVoorArtikel(
      positie,
    );
    final prijsData = OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(
      positie,
    );

    if (koppeling == null || prijsData == null) {
      return null;
    }

    final optiePlaatsing = !positie.isOfferteOptie
        ? OfferteArtikelOptiePlaatsing.geen
        : positie.offerteOptiePlaatsing == OfferteOptiePlaatsing.positieBehouden
        ? OfferteArtikelOptiePlaatsing.positieBehouden
        : OfferteArtikelOptiePlaatsing.apartePagina;

    final artikelNaam = positie.formulierTypeLabel.trim().isEmpty
        ? koppeling.formulierNaam
        : positie.formulierTypeLabel.trim();
    final titel = positie.titel.trim().isEmpty
        ? artikelNaam
        : positie.titel.trim();
    final breedte = OfferteArtikelPrijsKoppelingService.breedteMmVoorArtikel(
      positie,
    );
    final hoogte = OfferteArtikelPrijsKoppelingService.hoogteMmVoorArtikel(
      positie,
    );
    final omschrijving = breedte > 0 && hoogte > 0
        ? '$titel · $breedte × $hoogte mm'
        : titel;

    return OfferteArtikelModel(
      id: positie.id,
      artikelType: koppeling.formulierType,
      artikelNaam: artikelNaam,
      omschrijving: omschrijving,
      aantal: OfferteArtikelPrijsKoppelingService.aantalVoorArtikel(positie),
      prijsPerStukExclBtw: prijsData.prijsPerStukExclBtw,
      winstmargePercentage: prijsData.artikelWinstmargePercentage,
      kortingPercentage: positie.isOfferteOptie
          ? 0
          : prijsData.artikelKortingPercentage,
      isOptie: positie.isOfferteOptie,
      optiePlaatsing: optiePlaatsing,
      optieHoofdpositieId: positie.offerteOptieHoofdpositieId.trim(),
      oorspronkelijkeIndex: oorspronkelijkeIndex,
    );
  }

  String bepaalOptieHoofdpositieId({
    required List<OpmetingOverzichtRaamItem> posities,
    required String positieId,
  }) {
    return positiesService.bepaalOptieHoofdpositieId(
      posities: posities,
      positieId: positieId,
    );
  }
}
