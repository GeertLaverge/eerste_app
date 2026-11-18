// THIMACO-CONTROLE: VERLOF-WEBSITE-BLOKKERINGEN-20261105
import 'package:flutter/foundation.dart';

import '../website/thimaco_website_service.dart';
import 'agenda_item.dart';

class AgendaWebsiteSyncService {
  static final ThimacoWebsiteService _websiteService = ThimacoWebsiteService();

  /// Zowel blauwe afspraken als verlof blokkeren de boekbare tijd.
  /// Bij verlof kan de gebruiker expliciet de toonzaal open laten.
  static bool _blokkeertWebsite(AgendaItem item) {
    if (item.isVerwijderd || item.isWebsiteShowroomAfspraak) {
      return false;
    }
    final type = item.type.trim().toLowerCase();
    if (type == 'afspraak') return true;
    if (type == 'verlof') return !item.toonzaalTochOpen;
    return false;
  }

  static bool _isWebsiteRelevant(AgendaItem item) {
    final type = item.type.trim().toLowerCase();
    return (type == 'afspraak' || type == 'verlof') &&
        !item.isWebsiteShowroomAfspraak;
  }

  static String _datumKey(DateTime datum) {
    return '${datum.year.toString().padLeft(4, '0')}-'
        '${datum.month.toString().padLeft(2, '0')}-'
        '${datum.day.toString().padLeft(2, '0')}';
  }

  static String _websiteAgendaItemId(DateTime dag, AgendaItem item) {
    final vasteId = item.id.trim();
    if (vasteId.isNotEmpty) {
      return vasteId;
    }

    // Alleen voor zeer oude agenda-items zonder vaste id.
    // De datum wordt toegevoegd zodat dezelfde legacy-afspraak op twee
    // verschillende dagen niet dezelfde websiteblokkering krijgt.
    final legacy = 'legacy:${_datumKey(dag)}:${item.syncId}';
    if (legacy.length <= 200) {
      return legacy;
    }

    return 'legacy:${_datumKey(dag)}:${_stabieleHash(legacy)}';
  }

  static String _stabieleHash(String value) {
    var hash = 0x811C9DC5;

    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }

    return hash.toRadixString(16).padLeft(8, '0');
  }

  static ({int startMinuut, int eindMinuut})? _blokTijden(AgendaItem item) {
    if (item.volledigeDag) {
      return (startMinuut: 0, eindMinuut: 1440);
    }

    if (!item.heeftTijd) {
      return null;
    }

    final start = item.startMinuten;
    final eind = item.eindMinuten;

    if (start < 0 || eind > 1440 || eind <= start) {
      return null;
    }

    return (startMinuut: start, eindMinuut: eind);
  }

  static Future<void> synchroniseerAfspraak({
    required DateTime dag,
    required AgendaItem item,
  }) async {
    if (!_blokkeertWebsite(item)) {
      return;
    }

    final tijden = _blokTijden(item);
    if (tijden == null) {
      return;
    }

    final agendaItemId = _websiteAgendaItemId(dag, item);

    try {
      await _websiteService
          .bewaarAgendaBlokkering(
            agendaItemId: agendaItemId,
            datum: dag,
            startMinuut: tijden.startMinuut,
            eindMinuut: tijden.eindMinuut,
          )
          .timeout(const Duration(seconds: 12));
    } catch (error) {
      // De lokale agenda is op dit moment al veilig opgeslagen.
      // Een tijdelijke website-/internetfout mag die opslag nooit terugdraaien.
      debugPrint(
        'AgendaWebsiteSyncService: websiteblokkering niet bijgewerkt: $error',
      );
    }
  }

  static Future<void> verwijderAfspraak({
    required DateTime dag,
    required AgendaItem item,
  }) async {
    if (!_isWebsiteRelevant(item)) {
      return;
    }

    final agendaItemId = _websiteAgendaItemId(dag, item);

    try {
      await _websiteService
          .verwijderAgendaBlokkering(agendaItemId)
          .timeout(const Duration(seconds: 12));
    } catch (error) {
      debugPrint(
        'AgendaWebsiteSyncService: websiteblokkering niet verwijderd: $error',
      );
    }
  }

  static Future<void> synchroniseerBewerking({
    required DateTime dag,
    required AgendaItem oudItem,
    required AgendaItem nieuwItem,
  }) async {
    final oudWasBlauw = _blokkeertWebsite(oudItem);
    final nieuwIsBlauw = _blokkeertWebsite(nieuwItem);

    if (oudWasBlauw) {
      final oudeId = _websiteAgendaItemId(dag, oudItem);
      final nieuweId = _websiteAgendaItemId(dag, nieuwItem);

      if (!nieuwIsBlauw || oudeId != nieuweId) {
        await verwijderAfspraak(dag: dag, item: oudItem);
      }
    }

    if (nieuwIsBlauw) {
      await synchroniseerAfspraak(dag: dag, item: nieuwItem);
    }
  }

  static Future<void> synchroniseerVerplaatsing({
    required DateTime oudeDag,
    required DateTime nieuweDag,
    required AgendaItem item,
  }) async {
    if (!_blokkeertWebsite(item)) {
      // Een open-toonzaal-verlof mag geen oude blokkering achterlaten.
      if (_isWebsiteRelevant(item)) {
        await verwijderAfspraak(dag: oudeDag, item: item);
      }
      return;
    }

    final oudeId = _websiteAgendaItemId(oudeDag, item);
    final nieuweId = _websiteAgendaItemId(nieuweDag, item);

    // Nieuwe agenda-items hebben een vaste id; een upsert verplaatst dan
    // gewoon dezelfde websiteblokkering. Alleen legacy-items zonder id
    // krijgen door de datum een andere sleutel.
    if (oudeId != nieuweId) {
      await verwijderAfspraak(dag: oudeDag, item: item);
    }

    await synchroniseerAfspraak(dag: nieuweDag, item: item);
  }
}
