// THIMACO-CONTROLE: FINANCIELE-KLUIS-NOODBACKUP-20260806
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

import 'financiele_versleuteling_service.dart';

class FinancieleNoodbackupService {
  FinancieleNoodbackupService({
    FinancieleVersleutelingService? versleutelingService,
  }) : _versleutelingService =
           versleutelingService ?? FinancieleVersleutelingService();

  static const String bestandsExtensie = 'thimacofin';
  static const String _formaat = 'THIMACO_FINANCIELE_NOODBACKUP';
  static const int _maximaleBackupGrootte = 20 * 1024 * 1024;

  final FinancieleVersleutelingService _versleutelingService;

  Future<ShareResult> deelNoodbackup({
    required Uint8List masterKey,
    required String herstelcode,
    required Map<String, dynamic> kluisEnvelop,
    required Rect sharePositionOrigin,
  }) async {
    final sleutelVerpakking = await _versleutelingService.verpakMasterKey(
      masterKey: masterKey,
      herstelcode: herstelcode,
    );

    // De aanroeper geeft bewust een werkkopie door. Wis die onmiddellijk nadat
    // de herstelverpakking is gemaakt, dus vóór het iOS-deelvenster openstaat.
    masterKey.fillRange(0, masterKey.length, 0);

    final gemaaktOp = DateTime.now().toUtc();
    final backup = <String, dynamic>{
      'formaat': _formaat,
      'versie': 1,
      'gemaaktOp': gemaaktOp.toIso8601String(),
      'sleutelVerpakking': sleutelVerpakking,
      'kluisEnvelop': kluisEnvelop,
    };
    final bytes = Uint8List.fromList(utf8.encode(jsonEncode(backup)));
    final bestandsnaam =
        'Thimaco_financiele_noodbackup_${_tijdstempel(gemaaktOp)}'
        '.$bestandsExtensie';

    return SharePlus.instance.share(
      ShareParams(
        title: 'Thimaco financiële noodback-up',
        subject: 'Versleutelde financiële noodback-up',
        text:
            'Bewaar dit versleutelde bestand op een veilige locatie. '
            'Het bestand is uitsluitend herstelbaar met de papieren herstelcode.',
        files: <XFile>[XFile.fromData(bytes, mimeType: 'application/json')],
        fileNameOverrides: <String>[bestandsnaam],
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }

  Future<FinancieleHerstelResultaat?> kiesEnHerstel({
    required String herstelcode,
  }) async {
    final resultaat = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>[bestandsExtensie],
      allowMultiple: false,
      withData: true,
    );

    if (resultaat == null || resultaat.files.isEmpty) {
      return null;
    }

    final gekozen = resultaat.files.single;
    if (gekozen.size <= 0 || gekozen.size > _maximaleBackupGrootte) {
      throw const FinancieleNoodbackupException(
        'Het gekozen noodback-upbestand is leeg of groter dan 20 MB.',
      );
    }

    Uint8List? bytes = gekozen.bytes;

    if (bytes == null && gekozen.path != null) {
      bytes = await File(gekozen.path!).readAsBytes();
    }

    if (bytes == null || bytes.isEmpty) {
      throw const FinancieleNoodbackupException(
        'Het gekozen noodback-upbestand kon niet worden gelezen.',
      );
    }
    if (bytes.length > _maximaleBackupGrootte) {
      throw const FinancieleNoodbackupException(
        'Het gekozen noodback-upbestand is groter dan 20 MB.',
      );
    }

    return herstelUitBytes(bytes: bytes, herstelcode: herstelcode);
  }

  Future<FinancieleHerstelResultaat> herstelUitBytes({
    required Uint8List bytes,
    required String herstelcode,
  }) async {
    Uint8List? tijdelijkeMasterKey;

    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map) {
        throw const FormatException('Geen JSON-object.');
      }

      final backup = Map<String, dynamic>.from(decoded);
      if (backup['formaat']?.toString() != _formaat || backup['versie'] != 1) {
        throw const FinancieleNoodbackupException(
          'Dit bestand is geen ondersteunde Thimaco financiële noodback-up.',
        );
      }

      final sleutelVerpakking = _leesMap(
        backup['sleutelVerpakking'],
        'sleutelVerpakking',
      );
      final kluisEnvelop = _leesMap(backup['kluisEnvelop'], 'kluisEnvelop');

      final masterKey = await _versleutelingService.ontpakMasterKey(
        verpakking: sleutelVerpakking,
        herstelcode: herstelcode,
      );
      tijdelijkeMasterKey = masterKey;

      // Door de kluis nu al te ontsleutelen, controleren we zowel de herstelcode
      // als de integriteit van de volledige back-up vóór iets lokaal wijzigt.
      final inhoud = await _versleutelingService.ontsleutelJson(
        envelop: kluisEnvelop,
        sleutel: masterKey,
      );

      final resultaat = FinancieleHerstelResultaat(
        masterKey: masterKey,
        kluisEnvelop: kluisEnvelop,
        inhoud: inhoud,
      );
      tijdelijkeMasterKey = null;
      return resultaat;
    } on FinancieleNoodbackupException {
      rethrow;
    } on FinancieleKluisCryptoException catch (fout) {
      throw FinancieleNoodbackupException(
        'De noodback-up kon niet worden ontsleuteld. '
        'Controleer de papieren herstelcode.\n\n${fout.bericht}',
      );
    } catch (_) {
      throw const FinancieleNoodbackupException(
        'Het noodback-upbestand is beschadigd of heeft een ongeldig formaat.',
      );
    } finally {
      final sleutel = tijdelijkeMasterKey;
      if (sleutel != null) {
        sleutel.fillRange(0, sleutel.length, 0);
      }
    }
  }

  Map<String, dynamic> _leesMap(Object? waarde, String veld) {
    if (waarde is! Map) {
      throw FinancieleNoodbackupException(
        'Het veld “$veld” ontbreekt in de noodback-up.',
      );
    }

    return Map<String, dynamic>.from(waarde);
  }

  String _tijdstempel(DateTime datum) {
    String twee(int waarde) => waarde.toString().padLeft(2, '0');

    return '${datum.year}${twee(datum.month)}${twee(datum.day)}'
        '_${twee(datum.hour)}${twee(datum.minute)}${twee(datum.second)}';
  }
}

class FinancieleHerstelResultaat {
  const FinancieleHerstelResultaat({
    required this.masterKey,
    required this.kluisEnvelop,
    required this.inhoud,
  });

  final Uint8List masterKey;
  final Map<String, dynamic> kluisEnvelop;
  final Map<String, dynamic> inhoud;
}

class FinancieleNoodbackupException implements Exception {
  const FinancieleNoodbackupException(this.bericht);

  final String bericht;

  @override
  String toString() => bericht;
}
