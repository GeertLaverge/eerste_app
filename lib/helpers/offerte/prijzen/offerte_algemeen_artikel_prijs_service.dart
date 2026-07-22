import 'dart:convert';

import '../../opmeting/raam/opmeting_raam_keuzemenu_model.dart';
import 'offerte_artikel_prijs_data_model.dart';
import 'offerte_berekening_resultaat.dart';
import 'offerte_prijs_categorie.dart';
import 'offerte_prijs_eenheid.dart';
import 'offerte_prijsprofiel_model.dart';
import 'offerte_prijsregel_model.dart';
import 'offerte_technische_keuze_resolver.dart';
import 'offerte_toegepaste_prijsregel_model.dart';
import 'offerte_vrije_prijs_selectie_model.dart';

/// Prijsberekening voor algemene opmeetartikelen zoals PVC ramen.
///
/// De rekenregels zijn bewust identiek aan de bestaande inzethorberekening:
/// winstmarge en korting worden alleen op de prijs per stuk toegepast. Andere
/// prijsregels en verdeelde kosten blijven daar buiten.
class OfferteAlgemeenArtikelPrijsService {
  const OfferteAlgemeenArtikelPrijsService._();

  static const String _tijdelijkeVrijePrijsPrefix = 'tijdelijk_vrij_';
  static const String _toegepasteProjectPrijsPrefix = 'toegepast_project_';

  static bool moetTechnischeMomentopnameBijwerken({
    required OfferteArtikelPrijsDataModel prijsData,
    required OffertePrijsprofielModel profiel,
    required Map<String, Map<String, OpmetingRaamKeuzeSelectie>>
    keuzeSelectiesPerKader,
    required int breedteMm,
    required int hoogteMm,
    bool forceer = false,
  }) {
    if (forceer) {
      return true;
    }

    return prijsData.technischePrijsSignatuur !=
        _maakTechnischePrijsSignatuur(
          profiel: profiel,
          keuzeSelectiesPerKader: keuzeSelectiesPerKader,
          breedteMm: breedteMm,
          hoogteMm: hoogteMm,
        );
  }

  /// Past iedere actieve technische prijsregel één keer toe wanneer de
  /// gekoppelde keuze ergens in deze volledige PVC-raampositie geselecteerd
  /// is. Een keuze die op meerdere kaders voorkomt, verdubbelt de prijsregel
  /// dus niet: de categorie is bewust "per artikel".
  static OfferteArtikelPrijsDataModel maakTechnischeMomentopname({
    required OfferteArtikelPrijsDataModel prijsData,
    required OffertePrijsprofielModel profiel,
    required Map<String, Map<String, OpmetingRaamKeuzeSelectie>>
    keuzeSelectiesPerKader,
    required int breedteMm,
    required int hoogteMm,
  }) {
    final berekendOp = DateTime.now().toUtc().toIso8601String();
    final toegepasteRegels = <OfferteToegepastePrijsregelModel>[];

    for (final prijsregel in _geldigeTechnischeRegels(profiel)) {
      final technischeKeuze = prijsregel.technischeKeuze;
      if (technischeKeuze == null || technischeKeuze.isLeeg) {
        continue;
      }

      final isGeselecteerd = OfferteTechnischeKeuzeResolver.isGeselecteerd(
        keuze: technischeKeuze,
        keuzeSelectiesPerKader: keuzeSelectiesPerKader,
      );
      if (!isGeselecteerd) {
        continue;
      }

      final hoeveelheid = _berekenHoeveelheid(
        eenheid: prijsregel.eenheid,
        breedteMm: breedteMm,
        hoogteMm: hoogteMm,
        aantal: 1,
      );
      final totaal = _rondBedragAf(hoeveelheid * prijsregel.prijsExclBtw);

      toegepasteRegels.add(
        OfferteToegepastePrijsregelModel(
          bronPrijsregelId: prijsregel.id,
          categorie: OffertePrijsCategorie.technischeKeuzePerArtikel,
          omschrijving: prijsregel.omschrijving,
          prijsExclBtw: prijsregel.prijsExclBtw,
          eenheid: prijsregel.eenheid,
          hoeveelheid: hoeveelheid,
          totaalExclBtw: totaal,
          uitschrijfmodus: prijsregel.uitschrijfmodus,
          technischeKeuze: technischeKeuze,
          bronGewijzigdOp: prijsregel.gewijzigdOp,
          berekendOp: berekendOp,
        ),
      );
    }

    return prijsData.copyWith(
      toegepasteTechnischePrijsregels: toegepasteRegels,
      technischePrijsSignatuur: _maakTechnischePrijsSignatuur(
        profiel: profiel,
        keuzeSelectiesPerKader: keuzeSelectiesPerKader,
        breedteMm: breedteMm,
        hoogteMm: hoogteMm,
      ),
    );
  }

