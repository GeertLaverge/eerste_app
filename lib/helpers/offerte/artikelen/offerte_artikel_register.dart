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
}
