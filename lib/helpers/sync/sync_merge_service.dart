// THIMACO-CONTROLE: PRIJSARCHITECTUUR-LEGACY-PRIJSPROFIEL-MERGE-VERWIJDERD-20260815
import 'dart:convert';

import '../Agenda/agenda_item.dart';
import '../klanten/fiche/klantenfiche_model.dart';
import '../opmeting/overzicht/opmeting_overzicht_model.dart';
import '../opmeting/project/opmeting_project_titelhoofd_model.dart';

class SyncMergeService {
  static List<AgendaItem> mergeAgendaItems(
    List<AgendaItem> lokaal,
    List<AgendaItem> cloud,
  ) {
    final samengevoegd = mergeAgendaMap(
      <String, List<AgendaItem>>{'_': lokaal},
      <String, List<AgendaItem>>{'_': cloud},
    );

    return samengevoegd['_'] ?? <AgendaItem>[];
  }

  /// Voegt agenda-items samen over alle datums heen.
  ///
  /// Een agenda-item kan bij een verplaatsing onder een andere datumkey staan.
  /// Daarom mag niet per datum afzonderlijk worden gemerged. Per sync-ID blijft
  /// uitsluitend de nieuwste versie over, inclusief een eventuele tombstone.
  static Map<String, List<AgendaItem>> mergeAgendaMap(
    Map<String, List<AgendaItem>> lokaal,
    Map<String, List<AgendaItem>> cloud,
  ) {
    final nieuwstePerId = <String, _AgendaItemMetDatum>{};

    void verwerk(
      Map<String, List<AgendaItem>> bron, {
      required bool lokaleBron,
    }) {
      for (final entry in bron.entries) {
        for (final item in entry.value) {
          final syncId = item.syncId.trim();
          if (syncId.isEmpty) {
            continue;
          }

          final kandidaat = _AgendaItemMetDatum(
            datumKey: entry.key,
            item: item,
            lokaleBron: lokaleBron,
          );
          final bestaand = nieuwstePerId[syncId];

          if (bestaand == null || _kandidaatIsNieuwer(kandidaat, bestaand)) {
            nieuwstePerId[syncId] = kandidaat;
          }
        }
      }
    }

    // Bij een gelijke of ontbrekende wijzigingsdatum krijgt de lokale versie
    // voorrang. Daarom wordt cloud eerst en lokaal als tweede verwerkt.
    verwerk(cloud, lokaleBron: false);
    verwerk(lokaal, lokaleBron: true);

    final resultaat = <String, List<AgendaItem>>{};

    for (final record in nieuwstePerId.values) {
      resultaat
          .putIfAbsent(record.datumKey, () => <AgendaItem>[])
          .add(record.item);
    }

    return resultaat;
  }

  /// Behoudt verwijdermarkeringen wanneer de UI alleen zichtbare agenda-items
  /// terugstuurt naar de opslag.
  ///
  /// Zodra hetzelfde sync-ID opnieuw zichtbaar aanwezig is, wordt de oude
  /// tombstone niet behouden. Dat is nodig bij het verplaatsen of bewust
  /// herstellen van een agenda-item.
  static Map<String, List<AgendaItem>> behoudAgendaTombstones({
    required Map<String, List<AgendaItem>> actueleItems,
    required Map<String, List<AgendaItem>> opgeslagenItems,
  }) {
    final resultaat = <String, List<AgendaItem>>{
      for (final entry in actueleItems.entries)
        entry.key: List<AgendaItem>.from(entry.value),
    };

    final aanwezigeIds = <String>{
      for (final items in actueleItems.values)
        for (final item in items)
          if (item.syncId.trim().isNotEmpty) item.syncId.trim(),
    };

    for (final entry in opgeslagenItems.entries) {
      for (final item in entry.value) {
        final syncId = item.syncId.trim();
        if (!item.isVerwijderd ||
            syncId.isEmpty ||
            aanwezigeIds.contains(syncId)) {
          continue;
        }

        resultaat.putIfAbsent(entry.key, () => <AgendaItem>[]).add(item);
        aanwezigeIds.add(syncId);
      }
    }

    return resultaat;
  }

