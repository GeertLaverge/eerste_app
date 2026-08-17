// THIMACO-CONTROLE: OFFERTE-PDF-KLEURAFWIJKING-VOORBLAD-20260816
// THIMACO-CONTROLE: PRIJSARCHITECTUUR-OPRUIMEN-STAP5D3A-PDFMODEL-ZONDER-PROJECTPRIJS-20260814
// THIMACO-CONTROLE: OFFERTE-OMSCHRIJVING-IN-PDF-DATA-20260809-2030
// THIMACO-CONTROLE: SCHUIFVLIEGENDEUR-OFFERTE-PDF-MODEL-20260728
import 'dart:typed_data';

import '../opmeting/overzicht/opmeting_overzicht_model.dart';
import '../opmeting/project/opmeting_project_titelhoofd_model.dart';
import 'prijzen/offerte_artikel_prijs_koppeling_service.dart';
import 'prijzen/offerte_berekening_resultaat.dart';
import 'prijzen/offerte_prijsregel_weergave_service.dart';
import 'prijzen/offerte_toegepaste_prijsregel_model.dart';

class OfferteKlantgegevens {
  const OfferteKlantgegevens({
    required this.naam,
    required this.adres,
    required this.postcodeEnGemeente,
    required this.telefoon,
    required this.email,
    required this.projectAdres,
    this.contactpersoon = '',
  });

  final String naam;
  final String contactpersoon;
  final String adres;
  final String postcodeEnGemeente;
  final String telefoon;
  final String email;
  final String projectAdres;

  factory OfferteKlantgegevens.vanTitelhoofd(
    OpmetingProjectTitelhoofd titelhoofd,
  ) {
    final adresDelen = <String>[
      titelhoofd.adres.trim(),
      titelhoofd.huisnummer.trim(),
      if (titelhoofd.busNummer.trim().isNotEmpty)
        'bus ${titelhoofd.busNummer.trim()}',
    ].where((deel) => deel.isNotEmpty).toList();

    final volledigAdres = adresDelen.join(' ');
    final telefoon = titelhoofd.gsm.trim().isNotEmpty
        ? titelhoofd.gsm.trim()
        : titelhoofd.telefoon.trim();

    return OfferteKlantgegevens(
      naam: titelhoofd.klantNaamMetAanspreking.trim(),
      contactpersoon: titelhoofd.contactpersoon.trim(),
      adres: volledigAdres,
      postcodeEnGemeente: titelhoofd.plaats.trim(),
      telefoon: telefoon,
      email: titelhoofd.email.trim(),
      projectAdres: <String>[
        volledigAdres,
        titelhoofd.plaats.trim(),
      ].where((deel) => deel.isNotEmpty).join(', '),
    );
  }
}

class OffertePrijsOptieRegel {
  const OffertePrijsOptieRegel({
    required this.omschrijving,
    required this.bedragExclBtw,
  });

  final String omschrijving;
  final double bedragExclBtw;
}

class OfferteSamengevoegdeArtikelPrijsregel {
  const OfferteSamengevoegdeArtikelPrijsregel({
    required this.sleutel,
    required this.omschrijving,
    required this.totaalExclBtw,
    required this.toonAfzonderlijkePrijs,
    required this.toonOmschrijvingZonderPrijs,
    required this.toonAlsOptie,
  });

  final String sleutel;
  final String omschrijving;
  final double totaalExclBtw;
  final bool toonAfzonderlijkePrijs;
  final bool toonOmschrijvingZonderPrijs;
  final bool toonAlsOptie;

  bool get isZichtbaar =>
      toonAfzonderlijkePrijs || toonOmschrijvingZonderPrijs || toonAlsOptie;
}

