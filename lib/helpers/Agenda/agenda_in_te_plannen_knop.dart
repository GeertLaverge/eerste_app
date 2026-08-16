// THIMACO-CONTROLE: IN-TE-PLANNEN-SCHUIFBALK-EN-GROEPERING-20260816
// THIMACO-CONTROLE: NIEUWE-KLANT-BLIJFT-IN-TE-PLANNEN-NA-AFSPRAAK-20260816
import 'package:flutter/material.dart';

import 'agenda_item.dart';
import 'agenda_kleur_service.dart';
import 'agenda_sleep_data.dart';
import '../klanten/fiche/klantenfiche_model.dart';
import '../klanten/fiche/klantenfiche_repository.dart';
import '../klanten/kraan_waarschuwing_icon.dart';

class AgendaInTePlannenKnop extends StatelessWidget {
  final List<AgendaItem> items;

  const AgendaInTePlannenKnop({super.key, required this.items});

  String _wachtrijTypeVoorKlant(KlantenficheModel klant) {
    final explicietType = klant.inTePlannenType.trim();
    if (explicietType.isNotEmpty) {
      return explicietType;
    }

    if (klant.klantStatus == 'Nadienst') {
      return 'nadienst';
    }

    if (klant.klantStatus == 'Opvolgen' && klant.klaarVoorNieuwePlanning) {
      return 'opvolging';
    }

    return 'planning';
  }

  bool _isZelfdeKlant(KlantenficheModel klant, AgendaItem item) {
    final klantNr = klant.klantNr.trim().toLowerCase();
    final itemKlantNr = item.klantNr.trim().toLowerCase();

    // Een klantnummer is, waar beschikbaar, betrouwbaarder dan alleen de naam.
    if (klantNr.isNotEmpty && itemKlantNr.isNotEmpty) {
      return klantNr == itemKlantNr;
    }

    final klantNaam = klant.naam.trim().toLowerCase();
    if (klantNaam.isEmpty) {
      return false;
    }

    final itemNaam = item.naamKlant.trim().toLowerCase();
    final itemTitel = item.titel.trim().toLowerCase();
    return itemNaam == klantNaam || itemTitel == klantNaam;
  }

  bool klantStaatAlOpAgenda(KlantenficheModel klant) {
    final verwachtType = _wachtrijTypeVoorKlant(klant);

    return items.any((item) {
      if (item.isVerwijderd) {
        return false;
      }

      // Alleen een reeds ingepland item van hetzelfde wachtrijtype mag de klant
      // uit 'Nog in te plannen' halen. Een gewone afspraak mag een actieve klant
      // dus niet verbergen wanneer die nog als planning moet worden ingepland.
      if (item.type.trim() != verwachtType) {
        return false;
      }

      return _isZelfdeKlant(klant, item);
    });
  }

  AgendaItem maakAgendaItemVanKlant(KlantenficheModel klant) {
    final isOpvolging =
        klant.klantStatus == 'Opvolgen' && klant.klaarVoorNieuwePlanning;

    return AgendaItem(
      titel: klant.naam,
      type: _wachtrijTypeVoorKlant(klant),
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
      kraanNodig: klant.kraanNodig,
      kraanIngepland: klant.kraanDatum.isNotEmpty,
    );
  }

  int _volgordeVoorWachtrijType(String type) {
    switch (type.trim()) {
      case 'planning':
        return 0;
      case 'opvolging':
        return 1;
      case 'nadienst':
        return 2;
      default:
        return 3;
    }
  }

  String _groepLabelVoorType(String type) {
    switch (type.trim()) {
      case 'planning':
        return 'Planning';
      case 'opvolging':
        return 'Opvolging';
      case 'nadienst':
        return 'Nadienst';
      default:
        return type.trim().isEmpty ? 'Overige' : type.trim();
    }
  }

  List<String> _wachtrijTypesInVolgorde(List<AgendaItem> lijst) {
    final types = lijst
        .map((item) => item.type.trim())
        .where((type) => type.isNotEmpty)
        .toSet()
        .toList(growable: false);

    types.sort((a, b) {
      final volgorde = _volgordeVoorWachtrijType(
        a,
      ).compareTo(_volgordeVoorWachtrijType(b));
      if (volgorde != 0) {
        return volgorde;
      }
      return a.toLowerCase().compareTo(b.toLowerCase());
    });

    return types;
  }

