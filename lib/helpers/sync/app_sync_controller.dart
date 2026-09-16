// THIMACO-CONTROLE: LOCAL-FIRST-HOME-ALS-SYNC-HUB-20260914
// THIMACO-CONTROLE: CENTRALE-ACHTERGROND-SYNC-CONTROLLER-20260914

import 'dart:async';

import 'package:flutter/widgets.dart';

import 'onedrive_sync_service.dart';
import 'sync_navigatie_helper.dart';

/// Centrale synchronisatiecontroller voor de volledige app.
///
/// Nieuwe werkwijze:
/// - tijdens actief werken: alleen lokaal opslaan;
/// - bij eerste app-start op Home: veilige eerste-toestel/legacy-controle;
/// - wanneer Home zichtbaar wordt: module-sync na een korte rust;
/// - geen 3-minuten-sync meer midden in typen, aanvinken of opmeten;
/// - afsluiten blijft via Home een expliciete volledige veiligheidsbackup doen.
class AppSyncController with WidgetsBindingObserver {
  AppSyncController._();

  static final AppSyncController instance = AppSyncController._();

  static const Duration _eersteStartVertraging = Duration(seconds: 2);
  static const Duration _homeSyncVertraging = Duration(milliseconds: 1200);

  Timer? _uitgesteldeSyncTimer;

  bool _gestart = false;
  bool _gepauzeerd = false;
  bool _homeActief = false;
  bool _syncBezig = false;
  bool _syncOpnieuwNodig = false;
  bool _eersteSyncNogNietGestart = true;

  String laatsteResultaat = 'Nog geen centrale sync uitgevoerd';
  DateTime? laatsteSyncStart;
  DateTime? laatsteSyncEinde;

  bool get syncBezig => _syncBezig;

  /// Start de controller exact één keer voor de volledige app-sessie.
  /// Home meldt apart via [zetHomeActief] wanneer de route echt zichtbaar is.
  void start() {
    if (_gestart) {
      if (_homeActief) {
        vraagSyncAan();
      }
      return;
    }

    _gestart = true;
    _gepauzeerd = false;
    WidgetsBinding.instance.addObserver(this);

    if (_homeActief) {
      _planSync(_eersteStartVertraging);
    }
  }

  /// Home roept dit aan wanneer zijn ModalRoute current/niet-current wordt.
  /// Zodra een werkpagina boven Home ligt, annuleren we iedere nog niet gestarte
  /// sync. Zo begint OneDrive nooit midden in actief invoerwerk.
  void zetHomeActief(bool actief) {
    if (_homeActief == actief) {
      return;
    }

    _homeActief = actief;

    if (!actief) {
      _uitgesteldeSyncTimer?.cancel();
      _uitgesteldeSyncTimer = null;
      return;
    }

    if (!_gestart || _gepauzeerd) {
      return;
    }

    _planSync(
      _eersteSyncNogNietGestart
          ? _eersteStartVertraging
          : _homeSyncVertraging,
    );
  }

  /// Tijdens expliciet afsluiten mag geen tweede automatische sync starten.
  void pauzeerVoorAfsluiten() {
    _gepauzeerd = true;
    _uitgesteldeSyncTimer?.cancel();
    _uitgesteldeSyncTimer = null;
  }

  /// Als afsluiten mislukt, wordt de Home-sync opnieuw beschikbaar.
  void hervatNaMisluktAfsluiten() {
    if (!_gestart) {
      start();
      return;
    }

    _gepauzeerd = false;
    if (_homeActief) {
      vraagSyncAan();
    }
  }

  /// Plant een sync zonder de zichtbare Home te blokkeren.
  void vraagSyncAan({Duration vertraging = _homeSyncVertraging}) {
    if (!_gestart || _gepauzeerd || !_homeActief) {
      return;
    }

    if (_syncBezig) {
      _syncOpnieuwNodig = true;
      return;
    }

    _planSync(vertraging);
  }

  /// Bewust geen sync meer op pause/inactive/resume.
  /// Focus- en vensterwissels mogen nooit zware sync starten op een werkpagina.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  void _planSync(Duration vertraging) {
    if (!_homeActief || _gepauzeerd) {
      return;
    }

    _uitgesteldeSyncTimer?.cancel();

    _uitgesteldeSyncTimer = Timer(vertraging, () {
      _uitgesteldeSyncTimer = null;

      if (_homeActief && !_gepauzeerd) {
        unawaited(_voerSyncUit());
      }
    });
  }

  Future<void> _voerSyncUit() async {
    if (_gepauzeerd || !_homeActief) {
      return;
    }

    if (_syncBezig) {
      _syncOpnieuwNodig = true;
      return;
    }

    _syncBezig = true;
    _eersteSyncNogNietGestart = false;
    laatsteSyncStart = DateTime.now();

    try {
      final resultaat = await OneDriveSyncService().eersteStartSync();
      laatsteResultaat = resultaat;

      if (_isDownloadResultaat(resultaat)) {
        SyncNavigatieHelper.meldDownloadVoltooid();
      }
    } catch (e) {
      laatsteResultaat = 'SYNC_CONTROLLER_FOUT: $e';
    } finally {
      laatsteSyncEinde = DateTime.now();
      _syncBezig = false;

      if (_syncOpnieuwNodig && !_gepauzeerd && _homeActief) {
        _syncOpnieuwNodig = false;
        _planSync(_homeSyncVertraging);
      } else if (!_homeActief) {
        _syncOpnieuwNodig = false;
      }
    }
  }

  bool _isDownloadResultaat(String resultaat) {
    return resultaat.startsWith('IMPORT_OK');
  }
}
