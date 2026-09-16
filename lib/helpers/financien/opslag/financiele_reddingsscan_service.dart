// THIMACO-CONTROLE: FINANCIELE-REDDINGSSCAN-20260916
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class FinancieleReddingsscanService {
  static const String _formaatMarker = 'THIMACO_FINANCIELE_NOODBACKUP';
  static const int _maximaleBestandsgrootte = 20 * 1024 * 1024;
  static const int _scanKopGrootte = 256 * 1024;
  static const String _reddingsMapNaam = 'ThimacoHerstel';

  Future<List<FinancieleReddingsKandidaat>> zoekEnStelVeilig() async {
    final wortels = await _bepaalScanWortels();
    if (wortels.isEmpty) {
      throw const FinancieleReddingsscanException(
        'De lokale appmappen konden niet worden geopend voor de reddingsscan.',
      );
    }

    final gevondenPaden = <String>{};
    final kandidaten = <_RuweReddingsKandidaat>[];

    for (final wortel in wortels) {
      await _scanMap(
        wortel,
        gevondenPaden: gevondenPaden,
        kandidaten: kandidaten,
      );
    }

    if (kandidaten.isEmpty) {
      return const <FinancieleReddingsKandidaat>[];
    }

    kandidaten.sort((a, b) => b.gewijzigdOp.compareTo(a.gewijzigdOp));

    final documenten = await getApplicationDocumentsDirectory();
    final reddingsMap = Directory(
      '${documenten.path}${Platform.pathSeparator}$_reddingsMapNaam',
    );
    await reddingsMap.create(recursive: true);

    final resultaat = <FinancieleReddingsKandidaat>[];

    for (var index = 0; index < kandidaten.length; index++) {
      final kandidaat = kandidaten[index];
      final tijdstempel = _tijdstempel(kandidaat.gewijzigdOp.toUtc());
      final doelNaam =
          'Thimaco_geredde_noodbackup_${tijdstempel}_${index + 1}.thimacofin';
      final doel = File(
        '${reddingsMap.path}${Platform.pathSeparator}$doelNaam',
      );

      try {
        final bytes = await kandidaat.bestand.readAsBytes();
        if (bytes.isEmpty || bytes.length > _maximaleBestandsgrootte) {
          continue;
        }

        await doel.writeAsBytes(bytes, flush: true);

        // Controleer dat de veilige kopie werkelijk geschreven en herkenbaar is.
        if (!await doel.exists() ||
            await doel.length() != bytes.length ||
            !await _bevatNoodbackupMarker(doel)) {
          try {
            if (await doel.exists()) {
              await doel.delete();
            }
          } catch (_) {
            // Best effort. Onderstaande fout stopt de reddingsprocedure.
          }
          throw const FinancieleReddingsscanException(
            'Een mogelijke financiële noodback-up werd gevonden, maar kon niet '
            'veilig worden gekopieerd. Stop hier en verwijder de Thimaco-app niet.',
          );
        }

        resultaat.add(
          FinancieleReddingsKandidaat(
            origineelPad: kandidaat.bestand.path,
            veiligPad: doel.path,
            grootte: bytes.length,
            gewijzigdOp: kandidaat.gewijzigdOp,
          ),
        );
      } on FinancieleReddingsscanException {
        rethrow;
      } catch (_) {
        throw const FinancieleReddingsscanException(
          'Een mogelijke financiële noodback-up werd gevonden, maar kon niet '
          'veilig worden gekopieerd. Stop hier en verwijder de Thimaco-app niet.',
        );
      }
    }

    if (resultaat.isEmpty) {
      throw const FinancieleReddingsscanException(
        'Er werd een mogelijk herstelbestand gevonden, maar er kon geen veilige '
        'kopie van worden gemaakt. Verwijder de Thimaco-app niet.',
      );
    }

    return resultaat;
  }

  Future<Uint8List> leesVeiligeKopie(
    FinancieleReddingsKandidaat kandidaat,
  ) async {
    final bestand = File(kandidaat.veiligPad);
    if (!await bestand.exists()) {
      throw const FinancieleReddingsscanException(
        'De veiliggestelde noodback-up is niet meer beschikbaar.',
      );
    }

    final grootte = await bestand.length();
    if (grootte <= 0 || grootte > _maximaleBestandsgrootte) {
      throw const FinancieleReddingsscanException(
        'De veiliggestelde noodback-up heeft een ongeldige grootte.',
      );
    }

    return Uint8List.fromList(await bestand.readAsBytes());
  }

  Future<List<Directory>> _bepaalScanWortels() async {
    final gevonden = <String, Directory>{};

    Future<void> voegToe(Future<Directory> Function() leverancier) async {
      try {
        final map = await leverancier();
        if (await map.exists()) {
          gevonden[map.absolute.path] = map;
        }
      } catch (_) {
        // Niet ieder platform levert elke standaardmap. Andere wortels blijven
        // bruikbaar, dus een ontbrekende map mag de scan niet blokkeren.
      }
    }

    await voegToe(getTemporaryDirectory);
    await voegToe(getApplicationDocumentsDirectory);
    await voegToe(getApplicationSupportDirectory);
    await voegToe(getLibraryDirectory);

    // Op iOS liggen Documents, Library en tmp in dezelfde appcontainer. Door ook
    // de containerwortel te scannen vangen we tijdelijke share_plus-mappen op
    // die niet exact overeenkomen met een standaard path_provider-pad.
    try {
      final documenten = await getApplicationDocumentsDirectory();
      final container = documenten.parent;
      if (await container.exists()) {
        gevonden[container.absolute.path] = container;
      }
    } catch (_) {
      // De standaardmappen hierboven blijven beschikbaar.
    }

    return gevonden.values.toList(growable: false);
  }

  Future<void> _scanMap(
    Directory wortel, {
    required Set<String> gevondenPaden,
    required List<_RuweReddingsKandidaat> kandidaten,
  }) async {
    try {
      await for (final entiteit
          in wortel.list(recursive: true, followLinks: false)) {
        if (entiteit is! File) {
          continue;
        }

        final pad = entiteit.absolute.path;
        if (!gevondenPaden.add(pad)) {
          continue;
        }

        // Eerder veiliggestelde bestanden niet opnieuw kopiëren.
        if (_isInReddingsMap(pad)) {
          continue;
        }

        try {
          final grootte = await entiteit.length();
          if (grootte <= 0 || grootte > _maximaleBestandsgrootte) {
            continue;
          }

          if (!await _bevatNoodbackupMarker(entiteit)) {
            continue;
          }

          kandidaten.add(
            _RuweReddingsKandidaat(
              bestand: entiteit,
              gewijzigdOp: await entiteit.lastModified(),
            ),
          );
        } catch (_) {
          // Een onleesbaar tijdelijk bestand mag de rest van de scan niet stoppen.
        }
      }
    } catch (_) {
      // Een niet-toegankelijke submap mag andere scanwortels niet blokkeren.
    }
  }

  Future<bool> _bevatNoodbackupMarker(File bestand) async {
    RandomAccessFile? toegang;
    try {
      final grootte = await bestand.length();
      if (grootte <= 0 || grootte > _maximaleBestandsgrootte) {
        return false;
      }

      toegang = await bestand.open(mode: FileMode.read);
      final teLezen = grootte < _scanKopGrootte ? grootte : _scanKopGrootte;
      final bytes = await toegang.read(teLezen);
      final tekst = utf8.decode(bytes, allowMalformed: true);
      return tekst.contains(_formaatMarker);
    } catch (_) {
      return false;
    } finally {
      try {
        await toegang?.close();
      } catch (_) {
        // Geen verdere actie nodig.
      }
    }
  }

  bool _isInReddingsMap(String pad) {
    final scheiding = Platform.pathSeparator;
    return pad.contains('$scheiding$_reddingsMapNaam$scheiding');
  }

  String _tijdstempel(DateTime datum) {
    String twee(int waarde) => waarde.toString().padLeft(2, '0');

    return '${datum.year}${twee(datum.month)}${twee(datum.day)}'
        '_${twee(datum.hour)}${twee(datum.minute)}${twee(datum.second)}';
  }
}

class FinancieleReddingsKandidaat {
  const FinancieleReddingsKandidaat({
    required this.origineelPad,
    required this.veiligPad,
    required this.grootte,
    required this.gewijzigdOp,
  });

  final String origineelPad;
  final String veiligPad;
  final int grootte;
  final DateTime gewijzigdOp;

  String get veiligeBestandsnaam {
    final scheiding = Platform.pathSeparator;
    final delen = veiligPad.split(scheiding);
    return delen.isEmpty ? veiligPad : delen.last;
  }
}

class _RuweReddingsKandidaat {
  const _RuweReddingsKandidaat({
    required this.bestand,
    required this.gewijzigdOp,
  });

  final File bestand;
  final DateTime gewijzigdOp;
}

class FinancieleReddingsscanException implements Exception {
  const FinancieleReddingsscanException(this.bericht);

  final String bericht;

  @override
  String toString() => bericht;
}
