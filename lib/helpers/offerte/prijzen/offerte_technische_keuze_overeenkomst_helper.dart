// THIMACO-CONTROLE: TECHNISCHE-KEUZE-OVEREENKOMST-HELPER-FASE-6-20260727
import 'offerte_technische_keuze_ref.dart';

class OfferteTechnischeKeuzeOvereenkomstHelper {
  const OfferteTechnischeKeuzeOvereenkomstHelper._();

  // Binnen één artikeltype moeten alle vier stabiele IDs overeenkomen.
  static String lokaleExacteSleutelVan(OfferteTechnischeKeuzeRef keuze) {
    final keuzeId = keuze.keuzeId.trim();
    if (keuzeId.isEmpty) {
      return '';
    }

    return <String>[
      keuze.formulierType.trim(),
      keuze.menuId.trim(),
      keuze.submenuId.trim(),
      keuzeId,
    ].join('|');
  }

  // Een opgeladen keuze behoudt submenuId en keuzeId. Formulier- en menu-ID
  // mogen tussen artikeltypes verschillen en horen daarom niet in deze sleutel.
  static String exacteSleutelTussenArtikeltypesVan(
    OfferteTechnischeKeuzeRef keuze,
  ) {
    final keuzeId = keuze.keuzeId.trim();
    if (keuzeId.isEmpty) {
      return '';
    }

    return <String>[keuze.submenuId.trim(), keuzeId].join('|');
  }

  // Zichtbare tekst levert alleen een suggestiesleutel op. De prijsboom mag
  // deze sleutel nooit als automatische of exacte koppeling behandelen.
  static String tekstSuggestieSleutelVan(OfferteTechnischeKeuzeRef keuze) {
    final keuzeTitel = keuze.keuzeTitelMomentopname.trim().isNotEmpty
        ? keuze.keuzeTitelMomentopname.trim()
        : keuze.hoeUitschrijven.trim();
    final genormaliseerdeKeuze = normaliseerTekst(keuzeTitel);

    if (genormaliseerdeKeuze.isEmpty) {
      return '';
    }

    return <String>[
      normaliseerTekst(keuze.menuTitelMomentopname),
      normaliseerTekst(keuze.submenuTitelMomentopname),
      genormaliseerdeKeuze,
    ].join('|');
  }

  static bool zijnLokaalExact(
    OfferteTechnischeKeuzeRef eerste,
    OfferteTechnischeKeuzeRef tweede,
  ) {
    final eersteSleutel = lokaleExacteSleutelVan(eerste);
    return eersteSleutel.isNotEmpty &&
        eersteSleutel == lokaleExacteSleutelVan(tweede);
  }

  static bool zijnExactTussenArtikeltypes(
    OfferteTechnischeKeuzeRef eerste,
    OfferteTechnischeKeuzeRef tweede,
  ) {
    final eersteSleutel = exacteSleutelTussenArtikeltypesVan(eerste);
    return eersteSleutel.isNotEmpty &&
        eersteSleutel == exacteSleutelTussenArtikeltypesVan(tweede);
  }

  static bool zijnMogelijkeTekstovereenkomst(
    OfferteTechnischeKeuzeRef eerste,
    OfferteTechnischeKeuzeRef tweede,
  ) {
    final eersteSleutel = tekstSuggestieSleutelVan(eerste);
    return eersteSleutel.isNotEmpty &&
        eersteSleutel == tekstSuggestieSleutelVan(tweede);
  }

  static String normaliseerTekst(String waarde) {
    return waarde.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }
}
