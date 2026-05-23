import 'package:eerste_app/helpers/app_storage.dart';
import 'package:eerste_app/helpers/Agenda/agenda_bewerk_service.dart';
import 'package:eerste_app/helpers/Agenda/agenda_item.dart';
import 'package:eerste_app/helpers/Agenda/agenda_toevoeg_service.dart';
import 'package:eerste_app/helpers/Agenda/agenda_verplaats_service.dart';
import 'package:eerste_app/helpers/Agenda/agenda_sleep_service.dart';

class AgendaRepository {
  static Future<Map<String, List<AgendaItem>>> laadItems() async {
    return AppStorage.laadAgendaItemsNieuw();
  }

  static Future<void> bewaarItems(
    Map<String, List<AgendaItem>> itemsPerDag,
  ) async {
    await AppStorage.bewaarAgendaItemsNieuw(
      itemsPerDag,
    );
  }

  static Future<Map<String, List<AgendaItem>>> voegToe({
    required DateTime dag,
    required AgendaItem item,
    required Map<String, List<AgendaItem>> itemsPerDag,
  }) async {
    final nieuw = AgendaToevoegService.voegItemToe(
      dag: dag,
      nieuwItem: item,
      itemsPerDag: itemsPerDag,
    );

    await bewaarItems(nieuw);

    return nieuw;
  }

  static Future<Map<String, List<AgendaItem>>> bewerk({
    required DateTime dag,
    required AgendaItem oudItem,
    required AgendaItem nieuwItem,
    required Map<String, List<AgendaItem>> itemsPerDag,
  }) async {
    final nieuw = AgendaBewerkService.bewerkItem(
      dag: dag,
      oudItem: oudItem,
      nieuwItem: nieuwItem,
      itemsPerDag: itemsPerDag,
    );

    await bewaarItems(nieuw);

    return nieuw;
  }

  static Future<Map<String, List<AgendaItem>>> verwijder({
    required DateTime dag,
    required AgendaItem item,
    required Map<String, List<AgendaItem>> itemsPerDag,
  }) async {
    final nieuw = AgendaBewerkService.verwijderItem(
      dag: dag,
      item: item,
      itemsPerDag: itemsPerDag,
    );

    await bewaarItems(nieuw);

    return nieuw;
  }

  static Future<Map<String, List<AgendaItem>>> verplaats({
    required DateTime oudeDag,
    required DateTime nieuweDag,
    required AgendaItem item,
    required Map<String, List<AgendaItem>> itemsPerDag,
  }) async {
    final nieuw = AgendaVerplaatsService.verplaatsItem(
      oudeDag: oudeDag,
      nieuweDag: nieuweDag,
      item: item,
      itemsPerDag: itemsPerDag,
    );

    await bewaarItems(nieuw);

    return nieuw;
  }

  static Future<Map<String, List<AgendaItem>>> kopieer({
    required DateTime nieuweDag,
    required AgendaItem item,
    required Map<String, List<AgendaItem>> itemsPerDag,
  }) async {
    final nieuw = AgendaSleepService.kopieer(
      nieuweDag: nieuweDag,
      item: item,
      itemsPerDag: itemsPerDag,
    );

    await bewaarItems(nieuw);

    return nieuw;
  }
}
