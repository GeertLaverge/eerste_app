// THIMACO-CONTROLE: LEGACY-PRIJS-PROFIEL-MERGE-TESTS-VERWIJDERD-20260815
import 'package:eerste_app/helpers/Agenda/agenda_item.dart';
import 'package:eerste_app/helpers/opmeting/project/opmeting_project_titelhoofd_model.dart';
import 'package:eerste_app/helpers/sync/sync_merge_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SyncMergeService agenda', () {
    test('verplaatst item blijft uitsluitend op de nieuwste datum staan', () {
      final cloudItem = _agendaItem(
        id: 'afspraak-1',
        updatedAt: '2026-07-25T10:00:00.000Z',
      );
      final lokaalItem = _agendaItem(
        id: 'afspraak-1',
        updatedAt: '2026-07-25T11:00:00.000Z',
      );

      final resultaat = SyncMergeService.mergeAgendaMap(
        <String, List<AgendaItem>>{
          '2026-07-26': <AgendaItem>[lokaalItem],
        },
        <String, List<AgendaItem>>{
          '2026-07-25': <AgendaItem>[cloudItem],
        },
      );

      expect(resultaat['2026-07-25'], isNull);
      expect(resultaat['2026-07-26'], hasLength(1));
      expect(resultaat['2026-07-26']!.single.id, 'afspraak-1');
    });

    test('nieuwere tombstone onderdrukt oudere zichtbare cloudversie', () {
      final cloudItem = _agendaItem(
        id: 'afspraak-2',
        updatedAt: '2026-07-25T10:00:00.000Z',
      );
      final verwijderdItem = _agendaItem(
        id: 'afspraak-2',
        updatedAt: '2026-07-25T12:00:00.000Z',
        deletedAt: '2026-07-25T12:00:00.000Z',
      );

      final resultaat = SyncMergeService.mergeAgendaMap(
        <String, List<AgendaItem>>{
          '2026-07-25': <AgendaItem>[verwijderdItem],
        },
        <String, List<AgendaItem>>{
          '2026-07-25': <AgendaItem>[cloudItem],
        },
      );

      expect(resultaat['2026-07-25'], hasLength(1));
      expect(resultaat['2026-07-25']!.single.isVerwijderd, isTrue);
    });

    test('verborgen tombstone blijft behouden bij een volgende UI-opslag', () {
      final tombstone = _agendaItem(
        id: 'afspraak-3',
        updatedAt: '2026-07-25T12:00:00.000Z',
        deletedAt: '2026-07-25T12:00:00.000Z',
      );
      final zichtbaarItem = _agendaItem(
        id: 'afspraak-4',
        updatedAt: '2026-07-25T13:00:00.000Z',
      );

      final resultaat = SyncMergeService.behoudAgendaTombstones(
        actueleItems: <String, List<AgendaItem>>{
          '2026-07-26': <AgendaItem>[zichtbaarItem],
        },
        opgeslagenItems: <String, List<AgendaItem>>{
          '2026-07-25': <AgendaItem>[tombstone],
        },
      );

      expect(resultaat['2026-07-25'], hasLength(1));
      expect(resultaat['2026-07-25']!.single.id, 'afspraak-3');
      expect(resultaat['2026-07-25']!.single.isVerwijderd, isTrue);
    });

    test(
      'oude tombstone wordt niet behouden als hetzelfde item verhuisd is',
      () {
        final tombstone = _agendaItem(
          id: 'afspraak-5',
          updatedAt: '2026-07-25T12:00:00.000Z',
          deletedAt: '2026-07-25T12:00:00.000Z',
        );
        final verplaatstItem = _agendaItem(
          id: 'afspraak-5',
          updatedAt: '2026-07-25T13:00:00.000Z',
        );

        final resultaat = SyncMergeService.behoudAgendaTombstones(
          actueleItems: <String, List<AgendaItem>>{
            '2026-07-26': <AgendaItem>[verplaatstItem],
          },
          opgeslagenItems: <String, List<AgendaItem>>{
            '2026-07-25': <AgendaItem>[tombstone],
          },
        );

        expect(resultaat['2026-07-25'], isNull);
        expect(resultaat['2026-07-26'], hasLength(1));
        expect(resultaat['2026-07-26']!.single.isVerwijderd, isFalse);
      },
    );
  });

  group('SyncMergeService projecttitelhoofden', () {
    test(
      'behoudt verschillende projecten en kiest per project de nieuwste',
      () {
        final resultaat = SyncMergeService.mergeProjectTitelhoofden(
          <String, OpmetingProjectTitelhoofd>{
            'project-a': _titelhoofd(
              klantNaam: 'Project A lokaal',
              gewijzigdOp: '2026-07-26T10:00:00.000Z',
            ),
          },
          <String, OpmetingProjectTitelhoofd>{
            'project-a': _titelhoofd(
              klantNaam: 'Project A cloud oud',
              gewijzigdOp: '2026-07-26T09:00:00.000Z',
            ),
            'project-b': _titelhoofd(
              klantNaam: 'Project B cloud',
              gewijzigdOp: '2026-07-26T09:30:00.000Z',
            ),
          },
        );

        expect(resultaat, hasLength(2));
        expect(resultaat['project-a']!.klantNaam, 'Project A lokaal');
        expect(resultaat['project-b']!.klantNaam, 'Project B cloud');
      },
    );
  });

  group('SyncMergeService deurpaneelrecords', () {
    const sleutel = 'thimaco_deurpaneel_toewijzingen_opmeting-1';

    test('nieuwere lege lijst blijft als verwijdermarkering bewaard', () {
      final resultaat = SyncMergeService.mergeStringRecordsOpDatum(
        lokaal: const <String, String>{sleutel: '[]'},
        cloud: const <String, String>{sleutel: '[{"id":"oud"}]'},
        lokaleGewijzigdOp: const <String, String>{
          sleutel: '2026-07-26T11:00:00.000Z',
        },
        cloudGewijzigdOp: const <String, String>{
          sleutel: '2026-07-26T10:00:00.000Z',
        },
      );

      expect(resultaat.waarden[sleutel], '[]');
      expect(resultaat.gewijzigdOp[sleutel], '2026-07-26T11:00:00.000Z');
    });

    test('nieuwere cloudtoewijzing wint van oudere lokale versie', () {
      final resultaat = SyncMergeService.mergeStringRecordsOpDatum(
        lokaal: const <String, String>{sleutel: '[{"id":"lokaal"}]'},
        cloud: const <String, String>{sleutel: '[{"id":"cloud"}]'},
        lokaleGewijzigdOp: const <String, String>{
          sleutel: '2026-07-26T10:00:00.000Z',
        },
        cloudGewijzigdOp: const <String, String>{
          sleutel: '2026-07-26T11:00:00.000Z',
        },
      );

      expect(resultaat.waarden[sleutel], '[{"id":"cloud"}]');
    });
  });
  group('SyncMergeService JSON-recordcollecties', () {
    test(
      'onafhankelijke wijzigingen in verschillende records blijven bestaan',
      () {
        final resultaat = SyncMergeService.mergeJsonRecords(
          lokaal: const <Map<String, dynamic>>[
            <String, dynamic>{'id': 'menu-a', 'naam': 'Lokaal gewijzigd'},
          ],
          cloud: const <Map<String, dynamic>>[
            <String, dynamic>{'id': 'menu-b', 'naam': 'Cloud gewijzigd'},
          ],
          lokaleMetadata: const <String, SyncJsonRecordMetadata>{
            'menu-a': SyncJsonRecordMetadata(
              gewijzigdOp: '2026-07-26T12:00:00.000Z',
              verwijderd: false,
            ),
          },
          cloudMetadata: const <String, SyncJsonRecordMetadata>{
            'menu-b': SyncJsonRecordMetadata(
              gewijzigdOp: '2026-07-26T12:30:00.000Z',
              verwijderd: false,
            ),
          },
          idVoorRecord: _recordId,
        );

        expect(resultaat.records, hasLength(2));
        expect(
          resultaat.records.map((record) => record['id']),
          containsAll(<String>['menu-a', 'menu-b']),
        );
      },
    );

    test('nieuwere tombstone houdt een verwijderd record weg', () {
      final resultaat = SyncMergeService.mergeJsonRecords(
        lokaal: const <Map<String, dynamic>>[],
        cloud: const <Map<String, dynamic>>[
          <String, dynamic>{'id': 'kleur-1', 'naam': 'Oude cloudkleur'},
        ],
        lokaleMetadata: const <String, SyncJsonRecordMetadata>{
          'kleur-1': SyncJsonRecordMetadata(
            gewijzigdOp: '2026-07-26T13:00:00.000Z',
            verwijderd: true,
          ),
        },
        cloudMetadata: const <String, SyncJsonRecordMetadata>{
          'kleur-1': SyncJsonRecordMetadata(
            gewijzigdOp: '2026-07-26T12:00:00.000Z',
            verwijderd: false,
          ),
        },
        idVoorRecord: _recordId,
      );

      expect(resultaat.records, isEmpty);
      expect(resultaat.metadata['kleur-1']!.verwijderd, isTrue);
    });

    test('lokale opslag markeert wijzigingen en verwijderingen per record', () {
      final metadata = SyncMergeService.updateJsonRecordMetadata(
        oudeRecords: const <Map<String, dynamic>>[
          <String, dynamic>{'id': 'a', 'naam': 'Ongewijzigd'},
          <String, dynamic>{'id': 'b', 'naam': 'Wordt verwijderd'},
          <String, dynamic>{'id': 'c', 'naam': 'Oud'},
        ],
        nieuweRecords: const <Map<String, dynamic>>[
          <String, dynamic>{'id': 'a', 'naam': 'Ongewijzigd'},
          <String, dynamic>{'id': 'c', 'naam': 'Nieuw'},
        ],
        bestaandeMetadata: const <String, SyncJsonRecordMetadata>{
          'a': SyncJsonRecordMetadata(
            gewijzigdOp: '2026-07-25T10:00:00.000Z',
            verwijderd: false,
          ),
        },
        idVoorRecord: _recordId,
        gewijzigdOp: '2026-07-26T14:00:00.000Z',
      );

      expect(metadata['a']!.gewijzigdOp, '2026-07-25T10:00:00.000Z');
      expect(metadata['b']!.verwijderd, isTrue);
      expect(metadata['c']!.gewijzigdOp, '2026-07-26T14:00:00.000Z');
      expect(metadata['c']!.verwijderd, isFalse);
    });

    test('leveranciersleutel gebruikt e-mail hoofdletterongevoelig', () {
      final eerste = SyncMergeService.syncIdVoorLeverancierRecord(
        const <String, dynamic>{
          'naam': 'Leverancier A',
          'email': 'Info@Voorbeeld.be',
        },
      );
      final tweede = SyncMergeService.syncIdVoorLeverancierRecord(
        const <String, dynamic>{
          'naam': 'Andere schrijfwijze',
          'email': 'info@voorbeeld.be',
        },
      );

      expect(eerste, tweede);
      expect(eerste, 'email:info@voorbeeld.be');
    });
  });
}

AgendaItem _agendaItem({
  required String id,
  required String updatedAt,
  String deletedAt = '',
}) {
  return AgendaItem(
    id: id,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    titel: 'Testafspraak',
    type: 'afspraak',
  );
}

OpmetingProjectTitelhoofd _titelhoofd({
  required String klantNaam,
  required String gewijzigdOp,
}) {
  return OpmetingProjectTitelhoofd(
    klantNaam: klantNaam,
    gewijzigdOp: gewijzigdOp,
  );
}

String _recordId(Map<String, dynamic> record) {
  return record['id']?.toString() ?? '';
}
