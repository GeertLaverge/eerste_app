import 'package:flutter/material.dart';

import 'agenda_item.dart';
import 'agenda_kleur_service.dart';

class AgendaInTePlannenKnop extends StatelessWidget {
  final List<AgendaItem> items;

  const AgendaInTePlannenKnop({
    super.key,
    required this.items,
  });

  List<AgendaItem> get inTePlannenItems {
    return items.where((item) {
      return item.type == 'planning' ||
          item.type == 'opvolging' ||
          item.type == 'nadienst';
    }).toList();
  }

  String labelVoorType(String type) {
    if (type == 'planning') return 'Planning';
    if (type == 'opvolging') return 'Opvolging';
    if (type == 'nadienst') return 'Nadienst';
    return type;
  }

  void openMenu(BuildContext context) {
    final lijst = inTePlannenItems.isEmpty
        ? [
            AgendaItem(
              titel: 'Klant Janssens',
              type: 'planning',
            ),
            AgendaItem(
              titel: 'Onderhoud Willems',
              type: 'opvolging',
            ),
            AgendaItem(
              titel: 'Interventie Depot',
              type: 'nadienst',
            ),
          ]
        : inTePlannenItems;

    late OverlayEntry overlayEntry;

    double links = 18;
    double boven = 120;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setOverlayState) {
            return Positioned(
              left: links,
              top: boven,
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setOverlayState(() {
                      links += details.delta.dx;
                      boven += details.delta.dy;
                    });
                  },
                  child: Container(
                    width: 360,
                    constraints: const BoxConstraints(
                      maxHeight: 520,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.drag_indicator,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.playlist_add_check,
                                color: Color(0xFF0B7A3B),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'Nog in te plannen',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  overlayEntry.remove();
                                },
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Flexible(
                            child: lijst.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text(
                                      'Geen klanten in wachtrij',
                                      style: TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: lijst.length,
                                    itemBuilder: (context, index) {
                                      final item = lijst[index];
                                      final kleur =
                                          AgendaKleurService.kleur(item.type);

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: Draggable<AgendaItem>(
                                          data: item,
                                          feedback: Material(
                                            color: Colors.transparent,
                                            child: Container(
                                              width: 260,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AgendaKleurService
                                                    .achtergrond(
                                                  item.type,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: kleur,
                                                ),
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
                                                style: TextStyle(
                                                  color: kleur,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          ),
                                          childWhenDragging: Opacity(
                                            opacity: 0.35,
                                            child: inTePlannenRij(
                                              item: item,
                                              kleur: kleur,
                                            ),
                                          ),
                                          child: inTePlannenRij(
                                            item: item,
                                            kleur: kleur,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    Overlay.of(context).insert(overlayEntry);
  }

  Widget inTePlannenRij({
    required AgendaItem item,
    required Color kleur,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AgendaKleurService.achtergrond(item.type),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: kleur.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.drag_indicator,
            size: 18,
            color: Colors.grey.shade500,
          ),
          const SizedBox(width: 6),
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: kleur,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.titel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            labelVoorType(item.type),
            style: TextStyle(
              color: kleur,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aantal = inTePlannenItems.length;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: () => openMenu(context),
          icon: const Icon(
            Icons.playlist_add_check,
            color: Colors.black87,
          ),
        ),
        if (aantal > 0)
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: Text(
                aantal > 99 ? '99+' : aantal.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
