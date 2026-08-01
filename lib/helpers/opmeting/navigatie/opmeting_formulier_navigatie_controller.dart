// THIMACO-CONTROLE: UITVALSCHERM-NAVIGATIE-20260801
// THIMACO-CONTROLE: VOORZETROLLUIK-NAVIGATIE-AMBIGUOUS-IMPORT-HERSTEL-20260731-0845
// THIMACO-CONTROLE: VOORZETSCREEN-PROJECTKLEUR-NAVIGATIE-20260730-2005
// THIMACO-CONTROLE: VELUX-DAKRAMEN-NAVIGATIE-FASE-1-2-20260729-2030
// THIMACO-CONTROLE: SEKTIONALE-POORTEN-NAVIGATIE-20260729
// THIMACO-CONTROLE: PLOOIWERKEN-PROJECTKLEUR-HOOFDPAGINA-20260728-2110
import 'package:flutter/material.dart';

import '../../offerte/prijzen/offerte_prijsprofiel_model.dart';
import '../overzicht/opmeting_overzicht_model.dart' as overzicht;
import '../project/opmeting_project_titelhoofd_model.dart';
import '../toebehoren/vaste_inzethor/opmeting_vaste_inzethor_fiche.dart';
import '../toebehoren/vliegendeur/opmeting_vliegendeur_fiche.dart';
import '../toebehoren/schuifvliegendeur/opmeting_schuifvliegendeur_fiche.dart';
import '../toebehoren/plooiwerken/opmeting_plooiwerken_fiche.dart';
import '../toebehoren/voorzetscreen/opmeting_voorzetscreen_fiche.dart';
import '../toebehoren/voorzetrolluik/opmeting_voorzetrolluik_fiche.dart';
import '../toebehoren/uitvalscherm/opmeting_uitvalscherm_fiche.dart';
import '../toebehoren/sektionale_poort/opmeting_sektionale_poort_fiche.dart';
import '../toebehoren/velux_dakramen/opmeting_velux_dakraam_fiche.dart';
import '../../../paginas/opmeting_raam_pagina.dart';

class OpmetingFormulierNavigatieController {
  OpmetingFormulierNavigatieController({
    required this.context,
    required this.isMounted,
    required this.leesKlantNaam,
    required this.leesTitelhoofd,
    required this.zorgVoorActieveKlant,
    required this.laadVasteInzethorPrijsprofiel,
    required this.herlaadOpmetingen,
  });

  final BuildContext context;
  final bool Function() isMounted;
  final String Function() leesKlantNaam;
  final OpmetingProjectTitelhoofd Function() leesTitelhoofd;
  final Future<String?> Function() zorgVoorActieveKlant;
  final Future<OffertePrijsprofielModel> Function()
  laadVasteInzethorPrijsprofiel;
  final Future<void> Function(String? klantNaam) herlaadOpmetingen;

  bool _formulierOpenenBezig = false;

  Future<void> openRaamopmeting({String formulierType = 'pvcRaam'}) async {
    if (_formulierOpenenBezig) {
      return;
    }

    _formulierOpenenBezig = true;

    try {
      final klantNaam = await zorgVoorActieveKlant();

      if (klantNaam == null || klantNaam.trim().isEmpty || !isMounted()) {
        return;
      }

      await _wachtTotPopupEnDialogGeslotenZijn();

      if (!isMounted() || !context.mounted) {
        return;
      }

      final resultaat = await Navigator.of(context)
          .push<overzicht.OpmetingOverzichtRaamItem>(
            MaterialPageRoute(
              builder: (routeContext) {
                return OpmetingRaamPagina(
                  klantNaam: klantNaam.trim(),
                  formulierType: formulierType,
                );
              },
            ),
          );

      if (resultaat == null || !isMounted()) {
        return;
      }

      await herlaadOpmetingen(klantNaam.trim());
    } finally {
      _formulierOpenenBezig = false;
    }
  }

