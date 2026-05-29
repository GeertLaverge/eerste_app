import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AgendaMeldingService {
  static final FlutterLocalNotificationsPlugin _meldingen =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialiseren() async {
    const ios = DarwinInitializationSettings();

    const settings = InitializationSettings(
      iOS: ios,
    );

    await _meldingen.initialize(settings);

    await _meldingen
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static Future<void> toonTestMelding() async {
    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      iOS: iosDetails,
    );

    await _meldingen.show(
      999,
      'Thimaco',
      'Testmelding werkt correct',
      details,
    );
  }
}
