// THIMACO-CONTROLE: CENTRALE-TECHNISCHE-PRIJS-FORMULIERTYPE-OPSLAGSLEUTEL-FIX-20260815
// THIMACO-CONTROLE: CENTRALE-TECHNISCHE-PRIJS-UNNECESSARY-CASCADE-FIX-20260815
// THIMACO-CONTROLE: CENTRALE-TECHNISCHE-PRIJS-FICHEONAFHANKELIJKE-KOPPELING-20260815
// THIMACO-CONTROLE: CENTRALE-TECHNISCHE-PRIJS-ALLEEN-ZELFGEMAAKTE-KEUZES-20260815
// THIMACO-CONTROLE: CENTRALE-TECHNISCHE-KEUZEPRIJZEN-BEREKENING-20260815
import 'dart:convert';

import '../../app_storage.dart';
import 'offerte_artikel_prijs_data_model.dart';
import 'offerte_prijs_categorie.dart';
import 'offerte_prijs_eenheid.dart';
import 'offerte_prijs_uitschrijfmodus.dart';
import 'offerte_technische_keuze_laad_helper.dart';
import 'offerte_technische_keuze_overeenkomst_helper.dart';
import 'offerte_technische_keuze_prijs_model.dart';
import 'offerte_technische_keuze_ref.dart';
import 'offerte_toegepaste_prijsregel_model.dart';

/// Vooraf geladen context voor de nieuwe centrale technische prijslijst.
///
/// Eén centrale prijsinstelling blijft fiche-onafhankelijk. Voor de concrete
/// berekening wordt ze gekoppeld aan de lokale technische keuze van het huidige
/// formulier. Daardoor kan de bestaande selectiecontrole veilig met de lokale
/// menuId + keuzeId blijven werken. Stabiele IDs hebben altijd voorrang; /// alleen voor oudere/los aangemaakte maar eenduidig identieke keuzes is /// er een veilige unieke tekstfallback.
class OfferteCentraleTechnischePrijsContext {
  const OfferteCentraleTechnischePrijsContext({
    required this.prijzen,
    required this.lokaleKeuzesPerFormulierType,
  });

  final List<OfferteTechnischeKeuzePrijsModel> prijzen;
  final Map<String, Map<String, OfferteTechnischeKeuzeRef>>
  lokaleKeuzesPerFormulierType;

  Map<String, OfferteTechnischeKeuzeRef> lokaleKeuzesVoor(
    String formulierType,
  ) {
    return lokaleKeuzesPerFormulierType[OfferteCentraleTechnischePrijsService.normaliseerFormulierType(
          formulierType,
        )] ??
        const <String, OfferteTechnischeKeuzeRef>{};
  }
}

typedef OfferteCentraleTechnischeKeuzeSelectieTest =
    bool Function(OfferteTechnischeKeuzeRef lokaleKeuze);

/// Nieuwe eenvoudige berekeningsservice voor "Prijs bij technische keuzes".
///
/// Deze service gebruikt NIET de oude prijsprofielen per fiche. Alleen de
/// centrale prijslijst uit Instellingen en de werkelijk geselecteerde lokale
/// technische keuzes bepalen de technische prijs.
class OfferteCentraleTechnischePrijsService {
  const OfferteCentraleTechnischePrijsService._();

  static const String _signatuurVersie =
      'centrale-technische-prijs-v4-canoniek-formuliertype';
  static const String _bronPrefix = 'centraleTechnischeKeuze::';

