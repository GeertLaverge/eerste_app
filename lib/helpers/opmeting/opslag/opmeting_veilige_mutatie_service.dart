// THIMACO-CONTROLE: GLOBALE-ATOMAIRE-POSITIE-MUTATIES-20260810
// THIMACO-CONTROLE: VEILIGE-POSITIE-MUTATIES-FASE1-20260810_113219
import '../../app_storage.dart';
import '../overzicht/opmeting_overzicht_model.dart';

typedef OpmetingPositieMutatie =
    OpmetingOverzichtRaamItem Function(
      OpmetingOverzichtRaamItem actuelePositie,
    );

class OpmetingVeiligeMutatieResultaat {
  const OpmetingVeiligeMutatieResultaat({
    required this.positie,
    required this.gewijzigd,
  });

  final OpmetingOverzichtRaamItem positie;
  final bool gewijzigd;
}

class OpmetingVeiligeLijstResultaat {
  const OpmetingVeiligeLijstResultaat({
    required this.opmetingen,
    required this.gewijzigd,
  });

  final List<OpmetingOverzichtRaamItem> opmetingen;
  final bool gewijzigd;
}

class OpmetingVeiligeMutatieService {
  const OpmetingVeiligeMutatieService._();

  /// Voert de wijziging binnen dezelfde globale AppStorage-lock uit als alle
  /// andere fiche-, lijst- en syncmutaties.
  static Future<OpmetingVeiligeMutatieResultaat> wijzigPositie({
    required String positieId,
    required OpmetingPositieMutatie wijziging,
  }) {
    final id = positieId.trim();
    if (id.isEmpty) {
      return Future<OpmetingVeiligeMutatieResultaat>.error(
        StateError('Positie-ID ontbreekt bij veilige mutatie.'),
      );
    }

    return AppStorage.muteerOpmetingenAtomair<OpmetingVeiligeMutatieResultaat>((
      actueleOpmetingen,
    ) {
      final index = actueleOpmetingen.indexWhere((item) => item.id == id);

      if (index < 0) {
        throw StateError('Positie $id bestaat niet meer in de opslag.');
      }

      final actueel = actueleOpmetingen[index];
      final mutatieResultaat = wijziging(actueel);
      final kandidaat = mutatieResultaat.copyWith(
        id: actueel.id,
        gewijzigdOp: actueel.gewijzigdOp,
        isVerwijderd: actueel.isVerwijderd,
      );

      if (_positieInhoudGelijk(actueel, kandidaat)) {
        final resultaat = OpmetingVeiligeMutatieResultaat(
          positie: actueel,
          gewijzigd: false,
        );
        return AppStorageOpmetingMutatieResultaat<
          OpmetingVeiligeMutatieResultaat
        >(
          resultaat: resultaat,
          opmetingen: actueleOpmetingen,
          gewijzigd: false,
        );
      }

      final bijgewerkt = kandidaat.copyWith(
        gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
      );
      final nieuweLijst = List<OpmetingOverzichtRaamItem>.from(
        actueleOpmetingen,
      );
      nieuweLijst[index] = bijgewerkt;

      final resultaat = OpmetingVeiligeMutatieResultaat(
        positie: bijgewerkt,
        gewijzigd: true,
      );
      return AppStorageOpmetingMutatieResultaat<
        OpmetingVeiligeMutatieResultaat
      >(resultaat: resultaat, opmetingen: nieuweLijst, gewijzigd: true);
    });
  }

