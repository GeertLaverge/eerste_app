// THIMACO-CONTROLE: GEKOPPELDE-VERDEELKOST-EENMAAL-20260724
import 'dart:convert';
import 'dart:math' as math;

import '../../opmeting/overzicht/opmeting_overzicht_model.dart';
import 'offerte_artikel_prijs_koppeling_service.dart';
import 'offerte_prijs_categorie.dart';
import 'offerte_prijs_eenheid.dart';
import 'offerte_prijs_verdeel_limietmodus.dart';
import 'offerte_prijsprofiel_model.dart';
import 'offerte_prijsregel_model.dart';
import 'offerte_prijs_uitschrijfmodus.dart';
import 'offerte_toegepaste_prijsregel_model.dart';
import 'offerte_vrije_prijs_selectie_model.dart';

class OfferteVerdeelkostBijwerkingResultaat {
  const OfferteVerdeelkostBijwerkingResultaat({
    required this.opmetingen,
    required this.gewijzigd,
  });

  final List<OpmetingOverzichtRaamItem> opmetingen;
  final bool gewijzigd;
}

class OfferteVerdeelkostService {
  const OfferteVerdeelkostService._();

  static const String _geselecteerdeVerdeelkostBronPrefix =
      'geselecteerde_verdeelkost::';
  static const String _geselecteerdeVerdeelkostSelectiePrefix =
      'tijdelijk_vrij_geselecteerde_verdeelkost::';
  static const String _oudeToegepasteProjectPrijsPrefix = 'toegepast_project_';

  /// Geeft de projectbrede identiteit van een gekoppelde interne verdeelkost.
  /// Gelijknamige verdeelkosten uit verschillende artikelgroepen zijn één kost.
  static String gekoppeldeVerdeelkostSleutel(
    OffertePrijsregelModel prijsregel,
  ) {
    if (!prijsregel.isVerdeeldeProjectkost) return '';
    return gekoppeldeVerdeelkostSleutelVoorOmschrijving(
      prijsregel.omschrijving,
    );
  }

  static String gekoppeldeVerdeelkostSleutelVoorOmschrijving(
    String omschrijving,
  ) {
    return _normaliseerGekoppeldeOmschrijving(omschrijving);
  }

  static OfferteVerdeelkostBijwerkingResultaat werkMomentopnamesBij({
    required List<OpmetingOverzichtRaamItem> alleOpmetingen,
    required String klantNaam,
    required OffertePrijsprofielModel profiel,
    bool forceer = false,
  }) {
    final klantSleutel = klantNaam.trim().toLowerCase();
    final formulierType = _canoniekFormulierType(profiel.formulierType);

    if (klantSleutel.isEmpty || formulierType.isEmpty) {
      return OfferteVerdeelkostBijwerkingResultaat(
        opmetingen: alleOpmetingen,
        gewijzigd: false,
      );
    }

    final doelIndexen = <int>[];
    final optieIndexen = <int>[];

    for (var index = 0; index < alleOpmetingen.length; index++) {
      final opmeting = alleOpmetingen[index];
      if (_isDoelOpmeting(opmeting, klantSleutel, formulierType)) {
        doelIndexen.add(index);
      } else if (_isOptieOpmeting(opmeting, klantSleutel, formulierType)) {
        optieIndexen.add(index);
      }
    }

    final moetOptiesOpschonen = optieIndexen.any((index) {
      return _heeftVerdeelkosten(alleOpmetingen[index], formulierType);
    });

    if (doelIndexen.isEmpty) {
      if (!moetOptiesOpschonen) {
        return OfferteVerdeelkostBijwerkingResultaat(
          opmetingen: alleOpmetingen,
          gewijzigd: false,
        );
      }

      return OfferteVerdeelkostBijwerkingResultaat(
        opmetingen: _maakOptiesZonderVerdeelkosten(
          alleOpmetingen: alleOpmetingen,
          optieIndexen: optieIndexen,
          formulierType: formulierType,
        ),
        gewijzigd: true,
      );
    }

    final projectSignatuur = _maakProjectSignatuur(
      alleOpmetingen: alleOpmetingen,
      doelIndexen: doelIndexen,
      profiel: profiel,
      formulierType: formulierType,
    );

    final moetBijwerken =
        forceer ||
        moetOptiesOpschonen ||
        doelIndexen.any((index) {
          return _verdeeldePrijsSignatuur(
                alleOpmetingen[index],
                formulierType,
              ) !=
              projectSignatuur;
        });

    if (!moetBijwerken) {
      return OfferteVerdeelkostBijwerkingResultaat(
        opmetingen: alleOpmetingen,
        gewijzigd: false,
      );
    }

    final totaalAantalArtikelen = doelIndexen.fold<int>(0, (som, index) {
      return som + _aantalVoorOpmeting(alleOpmetingen[index], formulierType);
    });

    final aankoopTotaalVoorVerdeling = _rondBedragAf(
      doelIndexen.fold<double>(0.0, (som, index) {
        return som +
            _aankoopTotaalVoorLimiet(alleOpmetingen[index], formulierType);
      }),
    );

    final verdeeldeRegelsPerIndex =
        <int, List<OfferteToegepastePrijsregelModel>>{
          for (final index in doelIndexen)
            index: <OfferteToegepastePrijsregelModel>[],
        };

    final berekendOp = DateTime.now().toUtc().toIso8601String();
    final geselecteerdeUitsluitingen =
        _geselecteerdeVerdeelkostUitsluitingenVoorProject(
          alleOpmetingen: alleOpmetingen,
          klantSleutel: klantSleutel,
        );
    final verdeelRegels = profiel
        .regelsVoorCategorie(OffertePrijsCategorie.alleArtikelen)
        .where((regel) {
          if (!_isGeldigeVerdeelRegel(regel, profiel)) return false;
          final omschrijvingSleutel =
              gekoppeldeVerdeelkostSleutelVoorOmschrijving(regel.omschrijving);
          return !geselecteerdeUitsluitingen.prijsregelIds.contains(regel.id) &&
              !geselecteerdeUitsluitingen.omschrijvingSleutels.contains(
                omschrijvingSleutel,
              );
        })
        .toList(growable: false);

    for (final prijsregel in verdeelRegels) {
      if (_limietIsBereikt(
        prijsregel: prijsregel,
        aankoopTotaalVoorVerdeling: aankoopTotaalVoorVerdeling,
      )) {
        continue;
      }

      _verdeelPrijsregel(
        prijsregel: prijsregel,
        alleOpmetingen: alleOpmetingen,
        doelIndexen: doelIndexen,
        formulierType: formulierType,
        totaalAantalArtikelen: totaalAantalArtikelen,
        aankoopTotaalVoorVerdeling: aankoopTotaalVoorVerdeling,
        berekendOp: berekendOp,
        verdeeldeRegelsPerIndex: verdeeldeRegelsPerIndex,
      );
    }

    final bijgewerkteOpmetingen = List<OpmetingOverzichtRaamItem>.from(
      alleOpmetingen,
    );

    for (final index in doelIndexen) {
      bijgewerkteOpmetingen[index] = _werkVerdeelkostenBij(
        opmeting: bijgewerkteOpmetingen[index],
        formulierType: formulierType,
        prijsregels:
            verdeeldeRegelsPerIndex[index] ??
            const <OfferteToegepastePrijsregelModel>[],
        signatuur: projectSignatuur,
      );
    }

    for (final index in optieIndexen) {
      if (!_heeftVerdeelkosten(bijgewerkteOpmetingen[index], formulierType)) {
        continue;
      }

      bijgewerkteOpmetingen[index] = _werkVerdeelkostenBij(
        opmeting: bijgewerkteOpmetingen[index],
        formulierType: formulierType,
        prijsregels: const <OfferteToegepastePrijsregelModel>[],
        signatuur: '',
      );
    }

    return OfferteVerdeelkostBijwerkingResultaat(
      opmetingen: bijgewerkteOpmetingen,
      gewijzigd: true,
    );
  }

