import 'package:flutter/material.dart';

class SchakelBalk extends StatelessWidget {
  final String titel;
  final String subtitel;
  final IconData icoon;
  final bool waarde;
  final ValueChanged<bool> onChanged;

  const SchakelBalk({
    super.key,
    required this.titel,
    required this.subtitel,
    required this.icoon,
    required this.waarde,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:
            waarde ? Colors.green.withValues(alpha: 0.08) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: waarde
              ? Colors.green.withValues(alpha: 0.40)
              : Colors.grey.shade300,
        ),
      ),
      child: SwitchListTile(
        value: waarde,
        onChanged: onChanged,
        secondary: Icon(
          icoon,
          color: waarde ? Colors.green : Colors.grey.shade600,
        ),
        title: Text(
          titel,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitel),
      ),
    );
  }
}
