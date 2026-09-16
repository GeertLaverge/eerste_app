// THIMACO-CONTROLE: MODULE-DELTA-SYNC-LOCAL-FIRST-20260914
// THIMACO-CONTROLE: SYNC-PERFORMANCE-WORKER-ISOLATES-FASE2-20260914
// THIMACO-CONTROLE: SYNC-PERFORMANCE-ETAG-DEBOUNCE-20260914
// THIMACO-CONTROLE: MULTI-DEVICE-EERSTE-VOLLEDIGE-SYNC-20260913
// THIMACO-CONTROLE: ONEDRIVE-ZONDER-OUDE-OFFERTEVERSIES-20260912
// THIMACO-CONTROLE: ONEDRIVE-UPLOAD-DOWNLOAD-GESERIALISEERD-20260901
// THIMACO-CONTROLE: PRIJS-VERDEELD-OVER-BIBLIOTHEEK-ONEDRIVE-SYNC-20260815
// THIMACO-CONTROLE: LEGACY-PRIJS-PROFIELEN-NIET-MEER-SYNCEN-20260815
// THIMACO-CONTROLE: VASTE-INZETHOR-STANDAARDPRIJS-EIGEN-ONEDRIVE-SYNC-20260815
// THIMACO-CONTROLE: CENTRALE-TECHNISCHE-KEUZEPRIJZEN-ONEDRIVE-SYNC-20260815
// THIMACO-CONTROLE: PRIJS-VOOR-ALLE-POSITIES-BIBLIOTHEEK-ONEDRIVE-SYNC-20260815
// THIMACO-CONTROLE: PRIJS-PER-ARTIKEL-BIBLIOTHEEK-ONEDRIVE-SYNC-20260814
// THIMACO-CONTROLE: ONEDRIVE-NOOIT-INTERACTIEF-TIJDENS-AUTOMATISCHE-SYNC-20260805
// THIMACO-CONTROLE: ALGEMENE-PRIJSREGELS-ONEDRIVE-SYNC-FASE5-20260805
// THIMACO-CONTROLE: BIBLIOTHEEK-MAILTEKSTEN-ONEDRIVE-SYNC-FASE4-20260805
// THIMACO-CONTROLE: OPMEETINSTELLINGEN-ONEDRIVE-SYNC-FASE3-20260805
// THIMACO-CONTROLE: OPMEETINSTELLINGEN-ONEDRIVE-SYNC-FASE2-20260805
// THIMACO-CONTROLE: MAGAZIJN-ONEDRIVE-SYNC-COMPILE-FIX-20260805
// THIMACO-CONTROLE: PLOOIWERKEN-INSTELLINGEN-ONEDRIVE-20260728
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onedrive_auth_service.dart';

import '/helpers/Agenda/agenda_item.dart';
import '/helpers/klanten/fiche/klantenfiche_model.dart';
import '/helpers/opmeting/overzicht/opmeting_overzicht_model.dart';
import 'sync_merge_service.dart';
import '../app_storage.dart';

class OneDriveSyncService {
  // JSON en modelconversies zijn CPU-werk. `unawaited` maakt zulke berekeningen
  // niet automatisch achtergrondwerk; zonder worker-isolate blijven ze de
  // Flutter UI-isolate blokkeren. De zwaarste stappen lopen daarom via compute.
  static Map<String, dynamic> _decodeJsonObjectWorker(String jsonTekst) {
    final decoded = jsonDecode(jsonTekst);
    if (decoded is! Map) {
      return <String, dynamic>{};
    }
    return Map<String, dynamic>.from(decoded);
  }

  static String _encodeJsonWorker(Map<String, dynamic> data) {
    return jsonEncode(data);
  }

