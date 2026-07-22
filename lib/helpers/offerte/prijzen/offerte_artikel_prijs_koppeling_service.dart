// THIMACO-CONTROLE: OFFERTE-ARTIKEL-PRIJS-KOPPELING-SERVICE-20260721
import '../../opmeting/overzicht/opmeting_overzicht_model.dart';
import 'offerte_artikel_prijs_data_model.dart';
import 'offerte_algemeen_artikel_prijs_service.dart';
import 'offerte_berekening_resultaat.dart';
import 'offerte_prijs_berekening_service.dart';
import 'offerte_toegepaste_prijsregel_model.dart';

/// Beschrijft hoe één opmeetformulier aan de gezamenlijke artikelprijslogica
/// gekoppeld wordt.
///
/// De vaste inzethor blijft bewust een afzonderlijke adapter. Zij gebruikt haar
/// eigen aantal, maatvoering en prijsdata. De zes raam- en deurtypes gebruiken
/// de bestaande `offertePrijsData` van het overzichtsitem. Daardoor is geen
/// wijziging aan prijsmodellen of JSON nodig.
class OfferteArtikelPrijsKoppeling {
  const OfferteArtikelPrijsKoppeling({
    required this.adapterId,
    required this.formulierType,
    required this.formulierNaam,
    required this.isVasteInzethor,
    required this.ondersteuntTechnischeKeuzeprijzen,
  });

  final String adapterId;
  final String formulierType;
  final String formulierNaam;
  final bool isVasteInzethor;
  final bool ondersteuntTechnischeKeuzeprijzen;

  bool get isAlgemeenArtikel => !isVasteInzethor;
}

class OfferteArtikelPrijsKoppelingService {
  const OfferteArtikelPrijsKoppelingService._();

  static const OfferteArtikelPrijsKoppeling vasteInzethor =
      OfferteArtikelPrijsKoppeling(
        adapterId: 'vasteInzethor',
        formulierType: 'vasteInzethor',
        formulierNaam: 'Vaste inzethor',
        isVasteInzethor: true,
        ondersteuntTechnischeKeuzeprijzen: false,
      );

  static const OfferteArtikelPrijsKoppeling pvcRaam =
      OfferteArtikelPrijsKoppeling(
        adapterId: 'pvcRaam',
        formulierType: 'pvcRaam',
        formulierNaam: 'PVC raam',
        isVasteInzethor: false,
        ondersteuntTechnischeKeuzeprijzen: true,
      );

  static const OfferteArtikelPrijsKoppeling aluRaam =
      OfferteArtikelPrijsKoppeling(
        adapterId: 'aluRaam',
        formulierType: 'aluRaam',
        formulierNaam: 'ALU raam',
        isVasteInzethor: false,
        ondersteuntTechnischeKeuzeprijzen: true,
      );

  static const OfferteArtikelPrijsKoppeling pvcSchuifraam =
      OfferteArtikelPrijsKoppeling(
        adapterId: 'pvcSchuifraam',
        formulierType: 'pvcSchuifraam',
        formulierNaam: 'PVC schuifraam',
        isVasteInzethor: false,
        ondersteuntTechnischeKeuzeprijzen: true,
      );

  static const OfferteArtikelPrijsKoppeling aluSchuifraam =
      OfferteArtikelPrijsKoppeling(
        adapterId: 'aluSchuifraam',
        formulierType: 'aluSchuifraam',
        formulierNaam: 'ALU schuifraam',
        isVasteInzethor: false,
        ondersteuntTechnischeKeuzeprijzen: true,
      );

  static const OfferteArtikelPrijsKoppeling pvcDeur =
      OfferteArtikelPrijsKoppeling(
        adapterId: 'pvcDeur',
        formulierType: 'pvcDeur',
        formulierNaam: 'PVC deur',
        isVasteInzethor: false,
        ondersteuntTechnischeKeuzeprijzen: true,
      );

  static const OfferteArtikelPrijsKoppeling aluDeur =
      OfferteArtikelPrijsKoppeling(
        adapterId: 'aluDeur',
        formulierType: 'aluDeur',
        formulierNaam: 'ALU deur',
        isVasteInzethor: false,
        ondersteuntTechnischeKeuzeprijzen: true,
      );

  static const List<OfferteArtikelPrijsKoppeling> algemeneKoppelingen =
      <OfferteArtikelPrijsKoppeling>[
        pvcRaam,
        aluRaam,
        pvcSchuifraam,
        aluSchuifraam,
        pvcDeur,
        aluDeur,
      ];

  static const List<OfferteArtikelPrijsKoppeling> alleKoppelingen =
      <OfferteArtikelPrijsKoppeling>[vasteInzethor, ...algemeneKoppelingen];

  static const List<String> algemeneFormulierTypes = <String>[
    'pvcRaam',
    'aluRaam',
    'pvcSchuifraam',
    'aluSchuifraam',
    'pvcDeur',
    'aluDeur',
  ];

  static const List<String> ondersteundeFormulierTypes = <String>[
    'vasteInzethor',
    ...algemeneFormulierTypes,
  ];

  static OfferteArtikelPrijsKoppeling? koppelingVoorArtikel(
    OpmetingOverzichtRaamItem artikel,
  ) {
    if (artikel.vasteInzethorData != null) {
      return vasteInzethor;
    }

    final koppeling = koppelingVoorFormulierType(
      artikel.formulierTypeGenormaliseerd,
    );
    return koppeling?.isAlgemeenArtikel == true ? koppeling : null;
  }

