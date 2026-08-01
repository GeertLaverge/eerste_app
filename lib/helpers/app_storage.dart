// THIMACO-CONTROLE: UITVALSCHERM-APP-STORAGE-20260801
// THIMACO-CONTROLE: VOORZETROLLUIK-APP-STORAGE-FASE-1-20260731
// THIMACO-CONTROLE: VOORZETSCREEN-APP-STORAGE-BEDIENINGEN-20260730-2115
// THIMACO-CONTROLE: APP-STORAGE-VELUX-DAKRAMEN-CATALOGUS-20260729
// THIMACO-CONTROLE: APP-STORAGE-SEKTIONALE-POORTEN-20260729
// THIMACO-CONTROLE: APP-STORAGE-PLOOIWERKEN-KLEURLIJSTEN-DEFINITIEF-20260728-2110
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'Agenda/agenda_dagtaak_template.dart';
import 'Agenda/agenda_item.dart';
import 'sync/onedrive_sync_service.dart';
import 'sync/sync_merge_service.dart';

import '../helpers/notities/notitie_actie_model.dart';
import '../helpers/notities/notitie_model.dart';
import 'opmeting/raam/opmeting_raam_keuzemenu_model.dart';
import 'opmeting/raam/opmeting_raam_opvulling_model.dart';
import 'opmeting/overzicht/opmeting_overzicht_model.dart';
import 'opmeting/project/opmeting_project_kleur_model.dart';
import 'opmeting/project/opmeting_project_titelhoofd_model.dart';
import 'opmeting/toebehoren/plooiwerken/opmeting_plooiwerken_instellingen_model.dart';
import 'opmeting/toebehoren/voorzetscreen/opmeting_voorzetscreen_instellingen_model.dart';
import 'opmeting/toebehoren/voorzetrolluik/opmeting_voorzetrolluik_instellingen_model.dart';
import 'opmeting/toebehoren/uitvalscherm/opmeting_uitvalscherm_instellingen_model.dart';
import 'opmeting/toebehoren/sektionale_poort/opmeting_sektionale_poort_instellingen_model.dart';
import 'opmeting/toebehoren/velux_dakramen/opmeting_velux_dakraam_instellingen_model.dart';
import 'offerte/prijzen/offerte_prijs_opslag_codec.dart';
import 'offerte/prijzen/offerte_prijsprofiel_model.dart';

class AppStorage {
  static const String _agendaItemsNieuwKey = 'agenda_items_nieuw';

  static const String _dagtaakTemplatesKey = 'dagtaak_templates';

  static const String _dagtaakTemplatesSyncMetaKey =
      'dagtaak_templates_sync_meta';

  static const String _leveranciersKey = 'leveranciers_lijst';

  static const String _leveranciersSyncMetaKey = 'leveranciers_lijst_sync_meta';

  static const String _klantenFichesKey = 'klanten_fiches';

  static const String _notitiesKey = 'thimaco_notities';

  static const String _notitiesSyncMetaKey = 'thimaco_notities_sync_meta';

  static const String _notitieActiesKey = 'thimaco_notitie_acties';

  static const String _notitieActiesSyncMetaKey =
      'thimaco_notitie_acties_sync_meta';

  static const String _opmetingRaamOpvullingenKey = 'opmeting_raam_opvullingen';

  static const String _opmetingRaamKeuzemenusKey = 'opmeting_raam_keuzemenus';

  static const String _opmetingRaamKeuzemenusAluKey =
      'opmeting_raam_keuzemenus_alu';

  static const String _opmetingDeurKeuzemenusPvcKey =
      'opmeting_deur_keuzemenus_pvc';

  static const String _opmetingDeurKeuzemenusAluKey =
      'opmeting_deur_keuzemenus_alu';

  static const String _opmetingSchuifraamKeuzemenusPvcKey =
      'opmeting_schuifraam_keuzemenus_pvc';

  static const String _opmetingSchuifraamKeuzemenusAluKey =
      'opmeting_schuifraam_keuzemenus_alu';

  static const String _opmetingProjectTitelhoofdenKey =
      'thimaco_opmeting_project_titelhoofden';

  static const String _opmetingProjectKleurenKey =
      'thimaco_opmeting_project_kleuren';

  static const String _opmetingProjectKleurenSyncMetaKey =
      'thimaco_opmeting_project_kleuren_sync_meta';

  static const String _opmetingPlooiwerkenInstellingenKey =
      'thimaco_opmeting_plooiwerken_instellingen';

  static const String _opmetingVoorzetscreenInstellingenKey =
      'thimaco_opmeting_voorzetscreen_instellingen';

  static const String _opmetingVoorzetrolluikInstellingenKey =
      'thimaco_opmeting_voorzetrolluik_instellingen';

  static const String _opmetingUitvalschermInstellingenKey =
      'thimaco_opmeting_uitvalscherm_instellingen';

  static const String _opmetingSektionalePoortInstellingenKey =
      'thimaco_opmeting_sektionale_poort_instellingen';

  static const String _opmetingVeluxDakraamInstellingenKey =
      'thimaco_opmeting_velux_dakraam_instellingen';

  static const String _offertePrijsProfielenKey =
      'thimaco_offerte_prijs_profielen';

  static const String _opmetingenKey = 'thimaco_opmetingen';

  static Future<SharedPreferences> openBox() async {
    return SharedPreferences.getInstance();
  }

