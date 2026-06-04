import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../fiche/klantenfiche_model.dart';

class KlantenficheFotoService {
  static final ImagePicker _picker = ImagePicker();

  static Future<File> fotoBestand({
    required String ficheId,
    required KlantenficheFoto foto,
  }) async {
    final appMap = await getApplicationDocumentsDirectory();

    return File(
      '${appMap.path}/klanten_fotos/$ficheId/${foto.bestandsNaam}',
    );
  }

  static Future<KlantenficheFoto?> neemFoto({
    required String ficheId,
  }) async {
    final gekozenFoto = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (gekozenFoto == null) return null;

    final appMap = await getApplicationDocumentsDirectory();

    final klantMap = Directory(
      '${appMap.path}/klanten_fotos/$ficheId',
    );

    if (!await klantMap.exists()) {
      await klantMap.create(
        recursive: true,
      );
    }

    final nu = DateTime.now();
    final fotoId = nu.millisecondsSinceEpoch.toString();
    final bestandsNaam = 'foto_$fotoId.jpg';
    final nieuwPad = '${klantMap.path}/$bestandsNaam';

    await File(gekozenFoto.path).copy(nieuwPad);

    final datum = '${nu.day.toString().padLeft(2, '0')}/'
        '${nu.month.toString().padLeft(2, '0')}/'
        '${nu.year}';

    return KlantenficheFoto(
      id: fotoId,
      bestandsNaam: bestandsNaam,
      datum: datum,
    );
  }

  static Future<void> verwijderFoto({
    required String ficheId,
    required KlantenficheFoto foto,
  }) async {
    final bestand = await fotoBestand(
      ficheId: ficheId,
      foto: foto,
    );

    if (await bestand.exists()) {
      await bestand.delete();
    }
  }
}
