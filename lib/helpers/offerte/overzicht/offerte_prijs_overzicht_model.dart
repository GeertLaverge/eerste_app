/// Afgeleid weergavemodel voor het interne prijs- en margeoverzicht.
///
/// Dit model wordt niet opgeslagen en wijzigt geen bestaande prijsmodellen
/// of JSON-structuren.
class OffertePrijsOverzichtData {
  OffertePrijsOverzichtData({
    required this.klantNaam,
    required this.klantAdres,
    required this.offerteNummer,
    required this.opgemaaktOp,
    required List<OffertePrijsOverzichtArtikel> artikelen,
    required List<OffertePrijsOverzichtSamengevoegdeRegel> prijsregels,
  }) : artikelen = List<OffertePrijsOverzichtArtikel>.unmodifiable(artikelen),
       prijsregels = List<OffertePrijsOverzichtSamengevoegdeRegel>.unmodifiable(
         prijsregels,
       );

  final String klantNaam;
  final String klantAdres;
  final String offerteNummer;
  final DateTime opgemaaktOp;
  final List<OffertePrijsOverzichtArtikel> artikelen;
  final List<OffertePrijsOverzichtSamengevoegdeRegel> prijsregels;

  List<OffertePrijsOverzichtArtikel> get hoofdArtikelen {
    return List<OffertePrijsOverzichtArtikel>.unmodifiable(
      artikelen.where((artikel) => !artikel.isOptie),
    );
  }

  List<OffertePrijsOverzichtArtikel> get optieArtikelen {
    return List<OffertePrijsOverzichtArtikel>.unmodifiable(
      artikelen.where((artikel) => artikel.isOptie),
    );
  }

  List<OffertePrijsOverzichtSamengevoegdeRegel> get hoofdPrijsregels {
    return List<OffertePrijsOverzichtSamengevoegdeRegel>.unmodifiable(
      prijsregels.where((regel) => !regel.isOptie),
    );
  }

  List<OffertePrijsOverzichtSamengevoegdeRegel> get optiePrijsregels {
    return List<OffertePrijsOverzichtSamengevoegdeRegel>.unmodifiable(
      prijsregels.where((regel) => regel.isOptie),
    );
  }

  List<OffertePrijsOverzichtSamengevoegdeRegel> hoofdPrijsregelsVoorType(
    OffertePrijsOverzichtRegelType type,
  ) {
    return List<OffertePrijsOverzichtSamengevoegdeRegel>.unmodifiable(
      hoofdPrijsregels.where((regel) => regel.type == type),
    );
  }

  List<OffertePrijsOverzichtSamengevoegdeRegel> optiePrijsregelsVoorType(
    OffertePrijsOverzichtRegelType type,
  ) {
    return List<OffertePrijsOverzichtSamengevoegdeRegel>.unmodifiable(
      optiePrijsregels.where((regel) => regel.type == type),
    );
  }

  int get aantalPosities => hoofdArtikelen.length;

  int get aantalArtikelen {
    return hoofdArtikelen.fold<int>(0, (som, artikel) => som + artikel.aantal);
  }

  int get aantalOptieArtikelen {
    return optieArtikelen.fold<int>(0, (som, artikel) => som + artikel.aantal);
  }

  double get somBasisPrijsPerStukExclBtw {
    return _somArtikelen(
      hoofdArtikelen,
      (artikel) => artikel.basisPrijsPerStukExclBtw,
    );
  }

  double get somWinstmargePerStukExclBtw {
    return _somArtikelen(
      hoofdArtikelen,
      (artikel) => artikel.winstmargePerStukExclBtw,
    );
  }

  double get somKortingPerStukExclBtw {
    return _somArtikelen(
      hoofdArtikelen,
      (artikel) => artikel.kortingPerStukExclBtw,
    );
  }

  double get somTotaalPerStukExclBtw {
    return _somArtikelen(
      hoofdArtikelen,
      (artikel) => artikel.totaalPerStukExclBtw,
    );
  }

  double get basisTotaalExclBtw {
    return _somArtikelen(
      hoofdArtikelen,
      (artikel) => artikel.basisTotaalExclBtw,
    );
  }

  double get totaleWinstmargeExclBtw {
    return _somArtikelen(
      hoofdArtikelen,
      (artikel) => artikel.winstmargeTotaalExclBtw,
    );
  }

  double get totaleKortingExclBtw {
    return _somArtikelen(
      hoofdArtikelen,
      (artikel) => artikel.kortingTotaalExclBtw,
    );
  }

  double get artikelenTotaalExclBtw {
    return _somArtikelen(hoofdArtikelen, (artikel) => artikel.totaalExclBtw);
  }

  double get technischePrijsregelsTotaalExclBtw {
    return _somPrijsregels(
      hoofdPrijsregelsVoorType(OffertePrijsOverzichtRegelType.technisch),
    );
  }

