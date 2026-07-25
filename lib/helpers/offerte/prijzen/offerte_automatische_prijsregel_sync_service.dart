import '../../opmeting/overzicht/opmeting_overzicht_model.dart';
import 'offerte_algemeen_artikel_prijs_service.dart';
import 'offerte_algemene_prijsregel_model.dart';
import 'offerte_artikel_prijs_koppeling_service.dart';
import 'offerte_prijs_categorie.dart';
import 'offerte_prijsregel_model.dart';

class OfferteAutomatischePrijsregelSyncService {
  const OfferteAutomatischePrijsregelSyncService();

  OfferteAutomatischePrijsregelSyncResultaat synchroniseer({
    required List<OpmetingOverzichtRaamItem> artikelen,
    required List<OfferteAlgemenePrijsregelModel> prijsregels,
  }) {
    var werkLijst = List<OpmetingOverzichtRaamItem>.from(artikelen);

    final gewijzigdeArtikelIds = <String>{};
    final toepassingenPerPrijsregelId = <String, int>{};
    final verwijderingenPerPrijsregelId = <String, int>{};

    for (final prijsregel in prijsregels) {
      final resultaat = _synchroniseerPrijsregel(
        artikelen: werkLijst,
        prijsregel: prijsregel,
      );

      werkLijst = resultaat.artikelen;

      gewijzigdeArtikelIds.addAll(resultaat.gewijzigdeArtikelIds);

      if (resultaat.toegevoegdAantal > 0) {
        toepassingenPerPrijsregelId[prijsregel.id] = resultaat.toegevoegdAantal;
      }

      if (resultaat.verwijderdAantal > 0) {
        verwijderingenPerPrijsregelId[prijsregel.id] =
            resultaat.verwijderdAantal;
      }
    }

    return OfferteAutomatischePrijsregelSyncResultaat(
      artikelen: List<OpmetingOverzichtRaamItem>.unmodifiable(werkLijst),
      gewijzigdeArtikelIds: Set<String>.unmodifiable(gewijzigdeArtikelIds),
      toepassingenPerPrijsregelId: Map<String, int>.unmodifiable(
        toepassingenPerPrijsregelId,
      ),
      verwijderingenPerPrijsregelId: Map<String, int>.unmodifiable(
        verwijderingenPerPrijsregelId,
      ),
    );
  }

  _PrijsregelSyncResultaat _synchroniseerPrijsregel({
    required List<OpmetingOverzichtRaamItem> artikelen,
    required OfferteAlgemenePrijsregelModel prijsregel,
  }) {
    final nieuweLijst = List<OpmetingOverzichtRaamItem>.from(artikelen);

    final gewijzigdeArtikelIds = <String>{};

    final automatischeRegelActief =
        prijsregel.actief &&
        prijsregel.isGeldig &&
        prijsregel.prijsExclBtw > 0 &&
        prijsregel.altijdToepassenAlsArtikelInGebruik;

    final toepasselijkeArtikelen = automatischeRegelActief
        ? nieuweLijst
              .where(
                (artikel) => _artikelIsToegelatenVoorPrijsregel(
                  artikel: artikel,
                  prijsregel: prijsregel,
                ),
              )
              .toList(growable: false)
        : const <OpmetingOverzichtRaamItem>[];

    final maximumToegelaten = _maximumIsToegelaten(
      prijsregel: prijsregel,
      artikelen: toepasselijkeArtikelen,
    );

    final gewensteArtikelIds = automatischeRegelActief && maximumToegelaten
        ? toepasselijkeArtikelen.map((artikel) => artikel.id).toSet()
        : <String>{};

    var toegevoegdAantal = 0;
    var verwijderdAantal = 0;

    for (var index = 0; index < nieuweLijst.length; index++) {
      final huidig = nieuweLijst[index];

      final koppeling =
          OfferteArtikelPrijsKoppelingService.koppelingVoorArtikel(huidig);

      final huidigePrijsData =
          OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(huidig);

      if (koppeling == null || huidigePrijsData == null) {
        continue;
      }

      final moetToegepastZijn = gewensteArtikelIds.contains(huidig.id);

      final reedsToegepast =
          OfferteAlgemeenArtikelPrijsService.heeftGekozenProjectPrijsregel(
            prijsData: huidigePrijsData,
            oorspronkelijkPrijsregelId: prijsregel.id,
            doelFormulierType: koppeling.formulierType,
          );

      if (moetToegepastZijn) {
        final isReedsActueel = _heeftActueleGekozenProjectPrijsregel(
          prijsData: huidigePrijsData,
          prijsregel: prijsregel,
          formulierType: koppeling.formulierType,
        );

        if (isReedsActueel) {
          continue;
        }

        final bijgewerktePrijsData =
            OfferteAlgemeenArtikelPrijsService.voegGekozenProjectPrijsregelToe(
              prijsData: huidigePrijsData,
              prijsregel: _naarArtikelPrijsregel(
                prijsregel: prijsregel,
                formulierType: koppeling.formulierType,
              ),
              doelFormulierType: koppeling.formulierType,
            );

        final bijgewerkt = OfferteArtikelPrijsKoppelingService.schrijfPrijsData(
          artikel: huidig,
          prijsData: bijgewerktePrijsData,
        ).metNieuweWijzigingsDatum();

        nieuweLijst[index] = bijgewerkt;
        gewijzigdeArtikelIds.add(bijgewerkt.id);

        if (!reedsToegepast) {
          toegevoegdAantal++;
        }

        continue;
      }

      if (!reedsToegepast) {
        continue;
      }

      final bijgewerktePrijsData =
          OfferteAlgemeenArtikelPrijsService.verwijderGekozenProjectPrijsregel(
            prijsData: huidigePrijsData,
            oorspronkelijkPrijsregelId: prijsregel.id,
            doelFormulierType: koppeling.formulierType,
          );

      final bijgewerkt = OfferteArtikelPrijsKoppelingService.schrijfPrijsData(
        artikel: huidig,
        prijsData: bijgewerktePrijsData,
      ).metNieuweWijzigingsDatum();

      nieuweLijst[index] = bijgewerkt;
      gewijzigdeArtikelIds.add(bijgewerkt.id);
      verwijderdAantal++;
    }

    return _PrijsregelSyncResultaat(
      artikelen: nieuweLijst,
      gewijzigdeArtikelIds: gewijzigdeArtikelIds,
      toegevoegdAantal: toegevoegdAantal,
      verwijderdAantal: verwijderdAantal,
    );
  }

