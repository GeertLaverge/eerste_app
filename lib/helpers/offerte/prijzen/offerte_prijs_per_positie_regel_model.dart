// THIMACO-CONTROLE: BUITENJALOEZIE-EXACT-ZOALS-VOORZETSCREEN-PRIJSKOPPELING-20260803
// THIMACO-CONTROLE: BUITENJALOEZIE-PRIJSKOPPELING-FASE-3A-20260803
// THIMACO-CONTROLE: ALGEMENE-OPMETING-VERKOOP-AANKOOP-WINST-KORTING-20260802
// THIMACO-CONTROLE: ALGEMENE-OPMETING-AANKOOP-VERKOOP-PRIJSKOPPELING-20260802
// THIMACO-CONTROLE: UITVALSCHERM-VOLLEDIGE-PRIJSKOPPELING-20260801
// THIMACO-CONTROLE: VOORZETROLLUIK-VOLLEDIGE-PRIJSKOPPELING-20260731
// THIMACO-CONTROLE: VOORZETSCREEN-INBOUWSCHAKELAAR-TECHNISCHE-PRIJS-20260730-2205
// THIMACO-CONTROLE: VELUX-TECHNISCHE-AFWERKINGSPRIJZEN-20260730
// THIMACO-CONTROLE: VELUX-PARTICULIERE-VERKOOPPRIJS-ZONDER-CORRECTIES-20260730
// THIMACO-CONTROLE: VELUX-PRIJSKOPPELING-FASE-3-20260729-2212
// THIMACO-CONTROLE: SEKTIONALE-POORTEN-TECHNISCHE-PRIJSKOPPELING-FINAAL-20260729-1214
// THIMACO-CONTROLE: SEKTIONALE-POORTEN-TECHNISCHE-STOPCONTACTPRIJS-20260729
// THIMACO-CONTROLE: PLOOIWERKEN-PRIJS-KOPPELING-20260728
// THIMACO-CONTROLE: SCHUIFVLIEGENDEUR-INSTELLINGEN-EN-PRIJZEN-20260728
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
/// Vliegendeur, Schuifvliegendeur en Velux gebruiken eveneens de bestaande
/// `offertePrijsData`. Ze hebben een eigen prijsprofiel voor vrije
/// artikelprijzen en prijzen voor alle artikelen. Velux bewaart zijn berekende
/// catalogustotaal als basisprijs. Alleen de gekozen Velux-binnenafwerking
/// wordt aanvullend via de centrale technische-keuzeprijzen berekend.
///
/// Er is geen wijziging aan prijsmodellen of JSON-opslag nodig.
class OfferteArtikelPrijsKoppeling {
  const OfferteArtikelPrijsKoppeling({
    required this.adapterId,
    required this.formulierType,
    required this.formulierNaam,
    required this.isVasteInzethor,
    required this.ondersteuntTechnischeKeuzeprijzen,
    this.isHandmatigGeprijsdArtikel = false,
  });

  final String adapterId;
  final String formulierType;
  final String formulierNaam;
  final bool isVasteInzethor;
  final bool ondersteuntTechnischeKeuzeprijzen;
  final bool isHandmatigGeprijsdArtikel;