class OfferteDocumentData {
  OfferteDocumentData({
    required this.klant,
    required this.offerteNummer,
    required this.offerteDatum,
    required this.btwTarief,
    this.offerteOmschrijving = '',
    required this.posities,
    this.projectKleurBinnen = '',
    this.projectKleurBuiten = '',
    this.ralKleurToebehoren = '',
    this.kleurAfwijking = '',
    String kortingOmschrijving = 'Korting',
    Map<String, Uint8List> pvcRaamTekeningen = const <String, Uint8List>{},
  }) : pvcRaamTekeningen = Map<String, Uint8List>.unmodifiable(
         pvcRaamTekeningen,
       ),
       kortingOmschrijving = kortingOmschrijving.trim().isEmpty
           ? 'Korting'
           : kortingOmschrijving.trim();

  final OfferteKlantgegevens klant;
  final String offerteNummer;
  final DateTime offerteDatum;
  final String btwTarief;
  final String offerteOmschrijving;
  final String kortingOmschrijving;
  final String projectKleurBinnen;
  final String projectKleurBuiten;
  final String ralKleurToebehoren;
  final String kleurAfwijking;
  final List<OpmetingOverzichtRaamItem> posities;
  final Map<String, Uint8List> pvcRaamTekeningen;

  Uint8List? pvcRaamTekeningVoor(OpmetingOverzichtRaamItem positie) {
    final id = positie.id.trim();
    if (id.isEmpty) return null;
    return pvcRaamTekeningen[id];
  }

  bool isVliegendeurPositie(OpmetingOverzichtRaamItem positie) {
    return positie.vliegendeurData != null ||
        positie.formulierTypeGenormaliseerd == 'vliegendeur';
  }

  bool isSchuifvliegendeurPositie(OpmetingOverzichtRaamItem positie) {
    return positie.schuifvliegendeurData != null ||
        positie.formulierTypeGenormaliseerd == 'schuifvliegendeur';
  }

  bool isOndersteundeOffertePositie(OpmetingOverzichtRaamItem positie) {
    if (positie.isVerwijderd) return false;

    return isVliegendeurPositie(positie) ||
        isSchuifvliegendeurPositie(positie) ||
        OfferteArtikelPrijsKoppelingService.isOndersteundArtikel(positie);
  }

  List<OpmetingOverzichtRaamItem> get hoofdoffertePosities {
    return List<OpmetingOverzichtRaamItem>.unmodifiable(
      posities.where((positie) {
        return isOndersteundeOffertePositie(positie) &&
            positie.teltMeeInHoofdofferte;
      }),
    );
  }

  /// Alle gewone artikelen en opties waarvoor `positieBehouden` werd gekozen,
  /// in exact dezelfde volgorde als op het overzichtsformulier.
  List<OpmetingOverzichtRaamItem> get offertePositiesVoorWeergave {
    return List<OpmetingOverzichtRaamItem>.unmodifiable(
      posities.where((positie) {
        if (!isOndersteundeOffertePositie(positie)) return false;

        return positie.teltMeeInHoofdofferte || positie.isOfferteOptieOpPositie;
      }),
    );
  }

  List<OpmetingOverzichtRaamItem> get offerteOptiePosities {
    return List<OpmetingOverzichtRaamItem>.unmodifiable(
      posities.where((positie) {
        return isOndersteundeOffertePositie(positie) &&
            positie.isZichtbareOfferteOptie;
      }),
    );
  }

  /// Afzonderlijke selectie voor de bestaande inzethor-specifieke PDF-logica.
  /// Alle andere ondersteunde types lopen via de algemene artikelkoppeling.
  List<OpmetingOverzichtRaamItem> get vasteInzethorPosities {
    return List<OpmetingOverzichtRaamItem>.unmodifiable(
      hoofdoffertePosities.where(
        (positie) => positie.vasteInzethorData != null,
      ),
    );
  }

  List<OpmetingOverzichtRaamItem> get vasteInzethorPositiesVoorWeergave {
    return List<OpmetingOverzichtRaamItem>.unmodifiable(
      offertePositiesVoorWeergave.where(
        (positie) => positie.vasteInzethorData != null,
      ),
    );
  }

