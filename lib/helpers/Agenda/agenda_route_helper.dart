import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

class AgendaRouteHelper {
  static Future<void> openRoute({
    required String straat,
    required String huisNr,
    required String postcode,
    required String gemeente,
  }) async {
    final adres = '$straat $huisNr, $postcode $gemeente';

    final encodedAdres = Uri.encodeComponent(adres);

    Uri uri;

    if (Platform.isIOS) {
      uri = Uri.parse(
        'http://maps.apple.com/?q=$encodedAdres',
      );
    } else {
      uri = Uri.parse(
        'google.navigation:q=$encodedAdres',
      );
    }

    if (!await canLaunchUrl(uri)) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encodedAdres',
      );
    }

    await launchUrl(
      uri,
      mode: LaunchMode.platformDefault,
    );
  }
}
