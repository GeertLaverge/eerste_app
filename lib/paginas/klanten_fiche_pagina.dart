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
  @override
  void initState() {
    super.initState();
    ficheId = widget.bestaandeFiche?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();

    final fiche = widget.bestaandeFiche;

    if (fiche == null) return;

    klantStatus = fiche.klantStatus;

    naamController.text = fiche.naam;
    straatController.text = fiche.straatnaam;
    nrController.text = fiche.huisNr;
    gemeenteController.text = fiche.gemeente;
    postcodeController.text = fiche.postcode;
    gsmController.text = fiche.gsm;
    gsm2Controller.text = fiche.gsm2;
    emailController.text = fiche.email;
    taakController.text = fiche.taakVoorKlant;
  }

  @override
  void dispose() {
    naamController.dispose();
    straatController.dispose();
    nrController.dispose();
    gemeenteController.dispose();
    postcodeController.dispose();
    gsmController.dispose();
    gsm2Controller.dispose();
    emailController.dispose();
    taakController.dispose();
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
      klantNr: '',
      straatnaam: straatController.text,
      huisNr: nrController.text,
      gemeente: gemeenteController.text,
      postcode: postcodeController.text,
      gsm: gsmController.text,
      gsm2: gsm2Controller.text,
      email: emailController.text,
      klantStatus: klantStatus,
      bestelStatus: 'Geen artikels',
      taakVoorKlant: taakController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            KlantenficheBovenBalk(
              titel: titelNaam,
              onTerug: () => Navigator.pop(context),
            ),
            KlantenficheStatusBalk(
              geselecteerd: klantStatus,
              onGekozen: (waarde) async {
                setState(() {
                  klantStatus = waarde;
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
                    standaardOpen: false,
                    child: const KlantenficheLeveranciers(),
                  ),
                  KlantenficheUitvalBlok(
                    titel: naamController.text.trim().isEmpty
                        ? 'Taak voor klant'
                        : 'Taak voor klant ${naamController.text}',
                    standaardOpen: false,
                    child: KlantenficheTaakveld(
                      controller: taakController,
                      onChanged: automatischBewaren,
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
