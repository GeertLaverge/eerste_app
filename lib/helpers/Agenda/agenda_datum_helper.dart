class AgendaDatumHelper {
  static DateTime beginVanWeek(DateTime datum) {
    return DateTime(
      datum.year,
      datum.month,
      datum.day - datum.weekday + 1,
    );
  }

  static DateTime beginVanMaand(DateTime datum) {
    return DateTime(
      datum.year,
      datum.month,
      1,
    );
  }

  static DateTime vorigeMaand(DateTime datum) {
    return DateTime(
      datum.year,
      datum.month - 1,
      1,
    );
  }

  static DateTime volgendeMaand(DateTime datum) {
    return DateTime(
      datum.year,
      datum.month + 1,
      1,
    );
  }

  static bool zelfdeDag(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isVandaag(DateTime datum) {
    return zelfdeDag(datum, DateTime.now());
  }

  static List<DateTime> wekenVanMaand(DateTime maand) {
    final eersteDag = DateTime(maand.year, maand.month, 1);
    final laatsteDag = DateTime(maand.year, maand.month + 1, 0);

    final start = beginVanWeek(eersteDag);
    final einde = beginVanWeek(laatsteDag).add(
      const Duration(days: 6),
    );

    final aantalWeken = (einde.difference(start).inDays + 1) ~/ 7;

    return List.generate(
      aantalWeken,
      (index) => start.add(Duration(days: index * 7)),
    );
  }

  static String datumKey(DateTime datum) {
    return '${datum.year.toString().padLeft(4, '0')}-'
        '${datum.month.toString().padLeft(2, '0')}-'
        '${datum.day.toString().padLeft(2, '0')}';
  }

  static String maandTitel(DateTime datum) {
    const maanden = [
      'januari',
      'februari',
      'maart',
      'april',
      'mei',
      'juni',
      'juli',
      'augustus',
      'september',
      'oktober',
      'november',
      'december',
    ];

    return '${maanden[datum.month - 1]} ${datum.year}';
  }
}
