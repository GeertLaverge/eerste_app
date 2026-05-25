import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'Agenda/agenda_item.dart';
import 'Agenda/agenda_dagtaak_template.dart';

import '../modellen/agenda_actie.dart';
import '../modellen/agenda_actie_template.dart';
import '../modellen/klant.dart';
import '../modellen/leverancier.dart';
import '../modellen/notitie.dart';
import '../modellen/notitie_actie.dart';
import '../modellen/afspraak_klant.dart';

class AppStorage {
  static const String _klantenKey = 'klanten';
  static const String _leveranciersKey = 'leveranciers';
  static const String _vakantieDagenKey = 'vakantieDagen';
  static const String _agendaActiesKey = 'agendaActies';
  static const String _agendaActieTemplatesKey = 'agendaActieTemplates';
  static const String _notitiesKey = 'notities_bureau';
  static const String _notitieActiesKey = 'notitie_acties_bureau';
  static const String _afsprakenKey = 'afspraken_klanten';
  static const String _agendaItemsNieuwKey = 'agenda_items_nieuw';
  static const String _dagtaakTemplatesKey = 'dagtaak_templates';

  static Future<SharedPreferences> openBox() async {
    return SharedPreferences.getInstance();
  }

  static Future<List<AgendaDagtaakTemplate>> laadDagtaakTemplates() async {
    final prefs = await openBox();
    final jsonString = prefs.getString(_dagtaakTemplatesKey);

    if (jsonString == null || jsonString.isEmpty) return [];

    final lijst = jsonDecode(jsonString) as List<dynamic>;

    return lijst
        .map(
          (item) => AgendaDagtaakTemplate.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  static Future<void> bewaarDagtaakTemplates(
    List<AgendaDagtaakTemplate> templates,
  ) async {
    final prefs = await openBox();

    await prefs.setString(
      _dagtaakTemplatesKey,
      jsonEncode(
        templates.map((template) => template.toJson()).toList(),
      ),
    );
  }

  static Future<List<Klant>> laadKlanten() async {
    final prefs = await openBox();
    final jsonString = prefs.getString(_klantenKey);

    if (jsonString == null || jsonString.isEmpty) return [];

    final lijst = jsonDecode(jsonString) as List<dynamic>;

    return lijst
        .map((item) => Klant.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Future<void> bewaarKlanten(List<Klant> klanten) async {
    final prefs = await openBox();

    await prefs.setString(
      _klantenKey,
      jsonEncode(klanten.map((klant) => klant.toMap()).toList()),
    );
  }

  static Future<List<Leverancier>> laadLeveranciers() async {
    final prefs = await openBox();
    final jsonString = prefs.getString(_leveranciersKey);

    if (jsonString == null || jsonString.isEmpty) return [];

    final lijst = jsonDecode(jsonString) as List<dynamic>;

    return lijst
        .map((item) => Leverancier.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Future<void> bewaarLeveranciers(List<Leverancier> leveranciers) async {
    final prefs = await openBox();

    await prefs.setString(
      _leveranciersKey,
      jsonEncode(
        leveranciers.map((leverancier) => leverancier.toMap()).toList(),
      ),
    );
  }

  static Future<List<DateTime>> laadVakantieDagen() async {
    final prefs = await openBox();
    final jsonString = prefs.getString(_vakantieDagenKey);

    if (jsonString == null || jsonString.isEmpty) return [];

    final lijst = jsonDecode(jsonString) as List<dynamic>;

    return lijst.map((item) => DateTime.parse(item.toString())).toList();
  }

  static Future<void> bewaarVakantieDagen(List<DateTime> vakantieDagen) async {
    final prefs = await openBox();

    await prefs.setString(
      _vakantieDagenKey,
      jsonEncode(
        vakantieDagen.map((datum) => datum.toIso8601String()).toList(),
      ),
    );
  }

  static Map<String, dynamic> _agendaActieToMap(AgendaActie actie) {
    return {
      'id': actie.id,
      'titel': actie.titel,
      'typeActie': actie.typeActie,
      'datum': actie.datum.toIso8601String(),
      'toonOpDagtaak': actie.toonOpDagtaak,
      'dagenVoorafTonen': actie.dagenVoorafTonen,
      'weergaveType': actie.weergaveType,
      'kleurNaam': actie.kleurNaam,
      'icoonNaam': actie.icoonNaam,
      'startUur': actie.startUur,
      'startMinuut': actie.startMinuut,
      'eindUur': actie.eindUur,
      'eindMinuut': actie.eindMinuut,
      'opmerkingen': actie.opmerkingen,
    };
  }

  static AgendaActie _agendaActieFromMap(Map<String, dynamic> map) {
    return AgendaActie(
      id: map['id'] ?? '',
      titel: map['titel'] ?? '',
      typeActie: map['typeActie'] ?? '',
      datum:
          map['datum'] == null ? DateTime.now() : DateTime.parse(map['datum']),
      toonOpDagtaak: map['toonOpDagtaak'] ?? false,
      dagenVoorafTonen: map['dagenVoorafTonen'] ?? 0,
      weergaveType: map['weergaveType'] ?? 'symbool',
      kleurNaam: map['kleurNaam'] ?? 'groen',
      icoonNaam: map['icoonNaam'] ?? 'delete_sweep',
      startUur: map['startUur'],
      startMinuut: map['startMinuut'],
      eindUur: map['eindUur'],
      eindMinuut: map['eindMinuut'],
      opmerkingen: map['opmerkingen'] ?? '',
    );
  }

  static Future<List<AgendaActie>> laadAgendaActies() async {
    final prefs = await openBox();
    final jsonString = prefs.getString(_agendaActiesKey);

    if (jsonString == null || jsonString.isEmpty) return [];

    final lijst = jsonDecode(jsonString) as List<dynamic>;

    return lijst
        .map((item) => _agendaActieFromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Future<void> bewaarAgendaActies(List<AgendaActie> agendaActies) async {
    final prefs = await openBox();

    await prefs.setString(
      _agendaActiesKey,
      jsonEncode(agendaActies.map(_agendaActieToMap).toList()),
    );
  }

  static Future<void> bewaarAfsprakenKlanten(
    List<AfspraakKlant> afspraken,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final lijst = afspraken.map((e) => jsonEncode(e.toJson())).toList();

    await prefs.setStringList(_afsprakenKey, lijst);
  }

  static Future<List<AfspraakKlant>> laadAfsprakenKlanten() async {
    final prefs = await SharedPreferences.getInstance();

    final lijst = prefs.getStringList(_afsprakenKey) ?? [];

    return lijst.map((e) => AfspraakKlant.fromJson(jsonDecode(e))).toList();
  }

  static Map<String, dynamic> _templateToMap(AgendaActieTemplate template) {
    return {
      'id': template.id,
      'naam': template.naam,
      'icoonNaam': template.icoonNaam,
      'kleurNaam': template.kleurNaam,
    };
  }

  static AgendaActieTemplate _templateFromMap(Map<String, dynamic> map) {
    return AgendaActieTemplate(
      id: map['id'] ?? '',
      naam: map['naam'] ?? '',
      icoonNaam: map['icoonNaam'] ?? 'delete_sweep',
      kleurNaam: map['kleurNaam'] ?? 'groen',
    );
  }

  static Future<List<AgendaActieTemplate>> laadAgendaActieTemplates() async {
    final prefs = await openBox();
    final jsonString = prefs.getString(_agendaActieTemplatesKey);

    if (jsonString == null || jsonString.isEmpty) return [];

    final lijst = jsonDecode(jsonString) as List<dynamic>;

    return lijst
        .map((item) => _templateFromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Future<void> bewaarAgendaActieTemplates(
    List<AgendaActieTemplate> templates,
  ) async {
    final prefs = await openBox();

    await prefs.setString(
      _agendaActieTemplatesKey,
      jsonEncode(templates.map(_templateToMap).toList()),
    );
  }

  static Future<List<Notitie>> laadNotities() async {
    final prefs = await openBox();
    final jsonString = prefs.getString(_notitiesKey);

    if (jsonString == null || jsonString.isEmpty) return [];

    final lijst = jsonDecode(jsonString) as List<dynamic>;

    return lijst
        .map((item) => Notitie.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Future<void> bewaarNotities(List<Notitie> notities) async {
    final prefs = await openBox();

    await prefs.setString(
      _notitiesKey,
      jsonEncode(notities.map((n) => n.toMap()).toList()),
    );
  }

  static Future<List<NotitieActie>> laadNotitieActies() async {
    final prefs = await openBox();
    final jsonString = prefs.getString(_notitieActiesKey);

    if (jsonString == null || jsonString.isEmpty) return [];

    final lijst = jsonDecode(jsonString) as List<dynamic>;

    return lijst
        .map((item) => NotitieActie.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Future<void> bewaarNotitieActies(List<NotitieActie> acties) async {
    final prefs = await openBox();

    await prefs.setString(
      _notitieActiesKey,
      jsonEncode(acties.map((a) => a.toMap()).toList()),
    );
  }

  static Future<void> bewaarAgendaFilters(
    Map<String, bool> waarden,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    for (final entry in waarden.entries) {
      await prefs.setBool(
        'agenda_zicht_${entry.key}',
        entry.value,
      );
    }
  }

  static Future<Map<String, bool>> laadAgendaFilters() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'planningKlanten': prefs.getBool('agenda_zicht_planningKlanten') ?? true,
      'opvolging': prefs.getBool('agenda_zicht_opvolging') ?? true,
      'nadienst': prefs.getBool('agenda_zicht_nadienst') ?? true,
      'dagTaken': prefs.getBool('agenda_zicht_dagTaken') ?? true,
      'afspraken': prefs.getBool('agenda_zicht_afspraken') ?? true,
      'vakantie': prefs.getBool('agenda_zicht_vakantie') ?? true,
      'kraan': prefs.getBool('agenda_zicht_kraan') ?? true,
    };
  }

  static Future<Map<String, List<AgendaItem>>> laadAgendaItemsNieuw() async {
    final prefs = await openBox();
    final jsonString = prefs.getString(_agendaItemsNieuwKey);

    if (jsonString == null || jsonString.isEmpty) {
      return {};
    }

    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    return data.map((datumKey, lijst) {
      final items = (lijst as List<dynamic>)
          .map(
            (item) => AgendaItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
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
  }

  static Future<void> bewaarAlles({
    required List<Klant> klanten,
    required List<Leverancier> leveranciers,
    required List<DateTime> vakantieDagen,
  }) async {
    await bewaarKlanten(klanten);
    await bewaarLeveranciers(leveranciers);
    await bewaarVakantieDagen(vakantieDagen);
  }
}