  static Future<void> _syncBackup() async {
    await OneDriveSyncService.registreerLokaleWijziging();
    OneDriveSyncService().uploadBackupOpAchtergrond();
  }

  static List<Map<String, dynamic>> decodeJsonMapLijstVoorSync(
    String? jsonString,
  ) {
    if (jsonString == null || jsonString.trim().isEmpty) {
      return <Map<String, dynamic>>[];
    }

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! List) {
        return <Map<String, dynamic>>[];
      }

      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  static String encodeJsonMapLijstVoorSync(
    Iterable<Map<String, dynamic>> records,
  ) {
    return jsonEncode(records.toList());
  }

  static String _standaardSyncId(Map<String, dynamic> record) {
    return record['id']?.toString().trim() ?? '';
  }

  static String _syncMetaKeyVoorDataKey(String dataKey) {
    return '${dataKey}_sync_meta';
  }

  static Future<void> _bewaarJsonMapLijstMetSyncMetadata({
    required String dataKey,
    required String metadataKey,
    required List<Map<String, dynamic>> records,
    required String Function(Map<String, dynamic> record) idVoorRecord,
    required bool sync,
  }) async {
    final prefs = await openBox();
    final oudeRecords = decodeJsonMapLijstVoorSync(prefs.getString(dataKey));
    final bestaandeMetadata = SyncMergeService.decodeJsonRecordMetadata(
      prefs.getString(metadataKey),
    );
    final gewijzigdOp = DateTime.now().toUtc().toIso8601String();
    final nieuweMetadata = SyncMergeService.updateJsonRecordMetadata(
      oudeRecords: oudeRecords,
      nieuweRecords: records,
      bestaandeMetadata: bestaandeMetadata,
      idVoorRecord: idVoorRecord,
      gewijzigdOp: gewijzigdOp,
    );

    await prefs.setString(dataKey, encodeJsonMapLijstVoorSync(records));
    await prefs.setString(
      metadataKey,
      SyncMergeService.encodeJsonRecordMetadata(nieuweMetadata),
    );

    if (sync) {
      await _syncBackup();
    }
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
    await _bewaarJsonMapLijstMetSyncMetadata(
      dataKey: _dagtaakTemplatesKey,
      metadataKey: _dagtaakTemplatesSyncMetaKey,
      records: templates.map((template) => template.toJson()).toList(),
      idVoorRecord: _standaardSyncId,
      sync: true,
    );
  }

  // ------------------------------------------------------------
  // LEVERANCIERS
  // ------------------------------------------------------------

  static Future<List<Map<String, dynamic>>> laadLeveranciersVoorSync() async {
    final prefs = await openBox();
    return decodeJsonMapLijstVoorSync(prefs.getString(_leveranciersKey));
  }

