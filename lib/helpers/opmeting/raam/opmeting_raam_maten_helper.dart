import 'package:flutter/material.dart';

import '../kader_samenstelling/opmeting_kader_samenstelling_layout_helper.dart';
import '../kader_samenstelling/opmeting_kader_samenstelling_model.dart';

class OpmetingRaamMatenHelper {
  const OpmetingRaamMatenHelper._();

  static double waarde(TextEditingController controller) {
    return double.tryParse(controller.text.trim().replaceAll(',', '.')) ?? 0;
  }

  static void zetControllerTekst(TextEditingController controller, int waarde) {
    final tekst = waarde.toString();

    if (controller.text == tekst) {
      return;
    }

    controller.value = TextEditingValue(
      text: tekst,
      selection: TextSelection.collapsed(offset: tekst.length),
    );
  }

  static int berekenRaammaatBreedte({
    required TextEditingController dagmaatBreedteController,
    required TextEditingController slagLinksController,
    required TextEditingController slagRechtsController,
  }) {
    return (waarde(dagmaatBreedteController) +
            waarde(slagLinksController) +
            waarde(slagRechtsController))
        .round();
  }

  static int berekenRaammaatHoogte({
    required TextEditingController dagmaatHoogteController,
    required TextEditingController slagBovenController,
    required TextEditingController slagOnderController,
  }) {
    return (waarde(dagmaatHoogteController) +
            waarde(slagBovenController) +
            waarde(slagOnderController))
        .round();
  }

  static bool heeftMeerdereKaders(OpmetingKaderSamenstelling samenstelling) {
    return samenstelling.kaders.length > 1;
  }

  static int totaleRaammaatBreedte(OpmetingKaderSamenstelling samenstelling) {
    if (samenstelling.kaders.isEmpty) {
      return 0;
    }

    final layout = OpmetingKaderSamenstellingLayoutHelper.bereken(
      kaders: samenstelling.kaders,
    );

    return layout.breedteMm;
  }

  static int totaleRaammaatHoogte(OpmetingKaderSamenstelling samenstelling) {
    if (samenstelling.kaders.isEmpty) {
      return 0;
    }

    final layout = OpmetingKaderSamenstellingLayoutHelper.bereken(
      kaders: samenstelling.kaders,
    );

    return layout.hoogteMm;
  }

  static int berekenRaammaatBreedteVoorSamenstellingOfVelden({
    required OpmetingKaderSamenstelling samenstelling,
    required TextEditingController dagmaatBreedteController,
    required TextEditingController slagLinksController,
    required TextEditingController slagRechtsController,
  }) {
    if (heeftMeerdereKaders(samenstelling)) {
      return totaleRaammaatBreedte(samenstelling);
    }

    return berekenRaammaatBreedte(
      dagmaatBreedteController: dagmaatBreedteController,
      slagLinksController: slagLinksController,
      slagRechtsController: slagRechtsController,
    );
  }

  static int berekenRaammaatHoogteVoorSamenstellingOfVelden({
    required OpmetingKaderSamenstelling samenstelling,
    required TextEditingController dagmaatHoogteController,
    required TextEditingController slagBovenController,
    required TextEditingController slagOnderController,
  }) {
    if (heeftMeerdereKaders(samenstelling)) {
      return totaleRaammaatHoogte(samenstelling);
    }

    return berekenRaammaatHoogte(
      dagmaatHoogteController: dagmaatHoogteController,
      slagBovenController: slagBovenController,
      slagOnderController: slagOnderController,
    );
  }

  static int dagmaatBreedteVoorSamenstelling(
    OpmetingKaderSamenstelling samenstelling,
  ) {
    final slagBreedte = samenstelling.slagLinksMm + samenstelling.slagRechtsMm;
    final dagmaat = totaleRaammaatBreedte(samenstelling) - slagBreedte;

    return dagmaat < 0 ? 0 : dagmaat;
  }

