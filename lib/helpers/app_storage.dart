// THIMACO-CONTROLE: PRIJS-PER-ARTIKEL-BIBLIOTHEEK-ONEDRIVE-SYNC-ACTIEF-20260814
// THIMACO-CONTROLE: OFFERTEVARIANTEN-ATOMAIRE-OPSLAG-20260811
// THIMACO-CONTROLE: PROJECT-TITELHOOFD-ATOMAIRE-OPSLAG-BEREKEN-20260810
// THIMACO-CONTROLE: OPMETINGEN-ATOMAIRE-OPSLAG-GLOBAAL-20260810
// THIMACO-CONTROLE: OFFERTE-ONDERTEKENDE-VERSIES-OPSLAG-20260806
// THIMACO-CONTROLE: BUITENJALOEZIE-APP-STORAGE-FASE-3A-20260803
// THIMACO-CONTROLE: OFFERTE-MAIL-TEKSTEN-APP-STORAGE-20260802
// THIMACO-CONTROLE: ALGEMENE-BIBLIOTHEEK-APP-STORAGE-20260802
// THIMACO-CONTROLE: UITVALSCHERM-APP-STORAGE-20260801
// THIMACO-CONTROLE: VOORZETROLLUIK-APP-STORAGE-FASE-1-20260731
// THIMACO-CONTROLE: VOORZETSCREEN-APP-STORAGE-BEDIENINGEN-20260730-2115
// THIMACO-CONTROLE: APP-STORAGE-VELUX-DAKRAMEN-CATALOGUS-20260729
// THIMACO-CONTROLE: APP-STORAGE-SEKTIONALE-POORTEN-20260729
// THIMACO-CONTROLE: APP-STORAGE-PLOOIWERKEN-KLEURLIJSTEN-DEFINITIEF-20260728-2110
import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'Agenda/agenda_dagtaak_template.dart';
import 'Agenda/agenda_item.dart';
import 'sync/onedrive_sync_service.dart';
import 'sync/sync_merge_service.dart';

import '../helpers/notities/notitie_actie_model.dart';
import 'bibliotheek/bibliotheek_model.dart';
import '../helpers/notities/notitie_model.dart';
import 'opmeting/raam/opmeting_raam_keuzemenu_model.dart';
import 'opmeting/raam/opmeting_raam_opvulling_model.dart';
import 'opmeting/overzicht/opmeting_overzicht_model.dart';
import 'opmeting/project/opmeting_project_kleur_model.dart';
import 'opmeting/project/opmeting_project_titelhoofd_model.dart';
import 'opmeting/toebehoren/plooiwerken/opmeting_plooiwerken_instellingen_model.dart';
import 'opmeting/toebehoren/voorzetscreen/opmeting_voorzetscreen_instellingen_model.dart';
import 'opmeting/toebehoren/buitenjaloezie/opmeting_buitenjaloezie_instellingen_model.dart';
import 'opmeting/toebehoren/voorzetrolluik/opmeting_voorzetrolluik_instellingen_model.dart';
import 'opmeting/toebehoren/uitvalscherm/opmeting_uitvalscherm_instellingen_model.dart';
import 'opmeting/toebehoren/sektionale_poort/opmeting_sektionale_poort_instellingen_model.dart';
import 'opmeting/toebehoren/velux_dakramen/opmeting_velux_dakraam_instellingen_model.dart';
import 'offerte/mail/offerte_mail_tekst_model.dart';
import 'offerte/versies/offerte_versie_model.dart';
import 'offerte/prijzen/offerte_prijs_opslag_codec.dart';
import 'offerte/prijzen/offerte_prijsprofiel_model.dart';
import 'offerte/prijzen/offerte_prijs_per_artikel_template_model.dart';

class AppStorageOpmetingMutatieResultaat<T> {
  const AppStorageOpmetingMutatieResultaat({
    required this.resultaat,
    required this.opmetingen,
    required this.gewijzigd,
    this.startSync = true,
  });

  final T resultaat;
  final List<OpmetingOverzichtRaamItem> opmetingen;
  final bool gewijzigd;
  final bool startSync;
}

class AppStorageProjectTitelhoofdMutatieResultaat<T> {
  const AppStorageProjectTitelhoofdMutatieResultaat({
    required this.resultaat,
    required this.titelhoofden,
    required this.gewijzigd,
    this.startSync = true,
  });

  final T resultaat;
  final Map<String, OpmetingProjectTitelhoofd> titelhoofden;
  final bool gewijzigd;
  final bool startSync;
}

class AppStorageOfferteVersieMutatieResultaat<T> {
  const AppStorageOfferteVersieMutatieResultaat({
    required this.resultaat,
    required this.versies,
    required this.gewijzigd,
    this.startSync = true,
  });

  final T resultaat;
  final List<OfferteVersieModel> versies;
  final bool gewijzigd;
  final bool startSync;
}

class AppStorage {
  static const String _agendaItemsNieuwKey = 'agenda_items_nieuw';

  static const String _dagtaakTemplatesKey = 'dagtaak_templates';

  static const String _dagtaakTemplatesSyncMetaKey =
      'dagtaak_templates_sync_meta';

  static const String _leveranciersKey = 'leveranciers_lijst';

  static const String _leveranciersSyncMetaKey = 'leveranciers_lijst_sync_meta';

  static const String _bibliotheekKey = 'thimaco_algemene_bibliotheek';

  static const String _bibliotheekGewijzigdOpKey =
      'thimaco_algemene_bibliotheek_gewijzigd_op';

  static const String _offerteMailTekstenKey = 'thimaco_offerte_mail_teksten';

  static const String _offerteMailTekstenGewijzigdOpKey =
      'thimaco_offerte_mail_teksten_gewijzigd_op';

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

  static const String _opmetingBuitenjaloezieInstellingenKey =
      'thimaco_opmeting_buitenjaloezie_instellingen';

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

  // THIMACO-CONTROLE: PRIJS-PER-ARTIKEL-BIBLIOTHEEK-OPSLAG-20260813
  static const String _offertePrijsPerArtikelTemplatesKey =
      'thimaco_offerte_prijs_per_artikel_templates';

  static const String _offertePrijsPerArtikelTemplatesSyncMetaKey =
      'thimaco_offerte_prijs_per_artikel_templates_sync_meta';

  static const String _offerteVersiesKey = 'thimaco_offerte_versies';

  static const String _offerteVersiesSyncMetaKey =
      'thimaco_offerte_versies_sync_meta';

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
  // ALGEMENE BIBLIOTHEEK
  // ------------------------------------------------------------

