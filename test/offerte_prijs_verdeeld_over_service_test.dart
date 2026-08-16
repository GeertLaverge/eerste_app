// THIMACO-CONTROLE: PRIJS-VERDEELD-OVER-SERVICE-TESTS-20260815
import 'package:eerste_app/helpers/offerte/prijzen/offerte_artikel_prijs_data_model.dart';
import 'package:eerste_app/helpers/offerte/prijzen/offerte_prijs_verdeeld_over_service.dart';
import 'package:eerste_app/helpers/offerte/prijzen/offerte_prijs_verdeeld_over_template_model.dart';
import 'package:eerste_app/helpers/offerte/prijzen/offerte_prijs_voor_alle_posities_regel_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OffertePrijsVerdeeldOverService', () {
    test('verdeelt 100 euro over drie posities zonder centverlies', () {
      final delen = OffertePrijsVerdeeldOverService.verdeelBedragExclBtw(
        totaalExclBtw: 100.0,
        aantalPosities: 3,
      );

      expect(delen, <double>[33.34, 33.33, 33.33]);
      expect(_som(delen), 100.0);
    });

    test('ongeldige verdeling levert geen delen op', () {
      expect(
        OffertePrijsVerdeeldOverService.verdeelBedragExclBtw(
          totaalExclBtw: 0.0,
          aantalPosities: 3,
        ),
        isEmpty,
      );
      expect(
        OffertePrijsVerdeeldOverService.verdeelBedragExclBtw(
          totaalExclBtw: 100.0,
          aantalPosities: 0,
        ),
        isEmpty,
      );
    });

    test(
      'verkoopregel wordt één keer per unieke gekozen positie opgeslagen',
      () {
        final bestaand = _gewoneProjectRegel(id: 'bestaand');
        final resultaat = OffertePrijsVerdeeldOverService.pasToe(
          bestaandeRegels: <OffertePrijsVoorAllePositiesRegelModel>[bestaand],
          template: _template(
            id: 'transport',
            omschrijving: 'Transportkosten',
            type: OffertePrijsPerPositieType.verkoop,
          ),
          totaalExclBtw: 150.0,
          geselecteerdePositieIds: const <String>[
            'pos-1',
            'pos-2',
            'pos-3',
            'pos-2',
          ],
        );

        expect(resultaat, hasLength(4));
        expect(
          resultaat.where((regel) => regel.id == bestaand.id),
          hasLength(1),
        );

        final verdeeldeRegels = resultaat
            .where(OffertePrijsVerdeeldOverService.isVerdeeldOverRegel)
            .toList(growable: false);
        expect(verdeeldeRegels, hasLength(3));
        expect(
          verdeeldeRegels
              .expand((regel) => regel.geselecteerdePositieIds)
              .toSet(),
          <String>{'pos-1', 'pos-2', 'pos-3'},
        );
        expect(
          _som(
            verdeeldeRegels.map((regel) => regel.prijsregel.basisTotaalExclBtw),
          ),
          150.0,
        );
        expect(
          _som(
            verdeeldeRegels.map((regel) => regel.prijsregel.eindTotaalExclBtw),
          ),
          150.0,
        );

        final groepen = OffertePrijsVerdeeldOverService.leesGroepen(resultaat);
        expect(groepen, hasLength(1));
        expect(groepen.single.omschrijving, 'Transportkosten');
        expect(groepen.single.invoerTotaalExclBtw, 150.0);
        expect(groepen.single.verkoopTotaalExclBtw, 150.0);
        expect(groepen.single.positieIds.toSet(), <String>{
          'pos-1',
          'pos-2',
          'pos-3',
        });
      },
    );

    test(
      'aankoopregel behoudt aankoopbedrag en past winst per deelregel toe',
      () {
        final template = _template(
          id: 'leverancier',
          omschrijving: 'Leverancierskost',
          type: OffertePrijsPerPositieType.aankoop,
          winstPercentage: 20.0,
        );

        final resultaat = OffertePrijsVerdeeldOverService.pasToe(
          bestaandeRegels: const <OffertePrijsVoorAllePositiesRegelModel>[],
          template: template,
          totaalExclBtw: 100.0,
          geselecteerdePositieIds: const <String>['pos-1', 'pos-2', 'pos-3'],
        );

        final groepen = OffertePrijsVerdeeldOverService.leesGroepen(resultaat);
        expect(groepen, hasLength(1));
        expect(groepen.single.invoerTotaalExclBtw, 100.0);
        expect(groepen.single.winstPercentage, 20.0);
        expect(
          groepen.single.verkoopTotaalExclBtw,
          OffertePrijsVerdeeldOverService.berekenVerkoopTotaalExclBtw(
            template: template,
            invoerTotaalExclBtw: 100.0,
            aantalPosities: 3,
          ),
        );
        expect(groepen.single.verkoopTotaalExclBtw, 120.01);
      },
    );

    test('bewerken vervangt alleen de gekozen verdeelgroep', () {
      final bestaand = _gewoneProjectRegel(id: 'bestaand');
      final template = _template(
        id: 'transport',
        omschrijving: 'Transportkosten',
        type: OffertePrijsPerPositieType.verkoop,
      );

      final eerste = OffertePrijsVerdeeldOverService.pasToe(
        bestaandeRegels: <OffertePrijsVoorAllePositiesRegelModel>[bestaand],
        template: template,
        totaalExclBtw: 80.0,
        geselecteerdePositieIds: const <String>['pos-1', 'pos-2'],
      );
      final eersteGroep = OffertePrijsVerdeeldOverService.leesGroepen(
        eerste,
      ).single;

      final bewerkt = OffertePrijsVerdeeldOverService.pasToe(
        bestaandeRegels: eerste,
        template: template,
        totaalExclBtw: 90.0,
        geselecteerdePositieIds: const <String>['pos-2', 'pos-3'],
        bestaandeGroepId: eersteGroep.groepId,
      );

      expect(bewerkt.where((regel) => regel.id == bestaand.id), hasLength(1));
      final groepen = OffertePrijsVerdeeldOverService.leesGroepen(bewerkt);
      expect(groepen, hasLength(1));
      expect(groepen.single.groepId, eersteGroep.groepId);
      expect(groepen.single.invoerTotaalExclBtw, 90.0);
      expect(groepen.single.positieIds.toSet(), <String>{'pos-2', 'pos-3'});
    });

    test(
      'verwijderen wist alleen de verdeelgroep en bewaart gewone projectregels',
      () {
        final bestaand = _gewoneProjectRegel(id: 'bestaand');
        final metVerdeling = OffertePrijsVerdeeldOverService.pasToe(
          bestaandeRegels: <OffertePrijsVoorAllePositiesRegelModel>[bestaand],
          template: _template(
            id: 'transport',
            omschrijving: 'Transportkosten',
            type: OffertePrijsPerPositieType.verkoop,
          ),
          totaalExclBtw: 60.0,
          geselecteerdePositieIds: const <String>['pos-1', 'pos-2'],
        );
        final groep = OffertePrijsVerdeeldOverService.leesGroepen(
          metVerdeling,
        ).single;

        final zonderVerdeling = OffertePrijsVerdeeldOverService.verwijderGroep(
          bestaandeRegels: metVerdeling,
          groepId: groep.groepId,
        );

        expect(zonderVerdeling, hasLength(1));
        expect(zonderVerdeling.single.id, bestaand.id);
        expect(
          OffertePrijsVerdeeldOverService.isVerdeeldOverRegel(
            zonderVerdeling.single,
          ),
          isFalse,
        );
        expect(
          OffertePrijsVerdeeldOverService.leesGroepen(zonderVerdeling),
          isEmpty,
        );
      },
    );
  });
}

