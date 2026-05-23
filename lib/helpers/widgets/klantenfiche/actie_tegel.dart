import 'package:flutter/material.dart';

class ActieTegel extends StatelessWidget {
  final IconData icoon;
  final String titel;
  final Color kleur;
  final VoidCallback onTap;

  const ActieTegel({
    super.key,
    required this.icoon,
    required this.titel,
    required this.kleur,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 105,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: kleur.withValues(alpha: 0.08),
            border: Border.all(color: kleur.withValues(alpha: 0.22)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icoon, size: 30, color: kleur),
              const SizedBox(height: 8),
              Text(
                titel,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
