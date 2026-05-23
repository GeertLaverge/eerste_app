class KlantArtikel {
  String artikelNaam;
  bool besteld;
  bool geleverd;

  KlantArtikel({
    required this.artikelNaam,
    this.besteld = false,
    this.geleverd = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'artikelNaam': artikelNaam,
      'besteld': besteld,
      'geleverd': geleverd,
    };
  }

  factory KlantArtikel.fromMap(Map<String, dynamic> map) {
    return KlantArtikel(
      artikelNaam: map['artikelNaam'] ?? '',
      besteld: map['besteld'] ?? false,
      geleverd: map['geleverd'] ?? false,
    );
  }
}

class KlantLeverancier {
  String leverancierNaam;
  List<KlantArtikel> gekozenArtikelen;

  KlantLeverancier({
    required this.leverancierNaam,
    required this.gekozenArtikelen,
  });

  Map<String, dynamic> toMap() {
    return {
      'leverancierNaam': leverancierNaam,
      'gekozenArtikelen': gekozenArtikelen.map((e) => e.toMap()).toList(),
    };
  }

  factory KlantLeverancier.fromMap(Map<String, dynamic> map) {
    return KlantLeverancier(
      leverancierNaam: map['leverancierNaam'] ?? '',
      gekozenArtikelen: (map['gekozenArtikelen'] as List<dynamic>? ?? [])
          .map((e) => KlantArtikel.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
