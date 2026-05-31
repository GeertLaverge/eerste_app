import 'package:flutter/material.dart';

import '../../paginas/agenda_pagina_nieuw.dart';
import '../../helpers/sync/onedrive_sync_service.dart';
import '../../paginas/klanten_pagina.dart';

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
      width: compact ? 68 : 125,
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
            height: compact ? 8 : 14,
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
            height: compact ? 8 : 12,
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
    return InkWell(
      onTap: () async {
        if (titel == 'Agenda') {
          await OneDriveSyncService().slimmeSync();

          if (!context.mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AgendaPaginaNieuw(),
            ),
          );
        }

        if (titel == 'Klanten') {
          if (!context.mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => KlantenPagina(),
            ),
          );
        }
      },
      child: Container(
        height: compact ? 78 : 52,
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: actief ? groen : Colors.transparent,
              width: 3,
            ),
            bottom: const BorderSide(
              color: rand,
              width: 0.7,
            ),
          ),
        ),
        child: compact
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icoon,
                    size: 21,
                    color: actief ? groen : Colors.black87,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    titel,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.0,
                      fontWeight: actief ? FontWeight.w700 : FontWeight.w500,
                      color: actief ? groen : Colors.black87,
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                child: Row(
                  children: [
                    Icon(
                      icoon,
                      size: 20,
                      color: actief ? groen : Colors.black87,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        titel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              actief ? FontWeight.w700 : FontWeight.w500,
                          color: actief ? groen : Colors.black87,
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