  static Map<String, List<AgendaItem>> _decodeAgendaWorker(String jsonString) {
    if (jsonString.isEmpty) {
      return <String, List<AgendaItem>>{};
    }

    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    return data.map((datumKey, lijst) {
      final items = (lijst as List<dynamic>)
          .map(
            (item) => AgendaItem.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
      return MapEntry(datumKey, items);
    });
  }

  static String _encodeAgendaWorker(Map<String, List<AgendaItem>> data) {
    final jsonMap = data.map((datumKey, items) {
      return MapEntry(
        datumKey,
        items.map((item) => item.toJson()).toList(),
      );
    });
    return jsonEncode(jsonMap);
  }

  static List<KlantenficheModel> _decodeKlantenWorker(String jsonString) {
    if (jsonString.isEmpty) {
      return <KlantenficheModel>[];
    }

    final lijst = jsonDecode(jsonString) as List<dynamic>;
    return lijst
        .map(
          (item) => KlantenficheModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  static String _encodeKlantenWorker(List<KlantenficheModel> fiches) {
    return jsonEncode(fiches.map((fiche) => fiche.toJson()).toList());
  }

  static List<OpmetingOverzichtRaamItem> _decodeOpmetingenWorker(
    String jsonString,
  ) {
    if (jsonString.isEmpty) {
      return <OpmetingOverzichtRaamItem>[];
    }

    final lijst = jsonDecode(jsonString) as List<dynamic>;
    return lijst
        .whereType<Map>()
        .map(
          (item) => OpmetingOverzichtRaamItem.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  static String _encodeOpmetingenWorker(
    List<OpmetingOverzichtRaamItem> opmetingen,
  ) {
    return jsonEncode(
      opmetingen.map((opmeting) => opmeting.toJson()).toList(),
    );
  }

  static Map<String, List<AgendaItem>> _mergeAgendaWorker(
    List<Map<String, List<AgendaItem>>> bronnen,
  ) {
    return SyncMergeService.mergeAgendaMap(bronnen[0], bronnen[1]);
  }

  static List<KlantenficheModel> _mergeKlantenWorker(
    List<List<KlantenficheModel>> bronnen,
  ) {
    return SyncMergeService.mergeKlantenFiches(bronnen[0], bronnen[1]);
  }

  static List<OpmetingOverzichtRaamItem> _mergeOpmetingenWorker(
    List<List<OpmetingOverzichtRaamItem>> bronnen,
  ) {
    return SyncMergeService.mergeOpmetingen(bronnen[0], bronnen[1]);
  }

  static Future<Map<String, dynamic>> _decodeJsonObjectAchtergrond(
    String jsonTekst,
  ) {
    return compute(_decodeJsonObjectWorker, jsonTekst);
  }

  static Future<String> _encodeJsonAchtergrond(Map<String, dynamic> data) {
    return compute(_encodeJsonWorker, Map<String, dynamic>.from(data));
  }

  static Future<Map<String, List<AgendaItem>>> _decodeAgendaAchtergrond(
    String? jsonString,
  ) {
    return compute(_decodeAgendaWorker, jsonString ?? '');
  }

  static Future<String> _encodeAgendaAchtergrond(
    Map<String, List<AgendaItem>> data,
  ) {
    return compute(
      _encodeAgendaWorker,
      <String, List<AgendaItem>>{
        for (final entry in data.entries)
          entry.key: List<AgendaItem>.from(entry.value),
      },
    );
  }

  static Future<List<KlantenficheModel>> _decodeKlantenAchtergrond(
    String? jsonString,
  ) {
    return compute(_decodeKlantenWorker, jsonString ?? '');
  }

  static Future<String> _encodeKlantenAchtergrond(
    List<KlantenficheModel> fiches,
  ) {
    return compute(_encodeKlantenWorker, List<KlantenficheModel>.from(fiches));
  }

  static Future<List<OpmetingOverzichtRaamItem>>
  _decodeOpmetingenAchtergrond(String? jsonString) {
    return compute(_decodeOpmetingenWorker, jsonString ?? '');
  }

  static Future<String> _encodeOpmetingenAchtergrond(
    List<OpmetingOverzichtRaamItem> opmetingen,
  ) {
    return compute(
      _encodeOpmetingenWorker,
      List<OpmetingOverzichtRaamItem>.from(opmetingen),
    );
  }

  static Future<Map<String, List<AgendaItem>>> _mergeAgendaAchtergrond(
    Map<String, List<AgendaItem>> lokaal,
    Map<String, List<AgendaItem>> cloud,
  ) {
    return compute(
      _mergeAgendaWorker,
      <Map<String, List<AgendaItem>>>[lokaal, cloud],
    );
  }

  static Future<List<KlantenficheModel>> _mergeKlantenAchtergrond(
    List<KlantenficheModel> lokaal,
    List<KlantenficheModel> cloud,
  ) {
    return compute(
      _mergeKlantenWorker,
      <List<KlantenficheModel>>[lokaal, cloud],
    );
  }

  static Future<List<OpmetingOverzichtRaamItem>> _mergeOpmetingenAchtergrond(
    List<OpmetingOverzichtRaamItem> lokaal,
    List<OpmetingOverzichtRaamItem> cloud,
  ) {
    return compute(
      _mergeOpmetingenWorker,
      <List<OpmetingOverzichtRaamItem>>[lokaal, cloud],
    );
  }

  /// Geeft Flutter tussen grotere syncfasen expliciet een framekans.
  /// Dit is aanvullend op de worker-isolates en voorkomt lange aaneengesloten
  /// reeksen kleine merges op de UI-isolate.
  static Future<void> _geefUiTijd() => Future<void>.delayed(Duration.zero);

  static const String _backupDatumKey = 'laatste_backup_datum';
  static const String _oneDriveBackupEtagKey =
      'thimaco_onedrive_backup_etag_v1';

  // Alleen lokaal op dit toestel. Deze sleutels worden bewust niet naar
  // OneDrive gesynchroniseerd.
  static const String _eersteVolledigeSyncGestartKey =
      'thimaco_eerste_volledige_sync_gestart_v1';
  static const String _eersteVolledigeSyncVoltooidKey =
      'thimaco_eerste_volledige_sync_voltooid_v1';

  static const String _lokaleWijzigingOpenstaandKey =
      'lokale_wijziging_openstaand';

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

  static const String _offerteAlgemenePrijsregelsKey =
      'thimaco_offerte_algemene_prijsregels';

  static const String _offertePrijsPerArtikelTemplatesKey =
      'thimaco_offerte_prijs_per_artikel_templates';
  static const String _offertePrijsPerArtikelTemplatesSyncMetaKey =
      'thimaco_offerte_prijs_per_artikel_templates_sync_meta';

  static const String _offertePrijsVoorAllePositiesTemplatesKey =
      'thimaco_offerte_prijs_voor_alle_posities_templates';
  static const String _offertePrijsVoorAllePositiesTemplatesSyncMetaKey =
      'thimaco_offerte_prijs_voor_alle_posities_templates_sync_meta';

  static const String _offertePrijsVerdeeldOverTemplatesKey =
      'thimaco_offerte_prijs_verdeeld_over_templates';
  static const String _offertePrijsVerdeeldOverTemplatesSyncMetaKey =
      'thimaco_offerte_prijs_verdeeld_over_templates_sync_meta';

  static const String _offerteTechnischeKeuzePrijzenKey =
      'thimaco_offerte_technische_keuze_prijzen';
  static const String _offerteTechnischeKeuzePrijzenSyncMetaKey =
      'thimaco_offerte_technische_keuze_prijzen_sync_meta';

  static const String _offerteVasteInzethorStandaardPrijsinstellingenKey =
      'thimaco_offerte_vaste_inzethor_standaard_prijsinstellingen';
  static const String
  _offerteVasteInzethorStandaardPrijsinstellingenSyncMetaKey =
      'thimaco_offerte_vaste_inzethor_standaard_prijsinstellingen_sync_meta';

  static const String _notitiesKey = 'thimaco_notities';
  static const String _notitiesSyncMetaKey = 'thimaco_notities_sync_meta';
  static const String _notitieActiesKey = 'thimaco_notitie_acties';
  static const String _notitieActiesSyncMetaKey =
      'thimaco_notitie_acties_sync_meta';

  static const String _opmetingRaamKeuzemenusKey = 'opmeting_raam_keuzemenus';
  static const String _opmetingRaamKeuzemenusAluKey =
      'opmeting_raam_keuzemenus_alu';
  static const String _opmetingDeurKeuzemenusPvcKey =
      'opmeting_deur_keuzemenus_pvc';
  static const String _opmetingDeurKeuzemenusAluKey =
      'opmeting_deur_keuzemenus_alu';

  static const String _deurpanelenBibliotheekKey =
      'thimaco_deurpanelen_bibliotheek';

  static const String _deurpanelenBibliotheekGewijzigdOpKey =
      'thimaco_deurpanelen_bibliotheek_gewijzigd_op';

  static const String _deurpanelenDxfBibliotheekKey =
      'thimaco_deurpanelen_dxf_bibliotheek';

  static const String _deurpanelenDxfBibliotheekGewijzigdOpKey =
      'thimaco_deurpanelen_dxf_bibliotheek_gewijzigd_op';

  static const String _deurpaneelToewijzingenPrefix =
      'thimaco_deurpaneel_toewijzingen_';

  static const String _deurpaneelToewijzingGewijzigdOpPrefix =
      'thimaco_deurpaneel_toewijzing_gewijzigd_op_';

  static const String _opmetingProjectKleurenKey =
      'thimaco_opmeting_project_kleuren';

  static const String _opmetingProjectKleurenSyncMetaKey =
      'thimaco_opmeting_project_kleuren_sync_meta';

  static const String _opmetingSchuifraamKeuzemenusPvcKey =
      'opmeting_schuifraam_keuzemenus_pvc';

  static const String _opmetingSchuifraamKeuzemenusAluKey =
      'opmeting_schuifraam_keuzemenus_alu';

  static const String _opmetingSchuifraamOpbouwTypesKey =
      'opmeting_schuifraam_opbouw_types';

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

  static const String _magazijnDataKey = 'thimaco_magazijn_data';


  // --------------------------------------------------------------------------
  // LOCAL-FIRST MODULE-DELTA SYNC
  // --------------------------------------------------------------------------
  // Deze bestanden leven naast de bestaande thimaco_backup.json. Oude clients
  // blijven daardoor compatibel. De volledige backup blijft het herstelvangnet;
  // dagelijks werken synchroniseert alleen de operationele module die wijzigde.
  static const List<String> _deltaModules = <String>[
    'agenda',
    'klanten',
    'notities',
    'opmetingen',
    'magazijn',
  ];

  static const String _moduleHashPrefix = 'thimaco_sync_module_hash_v1_';
  static const String _moduleEtagPrefix = 'thimaco_sync_module_etag_v1_';

  static bool _backupBezig = false;
  static bool _backupOpnieuwNodig = false;
  static bool _backupOpnieuwMetFotosNodig = false;
  static Future<String>? _lopendeUpload;

  static bool _downloadBezig = false;
  static bool _fotoDownloadBezig = false;

  static Timer? _achtergrondUploadTimer;

  // Upload en download mogen nooit tegelijk dezelfde lokale/cloudgegevens
  // lezen, mergen en terugschrijven. Alle gewone OneDrive-syncbewerkingen
  // lopen daarom door één centrale wachtrij.
  static Future<void> _syncWachtrij = Future<void>.value();

  static Future<T> _voerSyncGeserialiseerdUit<T>(
    Future<T> Function() taak,
  ) {
    final completer = Completer<T>();

    _syncWachtrij = _syncWachtrij.then((_) async {
      try {
        final resultaat = await taak();
        completer.complete(resultaat);
      } catch (fout, stackTrace) {
        completer.completeError(fout, stackTrace);
      }
    });

    return completer.future;
  }

  static String laatsteSyncActie = 'Nog geen sync uitgevoerd';

  static Future<void> registreerLokaleWijziging() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_lokaleWijzigingOpenstaandKey, true);
  }

  /// Handmatige upload gebruikt standaard ook de foto's.
  ///
  /// Automatische upload moet [uploadFotos] op false zetten,
  /// zodat de app tijdens het werken niet alle fotobestanden
  /// opnieuw moet verwerken.
  Future<String> uploadBackup({bool uploadFotos = true}) {
    _backupOpnieuwMetFotosNodig = _backupOpnieuwMetFotosNodig || uploadFotos;

    final lopendeUpload = _lopendeUpload;
    if (lopendeUpload != null) {
      _backupOpnieuwNodig = true;
      laatsteSyncActie = 'Upload bezig; volgende upload in wachtrij geplaatst';
      return lopendeUpload;
    }

    final nieuweUpload = _voerUploadWachtrijUit();
    _lopendeUpload = nieuweUpload;

    nieuweUpload.whenComplete(() {
      if (identical(_lopendeUpload, nieuweUpload)) {
        _lopendeUpload = null;
      }
    });

    return nieuweUpload;
  }

  Future<String> _voerUploadWachtrijUit() async {
    var resultaat = 'BACKUP_GEEN_WIJZIGING';

    do {
      final uploadFotos = _backupOpnieuwMetFotosNodig;
      _backupOpnieuwNodig = false;
      _backupOpnieuwMetFotosNodig = false;
      _backupBezig = true;

      try {
        resultaat = await _voerSyncGeserialiseerdUit(
          () => _uploadBackupZonderVergrendeling(
            uploadFotos: uploadFotos,
          ),
        );
      } finally {
        _backupBezig = false;
      }
    } while (_backupOpnieuwNodig || _backupOpnieuwMetFotosNodig);

    return resultaat;
  }

  Future<String> _uploadBackupZonderVergrendeling({
    required bool uploadFotos,
  }) async {
    try {
      final token = await OneDriveAuthService().tokenSilent();

      if (token.startsWith('FOUT')) {
        laatsteSyncActie = 'Upload niet uitgevoerd: geen silent token';

        return token;
      }

      final prefs = await SharedPreferences.getInstance();

      final backupDatum = DateTime.now().toIso8601String();

      const url =
          'https://graph.microsoft.com/v1.0/me/drive/special/approot:/thimaco_backup.json:/content';

      Map<String, dynamic> cloudBackup = <String, dynamic>{};

      final cloudResponse = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (cloudResponse.statusCode == 200) {
        cloudBackup = await _decodeJsonObjectAchtergrond(cloudResponse.body);
      } else if (cloudResponse.statusCode != 404) {
        laatsteSyncActie =
            'Upload gestopt: bestaande OneDrive-back-up kon niet veilig worden gelezen';

        return 'BACKUP_CLOUD_LEZEN_FOUT '
            '${cloudResponse.statusCode}\n'
            '${cloudResponse.body}';
      }

      final cloudBackupDatum = cloudBackup['backupDatum'] is String
          ? cloudBackup['backupDatum'] as String
          : '';

      final lokaleAgenda = await AppStorage.laadAgendaItemsNieuwVoorSync();

      final cloudAgenda = await _decodeAgendaAchtergrond(
        cloudBackup['agendaItems'] is String
            ? cloudBackup['agendaItems'] as String
            : null,
      );

      final mergedAgenda = await _mergeAgendaAchtergrond(
        lokaleAgenda,
        cloudAgenda,
      );

      final lokaleKlanten = await _decodeKlantenAchtergrond(
        prefs.getString('klanten_fiches'),
      );

      final cloudKlanten = await _decodeKlantenAchtergrond(
        cloudBackup['klantenFiches'] is String
            ? cloudBackup['klantenFiches'] as String
            : null,
      );

      final mergedKlanten = await _mergeKlantenAchtergrond(
        lokaleKlanten,
        cloudKlanten,
      );

      final lokaleOpmetingen = await AppStorage.laadOpmetingenVoorSync();

      final cloudOpmetingen = await _decodeOpmetingenAchtergrond(
        cloudBackup['opmetingen'] is String
            ? cloudBackup['opmetingen'] as String
            : null,
      );

      final mergedOpmetingen = await _mergeOpmetingenAchtergrond(
        lokaleOpmetingen,
        cloudOpmetingen,
      );

      await _geefUiTijd();

      final lokaleTitelhoofden =
          await AppStorage.laadOpmetingProjectTitelhoofdenVoorSync();
      final cloudTitelhoofden =
          AppStorage.decodeOpmetingProjectTitelhoofdenVoorSync(
            cloudBackup['opmetingProjectTitelhoofden'] is String
                ? cloudBackup['opmetingProjectTitelhoofden'] as String
                : null,
          );
      final mergedTitelhoofden = SyncMergeService.mergeProjectTitelhoofden(
        lokaleTitelhoofden,
        cloudTitelhoofden,
      );

      // Alleen nog als eenmalige migratiebron voor oude vaste-inzethorwaarden.
      // Deze legacyprofielen worden niet meer gemerged of terug gesynchroniseerd.
      final lokalePrijsprofielenLegacy =
          await AppStorage.laadOffertePrijsProfielen();
      final cloudPrijsprofielenLegacy =
          AppStorage.decodeOffertePrijsProfielenVoorSync(
            cloudBackup['offertePrijsProfielen'] is String
                ? cloudBackup['offertePrijsProfielen'] as String
                : null,
          );

      final lokaleCollectieFallbackDatum =
          prefs.getString(_backupDatumKey) ?? backupDatum;

      final mergedDagtaakTemplates = _mergeJsonLijstCollectie(
        prefs: prefs,
        cloudData: cloudBackup,
        lokaleDataKey: _dagtaakTemplatesKey,
        lokaleMetadataKey: _dagtaakTemplatesSyncMetaKey,
        cloudDataVeld: 'dagtaakTemplates',
        cloudMetadataVeld: 'dagtaakTemplatesSyncMeta',
        lokaleFallbackDatum: lokaleCollectieFallbackDatum,
        cloudFallbackDatum: cloudBackupDatum,
      );
      final mergedLeveranciers = _mergeJsonLijstCollectie(
        prefs: prefs,
        cloudData: cloudBackup,
        lokaleDataKey: _leveranciersKey,
        lokaleMetadataKey: _leveranciersSyncMetaKey,
        cloudDataVeld: 'leveranciers',
        cloudMetadataVeld: 'leveranciersSyncMeta',
        lokaleFallbackDatum: lokaleCollectieFallbackDatum,
        cloudFallbackDatum: cloudBackupDatum,
        idVoorRecord: SyncMergeService.syncIdVoorLeverancierRecord,
      );
      final mergedNotities = _mergeJsonLijstCollectie(
        prefs: prefs,
        cloudData: cloudBackup,
        lokaleDataKey: _notitiesKey,
        lokaleMetadataKey: _notitiesSyncMetaKey,
        cloudDataVeld: 'notities',
        cloudMetadataVeld: 'notitiesSyncMeta',
        lokaleFallbackDatum: lokaleCollectieFallbackDatum,
        cloudFallbackDatum: cloudBackupDatum,
      );
      final mergedNotitieActies = _mergeJsonLijstCollectie(
        prefs: prefs,
        cloudData: cloudBackup,
        lokaleDataKey: _notitieActiesKey,
        lokaleMetadataKey: _notitieActiesSyncMetaKey,
        cloudDataVeld: 'notitieActies',
        cloudMetadataVeld: 'notitieActiesSyncMeta',
        lokaleFallbackDatum: lokaleCollectieFallbackDatum,
        cloudFallbackDatum: cloudBackupDatum,
      );
      final mergedProjectKleuren = _mergeJsonLijstCollectie(
        prefs: prefs,
        cloudData: cloudBackup,
        lokaleDataKey: _opmetingProjectKleurenKey,
        lokaleMetadataKey: _opmetingProjectKleurenSyncMetaKey,
        cloudDataVeld: 'opmetingProjectKleuren',
        cloudMetadataVeld: 'opmetingProjectKleurenSyncMeta',
        lokaleFallbackDatum: lokaleCollectieFallbackDatum,
        cloudFallbackDatum: cloudBackupDatum,
      );
      final mergedOffertePrijsPerArtikelTemplates = _mergeJsonLijstCollectie(
        prefs: prefs,
        cloudData: cloudBackup,
        lokaleDataKey: _offertePrijsPerArtikelTemplatesKey,
        lokaleMetadataKey: _offertePrijsPerArtikelTemplatesSyncMetaKey,
        cloudDataVeld: 'offertePrijsPerArtikelTemplates',
        cloudMetadataVeld: 'offertePrijsPerArtikelTemplatesSyncMeta',
        lokaleFallbackDatum: lokaleCollectieFallbackDatum,
        cloudFallbackDatum: cloudBackupDatum,
      );
      final mergedOffertePrijsVoorAllePositiesTemplates =
          _mergeJsonLijstCollectie(
            prefs: prefs,
            cloudData: cloudBackup,
            lokaleDataKey: _offertePrijsVoorAllePositiesTemplatesKey,
            lokaleMetadataKey:
                _offertePrijsVoorAllePositiesTemplatesSyncMetaKey,
            cloudDataVeld: 'offertePrijsVoorAllePositiesTemplates',
            cloudMetadataVeld: 'offertePrijsVoorAllePositiesTemplatesSyncMeta',
            lokaleFallbackDatum: lokaleCollectieFallbackDatum,
            cloudFallbackDatum: cloudBackupDatum,
          );
      final mergedOffertePrijsVerdeeldOverTemplates = _mergeJsonLijstCollectie(
        prefs: prefs,
        cloudData: cloudBackup,
        lokaleDataKey: _offertePrijsVerdeeldOverTemplatesKey,
        lokaleMetadataKey: _offertePrijsVerdeeldOverTemplatesSyncMetaKey,
        cloudDataVeld: 'offertePrijsVerdeeldOverTemplates',
        cloudMetadataVeld: 'offertePrijsVerdeeldOverTemplatesSyncMeta',
        lokaleFallbackDatum: lokaleCollectieFallbackDatum,
        cloudFallbackDatum: cloudBackupDatum,
      );
      final mergedOfferteTechnischeKeuzePrijzen = _mergeJsonLijstCollectie(
        prefs: prefs,
        cloudData: cloudBackup,
        lokaleDataKey: _offerteTechnischeKeuzePrijzenKey,
        lokaleMetadataKey: _offerteTechnischeKeuzePrijzenSyncMetaKey,
        cloudDataVeld: 'offerteTechnischeKeuzePrijzen',
        cloudMetadataVeld: 'offerteTechnischeKeuzePrijzenSyncMeta',
        lokaleFallbackDatum: lokaleCollectieFallbackDatum,
        cloudFallbackDatum: cloudBackupDatum,
      );
      final lokaleVasteInzethorStandaardPrijsinstellingen =
          AppStorage.decodeJsonMapLijstVoorSync(
            prefs.getString(_offerteVasteInzethorStandaardPrijsinstellingenKey),
          );
      final cloudVasteInzethorStandaardPrijsinstellingen =
          AppStorage.decodeJsonMapLijstVoorSync(
            cloudBackup['offerteVasteInzethorStandaardPrijsinstellingen']
                    is String
                ? cloudBackup['offerteVasteInzethorStandaardPrijsinstellingen']
                      as String
                : null,
          );

      // Eerste migratie: alleen wanneer de nieuwe collectie zowel lokaal als in
      // OneDrive nog ontbreekt, nemen we de reeds samengevoegde legacywaarde over.
      if (lokaleVasteInzethorStandaardPrijsinstellingen.isEmpty &&
          cloudVasteInzethorStandaardPrijsinstellingen.isEmpty) {
        final legacyVasteInzethor =
            AppStorage.vasteInzethorStandaardPrijsinstellingenUitLegacyProfielen(
              lokalePrijsprofielenLegacy,
            ) ??
            AppStorage.vasteInzethorStandaardPrijsinstellingenUitLegacyProfielen(
              cloudPrijsprofielenLegacy,
            );
        if (legacyVasteInzethor != null) {
          await AppStorage.bewaarVasteInzethorStandaardPrijsinstellingenVoorSync(
            standaardPrijsPerStukExclBtw:
                legacyVasteInzethor.standaardPrijsPerStukExclBtw,
            standaardWinstmargePercentage:
                legacyVasteInzethor.standaardWinstmargePercentage,
            standaardKortingPercentage:
                legacyVasteInzethor.standaardKortingPercentage,
          );
        }
      }

      final mergedVasteInzethorStandaardPrijsinstellingen =
          _mergeJsonLijstCollectie(
            prefs: prefs,
            cloudData: cloudBackup,
            lokaleDataKey: _offerteVasteInzethorStandaardPrijsinstellingenKey,
            lokaleMetadataKey:
                _offerteVasteInzethorStandaardPrijsinstellingenSyncMetaKey,
            cloudDataVeld: 'offerteVasteInzethorStandaardPrijsinstellingen',
            cloudMetadataVeld:
                'offerteVasteInzethorStandaardPrijsinstellingenSyncMeta',
            lokaleFallbackDatum: lokaleCollectieFallbackDatum,
            cloudFallbackDatum: cloudBackupDatum,
          );
      final mergedRaamKeuzemenus = _mergeJsonLijstCollectie(
        prefs: prefs,
        cloudData: cloudBackup,
        lokaleDataKey: _opmetingRaamKeuzemenusKey,
        lokaleMetadataKey: _syncMetaKeyVoorDataKey(_opmetingRaamKeuzemenusKey),
        cloudDataVeld: 'opmetingRaamKeuzemenus',
        cloudMetadataVeld: 'opmetingRaamKeuzemenusSyncMeta',
        lokaleFallbackDatum: lokaleCollectieFallbackDatum,
        cloudFallbackDatum: cloudBackupDatum,
      );
      final mergedRaamKeuzemenusAlu = _mergeJsonLijstCollectie(
        prefs: prefs,
        cloudData: cloudBackup,
        lokaleDataKey: _opmetingRaamKeuzemenusAluKey,
        lokaleMetadataKey: _syncMetaKeyVoorDataKey(
          _opmetingRaamKeuzemenusAluKey,
        ),
        cloudDataVeld: 'opmetingRaamKeuzemenusAlu',
        cloudMetadataVeld: 'opmetingRaamKeuzemenusAluSyncMeta',
        lokaleFallbackDatum: lokaleCollectieFallbackDatum,
        cloudFallbackDatum: cloudBackupDatum,
      );
      final mergedDeurKeuzemenusPvc = _mergeJsonLijstCollectie(
        prefs: prefs,
        cloudData: cloudBackup,
        lokaleDataKey: _opmetingDeurKeuzemenusPvcKey,
        lokaleMetadataKey: _syncMetaKeyVoorDataKey(
          _opmetingDeurKeuzemenusPvcKey,
        ),
        cloudDataVeld: 'opmetingDeurKeuzemenusPvc',
        cloudMetadataVeld: 'opmetingDeurKeuzemenusPvcSyncMeta',
        lokaleFallbackDatum: lokaleCollectieFallbackDatum,
        cloudFallbackDatum: cloudBackupDatum,
      );
      final mergedDeurKeuzemenusAlu = _mergeJsonLijstCollectie(
        prefs: prefs,
        cloudData: cloudBackup,
        lokaleDataKey: _opmetingDeurKeuzemenusAluKey,
        lokaleMetadataKey: _syncMetaKeyVoorDataKey(
          _opmetingDeurKeuzemenusAluKey,
        ),
        cloudDataVeld: 'opmetingDeurKeuzemenusAlu',
        cloudMetadataVeld: 'opmetingDeurKeuzemenusAluSyncMeta',
        lokaleFallbackDatum: lokaleCollectieFallbackDatum,
        cloudFallbackDatum: cloudBackupDatum,
      );
      final mergedSchuifraamKeuzemenusPvc = _mergeJsonLijstCollectie(
        prefs: prefs,
        cloudData: cloudBackup,
        lokaleDataKey: _opmetingSchuifraamKeuzemenusPvcKey,
        lokaleMetadataKey: _syncMetaKeyVoorDataKey(
          _opmetingSchuifraamKeuzemenusPvcKey,
        ),
        cloudDataVeld: 'opmetingSchuifraamKeuzemenusPvc',
        cloudMetadataVeld: 'opmetingSchuifraamKeuzemenusPvcSyncMeta',
        lokaleFallbackDatum: lokaleCollectieFallbackDatum,
        cloudFallbackDatum: cloudBackupDatum,
      );
      final mergedSchuifraamKeuzemenusAlu = _mergeJsonLijstCollectie(
        prefs: prefs,
        cloudData: cloudBackup,
        lokaleDataKey: _opmetingSchuifraamKeuzemenusAluKey,
        lokaleMetadataKey: _syncMetaKeyVoorDataKey(
          _opmetingSchuifraamKeuzemenusAluKey,
        ),
        cloudDataVeld: 'opmetingSchuifraamKeuzemenusAlu',
        cloudMetadataVeld: 'opmetingSchuifraamKeuzemenusAluSyncMeta',
        lokaleFallbackDatum: lokaleCollectieFallbackDatum,
        cloudFallbackDatum: cloudBackupDatum,
      );

      final bibliotheek = _kiesRecenteStringWaarde(
        lokaleWaarde: prefs.getString(_bibliotheekKey),
        cloudWaarde: cloudBackup['bibliotheek'] is String
            ? cloudBackup['bibliotheek'] as String
            : null,
        lokaleGewijzigdOp: prefs.getString(_bibliotheekGewijzigdOpKey),
        cloudGewijzigdOp: cloudBackup['bibliotheekGewijzigdOp'] is String
            ? cloudBackup['bibliotheekGewijzigdOp'] as String
            : null,
        fallbackDatum: cloudBackupDatum.isEmpty
            ? backupDatum
            : cloudBackupDatum,
      );

      final offerteMailTeksten = _kiesRecenteStringWaarde(
        lokaleWaarde: prefs.getString(_offerteMailTekstenKey),
        cloudWaarde: cloudBackup['offerteMailTeksten'] is String
            ? cloudBackup['offerteMailTeksten'] as String
            : null,
        lokaleGewijzigdOp: prefs.getString(_offerteMailTekstenGewijzigdOpKey),
        cloudGewijzigdOp: cloudBackup['offerteMailTekstenGewijzigdOp'] is String
            ? cloudBackup['offerteMailTekstenGewijzigdOp'] as String
            : null,
        fallbackDatum: cloudBackupDatum.isEmpty
            ? backupDatum
            : cloudBackupDatum,
      );

      final mergedOfferteAlgemenePrijsregels = _kiesRecenteInstellingenJson(
        lokaalJson: prefs.getString(_offerteAlgemenePrijsregelsKey),
        cloudJson: cloudBackup['offerteAlgemenePrijsregels'] is String
            ? cloudBackup['offerteAlgemenePrijsregels'] as String
            : null,
        lokaleFallbackDatum: backupDatum,
        cloudFallbackDatum: cloudBackupDatum,
        lokaalWintBijGelijkeDatum: true,
      );

      final mergedMagazijnData = _mergeMagazijnJson(
        lokaalJson: prefs.getString(_magazijnDataKey),
        cloudJson: cloudBackup['magazijnData'] is String
            ? cloudBackup['magazijnData'] as String
            : null,
        lokaalWintBijConflict: true,
      );

      final mergedVoorzetscreenInstellingen = _kiesRecenteInstellingenJson(
        lokaalJson: prefs.getString(_opmetingVoorzetscreenInstellingenKey),
        cloudJson: cloudBackup['opmetingVoorzetscreenInstellingen'] is String
            ? cloudBackup['opmetingVoorzetscreenInstellingen'] as String
            : null,
        lokaleFallbackDatum: backupDatum,
        cloudFallbackDatum: cloudBackupDatum,
        lokaalWintBijGelijkeDatum: true,
      );

      final mergedBuitenjaloezieInstellingen = _kiesRecenteInstellingenJson(
        lokaalJson: prefs.getString(_opmetingBuitenjaloezieInstellingenKey),
        cloudJson: cloudBackup['opmetingBuitenjaloezieInstellingen'] is String
            ? cloudBackup['opmetingBuitenjaloezieInstellingen'] as String
            : null,
        lokaleFallbackDatum: backupDatum,
        cloudFallbackDatum: cloudBackupDatum,
        lokaalWintBijGelijkeDatum: true,
      );

      final mergedVoorzetrolluikInstellingen = _kiesRecenteInstellingenJson(
        lokaalJson: prefs.getString(_opmetingVoorzetrolluikInstellingenKey),
        cloudJson: cloudBackup['opmetingVoorzetrolluikInstellingen'] is String
            ? cloudBackup['opmetingVoorzetrolluikInstellingen'] as String
            : null,
        lokaleFallbackDatum: backupDatum,
        cloudFallbackDatum: cloudBackupDatum,
        lokaalWintBijGelijkeDatum: true,
      );

      final mergedUitvalschermInstellingen = _kiesRecenteInstellingenJson(
        lokaalJson: prefs.getString(_opmetingUitvalschermInstellingenKey),
        cloudJson: cloudBackup['opmetingUitvalschermInstellingen'] is String
            ? cloudBackup['opmetingUitvalschermInstellingen'] as String
            : null,
        lokaleFallbackDatum: backupDatum,
        cloudFallbackDatum: cloudBackupDatum,
        lokaalWintBijGelijkeDatum: true,
      );

      final mergedSektionalePoortInstellingen = _kiesRecenteInstellingenJson(
        lokaalJson: prefs.getString(_opmetingSektionalePoortInstellingenKey),
        cloudJson: cloudBackup['opmetingSektionalePoortInstellingen'] is String
            ? cloudBackup['opmetingSektionalePoortInstellingen'] as String
            : null,
        lokaleFallbackDatum: backupDatum,
        cloudFallbackDatum: cloudBackupDatum,
        lokaalWintBijGelijkeDatum: true,
      );

      final mergedVeluxDakraamInstellingen = _kiesRecenteInstellingenJson(
        lokaalJson: prefs.getString(_opmetingVeluxDakraamInstellingenKey),
        cloudJson: cloudBackup['opmetingVeluxDakraamInstellingen'] is String
            ? cloudBackup['opmetingVeluxDakraamInstellingen'] as String
            : null,
        lokaleFallbackDatum: backupDatum,
        cloudFallbackDatum: cloudBackupDatum,
        lokaalWintBijGelijkeDatum: true,
      );

      final deurpanelenBibliotheek = _kiesRecenteStringWaarde(
        lokaleWaarde: prefs.getString(_deurpanelenBibliotheekKey),
        cloudWaarde: cloudBackup['deurpanelenBibliotheek'] is String
            ? cloudBackup['deurpanelenBibliotheek'] as String
            : null,
        lokaleGewijzigdOp: prefs.getString(
          _deurpanelenBibliotheekGewijzigdOpKey,
        ),
        cloudGewijzigdOp:
            cloudBackup['deurpanelenBibliotheekGewijzigdOp'] is String
            ? cloudBackup['deurpanelenBibliotheekGewijzigdOp'] as String
            : null,
        fallbackDatum: cloudBackupDatum.isEmpty
            ? backupDatum
            : cloudBackupDatum,
      );

      final deurpanelenDxfBibliotheek = _kiesRecenteStringWaarde(
        lokaleWaarde: prefs.getString(_deurpanelenDxfBibliotheekKey),
        cloudWaarde: cloudBackup['deurpanelenDxfBibliotheek'] is String
            ? cloudBackup['deurpanelenDxfBibliotheek'] as String
            : null,
        lokaleGewijzigdOp: prefs.getString(
          _deurpanelenDxfBibliotheekGewijzigdOpKey,
        ),
        cloudGewijzigdOp:
            cloudBackup['deurpanelenDxfBibliotheekGewijzigdOp'] is String
            ? cloudBackup['deurpanelenDxfBibliotheekGewijzigdOp'] as String
            : null,
        fallbackDatum: cloudBackupDatum.isEmpty
            ? backupDatum
            : cloudBackupDatum,
      );

      final mergedDeurpaneelToewijzingen =
          SyncMergeService.mergeStringRecordsOpDatum(
            lokaal: _leesStringPrefsMetPrefix(
              prefs,
              _deurpaneelToewijzingenPrefix,
            ),
            cloud: _leesStringMap(cloudBackup['deurpaneelToewijzingen']),
            lokaleGewijzigdOp: _leesDeurpaneelToewijzingDatums(prefs),
            cloudGewijzigdOp: _leesStringMap(
              cloudBackup['deurpaneelToewijzingenGewijzigdOp'],
            ),
            lokaleFallbackDatum: backupDatum,
            cloudFallbackDatum: cloudBackupDatum,
          );

      await _geefUiTijd();

      final agendaJson = await _encodeAgendaAchtergrond(mergedAgenda);
      final klantenJson = await _encodeKlantenAchtergrond(mergedKlanten);
      final opmetingenJson = await _encodeOpmetingenAchtergrond(mergedOpmetingen);
      await _geefUiTijd();

      final backup = <String, dynamic>{
        'backupDatum': backupDatum,
        'agendaItems': agendaJson,
        'dagtaakTemplates': AppStorage.encodeJsonMapLijstVoorSync(
          mergedDagtaakTemplates.records,
        ),
        'dagtaakTemplatesSyncMeta': SyncMergeService.encodeJsonRecordMetadata(
          mergedDagtaakTemplates.metadata,
        ),
        'leveranciers': AppStorage.encodeJsonMapLijstVoorSync(
          mergedLeveranciers.records,
        ),
        'leveranciersSyncMeta': SyncMergeService.encodeJsonRecordMetadata(
          mergedLeveranciers.metadata,
        ),
        'bibliotheek': bibliotheek.waarde,
        'bibliotheekGewijzigdOp': bibliotheek.gewijzigdOp,
        'offerteMailTeksten': offerteMailTeksten.waarde,
        'offerteMailTekstenGewijzigdOp': offerteMailTeksten.gewijzigdOp,
        'offerteAlgemenePrijsregels': mergedOfferteAlgemenePrijsregels,
        'klantenFiches': klantenJson,
        'notities': AppStorage.encodeJsonMapLijstVoorSync(
          mergedNotities.records,
        ),
        'notitiesSyncMeta': SyncMergeService.encodeJsonRecordMetadata(
          mergedNotities.metadata,
        ),
        'notitieActies': AppStorage.encodeJsonMapLijstVoorSync(
          mergedNotitieActies.records,
        ),
        'notitieActiesSyncMeta': SyncMergeService.encodeJsonRecordMetadata(
          mergedNotitieActies.metadata,
        ),
        'opmetingRaamOpvullingen': prefs.getString('opmeting_raam_opvullingen'),
        'opmetingRaamKeuzemenus': AppStorage.encodeJsonMapLijstVoorSync(
          mergedRaamKeuzemenus.records,
        ),
        'opmetingRaamKeuzemenusSyncMeta':
            SyncMergeService.encodeJsonRecordMetadata(
              mergedRaamKeuzemenus.metadata,
            ),
        'opmetingRaamKeuzemenusAlu': AppStorage.encodeJsonMapLijstVoorSync(
          mergedRaamKeuzemenusAlu.records,
        ),
        'opmetingRaamKeuzemenusAluSyncMeta':
            SyncMergeService.encodeJsonRecordMetadata(
              mergedRaamKeuzemenusAlu.metadata,
            ),
        'opmetingDeurKeuzemenusPvc': AppStorage.encodeJsonMapLijstVoorSync(
          mergedDeurKeuzemenusPvc.records,
        ),
        'opmetingDeurKeuzemenusPvcSyncMeta':
            SyncMergeService.encodeJsonRecordMetadata(
              mergedDeurKeuzemenusPvc.metadata,
            ),
        'opmetingDeurKeuzemenusAlu': AppStorage.encodeJsonMapLijstVoorSync(
          mergedDeurKeuzemenusAlu.records,
        ),
        'opmetingDeurKeuzemenusAluSyncMeta':
            SyncMergeService.encodeJsonRecordMetadata(
              mergedDeurKeuzemenusAlu.metadata,
            ),
        'opmetingSchuifraamKeuzemenusPvc':
            AppStorage.encodeJsonMapLijstVoorSync(
              mergedSchuifraamKeuzemenusPvc.records,
            ),
        'opmetingSchuifraamKeuzemenusPvcSyncMeta':
            SyncMergeService.encodeJsonRecordMetadata(
              mergedSchuifraamKeuzemenusPvc.metadata,
            ),
        'opmetingSchuifraamKeuzemenusAlu':
            AppStorage.encodeJsonMapLijstVoorSync(
              mergedSchuifraamKeuzemenusAlu.records,
            ),
        'opmetingSchuifraamKeuzemenusAluSyncMeta':
            SyncMergeService.encodeJsonRecordMetadata(
              mergedSchuifraamKeuzemenusAlu.metadata,
            ),
        'opmetingSchuifraamOpbouwTypes':
            prefs.getString(_opmetingSchuifraamOpbouwTypesKey) ??
            (cloudBackup['opmetingSchuifraamOpbouwTypes'] is String
                ? cloudBackup['opmetingSchuifraamOpbouwTypes'] as String
                : null),
        'opmetingPlooiwerkenInstellingen':
            prefs.getString(_opmetingPlooiwerkenInstellingenKey) ??
            (cloudBackup['opmetingPlooiwerkenInstellingen'] is String
                ? cloudBackup['opmetingPlooiwerkenInstellingen'] as String
                : null),
        'opmetingVoorzetscreenInstellingen': mergedVoorzetscreenInstellingen,
        'opmetingBuitenjaloezieInstellingen': mergedBuitenjaloezieInstellingen,
        'opmetingVoorzetrolluikInstellingen': mergedVoorzetrolluikInstellingen,
        'opmetingUitvalschermInstellingen': mergedUitvalschermInstellingen,
        'opmetingSektionalePoortInstellingen':
            mergedSektionalePoortInstellingen,
        'opmetingVeluxDakraamInstellingen': mergedVeluxDakraamInstellingen,
        'opmetingen': opmetingenJson,
        'magazijnData': mergedMagazijnData,
        'opmetingProjectTitelhoofden':
            AppStorage.encodeOpmetingProjectTitelhoofdenVoorSync(
              mergedTitelhoofden,
            ),
        'opmetingProjectKleuren': AppStorage.encodeJsonMapLijstVoorSync(
          mergedProjectKleuren.records,
        ),
        'opmetingProjectKleurenSyncMeta':
            SyncMergeService.encodeJsonRecordMetadata(
              mergedProjectKleuren.metadata,
            ),
        'offertePrijsPerArtikelTemplates':
            AppStorage.encodeJsonMapLijstVoorSync(
              mergedOffertePrijsPerArtikelTemplates.records,
            ),
        'offertePrijsPerArtikelTemplatesSyncMeta':
            SyncMergeService.encodeJsonRecordMetadata(
              mergedOffertePrijsPerArtikelTemplates.metadata,
            ),
        'offertePrijsVoorAllePositiesTemplates':
            AppStorage.encodeJsonMapLijstVoorSync(
              mergedOffertePrijsVoorAllePositiesTemplates.records,
            ),
        'offertePrijsVoorAllePositiesTemplatesSyncMeta':
            SyncMergeService.encodeJsonRecordMetadata(
              mergedOffertePrijsVoorAllePositiesTemplates.metadata,
            ),
        'offertePrijsVerdeeldOverTemplates':
            AppStorage.encodeJsonMapLijstVoorSync(
              mergedOffertePrijsVerdeeldOverTemplates.records,
            ),
        'offertePrijsVerdeeldOverTemplatesSyncMeta':
            SyncMergeService.encodeJsonRecordMetadata(
              mergedOffertePrijsVerdeeldOverTemplates.metadata,
            ),
        'offerteTechnischeKeuzePrijzen': AppStorage.encodeJsonMapLijstVoorSync(
          mergedOfferteTechnischeKeuzePrijzen.records,
        ),
        'offerteTechnischeKeuzePrijzenSyncMeta':
            SyncMergeService.encodeJsonRecordMetadata(
              mergedOfferteTechnischeKeuzePrijzen.metadata,
            ),
        'offerteVasteInzethorStandaardPrijsinstellingen':
            AppStorage.encodeJsonMapLijstVoorSync(
              mergedVasteInzethorStandaardPrijsinstellingen.records,
            ),
        'offerteVasteInzethorStandaardPrijsinstellingenSyncMeta':
            SyncMergeService.encodeJsonRecordMetadata(
              mergedVasteInzethorStandaardPrijsinstellingen.metadata,
            ),
        'deurpanelenBibliotheek': deurpanelenBibliotheek.waarde,
        'deurpanelenBibliotheekGewijzigdOp': deurpanelenBibliotheek.gewijzigdOp,
        'deurpanelenDxfBibliotheek': deurpanelenDxfBibliotheek.waarde,
        'deurpanelenDxfBibliotheekGewijzigdOp':
            deurpanelenDxfBibliotheek.gewijzigdOp,
        'deurpaneelToewijzingen': mergedDeurpaneelToewijzingen.waarden,
        'deurpaneelToewijzingenGewijzigdOp':
            mergedDeurpaneelToewijzingen.gewijzigdOp,
      };

      final backupJson = await _encodeJsonAchtergrond(backup);

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: backupJson,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        return 'BACKUP_FOUT '
            '${response.statusCode}\n'
            '${response.body}';
      }

      await AppStorage.bewaarAgendaItemsNieuwVoorSync(mergedAgenda);

      await _bewaarOptioneleString(
        prefs: prefs,
        key: _bibliotheekKey,
        waarde: bibliotheek.waarde,
      );
      await _bewaarOptioneleString(
        prefs: prefs,
        key: _bibliotheekGewijzigdOpKey,
        waarde: bibliotheek.gewijzigdOp,
      );
      await _bewaarOptioneleString(
        prefs: prefs,
        key: _offerteMailTekstenKey,
        waarde: offerteMailTeksten.waarde,
      );
      await _bewaarOptioneleString(
        prefs: prefs,
        key: _offerteMailTekstenGewijzigdOpKey,
        waarde: offerteMailTeksten.gewijzigdOp,
      );
      await _bewaarOptioneleString(
        prefs: prefs,
        key: _offerteAlgemenePrijsregelsKey,
        waarde: mergedOfferteAlgemenePrijsregels,
      );

      await AppStorage.bewaarKlantenFichesVoorSync(
        mergedKlanten.map((fiche) => fiche.toJson()).toList(),
      );

      await AppStorage.bewaarOpmetingenVoorSync(mergedOpmetingen);
      await _geefUiTijd();

      await prefs.setString(_magazijnDataKey, mergedMagazijnData);
      await _bewaarOptioneleString(
        prefs: prefs,
        key: _opmetingVoorzetscreenInstellingenKey,
        waarde: mergedVoorzetscreenInstellingen,
      );
      await _bewaarOptioneleString(
        prefs: prefs,
        key: _opmetingBuitenjaloezieInstellingenKey,
        waarde: mergedBuitenjaloezieInstellingen,
      );
      await _bewaarOptioneleString(
        prefs: prefs,
        key: _opmetingVoorzetrolluikInstellingenKey,
        waarde: mergedVoorzetrolluikInstellingen,
      );
      await _bewaarOptioneleString(
        prefs: prefs,
        key: _opmetingUitvalschermInstellingenKey,
        waarde: mergedUitvalschermInstellingen,
      );
      await _bewaarOptioneleString(
        prefs: prefs,
        key: _opmetingSektionalePoortInstellingenKey,
        waarde: mergedSektionalePoortInstellingen,
      );
      await _bewaarOptioneleString(
        prefs: prefs,
        key: _opmetingVeluxDakraamInstellingenKey,
        waarde: mergedVeluxDakraamInstellingen,
      );

      await AppStorage.bewaarOpmetingProjectTitelhoofdenVoorSync(
        mergedTitelhoofden,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _dagtaakTemplatesKey,
        metadataKey: _dagtaakTemplatesSyncMetaKey,
        resultaat: mergedDagtaakTemplates,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _leveranciersKey,
        metadataKey: _leveranciersSyncMetaKey,
        resultaat: mergedLeveranciers,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _notitiesKey,
        metadataKey: _notitiesSyncMetaKey,
        resultaat: mergedNotities,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _notitieActiesKey,
        metadataKey: _notitieActiesSyncMetaKey,
        resultaat: mergedNotitieActies,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _opmetingProjectKleurenKey,
        metadataKey: _opmetingProjectKleurenSyncMetaKey,
        resultaat: mergedProjectKleuren,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _offertePrijsPerArtikelTemplatesKey,
        metadataKey: _offertePrijsPerArtikelTemplatesSyncMetaKey,
        resultaat: mergedOffertePrijsPerArtikelTemplates,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _offertePrijsVoorAllePositiesTemplatesKey,
        metadataKey: _offertePrijsVoorAllePositiesTemplatesSyncMetaKey,
        resultaat: mergedOffertePrijsVoorAllePositiesTemplates,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _offertePrijsVerdeeldOverTemplatesKey,
        metadataKey: _offertePrijsVerdeeldOverTemplatesSyncMetaKey,
        resultaat: mergedOffertePrijsVerdeeldOverTemplates,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _offerteTechnischeKeuzePrijzenKey,
        metadataKey: _offerteTechnischeKeuzePrijzenSyncMetaKey,
        resultaat: mergedOfferteTechnischeKeuzePrijzen,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _offerteVasteInzethorStandaardPrijsinstellingenKey,
        metadataKey: _offerteVasteInzethorStandaardPrijsinstellingenSyncMetaKey,
        resultaat: mergedVasteInzethorStandaardPrijsinstellingen,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _opmetingRaamKeuzemenusKey,
        metadataKey: _syncMetaKeyVoorDataKey(_opmetingRaamKeuzemenusKey),
        resultaat: mergedRaamKeuzemenus,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _opmetingRaamKeuzemenusAluKey,
        metadataKey: _syncMetaKeyVoorDataKey(_opmetingRaamKeuzemenusAluKey),
        resultaat: mergedRaamKeuzemenusAlu,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _opmetingDeurKeuzemenusPvcKey,
        metadataKey: _syncMetaKeyVoorDataKey(_opmetingDeurKeuzemenusPvcKey),
        resultaat: mergedDeurKeuzemenusPvc,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _opmetingDeurKeuzemenusAluKey,
        metadataKey: _syncMetaKeyVoorDataKey(_opmetingDeurKeuzemenusAluKey),
        resultaat: mergedDeurKeuzemenusAlu,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _opmetingSchuifraamKeuzemenusPvcKey,
        metadataKey: _syncMetaKeyVoorDataKey(
          _opmetingSchuifraamKeuzemenusPvcKey,
        ),
        resultaat: mergedSchuifraamKeuzemenusPvc,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _opmetingSchuifraamKeuzemenusAluKey,
        metadataKey: _syncMetaKeyVoorDataKey(
          _opmetingSchuifraamKeuzemenusAluKey,
        ),
        resultaat: mergedSchuifraamKeuzemenusAlu,
      );

      await _geefUiTijd();

      await _bewaarOptioneleString(
        prefs: prefs,
        key: _deurpanelenBibliotheekKey,
        waarde: deurpanelenBibliotheek.waarde,
      );
      await _bewaarOptioneleString(
        prefs: prefs,
        key: _deurpanelenBibliotheekGewijzigdOpKey,
        waarde: deurpanelenBibliotheek.gewijzigdOp,
      );
      await _bewaarOptioneleString(
        prefs: prefs,
        key: _deurpanelenDxfBibliotheekKey,
        waarde: deurpanelenDxfBibliotheek.waarde,
      );
      await _bewaarOptioneleString(
        prefs: prefs,
        key: _deurpanelenDxfBibliotheekGewijzigdOpKey,
        waarde: deurpanelenDxfBibliotheek.gewijzigdOp,
      );
      await _schrijfStringPrefsMetPrefix(
        prefs,
        _deurpaneelToewijzingenPrefix,
        mergedDeurpaneelToewijzingen.waarden,
      );
      await _schrijfDeurpaneelToewijzingDatums(
        prefs,
        mergedDeurpaneelToewijzingen.gewijzigdOp,
      );

      String fotoResultaat = 'FOTOS_OVERGESLAGEN';

      if (uploadFotos) {
        fotoResultaat = await _uploadKlantenFotos(token);
      }

      await prefs.setString(_backupDatumKey, backupDatum);

      await prefs.setBool(_lokaleWijzigingOpenstaandKey, false);

      // Leg de cloudversie pas vast nadat de volledige lokale merge succesvol
      // is weggeschreven. Zo kan een gedeeltelijk mislukte lokale opslag nooit
      // ten onrechte als volledig gesynchroniseerd worden beschouwd.
      await _bewaarOneDriveEtagNaUpload(
        prefs: prefs,
        token: token,
        response: response,
      );

      laatsteSyncActie = uploadFotos
          ? 'Merge upload met foto’s en deurpanelen uitgevoerd'
          : 'Snelle merge upload zonder foto’s met deurpanelen uitgevoerd';

      if (uploadFotos && !fotoResultaat.startsWith('FOTOS_OK')) {
        return 'BACKUP_OK_FOTOS_LATER\n'
            '$fotoResultaat';
      }

      return uploadFotos ? 'BACKUP_OK' : 'BACKUP_OK_ZONDER_FOTOS';
    } catch (e) {
      return 'BACKUP_EXCEPTION: $e';
    }
  }

  static String? _kiesRecenteInstellingenJson({
    required String? lokaalJson,
    required String? cloudJson,
    required String lokaleFallbackDatum,
    required String cloudFallbackDatum,
    required bool lokaalWintBijGelijkeDatum,
  }) {
    if (lokaalJson == null || lokaalJson.trim().isEmpty) {
      return cloudJson;
    }

    if (cloudJson == null || cloudJson.trim().isEmpty) {
      return lokaalJson;
    }

    DateTime? datumUitJson(String jsonTekst, String fallback) {
      try {
        final decoded = jsonDecode(jsonTekst);
        if (decoded is Map) {
          final gewijzigdOp = decoded['gewijzigdOp']?.toString().trim() ?? '';
          final gewijzigdDatum = DateTime.tryParse(gewijzigdOp);
          if (gewijzigdDatum != null) {
            return gewijzigdDatum.toUtc();
          }
        }
      } catch (_) {
        // Bij ongeldige JSON gebruiken we de fallbackdatum.
      }

      return DateTime.tryParse(fallback)?.toUtc();
    }

    final lokaleDatum = datumUitJson(lokaalJson, lokaleFallbackDatum);
    final cloudDatum = datumUitJson(cloudJson, cloudFallbackDatum);

    if (lokaleDatum == null && cloudDatum == null) {
      return lokaalWintBijGelijkeDatum ? lokaalJson : cloudJson;
    }

    if (lokaleDatum == null) {
      return cloudJson;
    }

    if (cloudDatum == null) {
      return lokaalJson;
    }

    if (lokaleDatum.isAfter(cloudDatum)) {
      return lokaalJson;
    }

    if (cloudDatum.isAfter(lokaleDatum)) {
      return cloudJson;
    }

    return lokaalWintBijGelijkeDatum ? lokaalJson : cloudJson;
  }

  static String _mergeMagazijnJson({
    required String? lokaalJson,
    required String? cloudJson,
    required bool lokaalWintBijConflict,
  }) {
    Map<String, dynamic> decode(String? waarde) {
      if (waarde == null || waarde.trim().isEmpty) {
        return <String, dynamic>{};
      }

      try {
        final decoded = jsonDecode(waarde);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        // Een beschadigde zijde mag de andere geldige zijde niet blokkeren.
      }

      return <String, dynamic>{};
    }

    List<Map<String, dynamic>> leesRecords(
      Map<String, dynamic> data,
      String sleutel,
    ) {
      final ruweLijst = data[sleutel];
      if (ruweLijst is! List) {
        return <Map<String, dynamic>>[];
      }

      return ruweLijst
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }

    List<Map<String, dynamic>> mergeRecords({
      required List<Map<String, dynamic>> lokaal,
      required List<Map<String, dynamic>> cloud,
    }) {
      final resultaat = <String, Map<String, dynamic>>{};

      void voegToe(
        Iterable<Map<String, dynamic>> records, {
        required bool overschrijven,
      }) {
        for (final record in records) {
          final id = record['id']?.toString().trim() ?? '';
          if (id.isEmpty) {
            continue;
          }

          if (overschrijven || !resultaat.containsKey(id)) {
            resultaat[id] = Map<String, dynamic>.from(record);
          }
        }
      }

      if (lokaalWintBijConflict) {
        voegToe(cloud, overschrijven: false);
        voegToe(lokaal, overschrijven: true);
      } else {
        voegToe(lokaal, overschrijven: false);
        voegToe(cloud, overschrijven: true);
      }

      return resultaat.values.toList(growable: false);
    }

    final lokaal = decode(lokaalJson);
    final cloud = decode(cloudJson);

    if (lokaal.isEmpty && cloud.isEmpty) {
      return jsonEncode(<String, dynamic>{
        'leveranciers': <dynamic>[],
        'artikelen': <dynamic>[],
        'mutaties': <dynamic>[],
        'eenheden': <String>['stuk', 'doos', 'koker', 'rol', 'meter'],
      });
    }

    final leveranciers = mergeRecords(
      lokaal: leesRecords(lokaal, 'leveranciers'),
      cloud: leesRecords(cloud, 'leveranciers'),
    );

    final artikelen = mergeRecords(
      lokaal: leesRecords(lokaal, 'artikelen'),
      cloud: leesRecords(cloud, 'artikelen'),
    );

    final mutaties =
        mergeRecords(
          lokaal: leesRecords(lokaal, 'mutaties'),
          cloud: leesRecords(cloud, 'mutaties'),
        )..sort((eerste, tweede) {
          final eersteDatum = DateTime.tryParse(
            eerste['tijdstip']?.toString() ?? '',
          );
          final tweedeDatum = DateTime.tryParse(
            tweede['tijdstip']?.toString() ?? '',
          );

          return (tweedeDatum ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(eersteDatum ?? DateTime.fromMillisecondsSinceEpoch(0));
        });

    final eenheden = <String>{};

    void voegEenhedenToe(Map<String, dynamic> data) {
      final lijst = data['eenheden'];
      if (lijst is! List) {
        return;
      }

      for (final item in lijst) {
        final eenheid = item.toString().trim();
        if (eenheid.isNotEmpty) {
          eenheden.add(eenheid);
        }
      }
    }

    voegEenhedenToe(cloud);
    voegEenhedenToe(lokaal);

    if (eenheden.isEmpty) {
      eenheden.addAll(const <String>['stuk', 'doos', 'koker', 'rol', 'meter']);
    }

    final gesorteerdeEenheden = eenheden.toList(growable: false)
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return jsonEncode(<String, dynamic>{
      'leveranciers': leveranciers,
      'artikelen': artikelen,
      'mutaties': mutaties.take(2000).toList(growable: false),
      'eenheden': gesorteerdeEenheden,
    });
  }

  static String _syncMetaKeyVoorDataKey(String dataKey) {
    return '${dataKey}_sync_meta';
  }

  static String _standaardJsonRecordId(Map<String, dynamic> record) {
    return record['id']?.toString().trim() ?? '';
  }

  static SyncJsonRecordMergeResult _mergeJsonLijstCollectie({
    required SharedPreferences prefs,
    required Map<String, dynamic> cloudData,
    required String lokaleDataKey,
    required String lokaleMetadataKey,
    required String cloudDataVeld,
    required String cloudMetadataVeld,
    required String lokaleFallbackDatum,
    required String cloudFallbackDatum,
    String Function(Map<String, dynamic> record)? idVoorRecord,
  }) {
    return SyncMergeService.mergeJsonRecords(
      lokaal: AppStorage.decodeJsonMapLijstVoorSync(
        prefs.getString(lokaleDataKey),
      ),
      cloud: AppStorage.decodeJsonMapLijstVoorSync(
        cloudData[cloudDataVeld] is String
            ? cloudData[cloudDataVeld] as String
            : null,
      ),
      lokaleMetadata: SyncMergeService.decodeJsonRecordMetadata(
        prefs.getString(lokaleMetadataKey),
      ),
      cloudMetadata: SyncMergeService.decodeJsonRecordMetadata(
        cloudData[cloudMetadataVeld] is String
            ? cloudData[cloudMetadataVeld] as String
            : null,
      ),
      idVoorRecord: idVoorRecord ?? _standaardJsonRecordId,
      lokaleFallbackDatum: lokaleFallbackDatum,
      cloudFallbackDatum: cloudFallbackDatum,
    );
  }

  static Future<void> _bewaarJsonLijstCollectie({
    required SharedPreferences prefs,
    required String dataKey,
    required String metadataKey,
    required SyncJsonRecordMergeResult resultaat,
  }) async {
    await prefs.setString(
      dataKey,
      AppStorage.encodeJsonMapLijstVoorSync(resultaat.records),
    );
    await prefs.setString(
      metadataKey,
      SyncMergeService.encodeJsonRecordMetadata(resultaat.metadata),
    );
  }

  Future<String> _uploadKlantenFotos(String token) async {
    try {
      final appMap = await getApplicationDocumentsDirectory();

      final fotosMap = Directory('${appMap.path}/klanten_fotos');

      if (!await fotosMap.exists()) {
        await _uploadFotoManifest(
          token: token,
          bestanden: <Map<String, dynamic>>[],
        );

        return 'FOTOS_OK_GEEN_FOTOS';
      }

      final bestanden = <Map<String, dynamic>>[];

      final entities = fotosMap.listSync(recursive: true, followLinks: false);

      for (final entity in entities) {
        if (entity is! File) {
          continue;
        }

        final relatiefPad = entity.path
            .replaceFirst('${fotosMap.path}/', '')
            .replaceAll('\\', '/');

        final stat = await entity.stat();

        bestanden.add(<String, dynamic>{
          'pad': relatiefPad,
          'grootte': stat.size,
          'gewijzigdOp': stat.modified.toUtc().toIso8601String(),
        });

        final encodedPad = _encodeOneDrivePath('klanten_fotos/$relatiefPad');

        final url =
            'https://graph.microsoft.com/v1.0/me/drive/special/approot:/$encodedPad:/content';

        final bytes = await entity.readAsBytes();

        final response = await http.put(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/octet-stream',
          },
          body: bytes,
        );

        if (response.statusCode != 200 && response.statusCode != 201) {
          return 'FOTOS_UPLOAD_FOUT '
              '${response.statusCode}\n'
              '${response.body}';
        }
      }

      await _uploadFotoManifest(token: token, bestanden: bestanden);

      return 'FOTOS_OK ${bestanden.length}';
    } catch (e) {
      return 'FOTOS_EXCEPTION: $e';
    }
  }

  Future<void> _uploadFotoManifest({
    required String token,
    required List<Map<String, dynamic>> bestanden,
  }) async {
    final manifest = <String, dynamic>{
      'datum': DateTime.now().toIso8601String(),
      'bestanden': bestanden,
    };

    const url =
        'https://graph.microsoft.com/v1.0/me/drive/special/approot:/klanten_fotos_manifest.json:/content';

    await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(manifest),
    );
  }

  /// Automatische upload verzendt alleen de lichte gegevensbackup.
  ///
  /// Gewone lokale opslagacties worden 15 seconden gebundeld. Daardoor zorgt
  /// bijvoorbeeld het bewaren van meerdere agenda- of opmetingsvelden niet
  /// meer voor meerdere zware merge-uploads vlak na elkaar.
  ///
  /// Met [direct] wordt de debounce overgeslagen, bijvoorbeeld wanneer de app
  /// echt naar de achtergrond gaat of expliciet wordt afgesloten.
  Future<void> uploadBackupOpAchtergrond({bool direct = false}) async {
    /*
     * LOCAL-FIRST COMPATIBILITEITSLAAG
     *
     * Oudere pagina's roepen deze methode nog rechtstreeks aan na een lokale
     * wijziging. Vroeger startte dat na 15 seconden alsnog een volledige
     * merge-upload. Dat is precies wat tijdens typen/opmeten voor haperingen kon
     * zorgen.
     *
     * Vanaf nu start deze methode bewust GEEN netwerkverkeer meer. Ze markeert
     * alleen dat er lokaal iets wijzigde. De echte sync gebeurt op Home via
     * [syncModulesVoorHome], of als volledige veiligheidsbackup bij afsluiten.
     * [direct] blijft alleen voor broncompatibiliteit bestaan.
     */
    _achtergrondUploadTimer?.cancel();
    _achtergrondUploadTimer = null;
    await registreerLokaleWijziging();
  }


  Future<String> downloadBackup({bool downloadFotos = true}) async {
    final token = await OneDriveAuthService().loginInteractief();

    if (token.startsWith('FOUT')) {
      return token;
    }

    return downloadBackupMetToken(token, downloadFotos: downloadFotos);
  }

  /// Downloadt de gewone appgegevens.
  ///
  /// Bij automatische synchronisatie blijft [downloadFotos]
  /// false. Alleen een bewuste handmatige download zet dit
  /// op true.
  Future<String> downloadBackupMetToken(
    String token, {
    bool downloadFotos = false,
  }) async {
    if (_downloadBezig) {
      return 'FOUT_IMPORT_BEZIG';
    }

    _downloadBezig = true;

    try {
      return await _voerSyncGeserialiseerdUit(
        () => _downloadBackupMetTokenZonderVergrendeling(
          token,
          downloadFotos: downloadFotos,
        ),
      );
    } finally {
      _downloadBezig = false;
    }
  }

  Future<String> _downloadBackupMetTokenZonderVergrendeling(
    String token, {
    bool downloadFotos = false,
  }) async {
    try {
      if (token.startsWith('FOUT')) {
        return token;
      }

      const url =
          'https://graph.microsoft.com/v1.0/me/drive/special/approot:/thimaco_backup.json:/content';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        return 'IMPORT_FOUT '
            '${response.statusCode}\n'
            '${response.body}';
      }

      final data = await _decodeJsonObjectAchtergrond(response.body);

      final prefs = await SharedPreferences.getInstance();
      final backupDatum = data['backupDatum'] is String
          ? data['backupDatum'] as String
          : DateTime.now().toIso8601String();

      final cloudAgenda = await _decodeAgendaAchtergrond(
        data['agendaItems'] is String ? data['agendaItems'] as String : null,
      );

      final lokaleAgenda = await AppStorage.laadAgendaItemsNieuwVoorSync();

      final mergedAgenda = await _mergeAgendaAchtergrond(
        lokaleAgenda,
        cloudAgenda,
      );

      final cloudKlanten = await _decodeKlantenAchtergrond(
        data['klantenFiches'] is String
            ? data['klantenFiches'] as String
            : null,
      );

      final lokaleKlanten = await _decodeKlantenAchtergrond(
        prefs.getString('klanten_fiches'),
      );

      final mergedKlanten = await _mergeKlantenAchtergrond(
        lokaleKlanten,
        cloudKlanten,
      );

      final cloudOpmetingen = await _decodeOpmetingenAchtergrond(
        data['opmetingen'] is String ? data['opmetingen'] as String : null,
      );

      final lokaleOpmetingen = await AppStorage.laadOpmetingenVoorSync();

      final mergedOpmetingen = await _mergeOpmetingenAchtergrond(
        lokaleOpmetingen,
        cloudOpmetingen,
      );

      final bibliotheek = _kiesRecenteStringWaarde(
        lokaleWaarde: prefs.getString(_bibliotheekKey),
        cloudWaarde: data['bibliotheek'] is String
            ? data['bibliotheek'] as String
            : null,
        lokaleGewijzigdOp: prefs.getString(_bibliotheekGewijzigdOpKey),
        cloudGewijzigdOp: data['bibliotheekGewijzigdOp'] is String
            ? data['bibliotheekGewijzigdOp'] as String
            : null,
        fallbackDatum: backupDatum,
      );

      final offerteMailTeksten = _kiesRecenteStringWaarde(
        lokaleWaarde: prefs.getString(_offerteMailTekstenKey),
        cloudWaarde: data['offerteMailTeksten'] is String
            ? data['offerteMailTeksten'] as String
            : null,
        lokaleGewijzigdOp: prefs.getString(_offerteMailTekstenGewijzigdOpKey),
        cloudGewijzigdOp: data['offerteMailTekstenGewijzigdOp'] is String
            ? data['offerteMailTekstenGewijzigdOp'] as String
            : null,
        fallbackDatum: backupDatum,
      );

      final mergedOfferteAlgemenePrijsregels = _kiesRecenteInstellingenJson(
        lokaalJson: prefs.getString(_offerteAlgemenePrijsregelsKey),
        cloudJson: data['offerteAlgemenePrijsregels'] is String
            ? data['offerteAlgemenePrijsregels'] as String
            : null,
        lokaleFallbackDatum: prefs.getString(_backupDatumKey) ?? backupDatum,
        cloudFallbackDatum: backupDatum,
        lokaalWintBijGelijkeDatum: false,
      );

      final mergedMagazijnData = _mergeMagazijnJson(
        lokaalJson: prefs.getString(_magazijnDataKey),
        cloudJson: data['magazijnData'] is String
            ? data['magazijnData'] as String
            : null,
        lokaalWintBijConflict: false,
      );

      final mergedVoorzetscreenInstellingen = _kiesRecenteInstellingenJson(
        lokaalJson: prefs.getString(_opmetingVoorzetscreenInstellingenKey),
        cloudJson: data['opmetingVoorzetscreenInstellingen'] is String
            ? data['opmetingVoorzetscreenInstellingen'] as String
            : null,
        lokaleFallbackDatum: prefs.getString(_backupDatumKey) ?? backupDatum,
        cloudFallbackDatum: backupDatum,
        lokaalWintBijGelijkeDatum: false,
      );

      final mergedBuitenjaloezieInstellingen = _kiesRecenteInstellingenJson(
        lokaalJson: prefs.getString(_opmetingBuitenjaloezieInstellingenKey),
        cloudJson: data['opmetingBuitenjaloezieInstellingen'] is String
            ? data['opmetingBuitenjaloezieInstellingen'] as String
            : null,
        lokaleFallbackDatum: prefs.getString(_backupDatumKey) ?? backupDatum,
        cloudFallbackDatum: backupDatum,
        lokaalWintBijGelijkeDatum: false,
      );

      final mergedVoorzetrolluikInstellingen = _kiesRecenteInstellingenJson(
        lokaalJson: prefs.getString(_opmetingVoorzetrolluikInstellingenKey),
        cloudJson: data['opmetingVoorzetrolluikInstellingen'] is String
            ? data['opmetingVoorzetrolluikInstellingen'] as String
            : null,
        lokaleFallbackDatum: prefs.getString(_backupDatumKey) ?? backupDatum,
        cloudFallbackDatum: backupDatum,
        lokaalWintBijGelijkeDatum: false,
      );

      final mergedUitvalschermInstellingen = _kiesRecenteInstellingenJson(
        lokaalJson: prefs.getString(_opmetingUitvalschermInstellingenKey),
        cloudJson: data['opmetingUitvalschermInstellingen'] is String
            ? data['opmetingUitvalschermInstellingen'] as String
            : null,
        lokaleFallbackDatum: prefs.getString(_backupDatumKey) ?? backupDatum,
        cloudFallbackDatum: backupDatum,
        lokaalWintBijGelijkeDatum: false,
      );

      final mergedSektionalePoortInstellingen = _kiesRecenteInstellingenJson(
        lokaalJson: prefs.getString(_opmetingSektionalePoortInstellingenKey),
        cloudJson: data['opmetingSektionalePoortInstellingen'] is String
            ? data['opmetingSektionalePoortInstellingen'] as String
            : null,
        lokaleFallbackDatum: prefs.getString(_backupDatumKey) ?? backupDatum,
        cloudFallbackDatum: backupDatum,
        lokaalWintBijGelijkeDatum: false,
      );

      final mergedVeluxDakraamInstellingen = _kiesRecenteInstellingenJson(
        lokaalJson: prefs.getString(_opmetingVeluxDakraamInstellingenKey),
        cloudJson: data['opmetingVeluxDakraamInstellingen'] is String
            ? data['opmetingVeluxDakraamInstellingen'] as String
            : null,
        lokaleFallbackDatum: prefs.getString(_backupDatumKey) ?? backupDatum,
        cloudFallbackDatum: backupDatum,
        lokaalWintBijGelijkeDatum: false,
      );

      final lokaleTitelhoofden =
          await AppStorage.laadOpmetingProjectTitelhoofdenVoorSync();
      final cloudTitelhoofden =
          AppStorage.decodeOpmetingProjectTitelhoofdenVoorSync(
            data['opmetingProjectTitelhoofden'] is String
                ? data['opmetingProjectTitelhoofden'] as String
                : null,
          );
      final mergedTitelhoofden = SyncMergeService.mergeProjectTitelhoofden(
        lokaleTitelhoofden,
        cloudTitelhoofden,
      );

      // Alleen nog als eenmalige migratiebron voor oude vaste-inzethorwaarden.
      // Deze legacyprofielen worden niet meer gemerged of terug gesynchroniseerd.
      final lokalePrijsprofielenLegacy =
          await AppStorage.laadOffertePrijsProfielen();
      final cloudPrijsprofielenLegacy =
          AppStorage.decodeOffertePrijsProfielenVoorSync(
            data['offertePrijsProfielen'] is String
                ? data['offertePrijsProfielen'] as String
                : null,
          );

      final lokaleCollectieFallbackDatum =
          prefs.getString(_backupDatumKey) ?? backupDatum;

      final mergedDagtaakTemplates = _mergeJsonLijstCollectie(
        prefs: prefs,
        cloudData: data,
        lokaleDataKey: _dagtaakTemplatesKey,
        lokaleMetadataKey: _dagtaakTemplatesSyncMetaKey,
        cloudDataVeld: 'dagtaakTemplates',
        cloudMetadataVeld: 'dagtaakTemplatesSyncMeta',
        lokaleFallbackDatum: lokaleCollectieFallbackDatum,
        cloudFallbackDatum: backupDatum,
      );
      final mergedLeveranciers = _mergeJsonLijstCollectie(
        prefs: prefs,
        cloudData: data,
        lokaleDataKey: _leveranciersKey,
        lokaleMetadataKey: _leveranciersSyncMetaKey,
        cloudDataVeld: 'leveranciers',
        cloudMetadataVeld: 'leveranciersSyncMeta',
        lokaleFallbackDatum: lokaleCollectieFallbackDatum,
        cloudFallbackDatum: backupDatum,
        idVoorRecord: SyncMergeService.syncIdVoorLeverancierRecord,
      );
      final mergedNotities = _mergeJsonLijstCollectie(
        prefs: prefs,
        cloudData: data,
        lokaleDataKey: _notitiesKey,
        lokaleMetadataKey: _notitiesSyncMetaKey,
        cloudDataVeld: 'notities',
        cloudMetadataVeld: 'notitiesSyncMeta',
        lokaleFallbackDatum: lokaleCollectieFallbackDatum,
        cloudFallbackDatum: backupDatum,
      );
      final mergedNotitieActies = _mergeJsonLijstCollectie(
        prefs: prefs,
        cloudData: data,
        lokaleDataKey: _notitieActiesKey,
        lokaleMetadataKey: _notitieActiesSyncMetaKey,
        cloudDataVeld: 'notitieActies',
        cloudMetadataVeld: 'notitieActiesSyncMeta',
        lokaleFallbackDatum: lokaleCollectieFallbackDatum,
        cloudFallbackDatum: backupDatum,
      );
      final mergedProjectKleuren = _mergeJsonLijstCollectie(
        prefs: prefs,
        cloudData: data,
        lokaleDataKey: _opmetingProjectKleurenKey,
        lokaleMetadataKey: _opmetingProjectKleurenSyncMetaKey,
        cloudDataVeld: 'opmetingProjectKleuren',
        cloudMetadataVeld: 'opmetingProjectKleurenSyncMeta',
        lokaleFallbackDatum: lokaleCollectieFallbackDatum,
        cloudFallbackDatum: backupDatum,
      );
      final mergedOffertePrijsPerArtikelTemplates = _mergeJsonLijstCollectie(
        prefs: prefs,
        cloudData: data,
        lokaleDataKey: _offertePrijsPerArtikelTemplatesKey,
        lokaleMetadataKey: _offertePrijsPerArtikelTemplatesSyncMetaKey,
        cloudDataVeld: 'offertePrijsPerArtikelTemplates',
        cloudMetadataVeld: 'offertePrijsPerArtikelTemplatesSyncMeta',
        lokaleFallbackDatum: lokaleCollectieFallbackDatum,
        cloudFallbackDatum: backupDatum,
      );
      final mergedOffertePrijsVoorAllePositiesTemplates =
          _mergeJsonLijstCollectie(
            prefs: prefs,
            cloudData: data,
            lokaleDataKey: _offertePrijsVoorAllePositiesTemplatesKey,
            lokaleMetadataKey:
                _offertePrijsVoorAllePositiesTemplatesSyncMetaKey,
            cloudDataVeld: 'offertePrijsVoorAllePositiesTemplates',
            cloudMetadataVeld: 'offertePrijsVoorAllePositiesTemplatesSyncMeta',
            lokaleFallbackDatum: lokaleCollectieFallbackDatum,
            cloudFallbackDatum: backupDatum,
          );
      final mergedOffertePrijsVerdeeldOverTemplates = _mergeJsonLijstCollectie(
        prefs: prefs,
        cloudData: data,
        lokaleDataKey: _offertePrijsVerdeeldOverTemplatesKey,
        lokaleMetadataKey: _offertePrijsVerdeeldOverTemplatesSyncMetaKey,
        cloudDataVeld: 'offertePrijsVerdeeldOverTemplates',
        cloudMetadataVeld: 'offertePrijsVerdeeldOverTemplatesSyncMeta',
        lokaleFallbackDatum: lokaleCollectieFallbackDatum,
        cloudFallbackDatum: backupDatum,
      );
      final mergedOfferteTechnischeKeuzePrijzen = _mergeJsonLijstCollectie(
        prefs: prefs,
        cloudData: data,
        lokaleDataKey: _offerteTechnischeKeuzePrijzenKey,
        lokaleMetadataKey: _offerteTechnischeKeuzePrijzenSyncMetaKey,
        cloudDataVeld: 'offerteTechnischeKeuzePrijzen',
        cloudMetadataVeld: 'offerteTechnischeKeuzePrijzenSyncMeta',
        lokaleFallbackDatum: lokaleCollectieFallbackDatum,
        cloudFallbackDatum: backupDatum,
      );
      final lokaleVasteInzethorStandaardPrijsinstellingen =
          AppStorage.decodeJsonMapLijstVoorSync(
            prefs.getString(_offerteVasteInzethorStandaardPrijsinstellingenKey),
          );
      final cloudVasteInzethorStandaardPrijsinstellingen =
          AppStorage.decodeJsonMapLijstVoorSync(
            data['offerteVasteInzethorStandaardPrijsinstellingen'] is String
                ? data['offerteVasteInzethorStandaardPrijsinstellingen']
                      as String
                : null,
          );

      if (lokaleVasteInzethorStandaardPrijsinstellingen.isEmpty &&
          cloudVasteInzethorStandaardPrijsinstellingen.isEmpty) {
        final legacyVasteInzethor =
            AppStorage.vasteInzethorStandaardPrijsinstellingenUitLegacyProfielen(
              lokalePrijsprofielenLegacy,
            ) ??
            AppStorage.vasteInzethorStandaardPrijsinstellingenUitLegacyProfielen(
              cloudPrijsprofielenLegacy,
            );
        if (legacyVasteInzethor != null) {
          await AppStorage.bewaarVasteInzethorStandaardPrijsinstellingenVoorSync(
            standaardPrijsPerStukExclBtw:
                legacyVasteInzethor.standaardPrijsPerStukExclBtw,
            standaardWinstmargePercentage:
                legacyVasteInzethor.standaardWinstmargePercentage,
            standaardKortingPercentage:
                legacyVasteInzethor.standaardKortingPercentage,
          );
        }
      }

      final mergedVasteInzethorStandaardPrijsinstellingen =
          _mergeJsonLijstCollectie(
            prefs: prefs,
            cloudData: data,
            lokaleDataKey: _offerteVasteInzethorStandaardPrijsinstellingenKey,
            lokaleMetadataKey:
                _offerteVasteInzethorStandaardPrijsinstellingenSyncMetaKey,
            cloudDataVeld: 'offerteVasteInzethorStandaardPrijsinstellingen',
            cloudMetadataVeld:
                'offerteVasteInzethorStandaardPrijsinstellingenSyncMeta',
            lokaleFallbackDatum: lokaleCollectieFallbackDatum,
            cloudFallbackDatum: backupDatum,
          );
      final mergedRaamKeuzemenus = _mergeJsonLijstCollectie(
        prefs: prefs,
        cloudData: data,
        lokaleDataKey: _opmetingRaamKeuzemenusKey,
        lokaleMetadataKey: _syncMetaKeyVoorDataKey(_opmetingRaamKeuzemenusKey),
        cloudDataVeld: 'opmetingRaamKeuzemenus',
        cloudMetadataVeld: 'opmetingRaamKeuzemenusSyncMeta',
        lokaleFallbackDatum: lokaleCollectieFallbackDatum,
        cloudFallbackDatum: backupDatum,
      );
      final mergedRaamKeuzemenusAlu = _mergeJsonLijstCollectie(
        prefs: prefs,
        cloudData: data,
        lokaleDataKey: _opmetingRaamKeuzemenusAluKey,
        lokaleMetadataKey: _syncMetaKeyVoorDataKey(
          _opmetingRaamKeuzemenusAluKey,
        ),
        cloudDataVeld: 'opmetingRaamKeuzemenusAlu',
        cloudMetadataVeld: 'opmetingRaamKeuzemenusAluSyncMeta',
        lokaleFallbackDatum: lokaleCollectieFallbackDatum,
        cloudFallbackDatum: backupDatum,
      );
      final mergedDeurKeuzemenusPvc = _mergeJsonLijstCollectie(
        prefs: prefs,
        cloudData: data,
        lokaleDataKey: _opmetingDeurKeuzemenusPvcKey,
        lokaleMetadataKey: _syncMetaKeyVoorDataKey(
          _opmetingDeurKeuzemenusPvcKey,
        ),
        cloudDataVeld: 'opmetingDeurKeuzemenusPvc',
        cloudMetadataVeld: 'opmetingDeurKeuzemenusPvcSyncMeta',
        lokaleFallbackDatum: lokaleCollectieFallbackDatum,
        cloudFallbackDatum: backupDatum,
      );
      final mergedDeurKeuzemenusAlu = _mergeJsonLijstCollectie(
        prefs: prefs,
        cloudData: data,
        lokaleDataKey: _opmetingDeurKeuzemenusAluKey,
        lokaleMetadataKey: _syncMetaKeyVoorDataKey(
          _opmetingDeurKeuzemenusAluKey,
        ),
        cloudDataVeld: 'opmetingDeurKeuzemenusAlu',
        cloudMetadataVeld: 'opmetingDeurKeuzemenusAluSyncMeta',
        lokaleFallbackDatum: lokaleCollectieFallbackDatum,
        cloudFallbackDatum: backupDatum,
      );
      final mergedSchuifraamKeuzemenusPvc = _mergeJsonLijstCollectie(
        prefs: prefs,
        cloudData: data,
        lokaleDataKey: _opmetingSchuifraamKeuzemenusPvcKey,
        lokaleMetadataKey: _syncMetaKeyVoorDataKey(
          _opmetingSchuifraamKeuzemenusPvcKey,
        ),
        cloudDataVeld: 'opmetingSchuifraamKeuzemenusPvc',
        cloudMetadataVeld: 'opmetingSchuifraamKeuzemenusPvcSyncMeta',
        lokaleFallbackDatum: lokaleCollectieFallbackDatum,
        cloudFallbackDatum: backupDatum,
      );
      final mergedSchuifraamKeuzemenusAlu = _mergeJsonLijstCollectie(
        prefs: prefs,
        cloudData: data,
        lokaleDataKey: _opmetingSchuifraamKeuzemenusAluKey,
        lokaleMetadataKey: _syncMetaKeyVoorDataKey(
          _opmetingSchuifraamKeuzemenusAluKey,
        ),
        cloudDataVeld: 'opmetingSchuifraamKeuzemenusAlu',
        cloudMetadataVeld: 'opmetingSchuifraamKeuzemenusAluSyncMeta',
        lokaleFallbackDatum: lokaleCollectieFallbackDatum,
        cloudFallbackDatum: backupDatum,
      );

      final deurpanelenBibliotheek = _kiesRecenteStringWaarde(
        lokaleWaarde: prefs.getString(_deurpanelenBibliotheekKey),
        cloudWaarde: data['deurpanelenBibliotheek'] is String
            ? data['deurpanelenBibliotheek'] as String
            : null,
        lokaleGewijzigdOp: prefs.getString(
          _deurpanelenBibliotheekGewijzigdOpKey,
        ),
        cloudGewijzigdOp: data['deurpanelenBibliotheekGewijzigdOp'] is String
            ? data['deurpanelenBibliotheekGewijzigdOp'] as String
            : null,
        fallbackDatum: backupDatum,
      );

      final deurpanelenDxfBibliotheek = _kiesRecenteStringWaarde(
        lokaleWaarde: prefs.getString(_deurpanelenDxfBibliotheekKey),
        cloudWaarde: data['deurpanelenDxfBibliotheek'] is String
            ? data['deurpanelenDxfBibliotheek'] as String
            : null,
        lokaleGewijzigdOp: prefs.getString(
          _deurpanelenDxfBibliotheekGewijzigdOpKey,
        ),
        cloudGewijzigdOp: data['deurpanelenDxfBibliotheekGewijzigdOp'] is String
            ? data['deurpanelenDxfBibliotheekGewijzigdOp'] as String
            : null,
        fallbackDatum: backupDatum,
      );

      final mergedDeurpaneelToewijzingen =
          SyncMergeService.mergeStringRecordsOpDatum(
            lokaal: _leesStringPrefsMetPrefix(
              prefs,
              _deurpaneelToewijzingenPrefix,
            ),
            cloud: _leesStringMap(data['deurpaneelToewijzingen']),
            lokaleGewijzigdOp: _leesDeurpaneelToewijzingDatums(prefs),
            cloudGewijzigdOp: _leesStringMap(
              data['deurpaneelToewijzingenGewijzigdOp'],
            ),
            lokaleFallbackDatum:
                prefs.getString(_backupDatumKey) ?? backupDatum,
            cloudFallbackDatum: backupDatum,
          );

      await _geefUiTijd();

      await AppStorage.bewaarAgendaItemsNieuwVoorSync(mergedAgenda);

      await _bewaarOptioneleString(
        prefs: prefs,
        key: _bibliotheekKey,
        waarde: bibliotheek.waarde,
      );
      await _bewaarOptioneleString(
        prefs: prefs,
        key: _bibliotheekGewijzigdOpKey,
        waarde: bibliotheek.gewijzigdOp,
      );
      await _bewaarOptioneleString(
        prefs: prefs,
        key: _offerteMailTekstenKey,
        waarde: offerteMailTeksten.waarde,
      );
      await _bewaarOptioneleString(
        prefs: prefs,
        key: _offerteMailTekstenGewijzigdOpKey,
        waarde: offerteMailTeksten.gewijzigdOp,
      );
      await _bewaarOptioneleString(
        prefs: prefs,
        key: _offerteAlgemenePrijsregelsKey,
        waarde: mergedOfferteAlgemenePrijsregels,
      );

      await AppStorage.bewaarKlantenFichesVoorSync(
        mergedKlanten.map((fiche) => fiche.toJson()).toList(),
      );

      await AppStorage.bewaarOpmetingenVoorSync(mergedOpmetingen);
      await _geefUiTijd();
      await prefs.setString(_magazijnDataKey, mergedMagazijnData);
      await _bewaarOptioneleString(
        prefs: prefs,
        key: _opmetingVoorzetscreenInstellingenKey,
        waarde: mergedVoorzetscreenInstellingen,
      );
      await _bewaarOptioneleString(
        prefs: prefs,
        key: _opmetingBuitenjaloezieInstellingenKey,
        waarde: mergedBuitenjaloezieInstellingen,
      );
      await _bewaarOptioneleString(
        prefs: prefs,
        key: _opmetingVoorzetrolluikInstellingenKey,
        waarde: mergedVoorzetrolluikInstellingen,
      );
      await _bewaarOptioneleString(
        prefs: prefs,
        key: _opmetingUitvalschermInstellingenKey,
        waarde: mergedUitvalschermInstellingen,
      );
      await _bewaarOptioneleString(
        prefs: prefs,
        key: _opmetingSektionalePoortInstellingenKey,
        waarde: mergedSektionalePoortInstellingen,
      );
      await _bewaarOptioneleString(
        prefs: prefs,
        key: _opmetingVeluxDakraamInstellingenKey,
        waarde: mergedVeluxDakraamInstellingen,
      );
      await AppStorage.bewaarOpmetingProjectTitelhoofdenVoorSync(
        mergedTitelhoofden,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _dagtaakTemplatesKey,
        metadataKey: _dagtaakTemplatesSyncMetaKey,
        resultaat: mergedDagtaakTemplates,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _leveranciersKey,
        metadataKey: _leveranciersSyncMetaKey,
        resultaat: mergedLeveranciers,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _notitiesKey,
        metadataKey: _notitiesSyncMetaKey,
        resultaat: mergedNotities,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _notitieActiesKey,
        metadataKey: _notitieActiesSyncMetaKey,
        resultaat: mergedNotitieActies,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _opmetingProjectKleurenKey,
        metadataKey: _opmetingProjectKleurenSyncMetaKey,
        resultaat: mergedProjectKleuren,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _offertePrijsPerArtikelTemplatesKey,
        metadataKey: _offertePrijsPerArtikelTemplatesSyncMetaKey,
        resultaat: mergedOffertePrijsPerArtikelTemplates,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _offertePrijsVoorAllePositiesTemplatesKey,
        metadataKey: _offertePrijsVoorAllePositiesTemplatesSyncMetaKey,
        resultaat: mergedOffertePrijsVoorAllePositiesTemplates,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _offertePrijsVerdeeldOverTemplatesKey,
        metadataKey: _offertePrijsVerdeeldOverTemplatesSyncMetaKey,
        resultaat: mergedOffertePrijsVerdeeldOverTemplates,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _offerteTechnischeKeuzePrijzenKey,
        metadataKey: _offerteTechnischeKeuzePrijzenSyncMetaKey,
        resultaat: mergedOfferteTechnischeKeuzePrijzen,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _offerteVasteInzethorStandaardPrijsinstellingenKey,
        metadataKey: _offerteVasteInzethorStandaardPrijsinstellingenSyncMetaKey,
        resultaat: mergedVasteInzethorStandaardPrijsinstellingen,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _opmetingRaamKeuzemenusKey,
        metadataKey: _syncMetaKeyVoorDataKey(_opmetingRaamKeuzemenusKey),
        resultaat: mergedRaamKeuzemenus,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _opmetingRaamKeuzemenusAluKey,
        metadataKey: _syncMetaKeyVoorDataKey(_opmetingRaamKeuzemenusAluKey),
        resultaat: mergedRaamKeuzemenusAlu,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _opmetingDeurKeuzemenusPvcKey,
        metadataKey: _syncMetaKeyVoorDataKey(_opmetingDeurKeuzemenusPvcKey),
        resultaat: mergedDeurKeuzemenusPvc,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _opmetingDeurKeuzemenusAluKey,
        metadataKey: _syncMetaKeyVoorDataKey(_opmetingDeurKeuzemenusAluKey),
        resultaat: mergedDeurKeuzemenusAlu,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _opmetingSchuifraamKeuzemenusPvcKey,
        metadataKey: _syncMetaKeyVoorDataKey(
          _opmetingSchuifraamKeuzemenusPvcKey,
        ),
        resultaat: mergedSchuifraamKeuzemenusPvc,
      );
      await _bewaarJsonLijstCollectie(
        prefs: prefs,
        dataKey: _opmetingSchuifraamKeuzemenusAluKey,
        metadataKey: _syncMetaKeyVoorDataKey(
          _opmetingSchuifraamKeuzemenusAluKey,
        ),
        resultaat: mergedSchuifraamKeuzemenusAlu,
      );

      if (data['opmetingRaamOpvullingen'] is String) {
        await prefs.setString(
          'opmeting_raam_opvullingen',
          data['opmetingRaamOpvullingen'],
        );
      }

      if (data['opmetingSchuifraamOpbouwTypes'] is String) {
        await prefs.setString(
          _opmetingSchuifraamOpbouwTypesKey,
          data['opmetingSchuifraamOpbouwTypes'],
        );
      }

      if (data['opmetingPlooiwerkenInstellingen'] is String) {
        await prefs.setString(
          _opmetingPlooiwerkenInstellingenKey,
          data['opmetingPlooiwerkenInstellingen'],
        );
      }

      await _bewaarOptioneleString(
        prefs: prefs,
        key: _deurpanelenBibliotheekKey,
        waarde: deurpanelenBibliotheek.waarde,
      );
      await _bewaarOptioneleString(
        prefs: prefs,
        key: _deurpanelenBibliotheekGewijzigdOpKey,
        waarde: deurpanelenBibliotheek.gewijzigdOp,
      );
      await _bewaarOptioneleString(
        prefs: prefs,
        key: _deurpanelenDxfBibliotheekKey,
        waarde: deurpanelenDxfBibliotheek.waarde,
      );
      await _bewaarOptioneleString(
        prefs: prefs,
        key: _deurpanelenDxfBibliotheekGewijzigdOpKey,
        waarde: deurpanelenDxfBibliotheek.gewijzigdOp,
      );
      await _schrijfStringPrefsMetPrefix(
        prefs,
        _deurpaneelToewijzingenPrefix,
        mergedDeurpaneelToewijzingen.waarden,
      );
      await _schrijfDeurpaneelToewijzingDatums(
        prefs,
        mergedDeurpaneelToewijzingen.gewijzigdOp,
      );

      if (data['backupDatum'] is String) {
        await prefs.setString(_backupDatumKey, data['backupDatum']);
      }

      await _verversOneDriveEtagMetToken(prefs: prefs, token: token);

      String fotoResultaat = 'FOTOS_OVERGESLAGEN';

      if (downloadFotos) {
        fotoResultaat = await _downloadKlantenFotos(token);
      }

      laatsteSyncActie = downloadFotos
          ? 'Download met foto’s en deurpanelen uitgevoerd'
          : 'Snelle download zonder foto’s met deurpanelen uitgevoerd';

      if (downloadFotos && !fotoResultaat.startsWith('FOTOS_OK')) {
        return 'IMPORT_OK_FOTOS_LATER\n'
            '$fotoResultaat';
      }

      return downloadFotos ? 'IMPORT_OK' : 'IMPORT_OK_ZONDER_FOTOS';
    } catch (e) {
      return 'IMPORT_EXCEPTION: $e';
    }
  }


