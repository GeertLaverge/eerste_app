import 'package:flutter/material.dart';

import 'agenda_item.dart';
import 'agenda_repository.dart';
import 'agenda_klant_planning_tijd_helper.dart';

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

    return AgendaRepository.voegToe(
      dag: nieuweDag,
      item: itemMetTijd,
      itemsPerDag: itemsPerDag,
    );
  }
}
