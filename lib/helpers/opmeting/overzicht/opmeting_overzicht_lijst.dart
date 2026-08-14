// THIMACO-CONTROLE: PRIJSARCHITECTUUR-OPRUIMEN-STAP1-LEGACY-UI-20260814
// THIMACO-CONTROLE: PRIJS-PER-POSITIE-TABEL-LIJST-20260813
// THIMACO-CONTROLE: GROEPSGEWIJZE-WINST-KORTING-UI-UIT-LIJST-20260813
// THIMACO-CONTROLE: OUDE-PROJECTPRIJS-TOEVOEGKNOP-UIT-LIJST-20260813
// THIMACO-CONTROLE: OUDE-VRIJE-PRIJS-KNOP-UIT-LIJST-20260813
// THIMACO-CONTROLE: OPMETING-OVERZICHT-SCROLLCONTROLLER-20260812
import 'dart:async';

import 'package:flutter/material.dart';

import '../../offerte/offerte_controller.dart';
import '../../offerte/prijzen/offerte_artikel_prijs_data_model.dart';
import '../project/opmeting_project_kleur_model.dart';
import '../project/opmeting_project_titelhoofd_kaart.dart';
import '../project/opmeting_project_titelhoofd_model.dart';
import 'opmeting_overzicht_artikel_kaart.dart';
import 'opmeting_overzicht_model.dart';

typedef OpmetingOverzichtArtikelActie =
    Future<void> Function(OpmetingOverzichtRaamItem item);
typedef OpmetingOverzichtArtikelVerplaatsActie =
    Future<void> Function(OpmetingOverzichtRaamItem item, int richting);
typedef OpmetingOverzichtArtikelWaardeActie =
    Future<void> Function(OpmetingOverzichtRaamItem item, double waarde);
typedef OpmetingOverzichtPrijsPerPositieRegelsActie =
    Future<void> Function(
      OpmetingOverzichtRaamItem item,
      List<OffertePrijsPerPositieRegelModel> prijsregels,
    );

class OpmetingOverzichtLijst extends StatelessWidget {
  const OpmetingOverzichtLijst({
    super.key,
    required this.scrollController,
    required this.scrollStorageKey,
    required this.klantNaam,
    required this.projectTitelhoofd,
    required this.opmetingen,
    required this.verborgenFormulierTypes,
    required this.verborgenNietRekenenPositieIds,
    required this.projectKleurMenus,
    required this.offerteController,
    required this.onTitelhoofdGewijzigd,
    required this.onKlantLaden,
    required this.onToggleFormulierType,
    required this.onToggleNietRekenenPositie,
    required this.onArtikelOpenen,
    required this.onArtikelVerwijderen,
    required this.onArtikelKopieren,
    required this.onArtikelOptieWijzigen,
    required this.onArtikelNietRekenenWijzigen,
    required this.onPrijsGewijzigd,
    required this.onWinstmargeGewijzigd,
    required this.onKortingGewijzigd,
    required this.onPrijsPerPositieRegelsGewijzigd,
    required this.onArtikelVerplaatsen,
  });

  final ScrollController scrollController;
  final PageStorageKey<String> scrollStorageKey;
  final String klantNaam;
  final OpmetingProjectTitelhoofd projectTitelhoofd;
  final List<OpmetingOverzichtRaamItem> opmetingen;
  final Set<String> verborgenFormulierTypes;
  final Set<String> verborgenNietRekenenPositieIds;
  final List<OpmetingProjectKleurSubmenu> projectKleurMenus;
  final OfferteController offerteController;
  final ValueChanged<OpmetingProjectTitelhoofd> onTitelhoofdGewijzigd;
  final Future<void> Function() onKlantLaden;
  final ValueChanged<String> onToggleFormulierType;
  final ValueChanged<String> onToggleNietRekenenPositie;
  final OpmetingOverzichtArtikelActie onArtikelOpenen;
  final OpmetingOverzichtArtikelActie onArtikelVerwijderen;
  final OpmetingOverzichtArtikelActie onArtikelKopieren;
  final OpmetingOverzichtArtikelActie onArtikelOptieWijzigen;
  final OpmetingOverzichtArtikelActie onArtikelNietRekenenWijzigen;
  final OpmetingOverzichtArtikelWaardeActie onPrijsGewijzigd;
  final OpmetingOverzichtArtikelWaardeActie onWinstmargeGewijzigd;
  final OpmetingOverzichtArtikelWaardeActie onKortingGewijzigd;
  final OpmetingOverzichtPrijsPerPositieRegelsActie
  onPrijsPerPositieRegelsGewijzigd;
  final OpmetingOverzichtArtikelVerplaatsActie onArtikelVerplaatsen;

  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  OpmetingProjectTitelhoofd get _titelhoofdVoorPrijs {
    if (projectTitelhoofd.klantNaam.trim().isEmpty &&
        klantNaam.trim().isNotEmpty) {
      return projectTitelhoofd.copyWith(klantNaam: klantNaam.trim());
    }

    return projectTitelhoofd;
  }

