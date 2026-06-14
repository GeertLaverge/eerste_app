import 'package:flutter/material.dart';

import '../../paginas/agenda_pagina_nieuw.dart';
import '../../paginas/klanten_pagina.dart';
import '../sync/sync_navigatie_helper.dart';
import '../../paginas/notities_bureau_pagina.dart';
import '../../paginas/opmeting_pagina.dart';

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
          right: BorderSide(color: rand),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: compact ? 8 : 14),
          _menuKnop(context, 'Agenda', Icons.calendar_month_outlined,
              actief: true),
          _menuKnop(context, 'Klanten', Icons.groups_outlined),
          _menuKnop(
              context, 'Notitie\'s\nplaatsers', Icons.description_outlined),
          _menuKnop(context, 'Notitie\'s\nbureau', Icons.edit_note_outlined),
          _menuKnop(context, 'Opmeting', Icons.straighten_outlined),
          _menuKnop(context, 'Puinzak', Icons.delete_outline),
          _menuKnop(context, 'Magazijn', Icons.inventory_2_outlined),
          const Spacer(),
          _menuKnop(context, 'Afmelden', Icons.logout),
          SizedBox(height: compact ? 8 : 12),
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
          await SyncNavigatieHelper.openMetDownload(
            context: context,
            pagina: const AgendaPaginaNieuw(),
          );
          return;
        }

        if (titel == 'Klanten') {
          await SyncNavigatieHelper.openMetDownload(
            context: context,
            pagina: const KlantenPagina(),
          );
          return;
        }

        if (titel.contains('bureau')) {
          await SyncNavigatieHelper.openMetDownload(
            context: context,
            pagina: const NotitiesBureauPagina(),
          );
          return;
        }

        if (titel == 'Opmeting') {
          await SyncNavigatieHelper.openMetDownload(
            context: context,
            pagina: const OpmetingPagina(),
          );
          return;
        }
      },
      child: Container(
        height: compact ? 86 : 64,
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
                    maxLines: 3,
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
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Icon(
                      icoon,
                      size: 20,
                      color: actief ? groen : Colors.black87,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        titel,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.05,
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
