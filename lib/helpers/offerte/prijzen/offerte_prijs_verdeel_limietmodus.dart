enum OffertePrijsVerdeelLimietmodus {
  zonderLimiet(
    jsonWaarde: 'zonderLimiet',
    benaming: 'Zonder aankooplimiet',
    uitleg: 'De verdeelkost wordt altijd toegepast.',
  ),
  metAankooplimiet(
    jsonWaarde: 'metAankooplimiet',
    benaming: 'Met aankooplimiet',
    uitleg:
        'De verdeelkost wordt alleen toegepast zolang het aankoopbedrag lager is dan de ingestelde limiet.',
  );

  const OffertePrijsVerdeelLimietmodus({
    required this.jsonWaarde,
    required this.benaming,
    required this.uitleg,
  });

  final String jsonWaarde;
  final String benaming;
  final String uitleg;

  static OffertePrijsVerdeelLimietmodus fromJson(
    Object? waarde, {
    OffertePrijsVerdeelLimietmodus standaardWaarde =
        OffertePrijsVerdeelLimietmodus.zonderLimiet,
  }) {
    final tekst = waarde?.toString().trim();

    for (final modus in OffertePrijsVerdeelLimietmodus.values) {
      if (modus.jsonWaarde == tekst || modus.name == tekst) {
        return modus;
      }
    }

    return standaardWaarde;
  }
}
