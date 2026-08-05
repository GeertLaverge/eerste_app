// THIMACO-CONTROLE: MAGAZIJN-CENTRAAL-DOWNLOADSIGNAAL-FASE7-20260805
// THIMACO-CONTROLE: MAGAZIJN-PERIODIEKE-SYNC-FASE6-20260805

import 'dart:async';

import 'package:flutter/material.dart';

import '../../helpers/magazijn/magazijn_controller.dart';
import '../../helpers/sync/onedrive_sync_service.dart';
import '../../helpers/sync/sync_navigatie_helper.dart';
import 'magazijn_beheer_pagina.dart';
import 'magazijn_bestellijst_pagina.dart';
import 'magazijn_scan_pagina.dart';

class MagazijnPagina extends StatefulWidget {
  const MagazijnPagina({super.key});

  @override
  State<MagazijnPagina> createState() => _MagazijnPaginaState();
}

class _MagazijnPaginaState extends State<MagazijnPagina>
    with WidgetsBindingObserver {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Duration _syncInterval = Duration(minutes: 3);

  final MagazijnController _controller = MagazijnController();

  Timer? _syncTimer;
  bool _syncBezig = false;
  int _index = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _controller.laad();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _synchroniseerEnHerlaad();
    });

    _syncTimer = Timer.periodic(_syncInterval, (_) {
      _synchroniseerEnHerlaad();
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _synchroniseerEnHerlaad();
      return;
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      OneDriveSyncService().uploadBackupOpAchtergrond();
    }
  }

  Future<void> _synchroniseerEnHerlaad() async {
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
        await _controller.laad();

        if (!mounted) {
          return;
        }

        SyncNavigatieHelper.meldDownloadVoltooid();
      }
    } finally {
      _syncBezig = false;
    }
  }

  bool _isDownloadResultaat(String resultaat) {
    return resultaat.startsWith('IMPORT_OK');
  }

  @override
  Widget build(BuildContext context) {
    final paginas = <Widget>[
      MagazijnScanPagina(controller: _controller),
      MagazijnBestellijstPagina(controller: _controller),
      MagazijnBeheerPagina(controller: _controller),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: _groen,
        foregroundColor: Colors.white,
        title: const Text(
          'Magazijn',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          if (_controller.laden) {
            return const Center(child: CircularProgressIndicator());
          }

          return paginas[_index];
        },
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: const Color(0xFFE7F6EC),
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? _groen
                  : const Color(0xFF6B7280),
            ),
          ),
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
            (states) => TextStyle(
              color: states.contains(WidgetState.selected)
                  ? _groen
                  : const Color(0xFF6B7280),
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w900
                  : FontWeight.w700,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          indicatorColor: const Color(0xFFE7F6EC),
          onDestinationSelected: (waarde) => setState(() => _index = waarde),
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.qr_code_scanner),
              label: 'Scannen',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_cart_outlined),
              label: 'Te bestellen',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              label: 'Artikelen',
            ),
          ],
        ),
      ),
    );
  }
}
