import 'package:flutter/material.dart';

import '../../../modellen/agenda_actie.dart';
import '../../ui_helper.dart';

class DagtaakRij extends StatelessWidget {
  final AgendaActie actie;
  final VoidCallback onTap;
  final VoidCallback onAfvinken;

  const DagtaakRij({
    super.key,
    required this.actie,
    required this.onTap,
    required this.onAfvinken,
  });

  String tijdTekst() {
    if (actie.startUur == null || actie.startMinuut == null) return '';

    final start =
        '${actie.startUur.toString().padLeft(2, '0')}:${actie.startMinuut.toString().padLeft(2, '0')}';

    if (actie.eindUur == null || actie.eindMinuut == null) return start;

    final eind =
        '${actie.eindUur.toString().padLeft(2, '0')}:${actie.eindMinuut.toString().padLeft(2, '0')}';

    return '$start - $eind';
  }

  @override
  Widget build(BuildContext context) {
    final kleur = UiHelper.kleurUitNaam(actie.kleurNaam);
    final afgewerkt = actie.isAfgewerkt;
    final tijd = tijdTekst();

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: onAfvinken,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 30,
                minHeight: 30,
              ),
              icon: Icon(
                afgewerkt ? Icons.check_circle : Icons.radio_button_unchecked,
                color: afgewerkt ? Colors.green : Colors.grey.shade500,
                size: 22,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                actie.titel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: afgewerkt
                      ? Colors.grey.shade500
                      : const Color(0xFF111827),
                  decoration: afgewerkt
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
            if (tijd.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                tijd,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: afgewerkt ? Colors.grey.shade500 : kleur,
                ),
              ),
            ],
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
