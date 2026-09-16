// THIMACO-CONTROLE: NOTITIES-REPOSITORY-SERIEEL-SNAPSHOT-20260914
import '../../helpers/app_storage.dart';

import 'notitie_actie_model.dart';
import 'notitie_model.dart';

class NotitieRepository {
  /*
   * Eén gedeelde bewaarrij voor alle repository-instanties.
   * Hierdoor kan een oudere save nooit ná een nieuwere save worden geschreven.
   */
  static Future<void> _notitieBewaarKeten = Future<void>.value();
  static Future<void> _actieBewaarKeten = Future<void>.value();

  Future<List<NotitieModel>> laadNotities() async {
    /*
     * Eerst wachten tot eerder ingeplande saves klaar zijn.
     * Zo kan een nieuwe pagina nooit een oude snapshot lezen terwijl de laatste
     * tekst nog in de bewaarrij staat.
     */
    try {
      await _notitieBewaarKeten;
    } catch (_) {
      // Een vorige fout mag het opnieuw laden niet permanent blokkeren.
    }

    return AppStorage.laadNotities();
  }

  Future<void> bewaarNotities(List<NotitieModel> notities) {
    /*
     * Onmiddellijk een echte snapshot maken.
     * De UI mag daarna verder typen zonder de reeds ingeplande save te wijzigen.
     */
    final snapshot = notities
        .map(
          (notitie) => NotitieModel.fromJson(
            Map<String, dynamic>.from(notitie.toJson()),
          ),
        )
        .toList(growable: false);

    final vorigeBewaring = _notitieBewaarKeten;

    final nieuweBewaring = () async {
      try {
        await vorigeBewaring;
      } catch (_) {
        /*
         * Als een oudere save faalde, moet de nieuwste geldige snapshot nog
         * steeds een kans krijgen om te worden opgeslagen.
         */
      }

      await AppStorage.bewaarNotities(snapshot);
    }();

    _notitieBewaarKeten = nieuweBewaring;
    return nieuweBewaring;
  }

  Future<List<NotitieActieModel>> laadActies() async {
    try {
      await _actieBewaarKeten;
    } catch (_) {
      // Zie laadNotities.
    }

    return AppStorage.laadNotitieActies();
  }

  Future<void> bewaarActies(List<NotitieActieModel> acties) {
    final snapshot = acties
        .map(
          (actie) => NotitieActieModel.fromJson(
            Map<String, dynamic>.from(actie.toJson()),
          ),
        )
        .toList(growable: false);

    final vorigeBewaring = _actieBewaarKeten;

    final nieuweBewaring = () async {
      try {
        await vorigeBewaring;
      } catch (_) {
        // Een oudere fout mag de nieuwste actie-opslag niet blokkeren.
      }

      await AppStorage.bewaarNotitieActies(snapshot);
    }();

    _actieBewaarKeten = nieuweBewaring;
    return nieuweBewaring;
  }
}
