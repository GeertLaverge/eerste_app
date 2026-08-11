// THIMACO-CONTROLE: OFFERTEVARIANTEN-OPSLAAN-BIJSCHRIJVEN-ONDERTEKEND-APART-20260811
// THIMACO-CONTROLE: OFFERTE-GESCHIEDENIS-CONCEPTEN-WISSEN-ONDERTEKEND-BESCHERMD-20260809_2057
// THIMACO-CONTROLE: OFFERTEVERSIE-CONCEPT-BEWAREN-HEROPENEN-20260806
import 'dart:convert';

import '../../app_storage.dart';
import '../../opmeting/overzicht/opmeting_overzicht_model.dart';
import '../../opmeting/project/opmeting_project_titelhoofd_model.dart';
import '../offerte_goedkeuring_model.dart';
import 'offerte_versie_model.dart';

class OfferteVersieService {
  const OfferteVersieService();

  String projectSleutelVoor(OpmetingProjectTitelhoofd titelhoofd) {
    final klantSleutel = opmetingProjectTitelhoofdSleutel(titelhoofd.klantNaam);
    return 'project:$klantSleutel';
  }

  String maakInhoudSignatuur({
    required OpmetingProjectTitelhoofd titelhoofd,
    required List<OpmetingOverzichtRaamItem> posities,
  }) {
    final inhoud = <String, dynamic>{
      'titelhoofd': _zonderVluchtigeVelden(titelhoofd.toJson()),
      'posities': posities
          .map((positie) => _zonderVluchtigeVelden(positie.toJson()))
          .toList(growable: false),
    };
    final canoniek = jsonEncode(_canoniek(inhoud));

    var hash = 0x811C9DC5;
    for (final byte in utf8.encode(canoniek)) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }

