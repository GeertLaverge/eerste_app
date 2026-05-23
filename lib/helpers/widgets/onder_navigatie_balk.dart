import 'package:flutter/material.dart';

class OnderNavigatieBalk extends StatelessWidget {
  final String huidigePagina;
  final VoidCallback? onAgenda;
  final VoidCallback? onKlanten;

  const OnderNavigatieBalk({
    super.key,
    required this.huidigePagina,
    this.onAgenda,
    this.onKlanten,
  });

  bool get isAgenda => huidigePagina == 'agenda';
  bool get isKlanten => huidigePagina == 'klanten';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SizedBox(
          height: 46,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _knop(
                actief: isAgenda,
                icoon: Icons.calendar_month,
                onTap: isAgenda ? null : onAgenda,
              ),
              const SizedBox(width: 42),
              _homeKnop(context),
              const SizedBox(width: 42),
              _knop(
                actief: isKlanten,
                icoon: Icons.groups,
                onTap: isKlanten ? null : onKlanten,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _knop({
    required bool actief,
    required IconData icoon,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: Opacity(
        opacity: actief ? 0.30 : 1,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icoon,
            size: 24,
            color: actief ? Colors.grey : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _homeKnop(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: () {
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Image.asset(
          'assets/images/thimaco_logo_icon.png',
          width: 28,
          height: 28,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