  static bool _kandidaatIsNieuwer(
    _AgendaItemMetDatum kandidaat,
    _AgendaItemMetDatum bestaand,
  ) {
    final kandidaatDatum = _agendaWijzigingsDatum(kandidaat.item);
    final bestaandDatum = _agendaWijzigingsDatum(bestaand.item);

    if (kandidaatDatum != null && bestaandDatum != null) {
      if (kandidaatDatum.isAfter(bestaandDatum)) {
        return true;
      }
      if (kandidaatDatum.isBefore(bestaandDatum)) {
        return false;
      }
    } else if (kandidaatDatum != null) {
      return true;
    } else if (bestaandDatum != null) {
      // Een oude tombstone zonder geldige datum moet een zichtbare versie met
      // datum toch kunnen onderdrukken. Zo komen legacy-verwijderingen niet
      // opnieuw terug na een sync.
      return kandidaat.item.isVerwijderd && !bestaand.item.isVerwijderd;
    }

    if (kandidaat.item.isVerwijderd != bestaand.item.isVerwijderd) {
      return kandidaat.item.isVerwijderd;
    }

    if (kandidaat.lokaleBron != bestaand.lokaleBron) {
      return kandidaat.lokaleBron;
    }

    // Binnen dezelfde bron krijgt de laatst aangetroffen versie voorrang.
    // Dit ruimt ook oude dubbele agenda-items met hetzelfde ID op.
    return true;
  }

  static DateTime? _agendaWijzigingsDatum(AgendaItem item) {
    return DateTime.tryParse(item.updatedAt.trim()) ??
        DateTime.tryParse(item.deletedAt.trim());
  }

  static List<KlantenficheModel> mergeKlantenFiches(
    List<KlantenficheModel> lokaal,
    List<KlantenficheModel> cloud,
  ) {
    final resultaat = <String, KlantenficheModel>{};

    for (final fiche in [...lokaal, ...cloud]) {
      final key = fiche.id;

      if (!resultaat.containsKey(key)) {
        resultaat[key] = fiche;
        continue;
      }

      final bestaand = resultaat[key]!;

      final bestaandDatum = DateTime.tryParse(bestaand.updatedAt);

      final nieuwDatum = DateTime.tryParse(fiche.updatedAt);

      if (bestaandDatum == null && nieuwDatum != null) {
        resultaat[key] = fiche;
        continue;
      }

      if (bestaandDatum != null &&
          nieuwDatum != null &&
          nieuwDatum.isAfter(bestaandDatum)) {
        resultaat[key] = fiche;
      }
    }

    return resultaat.values.toList();
  }

  /// Voegt projecttitelhoofden per opgeslagen projectsleutel samen.
  /// De nieuwste wijziging blijft behouden; bij gelijke of ontbrekende datums
  /// wint de lokale versie.
  static Map<String, OpmetingProjectTitelhoofd> mergeProjectTitelhoofden(
    Map<String, OpmetingProjectTitelhoofd> lokaal,
    Map<String, OpmetingProjectTitelhoofd> cloud,
  ) {
    final resultaat = <String, _TitelhoofdMetBron>{};

    void verwerk(
      Map<String, OpmetingProjectTitelhoofd> bron, {
      required bool lokaleBron,
    }) {
      for (final entry in bron.entries) {
        final sleutel = entry.key.trim();
        if (sleutel.isEmpty) {
          continue;
        }

        final kandidaat = _TitelhoofdMetBron(
          titelhoofd: entry.value,
          lokaleBron: lokaleBron,
        );
        final bestaand = resultaat[sleutel];

        if (bestaand == null ||
            _recordIsNieuwer(
              kandidaatGewijzigdOp: entry.value.gewijzigdOp,
              bestaandGewijzigdOp: bestaand.titelhoofd.gewijzigdOp,
              kandidaatIsLokaal: lokaleBron,
              bestaandIsLokaal: bestaand.lokaleBron,
            )) {
          resultaat[sleutel] = kandidaat;
        }
      }
    }

    verwerk(cloud, lokaleBron: false);
    verwerk(lokaal, lokaleBron: true);

    return <String, OpmetingProjectTitelhoofd>{
      for (final entry in resultaat.entries) entry.key: entry.value.titelhoofd,
    };
  }

