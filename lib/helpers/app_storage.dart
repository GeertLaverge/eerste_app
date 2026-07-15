import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'Agenda/agenda_dagtaak_template.dart';
import 'Agenda/agenda_item.dart';
import 'sync/onedrive_sync_service.dart';

import '../helpers/notities/notitie_actie_model.dart';
import '../helpers/notities/notitie_model.dart';
import 'opmeting/raam/opmeting_raam_keuzemenu_model.dart';
import 'opmeting/raam/opmeting_raam_opvulling_model.dart';
import 'opmeting/overzicht/opmeting_overzicht_model.dart';

class AppStorage {
  static const String _agendaItemsNieuwKey = 'agenda_items_nieuw';

  static const String _dagtaakTemplatesKey = 'dagtaak_templates';

  static const String _klantenFichesKey = 'klanten_fiches';

  static const String _notitiesKey = 'thimaco_notities';

  static const String _notitieActiesKey = 'thimaco_notitie_acties';

  static const String _opmetingRaamOpvullingenKey = 'opmeting_raam_opvullingen';

  static const String _opmetingRaamKeuzemenusKey = 'opmeting_raam_keuzemenus';

  static const String _opmetingRaamKeuzemenusAluKey =
      'opmeting_raam_keuzemenus_alu';

  static const String _opmetingDeurKeuzemenusPvcKey =
      'opmeting_deur_keuzemenus_pvc';

  static const String _opmetingDeurKeuzemenusAluKey =
      'opmeting_deur_keuzemenus_alu';

  static const String _opmetingenKey = 'thimaco_opmetingen';

  static Future<SharedPreferences> openBox() async {
    return SharedPreferences.getInstance();
  }

  static Future<void> _syncBackup() async {
    await OneDriveSyncService.registreerLokaleWijziging();
    OneDriveSyncService().uploadBackupOpAchtergrond();
  }

  // ------------------------------------------------------------
  // DAGTAAK TEMPLATES
  // ------------------------------------------------------------

