import 'package:flutter/material.dart';

class KlantenficheUitvalBlok extends StatefulWidget {
  final String titel;
  final Widget child;
  final bool standaardOpen;
  final String? rechterTekst;
  final Color? rechterBolKleur;

  const KlantenficheUitvalBlok({
    super.key,
    required this.titel,
    required this.child,
    this.standaardOpen = false,
    this.rechterTekst,
    this.rechterBolKleur,
  });

  @override
  State<KlantenficheUitvalBlok> createState() => _KlantenficheUitvalBlokState();
}

class _KlantenficheUitvalBlokState extends State<KlantenficheUitvalBlok> {
  late bool open;

  @override
  void initState() {
    super.initState();
    open = widget.standaardOpen;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                open = !open;
              });
            },
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Icon(
                    open
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_right_rounded,
                    color: const Color(0xFF0B7A3B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.titel,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const Spacer(),
                  if (widget.rechterTekst != null) ...[
                    if (widget.rechterBolKleur != null)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: widget.rechterBolKleur,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Text(
                      widget.rechterTekst!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (open)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: widget.child,
            ),
        ],
      ),
    );
  }
}
