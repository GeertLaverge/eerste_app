import 'package:flutter/material.dart';

import 'paginas/home_pagina_nieuw.dart';

void main() {
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
