import 'package:flutter/material.dart';

import '../helpers/homepagina/home_boven_balk.dart';
import '../helpers/homepagina/home_dashboard.dart';
import '../helpers/homepagina/home_planning_helper.dart';
import '../helpers/homepagina/home_zij_menu.dart';
import '../helpers/sync/sync_navigatie_helper.dart';

class HomePaginaNieuw extends StatefulWidget {
  const HomePaginaNieuw({super.key});

  @override
  State<HomePaginaNieuw> createState() {
    return _HomePaginaNieuwState();
  }
}

class _HomePaginaNieuwState extends State<HomePaginaNieuw> {
  static const Color achtergrond = Color(0xFFF7F8FA);

  late Future<List<List<dynamic>>> _dashboardGegevens;

  int _laatsteVerwerkteDownloadVersie = 0;

  @override
  void initState() {
    super.initState();

    _laatsteVerwerkteDownloadVersie = SyncNavigatieHelper.downloadVersie.value;

    SyncNavigatieHelper.downloadVersie.addListener(_verwerkAchtergrondDownload);

    _dashboardGegevens = _laadDashboardGegevens();
  }

  @override
  void dispose() {
    SyncNavigatieHelper.downloadVersie.removeListener(
      _verwerkAchtergrondDownload,
    );

    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final compactZijMenu = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: achtergrond,
      body: SafeArea(
        child: Column(
          children: [
            const HomeBovenBalk(),
            const Padding(padding: EdgeInsets.all(8), child: SizedBox.shrink()),
            Expanded(
              child: Row(
                children: [
                  HomeZijMenu(compact: compactZijMenu),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                      children: [
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
    );
  }
}
