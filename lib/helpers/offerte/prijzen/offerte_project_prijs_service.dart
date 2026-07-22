import '../../opmeting/overzicht/opmeting_overzicht_model.dart';
import '../../opmeting/project/opmeting_project_titelhoofd_model.dart';
import 'offerte_artikel_prijs_koppeling_service.dart';
import 'offerte_prijs_categorie.dart';
import 'offerte_prijs_eenheid.dart';
import 'offerte_prijsprofiel_model.dart';
import 'offerte_prijsregel_model.dart';
import 'offerte_toegepaste_prijsregel_model.dart';

class OfferteProjectPrijsResultaat {
  OfferteProjectPrijsResultaat({
    List<OfferteToegepastePrijsregelModel> prijsregels =
        const <OfferteToegepastePrijsregelModel>[],
    int aantalArtikelen = 0,
  }) : prijsregels = List<OfferteToegepastePrijsregelModel>.unmodifiable(
         prijsregels,
       ),
       aantalArtikelen = aantalArtikelen < 0 ? 0 : aantalArtikelen;

  final List<OfferteToegepastePrijsregelModel> prijsregels;
  final int aantalArtikelen;

  bool get heeftPrijsregels => prijsregels.isNotEmpty;

  List<OfferteToegepastePrijsregelModel> get regelsVoorOverzicht {
    return List<OfferteToegepastePrijsregelModel>.unmodifiable(
      prijsregels.where((regel) => regel.isGeldig && regel.toonOpOverzicht),
    );
  }

  List<OfferteToegepastePrijsregelModel> get regelsVoorOfferte {
    return List<OfferteToegepastePrijsregelModel>.unmodifiable(
      prijsregels.where(
        (regel) => regel.isGeldig && regel.teltMeeInOfferteTotaal,
      ),
    );
  }

  List<OfferteToegepastePrijsregelModel> get afzonderlijkeRegelsVoorOfferte {
    return List<OfferteToegepastePrijsregelModel>.unmodifiable(
      regelsVoorOfferte.where((regel) => regel.toonAfzonderlijkePrijsOpOfferte),
    );
  }

  double get totaalOverzichtExclBtw => _som(regelsVoorOverzicht);

  double get totaalOfferteExclBtw => _som(regelsVoorOfferte);

  static OfferteProjectPrijsResultaat samenvoegen(
    Iterable<OfferteProjectPrijsResultaat> resultaten,
  ) {
    final samengevoegdPerSleutel = <String, OfferteToegepastePrijsregelModel>{};
    final sleutelVolgorde = <String>[];
    var aantalArtikelen = 0;

    for (final resultaat in resultaten) {
      aantalArtikelen += resultaat.aantalArtikelen;

      for (final regel in resultaat.prijsregels) {
        final sleutel = _samenvoegSleutel(regel);
        final bestaandeRegel = samengevoegdPerSleutel[sleutel];

        if (bestaandeRegel == null) {
          samengevoegdPerSleutel[sleutel] = regel;
          sleutelVolgorde.add(sleutel);
          continue;
        }

        samengevoegdPerSleutel[sleutel] = _voegPrijsregelsSamen(
          bestaandeRegel,
          regel,
        );
      }
    }

    return OfferteProjectPrijsResultaat(
      prijsregels: sleutelVolgorde
          .map((sleutel) => samengevoegdPerSleutel[sleutel]!)
          .toList(growable: false),
      aantalArtikelen: aantalArtikelen,
    );
  }

  static String _samenvoegSleutel(OfferteToegepastePrijsregelModel regel) {
    final omschrijving = _normaliseerOmschrijving(regel.omschrijving);
    final soort = regel.isOptie ? 'optie' : 'kost';

    if (omschrijving.isEmpty) {
      return '$soort|${regel.bronPrijsregelId}|${regel.hashCode}';
    }

    return '$soort|$omschrijving';
  }

