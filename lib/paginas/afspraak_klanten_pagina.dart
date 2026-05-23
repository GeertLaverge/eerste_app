import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../modellen/afspraak_klant.dart';
import '../helpers/app_storage.dart';

class AfspraakKlantenPagina extends StatefulWidget {
  final DateTime datum;
  final AfspraakKlant? bestaandeAfspraak;

  const AfspraakKlantenPagina({
    super.key,
    required this.datum,
    this.bestaandeAfspraak,
  });

  @override
  State<AfspraakKlantenPagina> createState() => _AfspraakKlantenPaginaState();
}

class _AfspraakKlantenPaginaState extends State<AfspraakKlantenPagina> {
  final klantNrController = TextEditingController();
  final klantNaamController = TextEditingController();
  final adresController = TextEditingController();
  final telefoonController = TextEditingController();
  final emailController = TextEditingController();
  final notitiesController = TextEditingController();

  bool ganseDag = false;

  int beginUur = 8;
  int beginMinuut = 0;
  int eindUur = 8;
  int eindMinuut = 0;

  String waarschuwing = 'Bij aanvang';

  List<AfspraakKlant> bestaandeAfspraken = [];

  late FixedExtentScrollController beginUurController;
  late FixedExtentScrollController beginMinuutController;
  late FixedExtentScrollController eindUurController;
  late FixedExtentScrollController eindMinuutController;

  final List<String> waarschuwingen = [
    'Geen waarschuwing',
    'Bij aanvang',
    '30 min vooraf',
    '1 uur vooraf',
    '2 uur vooraf',
  ];

  @override
  void initState() {
    super.initState();

    final bestaande = widget.bestaandeAfspraak;

    if (bestaande != null) {
      klantNrController.text = bestaande.klantNr;
      klantNaamController.text = bestaande.klantNaam;
      adresController.text = bestaande.adres;
      telefoonController.text = bestaande.telefoon;
      emailController.text = bestaande.email;
      notitiesController.text = bestaande.notities;

      ganseDag = bestaande.ganseDag;
      beginUur = bestaande.beginUur;
      beginMinuut = bestaande.beginMinuut;
      eindUur = bestaande.eindUur;
      eindMinuut = bestaande.eindMinuut;
      waarschuwing = bestaande.waarschuwing;
    }

    beginUurController = FixedExtentScrollController(initialItem: beginUur);
    beginMinuutController =
        FixedExtentScrollController(initialItem: beginMinuut ~/ 5);

    eindUurController = FixedExtentScrollController(initialItem: eindUur);
    eindMinuutController =
        FixedExtentScrollController(initialItem: eindMinuut ~/ 5);

    laadBestaandeAfspraken();
  }

  @override
  void dispose() {
    klantNrController.dispose();
    klantNaamController.dispose();
    adresController.dispose();
    telefoonController.dispose();
    emailController.dispose();
    notitiesController.dispose();

    beginUurController.dispose();
    beginMinuutController.dispose();
    eindUurController.dispose();
    eindMinuutController.dispose();

    super.dispose();
  }

  String datumTekst(DateTime datum) {
    return '${datum.day.toString().padLeft(2, '0')}/'
        '${datum.month.toString().padLeft(2, '0')}/'
        '${datum.year}';
  }

  Future<void> laadBestaandeAfspraken() async {
    final alles = await AppStorage.laadAfsprakenKlanten();

    if (!mounted) return;

    setState(() {
      bestaandeAfspraken = alles.where((afspraak) {
        return afspraak.datum.year == widget.datum.year &&
            afspraak.datum.month == widget.datum.month &&
            afspraak.datum.day == widget.datum.day &&
            afspraak.id != widget.bestaandeAfspraak?.id;
      }).toList();
    });
  }

  int minuten(int uur, int minuut) {
    return uur * 60 + minuut;
  }