  List<OpmetingOverzichtRaamItem> get vasteInzethorOptiePosities {
    return List<OpmetingOverzichtRaamItem>.unmodifiable(
      offerteOptiePosities.where(
        (positie) => positie.vasteInzethorData != null,
      ),
    );
  }

  /// Afzonderlijke selectie voor Vliegendeur-posities. Deze posities zijn
  /// zichtbaar in de offerte, maar blijven bewust buiten de prijsinstellingen.
  List<OpmetingOverzichtRaamItem> get vliegendeurPosities {
    return List<OpmetingOverzichtRaamItem>.unmodifiable(
      hoofdoffertePosities.where(isVliegendeurPositie),
    );
  }

  List<OpmetingOverzichtRaamItem> get vliegendeurPositiesVoorWeergave {
    return List<OpmetingOverzichtRaamItem>.unmodifiable(
      posities.where((positie) {
        if (positie.isVerwijderd || !isVliegendeurPositie(positie)) {
          return false;
        }
        return positie.teltMeeInHoofdofferte || positie.isOfferteOptieOpPositie;
      }),
    );
  }

  List<OpmetingOverzichtRaamItem> get vliegendeurOptiePosities {
    return List<OpmetingOverzichtRaamItem>.unmodifiable(
      offerteOptiePosities.where(isVliegendeurPositie),
    );
  }

  /// Afzonderlijke selectie voor Schuifvliegendeur-posities. Zo blijven deze
  /// posities ook zichtbaar wanneer een toekomstige prijsfilter wijzigt.
  List<OpmetingOverzichtRaamItem> get schuifvliegendeurPosities {
    return List<OpmetingOverzichtRaamItem>.unmodifiable(
      hoofdoffertePosities.where(isSchuifvliegendeurPositie),
    );
  }

  List<OpmetingOverzichtRaamItem> get schuifvliegendeurPositiesVoorWeergave {
    return List<OpmetingOverzichtRaamItem>.unmodifiable(
      posities.where((positie) {
        if (positie.isVerwijderd || !isSchuifvliegendeurPositie(positie)) {
          return false;
        }

        return positie.teltMeeInHoofdofferte || positie.isOfferteOptieOpPositie;
      }),
    );
  }

  List<OpmetingOverzichtRaamItem> get schuifvliegendeurOptiePosities {
    return List<OpmetingOverzichtRaamItem>.unmodifiable(
      offerteOptiePosities.where(isSchuifvliegendeurPositie),
    );
  }

  bool get heeftProjectKleuren {
    return projectKleurBinnen.trim().isNotEmpty ||
        projectKleurBuiten.trim().isNotEmpty ||
        ralKleurToebehoren.trim().isNotEmpty ||
        kleurAfwijking.trim().isNotEmpty;
  }

  int hoofdofferteArtikelNummer(OpmetingOverzichtRaamItem positie) {
    final index = hoofdoffertePosities.indexWhere(
      (item) => item.id == positie.id,
    );
    return index < 0 ? 1 : index + 1;
  }

  int positieNummer(OpmetingOverzichtRaamItem positie) {
    return hoofdofferteArtikelNummer(positie);
  }

  String optieLetter(OpmetingOverzichtRaamItem positie) {
    final index = offerteOptiePosities.indexWhere(
      (item) => item.id == positie.id,
    );
    return _letterVoorNummer(index < 0 ? 1 : index + 1);
  }

