import 'package:flutter/material.dart';

import 'opmeting_raam_kleinhout_helper.dart';
import 'opmeting_raam_kleinhout_model.dart';
import 'opmeting_raam_model.dart';
import 'opmeting_raam_vulling_helper.dart';

class OpmetingRaamLegendaMeldingController {
  OpmetingRaamLegendaMeldingController({
    required this.isMounted,
    required this.actueleTekenvlakGrootte,
    required this.bepaalVulvlakken,
    required this.vullingToewijzingen,
    required this.kleinhouten,
    required this.opvullingCallback,
    required this.kleinhoutCallback,
  });

  final bool Function() isMounted;

  final Size? Function() actueleTekenvlakGrootte;

  final List<OpmetingRaamVulvlak> Function(Size size) bepaalVulvlakken;

  final List<OpmetingRaamVullingToewijzing> Function() vullingToewijzingen;

  final List<OpmetingRaamKleinhout> Function() kleinhouten;

  final ValueChanged<List<OpmetingRaamVullingLegendaItem>>? Function()
  opvullingCallback;

  final ValueChanged<List<OpmetingRaamKleinhoutLegendaItem>>? Function()
  kleinhoutCallback;

  bool _opvullingMeldingGepland = false;
  bool _eersteOpvullingMeldingGepland = false;

  bool _kleinhoutMeldingGepland = false;
  bool _eersteKleinhoutMeldingGepland = false;

  void planEersteMeldingen() {
    if (!_eersteOpvullingMeldingGepland) {
      _eersteOpvullingMeldingGepland = true;
      planOpvullingMelding();
    }

    if (!_eersteKleinhoutMeldingGepland) {
      _eersteKleinhoutMeldingGepland = true;
      planKleinhoutMelding();
    }
  }

  void planOpvullingMelding() {
    if (_opvullingMeldingGepland) {
      return;
    }

    _opvullingMeldingGepland = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _opvullingMeldingGepland = false;

      if (!isMounted()) {
        return;
      }

      final callback = opvullingCallback();
      final size = actueleTekenvlakGrootte();

      if (callback == null || size == null) {
        return;
      }

      final vulvlakken = bepaalVulvlakken(size);

      final legenda = OpmetingRaamVullingHelper.bepaalLegenda(
        vulvlakken: vulvlakken,
        toewijzingen: vullingToewijzingen(),
      );

      callback(List<OpmetingRaamVullingLegendaItem>.unmodifiable(legenda));
    });
  }

  void planKleinhoutMelding() {
    if (_kleinhoutMeldingGepland) {
      return;
    }

    _kleinhoutMeldingGepland = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _kleinhoutMeldingGepland = false;

      if (!isMounted()) {
        return;
      }

      final callback = kleinhoutCallback();
      final size = actueleTekenvlakGrootte();

      if (callback == null || size == null) {
        return;
      }

      final vulvlakken = bepaalVulvlakken(size);

      final legenda = OpmetingRaamKleinhoutHelper.bepaalLegenda(
        vulvlakken: vulvlakken,
        kleinhouten: kleinhouten(),
      );

      callback(List<OpmetingRaamKleinhoutLegendaItem>.unmodifiable(legenda));
    });
  }
}
