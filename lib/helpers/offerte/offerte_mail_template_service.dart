// THIMACO-CONTROLE: MAILBERICHT-PLAATSHOUDERS-20260802

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

  static const List<String> beschikbareVelden = <String>[
    '[aanspreking]',
    '[klantnaam]',
    '[offertenummer]',
    '[offertedatum]',
    '[totaalbedrag]',
    '[ondertekenaar]',
  ];

  static OfferteMailTekst vulIn({
    required String onderwerp,
    required String bericht,
    required OfferteDocumentData data,
    OfferteGoedkeuring? goedkeuring,
  }) {
    return OfferteMailTekst(
      onderwerp: _vervangVelden(onderwerp, data, goedkeuring),
      bericht: _vervangVelden(bericht, data, goedkeuring),
    );
  }

  static String maakOnderwerpHerbruikbaar(
    String onderwerp,
    OfferteDocumentData data,
    OfferteGoedkeuring? goedkeuring,
  ) {
    return _maakHerbruikbaar(onderwerp, data, goedkeuring, onderwerpVeld: true);
  }

  static String maakBerichtHerbruikbaar(
    String bericht,
    OfferteDocumentData data,
    OfferteGoedkeuring? goedkeuring,
  ) {
    return _maakHerbruikbaar(bericht, data, goedkeuring, onderwerpVeld: false);
  }

  static String _vervangVelden(
    String waarde,
    OfferteDocumentData data,
    OfferteGoedkeuring? goedkeuring,
  ) {
    var resultaat = waarde;
    final velden = _veldWaarden(data, goedkeuring);
    for (final item in velden.entries) {
      resultaat = resultaat.replaceAll(item.key, item.value);
    }
    return resultaat;
  }

  static String _maakHerbruikbaar(
    String waarde,
    OfferteDocumentData data,
    OfferteGoedkeuring? goedkeuring, {
    required bool onderwerpVeld,
  }) {
    var resultaat = waarde;
    final velden = _veldWaarden(data, goedkeuring).entries
        .where((item) => item.value.trim().isNotEmpty)
        .toList(growable: false);

    velden.sort((links, rechts) {
      if (links.value == rechts.value) {
        final linksVoorkeur = _veldVoorkeur(links.key, onderwerpVeld);
        final rechtsVoorkeur = _veldVoorkeur(rechts.key, onderwerpVeld);
        return linksVoorkeur.compareTo(rechtsVoorkeur);
      }
      return rechts.value.length.compareTo(links.value.length);
    });

    final reedsVervangenWaarden = <String>{};
    for (final item in velden) {
      if (!reedsVervangenWaarden.add(item.value)) continue;
      resultaat = resultaat.replaceAll(item.value, item.key);
    }
    return resultaat;
  }

  static int _veldVoorkeur(String veld, bool onderwerpVeld) {
    if (onderwerpVeld) {
      return switch (veld) {
        '[klantnaam]' => 0,
        '[offertenummer]' => 1,
        '[offertedatum]' => 2,
        '[totaalbedrag]' => 3,
        '[aanspreking]' => 4,
        '[ondertekenaar]' => 5,
        _ => 10,
      };
    }
    return switch (veld) {
      '[aanspreking]' => 0,
      '[klantnaam]' => 1,
      '[offertenummer]' => 2,
      '[offertedatum]' => 3,
      '[totaalbedrag]' => 4,
      '[ondertekenaar]' => 5,
      _ => 10,
    };
  }

  static Map<String, String> _veldWaarden(
    OfferteDocumentData data,
    OfferteGoedkeuring? goedkeuring,
  ) {
    return <String, String>{
      '[aanspreking]': _aanspreking(data),
      '[klantnaam]': data.klant.naam.trim().isEmpty
          ? 'klant'
          : data.klant.naam.trim(),
      '[offertenummer]': _offerteNummer(data),
      '[offertedatum]': _datum(data.offerteDatum),
      '[totaalbedrag]': _euro(data.totaalInclusiefBtw),
      '[ondertekenaar]': goedkeuring?.naam.trim() ?? '',
    };
  }

  static String _aanspreking(OfferteDocumentData data) {
    final contact = data.klant.contactpersoon.trim();
    if (contact.isNotEmpty) return contact;

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
