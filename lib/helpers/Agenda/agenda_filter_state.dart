class AgendaFilterState {
  final bool toonPlanning;
  final bool toonOpvolging;
  final bool toonNadienst;
  final bool toonAfspraak;
  final bool toonDagtaak;
  final bool toonVerlof;
  final bool toonKraan;

  const AgendaFilterState({
    this.toonPlanning = true,
    this.toonOpvolging = true,
    this.toonNadienst = true,
    this.toonAfspraak = true,
    this.toonDagtaak = true,
    this.toonVerlof = true,
    this.toonKraan = true,
  });

  AgendaFilterState copyWith({
    bool? toonPlanning,
    bool? toonOpvolging,
    bool? toonNadienst,
    bool? toonAfspraak,
    bool? toonDagtaak,
    bool? toonVerlof,
    bool? toonKraan,
  }) {
    return AgendaFilterState(
      toonPlanning: toonPlanning ?? this.toonPlanning,
      toonOpvolging: toonOpvolging ?? this.toonOpvolging,
      toonNadienst: toonNadienst ?? this.toonNadienst,
      toonAfspraak: toonAfspraak ?? this.toonAfspraak,
      toonDagtaak: toonDagtaak ?? this.toonDagtaak,
      toonVerlof: toonVerlof ?? this.toonVerlof,
      toonKraan: toonKraan ?? this.toonKraan,
    );
  }
}