  static OfferteToegepastePrijsregelModel _voegPrijsregelsSamen(
    OfferteToegepastePrijsregelModel eerste,
    OfferteToegepastePrijsregelModel tweede,
  ) {
    final hoeveelheid = _rondHoeveelheidAf(
      eerste.hoeveelheid + tweede.hoeveelheid,
    );
    final totaalExclBtw = _rondBedragAf(
      eerste.totaalExclBtw + tweede.totaalExclBtw,
    );
    final prijsExclBtw = hoeveelheid > 0.0
        ? _rondBedragAf(totaalExclBtw / hoeveelheid)
        : _rondBedragAf(eerste.prijsExclBtw + tweede.prijsExclBtw);

    return eerste.copyWith(
      prijsExclBtw: prijsExclBtw,
      hoeveelheid: hoeveelheid,
      totaalExclBtw: totaalExclBtw,
      verdeeldOverAantalArtikelen:
          eerste.verdeeldOverAantalArtikelen +
          tweede.verdeeldOverAantalArtikelen,
      projectPrijsExclBtw: _rondBedragAf(
        eerste.projectPrijsExclBtw + tweede.projectPrijsExclBtw,
      ),
      aankoopTotaalVoorVerdelingExclBtw: _rondBedragAf(
        eerste.aankoopTotaalVoorVerdelingExclBtw +
            tweede.aankoopTotaalVoorVerdelingExclBtw,
      ),
      verdeelLimietBedragExclBtw:
          eerste.verdeelLimietBedragExclBtw > tweede.verdeelLimietBedragExclBtw
          ? eerste.verdeelLimietBedragExclBtw
          : tweede.verdeelLimietBedragExclBtw,
      bronGewijzigdOp: _laatsteIsoMoment(
        eerste.bronGewijzigdOp,
        tweede.bronGewijzigdOp,
      ),
      berekendOp: _laatsteIsoMoment(eerste.berekendOp, tweede.berekendOp),
    );
  }

  static String _normaliseerOmschrijving(String waarde) {
    return waarde.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String _laatsteIsoMoment(String eerste, String tweede) {
    if (eerste.trim().isEmpty) return tweede;
    if (tweede.trim().isEmpty) return eerste;
    return eerste.compareTo(tweede) >= 0 ? eerste : tweede;
  }

  static double _som(Iterable<OfferteToegepastePrijsregelModel> regels) {
    final totaal = regels.fold<double>(
      0.0,
      (som, regel) => som + regel.totaalExclBtw,
    );
    return _rondBedragAf(totaal);
  }

  static double _rondHoeveelheidAf(double waarde) {
    if (!waarde.isFinite || waarde < 0.0) {
      return 0.0;
    }

    return (waarde * 10000.0).roundToDouble() / 10000.0;
  }

  static double _rondBedragAf(double waarde) {
    if (!waarde.isFinite || waarde < 0.0) {
      return 0.0;
    }

    return (waarde * 100.0).roundToDouble() / 100.0;
  }
}

class OfferteProjectPrijsService {
  const OfferteProjectPrijsService._();

  static List<String> get ondersteundeFormulierTypes {
    return List<String>.unmodifiable(
      OfferteArtikelPrijsKoppelingService.ondersteundeFormulierTypes,
    );
  }

  static OfferteProjectPrijsResultaat berekenAlleOndersteundeUitTitelhoofd({
    required OpmetingProjectTitelhoofd titelhoofd,
    required List<OpmetingOverzichtRaamItem> alleOpmetingen,
  }) {
    return OfferteProjectPrijsResultaat.samenvoegen(
      ondersteundeFormulierTypes.map((formulierType) {
        return berekenUitTitelhoofd(
          titelhoofd: titelhoofd,
          alleOpmetingen: alleOpmetingen,
          formulierType: formulierType,
        );
      }),
    );
  }

