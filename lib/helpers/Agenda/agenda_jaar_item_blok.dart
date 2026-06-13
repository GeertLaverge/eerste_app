import 'package:flutter/material.dart';

import '../../helpers/Agenda/agenda_item.dart';
import '../../helpers/Agenda/agenda_kleur_service.dart';
import '../../helpers/klanten/kraan_waarschuwing_icon.dart';

class JaarItemBlok extends StatelessWidget {
  final AgendaItem item;

  const JaarItemBlok({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final tekstKleur = item.type == 'planning'
        ? const Color(0xFF0B7A3B)
        : item.type == 'opvolging'
            ? const Color(0xFFEAB308)
            : item.type == 'nadienst'
                ? Colors.purple
                : item.type == 'verlof'
                    ? Colors.red
                    : item.type == 'dagtaak'
                        ? Colors.orange
                        : item.type == 'kraan'
                            ? Colors.brown
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
          Flexible(
            child: Text(
              item.titel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: tekstKleur,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (item.kraanNodig && !item.kraanIngepland)
            const KraanWaarschuwingIcon(
              actief: true,
            ),
        ],
      ),
    );
  }
}