  static OfferteVerdeelkostBijwerkingResultaat
  stelGeselecteerdeProjectVerdeelkostDoelenIn({
    required List<OpmetingOverzichtRaamItem> alleOpmetingen,
    required String klantNaam,
    required OffertePrijsregelModel prijsregel,
    required Set<String> artikelIds,
  }) {
    final klantSleutel = klantNaam.trim().toLowerCase();
    final bronFormulierType =
        _canoniekFormulierType(prijsregel.formulierType).isNotEmpty
        ? _canoniekFormulierType(prijsregel.formulierType)
        : prijsregel.formulierType.trim();
    final bronPrijsregelId = prijsregel.id.trim();
    final gekoppeldeOmschrijvingSleutel = gekoppeldeVerdeelkostSleutel(
      prijsregel,
    );

    if (klantSleutel.isEmpty ||
        bronFormulierType.isEmpty ||
        bronPrijsregelId.isEmpty ||
        gekoppeldeOmschrijvingSleutel.isEmpty ||
        artikelIds.isEmpty ||
        !prijsregel.actief ||
        !prijsregel.isGeldig ||
        !prijsregel.isVerdeeldeProjectkost ||
        prijsregel.prijsExclBtw <= 0.0) {
      return OfferteVerdeelkostBijwerkingResultaat(
        opmetingen: alleOpmetingen,
        gewijzigd: false,
      );
    }

    final gekoppeldeMarkerId =
        'gekoppeld_${base64Url.encode(utf8.encode(gekoppeldeOmschrijvingSleutel)).replaceAll('=', '')}';
    final markerBronId = _maakGeselecteerdeVerdeelkostBronId(
      formulierType: bronFormulierType,
      prijsregelId: gekoppeldeMarkerId,
    );
    final markerId =
        '$_geselecteerdeVerdeelkostSelectiePrefix'
        '${_normaliseerFormulierType(bronFormulierType)}::$gekoppeldeMarkerId';
    final nu = DateTime.now().toUtc().toIso8601String();
    final resultaat = List<OpmetingOverzichtRaamItem>.from(alleOpmetingen);
    var gewijzigd = false;

    for (var index = 0; index < resultaat.length; index++) {
      final artikel = resultaat[index];
      if (artikel.klantNaam.trim().toLowerCase() != klantSleutel) {
        continue;
      }

      final prijsData =
          OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(artikel);
      if (prijsData == null) continue;

      // Een nieuwe selectie vervangt alle oude doelmarkeringen van dezelfde
      // gekoppelde kost, ook wanneer die uit een andere artikelgroep of oudere
      // versie met een andere interne regel-ID afkomstig zijn.
      final selecties = prijsData.vrijeArtikelPrijsSelecties
          .where(
            (selectie) => !_isZelfdeGeselecteerdeVerdeelkostSelectie(
              selectie: selectie,
              gekoppeldeOmschrijvingSleutel: gekoppeldeOmschrijvingSleutel,
              bronPrijsregelId: bronPrijsregelId,
              markerBronId: markerBronId,
            ),
          )
          .toList(growable: true);
      final isGeselecteerd =
          artikelIds.contains(artikel.id) &&
          !artikel.isVerwijderd &&
          artikel.teltMeeInHoofdofferte &&
          OfferteArtikelPrijsKoppelingService.koppelingVoorArtikel(artikel) !=
              null;

      if (isGeselecteerd) {
        selecties.add(
          OfferteVrijePrijsSelectieModel(
            id: markerId,
            bronPrijsregelId: markerBronId,
            omschrijving: prijsregel.omschrijving,
            bedragPerStukExclBtw: prijsregel.prijsExclBtw,
            eenheid: OffertePrijsEenheid.vast,
            uitschrijfmodus: prijsregel.uitschrijfmodus,
            bronPrijsPerStukExclBtw: prijsregel.prijsExclBtw,
            bronGewijzigdOp: prijsregel.gewijzigdOp,
            geselecteerdOp: nu,
            actief: true,
          ),
        );
      }

      if (_jsonLijstenGelijk(
        prijsData.vrijeArtikelPrijsSelecties
            .map((selectie) => selectie.toJson())
            .toList(growable: false),
        selecties.map((selectie) => selectie.toJson()).toList(growable: false),
      )) {
        continue;
      }

      final bijgewerktePrijsData = prijsData.copyWith(
        vrijeArtikelPrijsSelecties: selecties,
      );
      resultaat[index] = OfferteArtikelPrijsKoppelingService.schrijfPrijsData(
        artikel: artikel,
        prijsData: bijgewerktePrijsData,
      ).metNieuweWijzigingsDatum();
      gewijzigd = true;
    }

    return OfferteVerdeelkostBijwerkingResultaat(
      opmetingen: resultaat,
      gewijzigd: gewijzigd,
    );
  }

