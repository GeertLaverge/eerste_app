import 'agenda_bewerk_service.dart';
import 'agenda_item.dart';
import 'agenda_toevoeg_service.dart';
import 'agenda_verplaats_service.dart';

class AgendaSleepService {
  static String? kanKopieren({
    required DateTime nieuweDag,
    required AgendaItem item,
    required Map<String, List<AgendaItem>> itemsPerDag,
  }) {
    return AgendaToevoegService.kanItemToevoegen(
      dag: nieuweDag,
      nieuwItem: item,
      itemsPerDag: itemsPerDag,
    );
  }

  static String? kanVerplaatsen({
    required DateTime oudeDag,
    required DateTime nieuweDag,
    required AgendaItem item,
    required Map<String, List<AgendaItem>> itemsPerDag,
  }) {
    return AgendaVerplaatsService.kanItemVerplaatsen(
      oudeDag: oudeDag,
      nieuweDag: nieuweDag,
      item: item,
      itemsPerDag: itemsPerDag,
    );
  }

  static Map<String, List<AgendaItem>> kopieer({
    required DateTime nieuweDag,
    required AgendaItem item,
    required Map<String, List<AgendaItem>> itemsPerDag,
  }) {
    final kopieItem = item.copyWith(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      updatedAt: DateTime.now().toIso8601String(),
      deletedAt: '',
    );

    return AgendaToevoegService.voegItemToe(
      dag: nieuweDag,
      nieuwItem: kopieItem,
      itemsPerDag: itemsPerDag,
    );
  }

  static Map<String, List<AgendaItem>> verplaats({
    required DateTime oudeDag,
    required DateTime nieuweDag,
    required AgendaItem item,
    required Map<String, List<AgendaItem>> itemsPerDag,
  }) {
    return AgendaVerplaatsService.verplaatsItem(
      oudeDag: oudeDag,
      nieuweDag: nieuweDag,
      item: item,
      itemsPerDag: itemsPerDag,
    );
  }

  static Map<String, List<AgendaItem>> pasTijdenAan({
    required DateTime dag,
    required AgendaItem oudItem,
    required AgendaItem nieuwItem,
    required Map<String, List<AgendaItem>> itemsPerDag,
  }) {
    return AgendaBewerkService.bewerkItem(
      dag: dag,
      oudItem: oudItem,
      nieuwItem: nieuwItem,
      itemsPerDag: itemsPerDag,
    );
  }
}
