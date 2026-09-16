// THIMACO-CONTROLE: RAAM-TEKENPROGRAMMA-FASE7-STABIELE-TECHNIEK-WEERGAVE-20260913
import 'dart:async';

import 'package:flutter/material.dart';

import '../../ui/thimaco_huisstijl.dart';
import 'opmeting_raam_keuzemenu_model.dart';
import 'opmeting_raam_kleinhout_helper.dart';
import 'opmeting_raam_technische_keuzes_paneel.dart';
import 'opmeting_raam_vulling_helper.dart';

class OpmetingRaamTechnischeKeuzesRibbon extends StatelessWidget {
  const OpmetingRaamTechnischeKeuzesRibbon({
    super.key,
    required this.keuzemenus,
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
    required this.samenvattingPerMenu,
  });

  final List<OpmetingRaamKeuzeMenu> keuzemenus;
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
  final Map<String, String> samenvattingPerMenu;

  @override
  Widget build(BuildContext context) {
    final zichtbareMenus = keuzemenus
        .where((menu) => menuBeheerOntgrendeld || menu.actief)
        .toList()
      ..sort((eerste, tweede) {
        final volgorde = eerste.volgorde.compareTo(tweede.volgorde);
        if (volgorde != 0) return volgorde;
        return eerste.titel.toLowerCase().compareTo(tweede.titel.toLowerCase());
      });

    return Container(
      height: 92,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: ThimacoKleuren.rand)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: keuzemenusLaden
                ? const Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ThimacoKleuren.oranje,
                      ),
                    ),
                  )
                : zichtbareMenus.isEmpty
                ? const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Nog geen technische keuzes toegevoegd.',
                      style: TextStyle(
                        color: ThimacoKleuren.tekstGrijs,
                        fontSize: 12,
                      ),
                    ),
                  )
                : ListView.builder(
                    key: const PageStorageKey<String>(
                      'opmeting-raam-technische-keuzes-ribbon',
                    ),
                    scrollDirection: Axis.horizontal,
                    primary: false,
                    itemCount: zichtbareMenus.length,
                    itemBuilder: (context, index) {
                      final menu = zichtbareMenus[index];

                      return DragTarget<String>(
                        onWillAcceptWithDetails: (details) {
                          return details.data != menu.id;
                        },
                        onAcceptWithDetails: (details) {
                          _verplaatsMenuViaDrag(
                            zichtbareMenus: zichtbareMenus,
                            verplaatstMenuId: details.data,
                            doelMenuId: menu.id,
                          );
                        },
                        builder: (context, kandidaatData, afgewezenData) {
                          final isDropTarget = kandidaatData.isNotEmpty;

                          return Padding(
                            key: ValueKey<String>(
                              'technische-keuze-${menu.id}',
                            ),
                            padding: const EdgeInsets.only(right: 8),
                            child: _bouwKeuzeTegel(
                              context: context,
                              menu: menu,
                              isDropTarget: isDropTarget,
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          const SizedBox(width: 8),
          Container(width: 1, height: 62, color: ThimacoKleuren.rand),
          const SizedBox(width: 10),
          SizedBox(
            width: 142,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                if (keuzemenusBewaren)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.8,
                        color: ThimacoKleuren.oranje,
                      ),
                    ),
                  ),
                ThimacoTekstActie(
                  tekst: '+ Keuze toevoegen',
                  onPressed: () {
                    unawaited(onMenuToevoegen());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _verplaatsMenuViaDrag({
    required List<OpmetingRaamKeuzeMenu> zichtbareMenus,
    required String verplaatstMenuId,
    required String doelMenuId,
  }) {
    final ids = zichtbareMenus.map((menu) => menu.id).toList();
    final oudeIndex = ids.indexOf(verplaatstMenuId);
    final doelIndex = ids.indexOf(doelMenuId);

    if (oudeIndex < 0 || doelIndex < 0 || oudeIndex == doelIndex) {
      return;
    }

    final verplaatst = ids.removeAt(oudeIndex);
    final invoegIndex = doelIndex.clamp(0, ids.length).toInt();
    ids.insert(invoegIndex, verplaatst);

    unawaited(onMenuVolgordeGewijzigd(ids));
  }

  Widget _bouwKeuzeTegel({
    required BuildContext context,
    required OpmetingRaamKeuzeMenu menu,
    required bool isDropTarget,
  }) {
    // De ribbon is een overzicht van de volledige positie en niet van één
    // toevallig actieve kaderselectie. Gebruik daarom dezelfde samenvatting als
    // Eigenschappen > Techniek. De callback naar de actieve selectie blijft
    // alleen nodig voor het zwevende keuzevenster zelf.
    final samenvatting = samenvattingPerMenu[menu.id]?.trim() ?? '';
    final heeftKeuze = samenvatting.isNotEmpty;

    final titelTekst = menu.titel.trim().isEmpty
        ? 'Technische keuze'
        : menu.titel.trim();
    final waardeTekst = heeftKeuze ? samenvatting : 'Geen keuze';

    return SizedBox(
      width: 116,
      height: 64,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          hoverColor: ThimacoKleuren.oranje.withValues(alpha: 0.04),
          onTap: () {
            _toonKeuzeVenster(context, menu);
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(9, 6, 5, 5),
            decoration: BoxDecoration(
              color: heeftKeuze ? Colors.white : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(9),
              border: Border(
                top: BorderSide(
                  color: isDropTarget
                      ? ThimacoKleuren.oranje
                      : heeftKeuze
                      ? const Color(0xFFD7DBDF)
                      : ThimacoKleuren.rand,
                ),
                left: BorderSide(
                  color: isDropTarget
                      ? ThimacoKleuren.oranje
                      : heeftKeuze
                      ? const Color(0xFFD7DBDF)
                      : ThimacoKleuren.rand,
                ),
                right: BorderSide(
                  color: isDropTarget
                      ? ThimacoKleuren.oranje
                      : heeftKeuze
                      ? const Color(0xFFD7DBDF)
                      : ThimacoKleuren.rand,
                ),
                bottom: BorderSide(
                  color: heeftKeuze
                      ? ThimacoKleuren.oranje
                      : ThimacoKleuren.rand,
                  width: heeftKeuze ? 2 : 1,
                ),
              ),
              boxShadow: heeftKeuze
                  ? const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x10000000),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ]
                  : const <BoxShadow>[],
            ),
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
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        waardeTekst,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: heeftKeuze
                              ? ThimacoKleuren.antraciet
                              : ThimacoKleuren.tekstGrijs,
                          fontSize: 10,
                          height: 1.08,
                          fontWeight: heeftKeuze
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Draggable<String>(
                  data: menu.id,
                  axis: Axis.horizontal,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 116,
                      height: 52,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: ThimacoKleuren.oranje),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        titelTekst,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: ThimacoKleuren.antraciet,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  childWhenDragging: const Padding(
                    padding: EdgeInsets.fromLTRB(3, 1, 0, 10),
                    child: Icon(
                      Icons.drag_indicator_rounded,
                      size: 18,
                      color: Color(0xFFCBD5E1),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(3, 1, 0, 10),
                    child: Tooltip(
                      message: 'Versleep om de volgorde te wijzigen',
                      child: Icon(
                        Icons.drag_indicator_rounded,
                        size: 18,
                        color: ThimacoKleuren.tekstGrijs,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
