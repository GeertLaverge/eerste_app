// THIMACO-CONTROLE: PRIJSREGEL-WEERGAVE-UITSCHRIJFMODUS-20260721
import 'offerte_prijs_categorie.dart';
import 'offerte_prijs_uitschrijfmodus.dart';
import 'offerte_toegepaste_prijsregel_model.dart';

/// Centrale, uitsluitend visuele interpretatie van een toegepaste prijsregel.
///
/// De opgeslagen prijsregel, enumwaarden en JSON blijven ongewijzigd.
/// Bij technische prijsregels is uitsluitend de tekst uit `Hoe uitschrijven`
/// bepalend voor wat op het overzicht en de klantofferte wordt getoond.
class OffertePrijsregelWeergaveService {
  const OffertePrijsregelWeergaveService._();

  static bool isTechnischePrijsregel(
    OfferteToegepastePrijsregelModel prijsregel,
  ) {
    return prijsregel.categorie ==
        OffertePrijsCategorie.technischeKeuzePerArtikel;
  }

  static String technischeUitschrijftekst(
    OfferteToegepastePrijsregelModel prijsregel,
  ) {
    if (!isTechnischePrijsregel(prijsregel)) {
      return '';
    }

    return prijsregel.technischeKeuze?.hoeUitschrijven.trim() ?? '';
  }

  static String omschrijvingVoorOfferte(
    OfferteToegepastePrijsregelModel prijsregel,
  ) {
    final technischeTekst = technischeUitschrijftekst(prijsregel);
    if (technischeTekst.isNotEmpty) {
      return technischeTekst;
    }

    return prijsregel.omschrijving.trim();
  }

  static bool technischeOmschrijvingMagOpOfferte(
    OfferteToegepastePrijsregelModel prijsregel,
  ) {
    return !isTechnischePrijsregel(prijsregel) ||
        prijsregel.uitschrijfmodus.toonOmschrijvingOpOfferte;
  }

  /// Bepaalt of een bestaande technische overzichtsregel bij de gekoppelde
  /// technische prijsregel hoort. De alternatieve menu- en keuzeteksten worden
  /// uitsluitend gebruikt om de regel intern terug te vinden; ze worden nooit
  /// als zichtbare offerte- of overzichtstekst teruggegeven.
  static bool technischeRegelPastBijPrijsregel({
    required OfferteToegepastePrijsregelModel prijsregel,
    required String titel,
    required String waarde,
  }) {
    if (!isTechnischePrijsregel(prijsregel)) {
      return false;
    }

    final keuze = prijsregel.technischeKeuze;
    if (keuze == null || keuze.isLeeg) {
      return false;
    }

    final titelSleutel = _normaliseer(titel);
    final waardeSleutel = _normaliseer(waarde);
    final volledigeSleutel = _normaliseer('$titel $waarde');
    if (volledigeSleutel.isEmpty) {
      return false;
    }

    final hoeUitschrijven = _normaliseer(keuze.hoeUitschrijven);
    if (_tekstenPassen(
      regelTitel: titelSleutel,
      regelWaarde: waardeSleutel,
      volledigeRegel: volledigeSleutel,
      kandidaat: hoeUitschrijven,
    )) {
      return true;
    }

    final menu = _normaliseer(keuze.menuTitelMomentopname);
    final submenu = _normaliseer(keuze.submenuTitelMomentopname);
    final keuzeTitel = _normaliseer(keuze.keuzeTitelMomentopname);

    final keuzePast = _tekstenPassen(
      regelTitel: titelSleutel,
      regelWaarde: waardeSleutel,
      volledigeRegel: volledigeSleutel,
      kandidaat: keuzeTitel,
    );
    if (!keuzePast) {
      return false;
    }

    if (menu.isEmpty && submenu.isEmpty) {
      return true;
    }

    final menuPast =
        menu.isEmpty ||
        titelSleutel.contains(menu) ||
        volledigeSleutel.contains(menu);
    final submenuPast = submenu.isEmpty || volledigeSleutel.contains(submenu);

    return menuPast && submenuPast;
  }

  static String benamingVoorUitschrijfmodus(OffertePrijsUitschrijfmodus modus) {
    return switch (modus) {
      OffertePrijsUitschrijfmodus.overzichtEnOfferteMetPrijs =>
        'Uitschrijven en prijs tonen',
      OffertePrijsUitschrijfmodus.invullenEnOfferteMetPrijs =>
        'Uitschrijven en prijs tonen',
      OffertePrijsUitschrijfmodus.invullenEnOfferteZonderPrijs =>
        'Enkel uitschrijven',
      OffertePrijsUitschrijfmodus.alleenOverzicht =>
        'Enkel op overzicht — niet op offerte',
      OffertePrijsUitschrijfmodus.verdelenOverArtikelenAlleenOverzicht =>
        'Verdelen over artikelen — niet op offerte',
      OffertePrijsUitschrijfmodus.optie => 'Als optie tonen — niet meetellen',
    };
  }

  static String normaliseerTechnischeTekst(String waarde) {
    return _normaliseer(waarde);
  }

  static bool _tekstenPassen({
    required String regelTitel,
    required String regelWaarde,
    required String volledigeRegel,
    required String kandidaat,
  }) {
    if (kandidaat.isEmpty) {
      return false;
    }

    if (kandidaat == regelTitel ||
        kandidaat == regelWaarde ||
        kandidaat == volledigeRegel) {
      return true;
    }

    if (kandidaat.length < 4 || volledigeRegel.length < 4) {
      return false;
    }

    return volledigeRegel.contains(kandidaat) ||
        kandidaat.contains(volledigeRegel);
  }

  static String _normaliseer(String waarde) {
    return waarde.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }
}
