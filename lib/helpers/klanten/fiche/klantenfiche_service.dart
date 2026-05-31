import 'klantenfiche_model.dart';
import 'klantenfiche_repository.dart';

class KlantenficheService {
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
    required String bestelStatus,
    required String taakVoorKlant,
  }) async {
    if (naam.trim().isEmpty &&
        straatnaam.trim().isEmpty &&
        gsm.trim().isEmpty &&
        email.trim().isEmpty) {
      return;
    }

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
    );

    await KlantenficheRepository.bewaarKlantenFiche(
      fiche,
    );
  }
}