  static Future<OfferteCentraleTechnischePrijsContext> laadContext({
    required Iterable<String> formulierTypes,
  }) async {
    final prijzen = await AppStorage.laadOfferteTechnischeKeuzePrijzen();
    final lokaleKeuzesPerFormulierType =
        <String, Map<String, OfferteTechnischeKeuzeRef>>{};

    // Bewaar twee vormen van het formulierType:
    //
    // - de genormaliseerde vorm is uitsluitend de interne mapsleutel;
    // - de originele/canonieke vorm moet naar AppStorage en de laadhelper.
    //
    // AppStorage onderscheidt bijvoorbeeld 'pvcRaam', 'aluRaam',
    // 'pvcSchuifraam' en 'aluSchuifraam' expliciet. Wanneer we eerst
    // normaliseren naar 'aluschuifraam', valt AppStorage terug op de
    // standaard PVC-raamopslag. Dat was precies waarom technische prijzen wel
    // op PVC raam maar niet op ALU schuifraam gekoppeld raakten.
    final formulierTypePerGenormaliseerdeSleutel = <String, String>{};

    for (final formulierType in formulierTypes) {
      final canoniekFormulierType = formulierType.trim();
      final genormaliseerd = normaliseerFormulierType(canoniekFormulierType);

      if (genormaliseerd.isEmpty || canoniekFormulierType.isEmpty) {
        continue;
      }

      formulierTypePerGenormaliseerdeSleutel.putIfAbsent(
        genormaliseerd,
        () => canoniekFormulierType,
      );
    }

    final uniekeFormulierTypes =
        formulierTypePerGenormaliseerdeSleutel.keys.toList(growable: false)
          ..sort();

    for (final formulierType in uniekeFormulierTypes) {
      final opslagFormulierType =
          formulierTypePerGenormaliseerdeSleutel[formulierType]!;

      // Alleen de keuzemenu's die de gebruiker zelf via
      // "Nieuwe technische keuze" heeft aangemaakt zijn prijsbaar.
      // Ingebouwde programmakeuzes worden hier bewust niet geladen.
      final menus = await AppStorage.laadOpmetingRaamKeuzemenusVoorFormulier(
        opslagFormulierType,
      );
      final keuzes = menus.isEmpty
          ? const <OfferteTechnischeKeuzeRef>[]
          : OfferteTechnischeKeuzeLaadHelper.bouwUitKeuzemenus(
              formulierType: opslagFormulierType,
              menus: menus,
            );

      final perCentraleSleutel = <String, OfferteTechnischeKeuzeRef>{};
      for (final keuze in keuzes) {
        final sleutel =
            OfferteTechnischeKeuzeOvereenkomstHelper.exacteSleutelTussenArtikeltypesVan(
              keuze,
            );
        if (sleutel.isEmpty) {
          continue;
        }
        perCentraleSleutel[sleutel] = keuze;
      }

      lokaleKeuzesPerFormulierType[formulierType] =
          Map<String, OfferteTechnischeKeuzeRef>.unmodifiable(
            perCentraleSleutel,
          );
    }

    final beschikbareCentraleSleutels = lokaleKeuzesPerFormulierType.values
        .expand((keuzes) => keuzes.keys)
        .toSet();
    final geldigePrijzen = prijzen
        .where((prijs) => beschikbareCentraleSleutels.contains(prijs.id))
        .toList(growable: false);

    return OfferteCentraleTechnischePrijsContext(
      prijzen: List<OfferteTechnischeKeuzePrijsModel>.unmodifiable(
        geldigePrijzen,
      ),
      lokaleKeuzesPerFormulierType:
          Map<String, Map<String, OfferteTechnischeKeuzeRef>>.unmodifiable(
            lokaleKeuzesPerFormulierType,
          ),
    );
  }

  static bool moetMomentopnameBijwerken({
    required OfferteArtikelPrijsDataModel prijsData,
    required OfferteCentraleTechnischePrijsContext context,
    required String formulierType,
    required String artikelSignatuur,
    bool forceer = false,
  }) {
    if (forceer) {
      return true;
    }

    return prijsData.technischePrijsSignatuur !=
        maakSignatuur(
          context: context,
          formulierType: formulierType,
          artikelSignatuur: artikelSignatuur,
        );
  }

  static OfferteArtikelPrijsDataModel maakMomentopname({
    required OfferteArtikelPrijsDataModel prijsData,
    required OfferteCentraleTechnischePrijsContext context,
    required String formulierType,
    required int breedteMm,
    required int hoogteMm,
    required int aantal,
    required String artikelSignatuur,
    required OfferteCentraleTechnischeKeuzeSelectieTest keuzeIsGeselecteerd,
  }) {
    final berekendOp = DateTime.now().toUtc().toIso8601String();
    final lokaleKeuzes = context.lokaleKeuzesVoor(formulierType);
    final toegepasteRegels = <OfferteToegepastePrijsregelModel>[];

    for (final prijs in context.prijzen) {
      if (!prijs.isGeldig || !prijs.heeftPrijs) {
        continue;
      }

      final lokaleKeuze = _vindLokaleKeuzeVoorPrijs(
        prijs: prijs,
        lokaleKeuzes: lokaleKeuzes,
      );
      if (lokaleKeuze == null || !keuzeIsGeselecteerd(lokaleKeuze)) {
        continue;
      }

      final eenheid = _prijsEenheidVoor(prijs.eenheid);
      final hoeveelheid = berekenHoeveelheid(
        eenheid: eenheid,
        breedteMm: breedteMm,
        hoogteMm: hoogteMm,
        aantal: aantal,
      );
      final verkoopPrijsPerEenheid = prijs.verkoopPrijsPerEenheidExclBtw;
      final totaalExclBtw = _rondBedragAf(hoeveelheid * verkoopPrijsPerEenheid);

      if (hoeveelheid <= 0.0 || totaalExclBtw <= 0.0) {
        continue;
      }

      toegepasteRegels.add(
        OfferteToegepastePrijsregelModel(
          bronPrijsregelId: '$_bronPrefix${prijs.id}',
          categorie: OffertePrijsCategorie.technischeKeuzePerArtikel,
          omschrijving: prijs.omschrijving,
          prijsExclBtw: verkoopPrijsPerEenheid,
          eenheid: eenheid,
          hoeveelheid: hoeveelheid,
          totaalExclBtw: totaalExclBtw,
          uitschrijfmodus: _uitschrijfmodusVoor(prijs.offerteWeergave),
          technischeKeuze: lokaleKeuze,
          bronGewijzigdOp: prijs.gewijzigdOp,
          berekendOp: berekendOp,
        ),
      );
    }

    return prijsData.copyWith(
      toegepasteTechnischePrijsregels: toegepasteRegels,
      technischePrijsSignatuur: maakSignatuur(
        context: context,
        formulierType: formulierType,
        artikelSignatuur: artikelSignatuur,
      ),
    );
  }