  static OfferteVerdeelkostBijwerkingResultaat
  werkGeselecteerdeProjectVerdeelkostenBij({
    required List<OpmetingOverzichtRaamItem> alleOpmetingen,
    required String klantNaam,
    required Map<String, OffertePrijsprofielModel> profielen,
  }) {
    final klantSleutel = klantNaam.trim().toLowerCase();
    if (klantSleutel.isEmpty) {
      return OfferteVerdeelkostBijwerkingResultaat(
        opmetingen: alleOpmetingen,
        gewijzigd: false,
      );
    }

    final resultaat = List<OpmetingOverzichtRaamItem>.from(alleOpmetingen);
    var gewijzigd = false;

    // Eerst alle doelmarkeringen groeperen. De omschrijving is de projectbrede
    // koppelsleutel: "transport" uit twee artikelgroepen blijft één kost.
    final groepen = <String, _GeselecteerdeVerdeelkostGroep>{};
    for (var index = 0; index < resultaat.length; index++) {
      final artikel = resultaat[index];
      if (artikel.isVerwijderd ||
          !artikel.teltMeeInHoofdofferte ||
          artikel.klantNaam.trim().toLowerCase() != klantSleutel) {
        continue;
      }
      final prijsData =
          OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(artikel);
      if (prijsData == null) continue;

      for (final selectie in prijsData.vrijeArtikelPrijsSelecties) {
        if (!selectie.actief ||
            !selectie.uitschrijfmodus.isVerdeeldeInterneKost) {
          continue;
        }
        final sleutel = _leesGeselecteerdeVerdeelkostSleutel(
          selectie.bronPrijsregelId,
        );
        if (sleutel == null) continue;
        final groepId = _geselecteerdeVerdeelkostGroepId(
          sleutel: sleutel,
          marker: selectie,
        );
        final groep = groepen.putIfAbsent(
          groepId,
          () => _GeselecteerdeVerdeelkostGroep(
            sleutel: sleutel,
            marker: selectie,
          ),
        );
        groep
          ..artikelIndexen.add(index)
          ..neemNieuwsteMarkerOver(selectie);
      }
    }

    final geselecteerdeOmschrijvingSleutels = groepen.values
        .map(
          (groep) => gekoppeldeVerdeelkostSleutelVoorOmschrijving(
            groep.marker.omschrijving,
          ),
        )
        .where((sleutel) => sleutel.isNotEmpty)
        .toSet();

    // Verwijder zowel eerder berekende selectiedelen als profielgebonden
    // duplicaten met dezelfde gekoppelde omschrijving. Anders kan een tweede
    // artikelgroep het volledige transportbedrag nogmaals toevoegen.
    for (var index = 0; index < resultaat.length; index++) {
      final artikel = resultaat[index];
      if (artikel.klantNaam.trim().toLowerCase() != klantSleutel) continue;
      final prijsData =
          OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(artikel);
      if (prijsData == null) continue;

      final behoudenRegels = prijsData.toegepasteVerdeeldePrijsregels
          .where((regel) {
            if (regel.bronPrijsregelId.startsWith(
              _geselecteerdeVerdeelkostBronPrefix,
            )) {
              return false;
            }
            if (!regel.uitschrijfmodus.isVerdeeldeInterneKost) return true;
            final omschrijvingSleutel =
                gekoppeldeVerdeelkostSleutelVoorOmschrijving(
                  regel.omschrijving,
                );
            return !geselecteerdeOmschrijvingSleutels.contains(
              omschrijvingSleutel,
            );
          })
          .toList(growable: false);

      if (behoudenRegels.length ==
          prijsData.toegepasteVerdeeldePrijsregels.length) {
        continue;
      }

      final bijgewerktePrijsData = prijsData.copyWith(
        toegepasteVerdeeldePrijsregels: behoudenRegels,
      );
      resultaat[index] = OfferteArtikelPrijsKoppelingService.schrijfPrijsData(
        artikel: artikel,
        prijsData: bijgewerktePrijsData,
      );
    }

    for (final groep in groepen.values) {
      final doelIndexen = groep.artikelIndexen.toList(growable: false);
      if (doelIndexen.isEmpty) continue;

      final profielRegel = _vindPrijsregelInProfielen(
        profielen: profielen,
        sleutel: groep.sleutel,
        marker: groep.marker,
      );
      if (profielRegel != null &&
          (!profielRegel.actief ||
              !profielRegel.isGeldig ||
              !profielRegel.isVerdeeldeProjectkost ||
              profielRegel.prijsExclBtw <= 0.0)) {
        continue;
      }

      final bron = _GeselecteerdeVerdeelkostBron.from(
        marker: groep.marker,
        profielRegel: profielRegel,
      );
      if (bron.projectPrijsExclBtw <= 0.0 || bron.omschrijving.isEmpty) {
        continue;
      }

      final totaalAantalArtikelen = doelIndexen.fold<int>(0, (som, index) {
        return som + _aantalVoorArtikel(resultaat[index]);
      });
      if (totaalAantalArtikelen <= 0) continue;

      final aankoopTotaalVoorVerdeling = _rondBedragAf(
        doelIndexen.fold<double>(0.0, (som, index) {
          return som + _aankoopTotaalVoorArtikel(resultaat[index]);
        }),
      );
      if (bron.heeftAankooplimiet &&
          (bron.verdeelLimietBedragExclBtw <= 0.0 ||
              aankoopTotaalVoorVerdeling >= bron.verdeelLimietBedragExclBtw)) {
        continue;
      }

      final regelsPerIndex = <int, List<OfferteToegepastePrijsregelModel>>{};
      for (final index in doelIndexen) {
        final prijsData =
            OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(
              resultaat[index],
            );
        if (prijsData == null) continue;
        regelsPerIndex[index] = List<OfferteToegepastePrijsregelModel>.from(
          prijsData.toegepasteVerdeeldePrijsregels,
        );
      }

      final toegepasteBronId = _maakGeselecteerdeVerdeelkostBronId(
        formulierType:
            profielRegel?.formulierType ??
            (groep.sleutel.formulierType.isNotEmpty
                ? groep.sleutel.formulierType
                : 'gekoppeld'),
        prijsregelId: groep.sleutel.prijsregelId,
      );
      _verdeelGeselecteerdePrijsregel(
        bronPrijsregelId: toegepasteBronId,
        bron: bron,
        alleOpmetingen: resultaat,
        doelIndexen: doelIndexen,
        totaalAantalArtikelen: totaalAantalArtikelen,
        aankoopTotaalVoorVerdeling: aankoopTotaalVoorVerdeling,
        verdeeldeRegelsPerIndex: regelsPerIndex,
      );

      for (final index in doelIndexen) {
        final prijsData =
            OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(
              resultaat[index],
            );
        if (prijsData == null) continue;
        final nieuweRegels =
            regelsPerIndex[index] ?? const <OfferteToegepastePrijsregelModel>[];
        if (_jsonLijstenGelijk(
          prijsData.toegepasteVerdeeldePrijsregels
              .map((regel) => regel.toJson())
              .toList(growable: false),
          nieuweRegels.map((regel) => regel.toJson()).toList(growable: false),
        )) {
          continue;
        }

        final bijgewerktePrijsData = prijsData.copyWith(
          toegepasteVerdeeldePrijsregels: nieuweRegels,
        );
        resultaat[index] = OfferteArtikelPrijsKoppelingService.schrijfPrijsData(
          artikel: resultaat[index],
          prijsData: bijgewerktePrijsData,
        );
      }
    }

    for (var index = 0; index < resultaat.length; index++) {
      final oudPrijsData =
          OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(
            alleOpmetingen[index],
          );
      final nieuwPrijsData =
          OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(
            resultaat[index],
          );
      if (oudPrijsData == null || nieuwPrijsData == null) continue;
      if (_jsonLijstenGelijk(
        oudPrijsData.toegepasteVerdeeldePrijsregels
            .map((regel) => regel.toJson())
            .toList(growable: false),
        nieuwPrijsData.toegepasteVerdeeldePrijsregels
            .map((regel) => regel.toJson())
            .toList(growable: false),
      )) {
        continue;
      }
      resultaat[index] = resultaat[index].metNieuweWijzigingsDatum();
      gewijzigd = true;
    }

    return OfferteVerdeelkostBijwerkingResultaat(
      opmetingen: resultaat,
      gewijzigd: gewijzigd,
    );
  }