  static Future<void> bewaarLeveranciers(
    List<Map<String, dynamic>> leveranciers,
  ) async {
    await _bewaarJsonMapLijstMetSyncMetadata(
      dataKey: _leveranciersKey,
      metadataKey: _leveranciersSyncMetaKey,
      records: leveranciers,
      idVoorRecord: SyncMergeService.syncIdVoorLeverancierRecord,
      sync: true,
    );
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
    final opgeslagenItems = _decodeAgendaItems(
      prefs.getString(_agendaItemsNieuwKey),
    );
    final itemsMetTombstones = SyncMergeService.behoudAgendaTombstones(
      actueleItems: itemsPerDag,
      opgeslagenItems: opgeslagenItems,
    );

    await prefs.setString(
      _agendaItemsNieuwKey,
      encodeAgendaItemsVoorSync(itemsMetTombstones),
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
    await _bewaarJsonMapLijstMetSyncMetadata(
      dataKey: _notitiesKey,
      metadataKey: _notitiesSyncMetaKey,
      records: notities.map((notitie) => notitie.toJson()).toList(),
      idVoorRecord: _standaardSyncId,
      sync: true,
    );
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
    await _bewaarJsonMapLijstMetSyncMetadata(
      dataKey: _notitieActiesKey,
      metadataKey: _notitieActiesSyncMetaKey,
      records: acties.map((actie) => actie.toJson()).toList(),
      idVoorRecord: _standaardSyncId,
      sync: true,
    );
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

      case 'pvcSchuifraam':
      case 'pvc_schuifraam':
      case 'PVC Schuifraam':
        return _opmetingSchuifraamKeuzemenusPvcKey;

      case 'aluSchuifraam':
      case 'alu_schuifraam':
      case 'ALU Schuifraam':
        return _opmetingSchuifraamKeuzemenusAluKey;

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
    final key = _opmetingRaamKeuzemenusKeyVoorFormulier(formulierType);
    final menus = await _laadOpmetingRaamKeuzemenusMetKey(key);

    if (menus.isNotEmpty || !_isPvcSchuifraamFormulier(formulierType)) {
      return menus;
    }

    // Bestaande PVC-schuifraamfiches gebruikten vroeger dezelfde technische
    // keuzes als PVC raam. We kopiëren die één keer naar de eigen opslag,
    // zodat beide fiches vanaf nu volledig onafhankelijk verder werken.
    final oudeMenus = await _laadOpmetingRaamKeuzemenusMetKey(
      _opmetingRaamKeuzemenusKey,
    );

    if (oudeMenus.isEmpty) {
      return menus;
    }

    await _bewaarOpmetingRaamKeuzemenusMetKey(
      key: _opmetingSchuifraamKeuzemenusPvcKey,
      menus: oudeMenus,
      sync: false,
    );

    return List<OpmetingRaamKeuzeMenu>.unmodifiable(oudeMenus);
  }

  static bool _isPvcSchuifraamFormulier(String formulierType) {
    switch (formulierType.trim()) {
      case 'pvcSchuifraam':
      case 'pvc_schuifraam':
      case 'PVC Schuifraam':
        return true;
      default:
        return false;
    }
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
    bool metadataBijwerken = true,
  }) async {
    final genormaliseerdeMenus = _normaliseerOpmetingRaamKeuzemenus(menus);
    final records = genormaliseerdeMenus.map((menu) => menu.toJson()).toList();

    if (!metadataBijwerken) {
      final prefs = await openBox();
      await prefs.setString(key, encodeJsonMapLijstVoorSync(records));
      return;
    }

    await _bewaarJsonMapLijstMetSyncMetadata(
      dataKey: key,
      metadataKey: _syncMetaKeyVoorDataKey(key),
      records: records,
      idVoorRecord: _standaardSyncId,
      sync: sync,
    );
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
      metadataBijwerken: false,
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
  // OFFERTEPRIJZEN
  // ------------------------------------------------------------

  static List<OffertePrijsprofielModel> decodeOffertePrijsProfielenVoorSync(
    String? jsonString,
  ) {
    return OffertePrijsOpslagCodec.decode(jsonString);
  }

  static String encodeOffertePrijsProfielenVoorSync(
    List<OffertePrijsprofielModel> profielen,
  ) {
    return OffertePrijsOpslagCodec.encode(profielen);
  }

  static Future<List<OffertePrijsprofielModel>>
  laadOffertePrijsProfielen() async {
    final prefs = await openBox();

    return decodeOffertePrijsProfielenVoorSync(
      prefs.getString(_offertePrijsProfielenKey),
    );
  }

  static Future<void> bewaarOffertePrijsProfielenVoorSync(
    List<OffertePrijsprofielModel> profielen,
  ) async {
    final prefs = await openBox();

    await prefs.setString(
      _offertePrijsProfielenKey,
      encodeOffertePrijsProfielenVoorSync(profielen),
    );
  }

  static Future<void> bewaarOffertePrijsProfielen(
    List<OffertePrijsprofielModel> profielen,
  ) async {
    await bewaarOffertePrijsProfielenVoorSync(profielen);
    await _syncBackup();
  }

  static Future<OffertePrijsprofielModel?> laadOffertePrijsProfiel(
    String formulierType,
  ) async {
    final sleutel = formulierType.trim().toLowerCase();

    if (sleutel.isEmpty) {
      return null;
    }

    final profielen = await laadOffertePrijsProfielen();

    for (final profiel in profielen) {
      if (profiel.formulierType.trim().toLowerCase() == sleutel) {
        return profiel;
      }
    }

    return null;
  }

  static Future<void> bewaarOffertePrijsProfiel(
    OffertePrijsprofielModel profiel,
  ) async {
    final formulierType = profiel.formulierType.trim();

    if (formulierType.isEmpty) {
      return;
    }

    final profielen = await laadOffertePrijsProfielen();
    final sleutel = formulierType.toLowerCase();
    final bijgewerkt = profiel.metWijzigingsDatum();
    final index = profielen.indexWhere((bestaand) {
      return bestaand.formulierType.trim().toLowerCase() == sleutel;
    });

    if (index >= 0) {
      profielen[index] = bijgewerkt;
    } else {
      profielen.add(bijgewerkt);
    }

    profielen.sort((eerste, tweede) {
      return eerste.formulierNaam.toLowerCase().compareTo(
        tweede.formulierNaam.toLowerCase(),
      );
    });

    await bewaarOffertePrijsProfielen(profielen);
  }

  // ------------------------------------------------------------
  // OPMETING - PROJECT TITELHOOFD
  // ------------------------------------------------------------

  static Map<String, OpmetingProjectTitelhoofd>
  decodeOpmetingProjectTitelhoofdenVoorSync(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return <String, OpmetingProjectTitelhoofd>{};
    }

    try {
      final decoded = jsonDecode(jsonString);

      if (decoded is! Map) {
        return <String, OpmetingProjectTitelhoofd>{};
      }

      final resultaat = <String, OpmetingProjectTitelhoofd>{};

      decoded.forEach((sleutel, waarde) {
        if (waarde is! Map) {
          return;
        }

        final titelhoofd = OpmetingProjectTitelhoofd.fromJson(
          Map<String, dynamic>.from(waarde),
        );

        resultaat[sleutel.toString()] = titelhoofd;
      });

      return resultaat;
    } catch (_) {
      return <String, OpmetingProjectTitelhoofd>{};
    }
  }

  static String encodeOpmetingProjectTitelhoofdenVoorSync(
    Map<String, OpmetingProjectTitelhoofd> titelhoofden,
  ) {
    return jsonEncode(
      titelhoofden.map((sleutel, titelhoofd) {
        return MapEntry(sleutel, titelhoofd.toJson());
      }),
    );
  }

  static Future<Map<String, OpmetingProjectTitelhoofd>>
  laadOpmetingProjectTitelhoofdenVoorSync() async {
    final prefs = await openBox();

    return decodeOpmetingProjectTitelhoofdenVoorSync(
      prefs.getString(_opmetingProjectTitelhoofdenKey),
    );
  }

