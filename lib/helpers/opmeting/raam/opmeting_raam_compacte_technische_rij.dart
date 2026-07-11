import 'package:flutter/material.dart';

class OpmetingRaamCompacteTechnischeRij extends StatelessWidget {
  const OpmetingRaamCompacteTechnischeRij({
    super.key,
    required this.titel,
    required this.waarde,
    required this.isOpen,
    required this.heeftWaarde,
    required this.onTap,
    required this.inhoud,
  });

  static const Color groen = Color(0xFF0B7A3B);
  static const Color rand = Color(0xFFE5E7EB);
  static const Color tekstGrijs = Color(0xFF6B7280);

  final String titel;
  final String waarde;

  final bool isOpen;
  final bool heeftWaarde;

  final VoidCallback onTap;
  final Widget inhoud;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: rand)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      titel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 4,
                    child: Text(
                      waarde,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: heeftWaarde ? groen : tekstGrijs,
                        fontSize: 11.5,
                        fontWeight: heeftWaarde
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 19,
                    color: const Color(0xFF6B7280),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isOpen)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              border: Border(bottom: BorderSide(color: rand)),
            ),
            child: inhoud,
          ),
      ],
    );
  }
}