OffertePrijsVerdeeldOverTemplateModel _template({
  required String id,
  required String omschrijving,
  required OffertePrijsPerPositieType type,
  double winstPercentage = 0.0,
}) {
  return OffertePrijsVerdeeldOverTemplateModel(
    id: id,
    omschrijving: omschrijving,
    type: type,
    standaardWinstPercentage: winstPercentage,
    offerteWeergave: OffertePrijsPerPositieWeergave.uit,
  );
}

OffertePrijsVoorAllePositiesRegelModel _gewoneProjectRegel({
  required String id,
}) {
  return OffertePrijsVoorAllePositiesRegelModel(
    prijsregel: OffertePrijsPerPositieRegelModel(
      id: id,
      omschrijving: 'Bestaande regel',
      type: OffertePrijsPerPositieType.verkoop,
      aantal: 1,
      eenheid: 'st',
      eenheidsPrijsExclBtw: 25.0,
      offerteWeergave: OffertePrijsPerPositieWeergave.uit,
    ),
    geselecteerdePositieIds: const <String>{'pos-1'},
    volgorde: 1,
  );
}

double _som(Iterable<double> waarden) {
  final totaal = waarden.fold<double>(0.0, (som, waarde) => som + waarde);
  return (totaal * 100.0).roundToDouble() / 100.0;
}