  static bool moetVrijeArtikelMomentopnameBijwerken({
    required OfferteArtikelPrijsDataModel prijsData,
    required OffertePrijsprofielModel profiel,
    String? artikelSignatuur,
    bool forceer = false,
  }) {
    if (forceer) return true;

    return prijsData.vrijeArtikelPrijsSignatuur !=
        _maakVrijeArtikelPrijsSignatuur(
          profiel,
          artikelSignatuur: artikelSignatuur,
        );
  }

  /// Bouwt de automatische vrije prijsregels uit Instellingen opnieuw op.
  /// Eenmalige regels uit het zwevende prijsvenster blijven behouden.
  static OfferteArtikelPrijsDataModel maakVrijeArtikelMomentopname({
    required OfferteArtikelPrijsDataModel prijsData,
    required OffertePrijsprofielModel profiel,
    String? artikelSignatuur,
  }) {
    final berekendOp = DateTime.now().toUtc().toIso8601String();
    final tijdelijkeSelecties = prijsData.vrijeArtikelPrijsSelecties
        .where(_isTijdelijkeVrijePrijsSelectie)
        .toList(growable: false);

    final tijdelijkePrijsregelIds = tijdelijkeSelecties
        .map((selectie) => selectie.bronPrijsregelId)
        .where((id) => id.isNotEmpty)
        .toSet();

    final automatischeSelecties = _geldigeAutomatischeArtikelRegels(profiel)
        .where((regel) => !tijdelijkePrijsregelIds.contains(regel.id))
        .map((regel) {
          return OfferteVrijePrijsSelectieModel(
            id: 'automatisch_${regel.id}',
            bronPrijsregelId: regel.id,
            omschrijving: regel.omschrijving,
            bedragPerStukExclBtw: regel.prijsExclBtw,
            eenheid: regel.eenheid,
            uitschrijfmodus: regel.uitschrijfmodus,
            bronPrijsPerStukExclBtw: regel.prijsExclBtw,
            bronGewijzigdOp: regel.gewijzigdOp,
            geselecteerdOp: berekendOp,
            actief: true,
          );
        })
        .toList(growable: false);

    return prijsData.copyWith(
      vrijeArtikelPrijsSelecties: <OfferteVrijePrijsSelectieModel>[
        ...automatischeSelecties,
        ...tijdelijkeSelecties,
      ],
      vrijeArtikelPrijsSignatuur: _maakVrijeArtikelPrijsSignatuur(
        profiel,
        artikelSignatuur: artikelSignatuur,
      ),
    );
  }

  /// Leest uitsluitend de eenmalige regels terug die op deze positie werden
  /// opgeslagen. De centrale regels uit Instellingen worden in het zwevende
  /// venster afzonderlijk ingeladen en daarna met deze regels samengevoegd.
  static List<OffertePrijsregelModel> tijdelijkeVrijeArtikelPrijsregels(
    OfferteArtikelPrijsDataModel prijsData, {
    required String formulierType,
  }) {
    final regels = prijsData.vrijeArtikelPrijsSelecties
        .where(_isTijdelijkeVrijePrijsSelectie)
        .map((selectie) {
          return OffertePrijsregelModel(
            id: selectie.bronPrijsregelId,
            categorie: OffertePrijsCategorie.vrijPerArtikel,
            formulierType: formulierType,
            omschrijving: selectie.omschrijving,
            prijsExclBtw: selectie.prijsPerEenheidExclBtw,
            eenheid: selectie.eenheid,
            uitschrijfmodus: selectie.uitschrijfmodus,
            actief: selectie.actief,
            volgorde: _leesTijdelijkeVolgorde(selectie.id),
            gewijzigdOp: selectie.bronGewijzigdOp,
          );
        })
        .toList(growable: false);

    regels.sort((eerste, tweede) => eerste.volgorde.compareTo(tweede.volgorde));
    return List<OffertePrijsregelModel>.unmodifiable(regels);
  }