  OpmetingOverzichtRaamItem? hoofdpositieVoorOptie(
    OpmetingOverzichtRaamItem optie,
  ) {
    final gekoppeldId = optie.offerteOptieHoofdpositieId.trim();
    if (gekoppeldId.isNotEmpty) {
      for (final positie in hoofdoffertePosities) {
        if (positie.id == gekoppeldId) return positie;
      }
    }

    final optieIndex = posities.indexWhere((item) => item.id == optie.id);
    if (optieIndex < 0) return null;

    bool isGeldigHoofdartikel(OpmetingOverzichtRaamItem kandidaat) {
      return kandidaat.teltMeeInHoofdofferte &&
          isOndersteundeOffertePositie(kandidaat) &&
          kandidaat.formulierTypeGenormaliseerd ==
              optie.formulierTypeGenormaliseerd;
    }

    for (var index = optieIndex - 1; index >= 0; index--) {
      final kandidaat = posities[index];
      if (isGeldigHoofdartikel(kandidaat)) return kandidaat;
    }

    for (var index = optieIndex + 1; index < posities.length; index++) {
      final kandidaat = posities[index];
      if (isGeldigHoofdartikel(kandidaat)) return kandidaat;
    }

    return null;
  }

  List<OpmetingOverzichtRaamItem> optiesOpPositieVoor(
    OpmetingOverzichtRaamItem hoofdpositie,
  ) {
    return List<OpmetingOverzichtRaamItem>.unmodifiable(
      offerteOptiePosities.where((optie) {
        return optie.isOfferteOptieOpPositie &&
            hoofdpositieVoorOptie(optie)?.id == hoofdpositie.id;
      }),
    );
  }

  List<OpmetingOverzichtRaamItem> optiesOpApartePaginaVoor(
    OpmetingOverzichtRaamItem hoofdpositie,
  ) {
    return List<OpmetingOverzichtRaamItem>.unmodifiable(
      offerteOptiePosities.where((optie) {
        return optie.isOfferteOptieOpApartePagina &&
            hoofdpositieVoorOptie(optie)?.id == hoofdpositie.id;
      }),
    );
  }

  List<OpmetingOverzichtRaamItem> get ongekoppeldeOptiePosities {
    return List<OpmetingOverzichtRaamItem>.unmodifiable(
      offerteOptiePosities.where(
        (optie) => hoofdpositieVoorOptie(optie) == null,
      ),
    );
  }

  OfferteBerekeningResultaat? prijsResultaatVoorPositie(
    OpmetingOverzichtRaamItem positie, {
    bool kortingToestaan = true,
  }) {
    return OfferteArtikelPrijsKoppelingService.resultaatVoorArtikel(
      positie,
      kortingToestaan: kortingToestaan && !positie.isOfferteOptie,
    );
  }

  List<OffertePrijsOptieRegel> positiePrijsOptiesVoor(
    OpmetingOverzichtRaamItem positie,
  ) {
    if (positie.isOfferteOptie) {
      return const <OffertePrijsOptieRegel>[];
    }

    final resultaat = prijsResultaatVoorPositie(positie);
    if (resultaat == null) {
      return const <OffertePrijsOptieRegel>[];
    }

    return List<OffertePrijsOptieRegel>.unmodifiable(
      resultaat.optiePrijsregelsVoorOfferte
          .where((regel) => !_isAlgemeneArtikelPrijsregel(regel))
          .map(
            (regel) => OffertePrijsOptieRegel(
              omschrijving:
                  OffertePrijsregelWeergaveService.omschrijvingVoorOfferte(
                    regel,
                  ),
              bedragExclBtw: regel.totaalExclBtw,
            ),
          ),
    );
  }

  bool heeftPositiePrijsOpties(OpmetingOverzichtRaamItem positie) {
    return positiePrijsOptiesVoor(positie).isNotEmpty;
  }

