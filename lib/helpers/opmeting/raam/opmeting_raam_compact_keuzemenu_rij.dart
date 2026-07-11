import 'package:flutter/material.dart';

import 'opmeting_raam_keuzemenu_model.dart';

class OpmetingRaamCompactKeuzemenuRij extends StatelessWidget {
  const OpmetingRaamCompactKeuzemenuRij({
    super.key,
    required this.menu,
    required this.geselecteerdeOptieId,
    required this.onGekozen,
    this.beheerKnop,
  });

  static const Color groen = Color(0xFF0B7A3B);
  static const Color rand = Color(0xFFE5E7EB);
  static const Color tekstGrijs = Color(0xFF6B7280);

  final OpmetingRaamKeuzeMenu menu;
  final String geselecteerdeOptieId;

  final ValueChanged<String> onGekozen;

  final Widget? beheerKnop;

  List<OpmetingRaamKeuzeOptie> get _actieveOpties {
    return menu.actieveOpties;
  }

  OpmetingRaamKeuzeOptie get _geselecteerdeOptie {
    for (final optie in _actieveOpties) {
      if (optie.id == geselecteerdeOptieId) {
        return optie;
      }
    }

    return menu.geenOptie;
  }

  @override
  Widget build(BuildContext context) {
    final geselecteerdeOptie = _geselecteerdeOptie;
    final heeftKeuze = !geselecteerdeOptie.isGeenKeuze;

    return Container(
      height: 40,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: rand)),
      ),
      child: Row(
        children: [
          Expanded(
            child: PopupMenuButton<String>(
              enabled: _actieveOpties.isNotEmpty,
              initialValue: geselecteerdeOptie.id,
              position: PopupMenuPosition.under,
              padding: EdgeInsets.zero,
              tooltip: '',
              onSelected: onGekozen,
              itemBuilder: (context) {
                return _actieveOpties.map((optie) {
                  final geselecteerd = optie.id == geselecteerdeOptie.id;

                  return PopupMenuItem<String>(
                    value: optie.id,
                    height: 38,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            optie.naam,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: geselecteerd
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (geselecteerd)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(Icons.check, size: 17, color: groen),
                          ),
                      ],
                    ),
                  );
                }).toList();
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(
                        menu.titel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: menu.actief
                              ? const Color(0xFF111827)
                              : tekstGrijs,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      flex: 4,
                      child: Text(
                        geselecteerdeOptie.naam,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: heeftKeuze ? groen : tekstGrijs,
                          fontSize: 11.5,
                          fontWeight: heeftKeuze
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 19,
                      color: tekstGrijs,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (beheerKnop != null) beheerKnop!,
        ],
      ),
    );
  }
}
