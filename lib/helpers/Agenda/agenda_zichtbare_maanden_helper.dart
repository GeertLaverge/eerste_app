class AgendaZichtbareMaandenHelper {
  static List<DateTime> bereken(
    DateTime focusMaand,
  ) {
    return [
      DateTime(
        focusMaand.year,
        focusMaand.month - 1,
      ),
      focusMaand,
      DateTime(
        focusMaand.year,
        focusMaand.month + 1,
      ),
    ];
  }
}
