import 'package:flutter/foundation.dart';

import 'opmeting_deurpaneel_model.dart';
import 'opmeting_deurpaneel_toewijzing_model.dart';

class OpmetingDeurpaneelActieveKeuzeController {
  OpmetingDeurpaneelActieveKeuzeController._();

  static final ValueNotifier<OpmetingDeurpaneelKeuze?> keuze =
      ValueNotifier<OpmetingDeurpaneelKeuze?>(null);

  static final ValueNotifier<List<OpmetingDeurpaneelToewijzing>> toewijzingen =
      ValueNotifier<List<OpmetingDeurpaneelToewijzing>>(
        const <OpmetingDeurpaneelToewijzing>[],
      );

  static OpmetingDeurpaneelKeuze? get huidigeKeuze => keuze.value;

  static void kies(OpmetingDeurpaneelKeuze nieuweKeuze) {
    keuze.value = nieuweKeuze;
  }

  static void werkToewijzingenBij(
    List<OpmetingDeurpaneelToewijzing> nieuweToewijzingen,
  ) {
    toewijzingen.value = List<OpmetingDeurpaneelToewijzing>.unmodifiable(
      nieuweToewijzingen,
    );
  }

  static void wis() {
    keuze.value = null;
  }

  static void wisAlles() {
    keuze.value = null;
    toewijzingen.value = const <OpmetingDeurpaneelToewijzing>[];
  }
}