  @override
  Widget build(BuildContext context) {
    final zichtbareItems = <_OpmetingOverzichtItemMetPositie>[];
    final titelhoofdVoorPrijs = _titelhoofdVoorPrijs;
    final positieLabelPerId = offerteController.positiesService
        .maakBronPositieLabels(opmetingen);
    final geordendeItems = offerteController.positiesService
        .groepeerBronPositiesVoorOverzicht(opmetingen);

    for (final item in geordendeItems) {
      if (item.isNietRekenen) {
        if (verborgenNietRekenenPositieIds.contains(item.id)) {
          continue;
        }
      } else if (verborgenFormulierTypes.contains(
        item.formulierTypeGenormaliseerd,
      )) {
        continue;
      }

      final lijstIndex = opmetingen.indexWhere(
        (huidig) => huidig.id == item.id,
      );
      zichtbareItems.add(
        _OpmetingOverzichtItemMetPositie(
          item: item,
          lijstIndex: lijstIndex < 0 ? 0 : lijstIndex,
          positieLabel: positieLabelPerId[item.id] ?? 'Positie',
        ),
      );
    }

    return ListView(
      key: scrollStorageKey,
      controller: scrollController,
      primary: false,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        OpmetingProjectTitelhoofdKaart(
          titelhoofd: titelhoofdVoorPrijs,
          opmetingen: opmetingen,
          verborgenFormulierTypes: verborgenFormulierTypes,
          verborgenNietRekenenPositieIds: verborgenNietRekenenPositieIds,
          kleurMenus: projectKleurMenus,
          onTitelhoofdGewijzigd: onTitelhoofdGewijzigd,
          onKlantLaden: () {
            unawaited(onKlantLaden());
          },
          onToggleFormulierType: onToggleFormulierType,
          onToggleNietRekenenPositie: onToggleNietRekenenPositie,
        ),
        const SizedBox(height: 14),
        if (zichtbareItems.isEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _rand),
            ),
            child: Text(
              opmetingen.isEmpty
                  ? 'Nog geen posities in deze fiche. Klik rechtsboven op + om een eerste opmeting toe te voegen.'
                  : 'Alle posities zijn tijdelijk verborgen. Klik bovenaan opnieuw op het oogje om ze terug te tonen.',
              style: const TextStyle(
                color: _tekstGrijs,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          ...zichtbareItems.map((zichtbaarItem) {
            final item = zichtbaarItem.item;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: OpmetingOverzichtArtikelKaart(
                item: item,
                positieLabel: zichtbaarItem.positieLabel,
                berekenPrijzen: projectTitelhoofd.berekenPrijzen,
                onOpenen: () {
                  unawaited(onArtikelOpenen(item));
                },
                onVerwijderen: () {
                  unawaited(onArtikelVerwijderen(item));
                },
                onKopieren: () {
                  unawaited(onArtikelKopieren(item));
                },
                onOptieWijzigen: () {
                  unawaited(onArtikelOptieWijzigen(item));
                },
                onNietRekenenWijzigen: () {
                  unawaited(onArtikelNietRekenenWijzigen(item));
                },
                onPrijsGewijzigd: (prijs) {
                  unawaited(onPrijsGewijzigd(item, prijs));
                },
                onWinstmargeGewijzigd: (percentage) {
                  unawaited(onWinstmargeGewijzigd(item, percentage));
                },
                onKortingGewijzigd: (percentage) {
                  unawaited(onKortingGewijzigd(item, percentage));
                },
                onPrijsPerPositieRegelsGewijzigd: (prijsregels) {
                  unawaited(
                    onPrijsPerPositieRegelsGewijzigd(item, prijsregels),
                  );
                },
                onOmhoog: zichtbaarItem.lijstIndex > 0
                    ? () {
                        unawaited(onArtikelVerplaatsen(item, -1));
                      }
                    : null,
                onOmlaag: zichtbaarItem.lijstIndex < opmetingen.length - 1
                    ? () {
                        unawaited(onArtikelVerplaatsen(item, 1));
                      }
                    : null,
              ),
            );
          }),
      ],
    );
  }
}

class _OpmetingOverzichtItemMetPositie {
  const _OpmetingOverzichtItemMetPositie({
    required this.item,
    required this.lijstIndex,
    required this.positieLabel,
  });

  final OpmetingOverzichtRaamItem item;
  final int lijstIndex;
  final String positieLabel;
}
