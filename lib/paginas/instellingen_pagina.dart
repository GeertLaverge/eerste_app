import 'package:flutter/material.dart';

import 'leveranciers_pagina.dart';
import 'archief_klanten_pagina.dart';

import '../helpers/sync/onedrive_auth_service.dart';
import '../helpers/sync/onedrive_sync_service.dart';
import '../helpers/notities/notitie_acties_pagina.dart';

class InstellingenPagina extends StatelessWidget {
  const InstellingenPagina({super.key});

  static const groen = Color(0xFF0B7A3B);

  void _toonMelding(BuildContext context, String tekst) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tekst)));
  }

  Future<void> _toonDebugDialog(BuildContext context, String tekst) async {
    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sync debug'),
        content: SingleChildScrollView(child: SelectableText(tekst)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Sluiten'),
          ),
        ],
      ),
    );
  }

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
          width: 280,
          child: Column(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final token = await OneDriveAuthService().loginInteractief();

                  if (!context.mounted) return;

                  if (token.startsWith('FOUT')) {
                    _toonMelding(context, token);
                    return;
                  }

                  _toonMelding(context, 'Aangemeld Microsoft');
                },
                icon: const Icon(Icons.login),
                label: const Text('Aanmelden Microsoft'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: () async {
                  final resultaat = await OneDriveSyncService().uploadBackup();

                  if (!context.mounted) return;

                  _toonMelding(context, resultaat);
                },
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Upload naar OneDrive'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: groen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: () async {
                  final token = await OneDriveAuthService().tokenSilent();

                  if (!context.mounted) return;

                  if (token.startsWith('FOUT')) {
                    _toonMelding(context, token);
                    return;
                  }

                  final resultaat = await OneDriveSyncService()
                      .downloadBackupMetToken(token);

                  if (!context.mounted) return;

                  _toonMelding(context, resultaat);
                },
                icon: const Icon(Icons.cloud_download),
                label: const Text('Download van OneDrive'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: () async {
                  final debugInfo = await OneDriveSyncService().syncDebugInfo();

                  if (!context.mounted) return;

                  await _toonDebugDialog(context, debugInfo);
                },
                icon: const Icon(Icons.bug_report_outlined),
                label: const Text('Sync debug'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: () async {
                  // TIJDELIJK UITGESCHAKELD VOOR SYNC DEBUG
                  /*
                  await OneDriveSyncService().slimmeSync(
                    magLoginVragen: false,
                  );
                  */

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
                  // TIJDELIJK UITGESCHAKELD VOOR SYNC DEBUG
                  /*
                  await OneDriveSyncService().slimmeSync(
                    magLoginVragen: false,
                  );
                  */

                  if (!context.mounted) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotitieActiesPagina(),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_note_outlined),
                label: const Text('Acties notities'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: groen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: () async {
                  // TIJDELIJK UITGESCHAKELD VOOR SYNC DEBUG
                  /*
                  await OneDriveSyncService().slimmeSync(
                    magLoginVragen: false,
                  );
                  */

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
