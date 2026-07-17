import 'package:flutter/material.dart';

import 'leveranciers_pagina.dart';
import 'archief_klanten_pagina.dart';

import '../helpers/sync/onedrive_auth_service.dart';
import '../helpers/sync/onedrive_sync_service.dart';
import '../helpers/notities/notitie_acties_pagina.dart';
import '../helpers/opmeting/raam/opmeting_raam_opvullingen_pagina.dart';
import '../helpers/opmeting/deurpanelen/opmeting_deurpaneel_beheer_dialog.dart';
import '../helpers/opmeting/project/opmeting_project_kleuren_pagina.dart';

class InstellingenPagina extends StatelessWidget {
  const InstellingenPagina({super.key});

  static const Color groen = Color(0xFF0B7A3B);

  void _toonMelding(BuildContext context, String tekst) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tekst)));
  }

  Future<void> _toonDebugDialog(BuildContext context, String tekst) async {
    if (!context.mounted) {
      return;
    }

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Sync debug'),
          content: SingleChildScrollView(child: SelectableText(tekst)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Sluiten'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openDeurpanelenBeheer(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) {
        return const OpmetingDeurpaneelBeheerDialog();
      },
    );
  }

  ButtonStyle _knopStijl(Color achtergrond) {
    return ElevatedButton.styleFrom(
      backgroundColor: achtergrond,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(52),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Instellingen',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 312,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final token = await OneDriveAuthService().loginInteractief();

                  if (!context.mounted) {
                    return;
                  }

                  if (token.startsWith('FOUT')) {
                    _toonMelding(context, token);
                    return;
                  }

                  _toonMelding(context, 'Aangemeld Microsoft');
                },
                icon: const Icon(Icons.login),
                label: const Text('Aanmelden Microsoft'),
                style: _knopStijl(Colors.blue),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final resultaat = await OneDriveSyncService().uploadBackup();

                  if (!context.mounted) {
                    return;
                  }

                  _toonMelding(context, resultaat);
                },
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Upload naar OneDrive'),
                style: _knopStijl(groen),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final token = await OneDriveAuthService().tokenSilent();

                  if (!context.mounted) {
                    return;
                  }

                  if (token.startsWith('FOUT')) {
                    _toonMelding(context, token);
                    return;
                  }

                  final resultaat = await OneDriveSyncService()
                      .downloadBackupMetToken(token);

                  if (!context.mounted) {
                    return;
                  }

                  _toonMelding(context, resultaat);
                },
                icon: const Icon(Icons.cloud_download),
                label: const Text('Download van OneDrive'),
                style: _knopStijl(Colors.orange),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final debugInfo = await OneDriveSyncService().syncDebugInfo();

                  if (!context.mounted) {
                    return;
                  }

                  await _toonDebugDialog(context, debugInfo);
                },
                icon: const Icon(Icons.bug_report_outlined),
                label: const Text('Sync debug'),
                style: _knopStijl(Colors.black87),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final accountInfo = await OneDriveAuthService()
                      .accountDebugInfo();

                  if (!context.mounted) {
                    return;
                  }

                  await _toonDebugDialog(context, accountInfo);
                },
                icon: const Icon(Icons.account_circle_outlined),
                label: const Text('Account debug'),
                style: _knopStijl(Colors.purple),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  if (!context.mounted) {
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) {
                        return const LeveranciersPagina();
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.local_shipping_outlined),
                label: const Text('Leveranciers'),
                style: _knopStijl(groen),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  if (!context.mounted) {
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) {
                        return const NotitieActiesPagina();
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.edit_note_outlined),
                label: const Text('Acties notities'),
                style: _knopStijl(groen),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) {
                        return const OpmetingRaamOpvullingenPagina();
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.format_color_fill_outlined),
                label: const Text('Opvullingen'),
                style: _knopStijl(groen),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  _openDeurpanelenBeheer(context);
                },
                icon: const Icon(Icons.door_front_door_outlined),
                label: const Text('Deurpanelen'),
                style: _knopStijl(groen),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) {
                        return OpmetingProjectKleurenPagina();
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.palette_outlined),
                label: const Text('Kleuren raamleverancier'),
                style: _knopStijl(groen),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  if (!context.mounted) {
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) {
                        return const ArchiefKlantenPagina();
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.archive_outlined),
                label: const Text('Archief klanten'),
                style: _knopStijl(groen),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
