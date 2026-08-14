// THIMACO-CONTROLE: PRIJSARCHITECTUUR-STAP5D4B4A-TEST-NIET-TECHNISCHE-CATEGORIE-NAAR-PRIJS-PER-POSITIE-20260814
// THIMACO-CONTROLE: TEST-GEKOPPELDE-TECHNISCHE-PRIJZEN-FASE-5-20260727
import 'package:eerste_app/helpers/offerte/prijzen/offerte_prijs_categorie.dart';
import 'package:eerste_app/helpers/offerte/prijzen/offerte_prijs_eenheid.dart';
import 'package:eerste_app/helpers/offerte/prijzen/offerte_prijs_uitschrijfmodus.dart';
import 'package:eerste_app/helpers/offerte/prijzen/offerte_prijsprofiel_model.dart';
import 'package:eerste_app/helpers/offerte/prijzen/offerte_prijsregel_model.dart';
import 'package:eerste_app/helpers/offerte/prijzen/offerte_technische_keuze_ref.dart';
import 'package:eerste_app/helpers/offerte/prijzen/offerte_technische_prijs_koppeling_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OfferteTechnischePrijsKoppelingService', () {
    test('telt één gekoppelde regel per genormaliseerd artikeltype', () {
      final profielen = <OffertePrijsprofielModel>[
        _profiel(
          formulierType: 'pvcRaam',
          formulierNaam: 'PVC raam',
          regels: <OffertePrijsregelModel>[
            _technischeRegel(
              id: 'gedeeld-1',
              formulierType: 'pvcRaam',
              keuzeId: 'keuze-pvc-1',
            ),
          ],
        ),
        _profiel(
          formulierType: 'PVC-raam',
          formulierNaam: 'PVC raam duplicaat',
          regels: <OffertePrijsregelModel>[
            _technischeRegel(
              id: 'gedeeld-1',
              formulierType: 'PVC-raam',
              keuzeId: 'keuze-pvc-2',
            ),
          ],
        ),
        _profiel(
          formulierType: 'aluRaam',
          formulierNaam: 'ALU raam',
          regels: <OffertePrijsregelModel>[
            _technischeRegel(
              id: 'gedeeld-1',
              formulierType: 'aluRaam',
              keuzeId: 'keuze-alu-1',
            ),
          ],
        ),
      ];

      final aantallen =
          OfferteTechnischePrijsKoppelingService.berekenKoppelAantallen(
            profielen,
          );

      expect(aantallen, <String, int>{'gedeeld-1': 2});
      expect(() => aantallen['nieuw'] = 1, throwsUnsupportedError);
    });

    test('negeert niet-technische en lege technische regels', () {
      final profiel = _profiel(
        formulierType: 'pvcRaam',
        formulierNaam: 'PVC raam',
        regels: <OffertePrijsregelModel>[
          _technischeRegel(
            id: 'geldig',
            formulierType: 'pvcRaam',
            keuzeId: 'keuze-geldig',
          ),
          _technischeRegel(
            id: 'lege-keuze',
            formulierType: 'pvcRaam',
            keuzeId: '',
            technischeKeuze: const OfferteTechnischeKeuzeRef(),
          ),
          _regel(
            id: 'vrije-regel',
            categorie: OffertePrijsCategorie.prijsPerPositie,
            formulierType: 'pvcRaam',
            technischeKeuze: _keuze(
              formulierType: 'pvcRaam',
              keuzeId: 'wordt-genegeerd',
            ),
          ),
        ],
      );

      final aantallen =
          OfferteTechnischePrijsKoppelingService.berekenKoppelAantallen(
            <OffertePrijsprofielModel>[profiel],
          );

      expect(aantallen, <String, int>{'geldig': 1});
    });

    test('synchroniseert alleen gedeelde prijsvelden', () {
      const bronDatum = '2026-07-27T08:30:00.000Z';
      final lokaleKeuze = _keuze(
        formulierType: 'aluRaam',
        menuId: 'plaatsing-alu',
        submenuId: 'aansluiting-alu',
        keuzeId: 'opspuiten-alu',
        keuzeTitel: 'Lokale ALU-keuze',
      );
      final lokaleRegel = _regel(
        id: 'gedeeld-2',
        categorie: OffertePrijsCategorie.technischeKeuzePerArtikel,
        formulierType: 'aluRaam',
        omschrijving: 'Lokale ALU-omschrijving',
        prijsExclBtw: 5.25,
        eenheid: OffertePrijsEenheid.vast,
        uitschrijfmodus: OffertePrijsUitschrijfmodus.overzichtEnOfferteMetPrijs,
        technischeKeuze: lokaleKeuze,
        actief: true,
        volgorde: 30,
        gewijzigdOp: '2026-07-20T07:00:00.000Z',
      );
      final onaangeroerdeRegel = _technischeRegel(
        id: 'alleen-lokaal',
        formulierType: 'aluRaam',
        keuzeId: 'alleen-lokaal',
        prijsExclBtw: 3.50,
      );
      final doelProfiel = OffertePrijsprofielModel(
        formulierType: 'aluRaam',
        formulierNaam: 'ALU raam',
        prijsregels: <OffertePrijsregelModel>[lokaleRegel, onaangeroerdeRegel],
        standaardPrijsPerStukExclBtw: 125,
        standaardWinstmargePercentage: 20,
        standaardKortingPercentage: 5,
        gewijzigdOp: '2026-07-20T07:00:00.000Z',
      );
      final bronRegel = _regel(
        id: 'gedeeld-2',
        categorie: OffertePrijsCategorie.technischeKeuzePerArtikel,
        formulierType: 'pvcRaam',
        omschrijving: 'Bronomschrijving PVC',
        prijsExclBtw: 19.75,
        eenheid: OffertePrijsEenheid.oppervlakte,
        uitschrijfmodus: OffertePrijsUitschrijfmodus.alleenOverzicht,
        technischeKeuze: _keuze(
          formulierType: 'pvcRaam',
          menuId: 'plaatsing-pvc',
          submenuId: 'aansluiting-pvc',
          keuzeId: 'opspuiten-pvc',
          keuzeTitel: 'Bronkeuze PVC',
        ),
        actief: false,
        volgorde: 90,
        gewijzigdOp: bronDatum,
      );

      final resultaat =
          OfferteTechnischePrijsKoppelingService.synchroniseerProfielMetBronnen(
            profiel: doelProfiel,
            bronPerId: <String, OffertePrijsregelModel>{
              bronRegel.id: bronRegel,
            },
          );
      final bijgewerkt = _regelMetId(resultaat, 'gedeeld-2');
      final onaangeroerd = _regelMetId(resultaat, 'alleen-lokaal');

      expect(identical(resultaat, doelProfiel), isFalse);
      expect(bijgewerkt.prijsExclBtw, 19.75);
      expect(bijgewerkt.eenheid, OffertePrijsEenheid.oppervlakte);
      expect(
        bijgewerkt.uitschrijfmodus,
        OffertePrijsUitschrijfmodus.alleenOverzicht,
      );
      expect(bijgewerkt.actief, isFalse);
      expect(bijgewerkt.gewijzigdOp, bronDatum);

      expect(bijgewerkt.formulierType, 'aluRaam');
      expect(bijgewerkt.omschrijving, 'Lokale ALU-omschrijving');
      expect(bijgewerkt.technischeKeuze, same(lokaleKeuze));
      expect(bijgewerkt.volgorde, 30);

      expect(onaangeroerd, same(onaangeroerdeRegel));
      expect(resultaat.standaardPrijsPerStukExclBtw, 125);
      expect(resultaat.standaardWinstmargePercentage, 20);
      expect(resultaat.standaardKortingPercentage, 5);
      expect(resultaat.gewijzigdOp, bronDatum);
    });

    test('ongeldige of niet-passende bron laat profiel exact ongewijzigd', () {
      final doelProfiel = _profiel(
        formulierType: 'aluRaam',
        formulierNaam: 'ALU raam',
        regels: <OffertePrijsregelModel>[
          _technischeRegel(
            id: 'gedeeld-3',
            formulierType: 'aluRaam',
            keuzeId: 'doel-keuze',
          ),
        ],
      );
      final ongeldigeBron = _regel(
        id: 'gedeeld-3',
        categorie: OffertePrijsCategorie.prijsPerPositie,
        formulierType: 'pvcRaam',
        technischeKeuze: _keuze(
          formulierType: 'pvcRaam',
          keuzeId: 'bron-keuze',
        ),
      );

      final resultaat =
          OfferteTechnischePrijsKoppelingService.synchroniseerProfielMetBronnen(
            profiel: doelProfiel,
            bronPerId: <String, OffertePrijsregelModel>{
              ongeldigeBron.id: ongeldigeBron,
            },
          );

      expect(resultaat, same(doelProfiel));
    });

    test(
      'profielwijzigingsdatum gebruikt alleen werkelijk gekoppelde bronnen',
      () {
        const gebruikteDatum = '2026-07-27T09:00:00.000Z';
        const nietGebruikteNieuwereDatum = '2026-07-27T12:00:00.000Z';
        final doelProfiel = _profiel(
          formulierType: 'aluRaam',
          formulierNaam: 'ALU raam',
          regels: <OffertePrijsregelModel>[
            _technischeRegel(
              id: 'gekoppeld',
              formulierType: 'aluRaam',
              keuzeId: 'doel-keuze',
            ),
          ],
        );
        final gebruikteBron = _technischeRegel(
          id: 'gekoppeld',
          formulierType: 'pvcRaam',
          keuzeId: 'bron-keuze',
          gewijzigdOp: gebruikteDatum,
        );
        final nietGebruikteBron = _technischeRegel(
          id: 'andere-id',
          formulierType: 'pvcDeur',
          keuzeId: 'andere-keuze',
          gewijzigdOp: nietGebruikteNieuwereDatum,
        );

        final resultaat =
            OfferteTechnischePrijsKoppelingService.synchroniseerProfielMetBronnen(
              profiel: doelProfiel,
              bronPerId: <String, OffertePrijsregelModel>{
                gebruikteBron.id: gebruikteBron,
                nietGebruikteBron.id: nietGebruikteBron,
              },
            );

        expect(resultaat.gewijzigdOp, gebruikteDatum);
      },
    );
  });
}

