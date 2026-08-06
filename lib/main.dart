// THIMACO-CONTROLE: FINANCIELE-KLUIS-INITIALISATIE-20260806
import 'package:flutter/material.dart';

import 'helpers/adres/postcode_helper.dart';
import 'helpers/agenda/agenda_melding_service.dart';
import 'helpers/financien/beveiliging/financiele_kluis_sessie_controller.dart';
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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePaginaNieuw(),
    );
  }
}
