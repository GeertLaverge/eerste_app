import '../../app_storage.dart';
import 'klantenfiche_model.dart';

class KlantenficheRepository {
  static Future<List<KlantenficheModel>> _laadAlleKlantenFiches() async {
    final lijst = await AppStorage.laadKlantenFiches();

    return lijst
        .map(
          (item) => KlantenficheModel.fromJson(item),
        )
        .toList();
  }

  static Future<List<KlantenficheModel>> laadKlantenFiches() async {
    final fiches = await _laadAlleKlantenFiches();

    return fiches.where((fiche) {
      return fiche.deletedAt.trim().isEmpty;
    }).toList();
  }

  static Future<void> bewaarKlantenFiche(
    KlantenficheModel fiche,
  ) async {
    final fiches = await _laadAlleKlantenFiches();

    final index = fiches.indexWhere(
      (f) => f.id == fiche.id,
    );

    if (index == -1) {
      fiches.add(fiche);
    } else {
      final bestaandeFiche = fiches[index];

      final bestaandeDatum = DateTime.tryParse(
        bestaandeFiche.updatedAt,
      );

      final nieuweDatum = DateTime.tryParse(
        fiche.updatedAt,
      );

      if (bestaandeDatum != null &&
          nieuweDatum != null &&
          bestaandeDatum.isAfter(nieuweDatum)) {
        return;
      }

      fiches[index] = fiche;
    }

    await AppStorage.bewaarKlantenFiches(
      fiches.map((f) => f.toJson()).toList(),
    );
  }

  static Future<void> verwijderKlantenFiche(
    String id,
  ) async {
    final fiches = await _laadAlleKlantenFiches();

    final index = fiches.indexWhere(
      (f) => f.id == id,
    );

    if (index == -1) return;

    final bestaandeFiche = fiches[index];

    final verwijderdeFiche = KlantenficheModel(
      id: bestaandeFiche.id,
      updatedAt: DateTime.now().toIso8601String(),
      deletedAt: DateTime.now().toIso8601String(),
      naam: bestaandeFiche.naam,
      klantNr: bestaandeFiche.klantNr,
      straatnaam: bestaandeFiche.straatnaam,
      huisNr: bestaandeFiche.huisNr,
      gemeente: bestaandeFiche.gemeente,
      postcode: bestaandeFiche.postcode,
      gsm: bestaandeFiche.gsm,
      gsm2: bestaandeFiche.gsm2,
      email: bestaandeFiche.email,
      klantStatus: bestaandeFiche.klantStatus,
      bestelStatus: bestaandeFiche.bestelStatus,
      taakVoorKlant: bestaandeFiche.taakVoorKlant,
      klantTakenAfgewerktOp: bestaandeFiche.klantTakenAfgewerktOp,
      datumAfgewerkt: bestaandeFiche.datumAfgewerkt,
      archiefDatum: bestaandeFiche.archiefDatum,
      notities: bestaandeFiche.notities,
      afgewerktMailVerstuurd: bestaandeFiche.afgewerktMailVerstuurd,
      inTePlannenType: bestaandeFiche.inTePlannenType,
      klantTaken: bestaandeFiche.klantTaken,
      artikelen: bestaandeFiche.artikelen,
      extraWerken: bestaandeFiche.extraWerken,
      fotos: bestaandeFiche.fotos,
      opvolgTaken: bestaandeFiche.opvolgTaken,
      opvolgFicheVerstuurdNaarBureau:
          bestaandeFiche.opvolgFicheVerstuurdNaarBureau,
      klaarVoorNieuwePlanning: bestaandeFiche.klaarVoorNieuwePlanning,
    );

    fiches[index] = verwijderdeFiche;

    await AppStorage.bewaarKlantenFiches(
      fiches.map((f) => f.toJson()).toList(),
    );
  }
}