  static OfferteProjectPrijsResultaat berekenUitTitelhoofd({
    required OpmetingProjectTitelhoofd titelhoofd,
    required List<OpmetingOverzichtRaamItem> alleOpmetingen,
    String formulierType = 'vasteInzethor',
  }) {
    if (!titelhoofd.berekenPrijzen) {
      return OfferteProjectPrijsResultaat();
    }

    final canoniekFormulierType = _canoniekFormulierType(formulierType);
    if (canoniekFormulierType.isEmpty) {
      return OfferteProjectPrijsResultaat();
    }

    final momentopname = titelhoofd.prijsinstellingenMomentopnameVoor(
      canoniekFormulierType,
    );
    final basisProfiel =
        momentopname?.naarProfiel() ??
        OffertePrijsprofielModel.leeg(
          formulierType: canoniekFormulierType,
          formulierNaam: _formulierNaam(canoniekFormulierType),
        );

    final regelsPerId = <String, OffertePrijsregelModel>{};
    for (final regel in basisProfiel.prijsregels) {
      if (_isZelfdeFormulierType(regel.formulierType, canoniekFormulierType)) {
        regelsPerId[regel.id] = regel;
      }
    }
    for (final regel in titelhoofd.tijdelijkeProjectPrijsregels) {
      if (regel.categorie == OffertePrijsCategorie.alleArtikelen &&
          _isZelfdeFormulierType(regel.formulierType, canoniekFormulierType)) {
        regelsPerId[regel.id] = regel.copyWith(
          categorie: OffertePrijsCategorie.alleArtikelen,
          formulierType: canoniekFormulierType,
        );
      }
    }

    final gecombineerdProfiel = basisProfiel.copyWith(
      formulierType: canoniekFormulierType,
      formulierNaam: _formulierNaam(canoniekFormulierType),
      prijsregels: regelsPerId.values.toList(growable: false),
    );

    return bereken(
      alleOpmetingen: alleOpmetingen,
      klantNaam: titelhoofd.klantNaam,
      profiel: gecombineerdProfiel,
    );
  }

  static OfferteProjectPrijsResultaat bereken({
    required List<OpmetingOverzichtRaamItem> alleOpmetingen,
    required String klantNaam,
    required OffertePrijsprofielModel profiel,
  }) {
    final formulierType = _canoniekFormulierType(profiel.formulierType);
    if (formulierType.isEmpty) {
      return OfferteProjectPrijsResultaat();
    }

    final artikelen = _geldigeArtikelen(
      alleOpmetingen: alleOpmetingen,
      klantNaam: klantNaam,
      formulierType: formulierType,
    );

    if (artikelen.isEmpty) {
      return OfferteProjectPrijsResultaat();
    }

    final aantalArtikelen = artikelen.fold<int>(
      0,
      (som, artikel) => som + artikel.aantal,
    );
    final nu = DateTime.now().toUtc().toIso8601String();
    final toegepasteRegels = <OfferteToegepastePrijsregelModel>[];

    for (final prijsregel in profiel.prijsregels) {
      if (!prijsregel.actief ||
          !prijsregel.isGeldig ||
          prijsregel.prijsExclBtw <= 0.0 ||
          prijsregel.categorie != OffertePrijsCategorie.alleArtikelen ||
          prijsregel.isVerdeeldeProjectkost ||
          !_isZelfdeFormulierType(prijsregel.formulierType, formulierType)) {
        continue;
      }

      final hoeveelheid = _berekenProjectHoeveelheid(
        artikelen: artikelen,
        eenheid: prijsregel.eenheid,
      );

      if (hoeveelheid <= 0.0) {
        continue;
      }

      final totaal = _rondBedragAf(hoeveelheid * prijsregel.prijsExclBtw);

      if (totaal <= 0.0) {
        continue;
      }

      toegepasteRegels.add(
        OfferteToegepastePrijsregelModel(
          bronPrijsregelId: prijsregel.id,
          categorie: OffertePrijsCategorie.alleArtikelen,
          omschrijving: prijsregel.omschrijving,
          prijsExclBtw: prijsregel.prijsExclBtw,
          eenheid: prijsregel.eenheid,
          hoeveelheid: hoeveelheid,
          totaalExclBtw: totaal,
          uitschrijfmodus: prijsregel.uitschrijfmodus,
          bronGewijzigdOp: prijsregel.gewijzigdOp,
          berekendOp: nu,
        ),
      );
    }

    return OfferteProjectPrijsResultaat(
      prijsregels: toegepasteRegels,
      aantalArtikelen: aantalArtikelen,
    );
  }

  static List<_ProjectArtikelGegevens> _geldigeArtikelen({
    required List<OpmetingOverzichtRaamItem> alleOpmetingen,
    required String klantNaam,
    required String formulierType,
  }) {
    final klantSleutel = _normaliseerTekst(klantNaam);
    final resultaat = <_ProjectArtikelGegevens>[];

    for (final opmeting in alleOpmetingen) {
      if (opmeting.isVerwijderd ||
          !opmeting.teltMeeInHoofdofferte ||
          !_isZelfdeFormulierType(
            opmeting.formulierTypeGenormaliseerd,
            formulierType,
          )) {
        continue;
      }

      if (klantSleutel.isNotEmpty &&
          _normaliseerTekst(opmeting.klantNaam) != klantSleutel) {
        continue;
      }

      final gegevens = _gegevensVoorOpmeting(opmeting, formulierType);
      if (gegevens != null) {
        resultaat.add(gegevens);
      }
    }

    return List<_ProjectArtikelGegevens>.unmodifiable(resultaat);
  }

