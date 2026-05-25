import 'package:flutter/material.dart';

import '../../helpers/Agenda/agenda_item.dart';
import '../../helpers/Agenda/agenda_kleur_service.dart';

class JaarItemBlok extends StatelessWidget {
  final AgendaItem item;

  const JaarItemBlok({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final tekstKleur = item.type == 'verlof'
        ? Colors.red
        : item.type == 'dagtaak'
            ? Colors.orange
            : Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AgendaKleurService.achtergrond(
          item.type,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.tijdTekst.isNotEmpty)
            Text(
              item.tijdTekst,
              style: TextStyle(
                color: tekstKleur,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          if (item.tijdTekst.isNotEmpty)
            const SizedBox(
              width: 3,
            ),
          Text(
            item.titel,
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: TextStyle(
              color: tekstKleur,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
