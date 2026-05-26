import 'package:flutter/material.dart';

import '../helpers/homepagina/home_boven_balk.dart';
import '../helpers/homepagina/home_dashboard.dart';
import '../helpers/homepagina/home_zij_menu.dart';
import '../helpers/homepagina/home_planning_helper.dart';
import '../helpers/sync/onedrive_auth_service.dart';

class HomePaginaNieuw extends StatelessWidget {
  const HomePaginaNieuw({
    super.key,
  });

  static const achtergrond = Color(
    0xFFF7F8FA,
  );

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
                  final token = await OneDriveAuthService().login();

                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      SnackBar(
                        content: Text(
                          token != null
                              ? 'OneDrive login gelukt'
                              : 'Login mislukt',
                        ),
                      ),
                    );
                  }
                },
                child: const Text(
                  'OneDrive login testen',
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  HomeZijMenu(
                    compact: MediaQuery.of(
                          context,
                        ).size.width <
                        700,
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        6,
                        6,
                        6,
                        6,
                      ),
                      children: [
                        FutureBuilder<List<List<dynamic>>>(
                          future: Future.wait([
                            planningVandaag,
                            dagTakenVandaag,
                          ]),
                          builder: (
                            context,
                            snapshot,
                          ) {
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
