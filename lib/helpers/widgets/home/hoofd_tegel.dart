import 'package:flutter/material.dart';

class HoofdTegel extends StatelessWidget {
  final IconData icoon;
  final String titel;
  final Color kleur;
  final VoidCallback onTap;

  const HoofdTegel({
    super.key,
    required this.icoon,
    required this.titel,
    required this.kleur,
    required this.onTap,
  });

  static const Color donkerTekst = Color(0xFF111827);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 135,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: kleur.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: kleur.withValues(alpha: 0.22)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icoon, size: 44, color: kleur),
              const SizedBox(height: 18),
              Text(
                titel,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: donkerTekst,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
