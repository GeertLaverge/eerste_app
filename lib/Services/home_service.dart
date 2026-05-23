import '../modellen/agenda_actie.dart';
import '../modellen/klant.dart';

class HomeService {
  static DateTime zonderTijd(DateTime datum) {
    return DateTime(datum.year, datum.month, datum.day);
  }

  static bool zelfdeDag(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static List<DagPlanningItem> dagplanningVandaag(List<Klant> klanten) {
    final vandaag = DateTime.now();
    final items = <DagPlanningItem>[];

    for (final klant in klanten) {
      for (final planning in klant.planningDagen) {
        if (zelfdeDag(planning.datum, vandaag)) {
          items.add(
            DagPlanningItem(
              klant: klant,
              startUur: planning.startUur,
              startMinuut: planning.startMinuut,
              eindUur: planning.eindUur,
              eindMinuut: planning.eindMinuut,
            ),
          );
        }
      }
    }

    items.sort((a, b) {
      final aMinuten = a.startUur * 60 + a.startMinuut;
      final bMinuten = b.startUur * 60 + b.startMinuut;

      return aMinuten.compareTo(bMinuten);
    });

    return items;
  }

  static DateTime? eerstePlanningDatumVanKlant(Klant klant) {
    if (klant.planningDagen.isEmpty) return null;

    final datums = klant.planningDagen.map((planning) {
      return zonderTijd(planning.datum);
    }).toList();

    datums.sort((a, b) => a.compareTo(b));

    return datums.first;
  }

  static DateTime? toonDatumVoorKlantTaak(Klant klant) {
    final heeftTaken = klant.klantTaken.any(
      (taak) => taak.tekst.trim().isNotEmpty,
    );

    if (!heeftTaken) return null;

    if (klant.klantTaakMoment == 'vrijeDatum') {
      return klant.klantTaakVrijeDatum == null
          ? null
          : zonderTijd(klant.klantTaakVrijeDatum!);
    }

    final eerstePlanning = eerstePlanningDatumVanKlant(klant);
    if (eerstePlanning == null) return null;

    if (klant.klantTaakMoment == 'eenDagEerder') {
      return eerstePlanning.subtract(const Duration(days: 1));
    }

    return eerstePlanning;
  }

  static List<Klant> klantTakenVandaag(List<Klant> klanten) {
    final vandaag = zonderTijd(DateTime.now());

    final taken = klanten.where((klant) {
      final toonDatum = toonDatumVoorKlantTaak(klant);
      if (toonDatum == null) return false;

      return toonDatum == vandaag;
    }).toList();

    taken.sort((a, b) {
      return a.klantnaam.toLowerCase().compareTo(
            b.klantnaam.toLowerCase(),
          );
    });

    return taken;
  }

  static List<KlantTaakVandaagItem> klantTaakItemsVandaag(
    List<Klant> klanten,
  ) {
    final vandaag = zonderTijd(DateTime.now());
    final items = <KlantTaakVandaagItem>[];

    for (final klant in klanten) {
      final toonDatum = toonDatumVoorKlantTaak(klant);

      if (toonDatum == null) continue;
      if (toonDatum != vandaag) continue;

      for (final taak in klant.klantTaken) {
        if (taak.tekst.trim().isEmpty) continue;

        items.add(
          KlantTaakVandaagItem(
            klant: klant,
            taak: taak,
          ),
        );
      }
    }

    items.sort((a, b) {
      if (a.taak.isAfgewerkt != b.taak.isAfgewerkt) {
        return a.taak.isAfgewerkt ? 1 : -1;
      }

      return a.klant.klantnaam.toLowerCase().compareTo(
            b.klant.klantnaam.toLowerCase(),
          );
    });

    return items;
  }

  static List<AgendaActie> dagtakenVandaag(List<AgendaActie> agendaActies) {
    final vandaag = zonderTijd(DateTime.now());

    final taken = agendaActies.where((actie) {
      if (!actie.toonOpDagtaak) return false;

      final actieDatum = zonderTijd(actie.datum);
      final verschil = actieDatum.difference(vandaag).inDays;

      return verschil >= 0 && verschil <= actie.dagenVoorafTonen;
    }).toList();

    taken.sort((a, b) {
      if (a.isAfgewerkt != b.isAfgewerkt) {
        return a.isAfgewerkt ? 1 : -1;
      }

      final aMinuten = (a.startUur ?? 0) * 60 + (a.startMinuut ?? 0);
      final bMinuten = (b.startUur ?? 0) * 60 + (b.startMinuut ?? 0);

      return aMinuten.compareTo(bMinuten);
    });

    return taken;
  }
}

class DagPlanningItem {
  final Klant klant;
  final int startUur;
  final int startMinuut;
  final int eindUur;
  final int eindMinuut;

  DagPlanningItem({
    required this.klant,
    required this.startUur,
    required this.startMinuut,
    required this.eindUur,
    required this.eindMinuut,
  });
}

class KlantTaakVandaagItem {
  final Klant klant;
  final KlantTaakItem taak;

  KlantTaakVandaagItem({
    required this.klant,
    required this.taak,
  });
}
