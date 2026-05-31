import '../../app_storage.dart';
import 'klantenfiche_model.dart';

class KlantenficheRepository {
  static Future<List<KlantenficheModel>> laadKlantenFiches() async {
    final lijst = await AppStorage.laadKlantenFiches();

    print('REPOSITORY LAADT AANTAL: ${lijst.length}');

    return lijst
        .map(
          (item) => KlantenficheModel.fromJson(item),
        )
        .toList();
  }

  static Future<void> bewaarKlantenFiche(
    KlantenficheModel fiche,
  ) async {
    print('KLANT BEWAARD: ${fiche.naam}');

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

    print('REPOSITORY BEWAART AANTAL: ${data.length}');
    print('REPOSITORY DATA: $data');

    await AppStorage.bewaarKlantenFiches(data);

    final controle = await AppStorage.laadKlantenFiches();

    print('NA OPSLAG IN APPSTORAGE: ${controle.length}');
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
