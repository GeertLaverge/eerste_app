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

  static Future<KlantenficheModel?> bestaandeFiche(
    String ficheId,
  ) async {
    final fiches = await KlantenficheRepository.laadKlantenFiches();

    for (final fiche in fiches) {
      if (fiche.id == ficheId) {
        return fiche;
      }
    }

    return null;
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
    required String datumAfgewerkt,
    required String taakVoorKlant,
    required List<KlantTaakItem> klantTaken,
    required List<KlantenficheExtraWerk> extraWerken,
    required List<KlantenficheArtikel> artikelen,
    required List<KlantenficheFoto> fotos,
    required String opvolgTaken,
    required String notities,
    required bool opvolgFicheVerstuurdNaarBureau,
    required bool klaarVoorNieuwePlanning,
    required bool afgewerktMailVerstuurd,
  }) async {
    if (naam.trim().isEmpty &&
        straatnaam.trim().isEmpty &&
        gsm.trim().isEmpty &&
        email.trim().isEmpty &&
        artikelen.isEmpty &&
        klantTaken.isEmpty &&
        extraWerken.isEmpty &&
        opvolgTaken.trim().isEmpty &&
        notities.trim().isEmpty) {
      return;
    }

    final bestaand = await bestaandeFiche(
      ficheId,
    );

    final bestelStatus = berekenBestelStatus(
      artikelen,
    );

    final fiche = KlantenficheModel(
      id: ficheId,
      updatedAt: DateTime.now().toIso8601String(),
      deletedAt: bestaand?.deletedAt ?? '',
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
      klantTakenAfgewerktOp: bestaand?.klantTakenAfgewerktOp ?? '',
      datumAfgewerkt: datumAfgewerkt,
      archiefDatum: bestaand?.archiefDatum ?? '',
      artikelen: artikelen,
      klantTaken: klantTaken,
      extraWerken: extraWerken,
      fotos: fotos,
      opvolgTaken: opvolgTaken,
      notities: notities,
      opvolgFicheVerstuurdNaarBureau: opvolgFicheVerstuurdNaarBureau,
      klaarVoorNieuwePlanning: klaarVoorNieuwePlanning,
      afgewerktMailVerstuurd: afgewerktMailVerstuurd,
    );

    await KlantenficheRepository.bewaarKlantenFiche(
      fiche,
    );
  }
}
