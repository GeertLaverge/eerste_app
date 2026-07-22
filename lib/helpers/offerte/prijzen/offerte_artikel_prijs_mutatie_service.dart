// THIMACO-CONTROLE: OFFERTE-ARTIKEL-PRIJS-MUTATIE-SERVICE-20260721
import '../../opmeting/overzicht/opmeting_overzicht_model.dart';
import 'offerte_artikel_prijs_koppeling_service.dart';

abstract class OfferteArtikelPrijsMutatieAdapter {
  const OfferteArtikelPrijsMutatieAdapter();

  String get id;

  bool isGeschiktVoor(OpmetingOverzichtRaamItem artikel);

  OpmetingOverzichtRaamItem schrijfPrijsPerStuk({
    required OpmetingOverzichtRaamItem artikel,
    required double prijsPerStukExclBtw,
  });

  OpmetingOverzichtRaamItem schrijfPrijsCorrecties({
    required OpmetingOverzichtRaamItem artikel,
    double? kortingPercentage,
    double? winstmargePercentage,
  });
}

class OfferteArtikelPrijsMutatieResultaat {
  const OfferteArtikelPrijsMutatieResultaat({
    required this.artikelen,
    required this.gewijzigdeArtikelen,
    required this.lijstGewijzigd,
  });

  final List<OpmetingOverzichtRaamItem> artikelen;
  final List<OpmetingOverzichtRaamItem> gewijzigdeArtikelen;
  final bool lijstGewijzigd;

  bool get isGewijzigd => gewijzigdeArtikelen.isNotEmpty;

  factory OfferteArtikelPrijsMutatieResultaat.ongewijzigd(
    List<OpmetingOverzichtRaamItem> artikelen,
  ) {
    return OfferteArtikelPrijsMutatieResultaat(
      artikelen: List<OpmetingOverzichtRaamItem>.unmodifiable(artikelen),
      gewijzigdeArtikelen: const <OpmetingOverzichtRaamItem>[],
      lijstGewijzigd: false,
    );
  }
}

class OfferteArtikelPrijsMutatieService {
  const OfferteArtikelPrijsMutatieService._();

  static const OfferteArtikelPrijsMutatieAdapter pvcRaam =
      _AlgemeenArtikelPrijsMutatieAdapter('pvcRaam');
  static const OfferteArtikelPrijsMutatieAdapter aluRaam =
      _AlgemeenArtikelPrijsMutatieAdapter('aluRaam');
  static const OfferteArtikelPrijsMutatieAdapter pvcSchuifraam =
      _AlgemeenArtikelPrijsMutatieAdapter('pvcSchuifraam');
  static const OfferteArtikelPrijsMutatieAdapter aluSchuifraam =
      _AlgemeenArtikelPrijsMutatieAdapter('aluSchuifraam');
  static const OfferteArtikelPrijsMutatieAdapter pvcDeur =
      _AlgemeenArtikelPrijsMutatieAdapter('pvcDeur');
  static const OfferteArtikelPrijsMutatieAdapter aluDeur =
      _AlgemeenArtikelPrijsMutatieAdapter('aluDeur');
  static const OfferteArtikelPrijsMutatieAdapter vasteInzethor =
      _VasteInzethorPrijsMutatieAdapter();

  static const List<OfferteArtikelPrijsMutatieAdapter> _adapters =
      <OfferteArtikelPrijsMutatieAdapter>[
        pvcRaam,
        aluRaam,
        pvcSchuifraam,
        aluSchuifraam,
        pvcDeur,
        aluDeur,
        vasteInzethor,
      ];

  static OfferteArtikelPrijsMutatieAdapter? adapterVoor(
    OpmetingOverzichtRaamItem artikel,
  ) {
    for (final adapter in _adapters) {
      if (adapter.isGeschiktVoor(artikel)) {
        return adapter;
      }
    }
    return null;
  }

