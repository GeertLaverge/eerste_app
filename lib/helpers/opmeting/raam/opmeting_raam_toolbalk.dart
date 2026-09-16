import 'package:flutter/material.dart';

import '../../ui/thimaco_huisstijl.dart';

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

  bool get _kaderActief => actieveTool == 'kader';
  bool get _kadergroepActief => actieveTool == 'kadergroep';
  bool get _kaderToevoegenActief => actieveTool == 'kadertoevoegen';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: ThimacoKleuren.rand),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (!toonSchuifraamTools)
                _groep(
                  label: 'Algemeen',
                  children: <Widget>[
                    _toolKnop(
                      waarde: 'kadergroep',
                      label: 'Selecteren',
                      icoon: Icons.north_west_rounded,
                      tooltip: _kadergroepActief
                          ? 'Selecteren uitzetten'
                          : 'Kaders selecteren voor technische keuzes',
                      breedte: 76,
                      onTap: () {
                        onToolGekozen(
                          _kadergroepActief ? 'lijn' : 'kadergroep',
                        );
                      },
                    ),
                  ],
                ),
              _groep(
                label: 'Kader',
                children: <Widget>[
                  _toolKnop(
                    waarde: 'kader',
                    label: 'Kader',
                    icoon: Icons.open_with_rounded,
                    tooltip: _kaderActief
                        ? 'Kader wijzigen actief'
                        : 'Kader selecteren en afmetingen wijzigen',
                    breedte: 64,
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
                      breedte: 67,
                      onTap: () {
                        onToolGekozen(
                          _kaderToevoegenActief ? 'lijn' : 'kadertoevoegen',
                        );
                      },
                    ),
                  if (toonSchuifraamTools)
                    _toolKnop(
                      waarde: 'schuifraam_samenstellen',
                      label: 'Samenstellen',
                      icoon: Icons.view_week_outlined,
                      tooltip: 'Mono- of duo-schuifraam samenstellen',
                      breedte: 82,
                      onTap: onSchuifraamSamenstellen,
                    ),
                ],
              ),
              _groep(
                label: 'Indeling',
                children: <Widget>[
                  _toolKnop(
                    waarde: 'tstijl',
                    label: 'T-stijl',
                    icoon: Icons.format_align_center_rounded,
                    tooltip: 'T-stijl toevoegen',
                    breedte: 64,
                  ),
                ],
              ),
              _groep(
                label: 'Openingen',
                children: <Widget>[
                  if (!toonSchuifraamTools)
                    _toolKnop(
                      waarde: 'vleugel',
                      label: 'Raamvleugel',
                      icoon: Icons.crop_square_rounded,
                      tooltip: 'Raamvleugel toevoegen',
                      breedte: 82,
                    ),
                  if (toonDeurTools)
                    _toolKnop(
                      waarde: 'deurvleugel',
                      label: 'Deurvleugel',
                      icoon: Icons.door_front_door_outlined,
                      tooltip: 'Deurvleugel toevoegen',
                      breedte: 80,
                      onTap: onDeurVleugel ??
                          () => onToolGekozen('deurvleugel'),
                    ),
                ],
              ),
              _groep(
                label: 'Afwerking',
                laatste: true,
                children: <Widget>[
                  _toolKnop(
                    waarde: 'opvulling',
                    label: 'Opvulling',
                    icoon: Icons.layers_outlined,
                    tooltip: 'Opvulling kiezen',
                    breedte: 72,
                  ),
                  if (toonDeurTools)
                    _toolKnop(
                      waarde: 'deurpanelen',
                      label: 'Deurpanelen',
                      icoon: Icons.view_agenda_outlined,
                      tooltip: 'Deurpanelen toevoegen',
                      breedte: 82,
                      onTap: onDeurPanelen ??
                          () => onToolGekozen('deurpanelen'),
                    ),
                  _toolKnop(
                    waarde: 'kleinhout',
                    label: 'Kleinhout',
                    icoon: Icons.grid_on_rounded,
                    tooltip: 'Kleinhouten kiezen',
                    breedte: 72,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _groep({
    required String label,
    required List<Widget> children,
    bool laatste = false,
  }) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(right: laatste ? 0 : 7),
      padding: EdgeInsets.only(right: laatste ? 0 : 7),
      decoration: BoxDecoration(
        border: laatste
            ? null
            : const Border(
                right: BorderSide(color: ThimacoKleuren.rand),
              ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 48, child: Row(children: children)),
          const SizedBox(height: 1),
          Text(
            label,
            style: const TextStyle(
              color: ThimacoKleuren.tekstGrijs,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolKnop({
    required String waarde,
    required String label,
    required IconData icoon,
    required String tooltip,
    double breedte = 72,
    VoidCallback? onTap,
  }) {
    final geselecteerd = actieveTool == waarde;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: onTap ?? () => onToolGekozen(waarde),
        hoverColor: ThimacoKleuren.oranje.withValues(alpha: 0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: breedte,
          height: 46,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
          decoration: BoxDecoration(
            color: geselecteerd
                ? ThimacoKleuren.oranjeLicht
                : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            border: Border(
              bottom: BorderSide(
                color: geselecteerd
                    ? ThimacoKleuren.oranje
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icoon,
                size: 19,
                color: ThimacoKleuren.antraciet,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ThimacoKleuren.antraciet,
                  fontSize: 10.5,
                  fontWeight:
                      geselecteerd ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