  static _GeselecteerdeVerdeelkostUitsluitingen
  _geselecteerdeVerdeelkostUitsluitingenVoorProject({
    required List<OpmetingOverzichtRaamItem> alleOpmetingen,
    required String klantSleutel,
  }) {
    final prijsregelIds = <String>{};
    final omschrijvingSleutels = <String>{};

    for (final artikel in alleOpmetingen) {
      if (artikel.klantNaam.trim().toLowerCase() != klantSleutel) continue;
      final prijsData =
          OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(artikel);
      if (prijsData == null) continue;

      for (final selectie in prijsData.vrijeArtikelPrijsSelecties) {
        if (!selectie.actief ||
            !selectie.uitschrijfmodus.isVerdeeldeInterneKost) {
          continue;
        }
        final sleutel = _leesGeselecteerdeVerdeelkostSleutel(
          selectie.bronPrijsregelId,
        );
        if (sleutel == null) continue;
        if (sleutel.prijsregelId.isNotEmpty) {
          prijsregelIds.add(sleutel.prijsregelId);
        }
        final omschrijvingSleutel =
            gekoppeldeVerdeelkostSleutelVoorOmschrijving(selectie.omschrijving);
        if (omschrijvingSleutel.isNotEmpty) {
          omschrijvingSleutels.add(omschrijvingSleutel);
        }
      }
    }

    return _GeselecteerdeVerdeelkostUitsluitingen(
      prijsregelIds: prijsregelIds,
      omschrijvingSleutels: omschrijvingSleutels,
    );
  }

  static bool _isZelfdeGeselecteerdeVerdeelkostSelectie({
    required OfferteVrijePrijsSelectieModel selectie,
    required String gekoppeldeOmschrijvingSleutel,
    required String bronPrijsregelId,
    required String markerBronId,
  }) {
    if (!selectie.uitschrijfmodus.isVerdeeldeInterneKost) return false;
    if (selectie.bronPrijsregelId == markerBronId) return true;

    final selectieOmschrijvingSleutel =
        gekoppeldeVerdeelkostSleutelVoorOmschrijving(selectie.omschrijving);
    if (selectieOmschrijvingSleutel.isNotEmpty &&
        selectieOmschrijvingSleutel == gekoppeldeOmschrijvingSleutel) {
      return true;
    }

    final sleutel = _leesGeselecteerdeVerdeelkostSleutel(
      selectie.bronPrijsregelId,
    );
    return sleutel?.prijsregelId == bronPrijsregelId;
  }

