import 'package:flutter/material.dart';

import 'paginas/agenda_pagina_nieuw.dart';

void main() {
  runApp(
    const ThimacoApp(),
  );
}

class ThimacoApp extends StatelessWidget {
  const ThimacoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const TestHomePagina(),
    );
  }
}

class TestHomePagina extends StatelessWidget {
  const TestHomePagina({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AgendaPaginaNieuw(),
              ),
            );
          },
          child: const Text(
            'Open agenda',
          ),
        ),
      ),
    );
  }
}
