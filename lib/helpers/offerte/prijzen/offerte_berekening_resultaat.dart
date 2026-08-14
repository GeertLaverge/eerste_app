// THIMACO-CONTROLE: PRIJSARCHITECTUUR-OPRUIMEN-STAP5D4A-RESULTAAT-PRIJS-PER-POSITIE-CATEGORIE-20260814
// THIMACO-CONTROLE: PRIJSARCHITECTUUR-STAP5D3D-COMPATIBILITEITSGETTERS-DEFINITIEF-WEG-20260814
// THIMACO-CONTROLE: PRIJSARCHITECTUUR-STAP5D3B-STABILISATIE-TIJDELIJKE-PDF-BRUG-20260814
// THIMACO-CONTROLE: PRIJSARCHITECTUUR-OPRUIMEN-STAP5D3B-RESULTAAT-ZONDER-VRIJ-EN-VERDEELD-20260814
// THIMACO-CONTROLE: PRIJS-PER-POSITIE-PDF-WEERGAVE-20260813
// THIMACO-CONTROLE: PRIJS-PER-POSITIE-MEETELLEN-IN-TOTAAL-20260813
// THIMACO-CONTROLE: ALGEMENE-OPMETING-KORTING-ALLEEN-OP-AANKOOPDEEL-20260802
// THIMACO-CONTROLE: WINSTMARGE-BASIS-OVERRIDE-ALGEMENE-OPMETING-20260802
import 'offerte_artikel_prijs_data_model.dart';
import 'offerte_prijs_categorie.dart';
import 'offerte_prijs_eenheid.dart';
import 'offerte_prijs_uitschrijfmodus.dart';
import 'offerte_toegepaste_prijsregel_model.dart';