    return hash.toRadixString(16).padLeft(8, '0');
  }

  Future<List<OfferteVersieModel>> laadVoorProject(
    OpmetingProjectTitelhoofd titelhoofd,
  ) async {
    final projectSleutel = projectSleutelVoor(titelhoofd);
    final alleVersies = await AppStorage.laadOfferteVersies();
    final resultaat = alleVersies
        .where(
          (versie) =>
              versie.isGeldig && versie.projectSleutel == projectSleutel,
        )
        .toList();

    resultaat.sort((eerste, tweede) {
      final nummer = tweede.versieNummer.compareTo(eerste.versieNummer);
      if (nummer != 0) return nummer;
      if (eerste.isVariant != tweede.isVariant) {
        return eerste.isVariant ? -1 : 1;
      }
      return tweede.opgeslagenOp.compareTo(eerste.opgeslagenOp);
    });

    return List<OfferteVersieModel>.unmodifiable(resultaat);
  }

  List<OfferteVersieModel> variantenUit(Iterable<OfferteVersieModel> versies) {
    final resultaat = versies.where((versie) => versie.isVariant).toList();
    resultaat.sort(
      (eerste, tweede) => tweede.versieNummer.compareTo(eerste.versieNummer),
    );
    return List<OfferteVersieModel>.unmodifiable(resultaat);
  }

  List<OfferteVersieModel> ondertekendeMomentopnamesVoorVariant({
    required Iterable<OfferteVersieModel> versies,
    required String variantId,
  }) {
    final variant = variantVoorId(versies: versies, variantId: variantId);
    if (variant == null) return const <OfferteVersieModel>[];
    final resultaat =
        versies
            .where(
              (versie) => versie.hoortBijVariant(
                variant.id,
                variantNummer: variant.versieNummer,
              ),
            )
            .toList()
          ..sort(
            (eerste, tweede) =>
                tweede.opgeslagenOp.compareTo(eerste.opgeslagenOp),
          );
    return List<OfferteVersieModel>.unmodifiable(resultaat);
  }

  OfferteVersieModel? variantVoorId({
    required Iterable<OfferteVersieModel> versies,
    required String variantId,
  }) {
    final id = variantId.trim();
    if (id.isEmpty) return null;
    for (final versie in versies) {
      if (versie.id == id && versie.isVariant) return versie;
    }
    return null;
  }

  bool heeftOndertekendeMomentopname({
    required Iterable<OfferteVersieModel> versies,
    required String variantId,
  }) {
    final variant = variantVoorId(versies: versies, variantId: variantId);
    if (variant == null) return false;
    return versies.any(
      (versie) => versie.hoortBijVariant(
        variant.id,
        variantNummer: variant.versieNummer,
      ),
    );
  }

  Future<OfferteVersieModel> bewaarNieuweVariant({
    required OpmetingProjectTitelhoofd titelhoofd,
    required List<OpmetingOverzichtRaamItem> posities,
    required List<OpmetingOverzichtRaamItem> werkPosities,
    required DateTime offerteDatum,
    required double totaalInclusiefBtw,
    required String naam,
    required String omschrijving,
  }) {
    return AppStorage.muteerOfferteVersiesAtomair<OfferteVersieModel>((
      alleVersies,
    ) {
      final projectSleutel = projectSleutelVoor(titelhoofd);
      final hoogsteNummer = alleVersies
          .where((versie) => versie.projectSleutel == projectSleutel)
          .fold<int>(
            0,
            (hoogste, versie) =>
                versie.versieNummer > hoogste ? versie.versieNummer : hoogste,
          );
      final versieNummer = hoogsteNummer + 1;
      final titelhoofdVoorVariant = titelhoofd.copyWith(
        offerteVersie: OpmetingProjectTitelhoofd.offerteVersieVoorVariantNummer(
          versieNummer,
        ),
      );
      final versie = _maakNieuweVersie(
        titelhoofd: titelhoofdVoorVariant,
        posities: posities,
        werkPosities: werkPosities,
        offerteDatum: offerteDatum,
        totaalInclusiefBtw: totaalInclusiefBtw,
        status: OfferteVersieStatus.concept,
        versieNummer: versieNummer,
        naam: naam.trim(),
        omschrijving: omschrijving.trim(),
        bronVersieId: titelhoofd.offerteBronVersieId.trim(),
        bronVersieNummer: titelhoofd.offerteBronVersieNummer,
        goedkeuring: OfferteGoedkeuring.leeg(),
      );

      return AppStorageOfferteVersieMutatieResultaat<OfferteVersieModel>(
        resultaat: versie,
        versies: <OfferteVersieModel>[...alleVersies, versie],
        gewijzigd: true,
      );
    });
  }

  /// Oude aanroepnaam blijft bestaan zodat andere code niet onverwacht breekt.
  /// Een `concept` is voortaan een bewerkbare offertevariant.
  Future<OfferteVersieModel> bewaarConceptVersie({
    required OpmetingProjectTitelhoofd titelhoofd,
    required List<OpmetingOverzichtRaamItem> posities,
    required List<OpmetingOverzichtRaamItem> werkPosities,
    required DateTime offerteDatum,
    required double totaalInclusiefBtw,
    required String naam,
    required String omschrijving,
  }) {
    return bewaarNieuweVariant(
      titelhoofd: titelhoofd,
      posities: posities,
      werkPosities: werkPosities,
      offerteDatum: offerteDatum,
      totaalInclusiefBtw: totaalInclusiefBtw,
      naam: naam,
      omschrijving: omschrijving,
    );
  }

  Future<OfferteVersieModel> werkVariantBij({
    required String variantId,
    required OpmetingProjectTitelhoofd titelhoofd,
    required List<OpmetingOverzichtRaamItem> posities,
    required List<OpmetingOverzichtRaamItem> werkPosities,
    required DateTime offerteDatum,
    required double totaalInclusiefBtw,
    String? naam,
    String? omschrijving,
  }) {
    final gevraagdeId = variantId.trim();
    if (gevraagdeId.isEmpty) {
      throw StateError('Er is geen actieve offertevariant om bij te werken.');
    }

    return AppStorage.muteerOfferteVersiesAtomair<OfferteVersieModel>((
      alleVersies,
    ) {
      final index = alleVersies.indexWhere(
        (versie) => versie.id == gevraagdeId && versie.isVariant,
      );
      if (index < 0) {
        throw StateError(
          'De gekozen offertevariant bestaat niet meer in de opslag.',
        );
      }

      final bestaand = alleVersies[index];
      final titelhoofdVoorVariant = titelhoofd.metActieveOfferteVariant(
        versieId: bestaand.id,
        versieNummer: bestaand.versieNummer,
      );
      final bijgewerkt = bestaand.copyWith(
        offerteNummer: titelhoofdVoorVariant.samengesteldOffertenummer,
        klantNaam: titelhoofdVoorVariant.klantNaam,
        offerteDatum: offerteDatum,
        opgeslagenOp: DateTime.now(),
        totaalInclusiefBtw: totaalInclusiefBtw,
        inhoudSignatuur: maakInhoudSignatuur(
          titelhoofd: titelhoofdVoorVariant,
          posities: posities,
        ),
        status: OfferteVersieStatus.concept,
        naam: naam?.trim() ?? bestaand.naam,
        omschrijving: omschrijving?.trim() ?? bestaand.omschrijving,
        bronVersieId: bestaand.bronVersieId,
        bronVersieNummer: bestaand.bronVersieNummer,
        goedkeuring: OfferteGoedkeuring.leeg(),
        titelhoofdJson: Map<String, dynamic>.from(
          titelhoofdVoorVariant.toJson(),
        ),
        positiesJson: posities
            .map((positie) => Map<String, dynamic>.from(positie.toJson()))
            .toList(growable: false),
        werkPositiesJson: werkPosities
            .map((positie) => Map<String, dynamic>.from(positie.toJson()))
            .toList(growable: false),
      );
      final nieuweLijst = List<OfferteVersieModel>.from(alleVersies);
      nieuweLijst[index] = bijgewerkt;

      return AppStorageOfferteVersieMutatieResultaat<OfferteVersieModel>(
        resultaat: bijgewerkt,
        versies: nieuweLijst,
        gewijzigd: true,
      );
    });
  }

  Future<OfferteVersieModel> bewaarOndertekendeVersie({
    required OpmetingProjectTitelhoofd titelhoofd,
    required List<OpmetingOverzichtRaamItem> posities,
    required List<OpmetingOverzichtRaamItem> werkPosities,
    required DateTime offerteDatum,
    required double totaalInclusiefBtw,
    required OfferteGoedkeuring goedkeuring,
    String bestaandeConceptVersieId = '',
    String variantId = '',
    int variantNummer = 0,
    String variantNaam = '',
  }) {
    if (!goedkeuring.isOndertekend) {
      throw StateError('De offerte heeft geen geldige handtekening.');
    }

    return AppStorage.muteerOfferteVersiesAtomair<OfferteVersieModel>((
      alleVersies,
    ) {
      final projectSleutel = projectSleutelVoor(titelhoofd);
      final gevraagdeId = variantId.trim().isNotEmpty
          ? variantId.trim()
          : bestaandeConceptVersieId.trim();
      OfferteVersieModel? variant;

      if (gevraagdeId.isNotEmpty) {
        for (final kandidaat in alleVersies) {
          if (kandidaat.id == gevraagdeId &&
              kandidaat.projectSleutel == projectSleutel &&
              kandidaat.isVariant) {
            variant = kandidaat;
            break;
          }
        }
      }

      final titelhoofdVoorControle = variant == null
          ? titelhoofd
          : titelhoofd.metActieveOfferteVariant(
              versieId: variant.id,
              versieNummer: variant.versieNummer,
            );
      final inhoudSignatuur = maakInhoudSignatuur(
        titelhoofd: titelhoofdVoorControle,
        posities: posities,
      );

      if (variant == null) {
        for (final kandidaat in alleVersies) {
          if (kandidaat.projectSleutel == projectSleutel &&
              kandidaat.isVariant &&
              kandidaat.inhoudSignatuur == inhoudSignatuur) {
            variant = kandidaat;
            break;
          }
        }
      }

      if (variant == null) {
        throw StateError(
          'Sla deze offerte eerst op als offertevariant voordat u ze '
          'ondertekent.',
        );
      }

      final effectiefNummer = variantNummer > 0
          ? variantNummer
          : variant.versieNummer;
      if (effectiefNummer != variant.versieNummer) {
        throw StateError('Het nummer van de offertevariant is gewijzigd.');
      }

      final definitiefTitelhoofd = titelhoofd.metActieveOfferteVariant(
        versieId: variant.id,
        versieNummer: variant.versieNummer,
      );
      final definitieveSignatuur = maakInhoudSignatuur(
        titelhoofd: definitiefTitelhoofd,
        posities: posities,
      );
      final opgeslagenVariantTitelhoofd = titelhoofdVan(variant)
          .metActieveOfferteVariant(
            versieId: variant.id,
            versieNummer: variant.versieNummer,
          );
      final opgeslagenVariantSignatuur = maakInhoudSignatuur(
        titelhoofd: opgeslagenVariantTitelhoofd,
        posities: positiesVan(variant),
      );
      if (opgeslagenVariantSignatuur != definitieveSignatuur) {
        throw StateError(
          'Deze offerte bevat nog niet-opgeslagen wijzigingen. Sla de '
          'offertevariant eerst op en probeer daarna opnieuw.',
        );
      }

      final snapshot = _maakNieuweVersie(
        titelhoofd: definitiefTitelhoofd,
        posities: posities,
        werkPosities: werkPosities,
        offerteDatum: offerteDatum,
        totaalInclusiefBtw: totaalInclusiefBtw,
        status: OfferteVersieStatus.ondertekend,
        versieNummer: variant.versieNummer,
        naam: variantNaam.trim().isNotEmpty ? variantNaam.trim() : variant.naam,
        omschrijving:
            'Ondertekende momentopname van '
            '${variant.offerteVariantLabel}',
        bronVersieId: variant.id,
        bronVersieNummer: variant.versieNummer,
        goedkeuring: goedkeuring,
        idSoort: 'signed',
      );

      return AppStorageOfferteVersieMutatieResultaat<OfferteVersieModel>(
        resultaat: snapshot,
        versies: <OfferteVersieModel>[...alleVersies, snapshot],
        gewijzigd: true,
      );
    });
  }

  Future<void> verwijderConceptVersie(OfferteVersieModel versie) async {
    if (!versie.isVariant || versie.isOndertekend) {
      throw StateError('Een ondertekende offerte kan niet worden gewist.');
    }

    await AppStorage.muteerOfferteVersiesAtomair<void>((alleVersies) {
      final actueel = variantVoorId(versies: alleVersies, variantId: versie.id);
      if (actueel == null) {
        return AppStorageOfferteVersieMutatieResultaat<void>(
          resultaat: null,
          versies: alleVersies,
          gewijzigd: false,
        );
      }

      if (heeftOndertekendeMomentopname(
        versies: alleVersies,
        variantId: actueel.id,
      )) {
        throw StateError(
          'Deze offertevariant heeft een ondertekende momentopname en kan '
          'daarom niet worden verwijderd.',
        );
      }

      return AppStorageOfferteVersieMutatieResultaat<void>(
        resultaat: null,
        versies: alleVersies
            .where((bestaand) => bestaand.id != actueel.id)
            .toList(growable: false),
        gewijzigd: true,
      );
    });
  }

  OfferteVersieModel? vindOvereenkomendeVersie({
    required Iterable<OfferteVersieModel> versies,
    required String inhoudSignatuur,
    OfferteVersieStatus? status,
  }) {
    for (final versie in versies) {
      if (versie.inhoudSignatuur != inhoudSignatuur) continue;
      if (status != null && versie.status != status) continue;
      return versie;
    }
    return null;
  }

  OpmetingProjectTitelhoofd titelhoofdVan(OfferteVersieModel versie) {
    return OpmetingProjectTitelhoofd.fromJson(
      Map<String, dynamic>.from(versie.titelhoofdJson),
    );
  }

  List<OpmetingOverzichtRaamItem> positiesVan(OfferteVersieModel versie) {
    return _decodePosities(versie.positiesJson);
  }

  List<OpmetingOverzichtRaamItem> werkPositiesVan(OfferteVersieModel versie) {
    return _decodePosities(versie.werkPositiesJson);
  }

  List<OpmetingOverzichtRaamItem> _decodePosities(
    Iterable<Map<String, dynamic>> posities,
  ) {
    return posities
        .map(
          (positie) => OpmetingOverzichtRaamItem.fromJson(
            Map<String, dynamic>.from(positie),
          ),
        )
        .toList(growable: false);
  }

  OfferteVergelijkingResultaat vergelijkMetHuidig({
    required OfferteVersieModel versie,
    required OpmetingProjectTitelhoofd huidigTitelhoofd,
    required List<OpmetingOverzichtRaamItem> huidigePosities,
    required double huidigTotaalInclusiefBtw,
  }) {
    final oudePosities = versie.positiesJson;
    final nieuwePosities = huidigePosities
        .map((positie) => Map<String, dynamic>.from(positie.toJson()))
        .toList(growable: false);
    final oudPerId = <String, Map<String, dynamic>>{
      for (final positie in oudePosities)
        if (_idVan(positie).isNotEmpty) _idVan(positie): positie,
    };
    final nieuwPerId = <String, Map<String, dynamic>>{
      for (final positie in nieuwePosities)
        if (_idVan(positie).isNotEmpty) _idVan(positie): positie,
    };

    final toegevoegd = <String>[];
    final verwijderd = <String>[];
    final gewijzigd = <String>[];

    for (var index = 0; index < nieuwePosities.length; index++) {
      final positie = nieuwePosities[index];
      final id = _idVan(positie);
      if (id.isEmpty || !oudPerId.containsKey(id)) {
        toegevoegd.add(_positieNaam(positie, index + 1));
      }
    }

    for (var index = 0; index < oudePosities.length; index++) {
      final positie = oudePosities[index];
      final id = _idVan(positie);
      if (id.isEmpty || !nieuwPerId.containsKey(id)) {
        verwijderd.add(_positieNaam(positie, index + 1));
      }
    }

    for (var index = 0; index < nieuwePosities.length; index++) {
      final nieuwePositie = nieuwePosities[index];
      final id = _idVan(nieuwePositie);
      final oudePositie = oudPerId[id];
      if (id.isEmpty || oudePositie == null) continue;

      final oudCanoniek = jsonEncode(
        _canoniek(_zonderVluchtigeVelden(oudePositie)),
      );
      final nieuwCanoniek = jsonEncode(
        _canoniek(_zonderVluchtigeVelden(nieuwePositie)),
      );
      if (oudCanoniek != nieuwCanoniek) {
        gewijzigd.add(_positieNaam(nieuwePositie, index + 1));
      }
    }

    final projectWijzigingen = _vergelijkTitelhoofden(
      versie.titelhoofdJson,
      huidigTitelhoofd.toJson(),
    );
    final totaalGewijzigd =
        (versie.totaalInclusiefBtw - huidigTotaalInclusiefBtw).abs() > 0.005;

    return OfferteVergelijkingResultaat(
      toegevoegdePosities: toegevoegd,
      verwijderdePosities: verwijderd,
      gewijzigdePosities: gewijzigd,
      projectWijzigingen: projectWijzigingen,
      oudTotaalInclusiefBtw: versie.totaalInclusiefBtw,
      nieuwTotaalInclusiefBtw: huidigTotaalInclusiefBtw,
      totaalGewijzigd: totaalGewijzigd,
    );
  }

  OfferteVersieModel _maakNieuweVersie({
    required OpmetingProjectTitelhoofd titelhoofd,
    required List<OpmetingOverzichtRaamItem> posities,
    required List<OpmetingOverzichtRaamItem> werkPosities,
    required DateTime offerteDatum,
    required double totaalInclusiefBtw,
    required OfferteVersieStatus status,
    required int versieNummer,
    required String naam,
    required String omschrijving,
    required String bronVersieId,
    required int bronVersieNummer,
    required OfferteGoedkeuring goedkeuring,
    String idSoort = 'variant',
  }) {
    final projectSleutel = projectSleutelVoor(titelhoofd);
    final opgeslagenOp = DateTime.now();
    final soort = _veiligeId(idSoort).isEmpty ? 'record' : _veiligeId(idSoort);

    return OfferteVersieModel(
      id:
          '${_veiligeId(projectSleutel)}_v${versieNummer}_${soort}_'
          '${opgeslagenOp.toUtc().microsecondsSinceEpoch}',
      projectSleutel: projectSleutel,
      versieNummer: versieNummer,
      offerteNummer: titelhoofd.samengesteldOffertenummer,
      klantNaam: titelhoofd.klantNaam,
      offerteDatum: offerteDatum,
      opgeslagenOp: opgeslagenOp,
      totaalInclusiefBtw: totaalInclusiefBtw,
      inhoudSignatuur: maakInhoudSignatuur(
        titelhoofd: titelhoofd,
        posities: posities,
      ),
      status: status,
      naam: naam,
      omschrijving: omschrijving,
      bronVersieId: bronVersieId,
      bronVersieNummer: bronVersieNummer,
      goedkeuring: goedkeuring,
      titelhoofdJson: Map<String, dynamic>.from(titelhoofd.toJson()),
      positiesJson: posities
          .map((positie) => Map<String, dynamic>.from(positie.toJson()))
          .toList(growable: false),
      werkPositiesJson: werkPosities
          .map((positie) => Map<String, dynamic>.from(positie.toJson()))
          .toList(growable: false),
    );
  }

  static Map<String, dynamic> _zonderVluchtigeVelden(
    Map<String, dynamic> bron,
  ) {
    const uitgesloten = <String>{
      'gewijzigdOp',
      'updatedAt',
      'deletedAt',
      'offertePrijsinstellingenMomentopnames',
      'offerteBronVersieId',
      'offerteBronVersieNummer',
    };
    final resultaat = <String, dynamic>{};

    for (final entry in bron.entries) {
      if (uitgesloten.contains(entry.key)) continue;
      resultaat[entry.key] = _zonderVluchtigeWaarde(entry.value);
    }

    return resultaat;
  }

  static Object? _zonderVluchtigeWaarde(Object? waarde) {
    if (waarde is Map) {
      return _zonderVluchtigeVelden(Map<String, dynamic>.from(waarde));
    }
    if (waarde is List) {
      return waarde.map(_zonderVluchtigeWaarde).toList(growable: false);
    }
    return waarde;
  }

  static Object? _canoniek(Object? waarde) {
    if (waarde is Map) {
      final map = Map<String, dynamic>.from(waarde);
      final sleutels = map.keys.toList()..sort();
      return <String, dynamic>{
        for (final sleutel in sleutels) sleutel: _canoniek(map[sleutel]),
      };
    }
    if (waarde is List) {
      return waarde.map(_canoniek).toList(growable: false);
    }
    return waarde;
  }

  static String _veiligeId(String waarde) {
    return waarde
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  static String _idVan(Map<String, dynamic> positie) {
    return positie['id']?.toString().trim() ?? '';
  }

  static String _positieNaam(Map<String, dynamic> positie, int nummer) {
    final titel = positie['titel']?.toString().trim() ?? '';
    final formulierType = positie['formulierType']?.toString().trim() ?? '';
    final naam = titel.isNotEmpty
        ? titel
        : formulierType.isNotEmpty
        ? formulierType
        : 'Artikel';
    return 'Positie $nummer · $naam';
  }

  static List<String> _vergelijkTitelhoofden(
    Map<String, dynamic> oud,
    Map<String, dynamic> nieuw,
  ) {
    const velden = <String, String>{
      'klantNaam': 'Klantnaam',
      'contactpersoon': 'Contactpersoon',
      'adres': 'Klantadres',
      'huisnummer': 'Huisnummer klant',
      'busNummer': 'Busnummer klant',
      'postcode': 'Postcode klant',
      'gemeente': 'Gemeente klant',
      'projectAdres': 'Projectadres',
      'projectHuisnummer': 'Huisnummer project',
      'projectBusNummer': 'Busnummer project',
      'projectPostcode': 'Postcode project',
      'projectGemeente': 'Gemeente project',
      'projectKleurBinnen': 'Kleur binnen',
      'projectKleurBuiten': 'Kleur buiten',
      'ralKleurToebehoren': 'Kleur toebehoren',
      'kleurAfwijking': 'Kleurafwijking',
      'btwTarief': 'Btw-tarief',
      'offerteJaar': 'Offertejaar',
      'klantnummer': 'Klantnummer',
      'offerteVolgnummer': 'Offertevolgnummer',
      'kortingOmschrijving': 'Kortingomschrijving',
    };
    final resultaat = <String>[];

    for (final entry in velden.entries) {
      final oudeWaarde = oud[entry.key]?.toString().trim() ?? '';
      final nieuweWaarde = nieuw[entry.key]?.toString().trim() ?? '';
      if (oudeWaarde != nieuweWaarde) {
        final oudTekst = oudeWaarde.isEmpty ? '—' : oudeWaarde;
        final nieuwTekst = nieuweWaarde.isEmpty ? '—' : nieuweWaarde;
        resultaat.add('${entry.value}: $oudTekst → $nieuwTekst');
      }
    }

    return resultaat;
  }
}

class OfferteVergelijkingResultaat {
  const OfferteVergelijkingResultaat({
    required this.toegevoegdePosities,
    required this.verwijderdePosities,
    required this.gewijzigdePosities,
    required this.projectWijzigingen,
    required this.oudTotaalInclusiefBtw,
    required this.nieuwTotaalInclusiefBtw,
    required this.totaalGewijzigd,
  });

  final List<String> toegevoegdePosities;
  final List<String> verwijderdePosities;
  final List<String> gewijzigdePosities;
  final List<String> projectWijzigingen;
  final double oudTotaalInclusiefBtw;
  final double nieuwTotaalInclusiefBtw;
  final bool totaalGewijzigd;

  bool get heeftWijzigingen {
    return toegevoegdePosities.isNotEmpty ||
        verwijderdePosities.isNotEmpty ||
        gewijzigdePosities.isNotEmpty ||
        projectWijzigingen.isNotEmpty ||
        totaalGewijzigd;
  }
}
