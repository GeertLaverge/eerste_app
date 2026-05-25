import 'package:flutter/material.dart';

import 'agenda_dagtaak_helper.dart';
import 'agenda_dagtaak_template.dart';
import 'agenda_item.dart';
import 'agenda_tijd_helper.dart';
import 'agenda_tijd_picker.dart';

class AgendaDagtaakPopup extends StatefulWidget {
  final AgendaItem? bestaandItem;

  const AgendaDagtaakPopup({
    super.key,
    this.bestaandItem,
  });

  @override
  State<AgendaDagtaakPopup> createState() => _AgendaDagtaakPopupState();
}

class _AgendaDagtaakPopupState extends State<AgendaDagtaakPopup> {
  final naamController = TextEditingController();

  List<AgendaDagtaakTemplate> templates = [];

  bool nieuweDagtaak = false;
  bool heeftTijd = false;
  String homeKeuze = 'zelfdeDag';

  final dagenController = TextEditingController(
    text: '1',
  );

  DateTime? gekozenHomeDatum;

  TimeOfDay startTijd = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay eindTijd = const TimeOfDay(hour: 15, minute: 30);

  bool get isBewerken => widget.bestaandItem != null;

  @override
  void initState() {
    super.initState();

    final item = widget.bestaandItem;

    if (item != null) {
      naamController.text = item.titel;
      nieuweDagtaak = true;
      heeftTijd = !item.volledigeDag;

      if (item.startUur != null && item.startMinuut != null) {
        startTijd = TimeOfDay(
          hour: item.startUur!,
          minute: item.startMinuut!,
        );
      }

      if (item.eindUur != null && item.eindMinuut != null) {
        eindTijd = TimeOfDay(
          hour: item.eindUur!,
          minute: item.eindMinuut!,
        );
      }

      homeKeuze = item.homeWeergaveType;
      dagenController.text = item.dagenVooraf.toString();

      if (item.homeDatum.isNotEmpty) {
        gekozenHomeDatum = DateTime.tryParse(item.homeDatum);
      }
    }

    laadTemplates();
  }

  @override
  void dispose() {
    naamController.dispose();
    dagenController.dispose();
    super.dispose();
  }

  Future<void> laadTemplates() async {
    final geladen = await AgendaDagtaakHelper.laad();

    if (!mounted) return;

    setState(() {
      templates = geladen;
    });
  }

  int minuten(TimeOfDay tijd) {
    return tijd.hour * 60 + tijd.minute;
  }

  Future<void> kiesStartTijd() async {
    final gekozen = await AgendaTijdPicker.kiesTijd(
      context: context,
      titel: 'Starttijd',
      beginTijd: startTijd,
    );

    if (gekozen == null) return;

    setState(() {
      startTijd = gekozen;
      eindTijd = gekozen;
    });

    await kiesEindTijd();
  }