  List<OfferteSamengevoegdeArtikelPrijsregel>
  get samengevoegdeAlgemeneArtikelPrijsregels {
    final verzameld = <String, _AlgemeneArtikelPrijsregelAccumulator>{};

    for (final positie in hoofdoffertePosities) {
      final resultaat = prijsResultaatVoorPositie(positie);
      if (resultaat == null) continue;

      for (final regel in resultaat.allePrijsregels) {
        if (!_isAlgemeneArtikelPrijsregel(regel) || !regel.isGeldig) continue;

        final sleutel = _algemeneArtikelPrijsregelSleutel(positie, regel);
        final bestaand = verzameld[sleutel];
        if (bestaand == null) {
          verzameld[sleutel] = _AlgemeneArtikelPrijsregelAccumulator(
            sleutel: sleutel,
            omschrijving:
                OffertePrijsregelWeergaveService.omschrijvingVoorOfferte(regel),
            totaalExclBtw: regel.totaalExclBtw,
            toonAfzonderlijkePrijs: regel.toonAfzonderlijkePrijsOpOfferte,
            toonOmschrijvingZonderPrijs:
                regel.toonOmschrijvingZonderPrijsOpOfferte,
            toonAlsOptie: regel.toonAlsOptieOpOfferte,
          );
        } else {
          bestaand.totaalExclBtw += regel.totaalExclBtw;
        }
      }
    }

    return List<OfferteSamengevoegdeArtikelPrijsregel>.unmodifiable(
      verzameld.values
          .map((item) => item.bouw())
          .where((regel) => regel.isZichtbaar),
    );
  }

  List<OfferteSamengevoegdeArtikelPrijsregel>
  get algemeneArtikelPrijsregelsInbegrepenInOfferte {
    return List<OfferteSamengevoegdeArtikelPrijsregel>.unmodifiable(
      samengevoegdeAlgemeneArtikelPrijsregels.where(
        (regel) =>
            !regel.toonAlsOptie &&
            (regel.toonAfzonderlijkePrijs || regel.toonOmschrijvingZonderPrijs),
      ),
    );
  }

  List<OfferteSamengevoegdeArtikelPrijsregel> get algemeneArtikelPrijsopties {
    return List<OfferteSamengevoegdeArtikelPrijsregel>.unmodifiable(
      samengevoegdeAlgemeneArtikelPrijsregels.where(
        (regel) => regel.toonAlsOptie,
      ),
    );
  }

  bool get heeftAlgemeneArtikelPrijsregelsInbegrepenInOfferte =>
      algemeneArtikelPrijsregelsInbegrepenInOfferte.isNotEmpty;

  bool get btwIsVerlegd => btwTarief.trim().toLowerCase() == 'btw verlegd';

  double get btwPercentage {
    if (btwIsVerlegd) return 0;
    if (btwTarief.replaceAll(' ', '') == '6%') return 0.06;
    return 0.21;
  }

  String get btwRegelLabel =>
      btwIsVerlegd ? 'BTW verlegd' : 'BTW ${btwTarief.trim()}';

  double get artikelTotaalVoorKortingExclBtw {
    return _som(
      hoofdoffertePosities.map((positie) {
        final resultaat = prijsResultaatVoorPositie(positie);
        if (resultaat == null) return 0.0;
        return resultaat.offerteTotaalExclBtw + resultaat.kortingBedragExclBtw;
      }),
    );
  }

  double get kortingTotaalExclBtw {
    return _som(
      hoofdoffertePosities.map((positie) {
        return prijsResultaatVoorPositie(positie)?.kortingBedragExclBtw ?? 0.0;
      }),
    );
  }

  double get totaalVoorKortingExclBtw {
    return _rondBedragAf(artikelTotaalVoorKortingExclBtw);
  }

  double get totaalExclusiefBtw {
    return _rondBedragAf(totaalVoorKortingExclBtw - kortingTotaalExclBtw);
  }

  double get btwBedrag => _rondBedragAf(totaalExclusiefBtw * btwPercentage);

  double get totaalInclusiefBtw =>
      _rondBedragAf(totaalExclusiefBtw + btwBedrag);

