// THIMACO-CONTROLE: FINANCIELE-KLUIS-LOKALE-OPSLAG-HERSTELPAKKET-V2-20260916
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import '../beveiliging/financiele_privacy_scherm_service.dart';
import 'financiele_versleuteling_service.dart';

class FinancieleOpslagService {
  FinancieleOpslagService({
    FinancieleVersleutelingService? versleutelingService,
  }) : _versleutelingService =
           versleutelingService ?? FinancieleVersleutelingService();

  static const String _bestandsnaam = 'thimaco_financiele_kluis_v1.dat';
  static const String _herstelpakketBestandsnaam =
      'thimaco_financiele_herstel_v2.dat';
  static const String _herstelpakketFormaat =
      'THIMACO_FINANCIEEL_LOKAAL_HERSTELPAKKET';
  static const int _herstelpakketVersie = 2;

  final FinancieleVersleutelingService _versleutelingService;

  Future<bool> bestaat() async {
    final bestand = await _bestand();
    final vorigeVersie = File('${bestand.path}.bak');
    final huidigBestaat = await bestand.exists();
    final vorigeVersieBestaat = await vorigeVersie.exists();
    return huidigBestaat || vorigeVersieBestaat;
  }

  Future<bool> lokaalHerstelpakketBestaat() async {
    final bestand = await _herstelpakketBestand();
    final vorigeVersie = File('${bestand.path}.bak');
    return await bestand.exists() || await vorigeVersie.exists();
  }

  Future<void> initialiseerLegeKluis({
    required Uint8List masterKey,
    required Map<String, dynamic> herstelcodeVerifier,
  }) async {
    final inhoud = <String, dynamic>{
      'schemaVersie': 1,
      'aangemaaktOp': DateTime.now().toUtc().toIso8601String(),
      'gewijzigdOp': DateTime.now().toUtc().toIso8601String(),
      'rekeningen': <dynamic>[],
      'teBetalenFacturen': <dynamic>[],
      'teOntvangenFacturen': <dynamic>[],
      'andereOntvangsten': <dynamic>[],
      'vasteKosten': <dynamic>[],
      'notities': <dynamic>[],
      'herstelcodeVerifier': herstelcodeVerifier,
    };

    await bewaarOntsleuteld(
      inhoud: inhoud,
      masterKey: masterKey,
    );
  }

  Future<Map<String, dynamic>> laadOntsleuteld(Uint8List masterKey) async {
    final bestand = await _bestand();
    final vorigeVersie = File('${bestand.path}.bak');

    Object? huidigeFout;
    if (await bestand.exists()) {
      try {
        final envelop = await _leesEnvelopUitBestand(bestand);
        final inhoud = await _versleutelingService.ontsleutelJson(
          envelop: envelop,
          sleutel: masterKey,
        );

        await _verwijderBestandZonderFout(vorigeVersie);
        return _normaliseerInhoud(inhoud);
      } catch (fout) {
        huidigeFout = fout;
      }
    }

    if (await vorigeVersie.exists()) {
      try {
        final oudeEnvelop = await _leesEnvelopUitBestand(vorigeVersie);
        final oudeInhoud = await _versleutelingService.ontsleutelJson(
          envelop: oudeEnvelop,
          sleutel: masterKey,
        );

        await _verwijderBestandZonderFout(bestand);
        await vorigeVersie.rename(bestand.path);
        return _normaliseerInhoud(oudeInhoud);
      } catch (_) {
        // De algemene fout hieronder voorkomt cryptografische details in de UI.
      }
    }

    if (huidigeFout is FinancieleKluisCryptoException) {
      throw const FinancieleOpslagException(
        'Het lokale kluisbestand hoort niet bij de beschikbare financiële sleutel.',
      );
    }

    throw const FinancieleOpslagException(
      'Het lokale kluisbestand is beschadigd of onleesbaar.',
    );
  }

  Future<void> bewaarOntsleuteld({
    required Map<String, dynamic> inhoud,
    required Uint8List masterKey,
  }) async {
    final bijgewerkt = _normaliseerInhoud(inhoud)
      ..['gewijzigdOp'] = DateTime.now().toUtc().toIso8601String();

    final envelop = await _versleutelingService.versleutelJson(
      inhoud: bijgewerkt,
      sleutel: masterKey,
    );

    await schrijfVersleuteldeEnvelop(envelop);
  }

  Future<Map<String, dynamic>> leesVersleuteldeEnvelop() async {
    final bestand = await _bestand();
    if (!await bestand.exists()) {
      throw const FinancieleOpslagException(
        'Op dit toestel werd geen financiële kluis gevonden.',
      );
    }

    return _leesEnvelopUitBestand(bestand);
  }

