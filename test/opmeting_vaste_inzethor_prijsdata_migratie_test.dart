// THIMACO-CONTROLE: PRIJSARCHITECTUUR-OPRUIMEN-STAP3-PRIJSData-TEST-20260814
import 'package:flutter_test/flutter_test.dart';
import 'package:eerste_app/helpers/opmeting/toebehoren/vaste_inzethor/opmeting_vaste_inzethor_model.dart';

void main() {
  group('Vaste inzethor actieve prijsData', () {
    test('actieve prijsvelden worden genest gelezen en geschreven', () {
      final model = OpmetingVasteInzethorModel.fromJson(<String, dynamic>{
        'stukReferentie': 'TEST-001',
        'prijsData': <String, dynamic>{
          'prijsPerStukExclBtw': 199.95,
          'toegepasteTechnischePrijsregels': <dynamic>[],
          'technischePrijsSignatuur': 'technisch',
          'prijsPerPositieRegels': <dynamic>[],
          'artikelKortingPercentage': 8.5,
          'artikelWinstmargePercentage': 31.0,
        },
      });

      expect(model.prijsData.prijsPerStukExclBtw, 199.95);
      expect(model.prijsData.technischePrijsSignatuur, 'technisch');
      expect(model.prijsData.artikelKortingPercentage, 8.5);
      expect(model.prijsData.artikelWinstmargePercentage, 31.0);

      final json = model.toJson();
      final prijsData = Map<String, dynamic>.from(json['prijsData'] as Map);
      expect(prijsData['prijsPerStukExclBtw'], 199.95);
      expect(prijsData['technischePrijsSignatuur'], 'technisch');
      expect(prijsData.containsKey('vrijeArtikelPrijsSelecties'), isFalse);
      expect(prijsData.containsKey('vrijeArtikelPrijsSignatuur'), isFalse);
      expect(prijsData.containsKey('toegepasteVerdeeldePrijsregels'), isFalse);
      expect(prijsData.containsKey('verdeeldePrijsSignatuur'), isFalse);
    });

    test('verwijderde legacy prijsvelden worden genegeerd', () {
      final model = OpmetingVasteInzethorModel.fromJson(<String, dynamic>{
        'prijsData': <String, dynamic>{
          'prijsPerStukExclBtw': 100.0,
          'vrijeArtikelPrijsSelecties': <dynamic>[
            <String, dynamic>{'id': 'oud'},
          ],
          'vrijeArtikelPrijsSignatuur': 'oud-vrij',
          'toegepasteVerdeeldePrijsregels': <dynamic>[],
          'verdeeldePrijsSignatuur': 'oud-verdeeld',
        },
      });

      expect(model.prijsData.prijsPerStukExclBtw, 100.0);
      final prijsData = model.prijsData.toJson();
      expect(prijsData.containsKey('vrijeArtikelPrijsSelecties'), isFalse);
      expect(prijsData.containsKey('vrijeArtikelPrijsSignatuur'), isFalse);
      expect(prijsData.containsKey('toegepasteVerdeeldePrijsregels'), isFalse);
      expect(prijsData.containsKey('verdeeldePrijsSignatuur'), isFalse);
    });
  });
}
