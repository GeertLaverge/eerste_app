import 'package:flutter/material.dart';

import 'agenda_item.dart';
import 'agenda_dagtaak_popup.dart';
import 'agenda_verlof_popup.dart';
import 'agenda_toevoeg_popup.dart';

class AgendaItemOpenHelper {
  static Future<Object?> open({
    required BuildContext context,
    required AgendaItem item,
    required List<AgendaItem> geplandeItems,
  }) async {
    return showDialog<Object>(
      context: context,
      builder: (context) {
        if (item.type == 'dagtaak') {
          return AgendaDagtaakPopup(
            bestaandItem: item,
          );
        }

        if (item.type == 'verlof') {
          return AgendaVerlofPopup(
            bestaandItem: item,
          );
        }

        return AgendaToevoegPopup(
          bestaandItem: item,
          geplandeItems: geplandeItems,
        );
      },
    );
  }
}
