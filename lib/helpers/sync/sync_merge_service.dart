import '../Agenda/agenda_item.dart';
import '../klanten/fiche/klantenfiche_model.dart';

class SyncMergeService {
  static List<AgendaItem> mergeAgendaItems(
    List<AgendaItem> lokaal,
    List<AgendaItem> cloud,
  ) {
    final resultaat = <String, AgendaItem>{};

    for (final item in [...lokaal, ...cloud]) {
      final key = item.syncId;

      if (!resultaat.containsKey(key)) {
        resultaat[key] = item;
        continue;
      }

      final bestaand = resultaat[key]!;

      final bestaandDatum = DateTime.tryParse(
        bestaand.updatedAt,
      );

      final nieuwDatum = DateTime.tryParse(
        item.updatedAt,
      );

      if (bestaandDatum == null && nieuwDatum != null) {
        resultaat[key] = item;
        continue;
      }

      if (bestaandDatum != null &&
          nieuwDatum != null &&
          nieuwDatum.isAfter(bestaandDatum)) {
        resultaat[key] = item;
      }
    }

    return resultaat.values.where((item) {
      return !item.isVerwijderd;
    }).toList();
  }

  static Map<String, List<AgendaItem>> mergeAgendaMap(
    Map<String, List<AgendaItem>> lokaal,
    Map<String, List<AgendaItem>> cloud,
  ) {
    final alleDatums = <String>{
      ...lokaal.keys,
      ...cloud.keys,
    };

    final resultaat = <String, List<AgendaItem>>{};

    for (final datum in alleDatums) {
      final merged = mergeAgendaItems(
        lokaal[datum] ?? [],
        cloud[datum] ?? [],
      );

      if (merged.isNotEmpty) {
        resultaat[datum] = merged;
      }
    }

    return resultaat;
  }

  static List<KlantenficheModel> mergeKlantenFiches(
    List<KlantenficheModel> lokaal,
    List<KlantenficheModel> cloud,
  ) {
    final resultaat = <String, KlantenficheModel>{};

    for (final fiche in [...lokaal, ...cloud]) {
      final key = fiche.id;

      if (!resultaat.containsKey(key)) {
        resultaat[key] = fiche;
        continue;
      }

      final bestaand = resultaat[key]!;

      final bestaandDatum = DateTime.tryParse(
        bestaand.updatedAt,
      );

      final nieuwDatum = DateTime.tryParse(
        fiche.updatedAt,
      );

      if (bestaandDatum == null && nieuwDatum != null) {
        resultaat[key] = fiche;
        continue;
      }

      if (bestaandDatum != null &&
          nieuwDatum != null &&
          nieuwDatum.isAfter(bestaandDatum)) {
        resultaat[key] = fiche;
      }
    }

    return resultaat.values.where((fiche) {
      return fiche.deletedAt.trim().isEmpty;
    }).toList();
  }
}
