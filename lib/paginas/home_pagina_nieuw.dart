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

class _HomePaginaNieuwState extends State<HomePaginaNieuw> {
  static const achtergrond = Color(0xFFF7F8FA);

  String syncMelding = 'Nog geen OneDrive test uitgevoerd';
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      testOneDriveUpload();
    });
  }

  Future<void> testOneDriveUpload() async {
    setState(() {
      syncMelding = 'OneDrive test gestart...';
    });

    final melding = await OneDriveSyncService().uploadTestbestand();

    if (!mounted) return;

    setState(() {
      if (melding.contains('STATUS 201') || melding.contains('"id"')) {
        syncMelding = '✅ OneDrive upload gelukt';
      } else {
        syncMelding = melding;
      }
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
