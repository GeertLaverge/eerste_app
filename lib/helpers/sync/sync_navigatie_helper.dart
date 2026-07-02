import 'dart:async';

import 'package:flutter/material.dart';

import 'onedrive_auth_service.dart';
import 'onedrive_sync_service.dart';

class SyncNavigatieHelper {
  SyncNavigatieHelper._();

  /// Wordt verhoogd nadat een download van de gewone
  /// appgegevens succesvol is uitgevoerd.
  ///
  /// Agenda, Klanten, Notities en Home luisteren hiernaar
  /// en laden daarna hun lokale gegevens opnieuw in.
  static final ValueNotifier<int> downloadVersie = ValueNotifier<int>(0);

  /// Er kan maar één automatische download tegelijk lopen.
  static Future<void>? _lopendeAchtergrondDownload;

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
      downloadVersie.value++;
    }

    _melding(context, resultaat);
  }

  /// Keert onmiddellijk terug naar Home.
  ///
  /// De gewone appgegevens worden daarna zonder foto's
  /// op de achtergrond gedownload.
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

    _startAchtergrondDownloadNaNavigatie();

    return Future<void>.value();
  }

  /// Opent de gekozen pagina onmiddellijk.
  ///
  /// De gewone appgegevens worden daarna zonder foto's
  /// op de achtergrond gedownload.
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

    _startAchtergrondDownloadNaNavigatie();

    return Future<void>.value();
  }

  /// Laat Flutter eerst de nieuwe pagina tekenen.
  /// Daarna pas begint de achtergronddownload.
  static void _startAchtergrondDownloadNaNavigatie() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAchtergrondDownload();
    });
  }

  static void _startAchtergrondDownload() {
    if (_lopendeAchtergrondDownload != null) {
      return;
    }

    final taak = _voerAchtergrondDownloadUit();

    _lopendeAchtergrondDownload = taak;

    unawaited(
      taak.whenComplete(() {
        if (identical(_lopendeAchtergrondDownload, taak)) {
          _lopendeAchtergrondDownload = null;
        }
      }),
    );
  }

  static Future<void> _voerAchtergrondDownloadUit() async {
    try {
      final token = await OneDriveAuthService().tokenSilent();

      if (_isFoutmelding(token)) {
        return;
      }

      /*
       * Automatische navigatiesync:
       * alleen agenda, klanten, notities en instellingen.
       *
       * Klantenfoto's worden hier bewust overgeslagen,
       * zodat de geopende pagina soepel blijft werken.
       */
      final resultaat = await OneDriveSyncService().downloadBackupMetToken(
        token,
        downloadFotos: false,
      );

      if (_isFoutmelding(resultaat)) {
        return;
      }

      downloadVersie.value++;
    } catch (_) {
      /*
       * Een automatische synchronisatie mag de navigatie
       * nooit blokkeren en toont daarom geen foutmelding.
       *
       * Bij een handmatige download krijgt de gebruiker
       * wel het resultaat te zien.
       */
    }
  }
}
