import 'package:msal_auth/msal_auth.dart';

class OneDriveAuthService {
  static const String clientId = '3224b91e-bff0-4b46-8b8e-f3db21987a2a';
  static const String tenantId = 'cf489dc4-f99d-4365-8204-926a654d871b';

  static const List<String> scopes = [
    'User.Read',
    'Files.ReadWrite.AppFolder',
    'Mail.Send',
    'Mail.ReadWrite',
    'offline_access',
  ];

  static SingleAccountPca? _pca;

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

      final token = result.accessToken;

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

      final token = result.accessToken;

      if (token.isEmpty) {
        return 'FOUT_GEEN_TOKEN';
      }

      return token;
    } catch (e) {
      return 'FOUT_LOGIN: $e';
    }
  }

  Future<String> login() async {
    return loginInteractief();
  }
}
