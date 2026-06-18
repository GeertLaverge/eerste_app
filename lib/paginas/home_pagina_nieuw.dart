import 'dart:async';
import 'package:flutter/material.dart';

import '../helpers/homepagina/home_boven_balk.dart';
import '../helpers/homepagina/home_dashboard.dart';
import '../helpers/homepagina/home_zij_menu.dart';
import '../helpers/homepagina/home_planning_helper.dart';
import '../helpers/sync/onedrive_sync_service.dart';

class HomePaginaNieuw extends StatefulWidget {
  const HomePaginaNieuw({super.key});

  @override
  State<HomePaginaNieuw> createState() => _HomePaginaNieuwState();
}

class _HomePaginaNieuwState extends State<HomePaginaNieuw>
    with WidgetsBindingObserver {
  Timer? _syncTimer;
  static const achtergrond = Color(0xFFF7F8FA);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final resultaat = await OneDriveSyncService().eersteStartSync();

      debugPrint('EERSTE START SYNC: $resultaat');

      if (!mounted) return;

      setState(() {});
    });

    _syncTimer = Timer.periodic(const Duration(minutes: 3), (_) async {
      await OneDriveSyncService().slimmeSync();

      if (!mounted) return;

      setState(() {});
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
            const Padding(
              padding: EdgeInsets.all(8),
              child: Column(children: []),
            ),
            Expanded(
              child: Row(
                children: [
                  HomeZijMenu(compact: MediaQuery.of(context).size.width < 700),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
                      children: [
                        FutureBuilder<List<List<dynamic>>>(
                          future: Future.wait([
                            planningVandaag,
                            dagTakenVandaag,
                            HomePlanningHelper.klantTakenVandaag(),
                            HomePlanningHelper.kraanReservatiesVandaag(),
                          ]),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox();
                            }

                            return HomeDashboard(
                              planningVandaag: snapshot.data![0],
                              dagTakenVandaag: snapshot.data![1],
                              klantTakenVandaag: snapshot.data![2],
                              kraanReservatiesVandaag: snapshot.data![3],
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
