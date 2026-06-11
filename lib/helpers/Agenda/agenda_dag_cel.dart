import 'package:flutter/material.dart';

import 'agenda_item.dart';
import 'agenda_kleur_service.dart';
import 'agenda_sleep_data.dart';
import 'agenda_item_symbolen_rij.dart';
import 'agenda_weergave_type.dart';

class AgendaDagCel extends StatelessWidget {
  final DateTime dag;
  final bool geselecteerd;
  final bool andereMaand;
  final bool isVandaag;
  final bool isWeekend;
  final List<AgendaItem> items;

  final VoidCallback onTap;
  final Function(AgendaItem item) onItemTap;
  final Function(AgendaItem item) onItemSleep;

  final Function(
    DateTime nieuweDag,
    AgendaItem item,
    DateTime oudeDag,
  )? onItemDrop;

  final AgendaWeergaveType weergave;

  const AgendaDagCel({
    super.key,
    required this.dag,
    required this.geselecteerd,
    required this.andereMaand,
    required this.isVandaag,
    required this.isWeekend,
    required this.items,
    required this.onTap,
    required this.onItemTap,
    required this.onItemSleep,
    this.onItemDrop,
    required this.weergave,
  });
  int weekNummer(DateTime datum) {
    final eersteDag = DateTime(datum.year, 1, 1);

    return ((datum
                    .difference(
                      eersteDag,
                    )
                    .inDays +
                eersteDag.weekday -
                1) ~/
            7) +
        1;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DragTarget<AgendaSleepData>(
        onAcceptWithDetails: (details) {
          onItemDrop?.call(
            dag,
            details.data.item,
            details.data.oudeDag,
          );
        },
        builder: (context, kandidaat, geweigerd) {
          final isDoel = kandidaat.isNotEmpty;

          return InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              constraints: BoxConstraints(
                minHeight: weergave == AgendaWeergaveType.symbolen ? 70 : 102,
              ),
              margin: const EdgeInsets.symmetric(
                horizontal: 0.3,
                vertical: 1,
              ),
              padding: const EdgeInsets.fromLTRB(3, 3, 3, 2),
              decoration: BoxDecoration(
                color: isDoel
                    ? const Color(
                        0xFFE7F6EC,
                      )
                    : isWeekend
                        ? const Color(
                            0xFFEAEAEA,
                          )
                        : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: isDoel
                    ? Border.all(
                        color: const Color(
                          0xFF0B7A3B,
                        ),
                        width: 2,
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: geselecteerd
                                ? const Color(0xFF0B7A3B)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${dag.day}',
                            style: TextStyle(
                              color: geselecteerd
                                  ? Colors.white
                                  : isVandaag
                                      ? const Color(
                                          0xFF0B7A3B,
                                        )
                                      : andereMaand
                                          ? Colors.grey
                                          : Colors.black87,
                              fontWeight: geselecteerd || isVandaag
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              fontSize: geselecteerd
                                  ? 16
                                  : isVandaag
                                      ? 15
                                      : 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (weergave == AgendaWeergaveType.symbolen)
                        Center(
                          child: AgendaItemSymbolenRij(
                            items: items,
                          ),
                        )
                      else
                        ...items.map((item) {
                          final kleur = AgendaKleurService.kleur(item.type);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 1),
                            child: LongPressDraggable<AgendaSleepData>(
                              data: AgendaSleepData(
                                oudeDag: dag,
                                item: item,
                              ),
                              feedback: Material(
                                color: Colors.transparent,
                                child: Container(
                                  width: 165,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kleur,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 8,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    item.titel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.35,
                                child: itemBlok(
                                  item: item,
                                  kleur: kleur,
                                ),
                              ),
                              child: InkWell(
                                onTap: () {
                                  onItemTap(item);
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: itemBlok(
                                  item: item,
                                  kleur: kleur,
                                ),
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: dag.weekday == 7
                        ? Container(
                            width: 22,
                            height: 22,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.black87,
                                width: 1.6,
                              ),
                            ),
                            child: Text(
                              '${weekNummer(dag)}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget itemBlok({
    required AgendaItem item,
    required Color kleur,
  }) {
    final tijd =
        item.tijdTekst.isEmpty ? '' : item.tijdTekst.replaceAll('\n', ' - ');

    return LayoutBuilder(
      builder: (context, constraints) {
        final breedte = constraints.maxWidth;

        Widget inhoud;

        if (breedte >= 82) {
          inhoud = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (tijd.isNotEmpty)
                Text(
                  tijd,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: kleur,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              Text(
                item.titel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: kleur,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          );
        } else {
          inhoud = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (tijd.isNotEmpty)
                Text(
                  tijd,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: kleur,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              Text(
                item.titel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: kleur,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          );
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 1,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: AgendaKleurService.achtergrond(item.type),
            borderRadius: BorderRadius.circular(7),
          ),
          child: inhoud,
        );
      },
    );
  }
}
