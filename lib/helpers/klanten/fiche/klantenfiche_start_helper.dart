class KlantenficheStartHelper {
  static String startStatus({
    required String? bestaandeStatus,
    required String gewensteStartStatus,
  }) {
    if (bestaandeStatus != null && bestaandeStatus.trim().isNotEmpty) {
      return bestaandeStatus;
    }

    return gewensteStartStatus;
  }
}
