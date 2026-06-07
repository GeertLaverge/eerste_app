import 'package:flutter/material.dart';

import 'agenda_item.dart';
import 'agenda_repository.dart';
import 'agenda_klant_planning_tijd_helper.dart';
import '../klanten/fiche/klantenfiche_repository.dart';
import '../klanten/fiche/klantenfiche_model.dart';

class AgendaKlantPlanningDropService {
  static bool isNieuweKlantPlanning(DateTime oudeDag) {
    return oudeDag.year == 1900;
  }

  static Future<Map<String, List<AgendaItem>>?> verwerk({
    required BuildContext context,
    required DateTime nieuweDag,
    required AgendaItem item,
    required Map<String, List<AgendaItem>> itemsPerDag,
  }) async {
    final itemMetTijd = await AgendaKlantPlanningTijdHelper.kiesTijd(
      context: context,
      item: item,
    );

    if (itemMetTijd == null) return null;

    final nieuweItems = await AgendaRepository.voegToe(
      dag: nieuweDag,
      item: itemMetTijd,
      itemsPerDag: itemsPerDag,
    );

    if (item.type == 'opvolging') {
      await _zetOpvolgKlantUitWachtrij(item);
    }

    return nieuweItems;
  }

  static Future<void> _zetOpvolgKlantUitWachtrij(
    AgendaItem item,
  ) async {
    final fiches = await KlantenficheRepository.laadKlantenFiches();

    KlantenficheModel? gevonden;

    for (final fiche in fiches) {
      final zelfdeId = fiche.id.trim().isNotEmpty && fiche.id == item.klantNr;

      final zelfdeKlantNr =
          fiche.klantNr.trim().isNotEmpty && fiche.klantNr == item.klantNr;

      final zelfdeNaam = fiche.naam.trim().toLowerCase() ==
          item.naamKlant.trim().toLowerCase();

      if (zelfdeId || zelfdeKlantNr || zelfdeNaam) {
        gevonden = fiche;
        break;
      }
    }

    if (gevonden == null) return;

    final aangepasteFiche = KlantenficheModel(
      id: gevonden.id,
      naam: gevonden.naam,
      klantNr: gevonden.klantNr,
      straatnaam: gevonden.straatnaam,
      huisNr: gevonden.huisNr,
      gemeente: gevonden.gemeente,
      postcode: gevonden.postcode,
      gsm: gevonden.gsm,
      gsm2: gevonden.gsm2,
      email: gevonden.email,
      klantStatus: gevonden.klantStatus,
      bestelStatus: gevonden.bestelStatus,
      taakVoorKlant: gevonden.taakVoorKlant,
      klantTakenAfgewerktOp: gevonden.klantTakenAfgewerktOp,
      datumAfgewerkt: gevonden.datumAfgewerkt,
      klantTaken: gevonden.klantTaken,
      artikelen: gevonden.artikelen,
      extraWerken: gevonden.extraWerken,
      fotos: gevonden.fotos,
      opvolgTaken: gevonden.opvolgTaken,
      opvolgFicheVerstuurdNaarBureau: gevonden.opvolgFicheVerstuurdNaarBureau,
      klaarVoorNieuwePlanning: false,
    );

    await KlantenficheRepository.bewaarKlantenFiche(
      aangepasteFiche,
    );
  }

  static Future<void> zetOpvolgKlantTerugInWachtrij(
    AgendaItem item,
  ) async {
    final fiches = await KlantenficheRepository.laadKlantenFiches();

    KlantenficheModel? gevonden;

    for (final fiche in fiches) {
      final zelfdeKlantNr =
          fiche.klantNr.trim().isNotEmpty && fiche.klantNr == item.klantNr;

      final zelfdeNaam = fiche.naam.trim().toLowerCase() ==
          item.naamKlant.trim().toLowerCase();

      if (zelfdeKlantNr || zelfdeNaam) {
        gevonden = fiche;
        break;
      }
    }

    if (gevonden == null) return;

    final aangepasteFiche = KlantenficheModel(
      id: gevonden.id,
      naam: gevonden.naam,
      klantNr: gevonden.klantNr,
      straatnaam: gevonden.straatnaam,
      huisNr: gevonden.huisNr,
      gemeente: gevonden.gemeente,
      postcode: gevonden.postcode,
      gsm: gevonden.gsm,
      gsm2: gevonden.gsm2,
      email: gevonden.email,
      klantStatus: gevonden.klantStatus,
      bestelStatus: gevonden.bestelStatus,
      taakVoorKlant: gevonden.taakVoorKlant,
      klantTakenAfgewerktOp: gevonden.klantTakenAfgewerktOp,
      datumAfgewerkt: gevonden.datumAfgewerkt,
      klantTaken: gevonden.klantTaken,
      artikelen: gevonden.artikelen,
      extraWerken: gevonden.extraWerken,
      fotos: gevonden.fotos,
      opvolgTaken: gevonden.opvolgTaken,
      opvolgFicheVerstuurdNaarBureau: gevonden.opvolgFicheVerstuurdNaarBureau,
      klaarVoorNieuwePlanning: true,
    );

    await KlantenficheRepository.bewaarKlantenFiche(aangepasteFiche);
  }
}