  /// Merge voor afzonderlijke JSON-records met een wijzigingsdatum per sleutel.
  /// Een waarde zoals `[]` blijft bewust bewaard en kan zo als tombstone dienen.
  static SyncStringRecordMergeResult mergeStringRecordsOpDatum({
    required Map<String, String> lokaal,
    required Map<String, String> cloud,
    required Map<String, String> lokaleGewijzigdOp,
    required Map<String, String> cloudGewijzigdOp,
    String lokaleFallbackDatum = '',
    String cloudFallbackDatum = '',
  }) {
    final waarden = <String, String>{};
    final datums = <String, String>{};
    final sleutels = <String>{...cloud.keys, ...lokaal.keys};

    for (final sleutel in sleutels) {
      final lokaalAanwezig = lokaal.containsKey(sleutel);
      final cloudAanwezig = cloud.containsKey(sleutel);

      if (!lokaalAanwezig && !cloudAanwezig) {
        continue;
      }

      var kiesLokaal = lokaalAanwezig && !cloudAanwezig;

      if (lokaalAanwezig && cloudAanwezig) {
        kiesLokaal = _recordIsNieuwer(
          kandidaatGewijzigdOp: lokaleGewijzigdOp[sleutel] ?? '',
          bestaandGewijzigdOp: cloudGewijzigdOp[sleutel] ?? '',
          kandidaatIsLokaal: true,
          bestaandIsLokaal: false,
        );
      }

      final gekozenWaarde = kiesLokaal ? lokaal[sleutel] : cloud[sleutel];
      if (gekozenWaarde == null) {
        continue;
      }

      waarden[sleutel] = gekozenWaarde;

      final gekozenDatum = kiesLokaal
          ? lokaleGewijzigdOp[sleutel] ?? lokaleFallbackDatum
          : cloudGewijzigdOp[sleutel] ?? cloudFallbackDatum;
      if (gekozenDatum.trim().isNotEmpty) {
        datums[sleutel] = gekozenDatum.trim();
      }
    }

    return SyncStringRecordMergeResult(waarden: waarden, gewijzigdOp: datums);
  }

  static bool _recordIsNieuwer({
    required String kandidaatGewijzigdOp,
    required String bestaandGewijzigdOp,
    required bool kandidaatIsLokaal,
    required bool bestaandIsLokaal,
  }) {
    final kandidaatDatum = DateTime.tryParse(kandidaatGewijzigdOp.trim());
    final bestaandDatum = DateTime.tryParse(bestaandGewijzigdOp.trim());

    if (kandidaatDatum != null && bestaandDatum != null) {
      if (kandidaatDatum.isAfter(bestaandDatum)) {
        return true;
      }
      if (kandidaatDatum.isBefore(bestaandDatum)) {
        return false;
      }
    } else if (kandidaatDatum != null) {
      return true;
    } else if (bestaandDatum != null) {
      return false;
    }

    if (kandidaatIsLokaal != bestaandIsLokaal) {
      return kandidaatIsLokaal;
    }

    return true;
  }

