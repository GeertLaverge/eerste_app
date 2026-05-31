import 'package:flutter/material.dart';

class KlantenficheBovenBalk extends StatelessWidget {
  final String titel;
  final VoidCallback onTerug;

  const KlantenficheBovenBalk({
    super.key,
    required this.titel,
    required this.onTerug,
  });

  static const groen = Color(0xFF0B7A3B);
  static const achtergrond = Color(0xFFF7F8FA);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      color: achtergrond,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onTerug,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              titel,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(
            width: 48,
          ),
        ],
      ),
    );
  }
}
