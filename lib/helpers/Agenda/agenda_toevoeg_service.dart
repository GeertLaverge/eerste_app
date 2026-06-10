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

    final bestaandeItems = (itemsPerDag[datumKey] ?? []).where((item) {
      return !item.isVerwijderd;
    }).toList();

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

    final nu = DateTime.now().toIso8601String();

    final itemMetSync = nieuwItem.copyWith(
      id: nieuwItem.id.trim().isNotEmpty
          ? nieuwItem.id
          : DateTime.now().microsecondsSinceEpoch.toString(),
      updatedAt:
          nieuwItem.updatedAt.trim().isNotEmpty ? nieuwItem.updatedAt : nu,
      deletedAt: '',
    );

    bestaandeItems.add(itemMetSync);

    kopie[datumKey] = bestaandeItems;

    return kopie;
  }
}
