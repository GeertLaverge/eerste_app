import 'agenda_filter_helper.dart';
import 'agenda_filter_state.dart';
import 'agenda_item.dart';

class AgendaZichtbareItemsHelper {
  static Map<String, List<AgendaItem>> bereken({
    required Map<String, List<AgendaItem>> itemsPerDag,
    required AgendaFilterState filters,
  }) {
    return AgendaFilterHelper.gefilterdeItems(
      itemsPerDag: itemsPerDag,
      toonPlanning: filters.toonPlanning,
      toonOpvolging: filters.toonOpvolging,
      toonNadienst: filters.toonNadienst,
      toonAfspraak: filters.toonAfspraak,
      toonDagtaak: filters.toonDagtaak,
      toonVerlof: filters.toonVerlof,
      toonKraan: filters.toonKraan,
    );
  }
}
