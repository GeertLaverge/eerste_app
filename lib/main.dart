// THIMACO-CONTROLE: NUMERIEK-TOETSENBORD-KLAAR-IOS-20260812
// THIMACO-CONTROLE: FINANCIELE-KLUIS-INITIALISATIE-20260806
import 'package:flutter/material.dart';

import 'helpers/adres/postcode_helper.dart';
import 'helpers/agenda/agenda_melding_service.dart';
import 'helpers/financien/beveiliging/financiele_kluis_sessie_controller.dart';
import 'helpers/invoer/numeriek_toetsenbord_klaar_overlay.dart';
import 'paginas/home_pagina_nieuw.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AgendaMeldingService.initialiseren();
  await PostcodeHelper.initialiseren();
  await FinancieleKluisSessieController.instance.initialiseer();

  runApp(const ThimacoApp());
}

class ThimacoApp extends StatelessWidget {
  const ThimacoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return NumeriekToetsenbordKlaarOverlay(
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const HomePaginaNieuw(),
    );
  }
}