  bool _heeftActueleGekozenProjectPrijsregel({
    required dynamic prijsData,
    required OfferteAlgemenePrijsregelModel prijsregel,
    required String formulierType,
  }) {
    final oorspronkelijkId = prijsregel.id.trim();

    if (oorspronkelijkId.isEmpty) {
      return false;
    }

    final toegepasteId =
        OfferteAlgemeenArtikelPrijsService.gekozenProjectPrijsregelId(
          oorspronkelijkPrijsregelId: oorspronkelijkId,
          doelFormulierType: formulierType,
        );

    if (toegepasteId.isEmpty) {
      return false;
    }

    final overeenkomendeSelecties = prijsData.vrijeArtikelPrijsSelecties
        .where((selectie) {
          return selectie.bronPrijsregelId == oorspronkelijkId ||
              selectie.bronPrijsregelId == toegepasteId;
        })
        .toList(growable: false);

    /*
     * Er moet exact één actuele toepassing bestaan.
     *
     * Een oude toepassing met het oorspronkelijke ID, of meerdere dubbele
     * toepassingen, wordt hierdoor één keer vervangen door de nieuwe vaste
     * toepassing per doelartikeltype.
     */
    if (overeenkomendeSelecties.length != 1) {
      return false;
    }

    final selectie = overeenkomendeSelecties.single;

    if (selectie.bronPrijsregelId != toegepasteId) {
      return false;
    }

    if (!selectie.actief || !selectie.isGeldig) {
      return false;
    }

    if (selectie.omschrijving.trim() != prijsregel.omschrijving.trim()) {
      return false;
    }

    if (!_bedragenZijnGelijk(
      selectie.bedragPerStukExclBtw,
      prijsregel.prijsExclBtw,
    )) {
      return false;
    }

    if (!_bedragenZijnGelijk(
      selectie.bronPrijsPerStukExclBtw,
      prijsregel.prijsExclBtw,
    )) {
      return false;
    }

    if (selectie.eenheid != prijsregel.eenheid) {
      return false;
    }

    if (selectie.uitschrijfmodus != prijsregel.uitschrijfmodus) {
      return false;
    }

    if (selectie.bronGewijzigdOp != prijsregel.gewijzigdOp) {
      return false;
    }

    return true;
  }

  bool _maximumIsToegelaten({
    required OfferteAlgemenePrijsregelModel prijsregel,
    required Iterable<OpmetingOverzichtRaamItem> artikelen,
  }) {
    if (!prijsregel.uitschrijfmodus.isVerdeeldeInterneKost) {
      return true;
    }

    final maximum = prijsregel.maximaleTotaleStukprijs;

    if (maximum <= 0) {
      return true;
    }

    final totaleBasisArtikelwaarde = berekenTotaleBasisArtikelwaarde(artikelen);

    return totaleBasisArtikelwaarde <= maximum + 0.000001;
  }

