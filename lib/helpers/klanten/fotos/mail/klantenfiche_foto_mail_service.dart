import 'dart:io';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class KlantenficheFotoMailService {
  static const String _smtpServer = 'smtp-auth.mailprotect.be';
  static const int _smtpPoort = 2525;
  static const String _gebruikersnaam = 'info@thimaco.be';

  // TIJDELIJK: vul hier je SMTP-wachtwoord in om te testen.
  // Later zetten we dit beter in veilige opslag.
  static const String _wachtwoord = 'VUL_HIER_SMTP_WACHTWOORD_IN';

  Future<String> verstuurMail({
    required List<File> fotos,
    required String ontvanger,
    required String onderwerp,
    required String bericht,
  }) async {
    try {
      final smtpServer = SmtpServer(
        _smtpServer,
        port: _smtpPoort,
        username: _gebruikersnaam,
        password: _wachtwoord,
        ssl: false,
        allowInsecure: false,
      );

      final message = Message()
        ..from = const Address(_gebruikersnaam, 'Thimaco')
        ..recipients.add(ontvanger)
        ..subject = onderwerp
        ..text = bericht.trim().isEmpty ? 'Zie foto\'s in bijlage.' : bericht;

      for (final foto in fotos) {
        if (await foto.exists()) {
          message.attachments.add(FileAttachment(foto));
        }
      }

      await send(message, smtpServer);

      return 'MAIL_OK';
    } on MailerException catch (e) {
      return 'MAIL_FOUT\n${e.toString()}';
    } catch (e) {
      return 'MAIL_EXCEPTION: $e';
    }
  }
}
