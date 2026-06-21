import 'package:flutter/material.dart';

import 'onedrive_auth_service.dart';
import 'onedrive_sync_service.dart';

class SyncNavigatieHelper {
  static void _melding(BuildContext context, String tekst) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tekst)));
  }

  static Future<void> uploadVanafPagina({required BuildContext context}) async {
    final resultaat = await OneDriveSyncService().uploadBackup();

    if (!context.mounted) return;

    _melding(context, resultaat);
  }

  static Future<void> downloadVanafPagina({
    required BuildContext context,
  }) async {
    final token = await OneDriveAuthService().tokenSilent();

    if (!context.mounted) return;

    if (token.startsWith('FOUT')) {
      _melding(context, token);
      return;
    }

    final resultaat = await OneDriveSyncService().downloadBackupMetToken(token);

    if (!context.mounted) return;

    _melding(context, resultaat);
  }

  static Future<void> terugNaarHomeMetDownload({
    required BuildContext context,
  }) async {
    final token = await OneDriveAuthService().tokenSilent();

    if (!context.mounted) return;

    if (!token.startsWith('FOUT')) {
      await OneDriveSyncService().downloadBackupMetToken(token);
    }

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  static Future<void> openMetDownload({
    required BuildContext context,
    required Widget pagina,
  }) async {
    final token = await OneDriveAuthService().tokenSilent();

    if (!context.mounted) return;

    if (!token.startsWith('FOUT')) {
      await OneDriveSyncService().downloadBackupMetToken(token);
    }

    if (!context.mounted) return;

    Navigator.push(context, MaterialPageRoute(builder: (_) => pagina));
  }
}
