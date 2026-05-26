import 'onedrive_auth_service.dart';
import 'onedrive_storage_service.dart';

class OneDriveSyncService {
  final OneDriveAuthService _authService = OneDriveAuthService();

  final OneDriveStorageService _storageService = OneDriveStorageService();

  Future<bool> uploadTestbestand() async {
    final accessToken = await _authService.login();

    if (accessToken == null) {
      return false;
    }

    return _storageService.uploadTestbestand(
      accessToken,
    );
  }
}
