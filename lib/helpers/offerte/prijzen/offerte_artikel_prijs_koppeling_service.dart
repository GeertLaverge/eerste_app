// THIMACO-CONTROLE: OFFERTE-ARTIKEL-PRIJS-KOPPELING-SERVICE-20260723
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
/// de bestaande `offertePrijsData` van het overzichtsitem.
///
/// De Vliegendeur gebruikt eveneens de bestaande `offertePrijsData`. Zij heeft
/// een eigen prijsprofiel voor vrije artikelprijzen en prijzen voor alle
/// artikelen, maar ondersteunt bewust geen technische-keuzeprijzen.
///
/// Er is geen wijziging aan prijsmodellen of JSON-opslag nodig.
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

  bool get isHandmatigGeprijsdArtikel => adapterId == 'vliegendeur';

  bool get isAlgemeenArtikel => !isVasteInzethor && !isHandmatigGeprijsdArtikel;
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

  static const OfferteArtikelPrijsKoppeling vliegendeur =
      OfferteArtikelPrijsKoppeling(
        adapterId: 'vliegendeur',
        formulierType: 'vliegendeur',
        formulierNaam: 'Vliegendeur',
        isVasteInzethor: false,
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

  /// Alle artikelgroepen die in Instellingen → Offerteprijzen voorkomen.
  ///
  /// De Vliegendeur heeft een eigen prijsprofiel, maar de eigenschap
  /// [OfferteArtikelPrijsKoppeling.ondersteuntTechnischeKeuzeprijzen] blijft
  /// voor deze koppeling false.
  static const List<OfferteArtikelPrijsKoppeling> alleKoppelingen =
      <OfferteArtikelPrijsKoppeling>[
        vasteInzethor,
        vliegendeur,
        ...algemeneKoppelingen,
      ];

  /// Artikelen waarvan de basisprijs per stuk handmatig wordt ingevuld.
  ///
  /// Deze artikelen kunnen daarnaast vrije artikelprijzen en prijzen voor alle
  /// artikelen uit hun eigen prijsprofiel ontvangen.
  static const List<OfferteArtikelPrijsKoppeling>
  handmatigGeprijsdeKoppelingen = <OfferteArtikelPrijsKoppeling>[vliegendeur];

  /// Volledige lijst voor artikelprijsverwerking, prijsinstellingen, totalen en
  /// prijsoverzichten.
  static const List<OfferteArtikelPrijsKoppeling> artikelPrijsKoppelingen =
      <OfferteArtikelPrijsKoppeling>[...alleKoppelingen];

  static const List<String> algemeneFormulierTypes = <String>[
    'pvcRaam',
    'aluRaam',
    'pvcSchuifraam',
    'aluSchuifraam',
    'pvcDeur',
    'aluDeur',
  ];

  /// Formuliertypes waarvoor een prijsprofiel uit Instellingen wordt geladen.
  static const List<String> ondersteundeFormulierTypes = <String>[
    'vasteInzethor',
    'vliegendeur',
    ...algemeneFormulierTypes,
  ];

  static OfferteArtikelPrijsKoppeling? koppelingVoorArtikel(
    OpmetingOverzichtRaamItem artikel,
  ) {
    if (artikel.vasteInzethorData != null) {
      return vasteInzethor;
    }

    if (artikel.vliegendeurData != null) {
      return vliegendeur;
    }

    final koppeling = koppelingVoorFormulierType(
      artikel.formulierTypeGenormaliseerd,
    );

    // Een Vliegendeur wordt alleen als dusdanig behandeld wanneer de positie
    // werkelijk Vliegendeur-data bevat. Zo wordt een fout formulierlabel niet
    // onbedoeld als volledig Vliegendeur-artikel verwerkt.
    if (koppeling?.adapterId == vliegendeur.adapterId) {
      return null;
    }

    return koppeling?.isAlgemeenArtikel == true ? koppeling : null;
  }

  static OfferteArtikelPrijsKoppeling? koppelingVoorFormulierType(
    String formulierType,
  ) {
    final sleutel = _normaliseer(formulierType);

    for (final koppeling in artikelPrijsKoppelingen) {
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

    if (koppeling != null) {
      return koppeling.formulierNaam;
    }

    return formulierType.trim().isEmpty ? 'Artikel' : formulierType.trim();
  }

  static bool isOndersteundArtikel(OpmetingOverzichtRaamItem artikel) {
    return koppelingVoorArtikel(artikel) != null;
  }

  static bool isAlgemeenArtikel(OpmetingOverzichtRaamItem artikel) {
    final koppeling = koppelingVoorArtikel(artikel);

    if (koppeling == null) {
      return false;
    }

    return algemeneKoppelingen.any(
      (algemeneKoppeling) => algemeneKoppeling.adapterId == koppeling.adapterId,
    );
  }

  /// Geeft aan of het artikel een eigen profiel heeft onder
  /// Instellingen → Offerteprijzen.
  ///
  /// Dit is voor de Vliegendeur true. Dat betekent niet dat technische
  /// keuzeprijzen ondersteund worden; daarvoor moet afzonderlijk
  /// [ondersteuntTechnischeKeuzeprijzen] worden gecontroleerd.
  static bool ondersteuntPrijsinstellingenVoorArtikel(
    OpmetingOverzichtRaamItem artikel,
  ) {
    final koppeling = koppelingVoorArtikel(artikel);

    if (koppeling == null) {
      return false;
    }

    return alleKoppelingen.any(
      (instellingenKoppeling) =>
          instellingenKoppeling.adapterId == koppeling.adapterId,
    );
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

    if (koppeling == null) {
      return null;
    }

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

    if (koppeling == null) {
      return artikel;
    }

    if (koppeling.isVasteInzethor) {
      final model = artikel.vasteInzethorData;

      if (model == null) {
        return artikel;
      }

      return artikel.copyWith(
        vasteInzethorData: model.copyWithPrijsData(prijsData),
      );
    }

    return artikel.copyWith(offertePrijsData: prijsData);
  }

  static int aantalVoorArtikel(OpmetingOverzichtRaamItem artikel) {
    return artikel.vasteInzethorData?.aantal ??
        artikel.vliegendeurData?.aantal ??
        1;
  }

  static int breedteMmVoorArtikel(OpmetingOverzichtRaamItem artikel) {
    return artikel.vasteInzethorData?.breedteMm ??
        artikel.vliegendeurData?.breedteMm ??
        artikel.raammaatBreedteMm;
  }

  static int hoogteMmVoorArtikel(OpmetingOverzichtRaamItem artikel) {
    return artikel.vasteInzethorData?.hoogteMm ??
        artikel.vliegendeurData?.hoogteMm ??
        artikel.raammaatHoogteMm;
  }

  static OfferteBerekeningResultaat? resultaatVoorArtikel(
    OpmetingOverzichtRaamItem artikel, {
    bool kortingToestaan = true,
  }) {
    final koppeling = koppelingVoorArtikel(artikel);

    if (koppeling == null) {
      return null;
    }

    final vasteModel = artikel.vasteInzethorData;

    if (koppeling.isVasteInzethor && vasteModel != null) {
      return OffertePrijsBerekeningService.resultaatUitMomentopname(
        vasteModel,
        kortingToestaan: kortingToestaan,
      );
    }

    final vliegendeurModel = artikel.vliegendeurData;

    if (koppeling.adapterId == vliegendeur.adapterId &&
        vliegendeurModel != null) {
      return OfferteAlgemeenArtikelPrijsService.resultaatUitMomentopname(
        prijsData: artikel.offertePrijsData,
        aantal: vliegendeurModel.aantal,
        breedteMm: vliegendeurModel.breedteMm,
        hoogteMm: vliegendeurModel.hoogteMm,
        kortingToestaan: kortingToestaan,
      );
    }

    return OfferteAlgemeenArtikelPrijsService.resultaatUitMomentopname(
      prijsData: artikel.offertePrijsData,
      aantal: aantalVoorArtikel(artikel),
      breedteMm: breedteMmVoorArtikel(artikel),
      hoogteMm: hoogteMmVoorArtikel(artikel),
      kortingToestaan: kortingToestaan,
    );
  }

  static String _normaliseer(String waarde) {
    return waarde.trim().toLowerCase().replaceAll('_', '').replaceAll(' ', '');
  }
}
