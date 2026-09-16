// THIMACO-CONTROLE: TECHNISCHE-KEUZES-VERPLAATSKNOPPEN-SCHAKELBAAR-20260914
// THIMACO-CONTROLE: TECHNISCHE-KEUZES-GROEPEN-RIBBON-FASE10-20260913
// THIMACO-CONTROLE: RAAM-TEKENPROGRAMMA-V9-RIBBON-ZICHTBARE-KEUZE-FIX-20260913
// THIMACO-CONTROLE: RAAM-TEKENPROGRAMMA-V8-UNIEKE-RIBBON-CONTROLE-20260913
// THIMACO-CONTROLE: RAAM-TEKENPROGRAMMA-FASE7-STABIELE-TECHNIEK-WEERGAVE-20260913
import 'dart:async';

import 'package:flutter/material.dart';

import '../../ui/thimaco_huisstijl.dart';
import 'opmeting_raam_keuzemenu_model.dart';
import 'opmeting_raam_technische_groep_model.dart';
import 'opmeting_raam_kleinhout_helper.dart';
import 'opmeting_raam_technische_keuzes_paneel.dart';
import 'opmeting_raam_vulling_helper.dart';

class OpmetingRaamTechnischeKeuzesRibbonV10 extends StatelessWidget {
  const OpmetingRaamTechnischeKeuzesRibbonV10({
    super.key,
    required this.keuzemenus,
    required this.technischeGroepen,
    required this.keuzemenusLaden,
    required this.keuzemenusBewaren,
    required this.menuBeheerOntgrendeld,
    required this.gekozenOpvullingen,
    required this.gekozenKleinhouten,
    required this.opvullingenOpen,
    required this.kleinhoutenOpen,
    required this.onOpvullingenOpenGewijzigd,
    required this.onKleinhoutenOpenGewijzigd,
    required this.geselecteerdeOptieIdVoorMenu,
    required this.onOptieGekozen,
    required this.onMenuToevoegen,
    this.onTitelOpladen,
    required this.onKeuzeToevoegen,
    required this.onSubmenuToevoegen,
    required this.onMenuKopieren,
    required this.onItemKopieren,
    required this.onBeheerSlotWisselen,
    required this.onMenuAanpassen,
    required this.onMenuOmhoog,
    required this.onMenuOmlaag,
    required this.onMenuVerwijderen,
    required this.onMenuVolgordeGewijzigd,
    required this.toonVerplaatsKnoppen,
    required this.samenvattingPerMenu,
  });

  final List<OpmetingRaamKeuzeMenu> keuzemenus;
  final List<OpmetingRaamTechnischeGroep> technischeGroepen;
  final bool keuzemenusLaden;
  final bool keuzemenusBewaren;
  final bool menuBeheerOntgrendeld;
  final List<OpmetingRaamVullingLegendaItem> gekozenOpvullingen;
  final List<OpmetingRaamKleinhoutLegendaItem> gekozenKleinhouten;
  final bool opvullingenOpen;
  final bool kleinhoutenOpen;
  final ValueChanged<bool> onOpvullingenOpenGewijzigd;
  final ValueChanged<bool> onKleinhoutenOpenGewijzigd;
  final String? Function(OpmetingRaamKeuzeMenu menu)
  geselecteerdeOptieIdVoorMenu;
  final Future<void> Function(OpmetingRaamKeuzeMenu menu, String optieId)
  onOptieGekozen;
  final Future<void> Function() onMenuToevoegen;
  final Future<void> Function()? onTitelOpladen;
  final Future<void> Function(
    OpmetingRaamKeuzeMenu menu,
    String? ouderSubmenuId,
  )
  onKeuzeToevoegen;
  final Future<void> Function(
    OpmetingRaamKeuzeMenu menu,
    String? ouderSubmenuId,
  )
  onSubmenuToevoegen;
  final Future<void> Function(OpmetingRaamKeuzeMenu menu) onMenuKopieren;
  final Future<void> Function(
    OpmetingRaamKeuzeMenu menu,
    OpmetingRaamKeuzeMenuItem item,
  )
  onItemKopieren;
  final Future<void> Function() onBeheerSlotWisselen;
  final Future<void> Function(OpmetingRaamKeuzeMenu menu) onMenuAanpassen;
  final void Function(OpmetingRaamKeuzeMenu menu) onMenuOmhoog;
  final void Function(OpmetingRaamKeuzeMenu menu) onMenuOmlaag;
  final Future<void> Function(OpmetingRaamKeuzeMenu menu) onMenuVerwijderen;
  final Future<void> Function(List<String> menuIdsInVolgorde)
  onMenuVolgordeGewijzigd;
  final bool toonVerplaatsKnoppen;
  final Map<String, String> samenvattingPerMenu;

