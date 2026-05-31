import '../Agenda/agenda_item.dart';
import '../Agenda/agenda_repository.dart';

class KlantenAgendaService {
  static Future<List<AgendaItem>> laadAfspraakKlantenUitAgenda() async {
    final itemsPerDag = await AgendaRepository.laadItems();

    final gevonden = <AgendaItem>[];
    final gebruikteNamen = <String>{};

    final dagEntries = itemsPerDag.entries.toList();

    dagEntries.sort((a, b) {
      final datumA = DateTime.tryParse(a.key);
      final datumB = DateTime.tryParse(b.key);

      if (datumA == null || datumB == null) return 0;

      return datumB.compareTo(datumA);
    });

    for (final entry in dagEntries) {
      for (final item in entry.value) {
        final naam = item.naamKlant.trim();

        if (naam.isEmpty) continue;

        if (item.type != 'afspraak') continue;

        final sleutel = naam.toLowerCase();

        if (gebruikteNamen.contains(sleutel)) continue;

        gebruikteNamen.add(sleutel);
        gevonden.add(item);
      }
    }

    return gevonden;
  }
}
