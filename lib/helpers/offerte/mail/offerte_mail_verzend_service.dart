// THIMACO-CONTROLE: NATIVE-IOS-MAILCOMPOSER-DAGELIJKSE-IMAP-20260802

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class OfferteMailBijlage {
  const OfferteMailBijlage({
    required this.bestandsnaam,
    required this.bytes,
    this.contentType = 'application/pdf',
  });

  final String bestandsnaam;
  final Uint8List bytes;
  final String contentType;
}

typedef OfferteMailVoortgang = void Function(String status, double voortgang);

class OfferteMailVerzendService {
  static const MethodChannel _kanaal = MethodChannel(
    'be.thimaco.app/offerte_mail',
  );

  Future<void> verstuur({
    required String ontvanger,
    required String onderwerp,
    required String bericht,
    required List<OfferteMailBijlage> bijlagen,
    OfferteMailVoortgang? onVoortgang,
  }) async {
    final schoonAdres = ontvanger.trim();
    final schoonOnderwerp = onderwerp.trim();
    final schoonBericht = bericht.trim();

    if (!_isGeldigEmailadres(schoonAdres)) {
      throw const OfferteMailVerzendException(
        'Geef een geldig e-mailadres van de klant in.',
      );
    }
    if (schoonOnderwerp.isEmpty) {
      throw const OfferteMailVerzendException(
        'Geef een onderwerp voor de e-mail in.',
      );
    }
    if (schoonBericht.isEmpty) {
      throw const OfferteMailVerzendException(
        'De e-mailtekst mag niet leeg zijn.',
      );
    }

    for (final bijlage in bijlagen) {
      if (bijlage.bytes.isEmpty) {
        throw OfferteMailVerzendException(
          'De bijlage “${bijlage.bestandsnaam}” is leeg.',
        );
      }
    }

    if (defaultTargetPlatform != TargetPlatform.iOS) {
      throw const OfferteMailVerzendException(
        'Deze mailfunctie gebruikt het gewone iPad-mailvenster en kan alleen '
        'op de iPad worden getest.',
      );
    }

    onVoortgang?.call('iPad-mailvenster openen…', 0.35);

    try {
      final resultaat = await _kanaal.invokeMethod<String>(
        'openMailComposer',
        <String, dynamic>{
          'ontvangers': <String>[schoonAdres],
          'onderwerp': schoonOnderwerp,
          'bericht': schoonBericht,
          'bijlagen': bijlagen
              .map((bijlage) {
                return <String, dynamic>{
                  'bestandsnaam': _veiligeBestandsnaam(bijlage.bestandsnaam),
                  'contentType': bijlage.contentType,
                  'bytes': bijlage.bytes,
                };
              })
              .toList(growable: false),
        },
      );

      switch (resultaat) {
        case 'sent':
          onVoortgang?.call('E-mail verstuurd', 1.0);
          return;
        case 'saved':
          throw const OfferteMailGeannuleerdException(
            'De e-mail is als concept bewaard in de iPad-mailapp.',
          );
        case 'cancelled':
          throw const OfferteMailGeannuleerdException(
            'Het iPad-mailvenster is gesloten zonder te versturen.',
          );
        default:
          throw const OfferteMailVerzendException(
            'De iPad-mailapp gaf geen geldig verzendresultaat terug.',
          );
      }
    } on PlatformException catch (fout) {
      final melding = fout.message?.trim() ?? '';
      throw OfferteMailVerzendException(
        melding.isEmpty
            ? 'Het iPad-mailvenster kon niet worden geopend.'
            : melding,
      );
    } on MissingPluginException {
      throw const OfferteMailVerzendException(
        'De native iPad-mailkoppeling ontbreekt in deze build. '
        'Maak na het vervangen van AppDelegate.swift een nieuwe iOS-build.',
      );
    }
  }

  static bool _isGeldigEmailadres(String waarde) {
    return RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
      caseSensitive: false,
    ).hasMatch(waarde);
  }

  static String _veiligeBestandsnaam(String waarde) {
    final schoon = waarde.trim().replaceAll(RegExp(r'[\\/:*?"<>|]+'), '_');
    return schoon.isEmpty ? 'document.pdf' : schoon;
  }
}

class OfferteMailVerzendException implements Exception {
  const OfferteMailVerzendException(this.bericht);

  final String bericht;

  @override
  String toString() => bericht;
}

class OfferteMailGeannuleerdException extends OfferteMailVerzendException {
  const OfferteMailGeannuleerdException(super.bericht);
}
