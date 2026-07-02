import 'package:flutter/material.dart';

class OpmetingRaamToolbalk extends StatelessWidget {
  const OpmetingRaamToolbalk({
    super.key,
    required this.actieveTool,
    required this.onToolGekozen,
    required this.kanOngedaanMaken,
    required this.kanHerstellen,
    required this.onOngedaanMaken,
    required this.onHerstellen,
  });

  final String actieveTool;
  final ValueChanged<String> onToolGekozen;

  final bool kanOngedaanMaken;
  final bool kanHerstellen;

  final VoidCallback onOngedaanMaken;
  final VoidCallback onHerstellen;

  static const Color groen = Color(0xFF0B7A3B);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: _kaartDecoratie(),
      child: Row(
        children: [
          _toolKnop(waarde: 'lijn', icoon: Icons.show_chart, tekst: 'Lijn'),
          _toolKnop(
            waarde: 'tstijl',
            icoon: Icons.format_align_center,
            tekst: 'T-stijl',
          ),
          _toolKnop(
            waarde: 'vleugel',
            icoon: Icons.crop_square,
            tekst: 'Vleugel',
          ),
          _toolKnop(
            waarde: 'opvulling',
            icoon: Icons.layers_outlined,
            tekst: 'Opvulling',
          ),
          _toolKnop(
            waarde: 'kleinhout',
            icoon: Icons.grid_on_outlined,
            tekst: 'Kleinhouten',
          ),
          const Spacer(),
          _actieKnop(
            icoon: Icons.undo,
            tekst: 'Ongedaan',
            ingeschakeld: kanOngedaanMaken,
            onTap: onOngedaanMaken,
          ),
          _actieKnop(
            icoon: Icons.redo,
            tekst: 'Herstel',
            ingeschakeld: kanHerstellen,
            onTap: onHerstellen,
          ),
        ],
      ),
    );
  }

  Widget _toolKnop({
    required String waarde,
    required IconData icoon,
    required String tekst,
  }) {
    final actief = actieveTool == waarde;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        onToolGekozen(waarde);
      },
      child: Container(
        width: 78,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: actief ? const Color(0xFFE7F6EC) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: actief ? groen : Colors.transparent),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icoon, size: 19, color: actief ? groen : Colors.black87),
            const SizedBox(height: 3),
            Text(
              tekst,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: actief ? FontWeight.w800 : FontWeight.w500,
                color: actief ? groen : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actieKnop({
    required IconData icoon,
    required String tekst,
    required bool ingeschakeld,
    required VoidCallback onTap,
  }) {
    final kleur = ingeschakeld
        ? const Color(0xFF111827)
        : const Color(0xFFB6BBC3);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: ingeschakeld ? onTap : null,
      child: Container(
        width: 78,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: ingeschakeld ? const Color(0xFFF9FAFB) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: ingeschakeld ? const Color(0xFFE5E7EB) : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icoon, size: 19, color: kleur),
            const SizedBox(height: 3),
            Text(
              tekst,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: kleur,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _kaartDecoratie() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE5E7EB)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.035),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
