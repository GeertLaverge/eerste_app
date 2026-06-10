import 'agenda_datum_helper.dart';
import 'agenda_item.dart';
import 'agenda_overlap_helper.dart';

class AgendaBewerkService {
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

  static String? kanItemBewerken({
    required DateTime dag,
    required AgendaItem oudItem,
    required AgendaItem nieuwItem,
    required Map<String, List<AgendaItem>> itemsPerDag,
  }) {
    final datumKey = AgendaDatumHelper.datumKey(dag);

    final bestaandeItems = List<AgendaItem>.from(
      itemsPerDag[datumKey] ?? [],
    );

    bestaandeItems.removeWhere(
      (item) => zelfdeItem(item, oudItem),
    );

    return AgendaOverlapHelper.overlapMelding(
      nieuwItem: nieuwItem,
      bestaandeItems: bestaandeItems.where((item) {
        return !item.isVerwijderd;
      }).toList(),
    );
  }

  static Map<String, List<AgendaItem>> bewerkItem({
    required DateTime dag,
    required AgendaItem oudItem,
    required AgendaItem nieuwItem,
    required Map<String, List<AgendaItem>> itemsPerDag,
  }) {
    final datumKey = AgendaDatumHelper.datumKey(dag);

    final kopie = <String, List<AgendaItem>>{
      ...itemsPerDag,
    };

    final items = List<AgendaItem>.from(
      kopie[datumKey] ?? [],
    );

    final index = items.indexWhere(
      (item) => zelfdeItem(item, oudItem),
    );

    final aangepastItem = nieuwItem.copyWith(
      id: oudItem.id,
      updatedAt: DateTime.now().toIso8601String(),
      deletedAt: '',
    );

    if (index >= 0) {
      items[index] = aangepastItem;
    } else {
      items.add(aangepastItem);
    }

    kopie[datumKey] = items;

    return kopie;
  }

  static Map<String, List<AgendaItem>> verwijderItem({
    required DateTime dag,
    required AgendaItem item,
    required Map<String, List<AgendaItem>> itemsPerDag,
  }) {
    final datumKey = AgendaDatumHelper.datumKey(dag);

    final kopie = <String, List<AgendaItem>>{
      ...itemsPerDag,
    };

    final items = List<AgendaItem>.from(
      kopie[datumKey] ?? [],
    );

    final index = items.indexWhere(
      (bestaand) => zelfdeItem(bestaand, item),
    );

    final nu = DateTime.now().toIso8601String();

    final verwijderdItem = item.copyWith(
      updatedAt: nu,
      deletedAt: nu,
    );

    if (index >= 0) {
      items[index] = verwijderdItem;
    } else {
      items.add(verwijderdItem);
    }

    kopie[datumKey] = items;

    return kopie;
  }
}
