// THIMACO-CONTROLE: SCHUIFVLIEGENDEUR-PROFIEL-CATALOGUS-FASE-1-20260728

enum OpmetingSchuifvliegendeurProfielType { bovenrail, onderrail }

enum OpmetingSchuifvliegendeurProfielSchets {
  bovenrailCompact,
  bovenrailHoog,
  bovenrailVlak,
  bovenrailHaaks,
  onderrailZ,
  onderrailVlak,
  onderrailU,
  onderrailHaaks,
}

class OpmetingSchuifvliegendeurProfiel {
  const OpmetingSchuifvliegendeurProfiel({
    required this.code,
    required this.type,
    required this.schets,
    this.omschrijving = '',
  });

  final String code;
  final OpmetingSchuifvliegendeurProfielType type;
  final OpmetingSchuifvliegendeurProfielSchets schets;
  final String omschrijving;

  bool get isBovenrail {
    return type == OpmetingSchuifvliegendeurProfielType.bovenrail;
  }

  bool get isOnderrail {
    return type == OpmetingSchuifvliegendeurProfielType.onderrail;
  }
}

class OpmetingSchuifvliegendeurProfielCatalogus {
  const OpmetingSchuifvliegendeurProfielCatalogus._();

  static const String standaardBovenrailCode = 'VP1011';
  static const String standaardOnderrailCode = 'VP1012';

  static const List<OpmetingSchuifvliegendeurProfiel> bovenrails =
      <OpmetingSchuifvliegendeurProfiel>[
        OpmetingSchuifvliegendeurProfiel(
          code: 'VP1011',
          type: OpmetingSchuifvliegendeurProfielType.bovenrail,
          schets: OpmetingSchuifvliegendeurProfielSchets.bovenrailCompact,
          omschrijving: 'Standaard bovenrail',
        ),
        OpmetingSchuifvliegendeurProfiel(
          code: 'VP4961',
          type: OpmetingSchuifvliegendeurProfielType.bovenrail,
          schets: OpmetingSchuifvliegendeurProfielSchets.bovenrailHoog,
          omschrijving: 'Hoge bovenrail',
        ),
        OpmetingSchuifvliegendeurProfiel(
          code: 'VP5087',
          type: OpmetingSchuifvliegendeurProfielType.bovenrail,
          schets: OpmetingSchuifvliegendeurProfielSchets.bovenrailVlak,
          omschrijving: 'Vlakke bovenrail',
        ),
        OpmetingSchuifvliegendeurProfiel(
          code: 'VP5088',
          type: OpmetingSchuifvliegendeurProfielType.bovenrail,
          schets: OpmetingSchuifvliegendeurProfielSchets.bovenrailHaaks,
          omschrijving: 'Haakse bovenrail',
        ),
      ];

  static const List<OpmetingSchuifvliegendeurProfiel> onderrails =
      <OpmetingSchuifvliegendeurProfiel>[
        OpmetingSchuifvliegendeurProfiel(
          code: 'VP1012',
          type: OpmetingSchuifvliegendeurProfielType.onderrail,
          schets: OpmetingSchuifvliegendeurProfielSchets.onderrailZ,
          omschrijving: 'Standaard Z-onderrail',
        ),
        OpmetingSchuifvliegendeurProfiel(
          code: 'VP1016',
          type: OpmetingSchuifvliegendeurProfielType.onderrail,
          schets: OpmetingSchuifvliegendeurProfielSchets.onderrailVlak,
          omschrijving: 'Vlakke onderrail',
        ),
        OpmetingSchuifvliegendeurProfiel(
          code: 'VP1059/VP1060',
          type: OpmetingSchuifvliegendeurProfielType.onderrail,
          schets: OpmetingSchuifvliegendeurProfielSchets.onderrailU,
          omschrijving: 'U-profiel onderrail',
        ),
        OpmetingSchuifvliegendeurProfiel(
          code: 'VP1054',
          type: OpmetingSchuifvliegendeurProfielType.onderrail,
          schets: OpmetingSchuifvliegendeurProfielSchets.onderrailHaaks,
          omschrijving: 'Haakse onderrail',
        ),
        OpmetingSchuifvliegendeurProfiel(
          code: 'VR073',
          type: OpmetingSchuifvliegendeurProfielType.onderrail,
          schets: OpmetingSchuifvliegendeurProfielSchets.onderrailZ,
          omschrijving: 'Z-profiel onderrail',
        ),
        OpmetingSchuifvliegendeurProfiel(
          code: 'VR074',
          type: OpmetingSchuifvliegendeurProfielType.onderrail,
          schets: OpmetingSchuifvliegendeurProfielSchets.onderrailHaaks,
          omschrijving: 'Haaks Z-profiel onderrail',
        ),
      ];

  static List<String> get bovenrailCodes {
    return bovenrails.map((profiel) => profiel.code).toList(growable: false);
  }

  static List<String> get onderrailCodes {
    return onderrails.map((profiel) => profiel.code).toList(growable: false);
  }

  static OpmetingSchuifvliegendeurProfiel? zoek(String code) {
    final genormaliseerd = code.trim().toUpperCase();

    for (final profiel in <OpmetingSchuifvliegendeurProfiel>[
      ...bovenrails,
      ...onderrails,
    ]) {
      if (profiel.code.toUpperCase() == genormaliseerd) {
        return profiel;
      }
    }

    return null;
  }

  static bool isGeldigeBovenrail(String code) {
    return bovenrails.any((profiel) => profiel.code == code.trim());
  }

  static bool isGeldigeOnderrail(String code) {
    return onderrails.any((profiel) => profiel.code == code.trim());
  }
}
