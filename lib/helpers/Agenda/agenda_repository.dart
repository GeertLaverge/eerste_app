import 'dart:async';

import 'package:eerste_app/helpers/app_storage.dart';
import 'package:eerste_app/helpers/Agenda/agenda_bewerk_service.dart';
import 'package:eerste_app/helpers/Agenda/agenda_item.dart';
import 'package:eerste_app/helpers/Agenda/agenda_toevoeg_service.dart';
import 'package:eerste_app/helpers/Agenda/agenda_verplaats_service.dart';
import 'package:eerste_app/helpers/Agenda/agenda_sleep_service.dart';
import 'package:eerste_app/helpers/sync/onedrive_sync_service.dart';

import 'agenda_website_sync_service.dart';

class AgendaRepository {
  static Timer? _snelleAgendaSyncTimer;

  static Future<Map<String, List<AgendaItem>>> laadItems() async {
    return AppStorage.laadAgendaItemsNieuw();
  }

  static Future<Map<String, List<AgendaItem>>> bewaarItems(
    Map<String, List<AgendaItem>> itemsPerDag,
  ) async {
    await AppStorage.bewaarAgendaItemsNieuw(itemsPerDag);
    _planSnelleAgendaSync();

    // AppStorage voert vóór de fysieke save nog een veilige merge uit met
    // de meest recente lokale agenda. Geef daarom altijd precies de versie
    // terug die werkelijk is opgeslagen en zichtbaar hoort te zijn.
    return laadItems();
  }

  static void _planSnelleAgendaSync() {
    // Meerdere snelle mutaties (bv. websiteboekingen importeren) worden
    // samengenomen tot één lichte agenda-module-sync.
    _snelleAgendaSyncTimer?.cancel();
    _snelleAgendaSyncTimer = Timer(const Duration(milliseconds: 350), () {
      _snelleAgendaSyncTimer = null;
      unawaited(OneDriveSyncService().syncAgendaSnel());
    });
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
        : item.copyWith(id: DateTime.now().microsecondsSinceEpoch.toString());

    final nieuw = AgendaToevoegService.voegItemToe(
      dag: dag,
      nieuwItem: itemMetId,
      itemsPerDag: itemsPerDag,
    );

    // Eerst lokaal veilig bewaren. De UI kan daarna onmiddellijk vernieuwen.
    final opgeslagen = await bewaarItems(nieuw);

    // Websiteblokkering gebeurt bewust op de achtergrond. Een trage website-
    // verbinding mag de lokale agenda niet langer zichtbaar ophouden.
    unawaited(
      AgendaWebsiteSyncService.synchroniseerAfspraak(dag: dag, item: itemMetId),
    );

    return opgeslagen;
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

    final opgeslagen = await bewaarItems(nieuw);

    final opgeslagenItem = _zoekItem(
      itemsPerDag: opgeslagen,
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

    return opgeslagen;
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

    // Eerst de verwijdering veilig lokaal bewaren en meteen de werkelijk
    // opgeslagen zichtbare agenda teruglezen.
    final opgeslagen = await bewaarItems(nieuw);

    // Websiteblokkering mag op de achtergrond verdwijnen.
    unawaited(AgendaWebsiteSyncService.verwijderAfspraak(dag: dag, item: item));

    return opgeslagen;
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

    final opgeslagen = await bewaarItems(nieuw);

    unawaited(
      AgendaWebsiteSyncService.synchroniseerVerplaatsing(
        oudeDag: oudeDag,
        nieuweDag: nieuweDag,
        item: item,
      ),
    );

    return opgeslagen;
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

    final opgeslagen = await bewaarItems(nieuw);

    final kopie = opgeslagen.values
        .expand((items) => items)
        .where(
          (item) =>
              item.id.trim().isNotEmpty &&
              !bestaandeIds.contains(item.id.trim()) &&
              !item.isVerwijderd,
        )
        .cast<AgendaItem?>()
        .firstWhere((item) => item != null, orElse: () => null);

    if (kopie != null) {
      unawaited(
        AgendaWebsiteSyncService.synchroniseerAfspraak(
          dag: nieuweDag,
          item: kopie,
        ),
      );
    }

    return opgeslagen;
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
