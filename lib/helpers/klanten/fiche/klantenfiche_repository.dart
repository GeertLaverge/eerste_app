import '../../app_storage.dart';
import 'klantenfiche_model.dart';

class KlantenficheRepository {
  static Future<List<KlantenficheModel>> laadKlantenFiches() async {
    final lijst = await AppStorage.laadKlantenFiches();

    return lijst
        .map(
          (item) => KlantenficheModel.fromJson(item),
        )
        .toList();
  }

  static Future<void> bewaarKlantenFiche(
    KlantenficheModel fiche,
  ) async {
    final fiches = await laadKlantenFiches();

    final index = fiches.indexWhere(
      (f) => f.id == fiche.id,
    );

    if (index == -1) {
      fiches.add(fiche);
    } else {
      fiches[index] = fiche;
    }

    final data = fiches.map((f) => f.toJson()).toList();

    await AppStorage.bewaarKlantenFiches(data);
  }

  static Future<void> verwijderKlantenFiche(
    String id,
  ) async {
    final fiches = await laadKlantenFiches();

    fiches.removeWhere(
      (f) => f.id == id,
    );

    await AppStorage.bewaarKlantenFiches(
      fiches.map((f) => f.toJson()).toList(),
    );
  }
}
