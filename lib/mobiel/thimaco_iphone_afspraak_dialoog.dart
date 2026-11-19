import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../helpers/Agenda/agenda_item.dart';

/// Mobiel afspraakformulier: dezelfde AgendaItem-opslag als de bureau-agenda.
/// Tijd wordt met een digitale 24-uurs scrolklok gekozen.
class ThimacoIphoneAfspraakDialoog extends StatefulWidget {
  const ThimacoIphoneAfspraakDialoog({super.key, required this.datum});

  final DateTime datum;

  @override
  State<ThimacoIphoneAfspraakDialoog> createState() =>
      _ThimacoIphoneAfspraakDialoogState();
}

class _ThimacoIphoneAfspraakDialoogState
    extends State<ThimacoIphoneAfspraakDialoog> {
  static const Color _oranje = Color(0xFFF15A24);
  static const Color _donker = Color(0xFF20252B);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _subtekst = Color(0xFF66717D);

  static const List<(int, String)> _waarschuwingen = [
    (0, 'Geen'),
    (15, '15 min ervoor'),
    (30, '30 min ervoor'),
    (60, '1 uur ervoor'),
    (120, '2 uur ervoor'),
  ];

  final TextEditingController _klant = TextEditingController();
  final TextEditingController _notities = TextEditingController();
  late TimeOfDay _start;
  late TimeOfDay _eind;
  int _waarschuwing = 0;
  bool _heleDag = false;
  bool _showroom = false;
  bool _notitiesOpen = false;
  String? _fout;

  @override
  void initState() {
    super.initState();
    final nu = TimeOfDay.now();
    final startMinuten = ((nu.hour * 60 + nu.minute) ~/ 5) * 5;
    _start = TimeOfDay(hour: startMinuten ~/ 60, minute: startMinuten % 60);
    final eindMinuten = (startMinuten + 60).clamp(0, 1435).toInt();
    _eind = TimeOfDay(hour: eindMinuten ~/ 60, minute: eindMinuten % 60);
  }

  @override
  void dispose() {
    _klant.dispose();
    _notities.dispose();
    super.dispose();
  }

  String _uurTekst(TimeOfDay tijd) =>
      '${tijd.hour.toString().padLeft(2, '0')}:${tijd.minute.toString().padLeft(2, '0')}';

  int _minuten(TimeOfDay tijd) => tijd.hour * 60 + tijd.minute;

  Widget _cirkel(IconData icoon, String tooltip, VoidCallback actie) =>
      IconButton(
        tooltip: tooltip,
        onPressed: actie,
        style: IconButton.styleFrom(
          backgroundColor: _oranje,
          foregroundColor: Colors.white,
          minimumSize: const Size(37, 37),
          fixedSize: const Size(37, 37),
          padding: EdgeInsets.zero,
        ),
        icon: Icon(icoon, size: 22),
      );

  Future<void> _kiesTijd({required bool begin}) async {
    final gekozen = await toonThimacoAgendaKlok(
      context,
      begin ? _start : _eind,
      begin ? 'Starttijd' : 'Eindtijd',
    );
    if (!mounted || gekozen == null) return;
    setState(() {
      _fout = null;
      if (begin) {
        _start = gekozen;
        final eindMinuten = (_minuten(_start) + 60).clamp(0, 1435).toInt();
        _eind = TimeOfDay(hour: eindMinuten ~/ 60, minute: eindMinuten % 60);
      } else {
        _eind = gekozen;
      }
    });
  }

  Widget _tijdRegel(String titel, TimeOfDay waarde, {required bool begin}) =>
      InkWell(
        onTap: () => _kiesTijd(begin: begin),
        borderRadius: BorderRadius.circular(11),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: _rand),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(children: [
            Expanded(child: Text(titel,
                style: const TextStyle(color: _donker, fontSize: 14))),
            Text(_uurTekst(waarde),
                style: const TextStyle(
                  color: _donker,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                )),
            const SizedBox(width: 8),
            const Icon(Icons.unfold_more_rounded, color: _oranje, size: 21),
          ]),
        ),
      );

  void _bewaar() {
    final klantnaam = _klant.text.trim();
    if (klantnaam.isEmpty) {
      setState(() => _fout = 'Vul eerst een klantnaam in.');
      return;
    }
    if (!_heleDag && _minuten(_eind) <= _minuten(_start)) {
      setState(() => _fout = 'De eindtijd moet na de starttijd liggen.');
      return;
    }
    final afspraak = AgendaItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      titel: klantnaam,
      naamKlant: klantnaam,
      type: 'afspraak',
      afspraakSoort: _showroom ? 'showroom' : 'algemeen',
      bron: 'app',
      meldingVoorafMinuten: _waarschuwing,
      opmerkingen: _notities.text.trim(),
      volledigeDag: _heleDag,
      startUur: _heleDag ? null : _start.hour,
      startMinuut: _heleDag ? null : _start.minute,
      eindUur: _heleDag ? null : _eind.hour,
      eindMinuut: _heleDag ? null : _eind.minute,
    );
    Navigator.of(context).pop(AgendaItem.fromJson({
      ...afspraak.toJson(),
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    }));
  }

  Widget _keuzeSchakelaar(String label, bool gekozen, VoidCallback actie) =>
      InkWell(
        onTap: actie,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(children: [
            Expanded(child: Text(label,
                style: const TextStyle(color: _donker, fontSize: 14))),
            Icon(
              gekozen ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: gekozen ? _donker : _subtekst,
              size: 24,
            ),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.white,
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(children: [
            Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              color: _donker,
              child: Row(children: [
                _cirkel(Icons.close_rounded, 'Sluiten zonder opslaan',
                    () => Navigator.of(context).pop()),
                const Expanded(child: Center(
                  child: Text('Afspraak', style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700,
                    fontSize: 18,
                  )),
                )),
                _cirkel(Icons.check_rounded, 'Afspraak bewaren', _bewaar),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${widget.datum.day.toString().padLeft(2, '0')}/'
                      '${widget.datum.month.toString().padLeft(2, '0')}/'
                      '${widget.datum.year}',
                      style: const TextStyle(color: _subtekst, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _klant,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Klantnaam',
                        hintText: 'Naam van de klant',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: const BorderSide(color: _rand),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: const BorderSide(color: _oranje, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (!_heleDag) ...[
                      _tijdRegel('Starttijd', _start, begin: true),
                      const SizedBox(height: 9),
                      _tijdRegel('Eindtijd', _eind, begin: false),
                      const SizedBox(height: 12),
                    ],
                    _keuzeSchakelaar('Volledige dag', _heleDag,
                        () => setState(() => _heleDag = !_heleDag)),
                    _keuzeSchakelaar('Showroom', _showroom,
                        () => setState(() => _showroom = !_showroom)),
                    const Divider(color: _rand, height: 28),
                    const Text('Waarschuwing', style: TextStyle(
                      color: _donker, fontSize: 14, fontWeight: FontWeight.w400,
                    )),
                    const SizedBox(height: 9),
                    DropdownButtonFormField<int>(
                      initialValue: _waarschuwing,
                      isExpanded: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: const BorderSide(color: _rand),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: const BorderSide(color: _oranje),
                        ),
                      ),
                      items: [
                        for (final (minuten, titel) in _waarschuwingen)
                          DropdownMenuItem<int>(value: minuten,
                            child: Text(titel, style: const TextStyle(
                              color: _donker, fontSize: 14,
                            )),
                          ),
                      ],
                      onChanged: (waarde) {
                        if (waarde != null) setState(() => _waarschuwing = waarde);
                      },
                    ),
                    const Divider(color: _rand, height: 28),
                    InkWell(
                      borderRadius: BorderRadius.circular(9),
                      onTap: () => setState(() => _notitiesOpen = !_notitiesOpen),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(children: [
                          const Icon(Icons.notes_rounded,
                              color: _donker, size: 20),
                          const SizedBox(width: 8),
                          const Expanded(child: Text('Notities', style: TextStyle(
                            color: _donker, fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ))),
                          Icon(
                            _notitiesOpen ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: _oranje,
                          ),
                        ]),
                      ),
                    ),
                    if (_notitiesOpen) ...[
                      const SizedBox(height: 6),
                      TextField(
                        controller: _notities,
                        minLines: 3, maxLines: 6,
                        decoration: InputDecoration(
                          hintText: 'Notitie bij deze afspraak...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(11),
                            borderSide: const BorderSide(color: _rand),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(11),
                            borderSide: const BorderSide(color: _oranje),
                          ),
                        ),
                      ),
                    ],
                    if (_fout != null) ...[
                      const SizedBox(height: 12),
                      Text(_fout!, style: const TextStyle(
                        color: Color(0xFFB42318), fontSize: 12,
                      )),
                    ],
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

Future<TimeOfDay?> toonThimacoAgendaKlok(
  BuildContext context, TimeOfDay huidige, String titel,
) {
    const _oranje = Color(0xFFF15A24);
    const _donker = Color(0xFF20252B);
    var gekozen = TimeOfDay(hour: huidige.hour, minute: huidige.minute ~/ 5 * 5);
    return showModalBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                  child: Row(
                    children: [
                      Expanded(child: Text(titel,
                          style: const TextStyle(
                            color: _donker,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ))),
                      IconButton(
                        tooltip: 'Tijd kiezen',
                        onPressed: () => Navigator.of(sheetContext).pop(gekozen),
                        style: IconButton.styleFrom(
                          backgroundColor: _oranje, foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.check_rounded),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 224,
                  child: CupertinoTheme(
                    data: const CupertinoThemeData(
                      brightness: Brightness.light,
                      primaryColor: _oranje,
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      use24hFormat: true,
                      minuteInterval: 5,
                      initialDateTime: DateTime(
                        2026, 1, 1, gekozen.hour, gekozen.minute,
                      ),
                      onDateTimeChanged: (tijd) {
                        gekozen = TimeOfDay(hour: tijd.hour, minute: tijd.minute);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
