// THIMACO-CONTROLE: VOORZETROLLUIK-MENU-REGISTRATIE-20260731-1025
// THIMACO-CONTROLE: OPMEETFICHE-MENU-GROEPEN-20260730
// THIMACO-CONTROLE: VELUX-DAKRAMEN-REGISTER-FASE-1-2-20260729-2030
// THIMACO-CONTROLE: SEKTIONALE-POORTEN-REGISTER-20260729
// THIMACO-CONTROLE: PLOOIWERKEN-REGISTER-KOPPELING-20260728
// THIMACO-CONTROLE: SCHUIFVLIEGENDEUR-REGISTER-KOPPELING-20260728
import 'package:flutter/material.dart';

enum OfferteArtikelCategorie {
  ramen('Ramen'),
  deuren('Deuren'),
  toebehoren('Toebehoren');

  const OfferteArtikelCategorie(this.label);

  final String label;
}

enum OfferteArtikelOpenType {
  raamopmeting,
  vasteInzethor,
  vliegendeur,
  schuifvliegendeur,
  plooiwerken,
  voorzetscreen,
  voorzetrolluik,
  sektionalePoort,
  veluxDakraam,
}

class OfferteArtikelRegistratie {
  const OfferteArtikelRegistratie({
    required this.menuWaarde,
    required this.formulierType,
    required this.formulierNaam,
    required this.categorie,
    required this.icoon,
    required this.openType,
  });

  final String menuWaarde;
  final String formulierType;
  final String formulierNaam;
  final OfferteArtikelCategorie categorie;
  final IconData icoon;
  final OfferteArtikelOpenType openType;
}

class OfferteArtikelMenuGroep {
  const OfferteArtikelMenuGroep({
    required this.label,
    required this.menuWaarden,
  });

  final String label;
  final List<String> menuWaarden;
}

class OfferteArtikelRegister {
  const OfferteArtikelRegister._();

  static const List<OfferteArtikelRegistratie> registraties =
      <OfferteArtikelRegistratie>[
        OfferteArtikelRegistratie(
          menuWaarde: 'pvc_raam',
          formulierType: 'pvcRaam',
          formulierNaam: 'PVC Raam',
          categorie: OfferteArtikelCategorie.ramen,
          icoon: Icons.window_outlined,
          openType: OfferteArtikelOpenType.raamopmeting,
        ),
        OfferteArtikelRegistratie(
          menuWaarde: 'alu_raam',
          formulierType: 'aluRaam',
          formulierNaam: 'ALU Raam',
          categorie: OfferteArtikelCategorie.ramen,
          icoon: Icons.window_outlined,
          openType: OfferteArtikelOpenType.raamopmeting,
        ),
        OfferteArtikelRegistratie(
          menuWaarde: 'pvc_schuifraam',
          formulierType: 'pvcSchuifraam',
          formulierNaam: 'PVC Schuifraam',
          categorie: OfferteArtikelCategorie.ramen,
          icoon: Icons.view_week_outlined,
          openType: OfferteArtikelOpenType.raamopmeting,
        ),
        OfferteArtikelRegistratie(
          menuWaarde: 'alu_schuifraam',
          formulierType: 'aluSchuifraam',
          formulierNaam: 'ALU Schuifraam',
          categorie: OfferteArtikelCategorie.ramen,
          icoon: Icons.view_week_rounded,
          openType: OfferteArtikelOpenType.raamopmeting,
        ),
        OfferteArtikelRegistratie(
          menuWaarde: 'pvc_deur',
          formulierType: 'pvcDeur',
          formulierNaam: 'PVC Deur',
          categorie: OfferteArtikelCategorie.deuren,
          icoon: Icons.door_front_door_outlined,
          openType: OfferteArtikelOpenType.raamopmeting,
        ),
        OfferteArtikelRegistratie(
          menuWaarde: 'alu_deur',
          formulierType: 'aluDeur',
          formulierNaam: 'ALU Deur',
          categorie: OfferteArtikelCategorie.deuren,
          icoon: Icons.door_front_door_rounded,
          openType: OfferteArtikelOpenType.raamopmeting,
        ),
        OfferteArtikelRegistratie(
          menuWaarde: 'vaste_inzethor',
          formulierType: 'vasteInzethor',
          formulierNaam: 'Vaste inzethor',
          categorie: OfferteArtikelCategorie.toebehoren,
          icoon: Icons.grid_view_rounded,
          openType: OfferteArtikelOpenType.vasteInzethor,
        ),
        OfferteArtikelRegistratie(
          menuWaarde: 'vliegendeur',
          formulierType: 'vliegendeur',
          formulierNaam: 'Vliegendeur',
          categorie: OfferteArtikelCategorie.toebehoren,
          icoon: Icons.door_front_door_outlined,
          openType: OfferteArtikelOpenType.vliegendeur,
        ),
        OfferteArtikelRegistratie(
          menuWaarde: 'schuifvliegendeur',
          formulierType: 'schuifvliegendeur',
          formulierNaam: 'Schuifvliegendeur',
          categorie: OfferteArtikelCategorie.toebehoren,
          icoon: Icons.view_week_outlined,
          openType: OfferteArtikelOpenType.schuifvliegendeur,
        ),
        OfferteArtikelRegistratie(
          menuWaarde: 'plooiwerken',
          formulierType: 'plooiwerken',
          formulierNaam: 'Plooiwerken',
          categorie: OfferteArtikelCategorie.toebehoren,
          icoon: Icons.straighten_outlined,
          openType: OfferteArtikelOpenType.plooiwerken,
        ),
        OfferteArtikelRegistratie(
          menuWaarde: 'voorzetscreen',
          formulierType: 'voorzetscreen',
          formulierNaam: 'Voorzetscreen',
          categorie: OfferteArtikelCategorie.toebehoren,
          icoon: Icons.blinds_outlined,
          openType: OfferteArtikelOpenType.voorzetscreen,
        ),
        OfferteArtikelRegistratie(
          menuWaarde: 'voorzetrolluik',
          formulierType: 'voorzetrolluik',
          formulierNaam: 'Voorzetrolluiken',
          categorie: OfferteArtikelCategorie.toebehoren,
          icoon: Icons.view_stream_outlined,
          openType: OfferteArtikelOpenType.voorzetrolluik,
        ),
        OfferteArtikelRegistratie(
          menuWaarde: 'sektionale_poort',
          formulierType: 'sektionalePoort',
          formulierNaam: 'Sektionale poorten',
          categorie: OfferteArtikelCategorie.deuren,
          icoon: Icons.garage_outlined,
          openType: OfferteArtikelOpenType.sektionalePoort,
        ),
        OfferteArtikelRegistratie(
          menuWaarde: 'velux_dakraam',
          formulierType: 'veluxDakraam',
          formulierNaam: 'Velux dakramen',
          categorie: OfferteArtikelCategorie.ramen,
          icoon: Icons.roofing_outlined,
          openType: OfferteArtikelOpenType.veluxDakraam,
        ),
      ];

