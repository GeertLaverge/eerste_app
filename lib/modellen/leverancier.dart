class Leverancier {
  String naam;
  List<String> artikelen;

  Leverancier({
    required this.naam,
    required this.artikelen,
  });

  Map<String, dynamic> toMap() {
    return {
      'naam': naam,
      'artikelen': artikelen,
    };
  }

  factory Leverancier.fromMap(Map<String, dynamic> map) {
    return Leverancier(
      naam: map['naam'] ?? '',
      artikelen: List<String>.from(map['artikelen'] ?? []),
    );
  }
}