  Widget _wachtrijGroepKop({required String type, required int aantal}) {
    final kleur = AgendaKleurService.kleur(type);

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 4, 2, 7),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: kleur, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              _groepLabelVoorType(type),
              style: TextStyle(
                color: kleur,
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            aantal.toString(),
            style: TextStyle(
              color: kleur,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Future<List<AgendaItem>> laadActieveKlantenNogInTePlannen() async {
    final klanten = await KlantenficheRepository.laadKlantenFiches();

    final actieveKlanten = klanten.where((klant) {
      final actief =
          klant.klantStatus == 'Actief' ||
          klant.klantStatus == 'Nadienst' ||
          klant.inTePlannenType.trim().isNotEmpty;
      final opvolging =
          klant.klantStatus == 'Opvolgen' && klant.klaarVoorNieuwePlanning;

      return (actief || opvolging) &&
          klant.naam.trim().isNotEmpty &&
          !klantStaatAlOpAgenda(klant);
    }).toList();

    actieveKlanten.sort((a, b) {
      final typeVergelijking = _volgordeVoorWachtrijType(
        _wachtrijTypeVoorKlant(a),
      ).compareTo(_volgordeVoorWachtrijType(_wachtrijTypeVoorKlant(b)));

      if (typeVergelijking != 0) {
        return typeVergelijking;
      }

      return a.naam.toLowerCase().compareTo(b.naam.toLowerCase());
    });

    return actieveKlanten.map(maakAgendaItemVanKlant).toList();
  }

  void openMenu(BuildContext context) {
    late OverlayEntry overlayEntry;

    double links = 18;
    double boven = 120;

    final lijstScrollController = ScrollController();
    var scrollControllerOpgeruimd = false;

    void sluitOverlay() {
      overlayEntry.remove();
      if (!scrollControllerOpgeruimd) {
        scrollControllerOpgeruimd = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          lijstScrollController.dispose();
        });
      }
    }

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
                child: Container(
                  width: 360,
                  constraints: const BoxConstraints(maxHeight: 520),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.grey.shade300),
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
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onPanUpdate: (details) {
                            setOverlayState(() {
                              links += details.delta.dx;
                              boven += details.delta.dy;
                            });
                          },
                          child: Row(
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
                                onPressed: sluitOverlay,
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
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
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                );
                              }

                              final types = _wachtrijTypesInVolgorde(lijst);

                              return Scrollbar(
                                controller: lijstScrollController,
                                thumbVisibility: true,
                                trackVisibility: true,
                                interactive: true,
                                thickness: 8,
                                radius: const Radius.circular(8),
                                child: ListView(
                                  controller: lijstScrollController,
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.only(right: 14),
                                  children: [
                                    for (
                                      var typeIndex = 0;
                                      typeIndex < types.length;
                                      typeIndex++
                                    ) ...[
                                      Builder(
                                        builder: (context) {
                                          final type = types[typeIndex];
                                          final groepItems =
                                              lijst
                                                  .where(
                                                    (item) =>
                                                        item.type.trim() ==
                                                        type,
                                                  )
                                                  .toList(growable: false)
                                                ..sort(
                                                  (a, b) => a.titel
                                                      .toLowerCase()
                                                      .compareTo(
                                                        b.titel.toLowerCase(),
                                                      ),
                                                );

                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _wachtrijGroepKop(
                                                type: type,
                                                aantal: groepItems.length,
                                              ),
                                              for (final item in groepItems)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 8,
                                                      ),
                                                  child: Draggable<AgendaSleepData>(
                                                    data: AgendaSleepData(
                                                      oudeDag: DateTime(
                                                        1900,
                                                        1,
                                                        1,
                                                      ),
                                                      item: item,
                                                    ),
                                                    onDragCompleted: () {
                                                      openLijst!.removeWhere(
                                                        (x) =>
                                                            x.naamKlant ==
                                                            item.naamKlant,
                                                      );

                                                      setOverlayState(() {});
                                                    },
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
                                                          color:
                                                              AgendaKleurService.achtergrond(
                                                                item.type,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                          border: Border.all(
                                                            color:
                                                                AgendaKleurService.kleur(
                                                                  item.type,
                                                                ),
                                                          ),
                                                          boxShadow: const [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black26,
                                                              blurRadius: 8,
                                                              offset: Offset(
                                                                0,
                                                                3,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Text(
                                                          item.titel,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            color:
                                                                AgendaKleurService.kleur(
                                                                  item.type,
                                                                ),
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    childWhenDragging: Opacity(
                                                      opacity: 0.35,
                                                      child: inTePlannenRij(
                                                        item: item,
                                                        kleur:
                                                            AgendaKleurService.kleur(
                                                              item.type,
                                                            ),
                                                      ),
                                                    ),
                                                    child: inTePlannenRij(
                                                      item: item,
                                                      kleur:
                                                          AgendaKleurService.kleur(
                                                            item.type,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              if (typeIndex < types.length - 1)
                                                const SizedBox(height: 4),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ],
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
            );
          },
        );
      },
    );

    Overlay.of(context).insert(overlayEntry);
  }

  Widget inTePlannenRij({required AgendaItem item, required Color kleur}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AgendaKleurService.achtergrond(item.type),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kleur.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Icon(Icons.drag_indicator, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 6),
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: kleur, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                if (item.kraanNodig)
                  KraanWaarschuwingIcon(actief: !item.kraanIngepland),
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
              ],
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
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
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
