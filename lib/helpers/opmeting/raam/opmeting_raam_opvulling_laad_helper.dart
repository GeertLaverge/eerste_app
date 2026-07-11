import '../../app_storage.dart';
import 'opmeting_raam_opvulling_model.dart';

class OpmetingRaamOpvullingLaadResultaat {
  const OpmetingRaamOpvullingLaadResultaat({
    required this.opvullingen,
    required this.geselecteerdeOpvullingId,
  });

  final List<OpmetingRaamOpvullingModel> opvullingen;
  final String? geselecteerdeOpvullingId;
}

class OpmetingRaamOpvullingLaadHelper {
  const OpmetingRaamOpvullingLaadHelper._();

  static Future<OpmetingRaamOpvullingLaadResultaat?> laad({
    required String? huidigeGeselecteerdeOpvullingId,
  }) async {
    try {
      final geladenOpvullingen = await AppStorage.laadOpmetingRaamOpvullingen();

      final huidigeKeuzeBestaat = geladenOpvullingen.any(
        (opvulling) => opvulling.id == huidigeGeselecteerdeOpvullingId,
      );

      final geselecteerdeOpvullingId = huidigeKeuzeBestaat
          ? huidigeGeselecteerdeOpvullingId
          : geladenOpvullingen.isEmpty
          ? null
          : geladenOpvullingen.first.id;

      return OpmetingRaamOpvullingLaadResultaat(
        opvullingen: List<OpmetingRaamOpvullingModel>.unmodifiable(
          geladenOpvullingen,
        ),
        geselecteerdeOpvullingId: geselecteerdeOpvullingId,
      );
    } catch (_) {
      return null;
    }
  }
}
