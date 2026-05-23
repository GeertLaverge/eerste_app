class AgendaSelectieState {
  final DateTime focusMaand;
  final DateTime geselecteerdeDag;

  const AgendaSelectieState({
    required this.focusMaand,
    required this.geselecteerdeDag,
  });

  factory AgendaSelectieState.nieuw() {
    final nu = DateTime.now();

    return AgendaSelectieState(
      focusMaand: DateTime(
        nu.year,
        nu.month,
      ),
      geselecteerdeDag: nu,
    );
  }

  AgendaSelectieState copyWith({
    DateTime? focusMaand,
    DateTime? geselecteerdeDag,
  }) {
    return AgendaSelectieState(
      focusMaand: focusMaand ?? this.focusMaand,
      geselecteerdeDag: geselecteerdeDag ?? this.geselecteerdeDag,
    );
  }

  AgendaSelectieState kiesDag(DateTime dag) {
    return copyWith(
      geselecteerdeDag: dag,
      focusMaand: DateTime(
        dag.year,
        dag.month,
      ),
    );
  }

  AgendaSelectieState vorigeMaand() {
    return copyWith(
      focusMaand: DateTime(
        focusMaand.year,
        focusMaand.month - 1,
      ),
    );
  }

  AgendaSelectieState volgendeMaand() {
    return copyWith(
      focusMaand: DateTime(
        focusMaand.year,
        focusMaand.month + 1,
      ),
    );
  }
}
