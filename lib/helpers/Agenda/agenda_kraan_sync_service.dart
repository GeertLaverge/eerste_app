import 'agenda_datum_helper.dart';
import 'agenda_item.dart';
import 'agenda_repository.dart';
import '../klanten/fiche/klantenfiche_model.dart';
import '../klanten/fiche/klantenfiche_repository.dart';

class AgendaKraanSyncService {
  static bool _zelfdeKlant(AgendaItem item, KlantenficheModel fiche) {
    final zelfdeKlantNr =
        fiche.klantNr.trim().isNotEmpty && fiche.klantNr == item.klantNr;

    final itemNaam = item.naamKlant.trim().toLowerCase();
    final ficheNaam = fiche.naam.trim().toLowerCase();

    return zelfdeKlantNr || (itemNaam.isNotEmpty && itemNaam == ficheNaam);
  }

  static bool _isGeneriekePlanningTitel(String waarde) {
    final titel = waarde.trim().toLowerCase();

    return titel.isEmpty ||
        titel == 'planning' ||
        titel == 'opvolging' ||
        titel == 'nadienst' ||
        titel == 'afspraak' ||
        titel == 'klant';
  }

  static bool _kraanHoortBijKlant({
    required AgendaItem kraanItem,
    required AgendaItem klantItem,
  }) {
    final klantNr = klantItem.klantNr.trim();
    final kraanKlantNr = kraanItem.klantNr.trim();

    if (klantNr.isNotEmpty && kraanKlantNr.isNotEmpty) {
      return klantNr == kraanKlantNr;
    }

    final klantNaam = klantItem.naamKlant.trim().toLowerCase();
    final klantTitel = klantItem.titel.trim().toLowerCase();
    final kraanNaam = kraanItem.naamKlant.trim().toLowerCase();
    final kraanTitel = kraanItem.titel.trim().toLowerCase();

    if (klantNaam.isNotEmpty) {
      if (kraanNaam == klantNaam) {
        return true;
      }

      if (kraanTitel.isNotEmpty && kraanTitel.contains(klantNaam)) {
        return true;
      }
    }

    if (!_isGeneriekePlanningTitel(klantTitel)) {
      if (kraanNaam == klantTitel) {
        return true;
      }

      if (kraanTitel.isNotEmpty && kraanTitel.contains(klantTitel)) {
        return true;
      }
    }

    return false;
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

      await KlantenficheRepository.bewaarKlantenFiche(aangepasteFiche);

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

    AgendaItem? kraanItem;
    DateTime? kraanDag;

    zoekKraan:
    for (final entry in itemsPerDag.entries) {
      final datum = DateTime.tryParse(entry.key);
      if (datum == null) {
        continue;
      }

      for (final item in entry.value) {
        if (item.isVerwijderd) continue;
        if (item.type != 'kraan') continue;

        if (!_kraanHoortBijKlant(kraanItem: item, klantItem: klantItem)) {
          continue;
        }

        kraanItem = item;
        kraanDag = datum;
        break zoekKraan;
      }
    }

    if (kraanItem == null || kraanDag == null) {
      return itemsPerDag;
    }

    // De kraan wordt als één echte verplaatsing verwerkt.
    // Er is dus geen opgeslagen tussentoestand meer waarin de kraan al
    // verwijderd is maar nog niet op de nieuwe dag staat.
    final nieuweItems = await AgendaRepository.verplaats(
      oudeDag: kraanDag,
      nieuweDag: nieuweDag,
      item: kraanItem,
      itemsPerDag: itemsPerDag,
    );

    await updateFicheNaKraanAanpassing(
      dag: nieuweDag,
      kraanItem: kraanItem,
    );

    return nieuweItems;
  }
}
