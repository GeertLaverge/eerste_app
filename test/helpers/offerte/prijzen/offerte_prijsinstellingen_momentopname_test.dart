// THIMACO-CONTROLE: PRIJSINSTELLINGEN-MOMENTOPNAME-FASE-7-20260727
// THIMACO-CONTROLE: PRIJSARCHITECTUUR-OPRUIMEN-STAP5B2-TEST-ZONDER-VERDEELMETA-20260814
import 'package:eerste_app/helpers/offerte/prijzen/offerte_prijs_categorie.dart';
import 'package:eerste_app/helpers/offerte/prijzen/offerte_prijs_eenheid.dart';
import 'package:eerste_app/helpers/offerte/prijzen/offerte_prijs_uitschrijfmodus.dart';
import 'package:eerste_app/helpers/offerte/prijzen/offerte_prijsinstellingen_momentopname.dart';
import 'package:eerste_app/helpers/offerte/prijzen/offerte_technische_keuze_ref.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const keuze = OfferteTechnischeKeuzeRef(
    formulierType: 'pvcRaam',
    menuId: 'menu-rolluik',
    submenuId: 'submenu-bediening',
    keuzeId: 'keuze-elektrisch',
    menuTitelMomentopname: 'Rolluik',
    submenuTitelMomentopname: 'Bediening',
    keuzeTitelMomentopname: 'Elektrisch',
  );

  test('dezelfde vier IDs blijven dezelfde technische keuze', () {
    final oud = _momentopname(keuze);
    final nieuw = _momentopname(
      keuze.copyWith(
        menuTitelMomentopname: 'Nieuwe menutekst',
        keuzeTitelMomentopname: 'Nieuwe keuzetekst',
      ),
    );

    expect(
      oud.verschillenMet(nieuw),
      isNot(contains('Gekoppelde technische keuze gewijzigd')),
    );
  });

  test('afwijkend formulierType is een gewijzigde lokale koppeling', () {
    final oud = _momentopname(keuze);
    final nieuw = _momentopname(keuze.copyWith(formulierType: 'aluRaam'));

    expect(
      oud.verschillenMet(nieuw),
      contains('Gekoppelde technische keuze gewijzigd'),
    );
  });

  test('twee keuzes met lege keuzeId zijn nooit exact gelijk', () {
    final zonderId = keuze.copyWith(keuzeId: '');
    final oud = _momentopname(zonderId);
    final nieuw = _momentopname(zonderId);

    expect(
      oud.verschillenMet(nieuw),
      contains('Gekoppelde technische keuze gewijzigd'),
    );
  });

  test('twee ontbrekende technische keuzes blijven gelijk', () {
    final oud = _momentopname(null);
    final nieuw = _momentopname(null);

    expect(
      oud.verschillenMet(nieuw),
      isNot(contains('Gekoppelde technische keuze gewijzigd')),
    );
  });
}

OffertePrijsregelMomentopname _momentopname(
  OfferteTechnischeKeuzeRef? technischeKeuze,
) {
  return OffertePrijsregelMomentopname(
    id: 'regel-1',
    categorie: OffertePrijsCategorie.technischeKeuzePerArtikel,
    formulierType: 'pvcRaam',
    omschrijving: 'Technische prijs',
    prijsExclBtw: 100,
    eenheid: OffertePrijsEenheid.vast,
    uitschrijfmodus: OffertePrijsUitschrijfmodus.overzichtEnOfferteMetPrijs,
    technischeKeuze: technischeKeuze,
    actief: true,
    volgorde: 0,
  );
}