  /// De professionele volgorde van het menu in de opmetingbovenbalk.
  ///
  /// Nieuwe formulieren kunnen later eenvoudig aan de juiste groep worden
  /// toegevoegd zodra hun registratie en navigatie beschikbaar zijn.
  static const List<OfferteArtikelMenuGroep> menuGroepen =
      <OfferteArtikelMenuGroep>[
        OfferteArtikelMenuGroep(
          label: 'PVC',
          menuWaarden: <String>['pvc_raam', 'pvc_schuifraam', 'pvc_deur'],
        ),
        OfferteArtikelMenuGroep(
          label: 'ALU',
          menuWaarden: <String>['alu_raam', 'alu_schuifraam', 'alu_deur'],
        ),
        OfferteArtikelMenuGroep(
          label: 'Toebehoren',
          menuWaarden: <String>[
            'vaste_inzethor',
            'vliegendeur',
            'schuifvliegendeur',
            'plooiwerken',
            'voorzetscreen',
            'voorzetrolluik',
          ],
        ),
        OfferteArtikelMenuGroep(
          label: 'Poorten',
          menuWaarden: <String>['sektionale_poort'],
        ),
        OfferteArtikelMenuGroep(
          label: 'Dakramen',
          menuWaarden: <String>['velux_dakraam'],
        ),
      ];

  static OfferteArtikelRegistratie? voorMenuWaarde(String menuWaarde) {
    for (final registratie in registraties) {
      if (registratie.menuWaarde == menuWaarde) {
        return registratie;
      }
    }
    return null;
  }

  static List<OfferteArtikelRegistratie> voorCategorie(
    OfferteArtikelCategorie categorie,
  ) {
    return List<OfferteArtikelRegistratie>.unmodifiable(
      registraties.where((registratie) => registratie.categorie == categorie),
    );
  }

  static List<OfferteArtikelRegistratie> voorMenuGroep(
    OfferteArtikelMenuGroep groep,
  ) {
    final resultaat = <OfferteArtikelRegistratie>[];

    for (final menuWaarde in groep.menuWaarden) {
      final registratie = voorMenuWaarde(menuWaarde);
      if (registratie != null) {
        resultaat.add(registratie);
      }
    }

    return List<OfferteArtikelRegistratie>.unmodifiable(resultaat);
  }
}
