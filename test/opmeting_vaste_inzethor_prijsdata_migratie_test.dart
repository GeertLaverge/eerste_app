import 'package:flutter_test/flutter_test.dart';
import 'package:eerste_app/helpers/opmeting/toebehoren/vaste_inzethor/opmeting_vaste_inzethor_model.dart';

void main() {
  group('Vaste inzethor prijsData schema 2', () {
    test('oud dossier met alleen losse prijsvelden blijft leesbaar', () {
      final model = OpmetingVasteInzethorModel.fromJson(<String, dynamic>{
        'stukReferentie': 'OUD-001',
        'aantal': 2,
        'breedteMm': 850,
        'hoogteMm': 1200,
        'prijsPerStukExclBtw': 125.50,
        'toegepasteTechnischePrijsregels': <dynamic>[],
        'technischePrijsSignatuur': 'technisch-oud',
        'toegepasteVerdeeldePrijsregels': <dynamic>[],
        'verdeeldePrijsSignatuur': 'verdeeld-oud',
        'vrijeArtikelPrijsSelecties': <dynamic>[],
        'vrijeArtikelPrijsSignatuur': 'vrij-oud',
        'artikelKortingPercentage': 7.5,
        'artikelWinstmargePercentage': 22.0,
      });

      expect(model.stukReferentie, 'OUD-001');
      expect(model.aantal, 2);
      expect(model.breedteMm, 850);
      expect(model.hoogteMm, 1200);

      expect(model.prijsData.prijsPerStukExclBtw, 125.50);
      expect(model.prijsData.technischePrijsSignatuur, 'technisch-oud');
      expect(model.prijsData.verdeeldePrijsSignatuur, 'verdeeld-oud');
      expect(model.prijsData.vrijeArtikelPrijsSignatuur, 'vrij-oud');
      expect(model.prijsData.artikelKortingPercentage, 7.5);
      expect(model.prijsData.artikelWinstmargePercentage, 22.0);
    });

    test('oud prijsPerStuk-alias blijft leesbaar', () {
      final model = OpmetingVasteInzethorModel.fromJson(<String, dynamic>{
        'prijsPerStuk': 91.25,
      });

      expect(model.prijsData.prijsPerStukExclBtw, 91.25);
    });

    test('nieuw dossier met alleen geneste prijsData wordt gelezen', () {
      final model = OpmetingVasteInzethorModel.fromJson(<String, dynamic>{
        'stukReferentie': 'NIEUW-001',
        'prijsDataSchemaVersie': 2,
        'prijsData': <String, dynamic>{
          'prijsPerStukExclBtw': 199.95,
          'toegepasteTechnischePrijsregels': <dynamic>[],
          'technischePrijsSignatuur': 'genest-technisch',
          'toegepasteVerdeeldePrijsregels': <dynamic>[],
          'verdeeldePrijsSignatuur': 'genest-verdeeld',
          'vrijeArtikelPrijsSelecties': <dynamic>[],
          'vrijeArtikelPrijsSignatuur': 'genest-vrij',
          'artikelKortingPercentage': 8.5,
          'artikelWinstmargePercentage': 31.0,
        },
      });

      expect(model.prijsData.prijsPerStukExclBtw, 199.95);
      expect(model.prijsData.technischePrijsSignatuur, 'genest-technisch');
      expect(model.prijsData.verdeeldePrijsSignatuur, 'genest-verdeeld');
      expect(model.prijsData.vrijeArtikelPrijsSignatuur, 'genest-vrij');
      expect(model.prijsData.artikelKortingPercentage, 8.5);
      expect(model.prijsData.artikelWinstmargePercentage, 31.0);
    });

    test('geneste waarden winnen en ontbrekende waarden vallen terug', () {
      final model = OpmetingVasteInzethorModel.fromJson(<String, dynamic>{
        'prijsPerStukExclBtw': 88.25,
        'technischePrijsSignatuur': 'fallback-technisch',
        'verdeeldePrijsSignatuur': 'fallback-verdeeld',
        'vrijeArtikelPrijsSignatuur': 'fallback-vrij',
        'artikelKortingPercentage': 4.0,
        'artikelWinstmargePercentage': 19.0,
        'prijsData': <String, dynamic>{
          'technischePrijsSignatuur': 'genest-technisch',
        },
      });

      expect(model.prijsData.prijsPerStukExclBtw, 88.25);
      expect(model.prijsData.technischePrijsSignatuur, 'genest-technisch');
      expect(model.prijsData.verdeeldePrijsSignatuur, 'fallback-verdeeld');
      expect(model.prijsData.vrijeArtikelPrijsSignatuur, 'fallback-vrij');
      expect(model.prijsData.artikelKortingPercentage, 4.0);
      expect(model.prijsData.artikelWinstmargePercentage, 19.0);
    });

    test('copyWithPrijsData houdt compatibele getters gelijk', () {
      final basis = OpmetingVasteInzethorModel(
        stukReferentie: 'COPY-001',
        aantal: 3,
      );

      final bijgewerkt = basis.copyWithPrijsData(
        basis.prijsData.copyWith(
          prijsPerStukExclBtw: 145.75,
          technischePrijsSignatuur: 'copy-technisch',
          verdeeldePrijsSignatuur: 'copy-verdeeld',
          vrijeArtikelPrijsSignatuur: 'copy-vrij',
          artikelKortingPercentage: 6.0,
          artikelWinstmargePercentage: 27.5,
        ),
      );

      expect(bijgewerkt.prijsData.prijsPerStukExclBtw, 145.75);
      expect(bijgewerkt.prijsPerStukExclBtw, 145.75);

      expect(
        bijgewerkt.prijsData.technischePrijsSignatuur,
        bijgewerkt.technischePrijsSignatuur,
      );
      expect(
        bijgewerkt.prijsData.verdeeldePrijsSignatuur,
        bijgewerkt.verdeeldePrijsSignatuur,
      );
      expect(
        bijgewerkt.prijsData.vrijeArtikelPrijsSignatuur,
        bijgewerkt.vrijeArtikelPrijsSignatuur,
      );
      expect(
        bijgewerkt.prijsData.artikelKortingPercentage,
        bijgewerkt.artikelKortingPercentage,
      );
      expect(
        bijgewerkt.prijsData.artikelWinstmargePercentage,
        bijgewerkt.artikelWinstmargePercentage,
      );
    });

    test('copyWith vervangt prijsgegevens als één prijsData-object', () {
      final basis = OpmetingVasteInzethorModel(
        stukReferentie: 'COPY-PRIJS-001',
      );

      final nieuwePrijsData = basis.prijsData.copyWith(
        prijsPerStukExclBtw: 175.25,
        technischePrijsSignatuur: 'copy-prijsdata-technisch',
        artikelKortingPercentage: 5.5,
      );

      final bijgewerkt = basis.copyWith(prijsData: nieuwePrijsData);

      expect(bijgewerkt.stukReferentie, basis.stukReferentie);
      expect(bijgewerkt.prijsData, same(nieuwePrijsData));
      expect(bijgewerkt.prijsPerStukExclBtw, 175.25);
      expect(bijgewerkt.technischePrijsSignatuur, 'copy-prijsdata-technisch');
      expect(bijgewerkt.artikelKortingPercentage, 5.5);
    });

    test('toJson schrijft schema 2 en alleen geneste prijsData', () {
      final basis = OpmetingVasteInzethorModel(
        stukReferentie: 'JSON-001',
        aantal: 4,
      );

      final model = basis.copyWithPrijsData(
        basis.prijsData.copyWith(
          prijsPerStukExclBtw: 210.40,
          technischePrijsSignatuur: 'json-technisch',
          verdeeldePrijsSignatuur: 'json-verdeeld',
          vrijeArtikelPrijsSignatuur: 'json-vrij',
          artikelKortingPercentage: 9.0,
          artikelWinstmargePercentage: 33.0,
        ),
      );

      final json = model.toJson();

      expect(json['prijsDataSchemaVersie'], 2);
      expect(json.containsKey('prijsData'), isTrue);

      final genest = Map<String, dynamic>.from(json['prijsData'] as Map);

      expect(genest['prijsPerStukExclBtw'], 210.40);
      expect(genest['technischePrijsSignatuur'], 'json-technisch');
      expect(genest['verdeeldePrijsSignatuur'], 'json-verdeeld');
      expect(genest['vrijeArtikelPrijsSignatuur'], 'json-vrij');
      expect(genest['artikelKortingPercentage'], 9.0);
      expect(genest['artikelWinstmargePercentage'], 33.0);

      const oudeSleutels = <String>[
        'prijsPerStukExclBtw',
        'toegepasteTechnischePrijsregels',
        'technischePrijsSignatuur',
        'toegepasteVerdeeldePrijsregels',
        'verdeeldePrijsSignatuur',
        'vrijeArtikelPrijsSelecties',
        'vrijeArtikelPrijsSignatuur',
        'artikelKortingPercentage',
        'artikelWinstmargePercentage',
      ];

      for (final sleutel in oudeSleutels) {
        expect(
          json.containsKey(sleutel),
          isFalse,
          reason: 'Oude losse sleutel staat nog in toJson: $sleutel',
        );
      }
    });

    test('schema 2 rondreis behoudt alle prijswaarden', () {
      final basis = OpmetingVasteInzethorModel(
        stukReferentie: 'RONDREIS-001',
        aantal: 5,
        breedteMm: 975,
        hoogteMm: 1625,
      );

      final origineel = basis.copyWithPrijsData(
        basis.prijsData.copyWith(
          prijsPerStukExclBtw: 305.65,
          technischePrijsSignatuur: 'rondreis-technisch',
          verdeeldePrijsSignatuur: 'rondreis-verdeeld',
          vrijeArtikelPrijsSignatuur: 'rondreis-vrij',
          artikelKortingPercentage: 11.25,
          artikelWinstmargePercentage: 38.75,
        ),
      );

      final json = origineel.toJson();

      expect(json['prijsDataSchemaVersie'], 2);
      expect(json.containsKey('prijsPerStukExclBtw'), isFalse);

      final opnieuwGeopend = OpmetingVasteInzethorModel.fromJson(json);

      expect(opnieuwGeopend.stukReferentie, origineel.stukReferentie);
      expect(opnieuwGeopend.aantal, origineel.aantal);
      expect(opnieuwGeopend.breedteMm, origineel.breedteMm);
      expect(opnieuwGeopend.hoogteMm, origineel.hoogteMm);

      expect(
        opnieuwGeopend.prijsData.prijsPerStukExclBtw,
        origineel.prijsData.prijsPerStukExclBtw,
      );
      expect(
        opnieuwGeopend.prijsData.technischePrijsSignatuur,
        origineel.prijsData.technischePrijsSignatuur,
      );
      expect(
        opnieuwGeopend.prijsData.verdeeldePrijsSignatuur,
        origineel.prijsData.verdeeldePrijsSignatuur,
      );
      expect(
        opnieuwGeopend.prijsData.vrijeArtikelPrijsSignatuur,
        origineel.prijsData.vrijeArtikelPrijsSignatuur,
      );
      expect(
        opnieuwGeopend.prijsData.artikelKortingPercentage,
        origineel.prijsData.artikelKortingPercentage,
      );
      expect(
        opnieuwGeopend.prijsData.artikelWinstmargePercentage,
        origineel.prijsData.artikelWinstmargePercentage,
      );
    });
  });
}
