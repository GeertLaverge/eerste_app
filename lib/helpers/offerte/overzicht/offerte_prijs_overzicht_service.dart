import 'dart:collection';

import '../../opmeting/overzicht/opmeting_artikel_type_omschrijving_helper.dart';
import '../../opmeting/overzicht/opmeting_overzicht_model.dart';
import '../../opmeting/project/opmeting_project_titelhoofd_model.dart';
import '../offerte_posities_service.dart';
import '../prijzen/offerte_artikel_prijs_koppeling_service.dart';
import '../prijzen/offerte_project_prijs_service.dart';
import '../prijzen/offerte_toegepaste_prijsregel_model.dart';
import 'offerte_prijs_overzicht_model.dart';

class OffertePrijsOverzichtService {
  const OffertePrijsOverzichtService._();

  static OffertePrijsOverzichtData bouw({
    required OpmetingProjectTitelhoofd titelhoofd,
    required List<OpmetingOverzichtRaamItem> posities,
    DateTime? opgemaaktOp,
  }) {
    final actievePosities = posities
        .where((positie) {
          return !positie.isVerwijderd &&
              OfferteArtikelPrijsKoppelingService.isOndersteundArtikel(positie);
        })
        .toList(growable: false);

    final positiesService = const OffertePositiesService();
    final positieLabels = positiesService.maakBronPositieLabels(
      actievePosities,
    );
    final geordendePosities = positiesService.groepeerBronPositiesVoorOverzicht(
      actievePosities,
    );

    final artikelen = <OffertePrijsOverzichtArtikel>[];
    final prijsregelAccumulators =
        <String, _SamengevoegdePrijsregelAccumulator>{};

    for (final positie in geordendePosities) {
      final resultaat =
          OfferteArtikelPrijsKoppelingService.resultaatVoorArtikel(
            positie,
            kortingToestaan: !positie.isOfferteOptie,
          );
      if (resultaat == null) continue;

      final aantal = OfferteArtikelPrijsKoppelingService.aantalVoorArtikel(
        positie,
      ).clamp(1, 1000000).toInt();
      final positieLabel = positieLabels[positie.id] ?? 'Positie';
      final omschrijvingRegels =
          OpmetingArtikelTypeOmschrijvingHelper.omschrijvingRegelsVoor(positie);
      final omschrijving = omschrijvingRegels
          .map((regel) => regel.trim())
          .where((regel) => regel.isNotEmpty)
          .join(' · ');

      artikelen.add(
        OffertePrijsOverzichtArtikel(
          id: positie.id,
          positieLabel: positieLabel,
          artikelNaam: positie.formulierTypeLabel,
          omschrijving: omschrijving,
          maatLabel: _maatLabel(positie),
          formulierType:
              OfferteArtikelPrijsKoppelingService.canoniekFormulierType(
                positie.formulierTypeGenormaliseerd,
              ),
          aantal: aantal,
          isOptie: positie.isOfferteOptie,
          basisPrijsPerStukExclBtw: resultaat.basisPrijsPerStukExclBtw,
          basisTotaalExclBtw: resultaat.basisTotaalExclBtw,
          winstmargePercentage: resultaat.winstmargePercentage,
          winstmargePerStukExclBtw: resultaat.winstmargePerStukExclBtw,
          winstmargeTotaalExclBtw: resultaat.winstmargeBedragExclBtw,
          kortingPercentage: resultaat.kortingPercentage,
          kortingPerStukExclBtw: resultaat.kortingPerStukExclBtw,
          kortingTotaalExclBtw: resultaat.kortingBedragExclBtw,
          totaalPerStukExclBtw: _deelDoorAantal(
            resultaat.totaalExclBtw,
            aantal,
          ),
          totaalExclBtw: resultaat.totaalExclBtw,
        ),
      );

      _voegArtikelPrijsregelsToe(
        accumulators: prijsregelAccumulators,
        regels: resultaat.technischePrijsregels,
        type: OffertePrijsOverzichtRegelType.technisch,
        toepassingLabel: positieLabel,
        artikelIsOptie: positie.isOfferteOptie,
      );
      _voegArtikelPrijsregelsToe(
        accumulators: prijsregelAccumulators,
        regels: resultaat.vrijeArtikelPrijsregels,
        type: OffertePrijsOverzichtRegelType.vrij,
        toepassingLabel: positieLabel,
        artikelIsOptie: positie.isOfferteOptie,
      );
      _voegArtikelPrijsregelsToe(
        accumulators: prijsregelAccumulators,
        regels: resultaat.verdeeldePrijsregels,
        type: OffertePrijsOverzichtRegelType.alleArtikelen,
        toepassingLabel: positieLabel,
        artikelIsOptie: positie.isOfferteOptie,
      );
    }

    _voegProjectPrijsregelsToe(
      accumulators: prijsregelAccumulators,
      titelhoofd: titelhoofd,
      posities: actievePosities,
    );

    final prijsregels =
        prijsregelAccumulators.values
            .map((accumulator) {
              return OffertePrijsOverzichtSamengevoegdeRegel(
                type: accumulator.type,
                omschrijving: accumulator.omschrijving,
                toepassingLabels: accumulator.toepassingLabels.toList(
                  growable: false,
                ),
                aantalToepassingen: accumulator.aantalToepassingen,
                totaalExclBtw: accumulator.totaalExclBtw,
                isOptie: accumulator.isOptie,
              );
            })
            .toList(growable: true)
          ..sort((eerste, tweede) {
            final typeVergelijking = eerste.type.index.compareTo(
              tweede.type.index,
            );
            if (typeVergelijking != 0) return typeVergelijking;
            final optieVergelijking = eerste.isOptie == tweede.isOptie
                ? 0
                : eerste.isOptie
                ? 1
                : -1;
            if (optieVergelijking != 0) return optieVergelijking;
            return eerste.omschrijving.toLowerCase().compareTo(
              tweede.omschrijving.toLowerCase(),
            );
          });

    return OffertePrijsOverzichtData(
      klantNaam: titelhoofd.klantNaam.trim(),
      klantAdres: _klantAdres(titelhoofd),
      offerteNummer: titelhoofd.samengesteldOffertenummer.trim(),
      opgemaaktOp: opgemaaktOp ?? DateTime.now(),
      artikelen: artikelen,
      prijsregels: prijsregels,
    );
  }

