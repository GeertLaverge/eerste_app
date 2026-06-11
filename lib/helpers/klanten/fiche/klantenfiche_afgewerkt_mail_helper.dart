import '../fotos/mail/klantenfiche_foto_mail_service.dart';
import 'klantenfiche_model.dart';

class KlantenficheAfgewerktMailHelper {
  static String _datumTekst(DateTime? datum) {
    if (datum == null) return 'Geen datum ingevuld';

    return '${datum.day.toString().padLeft(2, '0')}/'
        '${datum.month.toString().padLeft(2, '0')}/'
        '${datum.year}';
  }

  static String _duurTekst(int minuten) {
    if (minuten <= 0) return '0 min';

    final uren = minuten ~/ 60;
    final rest = minuten % 60;

    if (uren == 0) return '$rest min';
    if (rest == 0) return '$uren u';

    return '$uren u $rest min';
  }

  static String _meerwerkenTekst(
    List<KlantenficheExtraWerk> extraWerken,
  ) {
    final ingevuld = extraWerken.where((werk) {
      return werk.omschrijving.trim().isNotEmpty ||
          werk.gebruikteMaterialen.trim().isNotEmpty ||
          werk.aantalMinuten > 0 ||
          werk.datum != null;
    }).toList();

    if (ingevuld.isEmpty) {
      return 'Er zijn geen meerwerken.';
    }

    var totaalMinuten = 0;
    final regels = <String>[
      'Er zijn wel meerwerken:',
      '',
    ];

    for (var i = 0; i < ingevuld.length; i++) {
      final werk = ingevuld[i];
      totaalMinuten += werk.aantalMinuten;

      regels.add('Meerwerk ${i + 1}');
      regels.add('Datum: ${_datumTekst(werk.datum)}');
      regels.add('Tijd: ${werk.tijdTekst}');
      regels.add(
          'Omschrijving: ${werk.omschrijving.trim().isEmpty ? 'Niet ingevuld' : werk.omschrijving.trim()}');
      regels.add(
          'Gebruikte materialen: ${werk.gebruikteMaterialen.trim().isEmpty ? 'Niet ingevuld' : werk.gebruikteMaterialen.trim()}');
      regels.add('Totaal: ${_duurTekst(werk.aantalMinuten)}');
      regels.add('');
    }

    regels.add('Totale extra uren: ${_duurTekst(totaalMinuten)}');

    return regels.join('\n');
  }

  static Future<String> verstuurAfgewerktMail({
    required String klantNaam,
    required List<KlantenficheExtraWerk> extraWerken,
  }) async {
    final naam = klantNaam.trim().isEmpty ? 'Naamloos' : klantNaam.trim();

    final bericht = '''
Klant '$naam' is afgewerkt.

${_meerwerkenTekst(extraWerken)}
''';

    return KlantenficheFotoMailService().verstuurMail(
      fotos: [],
      ontvanger: 'info@thimaco.be',
      onderwerp: 'Klant afgewerkt: $naam',
      bericht: bericht,
    );
  }
}