  List<OffertePrijsOptieRegel> get lossePrijsOpties {
    return List<OffertePrijsOptieRegel>.unmodifiable(
      algemeneArtikelPrijsopties.map(
        (regel) => OffertePrijsOptieRegel(
          omschrijving: regel.omschrijving,
          bedragExclBtw: regel.totaalExclBtw,
        ),
      ),
    );
  }

  bool get heeftLossePrijsOpties => lossePrijsOpties.isNotEmpty;

  double optiePositieTotaalExclBtw(OpmetingOverzichtRaamItem positie) {
    return prijsResultaatVoorPositie(
          positie,
          kortingToestaan: false,
        )?.offerteTotaalExclBtw ??
        0.0;
  }

  double optiePositieBtwBedrag(OpmetingOverzichtRaamItem positie) {
    return _rondBedragAf(optiePositieTotaalExclBtw(positie) * btwPercentage);
  }

  double optiePositieTotaalInclBtw(OpmetingOverzichtRaamItem positie) {
    return _rondBedragAf(
      optiePositieTotaalExclBtw(positie) + optiePositieBtwBedrag(positie),
    );
  }

  static String _letterVoorNummer(int nummer) {
    var resterend = nummer < 1 ? 1 : nummer;
    final tekens = <int>[];

    while (resterend > 0) {
      resterend--;
      tekens.add(65 + (resterend % 26));
      resterend ~/= 26;
    }

    return String.fromCharCodes(tekens.reversed);
  }

  static double _som(Iterable<double> waarden) {
    return _rondBedragAf(
      waarden.fold<double>(0, (som, waarde) => som + waarde),
    );
  }

  static double _rondBedragAf(double waarde) {
    if (!waarde.isFinite || waarde <= 0.0) return 0.0;
    return (waarde * 100.0).roundToDouble() / 100.0;
  }
}

class _AlgemeneArtikelPrijsregelAccumulator {
  _AlgemeneArtikelPrijsregelAccumulator({
    required this.sleutel,
    required this.omschrijving,
    required this.totaalExclBtw,
    required this.toonAfzonderlijkePrijs,
    required this.toonOmschrijvingZonderPrijs,
    required this.toonAlsOptie,
  });

  final String sleutel;
  final String omschrijving;
  double totaalExclBtw;
  final bool toonAfzonderlijkePrijs;
  final bool toonOmschrijvingZonderPrijs;
  final bool toonAlsOptie;

  OfferteSamengevoegdeArtikelPrijsregel bouw() {
    return OfferteSamengevoegdeArtikelPrijsregel(
      sleutel: sleutel,
      omschrijving: omschrijving,
      totaalExclBtw: _rondPdfBedragAf(totaalExclBtw),
      toonAfzonderlijkePrijs: toonAfzonderlijkePrijs,
      toonOmschrijvingZonderPrijs: toonOmschrijvingZonderPrijs,
      toonAlsOptie: toonAlsOptie,
    );
  }
}

bool _isAlgemeneArtikelPrijsregel(OfferteToegepastePrijsregelModel regel) {
  return regel.bronPrijsregelId.trim().startsWith('toegepast_project_');
}

String _algemeneArtikelPrijsregelSleutel(
  OpmetingOverzichtRaamItem positie,
  OfferteToegepastePrijsregelModel regel,
) {
  final bronId = regel.bronPrijsregelId.trim();
  final formulierSleutel = positie.formulierTypeGenormaliseerd
      .trim()
      .toLowerCase()
      .replaceAll('_', '')
      .replaceAll(' ', '');
  final prefix = 'toegepast_project_${formulierSleutel}_';
  if (formulierSleutel.isNotEmpty && bronId.startsWith(prefix)) {
    final oorspronkelijkId = bronId.substring(prefix.length).trim();
    if (oorspronkelijkId.isNotEmpty) return oorspronkelijkId;
  }
  return bronId;
}

double _rondPdfBedragAf(double waarde) {
  if (!waarde.isFinite) return 0.0;
  return (waarde * 100).roundToDouble() / 100;
}