class OfferteBerekeningResultaat {
  OfferteBerekeningResultaat({
    required double basisTotaalExclBtw,
    int aantalArtikelen = 1,
    double? basisPrijsPerStukExclBtw,
    List<OfferteToegepastePrijsregelModel> technischePrijsregels =
        const <OfferteToegepastePrijsregelModel>[],
    List<OffertePrijsPerPositieRegelModel> prijsPerPositieRegels =
        const <OffertePrijsPerPositieRegelModel>[],
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
       prijsPerPositieRegels =
           List<OffertePrijsPerPositieRegelModel>.unmodifiable(
             prijsPerPositieRegels,
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

  /// Lokale A/V-regels die uitsluitend bij deze offertepositie horen.
  /// De offerteweergave (Uit / Tekst / €) verandert nooit de berekening.
  final List<OffertePrijsPerPositieRegelModel> prijsPerPositieRegels;

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

  bool get heeftPrijsPerPositieRegels {
    return geldigePrijsPerPositieRegels.isNotEmpty;
  }

  List<OffertePrijsPerPositieRegelModel> get geldigePrijsPerPositieRegels {
    return List<OffertePrijsPerPositieRegelModel>.unmodifiable(
      prijsPerPositieRegels.where((regel) {
        return regel.isGeldig && regel.eindTotaalExclBtw > 0.0;
      }),
    );
  }

  bool get heeftArtikelWinstmarge {
    return winstmargeBedragExclBtw > 0.0;
  }

  bool get heeftArtikelKorting {
    return kortingBedragExclBtw > 0.0;
  }

  List<OfferteToegepastePrijsregelModel> get allePrijsregels {
    return List<OfferteToegepastePrijsregelModel>.unmodifiable(
      technischePrijsregels,
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
  ///
  /// Lokale prijs-per-positieregels met weergave `€` worden hier uitsluitend
  /// voor de PDF/weergavelaag als een bestaande toegepaste prijsregel
  /// aangeboden. Ze worden bewust NIET aan [prijsregelsVoorOfferte] toegevoegd,
  /// omdat hun bedrag reeds afzonderlijk in [prijsPerPositieTotaalExclBtw]
  /// meetelt. Zo kan de bestaande PDF-opbouw ze tonen zonder dubbel te tellen.
  List<OfferteToegepastePrijsregelModel>
  get afzonderlijkePrijsregelsVoorOfferte {
    final bestaande = prijsregelsVoorOfferte.where((regel) {
      return regel.toonAfzonderlijkePrijsOpOfferte;
    });
    final lokale = geldigePrijsPerPositieRegels
        .where((regel) => regel.offerteWeergave.toonPrijs)
        .map(_prijsPerPositieAlsToegepastePrijsregel);

    return List<OfferteToegepastePrijsregelModel>.unmodifiable(
      <OfferteToegepastePrijsregelModel>[...bestaande, ...lokale],
    );
  }

  /// Regels waarvan alleen de omschrijving op de klantofferte zichtbaar is.
  /// Het bedrag blijft wel volledig in het positie- en eindtotaal verwerkt.
  ///
  /// Lokale regels met weergave `Tekst` volgen exact dezelfde bestaande
  /// PDF-route als de oudere prijsregels zonder afzonderlijk bedrag.
  List<OfferteToegepastePrijsregelModel>
  get omschrijvingZonderPrijsRegelsVoorOfferte {
    final bestaande = prijsregelsVoorOfferte.where((regel) {
      return regel.toonOmschrijvingZonderPrijsOpOfferte;
    });
    final lokale = geldigePrijsPerPositieRegels
        .where((regel) {
          return regel.offerteWeergave.toonOmschrijving &&
              !regel.offerteWeergave.toonPrijs;
        })
        .map(_prijsPerPositieAlsToegepastePrijsregel);

    return List<OfferteToegepastePrijsregelModel>.unmodifiable(
      <OfferteToegepastePrijsregelModel>[...bestaande, ...lokale],
    );
  }

  OfferteToegepastePrijsregelModel _prijsPerPositieAlsToegepastePrijsregel(
    OffertePrijsPerPositieRegelModel regel,
  ) {
    final uitschrijfmodus = regel.offerteWeergave.toonPrijs
        ? OffertePrijsUitschrijfmodus.invullenEnOfferteMetPrijs
        : OffertePrijsUitschrijfmodus.invullenEnOfferteZonderPrijs;

    return OfferteToegepastePrijsregelModel(
      bronPrijsregelId: 'prijsPerPositie::${regel.id}',
      categorie: OffertePrijsCategorie.prijsPerPositie,
      omschrijving: regel.omschrijving,
      prijsExclBtw: regel.verkoopPrijsPerEenheidExclBtw,
      eenheid: OffertePrijsEenheid.vast,
      hoeveelheid: regel.veiligAantal,
      totaalExclBtw: regel.eindTotaalExclBtw,
      uitschrijfmodus: uitschrijfmodus,
    );
  }

  double get technischeTotaalExclBtw {
    return _som(technischePrijsregels.where((regel) => !regel.isOptie));
  }

  /// Verkoopwaarde van alle geldige lokale prijs-per-positieregels.
  /// A-regels bevatten hier hun eigen winst; V-regels hun ingevoerde
  /// verkoopprijs. Deze regels krijgen geen extra artikelwinstmarge of korting.
  double get prijsPerPositieTotaalExclBtw {
    final totaal = geldigePrijsPerPositieRegels.fold<double>(
      0.0,
      (som, regel) => som + regel.eindTotaalExclBtw,
    );
    return _rondBedragAf(totaal);
  }

  double get prijsPerPositieAankoopBasisTotaalExclBtw {
    final totaal = geldigePrijsPerPositieRegels
        .where((regel) => regel.isAankoop)
        .fold<double>(0.0, (som, regel) => som + regel.basisTotaalExclBtw);
    return _rondBedragAf(totaal);
  }

  double get prijsPerPositieWinstTotaalExclBtw {
    final totaal = geldigePrijsPerPositieRegels.fold<double>(
      0.0,
      (som, regel) => som + regel.winstBedragExclBtw,
    );
    return _rondBedragAf(totaal);
  }

  double get optiePrijsregelsTotaalExclBtw {
    return _som(optiePrijsregelsVoorOfferte);
  }

  double get offertePrijsregelsTotaalExclBtw {
    return _som(prijsregelsVoorOfferte);
  }

  /// De winstmarge wordt uitsluitend als opslag op de ingevoerde prijs per
  /// stuk berekend. Technische prijsregels en prijs-per-positieregels blijven
  /// buiten deze berekening.
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

  double get totaalExclBtw {
    return _rondBedragAf(
      basisNaWinstmargeEnKortingExclBtw +
          technischeTotaalExclBtw +
          prijsPerPositieTotaalExclBtw,
    );
  }

  /// Totaal dat werkelijk aan de klant wordt aangerekend.
  /// Verborgen prijsregels blijven hierin aanwezig.
  double get offerteTotaalExclBtw {
    return _rondBedragAf(
      basisNaWinstmargeEnKortingExclBtw +
          offertePrijsregelsTotaalExclBtw +
          prijsPerPositieTotaalExclBtw,
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
