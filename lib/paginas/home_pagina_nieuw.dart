import 'dart:async';
import 'package:flutter/material.dart';

import '../helpers/homepagina/home_boven_balk.dart';
import '../helpers/homepagina/home_dashboard.dart';
import '../helpers/homepagina/home_zij_menu.dart';
import '../helpers/homepagina/home_planning_helper.dart';
import '../helpers/sync/onedrive_sync_service.dart';

class HomePaginaNieuw extends StatefulWidget {
  const HomePaginaNieuw({
    super.key,
  });

  @override
  State<HomePaginaNieuw> createState() => _HomePaginaNieuwState();
}

class _HomePaginaNieuwState extends State<HomePaginaNieuw>
    with WidgetsBindingObserver {
  Timer? _syncTimer;
  static const achtergrond = Color(0xFFF7F8FA);

  String syncMelding = 'OneDrive sync wordt gecontroleerd...';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final melding = await OneDriveSyncService().slimmeSync();
      final debug = await OneDriveSyncService().syncDebugInfo();

      if (!mounted) return;

      setState(() {
        syncMelding = '$melding\n\n$debug';
      });
    });

    _syncTimer = Timer.periodic(
      const Duration(minutes: 3),
      (_) async {
        final melding = await OneDriveSyncService().slimmeSync();
        final debug = await OneDriveSyncService().syncDebugInfo();

        if (!mounted) return;

        setState(() {
          syncMelding = '$melding\n\n$debug';
        });
      },
    );
  }

  @override
  void dispose() {
    _syncTimer?.cancel();

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> testOneDriveUpload() async {
    setState(() {
      syncMelding = 'OneDrive test gestart...';
    });

    final melding = await OneDriveSyncService().uploadBackup();
    final debug = await OneDriveSyncService().syncDebugInfo();

    if (!mounted) return;

    setState(() {
      syncMelding = '$melding\n\n$debug';
    });
  }

  Future<void> laadOneDriveBackup() async {
    setState(() {
      syncMelding = 'OneDrive backup laden...';
    });

    final melding = await OneDriveSyncService().downloadBackup();
    final debug = await OneDriveSyncService().syncDebugInfo();

    if (!mounted) return;

    setState(() {
      syncMelding = '$melding\n\n$debug';
    });
  }

  Future<void> slimmeSyncTest() async {
    setState(() {
      syncMelding = 'Slimme sync gestart...';
    });

    final melding = await OneDriveSyncService().slimmeSync();
    final debug = await OneDriveSyncService().syncDebugInfo();

    if (!mounted) return;

    setState(() {
      syncMelding = '$melding\n\n$debug';
    });
  }

  @override
  Widget build(BuildContext context) {
    final planningVandaag = HomePlanningHelper.planningVandaag();
    final dagTakenVandaag = HomePlanningHelper.dagTakenVandaag();

    return Scaffold(
      backgroundColor: achtergrond,
      body: SafeArea(
        child: Column(
          children: [
            const HomeBovenBalk(),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  HomeZijMenu(
                    compact: MediaQuery.of(context).size.width < 700,
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Text(
                            syncMelding,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        FutureBuilder<List<List<dynamic>>>(
                          future: Future.wait([
                            planningVandaag,
                            dagTakenVandaag,
                            HomePlanningHelper.klantTakenVandaag(),
                          ]),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox();
                            }

                            return HomeDashboard(
                              planningVandaag: snapshot.data![0],
                              dagTakenVandaag: snapshot.data![1],
                              klantTakenVandaag: snapshot.data![2],
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
    );
  }
}
