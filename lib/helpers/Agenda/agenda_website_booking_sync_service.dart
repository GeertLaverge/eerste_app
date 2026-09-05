import 'package:flutter/foundation.dart';

import '../website/thimaco_website_service.dart';
import 'agenda_item.dart';
import 'agenda_repository.dart';

class AgendaWebsiteBookingSyncService {
  static final ThimacoWebsiteService _websiteService = ThimacoWebsiteService();

  static Future<Map<String, List<AgendaItem>>> synchroniseerMaanden(
    Iterable<DateTime> maanden,
  ) async {
    final uniekeMaanden = <String, DateTime>{};

    for (final maand in maanden) {
      final sleutel =
          '${maand.year.toString().padLeft(4, '0')}-${maand.month.toString().padLeft(2, '0')}';
      uniekeMaanden[sleutel] = DateTime(maand.year, maand.month, 1);
    }

    final bookings = <WebsiteShowroomBooking>[];

    for (final maand in uniekeMaanden.values) {
      try {
        final data = await _websiteService
            .laadMaand(maand)
            .timeout(const Duration(seconds: 12));
        bookings.addAll(data.bookings);
      } catch (error) {
        debugPrint(
          'AgendaWebsiteBookingSyncService: websiteboekingen voor '
          '${maand.year}-${maand.month.toString().padLeft(2, '0')} '
          'konden niet worden geladen: $error',
        );
      }
    }

    var itemsPerDag = await AgendaRepository.laadItems();

    final bestaandeExternIds = itemsPerDag.values
        .expand((items) => items)
        .where((item) => item.isWebsiteShowroomAfspraak)
        .map((item) => item.externId.trim())
        .where((id) => id.isNotEmpty)
        .toSet();

    final bestaandeIds = itemsPerDag.values
        .expand((items) => items)
        .map((item) => item.id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();

    bookings.sort((a, b) {
      final datumVergelijking = a.datum.compareTo(b.datum);
      if (datumVergelijking != 0) {
        return datumVergelijking;
      }
      return a.startTijd.compareTo(b.startTijd);
    });

    for (final booking in bookings) {
      final externId = booking.id.trim();
      if (externId.isEmpty || bestaandeExternIds.contains(externId)) {
        continue;
      }

      final agendaId = _agendaItemId(externId);
      if (bestaandeIds.contains(agendaId)) {
        bestaandeExternIds.add(externId);
        continue;
      }

      final start = _tijdDelen(booking.startTijd);
      final einde = _tijdDelen(booking.eindTijd);

      if (start == null || einde == null) {
        debugPrint(
          'AgendaWebsiteBookingSyncService: ongeldige tijd voor '
          'websiteboeking $externId.',
        );
        continue;
      }

      final dag = DateTime(
        booking.datum.year,
        booking.datum.month,
        booking.datum.day,
      );

      final opmerkingen = <String>[
        if (booking.reference.trim().isNotEmpty)
          'Website-referentie: ${booking.reference.trim()}',
        if (booking.projecten.isNotEmpty)
          'Project: ${booking.projecten.join(' · ')}',
        if (booking.notitie.trim().isNotEmpty) booking.notitie.trim(),
      ].join('\n');

      final nu = DateTime.now().toUtc().toIso8601String();

      final item = AgendaItem(
        id: agendaId,
        updatedAt: nu,
        titel: 'Showroomadvies',
        type: 'afspraak',
        naamKlant: booking.klantNaam.trim(),
        gemeente: booking.locatie.trim(),
        gsm: booking.gsm.trim(),
        email: booking.email.trim(),
        opmerkingen: opmerkingen,
        volledigeDag: false,
        startUur: start.$1,
        startMinuut: start.$2,
        eindUur: einde.$1,
        eindMinuut: einde.$2,
        afspraakSoort: 'showroom',
        bron: 'website_showroom',
        externId: externId,
      );

      itemsPerDag = await AgendaRepository.voegToe(
        dag: dag,
        item: item,
        itemsPerDag: itemsPerDag,
      );

      bestaandeExternIds.add(externId);
      bestaandeIds.add(agendaId);
    }

    return AgendaRepository.laadItems();
  }

  static String _agendaItemId(String externId) {
    return 'website_showroom:$externId';
  }

  static (int, int)? _tijdDelen(String waarde) {
    final delen = waarde.trim().split(':');
    if (delen.length < 2) {
      return null;
    }

    final uur = int.tryParse(delen[0]);
    final minuut = int.tryParse(delen[1]);

    if (uur == null ||
        minuut == null ||
        uur < 0 ||
        uur > 23 ||
        minuut < 0 ||
        minuut > 59) {
      return null;
    }

    return (uur, minuut);
  }
}