  static String _maakGeselecteerdeVerdeelkostBronId({
    required String formulierType,
    required String prijsregelId,
  }) {
    return '$_geselecteerdeVerdeelkostBronPrefix'
        '${_normaliseerFormulierType(formulierType)}::$prijsregelId';
  }

  static _GeselecteerdeVerdeelkostSleutel? _leesGeselecteerdeVerdeelkostSleutel(
    String bronPrijsregelId,
  ) {
    if (bronPrijsregelId.startsWith(_geselecteerdeVerdeelkostBronPrefix)) {
      final rest = bronPrijsregelId.substring(
        _geselecteerdeVerdeelkostBronPrefix.length,
      );
      final scheiding = rest.indexOf('::');
      if (scheiding <= 0 || scheiding >= rest.length - 2) return null;
      return _GeselecteerdeVerdeelkostSleutel(
        formulierType: rest.substring(0, scheiding),
        prijsregelId: rest.substring(scheiding + 2),
      );
    }

    // Compatibiliteit met selecties die door de eerdere projectknop werden
    // opgeslagen als `toegepast_project_<doeltype>_<bron-id>`. De doeltypes
    // verschilden per positie; door het doeltype af te strippen worden deze
    // oude selecties opnieuw als één gemengde verdeelgroep herkend.
    if (bronPrijsregelId.startsWith(_oudeToegepasteProjectPrijsPrefix)) {
      final rest = bronPrijsregelId.substring(
        _oudeToegepasteProjectPrijsPrefix.length,
      );
      final formulierSleutels =
          OfferteArtikelPrijsKoppelingService.alleKoppelingen
              .map(
                (koppeling) =>
                    _normaliseerFormulierType(koppeling.formulierType),
              )
              .where((sleutel) => sleutel.isNotEmpty)
              .toSet()
              .toList(growable: false)
            ..sort((eerste, tweede) => tweede.length.compareTo(eerste.length));

      for (final formulierSleutel in formulierSleutels) {
        final prefix = '${formulierSleutel}_';
        if (!rest.startsWith(prefix) || rest.length <= prefix.length) {
          continue;
        }
        return _GeselecteerdeVerdeelkostSleutel(
          formulierType: '',
          prijsregelId: rest.substring(prefix.length),
        );
      }
    }

    return null;
  }

  static String _geselecteerdeVerdeelkostGroepId({
    required _GeselecteerdeVerdeelkostSleutel sleutel,
    required OfferteVrijePrijsSelectieModel marker,
  }) {
    final omschrijvingSleutel = gekoppeldeVerdeelkostSleutelVoorOmschrijving(
      marker.omschrijving,
    );
    if (omschrijvingSleutel.isNotEmpty) {
      return 'omschrijving::$omschrijvingSleutel';
    }
    return 'prijsregel::${sleutel.prijsregelId}';
  }

  static OffertePrijsregelModel? _vindPrijsregelInProfielen({
    required Map<String, OffertePrijsprofielModel> profielen,
    required _GeselecteerdeVerdeelkostSleutel sleutel,
    required OfferteVrijePrijsSelectieModel marker,
  }) {
    // De omschrijving is de gekoppelde identiteit. Neem daarom de nieuwste
    // gelijknamige profielregel, ongeacht de interne ID of artikelgroep.
    final omschrijvingSleutel = gekoppeldeVerdeelkostSleutelVoorOmschrijving(
      marker.omschrijving,
    );
    OffertePrijsregelModel? nieuwste;
    for (final entry in profielen.entries) {
      for (final regel in entry.value.regelsVoorCategorie(
        OffertePrijsCategorie.alleArtikelen,
      )) {
        if (!regel.isVerdeeldeProjectkost ||
            gekoppeldeVerdeelkostSleutelVoorOmschrijving(regel.omschrijving) !=
                omschrijvingSleutel) {
          continue;
        }
        if (nieuwste == null ||
            regel.gewijzigdOp.compareTo(nieuwste.gewijzigdOp) > 0) {
          nieuwste = regel;
        }
      }
    }
    if (nieuwste != null) return nieuwste;

    // Compatibiliteit met oude selecties waarvan alleen de bron-ID bekend is.
    for (final entry in profielen.entries) {
      if (sleutel.formulierType.isNotEmpty &&
          !_isZelfdeFormulierType(entry.key, sleutel.formulierType) &&
          !_isZelfdeFormulierType(
            entry.value.formulierType,
            sleutel.formulierType,
          )) {
        continue;
      }
      for (final regel in entry.value.regelsVoorCategorie(
        OffertePrijsCategorie.alleArtikelen,
      )) {
        if (regel.id == sleutel.prijsregelId) return regel;
      }
    }
    return null;
  }

  static int _aantalVoorArtikel(OpmetingOverzichtRaamItem artikel) {
    final aantal = OfferteArtikelPrijsKoppelingService.aantalVoorArtikel(
      artikel,
    );
    return aantal < 1 ? 1 : aantal;
  }

  static double _aankoopTotaalVoorArtikel(OpmetingOverzichtRaamItem artikel) {
    return OfferteArtikelPrijsKoppelingService.resultaatVoorArtikel(
          artikel,
          kortingToestaan: false,
        )?.aankoopTotaalVoorLimietExclBtw ??
        0.0;
  }

