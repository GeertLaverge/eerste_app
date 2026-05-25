import 'agenda_filter_state.dart';
import 'agenda_item.dart';
import 'agenda_datum_helper.dart';
import 'agenda_filter_helper.dart';

class AgendaJaarMaandBreedte {
  static double bereken({
    required int jaar,
    required int maand,
    required Map<String, List<AgendaItem>> agendaItemsData,
    required AgendaFilterState actieveFilters,
  }) {
    const minimum = 150.0;
    const maximum = 900.0;

    double breedsteDag = minimum;

    final aantalDagen = DateTime(
      jaar,
      maand + 1,
      0,
    ).day;

    for (int dag = 1; dag <= aantalDagen; dag++) {
      final datum = DateTime(
        jaar,
        maand,
        dag,
      );

      final key = AgendaDatumHelper.datumKey(
        datum,
      );

      final items = agendaItemsData[key] ?? [];

      final zichtbaar = AgendaFilterHelper.gefilterdeItems(
            itemsPerDag: {
              key: items,
            },
            toonPlanning: actieveFilters.toonPlanning,
            toonOpvolging: actieveFilters.toonOpvolging,
            toonNadienst: actieveFilters.toonNadienst,
            toonAfspraak: actieveFilters.toonAfspraak,
            toonDagtaak: actieveFilters.toonDagtaak,
            toonVerlof: actieveFilters.toonVerlof,
            toonKraan: actieveFilters.toonKraan,
          )[key] ??
          [];

      for (final item in zichtbaar) {
        final tekst = '${item.tijdTekst} ${item.titel}';

        final rijBreedte = 28 + (tekst.length * 4.4);

        if (rijBreedte > breedsteDag) {
          breedsteDag = rijBreedte;
        }
      }
    }

    return breedsteDag.clamp(
      minimum,
      maximum,
    );
  }
}
