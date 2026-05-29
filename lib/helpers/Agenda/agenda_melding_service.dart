import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'agenda_item.dart';

class AgendaMeldingService {
  static final FlutterLocalNotificationsPlugin _meldingen =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialiseren() async {
    tz.initializeTimeZones();

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

  static int meldingId({
    required DateTime dag,
    required AgendaItem item,
  }) {
    return '${dag.year}${dag.month}${dag.day}${item.titel}${item.startUur}${item.startMinuut}'
        .hashCode
        .abs();
  }

  static Future<void> planMelding({
    required DateTime dag,
    required AgendaItem item,
  }) async {
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
      Duration(
        minutes: item.meldingVoorafMinuten,
      ),
    );

    if (meldingTijd.isBefore(DateTime.now())) return;

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      iOS: iosDetails,
    );

    await _meldingen.zonedSchedule(
      meldingId(
        dag: dag,
        item: item,
      ),
      'Thimaco afspraak',
      '${item.titel} om ${item.tijdTekst.replaceAll('\n', ' - ')}',
      tz.TZDateTime.from(
        meldingTijd,
        tz.local,
      ),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> verwijderMelding({
    required DateTime dag,
    required AgendaItem item,
  }) async {
    await _meldingen.cancel(
      meldingId(
        dag: dag,
        item: item,
      ),
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