  static void _verdeelGeselecteerdePrijsregel({
    required String bronPrijsregelId,
    required _GeselecteerdeVerdeelkostBron bron,
    required List<OpmetingOverzichtRaamItem> alleOpmetingen,
    required List<int> doelIndexen,
    required int totaalAantalArtikelen,
    required double aankoopTotaalVoorVerdeling,
    required Map<int, List<OfferteToegepastePrijsregelModel>>
    verdeeldeRegelsPerIndex,
  }) {
    final totaalCenten = (_rondBedragAf(bron.projectPrijsExclBtw) * 100.0)
        .round();
    if (totaalCenten <= 0 || totaalAantalArtikelen <= 0) return;

    final basisCentenPerArtikel = totaalCenten ~/ totaalAantalArtikelen;
    var resterendeCenten = totaalCenten % totaalAantalArtikelen;

    for (final index in doelIndexen) {
      final aantalInPositie = _aantalVoorArtikel(alleOpmetingen[index]);
      final extraCentenInPositie = math
          .min(resterendeCenten, aantalInPositie)
          .toInt();
      final positieCenten =
          (basisCentenPerArtikel * aantalInPositie) + extraCentenInPositie;
      resterendeCenten -= extraCentenInPositie;
      if (positieCenten <= 0) continue;

      final positieTotaal = positieCenten.toDouble() / 100.0;
      final gemiddeldePrijsPerArtikel =
          positieTotaal / aantalInPositie.toDouble();
      verdeeldeRegelsPerIndex[index]?.add(
        OfferteToegepastePrijsregelModel(
          bronPrijsregelId: bronPrijsregelId,
          categorie: OffertePrijsCategorie.alleArtikelen,
          omschrijving: bron.omschrijving,
          prijsExclBtw: _rondHoeveelheidAf(gemiddeldePrijsPerArtikel),
          eenheid: OffertePrijsEenheid.vast,
          hoeveelheid: aantalInPositie.toDouble(),
          totaalExclBtw: positieTotaal,
          uitschrijfmodus: bron.uitschrijfmodus,
          verdeeldOverAantalArtikelen: totaalAantalArtikelen,
          projectPrijsExclBtw: bron.projectPrijsExclBtw,
          aankoopTotaalVoorVerdelingExclBtw: aankoopTotaalVoorVerdeling,
          verdeelLimietBedragExclBtw: bron.verdeelLimietBedragExclBtw,
          bronGewijzigdOp: bron.bronGewijzigdOp,
          berekendOp: bron.berekendOp,
        ),
      );
    }
  }

  static bool _jsonLijstenGelijk(List<Object?> eerste, List<Object?> tweede) {
    return jsonEncode(eerste) == jsonEncode(tweede);
  }

  static bool _isDoelOpmeting(
    OpmetingOverzichtRaamItem opmeting,
    String klantSleutel,
    String formulierType,
  ) {
    return !opmeting.isVerwijderd &&
        opmeting.teltMeeInHoofdofferte &&
        opmeting.klantNaam.trim().toLowerCase() == klantSleutel &&
        _isZelfdeFormulierType(
          opmeting.formulierTypeGenormaliseerd,
          formulierType,
        ) &&
        _heeftGeldigPrijsmodel(opmeting, formulierType);
  }

  static bool _isOptieOpmeting(
    OpmetingOverzichtRaamItem opmeting,
    String klantSleutel,
    String formulierType,
  ) {
    return opmeting.isZichtbareOfferteOptie &&
        opmeting.klantNaam.trim().toLowerCase() == klantSleutel &&
        _isZelfdeFormulierType(
          opmeting.formulierTypeGenormaliseerd,
          formulierType,
        ) &&
        _heeftGeldigPrijsmodel(opmeting, formulierType);
  }

  static bool _heeftGeldigPrijsmodel(
    OpmetingOverzichtRaamItem opmeting,
    String formulierType,
  ) {
    final koppeling = OfferteArtikelPrijsKoppelingService.koppelingVoorArtikel(
      opmeting,
    );
    return koppeling != null &&
        _isZelfdeFormulierType(koppeling.formulierType, formulierType);
  }

  static bool _heeftVerdeelkosten(
    OpmetingOverzichtRaamItem opmeting,
    String formulierType,
  ) {
    if (!_heeftGeldigPrijsmodel(opmeting, formulierType)) return false;
    final prijsData = OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(
      opmeting,
    );
    return prijsData != null &&
        (prijsData.toegepasteVerdeeldePrijsregels.isNotEmpty ||
            prijsData.verdeeldePrijsSignatuur.isNotEmpty);
  }

  static List<OpmetingOverzichtRaamItem> _maakOptiesZonderVerdeelkosten({
    required List<OpmetingOverzichtRaamItem> alleOpmetingen,
    required List<int> optieIndexen,
    required String formulierType,
  }) {
    final resultaat = List<OpmetingOverzichtRaamItem>.from(alleOpmetingen);

    for (final index in optieIndexen) {
      if (!_heeftVerdeelkosten(resultaat[index], formulierType)) {
        continue;
      }

      resultaat[index] = _werkVerdeelkostenBij(
        opmeting: resultaat[index],
        formulierType: formulierType,
        prijsregels: const <OfferteToegepastePrijsregelModel>[],
        signatuur: '',
      );
    }

    return resultaat;
  }

  static OpmetingOverzichtRaamItem _werkVerdeelkostenBij({
    required OpmetingOverzichtRaamItem opmeting,
    required String formulierType,
    required List<OfferteToegepastePrijsregelModel> prijsregels,
    required String signatuur,
  }) {
    if (!_heeftGeldigPrijsmodel(opmeting, formulierType)) return opmeting;

    final prijsData = OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(
      opmeting,
    );
    if (prijsData == null) return opmeting;

    final bijgewerktePrijsData = prijsData.copyWith(
      toegepasteVerdeeldePrijsregels: prijsregels,
      verdeeldePrijsSignatuur: signatuur,
    );

    return OfferteArtikelPrijsKoppelingService.schrijfPrijsData(
      artikel: opmeting,
      prijsData: bijgewerktePrijsData,
    ).metNieuweWijzigingsDatum();
  }

