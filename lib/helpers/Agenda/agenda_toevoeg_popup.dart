import 'package:flutter/material.dart';

import 'agenda_item.dart';
import 'agenda_kleur_service.dart';
import 'agenda_tijd_helper.dart';
import 'agenda_tijd_picker.dart';
import '../adres/postcode_helper.dart';

class AgendaToevoegPopup extends StatefulWidget {
  final AgendaItem? bestaandItem;
  final List<AgendaItem> geplandeItems;
  final String? vastType;
  final bool isHeropendeNieuwePlanning;

  const AgendaToevoegPopup({
    super.key,
    this.bestaandItem,
    this.geplandeItems = const [],
    this.vastType,
    this.isHeropendeNieuwePlanning = false,
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
  final gemeenteFocusNode = FocusNode();
  final postcodeFocusNode = FocusNode();

  String type = 'afspraak';
  String meldingVooraf = '1 uur';
  bool notitiesOpen = false;

  TimeOfDay startTijd = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay eindTijd = const TimeOfDay(hour: 15, minute: 30);

  bool volledigeDag = false;

  bool get isBewerken => widget.bestaandItem != null;

  bool get isNieuwePlanningMetFout {
    return widget.bestaandItem != null &&
        widget.bestaandItem!.id.trim().isEmpty;
  }

  String get formulierTitel {
    if (type == 'dagtaak') {
      return isBewerken ? 'Dagtaak wijzigen' : 'Dagtaak';
    }

    if (type == 'verlof') {
      return isBewerken ? 'Verlof wijzigen' : 'Verlof';
    }

    return isBewerken ? 'Afspraak klant wijzigen' : 'Afspraak klant';
  }

  IconData get formulierIcoon {
    if (type == 'dagtaak') {
      return isBewerken ? Icons.edit_note_rounded : Icons.task_alt_rounded;
    }

    if (type == 'verlof') {
      return isBewerken ? Icons.edit_calendar : Icons.beach_access_rounded;
    }

    return isBewerken ? Icons.edit_calendar : Icons.add_circle;
  }

  @override
  void initState() {
    super.initState();

    final item = widget.bestaandItem;

    if (widget.vastType != null) {
      type = widget.vastType!;
    }

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

      type = item.type;

      volledigeDag = item.volledigeDag;

      if (item.startUur != null && item.startMinuut != null) {
        startTijd = TimeOfDay(hour: item.startUur!, minute: item.startMinuut!);
      }

      if (item.eindUur != null && item.eindMinuut != null) {
        eindTijd = TimeOfDay(hour: item.eindUur!, minute: item.eindMinuut!);
      }
      switch (item.meldingVoorafMinuten) {
        case 0:
          meldingVooraf = 'Geen';
          break;
        case 15:
          meldingVooraf = '15 min';
          break;
        case 30:
          meldingVooraf = '30 min';
          break;
        case 60:
          meldingVooraf = '1 uur';
          break;
        case 120:
          meldingVooraf = '2 uur';
          break;
      }
    }
    postcodeController.addListener(_postcodeGewijzigd);
    gemeenteController.addListener(_gemeenteGewijzigd);
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
    gemeenteFocusNode.dispose();
    postcodeFocusNode.dispose();
  }

  int minuten(TimeOfDay tijd) {
    return tijd.hour * 60 + tijd.minute;
  }

  bool _bezigMetInvullen = false;

  void _postcodeGewijzigd() {
    if (_bezigMetInvullen) return;

    if (postcodeController.text.trim().length != 4) return;

    final gemeente = PostcodeHelper.eersteGemeenteVanPostcode(
      postcodeController.text,
    );

    if (gemeente == null) return;

    _bezigMetInvullen = true;

    gemeenteController.text = gemeente;

    _bezigMetInvullen = false;
  }

  void _gemeenteGewijzigd() {
    if (_bezigMetInvullen) return;

    final postcode = PostcodeHelper.postcodeVanGemeente(
      gemeenteController.text,
    );

    if (postcode == null) return;

    _bezigMetInvullen = true;

    postcodeController.text = postcode;

    _bezigMetInvullen = false;
  }

  Future<void> kiesStartTijd() async {
    final gekozen = await AgendaTijdPicker.kiesTijd(
      context: context,
      titel: 'Starttijd',
      beginTijd: startTijd,
    );

    if (gekozen == null) return;

    final startMinuten = gekozen.hour * 60 + gekozen.minute;
    final eindMinuten = startMinuten + 60;

    setState(() {
      startTijd = gekozen;

      eindTijd = TimeOfDay(
        hour: (eindMinuten ~/ 60) % 24,
        minute: eindMinuten % 60,
      );
    });
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

    final nu = DateTime.now().toIso8601String();

    final bestaandId = widget.bestaandItem?.id ?? '';

    final itemId = bestaandId.trim().isNotEmpty
        ? bestaandId
        : DateTime.now().microsecondsSinceEpoch.toString();

    Navigator.pop(
      context,
      AgendaItem(
        id: itemId,
        updatedAt: nu,
        deletedAt: '',
        titel: titel,
        type: type,
        meldingVoorafMinuten: switch (meldingVooraf) {
          'Geen' => 0,
          '15 min' => 15,
          '30 min' => 30,
          '1 uur' => 60,
          '2 uur' => 120,
          _ => 60,
        },
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

  DropdownMenuItem<String> itemType(String waarde, String tekst) {
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

  Widget veld(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: label,
          isDense: true,
          contentPadding: const EdgeInsets.fromLTRB(0, 8, 0, 6),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF0B7A3B), width: 1.6),
          ),
        ),
      ),
    );
  }

  Widget gemeenteVeld() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RawAutocomplete<String>(
        textEditingController: gemeenteController,
        focusNode: gemeenteFocusNode,
        optionsBuilder: (waarde) {
          if (waarde.text.trim().isEmpty) {
            return const Iterable<String>.empty();
          }

          return PostcodeHelper.zoekGemeenten(waarde.text).take(8);
        },
        onSelected: (selectie) {
          _bezigMetInvullen = true;
          gemeenteController.text = selectie;

          final postcode = PostcodeHelper.postcodeVanGemeente(selectie);
          if (postcode != null) {
            postcodeController.text = postcode;
          }

          _bezigMetInvullen = false;
        },
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: 'Gemeente',
              isDense: true,
              contentPadding: const EdgeInsets.fromLTRB(0, 8, 0, 6),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF0B7A3B), width: 1.6),
              ),
            ),
          );
        },
        optionsViewBuilder: (context, onSelected, opties) {
          return Material(
            elevation: 4,
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: opties.map((optie) {
                return ListTile(
                  dense: true,
                  title: Text(optie),
                  onTap: () => onSelected(optie),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget postcodeVeld() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RawAutocomplete<String>(
        textEditingController: postcodeController,
        focusNode: postcodeFocusNode,
        optionsBuilder: (waarde) {
          if (waarde.text.trim().isEmpty) {
            return const Iterable<String>.empty();
          }

          return PostcodeHelper.zoekPostcodes(waarde.text).take(8);
        },
        onSelected: (selectie) {
          final postcode = PostcodeHelper.postcodeUitSuggestie(selectie);

          _bezigMetInvullen = true;
          postcodeController.text = postcode;

          final gemeente = PostcodeHelper.eersteGemeenteVanPostcode(postcode);
          if (gemeente != null) {
            gemeenteController.text = gemeente;
          }

          _bezigMetInvullen = false;
        },
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Postcode',
              isDense: true,
              contentPadding: const EdgeInsets.fromLTRB(0, 8, 0, 6),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF0B7A3B), width: 1.6),
              ),
            ),
          );
        },
        optionsViewBuilder: (context, onSelected, opties) {
          return Material(
            elevation: 4,
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: opties.map((optie) {
                return ListTile(
                  dense: true,
                  title: Text(optie),
                  onTap: () => onSelected(optie),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget tijdRegel({
    required IconData icoon,
    required String titel,
    required String waarde,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 6),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade400)),
          ),
          child: Row(
            children: [
              Icon(icoon, color: const Color(0xFF0B7A3B), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                waarde,
                style: const TextStyle(
                  color: Color(0xFF0B7A3B),
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF0B7A3B),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget meldingRegel() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 6),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade400)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.notifications_none,
              color: Color(0xFF0B7A3B),
              size: 20,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Melding vooraf',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: meldingVooraf,
                isDense: true,
                items: const [
                  DropdownMenuItem(value: 'Geen', child: Text('Geen')),
                  DropdownMenuItem(value: '15 min', child: Text('15 min')),
                  DropdownMenuItem(value: '30 min', child: Text('30 min')),
                  DropdownMenuItem(value: '1 uur', child: Text('1 uur')),
                  DropdownMenuItem(value: '2 uur', child: Text('2 uur')),
                ],
                onChanged: (waarde) {
                  if (waarde == null) return;

                  setState(() {
                    meldingVooraf = waarde;
                  });
                },
                style: const TextStyle(
                  color: Color(0xFF0B7A3B),
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget notitiesBlok() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              notitiesOpen = !notitiesOpen;
            });
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 6),
            child: Row(
              children: [
                Icon(
                  notitiesOpen
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_right,
                  color: const Color(0xFF0B7A3B),
                ),
                const SizedBox(width: 6),
                const Text(
                  "Notitie's",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
        if (notitiesOpen)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TextField(
              controller: opmerkingenController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Notitie's",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
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
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Er is nog geen naam ingevuld.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 14),
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(formulierIcoon, color: const Color(0xFF0B7A3B)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        formulierTitel,
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
                veld(klantNrController, 'Klantnr'),
                veld(naamController, 'Naam klant'),
                Row(
                  children: [
                    Expanded(flex: 3, child: veld(straatController, 'Straat')),
                    const SizedBox(width: 8),
                    Expanded(child: veld(huisNrController, 'Nr')),
                  ],
                ),
                Row(
                  children: [
                    Expanded(flex: 3, child: gemeenteVeld()),
                    const SizedBox(width: 8),
                    Expanded(child: postcodeVeld()),
                  ],
                ),
                veld(gsmController, 'GSM'),
                veld(gsm2Controller, 'GSM 2'),
                veld(emailController, 'Email'),
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
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                if (!volledigeDag) ...[
                  tijdRegel(
                    icoon: Icons.access_time,
                    titel: 'Starttijd',
                    waarde: AgendaTijdHelper.timeOfDayTekst(startTijd),
                    onTap: kiesStartTijd,
                  ),
                  tijdRegel(
                    icoon: Icons.access_time,
                    titel: 'Eindtijd',
                    waarde: AgendaTijdHelper.timeOfDayTekst(eindTijd),
                    onTap: kiesEindTijd,
                  ),
                  meldingRegel(),
                ],
                geplandeTakenBlok(),
                const SizedBox(height: 8),
                if (widget.isHeropendeNieuwePlanning) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: const Text('Planning annuleren'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                notitiesBlok(),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