  static OfferteArtikelPrijsKoppeling? koppelingVoorFormulierType(
    String formulierType,
  ) {
    final sleutel = _normaliseer(formulierType);
    for (final koppeling in alleKoppelingen) {
      if (_normaliseer(koppeling.formulierType) == sleutel) {
        return koppeling;
      }
    }
    return null;
  }

  static String canoniekFormulierType(String formulierType) {
    return koppelingVoorFormulierType(formulierType)?.formulierType ??
        formulierType.trim();
  }

  static String formulierNaamVoor(String formulierType) {
    final koppeling = koppelingVoorFormulierType(formulierType);
    if (koppeling != null) return koppeling.formulierNaam;
    return formulierType.trim().isEmpty ? 'Artikel' : formulierType.trim();
  }

  static bool isOndersteundArtikel(OpmetingOverzichtRaamItem artikel) {
    return koppelingVoorArtikel(artikel) != null;
  }

  static bool isAlgemeenArtikel(OpmetingOverzichtRaamItem artikel) {
    return koppelingVoorArtikel(artikel)?.isAlgemeenArtikel == true;
  }

  static bool ondersteuntTechnischeKeuzeprijzen(
    OpmetingOverzichtRaamItem artikel,
  ) {
    return koppelingVoorArtikel(artikel)?.ondersteuntTechnischeKeuzeprijzen ==
        true;
  }

  static OfferteArtikelPrijsDataModel? prijsDataVoorArtikel(
    OpmetingOverzichtRaamItem artikel,
  ) {
    final koppeling = koppelingVoorArtikel(artikel);
    if (koppeling == null) return null;

    if (koppeling.isVasteInzethor) {
      return artikel.vasteInzethorData?.prijsData;
    }
    return artikel.offertePrijsData;
  }

  /// Maakt een gewijzigde prijsdata-kopie zonder afhankelijk te zijn van de
  /// parameters van `OfferteArtikelPrijsDataModel.copyWith`.
  ///
  /// Dit houdt de koppeling compatibel met bestaande projectversies waarin
  /// `copyWith` nog niet alle korting- en winstmargevelden aanbiedt. Het model
  /// en zijn JSON-structuur zelf worden niet gewijzigd.
  static OfferteArtikelPrijsDataModel wijzigPrijsData({
    required OfferteArtikelPrijsDataModel prijsData,
    double? prijsPerStukExclBtw,
    double? artikelKortingPercentage,
    double? artikelWinstmargePercentage,
    List<OfferteToegepastePrijsregelModel>? toegepasteVerdeeldePrijsregels,
    String? verdeeldePrijsSignatuur,
  }) {
    final json = Map<String, dynamic>.from(prijsData.toJson());

    if (prijsPerStukExclBtw != null) {
      json['prijsPerStukExclBtw'] = prijsPerStukExclBtw;
    }
    if (artikelKortingPercentage != null) {
      json['artikelKortingPercentage'] = artikelKortingPercentage;
    }
    if (artikelWinstmargePercentage != null) {
      json['artikelWinstmargePercentage'] = artikelWinstmargePercentage;
    }
    if (toegepasteVerdeeldePrijsregels != null) {
      json['toegepasteVerdeeldePrijsregels'] = toegepasteVerdeeldePrijsregels
          .map((regel) => regel.toJson())
          .toList(growable: false);
    }
    if (verdeeldePrijsSignatuur != null) {
      json['verdeeldePrijsSignatuur'] = verdeeldePrijsSignatuur;
    }

    return OfferteArtikelPrijsDataModel.fromJson(json);
  }

  static OpmetingOverzichtRaamItem schrijfPrijsData({
    required OpmetingOverzichtRaamItem artikel,
    required OfferteArtikelPrijsDataModel prijsData,
  }) {
    final koppeling = koppelingVoorArtikel(artikel);
    if (koppeling == null) return artikel;

    if (koppeling.isVasteInzethor) {
      final model = artikel.vasteInzethorData;
      if (model == null) return artikel;
      return artikel.copyWith(
        vasteInzethorData: model.copyWithPrijsData(prijsData),
      );
    }

    return artikel.copyWith(offertePrijsData: prijsData);
  }

  static int aantalVoorArtikel(OpmetingOverzichtRaamItem artikel) {
    return artikel.vasteInzethorData?.aantal ?? 1;
  }

  static int breedteMmVoorArtikel(OpmetingOverzichtRaamItem artikel) {
    return artikel.vasteInzethorData?.breedteMm ?? artikel.raammaatBreedteMm;
  }

  static int hoogteMmVoorArtikel(OpmetingOverzichtRaamItem artikel) {
    return artikel.vasteInzethorData?.hoogteMm ?? artikel.raammaatHoogteMm;
  }

  static OfferteBerekeningResultaat? resultaatVoorArtikel(
    OpmetingOverzichtRaamItem artikel, {
    bool kortingToestaan = true,
  }) {
    final koppeling = koppelingVoorArtikel(artikel);
    if (koppeling == null) return null;

    final vasteModel = artikel.vasteInzethorData;
    if (koppeling.isVasteInzethor && vasteModel != null) {
      return OffertePrijsBerekeningService.resultaatUitMomentopname(
        vasteModel,
        kortingToestaan: kortingToestaan,
      );
    }

    return OfferteAlgemeenArtikelPrijsService.resultaatUitMomentopname(
      prijsData: artikel.offertePrijsData,
      breedteMm: artikel.raammaatBreedteMm,
      hoogteMm: artikel.raammaatHoogteMm,
      kortingToestaan: kortingToestaan,
    );
  }

  static String _normaliseer(String waarde) {
    return waarde.trim().toLowerCase().replaceAll('_', '').replaceAll(' ', '');
  }
}