  /// Voegt één gekozen prijsregel aanvullend toe aan de vrije
  /// artikelprijsopslag van een positie.
  ///
  /// Alle andere automatische en tijdelijke prijsregels blijven behouden. Als
  /// dezelfde bronprijsregel al op deze positie staat, wordt alleen die ene
  /// momentopname vervangen. Het prijsmodel en de JSON-structuur wijzigen niet.
  static OfferteArtikelPrijsDataModel voegTijdelijkeVrijeArtikelPrijsregelToe({
    required OfferteArtikelPrijsDataModel prijsData,
    required OffertePrijsregelModel prijsregel,
  }) {
    final regel = prijsregel.copyWith(
      categorie: OffertePrijsCategorie.vrijPerArtikel,
      actief: true,
    );
    if (!regel.isGeldig || regel.prijsExclBtw <= 0.0) {
      return prijsData;
    }

    final overigeSelecties = prijsData.vrijeArtikelPrijsSelecties
        .where((selectie) => selectie.bronPrijsregelId != regel.id)
        .toList(growable: false);
    final nu = DateTime.now().toUtc().toIso8601String();
    final nieuweSelectie = OfferteVrijePrijsSelectieModel(
      id: '${_tijdelijkeVrijePrijsPrefix}toegepast_${regel.id}',
      bronPrijsregelId: regel.id,
      omschrijving: regel.omschrijving,
      bedragPerStukExclBtw: regel.prijsExclBtw,
      eenheid: regel.eenheid,
      uitschrijfmodus: regel.uitschrijfmodus,
      bronPrijsPerStukExclBtw: regel.prijsExclBtw,
      bronGewijzigdOp: regel.gewijzigdOp,
      geselecteerdOp: nu,
      actief: true,
    );

    return prijsData.copyWith(
      vrijeArtikelPrijsSelecties: <OfferteVrijePrijsSelectieModel>[
        ...overigeSelecties,
        nieuweSelectie,
      ],
    );
  }

  /// Voegt uitsluitend de ene prijsregel toe die in het projectbrede
  /// prijsregelvenster gekozen werd.
  ///
  /// De toegepaste regel krijgt een eigen vrije-regel-ID per doelartikeltype.
  /// Daardoor kan een gelijknamige of bewaarde projectregel niet samenvallen
  /// met andere regels uit het projectmenu. Een oudere toepassing die nog het
  /// oorspronkelijke bron-ID gebruikte, wordt bij opnieuw toepassen vervangen.
  /// Het prijsmodel en de JSON-structuur blijven ongewijzigd.
  static OfferteArtikelPrijsDataModel voegGekozenProjectPrijsregelToe({
    required OfferteArtikelPrijsDataModel prijsData,
    required OffertePrijsregelModel prijsregel,
    required String doelFormulierType,
  }) {
    final oorspronkelijkPrijsregelId = prijsregel.id.trim();
    final formulierSleutel = _normaliseerFormulierType(doelFormulierType);
    final veiligeFormulierSleutel = formulierSleutel.isEmpty
        ? 'algemeen'
        : formulierSleutel;
    final toegepastePrijsregelId =
        '$_toegepasteProjectPrijsPrefix'
        '${veiligeFormulierSleutel}_$oorspronkelijkPrijsregelId';

    final regel = prijsregel.copyWith(
      id: toegepastePrijsregelId,
      categorie: OffertePrijsCategorie.vrijPerArtikel,
      formulierType: doelFormulierType,
      actief: true,
    );
    if (oorspronkelijkPrijsregelId.isEmpty ||
        !regel.isGeldig ||
        regel.prijsExclBtw <= 0.0) {
      return prijsData;
    }

    final teVervangenBronIds = <String>{
      oorspronkelijkPrijsregelId,
      toegepastePrijsregelId,
    };
    final overigeSelecties = prijsData.vrijeArtikelPrijsSelecties
        .where(
          (selectie) => !teVervangenBronIds.contains(selectie.bronPrijsregelId),
        )
        .toList(growable: false);
    final nu = DateTime.now().toUtc().toIso8601String();
    final nieuweSelectie = OfferteVrijePrijsSelectieModel(
      id: '${_tijdelijkeVrijePrijsPrefix}toegepast_$toegepastePrijsregelId',
      bronPrijsregelId: toegepastePrijsregelId,
      omschrijving: regel.omschrijving,
      bedragPerStukExclBtw: regel.prijsExclBtw,
      eenheid: regel.eenheid,
      uitschrijfmodus: regel.uitschrijfmodus,
      bronPrijsPerStukExclBtw: regel.prijsExclBtw,
      bronGewijzigdOp: regel.gewijzigdOp,
      geselecteerdOp: nu,
      actief: true,
    );

    return prijsData.copyWith(
      vrijeArtikelPrijsSelecties: <OfferteVrijePrijsSelectieModel>[
        ...overigeSelecties,
        nieuweSelectie,
      ],
    );
  }

