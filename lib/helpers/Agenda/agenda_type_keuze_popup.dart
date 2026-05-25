import 'package:flutter/material.dart';

class AgendaTypeKeuzePopup {
  static Future<String?> open(
    BuildContext context,
  ) {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Wat wil je toevoegen?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                _rij(
                  context,
                  'Afspraak',
                  Colors.blue,
                  Icons.event,
                  'afspraak',
                ),
                _rij(
                  context,
                  'Dagtaak',
                  Colors.orange,
                  Icons.task_alt,
                  'dagtaak',
                ),
                _rij(
                  context,
                  'Verlof',
                  Colors.red,
                  Icons.beach_access,
                  'verlof',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _rij(
    BuildContext context,
    String titel,
    Color kleur,
    IconData icoon,
    String waarde,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: InkWell(
        onTap: () {
          Navigator.pop(
            context,
            waarde,
          );
        },
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          decoration: BoxDecoration(
            color: kleur.withValues(
              alpha: 0.08,
            ),
            borderRadius: BorderRadius.circular(
              14,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icoon,
                color: kleur,
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Text(
                  titel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
