import 'dart:math';

import '../app_storage.dart';

import 'agenda_dagtaak_template.dart';

class AgendaDagtaakHelper {
  static Future<List<AgendaDagtaakTemplate>> laad() async {
    return AppStorage.laadDagtaakTemplates();
  }

  static Future<void> bewaar(
    AgendaDagtaakTemplate template,
  ) async {
    final lijst = await laad();

    final bestaat = lijst.any(
      (
        item,
      ) {
        return item.id == template.id;
      },
    );

    if (bestaat) {
      return;
    }

    lijst.add(
      template,
    );

    await AppStorage.bewaarDagtaakTemplates(
      lijst,
    );
  }

  static Future<void> verwijder(
    String id,
  ) async {
    final lijst = await laad();

    lijst.removeWhere(
      (
        item,
      ) {
        return item.id == id;
      },
    );

    await AppStorage.bewaarDagtaakTemplates(
      lijst,
    );
  }

  static String nieuwId() {
    final random = Random();

    return DateTime.now().millisecondsSinceEpoch.toString() +
        random
            .nextInt(
              999,
            )
            .toString();
  }
}
