// THIMACO-CONTROLE: TECHNISCHE-PRIJSBOOM-REGRESSIE-FASE-7-20260727
import 'package:eerste_app/helpers/offerte/prijzen/offerte_prijs_categorie.dart';
import 'package:eerste_app/helpers/offerte/prijzen/offerte_prijs_eenheid.dart';
import 'package:eerste_app/helpers/offerte/prijzen/offerte_prijs_uitschrijfmodus.dart';
import 'package:eerste_app/helpers/offerte/prijzen/offerte_prijsregel_model.dart';
import 'package:eerste_app/helpers/offerte/prijzen/offerte_technische_keuze_ref.dart';
import 'package:eerste_app/paginas/instellingen/offerte_prijzen/offerte_technische_prijs_overnemen_dialog.dart';
import 'package:eerste_app/paginas/instellingen/offerte_prijzen/offerte_technische_prijskeuze_boom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const exacteDoelKeuze = OfferteTechnischeKeuzeRef(
    formulierType: 'pvcRaam',
    menuId: 'menu-rolluik-pvc',
    submenuId: 'submenu-bediening',
    keuzeId: 'keuze-elektrisch',
    menuTitelMomentopname: 'Rolluik',
    submenuTitelMomentopname: 'Bediening',
    keuzeTitelMomentopname: 'Elektrisch',
    hoeUitschrijvenMomentopname: 'Elektrische bediening',
  );

  const tekstDoelKeuze = OfferteTechnischeKeuzeRef(
    formulierType: 'pvcRaam',
    menuId: 'menu-rolluik-pvc',
    submenuId: 'submenu-bediening',
    keuzeId: 'keuze-somfy-pvc',
    menuTitelMomentopname: 'Rolluik',
    submenuTitelMomentopname: 'Bediening',
    keuzeTitelMomentopname: 'Somfy',
    hoeUitschrijvenMomentopname: 'Somfy bediening',
  );

  const exacteBronKeuze = OfferteTechnischeKeuzeRef(
    formulierType: 'aluRaam',
    menuId: 'menu-rolluik-alu',
    submenuId: 'submenu-bediening',
    keuzeId: 'keuze-elektrisch',
    menuTitelMomentopname: 'Rolluik',
    submenuTitelMomentopname: 'Bediening',
    keuzeTitelMomentopname: 'Elektrisch',
    hoeUitschrijvenMomentopname: 'Elektrische bediening',
  );

  const tekstBronKeuze = OfferteTechnischeKeuzeRef(
    formulierType: 'aluRaam',
    menuId: 'menu-rolluik-alu',
    submenuId: 'submenu-bediening-alu',
    keuzeId: 'keuze-somfy-alu',
    menuTitelMomentopname: 'Rolluik',
    submenuTitelMomentopname: 'Bediening',
    keuzeTitelMomentopname: 'Somfy',
    hoeUitschrijvenMomentopname: 'Somfy bediening',
  );

  testWidgets(
    'tekstsuggestie opent handmatig en groepsacties nemen alleen exacte bron over',
    (tester) async {
      final geopendeKeuzes = <OfferteTechnischeKeuzeRef>[];
      final overnameGroepen = <OfferteTechnischePrijsOvernameGroep>[];

      await _pumpBoom(
        tester,
        keuzes: const <OfferteTechnischeKeuzeRef>[
          exacteDoelKeuze,
          tekstDoelKeuze,
        ],
        andereTechnischePrijsregels: <OffertePrijsregelModel>[
          _prijsregel(
            id: 'bron-exact',
            formulierType: 'aluRaam',
            omschrijving: 'Exacte bronprijs',
            technischeKeuze: exacteBronKeuze,
          ),
          _prijsregel(
            id: 'bron-tekst',
            formulierType: 'aluRaam',
            omschrijving: 'Tekstbronprijs',
            technischeKeuze: tekstBronKeuze,
          ),
        ],
        onKeuzeOpenen: (keuze, _) async {
          geopendeKeuzes.add(keuze);
        },
        onPrijsregelsOvernemen: (groep) async {
          overnameGroepen.add(groep);
        },
      );

      await _openMenuEnSubmenu(tester);

      await tester.tap(find.text('Somfy'));
      await tester.pump();

      expect(geopendeKeuzes, <OfferteTechnischeKeuzeRef>[tekstDoelKeuze]);
      expect(overnameGroepen, isEmpty);

      await tester.tap(find.text('Elektrisch'));
      await tester.pump();

      expect(overnameGroepen, hasLength(1));
      expect(overnameGroepen.single.enkeleKeuze, isTrue);
      expect(overnameGroepen.single.kandidaten, hasLength(1));
      expect(
        overnameGroepen.single.kandidaten.single.bronPrijsregel.id,
        'bron-exact',
      );
      expect(
        overnameGroepen.single.kandidaten.single.doelKeuze,
        exacteDoelKeuze,
      );

      await tester.tap(find.text('Overnemen'));
      await tester.pump();

      expect(overnameGroepen, hasLength(2));
      final submenuGroep = overnameGroepen.last;
      expect(submenuGroep.enkeleKeuze, isFalse);
      expect(submenuGroep.kandidaten, hasLength(1));
      expect(submenuGroep.kandidaten.single.bronPrijsregel.id, 'bron-exact');
      expect(submenuGroep.aantalMogelijkeTekstOvereenkomsten, 1);

      await tester.tap(find.text('Alles overnemen'));
      await tester.pump();

      expect(overnameGroepen, hasLength(3));
      final menuGroep = overnameGroepen.last;
      expect(menuGroep.kandidaten, hasLength(1));
      expect(menuGroep.kandidaten.single.bronPrijsregel.id, 'bron-exact');
      expect(menuGroep.aantalMogelijkeTekstOvereenkomsten, 1);
      expect(
        menuGroep.kandidaten.map((kandidaat) => kandidaat.bronPrijsregel.id),
        isNot(contains('bron-tekst')),
      );
    },
  );

  testWidgets('lokale prijsregel vereist alle vier gelijke ID-velden', (
    tester,
  ) async {
    OffertePrijsregelModel? geopendePrijsregel;

    final lokalePrijsregel = _prijsregel(
      id: 'lokale-prijsregel',
      formulierType: 'pvcRaam',
      omschrijving: 'Lokale exacte prijs',
      technischeKeuze: exacteDoelKeuze,
    );
    final verkeerdArtikeltype = _prijsregel(
      id: 'verkeerd-artikeltype',
      formulierType: 'aluRaam',
      omschrijving: 'Prijs van verkeerd artikeltype',
      technischeKeuze: exacteDoelKeuze.copyWith(formulierType: 'aluRaam'),
    );

    await _pumpBoom(
      tester,
      keuzes: const <OfferteTechnischeKeuzeRef>[exacteDoelKeuze],
      prijsregels: <OffertePrijsregelModel>[
        verkeerdArtikeltype,
        lokalePrijsregel,
      ],
      onKeuzeOpenen: (_, bestaandePrijsregel) async {
        geopendePrijsregel = bestaandePrijsregel;
      },
    );

    await _openMenuEnSubmenu(tester);
    await tester.tap(find.text('Elektrisch'));
    await tester.pump();

    expect(geopendePrijsregel?.id, 'lokale-prijsregel');
    expect(find.text('Prijs van verkeerd artikeltype'), findsOneWidget);
  });

  testWidgets('lege keuzeId koppelt geen lokale prijsregel', (tester) async {
    const keuzeZonderId = OfferteTechnischeKeuzeRef(
      formulierType: 'pvcRaam',
      menuId: 'menu-rolluik-pvc',
      submenuId: 'submenu-bediening',
      menuTitelMomentopname: 'Rolluik',
      submenuTitelMomentopname: 'Bediening',
      keuzeTitelMomentopname: 'Zonder ID',
      hoeUitschrijvenMomentopname: 'Keuze zonder ID',
    );
    OffertePrijsregelModel? geopendePrijsregel;

    await _pumpBoom(
      tester,
      keuzes: const <OfferteTechnischeKeuzeRef>[keuzeZonderId],
      prijsregels: <OffertePrijsregelModel>[
        _prijsregel(
          id: 'prijs-zonder-keuze-id',
          formulierType: 'pvcRaam',
          omschrijving: 'Prijs met lege keuze-ID',
          technischeKeuze: keuzeZonderId,
        ),
      ],
      onKeuzeOpenen: (_, bestaandePrijsregel) async {
        geopendePrijsregel = bestaandePrijsregel;
      },
    );

    await _openMenuEnSubmenu(tester);
    await tester.tap(find.text('Zonder ID'));
    await tester.pump();

    expect(geopendePrijsregel, isNull);
    expect(find.text('Prijs met lege keuze-ID'), findsOneWidget);
  });

  testWidgets(
    'actieve lokale prijsregel wint van een nieuwere inactieve dubbel',
    (tester) async {
      OffertePrijsregelModel? geopendePrijsregel;

      await _pumpBoom(
        tester,
        keuzes: const <OfferteTechnischeKeuzeRef>[exacteDoelKeuze],
        prijsregels: <OffertePrijsregelModel>[
          _prijsregel(
            id: 'inactieve-dubbel',
            formulierType: 'pvcRaam',
            omschrijving: 'Inactieve dubbele prijs',
            technischeKeuze: exacteDoelKeuze,
            actief: false,
            gewijzigdOp: '2026-07-27T10:00:00Z',
          ),
          _prijsregel(
            id: 'actieve-prijs',
            formulierType: 'pvcRaam',
            omschrijving: 'Actieve prijs',
            technischeKeuze: exacteDoelKeuze,
            gewijzigdOp: '2026-01-01T10:00:00Z',
          ),
        ],
        onKeuzeOpenen: (_, bestaandePrijsregel) async {
          geopendePrijsregel = bestaandePrijsregel;
        },
      );

      await _openMenuEnSubmenu(tester);
      await tester.tap(find.text('Elektrisch'));
      await tester.pump();

      expect(geopendePrijsregel?.id, 'actieve-prijs');
      expect(find.text('Inactieve dubbele prijs'), findsOneWidget);
    },
  );
}

