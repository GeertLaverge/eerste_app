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

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  bool get _kaderActief {
    return actieveTool == 'kader';
  }

  bool get _kadergroepActief {
    return actieveTool == 'kadergroep';
  }

  bool get _kaderToevoegenActief {
    return actieveTool == 'kadertoevoegen';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rand),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _toolKnop(
              waarde: 'kader',
              label: 'Kader',
              icoon: Icons.open_with_rounded,
              tooltip: _kaderActief
                  ? 'Kader wijzigen actief'
                  : 'Kader selecteren en afmetingen wijzigen',
              breedte: 76,
              onTap: () {
                onToolGekozen(_kaderActief ? 'lijn' : 'kader');
              },
            ),
            _toolKnop(
              waarde: 'kadertoevoegen',
              label: 'Kader +',
              icoon: Icons.add_box_outlined,
              tooltip: _kaderToevoegenActief
                  ? 'Kader toevoegen uitzetten'
                  : 'Extra kader toevoegen',
              breedte: 80,
              onTap: () {
                onToolGekozen(
                  _kaderToevoegenActief ? 'lijn' : 'kadertoevoegen',
                );
              },
            ),
            _toolKnop(
              waarde: 'kadergroep',
              label: 'Groeperen',
              icoon: Icons.select_all_rounded,
              tooltip: _kadergroepActief
                  ? 'Groeperen voor technische keuzes uitzetten'
                  : 'Meerdere kaders groeperen voor technische keuzes',
              breedte: 92,
              onTap: () {
                onToolGekozen(_kadergroepActief ? 'lijn' : 'kadergroep');
              },
            ),
            _toolKnop(
              waarde: 'tstijl',
              label: 'T-stijl',
              icoon: Icons.format_align_center_rounded,
              tooltip: 'T-stijl toevoegen',
              breedte: 76,
            ),
            _toolKnop(
              waarde: 'vleugel',
              label: 'Vleugel',
              icoon: Icons.crop_square_rounded,
              tooltip: 'Vleugel toevoegen',
              breedte: 76,
            ),
            _toolKnop(
              waarde: 'opvulling',
              label: 'Opvulling',
              icoon: Icons.layers_outlined,
              tooltip: 'Opvulling kiezen',
              breedte: 84,
            ),
            _toolKnop(
              waarde: 'kleinhout',
              label: 'Kleinhout',
              icoon: Icons.grid_on_rounded,
              tooltip: 'Kleinhouten kiezen',
              breedte: 84,
            ),
            const SizedBox(width: 18),
            _actieKnop(
              label: 'Ongedaan',
              icoon: Icons.undo_rounded,
              actief: kanOngedaanMaken,
              onTap: onOngedaanMaken,
            ),
            const SizedBox(width: 8),
            _actieKnop(
              label: 'Herstel',
              icoon: Icons.redo_rounded,
              actief: kanHerstellen,
              onTap: onHerstellen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolKnop({
    required String waarde,
    required String label,
    required IconData icoon,
    required String tooltip,
    double breedte = 84,
    VoidCallback? onTap,
  }) {
    final geselecteerd = actieveTool == waarde;

    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap:
              onTap ??
              () {
                onToolGekozen(waarde);
              },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: breedte,
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            decoration: BoxDecoration(
              color: geselecteerd ? _lichtGroen : Colors.transparent,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: geselecteerd ? _groen : Colors.transparent,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icoon,
                  size: 23,
                  color: geselecteerd ? _groen : _tekstDonker,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: geselecteerd ? _groen : _tekstDonker,
                    fontSize: 12,
                    fontWeight: geselecteerd
                        ? FontWeight.w900
                        : FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actieKnop({
    required String label,
    required IconData icoon,
    required bool actief,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: actief ? onTap : null,
        child: SizedBox(
          width: 76,
          height: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icoon,
                size: 22,
                color: actief ? _tekstDonker : const Color(0xFFCBD5E1),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: actief ? _tekstGrijs : const Color(0xFFCBD5E1),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
