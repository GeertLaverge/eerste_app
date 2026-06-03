import 'package:flutter/material.dart';

import 'fiche/klantenfiche_model.dart';

class KlantenficheTaakveld extends StatelessWidget {
  final List<KlantTaakItem> taken;
  final VoidCallback? onChanged;

  const KlantenficheTaakveld({
    super.key,
    required this.taken,
    this.onChanged,
  });

  void _taakToevoegen() {
    taken.add(
      KlantTaakItem(),
    );

    onChanged?.call();
  }

  void _taakVerwijderen(int index) {
    taken.removeAt(index);

    onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (taken.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'Nog geen taken toegevoegd.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ...List.generate(taken.length, (index) {
          final taak = taken[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(
                      text: taak.tekst,
                    )..selection = TextSelection.collapsed(
                        offset: taak.tekst.length,
                      ),
                    onChanged: (waarde) {
                      taak.tekst = waarde;
                      onChanged?.call();
                    },
                    decoration: InputDecoration(
                      hintText: 'Taak...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE5E7EB),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE5E7EB),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF0B7A3B),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    _taakVerwijderen(index);
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          );
        }),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _taakToevoegen,
            icon: const Icon(Icons.add),
            label: const Text('Taak toevoegen'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0B7A3B),
              side: const BorderSide(
                color: Color(0xFF0B7A3B),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