  Future<void> schrijfVersleuteldeEnvelop(
    Map<String, dynamic> envelop, {
    bool behoudVorigeVersie = false,
  }) async {
    final bestand = await _bestand();
    final tijdelijk = File('${bestand.path}.tmp');
    final vorigeVersie = File('${bestand.path}.bak');

    try {
      await _verwijderBestandZonderFout(tijdelijk);
      await _verwijderBestandZonderFout(vorigeVersie);

      await tijdelijk.writeAsString(jsonEncode(envelop), flush: true);

      if (await bestand.exists()) {
        await bestand.rename(vorigeVersie.path);
      }

      await tijdelijk.rename(bestand.path);

      if (!behoudVorigeVersie) {
        await _verwijderBestandZonderFout(vorigeVersie);
      }
    } catch (_) {
      await _verwijderBestandZonderFout(tijdelijk);

      if (!await bestand.exists() && await vorigeVersie.exists()) {
        try {
          await vorigeVersie.rename(bestand.path);
        } catch (_) {
          // De originele fout wordt hieronder als veilige opslagfout gemeld.
        }
      }

      throw const FinancieleOpslagException(
        'De financiële kluis kon niet veilig worden opgeslagen.',
      );
    }
  }

  Future<void> schrijfLokaalHerstelpakket({
    required Map<String, dynamic> sleutelVerpakking,
    bool behoudVorigeVersie = false,
  }) async {
    if (sleutelVerpakking.isEmpty) {
      throw const FinancieleOpslagException(
        'De lokale herstelverpakking is leeg.',
      );
    }

    final bestand = await _herstelpakketBestand();
    final tijdelijk = File('${bestand.path}.tmp');
    final vorigeVersie = File('${bestand.path}.bak');
    final pakket = <String, dynamic>{
      'formaat': _herstelpakketFormaat,
      'versie': _herstelpakketVersie,
      'gemaaktOp': DateTime.now().toUtc().toIso8601String(),
      'sleutelVerpakking': sleutelVerpakking,
    };

    try {
      await _verwijderBestandZonderFout(tijdelijk);
      await _verwijderBestandZonderFout(vorigeVersie);
      await tijdelijk.writeAsString(jsonEncode(pakket), flush: true);

      if (await bestand.exists()) {
        await bestand.rename(vorigeVersie.path);
      }
      await tijdelijk.rename(bestand.path);

      final controle = await _leesHerstelpakketUitBestand(bestand);
      if (controle.isEmpty) {
        throw const FinancieleOpslagException(
          'De controle van het lokale herstelpakket is mislukt.',
        );
      }

      if (!behoudVorigeVersie) {
        await _verwijderBestandZonderFout(vorigeVersie);
      }
    } catch (fout) {
      await _verwijderBestandZonderFout(tijdelijk);

      if (!await bestand.exists() && await vorigeVersie.exists()) {
        try {
          await vorigeVersie.rename(bestand.path);
        } catch (_) {
          // De fout hieronder blijft leidend.
        }
      }

      if (fout is FinancieleOpslagException) {
        rethrow;
      }
      throw const FinancieleOpslagException(
        'Het lokale herstelpakket kon niet veilig worden opgeslagen.',
      );
    }
  }

  Future<Map<String, dynamic>> leesLokaalHerstelpakket() async {
    final bestand = await _herstelpakketBestand();
    final vorigeVersie = File('${bestand.path}.bak');

    if (await bestand.exists()) {
      try {
        final verpakking = await _leesHerstelpakketUitBestand(bestand);
        await _verwijderBestandZonderFout(vorigeVersie);
        return verpakking;
      } catch (_) {
        // Probeer hieronder de vorige versie.
      }
    }

    if (await vorigeVersie.exists()) {
      try {
        final verpakking = await _leesHerstelpakketUitBestand(vorigeVersie);
        await _verwijderBestandZonderFout(bestand);
        await vorigeVersie.rename(bestand.path);
        return verpakking;
      } catch (_) {
        // Algemene fout hieronder.
      }
    }

    throw const FinancieleOpslagException(
      'Op deze iPad werd geen geldig lokaal herstelpakket gevonden. Gebruik een externe noodback-up.',
    );
  }

  Future<void> wisLokaalHerstelpakket() async {
    final bestand = await _herstelpakketBestand();
    await _verwijderBestandZonderFout(File('${bestand.path}.tmp'));
    await _verwijderBestandZonderFout(File('${bestand.path}.bak'));
    await _verwijderBestandZonderFout(bestand);
  }

