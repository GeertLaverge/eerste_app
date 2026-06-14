import '../../helpers/app_storage.dart';

import 'notitie_actie_model.dart';
import 'notitie_model.dart';

class NotitieRepository {
  Future<List<NotitieModel>> laadNotities() async {
    return AppStorage.laadNotities();
  }

  Future<void> bewaarNotities(
    List<NotitieModel> notities,
  ) async {
    await AppStorage.bewaarNotities(notities);
  }

  Future<List<NotitieActieModel>> laadActies() async {
    return AppStorage.laadNotitieActies();
  }

  Future<void> bewaarActies(
    List<NotitieActieModel> acties,
  ) async {
    await AppStorage.bewaarNotitieActies(acties);
  }
}