  /// Leest de afzonderlijke wijzigings- en verwijdergegevens van een
  /// JSON-lijstcollectie. Oude back-ups zonder metadata blijven geldig.
  static Map<String, SyncJsonRecordMetadata> decodeJsonRecordMetadata(
    String? jsonString,
  ) {
    if (jsonString == null || jsonString.trim().isEmpty) {
      return <String, SyncJsonRecordMetadata>{};
    }

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map) {
        return <String, SyncJsonRecordMetadata>{};
      }

      final resultaat = <String, SyncJsonRecordMetadata>{};

      decoded.forEach((sleutel, waarde) {
        final id = sleutel.toString().trim();
        if (id.isEmpty || waarde is! Map) {
          return;
        }

        resultaat[id] = SyncJsonRecordMetadata.fromJson(
          Map<String, dynamic>.from(waarde),
        );
      });

      return resultaat;
    } catch (_) {
      return <String, SyncJsonRecordMetadata>{};
    }
  }

  static String encodeJsonRecordMetadata(
    Map<String, SyncJsonRecordMetadata> metadata,
  ) {
    return jsonEncode(
      metadata.map((sleutel, waarde) => MapEntry(sleutel, waarde.toJson())),
    );
  }

  /// Berekent metadata na een gewone lokale opslag.
  ///
  /// Nieuwe en inhoudelijk gewijzigde records krijgen [gewijzigdOp]. Records
  /// die uit de lijst verdwenen zijn, blijven als tombstone in de metadata
  /// staan. Ongewijzigde records behouden hun bestaande datum.
  static Map<String, SyncJsonRecordMetadata> updateJsonRecordMetadata({
    required List<Map<String, dynamic>> oudeRecords,
    required List<Map<String, dynamic>> nieuweRecords,
    required Map<String, SyncJsonRecordMetadata> bestaandeMetadata,
    required String Function(Map<String, dynamic> record) idVoorRecord,
    required String gewijzigdOp,
  }) {
    final oudePerId = _jsonRecordsPerId(oudeRecords, idVoorRecord);
    final nieuwePerId = _jsonRecordsPerId(nieuweRecords, idVoorRecord);
    final resultaat = <String, SyncJsonRecordMetadata>{...bestaandeMetadata};

    for (final entry in nieuwePerId.entries) {
      final oud = oudePerId[entry.key];
      final bestaand = bestaandeMetadata[entry.key];
      final inhoudGewijzigd =
          oud == null || _canoniekeJson(oud) != _canoniekeJson(entry.value);

      if (inhoudGewijzigd || bestaand == null || bestaand.verwijderd) {
        resultaat[entry.key] = SyncJsonRecordMetadata(
          gewijzigdOp: gewijzigdOp,
          verwijderd: false,
        );
      }
    }

    for (final id in oudePerId.keys) {
      if (nieuwePerId.containsKey(id)) {
        continue;
      }

      resultaat[id] = SyncJsonRecordMetadata(
        gewijzigdOp: gewijzigdOp,
        verwijderd: true,
      );
    }

    return resultaat;
  }

  /// Voegt JSON-lijstcollecties per record samen.
  ///
  /// Hiermee blijven onafhankelijke wijzigingen in bijvoorbeeld twee
  /// technische keuzemenu's of twee notities naast elkaar bestaan. Een
  /// tombstone met een nieuwere datum voorkomt dat verwijderde records uit een
  /// oudere cloudback-up terugkeren.
  static SyncJsonRecordMergeResult mergeJsonRecords({
    required List<Map<String, dynamic>> lokaal,
    required List<Map<String, dynamic>> cloud,
    required Map<String, SyncJsonRecordMetadata> lokaleMetadata,
    required Map<String, SyncJsonRecordMetadata> cloudMetadata,
    required String Function(Map<String, dynamic> record) idVoorRecord,
    String lokaleFallbackDatum = '',
    String cloudFallbackDatum = '',
  }) {
    final lokaalPerId = _jsonRecordsPerId(lokaal, idVoorRecord);
    final cloudPerId = _jsonRecordsPerId(cloud, idVoorRecord);
    final idsInVolgorde = <String>[];
    final reedsToegevoegd = <String>{};

    void voegVolgordeToe(Iterable<Map<String, dynamic>> records) {
      for (final record in records) {
        final id = idVoorRecord(record).trim();
        if (id.isNotEmpty && reedsToegevoegd.add(id)) {
          idsInVolgorde.add(id);
        }
      }
    }

    voegVolgordeToe(lokaal);
    voegVolgordeToe(cloud);

    for (final id in <String>{...lokaleMetadata.keys, ...cloudMetadata.keys}) {
      if (reedsToegevoegd.add(id)) {
        idsInVolgorde.add(id);
      }
    }

    final records = <Map<String, dynamic>>[];
    final metadata = <String, SyncJsonRecordMetadata>{};

    for (final id in idsInVolgorde) {
      final lokaalRecord = lokaalPerId[id];
      final cloudRecord = cloudPerId[id];
      final lokaalMeta =
          lokaleMetadata[id] ??
          (lokaalRecord == null
              ? null
              : SyncJsonRecordMetadata(
                  gewijzigdOp: lokaleFallbackDatum,
                  verwijderd: false,
                ));
      final cloudMeta =
          cloudMetadata[id] ??
          (cloudRecord == null
              ? null
              : SyncJsonRecordMetadata(
                  gewijzigdOp: cloudFallbackDatum,
                  verwijderd: false,
                ));

      if (lokaalMeta == null && cloudMeta == null) {
        continue;
      }

      var kiesLokaal = lokaalMeta != null && cloudMeta == null;

      if (lokaalMeta != null && cloudMeta != null) {
        kiesLokaal = _recordIsNieuwer(
          kandidaatGewijzigdOp: lokaalMeta.gewijzigdOp,
          bestaandGewijzigdOp: cloudMeta.gewijzigdOp,
          kandidaatIsLokaal: true,
          bestaandIsLokaal: false,
        );
      }

      final gekozenMeta = kiesLokaal ? lokaalMeta! : cloudMeta!;
      final gekozenRecord = kiesLokaal ? lokaalRecord : cloudRecord;
      metadata[id] = gekozenMeta;

      if (!gekozenMeta.verwijderd && gekozenRecord != null) {
        records.add(Map<String, dynamic>.from(gekozenRecord));
      }
    }

    return SyncJsonRecordMergeResult(records: records, metadata: metadata);
  }

  /// Stabiele sleutel voor leveranciers die historisch nog geen eigen ID
  /// hebben. E-mail krijgt voorrang, daarna naam en adres/telefoon.
  static String syncIdVoorLeverancierRecord(Map<String, dynamic> record) {
    final bestaandId = record['id']?.toString().trim() ?? '';
    if (bestaandId.isNotEmpty) {
      return bestaandId;
    }

    String normaal(Object? waarde) {
      return waarde?.toString().trim().toLowerCase().replaceAll(
            RegExp(r'\s+'),
            ' ',
          ) ??
          '';
    }

    final email = normaal(record['email']);
    if (email.isNotEmpty) {
      return 'email:$email';
    }

    final naam = normaal(record['naam']);
    final postcode = normaal(record['postcode']);
    final telefoon = normaal(record['telefoon']);
    final gsm = normaal(record['gsm']);

    if (naam.isEmpty && postcode.isEmpty && telefoon.isEmpty && gsm.isEmpty) {
      return '';
    }

    return 'leverancier:$naam|$postcode|$telefoon|$gsm';
  }

  static Map<String, Map<String, dynamic>> _jsonRecordsPerId(
    Iterable<Map<String, dynamic>> records,
    String Function(Map<String, dynamic> record) idVoorRecord,
  ) {
    final resultaat = <String, Map<String, dynamic>>{};

    for (final record in records) {
      final id = idVoorRecord(record).trim();
      if (id.isEmpty) {
        continue;
      }
      resultaat[id] = Map<String, dynamic>.from(record);
    }

    return resultaat;
  }

  static String _canoniekeJson(Object? waarde) {
    Object? normaliseer(Object? item) {
      if (item is Map) {
        final sleutels = item.keys.map((sleutel) => sleutel.toString()).toList()
          ..sort();
        return <String, dynamic>{
          for (final sleutel in sleutels) sleutel: normaliseer(item[sleutel]),
        };
      }

      if (item is List) {
        return item.map(normaliseer).toList();
      }

      return item;
    }

    return jsonEncode(normaliseer(waarde));
  }

  static List<OpmetingOverzichtRaamItem> mergeOpmetingen(
    List<OpmetingOverzichtRaamItem> lokaal,
    List<OpmetingOverzichtRaamItem> cloud,
  ) {
    final resultaat = <String, OpmetingOverzichtRaamItem>{};

    for (final opmeting in [...lokaal, ...cloud]) {
      final key = opmeting.id.trim();

      if (key.isEmpty) {
        continue;
      }

      if (!resultaat.containsKey(key)) {
        resultaat[key] = opmeting;
        continue;
      }

      final bestaand = resultaat[key]!;

      final bestaandDatum = DateTime.tryParse(bestaand.gewijzigdOp);
      final nieuwDatum = DateTime.tryParse(opmeting.gewijzigdOp);

      if (bestaandDatum == null && nieuwDatum != null) {
        resultaat[key] = opmeting;
        continue;
      }

      if (bestaandDatum != null &&
          nieuwDatum != null &&
          nieuwDatum.isAfter(bestaandDatum)) {
        resultaat[key] = opmeting;
      }
    }

    // Niet sorteren op wijzigingsdatum.
    // De volgorde van lokaal/cloud wordt behouden, zodat Pos 1, Pos 2, ...
    // niet verspringt na synchronisatie of na het bewerken van een positie.
    return resultaat.values.toList();
  }
}

