// THIMACO-CONTROLE: HOME-MELDT-ACTIEVE-ROUTE-AAN-SYNC-20260914
// THIMACO-CONTROLE: HOME-WINDOWS-DESKTOP-DASHBOARD-FASE-1-20260914
// THIMACO-CONTROLE: HOME-WITTE-BOVENBALK-EN-TEKSTMENU-20260914
// THIMACO-CONTROLE: HOME-CENTRALE-ACHTERGROND-SYNC-20260914
// THIMACO-CONTROLE: HOME-NIEUW-TOESTEL-VOLLEDIGE-EERSTE-SYNC-20260913
// THIMACO-CONTROLE: FINANCIELE-KLUIS-HOME-KOPPELING-20260806
// THIMACO-CONTROLE: HOME-SNEL-AFSLUITEN-ZONDER-FOTO-BLOKKERING-20260805
// THIMACO-CONTROLE: HOME-ACTUELE-PAGINA-MET-IPHONE-MENU-20260805
// THIMACO-CONTROLE: HOME-OPSLAAN-EN-SLUITEN-ZONDER-MICROSOFT-AFMELDING-20260805
// THIMACO-CONTROLE: HOME-CENTRAAL-DOWNLOADSIGNAAL-FASE7-20260805
// THIMACO-CONTROLE: HOME-PERIODIEKE-SYNC-FASE6-20260805

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../helpers/homepagina/home_boven_balk.dart';
import '../helpers/homepagina/home_dashboard.dart';
import '../helpers/homepagina/home_desktop_dashboard.dart';
import '../helpers/homepagina/home_planning_helper.dart';
import '../helpers/homepagina/home_zij_menu.dart';
import '../helpers/financien/beveiliging/financiele_kluis_sessie_controller.dart';
import '../helpers/financien/paginas/financiele_kluis_pagina.dart';
import '../helpers/sync/app_sync_controller.dart';
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
  late Future<List<List<dynamic>>> _dashboardGegevens;

  bool _opslaanEnSluitenBezig = false;
  bool _programmaAfgesloten = false;
  int _laatsteVerwerkteDownloadVersie = 0;
  bool? _laatsteHomeRouteActief;

  final FinancieleKluisSessieController _financieleKluisController =
      FinancieleKluisSessieController.instance;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _financieleKluisController.addListener(_verwerkFinancieleKluisWijziging);

    _laatsteVerwerkteDownloadVersie = SyncNavigatieHelper.downloadVersie.value;

    SyncNavigatieHelper.downloadVersie.addListener(_verwerkAchtergrondDownload);

    _dashboardGegevens = _laadDashboardGegevens();

    // De synchronisatie leeft app-breed en onafhankelijk van Home.
    // Deze start is idempotent: terugnavigeren naar Home start geen nieuwe sync.
    AppSyncController.instance.start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final homeActief = ModalRoute.of(context)?.isCurrent ?? true;
    if (_laatsteHomeRouteActief == homeActief) {
      return;
    }

    _laatsteHomeRouteActief = homeActief;
    AppSyncController.instance.zetHomeActief(homeActief);
  }

  @override
  void dispose() {
    SyncNavigatieHelper.downloadVersie.removeListener(
      _verwerkAchtergrondDownload,
    );

    WidgetsBinding.instance.removeObserver(this);
    _financieleKluisController.removeListener(_verwerkFinancieleKluisWijziging);
    _financieleKluisController.vergrendel();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_programmaAfgesloten) {
      return;
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      _financieleKluisController.vergrendel();
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
            'Alle gegevens worden eerst snel naar OneDrive bewaard. Foto’s '
            'blokkeren het afsluiten niet en worden later verder verwerkt. '
            'Het Microsoft-account blijft aangemeld.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuleren'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _groen,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.power_settings_new_rounded),
              label: const Text('Opslaan en sluiten'),
            ),
          ],
        );
      },
    );

    if (bevestigd != true || !mounted) {
      return;
    }

    AppSyncController.instance.pauzeerVoorAfsluiten();

    setState(() {
      _opslaanEnSluitenBezig = true;
    });

    try {
      final uploadResultaat = await OneDriveSyncService().uploadBackup(
        uploadFotos: false,
      );

      if (!mounted) {
        return;
      }

      if (!uploadResultaat.startsWith('BACKUP_OK')) {
        await _toonOpslaanEnSluitenFout(
          titel: 'Sluiten gestopt',
          melding:
              'De gegevens konden niet naar OneDrive worden bewaard. '
              'Het programma blijft open en het Microsoft-account blijft aangemeld.\n\n'
              '$uploadResultaat',
        );
        AppSyncController.instance.hervatNaMisluktAfsluiten();
        return;
      }

      if (!mounted) {
        return;
      }

      if (!kIsWeb && defaultTargetPlatform != TargetPlatform.iOS) {
        await SystemNavigator.pop();
        return;
      }

      setState(() {
        _programmaAfgesloten = true;
      });
    } finally {
      if (mounted && !_programmaAfgesloten) {
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

  void _verwerkFinancieleKluisWijziging() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  Future<void> _openFinancieleKluis() async {
    if (!_financieleKluisController.magMenuTonen || !mounted) {
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const FinancieleKluisPagina(),
      ),
    );

    _financieleKluisController.vergrendel();
  }

  @override
  Widget build(BuildContext context) {
    if (_programmaAfgesloten) {
      return const AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: _groen,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: _groen,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: Colors.white,
                      size: 58,
                    ),
                    SizedBox(height: 18),
                    Text(
                      'Veilig afgesloten',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'De gegevens zijn naar OneDrive bewaard. '
                      'Het Microsoft-account blijft aangemeld.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final compactZijMenu = MediaQuery.of(context).size.width < 700;
    final toonDesktopDashboard =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: achtergrond,
        body: SafeArea(
          child: ColoredBox(
            color: achtergrond,
            child: Column(
              children: <Widget>[
                const HomeBovenBalk(),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      HomeZijMenu(
                        compact: compactZijMenu,
                        onAfsluiten: _opslaanEnSluiten,
                        afsluitenBezig: _opslaanEnSluitenBezig,
                        toonFinancieleKluis:
                            _financieleKluisController.magMenuTonen,
                        onFinancieleKluis: _openFinancieleKluis,
                      ),
                      Expanded(
                        child: FutureBuilder<List<List<dynamic>>>(
                          future: _dashboardGegevens,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Container(
                                  margin: const EdgeInsets.all(12),
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
                                ),
                              );
                            }

                            final gegevens = snapshot.data;

                            if (gegevens == null || gegevens.length < 4) {
                              return const SizedBox.shrink();
                            }

                            if (toonDesktopDashboard) {
                              return Padding(
                                padding: const EdgeInsets.all(12),
                                child: HomeDesktopDashboard(
                                  planningVandaag: gegevens[0],
                                  dagTakenVandaag: gegevens[1],
                                  klantTakenVandaag: gegevens[2],
                                  kraanReservatiesVandaag: gegevens[3],
                                ),
                              );
                            }

                            return ListView(
                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                              children: <Widget>[
                                HomeDashboard(
                                  planningVandaag: gegevens[0],
                                  dagTakenVandaag: gegevens[1],
                                  klantTakenVandaag: gegevens[2],
                                  kraanReservatiesVandaag: gegevens[3],
                                ),
                              ],
                            );
                          },
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
