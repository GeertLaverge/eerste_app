import 'package:flutter/material.dart';

import '../helpers/status_helper.dart';
import '../helpers/widgets/klantenfiche/uitklapbare_sectie.dart';
import '../helpers/widgets/klantenfiche/blokken/klantgegevens_blok.dart';
import '../helpers/widgets/klantenfiche/blokken/klant_taak_blok.dart';
import '../helpers/widgets/klantenfiche/blokken/opmerkingen_blok.dart';
import '../helpers/widgets/klantenfiche/blokken/leveranciers_blok.dart';
import '../helpers/widgets/klantenfiche/blokken/acties_blok.dart';

import '../modellen/klant.dart';
import '../modellen/klant_artikel.dart';
import '../modellen/leverancier.dart';

import 'extra_werk_pagina.dart';
import 'agenda_pagina.dart';
import 'kraan_reserveren_pagina.dart';
import 'klant_planning_pagina.dart';
import 'klant_planning_pagina.dart';
import '../helpers/widgets/onder_navigatie_balk.dart';

class KlantenfichePagina extends StatefulWidget {
  final Klant klant;
  final List<Klant> alleKlanten;
  final List<Leverancier> leveranciers;
  final List<DateTime> vakantieDagen;
  final bool isNieuweKlant;
  final Future<void> Function(Klant klant) onOpslaan;
  final Future<void> Function() onGewijzigd;

  const KlantenfichePagina({
    super.key,
    required this.klant,
    required this.alleKlanten,
    required this.leveranciers,
    required this.vakantieDagen,
    required this.isNieuweKlant,
    required this.onOpslaan,
    required this.onGewijzigd,
  });

  @override
  State<KlantenfichePagina> createState() => _KlantenfichePaginaState();
}

class _KlantenfichePaginaState extends State<KlantenfichePagina> {
  bool nieuweKlantAlToegevoegd = false;

  bool toonKlantgegevensSectie = false;
  bool toonKlantTaakSectie = false;
  bool toonOpmerkingenSectie = false;
  bool toonLeveranciersSectie = false;
  bool toonNogAfTeWerkenSectie = false;

  late final TextEditingController klantenNrController;
  late final TextEditingController klantNaamController;
  late final TextEditingController adresController;
  late final TextEditingController telefoonController;
  late final TextEditingController emailController;
  late final TextEditingController opmerkingenController;
  late final TextEditingController nogAfTeWerkenController;
  late final TextEditingController klantTaakController;

  @override
  void initState() {
    super.initState();

    if (widget.isNieuweKlant) {
      widget.klant.geenArtikelsNodig = true;
      widget.klant.toonOpmerkingen = false;
      widget.klant.toonKlantTaak = false;
      widget.klant.klantTaakMoment = 'eerstePlaatsingsdag';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      toonNieuwProjectOfNadienstVraag();
    });

