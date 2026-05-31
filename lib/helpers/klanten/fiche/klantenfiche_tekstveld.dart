import 'package:flutter/material.dart';

class KlantenficheTekstveld extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  final bool toonMenuKnop;
  final VoidCallback? onMenuTap;

  const KlantenficheTekstveld({
    super.key,
    required this.label,
    required this.controller,
    this.onChanged,
    this.toonMenuKnop = false,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: toonMenuKnop
              ? IconButton(
                  onPressed: onMenuTap,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                  ),
                )
              : null,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 12,
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xFFBDBDBD),
            ),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xFF0B7A3B),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
