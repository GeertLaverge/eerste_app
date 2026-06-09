import 'package:flutter/material.dart';

import 'onedrive_sync_service.dart';

class SyncNavigatieHelper {
  static Future<void> openMetDownload({
    required BuildContext context,
    required Widget pagina,
  }) async {
    await OneDriveSyncService().slimmeSync();

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => pagina,
      ),
    );
  }

  static Future<void> terugNaarHomeMetUpload({
    required BuildContext context,
  }) async {
    await OneDriveSyncService().uploadBackupOpAchtergrond();

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }
}