  Future<void> openVasteInzethor({
    overzicht.OpmetingOverzichtRaamItem? bestaandeOpmeting,
  }) async {
    if (_formulierOpenenBezig) {
      return;
    }

    _formulierOpenenBezig = true;

    try {
      final klantNaam = bestaandeOpmeting?.klantNaam.trim().isNotEmpty == true
          ? bestaandeOpmeting!.klantNaam.trim()
          : leesKlantNaam().trim();

      if (klantNaam.isEmpty || !isMounted()) {
        return;
      }

      final standaardPrijsprofiel = bestaandeOpmeting == null
          ? await laadVasteInzethorPrijsprofiel()
          : null;

      if (!isMounted()) {
        return;
      }

      await _wachtTotPopupEnDialogGeslotenZijn();

      if (!isMounted() || !context.mounted) {
        return;
      }

      final resultaat = await Navigator.of(context)
          .push<overzicht.OpmetingOverzichtRaamItem>(
            MaterialPageRoute(
              builder: (routeContext) {
                return OpmetingVasteInzethorFiche(
                  klantNaam: klantNaam,
                  bestaandeOpmeting: bestaandeOpmeting,
                  ralKleurToebehoren: leesTitelhoofd().ralKleurToebehoren,
                  standaardPrijsPerStukExclBtw:
                      standaardPrijsprofiel?.standaardPrijsPerStukExclBtw ?? 0,
                  standaardWinstmargePercentage:
                      standaardPrijsprofiel?.standaardWinstmargePercentage ?? 0,
                  standaardKortingPercentage:
                      standaardPrijsprofiel?.standaardKortingPercentage ?? 0,
                );
              },
            ),
          );

      if (resultaat == null || !isMounted()) {
        return;
      }

      await herlaadOpmetingen(klantNaam);
    } finally {
      _formulierOpenenBezig = false;
    }
  }

  Future<void> openVliegendeur({
    overzicht.OpmetingOverzichtRaamItem? bestaandeOpmeting,
  }) async {
    if (_formulierOpenenBezig) {
      return;
    }

    _formulierOpenenBezig = true;

    try {
      final klantNaam = bestaandeOpmeting?.klantNaam.trim().isNotEmpty == true
          ? bestaandeOpmeting!.klantNaam.trim()
          : leesKlantNaam().trim();

      if (klantNaam.isEmpty || !isMounted()) {
        return;
      }

      await _wachtTotPopupEnDialogGeslotenZijn();

      if (!isMounted() || !context.mounted) {
        return;
      }

      final resultaat = await Navigator.of(context)
          .push<overzicht.OpmetingOverzichtRaamItem>(
            MaterialPageRoute(
              builder: (routeContext) {
                return OpmetingVliegendeurFiche(
                  klantNaam: klantNaam,
                  bestaandeOpmeting: bestaandeOpmeting,
                  projectRalKleur: leesTitelhoofd().ralKleurToebehoren.trim(),
                );
              },
            ),
          );

      if (resultaat == null || !isMounted()) {
        return;
      }

      await herlaadOpmetingen(klantNaam);
    } finally {
      _formulierOpenenBezig = false;
    }
  }

  Future<void> openSchuifvliegendeur({
    overzicht.OpmetingOverzichtRaamItem? bestaandeOpmeting,
  }) async {
    if (_formulierOpenenBezig) {
      return;
    }

    _formulierOpenenBezig = true;

    try {
      final klantNaam = bestaandeOpmeting?.klantNaam.trim().isNotEmpty == true
          ? bestaandeOpmeting!.klantNaam.trim()
          : leesKlantNaam().trim();

      if (klantNaam.isEmpty || !isMounted()) {
        return;
      }

      await _wachtTotPopupEnDialogGeslotenZijn();

      if (!isMounted() || !context.mounted) {
        return;
      }

      final resultaat = await Navigator.of(context)
          .push<overzicht.OpmetingOverzichtRaamItem>(
            MaterialPageRoute(
              builder: (routeContext) {
                return OpmetingSchuifvliegendeurFiche(
                  klantNaam: klantNaam,
                  bestaandeOpmeting: bestaandeOpmeting,
                  ralKleurToebehoren: leesTitelhoofd().ralKleurToebehoren
                      .trim(),
                );
              },
            ),
          );

      if (resultaat == null || !isMounted()) {
        return;
      }

      await herlaadOpmetingen(klantNaam);
    } finally {
      _formulierOpenenBezig = false;
    }
  }

  String _projectKleurVoorPlooiwerken() {
    final titelhoofd = leesTitelhoofd();

    final toebehoren = titelhoofd.ralKleurToebehoren.trim();
    if (toebehoren.isNotEmpty) {
      return toebehoren;
    }

    final buiten = titelhoofd.projectKleurBuiten.trim();
    if (buiten.isNotEmpty) {
      return buiten;
    }

    return titelhoofd.projectKleurBinnen.trim();
  }

