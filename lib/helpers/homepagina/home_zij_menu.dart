import 'package:flutter/material.dart';

import '../../paginas/agenda_pagina_nieuw.dart';

class HomeZijMenu extends StatelessWidget {
  final bool compact;

  const HomeZijMenu({
    super.key,
    required this.compact,
  });

  static const groen = Color(0xFF0B7A3B);
  static const rand = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 108 : 205,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: rand,
          ),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: compact ? 18 : 24,
          ),
          _menuKnop(
            context,
            'Agenda',
            Icons.calendar_month_outlined,
            actief: true,
          ),
          _menuKnop(
            context,
            'Klanten',
            Icons.groups_outlined,
          ),
          _menuKnop(
            context,
            compact ? 'Notitie\'s\nplaatsers' : 'Notitie\'s plaatsers',
            Icons.description_outlined,
          ),
          _menuKnop(
            context,
            compact ? 'Notitie\'s\nbureau' : 'Notitie\'s bureau',
            Icons.edit_note_outlined,
          ),
          _menuKnop(
            context,
            'Puinzak',
            Icons.delete_outline,
          ),
          _menuKnop(
            context,
            'Magazijn',
            Icons.inventory_2_outlined,
          ),
          const Spacer(),
          _menuKnop(
            context,
            'Afmelden',
            Icons.logout,
          ),
          SizedBox(
            height: compact ? 14 : 20,
          ),
        ],
      ),
    );
  }

  Widget _menuKnop(
    BuildContext context,
    String titel,
    IconData icoon, {
    bool actief = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 14,
        vertical: compact ? 4 : 5,
      ),
      child: InkWell(
        onTap: () {
          if (titel == 'Agenda') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AgendaPaginaNieuw(),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(
          14,
        ),
        child: Container(
          height: compact ? 84 : 50,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 4 : 14,
          ),
          decoration: BoxDecoration(
            color: actief
                ? groen.withValues(
                    alpha: 0.06,
                  )
                : Colors.transparent,
            borderRadius: BorderRadius.circular(
              14,
            ),
            border: actief
                ? const Border(
                    left: BorderSide(
                      color: groen,
                      width: 3,
                    ),
                  )
                : null,
          ),
          child: compact
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icoon,
                      size: 23,
                      color: actief ? groen : Colors.black87,
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Text(
                      titel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.12,
                        fontWeight: actief ? FontWeight.w700 : FontWeight.w600,
                        color: actief ? groen : Colors.black87,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Icon(
                      icoon,
                      size: 22,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Text(
                        titel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              actief ? FontWeight.w800 : FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
