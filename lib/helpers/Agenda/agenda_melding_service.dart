import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'agenda_item.dart';

class AgendaMeldingService {
  static final FlutterLocalNotificationsPlugin _meldingen =
      FlutterLocalNotificationsPlugin();

  static bool get _isIos {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  }

  static Future<void> initialiseren() async {
    // De huidige notificatieconfiguratie is uitsluitend voor iOS.
    // Op Windows doen we hier bewust niets. Agenda-opslag en schermvernieuwing
    // mogen nooit afhankelijk zijn van een iOS-notificatieplugin.
    if (!_isIos) {
      return;
    }

    tz.initializeTimeZones();

    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(iOS: ios);

    try {
      await _meldingen.initialize(settings);

      await _meldingen
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (error) {
      debugPrint('AgendaMeldingService: initialiseren mislukt: $error');
    }
  }

  static int meldingId({required DateTime dag, required AgendaItem item}) {
    return '${dag.year}${dag.month}${dag.day}${item.titel}${item.startUur}${item.startMinuut}'
        .hashCode
        .abs();
  }

  static Future<void> planMelding({
    required DateTime dag,
    required AgendaItem item,
  }) async {
    // Alleen iPhone/iPad gebruiken momenteel lokale agendameldingen.
    // Windows moet onmiddellijk verder kunnen met de agenda-UI.
    if (!_isIos) {
      return;
    }

    if (item.meldingVoorafMinuten <= 0) return;
    if (item.volledigeDag) return;
    if (item.startUur == null || item.startMinuut == null) return;

    final afspraakTijd = DateTime(
      dag.year,
      dag.month,
      dag.day,
      item.startUur!,
      item.startMinuut!,
    );

    final meldingTijd = afspraakTijd.subtract(
      Duration(minutes: item.meldingVoorafMinuten),
    );

    if (meldingTijd.isBefore(DateTime.now())) return;

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(iOS: iosDetails);

    try {
      await _meldingen.zonedSchedule(
        meldingId(dag: dag, item: item),
        'Thimaco afspraak',
        '${item.titel} om ${item.tijdTekst.replaceAll('\n', ' - ')}',
        tz.TZDateTime.from(meldingTijd, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (error) {
      debugPrint('AgendaMeldingService: melding plannen mislukt: $error');
    }
  }

  static Future<void> verwijderMelding({
    required DateTime dag,
    required AgendaItem item,
  }) async {
    if (!_isIos) {
      return;
    }

    try {
      await _meldingen.cancel(meldingId(dag: dag, item: item));
    } catch (error) {
      debugPrint('AgendaMeldingService: melding verwijderen mislukt: $error');
    }
  }

  static Future<void> toonTestMelding() async {
    if (!_isIos) {
      return;
    }

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(iOS: iosDetails);

    try {
      await _meldingen.show(
        999,
        'Thimaco',
        'Testmelding werkt correct',
        details,
      );
    } catch (error) {
      debugPrint('AgendaMeldingService: testmelding mislukt: $error');
    }
  }
}
