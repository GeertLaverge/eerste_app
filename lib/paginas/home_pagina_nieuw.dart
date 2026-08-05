// THIMACO-CONTROLE: HOME-OPSLAAN-EN-SLUITEN-ZONDER-MICROSOFT-AFMELDING-20260805
// THIMACO-CONTROLE: HOME-GROENE-STATUSBALK-20260805
// THIMACO-CONTROLE: HOME-AFMELDEN-MET-VEILIGE-UPLOAD-20260805
// THIMACO-CONTROLE: HOME-CENTRAAL-DOWNLOADSIGNAAL-FASE7-20260805
// THIMACO-CONTROLE: HOME-PERIODIEKE-SYNC-FASE6-20260805

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../helpers/homepagina/home_boven_balk.dart';
import '../helpers/homepagina/home_dashboard.dart';
import '../helpers/homepagina/home_planning_helper.dart';
import '../helpers/homepagina/home_zij_menu.dart';
import '../helpers/sync/onedrive_sync_service.dart';
import '../helpers/sync/sync_navigatie_helper.dart';

class HomePaginaNieuw extends StatefulWidget {
  const HomePaginaNieuw({super.key});

  @override
  State<HomePaginaNieuw> createState() {
    return _HomePaginaNieuwState();
  }
}

class _HomePaginaNieuwState extends State<HomePaginaNieuw>
    with WidgetsBindingObserver {
  static const Color achtergrond = Color(0xFFF7F8FA);
  static const Color _groen = Color(0xFF0B7A3B);
  static const Duration _syncInterval = Duration(minutes: 3);

  late Future<List<List<dynamic>>> _dashboardGegevens;

  Timer? _syncTimer;
  bool _syncBezig = false;
  bool _opslaanEnSluitenBezig = false;
  int _laatsteVerwerkteDownloadVersie = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _laatsteVerwerkteDownloadVersie = SyncNavigatieHelper.downloadVersie.value;

    SyncNavigatieHelper.downloadVersie.addListener(_verwerkAchtergrondDownload);

    _dashboardGegevens = _laadDashboardGegevens();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _voerAutomatischeSyncUit();
    });

    _syncTimer = Timer.periodic(_syncInterval, (_) {
      _voerAutomatischeSyncUit();
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();

    SyncNavigatieHelper.downloadVersie.removeListener(
      _verwerkAchtergrondDownload,
    );

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _voerAutomatischeSyncUit();
      return;
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      OneDriveSyncService().uploadBackupOpAchtergrond();
    }
  }

  Future<List<List<dynamic>>> _laadDashboardGegevens() {
    final planningVandaag = HomePlanningHelper.planningVandaag();

    final dagTakenVandaag = HomePlanningHelper.dagTakenVandaag();

    final klantTakenVandaag = HomePlanningHelper.klantTakenVandaag();

    final kraanReservatiesVandaag =
        HomePlanningHelper.kraanReservatiesVandaag();

    return Future.wait<List<dynamic>>([
      planningVandaag,
      dagTakenVandaag,
      klantTakenVandaag,
      kraanReservatiesVandaag,
    ]);
  }

  Future<void> _voerAutomatischeSyncUit() async {
    if (_syncBezig) {
      return;
    }

    _syncBezig = true;

    try {
      final resultaat = await OneDriveSyncService().slimmeSync();

      if (!mounted) {
        return;
      }

      if (_isDownloadResultaat(resultaat)) {
        SyncNavigatieHelper.meldDownloadVoltooid();
      }
    } finally {
      _syncBezig = false;
    }
  }

  bool _isDownloadResultaat(String resultaat) {
    return resultaat.startsWith('IMPORT_OK');
  }

  void _verwerkAchtergrondDownload() {
    final nieuweVersie = SyncNavigatieHelper.downloadVersie.value;

    if (nieuweVersie <= _laatsteVerwerkteDownloadVersie) {
      return;
    }

    _laatsteVerwerkteDownloadVersie = nieuweVersie;

    _vernieuwDashboard();
  }

  void _vernieuwDashboard() {
    if (!mounted) {
      return;
    }

    setState(() {
      _dashboardGegevens = _laadDashboardGegevens();
    });
  }

  Future<void> _opslaanEnSluiten() async {
    if (_opslaanEnSluitenBezig) {
      return;
    }

    final bevestigd = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Opslaan en sluiten?',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text(
            'Alle gegevens en klantenfotoâ€™s worden eerst volledig naar '
            'OneDrive bewaard. Het Microsoft-account blijft aangemeld.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuleren'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0B7A3B),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Opslaan en sluiten'),
            ),
          ],
        );
      },
    );

    if (bevestigd != true || !mounted) {
      return;
    }

    _syncTimer?.cancel();

    setState(() {
      _opslaanEnSluitenBezig = true;
    });

    try {
      final uploadResultaat = await OneDriveSyncService().uploadBackup(
        uploadFotos: true,
      );

      if (!mounted) {
        return;
      }

      if (!uploadResultaat.startsWith('BACKUP_OK')) {
        await _toonOpslaanEnSluitenFout(
          titel: 'Sluiten gestopt',
          melding:
              'De gegevens konden niet volledig naar OneDrive worden bewaard. '
              'Het programma blijft open en het Microsoft-account blijft aangemeld.\n\n$uploadResultaat',
        );
        _startSyncTimerOpnieuw();
        return;
      }

      if (!mounted) {
        return;
      }

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Veilig opgeslagen',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            content: const Text(
              'Alle gegevens zijn veilig naar OneDrive bewaard. Het Microsoft-account '
              'blijft aangemeld. Sluit op Chrome het tabblad. Op iPhone kunt u '
              'de app na OK veilig sluiten.',
            ),
            actions: <Widget>[
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0B7A3B),
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      if (!kIsWeb && defaultTargetPlatform != TargetPlatform.iOS) {
        await SystemNavigator.pop();
      }
    } finally {
      if (mounted) {
        setState(() {
          _opslaanEnSluitenBezig = false;
        });
      }
    }
  }

  Future<void> _toonOpslaanEnSluitenFout({
    required String titel,
    required String melding,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            titel,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(melding),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Sluiten'),
            ),
          ],
        );
      },
    );
  }

  void _startSyncTimerOpnieuw() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_syncInterval, (_) {
      _voerAutomatischeSyncUit();
    });
  }

  @override
  Widget build(BuildContext context) {
    final compactZijMenu = MediaQuery.of(context).size.width < 700;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _groen,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _groen,
        body: SafeArea(
          child: ColoredBox(
            color: achtergrond,
            child: Column(
              children: <Widget>[
                const HomeBovenBalk(),
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: SizedBox.shrink(),
                ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      HomeZijMenu(
                        compact: compactZijMenu,
                        onOpslaanEnSluiten: _opslaanEnSluiten,
                        opslaanEnSluitenBezig: _opslaanEnSluitenBezig,
                      ),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                          children: <Widget>[
                            FutureBuilder<List<List<dynamic>>>(
                              future: _dashboardGegevens,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SizedBox(
                                    height: 80,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                }

                                if (snapshot.hasError) {
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    child: const Text(
                                      'De gegevens op Home konden niet geladen worden.',
                                      style: TextStyle(
                                        color: Color(0xFF6B7280),
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                }

                                final gegevens = snapshot.data;

                                if (gegevens == null || gegevens.length < 4) {
                                  return const SizedBox.shrink();
                                }

                                return HomeDashboard(
                                  planningVandaag: gegevens[0],
                                  dagTakenVandaag: gegevens[1],
                                  klantTakenVandaag: gegevens[2],
                                  kraanReservatiesVandaag: gegevens[3],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

