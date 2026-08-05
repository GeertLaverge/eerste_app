// THIMACO-CONTROLE: HOME-VOLLEDIG-GROENE-BOVENBALK-20260805
import 'package:flutter/material.dart';

import '../../paginas/instellingen_pagina.dart';

class HomeBovenBalk extends StatelessWidget {
  const HomeBovenBalk({super.key});

  static const Color groen = Color(0xFF0B7A3B);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: const BoxDecoration(
        color: groen,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text(
              'T',
              style: TextStyle(
                color: groen,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'THIMACO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Meldingen',
            color: Colors.white,
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, size: 25),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Instellingen',
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InstellingenPagina()),
              );
            },
            icon: const Icon(Icons.settings_outlined, size: 25),
          ),
        ],
      ),
    );
  }
}
