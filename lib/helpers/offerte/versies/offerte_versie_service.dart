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
      return tweede.opgeslagenOp.compareTo(eerste.opgeslagenOp);
    });

    return List<OfferteVersieModel>.unmodifiable(resultaat);
  }

  Future<OfferteVersieModel> bewaarConceptVersie({
    required OpmetingProjectTitelhoofd titelhoofd,
    required List<OpmetingOverzichtRaamItem> posities,
    required List<OpmetingOverzichtRaamItem> werkPosities,
    required DateTime offerteDatum,
    required double totaalInclusiefBtw,
    required String naam,
    required String omschrijving,
  }) async {
    final schoneNaam = naam.trim();
    if (schoneNaam.isEmpty) {
      throw StateError('Geef een herkenbare naam aan deze offerteversie.');
    }

    final alleVersies = await AppStorage.laadOfferteVersies();
    final versie = _maakNieuweVersie(
      alleVersies: alleVersies,
      titelhoofd: titelhoofd,
      posities: posities,
      werkPosities: werkPosities,
      offerteDatum: offerteDatum,
      totaalInclusiefBtw: totaalInclusiefBtw,
      status: OfferteVersieStatus.concept,
      naam: schoneNaam,
      omschrijving: omschrijving.trim(),
      goedkeuring: OfferteGoedkeuring.leeg(),
    );

    await AppStorage.bewaarOfferteVersies(<OfferteVersieModel>[
      ...alleVersies,
      versie,
    ]);

    return versie;
  }

  Future<OfferteVersieModel> bewaarOndertekendeVersie({
    required OpmetingProjectTitelhoofd titelhoofd,
    required List<OpmetingOverzichtRaamItem> posities,
    required List<OpmetingOverzichtRaamItem> werkPosities,
    required DateTime offerteDatum,
    required double totaalInclusiefBtw,
    required OfferteGoedkeuring goedkeuring,
    String bestaandeConceptVersieId = '',
  }) async {
    if (!goedkeuring.isOndertekend) {
      throw StateError('De offerte heeft geen geldige handtekening.');
    }

    final alleVersies = await AppStorage.laadOfferteVersies();
    final projectSleutel = projectSleutelVoor(titelhoofd);
    final inhoudSignatuur = maakInhoudSignatuur(
      titelhoofd: titelhoofd,
      posities: posities,
    );

    OfferteVersieModel? bestaandConcept;
    final gevraagdeId = bestaandeConceptVersieId.trim();
    if (gevraagdeId.isNotEmpty) {
      for (final versie in alleVersies) {
        if (versie.id == gevraagdeId &&
            versie.projectSleutel == projectSleutel &&
            versie.inhoudSignatuur == inhoudSignatuur &&
            versie.isConcept) {
          bestaandConcept = versie;
          break;
        }
      }
    }

    bestaandConcept ??= _nieuwsteOvereenkomendeConcept(
      alleVersies,
      projectSleutel: projectSleutel,
      inhoudSignatuur: inhoudSignatuur,
    );

    if (bestaandConcept != null) {
      final opgewaardeerd = bestaandConcept.copyWith(
        status: OfferteVersieStatus.ondertekend,
        goedkeuring: goedkeuring,
        offerteDatum: offerteDatum,
        totaalInclusiefBtw: totaalInclusiefBtw,
        offerteNummer: titelhoofd.samengesteldOffertenummer,
        klantNaam: titelhoofd.klantNaam,
        inhoudSignatuur: inhoudSignatuur,
        titelhoofdJson: Map<String, dynamic>.from(titelhoofd.toJson()),
        positiesJson: posities
            .map((positie) => Map<String, dynamic>.from(positie.toJson()))
            .toList(growable: false),
        werkPositiesJson: werkPosities
            .map((positie) => Map<String, dynamic>.from(positie.toJson()))
            .toList(growable: false),
      );
      final bijgewerkt = alleVersies
          .map(
            (versie) => versie.id == opgewaardeerd.id ? opgewaardeerd : versie,
          )
          .toList(growable: false);
      await AppStorage.bewaarOfferteVersies(bijgewerkt);
      return opgewaardeerd;
    }

    final versie = _maakNieuweVersie(
      alleVersies: alleVersies,
      titelhoofd: titelhoofd,
      posities: posities,
      werkPosities: werkPosities,
      offerteDatum: offerteDatum,
      totaalInclusiefBtw: totaalInclusiefBtw,
      status: OfferteVersieStatus.ondertekend,
      naam: 'Ondertekende offerte',
      omschrijving: '',
      goedkeuring: goedkeuring,
    );

    await AppStorage.bewaarOfferteVersies(<OfferteVersieModel>[
      ...alleVersies,
      versie,
    ]);

    return versie;
  }

  Future<void> verwijderConceptVersie(OfferteVersieModel versie) async {
    if (!versie.isConcept) {
      throw StateError(
        'Een ondertekende offerteversie kan niet worden gewist.',
      );
    }

    final alleVersies = await AppStorage.laadOfferteVersies();
    final wordtAlsBronGebruikt = alleVersies.any(
      (bestaand) => bestaand.bronVersieId == versie.id,
    );
    if (wordtAlsBronGebruikt) {
      throw StateError(
        'Deze conceptversie wordt gebruikt als bron van een latere versie '
        'en kan daarom niet worden gewist.',
      );
    }

    await AppStorage.bewaarOfferteVersies(
      alleVersies.where((bestaand) => bestaand.id != versie.id).toList(),
    );
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
    required List<OfferteVersieModel> alleVersies,
    required OpmetingProjectTitelhoofd titelhoofd,
    required List<OpmetingOverzichtRaamItem> posities,
    required List<OpmetingOverzichtRaamItem> werkPosities,
    required DateTime offerteDatum,
    required double totaalInclusiefBtw,
    required OfferteVersieStatus status,
    required String naam,
    required String omschrijving,
    required OfferteGoedkeuring goedkeuring,
  }) {
    final projectSleutel = projectSleutelVoor(titelhoofd);
    final hoogsteVersie = alleVersies
        .where((versie) => versie.projectSleutel == projectSleutel)
        .fold<int>(
          0,
          (hoogste, versie) =>
              versie.versieNummer > hoogste ? versie.versieNummer : hoogste,
        );
    final opgeslagenOp = DateTime.now();
    final versieNummer = hoogsteVersie + 1;

    return OfferteVersieModel(
      id:
          '${_veiligeId(projectSleutel)}_v${versieNummer}_'
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
      bronVersieId: titelhoofd.offerteBronVersieId,
      bronVersieNummer: titelhoofd.offerteBronVersieNummer,
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

  static OfferteVersieModel? _nieuwsteOvereenkomendeConcept(
    Iterable<OfferteVersieModel> versies, {
    required String projectSleutel,
    required String inhoudSignatuur,
  }) {
    OfferteVersieModel? resultaat;
    for (final versie in versies) {
      if (versie.projectSleutel != projectSleutel ||
          versie.inhoudSignatuur != inhoudSignatuur ||
          !versie.isConcept) {
        continue;
      }
      if (resultaat == null || versie.versieNummer > resultaat.versieNummer) {
        resultaat = versie;
      }
    }
    return resultaat;
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