  static void _voegArtikelPrijsregelsToe({
    required Map<String, _SamengevoegdePrijsregelAccumulator> accumulators,
    required List<OfferteToegepastePrijsregelModel> regels,
    required OffertePrijsOverzichtRegelType type,
    required String toepassingLabel,
    required bool artikelIsOptie,
  }) {
    for (final regel in regels) {
      if (!regel.isGeldig || regel.totaalExclBtw <= 0.0) continue;

      _voegSamengevoegdeRegelToe(
        accumulators: accumulators,
        type: type,
        omschrijving: regel.omschrijving,
        toepassingLabel: toepassingLabel,
        totaalExclBtw: regel.totaalExclBtw,
        isOptie: artikelIsOptie || regel.isOptie,
      );
    }
  }

  static void _voegProjectPrijsregelsToe({
    required Map<String, _SamengevoegdePrijsregelAccumulator> accumulators,
    required OpmetingProjectTitelhoofd titelhoofd,
    required List<OpmetingOverzichtRaamItem> posities,
  }) {
    for (final formulierType
        in OfferteArtikelPrijsKoppelingService.ondersteundeFormulierTypes) {
      final typeResultaat = OfferteProjectPrijsService.berekenUitTitelhoofd(
        titelhoofd: titelhoofd,
        alleOpmetingen: posities,
        formulierType: formulierType,
      );
      if (typeResultaat.aantalArtikelen <= 0) continue;

      final formulierNaam =
          OfferteArtikelPrijsKoppelingService.formulierNaamVoor(formulierType);

      for (final regel in typeResultaat.prijsregels) {
        if (!regel.isGeldig || regel.totaalExclBtw <= 0.0) continue;

        _voegSamengevoegdeRegelToe(
          accumulators: accumulators,
          type: OffertePrijsOverzichtRegelType.alleArtikelen,
          omschrijving: regel.omschrijving,
          toepassingLabel: formulierNaam,
          totaalExclBtw: regel.totaalExclBtw,
          isOptie: regel.isOptie,
        );
      }
    }
  }

