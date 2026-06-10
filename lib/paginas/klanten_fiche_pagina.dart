import 'package:flutter/material.dart';

import '../helpers/klanten/fiche/klantenfiche_boven_balk.dart';
import '../helpers/klanten/fiche/klantenfiche_status_balk.dart';
import '../helpers/klanten/fiche/klantenfiche_uitval_blok.dart';
import '../helpers/klanten/fiche/klantenfiche_tekstveld.dart';
import '../helpers/klanten/fiche/klantenfiche_klantkiezer.dart';
import '../helpers/klanten/klantenfiche_taakveld.dart';
import '../helpers/klanten/klantenfiche_leveranciers.dart';
import '../helpers/klanten/fiche/klantenfiche_service.dart';
import '../helpers/klanten/fiche/klantenfiche_model.dart';
import '../helpers/klanten/klantenfiche_extra_werk_veld.dart';
import '../helpers/klanten/fotos/klantenfiche_foto_blok.dart';
import '../helpers/klanten/fotos/mail/klantenfiche_foto_mail_service.dart';
import '../helpers/klanten/fiche/klantenfiche_lock_service.dart';
import 'dart:async';

class KlantenFichePagina extends StatefulWidget {
  final KlantenficheModel? bestaandeFiche;

  const KlantenFichePagina({
    super.key,
    this.bestaandeFiche,
  });

  @override
  State<KlantenFichePagina> createState() => _KlantenFichePaginaState();
}

class _KlantenFichePaginaState extends State<KlantenFichePagina> {
  String klantStatus = 'Actief';
  String datumAfgewerkt = '';

  late final String ficheId;

  Timer? _lockTimer;

  final naamController = TextEditingController();
  final straatController = TextEditingController();
  final nrController = TextEditingController();
  final gemeenteController = TextEditingController();
  final postcodeController = TextEditingController();
  final gsmController = TextEditingController();
  final gsm2Controller = TextEditingController();
  final emailController = TextEditingController();
  final taakController = TextEditingController();
  final klantNrController = TextEditingController();
  final opvolgTakenController = TextEditingController();

  bool opvolgFicheVerstuurdNaarBureau = false;
  bool klaarVoorNieuwePlanning = false;

  List<KlantenficheArtikel> artikelen = [];
  List<KlantTaakItem> klantTaken = [];
  List<KlantenficheExtraWerk> extraWerken = [];
  List<KlantenficheFoto> fotos = [];

  Color kleurVoorBestelStatus(String status) {
    switch (status) {
      case 'Te bestellen':
        return Colors.red;
      case 'Besteld':
        return Colors.blue;
      case 'Geleverd':
        return const Color(0xFF7BC67E);
      case 'Geen artikelen':
      default:
        return const Color(0xFF0B7A3B);
    }
  }

