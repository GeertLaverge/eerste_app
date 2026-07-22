enum OffertePrijsCategorie {
  technischeKeuzePerArtikel(
    jsonWaarde: 'technischeKeuzePerArtikel',
    benaming: 'Prijs volgens technische keuze',
  ),
  vrijPerArtikel(
    jsonWaarde: 'vrijPerArtikel',
    benaming: 'Vrije prijs per artikel',
  ),
  alleArtikelen(
    jsonWaarde: 'alleArtikelen',
    benaming: 'Prijs voor alle artikelen',
  );

  const OffertePrijsCategorie({
    required this.jsonWaarde,
    required this.benaming,
  });

  final String jsonWaarde;
  final String benaming;

  static OffertePrijsCategorie fromJson(
    Object? waarde, {
    OffertePrijsCategorie standaardWaarde =
        OffertePrijsCategorie.technischeKeuzePerArtikel,
  }) {
    final tekst = waarde?.toString().trim();

    for (final categorie in OffertePrijsCategorie.values) {
      if (categorie.jsonWaarde == tekst || categorie.name == tekst) {
        return categorie;
      }
    }

    return standaardWaarde;
  }
}
