import 'package:eerste_app/helpers/offerte/prijzen/offerte_technische_keuze_overeenkomst_helper.dart';
import 'package:eerste_app/helpers/offerte/prijzen/offerte_technische_keuze_ref.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OfferteTechnischeKeuzeOvereenkomstHelper', () {
    const bron = OfferteTechnischeKeuzeRef(
      formulierType: 'pvcRaam',
      menuId: 'menu-rolluik-pvc',
      submenuId: 'submenu-rolluik',
      keuzeId: 'keuze-elektrisch',
      menuTitelMomentopname: 'Rolluik',
      submenuTitelMomentopname: 'Bediening',
      keuzeTitelMomentopname: 'Elektrisch',
      hoeUitschrijvenMomentopname: 'Elektrische bediening',
    );

    test('lokale exacte sleutel gebruikt alle vier IDs', () {
      final andereMenuId = bron.copyWith(menuId: 'ander-menu');
      final anderFormulierType = bron.copyWith(formulierType: 'aluRaam');
      final andereSubmenuId = bron.copyWith(submenuId: 'ander-submenu');
      final andereKeuzeId = bron.copyWith(keuzeId: 'andere-keuze');

      expect(
        OfferteTechnischeKeuzeOvereenkomstHelper.zijnLokaalExact(bron, bron),
        isTrue,
      );
      expect(
        OfferteTechnischeKeuzeOvereenkomstHelper.zijnLokaalExact(
          bron,
          andereMenuId,
        ),
        isFalse,
      );
      expect(
        OfferteTechnischeKeuzeOvereenkomstHelper.zijnLokaalExact(
          bron,
          anderFormulierType,
        ),
        isFalse,
      );
      expect(
        OfferteTechnischeKeuzeOvereenkomstHelper.zijnLokaalExact(
          bron,
          andereSubmenuId,
        ),
        isFalse,
      );
      expect(
        OfferteTechnischeKeuzeOvereenkomstHelper.zijnLokaalExact(
          bron,
          andereKeuzeId,
        ),
        isFalse,
      );
    });

    test('opgeladen keuze met behouden IDs is exact', () {
      const opgeladen = OfferteTechnischeKeuzeRef(
        formulierType: 'aluRaam',
        menuId: 'menu-rolluik-alu',
        submenuId: 'submenu-rolluik',
        keuzeId: 'keuze-elektrisch',
        menuTitelMomentopname: 'Rolluik',
        submenuTitelMomentopname: 'Bediening',
        keuzeTitelMomentopname: 'Elektrisch',
        hoeUitschrijvenMomentopname: 'Elektrische bediening',
      );

      expect(
        OfferteTechnischeKeuzeOvereenkomstHelper.zijnExactTussenArtikeltypes(
          bron,
          opgeladen,
        ),
        isTrue,
      );
      expect(
        OfferteTechnischeKeuzeOvereenkomstHelper.zijnLokaalExact(
          bron,
          opgeladen,
        ),
        isFalse,
      );
    });

    test('gewone kopie met nieuwe IDs is niet exact', () {
      const gewoneKopie = OfferteTechnischeKeuzeRef(
        formulierType: 'aluRaam',
        menuId: 'menu-rolluik-alu',
        submenuId: 'submenu-rolluik-kopie',
        keuzeId: 'keuze-elektrisch-kopie',
        menuTitelMomentopname: 'Rolluik',
        submenuTitelMomentopname: 'Bediening',
        keuzeTitelMomentopname: 'Elektrisch',
        hoeUitschrijvenMomentopname: 'Elektrische bediening',
      );

      expect(
        OfferteTechnischeKeuzeOvereenkomstHelper.zijnExactTussenArtikeltypes(
          bron,
          gewoneKopie,
        ),
        isFalse,
      );
    });

    test('gelijknamige keuze met andere IDs is alleen tekstsuggestie', () {
      const gelijknamigeKeuze = OfferteTechnischeKeuzeRef(
        formulierType: 'pvcDeur',
        menuId: 'menu-rolluik-deur',
        submenuId: 'submenu-bediening-deur',
        keuzeId: 'keuze-elektrisch-deur',
        menuTitelMomentopname: 'ROLLUIK',
        submenuTitelMomentopname: 'Bediening',
        keuzeTitelMomentopname: 'Elektrisch!',
        hoeUitschrijvenMomentopname: 'Elektrische bediening',
      );

      expect(
        OfferteTechnischeKeuzeOvereenkomstHelper.zijnExactTussenArtikeltypes(
          bron,
          gelijknamigeKeuze,
        ),
        isFalse,
      );
      expect(
        OfferteTechnischeKeuzeOvereenkomstHelper.zijnMogelijkeTekstovereenkomst(
          bron,
          gelijknamigeKeuze,
        ),
        isTrue,
      );
    });

    test('lege keuzeId kan nooit exact gekoppeld worden', () {
      const eersteZonderKeuzeId = OfferteTechnischeKeuzeRef(
        formulierType: 'pvcRaam',
        menuId: 'menu-rolluik-pvc',
        submenuId: 'submenu-rolluik',
        menuTitelMomentopname: 'Rolluik',
        submenuTitelMomentopname: 'Bediening',
        keuzeTitelMomentopname: 'Elektrisch',
      );
      const tweedeZonderKeuzeId = OfferteTechnischeKeuzeRef(
        formulierType: 'pvcRaam',
        menuId: 'menu-rolluik-pvc',
        submenuId: 'submenu-rolluik',
        menuTitelMomentopname: 'Rolluik',
        submenuTitelMomentopname: 'Bediening',
        keuzeTitelMomentopname: 'Elektrisch',
      );

      expect(
        OfferteTechnischeKeuzeOvereenkomstHelper.lokaleExacteSleutelVan(
          eersteZonderKeuzeId,
        ),
        isEmpty,
      );
      expect(
        OfferteTechnischeKeuzeOvereenkomstHelper.exacteSleutelTussenArtikeltypesVan(
          eersteZonderKeuzeId,
        ),
        isEmpty,
      );
      expect(
        OfferteTechnischeKeuzeOvereenkomstHelper.zijnLokaalExact(
          eersteZonderKeuzeId,
          tweedeZonderKeuzeId,
        ),
        isFalse,
      );
      expect(
        OfferteTechnischeKeuzeOvereenkomstHelper.zijnExactTussenArtikeltypes(
          eersteZonderKeuzeId,
          tweedeZonderKeuzeId,
        ),
        isFalse,
      );
    });
  });
}