  /// Berekent vooraf het bedrag dat één prijsregel op één overzichtspositie
  /// zal toevoegen. Dezelfde eenheidslogica wordt gebruikt als bij de echte
  /// momentopnameberekening.
  static double berekenPrijsregelTotaalExclBtw({
    required OffertePrijsregelModel prijsregel,
    int aantal = 1,
    int breedteMm = 0,
    int hoogteMm = 0,
  }) {
    if (!prijsregel.actief ||
        !prijsregel.isGeldig ||
        prijsregel.prijsExclBtw <= 0.0) {
      return 0.0;
    }

    final hoeveelheid = _berekenHoeveelheid(
      eenheid: prijsregel.eenheid,
      breedteMm: breedteMm,
      hoogteMm: hoogteMm,
      aantal: aantal,
    );
    return _rondBedragAf(hoeveelheid * prijsregel.prijsExclBtw);
  }

  /// Vervangt alleen de eenmalige vrije prijsregels van één positie. De
  /// automatische regels uit Instellingen blijven bewaard.
  static OfferteArtikelPrijsDataModel metTijdelijkeVrijeArtikelPrijsregels({
    required OfferteArtikelPrijsDataModel prijsData,
    required List<OffertePrijsregelModel> prijsregels,
  }) {
    final tijdelijkePrijsregelIds = prijsregels
        .where(
          (regel) =>
              regel.isGeldig &&
              regel.categorie == OffertePrijsCategorie.vrijPerArtikel,
        )
        .map((regel) => regel.id)
        .where((id) => id.isNotEmpty)
        .toSet();

    final bestaandeAutomatischeSelecties = prijsData.vrijeArtikelPrijsSelecties
        .where(
          (selectie) =>
              !_isTijdelijkeVrijePrijsSelectie(selectie) &&
              !tijdelijkePrijsregelIds.contains(selectie.bronPrijsregelId),
        )
        .toList(growable: false);
    final nu = DateTime.now().toUtc().toIso8601String();

    final tijdelijkeSelecties = <OfferteVrijePrijsSelectieModel>[];
    for (var index = 0; index < prijsregels.length; index++) {
      final regel = prijsregels[index];
      if (!regel.isGeldig ||
          regel.categorie != OffertePrijsCategorie.vrijPerArtikel) {
        continue;
      }

      tijdelijkeSelecties.add(
        OfferteVrijePrijsSelectieModel(
          id: '$_tijdelijkeVrijePrijsPrefix${index}_${regel.id}',
          bronPrijsregelId: regel.id,
          omschrijving: regel.omschrijving,
          bedragPerStukExclBtw: regel.prijsExclBtw,
          eenheid: regel.eenheid,
          uitschrijfmodus: regel.uitschrijfmodus,
          bronPrijsPerStukExclBtw: regel.prijsExclBtw,
          bronGewijzigdOp: regel.gewijzigdOp,
          geselecteerdOp: nu,
          actief: regel.actief,
        ),
      );
    }

    return prijsData.copyWith(
      vrijeArtikelPrijsSelecties: <OfferteVrijePrijsSelectieModel>[
        ...bestaandeAutomatischeSelecties,
        ...tijdelijkeSelecties,
      ],
    );
  }