  static String maakSignatuur({
    required OfferteCentraleTechnischePrijsContext context,
    required String formulierType,
    required String artikelSignatuur,
  }) {
    final lokaleKeuzes = context.lokaleKeuzesVoor(formulierType);
    final relevantePrijzen = <Map<String, Object?>>[];

    for (final prijs in context.prijzen) {
      if (!prijs.isGeldig) {
        continue;
      }

      final lokaleKeuze = _vindLokaleKeuzeVoorPrijs(
        prijs: prijs,
        lokaleKeuzes: lokaleKeuzes,
      );
      if (lokaleKeuze == null) {
        continue;
      }

      relevantePrijzen.add(<String, Object?>{
        'id': prijs.id,
        'type': prijs.type.jsonWaarde,
        'eenheid': prijs.eenheid,
        'prijsExclBtw': prijs.veiligePrijsExclBtw,
        'winstPercentage': prijs.veiligWinstPercentage,
        'offerteWeergave': prijs.offerteWeergave.jsonWaarde,
        'gewijzigdOp': prijs.gewijzigdOp,
        'lokaleMenuId': lokaleKeuze.menuId.trim(),
        'lokaleSubmenuId': lokaleKeuze.submenuId.trim(),
        'lokaleKeuzeId': lokaleKeuze.keuzeId.trim(),
      });
    }

    relevantePrijzen.sort((eerste, tweede) {
      return (eerste['id']?.toString() ?? '').compareTo(
        tweede['id']?.toString() ?? '',
      );
    });

    return jsonEncode(<String, Object?>{
      'versie': _signatuurVersie,
      'formulierType': normaliseerFormulierType(formulierType),
      'artikelSignatuur': artikelSignatuur,
      'prijzen': relevantePrijzen,
    });
  }

  static OfferteTechnischeKeuzeRef? _vindLokaleKeuzeVoorPrijs({
    required OfferteTechnischeKeuzePrijsModel prijs,
    required Map<String, OfferteTechnischeKeuzeRef> lokaleKeuzes,
  }) {
    if (lokaleKeuzes.isEmpty) {
      return null;
    }

    // 1. Exacte nieuwe route: submenuId + keuzeId zijn identiek.
    final exact = lokaleKeuzes[prijs.id];
    if (exact != null) {
      return exact;
    }

    final bronKeuze = prijs.technischeKeuze;

    // 2. Veilige ID-fallback voor keuzes die door oudere versies in een ander
    // submenu terechtkwamen. Keuze-ID moet binnen deze fiche uniek zijn.
    final bronKeuzeId = bronKeuze.keuzeId.trim();
    if (bronKeuzeId.isNotEmpty) {
      final zelfdeKeuzeId = lokaleKeuzes.values
          .where((keuze) => keuze.keuzeId.trim() == bronKeuzeId)
          .toList(growable: false);

      if (zelfdeKeuzeId.length == 1) {
        return zelfdeKeuzeId.single;
      }
    }

    // 3. Bestaande technische keuzes kunnen vroeger op twee fiches apart zijn
    // aangemaakt en daardoor andere IDs hebben, terwijl ze voor de gebruiker
    // exact dezelfde keuze zijn. We koppelen dan alleen wanneer de volledige
    // zichtbare technische keuze (menu + submenu + keuze) exact en uniek is.
    final tekstOvereenkomsten = lokaleKeuzes.values
        .where(
          (keuze) =>
              OfferteTechnischeKeuzeOvereenkomstHelper.zijnMogelijkeTekstovereenkomst(
                bronKeuze,
                keuze,
              ),
        )
        .toList(growable: false);

    if (tekstOvereenkomsten.length == 1) {
      return tekstOvereenkomsten.single;
    }

    // 4. Laatste compatibiliteitsfallback: dezelfde effectieve
    // uitschrijftekst. Dit is alleen toegestaan wanneer die tekst binnen de
    // huidige fiche precies één technische keuze oplevert. Daardoor kan bv.
    // een oude los aangemaakte "mdf l en R" dezelfde centrale prijs gebruiken
    // zonder generieke teksten als "Ja" foutief aan meerdere keuzes te koppelen.
    final bronTekst = OfferteTechnischeKeuzeOvereenkomstHelper.normaliseerTekst(
      bronKeuze.hoeUitschrijven,
    );
    if (bronTekst.isEmpty) {
      return null;
    }

    final zelfdeUitschrijftekst = lokaleKeuzes.values
        .where((keuze) {
          final lokaleTekst =
              OfferteTechnischeKeuzeOvereenkomstHelper.normaliseerTekst(
                keuze.hoeUitschrijven,
              );
          return lokaleTekst.isNotEmpty && lokaleTekst == bronTekst;
        })
        .toList(growable: false);

    return zelfdeUitschrijftekst.length == 1
        ? zelfdeUitschrijftekst.single
        : null;
  }