  static Future<List<AgendaDagtaakTemplate>> laadDagtaakTemplates() async {
    final prefs = await openBox();

    final jsonString = prefs.getString(_dagtaakTemplatesKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

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
      await prefs.setBool('agenda_zicht_${soort}_${entry.key}', entry.value);
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

  static Map<String, List<AgendaItem>> _decodeAgendaItems(String? jsonString) {
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

  static String encodeAgendaItemsVoorSync(
    Map<String, List<AgendaItem>> itemsPerDag,
  ) {
    final data = itemsPerDag.map((datumKey, items) {
      return MapEntry(datumKey, items.map((item) => item.toJson()).toList());
    });

    return jsonEncode(data);
  }

  static Future<Map<String, List<AgendaItem>>>
  laadAgendaItemsNieuwVoorSync() async {
    final prefs = await openBox();

    return _decodeAgendaItems(prefs.getString(_agendaItemsNieuwKey));
  }

  static Future<Map<String, List<AgendaItem>>> laadAgendaItemsNieuw() async {
    final data = await laadAgendaItemsNieuwVoorSync();

    final zichtbaar = <String, List<AgendaItem>>{};

    data.forEach((datumKey, items) {
      final zichtbareItems = items.where((item) {
        return !item.isVerwijderd;
      }).toList();

      if (zichtbareItems.isNotEmpty) {
        zichtbaar[datumKey] = zichtbareItems;
      }
    });

    return zichtbaar;
  }

  static Future<void> bewaarAgendaItemsNieuw(
    Map<String, List<AgendaItem>> itemsPerDag,
  ) async {
    final prefs = await openBox();

    await prefs.setString(
      _agendaItemsNieuwKey,
      encodeAgendaItemsVoorSync(itemsPerDag),
    );

    await _syncBackup();
  }

  static Future<void> bewaarAgendaItemsNieuwVoorSync(
    Map<String, List<AgendaItem>> itemsPerDag,
  ) async {
    final prefs = await openBox();

    await prefs.setString(
      _agendaItemsNieuwKey,
      encodeAgendaItemsVoorSync(itemsPerDag),
    );
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

    return lijst.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  static Future<void> bewaarKlantenFiches(
    List<Map<String, dynamic>> klanten,
  ) async {
    final prefs = await openBox();

    await prefs.setString(_klantenFichesKey, jsonEncode(klanten));

    await _syncBackup();
  }

  static Future<void> bewaarKlantenFichesVoorSync(
    List<Map<String, dynamic>> klanten,
  ) async {
    final prefs = await openBox();

    await prefs.setString(_klantenFichesKey, jsonEncode(klanten));
  }

  // ------------------------------------------------------------
  // NOTITIES
  // ------------------------------------------------------------

  static Future<void> bewaarNotities(List<NotitieModel> notities) async {
    final prefs = await openBox();

    await prefs.setString(
      _notitiesKey,
      jsonEncode(notities.map((notitie) => notitie.toJson()).toList()),
    );

    await _syncBackup();
  }

  static Future<List<NotitieModel>> laadNotities() async {
    final prefs = await openBox();

    final jsonString = prefs.getString(_notitiesKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final lijst = jsonDecode(jsonString) as List<dynamic>;

    return lijst
        .map((item) => NotitieModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Future<void> bewaarNotitieActies(
    List<NotitieActieModel> acties,
  ) async {
    final prefs = await openBox();

    await prefs.setString(
      _notitieActiesKey,
      jsonEncode(acties.map((actie) => actie.toJson()).toList()),
    );

    await _syncBackup();
  }

  static Future<List<NotitieActieModel>> laadNotitieActies() async {
    final prefs = await openBox();

    final jsonString = prefs.getString(_notitieActiesKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final lijst = jsonDecode(jsonString) as List<dynamic>;

    return lijst
        .map(
          (item) => NotitieActieModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  // ------------------------------------------------------------
  // OPMETING RAAM - OPVULLINGEN
  // ------------------------------------------------------------

  static Future<List<OpmetingRaamOpvullingModel>>
  laadOpmetingRaamOpvullingen() async {
    final prefs = await openBox();

    final jsonString = prefs.getString(_opmetingRaamOpvullingenKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(jsonString);

      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) => OpmetingRaamOpvullingModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where((item) => item.naam.trim().isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> bewaarOpmetingRaamOpvullingen(
    List<OpmetingRaamOpvullingModel> opvullingen,
  ) async {
    final prefs = await openBox();

    await prefs.setString(
      _opmetingRaamOpvullingenKey,
      jsonEncode(opvullingen.map((opvulling) => opvulling.toJson()).toList()),
    );

    await _syncBackup();
  }

  static Future<void> bewaarOpmetingRaamOpvullingenVoorSync(
    List<OpmetingRaamOpvullingModel> opvullingen,
  ) async {
    final prefs = await openBox();

    await prefs.setString(
      _opmetingRaamOpvullingenKey,
      jsonEncode(opvullingen.map((opvulling) => opvulling.toJson()).toList()),
    );
  }

  // ------------------------------------------------------------
  // OPMETING RAAM - INSTELBARE KEUZEMENU'S
  // ------------------------------------------------------------

  static String _opmetingRaamKeuzemenusKeyVoorFormulier(String formulierType) {
    switch (formulierType.trim()) {
      case 'aluRaam':
      case 'alu_raam':
      case 'ALU Raam':
        return _opmetingRaamKeuzemenusAluKey;

      case 'pvcDeur':
      case 'pvc_deur':
      case 'PVC Deur':
        return _opmetingDeurKeuzemenusPvcKey;

      case 'aluDeur':
      case 'alu_deur':
      case 'ALU Deur':
        return _opmetingDeurKeuzemenusAluKey;

      case 'pvcRaam':
      case 'pvc_raam':
      case 'PVC Raam':
      case 'raam':
      case '':
        return _opmetingRaamKeuzemenusKey;

      default:
        return _opmetingRaamKeuzemenusKey;
    }
  }

  static Future<List<OpmetingRaamKeuzeMenu>>
  laadOpmetingRaamKeuzemenusVoorFormulier(String formulierType) async {
    return _laadOpmetingRaamKeuzemenusMetKey(
      _opmetingRaamKeuzemenusKeyVoorFormulier(formulierType),
    );
  }

  static Future<List<OpmetingRaamKeuzeMenu>> _laadOpmetingRaamKeuzemenusMetKey(
    String key,
  ) async {
    final prefs = await openBox();

    final jsonString = prefs.getString(key);

    if (jsonString == null || jsonString.isEmpty) {
      return <OpmetingRaamKeuzeMenu>[];
    }

    try {
      final decoded = jsonDecode(jsonString);

      if (decoded is! List) {
        return <OpmetingRaamKeuzeMenu>[];
      }

      final menus = decoded
          .whereType<Map>()
          .map(
            (item) =>
                OpmetingRaamKeuzeMenu.fromJson(Map<String, dynamic>.from(item)),
          )
          .where(
            (menu) => menu.id.trim().isNotEmpty && menu.titel.trim().isNotEmpty,
          )
          .map((menu) => menu.metGeldigeGeenOptie())
          .toList();

      _sorteerOpmetingRaamKeuzemenus(menus);

      return menus;
    } catch (_) {
      return <OpmetingRaamKeuzeMenu>[];
    }
  }

  static Future<List<OpmetingRaamKeuzeMenu>>
  laadOpmetingRaamKeuzemenus() async {
    return laadOpmetingRaamKeuzemenusVoorFormulier('pvcRaam');
  }

  static Future<void> bewaarOpmetingRaamKeuzemenusVoorFormulier({
    required String formulierType,
    required List<OpmetingRaamKeuzeMenu> menus,
  }) async {
    await _bewaarOpmetingRaamKeuzemenusMetKey(
      key: _opmetingRaamKeuzemenusKeyVoorFormulier(formulierType),
      menus: menus,
      sync: true,
    );
  }

  static Future<void> _bewaarOpmetingRaamKeuzemenusMetKey({
    required String key,
    required List<OpmetingRaamKeuzeMenu> menus,
    required bool sync,
  }) async {
    final prefs = await openBox();

    final genormaliseerdeMenus = _normaliseerOpmetingRaamKeuzemenus(menus);

    await prefs.setString(
      key,
      jsonEncode(genormaliseerdeMenus.map((menu) => menu.toJson()).toList()),
    );

    if (sync) {
      await _syncBackup();
    }
  }

  static Future<void> bewaarOpmetingRaamKeuzemenus(
    List<OpmetingRaamKeuzeMenu> menus,
  ) async {
    await bewaarOpmetingRaamKeuzemenusVoorFormulier(
      formulierType: 'pvcRaam',
      menus: menus,
    );
  }

  static Future<void> bewaarOpmetingRaamKeuzemenusVoorSync(
    List<OpmetingRaamKeuzeMenu> menus,
  ) async {
    await bewaarOpmetingRaamKeuzemenusVoorFormulierVoorSync(
      formulierType: 'pvcRaam',
      menus: menus,
    );
  }

  static Future<void> bewaarOpmetingRaamKeuzemenusVoorFormulierVoorSync({
    required String formulierType,
    required List<OpmetingRaamKeuzeMenu> menus,
  }) async {
    await _bewaarOpmetingRaamKeuzemenusMetKey(
      key: _opmetingRaamKeuzemenusKeyVoorFormulier(formulierType),
      menus: menus,
      sync: false,
    );
  }

  static List<OpmetingRaamKeuzeMenu> _normaliseerOpmetingRaamKeuzemenus(
    Iterable<OpmetingRaamKeuzeMenu> menus,
  ) {
    final resultaat = menus
        .where(
          (menu) => menu.id.trim().isNotEmpty && menu.titel.trim().isNotEmpty,
        )
        .map((menu) => menu.metGeldigeGeenOptie())
        .toList();

    _sorteerOpmetingRaamKeuzemenus(resultaat);

    return resultaat;
  }

  static void _sorteerOpmetingRaamKeuzemenus(
    List<OpmetingRaamKeuzeMenu> menus,
  ) {
    menus.sort((eerste, tweede) {
      final volgordeVergelijking = eerste.volgorde.compareTo(tweede.volgorde);

      if (volgordeVergelijking != 0) {
        return volgordeVergelijking;
      }

      return eerste.titel.toLowerCase().compareTo(tweede.titel.toLowerCase());
    });
  }

  // ------------------------------------------------------------
  // OPMETINGEN - ALGEMENE OPSLAG
  // ------------------------------------------------------------

  static List<OpmetingOverzichtRaamItem> _decodeOpmetingen(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return <OpmetingOverzichtRaamItem>[];
    }

    try {
      final decoded = jsonDecode(jsonString);

      if (decoded is! List) {
        return <OpmetingOverzichtRaamItem>[];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) => OpmetingOverzichtRaamItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where((opmeting) => opmeting.id.trim().isNotEmpty)
          .toList();
    } catch (_) {
      return <OpmetingOverzichtRaamItem>[];
    }
  }

  static String encodeOpmetingenVoorSync(
    List<OpmetingOverzichtRaamItem> opmetingen,
  ) {
    return jsonEncode(opmetingen.map((opmeting) => opmeting.toJson()).toList());
  }

  static Future<List<OpmetingOverzichtRaamItem>>
  laadOpmetingenVoorSync() async {
    final prefs = await openBox();

    return _decodeOpmetingen(prefs.getString(_opmetingenKey));
  }

  static Future<List<OpmetingOverzichtRaamItem>> laadOpmetingen() async {
    final alleOpmetingen = await laadOpmetingenVoorSync();

    // Volgorde bewust behouden zoals opgeslagen.
    // Daardoor blijft Pos 1 bovenaan staan en komt elke nieuwe positie onderaan.
    return alleOpmetingen.where((opmeting) {
      return !opmeting.isVerwijderd;
    }).toList();
  }

  static Future<void> bewaarOpmetingen(
    List<OpmetingOverzichtRaamItem> opmetingen,
  ) async {
    final prefs = await openBox();

    await prefs.setString(_opmetingenKey, encodeOpmetingenVoorSync(opmetingen));

    await _syncBackup();
  }

  static Future<void> bewaarOpmetingenVoorSync(
    List<OpmetingOverzichtRaamItem> opmetingen,
  ) async {
    final prefs = await openBox();

    await prefs.setString(_opmetingenKey, encodeOpmetingenVoorSync(opmetingen));
  }

  static Future<OpmetingOverzichtRaamItem> voegOpmetingToe(
    OpmetingOverzichtRaamItem opmeting,
  ) async {
    final bestaandeOpmetingen = await laadOpmetingenVoorSync();

    final id = opmeting.id.trim().isEmpty
        ? DateTime.now().microsecondsSinceEpoch.toString()
        : opmeting.id.trim();

    final opmetingVoorOpslag = opmeting.copyWith(
      id: id,
      gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
      isVerwijderd: false,
    );

    final resultaat = List<OpmetingOverzichtRaamItem>.from(bestaandeOpmetingen);

    final bestaandeIndex = resultaat.indexWhere((bestaand) {
      return bestaand.id == opmetingVoorOpslag.id;
    });

    if (bestaandeIndex >= 0) {
      // Bestaande positie bijwerken zonder deze in de lijst te verplaatsen.
      resultaat[bestaandeIndex] = opmetingVoorOpslag;
    } else {
      // Nieuwe positie altijd onderaan toevoegen.
      resultaat.add(opmetingVoorOpslag);
    }

    await bewaarOpmetingen(resultaat);

    return opmetingVoorOpslag;
  }

  static Future<OpmetingOverzichtRaamItem> werkOpmetingBij(
    OpmetingOverzichtRaamItem opmeting,
  ) async {
    return voegOpmetingToe(opmeting);
  }

  static Future<void> verwijderOpmeting(String id) async {
    final bestaandeOpmetingen = await laadOpmetingenVoorSync();

    final resultaat = <OpmetingOverzichtRaamItem>[];
    var gevonden = false;

    for (final opmeting in bestaandeOpmetingen) {
      if (opmeting.id != id) {
        resultaat.add(opmeting);
        continue;
      }

      gevonden = true;
      resultaat.add(opmeting.metNieuweWijzigingsDatum(isVerwijderd: true));
    }

    if (!gevonden) {
      return;
    }

    await bewaarOpmetingen(resultaat);
  }
}
