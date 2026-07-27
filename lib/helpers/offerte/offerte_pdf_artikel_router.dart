// THIMACO-CONTROLE: CENTRALE-OFFERTE-PDF-ARTIKELROUTER-20260726
import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;

import '../opmeting/overzicht/opmeting_overzicht_model.dart';
import 'offerte_pdf_inzethor_widget.dart';
import 'offerte_pdf_pvc_raam_widget.dart';
import 'offerte_pdf_vliegendeur_widget.dart';

class OffertePdfArtikelRouter {
  const OffertePdfArtikelRouter._();

  static pw.Widget bouwPositie({
    required OpmetingOverzichtRaamItem positie,
    required bool kortingToestaan,
    required bool isOptie,
    required double btwPercentage,
    required String btwRegelLabel,
    Uint8List? pvcRaamTekeningPng,
  }) {
    if (positie.vasteInzethorData != null) {
      return OffertePdfInzethorWidget.bouwPositie(
        positie: positie,
        kortingToestaan: kortingToestaan,
        isOptie: isOptie,
        btwPercentage: btwPercentage,
        btwRegelLabel: btwRegelLabel,
      );
    }

    if (positie.vliegendeurData != null) {
      return OffertePdfVliegendeurWidget.bouwPositie(
        positie: positie,
        kortingToestaan: kortingToestaan,
        isOptie: isOptie,
        btwPercentage: btwPercentage,
        btwRegelLabel: btwRegelLabel,
      );
    }

    return OffertePdfPvcRaamWidget.bouwPositie(
      positie: positie,
      kortingToestaan: kortingToestaan,
      isOptie: isOptie,
      btwPercentage: btwPercentage,
      btwRegelLabel: btwRegelLabel,
      tekeningPng: pvcRaamTekeningPng,
    );
  }

  static double berekenTotalePositieHoogte({
    required OpmetingOverzichtRaamItem positie,
    required bool kortingToestaan,
    required bool isOptie,
  }) {
    if (positie.vasteInzethorData != null) {
      return OffertePdfInzethorWidget.berekenTotalePositieHoogte(
        positie,
        kortingToestaan: kortingToestaan,
        isOptie: isOptie,
      );
    }

    if (positie.vliegendeurData != null) {
      return OffertePdfVliegendeurWidget.berekenTotalePositieHoogte(
        positie,
        kortingToestaan: kortingToestaan,
        isOptie: isOptie,
      );
    }

    return OffertePdfPvcRaamWidget.berekenTotalePositieHoogte(
      positie,
      kortingToestaan: kortingToestaan,
      isOptie: isOptie,
    );
  }
}