  static String _verdeeldePrijsSignatuur(
    OpmetingOverzichtRaamItem opmeting,
    String formulierType,
  ) {
    if (!_heeftGeldigPrijsmodel(opmeting, formulierType)) return '';
    return OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(
          opmeting,
        )?.verdeeldePrijsSignatuur ??
        '';
  }

  static int _aantalVoorOpmeting(
    OpmetingOverzichtRaamItem opmeting,
    String formulierType,
  ) {
    if (!_heeftGeldigPrijsmodel(opmeting, formulierType)) return 1;
    final aantal = OfferteArtikelPrijsKoppelingService.aantalVoorArtikel(
      opmeting,
    );
    return aantal < 1 ? 1 : aantal;
  }

  static double _aankoopTotaalVoorLimiet(
    OpmetingOverzichtRaamItem opmeting,
    String formulierType,
  ) {
    if (!_heeftGeldigPrijsmodel(opmeting, formulierType)) return 0.0;
    return OfferteArtikelPrijsKoppelingService.resultaatVoorArtikel(
          opmeting,
          kortingToestaan: false,
        )?.aankoopTotaalVoorLimietExclBtw ??
        0.0;
  }

  static bool _isGeldigeVerdeelRegel(
    OffertePrijsregelModel prijsregel,
    OffertePrijsprofielModel profiel,
  ) {
    return prijsregel.actief &&
        prijsregel.isGeldig &&
        prijsregel.isVerdeeldeProjectkost &&
        _isZelfdeFormulierType(prijsregel.formulierType, profiel.formulierType);
  }

  static bool _limietIsBereikt({
    required OffertePrijsregelModel prijsregel,
    required double aankoopTotaalVoorVerdeling,
  }) {
    if (prijsregel.verdeelLimietmodus !=
        OffertePrijsVerdeelLimietmodus.metAankooplimiet) {
      return false;
    }

    final limiet = prijsregel.verdeelLimietBedragExclBtw;
    if (limiet <= 0.0) {
      return true;
    }

    return aankoopTotaalVoorVerdeling >= limiet;
  }

  static void _verdeelPrijsregel({
    required OffertePrijsregelModel prijsregel,
    required List<OpmetingOverzichtRaamItem> alleOpmetingen,
    required List<int> doelIndexen,
    required String formulierType,
    required int totaalAantalArtikelen,
    required double aankoopTotaalVoorVerdeling,
    required String berekendOp,
    required Map<int, List<OfferteToegepastePrijsregelModel>>
    verdeeldeRegelsPerIndex,
  }) {
    if (totaalAantalArtikelen <= 0) {
      return;
    }

    final totaalCenten = (_rondBedragAf(prijsregel.prijsExclBtw) * 100.0)
        .round();
    if (totaalCenten <= 0) {
      return;
    }

    final basisCentenPerArtikel = totaalCenten ~/ totaalAantalArtikelen;
    var resterendeCenten = totaalCenten % totaalAantalArtikelen;

    for (final index in doelIndexen) {
      final aantalInPositie = _aantalVoorOpmeting(
        alleOpmetingen[index],
        formulierType,
      );
      final int extraCentenInPositie = math
          .min(resterendeCenten, aantalInPositie)
          .toInt();
      final positieCenten =
          (basisCentenPerArtikel * aantalInPositie) + extraCentenInPositie;
      resterendeCenten -= extraCentenInPositie;

      if (positieCenten <= 0) {
        continue;
      }

      final positieTotaal = positieCenten.toDouble() / 100.0;
      final gemiddeldePrijsPerArtikel =
          positieTotaal / aantalInPositie.toDouble();

      verdeeldeRegelsPerIndex[index]!.add(
        OfferteToegepastePrijsregelModel(
          bronPrijsregelId: prijsregel.id,
          categorie: prijsregel.categorie,
          omschrijving: prijsregel.omschrijving,
          prijsExclBtw: _rondHoeveelheidAf(gemiddeldePrijsPerArtikel),
          eenheid: OffertePrijsEenheid.vast,
          hoeveelheid: aantalInPositie.toDouble(),
          totaalExclBtw: positieTotaal,
          uitschrijfmodus: prijsregel.uitschrijfmodus,
          verdeeldOverAantalArtikelen: totaalAantalArtikelen,
          projectPrijsExclBtw: prijsregel.prijsExclBtw,
          aankoopTotaalVoorVerdelingExclBtw: aankoopTotaalVoorVerdeling,
          verdeelLimietBedragExclBtw: prijsregel.verdeelLimietBedragExclBtw,
          bronGewijzigdOp: prijsregel.gewijzigdOp,
          berekendOp: berekendOp,
        ),
      );
    }
  }

