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
import 'offerte_verdeelkost_service.dart';

/// Voegt automatische interne projectkosten met dezelfde omschrijving
/// uit verschillende artikeltypes samen.
///
/// Voorbeeld:
/// - PVC raam: Transport € 40
/// - Vaste inzethor: Transport € 40
///
/// Resultaat:
/// - één projectkost van € 40;
/// - verdeeld over alle betrokken artikelen.
///
/// De bestaande prijsmodellen en JSON-structuur worden niet gewijzigd.
class OfferteGekoppeldeVerdeelkostService {
  const OfferteGekoppeldeVerdeelkostService._();

  static const String _bronPrefix = 'gekoppelde_automatische_verdeelkost::';

  static OfferteVerdeelkostBijwerkingResultaat werkBij({
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

    final regelsPerOmschrijving =
        <String, Map<String, OffertePrijsregelModel>>{};

    for (final profiel in profielen.values) {
      final formulierType = _canoniekFormulierType(profiel.formulierType);

      if (formulierType.isEmpty) {
        continue;
      }

      final regels = profiel.regelsVoorCategorie(
        OffertePrijsCategorie.alleArtikelen,
      );

      for (final regel in regels) {
        final regelFormulierType = _canoniekFormulierType(regel.formulierType);

        if (!regel.actief ||
            !regel.isGeldig ||
            !regel.isVerdeeldeProjectkost ||
            regel.prijsExclBtw <= 0.0 ||
            regelFormulierType != formulierType) {
          continue;
        }

        final omschrijvingSleutel =
            OfferteVerdeelkostService.gekoppeldeVerdeelkostSleutelVoorOmschrijving(
              regel.omschrijving,
            );

        if (omschrijvingSleutel.isEmpty) {
          continue;
        }

        final regelsPerType = regelsPerOmschrijving.putIfAbsent(
          omschrijvingSleutel,
          () => <String, OffertePrijsregelModel>{},
        );

        final bestaandeRegel = regelsPerType[formulierType];

        if (bestaandeRegel == null ||
            regel.gewijzigdOp.compareTo(bestaandeRegel.gewijzigdOp) > 0) {
          regelsPerType[formulierType] = regel;
        }
      }
    }

    // Alleen een omschrijving die in minimaal twee verschillende
    // prijsprofielen voorkomt, is een gekoppelde projectkost.
    final gekoppeldeOmschrijvingSleutels = regelsPerOmschrijving.entries
        .where((entry) => entry.value.length >= 2)
        .map((entry) => entry.key)
        .toSet();

    final resultaat = List<OpmetingOverzichtRaamItem>.from(alleOpmetingen);

    final artikelIndexenPerFormulierType = <String, List<int>>{};

    for (var index = 0; index < resultaat.length; index++) {
      final artikel = resultaat[index];

      if (artikel.isVerwijderd ||
          !artikel.teltMeeInHoofdofferte ||
          artikel.klantNaam.trim().toLowerCase() != klantSleutel) {
        continue;
      }

      final koppeling =
          OfferteArtikelPrijsKoppelingService.koppelingVoorArtikel(artikel);

      if (koppeling == null) {
        continue;
      }

      final formulierType = _canoniekFormulierType(koppeling.formulierType);

      final prijsData =
          OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(artikel);

      if (formulierType.isEmpty || prijsData == null) {
        continue;
      }

      artikelIndexenPerFormulierType
          .putIfAbsent(formulierType, () => <int>[])
          .add(index);
    }

    // Verwijder eerst:
    // 1. eerder automatisch gekoppelde regels;
    // 2. de afzonderlijk berekende profielregels met dezelfde omschrijving.
    //
    // Daarna wordt voor iedere gekoppelde omschrijving één nieuwe
    // gezamenlijke projectverdeling opgebouwd.
    for (var index = 0; index < resultaat.length; index++) {
      final artikel = resultaat[index];

      if (artikel.klantNaam.trim().toLowerCase() != klantSleutel) {
        continue;
      }

      final prijsData =
          OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(artikel);

      if (prijsData == null) {
        continue;
      }

      final behoudenRegels = prijsData.toegepasteVerdeeldePrijsregels
          .where((regel) {
            if (regel.bronPrijsregelId.startsWith(_bronPrefix)) {
              return false;
            }

            if (!regel.uitschrijfmodus.isVerdeeldeInterneKost) {
              return true;
            }

            final omschrijvingSleutel =
                OfferteVerdeelkostService.gekoppeldeVerdeelkostSleutelVoorOmschrijving(
                  regel.omschrijving,
                );

            return !gekoppeldeOmschrijvingSleutels.contains(
              omschrijvingSleutel,
            );
          })
          .toList(growable: false);

      if (_regelsZijnGelijk(
        prijsData.toegepasteVerdeeldePrijsregels,
        behoudenRegels,
      )) {
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

    final gesorteerdeOmschrijvingSleutels =
        gekoppeldeOmschrijvingSleutels.toList(growable: false)..sort();

    for (final omschrijvingSleutel in gesorteerdeOmschrijvingSleutels) {
      final regelsPerType = regelsPerOmschrijving[omschrijvingSleutel];

      if (regelsPerType == null || regelsPerType.isEmpty) {
        continue;
      }

      final aanwezigeFormulierTypes = regelsPerType.keys
          .where((formulierType) {
            return artikelIndexenPerFormulierType[formulierType]?.isNotEmpty ==
                true;
          })
          .toList(growable: false);

      if (aanwezigeFormulierTypes.isEmpty) {
        continue;
      }

      // Wanneer momenteel slechts één van de gekoppelde artikeltypes
      // aanwezig is, blijft de kost gewoon volledig bij dat artikeltype.
      // Zodra een tweede gekoppeld artikeltype wordt toegevoegd, wordt
      // automatisch opnieuw over beide types verdeeld.
      OffertePrijsregelModel? bronRegel;

      for (final formulierType in aanwezigeFormulierTypes) {
        final kandidaat = regelsPerType[formulierType];

        if (kandidaat == null) {
          continue;
        }

        if (bronRegel == null ||
            kandidaat.gewijzigdOp.compareTo(bronRegel.gewijzigdOp) > 0) {
          bronRegel = kandidaat;
        }
      }

      if (bronRegel == null) {
        continue;
      }

      final doelIndexen = <int>[
        for (final formulierType in aanwezigeFormulierTypes)
          ...artikelIndexenPerFormulierType[formulierType]!,
      ];

      if (doelIndexen.isEmpty) {
        continue;
      }

      final totaalAantalArtikelen = doelIndexen.fold<int>(0, (som, index) {
        return som + _aantalVoorArtikel(resultaat[index]);
      });

      if (totaalAantalArtikelen <= 0) {
        continue;
      }

      final aankoopTotaalVoorVerdeling = _rondBedragAf(
        doelIndexen.fold<double>(0.0, (som, index) {
          return som + _aankoopTotaalVoorArtikel(resultaat[index]);
        }),
      );

      final heeftAankooplimiet =
          bronRegel.verdeelLimietmodus ==
          OffertePrijsVerdeelLimietmodus.metAankooplimiet;

      if (heeftAankooplimiet &&
          (bronRegel.verdeelLimietBedragExclBtw <= 0.0 ||
              aankoopTotaalVoorVerdeling >=
                  bronRegel.verdeelLimietBedragExclBtw)) {
        continue;
      }

      final totaalCenten = (_rondBedragAf(bronRegel.prijsExclBtw) * 100.0)
          .round();

      if (totaalCenten <= 0) {
        continue;
      }

      final basisCentenPerArtikel = totaalCenten ~/ totaalAantalArtikelen;

      var resterendeCenten = totaalCenten % totaalAantalArtikelen;

      final gekoppeldeId = base64Url
          .encode(utf8.encode(omschrijvingSleutel))
          .replaceAll('=', '');

      final bronPrijsregelId = '$_bronPrefix$gekoppeldeId';

      final berekendOp = bronRegel.gewijzigdOp.trim().isNotEmpty
          ? bronRegel.gewijzigdOp
          : '1970-01-01T00:00:00.000Z';

      for (final index in doelIndexen) {
        final artikel = resultaat[index];

        final prijsData =
            OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(artikel);

        if (prijsData == null) {
          continue;
        }

        final aantalInPositie = _aantalVoorArtikel(artikel);

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

        final prijsPerArtikel = positieTotaal / aantalInPositie.toDouble();

        final gekoppeldeRegel = OfferteToegepastePrijsregelModel(
          bronPrijsregelId: bronPrijsregelId,
          categorie: OffertePrijsCategorie.alleArtikelen,
          omschrijving: bronRegel.omschrijving,
          prijsExclBtw: _rondHoeveelheidAf(prijsPerArtikel),
          eenheid: OffertePrijsEenheid.vast,
          hoeveelheid: aantalInPositie.toDouble(),
          totaalExclBtw: positieTotaal,
          uitschrijfmodus: bronRegel.uitschrijfmodus,
          verdeeldOverAantalArtikelen: totaalAantalArtikelen,
          projectPrijsExclBtw: bronRegel.prijsExclBtw,
          aankoopTotaalVoorVerdelingExclBtw: aankoopTotaalVoorVerdeling,
          verdeelLimietBedragExclBtw: bronRegel.verdeelLimietBedragExclBtw,
          bronGewijzigdOp: bronRegel.gewijzigdOp,
          berekendOp: berekendOp,
        );

        final nieuweRegels = <OfferteToegepastePrijsregelModel>[
          ...prijsData.toegepasteVerdeeldePrijsregels,
          gekoppeldeRegel,
        ];

        resultaat[index] = OfferteArtikelPrijsKoppelingService.schrijfPrijsData(
          artikel: artikel,
          prijsData: prijsData.copyWith(
            toegepasteVerdeeldePrijsregels: nieuweRegels,
          ),
        );
      }
    }

    var gewijzigd = false;

    for (var index = 0; index < resultaat.length; index++) {
      final oudePrijsData =
          OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(
            alleOpmetingen[index],
          );

      final nieuwePrijsData =
          OfferteArtikelPrijsKoppelingService.prijsDataVoorArtikel(
            resultaat[index],
          );

      if (oudePrijsData == null || nieuwePrijsData == null) {
        continue;
      }

      if (_regelsZijnGelijk(
        oudePrijsData.toegepasteVerdeeldePrijsregels,
        nieuwePrijsData.toegepasteVerdeeldePrijsregels,
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

  static String _canoniekFormulierType(String formulierType) {
    return OfferteArtikelPrijsKoppelingService.canoniekFormulierType(
      formulierType,
    );
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

  static bool _regelsZijnGelijk(
    List<OfferteToegepastePrijsregelModel> eerste,
    List<OfferteToegepastePrijsregelModel> tweede,
  ) {
    return jsonEncode(
          eerste.map((regel) => regel.toJson()).toList(growable: false),
        ) ==
        jsonEncode(
          tweede.map((regel) => regel.toJson()).toList(growable: false),
        );
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
