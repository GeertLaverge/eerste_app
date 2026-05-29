import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

class AgendaRouteHelper {
  static Future<void> openRoute({
    required String straat,
    required String huisNr,
    required String postcode,
    required String gemeente,
  }) async {
    final adres = '$straat $huisNr, $postcode $gemeente'.trim();
    final encodedAdres = Uri.encodeComponent(adres);

    Uri uri;

    if (Platform.isIOS) {
      uri = Uri.parse(
        'https://maps.apple.com/?saddr=Current%20Location&daddr=$encodedAdres&dirflg=d',
      );
    } else if (Platform.isAndroid) {
      uri = Uri.parse(
        'google.navigation:q=$encodedAdres&mode=d',
      );
    } else {
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=Current%20Location&destination=$encodedAdres&travelmode=driving',
      );
    }

    if (!await canLaunchUrl(uri)) {
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=Current%20Location&destination=$encodedAdres&travelmode=driving',
      );
    }

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }
}