  String _moduleBestandsnaam(String module) {
    return 'thimaco_sync_${module.trim().toLowerCase()}.json';
  }

  String _moduleHashKey(String module) => '$_moduleHashPrefix$module';

  String _moduleEtagKey(String module) => '$_moduleEtagPrefix$module';

  String _stabieleHash(String tekst) {
    // FNV-1a 64-bit: klein, deterministisch en voldoende als wijzigingsvingerafdruk.
    var hash = 0xcbf29ce484222325;
    const prime = 0x100000001b3;
    const mask = 0xffffffffffffffff;

    for (final codeUnit in tekst.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * prime) & mask;
    }

    return hash.toRadixString(16).padLeft(16, '0');
  }

  String _moduleBronString({
    required String module,
    required SharedPreferences prefs,
  }) {
    String waarde(String key) => prefs.getString(key) ?? '';

    switch (module) {
      case 'agenda':
        return <String>[
          waarde('agenda_items_nieuw'),
          waarde(_dagtaakTemplatesKey),
          waarde(_dagtaakTemplatesSyncMetaKey),
        ].join('\u001f');
      case 'klanten':
        return waarde('klanten_fiches');
      case 'notities':
        return <String>[
          waarde(_notitiesKey),
          waarde(_notitiesSyncMetaKey),
          waarde(_notitieActiesKey),
          waarde(_notitieActiesSyncMetaKey),
        ].join('\u001f');
      case 'opmetingen':
        return <String>[
          waarde('thimaco_opmetingen'),
          waarde('thimaco_opmeting_project_titelhoofden'),
        ].join('\u001f');
      case 'magazijn':
        return waarde(_magazijnDataKey);
      default:
        return '';
    }
  }

  String _lokaleModuleHash({
    required String module,
    required SharedPreferences prefs,
  }) {
    return _stabieleHash(_moduleBronString(module: module, prefs: prefs));
  }

  Future<_OneDriveModuleInfo> _moduleInfoMetToken({
    required String token,
    required String module,
  }) async {
    final bestand = Uri.encodeComponent(_moduleBestandsnaam(module));
    final url =
        'https://graph.microsoft.com/v1.0/me/drive/special/approot:/$bestand?%24select=eTag,lastModifiedDateTime,size';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 404) {
        return const _OneDriveModuleInfo(
          gevonden: false,
          fout: false,
          etag: '',
        );
      }

      if (response.statusCode != 200) {
        return _OneDriveModuleInfo(
          gevonden: false,
          fout: true,
          etag: '',
          foutmelding: 'MODULE_INFO_${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        return const _OneDriveModuleInfo(
          gevonden: false,
          fout: true,
          etag: '',
          foutmelding: 'MODULE_INFO_ONGELDIG',
        );
      }

      return _OneDriveModuleInfo(
        gevonden: true,
        fout: false,
        etag: decoded['eTag']?.toString().trim() ?? '',
      );
    } catch (e) {
      return _OneDriveModuleInfo(
        gevonden: false,
        fout: true,
        etag: '',
        foutmelding: 'MODULE_INFO_EXCEPTION: $e',
      );
    }
  }

  Future<Map<String, dynamic>> _downloadModuleData({
    required String token,
    required String module,
  }) async {
    final bestand = Uri.encodeComponent(_moduleBestandsnaam(module));
    final url =
        'https://graph.microsoft.com/v1.0/me/drive/special/approot:/$bestand:/content';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 404) {
      return <String, dynamic>{};
    }

    if (response.statusCode != 200) {
      throw StateError(
        'MODULE_DOWNLOAD_${module}_${response.statusCode}: ${response.body}',
      );
    }

    return _decodeJsonObjectAchtergrond(response.body);
  }

  Future<String> _uploadModuleData({
    required String token,
    required String module,
    required Map<String, dynamic> data,
  }) async {
    final bestand = Uri.encodeComponent(_moduleBestandsnaam(module));
    final url =
        'https://graph.microsoft.com/v1.0/me/drive/special/approot:/$bestand:/content';

    final inhoud = await _encodeJsonAchtergrond(data);
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: inhoud,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw StateError(
        'MODULE_UPLOAD_${module}_${response.statusCode}: ${response.body}',
      );
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        return decoded['eTag']?.toString().trim() ?? '';
      }
    } catch (_) {
      // Als Graph geen DriveItem-body teruggeeft halen we de ETag nadien op.
    }

    return '';
  }

  Future<_ModuleSyncUitkomst> _syncEenModule({
    required String token,
    required SharedPreferences prefs,
    required String module,
  }) async {
    final huidigeHash = _lokaleModuleHash(module: module, prefs: prefs);
    final bewaardeHash = prefs.getString(_moduleHashKey(module)) ?? '';
    final lokaalGewijzigd =
        bewaardeHash.isEmpty || bewaardeHash != huidigeHash;

    final remoteInfo = await _moduleInfoMetToken(token: token, module: module);
    if (remoteInfo.fout) {
      return _ModuleSyncUitkomst(
        gelukt: false,
        remoteToegepast: false,
        melding: remoteInfo.foutmelding,
      );
    }

    final bewaardeEtag = prefs.getString(_moduleEtagKey(module)) ?? '';
    final remoteGewijzigd = remoteInfo.gevonden &&
        (bewaardeEtag.isEmpty || remoteInfo.etag != bewaardeEtag);

    if (!lokaalGewijzigd && !remoteGewijzigd && remoteInfo.gevonden) {
      return const _ModuleSyncUitkomst(
        gelukt: true,
        remoteToegepast: false,
        melding: 'ongewijzigd',
      );
    }

    Map<String, dynamic> cloudData = <String, dynamic>{};
    if (remoteInfo.gevonden && (lokaalGewijzigd || remoteGewijzigd)) {
      cloudData = await _downloadModuleData(token: token, module: module);
    }

    final remoteToegepast = remoteInfo.gevonden && remoteGewijzigd;
    final nu = DateTime.now().toUtc().toIso8601String();
    late final Map<String, dynamic> mergedData;

    switch (module) {
      case 'agenda':
        mergedData = await _mergeAgendaModule(
          prefs: prefs,
          cloudData: cloudData,
          moduleDatum: nu,
        );
        break;
      case 'klanten':
        mergedData = await _mergeKlantenModule(
          prefs: prefs,
          cloudData: cloudData,
          moduleDatum: nu,
        );
        break;
      case 'notities':
        mergedData = await _mergeNotitiesModule(
          prefs: prefs,
          cloudData: cloudData,
          moduleDatum: nu,
        );
        break;
      case 'opmetingen':
        mergedData = await _mergeOpmetingenModule(
          cloudData: cloudData,
          moduleDatum: nu,
        );
        break;
      case 'magazijn':
        mergedData = await _mergeMagazijnModule(
          prefs: prefs,
          cloudData: cloudData,
          moduleDatum: nu,
          lokaalWintBijConflict: lokaalGewijzigd,
        );
        break;
      default:
        return const _ModuleSyncUitkomst(
          gelukt: true,
          remoteToegepast: false,
          melding: 'module overgeslagen',
        );
    }

    String nieuweEtag = remoteInfo.etag;

    // Alleen wanneer lokaal iets veranderde of het modulebestand nog niet
    // bestaat, schrijven we naar OneDrive. Een puur remote wijziging wordt
    // alleen lokaal toegepast.
    if (lokaalGewijzigd || !remoteInfo.gevonden) {
      nieuweEtag = await _uploadModuleData(
        token: token,
        module: module,
        data: mergedData,
      );

      if (nieuweEtag.isEmpty) {
        final naUpload = await _moduleInfoMetToken(token: token, module: module);
        if (!naUpload.fout && naUpload.gevonden) {
          nieuweEtag = naUpload.etag;
        }
      }
    }

    final nieuweHash = _lokaleModuleHash(module: module, prefs: prefs);
    await prefs.setString(_moduleHashKey(module), nieuweHash);

    if (nieuweEtag.isNotEmpty) {
      await prefs.setString(_moduleEtagKey(module), nieuweEtag);
    }

    return _ModuleSyncUitkomst(
      gelukt: true,
      remoteToegepast: remoteToegepast,
      melding: lokaalGewijzigd
          ? 'lokale wijziging gesynchroniseerd'
          : 'remote wijziging toegepast',
    );
  }

  Future<Map<String, dynamic>> _mergeAgendaModule({
    required SharedPreferences prefs,
    required Map<String, dynamic> cloudData,
    required String moduleDatum,
  }) async {
    final lokaleAgenda = await AppStorage.laadAgendaItemsNieuwVoorSync();
    final cloudAgenda = await _decodeAgendaAchtergrond(
      cloudData['agendaItems'] is String
          ? cloudData['agendaItems'] as String
          : null,
    );
    final mergedAgenda = await _mergeAgendaAchtergrond(
      lokaleAgenda,
      cloudAgenda,
    );
    await AppStorage.bewaarAgendaItemsNieuwVoorSync(mergedAgenda);

    final cloudDatum = cloudData['moduleDatum']?.toString() ?? moduleDatum;
    final lokaleFallback = prefs.getString(_backupDatumKey) ?? moduleDatum;
    final mergedTemplates = _mergeJsonLijstCollectie(
      prefs: prefs,
      cloudData: cloudData,
      lokaleDataKey: _dagtaakTemplatesKey,
      lokaleMetadataKey: _dagtaakTemplatesSyncMetaKey,
      cloudDataVeld: 'dagtaakTemplates',
      cloudMetadataVeld: 'dagtaakTemplatesSyncMeta',
      lokaleFallbackDatum: lokaleFallback,
      cloudFallbackDatum: cloudDatum,
    );
    await _bewaarJsonLijstCollectie(
      prefs: prefs,
      dataKey: _dagtaakTemplatesKey,
      metadataKey: _dagtaakTemplatesSyncMetaKey,
      resultaat: mergedTemplates,
    );

    return <String, dynamic>{
      'schema': 1,
      'module': 'agenda',
      'moduleDatum': moduleDatum,
      'agendaItems': await _encodeAgendaAchtergrond(mergedAgenda),
      'dagtaakTemplates': AppStorage.encodeJsonMapLijstVoorSync(
        mergedTemplates.records,
      ),
      'dagtaakTemplatesSyncMeta':
          SyncMergeService.encodeJsonRecordMetadata(mergedTemplates.metadata),
    };
  }

  Future<Map<String, dynamic>> _mergeKlantenModule({
    required SharedPreferences prefs,
    required Map<String, dynamic> cloudData,
    required String moduleDatum,
  }) async {
    final lokaal = await _decodeKlantenAchtergrond(
      prefs.getString('klanten_fiches'),
    );
    final cloud = await _decodeKlantenAchtergrond(
      cloudData['klantenFiches'] is String
          ? cloudData['klantenFiches'] as String
          : null,
    );
    final merged = await _mergeKlantenAchtergrond(lokaal, cloud);

    await AppStorage.bewaarKlantenFichesVoorSync(
      merged.map((fiche) => fiche.toJson()).toList(growable: false),
    );

    return <String, dynamic>{
      'schema': 1,
      'module': 'klanten',
      'moduleDatum': moduleDatum,
      'klantenFiches': await _encodeKlantenAchtergrond(merged),
    };
  }

  Future<Map<String, dynamic>> _mergeNotitiesModule({
    required SharedPreferences prefs,
    required Map<String, dynamic> cloudData,
    required String moduleDatum,
  }) async {
    final cloudDatum = cloudData['moduleDatum']?.toString() ?? moduleDatum;
    final lokaleFallback = prefs.getString(_backupDatumKey) ?? moduleDatum;

    final mergedNotities = _mergeJsonLijstCollectie(
      prefs: prefs,
      cloudData: cloudData,
      lokaleDataKey: _notitiesKey,
      lokaleMetadataKey: _notitiesSyncMetaKey,
      cloudDataVeld: 'notities',
      cloudMetadataVeld: 'notitiesSyncMeta',
      lokaleFallbackDatum: lokaleFallback,
      cloudFallbackDatum: cloudDatum,
    );

    final mergedActies = _mergeJsonLijstCollectie(
      prefs: prefs,
      cloudData: cloudData,
      lokaleDataKey: _notitieActiesKey,
      lokaleMetadataKey: _notitieActiesSyncMetaKey,
      cloudDataVeld: 'notitieActies',
      cloudMetadataVeld: 'notitieActiesSyncMeta',
      lokaleFallbackDatum: lokaleFallback,
      cloudFallbackDatum: cloudDatum,
    );

    await _bewaarJsonLijstCollectie(
      prefs: prefs,
      dataKey: _notitiesKey,
      metadataKey: _notitiesSyncMetaKey,
      resultaat: mergedNotities,
    );
    await _bewaarJsonLijstCollectie(
      prefs: prefs,
      dataKey: _notitieActiesKey,
      metadataKey: _notitieActiesSyncMetaKey,
      resultaat: mergedActies,
    );

    return <String, dynamic>{
      'schema': 1,
      'module': 'notities',
      'moduleDatum': moduleDatum,
      'notities': AppStorage.encodeJsonMapLijstVoorSync(mergedNotities.records),
      'notitiesSyncMeta':
          SyncMergeService.encodeJsonRecordMetadata(mergedNotities.metadata),
      'notitieActies':
          AppStorage.encodeJsonMapLijstVoorSync(mergedActies.records),
      'notitieActiesSyncMeta':
          SyncMergeService.encodeJsonRecordMetadata(mergedActies.metadata),
    };
  }

  Future<Map<String, dynamic>> _mergeOpmetingenModule({
    required Map<String, dynamic> cloudData,
    required String moduleDatum,
  }) async {
    final lokaal = await AppStorage.laadOpmetingenVoorSync();
    final cloud = await _decodeOpmetingenAchtergrond(
      cloudData['opmetingen'] is String
          ? cloudData['opmetingen'] as String
          : null,
    );
    final merged = await _mergeOpmetingenAchtergrond(lokaal, cloud);
    await AppStorage.bewaarOpmetingenVoorSync(merged);

    final lokaleTitelhoofden =
        await AppStorage.laadOpmetingProjectTitelhoofdenVoorSync();
    final cloudTitelhoofden =
        AppStorage.decodeOpmetingProjectTitelhoofdenVoorSync(
          cloudData['opmetingProjectTitelhoofden'] is String
              ? cloudData['opmetingProjectTitelhoofden'] as String
              : null,
        );
    final mergedTitelhoofden = SyncMergeService.mergeProjectTitelhoofden(
      lokaleTitelhoofden,
      cloudTitelhoofden,
    );
    await AppStorage.bewaarOpmetingProjectTitelhoofdenVoorSync(
      mergedTitelhoofden,
    );

    return <String, dynamic>{
      'schema': 1,
      'module': 'opmetingen',
      'moduleDatum': moduleDatum,
      'opmetingen': await _encodeOpmetingenAchtergrond(merged),
      'opmetingProjectTitelhoofden':
          AppStorage.encodeOpmetingProjectTitelhoofdenVoorSync(
            mergedTitelhoofden,
          ),
    };
  }

  Future<Map<String, dynamic>> _mergeMagazijnModule({
    required SharedPreferences prefs,
    required Map<String, dynamic> cloudData,
    required String moduleDatum,
    required bool lokaalWintBijConflict,
  }) async {
    final merged = _mergeMagazijnJson(
      lokaalJson: prefs.getString(_magazijnDataKey),
      cloudJson: cloudData['magazijnData'] is String
          ? cloudData['magazijnData'] as String
          : null,
      lokaalWintBijConflict: lokaalWintBijConflict,
    );

    await prefs.setString(_magazijnDataKey, merged);

    return <String, dynamic>{
      'schema': 1,
      'module': 'magazijn',
      'moduleDatum': moduleDatum,
      'magazijnData': merged,
    };
  }

  Future<bool> _pasLegacyBackupToeIndienGewijzigd({
    required String token,
    required SharedPreferences prefs,
  }) async {
    final remoteInfo = await _oneDriveBackupInfoMetToken(token);
    if (remoteInfo == null) {
      return false;
    }

    final remoteEtag = remoteInfo.etag.trim();
    final lokaleEtag = prefs.getString(_oneDriveBackupEtagKey)?.trim() ?? '';

    if (remoteEtag.isNotEmpty &&
        lokaleEtag.isNotEmpty &&
        remoteEtag == lokaleEtag) {
      return false;
    }

    final resultaat = await _downloadBackupMetTokenZonderVergrendeling(
      token,
      downloadFotos: false,
    );

    return resultaat.startsWith('IMPORT_OK');
  }

  /// Synchroniseert alleen de operationele modules die lokaal of in OneDrive
  /// veranderd zijn. Dit is de standaard sync op Home.
  ///
  /// De bestaande volledige thimaco_backup.json blijft bestaan voor:
  /// - oude clients tijdens de overgang;
  /// - eerste installatie / herstel;
  /// - handmatige volledige upload;
  /// - expliciet afsluiten via Home.
  Future<String> syncModulesVoorHome() {
    return _voerSyncGeserialiseerdUit(() async {
      final token = await OneDriveAuthService().tokenSilent();
      if (token.startsWith('FOUT')) {
        laatsteSyncActie = 'Module-sync overgeslagen: geen silent token';
        return 'SYNC_GEEN_ONEDRIVE_LOGIN';
      }

      final prefs = await SharedPreferences.getInstance();
      var remoteToegepast = false;
      final fouten = <String>[];

      // Overgangsbeveiliging: zolang een oudere iPad/pc nog alleen de volledige
      // backup schrijft, halen we die uitsluitend binnen wanneer de ETag echt
      // veranderd is. Daarna worden de operationele modules weer bijgewerkt.
      try {
        remoteToegepast = await _pasLegacyBackupToeIndienGewijzigd(
          token: token,
          prefs: prefs,
        );
      } catch (e) {
        fouten.add('legacy: $e');
      }

      for (final module in _deltaModules) {
        try {
          final uitkomst = await _syncEenModule(
            token: token,
            prefs: prefs,
            module: module,
          );

          if (!uitkomst.gelukt) {
            fouten.add('$module: ${uitkomst.melding}');
          }

          remoteToegepast =
              remoteToegepast || uitkomst.remoteToegepast;

          // Tussen modules krijgt Flutter steeds een framekans.
          await _geefUiTijd();
        } catch (e) {
          fouten.add('$module: $e');
        }
      }

      if (fouten.isNotEmpty) {
        laatsteSyncActie =
            'Module-sync gedeeltelijk gelukt: ${fouten.join(' | ')}';
        return remoteToegepast
            ? 'IMPORT_OK_MODULES_MET_WAARSCHUWING'
            : 'SYNC_MODULES_MET_WAARSCHUWING';
      }

      laatsteSyncActie = remoteToegepast
          ? 'Module-sync uitgevoerd; remote wijzigingen lokaal toegepast'
          : 'Module-sync uitgevoerd; alleen gewijzigde modules verwerkt';

      return remoteToegepast ? 'IMPORT_OK_MODULES' : 'SYNC_MODULES_OK';
    });
  }

  Future<String> eersteStartSync() async {
    final prefs = await SharedPreferences.getInstance();
    final eersteVolledigeSyncVoltooid =
        prefs.getBool(_eersteVolledigeSyncVoltooidKey) ?? false;

    if (eersteVolledigeSyncVoltooid) {
      return syncModulesVoorHome();
    }

    final eersteVolledigeSyncGestart =
        prefs.getBool(_eersteVolledigeSyncGestartKey) ?? false;
    final lokaal = await lokaleBackupDatum();

    // Migratie voor bestaande installaties, zoals de huidige iPad:
    // wanneer er al een lokale backupdatum bestaat en deze nieuwe
    // initialisatieprocedure nog nooit gestart is, beschouwen we het toestel
    // als bestaand. Zo dwingen we geen volledige cloud-download af op een
    // toestel waarop de gegevens al correct staan.
    if (lokaal != null && !eersteVolledigeSyncGestart) {
      await prefs.setBool(_eersteVolledigeSyncVoltooidKey, true);
      laatsteSyncActie =
          'Bestaand toestel herkend; module-synchronisatie actief';
      return syncModulesVoorHome();
    }

    // Vanaf dit punt is dit een echt nieuw toestel, of een eerdere volledige
    // eerste synchronisatie die nog niet helemaal gelukt is.
    await prefs.setBool(_eersteVolledigeSyncGestartKey, true);

    // Automatisch wordt nooit een Microsoft-aanmeldvenster geopend.
    // Zonder stille token blijft de initialisatie openstaan en proberen we
    // bij een volgende sync opnieuw.
    final token = await OneDriveAuthService().tokenSilent();

    if (token.startsWith('FOUT')) {
      laatsteSyncActie =
          'Eerste volledige synchronisatie wacht op Microsoft-aanmelding';
      return 'SYNC_GEEN_ONEDRIVE_LOGIN';
    }

    final resultaat = await downloadBackupMetToken(token, downloadFotos: true);

    if (resultaat == 'IMPORT_OK') {
      await prefs.setBool(_eersteVolledigeSyncVoltooidKey, true);
      laatsteSyncActie = 'Eerste volledige synchronisatie uitgevoerd';

      // Een nieuw toestel haalt daarna ook meteen de nieuwere modulebestanden
      // binnen. Zo blijft de migratie veilig wanneer andere toestellen al met
      // module-delta-sync werken terwijl de volledige backup iets ouder is.
      await syncModulesVoorHome();
    } else {
      // Bij een tijdelijke fout, bijvoorbeeld tijdens de fotodownload, blijft
      // "gestart" waar en "voltooid" onwaar. Daardoor wordt de volledige
      // initialisatie later opnieuw geprobeerd, ook als de backupdatum tijdens
      // de gegevensdownload al lokaal werd bijgewerkt.
      laatsteSyncActie =
          'Eerste volledige synchronisatie nog niet voltooid: $resultaat';
    }

    return resultaat;
  }

  Future<String> _downloadKlantenFotos(String token) async {
    if (_fotoDownloadBezig) {
      return 'FOTOS_BEZIG';
    }

    _fotoDownloadBezig = true;

    try {
      const manifestUrl =
          'https://graph.microsoft.com/v1.0/me/drive/special/approot:/klanten_fotos_manifest.json:/content';

      final manifestResponse = await http.get(
        Uri.parse(manifestUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (manifestResponse.statusCode != 200) {
        return 'FOTOS_OK_GEEN_MANIFEST';
      }

      final manifest =
          jsonDecode(manifestResponse.body) as Map<String, dynamic>;

      final bestanden = manifest['bestanden'];

      if (bestanden is! List) {
        return 'FOTOS_OK_LEEG_MANIFEST';
      }

      final appMap = await getApplicationDocumentsDirectory();

      final fotosMap = Directory('${appMap.path}/klanten_fotos');

      if (!await fotosMap.exists()) {
        await fotosMap.create(recursive: true);
      }

      var gedownload = 0;
      var overgeslagen = 0;

      for (final item in bestanden) {
        if (item is! Map) {
          continue;
        }

        final pad = item['pad'];

        if (pad is! String || pad.trim().isEmpty) {
          continue;
        }

        final lokaalBestand = File('${fotosMap.path}/$pad');

        final remoteGrootte = _leesManifestGrootte(item['grootte']);

        final remoteGewijzigdOp = _leesManifestDatum(item['gewijzigdOp']);

        final isOngewijzigd = await _isLokaalFotoOngewijzigd(
          bestand: lokaalBestand,
          remoteGrootte: remoteGrootte,
          remoteGewijzigdOp: remoteGewijzigdOp,
        );

        if (isOngewijzigd) {
          overgeslagen++;
          continue;
        }

        final encodedPad = _encodeOneDrivePath('klanten_fotos/$pad');

        final url =
            'https://graph.microsoft.com/v1.0/me/drive/special/approot:/$encodedPad:/content';

        final response = await http.get(
          Uri.parse(url),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode != 200) {
          continue;
        }

        final parent = lokaalBestand.parent;

        if (!await parent.exists()) {
          await parent.create(recursive: true);
        }

        await lokaalBestand.writeAsBytes(response.bodyBytes, flush: true);

        if (remoteGewijzigdOp != null) {
          await lokaalBestand.setLastModified(remoteGewijzigdOp);
        }

        gedownload++;
      }

      return 'FOTOS_OK gedownload:$gedownload overgeslagen:$overgeslagen';
    } catch (e) {
      return 'FOTOS_EXCEPTION: $e';
    } finally {
      _fotoDownloadBezig = false;
    }
  }

  int? _leesManifestGrootte(dynamic waarde) {
    if (waarde is int) {
      return waarde;
    }

    if (waarde is num) {
      return waarde.toInt();
    }

    return int.tryParse(waarde?.toString() ?? '');
  }

  DateTime? _leesManifestDatum(dynamic waarde) {
    if (waarde == null) {
      return null;
    }

    return DateTime.tryParse(waarde.toString());
  }

  Future<bool> _isLokaalFotoOngewijzigd({
    required File bestand,
    required int? remoteGrootte,
    required DateTime? remoteGewijzigdOp,
  }) async {
    if (!await bestand.exists()) {
      return false;
    }

    final stat = await bestand.stat();

    if (remoteGrootte != null && stat.size != remoteGrootte) {
      return false;
    }

    if (remoteGewijzigdOp == null) {
      return true;
    }

    final lokaal = stat.modified.toUtc();
    final remote = remoteGewijzigdOp.toUtc();

    return lokaal.difference(remote).abs() < const Duration(seconds: 3);
  }

  String _encodeOneDrivePath(String pad) {
    return pad.split('/').map(Uri.encodeComponent).join('/');
  }

  Future<String?> lokaleBackupDatum() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_backupDatumKey);
  }

  Future<_OneDriveBackupInfo?> _oneDriveBackupInfoMetToken(
    String token,
  ) async {
    if (token.startsWith('FOUT')) {
      return null;
    }

    const url =
        'https://graph.microsoft.com/v1.0/me/drive/special/approot:/thimaco_backup.json?%24select=eTag,lastModifiedDateTime,size';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      return null;
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      return null;
    }

    final data = Map<String, dynamic>.from(decoded);
    final etag = data['eTag']?.toString().trim() ?? '';
    final gewijzigdOp = DateTime.tryParse(
      data['lastModifiedDateTime']?.toString() ?? '',
    );

    return _OneDriveBackupInfo(
      etag: etag,
      gewijzigdOp: gewijzigdOp,
    );
  }

  Future<void> _bewaarOneDriveEtagNaUpload({
    required SharedPreferences prefs,
    required String token,
    required http.Response response,
  }) async {
    String etag = '';

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        etag = decoded['eTag']?.toString().trim() ?? '';
      }
    } catch (_) {
      // Sommige Graph-antwoorden bevatten geen bruikbare DriveItem-body.
    }

    if (etag.isNotEmpty) {
      await prefs.setString(_oneDriveBackupEtagKey, etag);
      return;
    }

    await _verversOneDriveEtagMetToken(prefs: prefs, token: token);
  }

  Future<void> _verversOneDriveEtagMetToken({
    required SharedPreferences prefs,
    required String token,
  }) async {
    try {
      final info = await _oneDriveBackupInfoMetToken(token);
      final etag = info?.etag.trim() ?? '';

      if (etag.isNotEmpty) {
        await prefs.setString(_oneDriveBackupEtagKey, etag);
      }
    } catch (_) {
      // ETag is een optimalisatie. Een fout mag de echte sync nooit blokkeren.
    }
  }

  Future<String?> oneDriveBackupDatum({bool magLoginVragen = false}) async {
    try {
      // Automatische synchronisatie mag nooit zelf een interactief
      // Microsoft-venster openen. De parameter blijft alleen bestaan voor
      // broncompatibiliteit met oudere aanroepen.
      final token = await OneDriveAuthService().tokenSilent();

      if (token.startsWith('FOUT')) {
        return null;
      }

      const url =
          'https://graph.microsoft.com/v1.0/me/drive/special/approot:/thimaco_backup.json:/content';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body);

      if (data is Map && data['backupDatum'] is String) {
        return data['backupDatum'] as String;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String> syncDebugInfo() async {
    final prefs = await SharedPreferences.getInstance();

    final lokaal = await lokaleBackupDatum();

    final oneDrive = await oneDriveBackupDatum();

    final openstaand = prefs.getBool(_lokaleWijzigingOpenstaandKey) ?? false;
    final lokaleEtag = prefs.getString(_oneDriveBackupEtagKey) ?? '-';
    final eersteVolledigeSyncGestart =
        prefs.getBool(_eersteVolledigeSyncGestartKey) ?? false;
    final eersteVolledigeSyncVoltooid =
        prefs.getBool(_eersteVolledigeSyncVoltooidKey) ?? false;

    return '''
LOKAAL:
$lokaal

ONEDRIVE:
$oneDrive

LOKALE WIJZIGING OPENSTAAND:
$openstaand

LOKALE ONEDRIVE ETAG:
$lokaleEtag

EERSTE VOLLEDIGE SYNC GESTART:
$eersteVolledigeSyncGestart

EERSTE VOLLEDIGE SYNC VOLTOOID:
$eersteVolledigeSyncVoltooid

BACKUP BEZIG:
$_backupBezig

DOWNLOAD BEZIG:
$_downloadBezig

FOTODOWNLOAD BEZIG:
$_fotoDownloadBezig

LAATSTE SYNC ACTIE:
$laatsteSyncActie
''';
  }

  Future<String> slimmeSync({bool magLoginVragen = false}) async {
    // Broncompatibiliteit voor bestaande knoppen/aanroepen.
    // De normale slimme sync is vanaf nu dezelfde local-first module-sync die
    // Home gebruikt. [magLoginVragen] blijft bewust genegeerd: automatische
    // synchronisatie opent nooit zelf een Microsoft-loginvenster.
    return syncModulesVoorHome();
  }

  _SyncStringWaarde _kiesRecenteStringWaarde({
    required String? lokaleWaarde,
    required String? cloudWaarde,
    required String? lokaleGewijzigdOp,
    required String? cloudGewijzigdOp,
    required String fallbackDatum,
  }) {
    final lokaal = _legeStringNaarNull(lokaleWaarde);
    final cloud = _legeStringNaarNull(cloudWaarde);
    final lokaleDatumTekst = lokaleGewijzigdOp?.trim() ?? '';
    final cloudDatumTekst = cloudGewijzigdOp?.trim() ?? '';
    final lokaleDatum = DateTime.tryParse(lokaleDatumTekst);
    final cloudDatum = DateTime.tryParse(cloudDatumTekst);
    final lokaalHeeftRecord = lokaal != null || lokaleDatumTekst.isNotEmpty;
    final cloudHeeftRecord = cloud != null || cloudDatumTekst.isNotEmpty;

    if (!lokaalHeeftRecord && !cloudHeeftRecord) {
      return const _SyncStringWaarde(null, null);
    }

    if (lokaalHeeftRecord && !cloudHeeftRecord) {
      return _SyncStringWaarde(
        lokaal,
        lokaleDatumTekst.isEmpty ? fallbackDatum : lokaleDatumTekst,
      );
    }

    if (cloudHeeftRecord && !lokaalHeeftRecord) {
      return _SyncStringWaarde(
        cloud,
        cloudDatumTekst.isEmpty ? fallbackDatum : cloudDatumTekst,
      );
    }

    if (lokaleDatum != null && cloudDatum != null) {
      if (cloudDatum.isAfter(lokaleDatum)) {
        return _SyncStringWaarde(cloud, cloudDatumTekst);
      }
      return _SyncStringWaarde(lokaal, lokaleDatumTekst);
    }

    if (cloudDatum != null && lokaleDatum == null) {
      return _SyncStringWaarde(cloud, cloudDatumTekst);
    }

    if (lokaleDatum != null && cloudDatum == null) {
      return _SyncStringWaarde(lokaal, lokaleDatumTekst);
    }

    // Legacy records zonder datum: lokaal blijft de veilige voorkeur.
    return _SyncStringWaarde(lokaal, fallbackDatum);
  }

  String? _legeStringNaarNull(String? waarde) {
    final tekst = waarde?.trim() ?? '';

    if (tekst.isEmpty) {
      return null;
    }

    return tekst;
  }

  Future<void> _bewaarOptioneleString({
    required SharedPreferences prefs,
    required String key,
    required String? waarde,
  }) async {
    final tekst = waarde?.trim() ?? '';

    if (tekst.isEmpty) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, tekst);
    }
  }

  Map<String, String> _leesStringMap(dynamic waarde) {
    if (waarde is! Map) {
      return <String, String>{};
    }

    final resultaat = <String, String>{};

    waarde.forEach((key, value) {
      final sleutel = key.toString().trim();
      final tekst = value?.toString() ?? '';

      if (sleutel.isEmpty || tekst.trim().isEmpty) {
        return;
      }

      resultaat[sleutel] = tekst;
    });

    return resultaat;
  }

  Map<String, String> _leesStringPrefsMetPrefix(
    SharedPreferences prefs,
    String prefix,
  ) {
    final resultaat = <String, String>{};

    for (final key in prefs.getKeys()) {
      if (!key.startsWith(prefix)) {
        continue;
      }

      final waarde = prefs.getString(key);

      if (waarde == null || waarde.trim().isEmpty) {
        continue;
      }

      resultaat[key] = waarde;
    }

    return resultaat;
  }

  Map<String, String> _leesDeurpaneelToewijzingDatums(SharedPreferences prefs) {
    final resultaat = <String, String>{};

    for (final key in prefs.getKeys()) {
      if (!key.startsWith(_deurpaneelToewijzingGewijzigdOpPrefix)) {
        continue;
      }

      final opmetingId = key
          .substring(_deurpaneelToewijzingGewijzigdOpPrefix.length)
          .trim();
      final datum = prefs.getString(key)?.trim() ?? '';

      if (opmetingId.isEmpty || datum.isEmpty) {
        continue;
      }

      resultaat['$_deurpaneelToewijzingenPrefix$opmetingId'] = datum;
    }

    return resultaat;
  }

  Future<void> _schrijfDeurpaneelToewijzingDatums(
    SharedPreferences prefs,
    Map<String, String> datums,
  ) async {
    final gewenstePrefs = <String, String>{};

    for (final entry in datums.entries) {
      if (!entry.key.startsWith(_deurpaneelToewijzingenPrefix)) {
        continue;
      }

      final opmetingId = entry.key
          .substring(_deurpaneelToewijzingenPrefix.length)
          .trim();
      final datum = entry.value.trim();

      if (opmetingId.isEmpty || datum.isEmpty) {
        continue;
      }

      gewenstePrefs['$_deurpaneelToewijzingGewijzigdOpPrefix$opmetingId'] =
          datum;
    }

    final bestaandeKeys = prefs
        .getKeys()
        .where((key) => key.startsWith(_deurpaneelToewijzingGewijzigdOpPrefix))
        .toList(growable: false);

    for (final key in bestaandeKeys) {
      if (!gewenstePrefs.containsKey(key)) {
        await prefs.remove(key);
      }
    }

    for (final entry in gewenstePrefs.entries) {
      await prefs.setString(entry.key, entry.value);
    }
  }

  Future<void> _schrijfStringPrefsMetPrefix(
    SharedPreferences prefs,
    String prefix,
    Map<String, String> waarden,
  ) async {
    final bestaandeKeys = prefs
        .getKeys()
        .where((key) {
          return key.startsWith(prefix);
        })
        .toList(growable: false);

    for (final key in bestaandeKeys) {
      if (!waarden.containsKey(key)) {
        await prefs.remove(key);
      }
    }

    for (final entry in waarden.entries) {
      if (!entry.key.startsWith(prefix)) {
        continue;
      }

      if (entry.value.trim().isEmpty) {
        await prefs.remove(entry.key);
      } else {
        await prefs.setString(entry.key, entry.value);
      }
    }
  }
}

class _OneDriveModuleInfo {
  const _OneDriveModuleInfo({
    required this.gevonden,
    required this.fout,
    required this.etag,
    this.foutmelding = '',
  });

  final bool gevonden;
  final bool fout;
  final String etag;
  final String foutmelding;
}

class _ModuleSyncUitkomst {
  const _ModuleSyncUitkomst({
    required this.gelukt,
    required this.remoteToegepast,
    required this.melding,
  });

  final bool gelukt;
  final bool remoteToegepast;
  final String melding;
}

class _SyncStringWaarde {
  const _SyncStringWaarde(this.waarde, this.gewijzigdOp);

  final String? waarde;
  final String? gewijzigdOp;
}

class _OneDriveBackupInfo {
  const _OneDriveBackupInfo({required this.etag, required this.gewijzigdOp});

  final String etag;
  final DateTime? gewijzigdOp;
}
