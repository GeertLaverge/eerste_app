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
  }

  @override
  void dispose() {
    naamController.dispose();
    klantNrController.dispose();
    straatController.dispose();
    nrController.dispose();
    gemeenteController.dispose();
    postcodeController.dispose();
    gsmController.dispose();
    gsm2Controller.dispose();
    emailController.dispose();

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

                if (!mounted) return;

                Navigator.pop(context);
              },
            ),
            KlantenficheStatusBalk(
              geselecteerd: klantStatus,
              onGekozen: (waarde) async {
                setState(() {
                  klantStatus = waarde;

                  if (waarde == 'Afgewerkt') {
                    final vandaag = DateTime.now();

                    datumAfgewerkt =
                        '${vandaag.day.toString().padLeft(2, '0')}/'
                        '${vandaag.month.toString().padLeft(2, '0')}/'
                        '${vandaag.year}';
                  } else {
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
