// THIMACO-CONTROLE: ONEDRIVE-WINDOWS-PKCE-LOGIN-20260913
// THIMACO-CONTROLE: ONEDRIVE-CENTRAAL-GRAPH-TOKEN-20260817
// THIMACO-CONTROLE: ONEDRIVE-AFMELDEN-NA-VEILIGE-UPLOAD-20260805
// THIMACO-CONTROLE: ONEDRIVE-AUTOMATISCH-ALTIJD-SILENT-20260802
// THIMACO-CONTROLE: ONEDRIVE-ACCOUNT-DEBUG-MET-ECHT-EMAILADRES-20260802
// THIMACO-CONTROLE: ONEDRIVE-SILENT-ZONDER-OVERBODIGE-POPUP-20260731
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:msal_auth/msal_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class OneDriveAuthService {
  static const String clientId = '3224b91e-bff0-4b46-8b8e-f3db21987a2a';
  static const String tenantId = 'cf489dc4-f99d-4365-8204-926a654d871b';

  static const List<String> scopes = <String>[
    'User.Read',
    'Files.ReadWrite.AppFolder',
    'Files.ReadWrite',
    'Mail.Send',
    'Mail.ReadWrite',
  ];

  static const String _windowsRefreshTokenKey =
      'thimaco_windows_microsoft_refresh_token_v1';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static SingleAccountPca? _pca;

  // Vermijdt dat meerdere gelijktijdige automatische acties elk afzonderlijk
  // een tokenaanvraag starten.
  static Future<String>? _lopendeSilentAanvraag;
  static Future<String>? _lopendeInteractieveAanvraag;

  // Tijdelijke geheugenbuffer. Op iOS/macOS bewaart MSAL de blijvende sessie.
  // Op Windows bewaren we uitsluitend het refresh token beveiligd via
  // flutter_secure_storage.
  static String? _geheugenToken;
  static DateTime? _geheugenTokenVervaltOp;

  Future<SingleAccountPca> _getPca() async {
    _pca ??= await SingleAccountPca.create(
      clientId: clientId,
      appleConfig: AppleConfig(
        authority: 'https://login.microsoftonline.com/$tenantId',
        authorityType: AuthorityType.aad,
      ),
    );

    return _pca!;
  }

  Future<String> tokenSilent() {
    final tokenUitGeheugen = _geldigGeheugenToken();
    if (tokenUitGeheugen != null) {
      return Future<String>.value(tokenUitGeheugen);
    }

    final lopendeAanvraag = _lopendeSilentAanvraag;
    if (lopendeAanvraag != null) {
      return lopendeAanvraag;
    }

    final nieuweAanvraag = _tokenSilentIntern();
    _lopendeSilentAanvraag = nieuweAanvraag;

    nieuweAanvraag.whenComplete(() {
      if (identical(_lopendeSilentAanvraag, nieuweAanvraag)) {
        _lopendeSilentAanvraag = null;
      }
    });

    return nieuweAanvraag;
  }

  Future<String> _tokenSilentIntern() async {
    if (Platform.isWindows) {
      return _windowsTokenSilent();
    }

    try {
      final pca = await _getPca();
      final result = await pca.acquireTokenSilent(scopes: scopes);
      return _bewaarResultaat(result, foutCode: 'FOUT_GEEN_TOKEN_SILENT');
    } catch (e) {
      // Wanneer een andere gelijktijdige aanvraag intussen wel een geldig
      // token opleverde, gebruiken we dat in plaats van een loginvenster te
      // openen.
      final tokenUitGeheugen = _geldigGeheugenToken();
      if (tokenUitGeheugen != null) {
        return tokenUitGeheugen;
      }

      return 'FOUT_SILENT_LOGIN: $e';
    }
  }

  Future<String> loginInteractief() {
    final lopendeAanvraag = _lopendeInteractieveAanvraag;
    if (lopendeAanvraag != null) {
      return lopendeAanvraag;
    }

    final nieuweAanvraag = _loginInteractiefIntern();
    _lopendeInteractieveAanvraag = nieuweAanvraag;

    nieuweAanvraag.whenComplete(() {
      if (identical(_lopendeInteractieveAanvraag, nieuweAanvraag)) {
        _lopendeInteractieveAanvraag = null;
      }
    });

    return nieuweAanvraag;
  }

  Future<String> _loginInteractiefIntern() async {
    if (Platform.isWindows) {
      return _windowsLoginInteractief();
    }

    try {
      final pca = await _getPca();
      final result = await pca.acquireToken(
        scopes: scopes,
        prompt: Prompt.whenRequired,
      );
      return _bewaarResultaat(result, foutCode: 'FOUT_GEEN_TOKEN');
    } catch (e) {
      final tokenUitGeheugen = _geldigGeheugenToken();
      if (tokenUitGeheugen != null) {
        return tokenUitGeheugen;
      }

      return 'FOUT_LOGIN: $e';
    }
  }

  /// Voor alle automatische appwerking wordt uitsluitend stil aangemeld.
  /// Alleen de expliciete knop 'Aanmelden Microsoft' mag loginInteractief()
  /// aanroepen. Hierdoor kan synchronisatie, mail of OneDrive-navigatie nooit
  /// uit zichzelf een Microsoft-venster openen.
  Future<String> login() => tokenSilent();

  /// Enig toegangspunt voor services die Microsoft Graph aanroepen.
  ///
  /// Bij een 401 kan de service [forceerVernieuwen] gebruiken. Dan wordt alleen
  /// de tijdelijke access-tokenbuffer gewist en wordt stil een nieuw token
  /// aangevraagd. Op Windows gebeurt dat met het beveiligd bewaarde refresh
  /// token; op iOS/macOS via MSAL.
  Future<String> tokenVoorGraph({bool forceerVernieuwen = false}) async {
    if (forceerVernieuwen) {
      wisTijdelijkToken();
    }

    return tokenSilent();
  }

  /// Verwijdert uitsluitend de tijdelijke access-tokenbuffer in het geheugen.
  void wisTijdelijkToken() {
    _geheugenToken = null;
    _geheugenTokenVervaltOp = null;
  }

  /// Meldt het huidige Microsoft-account voor Thimaco af.
  ///
  /// Op iOS/macOS wordt MSAL afgemeld. Op Windows verwijderen we het beveiligd
  /// opgeslagen refresh token. De Microsoft-sessie in de gewone browser zelf
  /// blijft buiten Thimaco bestaan.
  Future<String> afmelden() async {
    if (Platform.isWindows) {
      try {
        await _secureStorage.delete(key: _windowsRefreshTokenKey);
        _lopendeSilentAanvraag = null;
        _lopendeInteractieveAanvraag = null;
        wisTijdelijkToken();
        return 'AFMELDEN_OK';
      } catch (e) {
        return 'AFMELDEN_FOUT: $e';
      }
    }

    try {
      final pca = await _getPca();
      final afgemeld = await pca.signOut();

      _lopendeSilentAanvraag = null;
      _lopendeInteractieveAanvraag = null;
      wisTijdelijkToken();

      return afgemeld ? 'AFMELDEN_OK' : 'AFMELDEN_GEEN_ACCOUNT';
    } catch (e) {
      return 'AFMELDEN_FOUT: $e';
    }
  }

  Future<String> accountDebugInfo() async {
    try {
      final token = await tokenSilent();
      if (_isFout(token)) {
        return 'ACCOUNT_DEBUG: ACCOUNT GEVONDEN, MAAR GEEN STILLE TOKEN\n'
            '$token';
      }

      final response = await http.get(
        Uri.parse(
          'https://graph.microsoft.com/v1.0/me?'
          r'$select=id,displayName,mail,userPrincipalName',
        ),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        return 'ACCOUNT_DEBUG: MICROSOFT GRAPH FOUT ${response.statusCode}\n'
            '${response.body}';
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        return 'ACCOUNT_DEBUG: ONVERWACHT ANTWOORD VAN MICROSOFT';
      }

      final data = Map<String, dynamic>.from(decoded);
      final naam = data['displayName']?.toString().trim() ?? '';
      final mail = data['mail']?.toString().trim() ?? '';
      final gebruikersnaam = data['userPrincipalName']?.toString().trim() ?? '';
      final id = data['id']?.toString().trim() ?? '';
      final effectiefAdres = mail.isNotEmpty ? mail : gebruikersnaam;

      return 'ACCOUNT_DEBUG: ACCOUNT GEVONDEN\n'
          'Naam: ${naam.isEmpty ? '-' : naam}\n'
          'E-mailadres: ${effectiefAdres.isEmpty ? '-' : effectiefAdres}\n'
          'Microsoft-gebruikersnaam: '
          '${gebruikersnaam.isEmpty ? '-' : gebruikersnaam}\n'
          'Account-ID: ${id.isEmpty ? '-' : id}';
    } catch (e) {
      return 'ACCOUNT_DEBUG_FOUT: $e';
    }
  }

  Future<String> _windowsTokenSilent() async {
    try {
      final refreshToken =
          (await _secureStorage.read(key: _windowsRefreshTokenKey))?.trim() ?? '';

      if (refreshToken.isEmpty) {
        return 'FOUT_GEEN_TOKEN_SILENT';
      }

      final response = await http.post(
        Uri.parse(
          'https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token',
        ),
        body: <String, String>{
          'client_id': clientId,
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'scope': _windowsScopeTekst,
        },
      );

      if (response.statusCode != 200) {
        final fout = _leesOAuthFout(response.body);

        // Een ongeldig of ingetrokken refresh token mag niet iedere drie
        // minuten opnieuw gebruikt blijven worden. De gebruiker kan daarna
        // bewust opnieuw op 'Aanmelden Microsoft' drukken.
        if (fout.code == 'invalid_grant') {
          await _secureStorage.delete(key: _windowsRefreshTokenKey);
        }

        return 'FOUT_SILENT_LOGIN_WINDOWS ${response.statusCode}: '
            '${fout.beschrijving}';
      }

      return _bewaarWindowsTokenResponse(
        response.body,
        bestaandRefreshToken: refreshToken,
        foutCode: 'FOUT_GEEN_TOKEN_SILENT',
      );
    } catch (e) {
      final tokenUitGeheugen = _geldigGeheugenToken();
      if (tokenUitGeheugen != null) {
        return tokenUitGeheugen;
      }

      return 'FOUT_SILENT_LOGIN_WINDOWS: $e';
    }
  }

  Future<String> _windowsLoginInteractief() async {
    HttpServer? server;

    try {
      final verifier = _maakVeiligeRandomTekst(64);
      final challenge = await _maakPkceChallenge(verifier);
      final state = _maakVeiligeRandomTekst(32);

      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final redirectUri = 'http://localhost:${server.port}';

      final authorizeUri = Uri.https(
        'login.microsoftonline.com',
        '/$tenantId/oauth2/v2.0/authorize',
        <String, String>{
          'client_id': clientId,
          'response_type': 'code',
          'redirect_uri': redirectUri,
          'response_mode': 'query',
          'scope': _windowsScopeTekst,
          'code_challenge': challenge,
          'code_challenge_method': 'S256',
          'state': state,
        },
      );

      final geopend = await launchUrl(
        authorizeUri,
        mode: LaunchMode.externalApplication,
      );

      if (!geopend) {
        return 'FOUT_LOGIN_WINDOWS: Microsoft-aanmeldpagina kon niet worden geopend';
      }

      final request = await server.first.timeout(const Duration(minutes: 5));
      final parameters = request.uri.queryParameters;

      final terugState = parameters['state'] ?? '';
      final code = parameters['code'] ?? '';
      final foutCode = parameters['error'] ?? '';
      final foutBeschrijving = parameters['error_description'] ?? '';

      if (foutCode.isNotEmpty) {
        await _antwoordBrowser(
          request,
          gelukt: false,
          tekst: 'Microsoft-aanmelding is niet voltooid. Je mag dit venster sluiten.',
        );
        return 'FOUT_LOGIN_WINDOWS: '
            '${foutBeschrijving.isEmpty ? foutCode : foutBeschrijving}';
      }

      if (terugState != state) {
        await _antwoordBrowser(
          request,
          gelukt: false,
          tekst: 'De beveiligingscontrole van de aanmelding is mislukt. '
              'Je mag dit venster sluiten en opnieuw proberen.',
        );
        return 'FOUT_LOGIN_WINDOWS: ONGELDIGE_STATE';
      }

      if (code.isEmpty) {
        await _antwoordBrowser(
          request,
          gelukt: false,
          tekst: 'Microsoft gaf geen geldige aanmeldcode terug. '
              'Je mag dit venster sluiten en opnieuw proberen.',
        );
        return 'FOUT_LOGIN_WINDOWS: GEEN_AUTH_CODE';
      }

      await _antwoordBrowser(
        request,
        gelukt: true,
        tekst: 'Aanmelding ontvangen. Je mag dit browservenster sluiten '
            'en terugkeren naar Thimaco.',
      );

      final tokenResponse = await http.post(
        Uri.parse(
          'https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token',
        ),
        body: <String, String>{
          'client_id': clientId,
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': redirectUri,
          'code_verifier': verifier,
          'scope': _windowsScopeTekst,
        },
      );

      if (tokenResponse.statusCode != 200) {
        final fout = _leesOAuthFout(tokenResponse.body);
        return 'FOUT_LOGIN_WINDOWS ${tokenResponse.statusCode}: '
            '${fout.beschrijving}';
      }

      return _bewaarWindowsTokenResponse(
        tokenResponse.body,
        foutCode: 'FOUT_GEEN_TOKEN',
      );
    } on TimeoutException {
      return 'FOUT_LOGIN_WINDOWS: AANMELDEN_TIMEOUT';
    } catch (e) {
      final tokenUitGeheugen = _geldigGeheugenToken();
      if (tokenUitGeheugen != null) {
        return tokenUitGeheugen;
      }

      return 'FOUT_LOGIN_WINDOWS: $e';
    } finally {
      await server?.close(force: true);
    }
  }

  static String get _windowsScopeTekst => <String>[
        ...scopes,
        'openid',
        'profile',
        'offline_access',
      ].join(' ');

  static String _maakVeiligeRandomTekst(int aantalBytes) {
    final random = Random.secure();
    final bytes = List<int>.generate(
      aantalBytes,
      (_) => random.nextInt(256),
      growable: false,
    );
    return _base64UrlZonderPadding(bytes);
  }

  static Future<String> _maakPkceChallenge(String verifier) async {
    final hash = await Sha256().hash(utf8.encode(verifier));
    return _base64UrlZonderPadding(hash.bytes);
  }

  static String _base64UrlZonderPadding(List<int> bytes) {
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  static Future<void> _antwoordBrowser(
    HttpRequest request, {
    required bool gelukt,
    required String tekst,
  }) async {
    request.response.statusCode = HttpStatus.ok;
    request.response.headers.contentType = ContentType.html;
    request.response.write('''
<!doctype html>
<html lang="nl">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Thimaco Microsoft-aanmelding</title>
</head>
<body style="font-family:Segoe UI,Arial,sans-serif;padding:32px;max-width:720px;margin:auto;">
  <h2>${gelukt ? 'Aanmelding gelukt' : 'Aanmelding niet gelukt'}</h2>
  <p>${htmlEscape.convert(tekst)}</p>
</body>
</html>
''');
    await request.response.close();
  }

  Future<String> _bewaarWindowsTokenResponse(
    String responseBody, {
    String? bestaandRefreshToken,
    required String foutCode,
  }) async {
    final decoded = jsonDecode(responseBody);
    if (decoded is! Map) {
      return foutCode;
    }

    final data = Map<String, dynamic>.from(decoded);
    final accessToken = data['access_token']?.toString().trim() ?? '';

    if (accessToken.isEmpty) {
      return foutCode;
    }

    final expiresInRaw = data['expires_in'];
    final expiresIn = expiresInRaw is num
        ? expiresInRaw.toInt()
        : int.tryParse(expiresInRaw?.toString() ?? '') ?? 3600;

    final nieuwRefreshToken = data['refresh_token']?.toString().trim() ?? '';
    final refreshToken = nieuwRefreshToken.isNotEmpty
        ? nieuwRefreshToken
        : (bestaandRefreshToken?.trim() ?? '');

    if (refreshToken.isNotEmpty) {
      await _secureStorage.write(
        key: _windowsRefreshTokenKey,
        value: refreshToken,
      );
    }

    _geheugenToken = accessToken;
    _geheugenTokenVervaltOp = DateTime.now().add(
      Duration(seconds: expiresIn),
    );

    return accessToken;
  }

  static _OAuthFout _leesOAuthFout(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map) {
        final data = Map<String, dynamic>.from(decoded);
        final code = data['error']?.toString().trim() ?? '';
        final beschrijving =
            data['error_description']?.toString().trim() ?? code;
        return _OAuthFout(
          code: code,
          beschrijving: beschrijving.isEmpty
              ? 'Onbekende Microsoft-aanmeldfout'
              : beschrijving,
        );
      }
    } catch (_) {
      // Gebruik hieronder de ruwe response als die geen JSON was.
    }

    final tekst = responseBody.trim();
    return _OAuthFout(
      code: '',
      beschrijving: tekst.isEmpty ? 'Onbekende Microsoft-aanmeldfout' : tekst,
    );
  }

  static String _bewaarResultaat(
    AuthenticationResult resultaat, {
    required String foutCode,
  }) {
    final token = resultaat.accessToken.trim();
    if (token.isEmpty) {
      return foutCode;
    }

    _geheugenToken = token;
    _geheugenTokenVervaltOp = resultaat.expiresOn;
    return token;
  }

  static String? _geldigGeheugenToken() {
    final token = _geheugenToken?.trim() ?? '';
    final vervaltOp = _geheugenTokenVervaltOp;

    if (token.isEmpty || vervaltOp == null) {
      return null;
    }

    // Een kleine veiligheidsmarge voorkomt dat een token tijdens een upload
    // of mapnavigatie net vervalt.
    if (!vervaltOp.isAfter(DateTime.now().add(const Duration(minutes: 2)))) {
      _geheugenToken = null;
      _geheugenTokenVervaltOp = null;
      return null;
    }

    return token;
  }

  static bool _isFout(String waarde) {
    final tekst = waarde.trim();
    return tekst.isEmpty || tekst.startsWith('FOUT');
  }
}

class _OAuthFout {
  const _OAuthFout({
    required this.code,
    required this.beschrijving,
  });

  final String code;
  final String beschrijving;
}
