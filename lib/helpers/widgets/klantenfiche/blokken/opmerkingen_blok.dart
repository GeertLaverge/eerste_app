import 'package:flutter/material.dart';

import '../uitklapbare_sectie.dart';

class OpmerkingenBlok extends StatelessWidget {
  final bool geopend;
  final VoidCallback onToggle;

  final bool toonOpmerkingen;
  final ValueChanged<bool> onToonOpmerkingenChanged;

  final TextEditingController opmerkingenController;
  final Future<void> Function() onChanged;

  const OpmerkingenBlok({
    super.key,
    required this.geopend,
    required this.onToggle,
    required this.toonOpmerkingen,
    required this.onToonOpmerkingenChanged,
    required this.opmerkingenController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return UitklapbareSectie(
      titel: 'Opmerkingen',
      icoon: Icons.notes,
      geopend: geopend,
      onToggle: onToggle,
      children: [
        TextField(
          controller: opmerkingenController,
          maxLines: 4,
          onChanged: (_) async {
            onToonOpmerkingenChanged(
              opmerkingenController.text.trim().isNotEmpty,
            );
            await onChanged();
          },
          decoration: InputDecoration(
            hintText: 'Typ opmerkingen...',
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: Colors.blueGrey,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
