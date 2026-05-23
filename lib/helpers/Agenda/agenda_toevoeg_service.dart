import 'agenda_datum_helper.dart';
import 'agenda_item.dart';
import 'agenda_overlap_helper.dart';

class AgendaToevoegService {
  static String? kanItemToevoegen({
    required DateTime dag,
    required AgendaItem nieuwItem,
    required Map<String, List<AgendaItem>> itemsPerDag,
  }) {
    final datumKey = AgendaDatumHelper.datumKey(dag);

    final bestaandeItems = itemsPerDag[datumKey] ?? [];

    return AgendaOverlapHelper.overlapMelding(
      nieuwItem: nieuwItem,
      bestaandeItems: bestaandeItems,
    );
  }

  static Map<String, List<AgendaItem>> voegItemToe({
    required DateTime dag,
    required AgendaItem nieuwItem,
    required Map<String, List<AgendaItem>> itemsPerDag,
  }) {
    final datumKey = AgendaDatumHelper.datumKey(dag);

    final kopie = <String, List<AgendaItem>>{
      ...itemsPerDag,
    };

    final bestaandeItems = List<AgendaItem>.from(
      kopie[datumKey] ?? [],
    );

    bestaandeItems.add(nieuwItem);

    kopie[datumKey] = bestaandeItems;

    return kopie;
  }
}
