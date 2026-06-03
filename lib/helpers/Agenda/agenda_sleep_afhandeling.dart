import 'package:flutter/material.dart';

import 'agenda_item.dart';
import 'agenda_repository.dart';
import 'agenda_sleep_keuze_popup.dart';
import 'agenda_sleep_tijd_popup.dart';
import 'agenda_toevoeg_service.dart';
import 'agenda_verplaats_service.dart';

class AgendaSleepAfhandeling {
  static AgendaItem itemMetNieuweTijden({
    required AgendaItem item,
    required TimeOfDay start,
    required TimeOfDay eind,
  }) {
    return item.copyWithTijd(
      startUur: start.hour,
      startMinuut: start.minute,
      eindUur: eind.hour,
      eindMinuut: eind.minute,
    );
  }

  static Future<Map<String, List<AgendaItem>>?> verwerkDrop({
    required BuildContext context,
    required DateTime oudeDag,
    required DateTime nieuweDag,
    required AgendaItem item,
    required Map<String, List<AgendaItem>> itemsPerDag,
  }) async {
    final actie = await AgendaSleepKeuzePopup.toon(context);

    if (actie == null) return null;

    AgendaItem nieuwItem = item;
    if (actie.actie == AgendaSleepActie.verwijderen) {
      return AgendaRepository.verwijder(
        dag: oudeDag,
        item: item,
        itemsPerDag: itemsPerDag,
      );
    }

    if (actie.actie == AgendaSleepActie.tijdAanpassen) {
      final tijd = await AgendaSleepTijdPopup.toon(
        context,
        huidigeStart: TimeOfDay(
          hour: item.startUur ?? 7,
          minute: item.startMinuut ?? 0,
        ),
        huidigeEind: TimeOfDay(
          hour: item.eindUur ?? 15,
          minute: item.eindMinuut ?? 30,
        ),
      );

      if (tijd == null) return null;

      if (!tijd.tijdenBehouden &&
          tijd.startTijd != null &&
          tijd.eindTijd != null) {
        nieuwItem = itemMetNieuweTijden(
          item: item,
          start: tijd.startTijd!,
          eind: tijd.eindTijd!,
        );
      }

      return AgendaRepository.bewerk(
        dag: oudeDag,
        oudItem: item,
        nieuwItem: nieuwItem,
        itemsPerDag: itemsPerDag,
      );
    }

    final tijd = await AgendaSleepTijdPopup.toon(
      context,
      huidigeStart: TimeOfDay(
        hour: item.startUur ?? 7,
        minute: item.startMinuut ?? 0,
      ),
      huidigeEind: TimeOfDay(
        hour: item.eindUur ?? 15,
        minute: item.eindMinuut ?? 30,
      ),
    );

    if (tijd == null) return null;

    if (!tijd.tijdenBehouden &&
        tijd.startTijd != null &&
        tijd.eindTijd != null) {
      nieuwItem = itemMetNieuweTijden(
        item: item,
        start: tijd.startTijd!,
        eind: tijd.eindTijd!,
      );
    }

    String? foutmelding;

    if (actie.actie == AgendaSleepActie.kopieren) {
      foutmelding = AgendaToevoegService.kanItemToevoegen(
        dag: nieuweDag,
        nieuwItem: nieuwItem,
        itemsPerDag: itemsPerDag,
      );
    } else {
      foutmelding = AgendaVerplaatsService.kanItemVerplaatsen(
        oudeDag: oudeDag,
        nieuweDag: nieuweDag,
        item: nieuwItem,
        itemsPerDag: itemsPerDag,
      );
    }

    if (foutmelding != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(foutmelding),
          backgroundColor: Colors.red,
        ),
      );

      return null;
    }

    if (actie.actie == AgendaSleepActie.kopieren) {
      return AgendaRepository.voegToe(
        dag: nieuweDag,
        item: nieuwItem,
        itemsPerDag: itemsPerDag,
      );
    }

    return AgendaRepository.verplaats(
      oudeDag: oudeDag,
      nieuweDag: nieuweDag,
      item: nieuwItem,
      itemsPerDag: itemsPerDag,
    );
  }
}