Future<void> _pumpBoom(
  WidgetTester tester, {
  required List<OfferteTechnischeKeuzeRef> keuzes,
  List<OffertePrijsregelModel> prijsregels = const <OffertePrijsregelModel>[],
  List<OffertePrijsregelModel> andereTechnischePrijsregels =
      const <OffertePrijsregelModel>[],
  Future<void> Function(
    OfferteTechnischeKeuzeRef keuze,
    OffertePrijsregelModel? bestaandePrijsregel,
  )?
  onKeuzeOpenen,
  Future<void> Function(OfferteTechnischePrijsOvernameGroep groep)?
  onPrijsregelsOvernemen,
}) async {
  tester.view.physicalSize = const Size(1200, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: OfferteTechnischePrijskeuzeBoom(
            keuzes: keuzes,
            prijsregels: prijsregels,
            andereTechnischePrijsregels: andereTechnischePrijsregels,
            gekoppeldePrijsregelAantallen: const <String, int>{},
            onKeuzeOpenen: onKeuzeOpenen ?? (_, __) async {},
            onPrijsregelOpenen: (_) async {},
            onPrijsregelVerwijderen: (_) async {},
            onPrijsregelOntkoppelen: (_) async {},
            onPrijsregelsOvernemen: onPrijsregelsOvernemen ?? (_) async {},
          ),
        ),
      ),
    ),
  );
}

Future<void> _openMenuEnSubmenu(WidgetTester tester) async {
  await tester.tap(find.text('Rolluik'));
  await tester.pump();
  await tester.tap(find.text('Bediening'));
  await tester.pump();
}

OffertePrijsregelModel _prijsregel({
  required String id,
  required String formulierType,
  required String omschrijving,
  required OfferteTechnischeKeuzeRef technischeKeuze,
  bool actief = true,
  String gewijzigdOp = '2026-01-01T00:00:00Z',
}) {
  return OffertePrijsregelModel(
    id: id,
    categorie: OffertePrijsCategorie.technischeKeuzePerArtikel,
    formulierType: formulierType,
    omschrijving: omschrijving,
    prijsExclBtw: 100,
    eenheid: OffertePrijsEenheid.vast,
    uitschrijfmodus: OffertePrijsUitschrijfmodus.overzichtEnOfferteMetPrijs,
    technischeKeuze: technischeKeuze,
    actief: actief,
    gewijzigdOp: gewijzigdOp,
  );
}
