import 'package:flutter/material.dart';

import 'leveranciers_pagina.dart';
import 'archief_klanten_pagina.dart';
import '../helpers/sync/onedrive_sync_service.dart';

class InstellingenPagina extends StatelessWidget {
  const InstellingenPagina({super.key});

  static const groen = Color(0xFF0B7A3B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Instellingen'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 260,
          child: Column(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  await OneDriveSyncService().slimmeSync();

                  if (!context.mounted) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LeveranciersPagina(),
                    ),
                  );
                },
                icon: const Icon(Icons.local_shipping_outlined),
                label: const Text('Leveranciers'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: groen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  await OneDriveSyncService().slimmeSync();

                  if (!context.mounted) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ArchiefKlantenPagina(),
                    ),
                  );
                },
                icon: const Icon(Icons.archive_outlined),
                label: const Text('Archief klanten'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: groen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
