// THIMACO-CONTROLE: NAVIGATIE-ZONDER-DUBBELE-AUTOSYNC-20260914
// THIMACO-CONTROLE: CENTRAAL-DOWNLOADSIGNAAL-FASE7-20260805

import 'dart:async';

import 'package:flutter/material.dart';

import 'onedrive_auth_service.dart';
import 'onedrive_sync_service.dart';

class SyncNavigatieHelper {
  SyncNavigatieHelper._();

  /// Wordt verhoogd nadat een download van de gewone
  /// appgegevens succesvol is uitgevoerd.
  ///
  /// Agenda, Klanten, Notities, Home en andere luisterende
  /// pagina's laden daarna hun lokale gegevens opnieuw in.
  static final ValueNotifier<int> downloadVersie = ValueNotifier<int>(0);

  /// Centraal signaal voor iedere geslaagde download.
  ///
  /// Gebruik deze methode ook wanneer [OneDriveSyncService.slimmeSync]
  /// buiten deze helper rechtstreeks wordt aangeroepen.
  static void meldDownloadVoltooid() {
    downloadVersie.value++;
  }

  static void _melding(BuildContext context, String tekst) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tekst)));
  }

  static bool _isFoutmelding(String waarde) {
    final tekst = waarde.trimLeft().toUpperCase();

    return tekst.startsWith('FOUT') ||
        tekst.startsWith('IMPORT_FOUT') ||
        tekst.startsWith('IMPORT_EXCEPTION') ||
        tekst.startsWith('BACKUP_FOUT') ||
        tekst.startsWith('BACKUP_EXCEPTION');
  }

  /// Handmatige upload vanaf een knop.
  ///
  /// Omdat de gebruiker deze upload bewust uitvoert,
  /// worden ook de klantenfoto's meegenomen.
  static Future<void> uploadVanafPagina({required BuildContext context}) async {
    final resultaat = await OneDriveSyncService().uploadBackup(
      uploadFotos: true,
    );

    if (!context.mounted) {
      return;
    }

    _melding(context, resultaat);
  }

  /// Handmatige download vanaf een knop.
  ///
  /// Omdat de gebruiker deze download bewust uitvoert,
  /// worden ook de klantenfoto's gecontroleerd en,
  /// indien nodig, gedownload.
  static Future<void> downloadVanafPagina({
    required BuildContext context,
  }) async {
    final token = await OneDriveAuthService().tokenSilent();

    if (!context.mounted) {
      return;
    }

    if (_isFoutmelding(token)) {
      _melding(context, token);

      return;
    }

    final resultaat = await OneDriveSyncService().downloadBackupMetToken(
      token,
      downloadFotos: true,
    );

    if (!context.mounted) {
      return;
    }

    if (!_isFoutmelding(resultaat)) {
      meldDownloadVoltooid();
    }

    _melding(context, resultaat);
  }

  /// Keert onmiddellijk terug naar Home.
  ///
  /// De centrale app-synccontroller verzorgt de automatische synchronisatie.
  /// Navigatie start daarom bewust geen tweede download meer.
  static Future<void> terugNaarHomeMetDownload({
    required BuildContext context,
  }) {
    if (!context.mounted) {
      return Future<void>.value();
    }

    unawaited(
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil<void>('/', (route) => false),
    );

    return Future<void>.value();
  }

  /// Opent de gekozen pagina onmiddellijk.
  ///
  /// De centrale app-synccontroller verzorgt de automatische synchronisatie.
  /// Navigatie start daarom bewust geen tweede download meer.
  static Future<void> openMetDownload({
    required BuildContext context,
    required Widget pagina,
  }) {
    if (!context.mounted) {
      return Future<void>.value();
    }

    unawaited(
      Navigator.of(
        context,
      ).push<void>(MaterialPageRoute<void>(builder: (_) => pagina)),
    );

    return Future<void>.value();
  }
}
