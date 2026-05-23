import 'package:flutter/material.dart';

import '../modellen/klant.dart';

class StatusHelper {
  static bool heeftArtikelsInBestelling(Klant klant) {
    if (klant.geenArtikelsNodig) {
      return true;
    }

    for (final leverancier in klant.klantLeveranciers) {
      if (leverancier.gekozenArtikelen.isNotEmpty) {
        return true;
      }
    }

    return false;
  }

  static String bepaalStatus(Klant klant) {
    if (klant.geenArtikelsNodig) {
      return 'geen artikels nodig';
    }

    final alleArtikelen = klant.klantLeveranciers
        .expand((leverancier) => leverancier.gekozenArtikelen)
        .toList();

    if (alleArtikelen.isEmpty) {
      return 'Nog niet alles besteld';
    }

    final allesGeleverd =
        alleArtikelen.every((artikel) => artikel.geleverd == true);

    if (allesGeleverd) {
      return 'Alles geleverd';
    }

    final allesBesteld =
        alleArtikelen.every((artikel) => artikel.besteld == true);

    if (allesBesteld) {
      return 'Alles besteld';
    }

    return 'Nog niet alles besteld';
  }

  static Color bepaalStatusKleur(String status) {
    switch (status) {
      case 'geen artikels nodig':
        return Colors.green;
      case 'Nog niet alles besteld':
        return Colors.red;
      case 'Alles besteld':
        return Colors.blue;
      case 'Alles geleverd':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
