// THIMACO-CONTROLE: ALGEMENE-BIBLIOTHEEK-REPOSITORY-20260802

import '../app_storage.dart';
import 'bibliotheek_model.dart';

class BibliotheekRepository {
  const BibliotheekRepository._();

  static Future<BibliotheekData> laad() {
    return AppStorage.laadBibliotheek();
  }

  static Future<void> bewaar(BibliotheekData data) {
    return AppStorage.bewaarBibliotheek(data);
  }
}
