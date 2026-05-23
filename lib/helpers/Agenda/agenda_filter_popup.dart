import 'package:flutter/material.dart';

import 'agenda_filter_menu.dart';
import 'agenda_filter_state.dart';

class AgendaFilterPopup {
  static Future<AgendaFilterState?> open(
    BuildContext context,
    AgendaFilterState huidigeFilters,
  ) async {
    AgendaFilterState tijdelijkeFilters = huidigeFilters;

    return showDialog<AgendaFilterState>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 460,
              maxHeight: 600,
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: StatefulBuilder(
                builder: (context, setPopupState) {
                  void wijzigFilters(AgendaFilterState nieuweFilters) {
                    setPopupState(() {
                      tijdelijkeFilters = nieuweFilters;
                    });
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.visibility,
                            color: Color(0xFF0B7A3B),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Agenda filteren',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(
                                context,
                                tijdelijkeFilters,
                              );
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Flexible(
                        child: SingleChildScrollView(
                          child: AgendaFilterMenu(
                            toonPlanning: tijdelijkeFilters.toonPlanning,
                            toonOpvolging: tijdelijkeFilters.toonOpvolging,
                            toonNadienst: tijdelijkeFilters.toonNadienst,
                            toonAfspraak: tijdelijkeFilters.toonAfspraak,
                            toonDagtaak: tijdelijkeFilters.toonDagtaak,
                            toonVerlof: tijdelijkeFilters.toonVerlof,
                            toonKraan: tijdelijkeFilters.toonKraan,
                            onPlanningChanged: (waarde) {
                              wijzigFilters(
                                tijdelijkeFilters.copyWith(
                                  toonPlanning: waarde,
                                ),
                              );
                            },
                            onOpvolgingChanged: (waarde) {
                              wijzigFilters(
                                tijdelijkeFilters.copyWith(
                                  toonOpvolging: waarde,
                                ),
                              );
                            },
                            onNadienstChanged: (waarde) {
                              wijzigFilters(
                                tijdelijkeFilters.copyWith(
                                  toonNadienst: waarde,
                                ),
                              );
                            },
                            onAfspraakChanged: (waarde) {
                              wijzigFilters(
                                tijdelijkeFilters.copyWith(
                                  toonAfspraak: waarde,
                                ),
                              );
                            },
                            onDagtaakChanged: (waarde) {
                              wijzigFilters(
                                tijdelijkeFilters.copyWith(
                                  toonDagtaak: waarde,
                                ),
                              );
                            },
                            onVerlofChanged: (waarde) {
                              wijzigFilters(
                                tijdelijkeFilters.copyWith(
                                  toonVerlof: waarde,
                                ),
                              );
                            },
                            onKraanChanged: (waarde) {
                              wijzigFilters(
                                tijdelijkeFilters.copyWith(
                                  toonKraan: waarde,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
