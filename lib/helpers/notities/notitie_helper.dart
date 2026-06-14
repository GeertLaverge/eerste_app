import 'notitie_model.dart';

class NotitieHelper {
  static String datumKey(
    DateTime datum,
  ) {
    return '${datum.year.toString().padLeft(4, '0')}-'
        '${datum.month.toString().padLeft(2, '0')}-'
        '${datum.day.toString().padLeft(2, '0')}';
  }

  static List<NotitieModel> sorteerVoorDag(
    List<NotitieModel> lijst,
  ) {
    final kopie = [...lijst];

    kopie.sort((a, b) {
      if (a.afgewerkt != b.afgewerkt) {
        return a.afgewerkt ? 1 : -1;
      }

      return a.aangemaaktOp.compareTo(
        b.aangemaaktOp,
      );
    });

    return kopie;
  }

  static bool heeftOpenNotities(
    List<NotitieModel> lijst,
  ) {
    return lijst.any(
      (n) => !n.afgewerkt,
    );
  }
}