OffertePrijsprofielModel _profiel({
  required String formulierType,
  required String formulierNaam,
  required List<OffertePrijsregelModel> regels,
}) {
  return OffertePrijsprofielModel(
    formulierType: formulierType,
    formulierNaam: formulierNaam,
    prijsregels: regels,
    gewijzigdOp: '2026-07-01T00:00:00.000Z',
  );
}

OffertePrijsregelModel _technischeRegel({
  required String id,
  required String formulierType,
  required String keuzeId,
  double prijsExclBtw = 10,
  String gewijzigdOp = '2026-07-27T08:00:00.000Z',
  OfferteTechnischeKeuzeRef? technischeKeuze,
}) {
  return _regel(
    id: id,
    categorie: OffertePrijsCategorie.technischeKeuzePerArtikel,
    formulierType: formulierType,
    prijsExclBtw: prijsExclBtw,
    technischeKeuze:
        technischeKeuze ??
        _keuze(formulierType: formulierType, keuzeId: keuzeId),
    gewijzigdOp: gewijzigdOp,
  );
}

OffertePrijsregelModel _regel({
  required String id,
  required OffertePrijsCategorie categorie,
  required String formulierType,
  String omschrijving = 'Testprijsregel',
  double prijsExclBtw = 10,
  OffertePrijsEenheid eenheid = OffertePrijsEenheid.vast,
  OffertePrijsUitschrijfmodus uitschrijfmodus =
      OffertePrijsUitschrijfmodus.overzichtEnOfferteMetPrijs,
  OfferteTechnischeKeuzeRef? technischeKeuze,
  bool actief = true,
  int volgorde = 0,
  String gewijzigdOp = '2026-07-27T08:00:00.000Z',
}) {
  return OffertePrijsregelModel(
    id: id,
    categorie: categorie,
    formulierType: formulierType,
    omschrijving: omschrijving,
    prijsExclBtw: prijsExclBtw,
    eenheid: eenheid,
    uitschrijfmodus: uitschrijfmodus,
    technischeKeuze: technischeKeuze,
    actief: actief,
    volgorde: volgorde,
    gewijzigdOp: gewijzigdOp,
  );
}

OfferteTechnischeKeuzeRef _keuze({
  required String formulierType,
  String menuId = 'menu',
  String submenuId = 'submenu',
  required String keuzeId,
  String keuzeTitel = 'Technische keuze',
}) {
  return OfferteTechnischeKeuzeRef(
    formulierType: formulierType,
    menuId: menuId,
    submenuId: submenuId,
    keuzeId: keuzeId,
    menuTitelMomentopname: 'Menu',
    submenuTitelMomentopname: 'Submenu',
    keuzeTitelMomentopname: keuzeTitel,
  );
}

OffertePrijsregelModel _regelMetId(
  OffertePrijsprofielModel profiel,
  String id,
) {
  return profiel.prijsregels.singleWhere((regel) => regel.id == id);
}
