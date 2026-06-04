import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'Agenda/agenda_item.dart';
import 'Agenda/agenda_dagtaak_template.dart';
import 'sync/onedrive_sync_service.dart';

class AppStorage {
  static const String _agendaItemsNieuwKey = 'agenda_items_nieuw';
  static const String _dagtaakTemplatesKey = 'dagtaak_templates';
  static const String _klantenFichesKey = 'klanten_fiches';

  static Future<SharedPreferences> openBox() async {
    return SharedPreferences.getInstance();
  }

  static Future<void> _syncBackup() async {
    await OneDriveSyncService().uploadBackupOpAchtergrond();
  }

  // ------------------------------------------------------------
  // DAGTAAK TEMPLATES
  // ------------------------------------------------------------

  static Future<List<AgendaDagtaakTemplate>> laadDagtaakTemplates() async {
    final prefs = await openBox();
    final jsonString = prefs.getString(_dagtaakTemplatesKey);

    if (jsonString == null || jsonString.isEmpty) return [];

    final lijst = jsonDecode(jsonString) as List<dynamic>;

    return lijst
        .map(
          (item) =>
              AgendaDagtaakTemplate.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  static Future<void> bewaarDagtaakTemplates(
    List<AgendaDagtaakTemplate> templates,
  ) async {
    final prefs = await openBox();

    await prefs.setString(
      _dagtaakTemplatesKey,
      jsonEncode(templates.map((template) => template.toJson()).toList()),
    );

    await _syncBackup();
  }

  // ------------------------------------------------------------
  // AGENDA FILTERS
  // ------------------------------------------------------------

  static Future<void> bewaarAgendaFilters(
    Map<String, bool> waarden, {
    String soort = 'detail',
  }) async {
    final prefs = await openBox();

    for (final entry in waarden.entries) {
      await prefs.setBool(
        'agenda_zicht_${soort}_${entry.key}',
        entry.value,
      );
    }

    await _syncBackup();
  }

  static Future<Map<String, bool>> laadAgendaFilters({
    String soort = 'detail',
  }) async {
    final prefs = await openBox();

    return {
      'planningKlanten':
          prefs.getBool('agenda_zicht_${soort}_planningKlanten') ?? true,
      'opvolging': prefs.getBool('agenda_zicht_${soort}_opvolging') ?? true,
      'nadienst': prefs.getBool('agenda_zicht_${soort}_nadienst') ?? true,
      'dagTaken': prefs.getBool('agenda_zicht_${soort}_dagTaken') ?? true,
      'afspraken': prefs.getBool('agenda_zicht_${soort}_afspraken') ?? true,
      'vakantie': prefs.getBool('agenda_zicht_${soort}_vakantie') ?? true,
      'kraan': prefs.getBool('agenda_zicht_${soort}_kraan') ?? true,
    };
  }

  // ------------------------------------------------------------
  // NIEUWE AGENDA ITEMS
  // ------------------------------------------------------------

  static Future<Map<String, List<AgendaItem>>> laadAgendaItemsNieuw() async {
    final prefs = await openBox();
    final jsonString = prefs.getString(_agendaItemsNieuwKey);

    if (jsonString == null || jsonString.isEmpty) {
      return {};
    }

    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    return data.map((datumKey, lijst) {
      final items = (lijst as List<dynamic>)
          .map((item) => AgendaItem.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      return MapEntry(datumKey, items);
    });
  }

  static Future<void> bewaarAgendaItemsNieuw(
    Map<String, List<AgendaItem>> itemsPerDag,
  ) async {
    final prefs = await openBox();

    final data = itemsPerDag.map((datumKey, items) {
      return MapEntry(
        datumKey,
        items.map((item) => item.toJson()).toList(),
      );
    });

    await prefs.setString(
      _agendaItemsNieuwKey,
      jsonEncode(data),
    );

    await _syncBackup();
  }

  // ------------------------------------------------------------
  // KLANTENFICHES
  // ------------------------------------------------------------

  static Future<List<Map<String, dynamic>>> laadKlantenFiches() async {
    final prefs = await openBox();
    final jsonString = prefs.getString(_klantenFichesKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final lijst = jsonDecode(jsonString) as List<dynamic>;

    return lijst
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();
  }

  static Future<void> bewaarKlantenFiches(
    List<Map<String, dynamic>> klanten,
  ) async {
    final prefs = await openBox();

    await prefs.setString(
      _klantenFichesKey,
      jsonEncode(klanten),
    );

    await _syncBackup();
  }
}
