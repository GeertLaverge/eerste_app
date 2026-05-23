import 'agenda_datum_helper.dart';
import 'agenda_item.dart';

class AgendaTestData {
  static Map<String, List<AgendaItem>> get items {
    final nu = DateTime.now();

    final dag1 = DateTime(nu.year, nu.month, 5);
    final dag2 = DateTime(nu.year, nu.month, 6);
    final dag3 = DateTime(nu.year, nu.month, 7);
    final dag4 = DateTime(nu.year, nu.month, 8);

    return {
      AgendaDatumHelper.datumKey(dag1): [
        AgendaItem(
          titel: 'Planning hele dag',
          type: 'planning',
          volledigeDag: true,
        ),
        AgendaItem(
          titel: 'Afspraak hele dag',
          type: 'afspraak',
          volledigeDag: true,
        ),
      ],
      AgendaDatumHelper.datumKey(dag2): [
        AgendaItem(
          titel: 'Opvolging hele dag',
          type: 'opvolging',
          volledigeDag: true,
        ),
        AgendaItem(
          titel: 'Dagtaak hele dag',
          type: 'dagtaak',
          volledigeDag: true,
        ),
      ],
      AgendaDatumHelper.datumKey(dag3): [
        AgendaItem(
          titel: 'Nadienst hele dag',
          type: 'nadienst',
          volledigeDag: true,
        ),
        AgendaItem(
          titel: 'Kraan hele dag',
          type: 'kraan',
          volledigeDag: true,
        ),
      ],
      AgendaDatumHelper.datumKey(dag4): [
        AgendaItem(
          titel: 'Verlof hele dag',
          type: 'verlof',
          volledigeDag: true,
        ),
        AgendaItem(
          titel: 'Dagtaak 2 hele dag',
          type: 'dagtaak',
          volledigeDag: true,
        ),
      ],
    };
  }
}
