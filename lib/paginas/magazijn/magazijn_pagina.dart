// THIMACO-CONTROLE: MAGAZIJN-GEBRUIKT-CENTRALE-SYNC-20260914
// THIMACO-CONTROLE: MAGAZIJN-CENTRAAL-DOWNLOADSIGNAAL-FASE7-20260805
// THIMACO-CONTROLE: MAGAZIJN-PERIODIEKE-SYNC-FASE6-20260805

import 'dart:async';

import 'package:flutter/material.dart';

import '../../helpers/magazijn/magazijn_controller.dart';
import '../../helpers/sync/sync_navigatie_helper.dart';
import 'magazijn_beheer_pagina.dart';
import 'magazijn_bestellijst_pagina.dart';
import 'magazijn_scan_pagina.dart';

class MagazijnPagina extends StatefulWidget {
  const MagazijnPagina({super.key});

  @override
  State<MagazijnPagina> createState() => _MagazijnPaginaState();
}

class _MagazijnPaginaState extends State<MagazijnPagina> {
  static const Color _groen = Color(0xFF0B7A3B);
  final MagazijnController _controller = MagazijnController();

  int _laatsteVerwerkteDownloadVersie = 0;
  bool _herladenBezig = false;
  bool _herladenNogmaals = false;
  int _index = 0;

  @override
  void initState() {
    super.initState();

    _laatsteVerwerkteDownloadVersie = SyncNavigatieHelper.downloadVersie.value;
    SyncNavigatieHelper.downloadVersie.addListener(_verwerkAchtergrondDownload);

    unawaited(_controller.laad());
  }

  @override
  void dispose() {
    SyncNavigatieHelper.downloadVersie.removeListener(
      _verwerkAchtergrondDownload,
    );
    _controller.dispose();
    super.dispose();
  }

  void _verwerkAchtergrondDownload() {
    final nieuweVersie = SyncNavigatieHelper.downloadVersie.value;
    if (nieuweVersie <= _laatsteVerwerkteDownloadVersie) {
      return;
    }

    _laatsteVerwerkteDownloadVersie = nieuweVersie;
    unawaited(_herlaadNaCentraleDownload());
  }

  Future<void> _herlaadNaCentraleDownload() async {
    if (_herladenBezig) {
      _herladenNogmaals = true;
      return;
    }

    _herladenBezig = true;
    try {
      do {
        _herladenNogmaals = false;
        await _controller.laad();
      } while (_herladenNogmaals && mounted);
    } finally {
      _herladenBezig = false;
    }
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