  @override
  void initState() {
    super.initState();
    ficheId = widget.bestaandeFiche?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();

    final fiche = widget.bestaandeFiche;

    if (fiche == null) return;

    artikelen = List<KlantenficheArtikel>.from(
      fiche.artikelen,
    );

    klantStatus = fiche.klantStatus;
    datumAfgewerkt = fiche.datumAfgewerkt;

    naamController.text = fiche.naam;
    klantNrController.text = fiche.klantNr;
    straatController.text = fiche.straatnaam;
    nrController.text = fiche.huisNr;
    gemeenteController.text = fiche.gemeente;
    postcodeController.text = fiche.postcode;
    gsmController.text = fiche.gsm;
    gsm2Controller.text = fiche.gsm2;
    emailController.text = fiche.email;
    taakController.text = fiche.taakVoorKlant;
    klantTaken = List<KlantTaakItem>.from(fiche.klantTaken);
    extraWerken = List<KlantenficheExtraWerk>.from(
      fiche.extraWerken,
    );
    fotos = List<KlantenficheFoto>.from(
      fiche.fotos,
    );
    opvolgTakenController.text = fiche.opvolgTaken;
    opvolgFicheVerstuurdNaarBureau = fiche.opvolgFicheVerstuurdNaarBureau;
    klaarVoorNieuwePlanning = fiche.klaarVoorNieuwePlanning;

    _lockTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        KlantenficheLockService.vernieuwLock(
          ficheId,
        );
      },
    );
  }

  @override
  void dispose() {
    _lockTimer?.cancel();
    KlantenficheLockService.verwijderLock(
      ficheId,
    );

    naamController.dispose();
    klantNrController.dispose();
    straatController.dispose();
    nrController.dispose();
    gemeenteController.dispose();
    postcodeController.dispose();
    gsmController.dispose();
    gsm2Controller.dispose();
    emailController.dispose();
    opvolgTakenController.dispose();
    super.dispose();
  }

  String get titelNaam {
    final naam = naamController.text.trim();
    return naam.isEmpty ? 'Nieuwe klantenfiche' : naam;
  }

  Future<void> automatischBewaren() async {
    await KlantenficheService.automatischBewaren(
      ficheId: ficheId,
      naam: naamController.text,
      klantNr: klantNrController.text,
      straatnaam: straatController.text,
      huisNr: nrController.text,
      gemeente: gemeenteController.text,
      postcode: postcodeController.text,
      gsm: gsmController.text,
      gsm2: gsm2Controller.text,
      email: emailController.text,
      klantStatus: klantStatus,
      datumAfgewerkt: datumAfgewerkt,
      taakVoorKlant: '',
      klantTaken: klantTaken,
      extraWerken: extraWerken,
      fotos: fotos,
      artikelen: artikelen,
      opvolgTaken: opvolgTakenController.text,
      opvolgFicheVerstuurdNaarBureau: opvolgFicheVerstuurdNaarBureau,
      klaarVoorNieuwePlanning: klaarVoorNieuwePlanning,
    );
  }

  String _extraWerkenTekst() {
    final ingevuld = extraWerken.where((werk) {
      return werk.omschrijving.trim().isNotEmpty ||
          werk.gebruikteMaterialen.trim().isNotEmpty ||
          werk.aantalMinuten > 0;
    }).toList();

    if (ingevuld.isEmpty) {
      return 'Er zijn geen Extra werken uitgevoerd';
    }

    String tijdTekst(KlantenficheExtraWerk werk) {
      if (werk.startUur == null ||
          werk.startMinuut == null ||
          werk.eindUur == null ||
          werk.eindMinuut == null) {
        return 'Geen tijd ingevuld';
      }

      final start =
          '${werk.startUur!.toString().padLeft(2, '0')}:${werk.startMinuut!.toString().padLeft(2, '0')}';

      final eind =
          '${werk.eindUur!.toString().padLeft(2, '0')}:${werk.eindMinuut!.toString().padLeft(2, '0')}';

      return '$start - $eind';
    }

    String duurTekst(int minuten) {
      final uren = minuten ~/ 60;
      final rest = minuten % 60;

      if (uren == 0) return '$rest min';
      if (rest == 0) return '$uren u';

      return '$uren u $rest min';
    }

    var totaalMinuten = 0;
    final regels = <String>[];

    for (var i = 0; i < ingevuld.length; i++) {
      final werk = ingevuld[i];
      totaalMinuten += werk.aantalMinuten;

      regels.add('Extra werk ${i + 1}');
      regels.add('Tijd: ${tijdTekst(werk)}');
      regels.add('Totaaltijd: ${duurTekst(werk.aantalMinuten)}');
      regels.add(
          'Omschrijving werken: ${werk.omschrijving.trim().isEmpty ? 'niet ingevuld' : werk.omschrijving.trim()}');
      regels.add(
          'Gebruikte materialen: ${werk.gebruikteMaterialen.trim().isEmpty ? 'niet ingevuld' : werk.gebruikteMaterialen.trim()}');
      regels.add('');
    }

    regels.add('Totale tijd extra werken: ${duurTekst(totaalMinuten)}');

    return regels.join('\n');
  }

  Future<void> _verstuurOpvolgFicheNaarBureau() async {
    final naam = naamController.text.trim();

    if (naam.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Geef eerst een klantnaam in.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (opvolgTakenController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vul eerst de nog af te werken taken in.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final bericht = '''
Klant '$naam' moet worden opgevolgd.

Nog af te werken taken:
${opvolgTakenController.text.trim()}

Gelieve na te kijken of er nieuwe artikelen en taken voor klant moeten worden ingevuld.

Van zodra de klantenfiche is aangepast aan de nieuwe status, druk op de knop:
'Fiche nagekeken, alles in (her)bestelling'.

Extra werken:
${_extraWerkenTekst()}
''';

    final resultaat = await KlantenficheFotoMailService().verstuurMail(
      fotos: [],
      ontvanger: 'info@thimaco.be',
      onderwerp: 'Op te volgen klant: $naam',
      bericht: bericht,
    );

    if (!mounted) return;

    if (resultaat == 'MAIL_OK') {
      setState(() {
        opvolgFicheVerstuurdNaarBureau = true;
        klaarVoorNieuwePlanning = false;
      });

      await automatischBewaren();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opvolgfiche verstuurd naar bureau.'),
          backgroundColor: Color(0xFF0B7A3B),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultaat),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _klantIsOpgevolgd() async {
    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Fiche nagekeken?'),
          content: const Text(
            'Bent u zeker dat alles is nagekeken en dat de nodige artikelen opnieuw in bestelling staan?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Annuleren'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Ja, bevestigen',
                style: TextStyle(
                  color: Color(0xFF0B7A3B),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (bevestigen != true) return;

    setState(() {
      klantStatus = 'Opvolgen';
      opvolgFicheVerstuurdNaarBureau = true;
      klaarVoorNieuwePlanning = true;
    });

    await automatischBewaren();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Klant staat klaar om opnieuw in te plannen.'),
        backgroundColor: Color(0xFF0B7A3B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bestelStatus = KlantenficheService.berekenBestelStatus(artikelen);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            KlantenficheBovenBalk(
              titel: titelNaam,
              onTerug: () async {
                await automatischBewaren();

                await KlantenficheLockService.verwijderLock(
                  ficheId,
                );

                if (!mounted) return;

                Navigator.pop(context);
              },
            ),
            KlantenficheStatusBalk(
              geselecteerd: klantStatus,
              onGekozen: (waarde) async {
                if (waarde == klantStatus) return;

                final huidigeStatus = klantStatus;

                if (huidigeStatus == 'Opvolgen' && waarde == 'Actief') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Een klant op opvolgen kan niet terug naar actief.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (huidigeStatus == 'Afgewerkt' && waarde == 'Actief') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Een afgewerkte klant kan niet terug naar actief.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (huidigeStatus == 'Afgewerkt' && waarde == 'Opvolgen') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Een afgewerkte klant kan niet meer naar opvolgen.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (waarde == 'Opvolgen' || waarde == 'Afgewerkt') {
                  final bevestigen = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          waarde == 'Opvolgen'
                              ? 'Klant op opvolgen plaatsen?'
                              : 'Klant afwerken?',
                        ),
                        content: Text(
                          waarde == 'Opvolgen'
                              ? 'Bent u zeker? Leveranciers, artikelen en taken voor klant worden leeggemaakt.'
                              : 'Bent u zeker dat deze klant volledig afgewerkt is?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child: const Text('Annuleren'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: const Text(
                              'Ja, bevestigen',
                              style: TextStyle(
                                color: Color(0xFF0B7A3B),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  if (bevestigen != true) return;
                }

                setState(() {
                  klantStatus = waarde;

                  if (waarde == 'Opvolgen') {
                    artikelen.clear();
                    klantTaken.clear();
                    taakController.clear();

                    opvolgTakenController.clear();
                    opvolgFicheVerstuurdNaarBureau = false;
                    klaarVoorNieuwePlanning = false;

                    datumAfgewerkt = '';
                  }

                  if (waarde == 'Afgewerkt') {
                    final vandaag = DateTime.now();

                    datumAfgewerkt =
                        '${vandaag.day.toString().padLeft(2, '0')}/'
                        '${vandaag.month.toString().padLeft(2, '0')}/'
                        '${vandaag.year}';
                  }

                  if (waarde != 'Afgewerkt' && waarde != 'Opvolgen') {
                    datumAfgewerkt = '';
                  }
                });

                await automatischBewaren();
              },
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  KlantenficheUitvalBlok(
                    titel: 'Klantengegevens',
                    standaardOpen: false,
                    child: Column(
                      children: [
                        KlantenficheTekstveld(
                          label: 'Klantnr',
                          controller: klantNrController,
                          onChanged: (_) {
                            automatischBewaren();
                          },
                        ),
                        KlantenficheTekstveld(
                          label: 'Naam klant',
                          controller: naamController,
                          onChanged: (_) {
                            setState(() {});
                            automatischBewaren();
                          },
                          toonMenuKnop: true,
                          onMenuTap: () async {
                            final klant =
                                await KlantenficheKlantkiezer.toon(context);

                            if (klant == null) return;

                            setState(() {
                              naamController.text = klant.naamKlant;
                              straatController.text = klant.straatnaam;
                              nrController.text = klant.huisNr;
                              gemeenteController.text = klant.gemeente;
                              postcodeController.text = klant.postcode;
                              gsmController.text = klant.gsm;
                              gsm2Controller.text = klant.gsm2;
                              emailController.text = klant.email;
                            });

                            await automatischBewaren();
                          },
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: KlantenficheTekstveld(
                                onChanged: (_) {
                                  automatischBewaren();
                                },
                                label: 'Straat',
                                controller: straatController,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: KlantenficheTekstveld(
                                onChanged: (_) {
                                  automatischBewaren();
                                },
                                label: 'Nr',
                                controller: nrController,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: KlantenficheTekstveld(
                                onChanged: (_) {
                                  automatischBewaren();
                                },
                                label: 'Gemeente',
                                controller: gemeenteController,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: KlantenficheTekstveld(
                                onChanged: (_) {
                                  automatischBewaren();
                                },
                                label: 'Postcode',
                                controller: postcodeController,
                              ),
                            ),
                          ],
                        ),
                        KlantenficheTekstveld(
                          onChanged: (_) {
                            automatischBewaren();
                          },
                          label: 'GSM',
                          controller: gsmController,
                        ),
                        KlantenficheTekstveld(
                          onChanged: (_) {
                            automatischBewaren();
                          },
                          label: 'GSM 2',
                          controller: gsm2Controller,
                        ),
                        KlantenficheTekstveld(
                          onChanged: (_) {
                            automatischBewaren();
                          },
                          label: 'Email',
                          controller: emailController,
                        ),
                      ],
                    ),
                  ),
                  KlantenficheUitvalBlok(
                    titel: 'Leveranciers en artikelen',
                    rechterTekst: bestelStatus,
                    rechterBolKleur: kleurVoorBestelStatus(bestelStatus),
                    standaardOpen: false,
                    child: KlantenficheLeveranciers(
                      artikelen: artikelen,
                      onChanged: (nieuweArtikelen) async {
                        setState(() {
                          artikelen = nieuweArtikelen;
                        });

                        await automatischBewaren();
                      },
                    ),
                  ),
                  KlantenficheUitvalBlok(
                    titel: naamController.text.trim().isEmpty
                        ? 'Taak voor klant'
                        : 'Taak voor klant ${naamController.text}',
                    standaardOpen: false,
                    child: KlantenficheTaakveld(
                      taken: klantTaken,
                      onChanged: () async {
                        setState(() {});
                        await automatischBewaren();
                      },
                    ),
                  ),
                  if (klantStatus == 'Opvolgen')
                    KlantenficheUitvalBlok(
                      titel: 'Vul hier de nog af te werken taken in',
                      standaardOpen: true,
                      child: Column(
                        children: [
                          TextField(
                            controller: opvolgTakenController,
                            minLines: 4,
                            maxLines: 8,
                            onChanged: (_) {
                              automatischBewaren();
                            },
                            decoration: InputDecoration(
                              hintText:
                                  'Beschrijf hier wat nog moet opgevolgd worden...',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: opvolgFicheVerstuurdNaarBureau
                                  ? null
                                  : () async {
                                      final bevestigen = await showDialog<bool>(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text(
                                              'Opvolgfiche versturen?',
                                            ),
                                            content: const Text(
                                              'Bent u zeker dat deze opvolgfiche naar het bureau mag worden verstuurd?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, false);
                                                },
                                                child: const Text(
                                                  'Annuleren',
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, true);
                                                },
                                                child: const Text(
                                                  'Versturen',
                                                  style: TextStyle(
                                                    color: Color(0xFF0B7A3B),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (bevestigen != true) {
                                        return;
                                      }

                                      await _verstuurOpvolgFicheNaarBureau();
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0B7A3B),
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                opvolgFicheVerstuurdNaarBureau
                                    ? 'Opvolgfiche is verstuurd naar bureau'
                                    : 'Verstuur deze op te volgen fiche naar bureau',
                              ),
                            ),
                          ),
                          if (opvolgFicheVerstuurdNaarBureau) ...[
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: klaarVoorNieuwePlanning
                                    ? null
                                    : _klantIsOpgevolgd,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber,
                                  foregroundColor: Colors.black,
                                ),
                                child: Text(
                                  klaarVoorNieuwePlanning
                                      ? 'Klant staat klaar om in te plannen'
                                      : 'Fiche nagekeken, alles in (her)bestelling',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  KlantenficheUitvalBlok(
                    titel: 'Extra werk',
                    standaardOpen: false,
                    child: KlantenficheExtraWerkVeld(
                      extraWerken: extraWerken,
                      onChanged: () async {
                        setState(() {});
                        await automatischBewaren();
                      },
                    ),
                  ),
                  KlantenficheUitvalBlok(
                    titel: 'Foto\'s en werfinstructies',
                    standaardOpen: false,
                    child: KlantenficheFotoBlok(
                      ficheId: ficheId,
                      fotos: fotos,
                      onChanged: (nieuweFotos) async {
                        setState(() {
                          fotos = nieuweFotos;
                        });

                        await automatischBewaren();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