  static double berekenHoeveelheid({
    required OffertePrijsEenheid eenheid,
    required int breedteMm,
    required int hoogteMm,
    required int aantal,
  }) {
    final breedteMeter = breedteMm < 0 ? 0.0 : breedteMm / 1000.0;
    final hoogteMeter = hoogteMm < 0 ? 0.0 : hoogteMm / 1000.0;
    final geldigAantal = (aantal < 1 ? 1 : aantal).toDouble();

    final hoeveelheidPerStuk = switch (eenheid) {
      OffertePrijsEenheid.vast => 1.0,
      OffertePrijsEenheid.eenBreedte => breedteMeter,
      OffertePrijsEenheid.tweeBreedtes => 2.0 * breedteMeter,
      OffertePrijsEenheid.eenHoogte => hoogteMeter,
      OffertePrijsEenheid.tweeHoogtes => 2.0 * hoogteMeter,
      OffertePrijsEenheid.eenBreedteEenHoogte => breedteMeter + hoogteMeter,
      OffertePrijsEenheid.tweeBreedtesEenHoogte =>
        (2.0 * breedteMeter) + hoogteMeter,
      OffertePrijsEenheid.eenBreedteTweeHoogtes =>
        breedteMeter + (2.0 * hoogteMeter),
      OffertePrijsEenheid.omtrek => (2.0 * breedteMeter) + (2.0 * hoogteMeter),
      OffertePrijsEenheid.oppervlakte => breedteMeter * hoogteMeter,
    };

    return _rondHoeveelheidAf(geldigAantal * hoeveelheidPerStuk);
  }

  static OffertePrijsEenheid _prijsEenheidVoor(String waarde) {
    final sleutel = waarde
        .trim()
        .toLowerCase()
        .replaceAll('×', 'x')
        .replaceAll(RegExp(r'\s+'), '');

    return switch (sleutel) {
      '1xb' => OffertePrijsEenheid.eenBreedte,
      '2xb' => OffertePrijsEenheid.tweeBreedtes,
      '1xh' => OffertePrijsEenheid.eenHoogte,
      '2xh' => OffertePrijsEenheid.tweeHoogtes,
      '2xhen1xb' => OffertePrijsEenheid.eenBreedteTweeHoogtes,
      '1xhen2xb' => OffertePrijsEenheid.tweeBreedtesEenHoogte,
      'rondom' => OffertePrijsEenheid.omtrek,
      'oppervlakte' => OffertePrijsEenheid.oppervlakte,
      _ => OffertePrijsEenheid.vast,
    };
  }

  static OffertePrijsUitschrijfmodus _uitschrijfmodusVoor(
    OffertePrijsPerPositieWeergave weergave,
  ) {
    return switch (weergave) {
      OffertePrijsPerPositieWeergave.uit =>
        OffertePrijsUitschrijfmodus.alleenOverzicht,
      OffertePrijsPerPositieWeergave.tekst =>
        OffertePrijsUitschrijfmodus.invullenEnOfferteZonderPrijs,
      OffertePrijsPerPositieWeergave.prijs =>
        OffertePrijsUitschrijfmodus.overzichtEnOfferteMetPrijs,
    };
  }

  static String normaliseerFormulierType(String waarde) {
    return waarde.trim().toLowerCase().replaceAll('_', '').replaceAll(' ', '');
  }

  static double _rondHoeveelheidAf(double waarde) {
    if (!waarde.isFinite || waarde < 0.0) {
      return 0.0;
    }
    return (waarde * 10000.0).roundToDouble() / 10000.0;
  }

  static double _rondBedragAf(double waarde) {
    if (!waarde.isFinite || waarde <= 0.0) {
      return 0.0;
    }
    return (waarde * 100.0).roundToDouble() / 100.0;
  }
}