  double get vrijePrijsregelsTotaalExclBtw {
    return _somPrijsregels(
      hoofdPrijsregelsVoorType(OffertePrijsOverzichtRegelType.vrij),
    );
  }

  double get alleArtikelenPrijsregelsTotaalExclBtw {
    return _somPrijsregels(
      hoofdPrijsregelsVoorType(OffertePrijsOverzichtRegelType.alleArtikelen),
    );
  }

  double get prijsregelsTotaalExclBtw {
    return _rondBedrag(
      technischePrijsregelsTotaalExclBtw +
          vrijePrijsregelsTotaalExclBtw +
          alleArtikelenPrijsregelsTotaalExclBtw,
    );
  }

  double get eindtotaalExclBtw {
    return _rondBedrag(
      basisTotaalExclBtw +
          technischePrijsregelsTotaalExclBtw +
          vrijePrijsregelsTotaalExclBtw +
          alleArtikelenPrijsregelsTotaalExclBtw +
          totaleWinstmargeExclBtw -
          totaleKortingExclBtw,
    );
  }

  static double _somArtikelen(
    Iterable<OffertePrijsOverzichtArtikel> bron,
    double Function(OffertePrijsOverzichtArtikel artikel) selecteer,
  ) {
    return _rondBedrag(
      bron.fold<double>(0.0, (som, artikel) => som + selecteer(artikel)),
    );
  }

  static double _somPrijsregels(
    Iterable<OffertePrijsOverzichtSamengevoegdeRegel> bron,
  ) {
    return _rondBedrag(
      bron.fold<double>(0.0, (som, regel) => som + regel.totaalExclBtw),
    );
  }
}

class OffertePrijsOverzichtArtikel {
  const OffertePrijsOverzichtArtikel({
    required this.id,
    required this.positieLabel,
    required this.artikelNaam,
    required this.omschrijving,
    required this.maatLabel,
    required this.formulierType,
    required this.aantal,
    required this.isOptie,
    required this.basisPrijsPerStukExclBtw,
    required this.basisTotaalExclBtw,
    required this.winstmargePercentage,
    required this.winstmargePerStukExclBtw,
    required this.winstmargeTotaalExclBtw,
    required this.kortingPercentage,
    required this.kortingPerStukExclBtw,
    required this.kortingTotaalExclBtw,
    required this.totaalPerStukExclBtw,
    required this.totaalExclBtw,
  });

  final String id;
  final String positieLabel;
  final String artikelNaam;
  final String omschrijving;
  final String maatLabel;
  final String formulierType;
  final int aantal;
  final bool isOptie;
  final double basisPrijsPerStukExclBtw;
  final double basisTotaalExclBtw;
  final double winstmargePercentage;
  final double winstmargePerStukExclBtw;
  final double winstmargeTotaalExclBtw;
  final double kortingPercentage;
  final double kortingPerStukExclBtw;
  final double kortingTotaalExclBtw;
  final double totaalPerStukExclBtw;
  final double totaalExclBtw;

  String get compacteOmschrijving {
    return <String>[
      if (omschrijving.trim().isNotEmpty) omschrijving.trim(),
      if (maatLabel.trim().isNotEmpty) maatLabel.trim(),
    ].join(' · ');
  }
}

enum OffertePrijsOverzichtRegelType {
  technisch('Technische prijsregels'),
  vrij('Vrije prijsregels'),
  alleArtikelen('Prijsregels voor alle artikelen');

  const OffertePrijsOverzichtRegelType(this.label);

  final String label;
}

class OffertePrijsOverzichtSamengevoegdeRegel {
  OffertePrijsOverzichtSamengevoegdeRegel({
    required this.type,
    required this.omschrijving,
    required List<String> toepassingLabels,
    required this.aantalToepassingen,
    required this.totaalExclBtw,
    required this.isOptie,
  }) : toepassingLabels = List<String>.unmodifiable(toepassingLabels);

  final OffertePrijsOverzichtRegelType type;
  final String omschrijving;
  final List<String> toepassingLabels;
  final int aantalToepassingen;
  final double totaalExclBtw;
  final bool isOptie;

  String get toepassingTekst {
    if (toepassingLabels.isEmpty) {
      return aantalToepassingen == 1
          ? '1 toepassing'
          : '$aantalToepassingen toepassingen';
    }

    final labels = toepassingLabels.join(', ');
    final aantalTekst = aantalToepassingen == 1
        ? '1 toepassing'
        : '$aantalToepassingen toepassingen';
    return '$aantalTekst · $labels';
  }
}

double _rondBedrag(double waarde) {
  if (!waarde.isFinite) return 0.0;
  return (waarde * 100.0).roundToDouble() / 100.0;
}
