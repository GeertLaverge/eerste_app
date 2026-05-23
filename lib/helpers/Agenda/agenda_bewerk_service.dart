import 'agenda_datum_helper.dart';
import 'agenda_item.dart';
import 'agenda_overlap_helper.dart';

class AgendaBewerkService {
  static bool zelfdeItem(
    AgendaItem a,
    AgendaItem b,
  ) {
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

    final index = bestaandeItems.indexWhere(
      (item) => zelfdeItem(item, oudItem),
    );

    if (index >= 0) {
      bestaandeItems.removeAt(index);
    }

    return AgendaOverlapHelper.overlapMelding(
      nieuwItem: nieuwItem,
      bestaandeItems: bestaandeItems,
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

    if (index >= 0) {
      items[index] = nieuwItem;
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

    if (index >= 0) {
      items.removeAt(index);
    }

    if (items.isEmpty) {
      kopie.remove(datumKey);
    } else {
      kopie[datumKey] = items;
    }

    return kopie;
  }
}