  /// Drie-weg-save voor een bestaande fiche. Alleen verschillen tussen [basis]
  /// en [gewijzigd] worden op de nieuwste opgeslagen positie toegepast.
  static Future<OpmetingVeiligeMutatieResultaat> bewaarFicheWijzigingen({
    required OpmetingOverzichtRaamItem basis,
    required OpmetingOverzichtRaamItem gewijzigd,
  }) {
    final id = basis.id.trim();

    if (id.isEmpty || gewijzigd.id.trim() != id) {
      return Future<OpmetingVeiligeMutatieResultaat>.error(
        StateError(
          'De basisfiche en gewijzigde fiche hebben geen geldige gelijke ID.',
        ),
      );
    }

    return AppStorage.muteerOpmetingenAtomair<OpmetingVeiligeMutatieResultaat>((
      actueleOpmetingen,
    ) {
      final index = actueleOpmetingen.indexWhere((item) => item.id == id);

      if (index < 0) {
        throw StateError('Positie $id bestaat niet meer in de opslag.');
      }

      final actueel = actueleOpmetingen[index];
      final samengevoegd = _driewegSamenvoegenPositie(
        basis: basis,
        gewijzigd: gewijzigd,
        actueel: actueel,
      );

      if (_positieInhoudGelijk(actueel, samengevoegd)) {
        final resultaat = OpmetingVeiligeMutatieResultaat(
          positie: actueel,
          gewijzigd: false,
        );
        return AppStorageOpmetingMutatieResultaat<
          OpmetingVeiligeMutatieResultaat
        >(
          resultaat: resultaat,
          opmetingen: actueleOpmetingen,
          gewijzigd: false,
        );
      }

      final bijgewerkt = samengevoegd.copyWith(
        id: actueel.id,
        isVerwijderd: actueel.isVerwijderd,
        gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
      );
      final nieuweLijst = List<OpmetingOverzichtRaamItem>.from(
        actueleOpmetingen,
      );
      nieuweLijst[index] = bijgewerkt;

      final resultaat = OpmetingVeiligeMutatieResultaat(
        positie: bijgewerkt,
        gewijzigd: true,
      );
      return AppStorageOpmetingMutatieResultaat<
        OpmetingVeiligeMutatieResultaat
      >(resultaat: resultaat, opmetingen: nieuweLijst, gewijzigd: true);
    });
  }

  /// Veilige batch-save voor prijs- of projectberekeningen die op een eerder
  /// geladen volledige lijst gestart zijn.
  static Future<OpmetingVeiligeLijstResultaat> bewaarBerekendeWijzigingen({
    required List<OpmetingOverzichtRaamItem> basis,
    required List<OpmetingOverzichtRaamItem> gewijzigd,
  }) {
    return AppStorage.muteerOpmetingenAtomair<OpmetingVeiligeLijstResultaat>((
      actueleOpmetingen,
    ) {
      final basisPerId = <String, OpmetingOverzichtRaamItem>{
        for (final item in basis)
          if (item.id.trim().isNotEmpty) item.id: item,
      };
      final gewijzigdPerId = <String, OpmetingOverzichtRaamItem>{
        for (final item in gewijzigd)
          if (item.id.trim().isNotEmpty) item.id: item,
      };
      final nieuweLijst = List<OpmetingOverzichtRaamItem>.from(
        actueleOpmetingen,
      );
      final indexPerId = <String, int>{
        for (var index = 0; index < nieuweLijst.length; index++)
          if (nieuweLijst[index].id.trim().isNotEmpty)
            nieuweLijst[index].id: index,
      };

      var heeftWijziging = false;

      for (final entry in gewijzigdPerId.entries) {
        final basisPositie = basisPerId[entry.key];
        final actueleIndex = indexPerId[entry.key];

        // Een oude berekening mag geen ondertussen verwijderde of nieuw
        // aangemaakte positie opnieuw creëren of verwijderen.
        if (basisPositie == null || actueleIndex == null) continue;

        final actuelePositie = nieuweLijst[actueleIndex];
        final samengevoegd = _driewegSamenvoegenPositie(
          basis: basisPositie,
          gewijzigd: entry.value,
          actueel: actuelePositie,
        );

        if (_positieInhoudGelijk(actuelePositie, samengevoegd)) continue;

        nieuweLijst[actueleIndex] = samengevoegd.copyWith(
          id: actuelePositie.id,
          isVerwijderd: actuelePositie.isVerwijderd,
          gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
        );
        heeftWijziging = true;
      }

      final resultaat = OpmetingVeiligeLijstResultaat(
        opmetingen: List<OpmetingOverzichtRaamItem>.unmodifiable(nieuweLijst),
        gewijzigd: heeftWijziging,
      );
      return AppStorageOpmetingMutatieResultaat<OpmetingVeiligeLijstResultaat>(
        resultaat: resultaat,
        opmetingen: nieuweLijst,
        gewijzigd: heeftWijziging,
      );
    });
  }

