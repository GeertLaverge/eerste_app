// THIMACO-CONTROLE: ONEDRIVE-SILENT-LOGIN-KEYCHAIN-20260731
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
  static Future<String>? _lopendeLogin;

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

  Future<String> tokenSilent() async {
    try {
      final pca = await _getPca();
      final result = await pca.acquireTokenSilent(scopes: scopes);
      final token = result.accessToken.trim();

      if (token.isEmpty) {
        return 'FOUT_GEEN_TOKEN_SILENT';
      }

      return token;
    } catch (e) {
      return 'FOUT_SILENT_LOGIN: $e';
    }
  }

  Future<String> loginInteractief() async {
    try {
      final pca = await _getPca();
      final result = await pca.acquireToken(scopes: scopes);
      final token = result.accessToken.trim();

      if (token.isEmpty) {
        return 'FOUT_GEEN_TOKEN';
      }

      return token;
    } catch (e) {
      return 'FOUT_LOGIN: $e';
    }
  }

  Future<String> login() {
    final lopendeLogin = _lopendeLogin;
    if (lopendeLogin != null) {
      return lopendeLogin;
    }

    final nieuweLogin = _loginMetSilentFallback();
    _lopendeLogin = nieuweLogin;

    nieuweLogin.whenComplete(() {
      if (identical(_lopendeLogin, nieuweLogin)) {
        _lopendeLogin = null;
      }
    });

    return nieuweLogin;
  }

  Future<String> _loginMetSilentFallback() async {
    final silentToken = await tokenSilent();

    if (!_isFout(silentToken)) {
      return silentToken;
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

  static bool _isFout(String waarde) {
    final tekst = waarde.trim();
    return tekst.isEmpty || tekst.startsWith('FOUT');
  }
}
