import 'klantenfiche_model.dart';
import 'klantenfiche_repository.dart';

class KlantenficheService {
  static String berekenBestelStatus(
    List<KlantenficheArtikel> artikelen,
  ) {
    if (artikelen.isEmpty) {
      return 'Geen artikelen';
    }

    final allesGeleverd = artikelen.every(
      (artikel) => artikel.geleverd,
    );

    final allesBesteld = artikelen.every(
      (artikel) => artikel.besteld,
    );

    if (allesGeleverd) {
      return 'Geleverd';
    }

    if (allesBesteld) {
      return 'Besteld';
    }

    return 'Te bestellen';
  }

  static Future<void> automatischBewaren({
    required String ficheId,
    required String naam,
    required String klantNr,
    required String straatnaam,
    required String huisNr,
    required String gemeente,
    required String postcode,
    required String gsm,
    required String gsm2,
    required String email,
    required String klantStatus,
    required String taakVoorKlant,
    required List<KlantenficheArtikel> artikelen,
    required List<KlantTaakItem> klantTaken,
  }) async {
    if (naam.trim().isEmpty &&
        straatnaam.trim().isEmpty &&
        gsm.trim().isEmpty &&
        email.trim().isEmpty &&
        artikelen.isEmpty &&
        klantTaken.isEmpty) {
      return;
    }

    final bestelStatus = berekenBestelStatus(
      artikelen,
    );

    final fiche = KlantenficheModel(
      id: ficheId,
      naam: naam,
      klantNr: klantNr,
      straatnaam: straatnaam,
      huisNr: huisNr,
      gemeente: gemeente,
      postcode: postcode,
      gsm: gsm,
      gsm2: gsm2,
      email: email,
      klantStatus: klantStatus,
      bestelStatus: bestelStatus,
      taakVoorKlant: taakVoorKlant,
      artikelen: artikelen,
      klantTaken: klantTaken,
    );

    await KlantenficheRepository.bewaarKlantenFiche(
      fiche,
    );
  }
}
