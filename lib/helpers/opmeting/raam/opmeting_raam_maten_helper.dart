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
  }) {
    return (waarde(dagmaatHoogteController) + waarde(slagBovenController))
        .round();
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

    final slagBreedte = samenstelling.slagLinksMm + samenstelling.slagRechtsMm;
    final slagHoogte = samenstelling.slagBovenMm;

    final dagmaatBreedte = actiefKader.breedteMm - slagBreedte;
    final dagmaatHoogte = actiefKader.hoogteMm - slagHoogte;

    zetControllerTekst(
      dagmaatBreedteController,
      dagmaatBreedte < 0 ? 0 : dagmaatBreedte,
    );

    zetControllerTekst(
      dagmaatHoogteController,
      dagmaatHoogte < 0 ? 0 : dagmaatHoogte,
    );

    zetControllerTekst(slagLinksController, samenstelling.slagLinksMm);
    zetControllerTekst(slagRechtsController, samenstelling.slagRechtsMm);
    zetControllerTekst(slagBovenController, samenstelling.slagBovenMm);
    zetControllerTekst(slagOnderController, 0);
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

    zetControllerTekst(slagOnderController, 0);

    final nieuweSlagLinksMm = waarde(slagLinksController).round();
    final nieuweSlagRechtsMm = waarde(slagRechtsController).round();
    final nieuweSlagBovenMm = waarde(slagBovenController).round();
    const nieuweSlagOnderMm = 0;

    final nieuweKaders = actiefKader == null
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
