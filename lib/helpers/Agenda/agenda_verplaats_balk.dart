import 'package:flutter/material.dart';

import 'agenda_item.dart';

class AgendaVerplaatsBalk extends StatelessWidget {
  final AgendaItem item;

  const AgendaVerplaatsBalk({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      color: const Color(0xFFE7F6EC),
      child: Text(
        'Verplaatsen: ${item.titel}',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF0B7A3B),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
