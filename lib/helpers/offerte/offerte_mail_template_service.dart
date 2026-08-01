import 'offerte_goedkeuring_model.dart';
import 'offerte_pdf_model.dart';

class OfferteMailTekst {
  const OfferteMailTekst({required this.onderwerp, required this.bericht});

  final String onderwerp;
  final String bericht;

  String get volledig => 'Onderwerp: $onderwerp\n\n$bericht';
}

class OfferteMailTemplateService {
  const OfferteMailTemplateService._();

  static OfferteMailTekst voorVersturen(OfferteDocumentData data) {
    final aanspreking = _aanspreking(data);
    final nummer = _offerteNummer(data);
    final datum = _datum(data.offerteDatum);
    final totaal = _euro(data.totaalInclusiefBtw);

    return OfferteMailTekst(
      onderwerp: 'Offerte Thimaco $nummer – ${data.klant.naam.trim()}',
      bericht:
          '''Beste $aanspreking,

In bijlage bezorgen wij u onze offerte met nummer $nummer voor de besproken werken.

Het totaalbedrag van de offerte bedraagt $totaal inclusief btw.

U kunt de offerte op een van de volgende manieren goedkeuren:

• ondertekenen tijdens onze afspraak op de iPad;
• de goedkeuringspagina afdrukken, ondertekenen en per e-mail terugbezorgen;
• deze e-mail beantwoorden met de onderstaande tekst:

“Ik, [naam klant], keur offerte $nummer van $datum voor een totaalbedrag van $totaal inclusief btw goed.”

Hebt u nog vragen of wenst u bepaalde zaken te bespreken, dan mag u ons uiteraard steeds contacteren.

Met vriendelijke groeten

Geert
Thimaco
Ramen · Deuren · Zonwering
Kerkdreef 1
8791 Beveren-Leie
056 44 91 35
info@thimaco.be''',
    );
  }

  static OfferteMailTekst naGoedkeuring(
    OfferteDocumentData data,
    OfferteGoedkeuring? goedkeuring,
  ) {
    final aanspreking = _aanspreking(data);
    final nummer = _offerteNummer(data);
    final totaal = _euro(data.totaalInclusiefBtw);
    final naam = goedkeuring?.naam.trim() ?? '';
    final ondertekenaar = naam.isEmpty ? '' : ' door $naam';

    return OfferteMailTekst(
      onderwerp: 'Bevestiging goedkeuring offerte Thimaco $nummer',
      bericht:
          '''Beste $aanspreking,

Bedankt voor uw goedkeuring$ondertekenaar van offerte $nummer.

In bijlage vindt u een kopie van de ondertekende offerte voor een totaalbedrag van $totaal inclusief btw.

Wij nemen contact met u op voor de verdere opvolging en planning van uw dossier.

Met vriendelijke groeten

Geert
Thimaco
Ramen · Deuren · Zonwering
Kerkdreef 1
8791 Beveren-Leie
056 44 91 35
info@thimaco.be''',
    );
  }

  static String _aanspreking(OfferteDocumentData data) {
    final contactpersoon = data.klant.contactpersoon.trim();
    if (contactpersoon.isNotEmpty) return contactpersoon;

    final naam = data.klant.naam.trim();
    return naam.isEmpty ? 'klant' : naam;
  }

  static String _offerteNummer(OfferteDocumentData data) {
    final nummer = data.offerteNummer.trim();
    return nummer.isEmpty ? 'zonder nummer' : nummer;
  }

  static String _datum(DateTime datum) {
    String twee(int waarde) => waarde.toString().padLeft(2, '0');
    return '${twee(datum.day)}/${twee(datum.month)}/${datum.year}';
  }

  static String _euro(double waarde) {
    final veilig = waarde.isFinite ? waarde : 0.0;
    final delen = veilig.toStringAsFixed(2).split('.');
    final geheel = delen.first;
    final decimalen = delen.length > 1 ? delen[1] : '00';
    final buffer = StringBuffer();

    for (var index = 0; index < geheel.length; index++) {
      if (index > 0 && (geheel.length - index) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(geheel[index]);
    }

    return '€ ${buffer.toString()},$decimalen';
  }
}
