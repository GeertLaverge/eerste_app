// THIMACO-CONTROLE: HOME-WITTE-BOVENBALK-MET-NIEUW-LOGO-20260914
import 'package:flutter/material.dart';

import '../../paginas/instellingen_pagina.dart';

class HomeBovenBalk extends StatelessWidget {
  const HomeBovenBalk({super.key});

  static const Color _antraciet = Color(0xFF22272D);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _oranjeLicht = Color(0xFFFFF4ED);

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 700;

    return Container(
      height: compact ? 64 : 76,
      padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 22),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: _rand),
        ),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: compact ? 185 : 280,
            child: Image.asset(
              'assets/offerte/thimaco_logo.png',
              height: compact ? 38 : 50,
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Meldingen',
            color: _antraciet,
            hoverColor: _oranjeLicht,
            highlightColor: _oranjeLicht,
            onPressed: () {},
            icon: Icon(
              Icons.notifications_none_rounded,
              size: compact ? 22 : 24,
            ),
          ),
          SizedBox(width: compact ? 0 : 4),
          IconButton(
            tooltip: 'Instellingen',
            color: _antraciet,
            hoverColor: _oranjeLicht,
            highlightColor: _oranjeLicht,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InstellingenPagina(),
                ),
              );
            },
            icon: Icon(
              Icons.settings_outlined,
              size: compact ? 22 : 24,
            ),
          ),
        ],
      ),
    );
  }
}
