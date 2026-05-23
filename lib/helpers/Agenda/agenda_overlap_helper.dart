import 'agenda_item.dart';

class AgendaOverlapHelper {
  static bool heeftOverlap({
    required AgendaItem nieuwItem,
    required List<AgendaItem> bestaandeItems,
  }) {
    return overlapMelding(
          nieuwItem: nieuwItem,
          bestaandeItems: bestaandeItems,
        ) !=
        null;
  }

  static String? overlapMelding({
    required AgendaItem nieuwItem,
    required List<AgendaItem> bestaandeItems,
  }) {
    for (final bestaand in bestaandeItems) {
      if (!tijdenOverlappen(nieuwItem, bestaand)) {
        continue;
      }

      if (!magOverlappen(nieuwItem.type, bestaand.type)) {
        return '${nieuwItem.titel} overlapt met ${bestaand.titel}.';
      }
    }

    return null;
  }

  static bool tijdenOverlappen(
    AgendaItem a,
    AgendaItem b,
  ) {
    if (a.volledigeDag || b.volledigeDag) {
      return true;
    }

    if (!a.heeftTijd || !b.heeftTijd) {
      return false;
    }

    final startA = a.startMinuten;
    final eindeA = (a.eindUur! * 60) + a.eindMinuut!;

    final startB = b.startMinuten;
    final eindeB = (b.eindUur! * 60) + b.eindMinuut!;

    return startA < eindeB && startB < eindeA;
  }

  static bool magOverlappen(
    String typeA,
    String typeB,
  ) {
    // Zelfde type mag nooit overlappen.
    if (typeA == typeB) {
      return false;
    }

    // Verlof blokkeert de volledige dag.
    // Als er verlof staat, mag er niets anders bij.
    // Als er iets staat, mag verlof er niet bij.
    if (typeA == 'verlof' || typeB == 'verlof') {
      return false;
    }

    // Deze drie mogen onderling niet overlappen.
    const vasteTypes = [
      'planning',
      'opvolging',
      'nadienst',
    ];

    final aIsVast = vasteTypes.contains(typeA);
    final bIsVast = vasteTypes.contains(typeB);

    if (aIsVast && bIsVast) {
      return false;
    }

    // Afspraak, dagtaak en kraan mogen met andere types overlappen,
    // maar niet met zichzelf. Zelfde type is bovenaan al geblokkeerd.
    return true;
  }
}