class SyncStringRecordMergeResult {
  SyncStringRecordMergeResult({
    required Map<String, String> waarden,
    required Map<String, String> gewijzigdOp,
  }) : waarden = Map<String, String>.unmodifiable(waarden),
       gewijzigdOp = Map<String, String>.unmodifiable(gewijzigdOp);

  final Map<String, String> waarden;
  final Map<String, String> gewijzigdOp;
}

class SyncJsonRecordMetadata {
  const SyncJsonRecordMetadata({
    required this.gewijzigdOp,
    required this.verwijderd,
  });

  final String gewijzigdOp;
  final bool verwijderd;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'gewijzigdOp': gewijzigdOp,
      'verwijderd': verwijderd,
    };
  }

  factory SyncJsonRecordMetadata.fromJson(Map<String, dynamic> json) {
    return SyncJsonRecordMetadata(
      gewijzigdOp: json['gewijzigdOp']?.toString() ?? '',
      verwijderd: json['verwijderd'] == true,
    );
  }
}

class SyncJsonRecordMergeResult {
  SyncJsonRecordMergeResult({
    required List<Map<String, dynamic>> records,
    required Map<String, SyncJsonRecordMetadata> metadata,
  }) : records = List<Map<String, dynamic>>.unmodifiable(records),
       metadata = Map<String, SyncJsonRecordMetadata>.unmodifiable(metadata);

  final List<Map<String, dynamic>> records;
  final Map<String, SyncJsonRecordMetadata> metadata;
}

class _TitelhoofdMetBron {
  const _TitelhoofdMetBron({
    required this.titelhoofd,
    required this.lokaleBron,
  });

  final OpmetingProjectTitelhoofd titelhoofd;
  final bool lokaleBron;
}

class _AgendaItemMetDatum {
  const _AgendaItemMetDatum({
    required this.datumKey,
    required this.item,
    required this.lokaleBron,
  });

  final String datumKey;
  final AgendaItem item;
  final bool lokaleBron;
}