  bool get isAlgemeenArtikel {
    return !isVasteInzethor && !isHandmatigGeprijsdArtikel;
  }
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
        isHandmatigGeprijsdArtikel: true,
      );

  static const OfferteArtikelPrijsKoppeling schuifvliegendeur =
      OfferteArtikelPrijsKoppeling(
        adapterId: 'schuifvliegendeur',
        formulierType: 'schuifvliegendeur',
        formulierNaam: 'Schuifvliegendeur',
        isVasteInzethor: false,
        ondersteuntTechnischeKeuzeprijzen: false,
        isHandmatigGeprijsdArtikel: true,
      );

  static const OfferteArtikelPrijsKoppeling plooiwerken =
      OfferteArtikelPrijsKoppeling(
        adapterId: 'plooiwerken',
        formulierType: 'plooiwerken',
        formulierNaam: 'Plooiwerken',
        isVasteInzethor: false,
        ondersteuntTechnischeKeuzeprijzen: false,
        isHandmatigGeprijsdArtikel: true,
      );

  static const OfferteArtikelPrijsKoppeling voorzetscreen =
      OfferteArtikelPrijsKoppeling(
        adapterId: 'voorzetscreen',
        formulierType: 'voorzetscreen',
        formulierNaam: 'Voorzetscreen',
        isVasteInzethor: false,
        ondersteuntTechnischeKeuzeprijzen: true,
        isHandmatigGeprijsdArtikel: true,
      );

  static const OfferteArtikelPrijsKoppeling buitenjaloezie =
      OfferteArtikelPrijsKoppeling(
        adapterId: 'buitenjaloezie',
        formulierType: 'buitenjaloezie',
        formulierNaam: 'Buitenjaloezie',
        isVasteInzethor: false,
        ondersteuntTechnischeKeuzeprijzen: true,
        isHandmatigGeprijsdArtikel: true,
      );

  static const OfferteArtikelPrijsKoppeling voorzetrolluik =
      OfferteArtikelPrijsKoppeling(
        adapterId: 'voorzetrolluik',
        formulierType: 'voorzetrolluik',
        formulierNaam: 'Voorzetrolluik',
        isVasteInzethor: false,
        ondersteuntTechnischeKeuzeprijzen: true,
        isHandmatigGeprijsdArtikel: true,
      );

  static const OfferteArtikelPrijsKoppeling uitvalscherm =
      OfferteArtikelPrijsKoppeling(
        adapterId: 'uitvalscherm',
        formulierType: 'uitvalscherm',
        formulierNaam: 'Uitvalscherm',
        isVasteInzethor: false,
        ondersteuntTechnischeKeuzeprijzen: true,
        isHandmatigGeprijsdArtikel: true,
      );

  static const OfferteArtikelPrijsKoppeling algemeneOpmeting =
      OfferteArtikelPrijsKoppeling(
        adapterId: 'algemeneOpmeting',
        formulierType: 'algemeneOpmeting',
        formulierNaam: 'Algemene opmeting',
        isVasteInzethor: false,
        ondersteuntTechnischeKeuzeprijzen: false,
        isHandmatigGeprijsdArtikel: true,
      );

  static const OfferteArtikelPrijsKoppeling sektionalePoort =
      OfferteArtikelPrijsKoppeling(
        adapterId: 'sektionalePoort',
        formulierType: 'sektionalePoort',
        formulierNaam: 'Sektionale poorten',
        isVasteInzethor: false,
        ondersteuntTechnischeKeuzeprijzen: true,
        isHandmatigGeprijsdArtikel: true,
      );

  static const OfferteArtikelPrijsKoppeling veluxDakraam =
      OfferteArtikelPrijsKoppeling(
        adapterId: 'veluxDakraam',
        formulierType: 'veluxDakraam',
        formulierNaam: 'Velux dakramen',
        isVasteInzethor: false,
        ondersteuntTechnischeKeuzeprijzen: true,
        isHandmatigGeprijsdArtikel: true,
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
  /// Vliegendeur en Schuifvliegendeur hebben een eigen prijsprofiel, maar de
  /// eigenschap
  /// [OfferteArtikelPrijsKoppeling.ondersteuntTechnischeKeuzeprijzen] blijft
  /// voor deze koppeling false.
  static const List<OfferteArtikelPrijsKoppeling> alleKoppelingen =
      <OfferteArtikelPrijsKoppeling>[
        vasteInzethor,
        vliegendeur,
        schuifvliegendeur,
        plooiwerken,
        voorzetscreen,
        buitenjaloezie,
        voorzetrolluik,
        uitvalscherm,
        sektionalePoort,
        veluxDakraam,
        ...algemeneKoppelingen,
        algemeneOpmeting,
      ];

  /// Artikelen waarvan de basisprijs per stuk handmatig wordt ingevuld.
  ///
  /// Deze artikelen kunnen daarnaast vrije artikelprijzen en prijzen voor alle
  /// artikelen uit hun eigen prijsprofiel ontvangen.
  static const List<OfferteArtikelPrijsKoppeling>
  handmatigGeprijsdeKoppelingen = <OfferteArtikelPrijsKoppeling>[
    vliegendeur,
    schuifvliegendeur,
    plooiwerken,
    voorzetscreen,
    buitenjaloezie,
    voorzetrolluik,
    uitvalscherm,
    sektionalePoort,
    veluxDakraam,
    algemeneOpmeting,
  ];

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
    'schuifvliegendeur',
    'plooiwerken',
    'voorzetscreen',
    'buitenjaloezie',
    'voorzetrolluik',
    'uitvalscherm',
    'sektionalePoort',
    'veluxDakraam',
    ...algemeneFormulierTypes,
    'algemeneOpmeting',
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

    if (artikel.schuifvliegendeurData != null) {
      return schuifvliegendeur;
    }

    if (artikel.plooiwerkenData != null) {
      return plooiwerken;
    }

    if (artikel.voorzetscreenData != null) {
      return voorzetscreen;
    }

    if (artikel.buitenjaloezieData != null) {
      return buitenjaloezie;
    }

    if (artikel.voorzetrolluikData != null) {
      return voorzetrolluik;
    }

    if (artikel.uitvalschermData != null) {
      return uitvalscherm;
    }

    if (artikel.algemeneOpmetingData != null) {
      return algemeneOpmeting;
    }

    if (artikel.sektionalePoortData != null) {
      return sektionalePoort;
    }

    if (artikel.veluxDakraamData != null) {
      return veluxDakraam;
    }

    final koppeling = koppelingVoorFormulierType(
      artikel.formulierTypeGenormaliseerd,
    );

    // Een handmatig geprijsd artikel wordt alleen als dusdanig behandeld
    // wanneer de positie werkelijk de bijbehorende modeldata bevat. Zo wordt
    // een fout formulierlabel niet onbedoeld als volledig toebehorenartikel
    // verwerkt.
    if (koppeling?.isHandmatigGeprijsdArtikel == true) {
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
  /// Dit is voor Vliegendeur en Schuifvliegendeur true. Dat betekent niet
  /// dat technische keuzeprijzen ondersteund worden; daarvoor moet afzonderlijk
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

  /// Geeft het werkelijke aantal stuks binnen één overzichtspositie.
  ///
  /// Algemene raam-, deur- en schuifraamposities stellen telkens één stuk voor.
  /// Artikeltypes met een eigen aantalveld, zoals vaste inzethorren en
  /// vliegendeuren en schuifvliegendeuren, gebruiken dat opgeslagen aantal. Een ongeldig of leeg
  /// aantal wordt altijd veilig als één stuk behandeld.
  static int aantalVoorArtikel(OpmetingOverzichtRaamItem artikel) {
    final aantal =
        artikel.vasteInzethorData?.aantal ??
        artikel.vliegendeurData?.aantal ??
        artikel.schuifvliegendeurData?.aantal ??
        artikel.plooiwerkenData?.aantal ??
        artikel.voorzetscreenData?.aantal ??
        artikel.buitenjaloezieData?.aantal ??
        artikel.voorzetrolluikData?.aantal ??
        artikel.uitvalschermData?.aantal ??
        (artikel.algemeneOpmetingData != null ? 1 : null) ??
        artikel.sektionalePoortData?.aantal ??
        artikel.veluxDakraamData?.veiligAantal ??
        1;

    return aantal < 1 ? 1 : aantal;
  }

  static int breedteMmVoorArtikel(OpmetingOverzichtRaamItem artikel) {
    return artikel.vasteInzethorData?.breedteMm ??
        artikel.vliegendeurData?.breedteMm ??
        artikel.schuifvliegendeurData?.breedteMm ??
        artikel.voorzetscreenData?.breedteMm ??
        artikel.buitenjaloezieData?.totaleBreedteMm ??
        artikel.voorzetrolluikData?.breedteMm ??
        artikel.uitvalschermData?.breedteMm ??
        artikel.sektionalePoortData?.breedteMm ??
        artikel.veluxDakraamData?.breedteMm ??
        artikel.raammaatBreedteMm;
  }

  static int hoogteMmVoorArtikel(OpmetingOverzichtRaamItem artikel) {
    return artikel.vasteInzethorData?.hoogteMm ??
        artikel.vliegendeurData?.hoogteMm ??
        artikel.schuifvliegendeurData?.hoogteMm ??
        artikel.voorzetscreenData?.hoogteMm ??
        artikel.buitenjaloezieData?.totaleHoogteMm ??
        artikel.voorzetrolluikData?.hoogteMm ??
        artikel.uitvalschermData?.uitvalMm ??
        artikel.sektionalePoortData?.hoogteMm ??
        artikel.veluxDakraamData?.hoogteMm ??
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

    final algemeneOpmeting = artikel.algemeneOpmetingData;
    if (algemeneOpmeting != null) {
      // Algemene opmeting beheert vrije prijzen bewust als zichtbare,
      // verplaatsbare blokken in de fiche. Automatisch opgebouwde vrije-
      // prijsselecties uit het centrale profiel worden hier daarom niet nog
      // eens meegerekend; anders zou een gekozen regel dubbel in het totaal
      // terechtkomen.
      final actuelePrijsData = artikel.offertePrijsData.copyWith(
        prijsPerStukExclBtw: algemeneOpmeting.prijsTotaalExclBtw,
        toegepasteTechnischePrijsregels:
            const <OfferteToegepastePrijsregelModel>[],
        technischePrijsSignatuur: '',
        vrijeArtikelPrijsSelecties: const [],
        vrijeArtikelPrijsSignatuur: '',
      );
      final standaardResultaat =
          OfferteAlgemeenArtikelPrijsService.resultaatUitMomentopname(
            prijsData: actuelePrijsData,
            aantal: 1,
            breedteMm: breedteMmVoorArtikel(artikel),
            hoogteMm: hoogteMmVoorArtikel(artikel),
            kortingToestaan: kortingToestaan,
          );

      final aankoopTotaal = algemeneOpmeting.aankoopPrijsTotaalExclBtw;
      final winstmargePercentage = actuelePrijsData.artikelWinstmargePercentage;
      final kortingPercentage = kortingToestaan
          ? actuelePrijsData.artikelKortingPercentage
          : 0.0;
      final winstmargeBedrag = aankoopTotaal * (winstmargePercentage / 100.0);
      final aankoopdeelNaWinstmarge = aankoopTotaal + winstmargeBedrag;

      return OfferteBerekeningResultaat(
        basisTotaalExclBtw: standaardResultaat.basisTotaalExclBtw,
        aantalArtikelen: standaardResultaat.aantalArtikelen,
        basisPrijsPerStukExclBtw: standaardResultaat.basisPrijsPerStukExclBtw,
        technischePrijsregels: standaardResultaat.technischePrijsregels,
        vrijeArtikelPrijsregels: standaardResultaat.vrijeArtikelPrijsregels,
        verdeeldePrijsregels: standaardResultaat.verdeeldePrijsregels,
        winstmargePercentage: winstmargePercentage,
        winstmargeBasisExclBtwOverride: aankoopTotaal,
        kortingBasisExclBtwOverride: aankoopdeelNaWinstmarge,
        winstmargeOmschrijving: standaardResultaat.winstmargeOmschrijving,
        kortingPercentage: kortingPercentage,
        kortingOmschrijving: standaardResultaat.kortingOmschrijving,
      );
    }

    if (artikel.veluxDakraamData != null) {
      final verkoopPrijsData = wijzigPrijsData(
        prijsData: artikel.offertePrijsData,
        artikelWinstmargePercentage: 0.0,
        artikelKortingPercentage: 0.0,
      );

      return OfferteAlgemeenArtikelPrijsService.resultaatUitMomentopname(
        prijsData: verkoopPrijsData,
        aantal: aantalVoorArtikel(artikel),
        breedteMm: breedteMmVoorArtikel(artikel),
        hoogteMm: hoogteMmVoorArtikel(artikel),
        kortingToestaan: false,
      );
    }

    if (koppeling.isHandmatigGeprijsdArtikel) {
      return OfferteAlgemeenArtikelPrijsService.resultaatUitMomentopname(
        prijsData: artikel.offertePrijsData,
        aantal: aantalVoorArtikel(artikel),
        breedteMm: breedteMmVoorArtikel(artikel),
        hoogteMm: hoogteMmVoorArtikel(artikel),
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
