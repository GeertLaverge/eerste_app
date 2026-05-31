import 'package:flutter/material.dart';

class KlantenficheTaakveld extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onChanged;

  const KlantenficheTaakveld({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 5,
      maxLines: 10,
      onChanged: (_) {
        onChanged?.call();
      },
      decoration: InputDecoration(
        hintText: 'Taak voor klant...',
        filled: true,
        fillColor: Colors.white,
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
    );
  }
}
