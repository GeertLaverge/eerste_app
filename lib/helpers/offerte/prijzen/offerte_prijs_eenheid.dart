enum OffertePrijsEenheid {
  vast(jsonWaarde: 'vast', benaming: 'Vaste prijs', formuleBenaming: 'Vast'),
  eenBreedte(
    jsonWaarde: 'eenBreedte',
    benaming: '1 × breedte',
    formuleBenaming: '1B',
  ),
  tweeBreedtes(
    jsonWaarde: 'tweeBreedtes',
    benaming: '2 × breedte',
    formuleBenaming: '2B',
  ),
  eenHoogte(
    jsonWaarde: 'eenHoogte',
    benaming: '1 × hoogte',
    formuleBenaming: '1H',
  ),
  tweeHoogtes(
    jsonWaarde: 'tweeHoogtes',
    benaming: '2 × hoogte',
    formuleBenaming: '2H',
  ),
  eenBreedteTweeHoogtes(
    jsonWaarde: 'eenBreedteTweeHoogtes',
    benaming: '1 × breedte + 2 × hoogte',
    formuleBenaming: '1B + 2H',
  ),
  omtrek(jsonWaarde: 'omtrek', benaming: 'Omtrek', formuleBenaming: '2B + 2H'),
  oppervlakte(
    jsonWaarde: 'oppervlakte',
    benaming: 'Oppervlakte',
    formuleBenaming: 'B × H',
  );

  const OffertePrijsEenheid({
    required this.jsonWaarde,
    required this.benaming,
    required this.formuleBenaming,
  });

  final String jsonWaarde;
  final String benaming;
  final String formuleBenaming;

  static OffertePrijsEenheid fromJson(
    Object? waarde, {
    OffertePrijsEenheid standaardWaarde = OffertePrijsEenheid.vast,
  }) {
    final tekst = waarde?.toString().trim();

    for (final eenheid in OffertePrijsEenheid.values) {
      if (eenheid.jsonWaarde == tekst || eenheid.name == tekst) {
        return eenheid;
      }
    }

    return standaardWaarde;
  }
}