  @override
  Widget build(BuildContext context) {
    final alleMenus = keuzemenus
        .where((menu) => menuBeheerOntgrendeld || menu.actief)
        .toList()
      ..sort((eerste, tweede) {
        final volgorde = eerste.volgorde.compareTo(tweede.volgorde);
        if (volgorde != 0) return volgorde;
        return eerste.titel.toLowerCase().compareTo(tweede.titel.toLowerCase());
      });

    final groepen = List<OpmetingRaamTechnischeGroep>.from(technischeGroepen)
      ..sort((eerste, tweede) {
        final volgorde = eerste.volgorde.compareTo(tweede.volgorde);
        if (volgorde != 0) return volgorde;
        return eerste.naam.toLowerCase().compareTo(tweede.naam.toLowerCase());
      });
    final groepIds = groepen.map((groep) => groep.id).toSet();
    final nietIngedeeld = alleMenus.where((menu) {
      final groepId = menu.groepId.trim();
      return groepId.isEmpty || !groepIds.contains(groepId);
    }).toList();
    final zichtbareGroepen = groepen.where((groep) => groep.zichtbaar).toList();

    final rijen = <Widget>[];
    if (nietIngedeeld.isNotEmpty) {
      rijen.add(
        _bouwGroepRij(
          context: context,
          groepNaam: 'Niet ingedeeld',
          menus: nietIngedeeld,
          alleMenus: alleMenus,
        ),
      );
    }

    for (final groep in zichtbareGroepen) {
      final menusInGroep = alleMenus
          .where((menu) => menu.groepId.trim() == groep.id)
          .toList();
      rijen.add(
        _bouwGroepRij(
          context: context,
          groepNaam: groep.naam,
          menus: menusInGroep,
          alleMenus: alleMenus,
        ),
      );
    }

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: ThimacoKleuren.rand)),
      ),
      child: keuzemenusLaden
          ? const SizedBox(
              height: 82,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 14),
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ThimacoKleuren.oranje,
                    ),
                  ),
                ),
              ),
            )
          : rijen.isEmpty
          ? const SizedBox(
              height: 82,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    'Geen technische groepen zichtbaar. Open “Technische keuzes ▾” om een groep te tonen of toe te voegen.',
                    style: TextStyle(
                      color: ThimacoKleuren.tekstGrijs,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              primary: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (var index = 0; index < rijen.length; index++) ...<Widget>[
                    rijen[index],
                    if (index < rijen.length - 1)
                      const Divider(height: 1, color: ThimacoKleuren.rand),
                  ],
                  if (keuzemenusBewaren)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(14, 4, 14, 7),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.7,
                            color: ThimacoKleuren.oranje,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _bouwGroepRij({
    required BuildContext context,
    required String groepNaam,
    required List<OpmetingRaamKeuzeMenu> menus,
    required List<OpmetingRaamKeuzeMenu> alleMenus,
  }) {
    return SizedBox(
      height: 78,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            width: 118,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    groepNaam.trim().isEmpty ? 'Technische groep' : groepNaam,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ThimacoKleuren.antraciet,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 28,
                    height: 1.5,
                    decoration: BoxDecoration(
                      color: ThimacoKleuren.oranje.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(width: 1, color: ThimacoKleuren.rand),
          Expanded(
            child: menus.isEmpty
                ? const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Nog geen technische keuzes in deze groep.',
                        style: TextStyle(
                          color: ThimacoKleuren.tekstGrijs,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    primary: false,
                    padding: const EdgeInsets.fromLTRB(10, 7, 12, 7),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        for (var index = 0; index < menus.length; index++) ...<Widget>[
                          _bouwKeuzeTegel(
                            context: context,
                            menu: menus[index],
                            index: index,
                            aantalMenus: menus.length,
                            groepMenus: menus,
                            alleMenus: alleMenus,
                          ),
                          if (index < menus.length - 1)
                            const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _bouwKeuzeTegel({
    required BuildContext context,
    required OpmetingRaamKeuzeMenu menu,
    required int index,
    required int aantalMenus,
    required List<OpmetingRaamKeuzeMenu> groepMenus,
    required List<OpmetingRaamKeuzeMenu> alleMenus,
  }) {
    final samenvatting = samenvattingPerMenu[menu.id]?.trim() ?? '';
    final heeftKeuze = samenvatting.isNotEmpty;
    final titelTekst = menu.titel.trim().isEmpty
        ? 'Technische keuze'
        : menu.titel.trim();
    final waardeTekst = heeftKeuze ? samenvatting : 'Geen keuze';

    return SizedBox(
      width: 112,
      height: 64,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toonKeuzeVenster(context, menu),
          borderRadius: BorderRadius.circular(8),
          hoverColor: ThimacoKleuren.oranje.withValues(alpha: 0.04),
          child: Container(
            decoration: BoxDecoration(
              color: heeftKeuze ? Colors.white : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: heeftKeuze
                    ? const Color(0xFFD7DBDF)
                    : ThimacoKleuren.rand,
              ),
              boxShadow: heeftKeuze
                  ? const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ]
                  : const <BoxShadow>[],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 5, 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                titelTekst,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: heeftKeuze
                                      ? ThimacoKleuren.antraciet
                                      : ThimacoKleuren.tekstGrijs,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                waardeTekst,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: heeftKeuze
                                      ? ThimacoKleuren.antraciet
                                      : ThimacoKleuren.tekstGrijs,
                                  fontSize: 9.8,
                                  fontWeight: heeftKeuze
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (toonVerplaatsKnoppen) ...<Widget>[
                          const SizedBox(width: 2),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              _volgordeKnop(
                                icoon: Icons.chevron_left_rounded,
                                tooltip: 'Naar links',
                                actief: index > 0,
                                onTap: () => _verplaatsBinnenGroep(
                                  menu: menu,
                                  groepMenus: groepMenus,
                                  alleMenus: alleMenus,
                                  richting: -1,
                                ),
                              ),
                              _volgordeKnop(
                                icoon: Icons.chevron_right_rounded,
                                tooltip: 'Naar rechts',
                                actief: index < aantalMenus - 1,
                                onTap: () => _verplaatsBinnenGroep(
                                  menu: menu,
                                  groepMenus: groepMenus,
                                  alleMenus: alleMenus,
                                  richting: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  height: heeftKeuze ? 2.5 : 1,
                  color: heeftKeuze
                      ? ThimacoKleuren.oranje
                      : ThimacoKleuren.rand,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _verplaatsBinnenGroep({
    required OpmetingRaamKeuzeMenu menu,
    required List<OpmetingRaamKeuzeMenu> groepMenus,
    required List<OpmetingRaamKeuzeMenu> alleMenus,
    required int richting,
  }) {
    final huidigeIndex = groepMenus.indexWhere((item) => item.id == menu.id);
    final doelIndex = huidigeIndex + richting;
    if (huidigeIndex < 0 || doelIndex < 0 || doelIndex >= groepMenus.length) {
      return;
    }

    final buur = groepMenus[doelIndex];
    final ids = alleMenus.map((item) => item.id).toList();
    final eersteIndex = ids.indexOf(menu.id);
    final tweedeIndex = ids.indexOf(buur.id);
    if (eersteIndex < 0 || tweedeIndex < 0) {
      return;
    }

    final tijdelijk = ids[eersteIndex];
    ids[eersteIndex] = ids[tweedeIndex];
    ids[tweedeIndex] = tijdelijk;
    unawaited(onMenuVolgordeGewijzigd(ids));
  }

  Widget _volgordeKnop({
    required IconData icoon,
    required String tooltip,
    required bool actief,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: actief ? onTap : null,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(
            icoon,
            size: 14,
            color: actief
                ? ThimacoKleuren.tekstGrijs
                : ThimacoKleuren.rand,
          ),
        ),
      ),
    );
  }

  Future<void> _toonKeuzeVenster(
    BuildContext context,
    OpmetingRaamKeuzeMenu menu,
  ) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.12),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: ThimacoKleuren.rand),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640, maxHeight: 640),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: 48,
                  padding: const EdgeInsets.only(left: 14, right: 5),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: ThimacoKleuren.rand),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              menu.titel.trim().isEmpty
                                  ? 'Technische keuze'
                                  : menu.titel.trim(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: ThimacoKleuren.antraciet,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              width: 34,
                              height: 1.5,
                              decoration: BoxDecoration(
                                color: ThimacoKleuren.oranje,
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ThimacoIcoonActie(
                        icoon: Icons.close_rounded,
                        tooltip: 'Sluiten',
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: OpmetingRaamTechnischeKeuzesPaneel(
                      gekozenOpvullingen: gekozenOpvullingen,
                      gekozenKleinhouten: gekozenKleinhouten,
                      keuzemenus: keuzemenus,
                      keuzemenusLaden: keuzemenusLaden,
                      keuzemenusBewaren: keuzemenusBewaren,
                      menuBeheerOntgrendeld: menuBeheerOntgrendeld,
                      opvullingenOpen: opvullingenOpen,
                      kleinhoutenOpen: kleinhoutenOpen,
                      onOpvullingenOpenGewijzigd:
                          onOpvullingenOpenGewijzigd,
                      onKleinhoutenOpenGewijzigd:
                          onKleinhoutenOpenGewijzigd,
                      geselecteerdeOptieIdVoorMenu:
                          geselecteerdeOptieIdVoorMenu,
                      onOptieGekozen: (gekozenMenu, optieId) async {
                        await onOptieGekozen(gekozenMenu, optieId);
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }
                      },
                      onMenuToevoegen: onMenuToevoegen,
                      onTitelOpladen: onTitelOpladen,
                      onKeuzeToevoegen: onKeuzeToevoegen,
                      onSubmenuToevoegen: onSubmenuToevoegen,
                      onMenuKopieren: onMenuKopieren,
                      onItemKopieren: onItemKopieren,
                      onBeheerSlotWisselen: onBeheerSlotWisselen,
                      onMenuAanpassen: onMenuAanpassen,
                      onMenuOmhoog: onMenuOmhoog,
                      onMenuOmlaag: onMenuOmlaag,
                      onMenuVerwijderen: onMenuVerwijderen,
                      focusMenuId: menu.id,
                      selectieDialoog: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}