  Future<void> openPlooiwerken({
    overzicht.OpmetingOverzichtRaamItem? bestaandeOpmeting,
  }) async {
    if (_formulierOpenenBezig) {
      return;
    }

    _formulierOpenenBezig = true;

    try {
      final klantNaam = bestaandeOpmeting?.klantNaam.trim().isNotEmpty == true
          ? bestaandeOpmeting!.klantNaam.trim()
          : leesKlantNaam().trim();

      if (klantNaam.isEmpty || !isMounted()) {
        return;
      }

      await _wachtTotPopupEnDialogGeslotenZijn();

      if (!isMounted() || !context.mounted) {
        return;
      }

      final resultaat = await Navigator.of(context)
          .push<overzicht.OpmetingOverzichtRaamItem>(
            MaterialPageRoute(
              builder: (routeContext) {
                return OpmetingPlooiwerkenFiche(
                  klantNaam: klantNaam,
                  bestaandeOpmeting: bestaandeOpmeting,
                  projectKleur: _projectKleurVoorPlooiwerken(),
                );
              },
            ),
          );

      if (resultaat == null || !isMounted()) {
        return;
      }

      await herlaadOpmetingen(klantNaam);
    } finally {
      _formulierOpenenBezig = false;
    }
  }

  Future<void> openVoorzetscreen({
    overzicht.OpmetingOverzichtRaamItem? bestaandeOpmeting,
  }) async {
    if (_formulierOpenenBezig) return;
    _formulierOpenenBezig = true;

    try {
      final klantNaam = bestaandeOpmeting?.klantNaam.trim().isNotEmpty == true
          ? bestaandeOpmeting!.klantNaam.trim()
          : leesKlantNaam().trim();

      if (klantNaam.isEmpty || !isMounted()) return;

      await _wachtTotPopupEnDialogGeslotenZijn();
      if (!isMounted() || !context.mounted) return;

      final resultaat = await Navigator.of(context)
          .push<overzicht.OpmetingOverzichtRaamItem>(
            MaterialPageRoute(
              builder: (routeContext) {
                return OpmetingVoorzetscreenFiche(
                  klantNaam: klantNaam,
                  bestaandeOpmeting: bestaandeOpmeting,
                  projectKleur: _projectKleurVoorPlooiwerken(),
                );
              },
            ),
          );

      if (resultaat == null || !isMounted()) return;
      await herlaadOpmetingen(klantNaam);
    } finally {
      _formulierOpenenBezig = false;
    }
  }

  Future<void> openVoorzetrolluik({
    overzicht.OpmetingOverzichtRaamItem? bestaandeOpmeting,
  }) async {
    if (_formulierOpenenBezig) return;
    _formulierOpenenBezig = true;

    try {
      final klantNaam = bestaandeOpmeting?.klantNaam.trim().isNotEmpty == true
          ? bestaandeOpmeting!.klantNaam.trim()
          : leesKlantNaam().trim();

      if (klantNaam.isEmpty || !isMounted()) return;

      await _wachtTotPopupEnDialogGeslotenZijn();
      if (!isMounted() || !context.mounted) return;

      final resultaat = await Navigator.of(context)
          .push<overzicht.OpmetingOverzichtRaamItem>(
            MaterialPageRoute(
              builder: (routeContext) {
                return OpmetingVoorzetrolluikFiche(
                  klantNaam: klantNaam,
                  bestaandeOpmeting: bestaandeOpmeting,
                  projectKleur: _projectKleurVoorPlooiwerken(),
                );
              },
            ),
          );

      if (resultaat == null || !isMounted()) return;
      await herlaadOpmetingen(klantNaam);
    } finally {
      _formulierOpenenBezig = false;
    }
  }

  Future<void> openUitvalscherm({
    overzicht.OpmetingOverzichtRaamItem? bestaandeOpmeting,
  }) async {
    if (_formulierOpenenBezig) return;
    _formulierOpenenBezig = true;

    try {
      final klantNaam = bestaandeOpmeting?.klantNaam.trim().isNotEmpty == true
          ? bestaandeOpmeting!.klantNaam.trim()
          : leesKlantNaam().trim();

      if (klantNaam.isEmpty || !isMounted()) return;

      await _wachtTotPopupEnDialogGeslotenZijn();
      if (!isMounted() || !context.mounted) return;

      final resultaat = await Navigator.of(context)
          .push<overzicht.OpmetingOverzichtRaamItem>(
            MaterialPageRoute(
              builder: (routeContext) {
                return OpmetingUitvalschermFiche(
                  klantNaam: klantNaam,
                  bestaandeOpmeting: bestaandeOpmeting,
                  projectKleur: _projectKleurVoorPlooiwerken(),
                );
              },
            ),
          );

      if (resultaat == null || !isMounted()) return;
      await herlaadOpmetingen(klantNaam);
    } finally {
      _formulierOpenenBezig = false;
    }
  }

