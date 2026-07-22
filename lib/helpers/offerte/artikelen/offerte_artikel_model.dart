enum OfferteArtikelOptiePlaatsing { geen, positieBehouden, apartePagina }

class OfferteArtikelModel {
  const OfferteArtikelModel({
    required this.id,
    required this.artikelType,
    required this.artikelNaam,
    required this.omschrijving,
    required this.aantal,
    required this.prijsPerStukExclBtw,
    required this.winstmargePercentage,
    required this.kortingPercentage,
    required this.isOptie,
    required this.optiePlaatsing,
    required this.optieHoofdpositieId,
    required this.oorspronkelijkeIndex,
  });

  final String id;
  final String artikelType;
  final String artikelNaam;
  final String omschrijving;
  final int aantal;
  final double prijsPerStukExclBtw;
  final double winstmargePercentage;
  final double kortingPercentage;
  final bool isOptie;
  final OfferteArtikelOptiePlaatsing optiePlaatsing;
  final String optieHoofdpositieId;
  final int oorspronkelijkeIndex;

  bool get teltMeeInHoofdofferte => !isOptie;

  bool get blijftOpOorspronkelijkePositie {
    return isOptie &&
        optiePlaatsing == OfferteArtikelOptiePlaatsing.positieBehouden;
  }

  bool get hoortOpAparteOptiePagina {
    return isOptie &&
        optiePlaatsing == OfferteArtikelOptiePlaatsing.apartePagina;
  }

  bool get heeftPrijsPerStuk => prijsPerStukExclBtw > 0;
  bool get heeftWinstmarge => winstmargePercentage > 0;

  String get zichtbareOmschrijving {
    final waarde = omschrijving.trim();
    return waarde.isEmpty ? artikelNaam : waarde;
  }
}
