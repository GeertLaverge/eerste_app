import 'package:flutter/material.dart';

class InvoerVeld extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const InvoerVeld({
    super.key,
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