  Future<void> annuleerHerstelpakketSchrijfbeurt() async {
    final bestand = await _herstelpakketBestand();
    final vorigeVersie = File('${bestand.path}.bak');

    if (!await vorigeVersie.exists()) {
      await _verwijderBestandZonderFout(bestand);
      return;
    }

    await _verwijderBestandZonderFout(bestand);
    try {
      await vorigeVersie.rename(bestand.path);
    } catch (_) {
      throw const FinancieleOpslagException(
        'Het vorige lokale herstelpakket kon niet worden teruggezet.',
      );
    }
  }

  Future<void> voltooiHerstelpakketSchrijfbeurt() async {
    final bestand = await _herstelpakketBestand();
    await _verwijderBestandZonderFout(File('${bestand.path}.bak'));
  }

  Future<void> annuleerHerstelSchrijfbeurt() async {
    final bestand = await _bestand();
    final vorigeVersie = File('${bestand.path}.bak');

    if (!await vorigeVersie.exists()) {
      await _verwijderBestandZonderFout(bestand);
      return;
    }

    await _verwijderBestandZonderFout(bestand);
    try {
      await vorigeVersie.rename(bestand.path);
    } catch (_) {
      throw const FinancieleOpslagException(
        'De vorige lokale kluisversie kon na de mislukte herstelpoging niet worden teruggezet.',
      );
    }
  }

  Future<void> voltooiHerstelSchrijfbeurt() async {
    final bestand = await _bestand();
    await _verwijderBestandZonderFout(File('${bestand.path}.bak'));
  }

  Future<void> wisLokaalKluisbestand() async {
    final bestand = await _bestand();
    await _verwijderBestandZonderFout(File('${bestand.path}.tmp'));
    await _verwijderBestandZonderFout(File('${bestand.path}.bak'));
    await _verwijderBestandZonderFout(bestand);
  }

  Future<void> wisFinancieleLokaleDataVoorNieuweStart() async {
    final kandidaten = await _lokaleVeiligheidsKandidaten();

    for (final kandidaat in kandidaten) {
      try {
        if (await kandidaat.bestand.exists()) {
          await kandidaat.bestand.delete();
        }
      } catch (_) {
        throw const FinancieleOpslagException(
          'De oude lokale financiële bestanden konden niet volledig worden vrijgemaakt. De veilige archiefkopie blijft behouden.',
        );
      }
    }

    for (final kandidaat in kandidaten) {
      if (await kandidaat.bestand.exists()) {
        throw const FinancieleOpslagException(
          'De oude lokale financiële bestanden konden niet volledig worden vrijgemaakt. De veilige archiefkopie blijft behouden.',
        );
      }
    }
  }

  Future<List<FinancieleRuweKluisExport>> stelRuweKluisVeiligVoorExport() async {
    final kandidaten = await _lokaleVeiligheidsKandidaten();
    final aanwezige = await _bestaandeNietLegeBestanden(kandidaten);

    if (aanwezige.isEmpty) {
      throw const FinancieleOpslagException(
        'Er werd geen lokaal versleuteld financieel kluis- of herstelbestand gevonden om veilig te stellen.',
      );
    }

    final documenten = await getApplicationDocumentsDirectory();
    final herstelMap = Directory(
      '${documenten.path}/ThimacoHerstel/RuweKluis_${_tijdstempel(DateTime.now().toUtc())}',
    );

    try {
      await herstelMap.create(recursive: true);
    } catch (_) {
      throw const FinancieleOpslagException(
        'De veilige herstelmap voor de lokale financiële kluis kon niet worden aangemaakt.',
      );
    }

    return _kopieerKandidatenNaarMap(
      aanwezige,
      herstelMap,
      foutmelding:
          'De versleutelde lokale kluis werd gevonden, maar kon niet veilig worden gekopieerd. Verwijder of reset de Thimaco-app niet.',
    );
  }

  Future<FinancieleNieuweStartArchief> archiveerVoorNieuweStart() async {
    final kandidaten = await _lokaleVeiligheidsKandidaten();
    final aanwezige = await _bestaandeNietLegeBestanden(kandidaten);

    final bevatKluis = aanwezige.any(
      (item) => item.label == _bestandsnaam || item.label == '$_bestandsnaam.bak',
    );
    if (!bevatKluis) {
      throw const FinancieleOpslagException(
        'De huidige financiële kluis kon niet worden gevonden. Nieuwe activatie is daarom niet gestart.',
      );
    }

    final documenten = await getApplicationDocumentsDirectory();
    final archiefMap = Directory(
      '${documenten.path}/ThimacoHerstel/OudeKluis_${_tijdstempel(DateTime.now().toUtc())}',
    );

    try {
      await archiefMap.create(recursive: true);
    } catch (_) {
      throw const FinancieleOpslagException(
        'De interne archiefmap voor de oude kluis kon niet worden aangemaakt.',
      );
    }

    final exports = await _kopieerKandidatenNaarMap(
      aanwezige,
      archiefMap,
      foutmelding:
          'De oude financiële kluis kon niet volledig worden gearchiveerd. Er is niets gereset.',
    );

    return FinancieleNieuweStartArchief(
      mapPad: archiefMap.path,
      bestanden: exports,
    );
  }

