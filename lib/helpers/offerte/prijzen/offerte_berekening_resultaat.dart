// THIMACO-CONTROLE: ALGEMENE-OPMETING-KORTING-ALLEEN-OP-AANKOOPDEEL-20260802
// THIMACO-CONTROLE: WINSTMARGE-BASIS-OVERRIDE-ALGEMENE-OPMETING-20260802
import 'offerte_toegepaste_prijsregel_model.dart';

class OfferteBerekeningResultaat {
  OfferteBerekeningResultaat({
    required double basisTotaalExclBtw,
    int aantalArtikelen = 1,
    double? basisPrijsPerStukExclBtw,
    List<OfferteToegepastePrijsregelModel> technischePrijsregels =
        const <OfferteToegepastePrijsregelModel>[],
    List<OfferteToegepastePrijsregelModel> vrijeArtikelPrijsregels =
        const <OfferteToegepastePrijsregelModel>[],
    List<OfferteToegepastePrijsregelModel> verdeeldePrijsregels =
        const <OfferteToegepastePrijsregelModel>[],
    double winstmargePercentage = 0,
    double? winstmargeBasisExclBtwOverride,
    double? kortingBasisExclBtwOverride,
    String winstmargeOmschrijving = 'Winstmarge',
    double kortingPercentage = 0,
    String kortingOmschrijving = 'Korting',
  }) : basisTotaalExclBtw = _rondBedragAf(basisTotaalExclBtw),
       aantalArtikelen = aantalArtikelen < 1 ? 1 : aantalArtikelen,
       basisPrijsPerStukExclBtw = _rondHoeveelheidAf(
         basisPrijsPerStukExclBtw ??
             (basisTotaalExclBtw /
                 (aantalArtikelen < 1 ? 1 : aantalArtikelen).toDouble()),
       ),
       technischePrijsregels =
           List<OfferteToegepastePrijsregelModel>.unmodifiable(
             technischePrijsregels,
           ),
       vrijeArtikelPrijsregels =
           List<OfferteToegepastePrijsregelModel>.unmodifiable(
             vrijeArtikelPrijsregels,
           ),
       verdeeldePrijsregels =
           List<OfferteToegepastePrijsregelModel>.unmodifiable(
             verdeeldePrijsregels,
           ),
       winstmargePercentage = _normaliseerWinstmargePercentage(
         winstmargePercentage,
       ),
       winstmargeBasisExclBtwOverride = winstmargeBasisExclBtwOverride == null
           ? null
           : _rondBedragAf(winstmargeBasisExclBtwOverride),
       kortingBasisExclBtwOverride = kortingBasisExclBtwOverride == null
           ? null
           : _rondBedragAf(kortingBasisExclBtwOverride),
       winstmargeOmschrijving = winstmargeOmschrijving.trim().isEmpty
           ? 'Winstmarge'
           : winstmargeOmschrijving.trim(),
       kortingPercentage = _normaliseerKortingPercentage(kortingPercentage),
       kortingOmschrijving = kortingOmschrijving.trim().isEmpty
           ? 'Korting'
           : kortingOmschrijving.trim();

  final double basisTotaalExclBtw;
  final int aantalArtikelen;
  final double basisPrijsPerStukExclBtw;
  final List<OfferteToegepastePrijsregelModel> technischePrijsregels;
  final List<OfferteToegepastePrijsregelModel> vrijeArtikelPrijsregels;
  final List<OfferteToegepastePrijsregelModel> verdeeldePrijsregels;
  final double winstmargePercentage;

  /// Optionele interne basis waarop alleen de winstmarge wordt berekend.
  ///
  /// Zonder override blijft de bestaande werking ongewijzigd en wordt de
  /// volledige basisprijs gebruikt. Algemene opmeting gebruikt dit om alleen
  /// aankoopprijsblokken van winstmarge te voorzien, terwijl verkoopprijzen
  /// reeds hun definitieve verkoopbedrag bevatten.
  final double? winstmargeBasisExclBtwOverride;

  /// Optionele interne basis waarop uitsluitend de artikelkorting wordt
  /// berekend. Zonder override blijft de bestaande werking van alle andere
  /// fiches ongewijzigd. Algemene opmeting gebruikt het aankoopdeel na
  /// winstmarge, zodat reeds ingevoerde verkoopprijzen nooit korting krijgen.
  final double? kortingBasisExclBtwOverride;

  final String winstmargeOmschrijving;
  final double kortingPercentage;
  final String kortingOmschrijving;

