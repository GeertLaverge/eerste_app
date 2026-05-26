import 'package:flutter_appauth/flutter_appauth.dart';

class OneDriveAuthService {
  static const String clientId = '3224b91e-bff0-4b46-8b8e-f3db21987a2a';

  static const String redirectUrl = 'msauth.be.thimaco.app://auth';

  static const String tenantId = 'cf489dc4-f99d-4365-8204-926a654d871b';

  static const List<String> scopes = [
    'User.Read',
    'Files.ReadWrite.AppFolder',
    'offline_access',
  ];

  final FlutterAppAuth _appAuth = FlutterAppAuth();
  Future<String?> login() async {
    final result = await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        clientId,
        redirectUrl,
        serviceConfiguration: const AuthorizationServiceConfiguration(
          authorizationEndpoint:
              'https://login.microsoftonline.com/cf489dc4-f99d-4365-8204-926a654d871b/oauth2/v2.0/authorize',
          tokenEndpoint:
              'https://login.microsoftonline.com/cf489dc4-f99d-4365-8204-926a654d871b/oauth2/v2.0/token',
        ),
        scopes: scopes,
      ),
    );

    return result?.accessToken;
  }
}