  Future<void> kiesEindTijd() async {
    final gekozen = await AgendaTijdPicker.kiesTijd(
      context: context,
      titel: 'Eindtijd',
      beginTijd: eindTijd,
    );

    if (gekozen == null) return;

    if (minuten(gekozen) <= minuten(startTijd)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Eindtijd moet later zijn dan starttijd.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      eindTijd = gekozen;
    });
  }

  Future<void> sluitFormulier() async {
    final annuleren = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: SizedBox(
            width: 395,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFF0B7A3B),
                    size: 34,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Annuleren zonder toevoegen?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isBewerken
                        ? 'Wijzigingen worden niet opgeslagen.'
                        : 'Dagtaak wordt niet toegevoegd.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: const Text('Nee'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B7A3B),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Ja'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (annuleren == true && mounted) {
      Navigator.pop(context);
    }
  }

  Widget tijdKaart({
    required String titel,
    required TimeOfDay tijd,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                titel,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              AgendaTijdHelper.timeOfDayTekst(tijd),
              style: const TextStyle(
                color: Color(0xFF0B7A3B),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.access_time,
              color: Color(0xFF0B7A3B),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String homeDatumTekst() {
    if (gekozenHomeDatum == null) {
      return '';
    }

    return '${gekozenHomeDatum!.year.toString().padLeft(4, '0')}-'
        '${gekozenHomeDatum!.month.toString().padLeft(2, '0')}-'
        '${gekozenHomeDatum!.day.toString().padLeft(2, '0')}';
  }

  int aantalDagenVooraf() {
    return int.tryParse(dagenController.text.trim()) ?? 0;
  }

  AgendaItem maakItem() {
    return AgendaItem(
      titel: naamController.text.trim(),
      type: 'dagtaak',
      volledigeDag: !heeftTijd,
      startUur: heeftTijd ? startTijd.hour : null,
      startMinuut: heeftTijd ? startTijd.minute : null,
      eindUur: heeftTijd ? eindTijd.hour : null,
      eindMinuut: heeftTijd ? eindTijd.minute : null,
      homeWeergaveType: homeKeuze,
      dagenVooraf: homeKeuze == 'dagenVooraf' ? aantalDagenVooraf() : 0,
      homeDatum: homeKeuze == 'datum' ? homeDatumTekst() : '',
    );
  }

  Future<void> plaatsInAgenda({
    required bool bewaren,
  }) async {
    final naam = naamController.text.trim();

    if (naam.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Geef een naam in.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (heeftTijd && minuten(eindTijd) <= minuten(startTijd)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Eindtijd moet later zijn dan starttijd.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (homeKeuze == 'datum' && gekozenHomeDatum == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kies een datum voor de homepagina.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (bewaren && !isBewerken) {
      await AgendaDagtaakHelper.bewaar(
        AgendaDagtaakTemplate(
          id: AgendaDagtaakHelper.nieuwId(),
          naam: naam,
          heeftTijd: heeftTijd,
          startUur: heeftTijd ? startTijd.hour : null,
          startMinuut: heeftTijd ? startTijd.minute : null,
          eindUur: heeftTijd ? eindTijd.hour : null,
          eindMinuut: heeftTijd ? eindTijd.minute : null,
        ),
      );
    }

    if (!mounted) return;

    Navigator.pop(
      context,
      maakItem(),
    );
  }

  void kiesTemplate(AgendaDagtaakTemplate template) {
    setState(() {
      naamController.text = template.naam;
      heeftTijd = template.heeftTijd;

      if (template.startUur != null && template.startMinuut != null) {
        startTijd = TimeOfDay(
          hour: template.startUur!,
          minute: template.startMinuut!,
        );
      }

      if (template.eindUur != null && template.eindMinuut != null) {
        eindTijd = TimeOfDay(
          hour: template.eindUur!,
          minute: template.eindMinuut!,
        );
      }

      nieuweDagtaak = true;
    });
  }

  Future<void> verwijderTemplate(AgendaDagtaakTemplate template) async {
    await AgendaDagtaakHelper.verwijder(template.id);
    await laadTemplates();
  }

  Widget formulierBlok() {
    if (!nieuweDagtaak && naamController.text.isEmpty) {
      return const SizedBox();
    }

    return Column(
      children: [
        TextField(
          controller: naamController,
          decoration: InputDecoration(
            labelText: 'Naam',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFE7F6EC),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      heeftTijd = false;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: !heeftTijd
                          ? const Color(0xFF0B7A3B)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        'Taak zonder tijd',
                        style: TextStyle(
                          color: !heeftTijd ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      heeftTijd = true;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: heeftTijd
                          ? const Color(0xFF0B7A3B)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        'Taak met tijd',
                        style: TextStyle(
                          color: heeftTijd ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (heeftTijd) ...[
          const SizedBox(height: 10),
          tijdKaart(
            titel: 'Starttijd',
            tijd: startTijd,
            onTap: kiesStartTijd,
          ),
          tijdKaart(
            titel: 'Eindtijd',
            tijd: eindTijd,
            onTap: kiesEindTijd,
          ),
        ],
        const SizedBox(height: 14),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Tonen op homepagina',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE7F6EC),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              RadioListTile<String>(
                activeColor: const Color(0xFF0B7A3B),
                value: 'zelfdeDag',
                groupValue: homeKeuze,
                title: const Text('Zelfde dag'),
                onChanged: (value) {
                  setState(() {
                    homeKeuze = value!;
                    gekozenHomeDatum = null;
                  });
                },
              ),
              RadioListTile<String>(
                activeColor: const Color(0xFF0B7A3B),
                value: 'dagenVooraf',
                groupValue: homeKeuze,
                title: const Text('Zoveel dagen vooraf'),
                onChanged: (value) {
                  setState(() {
                    homeKeuze = value!;
                    gekozenHomeDatum = null;
                  });
                },
              ),
              if (homeKeuze == 'dagenVooraf')
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: dagenController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Aantal dagen',
                    ),
                  ),
                ),
              RadioListTile<String>(
                activeColor: const Color(0xFF0B7A3B),
                value: 'datum',
                groupValue: homeKeuze,
                title: Text(
                  gekozenHomeDatum == null
                      ? 'Kies datum'
                      : 'Gekozen datum ${gekozenHomeDatum!.day}/${gekozenHomeDatum!.month}/${gekozenHomeDatum!.year}',
                  style: TextStyle(
                    color:
                        homeKeuze == 'datum' ? Colors.black87 : Colors.black38,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onChanged: (value) async {
                  setState(() {
                    homeKeuze = value!;
                  });

                  final datum = await showDatePicker(
                    context: context,
                    builder: (
                      context,
                      child,
                    ) {
                      return Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFF0B7A3B),
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            onSurface: Colors.black,
                          ),
                        ),
                        child: child!,
                      );
                    },
                    initialDate: gekozenHomeDatum ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2050),
                  );

                  if (datum == null) return;

                  setState(() {
                    gekozenHomeDatum = datum;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget vasteKnoppen() {
    if (!nieuweDagtaak && naamController.text.isEmpty) {
      return const SizedBox();
    }

    return Column(
      children: [
        if (isBewerken) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(
                  context,
                  'verwijderen',
                );
              },
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
              label: const Text(
                'Dagtaak verwijderen',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              plaatsInAgenda(
                bewaren: false,
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            child: Text(
              isBewerken
                  ? 'Wijzigingen opslaan'
                  : 'Plaats in agenda zonder te bewaren',
            ),
          ),
        ),
        if (!isBewerken) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                plaatsInAgenda(
                  bewaren: true,
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 50),
                backgroundColor: const Color(0xFF0B7A3B),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Plaats in agenda en bewaar',
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget keuzeBlok() {
    if (nieuweDagtaak || isBewerken) {
      return const SizedBox();
    }

    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey.shade300,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Opgeslagen dagtaken',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 10),
              if (templates.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  child: Text(
                    'Nog geen opgeslagen dagtaken',
                    style: TextStyle(
                      color: Colors.black45,
                    ),
                  ),
                ),
              if (templates.isNotEmpty)
                ...templates.map(
                  (template) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                kiesTemplate(template);
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 46),
                                alignment: Alignment.centerLeft,
                              ),
                              child: Text(
                                template.naam,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              await verwijderTemplate(template);
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                nieuweDagtaak = true;
                naamController.clear();
                heeftTijd = false;
                homeKeuze = 'zelfdeDag';
                gekozenHomeDatum = null;
                dagenController.text = '1';
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Nieuwe dagtaak aanmaken'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 48),
              backgroundColor: const Color(0xFF0B7A3B),
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 460,
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.78,
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.task_alt,
                      color: Color(0xFF0B7A3B),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isBewerken ? 'Dagtaak bewerken' : 'Kies dagtaak',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: sluitFormulier,
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        keuzeBlok(),
                        formulierBlok(),
                      ],
                    ),
                  ),
                ),
                vasteKnoppen(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
