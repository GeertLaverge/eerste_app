import '../app_storage.dart';
import 'agenda_filter_state.dart';

class AgendaFilterStorage {
  static Future<AgendaFilterState> laad() async {
    final waarden = await AppStorage.laadAgendaFilters();

    return AgendaFilterState(
      toonPlanning: waarden['planningKlanten'] ?? true,
      toonOpvolging: waarden['opvolging'] ?? true,
      toonNadienst: waarden['nadienst'] ?? true,
      toonAfspraak: waarden['afspraken'] ?? true,
      toonDagtaak: waarden['dagTaken'] ?? true,
      toonVerlof: waarden['vakantie'] ?? true,
      toonKraan: waarden['kraan'] ?? true,
    );
  }

  static Future<void> bewaar(
    AgendaFilterState filters,
  ) async {
    await AppStorage.bewaarAgendaFilters({
      'planningKlanten': filters.toonPlanning,
      'opvolging': filters.toonOpvolging,
      'nadienst': filters.toonNadienst,
      'afspraken': filters.toonAfspraak,
      'dagTaken': filters.toonDagtaak,
      'vakantie': filters.toonVerlof,
      'kraan': filters.toonKraan,
    });
  }
}