  bool overlaptMetBestaandeAfspraak() {
    if (ganseDag) return bestaandeAfspraken.isNotEmpty;

    final nieuwStart = minuten(beginUur, beginMinuut);
    final nieuwEind = minuten(eindUur, eindMinuut);

    for (final afspraak in bestaandeAfspraken) {
      if (afspraak.ganseDag) return true;

      final bestaandStart = minuten(afspraak.beginUur, afspraak.beginMinuut);
      final bestaandEind = minuten(afspraak.eindUur, afspraak.eindMinuut);

      if (nieuwStart < bestaandEind && nieuwEind > bestaandStart) {
        return true;
      }
    }

    return false;
  }

  void toonFout(String tekst) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tekst),
        backgroundColor: Colors.red,
      ),
    );
  }

  bool isLeeg() {
    return klantNrController.text.trim().isEmpty &&
        klantNaamController.text.trim().isEmpty &&
        adresController.text.trim().isEmpty &&
        telefoonController.text.trim().isEmpty &&
        emailController.text.trim().isEmpty;
  }

  Future<void> bewaarEnSluit() async {
    if (isLeeg()) {
      if (mounted) {
        Navigator.pop(context, false);
      }
      return;
    }

    if (!ganseDag) {
      final start = minuten(beginUur, beginMinuut);
      final eind = minuten(eindUur, eindMinuut);

      if (eind < start) {
        toonFout('Eindtijd mag niet vroeger zijn dan begintijd.');
        return;
      }
    }

    if (overlaptMetBestaandeAfspraak()) {
      toonFout('Deze afspraak overlapt met een bestaande afspraak.');
      return;
    }

    final afspraken = await AppStorage.laadAfsprakenKlanten();

    final afspraak = AfspraakKlant(
      id: widget.bestaandeAfspraak?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      klantNr: klantNrController.text.trim(),
      klantNaam: klantNaamController.text.trim(),
      adres: adresController.text.trim(),
      telefoon: telefoonController.text.trim(),
      email: emailController.text.trim(),
      datum: DateTime(
        widget.datum.year,
        widget.datum.month,
        widget.datum.day,
      ),
      ganseDag: ganseDag,
      beginUur: beginUur,
      beginMinuut: beginMinuut,
      eindUur: eindUur,
      eindMinuut: eindMinuut,
      waarschuwing: waarschuwing,
      notities: notitiesController.text.trim(),
    );

    final index = afspraken.indexWhere((item) => item.id == afspraak.id);

    if (index >= 0) {
      afspraken[index] = afspraak;
    } else {
      afspraken.add(afspraak);
    }

    await AppStorage.bewaarAfsprakenKlanten(afspraken);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  Widget groeneBalk() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
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
            onPressed: bewaarEnSluit,
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Afspraak klanten',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  datumTekst(widget.datum),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.event_available,
            color: Colors.white,
            size: 30,
          ),
        ],
      ),
    );
  }

  Widget kaart(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget invoerVeld({
    required String label,
    required TextEditingController controller,
    TextInputType toetsenbord = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: toetsenbord,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget tijdKeuze({
    required String titel,
    required int uur,
    required int minuut,
    required FixedExtentScrollController uurController,
    required FixedExtentScrollController minuutController,
    required Function(int uur, int minuut) onChanged,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Text(
              titel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 130,
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: uurController,
                      itemExtent: 40,
                      diameterRatio: 1.2,
                      useMagnifier: true,
                      magnification: 1.05,
                      looping: true,
                      onSelectedItemChanged: (value) {
                        onChanged(value, minuut);
                      },
                      children: List.generate(
                        24,
                        (index) => Center(
                          child: Text(
                            index.toString().padLeft(2, '0'),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    ':',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: minuutController,
                      itemExtent: 40,
                      diameterRatio: 1.2,
                      useMagnifier: true,
                      magnification: 1.05,
                      looping: true,
                      onSelectedItemChanged: (value) {
                        onChanged(uur, value * 5);
                      },
                      children: List.generate(
                        12,
                        (index) => Center(
                          child: Text(
                            (index * 5).toString().padLeft(2, '0'),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
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

  Widget waarschuwingKeuze() {
    return DropdownButtonFormField<String>(
      value: waarschuwing,
      decoration: InputDecoration(
        labelText: 'Waarschuwing',
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      items: waarschuwingen.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          waarschuwing = value;
        });
      },
    );
  }

  Widget overzichtAfsprakenDezeDag() {
    return kaart([
      const Text(
        'Reeds geplande afspraken deze dag',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
      const SizedBox(height: 10),
      if (bestaandeAfspraken.isEmpty)
        Text(
          'Nog geen afspraken gepland.',
          style: TextStyle(color: Colors.grey.shade600),
        )
      else
        ...bestaandeAfspraken.map((afspraak) {
          final tijd = afspraak.ganseDag
              ? 'Ganse dag'
              : '${afspraak.beginUur.toString().padLeft(2, '0')}:'
                  '${afspraak.beginMinuut.toString().padLeft(2, '0')} - '
                  '${afspraak.eindUur.toString().padLeft(2, '0')}:'
                  '${afspraak.eindMinuut.toString().padLeft(2, '0')}';

          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.event_available,
                  color: Colors.blue,
                  size: 18,
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 90,
                  child: Text(
                    tijd,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    afspraak.klantNaam.isEmpty
                        ? 'Klant zonder naam'
                        : afspraak.klantNaam,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        }),
    ]);
  }

  Widget inhoud() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        kaart([
          const Text(
            'Klantgegevens',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 12),
          invoerVeld(
            label: 'Klantennr',
            controller: klantNrController,
          ),
          invoerVeld(
            label: 'Klantnaam',
            controller: klantNaamController,
          ),
          invoerVeld(
            label: 'Adres',
            controller: adresController,
          ),
          invoerVeld(
            label: 'Telefoon',
            controller: telefoonController,
            toetsenbord: TextInputType.phone,
          ),
          invoerVeld(
            label: 'Email',
            controller: emailController,
            toetsenbord: TextInputType.emailAddress,
          ),
        ]),
        kaart([
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Ganse dag',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Switch(
                value: ganseDag,
                activeColor: Colors.green,
                onChanged: (value) {
                  setState(() {
                    ganseDag = value;
                  });
                },
              ),
            ],
          ),
          if (!ganseDag) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                tijdKeuze(
                  titel: 'Begin',
                  uur: beginUur,
                  minuut: beginMinuut,
                  uurController: beginUurController,
                  minuutController: beginMinuutController,
                  onChanged: (uur, minuut) {
                    setState(() {
                      beginUur = uur;
                      beginMinuut = minuut;

                      final begin = minuten(beginUur, beginMinuut);
                      final einde = minuten(eindUur, eindMinuut);

                      if (einde < begin) {
                        eindUur = beginUur;
                        eindMinuut = beginMinuut;

                        eindUurController.jumpToItem(eindUur);
                        eindMinuutController.jumpToItem(eindMinuut ~/ 5);
                      }
                    });
                  },
                ),
                const SizedBox(width: 10),
                tijdKeuze(
                  titel: 'Einde',
                  uur: eindUur,
                  minuut: eindMinuut,
                  uurController: eindUurController,
                  minuutController: eindMinuutController,
                  onChanged: (uur, minuut) {
                    setState(() {
                      eindUur = uur;
                      eindMinuut = minuut;

                      final begin = minuten(beginUur, beginMinuut);
                      final einde = minuten(eindUur, eindMinuut);

                      if (einde < begin) {
                        eindUur = beginUur;
                        eindMinuut = beginMinuut;

                        eindUurController.jumpToItem(eindUur);
                        eindMinuutController.jumpToItem(eindMinuut ~/ 5);
                      }
                    });
                  },
                ),
              ],
            ),
          ],
        ]),
        overzichtAfsprakenDezeDag(),
        kaart([
          waarschuwingKeuze(),
          const SizedBox(height: 12),
          TextField(
            controller: notitiesController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Notities',
              alignLabelWithHint: true,
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        bewaarEnSluit();
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: SafeArea(
          child: Column(
            children: [
              groeneBalk(),
              Expanded(
                child: inhoud(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
