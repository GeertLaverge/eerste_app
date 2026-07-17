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
    this.toonDeurTools = false,
    this.onDeurVleugel,
    this.onDeurPanelen,
    this.toonSchuifraamTools = false,
    this.onSchuifraamSamenstellen,
  });

  final String actieveTool;
  final ValueChanged<String> onToolGekozen;
  final bool kanOngedaanMaken;
  final bool kanHerstellen;
  final VoidCallback onOngedaanMaken;
  final VoidCallback onHerstellen;
  final bool toonDeurTools;
  final VoidCallback? onDeurVleugel;
  final VoidCallback? onDeurPanelen;
  final bool toonSchuifraamTools;
  final VoidCallback? onSchuifraamSamenstellen;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  bool get _kaderActief => actieveTool == 'kader';
  bool get _kadergroepActief => actieveTool == 'kadergroep';
  bool get _kaderToevoegenActief => actieveTool == 'kadertoevoegen';

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
              breedte: 72,
              onTap: () {
                onToolGekozen(_kaderActief ? 'lijn' : 'kader');
              },
            ),
            if (!toonSchuifraamTools)
              _toolKnop(
                waarde: 'kadertoevoegen',
                label: 'Kader +',
                icoon: Icons.add_box_outlined,
                tooltip: _kaderToevoegenActief
                    ? 'Kader toevoegen uitzetten'
                    : 'Extra kader toevoegen',
                breedte: 74,
                onTap: () {
                  onToolGekozen(
                    _kaderToevoegenActief ? 'lijn' : 'kadertoevoegen',
                  );
                },
              ),
            if (!toonSchuifraamTools)
              _toolKnop(
                waarde: 'kadergroep',
                label: 'Selecteren',
                icoon: Icons.north_west_rounded,
                tooltip: _kadergroepActief
                    ? 'Selecteren uitzetten'
                    : 'Kaders selecteren voor technische keuzes',
                breedte: 86,
                onTap: () {
                  onToolGekozen(_kadergroepActief ? 'lijn' : 'kadergroep');
                },
              ),
            if (toonSchuifraamTools)
              _toolKnop(
                waarde: 'schuifraam_samenstellen',
                label: 'Schuifraam\nsamenstellen',
                icoon: Icons.view_week_outlined,
                tooltip: 'Mono- of duo-schuifraam samenstellen',
                breedte: 104,
                onTap: onSchuifraamSamenstellen,
              ),
            _toolKnop(
              waarde: 'tstijl',
              label: 'T-stijl',
              icoon: Icons.format_align_center_rounded,
              tooltip: 'T-stijl toevoegen',
              breedte: 70,
            ),
            if (!toonSchuifraamTools)
              _toolKnop(
                waarde: 'vleugel',
                label: 'Raam\nvleugel',
                icoon: Icons.crop_square_rounded,
                tooltip: 'Raamvleugel toevoegen',
                breedte: toonDeurTools ? 72 : 82,
              ),
            if (toonDeurTools)
              _toolKnop(
                waarde: 'deurvleugel',
                label: 'Deur\nvleugel',
                icoon: Icons.door_front_door_outlined,
                tooltip: 'Deurvleugel toevoegen',
                breedte: 72,
                onTap:
                    onDeurVleugel ??
                    () {
                      onToolGekozen('deurvleugel');
                    },
              ),
            _toolKnop(
              waarde: 'opvulling',
              label: 'Opvulling',
              icoon: Icons.layers_outlined,
              tooltip: 'Opvulling kiezen',
              breedte: 78,
            ),
            if (toonDeurTools)
              _toolKnop(
                waarde: 'deurpanelen',
                label: 'Deur\npanelen',
                icoon: Icons.view_agenda_outlined,
                tooltip: 'Deurpanelen toevoegen',
                breedte: 72,
                onTap:
                    onDeurPanelen ??
                    () {
                      onToolGekozen('deurpanelen');
                    },
              ),
            _toolKnop(
              waarde: 'kleinhout',
              label: 'Kleinhout',
              icoon: Icons.grid_on_rounded,
              tooltip: 'Kleinhouten kiezen',
              breedte: 78,
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
    double breedte = 78,
    VoidCallback? onTap,
  }) {
    final geselecteerd = actieveTool == waarde;

    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: onTap ?? () => onToolGekozen(waarde),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: breedte,
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
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
                  size: 22,
                  color: geselecteerd ? _groen : _tekstDonker,
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: geselecteerd ? _groen : _tekstDonker,
                    fontSize: label.contains('\n') ? 10.5 : 11.5,
                    height: 0.98,
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
          width: 70,
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
                  fontSize: 11,
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
