import 'package:flutter/material.dart';

import 'agenda_item.dart';
import 'agenda_kleur_service.dart';
import 'agenda_sleep_data.dart';
import '../klanten/fiche/klantenfiche_model.dart';
import '../klanten/fiche/klantenfiche_repository.dart';

class AgendaInTePlannenKnop extends StatelessWidget {
  final List<AgendaItem> items;

  const AgendaInTePlannenKnop({
    super.key,
    required this.items,
  });

  bool klantStaatAlOpAgenda(KlantenficheModel klant) {
    final klantNaam = klant.naam.trim().toLowerCase();

    if (klantNaam.isEmpty) return true;

    return items.any((item) {
      final itemNaam = item.naamKlant.trim().toLowerCase();
      final itemTitel = item.titel.trim().toLowerCase();

      return (item.type == 'planning' ||
              item.type == 'opvolging' ||
              item.type == 'nadienst' ||
              item.type == 'afspraak') &&
          (itemNaam == klantNaam || itemTitel == klantNaam);
    });
  }

  AgendaItem maakAgendaItemVanKlant(
    KlantenficheModel klant,
  ) {
    final isOpvolging =
        klant.klantStatus == 'Opvolgen' && klant.klaarVoorNieuwePlanning;

    return AgendaItem(
      titel: klant.naam,
      type: klant.inTePlannenType.trim().isNotEmpty
          ? klant.inTePlannenType
          : klant.klantStatus == 'Nadienst'
              ? 'nadienst'
              : isOpvolging
                  ? 'opvolging'
                  : 'planning',
      klantNr: klant.klantNr,
      naamKlant: klant.naam,
      straatnaam: klant.straatnaam,
      huisNr: klant.huisNr,
      gemeente: klant.gemeente,
      postcode: klant.postcode,
      gsm: klant.gsm,
      gsm2: klant.gsm2,
      email: klant.email,
      opmerkingen: isOpvolging ? klant.opvolgTaken : klant.taakVoorKlant,
    );
  }

  Future<List<AgendaItem>> laadActieveKlantenNogInTePlannen() async {
    final klanten = await KlantenficheRepository.laadKlantenFiches();

    final actieveKlanten = klanten.where((klant) {
      final actief = klant.klantStatus == 'Actief' ||
          klant.klantStatus == 'Nadienst' ||
          klant.inTePlannenType == 'afspraak';
      final opvolging =
          klant.klantStatus == 'Opvolgen' && klant.klaarVoorNieuwePlanning;

      return (actief || opvolging) &&
          klant.naam.trim().isNotEmpty &&
          !klantStaatAlOpAgenda(klant);
    }).toList();

    actieveKlanten.sort(
      (a, b) => a.naam.toLowerCase().compareTo(
            b.naam.toLowerCase(),
          ),
    );

    return actieveKlanten
        .map(
          maakAgendaItemVanKlant,
        )
        .toList();
  }

  void openMenu(BuildContext context) {
    late OverlayEntry overlayEntry;

    double links = 18;
    double boven = 120;

    List<AgendaItem>? openLijst;

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
                            child: FutureBuilder<List<AgendaItem>>(
                              future: laadActieveKlantenNogInTePlannen(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                openLijst ??= List<AgendaItem>.from(
                                  snapshot.data!,
                                );

                                final lijst = openLijst!;

                                if (lijst.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text(
                                      'Geen actieve klanten in wachtrij',
                                      style: TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  );
                                }

                                return ListView.builder(
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
                                      child: Draggable<AgendaSleepData>(
                                        data: AgendaSleepData(
                                          oudeDag: DateTime(1900, 1, 1),
                                          item: item,
                                        ),
                                        onDragCompleted: () {
                                          openLijst!.removeWhere(
                                            (x) =>
                                                x.naamKlant == item.naamKlant,
                                          );

                                          setOverlayState(() {});
                                        },
                                        feedback: Material(
                                          color: Colors.transparent,
                                          child: Container(
                                            width: 260,
                                            padding: const EdgeInsets.symmetric(
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
            item.type == 'nadienst'
                ? 'Nadienst'
                : item.type == 'opvolging'
                    ? 'Opvolging'
                    : item.type == 'afspraak'
                        ? 'Afspraak klant'
                        : 'Actieve klant',
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
    return FutureBuilder<List<AgendaItem>>(
      future: laadActieveKlantenNogInTePlannen(),
      builder: (context, snapshot) {
        final aantal = snapshot.data?.length ?? 0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF0B7A3B),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => openMenu(context),
                icon: const Icon(
                  Icons.playlist_add_check,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
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
      },
    );
  }
}