  bool get heeftTechnischePrijsregels {
    return technischePrijsregels.isNotEmpty;
  }

  bool get heeftVrijeArtikelPrijsregels {
    return vrijeArtikelPrijsregels.isNotEmpty;
  }

  bool get heeftVerdeeldePrijsregels {
    return verdeeldePrijsregels.isNotEmpty;
  }

  bool get heeftArtikelWinstmarge {
    return winstmargeBedragExclBtw > 0.0;
  }

  bool get heeftArtikelKorting {
    return kortingBedragExclBtw > 0.0;
  }

  List<OfferteToegepastePrijsregelModel> get allePrijsregels {
    return List<OfferteToegepastePrijsregelModel>.unmodifiable(
      <OfferteToegepastePrijsregelModel>[
        ...technischePrijsregels,
        ...vrijeArtikelPrijsregels,
        ...verdeeldePrijsregels,
      ],
    );
  }

  /// Alle regels die werkelijk in het eindtotaal moeten worden verwerkt.
  /// Verborgen regels blijven dus aanwezig. Alleen opties worden uitgesloten.
  List<OfferteToegepastePrijsregelModel> get prijsregelsVoorOfferte {
    return List<OfferteToegepastePrijsregelModel>.unmodifiable(
      allePrijsregels.where((regel) {
        return regel.isGeldig && regel.teltMeeInOfferteTotaal;
      }),
    );
  }

  List<OfferteToegepastePrijsregelModel> get optiePrijsregelsVoorOfferte {
    return List<OfferteToegepastePrijsregelModel>.unmodifiable(
      allePrijsregels.where((regel) {
        return regel.isGeldig && regel.toonAlsOptieOpOfferte;
      }),
    );
  }

  bool get heeftOptiePrijsregels {
    return optiePrijsregelsVoorOfferte.isNotEmpty;
  }

  /// Regels waarvan zowel de omschrijving als de afzonderlijke prijs
  /// op de klantofferte zichtbaar moet zijn.
  List<OfferteToegepastePrijsregelModel>
  get afzonderlijkePrijsregelsVoorOfferte {
    return List<OfferteToegepastePrijsregelModel>.unmodifiable(
      prijsregelsVoorOfferte.where((regel) {
        return regel.toonAfzonderlijkePrijsOpOfferte;
      }),
    );
  }

  /// Regels waarvan alleen de omschrijving op de klantofferte zichtbaar is.
  /// Het bedrag blijft wel volledig in het positie- en eindtotaal verwerkt.
  List<OfferteToegepastePrijsregelModel>
  get omschrijvingZonderPrijsRegelsVoorOfferte {
    return List<OfferteToegepastePrijsregelModel>.unmodifiable(
      prijsregelsVoorOfferte.where((regel) {
        return regel.toonOmschrijvingZonderPrijsOpOfferte;
      }),
    );
  }

  double get technischeTotaalExclBtw {
    return _som(technischePrijsregels.where((regel) => !regel.isOptie));
  }

  double get vrijeArtikelTotaalExclBtw {
    return _som(vrijeArtikelPrijsregels.where((regel) => !regel.isOptie));
  }

  double get verdeeldeTotaalExclBtw {
    return _som(verdeeldePrijsregels.where((regel) => !regel.isOptie));
  }

  double get optiePrijsregelsTotaalExclBtw {
    return _som(optiePrijsregelsVoorOfferte);
  }

  double get offertePrijsregelsTotaalExclBtw {
    return _som(prijsregelsVoorOfferte);
  }

  /// Het aankoopbedrag waarop een ingestelde transportlimiet wordt getest.
  /// Winstmarge en korting worden bewust niet meegenomen.
  double get aankoopTotaalVoorLimietExclBtw {
    return _rondBedragAf(
      basisTotaalExclBtw + technischeTotaalExclBtw + vrijeArtikelTotaalExclBtw,
    );
  }

  /// De winstmarge wordt uitsluitend als opslag op de ingevoerde prijs per
  /// stuk berekend. Artikeltoeslagen, verdeelde transport- en projectkosten
  /// blijven buiten deze berekening.
  double get winstmargeBasisExclBtw {
    return winstmargeBasisExclBtwOverride ?? basisTotaalExclBtw;
  }

  double get winstmargePerStukExclBtw {
    if (winstmargePercentage <= 0.0 || winstmargeBasisExclBtw <= 0.0) {
      return 0.0;
    }

    // Zonder override blijft de bestaande berekening exact gebaseerd op de
    // opgeslagen basisprijs per stuk. Alleen Algemene opmeting gebruikt de
    // afwijkende aankoopbasis.
    final basisPerStuk = winstmargeBasisExclBtwOverride == null
        ? basisPrijsPerStukExclBtw
        : winstmargeBasisExclBtw / aantalArtikelen.toDouble();
    return _rondBedragAf(basisPerStuk * (winstmargePercentage / 100.0));
  }

