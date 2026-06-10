import 'agenda_datum_helper.dart';
import 'agenda_item.dart';
import 'agenda_overlap_helper.dart';

class AgendaVerplaatsService {
  static bool zelfdeItem(
    AgendaItem a,
    AgendaItem b,
  ) {
    if (a.id.trim().isNotEmpty && b.id.trim().isNotEmpty) {
      return a.id == b.id;
    }

    return a.titel == b.titel &&
        a.type == b.type &&
        a.startUur == b.startUur &&
        a.startMinuut == b.startMinuut &&
        a.eindUur == b.eindUur &&
        a.eindMinuut == b.eindMinuut &&
        a.volledigeDag == b.volledigeDag;
  }

  static String? kanItemVerplaatsen({
    required DateTime oudeDag,
    required DateTime nieuweDag,
    required AgendaItem item,
    required Map<String, List<AgendaItem>> itemsPerDag,
  }) {
    final oudeKey = AgendaDatumHelper.datumKey(oudeDag);
    final nieuweKey = AgendaDatumHelper.datumKey(nieuweDag);

    final bestaandeItems = List<AgendaItem>.from(
      itemsPerDag[nieuweKey] ?? [],
    );

    if (oudeKey == nieuweKey) {
      bestaandeItems.removeWhere(
        (bestaand) => zelfdeItem(bestaand, item),
      );
    }

    return AgendaOverlapHelper.overlapMelding(
      nieuwItem: item,
      bestaandeItems: bestaandeItems.where((item) {
        return !item.isVerwijderd;
      }).toList(),
    );
  }

  static Map<String, List<AgendaItem>> verplaatsItem({
    required DateTime oudeDag,
    required DateTime nieuweDag,
    required AgendaItem item,
    required Map<String, List<AgendaItem>> itemsPerDag,
  }) {
    final oudeKey = AgendaDatumHelper.datumKey(oudeDag);
    final nieuweKey = AgendaDatumHelper.datumKey(nieuweDag);

    final kopie = <String, List<AgendaItem>>{
      ...itemsPerDag,
    };

    final oudeItems = List<AgendaItem>.from(
      kopie[oudeKey] ?? [],
    );

    oudeItems.removeWhere(
      (bestaand) => zelfdeItem(bestaand, item),
    );

    if (oudeItems.isEmpty) {
      kopie.remove(oudeKey);
    } else {
      kopie[oudeKey] = oudeItems;
    }

    final nieuweItems = List<AgendaItem>.from(
      kopie[nieuweKey] ?? [],
    );

    final verplaatstItem = item.copyWith(
      updatedAt: DateTime.now().toIso8601String(),
      deletedAt: '',
    );

    nieuweItems.add(verplaatstItem);
    kopie[nieuweKey] = nieuweItems;

    return kopie;
  }
}
