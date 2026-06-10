import '../app_storage.dart';
import '../klanten/fiche/klantenfiche_repository.dart';

class HomePlanningHelper {
  static Future<List<dynamic>> planningVandaag() async {
    final data = await AppStorage.laadAgendaItemsNieuw();
    final sleutel = _sleutelVandaag();

    final items = data[sleutel] ?? [];

    final planning = items.where((item) {
      if (item.isVerwijderd) return false;

      return item.type == 'planning' ||
          item.type == 'opvolging' ||
          item.type == 'afspraak' ||
          item.type == 'verlof';
    }).toList();

    planning.sort((a, b) {
      if (a.type == 'planning' && b.type != 'planning') return -1;
      if (a.type != 'planning' && b.type == 'planning') return 1;

      return a.startMinuten.compareTo(b.startMinuten);
    });

    return planning;
  }

  static Future<List<dynamic>> klantTakenVandaag() async {
    final planning = await planningVandaag();
    final fiches = await KlantenficheRepository.laadKlantenFiches();

    final klantenOpPlanning = planning.where((item) {
      if (item.isVerwijderd) return false;

      return (item.type == 'planning' || item.type == 'opvolging') &&
          item.naamKlant.toString().trim().isNotEmpty;
    }).toList();

    final resultaat = <dynamic>[];

    for (final item in klantenOpPlanning) {
      final naam = item.naamKlant.toString().trim().toLowerCase();

      final fiche = fiches.where((f) {
        return f.naam.trim().toLowerCase() == naam;
      }).toList();

      if (fiche.isEmpty) continue;

      final klantenFiche = fiche.first;

      if (klantenFiche.klantTaken.isEmpty) continue;

      if (klantenFiche.klantTakenAfgewerktOp.isNotEmpty) {
        final afwerkDatum = DateTime.tryParse(
          klantenFiche.klantTakenAfgewerktOp,
        );

        if (afwerkDatum != null) {
          final vandaag = DateTime.now();

          final enkelVandaag = DateTime(
            vandaag.year,
            vandaag.month,
            vandaag.day,
          );

          if (afwerkDatum.isBefore(enkelVandaag)) {
            continue;
          }
        }
      }

      resultaat.add(klantenFiche);
    }

    return resultaat;
  }

  static Future<List<dynamic>> dagTakenVandaag() async {
    final data = await AppStorage.laadAgendaItemsNieuw();
    final vandaagSleutel = _sleutelVandaag();

    final resultaat = <dynamic>[];

    data.forEach((datumKey, items) {
      for (final item in items) {
        if (item.isVerwijderd) continue;
        if (item.type != 'dagtaak') continue;

        final toonDatum = _homeDatumVoorItem(
          agendaDatumKey: datumKey,
          item: item,
        );

        if (toonDatum == vandaagSleutel) {
          resultaat.add(item);
        }
      }
    });

    return resultaat;
  }

  static String _homeDatumVoorItem({
    required String agendaDatumKey,
    required dynamic item,
  }) {
    if (item.homeWeergaveType == 'dagenVooraf') {
      final agendaDatum = DateTime.tryParse(agendaDatumKey);

      if (agendaDatum == null) {
        return agendaDatumKey;
      }

      final homeDatum = agendaDatum.subtract(
        Duration(
          days: item.dagenVooraf,
        ),
      );

      return _datumKey(homeDatum);
    }

    if (item.homeWeergaveType == 'datum' && item.homeDatum.isNotEmpty) {
      return item.homeDatum;
    }

    return agendaDatumKey;
  }

  static String _sleutelVandaag() {
    return _datumKey(DateTime.now());
  }

  static String _datumKey(DateTime datum) {
    return '${datum.year.toString().padLeft(4, '0')}-'
        '${datum.month.toString().padLeft(2, '0')}-'
        '${datum.day.toString().padLeft(2, '0')}';
  }
}
