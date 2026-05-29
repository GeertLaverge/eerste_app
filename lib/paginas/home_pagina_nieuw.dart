import 'package:flutter/material.dart';

import '../helpers/homepagina/home_boven_balk.dart';
import '../helpers/homepagina/home_dashboard.dart';
import '../helpers/homepagina/home_zij_menu.dart';
import '../helpers/homepagina/home_planning_helper.dart';
import '../helpers/sync/onedrive_sync_service.dart';
import '../helpers/agenda/agenda_melding_service.dart';

class HomePaginaNieuw extends StatefulWidget {
  const HomePaginaNieuw({
    super.key,
  });

  @override
  State<HomePaginaNieuw> createState() => _HomePaginaNieuwState();
}

class _HomePaginaNieuwState extends State<HomePaginaNieuw>
    with WidgetsBindingObserver {
  static const achtergrond = Color(0xFFF7F8FA);

  String syncMelding = 'Nog geen OneDrive test uitgevoerd';
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      OneDriveSyncService().slimmeSync();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> testOneDriveUpload() async {
    setState(() {
      syncMelding = 'OneDrive test gestart...';
    });

    final melding = await OneDriveSyncService().uploadBackup();

    final datum = await OneDriveSyncService().lokaleBackupDatum();

    print('LOKALE BACKUP DATUM: $datum');
    final oneDriveDatum = await OneDriveSyncService().oneDriveBackupDatum();

    print('ONEDRIVE BACKUP DATUM: $oneDriveDatum');

    if (!mounted) return;

    setState(() {
      if (melding == 'BACKUP_OK') {
        syncMelding = 'LOKAAL:\n$datum\n\nONEDRIVE:\n$oneDriveDatum';
      } else {
        syncMelding = melding;
      }
    });
  }

  Future<void> laadOneDriveBackup() async {
    setState(() {
      syncMelding = 'OneDrive backup laden...';
    });

    final melding = await OneDriveSyncService().downloadBackup();

    if (!mounted) return;

    setState(() {
      if (melding == 'IMPORT_OK') {
        syncMelding = '✅ OneDrive backup geladen';
      } else {
        syncMelding = melding;
      }
    });
  }

  Future<void> slimmeSyncTest() async {
    setState(() {
      syncMelding = 'Slimme sync gestart...';
    });

    final melding = await OneDriveSyncService().slimmeSync();

    if (!mounted) return;

    setState(() {
      syncMelding = melding;
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
                children: [
                  ElevatedButton(
                    onPressed: testOneDriveUpload,
                    child: const Text(
                      'OneDrive upload testen',
                    ),
                  ),
                  const SizedBox(height: 6),
                  ElevatedButton(
                    onPressed: laadOneDriveBackup,
                    child: const Text(
                      'OneDrive backup laden',
                    ),
                  ),
                  const SizedBox(height: 6),
                  ElevatedButton(
                    onPressed: () async {
                      await AgendaMeldingService.toonTestMelding();
                    },
                    child: const Text(
                      'Test melding',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: slimmeSyncTest,
                    child: const Text(
                      'Slimme sync testen',
                    ),
                  ),
                  Text(
                    syncMelding,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
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
                        FutureBuilder<List<List<dynamic>>>(
                          future: Future.wait([
                            planningVandaag,
                            dagTakenVandaag,
                          ]),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox();
                            }

                            return HomeDashboard(
                              planningVandaag: snapshot.data![0],
                              dagTakenVandaag: snapshot.data![1],
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
