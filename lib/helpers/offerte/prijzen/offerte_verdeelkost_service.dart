import 'dart:convert';
import 'dart:math' as math;

import '../../opmeting/overzicht/opmeting_overzicht_model.dart';
import 'offerte_artikel_prijs_koppeling_service.dart';
import 'offerte_prijs_categorie.dart';
import 'offerte_prijs_eenheid.dart';
import 'offerte_prijs_verdeel_limietmodus.dart';
import 'offerte_prijsprofiel_model.dart';
import 'offerte_prijsregel_model.dart';
import 'offerte_toegepaste_prijsregel_model.dart';

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
    final verdeelRegels = profiel
        .regelsVoorCategorie(OffertePrijsCategorie.alleArtikelen)
        .where((regel) => _isGeldigeVerdeelRegel(regel, profiel))
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
    return !opmeting.isVerwijderd &&
        opmeting.isOfferteOptie &&
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
