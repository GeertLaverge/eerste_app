import 'package:flutter/material.dart';

import 'paginas/home_pagina_nieuw.dart';
import 'helpers/agenda/agenda_melding_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AgendaMeldingService.initialiseren();
  runApp(
    const ThimacoApp(),
  );
}

class ThimacoApp extends StatelessWidget {
  const ThimacoApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePaginaNieuw(),
    );
  }
}