  static Future<BibliotheekData> laadBibliotheek() async {
    final prefs = await openBox();
    final jsonString = prefs.getString(_bibliotheekKey);

    if (jsonString == null || jsonString.trim().isEmpty) {
      return BibliotheekData.leeg();
    }

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map) {
        return BibliotheekData.leeg();
      }

      return BibliotheekData.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return BibliotheekData.leeg();
    }
  }

  static Future<void> bewaarBibliotheek(BibliotheekData data) async {
    final prefs = await openBox();
    final gewijzigdOp = DateTime.now().toUtc().toIso8601String();

    await prefs.setString(_bibliotheekKey, jsonEncode(data.toJson()));
    await prefs.setString(_bibliotheekGewijzigdOpKey, gewijzigdOp);
    await _syncBackup();
  }

  static Future<void> bewaarBibliotheekVoorSync({
    required BibliotheekData data,
    required String gewijzigdOp,
  }) async {
    final prefs = await openBox();

    await prefs.setString(_bibliotheekKey, jsonEncode(data.toJson()));
    await prefs.setString(
      _bibliotheekGewijzigdOpKey,
      gewijzigdOp.trim().isEmpty
          ? DateTime.now().toUtc().toIso8601String()
          : gewijzigdOp.trim(),
    );
  }

  static Future<String> laadBibliotheekJsonVoorSync() async {
    final prefs = await openBox();
    return prefs.getString(_bibliotheekKey) ?? '';
  }

  static Future<String> laadBibliotheekGewijzigdOpVoorSync() async {
    final prefs = await openBox();
    return prefs.getString(_bibliotheekGewijzigdOpKey) ?? '';
  }

  // ------------------------------------------------------------
  // OFFERTE MAILTEKSTEN
  // ------------------------------------------------------------

  static Future<OfferteMailTekstenData> laadOfferteMailTeksten() async {
    final prefs = await openBox();
    final jsonString = prefs.getString(_offerteMailTekstenKey);

    if (jsonString == null || jsonString.trim().isEmpty) {
      return OfferteMailTekstenData.leeg();
    }

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map) {
        return OfferteMailTekstenData.leeg();
      }
      return OfferteMailTekstenData.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } catch (_) {
      return OfferteMailTekstenData.leeg();
    }
  }

  static Future<void> bewaarOfferteMailTeksten(
    OfferteMailTekstenData data,
  ) async {
    final prefs = await openBox();
    final gewijzigdOp = DateTime.now().toUtc().toIso8601String();

    await prefs.setString(_offerteMailTekstenKey, jsonEncode(data.toJson()));
    await prefs.setString(_offerteMailTekstenGewijzigdOpKey, gewijzigdOp);
    await _syncBackup();
  }

  static Future<void> bewaarOfferteMailTekstenVoorSync({
    required OfferteMailTekstenData data,
    required String gewijzigdOp,
  }) async {
    final prefs = await openBox();
    await prefs.setString(_offerteMailTekstenKey, jsonEncode(data.toJson()));
    await prefs.setString(
      _offerteMailTekstenGewijzigdOpKey,
      gewijzigdOp.trim().isEmpty
          ? DateTime.now().toUtc().toIso8601String()
          : gewijzigdOp.trim(),
    );
  }

  static Future<String> laadOfferteMailTekstenJsonVoorSync() async {
    final prefs = await openBox();
    return prefs.getString(_offerteMailTekstenKey) ?? '';
  }

  static Future<String> laadOfferteMailTekstenGewijzigdOpVoorSync() async {
    final prefs = await openBox();
    return prefs.getString(_offerteMailTekstenGewijzigdOpKey) ?? '';
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
  // PRIJS PER ARTIKEL - HERBRUIKBARE BIBLIOTHEEK
  // ------------------------------------------------------------

  static Future<List<OffertePrijsPerArtikelTemplateModel>>
  laadOffertePrijsPerArtikelTemplates() async {
    final prefs = await openBox();
    final records = decodeJsonMapLijstVoorSync(
      prefs.getString(_offertePrijsPerArtikelTemplatesKey),
    );
    final resultaat = <OffertePrijsPerArtikelTemplateModel>[];

    for (final record in records) {
      try {
        final template = OffertePrijsPerArtikelTemplateModel.fromJson(record);
        if (template.isGeldig) resultaat.add(template);
      } catch (_) {
        // Eén beschadigde bibliotheekregel mag de overige regels niet blokkeren.
      }
    }

    resultaat.sort((eerste, tweede) {
      final volgorde = eerste.volgorde.compareTo(tweede.volgorde);
      if (volgorde != 0) return volgorde;
      return eerste.omschrijving.toLowerCase().compareTo(
        tweede.omschrijving.toLowerCase(),
      );
    });

    return resultaat;
  }

  static Future<void> bewaarOffertePrijsPerArtikelTemplates(
    List<OffertePrijsPerArtikelTemplateModel> templates,
  ) async {
    final geldigeTemplates = templates
        .where((template) => template.isGeldig)
        .toList(growable: false);

    await _bewaarJsonMapLijstMetSyncMetadata(
      dataKey: _offertePrijsPerArtikelTemplatesKey,
      metadataKey: _offertePrijsPerArtikelTemplatesSyncMetaKey,
      records: geldigeTemplates.map((template) => template.toJson()).toList(),
      idVoorRecord: _standaardSyncId,
      sync: true,
    );
  }

  static Future<void> bewaarOffertePrijsPerArtikelTemplatesVoorSync(
    List<OffertePrijsPerArtikelTemplateModel> templates,
  ) async {
    final prefs = await openBox();
    await prefs.setString(
      _offertePrijsPerArtikelTemplatesKey,
      encodeJsonMapLijstVoorSync(
        templates
            .where((template) => template.isGeldig)
            .map((template) => template.toJson()),
      ),
    );
  }

  static Future<String>
  laadOffertePrijsPerArtikelTemplatesJsonVoorSync() async {
    final prefs = await openBox();
    return prefs.getString(_offertePrijsPerArtikelTemplatesKey) ?? '';
  }

  static Future<String>
  laadOffertePrijsPerArtikelTemplatesSyncMetadataJsonVoorSync() async {
    final prefs = await openBox();
    return prefs.getString(_offertePrijsPerArtikelTemplatesSyncMetaKey) ?? '';
  }

  static Future<void>
  bewaarOffertePrijsPerArtikelTemplatesSyncMetadataJsonVoorSync(
    String metadataJson,
  ) async {
    final prefs = await openBox();
    await prefs.setString(
      _offertePrijsPerArtikelTemplatesSyncMetaKey,
      metadataJson,
    );
  }

  // ------------------------------------------------------------
  // OFFERTE - BEWERKBARE VARIANTEN + ONDERTEKENDE MOMENTOPNAMES
  // ------------------------------------------------------------

  // Net zoals de opmetingen krijgen offertevarianten één centrale wachtrij.
  // Daardoor kan een update van Offerte 2 nooit een gelijktijdig aangemaakte
  // Offerte 3 of ondertekende momentopname overschrijven.
  static Future<void> _offerteVersiesWachtrij = Future<void>.value();

  static List<OfferteVersieModel> _decodeOfferteVersies(String? jsonString) {
    final records = decodeJsonMapLijstVoorSync(jsonString);
    final resultaat = <OfferteVersieModel>[];

    for (final record in records) {
      try {
        final versie = OfferteVersieModel.fromJson(record);
        if (versie.isGeldig) resultaat.add(versie);
      } catch (_) {
        // Eén beschadigde versie mag de overige offertevarianten niet blokkeren.
      }
    }

    return resultaat;
  }

  static Future<T> muteerOfferteVersiesAtomair<T>(
    FutureOr<AppStorageOfferteVersieMutatieResultaat<T>> Function(
      List<OfferteVersieModel> actueleVersies,
    )
    mutatie,
  ) {
    final completer = Completer<T>();

    _offerteVersiesWachtrij = _offerteVersiesWachtrij.then((_) async {
      try {
        final prefs = await openBox();
        final oudeRecords = decodeJsonMapLijstVoorSync(
          prefs.getString(_offerteVersiesKey),
        );
        final actueel = _decodeOfferteVersies(
          prefs.getString(_offerteVersiesKey),
        );

        final mutatieResultaat = await mutatie(
          List<OfferteVersieModel>.from(actueel),
        );

        if (mutatieResultaat.gewijzigd) {
          final nieuweVersies = mutatieResultaat.versies
              .where((versie) => versie.isGeldig)
              .toList(growable: false);
          final nieuweRecords = nieuweVersies
              .map((versie) => versie.toJson())
              .toList(growable: false);
          final bestaandeMetadata = SyncMergeService.decodeJsonRecordMetadata(
            prefs.getString(_offerteVersiesSyncMetaKey),
          );
          final gewijzigdOp = DateTime.now().toUtc().toIso8601String();
          final nieuweMetadata = SyncMergeService.updateJsonRecordMetadata(
            oudeRecords: oudeRecords,
            nieuweRecords: nieuweRecords,
            bestaandeMetadata: bestaandeMetadata,
            idVoorRecord: _standaardSyncId,
            gewijzigdOp: gewijzigdOp,
          );

          await prefs.setString(
            _offerteVersiesKey,
            encodeJsonMapLijstVoorSync(nieuweRecords),
          );
          await prefs.setString(
            _offerteVersiesSyncMetaKey,
            SyncMergeService.encodeJsonRecordMetadata(nieuweMetadata),
          );

          if (mutatieResultaat.startSync) {
            await _syncBackup();
          }
        }

        completer.complete(mutatieResultaat.resultaat);
      } catch (fout, stackTrace) {
        completer.completeError(fout, stackTrace);
      }
    });

    return completer.future;
  }

  static Future<List<OfferteVersieModel>> laadOfferteVersies() async {
    // Een lezer krijgt nooit een toestand van vóór een reeds gestarte
    // variantmutatie.
    await _offerteVersiesWachtrij;

    final prefs = await openBox();
    final resultaat = _decodeOfferteVersies(
      prefs.getString(_offerteVersiesKey),
    );

    resultaat.sort((eerste, tweede) {
      final project = eerste.projectSleutel.compareTo(tweede.projectSleutel);
      if (project != 0) return project;

      final nummer = eerste.versieNummer.compareTo(tweede.versieNummer);
      if (nummer != 0) return nummer;

      return eerste.opgeslagenOp.compareTo(tweede.opgeslagenOp);
    });

    return resultaat;
  }

  /// Compatibele volledige save. Nieuwe offertecode gebruikt bij voorkeur
  /// [muteerOfferteVersiesAtomair] zodat één variant gericht wordt gewijzigd.
  static Future<void> bewaarOfferteVersies(
    List<OfferteVersieModel> versies,
  ) async {
    await muteerOfferteVersiesAtomair<void>((_) {
      return AppStorageOfferteVersieMutatieResultaat<void>(
        resultaat: null,
        versies: List<OfferteVersieModel>.from(versies),
        gewijzigd: true,
      );
    });
  }

  // ------------------------------------------------------------
  // OPMETING - PROJECT TITELHOOFD
  // ------------------------------------------------------------

  // Projecttitelhoofden bevatten o.a. de keuze "Bereken". Ook deze opslag
  // krijgt één centrale wachtrij, zodat een vertraagde UI-save en een sync
  // nooit tegelijk dezelfde volledige projectmap kunnen terugschrijven.
  static Future<void> _projectTitelhoofdenWachtrij = Future<void>.value();

  static final Map<String, OpmetingProjectTitelhoofd>
  _projectTitelhoofdBasisMomentopnames = <String, OpmetingProjectTitelhoofd>{};

  static const int _maxProjectTitelhoofdBasisMomentopnames = 1000;

  static String _projectTitelhoofdMomentopnameSleutel(
    String projectSleutel,
    OpmetingProjectTitelhoofd titelhoofd,
  ) {
    return '${projectSleutel.trim()}\u0000${titelhoofd.gewijzigdOp.trim()}';
  }

  static void _onthoudProjectTitelhoofdMomentopnames(
    Map<String, OpmetingProjectTitelhoofd> titelhoofden,
  ) {
    for (final entry in titelhoofden.entries) {
      final sleutel = entry.key.trim();
      final gewijzigdOp = entry.value.gewijzigdOp.trim();
      if (sleutel.isEmpty || gewijzigdOp.isEmpty) continue;

      _projectTitelhoofdBasisMomentopnames[_projectTitelhoofdMomentopnameSleutel(
            sleutel,
            entry.value,
          )] =
          entry.value;
    }

    while (_projectTitelhoofdBasisMomentopnames.length >
        _maxProjectTitelhoofdBasisMomentopnames) {
      _projectTitelhoofdBasisMomentopnames.remove(
        _projectTitelhoofdBasisMomentopnames.keys.first,
      );
    }
  }

  static OpmetingProjectTitelhoofd? _zoekProjectTitelhoofdBasisMomentopname(
    OpmetingProjectTitelhoofd titelhoofd,
  ) {
    final gewijzigdOp = titelhoofd.gewijzigdOp.trim();
    if (gewijzigdOp.isEmpty) return null;

    final sleutel = opmetingProjectTitelhoofdSleutel(titelhoofd.klantNaam);
    return _projectTitelhoofdBasisMomentopnames['$sleutel\u0000$gewijzigdOp'];
  }

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

  static Future<T> _muteerProjectTitelhoofdenAtomair<T>(
    FutureOr<AppStorageProjectTitelhoofdMutatieResultaat<T>> Function(
      Map<String, OpmetingProjectTitelhoofd> actueleTitelhoofden,
    )
    mutatie,
  ) {
    final completer = Completer<T>();

    _projectTitelhoofdenWachtrij = _projectTitelhoofdenWachtrij.then((_) async {
      try {
        final prefs = await openBox();
        final actueel = decodeOpmetingProjectTitelhoofdenVoorSync(
          prefs.getString(_opmetingProjectTitelhoofdenKey),
        );
        _onthoudProjectTitelhoofdMomentopnames(actueel);

        final mutatieResultaat = await mutatie(
          Map<String, OpmetingProjectTitelhoofd>.from(actueel),
        );

        if (mutatieResultaat.gewijzigd) {
          final nieuweMap = Map<String, OpmetingProjectTitelhoofd>.from(
            mutatieResultaat.titelhoofden,
          );
          await prefs.setString(
            _opmetingProjectTitelhoofdenKey,
            encodeOpmetingProjectTitelhoofdenVoorSync(nieuweMap),
          );
          _onthoudProjectTitelhoofdMomentopnames(nieuweMap);

          if (mutatieResultaat.startSync) {
            await _syncBackup();
          }
        }

        completer.complete(mutatieResultaat.resultaat);
      } catch (fout, stackTrace) {
        completer.completeError(fout, stackTrace);
      }
    });

    return completer.future;
  }

  static Future<Map<String, OpmetingProjectTitelhoofd>>
  laadOpmetingProjectTitelhoofdenVoorSync() async {
    await _projectTitelhoofdenWachtrij;

    final prefs = await openBox();
    final titelhoofden = decodeOpmetingProjectTitelhoofdenVoorSync(
      prefs.getString(_opmetingProjectTitelhoofdenKey),
    );
    _onthoudProjectTitelhoofdMomentopnames(titelhoofden);
    return titelhoofden;
  }

  static Future<void> bewaarOpmetingProjectTitelhoofdenVoorSync(
    Map<String, OpmetingProjectTitelhoofd> titelhoofden,
  ) async {
    await _muteerProjectTitelhoofdenAtomair<void>((actueel) {
      // OneDrive heeft al een merge uitgevoerd. Controleer hier nogmaals tegen
      // de allernieuwste lokale toestand die tijdens die sync kan zijn ontstaan.
      final samengevoegd = SyncMergeService.mergeProjectTitelhoofden(
        actueel,
        titelhoofden,
      );

      return AppStorageProjectTitelhoofdMutatieResultaat<void>(
        resultaat: null,
        titelhoofden: samengevoegd,
        gewijzigd: !_projectTitelhoofdMapsGelijk(actueel, samengevoegd),
        startSync: false,
      );
    });
  }

  static Future<OpmetingProjectTitelhoofd> laadOpmetingProjectTitelhoofd(
    String klantNaam,
  ) async {
    final titelhoofden = await laadOpmetingProjectTitelhoofdenVoorSync();
    final sleutel = opmetingProjectTitelhoofdSleutel(klantNaam);
    final titelhoofd =
        titelhoofden[sleutel] ??
        OpmetingProjectTitelhoofd(klantNaam: klantNaam.trim());

    if (titelhoofd.gewijzigdOp.trim().isNotEmpty) {
      _projectTitelhoofdBasisMomentopnames[_projectTitelhoofdMomentopnameSleutel(
            sleutel,
            titelhoofd,
          )] =
          titelhoofd;
    }
    return titelhoofd;
  }

  /// Bestaande publieke save blijft bruikbaar, maar schrijft nooit meer buiten
  /// de centrale titelhoofd-wachtrij. Een aantoonbaar oudere snapshot kan een
  /// nieuwere opgeslagen toestand niet terug overschrijven.
  static Future<void> bewaarOpmetingProjectTitelhoofd(
    OpmetingProjectTitelhoofd titelhoofd,
  ) async {
    await _muteerProjectTitelhoofdenAtomair<void>((actueel) {
      final sleutel = opmetingProjectTitelhoofdSleutel(titelhoofd.klantNaam);
      final huidig = actueel[sleutel];

      OpmetingProjectTitelhoofd kandidaat = titelhoofd;
      if (huidig != null) {
        final basis = _zoekProjectTitelhoofdBasisMomentopname(titelhoofd);
        if (basis != null) {
          kandidaat = _driewegSamenvoegenProjectTitelhoofd(
            basis: basis,
            gewijzigd: titelhoofd,
            actueel: huidig,
          );
        } else {
          final huidigeDatum = DateTime.tryParse(huidig.gewijzigdOp);
          final inkomendeDatum = DateTime.tryParse(titelhoofd.gewijzigdOp);

          if (huidigeDatum != null &&
              inkomendeDatum != null &&
              huidigeDatum.isAfter(inkomendeDatum)) {
            kandidaat = huidig;
          }
        }

        if (_projectTitelhoofdInhoudGelijk(huidig, kandidaat)) {
          return AppStorageProjectTitelhoofdMutatieResultaat<void>(
            resultaat: null,
            titelhoofden: actueel,
            gewijzigd: false,
          );
        }
      }

      final opgeslagen = kandidaat.copyWith(
        gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
      );
      final nieuweMap = Map<String, OpmetingProjectTitelhoofd>.from(actueel);
      nieuweMap[sleutel] = opgeslagen;

      return AppStorageProjectTitelhoofdMutatieResultaat<void>(
        resultaat: null,
        titelhoofden: nieuweMap,
        gewijzigd: true,
      );
    });
  }

  /// Expliciete drie-weg-save voor het titelhoofd. [basis] is de toestand vóór
  /// een reeks UI-wijzigingen en [gewijzigd] bevat de uiteindelijke invoer.
  /// Alleen velden die werkelijk tussen basis en gewijzigd veranderden worden
  /// op de nieuwste opgeslagen versie toegepast. Daardoor kan een vertraagde
  /// save bijvoorbeeld "Bereken" niet opnieuw uitvinken.
  static Future<OpmetingProjectTitelhoofd>
  bewaarOpmetingProjectTitelhoofdWijzigingen({
    required OpmetingProjectTitelhoofd basis,
    required OpmetingProjectTitelhoofd gewijzigd,
  }) {
    return _muteerProjectTitelhoofdenAtomair<OpmetingProjectTitelhoofd>((
      actueel,
    ) {
      final oudeSleutel = opmetingProjectTitelhoofdSleutel(basis.klantNaam);
      final nieuweSleutel = opmetingProjectTitelhoofdSleutel(
        gewijzigd.klantNaam,
      );
      final huidig = actueel[oudeSleutel] ?? actueel[nieuweSleutel] ?? basis;

      final kandidaat = _driewegSamenvoegenProjectTitelhoofd(
        basis: basis,
        gewijzigd: gewijzigd,
        actueel: huidig,
      );

      final sleutelGewijzigd = oudeSleutel != nieuweSleutel;
      if (!sleutelGewijzigd &&
          _projectTitelhoofdInhoudGelijk(huidig, kandidaat)) {
        return AppStorageProjectTitelhoofdMutatieResultaat<
          OpmetingProjectTitelhoofd
        >(resultaat: huidig, titelhoofden: actueel, gewijzigd: false);
      }

      final opgeslagen = kandidaat.copyWith(
        gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
      );
      final nieuweMap = Map<String, OpmetingProjectTitelhoofd>.from(actueel);

      if (sleutelGewijzigd) {
        nieuweMap.remove(oudeSleutel);
      }
      nieuweMap[nieuweSleutel] = opgeslagen;

      return AppStorageProjectTitelhoofdMutatieResultaat<
        OpmetingProjectTitelhoofd
      >(resultaat: opgeslagen, titelhoofden: nieuweMap, gewijzigd: true);
    });
  }

  static OpmetingProjectTitelhoofd _driewegSamenvoegenProjectTitelhoofd({
    required OpmetingProjectTitelhoofd basis,
    required OpmetingProjectTitelhoofd gewijzigd,
    required OpmetingProjectTitelhoofd actueel,
  }) {
    final json = _voegMapWijzigingenSamen(
      basis: basis.toJson(),
      gewijzigd: gewijzigd.toJson(),
      actueel: actueel.toJson(),
      hoofdNiveau: true,
    );
    json['gewijzigdOp'] = actueel.gewijzigdOp;
    return OpmetingProjectTitelhoofd.fromJson(json);
  }

  static bool _projectTitelhoofdInhoudGelijk(
    OpmetingProjectTitelhoofd eerste,
    OpmetingProjectTitelhoofd tweede,
  ) {
    final eersteJson = Map<String, dynamic>.from(eerste.toJson())
      ..remove('gewijzigdOp');
    final tweedeJson = Map<String, dynamic>.from(tweede.toJson())
      ..remove('gewijzigdOp');
    return _jsonGelijk(eersteJson, tweedeJson);
  }

  static bool _projectTitelhoofdMapsGelijk(
    Map<String, OpmetingProjectTitelhoofd> eerste,
    Map<String, OpmetingProjectTitelhoofd> tweede,
  ) {
    if (eerste.length != tweede.length) return false;

    for (final entry in eerste.entries) {
      final ander = tweede[entry.key];
      if (ander == null || !_jsonGelijk(entry.value.toJson(), ander.toJson())) {
        return false;
      }
    }
    return true;
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
  // OPMETING - INSTELLINGEN BUITENJALOEZIEËN
  // ------------------------------------------------------------

  static OpmetingBuitenjaloezieInstellingen
  _decodeOpmetingBuitenjaloezieInstellingen(String? jsonString) {
    if (jsonString == null || jsonString.trim().isEmpty) {
      return const OpmetingBuitenjaloezieInstellingen();
    }

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map) {
        return const OpmetingBuitenjaloezieInstellingen();
      }

      return OpmetingBuitenjaloezieInstellingen.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } catch (_) {
      return const OpmetingBuitenjaloezieInstellingen();
    }
  }

  static String encodeOpmetingBuitenjaloezieInstellingenVoorSync(
    OpmetingBuitenjaloezieInstellingen instellingen,
  ) {
    return jsonEncode(instellingen.toJson());
  }

  static Future<OpmetingBuitenjaloezieInstellingen>
  laadOpmetingBuitenjaloezieInstellingen() async {
    final prefs = await openBox();
    return _decodeOpmetingBuitenjaloezieInstellingen(
      prefs.getString(_opmetingBuitenjaloezieInstellingenKey),
    );
  }

  static Future<void> bewaarOpmetingBuitenjaloezieInstellingen(
    OpmetingBuitenjaloezieInstellingen instellingen,
  ) async {
    final prefs = await openBox();
    final voorOpslag = instellingen.gewijzigdOp.trim().isEmpty
        ? instellingen.metWijzigingsDatum()
        : instellingen;

    await prefs.setString(
      _opmetingBuitenjaloezieInstellingenKey,
      encodeOpmetingBuitenjaloezieInstellingenVoorSync(voorOpslag),
    );

    await _syncBackup();
  }

  static Future<void> bewaarOpmetingBuitenjaloezieInstellingenVoorSync(
    OpmetingBuitenjaloezieInstellingen instellingen,
  ) async {
    final prefs = await openBox();
    await prefs.setString(
      _opmetingBuitenjaloezieInstellingenKey,
      encodeOpmetingBuitenjaloezieInstellingenVoorSync(instellingen),
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

  // Alle wijzigingen aan de positielijst lopen door exact dezelfde wachtrij.
  // Daardoor kan geen fiche, prijsberekening, kopieeractie of sync nog tussen
  // het lezen en schrijven van een andere opmetingsmutatie terechtkomen.
  static Future<void> _opmetingenWachtrij = Future<void>.value();

  // Houd enkele geladen basisversies bij. Oudere gespecialiseerde fiches geven
  // bij bewaren nog hun oorspronkelijke [gewijzigdOp] mee. Daarmee kan
  // [werkOpmetingBij] een drie-weg-merge uitvoeren en uitsluitend de velden
  // toepassen die de fiche werkelijk heeft gewijzigd.
  static final Map<String, OpmetingOverzichtRaamItem>
  _opmetingBasisMomentopnames = <String, OpmetingOverzichtRaamItem>{};

  static const int _maxOpmetingBasisMomentopnames = 4000;

  static String _opmetingMomentopnameSleutel(
    OpmetingOverzichtRaamItem opmeting,
  ) {
    return '${opmeting.id.trim()}\u0000${opmeting.gewijzigdOp.trim()}';
  }

  static void _onthoudOpmetingMomentopnames(
    Iterable<OpmetingOverzichtRaamItem> opmetingen,
  ) {
    for (final opmeting in opmetingen) {
      final id = opmeting.id.trim();
      if (id.isEmpty) continue;

      _opmetingBasisMomentopnames[_opmetingMomentopnameSleutel(opmeting)] =
          opmeting;
    }

    while (_opmetingBasisMomentopnames.length >
        _maxOpmetingBasisMomentopnames) {
      _opmetingBasisMomentopnames.remove(
        _opmetingBasisMomentopnames.keys.first,
      );
    }
  }

  static OpmetingOverzichtRaamItem? _zoekOpmetingBasisMomentopname(
    OpmetingOverzichtRaamItem opmeting,
  ) {
    final id = opmeting.id.trim();
    final gewijzigdOp = opmeting.gewijzigdOp.trim();
    if (id.isEmpty || gewijzigdOp.isEmpty) return null;

    return _opmetingBasisMomentopnames['$id\u0000$gewijzigdOp'];
  }

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

  static Future<T> muteerOpmetingenAtomair<T>(
    FutureOr<AppStorageOpmetingMutatieResultaat<T>> Function(
      List<OpmetingOverzichtRaamItem> actueleOpmetingen,
    )
    mutatie,
  ) {
    final completer = Completer<T>();

    _opmetingenWachtrij = _opmetingenWachtrij.then((_) async {
      try {
        final prefs = await openBox();
        final actueel = _decodeOpmetingen(prefs.getString(_opmetingenKey));
        _onthoudOpmetingMomentopnames(actueel);

        final mutatieResultaat = await mutatie(
          List<OpmetingOverzichtRaamItem>.from(actueel),
        );

        if (mutatieResultaat.gewijzigd) {
          final nieuweLijst = List<OpmetingOverzichtRaamItem>.from(
            mutatieResultaat.opmetingen,
          );
          await prefs.setString(
            _opmetingenKey,
            encodeOpmetingenVoorSync(nieuweLijst),
          );
          _onthoudOpmetingMomentopnames(nieuweLijst);

          if (mutatieResultaat.startSync) {
            await _syncBackup();
          }
        }

        completer.complete(mutatieResultaat.resultaat);
      } catch (fout, stackTrace) {
        completer.completeError(fout, stackTrace);
      }
    });

    return completer.future;
  }

  static Future<List<OpmetingOverzichtRaamItem>>
  laadOpmetingenVoorSync() async {
    // Een lezer krijgt nooit een toestand van vóór een reeds gestarte mutatie.
    await _opmetingenWachtrij;

    final prefs = await openBox();
    final opmetingen = _decodeOpmetingen(prefs.getString(_opmetingenKey));
    _onthoudOpmetingMomentopnames(opmetingen);
    return opmetingen;
  }

  static Future<List<OpmetingOverzichtRaamItem>> laadOpmetingen() async {
    final alleOpmetingen = await laadOpmetingenVoorSync();

    // Volgorde bewust behouden zoals opgeslagen.
    // Daardoor blijft Pos 1 bovenaan staan en komt elke nieuwe positie onderaan.
    return alleOpmetingen.where((opmeting) {
      return !opmeting.isVerwijderd;
    }).toList();
  }

  /// Veilige lijstsave voor bestaande aanroepers die nog een volledige lijst
  /// aanleveren. Nieuwere records die ondertussen in de opslag zijn gekomen
  /// worden nooit verwijderd door een oudere snapshot.
  static Future<void> bewaarOpmetingen(
    List<OpmetingOverzichtRaamItem> opmetingen,
  ) async {
    await muteerOpmetingenAtomair<void>((actueel) {
      final samengevoegd = _voegOpmetingLijstenVeiligSamen(
        actueel: actueel,
        inkomend: opmetingen,
        inkomendWintBijGelijkeDatum: true,
      );

      final gewijzigd = !_opmetingLijstenGelijk(actueel, samengevoegd);
      return AppStorageOpmetingMutatieResultaat<void>(
        resultaat: null,
        opmetingen: samengevoegd,
        gewijzigd: gewijzigd,
      );
    });
  }

  /// Sync-variant: merge de aangeleverde syncmomentopname nog één keer met de
  /// allernieuwste lokale opslag binnen dezelfde atomaire lock. Zo kan een
  /// lokale invoer die tijdens een OneDrive-download ontstond niet verdwijnen.
  static Future<void> bewaarOpmetingenVoorSync(
    List<OpmetingOverzichtRaamItem> opmetingen,
  ) async {
    await muteerOpmetingenAtomair<void>((actueel) {
      final samengevoegd = _voegOpmetingLijstenVeiligSamen(
        actueel: actueel,
        inkomend: opmetingen,
        inkomendWintBijGelijkeDatum: false,
      );

      return AppStorageOpmetingMutatieResultaat<void>(
        resultaat: null,
        opmetingen: samengevoegd,
        gewijzigd: !_opmetingLijstenGelijk(actueel, samengevoegd),
        startSync: false,
      );
    });
  }

  static Future<OpmetingOverzichtRaamItem> voegOpmetingToe(
    OpmetingOverzichtRaamItem opmeting,
  ) {
    return muteerOpmetingenAtomair<OpmetingOverzichtRaamItem>((actueel) {
      var id = opmeting.id.trim();

      if (id.isEmpty || actueel.any((bestaand) => bestaand.id == id)) {
        final basis = DateTime.now().microsecondsSinceEpoch.toString();
        id = basis;
        var teller = 2;
        while (actueel.any((bestaand) => bestaand.id == id)) {
          id = '${basis}_$teller';
          teller++;
        }
      }

      final opmetingVoorOpslag = opmeting.copyWith(
        id: id,
        gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
        isVerwijderd: false,
      );

      final resultaat = List<OpmetingOverzichtRaamItem>.from(actueel)
        ..add(opmetingVoorOpslag);

      return AppStorageOpmetingMutatieResultaat<OpmetingOverzichtRaamItem>(
        resultaat: opmetingVoorOpslag,
        opmetingen: resultaat,
        gewijzigd: true,
      );
    });
  }

  static Future<OpmetingOverzichtRaamItem> werkOpmetingBij(
    OpmetingOverzichtRaamItem opmeting,
  ) {
    return muteerOpmetingenAtomair<OpmetingOverzichtRaamItem>((actueel) {
      final id = opmeting.id.trim();
      if (id.isEmpty) {
        throw StateError('Een bestaande opmeting kan niet zonder ID bewaren.');
      }

      final index = actueel.indexWhere((bestaand) => bestaand.id == id);
      if (index < 0) {
        // Een oude, reeds verwijderde fiche mag niet stil opnieuw aangemaakt
        // worden. Alleen echte nieuwe fiches horen via [voegOpmetingToe] te lopen.
        throw StateError('Positie $id bestaat niet meer in de opslag.');
      }

      final huidige = actueel[index];
      final basis = _zoekOpmetingBasisMomentopname(opmeting);

      OpmetingOverzichtRaamItem kandidaat;
      if (basis != null) {
        kandidaat = _driewegSamenvoegenPositie(
          basis: basis,
          gewijzigd: opmeting,
          actueel: huidige,
        );
      } else if (opmeting.gewijzigdOp.trim() == huidige.gewijzigdOp.trim()) {
        kandidaat = opmeting;
      } else {
        final inkomendeDatum = DateTime.tryParse(opmeting.gewijzigdOp);
        final huidigeDatum = DateTime.tryParse(huidige.gewijzigdOp);

        // Zonder bekende basisversie krijgt een aantoonbaar nieuwere invoer
        // voorrang. Een oudere onbekende snapshot mag nooit nieuwere gegevens
        // terug overschrijven.
        kandidaat =
            inkomendeDatum != null &&
                (huidigeDatum == null || inkomendeDatum.isAfter(huidigeDatum))
            ? opmeting
            : huidige;
      }

      kandidaat = kandidaat.copyWith(
        id: huidige.id,
        isVerwijderd: huidige.isVerwijderd,
      );

      if (_positieInhoudGelijk(huidige, kandidaat)) {
        return AppStorageOpmetingMutatieResultaat<OpmetingOverzichtRaamItem>(
          resultaat: huidige,
          opmetingen: actueel,
          gewijzigd: false,
        );
      }

      final bijgewerkt = kandidaat.copyWith(
        gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
      );
      final nieuweLijst = List<OpmetingOverzichtRaamItem>.from(actueel);
      nieuweLijst[index] = bijgewerkt;

      return AppStorageOpmetingMutatieResultaat<OpmetingOverzichtRaamItem>(
        resultaat: bijgewerkt,
        opmetingen: nieuweLijst,
        gewijzigd: true,
      );
    });
  }

  static Future<bool> verplaatsOpmetingBinnenKlant({
    required String klantNaam,
    required String opmetingId,
    required int richting,
  }) {
    if (richting != -1 && richting != 1) {
      return Future<bool>.value(false);
    }

    return muteerOpmetingenAtomair<bool>((actueel) {
      final klantSleutel = klantNaam.trim().toLowerCase();
      final klantIndices = <int>[];

      for (var index = 0; index < actueel.length; index++) {
        final opmeting = actueel[index];

        if (opmeting.isVerwijderd) continue;
        if (opmeting.klantNaam.trim().toLowerCase() != klantSleutel) continue;

        klantIndices.add(index);
      }

      final huidigePositie = klantIndices.indexWhere(
        (index) => actueel[index].id == opmetingId,
      );
      if (huidigePositie < 0) {
        return AppStorageOpmetingMutatieResultaat<bool>(
          resultaat: false,
          opmetingen: actueel,
          gewijzigd: false,
        );
      }

      final nieuwePositie = huidigePositie + richting;
      if (nieuwePositie < 0 || nieuwePositie >= klantIndices.length) {
        return AppStorageOpmetingMutatieResultaat<bool>(
          resultaat: false,
          opmetingen: actueel,
          gewijzigd: false,
        );
      }

      final huidigeIndex = klantIndices[huidigePositie];
      final nieuweIndex = klantIndices[nieuwePositie];
      final nu = DateTime.now().toUtc().toIso8601String();
      final huidige = actueel[huidigeIndex];
      final andere = actueel[nieuweIndex];
      final nieuweLijst = List<OpmetingOverzichtRaamItem>.from(actueel);

      nieuweLijst[huidigeIndex] = andere.copyWith(gewijzigdOp: nu);
      nieuweLijst[nieuweIndex] = huidige.copyWith(gewijzigdOp: nu);

      return AppStorageOpmetingMutatieResultaat<bool>(
        resultaat: true,
        opmetingen: nieuweLijst,
        gewijzigd: true,
      );
    });
  }

  static Future<void> verwijderOpmeting(String id) async {
    await verwijderOpmetingen(<String>{id});
  }

  static Future<int> verwijderOpmetingen(
    Iterable<String> ids, {
    bool startSync = true,
  }) {
    final teWissen = ids
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();

    return muteerOpmetingenAtomair<int>((actueel) {
      if (teWissen.isEmpty) {
        return AppStorageOpmetingMutatieResultaat<int>(
          resultaat: 0,
          opmetingen: actueel,
          gewijzigd: false,
        );
      }

      final nu = DateTime.now().toUtc().toIso8601String();
      var aantal = 0;
      final nieuweLijst = <OpmetingOverzichtRaamItem>[];

      for (final opmeting in actueel) {
        if (!teWissen.contains(opmeting.id) || opmeting.isVerwijderd) {
          nieuweLijst.add(opmeting);
          continue;
        }

        aantal++;
        nieuweLijst.add(opmeting.copyWith(isVerwijderd: true, gewijzigdOp: nu));
      }

      return AppStorageOpmetingMutatieResultaat<int>(
        resultaat: aantal,
        opmetingen: nieuweLijst,
        gewijzigd: aantal > 0,
        startSync: startSync,
      );
    });
  }

  static List<OpmetingOverzichtRaamItem> _voegOpmetingLijstenVeiligSamen({
    required List<OpmetingOverzichtRaamItem> actueel,
    required List<OpmetingOverzichtRaamItem> inkomend,
    required bool inkomendWintBijGelijkeDatum,
  }) {
    final actuelePerId = <String, OpmetingOverzichtRaamItem>{
      for (final item in actueel)
        if (item.id.trim().isNotEmpty) item.id.trim(): item,
    };
    final inkomendePerId = <String, OpmetingOverzichtRaamItem>{
      for (final item in inkomend)
        if (item.id.trim().isNotEmpty) item.id.trim(): item,
    };

    final winnaarPerId = <String, OpmetingOverzichtRaamItem>{};
    final nu = DateTime.now().toUtc().toIso8601String();

    for (final id in <String>{...actuelePerId.keys, ...inkomendePerId.keys}) {
      final huidig = actuelePerId[id];
      final kandidaat = inkomendePerId[id];

      if (huidig == null) {
        if (kandidaat == null) continue;

        // Als deze versie eerder door dit proces geladen werd maar intussen
        // volledig uit de opslag verdwenen is, is dit een oude momentopname.
        // Die mag een verwijderd record niet opnieuw aanmaken.
        final bekendeBasis = _zoekOpmetingBasisMomentopname(kandidaat);
        if (bekendeBasis == null) {
          winnaarPerId[id] = kandidaat;
        }
        continue;
      }

      if (kandidaat == null) {
        // Ontbreken in een aangeleverde volledige lijst is nooit voldoende om
        // een positie te verwijderen. Verwijderen gebeurt altijd via tombstones.
        winnaarPerId[id] = huidig;
        continue;
      }

      final basis = _zoekOpmetingBasisMomentopname(kandidaat);
      if (basis != null) {
        if (_positieInhoudGelijk(basis, kandidaat)) {
          // De aanroeper heeft dit record zelf niet gewijzigd. Bewaar dus
          // altijd wat ondertussen werkelijk in de opslag staat.
          winnaarPerId[id] = huidig;
          continue;
        }

        // De aanroeper vertrok aantoonbaar van [basis]. Pas alleen zijn echte
        // veldwijzigingen toe op de nieuwste versie. Dit beschermt zowel
        // gespecialiseerde fiches als achtergrondberekeningen.
        var samengevoegd = _driewegSamenvoegenPositie(
          basis: basis,
          gewijzigd: kandidaat,
          actueel: huidig,
        ).copyWith(id: huidig.id);

        if (_positieInhoudGelijk(huidig, samengevoegd)) {
          winnaarPerId[id] = huidig;
        } else {
          samengevoegd = samengevoegd.copyWith(gewijzigdOp: nu);
          winnaarPerId[id] = samengevoegd;
        }
        continue;
      }

      final huidigeDatum = DateTime.tryParse(huidig.gewijzigdOp);
      final inkomendeDatum = DateTime.tryParse(kandidaat.gewijzigdOp);

      if (inkomendeDatum != null &&
          (huidigeDatum == null || inkomendeDatum.isAfter(huidigeDatum))) {
        winnaarPerId[id] = kandidaat;
      } else if (huidigeDatum != null &&
          inkomendeDatum != null &&
          huidigeDatum.isAfter(inkomendeDatum)) {
        winnaarPerId[id] = huidig;
      } else {
        winnaarPerId[id] = inkomendWintBijGelijkeDatum ? kandidaat : huidig;
      }
    }

    // Een verouderde volledige lijst mag ook de recent gewijzigde volgorde
    // niet terugzetten. Daarom blijft de actuele opslagvolgorde leidend. Nieuwe
    // records uit de inkomende lijst worden daarna in hun inkomende volgorde
    // toegevoegd. Expliciet verplaatsen/kopiëren gebruikt de atomaire API en
    // kan de volgorde dus wel doelbewust wijzigen.
    final resultaat = <OpmetingOverzichtRaamItem>[];
    final toegevoegd = <String>{};

    for (final item in actueel) {
      final id = item.id.trim();
      final winnaar = winnaarPerId[id];
      if (id.isEmpty || winnaar == null || !toegevoegd.add(id)) continue;
      resultaat.add(winnaar);
    }

    for (final item in inkomend) {
      final id = item.id.trim();
      final winnaar = winnaarPerId[id];
      if (id.isEmpty || winnaar == null || !toegevoegd.add(id)) continue;
      resultaat.add(winnaar);
    }

    return resultaat;
  }

  static bool _opmetingLijstenGelijk(
    List<OpmetingOverzichtRaamItem> eerste,
    List<OpmetingOverzichtRaamItem> tweede,
  ) {
    if (eerste.length != tweede.length) return false;

    for (var index = 0; index < eerste.length; index++) {
      if (!_jsonGelijk(eerste[index].toJson(), tweede[index].toJson())) {
        return false;
      }
    }
    return true;
  }

  static OpmetingOverzichtRaamItem _driewegSamenvoegenPositie({
    required OpmetingOverzichtRaamItem basis,
    required OpmetingOverzichtRaamItem gewijzigd,
    required OpmetingOverzichtRaamItem actueel,
  }) {
    final json = _voegMapWijzigingenSamen(
      basis: basis.toJson(),
      gewijzigd: gewijzigd.toJson(),
      actueel: actueel.toJson(),
      hoofdNiveau: true,
    );

    json['id'] = actueel.id;
    json['gewijzigdOp'] = actueel.gewijzigdOp;
    return OpmetingOverzichtRaamItem.fromJson(json);
  }

  static Map<String, dynamic> _voegMapWijzigingenSamen({
    required Map<String, dynamic> basis,
    required Map<String, dynamic> gewijzigd,
    required Map<String, dynamic> actueel,
    bool hoofdNiveau = false,
  }) {
    final resultaat = <String, dynamic>{
      for (final entry in actueel.entries)
        entry.key: _kopieJsonWaarde(entry.value),
    };
    final sleutels = <String>{...basis.keys, ...gewijzigd.keys};

    for (final sleutel in sleutels) {
      if (hoofdNiveau && (sleutel == 'id' || sleutel == 'gewijzigdOp')) {
        continue;
      }

      final basisHeeft = basis.containsKey(sleutel);
      final gewijzigdHeeft = gewijzigd.containsKey(sleutel);

      if (basisHeeft == gewijzigdHeeft &&
          _jsonGelijk(basis[sleutel], gewijzigd[sleutel])) {
        continue;
      }

      if (!gewijzigdHeeft) {
        resultaat.remove(sleutel);
        continue;
      }

      final basisWaarde = basis[sleutel];
      final gewijzigdeWaarde = gewijzigd[sleutel];
      final actueleWaarde = resultaat[sleutel];

      if (basisWaarde is Map &&
          gewijzigdeWaarde is Map &&
          actueleWaarde is Map) {
        resultaat[sleutel] = _voegMapWijzigingenSamen(
          basis: Map<String, dynamic>.from(basisWaarde),
          gewijzigd: Map<String, dynamic>.from(gewijzigdeWaarde),
          actueel: Map<String, dynamic>.from(actueleWaarde),
        );
        continue;
      }

      resultaat[sleutel] = _kopieJsonWaarde(gewijzigdeWaarde);
    }

    return resultaat;
  }

  static bool _positieInhoudGelijk(
    OpmetingOverzichtRaamItem eerste,
    OpmetingOverzichtRaamItem tweede,
  ) {
    final eersteJson = Map<String, dynamic>.from(eerste.toJson())
      ..remove('gewijzigdOp');
    final tweedeJson = Map<String, dynamic>.from(tweede.toJson())
      ..remove('gewijzigdOp');

    return _jsonGelijk(eersteJson, tweedeJson);
  }

  static bool _jsonGelijk(Object? eerste, Object? tweede) {
    if (identical(eerste, tweede)) return true;

    if (eerste is Map && tweede is Map) {
      if (eerste.length != tweede.length) return false;
      for (final sleutel in eerste.keys) {
        if (!tweede.containsKey(sleutel) ||
            !_jsonGelijk(eerste[sleutel], tweede[sleutel])) {
          return false;
        }
      }
      return true;
    }

    if (eerste is List && tweede is List) {
      if (eerste.length != tweede.length) return false;
      for (var index = 0; index < eerste.length; index++) {
        if (!_jsonGelijk(eerste[index], tweede[index])) return false;
      }
      return true;
    }

    return eerste == tweede;
  }

  static Object? _kopieJsonWaarde(Object? waarde) {
    if (waarde is Map) {
      return <String, dynamic>{
        for (final entry in waarde.entries)
          entry.key.toString(): _kopieJsonWaarde(entry.value),
      };
    }
    if (waarde is List) {
      return waarde.map(_kopieJsonWaarde).toList(growable: false);
    }
    return waarde;
  }
}
