import 'package:flutter/material.dart';

import '../helpers/homepagina/home_boven_balk.dart';
import '../helpers/homepagina/home_dashboard.dart';
import '../helpers/homepagina/home_zij_menu.dart';
import '../helpers/homepagina/home_planning_helper.dart';
import '../helpers/sync/onedrive_sync_service.dart';

class HomePaginaNieuw extends StatelessWidget {
  const HomePaginaNieuw({
    super.key,
  });

  static const achtergrond = Color(0xFFF7F8FA);

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
              child: ElevatedButton(
                onPressed: () async {
                  final melding =
                      await OneDriveSyncService().uploadTestbestand();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 8),
                        content: Text(melding),
                      ),
                    );
                  }
                },
                child: const Text(
                  'OneDrive upload testen',
                ),
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
