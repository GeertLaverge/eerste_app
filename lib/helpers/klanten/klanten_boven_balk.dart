import 'package:flutter/material.dart';

class KlantenBovenBalk extends StatelessWidget {
  final VoidCallback onTerug;
  final VoidCallback onNieuw;

  const KlantenBovenBalk({
    super.key,
    required this.onTerug,
    required this.onNieuw,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: const Color(0xFFF7F8FA),
      child: Row(
        children: [
          IconButton(
            onPressed: onTerug,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: const Color(0xFF1F2937),
          ),
          const Expanded(
            child: Text(
              'Klanten',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          IconButton(
            onPressed: onNieuw,
            icon: const Icon(Icons.add_rounded),
            color: const Color(0xFF1F2937),
          ),
        ],
      ),
    );
  }
}
