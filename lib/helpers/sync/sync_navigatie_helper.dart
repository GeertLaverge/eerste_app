import 'package:flutter/material.dart';

class SyncNavigatieHelper {
  static Future<void> openMetDownload({
    required BuildContext context,
    required Widget pagina,
  }) async {
    // TIJDELIJK UITGESCHAKELD VOOR SYNC DEBUG
    /*
    await OneDriveSyncService().slimmeSync(
      magLoginVragen: false,
    );
    */

    if (!context.mounted) return;

    Navigator.push(context, MaterialPageRoute(builder: (_) => pagina));
  }

  static Future<void> terugNaarHomeMetUpload({
    required BuildContext context,
  }) async {
    // TIJDELIJK UITGESCHAKELD VOOR SYNC DEBUG
    /*
    await OneDriveSyncService().slimmeSync(
      magLoginVragen: false,
    );
    */

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }
}