  static Future<void> bewaarOpmetingProjectTitelhoofdenVoorSync(
    Map<String, OpmetingProjectTitelhoofd> titelhoofden,
  ) async {
    final prefs = await openBox();

    await prefs.setString(
      _opmetingProjectTitelhoofdenKey,
      encodeOpmetingProjectTitelhoofdenVoorSync(titelhoofden),
    );
  }

  static Future<OpmetingProjectTitelhoofd> laadOpmetingProjectTitelhoofd(
    String klantNaam,
  ) async {
    final titelhoofden = await laadOpmetingProjectTitelhoofdenVoorSync();
    final sleutel = opmetingProjectTitelhoofdSleutel(klantNaam);

    return titelhoofden[sleutel] ??
        OpmetingProjectTitelhoofd(klantNaam: klantNaam.trim());
  }

  static Future<void> bewaarOpmetingProjectTitelhoofd(
    OpmetingProjectTitelhoofd titelhoofd,
  ) async {
    final titelhoofden = await laadOpmetingProjectTitelhoofdenVoorSync();
    final sleutel = opmetingProjectTitelhoofdSleutel(titelhoofd.klantNaam);

    titelhoofden[sleutel] = titelhoofd.metWijzigingsDatum();

    final prefs = await openBox();

    await prefs.setString(
      _opmetingProjectTitelhoofdenKey,
      encodeOpmetingProjectTitelhoofdenVoorSync(titelhoofden),
    );

    await _syncBackup();
  }

  // ------------------------------------------------------------
  // OPMETING - PROJECTKLEUREN RAAMLEVERANCIER
  // ------------------------------------------------------------

  static List<OpmetingProjectKleurSubmenu> _decodeProjectKleuren(
    String? jsonString,
  ) {
    if (jsonString == null || jsonString.isEmpty) {
      return <OpmetingProjectKleurSubmenu>[];
    }

    try {
      final decoded = jsonDecode(jsonString);

      if (decoded is! List) {
        return <OpmetingProjectKleurSubmenu>[];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) => OpmetingProjectKleurSubmenu.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where((submenu) {
            return submenu.id.trim().isNotEmpty &&
                submenu.naam.trim().isNotEmpty;
          })
          .toList();
    } catch (_) {
      return <OpmetingProjectKleurSubmenu>[];
    }
  }

  static String encodeOpmetingProjectKleurenVoorSync(
    List<OpmetingProjectKleurSubmenu> kleuren,
  ) {
    return jsonEncode(kleuren.map((submenu) => submenu.toJson()).toList());
  }

  static Future<List<OpmetingProjectKleurSubmenu>>
  laadOpmetingProjectKleuren() async {
    final prefs = await openBox();

    return _decodeProjectKleuren(prefs.getString(_opmetingProjectKleurenKey));
  }

  static Future<void> bewaarOpmetingProjectKleuren(
    List<OpmetingProjectKleurSubmenu> kleuren,
  ) async {
    await _bewaarJsonMapLijstMetSyncMetadata(
      dataKey: _opmetingProjectKleurenKey,
      metadataKey: _opmetingProjectKleurenSyncMetaKey,
      records: kleuren.map((submenu) => submenu.toJson()).toList(),
      idVoorRecord: _standaardSyncId,
      sync: true,
    );
  }

  static Future<void> bewaarOpmetingProjectKleurenVoorSync(
    List<OpmetingProjectKleurSubmenu> kleuren,
  ) async {
    final prefs = await openBox();
    await prefs.setString(
      _opmetingProjectKleurenKey,
      encodeOpmetingProjectKleurenVoorSync(kleuren),
    );
  }

  // ------------------------------------------------------------
  // OPMETING - INSTELLINGEN PLOOIWERKEN
  // ------------------------------------------------------------

  static OpmetingPlooiwerkenInstellingen _decodeOpmetingPlooiwerkenInstellingen(
    String? jsonString,
  ) {
    if (jsonString == null || jsonString.trim().isEmpty) {
      return const OpmetingPlooiwerkenInstellingen();
    }

    try {
      final decoded = jsonDecode(jsonString);

      if (decoded is! Map) {
        return const OpmetingPlooiwerkenInstellingen();
      }

      return OpmetingPlooiwerkenInstellingen.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } catch (_) {
      return const OpmetingPlooiwerkenInstellingen();
    }
  }

  static String encodeOpmetingPlooiwerkenInstellingenVoorSync(
    OpmetingPlooiwerkenInstellingen instellingen,
  ) {
    return jsonEncode(instellingen.toJson());
  }

  static Future<OpmetingPlooiwerkenInstellingen>
  laadOpmetingPlooiwerkenInstellingen() async {
    final prefs = await openBox();

    return _decodeOpmetingPlooiwerkenInstellingen(
      prefs.getString(_opmetingPlooiwerkenInstellingenKey),
    );
  }

  static Future<void> bewaarOpmetingPlooiwerkenInstellingen(
    OpmetingPlooiwerkenInstellingen instellingen,
  ) async {
    final prefs = await openBox();
    final voorOpslag = instellingen.gewijzigdOp.trim().isEmpty
        ? instellingen.metWijzigingsDatum()
        : instellingen;

    await prefs.setString(
      _opmetingPlooiwerkenInstellingenKey,
      encodeOpmetingPlooiwerkenInstellingenVoorSync(voorOpslag),
    );

    await _syncBackup();
  }

