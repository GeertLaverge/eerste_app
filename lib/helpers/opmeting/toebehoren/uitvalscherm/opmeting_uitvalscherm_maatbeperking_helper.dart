class OpmetingUitvalschermMaatbeperkingHelper {
  const OpmetingUitvalschermMaatbeperkingHelper._();

  static const int minimumBreedteMm = 2300;
  static const int minimumUitvalMm = 500;
  static const int uitvalStapMm = 500;

  static int maximumBreedteMm(String typeId) {
    return typeId == '500X' ? 5000 : 7000;
  }

  static int maximumUitvalMm({required String typeId, required int breedteMm}) {
    final breedte = breedteMm.clamp(minimumBreedteMm, maximumBreedteMm(typeId));

    if (typeId == '500X') {
      if (breedte <= 2500) return 1500;
      if (breedte <= 3000) return 2000;
      if (breedte <= 3500) return 2500;
      if (breedte <= 4000) return 3000;
      return 3500;
    }

    if (breedte <= 2300) return 500;
    if (breedte <= 2500) return 1500;
    if (breedte <= 3000) return 2000;
    if (breedte <= 3500) return 2500;
    if (breedte <= 4000) return 3000;
    return 3500;
  }

  static List<int> toegestaneUitvallen({
    required String typeId,
    required int breedteMm,
  }) {
    final maximum = maximumUitvalMm(typeId: typeId, breedteMm: breedteMm);
    return List<int>.unmodifiable(<int>[
      for (
        var waarde = minimumUitvalMm;
        waarde <= maximum;
        waarde += uitvalStapMm
      )
        waarde,
    ]);
  }

  static int normaliseerBreedte({required String typeId, required int waarde}) {
    return waarde.clamp(minimumBreedteMm, maximumBreedteMm(typeId)).toInt();
  }

  static int normaliseerUitval({
    required String typeId,
    required int breedteMm,
    required int waarde,
  }) {
    final keuzes = toegestaneUitvallen(typeId: typeId, breedteMm: breedteMm);
    if (keuzes.contains(waarde)) return waarde;

    var dichtste = keuzes.first;
    var verschil = (waarde - dichtste).abs();
    for (final keuze in keuzes.skip(1)) {
      final nieuwVerschil = (waarde - keuze).abs();
      if (nieuwVerschil < verschil) {
        dichtste = keuze;
        verschil = nieuwVerschil;
      }
    }
    return dichtste;
  }
}