  static OpmetingOverzichtRaamItem _driewegSamenvoegenPositie({
    required OpmetingOverzichtRaamItem basis,
    required OpmetingOverzichtRaamItem gewijzigd,
    required OpmetingOverzichtRaamItem actueel,
  }) {
    final json = _voegMapWijzigingenSamen(
      basis: basis.toJson(),
      gewijzigd: gewijzigd.toJson(),
      actueel: actueel.toJson(),
      hoofdNiveau: true,
    );

    json['id'] = actueel.id;
    json['gewijzigdOp'] = actueel.gewijzigdOp;

    return OpmetingOverzichtRaamItem.fromJson(json);
  }

  /// Recursieve drie-weg-merge. Ook geneste maps zoals offertePrijsData worden
  /// veld per veld samengevoegd. Daardoor kan een nieuwe eenheidsprijs blijven
  /// staan wanneer een reeds open fiche daarna een technische keuze bewaart.
  static Map<String, dynamic> _voegMapWijzigingenSamen({
    required Map<String, dynamic> basis,
    required Map<String, dynamic> gewijzigd,
    required Map<String, dynamic> actueel,
    bool hoofdNiveau = false,
  }) {
    final resultaat = <String, dynamic>{
      for (final entry in actueel.entries)
        entry.key: _kopieJsonWaarde(entry.value),
    };

    final sleutels = <String>{...basis.keys, ...gewijzigd.keys};

    for (final sleutel in sleutels) {
      if (hoofdNiveau && (sleutel == 'id' || sleutel == 'gewijzigdOp')) {
        continue;
      }

      final basisHeeft = basis.containsKey(sleutel);
      final gewijzigdHeeft = gewijzigd.containsKey(sleutel);

      if (basisHeeft == gewijzigdHeeft &&
          _jsonGelijk(basis[sleutel], gewijzigd[sleutel])) {
        // Niet door deze handeling gewijzigd: huidige opslag behouden.
        continue;
      }

      if (!gewijzigdHeeft) {
        resultaat.remove(sleutel);
        continue;
      }

      final basisWaarde = basis[sleutel];
      final gewijzigdeWaarde = gewijzigd[sleutel];
      final actueleWaarde = resultaat[sleutel];

      if (basisWaarde is Map &&
          gewijzigdeWaarde is Map &&
          actueleWaarde is Map) {
        resultaat[sleutel] = _voegMapWijzigingenSamen(
          basis: Map<String, dynamic>.from(basisWaarde),
          gewijzigd: Map<String, dynamic>.from(gewijzigdeWaarde),
          actueel: Map<String, dynamic>.from(actueleWaarde),
        );
        continue;
      }

      // Lijsten en scalaire waarden worden alleen vervangen wanneer deze
      // handeling ze werkelijk gewijzigd heeft.
      resultaat[sleutel] = _kopieJsonWaarde(gewijzigdeWaarde);
    }

    return resultaat;
  }

  static bool _positieInhoudGelijk(
    OpmetingOverzichtRaamItem eerste,
    OpmetingOverzichtRaamItem tweede,
  ) {
    final eersteJson = Map<String, dynamic>.from(eerste.toJson())
      ..remove('gewijzigdOp');
    final tweedeJson = Map<String, dynamic>.from(tweede.toJson())
      ..remove('gewijzigdOp');

    return _jsonGelijk(eersteJson, tweedeJson);
  }

  static bool _jsonGelijk(Object? eerste, Object? tweede) {
    if (identical(eerste, tweede)) {
      return true;
    }

    if (eerste is Map && tweede is Map) {
      if (eerste.length != tweede.length) {
        return false;
      }

      for (final sleutel in eerste.keys) {
        if (!tweede.containsKey(sleutel) ||
            !_jsonGelijk(eerste[sleutel], tweede[sleutel])) {
          return false;
        }
      }

      return true;
    }

    if (eerste is List && tweede is List) {
      if (eerste.length != tweede.length) {
        return false;
      }

      for (var index = 0; index < eerste.length; index++) {
        if (!_jsonGelijk(eerste[index], tweede[index])) {
          return false;
        }
      }

      return true;
    }

    return eerste == tweede;
  }

  static Object? _kopieJsonWaarde(Object? waarde) {
    if (waarde is Map) {
      return <String, dynamic>{
        for (final entry in waarde.entries)
          entry.key.toString(): _kopieJsonWaarde(entry.value),
      };
    }

    if (waarde is List) {
      return waarde.map(_kopieJsonWaarde).toList(growable: false);
    }

    return waarde;
  }
}
