import 'package:flutter/material.dart';

class KlantenBovenBalk extends StatelessWidget {
  final VoidCallback onTerug;
  final VoidCallback onNieuw;
  final VoidCallback? onUpload;

  const KlantenBovenBalk({
    super.key,
    required this.onTerug,
    required this.onNieuw,
    this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: const Color(0xFF0B7A3B),
      child: Row(
        children: [
          IconButton(
            onPressed: onTerug,
            icon: const Icon(Icons.home_rounded),
            color: Colors.white,
          ),
          Expanded(
            child: GestureDetector(
              onTap: onUpload,
              child: const Text(
                'Klanten',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onNieuw,
            icon: const Icon(Icons.add_rounded),
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
