import 'package:flutter/material.dart';

import 'agenda_item.dart';
import 'agenda_tijd_helper.dart';
import 'agenda_tijd_picker.dart';

class AgendaVerlofPopup extends StatefulWidget {
  final AgendaItem? bestaandItem;

  const AgendaVerlofPopup({
    super.key,
    this.bestaandItem,
  });

  @override
  State<AgendaVerlofPopup> createState() => _AgendaVerlofPopupState();
}

class _AgendaVerlofPopupState extends State<AgendaVerlofPopup> {
  final naamController = TextEditingController(text: 'Verlof');

  TimeOfDay startTijd = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay eindTijd = const TimeOfDay(hour: 15, minute: 30);

  bool volledigeDag = true;

  bool get isBewerken => widget.bestaandItem != null;

  @override
  void initState() {
    super.initState();

    final item = widget.bestaandItem;

    if (item == null) return;

    naamController.text = item.titel;
    volledigeDag = item.volledigeDag;

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
  }

  @override
  void dispose() {
    naamController.dispose();
    super.dispose();
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

  Widget veld(
    TextEditingController controller,
    String label,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              14,
            ),
          ),
        ),
      ),
    );
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
                        : 'Verlof wordt niet toegevoegd.',
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

  void opslaan() {
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

    if (!volledigeDag && minuten(eindTijd) <= minuten(startTijd)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Eindtijd moet later zijn dan starttijd.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      AgendaItem(
        titel: naam,
        type: 'verlof',
        volledigeDag: volledigeDag,
        startUur: volledigeDag ? null : startTijd.hour,
        startMinuut: volledigeDag ? null : startTijd.minute,
        eindUur: volledigeDag ? null : eindTijd.hour,
        eindMinuut: volledigeDag ? null : eindTijd.minute,
      ),
    );
  }

  void verwijderen() {
    Navigator.pop(
      context,
      'verwijderen',
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.beach_access,
                      color: Color(0xFF0B7A3B),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isBewerken ? 'Verlof bewerken' : 'Verlof toevoegen',
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
                const SizedBox(height: 12),
                veld(
                  naamController,
                  'Naam',
                ),
                SwitchListTile(
                  value: volledigeDag,
                  activeColor: const Color(0xFF0B7A3B),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (waarde) {
                    setState(() {
                      volledigeDag = waarde;
                    });
                  },
                  title: const Text(
                    'Volledige dag',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (!volledigeDag) ...[
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
                const SizedBox(height: 8),
                Column(
                  children: [
                    if (isBewerken) ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: verwijderen,
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          label: const Text(
                            'Verlof verwijderen',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: opslaan,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 50),
                          backgroundColor: const Color(0xFF0B7A3B),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          isBewerken ? 'Opslaan' : 'Toevoegen',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
