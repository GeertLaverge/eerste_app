import 'dart:convert';

import 'offerte_prijsprofiel_model.dart';

class OffertePrijsOpslagCodec {
  const OffertePrijsOpslagCodec._();

  static String encode(List<OffertePrijsprofielModel> profielen) {
    return jsonEncode(
      profielen.map((profiel) => profiel.toJson()).toList(growable: false),
    );
  }

  static List<OffertePrijsprofielModel> decode(String? jsonString) {
    if (jsonString == null || jsonString.trim().isEmpty) {
      return <OffertePrijsprofielModel>[];
    }

    try {
      final decoded = jsonDecode(jsonString);
      final ruweProfielen = decoded is List
          ? decoded
          : decoded is Map && decoded['profielen'] is List
          ? decoded['profielen'] as List
          : const <dynamic>[];

      final perFormulierType = <String, OffertePrijsprofielModel>{};

      for (final item in ruweProfielen.whereType<Map>()) {
        try {
          final profiel = OffertePrijsprofielModel.fromJson(
            Map<String, dynamic>.from(item),
          );
          final sleutel = profiel.formulierType.trim().toLowerCase();

          if (sleutel.isEmpty) {
            continue;
          }

          perFormulierType[sleutel] = profiel;
        } catch (_) {
          // Een ongeldig profiel wordt overgeslagen; geldige profielen blijven.
        }
      }

      final resultaat = perFormulierType.values.toList();
      resultaat.sort((eerste, tweede) {
        return eerste.formulierNaam.toLowerCase().compareTo(
          tweede.formulierNaam.toLowerCase(),
        );
      });

      return resultaat;
    } catch (_) {
      return <OffertePrijsprofielModel>[];
    }
  }
}
