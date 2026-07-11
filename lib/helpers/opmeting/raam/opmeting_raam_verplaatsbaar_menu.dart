import 'package:flutter/material.dart';

class OpmetingRaamVerplaatsbaarMenu extends StatelessWidget {
  const OpmetingRaamVerplaatsbaarMenu({
    super.key,
    required this.menuKey,
    required this.breedte,
    required this.titel,
    required this.onSleepStart,
    required this.onVerslepen,
    required this.onSleepEinde,
    required this.onSleepAnnuleren,
    required this.onSluiten,
    required this.child,
  });

  final GlobalKey menuKey;
  final double breedte;
  final String titel;

  final GestureDragStartCallback onSleepStart;
  final GestureDragUpdateCallback onVerslepen;
  final GestureDragEndCallback onSleepEinde;
  final VoidCallback onSleepAnnuleren;
  final VoidCallback onSluiten;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: menuKey,
      width: breedte,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF0B7A3B),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: const Color(0xFF086330)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.move,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: onSleepStart,
                      onPanUpdate: onVerslepen,
                      onPanEnd: onSleepEinde,
                      onPanCancel: onSleepAnnuleren,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, right: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.drag_indicator,
                              size: 19,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                titel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.open_with,
                              size: 17,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: IconButton(
                    tooltip: 'Menu sluiten',
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 30,
                      minHeight: 30,
                    ),
                    onPressed: onSluiten,
                    icon: const Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          child,
        ],
      ),
    );
  }
}
