import 'package:flutter/material.dart';

import 'notitie_actie_model.dart';
import 'notitie_helper.dart';
import 'notitie_model.dart';
import 'notitie_regel.dart';

class NotitieDagContainer extends StatelessWidget {
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

  String get _titel {
    final delen = datumKey.split('-');
    final vandaag = NotitieHelper.datumKey(DateTime.now());

    if (datumKey == vandaag) return 'Vandaag';
    if (delen.length != 3) return datumKey;

    return '${delen[2]}/${delen[1]}/${delen[0]}';
  }

  @override
  Widget build(BuildContext context) {
    final gesorteerd = NotitieHelper.sorteerVoorDag(notities);
    final openAantal = notities.where((n) => !n.afgewerkt).length;
    final afgewerktAantal = notities.where((n) => n.afgewerkt).length;

    return DragTarget<NotitieModel>(
      onWillAcceptWithDetails: (details) {
        return details.data.datumKey != datumKey;
      },
      onAcceptWithDetails: (details) {
        onNotitieVerplaatst(details.data, datumKey);
      },
      builder: (context, candidateData, rejectedData) {
        final isHover = candidateData.isNotEmpty;

        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 2,
                  right: 2,
                  bottom: 5,
                ),
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
                      color: Colors.black.withOpacity(0.035),
                      blurRadius: 7,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    for (final notitie in gesorteerd)
                      NotitieRegel(
                        notitie: notitie,
                        acties: acties,
                        onChanged: onNotitieChanged,
                        onDelete: onNotitieVerwijderd,
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
