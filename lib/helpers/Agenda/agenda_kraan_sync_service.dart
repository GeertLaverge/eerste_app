import 'agenda_datum_helper.dart';
import 'agenda_item.dart';
import 'agenda_repository.dart';
import '../klanten/fiche/klantenfiche_model.dart';
import '../klanten/fiche/klantenfiche_repository.dart';

class AgendaKraanSyncService {
  static bool _zelfdeKlant(
    AgendaItem item,
    KlantenficheModel fiche,
  ) {
    final zelfdeKlantNr =
        fiche.klantNr.trim().isNotEmpty && fiche.klantNr == item.klantNr;

    final itemNaam = item.naamKlant.trim().toLowerCase();
    final ficheNaam = fiche.naam.trim().toLowerCase();

    return zelfdeKlantNr || (itemNaam.isNotEmpty && itemNaam == ficheNaam);
  }

  static Future<void> updateFicheNaKraanAanpassing({
    required DateTime dag,
    required AgendaItem kraanItem,
  }) async {
    if (kraanItem.type != 'kraan') return;
    if (!kraanItem.heeftTijd) return;

    final fiches = await KlantenficheRepository.laadKlantenFiches();

    for (final fiche in fiches) {
      if (!_zelfdeKlant(kraanItem, fiche)) continue;

      final aangepasteFiche = KlantenficheModel(
        id: fiche.id,
        updatedAt: DateTime.now().toIso8601String(),
        deletedAt: fiche.deletedAt,
        naam: fiche.naam,
        klantNr: fiche.klantNr,
        straatnaam: fiche.straatnaam,
        huisNr: fiche.huisNr,
        gemeente: fiche.gemeente,
        postcode: fiche.postcode,
        gsm: fiche.gsm,
        gsm2: fiche.gsm2,
        email: fiche.email,
        klantStatus: fiche.klantStatus,
        bestelStatus: fiche.bestelStatus,
        taakVoorKlant: fiche.taakVoorKlant,
        klantTakenAfgewerktOp: fiche.klantTakenAfgewerktOp,
        datumAfgewerkt: fiche.datumAfgewerkt,
        archiefDatum: fiche.archiefDatum,
        klantTaken: fiche.klantTaken,
        artikelen: fiche.artikelen,
        extraWerken: fiche.extraWerken,
        fotos: fiche.fotos,
        opvolgTaken: fiche.opvolgTaken,
        notities: fiche.notities,
        opvolgFicheVerstuurdNaarBureau: fiche.opvolgFicheVerstuurdNaarBureau,
        klaarVoorNieuwePlanning: fiche.klaarVoorNieuwePlanning,
        afgewerktMailVerstuurd: fiche.afgewerktMailVerstuurd,
        inTePlannenType: fiche.inTePlannenType,
        kraanNodig: true,
        kraanDatum: AgendaDatumHelper.datumKey(dag),
        kraanStartUur: kraanItem.startUur,
        kraanStartMinuut: kraanItem.startMinuut,
        kraanEindUur: kraanItem.eindUur,
        kraanEindMinuut: kraanItem.eindMinuut,
      );

      await KlantenficheRepository.bewaarKlantenFiche(
        aangepasteFiche,
      );

      return;
    }
  }

  static Future<Map<String, List<AgendaItem>>> verplaatsKraanMeeMetKlant({
    required DateTime oudeDag,
    required DateTime nieuweDag,
    required AgendaItem klantItem,
    required Map<String, List<AgendaItem>> itemsPerDag,
  }) async {
    if (klantItem.type != 'planning' &&
        klantItem.type != 'opvolging' &&
        klantItem.type != 'nadienst' &&
        klantItem.type != 'afspraak') {
      return itemsPerDag;
    }

    final klantNaam = klantItem.naamKlant.trim().toLowerCase();
    final klantTitel = klantItem.titel.trim().toLowerCase();

    AgendaItem? kraanItem;
    DateTime? kraanDag;

    itemsPerDag.forEach((datumKey, items) {
      for (final item in items) {
        if (item.isVerwijderd) continue;
        if (item.type != 'kraan') continue;

        final itemNaam = item.naamKlant.trim().toLowerCase();
        final itemTitel = item.titel.trim().toLowerCase();

        final zelfdeKlant = itemNaam == klantNaam ||
            itemNaam == klantTitel ||
            itemTitel.contains(klantNaam) ||
            itemTitel.contains(klantTitel);

        if (zelfdeKlant) {
          kraanItem = item;
          kraanDag = DateTime.tryParse(datumKey);
          return;
        }
      }
    });

    if (kraanItem == null || kraanDag == null) {
      return itemsPerDag;
    }

    final eerstVerwijderd = await AgendaRepository.verwijder(
      dag: kraanDag!,
      item: kraanItem!,
      itemsPerDag: itemsPerDag,
    );

    final nieuwKraanItem = kraanItem!.copyWith(
      updatedAt: DateTime.now().toIso8601String(),
    );

    final nieuweItems = await AgendaRepository.voegToe(
      dag: nieuweDag,
      item: nieuwKraanItem,
      itemsPerDag: eerstVerwijderd,
    );

    await updateFicheNaKraanAanpassing(
      dag: nieuweDag,
      kraanItem: nieuwKraanItem,
    );

    return nieuweItems;
  }
}