  static OfferteArtikelPrijsMutatieResultaat wijzigPrijsPerStuk({
    required List<OpmetingOverzichtRaamItem> artikelen,
    required OpmetingOverzichtRaamItem artikel,
    required double prijsPerStukExclBtw,
    required OfferteArtikelPrijsMutatieAdapter adapter,
  }) {
    if (!adapter.isGeschiktVoor(artikel)) {
      return OfferteArtikelPrijsMutatieResultaat.ongewijzigd(artikelen);
    }

    final bijgewerkt = adapter
        .schrijfPrijsPerStuk(
          artikel: artikel,
          prijsPerStukExclBtw: prijsPerStukExclBtw,
        )
        .metNieuweWijzigingsDatum();
    final nieuweLijst = List<OpmetingOverzichtRaamItem>.from(artikelen);
    final index = nieuweLijst.indexWhere(
      (bestaand) => bestaand.id == artikel.id,
    );

    if (index >= 0) {
      nieuweLijst[index] = bijgewerkt;
    }

    return OfferteArtikelPrijsMutatieResultaat(
      artikelen: List<OpmetingOverzichtRaamItem>.unmodifiable(nieuweLijst),
      gewijzigdeArtikelen: <OpmetingOverzichtRaamItem>[bijgewerkt],
      lijstGewijzigd: index >= 0,
    );
  }

  static OfferteArtikelPrijsMutatieResultaat wijzigPrijsCorrecties({
    required List<OpmetingOverzichtRaamItem> artikelen,
    required OpmetingOverzichtRaamItem artikel,
    required OfferteArtikelPrijsMutatieAdapter adapter,
    double? kortingPercentage,
    double? winstmargePercentage,
    Set<String>? doelArtikelIds,
    bool toepassenOpAlleArtikelen = false,
  }) {
    if (!adapter.isGeschiktVoor(artikel) ||
        (kortingPercentage != null && artikel.isOfferteOptie) ||
        (kortingPercentage == null && winstmargePercentage == null)) {
      return OfferteArtikelPrijsMutatieResultaat.ongewijzigd(artikelen);
    }

    final gevraagdeDoelIds =
        doelArtikelIds ??
        (toepassenOpAlleArtikelen
            ? artikelen
                  .where(
                    (huidig) =>
                        !huidig.isVerwijderd &&
                        adapterVoor(huidig) != null &&
                        (kortingPercentage == null || !huidig.isOfferteOptie),
                  )
                  .map((huidig) => huidig.id)
                  .toSet()
            : <String>{artikel.id});

    final geldigeDoelIds = artikelen
        .where(
          (huidig) =>
              gevraagdeDoelIds.contains(huidig.id) &&
              !huidig.isVerwijderd &&
              adapterVoor(huidig) != null &&
              (kortingPercentage == null || !huidig.isOfferteOptie),
        )
        .map((huidig) => huidig.id)
        .toSet();

    if (geldigeDoelIds.isEmpty) {
      return OfferteArtikelPrijsMutatieResultaat.ongewijzigd(artikelen);
    }

    final bijgewerkteArtikelen = <OpmetingOverzichtRaamItem>[];
    final nieuweLijst = List<OpmetingOverzichtRaamItem>.from(artikelen);

    for (var index = 0; index < nieuweLijst.length; index++) {
      final huidig = nieuweLijst[index];
      if (!geldigeDoelIds.contains(huidig.id)) {
        continue;
      }

      final doelAdapter = adapterVoor(huidig);
      if (doelAdapter == null) {
        continue;
      }

      final bijgewerkt = doelAdapter
          .schrijfPrijsCorrecties(
            artikel: huidig,
            kortingPercentage: kortingPercentage,
            winstmargePercentage: winstmargePercentage,
          )
          .metNieuweWijzigingsDatum();

      nieuweLijst[index] = bijgewerkt;
      bijgewerkteArtikelen.add(bijgewerkt);
    }

    if (bijgewerkteArtikelen.isEmpty) {
      return OfferteArtikelPrijsMutatieResultaat.ongewijzigd(artikelen);
    }

    return OfferteArtikelPrijsMutatieResultaat(
      artikelen: List<OpmetingOverzichtRaamItem>.unmodifiable(nieuweLijst),
      gewijzigdeArtikelen: List<OpmetingOverzichtRaamItem>.unmodifiable(
        bijgewerkteArtikelen,
      ),
      lijstGewijzigd: true,
    );
  }
}