  static _ProjectArtikelGegevens? _gegevensVoorOpmeting(
    OpmetingOverzichtRaamItem opmeting,
    String formulierType,
  ) {
    final koppeling = OfferteArtikelPrijsKoppelingService.koppelingVoorArtikel(
      opmeting,
    );
    final verwacht =
        OfferteArtikelPrijsKoppelingService.koppelingVoorFormulierType(
          formulierType,
        );
    if (koppeling == null ||
        verwacht == null ||
        !_isZelfdeFormulierType(
          koppeling.formulierType,
          verwacht.formulierType,
        )) {
      return null;
    }

    final aantal = OfferteArtikelPrijsKoppelingService.aantalVoorArtikel(
      opmeting,
    );
    return _ProjectArtikelGegevens(
      aantal: aantal < 1 ? 1 : aantal,
      breedteMm: OfferteArtikelPrijsKoppelingService.breedteMmVoorArtikel(
        opmeting,
      ),
      hoogteMm: OfferteArtikelPrijsKoppelingService.hoogteMmVoorArtikel(
        opmeting,
      ),
    );
  }

  static double _berekenProjectHoeveelheid({
    required List<_ProjectArtikelGegevens> artikelen,
    required OffertePrijsEenheid eenheid,
  }) {
    if (eenheid == OffertePrijsEenheid.vast) {
      return 1.0;
    }

    var totaal = 0.0;

    for (final artikel in artikelen) {
      final aantal = artikel.aantal.toDouble();
      final breedteMeter = artikel.breedteMm.toDouble() / 1000.0;
      final hoogteMeter = artikel.hoogteMm.toDouble() / 1000.0;

      final hoeveelheidPerStuk = switch (eenheid) {
        OffertePrijsEenheid.vast => 1.0,
        OffertePrijsEenheid.eenBreedte => breedteMeter,
        OffertePrijsEenheid.tweeBreedtes => breedteMeter * 2.0,
        OffertePrijsEenheid.eenHoogte => hoogteMeter,
        OffertePrijsEenheid.tweeHoogtes => hoogteMeter * 2.0,
        OffertePrijsEenheid.eenBreedteTweeHoogtes =>
          breedteMeter + (hoogteMeter * 2.0),
        OffertePrijsEenheid.omtrek =>
          (breedteMeter * 2.0) + (hoogteMeter * 2.0),
        OffertePrijsEenheid.oppervlakte => breedteMeter * hoogteMeter,
      };

      totaal += hoeveelheidPerStuk * aantal;
    }

    return _rondHoeveelheidAf(totaal);
  }

  static String _formulierNaam(String formulierType) {
    return OfferteArtikelPrijsKoppelingService.formulierNaamVoor(formulierType);
  }

  static String _canoniekFormulierType(String formulierType) {
    return OfferteArtikelPrijsKoppelingService.koppelingVoorFormulierType(
          formulierType,
        )?.formulierType ??
        '';
  }

  static String _normaliseerTekst(String waarde) {
    return waarde.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  static bool _isZelfdeFormulierType(String eerste, String tweede) {
    return _normaliseerFormulierType(eerste) ==
        _normaliseerFormulierType(tweede);
  }

  static String _normaliseerFormulierType(String waarde) {
    return waarde.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  static double _rondHoeveelheidAf(double waarde) {
    if (!waarde.isFinite || waarde < 0.0) {
      return 0.0;
    }

    return (waarde * 10000.0).roundToDouble() / 10000.0;
  }

  static double _rondBedragAf(double waarde) {
    if (!waarde.isFinite || waarde < 0.0) {
      return 0.0;
    }

    return (waarde * 100.0).roundToDouble() / 100.0;
  }
}

class _ProjectArtikelGegevens {
  const _ProjectArtikelGegevens({
    required this.aantal,
    required this.breedteMm,
    required this.hoogteMm,
  });

  final int aantal;
  final int breedteMm;
  final int hoogteMm;
}