  static int dagmaatHoogteVoorSamenstelling(
    OpmetingKaderSamenstelling samenstelling,
  ) {
    final slagHoogte = samenstelling.slagBovenMm + samenstelling.slagOnderMm;
    final dagmaat = totaleRaammaatHoogte(samenstelling) - slagHoogte;

    return dagmaat < 0 ? 0 : dagmaat;
  }

  static int berekenVerschilTablet({
    required TextEditingController binnenTabletController,
    required TextEditingController buitenTabletController,
  }) {
    return (waarde(buitenTabletController) - waarde(binnenTabletController))
        .round();
  }

  static void vulMaatveldenMetActiefKader({
    required OpmetingKaderSamenstelling samenstelling,
    required TextEditingController dagmaatBreedteController,
    required TextEditingController dagmaatHoogteController,
    required TextEditingController slagLinksController,
    required TextEditingController slagRechtsController,
    required TextEditingController slagBovenController,
    required TextEditingController slagOnderController,
  }) {
    final actiefKader = samenstelling.actiefKader;

    if (actiefKader == null) {
      return;
    }

    final int dagmaatBreedte;
    final int dagmaatHoogte;

    if (heeftMeerdereKaders(samenstelling)) {
      dagmaatBreedte = dagmaatBreedteVoorSamenstelling(samenstelling);
      dagmaatHoogte = dagmaatHoogteVoorSamenstelling(samenstelling);
    } else {
      final slagBreedte =
          samenstelling.slagLinksMm + samenstelling.slagRechtsMm;
      final slagHoogte = samenstelling.slagBovenMm + samenstelling.slagOnderMm;

      final berekendeDagmaatBreedte = actiefKader.breedteMm - slagBreedte;
      final berekendeDagmaatHoogte = actiefKader.hoogteMm - slagHoogte;

      dagmaatBreedte = berekendeDagmaatBreedte < 0
          ? 0
          : berekendeDagmaatBreedte;
      dagmaatHoogte = berekendeDagmaatHoogte < 0 ? 0 : berekendeDagmaatHoogte;
    }

    zetControllerTekst(dagmaatBreedteController, dagmaatBreedte);
    zetControllerTekst(dagmaatHoogteController, dagmaatHoogte);

    zetControllerTekst(slagLinksController, samenstelling.slagLinksMm);
    zetControllerTekst(slagRechtsController, samenstelling.slagRechtsMm);
    zetControllerTekst(slagBovenController, samenstelling.slagBovenMm);
    zetControllerTekst(slagOnderController, samenstelling.slagOnderMm);
  }

  static OpmetingKaderSamenstelling herberekenSamenstelling({
    required OpmetingKaderSamenstelling huidigeSamenstelling,
    required int raammaatBreedte,
    required int raammaatHoogte,
    required TextEditingController slagLinksController,
    required TextEditingController slagRechtsController,
    required TextEditingController slagBovenController,
    required TextEditingController slagOnderController,
  }) {
    final actiefKader = huidigeSamenstelling.actiefKader;

    final nieuweSlagLinksMm = waarde(slagLinksController).round();
    final nieuweSlagRechtsMm = waarde(slagRechtsController).round();
    final nieuweSlagBovenMm = waarde(slagBovenController).round();
    final nieuweSlagOnderMm = waarde(slagOnderController).round();

    final nieuweKaders =
        actiefKader == null || heeftMeerdereKaders(huidigeSamenstelling)
        ? huidigeSamenstelling.kaders
        : OpmetingKaderSamenstellingLayoutHelper.wijzigKaderAfmetingen(
            kaders: huidigeSamenstelling.kaders,
            kaderId: actiefKader.id,
            breedteMm: raammaatBreedte,
            hoogteMm: raammaatHoogte,
          );

    return huidigeSamenstelling.copyWith(
      slagLinksMm: nieuweSlagLinksMm,
      slagRechtsMm: nieuweSlagRechtsMm,
      slagBovenMm: nieuweSlagBovenMm,
      slagOnderMm: nieuweSlagOnderMm,
      kaders: nieuweKaders,
    );
  }
}
