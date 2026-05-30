import 'package:flutter/material.dart';
import '../../paginas/instellingen_pagina.dart';

class HomeBovenBalk extends StatelessWidget {
  const HomeBovenBalk({
    super.key,
  });

  static const groen = Color(
    0xFF0B7A3B,
  );

  static const rand = Color(
    0xFFE5E7EB,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        border: Border(
          bottom: BorderSide(
            color: rand,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: groen,
            child: Text(
              'T',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Text(
            'THIMACO',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: Colors.black87,
            ),
          ),
          Spacer(),
          Icon(
            Icons.notifications_none,
            size: 24,
          ),
          SizedBox(
            width: 16,
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InstellingenPagina(),
                ),
              );
            },
            child: const Icon(
              Icons.settings_outlined,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
