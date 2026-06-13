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

  static String klantSleutel(AgendaItem item) {
    final klantNr = item.klantNr.trim().toLowerCase();

    if (klantNr.isNotEmpty) return 'nr:$klantNr';

    final naam = item.naamKlant.trim().toLowerCase();

    if (naam.isNotEmpty) return 'naam:$naam';

    return 'titel:${item.titel.trim().toLowerCase()}';
  }

  static Map<String, String> eersteKraanWaarschuwingPerKlant(
    Map<String, List<AgendaItem>> itemsPerDag,
  ) {
    final eersteDatumPerKlant = <String, String>{};

    final datums = itemsPerDag.keys.toList()..sort();

    for (final datumKey in datums) {
      final items = itemsPerDag[datumKey] ?? [];

      for (final item in items) {
        if (item.isVerwijderd) continue;
        if (!item.kraanNodig) continue;
        if (item.kraanIngepland) continue;
        if (item.type == 'kraan') continue;

        final sleutel = klantSleutel(item);

        eersteDatumPerKlant.putIfAbsent(
          sleutel,
          () => datumKey,
        );
      }
    }

    return eersteDatumPerKlant;
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
    final eersteKraanDatum = eersteKraanWaarschuwingPerKlant(
      itemsPerDag,
    );

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
      }).map((item) {
        final sleutel = klantSleutel(item);
        final magKraanWaarschuwingTonen = item.kraanNodig &&
            !item.kraanIngepland &&
            item.type != 'kraan' &&
            eersteKraanDatum[sleutel] == datumKey;

        return item.copyWith(
          kraanNodig: magKraanWaarschuwingTonen,
          kraanIngepland: item.kraanIngepland,
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
