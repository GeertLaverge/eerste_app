import 'package:flutter/material.dart';

class UitklapbareSectie extends StatelessWidget {
  final String titel;
  final IconData icoon;
  final bool geopend;
  final VoidCallback onToggle;
  final List<Widget> children;

  const UitklapbareSectie({
    super.key,
    required this.titel,
    required this.icoon,
    required this.geopend,
    required this.onToggle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(icoon, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      titel,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    geopend
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),
          ),
          if (geopend)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(children: children),
            ),
        ],
      ),
    );
  }
}
