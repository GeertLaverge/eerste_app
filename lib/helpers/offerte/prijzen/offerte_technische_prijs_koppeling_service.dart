// THIMACO-CONTROLE: TESTBARE-GEKOPPELDE-TECHNISCHE-PRIJZEN-FASE-5-20260727
// THIMACO-CONTROLE: GEKOPPELDE-TECHNISCHE-PRIJSREGELS-FASE-4-20260727
import '../../app_storage.dart';
import 'offerte_prijs_categorie.dart';
import 'offerte_prijsprofiel_model.dart';
import 'offerte_prijsregel_model.dart';

/// Beheert gekoppelde technische prijsregels zonder extra JSON-velden.
///
/// Technische prijsregels zijn gekoppeld wanneer dezelfde niet-lege
/// prijsregel-ID in minstens twee verschillende prijsprofielen voorkomt.
/// Elk profiel behoudt daarbij zijn eigen formulierType, technische keuze,
/// omschrijving en volgorde. Alleen de gedeelde prijsvelden worden
/// gesynchroniseerd.
class OfferteTechnischePrijsKoppelingService {
  const OfferteTechnischePrijsKoppelingService._();

  static Future<Map<String, int>> laadKoppelAantallen() async {
    final profielen = await AppStorage.laadOffertePrijsProfielen();
    return berekenKoppelAantallen(profielen);
  }

  static Map<String, int> berekenKoppelAantallen(
    Iterable<OffertePrijsprofielModel> profielen,
  ) {
    final formulierTypesPerPrijsregelId = <String, Set<String>>{};

    for (final profiel in profielen) {
      final formulierTypeSleutel = _normaliseerFormulierType(
        profiel.formulierType,
      );

      if (formulierTypeSleutel.isEmpty) {
        continue;
      }

      for (final prijsregel in profiel.regelsVoorCategorie(
        OffertePrijsCategorie.technischeKeuzePerArtikel,
      )) {
        final prijsregelId = prijsregel.id.trim();
        final technischeKeuze = prijsregel.technischeKeuze;

        if (prijsregelId.isEmpty ||
            technischeKeuze == null ||
            technischeKeuze.isLeeg) {
          continue;
        }

        formulierTypesPerPrijsregelId
            .putIfAbsent(prijsregelId, () => <String>{})
            .add(formulierTypeSleutel);
      }
    }

    return Map<String, int>.unmodifiable(
      formulierTypesPerPrijsregelId.map((prijsregelId, formulierTypes) {
        return MapEntry(prijsregelId, formulierTypes.length);
      }),
    );
  }

  static Future<void> bewaarEnSynchroniseer({
    required OffertePrijsprofielModel huidigProfiel,
    required Set<String> prijsregelIds,
  }) async {
    await AppStorage.bewaarOffertePrijsProfiel(huidigProfiel);

    final geldigeIds = prijsregelIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();

    if (geldigeIds.isEmpty) {
      return;
    }

    final bronPerId = <String, OffertePrijsregelModel>{};

    for (final prijsregel in huidigProfiel.regelsVoorCategorie(
      OffertePrijsCategorie.technischeKeuzePerArtikel,
    )) {
      if (!geldigeIds.contains(prijsregel.id) ||
          prijsregel.technischeKeuze == null ||
          prijsregel.technischeKeuze!.isLeeg) {
        continue;
      }

      bronPerId[prijsregel.id] = prijsregel;
    }

    if (bronPerId.isEmpty) {
      return;
    }

    final profielen = await AppStorage.laadOffertePrijsProfielen();

    for (final profiel in profielen) {
      if (_isZelfdeFormulierType(
        profiel.formulierType,
        huidigProfiel.formulierType,
      )) {
        continue;
      }

      final bijgewerktProfiel = synchroniseerProfielMetBronnen(
        profiel: profiel,
        bronPerId: bronPerId,
      );

      if (identical(bijgewerktProfiel, profiel)) {
        continue;
      }

      await AppStorage.bewaarOffertePrijsProfiel(bijgewerktProfiel);
    }
  }

  /// Werkt één prijsprofiel zuiver in het geheugen bij.
  ///
  /// Deze methode bevat dezelfde synchronisatielogica als de opslagroute,
  /// maar schrijft zelf niets weg. Daardoor kan exact worden getest dat alleen
  /// de gedeelde prijsvelden wijzigen. De lokale technische keuze,
  /// omschrijving, formulierkoppeling en volgorde blijven behouden.
  ///
  /// Wanneer geen geldige gekoppelde bron wordt gevonden, wordt exact hetzelfde
  /// [profiel]-object teruggegeven.
  static OffertePrijsprofielModel synchroniseerProfielMetBronnen({
    required OffertePrijsprofielModel profiel,
    required Map<String, OffertePrijsregelModel> bronPerId,
  }) {
    if (bronPerId.isEmpty) {
      return profiel;
    }

    var gewijzigd = false;
    final gebruikteBronnen = <OffertePrijsregelModel>[];

    final bijgewerktePrijsregels = profiel.prijsregels
        .map((prijsregel) {
          if (prijsregel.categorie !=
                  OffertePrijsCategorie.technischeKeuzePerArtikel ||
              prijsregel.technischeKeuze == null ||
              prijsregel.technischeKeuze!.isLeeg) {
            return prijsregel;
          }

          final bron = bronPerId[prijsregel.id];
          if (bron == null ||
              bron.categorie !=
                  OffertePrijsCategorie.technischeKeuzePerArtikel ||
              bron.technischeKeuze == null ||
              bron.technischeKeuze!.isLeeg) {
            return prijsregel;
          }

          gewijzigd = true;
          gebruikteBronnen.add(bron);

          return prijsregel.copyWith(
            prijsExclBtw: bron.prijsExclBtw,
            eenheid: bron.eenheid,
            uitschrijfmodus: bron.uitschrijfmodus,
            actief: bron.actief,
            gewijzigdOp: bron.gewijzigdOp,
          );
        })
        .toList(growable: false);

    if (!gewijzigd) {
      return profiel;
    }

    final nieuwsteWijziging = gebruikteBronnen
        .map((regel) => regel.gewijzigdOp)
        .fold<String>('', _nieuwsteDatumTekst);

    return profiel.copyWith(
      prijsregels: bijgewerktePrijsregels,
      gewijzigdOp: nieuwsteWijziging.isEmpty
          ? profiel.gewijzigdOp
          : nieuwsteWijziging,
    );
  }

  static String _nieuwsteDatumTekst(String eerste, String tweede) {
    final eersteDatum = DateTime.tryParse(eerste);
    final tweedeDatum = DateTime.tryParse(tweede);

    if (eersteDatum == null) {
      return tweede;
    }

    if (tweedeDatum == null) {
      return eerste;
    }

    return tweedeDatum.isAfter(eersteDatum) ? tweede : eerste;
  }

  static bool _isZelfdeFormulierType(String eerste, String tweede) {
    return _normaliseerFormulierType(eerste) ==
        _normaliseerFormulierType(tweede);
  }

  static String _normaliseerFormulierType(String waarde) {
    return waarde.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }
}
