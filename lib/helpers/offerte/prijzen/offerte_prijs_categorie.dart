// THIMACO-CONTROLE: PRIJSARCHITECTUUR-STAP5D4B4A-LEGACY-CATEGORIEEN-UIT-ENUM-20260814
// THIMACO-CONTROLE: PRIJSARCHITECTUUR-OPRUIMEN-STAP5D4A-PRIJS-PER-POSITIE-CATEGORIE-20260814
enum OffertePrijsCategorie {
  technischeKeuzePerArtikel(
    jsonWaarde: 'technischeKeuzePerArtikel',
    benaming: 'Prijs volgens technische keuze',
  ),
  prijsPerPositie(jsonWaarde: 'prijsPerPositie', benaming: 'Prijs per positie');

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

    // Oude vrije/projectcategorieën mogen na de opschoning nooit terugvallen
    // op technischeKeuzePerArtikel. Ze worden alleen als niet-technische
    // legacywaarde ingelezen en krijgen daardoor geen technische werking.
    if (tekst == 'vrijPerArtikel' || tekst == 'alleArtikelen') {
      return OffertePrijsCategorie.prijsPerPositie;
    }

    for (final categorie in OffertePrijsCategorie.values) {
      if (categorie.jsonWaarde == tekst || categorie.name == tekst) {
        return categorie;
      }
    }

    return standaardWaarde;
  }
}