  double berekenTotaleBasisArtikelwaarde(
    Iterable<OpmetingOverzichtRaamItem> artikelen,
  ) {
    var totaal = 0.0;

    for (final artikel in artikelen) {
      if (artikel.isVerwijderd || artikel.isNietRekenen) {
        continue;
      }

      final prijsData =
          OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(artikel);

      if (prijsData == null) {
        continue;
      }

      final prijsPerStuk = prijsData.prijsPerStukExclBtw;

      final aantal = OfferteArtikelPrijsKoppelingService.aantalVoorArtikel(
        artikel,
      );

      if (!prijsPerStuk.isFinite || prijsPerStuk < 0 || aantal <= 0) {
        continue;
      }

      totaal += prijsPerStuk * aantal;
    }

    return _rondBedragAf(totaal);
  }

  bool _artikelIsToegelatenVoorPrijsregel({
    required OpmetingOverzichtRaamItem artikel,
    required OfferteAlgemenePrijsregelModel prijsregel,
  }) {
    if (artikel.isVerwijderd || artikel.isNietRekenen) {
      return false;
    }

    if (!OfferteArtikelPrijsKoppelingService.isOndersteundArtikel(artikel)) {
      return false;
    }

    final koppeling = OfferteArtikelPrijsKoppelingService.koppelingVoorArtikel(
      artikel,
    );

    final prijsData = OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(
      artikel,
    );

    if (koppeling == null || prijsData == null) {
      return false;
    }

    final doelSleutel = _normaliseerFormulierType(koppeling.formulierType);

    return prijsregel.toepasselijkeFormulierTypes.any(
      (type) => _normaliseerFormulierType(type) == doelSleutel,
    );
  }

  OffertePrijsregelModel _naarArtikelPrijsregel({
    required OfferteAlgemenePrijsregelModel prijsregel,
    required String formulierType,
  }) {
    return OffertePrijsregelModel(
      id: prijsregel.id,
      categorie: OffertePrijsCategorie.vrijPerArtikel,
      formulierType: formulierType,
      omschrijving: prijsregel.omschrijving,
      prijsExclBtw: prijsregel.prijsExclBtw,
      eenheid: prijsregel.eenheid,
      uitschrijfmodus: prijsregel.uitschrijfmodus,
      actief: prijsregel.actief,
      volgorde: prijsregel.volgorde,
      gewijzigdOp: prijsregel.gewijzigdOp,
    );
  }

  static bool _bedragenZijnGelijk(double eerste, double tweede) {
    if (!eerste.isFinite || !tweede.isFinite) {
      return false;
    }

    return (eerste - tweede).abs() <= 0.000001;
  }

  static double _rondBedragAf(double bedrag) {
    if (!bedrag.isFinite || bedrag <= 0) {
      return 0;
    }

    return (bedrag * 100).roundToDouble() / 100;
  }

  static String _normaliseerFormulierType(String waarde) {
    return waarde.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }
}

class OfferteAutomatischePrijsregelSyncResultaat {
  const OfferteAutomatischePrijsregelSyncResultaat({
    required this.artikelen,
    required this.gewijzigdeArtikelIds,
    required this.toepassingenPerPrijsregelId,
    required this.verwijderingenPerPrijsregelId,
  });

  final List<OpmetingOverzichtRaamItem> artikelen;

  final Set<String> gewijzigdeArtikelIds;

  final Map<String, int> toepassingenPerPrijsregelId;

  final Map<String, int> verwijderingenPerPrijsregelId;

  bool get gewijzigd {
    return gewijzigdeArtikelIds.isNotEmpty;
  }

  int get toegevoegdAantal {
    return toepassingenPerPrijsregelId.values.fold<int>(
      0,
      (totaal, aantal) => totaal + aantal,
    );
  }

  int get verwijderdAantal {
    return verwijderingenPerPrijsregelId.values.fold<int>(
      0,
      (totaal, aantal) => totaal + aantal,
    );
  }
}

class _PrijsregelSyncResultaat {
  const _PrijsregelSyncResultaat({
    required this.artikelen,
    required this.gewijzigdeArtikelIds,
    required this.toegevoegdAantal,
    required this.verwijderdAantal,
  });

  final List<OpmetingOverzichtRaamItem> artikelen;

  final Set<String> gewijzigdeArtikelIds;

  final int toegevoegdAantal;
  final int verwijderdAantal;
}
