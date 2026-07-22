enum OffertePrijsUitschrijfmodus {
  overzichtEnOfferteMetPrijs(
    jsonWaarde: 'overzichtEnOfferteMetPrijs',
    benaming: 'Omschrijving + prijs op offerte',
  ),
  alleenOverzicht(
    jsonWaarde: 'alleenOverzicht',
    benaming: 'Alleen op intern overzicht',
  ),
  invullenEnOfferteMetPrijs(
    jsonWaarde: 'invullenEnOfferteMetPrijs',
    benaming: 'Omschrijving + prijs op offerte',
  ),
  invullenEnOfferteZonderPrijs(
    jsonWaarde: 'invullenEnOfferteZonderPrijs',
    benaming: 'Alleen omschrijving op offerte',
  ),
  verdelenOverArtikelenAlleenOverzicht(
    jsonWaarde: 'verdelenOverArtikelenAlleenOverzicht',
    benaming: 'Verdelen over artikelen — verborgen',
  ),
  optie(jsonWaarde: 'optie', benaming: 'Optie — niet meetellen');

  const OffertePrijsUitschrijfmodus({
    required this.jsonWaarde,
    required this.benaming,
  });

  final String jsonWaarde;
  final String benaming;

  bool get isVerdeeldeInterneKost {
    return this ==
        OffertePrijsUitschrijfmodus.verdelenOverArtikelenAlleenOverzicht;
  }

  bool get isOptie {
    return this == OffertePrijsUitschrijfmodus.optie;
  }

  /// Bepaalt uitsluitend of de omschrijving afzonderlijk op de
  /// klantofferte zichtbaar is.
  bool get toonOmschrijvingOpOfferte {
    return switch (this) {
      OffertePrijsUitschrijfmodus.overzichtEnOfferteMetPrijs => true,
      OffertePrijsUitschrijfmodus.invullenEnOfferteMetPrijs => true,
      OffertePrijsUitschrijfmodus.invullenEnOfferteZonderPrijs => true,
      OffertePrijsUitschrijfmodus.optie => true,
      OffertePrijsUitschrijfmodus.alleenOverzicht => false,
      OffertePrijsUitschrijfmodus.verdelenOverArtikelenAlleenOverzicht => false,
    };
  }

  /// Bepaalt uitsluitend of de prijs afzonderlijk naast de omschrijving
  /// op de klantofferte zichtbaar is.
  bool get toonPrijsOpOfferte {
    return switch (this) {
      OffertePrijsUitschrijfmodus.overzichtEnOfferteMetPrijs => true,
      OffertePrijsUitschrijfmodus.invullenEnOfferteMetPrijs => true,
      OffertePrijsUitschrijfmodus.optie => true,
      OffertePrijsUitschrijfmodus.invullenEnOfferteZonderPrijs => false,
      OffertePrijsUitschrijfmodus.alleenOverzicht => false,
      OffertePrijsUitschrijfmodus.verdelenOverArtikelenAlleenOverzicht => false,
    };
  }

  /// Zichtbaarheid en berekening zijn twee aparte zaken.
  /// Alleen een expliciete optie wordt niet meegerekend.
  bool get teltMeeInEindtotaal {
    return !isOptie;
  }

  String get overzichtUitleg {
    if (isOptie) {
      return 'Omschrijving en prijs zichtbaar als optie';
    }

    return 'Omschrijving en prijs zichtbaar';
  }

  String get offerteUitleg {
    return switch (this) {
      OffertePrijsUitschrijfmodus.overzichtEnOfferteMetPrijs =>
        'Omschrijving en prijs zichtbaar',
      OffertePrijsUitschrijfmodus.invullenEnOfferteMetPrijs =>
        'Omschrijving en prijs zichtbaar',
      OffertePrijsUitschrijfmodus.invullenEnOfferteZonderPrijs =>
        'Alleen omschrijving zichtbaar',
      OffertePrijsUitschrijfmodus.alleenOverzicht => 'Niet zichtbaar',
      OffertePrijsUitschrijfmodus.verdelenOverArtikelenAlleenOverzicht =>
        'Niet zichtbaar',
      OffertePrijsUitschrijfmodus.optie =>
        'Zichtbaar als optie met afzonderlijke prijs',
    };
  }

  String get totaalUitleg {
    return teltMeeInEindtotaal ? 'Wel meegerekend' : 'Niet meegerekend';
  }

  static OffertePrijsUitschrijfmodus fromJson(
    Object? waarde, {
    OffertePrijsUitschrijfmodus standaardWaarde =
        OffertePrijsUitschrijfmodus.overzichtEnOfferteMetPrijs,
  }) {
    final tekst = waarde?.toString().trim();

    for (final modus in OffertePrijsUitschrijfmodus.values) {
      if (modus.jsonWaarde == tekst || modus.name == tekst) {
        return modus;
      }
    }

    return standaardWaarde;
  }
}
