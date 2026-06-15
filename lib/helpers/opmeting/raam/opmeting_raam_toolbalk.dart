import 'package:flutter/material.dart';

class OpmetingRaamToolbalk extends StatelessWidget {
  const OpmetingRaamToolbalk({
    super.key,
    required this.actieveTool,
    required this.onToolGekozen,
  });

  final String actieveTool;
  final ValueChanged<String> onToolGekozen;

  static const groen = Color(0xFF0B7A3B);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: _kaartDecoratie(),
      child: Row(
        children: [
          _knop('lijn', Icons.show_chart, 'Lijn'),
          _knop('driehoek', Icons.change_history, 'Driehoek'),
          _knop('tstijl', Icons.format_align_center, 'T-stijl'),
          _knop('middenstijl', Icons.add, 'Middenstijl'),
          _knop('vlak', Icons.select_all, 'Vlak'),
          const Spacer(),
          _knop('undo', Icons.undo, 'Ongedaan'),
          _knop('redo', Icons.redo, 'Herstel'),
        ],
      ),
    );
  }

  Widget _knop(
    String waarde,
    IconData icoon,
    String tekst,
  ) {
    final actief = actieveTool == waarde;

    return InkWell(
      onTap: () => onToolGekozen(waarde),
      child: Container(
        width: 78,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: actief ? const Color(0xFFE7F6EC) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: actief ? groen : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icoon,
              size: 19,
              color: actief ? groen : Colors.black87,
            ),
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

  BoxDecoration _kaartDecoratie() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: const Color(0xFFE5E7EB),
      ),
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
