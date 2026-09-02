import 'dart:async';

import 'package:eerste_app/helpers/app_storage.dart';
import 'package:eerste_app/helpers/Agenda/agenda_bewerk_service.dart';
import 'package:eerste_app/helpers/Agenda/agenda_item.dart';
import 'package:eerste_app/helpers/Agenda/agenda_toevoeg_service.dart';
import 'package:eerste_app/helpers/Agenda/agenda_verplaats_service.dart';
import 'package:eerste_app/helpers/Agenda/agenda_sleep_service.dart';

import 'agenda_website_sync_service.dart';

class AgendaRepository {
  static Future<Map<String, List<AgendaItem>>> laadItems() async {
    return AppStorage.laadAgendaItemsNieuw();
  }

  static Future<void> bewaarItems(
    Map<String, List<AgendaItem>> itemsPerDag,
  ) async {
    await AppStorage.bewaarAgendaItemsNieuw(itemsPerDag);
  }

  static Future<Map<String, List<AgendaItem>>> voegToe({
    required DateTime dag,
    required AgendaItem item,
    required Map<String, List<AgendaItem>> itemsPerDag,
  }) async {
    // We geven nieuwe items hier al hun vaste id zodat exact dezelfde id
    // ook als sleutel voor de websiteblokkering gebruikt kan worden.
    final itemMetId = item.id.trim().isNotEmpty
        ? item
        : item.copyWith(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
          );

    final nieuw = AgendaToevoegService.voegItemToe(
      dag: dag,
      nieuwItem: itemMetId,
      itemsPerDag: itemsPerDag,
    );

    // Eerst lokaal veilig bewaren.
    await bewaarItems(nieuw);

    // Daarna pas website-sync. Deze mag de lokale opslag nooit blokkeren.
    unawaited(
      AgendaWebsiteSyncService.synchroniseerAfspraak(
        dag: dag,
        item: itemMetId,
      ),
    );

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

    final opgeslagenItem = _zoekItem(
      itemsPerDag: nieuw,
      id: oudItem.id,
      alternatief: nieuwItem,
    );

    unawaited(
      AgendaWebsiteSyncService.synchroniseerBewerking(
        dag: dag,
        oudItem: oudItem,
        nieuwItem: opgeslagenItem,
      ),
    );

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

    unawaited(
      AgendaWebsiteSyncService.verwijderAfspraak(
        dag: dag,
        item: item,
      ),
    );

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

    unawaited(
      AgendaWebsiteSyncService.synchroniseerVerplaatsing(
        oudeDag: oudeDag,
        nieuweDag: nieuweDag,
        item: item,
      ),
    );

    return nieuw;
  }

  static Future<Map<String, List<AgendaItem>>> kopieer({
    required DateTime nieuweDag,
    required AgendaItem item,
    required Map<String, List<AgendaItem>> itemsPerDag,
  }) async {
    final bestaandeIds = itemsPerDag.values
        .expand((items) => items)
        .map((item) => item.id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();

    final nieuw = AgendaSleepService.kopieer(
      nieuweDag: nieuweDag,
      item: item,
      itemsPerDag: itemsPerDag,
    );

    await bewaarItems(nieuw);

    final kopie = nieuw.values
        .expand((items) => items)
        .where(
          (item) =>
              item.id.trim().isNotEmpty &&
              !bestaandeIds.contains(item.id.trim()) &&
              !item.isVerwijderd,
        )
        .cast<AgendaItem?>()
        .firstWhere(
          (item) => item != null,
          orElse: () => null,
        );

    if (kopie != null) {
      unawaited(
        AgendaWebsiteSyncService.synchroniseerAfspraak(
          dag: nieuweDag,
          item: kopie,
        ),
      );
    }

    return nieuw;
  }

  static AgendaItem _zoekItem({
    required Map<String, List<AgendaItem>> itemsPerDag,
    required String id,
    required AgendaItem alternatief,
  }) {
    final zoekId = id.trim();
    if (zoekId.isEmpty) {
      return alternatief;
    }

    for (final items in itemsPerDag.values) {
      for (final item in items) {
        if (item.id.trim() == zoekId && !item.isVerwijderd) {
          return item;
        }
      }
    }

    return alternatief;
  }
}
