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
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 460,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                18,
                18,
                18,
                14,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Wat wil je toevoegen?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
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
    return InkWell(
      onTap: () {
        Navigator.pop(
          context,
          waarde,
        );
      },
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icoon,
              color: kleur,
              size: 21,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                titel,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}