    klantenNrController = TextEditingController(text: widget.klant.klantenNr);
    klantNaamController = TextEditingController(text: widget.klant.klantnaam);
    adresController = TextEditingController(text: widget.klant.adres);
    telefoonController = TextEditingController(text: widget.klant.telefoon);
    emailController = TextEditingController(text: widget.klant.email);
    opmerkingenController = TextEditingController(
      text: widget.klant.opmerkingen,
    );
    nogAfTeWerkenController = TextEditingController(
      text: widget.klant.nogAfTeWerken,
    );
    klantTaakController = TextEditingController(
      text: widget.klant.klantTaakTekst,
    );
  }

  @override
  void dispose() {
    klantenNrController.dispose();
    klantNaamController.dispose();
    adresController.dispose();
    telefoonController.dispose();
    emailController.dispose();
    opmerkingenController.dispose();
    nogAfTeWerkenController.dispose();
    klantTaakController.dispose();
    super.dispose();
  }

  Future<void> _bewaarNieuweOfBestaandeKlant() async {
    if (widget.isNieuweKlant && !nieuweKlantAlToegevoegd) {
      nieuweKlantAlToegevoegd = true;
      await widget.onOpslaan(widget.klant);
    } else {
      await widget.onGewijzigd();
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _zetControllerWaardenOpKlant() {
    widget.klant.klantenNr = klantenNrController.text.trim();
    widget.klant.klantnaam = klantNaamController.text.trim();
    widget.klant.adres = adresController.text.trim();
    widget.klant.telefoon = telefoonController.text.trim();
    widget.klant.email = emailController.text.trim();
    widget.klant.opmerkingen = opmerkingenController.text.trim();
    widget.klant.nogAfTeWerken = nogAfTeWerkenController.text.trim();
    widget.klant.klantTaakTekst = klantTaakController.text.trim();
  }

  Future<void> bewaarVelden() async {
    _zetControllerWaardenOpKlant();
    await _bewaarNieuweOfBestaandeKlant();
  }

  Future<void> bewaarStatusVelden() async {
    widget.klant.nogAfTeWerken = nogAfTeWerkenController.text.trim();
    widget.klant.klantTaakTekst = klantTaakController.text.trim();

    await _bewaarNieuweOfBestaandeKlant();
  }

  Future<bool> toonJaNeeVraag({
    required String titel,
    required String tekst,
  }) async {
    final keuze = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titel),
          content: Text(tekst),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Nee'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ja'),
            ),
          ],
        );
      },
    );

    return keuze ?? false;
  }

  Future<void> handelNadienstAf() async {
    if (widget.klant.isNadienst) {
      await openPlanningAgenda();
      return;
    }

    final bevestigen = await toonJaNeeVraag(
      titel: 'Nadienst',
      tekst: 'Deze klantenfiche is een nadienst?',
    );

    if (!bevestigen) return;

    setState(() {
      widget.klant.isNadienst = true;
      widget.klant.isProjectAfgewerkt = false;
      widget.klant.isOpTeVolgen = false;
    });

    await bewaarStatusVelden();

    if (!mounted) return;

    await openPlanningAgenda();
  }

  Future<void> handelProjectAfgewerktAf() async {
    final bevestigen = await toonJaNeeVraag(
      titel: 'Project afgewerkt',
      tekst: 'Project afgewerkt?',
    );

    if (!bevestigen) return;

    widget.klant.isProjectAfgewerkt = true;
    widget.klant.isOpTeVolgen = false;
    widget.klant.isNadienst = false;
    widget.klant.nogAfTeWerken = '';
    nogAfTeWerkenController.clear();

    await bewaarStatusVelden();
  }

  Future<void> handelProjectOpvolgenAf() async {
    bool taakLeegmaken = false;
    bool opmerkingenLeegmaken = false;
    bool leveranciersLeegmaken = false;

    final TextEditingController opvolgingController = TextEditingController(
      text: nogAfTeWerkenController.text,
    );

    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Project opvolgen'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Wat wil je leegmaken voor deze opvolging?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: taakLeegmaken,
                      onChanged: (waarde) {
                        setDialogState(() {
                          taakLeegmaken = waarde ?? false;
                        });
                      },
                      title: const Text('Taak voor klant leegmaken'),
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: opmerkingenLeegmaken,
                      onChanged: (waarde) {
                        setDialogState(() {
                          opmerkingenLeegmaken = waarde ?? false;
                        });
                      },
                      title: const Text('Opmerkingen leegmaken'),
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: leveranciersLeegmaken,
                      onChanged: (waarde) {
                        setDialogState(() {
                          leveranciersLeegmaken = waarde ?? false;
                        });
                      },
                      title: const Text('Leveranciers en artikelen leegmaken'),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Nog af te werken',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: opvolgingController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Typ hier wat nog moet worden afgewerkt...',
                        filled: true,
                        fillColor: Colors.orange.withValues(alpha: 0.08),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Annuleren'),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  icon: const Icon(Icons.pending_actions),
                  label: const Text('Nog af te werken'),
                ),
              ],
            );
          },
        );
      },
    );

    if (bevestigen != true) {
      opvolgingController.dispose();
      return;
    }

    setState(() {
      widget.klant.isOpTeVolgen = true;
      widget.klant.isProjectAfgewerkt = false;
      widget.klant.isNadienst = false;

      widget.klant.nogAfTeWerken = opvolgingController.text.trim();
      nogAfTeWerkenController.text = opvolgingController.text.trim();

      if (taakLeegmaken) {
        widget.klant.klantTaakTekst = '';
        klantTaakController.clear();
      }

      if (opmerkingenLeegmaken) {
        widget.klant.opmerkingen = '';
        opmerkingenController.clear();
      }

      if (leveranciersLeegmaken) {
        widget.klant.klantLeveranciers.clear();
        widget.klant.geenArtikelsNodig = false;
        toonLeveranciersSectie = true;
      }

      toonNogAfTeWerkenSectie = true;
    });

    opvolgingController.dispose();

    await bewaarStatusVelden();
  }

  Future<void> wijzigGeenArtikelsNodig(bool waarde) async {
    setState(() {
      widget.klant.geenArtikelsNodig = waarde;
      toonLeveranciersSectie = !waarde;
    });

    await bewaarStatusVelden();
  }

  Future<void> wijzigToonOpmerkingen(bool waarde) async {
    setState(() {
      widget.klant.toonOpmerkingen = waarde;
      toonOpmerkingenSectie = waarde;
    });

    await bewaarVelden();
  }

  Future<void> wijzigToonKlantTaak(bool waarde) async {
    setState(() {
      widget.klant.toonKlantTaak = waarde;
      toonKlantTaakSectie = waarde;

      if (waarde && widget.klant.klantTaakMoment.isEmpty) {
        widget.klant.klantTaakMoment = 'eerstePlaatsingsdag';
      }
    });

    await bewaarVelden();
  }

  Future<void> wijzigKlantTaakMoment(String moment) async {
    setState(() {
      widget.klant.klantTaakMoment = moment;
    });

    await bewaarVelden();
  }

  List<String> artikelenVanLeverancier(String leverancierNaam) {
    final leverancier = widget.leveranciers.firstWhere(
      (item) => item.naam == leverancierNaam,
      orElse: () => Leverancier(naam: '', artikelen: []),
    );

    return leverancier.artikelen;
  }

  Future<void> voegLeverancierToeAanKlant() async {
    if (widget.leveranciers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Voeg eerst een leverancier toe op de leverancierspagina.',
          ),
        ),
      );
      return;
    }

    final eersteLeverancier = widget.leveranciers.first;

    setState(() {
      widget.klant.geenArtikelsNodig = false;
      toonLeveranciersSectie = true;

      widget.klant.klantLeveranciers.add(
        KlantLeverancier(
          leverancierNaam: eersteLeverancier.naam,
          gekozenArtikelen: [],
        ),
      );
    });

    await bewaarStatusVelden();
  }

  Future<void> voegArtikelToeAanLeverancier(
    KlantLeverancier klantLeverancier,
  ) async {
    final beschikbareArtikelen = artikelenVanLeverancier(
      klantLeverancier.leverancierNaam,
    );

    final nogNietToegevoegd = beschikbareArtikelen.where((artikel) {
      return !klantLeverancier.gekozenArtikelen.any(
        (gekozen) => gekozen.artikelNaam == artikel,
      );
    }).toList();

    if (nogNietToegevoegd.isEmpty) return;

    setState(() {
      widget.klant.geenArtikelsNodig = false;

      klantLeverancier.gekozenArtikelen.add(
        KlantArtikel(
          artikelNaam: nogNietToegevoegd.first,
        ),
      );
    });

    await bewaarStatusVelden();
  }

  Future<void> wisKlantLeverancier(int index) async {
    setState(() {
      widget.klant.klantLeveranciers.removeAt(index);
    });

    await bewaarStatusVelden();
  }

  Future<void> wisArtikelVanLeverancier(
    KlantLeverancier klantLeverancier,
    int index,
  ) async {
    setState(() {
      klantLeverancier.gekozenArtikelen.removeAt(index);
    });

    await bewaarStatusVelden();
  }

  Future<void> bewaarKlantTaakTekst() async {
    widget.klant.toonKlantTaak = widget.klant.klantTaken.any(
      (taak) => taak.tekst.trim().isNotEmpty,
    );

    await _bewaarNieuweOfBestaandeKlant();
  }

  Future<void> openPlanningAgenda() async {
    await bewaarVelden();

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KlantPlanningPagina(
          klant: widget.klant,
          alleKlanten: widget.alleKlanten,
          vakantieDagen: widget.vakantieDagen,
          onBewaren: () async {
            await widget.onOpslaan(widget.klant);
          },
        ),
      ),
    );

    await widget.onGewijzigd();

    if (mounted) setState(() {});
  }

  Future<void> openExtraWerk() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExtraWerkPagina(
          klant: widget.klant,
          onGewijzigd: widget.onGewijzigd,
        ),
      ),
    );

    await widget.onGewijzigd();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> openKraanReserveren() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KraanReserverenPagina(
          klant: widget.klant,
          alleKlanten: widget.alleKlanten,
          vakantieDagen: widget.vakantieDagen,
          onGewijzigd: widget.onGewijzigd,
        ),
      ),
    );

    await widget.onGewijzigd();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> toonNieuwProjectOfNadienstVraag() async {
    if (!widget.isNieuweKlant) return;

    final keuze = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nieuwe klantenfiche'),
          content: const Text(
            'Gaat het om een nieuw project of een nadienst?',
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context, 'project');
              },
              icon: const Icon(Icons.business),
              label: const Text('Nieuw project'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context, 'nadienst');
              },
              icon: const Icon(Icons.support_agent),
              label: const Text('Nadienst'),
            ),
          ],
        );
      },
    );

    if (keuze == 'nadienst') {
      setState(() {
        widget.klant.isNadienst = true;
      });
    } else {
      setState(() {
        widget.klant.isNadienst = false;
      });
    }

    await bewaarStatusVelden();
  }

  Widget groeneBalk() {
    final naam = widget.klant.klantnaam.trim().isEmpty
        ? 'Nieuwe klant'
        : widget.klant.klantnaam;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0B7A3B),
            Color(0xFF23B15F),
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            iconSize: 30,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              widget.klant.isNadienst
                  ? 'Klantenfiche • $naam • Nadienst'
                  : 'Klantenfiche • $naam',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = StatusHelper.bepaalStatus(widget.klant);
    final kleur = StatusHelper.bepaalStatusKleur(status);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      bottomNavigationBar: OnderNavigatieBalk(
        huidigePagina: 'andere',
        onAgenda: () {
          Navigator.popUntil(context, (route) => route.isFirst);
          // later eventueel rechtstreeks naar agenda
        },
        onKlanten: () {
          Navigator.popUntil(context, (route) => route.isFirst);
          // later eventueel rechtstreeks naar klanten
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            groeneBalk(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  ActiesBlok(
                    klant: widget.klant,
                    heeftExtraWerk: widget.klant.extraWerkItems.any(
                      (item) => item.omschrijving.trim().isNotEmpty,
                    ),
                    isIngeplandStart: widget.klant.isOpTeVolgen
                        ? false
                        : widget.klant.planningDagen.isNotEmpty,
                    isKraanGereserveerd:
                        widget.klant.kraanReservering?.gereserveerd == true,
                    onAgenda: null,
                    onProjectAfgewerkt: handelProjectAfgewerktAf,
                    onProjectOpvolgen: handelProjectOpvolgenAf,
                    onExtraWerk: openExtraWerk,
                    onNadienst: handelNadienstAf,
                    onKraanReserveren: openKraanReserveren,
                  ),
                  const SizedBox(height: 18),
                  UitklapbareSectie(
                    titel: 'Klantgegevens',
                    icoon: Icons.person_outline,
                    geopend: toonKlantgegevensSectie,
                    onToggle: () {
                      setState(() {
                        toonKlantgegevensSectie = !toonKlantgegevensSectie;
                      });
                    },
                    children: [
                      KlantgegevensBlok(
                        klantenNrController: klantenNrController,
                        klantNaamController: klantNaamController,
                        adresController: adresController,
                        telefoonController: telefoonController,
                        emailController: emailController,
                        onChanged: bewaarVelden,
                      ),
                    ],
                  ),
                  if (widget.klant.isOpTeVolgen)
                    UitklapbareSectie(
                      titel: 'Nog af te werken',
                      icoon: Icons.pending_actions,
                      geopend: toonNogAfTeWerkenSectie,
                      onToggle: () {
                        setState(() {
                          toonNogAfTeWerkenSectie = !toonNogAfTeWerkenSectie;
                        });
                      },
                      children: [
                        TextField(
                          controller: nogAfTeWerkenController,
                          maxLines: 5,
                          onChanged: (_) async {
                            await bewaarVelden();
                          },
                          decoration: InputDecoration(
                            hintText: 'Typ hier wat nog af te werken is...',
                            filled: true,
                            fillColor: Colors.green.withOpacity(0.08),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  KlantTaakBlok(
                    geopend: toonKlantTaakSectie,
                    onToggle: () {
                      setState(() {
                        toonKlantTaakSectie = !toonKlantTaakSectie;
                      });
                    },
                    klantTaken: widget.klant.klantTaken,
                    geselecteerdMoment: widget.klant.klantTaakMoment,
                    onMomentChanged: wijzigKlantTaakMoment,
                    vrijeDatum: widget.klant.klantTaakVrijeDatum,
                    onVrijeDatumChanged: (datum) async {
                      setState(() {
                        widget.klant.klantTaakVrijeDatum = datum;
                        widget.klant.klantTaakMoment = 'vrijeDatum';
                      });

                      await bewaarVelden();
                    },
                    onChanged: bewaarKlantTaakTekst,
                  ),
                  OpmerkingenBlok(
                    geopend: toonOpmerkingenSectie,
                    onToggle: () {
                      setState(() {
                        toonOpmerkingenSectie = !toonOpmerkingenSectie;
                      });
                    },
                    toonOpmerkingen: widget.klant.toonOpmerkingen,
                    onToonOpmerkingenChanged: wijzigToonOpmerkingen,
                    opmerkingenController: opmerkingenController,
                    onChanged: bewaarVelden,
                  ),
                  UitklapbareSectie(
                    titel: 'Leveranciers en artikelen',
                    icoon: Icons.inventory_2_outlined,
                    geopend: toonLeveranciersSectie,
                    onToggle: () {
                      setState(() {
                        toonLeveranciersSectie = !toonLeveranciersSectie;
                      });
                    },
                    children: [
                      LeveranciersBlok(
                        klant: widget.klant,
                        leveranciers: widget.leveranciers,
                        onChanged: bewaarStatusVelden,
                        wijzigGeenArtikelsNodig: wijzigGeenArtikelsNodig,
                        voegLeverancierToe: voegLeverancierToeAanKlant,
                        wisLeverancier: wisKlantLeverancier,
                        voegArtikelToe: voegArtikelToeAanLeverancier,
                        wisArtikel: wisArtikelVanLeverancier,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