  static OfferteBerekeningResultaat resultaatUitMomentopname({
    required OfferteArtikelPrijsDataModel prijsData,
    int aantal = 1,
    int breedteMm = 0,
    int hoogteMm = 0,
    bool kortingToestaan = true,
  }) {
    final geldigAantal = aantal < 1 ? 1 : aantal;
    final basisTotaal = _rondBedragAf(
      prijsData.prijsPerStukExclBtw * geldigAantal.toDouble(),
    );

    final vrijeArtikelPrijsregels = prijsData.vrijeArtikelPrijsSelecties
        .where(
          (selectie) =>
              selectie.actief && selectie.isGeldig && selectie.heeftBedrag,
        )
        .map((selectie) {
          final hoeveelheid = selectie.hoeveelheidVoorMaten(
            aantal: geldigAantal,
            breedteMm: breedteMm,
            hoogteMm: hoogteMm,
          );
          final totaal = selectie.totaalExclBtwVoorMaten(
            aantal: geldigAantal,
            breedteMm: breedteMm,
            hoogteMm: hoogteMm,
          );

          return OfferteToegepastePrijsregelModel(
            bronPrijsregelId: selectie.bronPrijsregelId,
            categorie: OffertePrijsCategorie.vrijPerArtikel,
            omschrijving: selectie.omschrijving,
            prijsExclBtw: selectie.prijsPerEenheidExclBtw,
            eenheid: selectie.eenheid,
            hoeveelheid: hoeveelheid,
            totaalExclBtw: totaal,
            uitschrijfmodus: selectie.uitschrijfmodus,
            bronGewijzigdOp: selectie.bronGewijzigdOp,
            berekendOp: selectie.geselecteerdOp,
          );
        })
        .where((regel) => regel.isGeldig && regel.totaalExclBtw > 0.0)
        .toList(growable: false);

    return OfferteBerekeningResultaat(
      basisTotaalExclBtw: basisTotaal,
      aantalArtikelen: geldigAantal,
      basisPrijsPerStukExclBtw: prijsData.prijsPerStukExclBtw,
      technischePrijsregels: prijsData.toegepasteTechnischePrijsregels
          .where((regel) => regel.toonOpOverzicht && regel.isGeldig)
          .toList(growable: false),
      vrijeArtikelPrijsregels: vrijeArtikelPrijsregels,
      verdeeldePrijsregels: prijsData.toegepasteVerdeeldePrijsregels
          .where((regel) => regel.toonOpOverzicht && regel.isGeldig)
          .toList(growable: false),
      winstmargePercentage: prijsData.artikelWinstmargePercentage,
      winstmargeOmschrijving: prijsData.artikelWinstmargeOmschrijving,
      kortingPercentage: kortingToestaan
          ? prijsData.artikelKortingPercentage
          : 0.0,
      kortingOmschrijving: prijsData.artikelKortingOmschrijving,
    );
  }

  static List<OffertePrijsregelModel> _geldigeTechnischeRegels(
    OffertePrijsprofielModel profiel,
  ) {
    return profiel
        .regelsVoorCategorie(OffertePrijsCategorie.technischeKeuzePerArtikel)
        .where((regel) {
          final technischeKeuze = regel.technischeKeuze;
          return regel.actief &&
              regel.isGeldig &&
              regel.prijsExclBtw > 0.0 &&
              technischeKeuze != null &&
              !technischeKeuze.isLeeg &&
              _isZelfdeFormulierType(
                regel.formulierType,
                profiel.formulierType,
              ) &&
              _isZelfdeFormulierType(
                technischeKeuze.formulierType,
                profiel.formulierType,
              );
        })
        .toList(growable: false);
  }

  static List<OffertePrijsregelModel> _geldigeAutomatischeArtikelRegels(
    OffertePrijsprofielModel profiel,
  ) {
    return profiel
        .regelsVoorCategorie(OffertePrijsCategorie.vrijPerArtikel)
        .where((regel) {
          return regel.actief &&
              regel.isGeldig &&
              regel.prijsExclBtw > 0.0 &&
              _isZelfdeFormulierType(
                regel.formulierType,
                profiel.formulierType,
              );
        })
        .toList(growable: false);
  }