  Future<void> openSektionalePoort({
    overzicht.OpmetingOverzichtRaamItem? bestaandeOpmeting,
  }) async {
    if (_formulierOpenenBezig) {
      return;
    }

    _formulierOpenenBezig = true;

    try {
      final klantNaam = bestaandeOpmeting?.klantNaam.trim().isNotEmpty == true
          ? bestaandeOpmeting!.klantNaam.trim()
          : leesKlantNaam().trim();

      if (klantNaam.isEmpty || !isMounted()) {
        return;
      }

      await _wachtTotPopupEnDialogGeslotenZijn();

      if (!isMounted() || !context.mounted) {
        return;
      }

      final resultaat = await Navigator.of(context)
          .push<overzicht.OpmetingOverzichtRaamItem>(
            MaterialPageRoute(
              builder: (routeContext) {
                return OpmetingSektionalePoortFiche(
                  klantNaam: klantNaam,
                  bestaandeOpmeting: bestaandeOpmeting,
                  projectKleur: _projectKleurVoorPlooiwerken(),
                );
              },
            ),
          );

      if (resultaat == null || !isMounted()) {
        return;
      }

      await herlaadOpmetingen(klantNaam);
    } finally {
      _formulierOpenenBezig = false;
    }
  }

  Future<void> openVeluxDakraam({
    overzicht.OpmetingOverzichtRaamItem? bestaandeOpmeting,
  }) async {
    if (_formulierOpenenBezig) {
      return;
    }

    _formulierOpenenBezig = true;

    try {
      final klantNaam = bestaandeOpmeting?.klantNaam.trim().isNotEmpty == true
          ? bestaandeOpmeting!.klantNaam.trim()
          : leesKlantNaam().trim();

      if (klantNaam.isEmpty || !isMounted()) {
        return;
      }

      await _wachtTotPopupEnDialogGeslotenZijn();

      if (!isMounted() || !context.mounted) {
        return;
      }

      final resultaat = await Navigator.of(context)
          .push<overzicht.OpmetingOverzichtRaamItem>(
            MaterialPageRoute(
              builder: (routeContext) {
                return OpmetingVeluxDakraamFiche(
                  klantNaam: klantNaam,
                  bestaandeOpmeting: bestaandeOpmeting,
                );
              },
            ),
          );

      if (resultaat == null || !isMounted()) {
        return;
      }

      await herlaadOpmetingen(klantNaam);
    } finally {
      _formulierOpenenBezig = false;
    }
  }

  Future<void> bewerkOpmeting(overzicht.OpmetingOverzichtRaamItem item) async {
    if (item.formulierTypeGenormaliseerd == 'vasteInzethor') {
      await openVasteInzethor(bestaandeOpmeting: item);
      return;
    }

    if (item.formulierTypeGenormaliseerd == 'vliegendeur') {
      await openVliegendeur(bestaandeOpmeting: item);
      return;
    }

    if (item.formulierTypeGenormaliseerd == 'schuifvliegendeur') {
      await openSchuifvliegendeur(bestaandeOpmeting: item);
      return;
    }

    if (item.formulierTypeGenormaliseerd == 'plooiwerken') {
      await openPlooiwerken(bestaandeOpmeting: item);
      return;
    }

    if (item.formulierTypeGenormaliseerd == 'voorzetscreen') {
      await openVoorzetscreen(bestaandeOpmeting: item);
      return;
    }

    if (item.formulierTypeGenormaliseerd == 'voorzetrolluik') {
      await openVoorzetrolluik(bestaandeOpmeting: item);
      return;
    }

    if (item.formulierTypeGenormaliseerd == 'uitvalscherm') {
      await openUitvalscherm(bestaandeOpmeting: item);
      return;
    }

    if (item.formulierTypeGenormaliseerd == 'sektionalePoort') {
      await openSektionalePoort(bestaandeOpmeting: item);
      return;
    }

    if (item.formulierTypeGenormaliseerd == 'veluxDakraam') {
      await openVeluxDakraam(bestaandeOpmeting: item);
      return;
    }

    final resultaat = await Navigator.of(context)
        .push<overzicht.OpmetingOverzichtRaamItem>(
          MaterialPageRoute(
            builder: (routeContext) {
              return OpmetingRaamPagina(
                klantNaam: item.klantNaam,
                bestaandeOpmeting: item,
                formulierType: item.formulierTypeGenormaliseerd,
              );
            },
          ),
        );

    if (resultaat == null || !isMounted()) {
      return;
    }

    final actieveKlantNaam = leesKlantNaam().trim();
    await herlaadOpmetingen(actieveKlantNaam.isEmpty ? null : actieveKlantNaam);
  }

  Future<void> _wachtTotPopupEnDialogGeslotenZijn() async {
    await Future<void>.delayed(Duration.zero);

    if (!isMounted()) {
      return;
    }

    await WidgetsBinding.instance.endOfFrame;
  }
}
