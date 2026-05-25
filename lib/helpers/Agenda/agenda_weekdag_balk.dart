import 'package:flutter/material.dart';

class AgendaWeekdagBalk extends StatelessWidget {
  const AgendaWeekdagBalk({super.key});

  @override
  Widget build(BuildContext context) {
    const dagNamen = [
      'Ma',
      'Di',
      'Wo',
      'Do',
      'Vr',
      'Za',
      'Zo',
    ];

    return Container(
      color: const Color(0xFFE7F6EC),
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: dagNamen.map((dag) {
          return Expanded(
            child: Center(
              child: Text(
                dag,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0B7A3B),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