  static String _maakTechnischePrijsSignatuur({
    required OffertePrijsprofielModel profiel,
    required Map<String, Map<String, OpmetingRaamKeuzeSelectie>>
    keuzeSelectiesPerKader,
    required int breedteMm,
    required int hoogteMm,
  }) {
    final regels = _geldigeTechnischeRegels(profiel)
        .map(
          (regel) => <String, Object?>{
            'id': regel.id,
            'omschrijving': regel.omschrijving,
            'prijsExclBtw': regel.prijsExclBtw,
            'eenheid': regel.eenheid.jsonWaarde,
            'uitschrijfmodus': regel.uitschrijfmodus.jsonWaarde,
            'technischeKeuze': regel.technischeKeuze?.toJson(),
            'actief': regel.actief,
            'volgorde': regel.volgorde,
            'gewijzigdOp': regel.gewijzigdOp,
          },
        )
        .toList(growable: false);

    return jsonEncode(<String, Object?>{
      'formulierType': profiel.formulierType,
      'breedteMm': breedteMm < 0 ? 0 : breedteMm,
      'hoogteMm': hoogteMm < 0 ? 0 : hoogteMm,
      'selecties': OfferteTechnischeKeuzeResolver.signatuurSelecties(
        keuzeSelectiesPerKader,
      ),
      'regels': regels,
    });
  }

  static String _maakVrijeArtikelPrijsSignatuur(
    OffertePrijsprofielModel profiel, {
    String? artikelSignatuur,
  }) {
    final regels = _geldigeAutomatischeArtikelRegels(profiel)
        .map(
          (regel) => <String, Object?>{
            'id': regel.id,
            'omschrijving': regel.omschrijving,
            'prijsExclBtw': regel.prijsExclBtw,
            'eenheid': regel.eenheid.jsonWaarde,
            'uitschrijfmodus': regel.uitschrijfmodus.jsonWaarde,
            'actief': regel.actief,
            'volgorde': regel.volgorde,
            'gewijzigdOp': regel.gewijzigdOp,
          },
        )
        .toList(growable: false);

    if (artikelSignatuur != null) {
      return jsonEncode(<String, Object?>{
        'artikel': artikelSignatuur,
        'regels': regels,
      });
    }

    return jsonEncode(<String, Object?>{
      'formulierType': profiel.formulierType,
      'regels': regels,
    });
  }

  static double _berekenHoeveelheid({
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
      OffertePrijsEenheid.eenBreedteTweeHoogtes =>
        breedteMeter + (2.0 * hoogteMeter),
      OffertePrijsEenheid.omtrek => (2.0 * breedteMeter) + (2.0 * hoogteMeter),
      OffertePrijsEenheid.oppervlakte => breedteMeter * hoogteMeter,
    };

    return _rondHoeveelheidAf(geldigAantal * hoeveelheidPerStuk);
  }

  static bool _isTijdelijkeVrijePrijsSelectie(
    OfferteVrijePrijsSelectieModel selectie,
  ) {
    return selectie.id.startsWith(_tijdelijkeVrijePrijsPrefix);
  }

  static int _leesTijdelijkeVolgorde(String id) {
    if (!id.startsWith(_tijdelijkeVrijePrijsPrefix)) return 0;
    final rest = id.substring(_tijdelijkeVrijePrijsPrefix.length);
    final scheiding = rest.indexOf('_');
    if (scheiding <= 0) return 0;
    final index = int.tryParse(rest.substring(0, scheiding)) ?? 0;
    return index * 10;
  }

  static bool _isZelfdeFormulierType(String eerste, String tweede) {
    return _normaliseerFormulierType(eerste) ==
        _normaliseerFormulierType(tweede);
  }

  static String _normaliseerFormulierType(String waarde) {
    return waarde.trim().toLowerCase().replaceAll('_', '').replaceAll(' ', '');
  }

  static double _rondHoeveelheidAf(double waarde) {
    if (!waarde.isFinite || waarde < 0.0) return 0.0;
    return (waarde * 10000.0).roundToDouble() / 10000.0;
  }

  static double _rondBedragAf(double waarde) {
    if (!waarde.isFinite || waarde <= 0.0) return 0.0;
    return (waarde * 100.0).roundToDouble() / 100.0;
  }
}
