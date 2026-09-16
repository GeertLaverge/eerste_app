// THIMACO-CONTROLE: NOTITIE-DAG-LOKALE-REBUILD-BIJ-STATUS-20260914
import 'package:flutter/material.dart';

import 'notitie_actie_model.dart';
import 'notitie_helper.dart';
import 'notitie_model.dart';
import 'notitie_regel.dart';

class NotitieDagContainer extends StatefulWidget {
  const NotitieDagContainer({
    super.key,
    required this.datumKey,
    required this.notities,
    required this.acties,
    required this.onNotitieChanged,
    required this.onNotitieVerplaatst,
    required this.onNotitieVerwijderd,
  });

  final String datumKey;
  final List<NotitieModel> notities;
  final List<NotitieActieModel> acties;

  final ValueChanged<NotitieModel> onNotitieChanged;
  final ValueChanged<NotitieModel> onNotitieVerwijderd;

  final void Function(
    NotitieModel notitie,
    String nieuweDatumKey,
  ) onNotitieVerplaatst;

  @override
  State<NotitieDagContainer> createState() => _NotitieDagContainerState();
}

class _NotitieDagContainerState extends State<NotitieDagContainer> {
  String get _titel {
    final delen = widget.datumKey.split('-');
    final vandaag = NotitieHelper.datumKey(DateTime.now());

    if (widget.datumKey == vandaag) return 'Vandaag';
    if (delen.length != 3) return widget.datumKey;

    return '${delen[2]}/${delen[1]}/${delen[0]}';
  }

  void _statusGewijzigd() {
    if (!mounted) return;

    /*
     * Alleen deze dag opnieuw tekenen. Zo wijzigen telling en sortering
     * onmiddellijk zonder de volledige Notities Bureau-pagina te herbouwen.
     */
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final gesorteerd = NotitieHelper.sorteerVoorDag(widget.notities);
    final openAantal = widget.notities.where((n) => !n.afgewerkt).length;
    final afgewerktAantal = widget.notities.where((n) => n.afgewerkt).length;

    return DragTarget<NotitieModel>(
      onWillAcceptWithDetails: (details) {
        return details.data.datumKey != widget.datumKey;
      },
      onAcceptWithDetails: (details) {
        widget.onNotitieVerplaatst(details.data, widget.datumKey);
      },
      builder: (context, candidateData, rejectedData) {
        final isHover = candidateData.isNotEmpty;

        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 2, right: 2, bottom: 5),
                child: Row(
                  children: [
                    Text(
                      _titel,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$openAantal open · $afgewerktAantal afgewerkt',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isHover
                        ? const Color(0xFF0B7A3B)
                        : const Color(0xFFE5E7EB),
                    width: isHover ? 1.4 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.035),
                      blurRadius: 7,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    for (final notitie in gesorteerd)
                      NotitieRegel(
                        key: ValueKey(notitie.id),
                        notitie: notitie,
                        acties: widget.acties,
                        onChanged: widget.onNotitieChanged,
                        onDelete: widget.onNotitieVerwijderd,
                        onStatusChanged: _statusGewijzigd,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
