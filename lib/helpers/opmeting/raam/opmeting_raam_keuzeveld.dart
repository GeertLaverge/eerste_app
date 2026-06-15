import 'package:flutter/material.dart';

class OpmetingRaamKeuzeveld extends StatelessWidget {
  const OpmetingRaamKeuzeveld({
    super.key,
    required this.titel,
    required this.waarde,
    required this.keuzes,
    required this.onGekozen,
  });

  final String titel;
  final String waarde;
  final List<String> keuzes;
  final ValueChanged<String> onGekozen;

  static const groen = Color(0xFF0B7A3B);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: Colors.white,
      elevation: 8,
      onSelected: onGekozen,
      itemBuilder: (context) {
        return keuzes.map((keuze) {
          final actief = keuze == waarde;

          return PopupMenuItem<String>(
            value: keuze,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    keuze,
                    style: TextStyle(
                      fontWeight: actief ? FontWeight.w800 : FontWeight.w500,
                      color: actief ? groen : Colors.black87,
                    ),
                  ),
                ),
                if (actief)
                  const Icon(
                    Icons.check,
                    size: 18,
                    color: groen,
                  ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: const Color(0xFFD1D5DB),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                titel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Flexible(
              child: Text(
                waarde,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
