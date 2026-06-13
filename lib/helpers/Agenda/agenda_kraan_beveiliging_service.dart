import 'agenda_datum_helper.dart';
import 'agenda_item.dart';

class AgendaKraanBeveiligingService {
  static bool _zelfdeKlant(AgendaItem a, AgendaItem b) {
    final aNr = a.klantNr.trim();
    final bNr = b.klantNr.trim();

    if (aNr.isNotEmpty && bNr.isNotEmpty && aNr == bNr) {
      return true;
    }

    final aNaam = a.naamKlant.trim().toLowerCase();
    final bNaam = b.naamKlant.trim().toLowerCase();

    return aNaam.isNotEmpty && bNaam.isNotEmpty && aNaam == bNaam;
  }

  static bool _isKlantPlanning(AgendaItem item) {
    return item.type == 'planning' ||
        item.type == 'opvolging' ||
        item.type == 'nadienst' ||
        item.type == 'afspraak';
  }

  static String? controleerKraan({
    required DateTime dag,
    required AgendaItem kraanItem,
    required Map<String, List<AgendaItem>> itemsPerDag,
  }) {
    if (kraanItem.type != 'kraan') return null;

    if (!kraanItem.heeftTijd) {
      return 'Kraan moet een begin- en eindtijd hebben.';
    }

    final key = AgendaDatumHelper.datumKey(dag);
    final itemsOpDag = itemsPerDag[key] ?? [];

    final klantPlanningen = itemsOpDag.where((item) {
      return !item.isVerwijderd &&
          _isKlantPlanning(item) &&
          _zelfdeKlant(item, kraanItem) &&
          item.heeftTijd;
    }).toList();

    if (klantPlanningen.isEmpty) {
      return 'Kraan kan enkel op een dag waarop de klant ingepland is.';
    }

    final kraanStart = kraanItem.startMinuten;
    final kraanEind = (kraanItem.eindUur! * 60) + kraanItem.eindMinuut!;

    final pastBinnenPlanning = klantPlanningen.any((planning) {
      final planningStart = planning.startMinuten;
      final planningEind = (planning.eindUur! * 60) + planning.eindMinuut!;

      return kraanStart >= planningStart && kraanEind <= planningEind;
    });

    if (!pastBinnenPlanning) {
      return 'Kraan moet binnen de uren van de klantplanning vallen.';
    }

    return null;
  }
}
