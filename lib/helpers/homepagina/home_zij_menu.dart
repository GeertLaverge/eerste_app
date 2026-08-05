// THIMACO-CONTROLE: HOME-IPHONE-CAPSULEKNOPPEN-MET-BESTAANDE-ROUTES-20260805
// THIMACO-CONTROLE: MAGAZIJN-HOME-ROUTE-20260804
import 'package:flutter/material.dart';

import '../../paginas/agenda_pagina_nieuw.dart' as agenda;
import '../../paginas/bibliotheek_pagina.dart';
import '../../paginas/klanten_pagina.dart';
import '../../paginas/magazijn/magazijn_pagina.dart';
import '../../paginas/notities_bureau_pagina.dart';
import '../../paginas/opmeting_pagina.dart' as opmeting;

class HomeZijMenu extends StatelessWidget {
  final bool compact;
  final Future<void> Function()? onAfsluiten;
  final bool afsluitenBezig;

  const HomeZijMenu({
    super.key,
    required this.compact,
    this.onAfsluiten,
    this.afsluitenBezig = false,
  });

  static const Color groen = Color(0xFF0B7A3B);
  static const Color rand = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 78 : 205,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: rand)),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(height: compact ? 10 : 16),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: compact ? 7 : 14),
              child: Column(
                children: <Widget>[
                  _menuKnop(
                    context,
                    'Agenda',
                    Icons.calendar_month_outlined,
                    actief: true,
                  ),
                  _menuKnop(context, 'Klanten', Icons.groups_outlined),
                  _menuKnop(
                    context,
                    'Notitie\'s\nplaatsers',
                    Icons.description_outlined,
                  ),
                  _menuKnop(
                    context,
                    'Notitie\'s\nbureau',
                    Icons.edit_note_outlined,
                  ),
                  _menuKnop(context, 'Opmeting', Icons.straighten_outlined),
                  _menuKnop(context, 'Puinzak', Icons.delete_outline),
                  _menuKnop(context, 'Magazijn', Icons.inventory_2_outlined),
                  _menuKnop(
                    context,
                    'Bibliotheek',
                    Icons.local_library_outlined,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: rand),
          Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 7 : 14,
              compact ? 10 : 14,
              compact ? 7 : 14,
              compact ? 10 : 14,
            ),
            child: _menuKnop(
              context,
              afsluitenBezig ? 'Bewaren…' : 'Afsluiten',
              Icons.power_settings_new_rounded,
              onTap: afsluitenBezig ? null : onAfsluiten,
              bezig: afsluitenBezig,
              onderMarge: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuKnop(
    BuildContext context,
    String titel,
    IconData icoon, {
    bool actief = false,
    Future<void> Function()? onTap,
    bool bezig = false,
    double onderMarge = 10,
  }) {
    final Color achtergrondKleur = actief
        ? const Color(0xFFEAF6EE)
        : Colors.white;
    final Color voorgrondKleur = actief ? groen : const Color(0xFF27302B);

    return Padding(
      padding: EdgeInsets.only(bottom: onderMarge),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: bezig
              ? null
              : () async {
                  if (onTap != null) {
                    await onTap();
                    return;
                  }

                  // TIJDELIJK UITGESCHAKELD VOOR SYNC DEBUG
                  /*
                  await SyncNavigatieHelper.openMetDownload(
                    context: context,
                    pagina: pagina,
                  );
                  */

                  if (titel == 'Agenda') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const agenda.AgendaPaginaNieuw(),
                      ),
                    );
                    return;
                  }

                  if (titel == 'Klanten') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const KlantenPagina()),
                    );
                    return;
                  }

                  if (titel.contains('bureau')) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotitiesBureauPagina(),
                      ),
                    );
                    return;
                  }

                  if (titel == 'Magazijn') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MagazijnPagina()),
                    );
                    return;
                  }

                  if (titel == 'Bibliotheek') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BibliotheekPagina(),
                      ),
                    );
                    return;
                  }

                  if (titel == 'Opmeting') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const opmeting.OpmetingPagina(),
                      ),
                    );
                    return;
                  }
                },
          child: Ink(
            height: compact ? 66 : 58,
            decoration: BoxDecoration(
              color: achtergrondKleur,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: actief
                    ? const Color(0xFFCDE8D5)
                    : const Color(0xFFEDF0EE),
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: compact
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _bouwIcoon(
                        icoon: icoon,
                        kleur: voorgrondKleur,
                        bezig: bezig,
                        grootte: 21,
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Text(
                          titel,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: voorgrondKleur,
                            fontSize: 9.5,
                            height: 1,
                            fontWeight: actief
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      children: <Widget>[
                        _bouwIcoon(
                          icoon: icoon,
                          kleur: voorgrondKleur,
                          bezig: bezig,
                          grootte: 21,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            titel.replaceAll('\n', ' '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: voorgrondKleur,
                              fontSize: 13,
                              height: 1.1,
                              fontWeight: actief
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _bouwIcoon({
    required IconData icoon,
    required Color kleur,
    required bool bezig,
    required double grootte,
  }) {
    if (bezig) {
      return SizedBox(
        width: grootte,
        height: grootte,
        child: const CircularProgressIndicator(strokeWidth: 2.2, color: groen),
      );
    }

    return Icon(icoon, size: grootte, color: kleur);
  }
}