  static Future<void> bewaarOpmetingPlooiwerkenInstellingenVoorSync(
    OpmetingPlooiwerkenInstellingen instellingen,
  ) async {
    final prefs = await openBox();

    await prefs.setString(
      _opmetingPlooiwerkenInstellingenKey,
      encodeOpmetingPlooiwerkenInstellingenVoorSync(instellingen),
    );
  }

  // ------------------------------------------------------------
  // OPMETING - INSTELLINGEN VOORZETSCREENS
  // ------------------------------------------------------------

  static OpmetingVoorzetscreenInstellingen
  _decodeOpmetingVoorzetscreenInstellingen(String? jsonString) {
    if (jsonString == null || jsonString.trim().isEmpty) {
      return const OpmetingVoorzetscreenInstellingen();
    }

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map) {
        return const OpmetingVoorzetscreenInstellingen();
      }

      return OpmetingVoorzetscreenInstellingen.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } catch (_) {
      return const OpmetingVoorzetscreenInstellingen();
    }
  }

  static String encodeOpmetingVoorzetscreenInstellingenVoorSync(
    OpmetingVoorzetscreenInstellingen instellingen,
  ) {
    return jsonEncode(instellingen.toJson());
  }

  static Future<OpmetingVoorzetscreenInstellingen>
  laadOpmetingVoorzetscreenInstellingen() async {
    final prefs = await openBox();
    final instellingen = _decodeOpmetingVoorzetscreenInstellingen(
      prefs.getString(_opmetingVoorzetscreenInstellingenKey),
    );

    return instellingen.copyWith(
      poederkleuren: instellingen.poederkleuren.isEmpty
          ? OpmetingVoorzetscreenInstellingen.standaardPoederkleuren
          : instellingen.poederkleuren,
      screendoeken: instellingen.screendoeken.isEmpty
          ? OpmetingVoorzetscreenInstellingen.standaardScreendoeken
          : instellingen.screendoeken,
      motoren: instellingen.motoren.isEmpty
          ? OpmetingVoorzetscreenInstellingen.standaardMotoren
          : instellingen.motoren,
      zonnecelMotoren: instellingen.zonnecelMotoren.isEmpty
          ? OpmetingVoorzetscreenInstellingen.standaardZonnecelMotoren
          : instellingen.zonnecelMotoren,
      bedieningen: instellingen.bedieningen.isEmpty
          ? OpmetingVoorzetscreenInstellingen.standaardBedieningen
          : instellingen.bedieningen,
    );
  }

  static Future<void> bewaarOpmetingVoorzetscreenInstellingen(
    OpmetingVoorzetscreenInstellingen instellingen,
  ) async {
    final prefs = await openBox();
    final voorOpslag = instellingen.gewijzigdOp.trim().isEmpty
        ? instellingen.metWijzigingsDatum()
        : instellingen;

    await prefs.setString(
      _opmetingVoorzetscreenInstellingenKey,
      encodeOpmetingVoorzetscreenInstellingenVoorSync(voorOpslag),
    );

    await _syncBackup();
  }

  static Future<void> bewaarOpmetingVoorzetscreenInstellingenVoorSync(
    OpmetingVoorzetscreenInstellingen instellingen,
  ) async {
    final prefs = await openBox();
    await prefs.setString(
      _opmetingVoorzetscreenInstellingenKey,
      encodeOpmetingVoorzetscreenInstellingenVoorSync(instellingen),
    );
  }

  // ------------------------------------------------------------
  // OPMETING - INSTELLINGEN VOORZETROLLUIKEN
  // ------------------------------------------------------------

  static OpmetingVoorzetrolluikInstellingen
  _decodeOpmetingVoorzetrolluikInstellingen(String? jsonString) {
    if (jsonString == null || jsonString.trim().isEmpty) {
      return const OpmetingVoorzetrolluikInstellingen();
    }

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map) {
        return const OpmetingVoorzetrolluikInstellingen();
      }

      return OpmetingVoorzetrolluikInstellingen.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } catch (_) {
      return const OpmetingVoorzetrolluikInstellingen();
    }
  }

  static String encodeOpmetingVoorzetrolluikInstellingenVoorSync(
    OpmetingVoorzetrolluikInstellingen instellingen,
  ) {
    return jsonEncode(instellingen.toJson());
  }

  static Future<OpmetingVoorzetrolluikInstellingen>
  laadOpmetingVoorzetrolluikInstellingen() async {
    final prefs = await openBox();
    final instellingen = _decodeOpmetingVoorzetrolluikInstellingen(
      prefs.getString(_opmetingVoorzetrolluikInstellingenKey),
    );

    return instellingen.copyWith(
      lamelkleuren: instellingen.lamelkleuren.isEmpty
          ? OpmetingVoorzetrolluikInstellingen.standaardLamelkleuren
          : instellingen.lamelkleuren,
      motoren: instellingen.motoren.isEmpty
          ? OpmetingVoorzetrolluikInstellingen.standaardMotoren
          : instellingen.motoren,
      zonnecelMotoren: instellingen.zonnecelMotoren.isEmpty
          ? OpmetingVoorzetrolluikInstellingen.standaardZonnecelMotoren
          : instellingen.zonnecelMotoren,
    );
  }

  static Future<void> bewaarOpmetingVoorzetrolluikInstellingen(
    OpmetingVoorzetrolluikInstellingen instellingen,
  ) async {
    final prefs = await openBox();
    final voorOpslag = instellingen.gewijzigdOp.trim().isEmpty
        ? instellingen.metWijzigingsDatum()
        : instellingen;

    await prefs.setString(
      _opmetingVoorzetrolluikInstellingenKey,
      encodeOpmetingVoorzetrolluikInstellingenVoorSync(voorOpslag),
    );

    await _syncBackup();
  }

  static Future<void> bewaarOpmetingVoorzetrolluikInstellingenVoorSync(
    OpmetingVoorzetrolluikInstellingen instellingen,
  ) async {
    final prefs = await openBox();
    await prefs.setString(
      _opmetingVoorzetrolluikInstellingenKey,
      encodeOpmetingVoorzetrolluikInstellingenVoorSync(instellingen),
    );
  }

  // ------------------------------------------------------------
  // OPMETING - INSTELLINGEN UITVALSCHERMEN
  // ------------------------------------------------------------

  static OpmetingUitvalschermInstellingen
  _decodeOpmetingUitvalschermInstellingen(String? jsonString) {
    if (jsonString == null || jsonString.trim().isEmpty) {
      return const OpmetingUitvalschermInstellingen();
    }

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map) {
        return const OpmetingUitvalschermInstellingen();
      }
      return OpmetingUitvalschermInstellingen.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } catch (_) {
      return const OpmetingUitvalschermInstellingen();
    }
  }

  static String encodeOpmetingUitvalschermInstellingenVoorSync(
    OpmetingUitvalschermInstellingen instellingen,
  ) {
    return jsonEncode(instellingen.toJson());
  }

  static Future<OpmetingUitvalschermInstellingen>
  laadOpmetingUitvalschermInstellingen() async {
    final prefs = await openBox();
    return _decodeOpmetingUitvalschermInstellingen(
      prefs.getString(_opmetingUitvalschermInstellingenKey),
    );
  }

  static Future<void> bewaarOpmetingUitvalschermInstellingen(
    OpmetingUitvalschermInstellingen instellingen,
  ) async {
    final prefs = await openBox();
    final voorOpslag = instellingen.gewijzigdOp.trim().isEmpty
        ? instellingen.metWijzigingsDatum()
        : instellingen;
    await prefs.setString(
      _opmetingUitvalschermInstellingenKey,
      encodeOpmetingUitvalschermInstellingenVoorSync(voorOpslag),
    );
    await _syncBackup();
  }

  static Future<void> bewaarOpmetingUitvalschermInstellingenVoorSync(
    OpmetingUitvalschermInstellingen instellingen,
  ) async {
    final prefs = await openBox();
    await prefs.setString(
      _opmetingUitvalschermInstellingenKey,
      encodeOpmetingUitvalschermInstellingenVoorSync(instellingen),
    );
  }

  // ------------------------------------------------------------
  // OPMETING - INSTELLINGEN SEKTIONALE POORTEN
  // ------------------------------------------------------------

  static OpmetingSektionalePoortInstellingen
  _decodeOpmetingSektionalePoortInstellingen(String? jsonString) {
    if (jsonString == null || jsonString.trim().isEmpty) {
      return const OpmetingSektionalePoortInstellingen();
    }

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map) {
        return const OpmetingSektionalePoortInstellingen();
      }
      return OpmetingSektionalePoortInstellingen.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } catch (_) {
      return const OpmetingSektionalePoortInstellingen();
    }
  }

  static String encodeOpmetingSektionalePoortInstellingenVoorSync(
    OpmetingSektionalePoortInstellingen instellingen,
  ) {
    return jsonEncode(instellingen.toJson());
  }

  static Future<OpmetingSektionalePoortInstellingen>
  laadOpmetingSektionalePoortInstellingen() async {
    final prefs = await openBox();
    return _decodeOpmetingSektionalePoortInstellingen(
      prefs.getString(_opmetingSektionalePoortInstellingenKey),
    );
  }

  static Future<void> bewaarOpmetingSektionalePoortInstellingen(
    OpmetingSektionalePoortInstellingen instellingen,
  ) async {
    final prefs = await openBox();
    final voorOpslag = instellingen.gewijzigdOp.trim().isEmpty
        ? instellingen.metWijzigingsDatum()
        : instellingen;
    await prefs.setString(
      _opmetingSektionalePoortInstellingenKey,
      encodeOpmetingSektionalePoortInstellingenVoorSync(voorOpslag),
    );
    await _syncBackup();
  }

  static Future<void> bewaarOpmetingSektionalePoortInstellingenVoorSync(
    OpmetingSektionalePoortInstellingen instellingen,
  ) async {
    final prefs = await openBox();
    await prefs.setString(
      _opmetingSektionalePoortInstellingenKey,
      encodeOpmetingSektionalePoortInstellingenVoorSync(instellingen),
    );
  }

  // ------------------------------------------------------------
  // OPMETING - INSTELLINGEN VELUX DAKRAMEN
  // ------------------------------------------------------------

  static OpmetingVeluxDakraamInstellingen
  _decodeOpmetingVeluxDakraamInstellingen(String? jsonString) {
    if (jsonString == null || jsonString.trim().isEmpty) {
      return OpmetingVeluxDakraamInstellingen.standaard2026();
    }

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map) {
        return OpmetingVeluxDakraamInstellingen.standaard2026();
      }
      return OpmetingVeluxDakraamInstellingen.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } catch (_) {
      return OpmetingVeluxDakraamInstellingen.standaard2026();
    }
  }

  static String encodeOpmetingVeluxDakraamInstellingenVoorSync(
    OpmetingVeluxDakraamInstellingen instellingen,
  ) {
    return jsonEncode(instellingen.toJson());
  }

  static Future<OpmetingVeluxDakraamInstellingen>
  laadOpmetingVeluxDakraamInstellingen() async {
    final prefs = await openBox();
    return _decodeOpmetingVeluxDakraamInstellingen(
      prefs.getString(_opmetingVeluxDakraamInstellingenKey),
    );
  }

  static Future<void> bewaarOpmetingVeluxDakraamInstellingen(
    OpmetingVeluxDakraamInstellingen instellingen,
  ) async {
    final prefs = await openBox();
    final voorOpslag = instellingen.gewijzigdOp.trim().isEmpty
        ? instellingen.metWijzigingsDatum()
        : instellingen;
    await prefs.setString(
      _opmetingVeluxDakraamInstellingenKey,
      encodeOpmetingVeluxDakraamInstellingenVoorSync(voorOpslag),
    );
    await _syncBackup();
  }

  static Future<void> bewaarOpmetingVeluxDakraamInstellingenVoorSync(
    OpmetingVeluxDakraamInstellingen instellingen,
  ) async {
    final prefs = await openBox();
    await prefs.setString(
      _opmetingVeluxDakraamInstellingenKey,
      encodeOpmetingVeluxDakraamInstellingenVoorSync(instellingen),
    );
  }

  // ------------------------------------------------------------
  // OPMETING - KLANTEN UIT KLANTENFICHES
  // ------------------------------------------------------------

  static Future<List<OpmetingAgendaKlantInfo>> laadKlantenVoorOpmeting() async {
    try {
      final fiches = await laadKlantenFiches();
      final perKlant = <String, OpmetingAgendaKlantInfo>{};

      for (final fiche in fiches) {
        final verwijderd =
            fiche['isVerwijderd'] == true ||
            fiche['verwijderd'] == true ||
            fiche['deleted'] == true ||
            _leesEersteTekst(fiche, const <String>['deletedAt']).isNotEmpty;

        if (verwijderd) {
          continue;
        }

        final klantNaam = _leesEersteTekst(fiche, const <String>[
          'naam',
          'klantNaam',
          'naamKlant',
          'klant',
        ]).trim();

        if (klantNaam.isEmpty) {
          continue;
        }

        final opgeslagenAanspreking = normaliseerOpmetingAanspreking(
          _leesEersteTekst(fiche, const <String>[
            'aanspreking',
            'aanhef',
            'salutation',
          ]),
        );
        final aanspreking = opgeslagenAanspreking.isNotEmpty
            ? opgeslagenAanspreking
            : opmetingAansprekingUitKlantNaam(klantNaam);
        final schoneKlantNaam = opmetingKlantNaamZonderAanspreking(klantNaam);

        final info = OpmetingAgendaKlantInfo(
          klantNaam: schoneKlantNaam,
          aanspreking: aanspreking,
          klantnummer: _leesEersteTekst(fiche, const <String>[
            'klantNr',
            'klantnummer',
            'klantNummer',
            'klantnr',
            'customerNumber',
          ]),
          contactpersoon: _leesEersteTekst(fiche, const <String>[
            'contactpersoon',
            'contactPersoon',
            'contact',
          ]),
          adres: _leesEersteTekst(fiche, const <String>[
            'straatnaam',
            'straatNaam',
            'straat',
            'adres',
          ]),
          huisnummer: _leesEersteTekst(fiche, const <String>[
            'huisNr',
            'huisnummer',
            'huisNummer',
            'nummer',
            'nr',
          ]),
          busNummer: _leesEersteTekst(fiche, const <String>[
            'busNr',
            'busNummer',
            'busnummer',
            'bus',
          ]),
          postcode: _leesEersteTekst(fiche, const <String>[
            'postcode',
            'postCode',
          ]),
          gemeente: _leesEersteTekst(fiche, const <String>[
            'gemeente',
            'plaats',
            'stad',
            'woonplaats',
          ]),
          gsm: _leesEersteTekst(fiche, const <String>[
            'gsm',
            'gsm1',
            'mobiel',
            'mobile',
          ]),
          telefoon: _leesEersteTekst(fiche, const <String>[
            'gsm2',
            'telefoon',
            'tel',
            'telefoonnummer',
          ]),
          email: _leesEersteTekst(fiche, const <String>[
            'email',
            'eMail',
            'mail',
          ]),
          omschrijving: _leesEersteTekst(fiche, const <String>[
            'notities',
            'opmerkingen',
            'omschrijving',
            'beschrijving',
            'notitie',
          ]),
          datumKey: 'klantenfiche',
        );

        final sleutel = opmetingKlantNaamSleutel(schoneKlantNaam);
        if (sleutel.isEmpty) {
          continue;
        }
        final bestaand = perKlant[sleutel];

        perKlant[sleutel] = bestaand == null
            ? info
            : bestaand.combineerMet(info);
      }

      final resultaat = perKlant.values.toList()
        ..sort((eerste, tweede) {
          return eerste.klantNaamMetAanspreking.toLowerCase().compareTo(
            tweede.klantNaamMetAanspreking.toLowerCase(),
          );
        });

      return resultaat;
    } catch (_) {
      return <OpmetingAgendaKlantInfo>[];
    }
  }

  // ------------------------------------------------------------
  // OPMETING - KLANTEN UIT BLAUWE AGENDA
  // ------------------------------------------------------------

  static Future<List<OpmetingAgendaKlantInfo>>
  laadAgendaKlantenVoorOpmeting() async {
    try {
      final itemsPerDag = await laadAgendaItemsNieuwVoorSync();
      final perKlant = <String, OpmetingAgendaKlantInfo>{};
      const klantTypes = <String>{
        'planning',
        'opvolging',
        'nadienst',
        'afspraak',
      };

      for (final dagEntry in itemsPerDag.entries) {
        for (final item in dagEntry.value) {
          final type = item.type.trim().toLowerCase();
          if (item.isVerwijderd || !klantTypes.contains(type)) {
            continue;
          }

          final ruweKlantNaam = item.naamKlant.trim();
          final opgeslagenAanspreking = normaliseerOpmetingAanspreking(
            item.aanspreking,
          );
          final aanspreking = opgeslagenAanspreking.isNotEmpty
              ? opgeslagenAanspreking
              : opmetingAansprekingUitKlantNaam(ruweKlantNaam);
          final klantNaam = opmetingKlantNaamZonderAanspreking(ruweKlantNaam);
          final sleutel = opmetingKlantNaamSleutel(klantNaam);
          if (sleutel.isEmpty || _isGeenEchteAgendaKlantNaam(klantNaam)) {
            continue;
          }

          final info = OpmetingAgendaKlantInfo(
            klantNaam: klantNaam,
            aanspreking: aanspreking,
            klantnummer: item.klantNr.trim(),
            adres: item.straatnaam.trim(),
            huisnummer: item.huisNr.trim(),
            busNummer: item.busNr.trim(),
            postcode: item.postcode.trim(),
            gemeente: item.gemeente.trim(),
            gsm: item.gsm.trim(),
            telefoon: item.gsm2.trim(),
            email: item.email.trim(),
            omschrijving: item.opmerkingen.trim(),
            datumKey: dagEntry.key,
          );

          final bestaand = perKlant[sleutel];
          perKlant[sleutel] = bestaand == null
              ? info
              : bestaand.combineerMet(info);
        }
      }

      final resultaat = perKlant.values.toList()
        ..sort((eerste, tweede) {
          return eerste.klantNaamMetAanspreking.toLowerCase().compareTo(
            tweede.klantNaamMetAanspreking.toLowerCase(),
          );
        });

      return resultaat;
    } catch (_) {
      return <OpmetingAgendaKlantInfo>[];
    }
  }

  static bool _isGeenEchteAgendaKlantNaam(String waarde) {
    final naam = waarde.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    return naam.isEmpty ||
        naam == 'afspraak' ||
        naam == 'planning' ||
        naam == 'opvolging' ||
        naam == 'nadienst' ||
        naam == 'klant' ||
        naam == 'onbekend';
  }

  static String _leesEersteTekst(
    Map<String, dynamic> map,
    List<String> sleutels,
  ) {
    for (final sleutel in sleutels) {
      if (!map.containsKey(sleutel)) {
        continue;
      }

      final waarde = map[sleutel];

      if (waarde == null) {
        continue;
      }

      final tekst = waarde.toString().trim();

      if (tekst.isNotEmpty && tekst.toLowerCase() != 'null') {
        return tekst;
      }
    }

    return '';
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

  static Future<bool> verplaatsOpmetingBinnenKlant({
    required String klantNaam,
    required String opmetingId,
    required int richting,
  }) async {
    if (richting != -1 && richting != 1) {
      return false;
    }

    final alleOpmetingen = await laadOpmetingenVoorSync();
    final klantSleutel = klantNaam.trim().toLowerCase();
    final klantIndices = <int>[];

    for (var index = 0; index < alleOpmetingen.length; index++) {
      final opmeting = alleOpmetingen[index];

      if (opmeting.isVerwijderd) {
        continue;
      }

      if (opmeting.klantNaam.trim().toLowerCase() != klantSleutel) {
        continue;
      }

      klantIndices.add(index);
    }

    final huidigePositie = klantIndices.indexWhere((index) {
      return alleOpmetingen[index].id == opmetingId;
    });

    if (huidigePositie < 0) {
      return false;
    }

    final nieuwePositie = huidigePositie + richting;

    if (nieuwePositie < 0 || nieuwePositie >= klantIndices.length) {
      return false;
    }

    final huidigeIndex = klantIndices[huidigePositie];
    final nieuweIndex = klantIndices[nieuwePositie];
    final nu = DateTime.now().toUtc().toIso8601String();
    final huidige = alleOpmetingen[huidigeIndex];
    final andere = alleOpmetingen[nieuweIndex];

    alleOpmetingen[huidigeIndex] = andere.copyWith(gewijzigdOp: nu);
    alleOpmetingen[nieuweIndex] = huidige.copyWith(gewijzigdOp: nu);

    await bewaarOpmetingen(alleOpmetingen);

    return true;
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
