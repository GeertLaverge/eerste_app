// THIMACO-CONTROLE: ONEDRIVE-SILENT-ZONDER-OVERBODIGE-POPUP-20260731
import 'package:msal_auth/msal_auth.dart';

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

  static SingleAccountPca? _pca;

  // Vermijdt dat meerdere gelijktijdige automatische acties elk afzonderlijk
  // MSAL aanroepen. Dat veroorzaakte op iOS overbodige aanmeldvensters terwijl
  // een andere stille tokenaanvraag al geldig was.
  static Future<String>? _lopendeSilentAanvraag;
  static Future<String>? _lopendeInteractieveAanvraag;
  static Future<String>? _lopendeLoginMetFallback;

  // Alleen een tijdelijke geheugenbuffer. De blijvende account- en
  // refreshtokenopslag blijft door MSAL in de iOS-Keychain gebeuren.
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

  /// Voor normale appwerking: eerst zonder scherm aanmelden en uitsluitend
  /// wanneer er echt geen bruikbare sessie bestaat interactief aanmelden.
  Future<String> login() {
    final tokenUitGeheugen = _geldigGeheugenToken();
    if (tokenUitGeheugen != null) {
      return Future<String>.value(tokenUitGeheugen);
    }

    final lopendeAanvraag = _lopendeLoginMetFallback;
    if (lopendeAanvraag != null) {
      return lopendeAanvraag;
    }

    final nieuweAanvraag = _loginMetSilentFallback();
    _lopendeLoginMetFallback = nieuweAanvraag;

    nieuweAanvraag.whenComplete(() {
      if (identical(_lopendeLoginMetFallback, nieuweAanvraag)) {
        _lopendeLoginMetFallback = null;
      }
    });

    return nieuweAanvraag;
  }

  Future<String> _loginMetSilentFallback() async {
    final silentToken = await tokenSilent();

    if (!_isFout(silentToken)) {
      return silentToken;
    }

    // Controleer nogmaals of een parallelle aanvraag intussen een token
    // opleverde voordat een zichtbaar Microsoft-scherm wordt gestart.
    final tokenUitGeheugen = _geldigGeheugenToken();
    if (tokenUitGeheugen != null) {
      return tokenUitGeheugen;
    }

    return loginInteractief();
  }

  Future<String> accountDebugInfo() async {
    try {
      final pca = await _getPca();
      final account = await pca.currentAccount;

      return 'ACCOUNT_DEBUG: ACCOUNT GEVONDEN\n$account';
    } catch (e) {
      return 'ACCOUNT_DEBUG_FOUT: $e';
    }
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
