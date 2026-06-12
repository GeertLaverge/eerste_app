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

    return nieuweItems;
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

    final nieuweStatus = item.type == 'afspraak'
        ? 'Afspraak'
        : item.type == 'nadienst'
            ? 'Nadienst'
            : item.type == 'opvolging'
                ? 'Opvolgen'
                : 'Actief';

    final klaarVoorNieuwePlanning = item.type == 'opvolging';

    final basisFiche = gevonden ??
        KlantenficheModel(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          naam: item.naamKlant.trim().isNotEmpty
              ? item.naamKlant.trim()
              : item.titel.trim(),
          klantNr: item.klantNr,
          straatnaam: item.straatnaam,
          huisNr: item.huisNr,
          gemeente: item.gemeente,
          postcode: item.postcode,
          gsm: item.gsm,
          gsm2: item.gsm2,
          email: item.email,
        );

    final aangepasteFiche = KlantenficheModel(
      id: basisFiche.id,
      updatedAt: DateTime.now().toIso8601String(),
      deletedAt: basisFiche.deletedAt,
      naam: basisFiche.naam,
      klantNr: basisFiche.klantNr,
      straatnaam: basisFiche.straatnaam,
      huisNr: basisFiche.huisNr,
      gemeente: basisFiche.gemeente,
      postcode: basisFiche.postcode,
      gsm: basisFiche.gsm,
      gsm2: basisFiche.gsm2,
      email: basisFiche.email,
      klantStatus: nieuweStatus,
      bestelStatus: basisFiche.bestelStatus,
      taakVoorKlant: basisFiche.taakVoorKlant,
      klantTakenAfgewerktOp: basisFiche.klantTakenAfgewerktOp,
      datumAfgewerkt: basisFiche.datumAfgewerkt,
      archiefDatum: basisFiche.archiefDatum,
      klantTaken: basisFiche.klantTaken,
      artikelen: basisFiche.artikelen,
      extraWerken: basisFiche.extraWerken,
      fotos: basisFiche.fotos,
      opvolgTaken: basisFiche.opvolgTaken,
      notities: basisFiche.notities,
      opvolgFicheVerstuurdNaarBureau: basisFiche.opvolgFicheVerstuurdNaarBureau,
      klaarVoorNieuwePlanning: klaarVoorNieuwePlanning,
      afgewerktMailVerstuurd: basisFiche.afgewerktMailVerstuurd,
      inTePlannenType: item.type,
    );

    await KlantenficheRepository.bewaarKlantenFiche(
      aangepasteFiche,
    );
  }
}
