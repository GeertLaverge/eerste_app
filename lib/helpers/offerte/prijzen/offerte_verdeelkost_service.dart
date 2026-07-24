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

  /// Behouden voor bestaande aanroepen die slechts één prijsprofiel verwerken.
  ///
  /// Nieuwe projectbrede berekeningen gebruiken bij voorkeur
  /// [werkGedeeldeMomentopnamesBij], zodat verdeelkosten met hetzelfde ID over
  /// meerdere artikelgroepen samen kunnen worden verdeeld.
  static OfferteVerdeelkostBijwerkingResultaat werkMomentopnamesBij({
    required List<OpmetingOverzichtRaamItem> alleOpmetingen,
    required String klantNaam,
    required OffertePrijsprofielModel profiel,
    bool forceer = false,
  }) {
    return werkGedeeldeMomentopnamesBij(
      alleOpmetingen: alleOpmetingen,
      klantNaam: klantNaam,
      profielen: <String, OffertePrijsprofielModel>{
        profiel.formulierType: profiel,
      },
      forceer: forceer,
    );
  }

  /// Verwerkt alle interne verdeelkosten projectbreed.
  ///
  /// Prijsregels met hetzelfde [OffertePrijsregelModel.id] vormen één gedeelde
  /// verdeelgroep. Het bedrag wordt één keer genomen en verdeeld over alle
  /// hoofdartikelen waarvan het formuliertype aan die groep gekoppeld is.
  static OfferteVerdeelkostBijwerkingResultaat werkGedeeldeMomentopnamesBij({
    required List<OpmetingOverzichtRaamItem> alleOpmetingen,
    required String klantNaam,
    required Map<String, OffertePrijsprofielModel> profielen,
    bool forceer = false,
  }) {
    final klantSleutel = klantNaam.trim().toLowerCase();

    if (klantSleutel.isEmpty || profielen.isEmpty) {
      return OfferteVerdeelkostBijwerkingResultaat(
        opmetingen: alleOpmetingen,
        gewijzigd: false,
      );
    }

    final profielenPerType = _normaliseerProfielen(profielen);

    if (profielenPerType.isEmpty) {
      return OfferteVerdeelkostBijwerkingResultaat(
        opmetingen: alleOpmetingen,
        gewijzigd: false,
      );
    }

    final ondersteundeFormulierTypes = profielenPerType.keys.toSet();

    final doelIndexen = <int>[];
    final optieIndexen = <int>[];

    for (var index = 0; index < alleOpmetingen.length; index++) {
      final opmeting = alleOpmetingen[index];

      if (_isDoelOpmeting(
        opmeting: opmeting,
        klantSleutel: klantSleutel,
        ondersteundeFormulierTypes: ondersteundeFormulierTypes,
      )) {
        doelIndexen.add(index);
        continue;
      }

      if (_isOptieOpmeting(
        opmeting: opmeting,
        klantSleutel: klantSleutel,
        ondersteundeFormulierTypes: ondersteundeFormulierTypes,
      )) {
        optieIndexen.add(index);
      }
    }

    final verdeelgroepen = _bouwVerdeelgroepen(profielenPerType);

    final projectSignatuur = verdeelgroepen.isEmpty
        ? ''
        : _maakProjectSignatuur(
            alleOpmetingen: alleOpmetingen,
            doelIndexen: doelIndexen,
            verdeelgroepen: verdeelgroepen,
          );

    final optiesMetVerdeelkosten = optieIndexen.any(
      (index) => _heeftVerdeelkosten(alleOpmetingen[index]),
    );

    final hoofdartikelenMoetenBijwerken = doelIndexen.any((index) {
      final opmeting = alleOpmetingen[index];
      final huidigeSignatuur = _verdeeldePrijsSignatuur(opmeting);

      if (huidigeSignatuur != projectSignatuur) {
        return true;
      }

      if (projectSignatuur.isEmpty && _heeftVerdeelkosten(opmeting)) {
        return true;
      }

      return false;
    });

    final moetBijwerken =
        forceer || optiesMetVerdeelkosten || hoofdartikelenMoetenBijwerken;

    if (!moetBijwerken) {
      return OfferteVerdeelkostBijwerkingResultaat(
        opmetingen: alleOpmetingen,
        gewijzigd: false,
      );
    }

    final verdeeldeRegelsPerIndex =
        <int, List<OfferteToegepastePrijsregelModel>>{
          for (final index in doelIndexen)
            index: <OfferteToegepastePrijsregelModel>[],
        };

    final berekendOp = DateTime.now().toUtc().toIso8601String();

    for (final verdeelgroep in verdeelgroepen) {
      final prijsregel = verdeelgroep.prijsregel;

      if (!prijsregel.actief ||
          !prijsregel.isGeldig ||
          !prijsregel.isVerdeeldeProjectkost) {
        continue;
      }

      final groepDoelIndexen = doelIndexen
          .where((index) {
            final formulierType = _formulierTypeVoorOpmeting(
              alleOpmetingen[index],
            );

            return verdeelgroep.formulierTypes.contains(formulierType);
          })
          .toList(growable: false);

      if (groepDoelIndexen.isEmpty) {
        continue;
      }

      final totaalAantalArtikelen = groepDoelIndexen.fold<int>(0, (som, index) {
        return som + _aantalVoorOpmeting(alleOpmetingen[index]);
      });

      if (totaalAantalArtikelen <= 0) {
        continue;
      }

      final aankoopTotaalVoorVerdeling = _rondBedragAf(
        groepDoelIndexen.fold<double>(0.0, (som, index) {
          return som + _aankoopTotaalVoorLimiet(alleOpmetingen[index]);
        }),
      );

      if (_limietIsBereikt(
        prijsregel: prijsregel,
        aankoopTotaalVoorVerdeling: aankoopTotaalVoorVerdeling,
      )) {
        continue;
      }

      _verdeelPrijsregel(
        prijsregel: prijsregel,
        alleOpmetingen: alleOpmetingen,
        doelIndexen: groepDoelIndexen,
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
      final prijsregels =
          verdeeldeRegelsPerIndex[index] ??
          const <OfferteToegepastePrijsregelModel>[];

      final gesorteerdePrijsregels =
          List<OfferteToegepastePrijsregelModel>.from(prijsregels)
            ..sort((eerste, tweede) {
              final omschrijvingVergelijking = eerste.omschrijving
                  .toLowerCase()
                  .compareTo(tweede.omschrijving.toLowerCase());

              if (omschrijvingVergelijking != 0) {
                return omschrijvingVergelijking;
              }

              return eerste.bronPrijsregelId.compareTo(tweede.bronPrijsregelId);
            });

      bijgewerkteOpmetingen[index] = _werkVerdeelkostenBij(
        opmeting: bijgewerkteOpmetingen[index],
        prijsregels: gesorteerdePrijsregels,
        signatuur: projectSignatuur,
      );
    }

    for (final index in optieIndexen) {
      if (!_heeftVerdeelkosten(bijgewerkteOpmetingen[index])) {
        continue;
      }

      bijgewerkteOpmetingen[index] = _werkVerdeelkostenBij(
        opmeting: bijgewerkteOpmetingen[index],
        prijsregels: const <OfferteToegepastePrijsregelModel>[],
        signatuur: '',
      );
    }

    return OfferteVerdeelkostBijwerkingResultaat(
      opmetingen: bijgewerkteOpmetingen,
      gewijzigd: true,
    );
  }

  static Map<String, OffertePrijsprofielModel> _normaliseerProfielen(
    Map<String, OffertePrijsprofielModel> profielen,
  ) {
    final resultaat = <String, OffertePrijsprofielModel>{};

    for (final profiel in profielen.values) {
      final formulierType = _canoniekFormulierType(profiel.formulierType);

      if (formulierType.isEmpty) {
        continue;
      }

      resultaat[formulierType] = profiel;
    }

    return resultaat;
  }

  static List<_GedeeldeVerdeelgroep> _bouwVerdeelgroepen(
    Map<String, OffertePrijsprofielModel> profielenPerType,
  ) {
    final groepenPerId = <String, _GedeeldeVerdeelgroep>{};

    for (final entry in profielenPerType.entries) {
      final formulierType = entry.key;
      final profiel = entry.value;

      final verdeelregels = profiel
          .regelsVoorCategorie(OffertePrijsCategorie.alleArtikelen)
          .where((prijsregel) {
            return prijsregel.isGeldig &&
                prijsregel.isVerdeeldeProjectkost &&
                _isZelfdeFormulierType(prijsregel.formulierType, formulierType);
          });

      for (final prijsregel in verdeelregels) {
        final groepId = prijsregel.id.trim();

        if (groepId.isEmpty) {
          continue;
        }

        final bestaandeGroep = groepenPerId[groepId];

        if (bestaandeGroep == null) {
          groepenPerId[groepId] = _GedeeldeVerdeelgroep(
            prijsregel: prijsregel,
            formulierTypes: <String>{formulierType},
          );
          continue;
        }

        bestaandeGroep.formulierTypes.add(formulierType);

        if (_isNieuwer(
          prijsregel.gewijzigdOp,
          bestaandeGroep.prijsregel.gewijzigdOp,
        )) {
          bestaandeGroep.prijsregel = prijsregel;
        }
      }
    }

    final resultaat = groepenPerId.values.toList(growable: false)
      ..sort((eerste, tweede) {
        final omschrijvingVergelijking = eerste.prijsregel.omschrijving
            .toLowerCase()
            .compareTo(tweede.prijsregel.omschrijving.toLowerCase());

        if (omschrijvingVergelijking != 0) {
          return omschrijvingVergelijking;
        }

        return eerste.prijsregel.id.compareTo(tweede.prijsregel.id);
      });

    return resultaat;
  }

  static bool _isDoelOpmeting({
    required OpmetingOverzichtRaamItem opmeting,
    required String klantSleutel,
    required Set<String> ondersteundeFormulierTypes,
  }) {
    return !opmeting.isVerwijderd &&
        opmeting.teltMeeInHoofdofferte &&
        opmeting.klantNaam.trim().toLowerCase() == klantSleutel &&
        _heeftGeldigPrijsmodel(
          opmeting: opmeting,
          ondersteundeFormulierTypes: ondersteundeFormulierTypes,
        );
  }

  static bool _isOptieOpmeting({
    required OpmetingOverzichtRaamItem opmeting,
    required String klantSleutel,
    required Set<String> ondersteundeFormulierTypes,
  }) {
    return !opmeting.isVerwijderd &&
        opmeting.isOfferteOptie &&
        opmeting.klantNaam.trim().toLowerCase() == klantSleutel &&
        _heeftGeldigPrijsmodel(
          opmeting: opmeting,
          ondersteundeFormulierTypes: ondersteundeFormulierTypes,
        );
  }

  static bool _heeftGeldigPrijsmodel({
    required OpmetingOverzichtRaamItem opmeting,
    required Set<String> ondersteundeFormulierTypes,
  }) {
    final formulierType = _formulierTypeVoorOpmeting(opmeting);

    return formulierType.isNotEmpty &&
        ondersteundeFormulierTypes.contains(formulierType) &&
        OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(opmeting) !=
            null;
  }

  static String _formulierTypeVoorOpmeting(OpmetingOverzichtRaamItem opmeting) {
    final koppeling = OfferteArtikelPrijsKoppelingService.koppelingVoorArtikel(
      opmeting,
    );

    if (koppeling == null) {
      return '';
    }

    return _canoniekFormulierType(koppeling.formulierType);
  }

  static bool _heeftVerdeelkosten(OpmetingOverzichtRaamItem opmeting) {
    final prijsData = OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(
      opmeting,
    );

    return prijsData != null &&
        (prijsData.toegepasteVerdeeldePrijsregels.isNotEmpty ||
            prijsData.verdeeldePrijsSignatuur.isNotEmpty);
  }

  static OpmetingOverzichtRaamItem _werkVerdeelkostenBij({
    required OpmetingOverzichtRaamItem opmeting,
    required List<OfferteToegepastePrijsregelModel> prijsregels,
    required String signatuur,
  }) {
    final prijsData = OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(
      opmeting,
    );

    if (prijsData == null) {
      return opmeting;
    }

    final bijgewerktePrijsData =
        OfferteArtikelPrijsKoppelingService.wijzigPrijsData(
          prijsData: prijsData,
          toegepasteVerdeeldePrijsregels: prijsregels,
          verdeeldePrijsSignatuur: signatuur,
        );

    return OfferteArtikelPrijsKoppelingService.schrijfPrijsData(
      artikel: opmeting,
      prijsData: bijgewerktePrijsData,
    ).metNieuweWijzigingsDatum();
  }

  static String _verdeeldePrijsSignatuur(OpmetingOverzichtRaamItem opmeting) {
    return OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(
          opmeting,
        )?.verdeeldePrijsSignatuur ??
        '';
  }

  static int _aantalVoorOpmeting(OpmetingOverzichtRaamItem opmeting) {
    final aantal = OfferteArtikelPrijsKoppelingService.aantalVoorArtikel(
      opmeting,
    );

    return aantal < 1 ? 1 : aantal;
  }

  static double _aankoopTotaalVoorLimiet(OpmetingOverzichtRaamItem opmeting) {
    return OfferteArtikelPrijsKoppelingService.resultaatVoorArtikel(
          opmeting,
          kortingToestaan: false,
        )?.aankoopTotaalVoorLimietExclBtw ??
        0.0;
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
      final aantalInPositie = _aantalVoorOpmeting(alleOpmetingen[index]);

      final extraCentenInPositie = math
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

      verdeeldeRegelsPerIndex[index]?.add(
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
    required List<_GedeeldeVerdeelgroep> verdeelgroepen,
  }) {
    final artikelen = doelIndexen
        .map((index) {
          final opmeting = alleOpmetingen[index];

          final prijsData =
              OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(
                opmeting,
              );

          return <String, Object?>{
            'id': opmeting.id,
            'formulierType': _formulierTypeVoorOpmeting(opmeting),
            'aantal': _aantalVoorOpmeting(opmeting),
            'breedteMm':
                OfferteArtikelPrijsKoppelingService.breedteMmVoorArtikel(
                  opmeting,
                ),
            'hoogteMm': OfferteArtikelPrijsKoppelingService.hoogteMmVoorArtikel(
              opmeting,
            ),
            'prijsPerStukExclBtw': prijsData?.prijsPerStukExclBtw ?? 0.0,
            'artikelKortingPercentage':
                prijsData?.artikelKortingPercentage ?? 0.0,
            'artikelWinstmargePercentage':
                prijsData?.artikelWinstmargePercentage ?? 0.0,
            'technischePrijsSignatuur':
                prijsData?.technischePrijsSignatuur ?? '',
            'technischePrijsregels':
                prijsData?.toegepasteTechnischePrijsregels
                    .map((regel) {
                      return <String, Object?>{
                        'id': regel.bronPrijsregelId,
                        'totaalExclBtw': regel.totaalExclBtw,
                        'bronGewijzigdOp': regel.bronGewijzigdOp,
                      };
                    })
                    .toList(growable: false) ??
                const <Object?>[],
            'vrijeArtikelPrijsSignatuur':
                prijsData?.vrijeArtikelPrijsSignatuur ?? '',
            'vrijeArtikelPrijsSelecties':
                prijsData?.vrijeArtikelPrijsSelecties
                    .map((selectie) {
                      return <String, Object?>{
                        'id': selectie.id,
                        'bronPrijsregelId': selectie.bronPrijsregelId,
                        'omschrijving': selectie.omschrijving,
                        'bedragPerStukExclBtw': selectie.bedragPerStukExclBtw,
                        'eenheid': selectie.eenheid.jsonWaarde,
                        'uitschrijfmodus': selectie.uitschrijfmodus.jsonWaarde,
                        'actief': selectie.actief,
                      };
                    })
                    .toList(growable: false) ??
                const <Object?>[],
          };
        })
        .toList(growable: false);

    final groepen = verdeelgroepen
        .map((groep) {
          final prijsregel = groep.prijsregel;

          final formulierTypes = groep.formulierTypes.toList(growable: false)
            ..sort();

          return <String, Object?>{
            'id': prijsregel.id,
            'formulierTypes': formulierTypes,
            'actief': prijsregel.actief,
            'omschrijving': prijsregel.omschrijving,
            'prijsExclBtw': prijsregel.prijsExclBtw,
            'eenheid': prijsregel.eenheid.jsonWaarde,
            'uitschrijfmodus': prijsregel.uitschrijfmodus.jsonWaarde,
            'verdeelLimietmodus': prijsregel.verdeelLimietmodus.jsonWaarde,
            'verdeelLimietBedragExclBtw': prijsregel.verdeelLimietBedragExclBtw,
            'gewijzigdOp': prijsregel.gewijzigdOp,
          };
        })
        .toList(growable: false);

    return jsonEncode(<String, Object?>{
      'artikelen': artikelen,
      'verdeelgroepen': groepen,
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

  static bool _isNieuwer(String eerste, String tweede) {
    final eersteDatum = DateTime.tryParse(eerste);

    final tweedeDatum = DateTime.tryParse(tweede);

    if (eersteDatum == null) {
      return false;
    }

    if (tweedeDatum == null) {
      return true;
    }

    return eersteDatum.isAfter(tweedeDatum);
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

class _GedeeldeVerdeelgroep {
  _GedeeldeVerdeelgroep({
    required this.prijsregel,
    required Set<String> formulierTypes,
  }) : formulierTypes = Set<String>.from(formulierTypes);

  OffertePrijsregelModel prijsregel;
  final Set<String> formulierTypes;
}
