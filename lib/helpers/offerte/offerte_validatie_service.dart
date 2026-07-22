import 'artikelen/offerte_artikel_model.dart';

class OfferteValidatieMelding {
  const OfferteValidatieMelding({
    required this.artikel,
    required this.positieLabel,
  });

  final OfferteArtikelModel artikel;
  final String positieLabel;
}

class OfferteValidatieResultaat {
  const OfferteValidatieResultaat({
    this.zonderPrijsPerStuk = const <OfferteValidatieMelding>[],
    this.zonderWinstmarge = const <OfferteValidatieMelding>[],
  });

  final List<OfferteValidatieMelding> zonderPrijsPerStuk;
  final List<OfferteValidatieMelding> zonderWinstmarge;

  bool get isGeldig {
    return zonderPrijsPerStuk.isEmpty && zonderWinstmarge.isEmpty;
  }
}

class OfferteValidatieService {
  const OfferteValidatieService();

  OfferteValidatieResultaat valideerPrijsgegevens({
    required Iterable<OfferteArtikelModel> artikelen,
    required Map<String, String> positieLabels,
  }) {
    final zonderPrijsPerStuk = <OfferteValidatieMelding>[];
    final zonderWinstmarge = <OfferteValidatieMelding>[];

    for (final artikel in artikelen) {
      final positieLabel = positieLabels[artikel.id] ?? artikel.artikelNaam;
      final melding = OfferteValidatieMelding(
        artikel: artikel,
        positieLabel: positieLabel,
      );

      if (!artikel.heeftPrijsPerStuk) {
        zonderPrijsPerStuk.add(melding);
      }
      if (!artikel.heeftWinstmarge) {
        zonderWinstmarge.add(melding);
      }
    }

    return OfferteValidatieResultaat(
      zonderPrijsPerStuk: List<OfferteValidatieMelding>.unmodifiable(
        zonderPrijsPerStuk,
      ),
      zonderWinstmarge: List<OfferteValidatieMelding>.unmodifiable(
        zonderWinstmarge,
      ),
    );
  }
}