class _AlgemeenArtikelPrijsMutatieAdapter
    extends OfferteArtikelPrijsMutatieAdapter {
  const _AlgemeenArtikelPrijsMutatieAdapter(this.formulierType);

  final String formulierType;

  @override
  String get id => formulierType;

  @override
  bool isGeschiktVoor(OpmetingOverzichtRaamItem artikel) {
    final koppeling = OfferteArtikelPrijsKoppelingService.koppelingVoorArtikel(
      artikel,
    );
    return koppeling?.isAlgemeenArtikel == true &&
        koppeling?.adapterId == formulierType;
  }

  @override
  OpmetingOverzichtRaamItem schrijfPrijsPerStuk({
    required OpmetingOverzichtRaamItem artikel,
    required double prijsPerStukExclBtw,
  }) {
    final prijsData = OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(
      artikel,
    );
    if (prijsData == null) return artikel;

    return OfferteArtikelPrijsKoppelingService.schrijfPrijsData(
      artikel: artikel,
      prijsData: OfferteArtikelPrijsKoppelingService.wijzigPrijsData(
        prijsData: prijsData,
        prijsPerStukExclBtw: prijsPerStukExclBtw,
      ),
    );
  }

  @override
  OpmetingOverzichtRaamItem schrijfPrijsCorrecties({
    required OpmetingOverzichtRaamItem artikel,
    double? kortingPercentage,
    double? winstmargePercentage,
  }) {
    final prijsData = OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(
      artikel,
    );
    if (prijsData == null) return artikel;

    return OfferteArtikelPrijsKoppelingService.schrijfPrijsData(
      artikel: artikel,
      prijsData: OfferteArtikelPrijsKoppelingService.wijzigPrijsData(
        prijsData: prijsData,
        artikelKortingPercentage:
            kortingPercentage ?? prijsData.artikelKortingPercentage,
        artikelWinstmargePercentage:
            winstmargePercentage ?? prijsData.artikelWinstmargePercentage,
      ),
    );
  }
}

class _VasteInzethorPrijsMutatieAdapter
    extends OfferteArtikelPrijsMutatieAdapter {
  const _VasteInzethorPrijsMutatieAdapter();

  @override
  String get id => 'vasteInzethor';

  @override
  bool isGeschiktVoor(OpmetingOverzichtRaamItem artikel) {
    return artikel.vasteInzethorData != null;
  }

  @override
  OpmetingOverzichtRaamItem schrijfPrijsPerStuk({
    required OpmetingOverzichtRaamItem artikel,
    required double prijsPerStukExclBtw,
  }) {
    final model = artikel.vasteInzethorData;
    if (model == null) {
      return artikel;
    }

    return artikel.copyWith(
      vasteInzethorData: model.copyWithPrijsData(
        OfferteArtikelPrijsKoppelingService.wijzigPrijsData(
          prijsData: model.prijsData,
          prijsPerStukExclBtw: prijsPerStukExclBtw,
        ),
      ),
    );
  }

  @override
  OpmetingOverzichtRaamItem schrijfPrijsCorrecties({
    required OpmetingOverzichtRaamItem artikel,
    double? kortingPercentage,
    double? winstmargePercentage,
  }) {
    final model = artikel.vasteInzethorData;
    if (model == null) {
      return artikel;
    }

    final prijsData = model.prijsData;
    return artikel.copyWith(
      vasteInzethorData: model.copyWithPrijsData(
        OfferteArtikelPrijsKoppelingService.wijzigPrijsData(
          prijsData: prijsData,
          artikelKortingPercentage:
              kortingPercentage ?? prijsData.artikelKortingPercentage,
          artikelWinstmargePercentage:
              winstmargePercentage ?? prijsData.artikelWinstmargePercentage,
        ),
      ),
    );
  }
}
