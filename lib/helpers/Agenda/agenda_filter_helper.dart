import 'agenda_item.dart';
import 'agenda_overlap_helper.dart';

class AgendaFilterHelper {
  static bool itemMagTonen({
    required AgendaItem item,
    required bool toonPlanning,
    required bool toonOpvolging,
    required bool toonNadienst,
    required bool toonAfspraak,
    required bool toonDagtaak,
    required bool toonVerlof,
    required bool toonKraan,
  }) {
    switch (item.type) {
      case 'planning':
        return toonPlanning;
      case 'opvolging':
        return toonOpvolging;
      case 'nadienst':
        return toonNadienst;
      case 'afspraak':
        return toonAfspraak;
      case 'dagtaak':
        return toonDagtaak;
      case 'verlof':
        return toonVerlof;
      case 'kraan':
        return toonKraan;
      default:
        return true;
    }
  }

  static Map<String, List<AgendaItem>> gefilterdeItems({
    required Map<String, List<AgendaItem>> itemsPerDag,
    required bool toonPlanning,
    required bool toonOpvolging,
    required bool toonNadienst,
    required bool toonAfspraak,
    required bool toonDagtaak,
    required bool toonVerlof,
    required bool toonKraan,
  }) {
    final resultaat = <String, List<AgendaItem>>{};

    itemsPerDag.forEach((datumKey, items) {
      final zichtbareItems = items.where((item) {
        return itemMagTonen(
          item: item,
          toonPlanning: toonPlanning,
          toonOpvolging: toonOpvolging,
          toonNadienst: toonNadienst,
          toonAfspraak: toonAfspraak,
          toonDagtaak: toonDagtaak,
          toonVerlof: toonVerlof,
          toonKraan: toonKraan,
        );
      }).toList();

      final itemsMetOverlap = zichtbareItems.map((huidig) {
        final andereItems =
            zichtbareItems.where((item) => item != huidig).toList();

        final overlap = AgendaOverlapHelper.heeftOverlap(
          nieuwItem: huidig,
          bestaandeItems: andereItems,
        );

        return huidig.copyWith(
          heeftOverlap: overlap,
        );
      }).toList();

      itemsMetOverlap.sort(
        (a, b) => a.startMinuten.compareTo(b.startMinuten),
      );

      if (itemsMetOverlap.isNotEmpty) {
        resultaat[datumKey] = itemsMetOverlap;
      }
    });

    return resultaat;
  }
}