  static String _maakProjectSignatuur({
    required List<OpmetingOverzichtRaamItem> alleOpmetingen,
    required List<int> doelIndexen,
    required OffertePrijsprofielModel profiel,
    required String formulierType,
  }) {
    final gegevens = doelIndexen
        .map((index) {
          final opmeting = alleOpmetingen[index];
          final prijsData =
              OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(
                opmeting,
              )!;

          return <String, Object?>{
            'id': opmeting.id,
            'aantal': _aantalVoorOpmeting(opmeting, formulierType),
            'breedteMm':
                OfferteArtikelPrijsKoppelingService.breedteMmVoorArtikel(
                  opmeting,
                ),
            'hoogteMm': OfferteArtikelPrijsKoppelingService.hoogteMmVoorArtikel(
              opmeting,
            ),
            'prijsPerStukExclBtw': prijsData.prijsPerStukExclBtw,
            'technischePrijsSignatuur': prijsData.technischePrijsSignatuur,
            'technischePrijsregels': prijsData.toegepasteTechnischePrijsregels
                .map(
                  (regel) => <String, Object?>{
                    'id': regel.bronPrijsregelId,
                    'totaalExclBtw': regel.totaalExclBtw,
                    'bronGewijzigdOp': regel.bronGewijzigdOp,
                  },
                )
                .toList(growable: false),
            'vrijeArtikelPrijsSignatuur': prijsData.vrijeArtikelPrijsSignatuur,
            'vrijeArtikelPrijsSelecties': prijsData.vrijeArtikelPrijsSelecties
                .map(
                  (selectie) => <String, Object?>{
                    'id': selectie.id,
                    'bronPrijsregelId': selectie.bronPrijsregelId,
                    'omschrijving': selectie.omschrijving,
                    'bedragPerStukExclBtw': selectie.bedragPerStukExclBtw,
                    'eenheid': selectie.eenheid.jsonWaarde,
                    'uitschrijfmodus': selectie.uitschrijfmodus.jsonWaarde,
                    'actief': selectie.actief,
                  },
                )
                .toList(growable: false),
          };
        })
        .toList(growable: false);

    final profielGegevens = profiel
        .regelsVoorCategorie(OffertePrijsCategorie.alleArtikelen)
        .where(
          (regel) => _isZelfdeFormulierType(regel.formulierType, formulierType),
        )
        .map(
          (regel) => <String, Object?>{
            'id': regel.id,
            'actief': regel.actief,
            'omschrijving': regel.omschrijving,
            'prijsExclBtw': regel.prijsExclBtw,
            'eenheid': regel.eenheid.jsonWaarde,
            'uitschrijfmodus': regel.uitschrijfmodus.jsonWaarde,
            'verdeelLimietmodus': regel.verdeelLimietmodus.jsonWaarde,
            'verdeelLimietBedragExclBtw': regel.verdeelLimietBedragExclBtw,
            'volgorde': regel.volgorde,
          },
        )
        .toList(growable: false);

    return jsonEncode(<String, Object?>{
      'formulierType': formulierType,
      'artikelen': gegevens,
      'prijsprofiel': profielGegevens,
    });
  }

  static String _canoniekFormulierType(String formulierType) {
    return OfferteArtikelPrijsKoppelingService.koppelingVoorFormulierType(
          formulierType,
        )?.formulierType ??
        '';
  }

  static bool _isZelfdeFormulierType(String eerste, String tweede) {
    return _normaliseerFormulierType(eerste) ==
        _normaliseerFormulierType(tweede);
  }

  static String _normaliseerFormulierType(String waarde) {
    return waarde.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  static String _normaliseerGekoppeldeOmschrijving(String waarde) {
    return waarde.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
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

class _GeselecteerdeVerdeelkostUitsluitingen {
  const _GeselecteerdeVerdeelkostUitsluitingen({
    required this.prijsregelIds,
    required this.omschrijvingSleutels,
  });

  final Set<String> prijsregelIds;
  final Set<String> omschrijvingSleutels;
}

class _GeselecteerdeVerdeelkostSleutel {
  const _GeselecteerdeVerdeelkostSleutel({
    required this.formulierType,
    required this.prijsregelId,
  });

  final String formulierType;
  final String prijsregelId;
}

class _GeselecteerdeVerdeelkostGroep {
  _GeselecteerdeVerdeelkostGroep({required this.sleutel, required this.marker});

  final _GeselecteerdeVerdeelkostSleutel sleutel;
  OfferteVrijePrijsSelectieModel marker;
  final Set<int> artikelIndexen = <int>{};

  void neemNieuwsteMarkerOver(OfferteVrijePrijsSelectieModel kandidaat) {
    if (kandidaat.geselecteerdOp.compareTo(marker.geselecteerdOp) > 0) {
      marker = kandidaat;
    }
  }
}

class _GeselecteerdeVerdeelkostBron {
  const _GeselecteerdeVerdeelkostBron({
    required this.omschrijving,
    required this.projectPrijsExclBtw,
    required this.uitschrijfmodus,
    required this.heeftAankooplimiet,
    required this.verdeelLimietBedragExclBtw,
    required this.bronGewijzigdOp,
    required this.berekendOp,
  });

  final String omschrijving;
  final double projectPrijsExclBtw;
  final OffertePrijsUitschrijfmodus uitschrijfmodus;
  final bool heeftAankooplimiet;
  final double verdeelLimietBedragExclBtw;
  final String bronGewijzigdOp;
  final String berekendOp;

  factory _GeselecteerdeVerdeelkostBron.from({
    required OfferteVrijePrijsSelectieModel marker,
    required OffertePrijsregelModel? profielRegel,
  }) {
    final bronGewijzigdOp = profielRegel?.gewijzigdOp.trim().isNotEmpty == true
        ? profielRegel!.gewijzigdOp
        : marker.bronGewijzigdOp;
    final berekendOp = bronGewijzigdOp.compareTo(marker.geselecteerdOp) >= 0
        ? bronGewijzigdOp
        : marker.geselecteerdOp;
    return _GeselecteerdeVerdeelkostBron(
      omschrijving: profielRegel?.omschrijving.trim().isNotEmpty == true
          ? profielRegel!.omschrijving
          : marker.omschrijving,
      projectPrijsExclBtw:
          profielRegel?.prijsExclBtw ??
          (marker.bronPrijsPerStukExclBtw > 0.0
              ? marker.bronPrijsPerStukExclBtw
              : marker.bedragPerStukExclBtw),
      uitschrijfmodus: profielRegel?.uitschrijfmodus ?? marker.uitschrijfmodus,
      heeftAankooplimiet:
          profielRegel?.verdeelLimietmodus ==
          OffertePrijsVerdeelLimietmodus.metAankooplimiet,
      verdeelLimietBedragExclBtw:
          profielRegel?.verdeelLimietBedragExclBtw ?? 0.0,
      bronGewijzigdOp: bronGewijzigdOp,
      berekendOp: berekendOp,
    );
  }
}
