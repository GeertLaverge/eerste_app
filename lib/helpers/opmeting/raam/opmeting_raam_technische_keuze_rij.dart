import 'package:flutter/material.dart';

class OpmetingRaamTechnischeKeuzeRij extends StatelessWidget {
  const OpmetingRaamTechnischeKeuzeRij({
    super.key,
    required this.titel,
    required this.soorten,
    required this.gekozenSoort,
    required this.onGewijzigd,
  });

  final String titel;
  final List<String> soorten;
  final String gekozenSoort;

  final ValueChanged<String> onGewijzigd;

  String get _zichtbareKeuze {
    if (soorten.contains(gekozenSoort)) {
      return gekozenSoort;
    }

    if (soorten.isNotEmpty) {
      return soorten.first;
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    final thema = Theme.of(context);
    final keuze = _zichtbareKeuze;

    return SizedBox(
      height: 40,
      child: PopupMenuButton<String>(
        enabled: soorten.isNotEmpty,
        initialValue: keuze.isEmpty ? null : keuze,
        position: PopupMenuPosition.under,
        padding: EdgeInsets.zero,
        tooltip: '',
        onSelected: onGewijzigd,
        itemBuilder: (context) {
          return soorten.map((soort) {
            final geselecteerd = soort == keuze;

            return PopupMenuItem<String>(
              value: soort,
              height: 38,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      soort,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: thema.textTheme.bodyMedium?.copyWith(
                        fontWeight: geselecteerd
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (geselecteerd)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.check,
                        size: 17,
                        color: Color(0xFF0B7A3B),
                      ),
                    ),
                ],
              ),
            );
          }).toList();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Text(
                  titel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: thema.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 4,
                child: Text(
                  keuze.isEmpty ? 'Geen keuze' : keuze,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: thema.textTheme.bodySmall?.copyWith(
                    color: keuze.isEmpty
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF4B5563),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 19,
                color: soorten.isEmpty
                    ? const Color(0xFFD1D5DB)
                    : const Color(0xFF6B7280),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
