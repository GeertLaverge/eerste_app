import 'package:flutter/material.dart';

import 'agenda_item.dart';
import 'agenda_kleur_service.dart';
import 'agenda_tijd_helper.dart';
import 'agenda_tijd_picker.dart';

class AgendaToevoegPopup extends StatefulWidget {
  final AgendaItem? bestaandItem;
  final List<AgendaItem> geplandeItems;

  const AgendaToevoegPopup({
    super.key,
    this.bestaandItem,
    this.geplandeItems = const [],
  });

  @override
  State<AgendaToevoegPopup> createState() => _AgendaToevoegPopupState();
}

class _AgendaToevoegPopupState extends State<AgendaToevoegPopup> {
  final klantNrController = TextEditingController();

  final naamController = TextEditingController();

  final straatController = TextEditingController();

  final huisNrController = TextEditingController();

  final gemeenteController = TextEditingController();

  final postcodeController = TextEditingController();

  final gsmController = TextEditingController();

  final gsm2Controller = TextEditingController();

  final emailController = TextEditingController();

  final opmerkingenController = TextEditingController();

  final titelController = TextEditingController();
  String type = 'afspraak';

  TimeOfDay startTijd = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay eindTijd = const TimeOfDay(hour: 15, minute: 30);

  bool volledigeDag = false;

  bool get isBewerken => widget.bestaandItem != null;

  @override
  void initState() {
    super.initState();

    final item = widget.bestaandItem;

    if (item != null) {
      titelController.text = item.titel;

      klantNrController.text = item.klantNr;

      naamController.text = item.naamKlant;

      straatController.text = item.straatnaam;

      huisNrController.text = item.huisNr;

      gemeenteController.text = item.gemeente;

      postcodeController.text = item.postcode;

      gsmController.text = item.gsm;

      gsm2Controller.text = item.gsm2;

      emailController.text = item.email;

      opmerkingenController.text = item.opmerkingen;

      if (item.type == 'afspraak' ||
          item.type == 'dagtaak' ||
          item.type == 'verlof' ||
          item.type == 'kraan') {
        type = item.type;
      }

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
  }

  @override
  void dispose() {
    klantNrController.dispose();

    naamController.dispose();

    straatController.dispose();

    huisNrController.dispose();

    gemeenteController.dispose();

    postcodeController.dispose();

    gsmController.dispose();

    gsm2Controller.dispose();

    emailController.dispose();

    opmerkingenController.dispose();

    titelController.dispose();

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

    await kiesEindTijd();
  }

  Future<void> kiesEindTijd() async {
    final gekozen = await AgendaTijdPicker.kiesTijd(
      context: context,
      titel: 'Eindtijd',
      beginTijd: eindTijd,
    );

    if (gekozen == null) return;

    if (minuten(gekozen) < minuten(startTijd)) {
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

  void opslaan() {
    final titel = naamController.text.trim();

    if (titel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Geef een naam klant in.'),
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
        titel: titel,
        type: type,
        klantNr: klantNrController.text.trim(),
        naamKlant: naamController.text.trim(),
        straatnaam: straatController.text.trim(),
        huisNr: huisNrController.text.trim(),
        gemeente: gemeenteController.text.trim(),
        postcode: postcodeController.text.trim(),
        gsm: gsmController.text.trim(),
        gsm2: gsm2Controller.text.trim(),
        email: emailController.text.trim(),
        opmerkingen: opmerkingenController.text.trim(),
        volledigeDag: volledigeDag,
        startUur: volledigeDag ? null : startTijd.hour,
        startMinuut: volledigeDag ? null : startTijd.minute,
        eindUur: volledigeDag ? null : eindTijd.hour,
        eindMinuut: volledigeDag ? null : eindTijd.minute,
      ),
    );
  }

  void verplaatsen() {
    Navigator.pop(context, 'verplaatsen');
  }

  void verwijderen() {
    Navigator.pop(context, 'verwijderen');
  }

  DropdownMenuItem<String> itemType(
    String waarde,
    String tekst,
  ) {
    final kleur = AgendaKleurService.kleur(waarde);

    return DropdownMenuItem(
      value: waarde,
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: kleur,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: 10),
          Text(tekst),
        ],
      ),
    );
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

  Widget geplandeTakenBlok() {
    if (widget.geplandeItems.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Reeds gepland',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 6),
          ...widget.geplandeItems.map((item) {
            final kleur = AgendaKleurService.kleur(item.type);

            return Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  Text(
                    item.tijdTekst,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  if (item.tijdTekst.isNotEmpty) const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: kleur,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.titel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> sluitFormulier() async {
    if (naamController.text.trim().isNotEmpty) {
      opslaan();
      return;
    }

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
                  const Text(
                    'Er is nog geen naam ingevuld.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
                    Icon(
                      isBewerken ? Icons.edit_calendar : Icons.add_circle,
                      color: const Color(0xFF0B7A3B),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isBewerken ? 'Item bewerken' : 'Item toevoegen',
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
                  klantNrController,
                  'Klantnr',
                ),
                veld(
                  naamController,
                  'Naam klant',
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: veld(
                        straatController,
                        'Straat',
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: veld(
                        huisNrController,
                        'Nr',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: veld(
                        gemeenteController,
                        'Gemeente',
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: veld(
                        postcodeController,
                        'Postcode',
                      ),
                    ),
                  ],
                ),
                veld(
                  gsmController,
                  'GSM',
                ),
                veld(
                  gsm2Controller,
                  'GSM 2',
                ),
                veld(
                  emailController,
                  'Email',
                ),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  items: [
                    itemType('afspraak', 'Afspraak'),
                    itemType('dagtaak', 'Dagtaak'),
                    itemType('verlof', 'Verlof'),
                  ],
                  onChanged: (waarde) {
                    if (waarde == null) {
                      return;
                    }

                    setState(() {
                      type = waarde;

                      if (waarde == 'verlof') {
                        volledigeDag = true;
                        naamController.text = 'Verlof';
                      }

                      if (waarde == 'afspraak' ||
                          waarde == 'dagtaak' ||
                          waarde == 'kraan') {
                        volledigeDag = false;
                      }
                    });
                  },
                ),
                const SizedBox(height: 10),
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
                geplandeTakenBlok(),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: opslaan,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 50),
                      backgroundColor: const Color(0xFF0B7A3B),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isBewerken ? 'Opslaan' : 'Toevoegen'),
                  ),
                ),
                if (isBewerken) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: opslaan,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 50),
                        backgroundColor: const Color(
                          0xFF0B7A3B,
                        ),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        isBewerken ? 'Opslaan' : 'Toevoegen',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