  Future<void> herstelActieveBestandenUitNieuweStartArchief(
    FinancieleNieuweStartArchief archief,
  ) async {
    final kandidaten = await _lokaleVeiligheidsKandidaten();
    final perLabel = <String, File>{
      for (final kandidaat in kandidaten) kandidaat.label: kandidaat.bestand,
    };

    try {
      for (final export in archief.bestanden) {
        final doel = perLabel[export.bestandsnaam];
        if (doel == null) {
          continue;
        }

        final bron = File(export.veiligPad);
        final bytes = await bron.readAsBytes();
        if (bytes.isEmpty) {
          continue;
        }

        await doel.writeAsBytes(bytes, flush: true);
        final controleBytes = await doel.readAsBytes();
        if (!_zelfdeBytes(bytes, controleBytes)) {
          throw const FinancieleOpslagException(
            'De terugzetcontrole van het interne archief is mislukt.',
          );
        }
      }
    } catch (_) {
      throw const FinancieleOpslagException(
        'De actieve financiële bestanden konden na een afgebroken nieuwe-startactie niet volledig worden teruggezet. De interne archiefkopie en externe kopie blijven behouden.',
      );
    }
  }

  Future<List<({File bestand, String label})>> _lokaleVeiligheidsKandidaten() async {
    final kluis = await _bestand();
    final herstel = await _herstelpakketBestand();

    return <({File bestand, String label})>[
      (bestand: kluis, label: _bestandsnaam),
      (bestand: File('${kluis.path}.bak'), label: '$_bestandsnaam.bak'),
      (bestand: File('${kluis.path}.tmp'), label: '$_bestandsnaam.tmp'),
      (bestand: herstel, label: _herstelpakketBestandsnaam),
      (
        bestand: File('${herstel.path}.bak'),
        label: '$_herstelpakketBestandsnaam.bak',
      ),
      (
        bestand: File('${herstel.path}.tmp'),
        label: '$_herstelpakketBestandsnaam.tmp',
      ),
    ];
  }

  Future<List<({File bestand, String label})>> _bestaandeNietLegeBestanden(
    List<({File bestand, String label})> kandidaten,
  ) async {
    final aanwezige = <({File bestand, String label})>[];
    for (final kandidaat in kandidaten) {
      try {
        if (await kandidaat.bestand.exists() &&
            await kandidaat.bestand.length() > 0) {
          aanwezige.add(kandidaat);
        }
      } catch (_) {
        // Een onleesbare nevenversie mag de hoofdversie niet blokkeren.
      }
    }
    return aanwezige;
  }

  Future<List<FinancieleRuweKluisExport>> _kopieerKandidatenNaarMap(
    List<({File bestand, String label})> kandidaten,
    Directory doelMap, {
    required String foutmelding,
  }) async {
    final resultaat = <FinancieleRuweKluisExport>[];

    try {
      for (final kandidaat in kandidaten) {
        final doel = File('${doelMap.path}/${kandidaat.label}');
        final bytes = await kandidaat.bestand.readAsBytes();
        if (bytes.isEmpty) {
          continue;
        }

        await doel.writeAsBytes(bytes, flush: true);
        if (!await doel.exists()) {
          throw const FinancieleOpslagException(
            'De controle van de veilige kopie is mislukt.',
          );
        }
        final controleBytes = await doel.readAsBytes();
        if (!_zelfdeBytes(bytes, controleBytes)) {
          throw const FinancieleOpslagException(
            'De controle van de veilige kopie is mislukt.',
          );
        }

        resultaat.add(
          FinancieleRuweKluisExport(
            bronPad: kandidaat.bestand.path,
            veiligPad: doel.path,
            bestandsnaam: kandidaat.label,
            grootte: bytes.length,
          ),
        );
      }
    } catch (_) {
      throw FinancieleOpslagException(foutmelding);
    }

    if (resultaat.isEmpty) {
      throw FinancieleOpslagException(foutmelding);
    }

    return resultaat;
  }

