import '../app_storage.dart';

class HomePlanningHelper {
  static Future<List<dynamic>> planningVandaag() async {
    final data = await AppStorage.laadAgendaItemsNieuw();
    final sleutel = _sleutelVandaag();

    final items = data[sleutel] ?? [];

    return items.where((item) {
      return item.type == 'afspraak' || item.type == 'verlof';
    }).toList();
  }

  static Future<List<dynamic>> dagTakenVandaag() async {
    final data = await AppStorage.laadAgendaItemsNieuw();
    final vandaagSleutel = _sleutelVandaag();

    final resultaat = <dynamic>[];

    data.forEach((datumKey, items) {
      for (final item in items) {
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