  double get winstmargeBedragExclBtw {
    return _rondBedragAf(winstmargePerStukExclBtw * aantalArtikelen.toDouble());
  }

  double get prijsPerStukNaWinstmargeExclBtw {
    return _rondBedragAf(basisPrijsPerStukExclBtw + winstmargePerStukExclBtw);
  }

  double get basisNaWinstmargeExclBtw {
    return _rondBedragAf(
      prijsPerStukNaWinstmargeExclBtw * aantalArtikelen.toDouble(),
    );
  }

  /// De korting wordt uitsluitend berekend op de prijs per stuk nadat de
  /// winstmarge werd toegevoegd. Artikeltoeslagen en transportkosten worden
  /// hierdoor nooit verlaagd.
  double get kortingBasisExclBtw {
    return kortingBasisExclBtwOverride ?? basisNaWinstmargeExclBtw;
  }

  double get kortingPerStukExclBtw {
    if (kortingPercentage <= 0.0 || kortingBasisExclBtw <= 0.0) {
      return 0.0;
    }

    final basisPerStuk = kortingBasisExclBtw / aantalArtikelen.toDouble();
    return _rondBedragAf(basisPerStuk * (kortingPercentage / 100.0));
  }

  double get kortingBedragExclBtw {
    return _rondBedragAf(kortingPerStukExclBtw * aantalArtikelen.toDouble());
  }

  double get verkoopPrijsPerStukNaKortingExclBtw {
    return _rondBedragAf(
      basisNaWinstmargeEnKortingExclBtw / aantalArtikelen.toDouble(),
    );
  }

  double get basisNaWinstmargeEnKortingExclBtw {
    return _rondBedragAf(basisNaWinstmargeExclBtw - kortingBedragExclBtw);
  }

  double get totaalZonderVerdeeldeKostenExclBtw {
    return _rondBedragAf(
      basisNaWinstmargeEnKortingExclBtw +
          technischeTotaalExclBtw +
          vrijeArtikelTotaalExclBtw,
    );
  }

  /// Intern totaal op het overzicht. Dit bevat ook verdeelde kosten die niet
  /// afzonderlijk op de klantofferte worden vermeld.
  double get totaalExclBtw {
    return _rondBedragAf(
      totaalZonderVerdeeldeKostenExclBtw + verdeeldeTotaalExclBtw,
    );
  }

  /// Totaal dat werkelijk aan de klant wordt aangerekend.
  /// Verborgen prijsregels blijven hierin aanwezig.
  double get offerteTotaalExclBtw {
    return _rondBedragAf(
      basisNaWinstmargeEnKortingExclBtw + offertePrijsregelsTotaalExclBtw,
    );
  }

  double offertePrijsPerStukExclBtw(int aantal) {
    final geldigAantal = aantal < 1 ? 1 : aantal;

    return _rondHoeveelheidAf(offerteTotaalExclBtw / geldigAantal.toDouble());
  }

  static double _som(Iterable<OfferteToegepastePrijsregelModel> prijsregels) {
    final totaal = prijsregels.fold<double>(
      0.0,
      (som, regel) => som + regel.totaalExclBtw,
    );

    return _rondBedragAf(totaal);
  }

  static double _normaliseerKortingPercentage(double waarde) {
    if (!waarde.isFinite || waarde <= 0.0) {
      return 0.0;
    }

    if (waarde >= 100.0) {
      return 100.0;
    }

    return (waarde * 100.0).roundToDouble() / 100.0;
  }

  static double _normaliseerWinstmargePercentage(double waarde) {
    if (!waarde.isFinite || waarde <= 0.0) {
      return 0.0;
    }

    if (waarde >= 500.0) {
      return 500.0;
    }

    return (waarde * 100.0).roundToDouble() / 100.0;
  }

  static double _rondHoeveelheidAf(double waarde) {
    if (!waarde.isFinite || waarde < 0.0) {
      return 0.0;
    }

    return (waarde * 10000.0).roundToDouble() / 10000.0;
  }

  static double _rondBedragAf(double waarde) {
    if (!waarde.isFinite || waarde <= 0.0) {
      return 0.0;
    }

    return (waarde * 100.0).roundToDouble() / 100.0;
  }
}