  Future<Map<String, dynamic>> _leesHerstelpakketUitBestand(File bestand) async {
    final pakket = await _leesJsonMap(
      bestand,
      foutmelding: 'Het lokale herstelpakket is beschadigd of onleesbaar.',
    );

    if (pakket['formaat']?.toString() != _herstelpakketFormaat ||
        pakket['versie'] != _herstelpakketVersie ||
        pakket['sleutelVerpakking'] is! Map) {
      throw const FinancieleOpslagException(
        'Het lokale herstelpakket heeft een ongeldig formaat.',
      );
    }

    return Map<String, dynamic>.from(
      pakket['sleutelVerpakking'] as Map,
    );
  }

  bool _zelfdeBytes(List<int> a, List<int> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var index = 0; index < a.length; index++) {
      if (a[index] != b[index]) {
        return false;
      }
    }
    return true;
  }

  String _tijdstempel(DateTime datum) {
    String twee(int waarde) => waarde.toString().padLeft(2, '0');

    return '${datum.year}${twee(datum.month)}${twee(datum.day)}'
        '_${twee(datum.hour)}${twee(datum.minute)}${twee(datum.second)}';
  }

  Map<String, dynamic> _normaliseerInhoud(Map<String, dynamic> inhoud) {
    final resultaat = Map<String, dynamic>.from(inhoud);

    void zorgVoorLijst(String sleutel) {
      if (resultaat[sleutel] is! List) {
        resultaat[sleutel] = <dynamic>[];
      }
    }

    resultaat['schemaVersie'] ??= 1;
    resultaat['aangemaaktOp'] ??= DateTime.now().toUtc().toIso8601String();
    zorgVoorLijst('rekeningen');
    zorgVoorLijst('teBetalenFacturen');
    zorgVoorLijst('teOntvangenFacturen');
    zorgVoorLijst('andereOntvangsten');
    zorgVoorLijst('vasteKosten');
    zorgVoorLijst('notities');

    return resultaat;
  }

  Future<Map<String, dynamic>> _leesEnvelopUitBestand(File bestand) {
    return _leesJsonMap(
      bestand,
      foutmelding: 'Het lokale kluisbestand is beschadigd of onleesbaar.',
    );
  }

  Future<Map<String, dynamic>> _leesJsonMap(
    File bestand, {
    required String foutmelding,
  }) async {
    try {
      final tekst = await bestand.readAsString();
      final decoded = jsonDecode(tekst);
      if (decoded is! Map) {
        throw const FormatException('Geen JSON-object.');
      }
      return Map<String, dynamic>.from(decoded);
    } catch (_) {
      throw FinancieleOpslagException(foutmelding);
    }
  }

  Future<void> _verwijderBestandZonderFout(File bestand) async {
    try {
      if (await bestand.exists()) {
        await bestand.delete();
      }
    } catch (_) {
      // Oude tijdelijke bestanden bevatten uitsluitend versleutelde data.
    }
  }

  Future<Directory> _financieleMap() async {
    final map = await getApplicationSupportDirectory();
    final financieleMap = Directory('${map.path}/financiele_kluis');

    if (!await financieleMap.exists()) {
      await financieleMap.create(recursive: true);
    }

    final uitgeslotenVanBackup =
        await FinancielePrivacySchermService.sluitPadUitVanIosBackup(
          financieleMap.path,
        );
    if (!uitgeslotenVanBackup) {
      throw const FinancieleOpslagException(
        'De financiële opslag kon niet van iCloud-reservekopieën worden uitgesloten.',
      );
    }

    return financieleMap;
  }

  Future<File> _bestand() async {
    final map = await _financieleMap();
    return File('${map.path}/$_bestandsnaam');
  }

  Future<File> _herstelpakketBestand() async {
    final map = await _financieleMap();
    return File('${map.path}/$_herstelpakketBestandsnaam');
  }
}

class FinancieleRuweKluisExport {
  const FinancieleRuweKluisExport({
    required this.bronPad,
    required this.veiligPad,
    required this.bestandsnaam,
    required this.grootte,
  });

  final String bronPad;
  final String veiligPad;
  final String bestandsnaam;
  final int grootte;
}

class FinancieleNieuweStartArchief {
  const FinancieleNieuweStartArchief({
    required this.mapPad,
    required this.bestanden,
  });

  final String mapPad;
  final List<FinancieleRuweKluisExport> bestanden;
}

class FinancieleOpslagException implements Exception {
  const FinancieleOpslagException(this.bericht);

  final String bericht;

  @override
  String toString() => bericht;
}