  static void _voegSamengevoegdeRegelToe({
    required Map<String, _SamengevoegdePrijsregelAccumulator> accumulators,
    required OffertePrijsOverzichtRegelType type,
    required String omschrijving,
    required String toepassingLabel,
    required double totaalExclBtw,
    required bool isOptie,
  }) {
    final veiligeOmschrijving = omschrijving.trim().isEmpty
        ? type.label
        : omschrijving.trim();
    final sleutel = <String>[
      type.name,
      _normaliseerTekst(veiligeOmschrijving),
      isOptie ? 'optie' : 'hoofd',
    ].join('|');

    final bestaand = accumulators[sleutel];
    if (bestaand == null) {
      accumulators[sleutel] = _SamengevoegdePrijsregelAccumulator(
        type: type,
        omschrijving: veiligeOmschrijving,
        toepassingLabels: LinkedHashSet<String>.from(
          toepassingLabel.trim().isEmpty
              ? const <String>[]
              : <String>[toepassingLabel.trim()],
        ),
        aantalToepassingen: 1,
        totaalExclBtw: _rondBedrag(totaalExclBtw),
        isOptie: isOptie,
      );
      return;
    }

    bestaand
      ..aantalToepassingen += 1
      ..totaalExclBtw = _rondBedrag(bestaand.totaalExclBtw + totaalExclBtw);
    if (toepassingLabel.trim().isNotEmpty) {
      bestaand.toepassingLabels.add(toepassingLabel.trim());
    }
  }

  static String _maatLabel(OpmetingOverzichtRaamItem positie) {
    final breedte = OfferteArtikelPrijsKoppelingService.breedteMmVoorArtikel(
      positie,
    );
    final hoogte = OfferteArtikelPrijsKoppelingService.hoogteMmVoorArtikel(
      positie,
    );
    if (breedte <= 0 && hoogte <= 0) return '';
    return '$breedte × $hoogte mm';
  }

  static String _klantAdres(OpmetingProjectTitelhoofd titelhoofd) {
    final straat = <String>[
      titelhoofd.adres.trim(),
      titelhoofd.huisnummer.trim(),
      if (titelhoofd.busNummer.trim().isNotEmpty)
        'bus ${titelhoofd.busNummer.trim()}',
    ].where((deel) => deel.isNotEmpty).join(' ');

    return <String>[
      straat,
      titelhoofd.plaats.trim(),
    ].where((deel) => deel.isNotEmpty).join(' · ');
  }

  static double _deelDoorAantal(double totaal, int aantal) {
    if (aantal <= 0) return 0.0;
    return _rondBedrag(totaal / aantal.toDouble());
  }

  static double _rondBedrag(double waarde) {
    if (!waarde.isFinite) return 0.0;
    return (waarde * 100.0).roundToDouble() / 100.0;
  }

  static String _normaliseerTekst(String waarde) {
    return waarde.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }
}

class _SamengevoegdePrijsregelAccumulator {
  _SamengevoegdePrijsregelAccumulator({
    required this.type,
    required this.omschrijving,
    required this.toepassingLabels,
    required this.aantalToepassingen,
    required this.totaalExclBtw,
    required this.isOptie,
  });

  final OffertePrijsOverzichtRegelType type;
  final String omschrijving;
  final LinkedHashSet<String> toepassingLabels;
  int aantalToepassingen;
  double totaalExclBtw;
  final bool isOptie;
}
