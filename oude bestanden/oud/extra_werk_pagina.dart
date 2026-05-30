import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../lib/helpers/widgets/onder_navigatie_balk.dart';
import '../../lib/modellen/klant.dart';

class ExtraWerkPagina extends StatefulWidget {
  final Klant klant;
  final Future<void> Function() onGewijzigd;

  const ExtraWerkPagina({
    super.key,
    required this.klant,
    required this.onGewijzigd,
  });

  @override
  State<ExtraWerkPagina> createState() => _ExtraWerkPaginaState();
}

class _ExtraWerkPaginaState extends State<ExtraWerkPagina> {
  final List<TextEditingController> controllers = [];

  @override
  void initState() {
    super.initState();

    if (widget.klant.extraWerkItems.isEmpty) {
      widget.klant.extraWerkItems.add(
        ExtraWerkItem(
          datum: DateTime.now(),
          startUur: 7,
          startMinuut: 0,
          eindUur: 7,
          eindMinuut: 0,
          omschrijving: '',
        ),
      );
    }

    for (final item in widget.klant.extraWerkItems) {
      controllers.add(TextEditingController(text: item.omschrijving));
    }
  }

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> opslaan() async {
    await widget.onGewijzigd();
    if (mounted) setState(() {});
  }

  String datumTekst(DateTime? datum) {
    if (datum == null) return 'Datum kiezen';

    return '${datum.day.toString().padLeft(2, '0')}/'
        '${datum.month.toString().padLeft(2, '0')}/'
        '${datum.year}';
  }

  String tijdTekst(int? uur, int? minuut) {
    if (uur == null || minuut == null) return '';

    return '${uur.toString().padLeft(2, '0')}:'
        '${minuut.toString().padLeft(2, '0')}';
  }

  Future<void> kiesDatum(int index) async {
    final gekozen = await showDatePicker(
      context: context,
      initialDate: widget.klant.extraWerkItems[index].datum ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (gekozen == null) return;

    widget.klant.extraWerkItems[index].datum = gekozen;
    await opslaan();
  }

  Future<TimeOfDay?> kiesTijdScroll({
    required int startUur,
    required int startMinuut,
  }) async {
    int gekozenUur = startUur;
    int gekozenMinuut = startMinuut;

    final uurController = FixedExtentScrollController(initialItem: gekozenUur);
    final minuutController =
        FixedExtentScrollController(initialItem: gekozenMinuut);

    final resultaat = await showModalBottomSheet<TimeOfDay>(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 310,
          child: Column(
            children: [
              Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuleer'),
                    ),
                    const Spacer(),
                    const Text(
                      'Tijd kiezen',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          TimeOfDay(
                            hour: gekozenUur,
                            minute: gekozenMinuut,
                          ),
                        );
                      },
                      child: const Text('Klaar'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: uurController,
                        itemExtent: 42,
                        onSelectedItemChanged: (waarde) {
                          gekozenUur = waarde;
                        },
                        children: List.generate(
                          24,
                          (index) => Center(
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      ':',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: minuutController,
                        itemExtent: 42,
                        onSelectedItemChanged: (waarde) {
                          gekozenMinuut = waarde;
                        },
                        children: List.generate(
                          60,
                          (index) => Center(
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: const TextStyle(fontSize: 22),
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
        );
      },
    );

    uurController.dispose();
    minuutController.dispose();

    return resultaat;
  }

  Future<void> kiesStart(int index) async {
    final item = widget.klant.extraWerkItems[index];

    final gekozen = await kiesTijdScroll(
      startUur: item.startUur ?? 7,
      startMinuut: item.startMinuut ?? 0,
    );

    if (gekozen == null) return;

    item.startUur = gekozen.hour;
    item.startMinuut = gekozen.minute;

    final start = item.startUur! * 60 + item.startMinuut!;
    final eind = (item.eindUur ?? 7) * 60 + (item.eindMinuut ?? 0);

    if (eind < start) {
      item.eindUur = item.startUur;
      item.eindMinuut = item.startMinuut;
    }

    await opslaan();
  }

  Future<void> kiesEinde(int index) async {
    final item = widget.klant.extraWerkItems[index];

    final startUurWaarde = item.startUur ?? 7;
    final startMinuutWaarde = item.startMinuut ?? 0;

    final gekozen = await kiesTijdScroll(
      startUur: item.eindUur ?? startUurWaarde,
      startMinuut: item.eindMinuut ?? startMinuutWaarde,
    );

    if (gekozen == null) return;

    final gekozenMinuten = gekozen.hour * 60 + gekozen.minute;
    final startMinuten = startUurWaarde * 60 + startMinuutWaarde;

    if (gekozenMinuten < startMinuten) {
      item.eindUur = startUurWaarde;
      item.eindMinuut = startMinuutWaarde;
    } else {
      item.eindUur = gekozen.hour;
      item.eindMinuut = gekozen.minute;
    }

    await opslaan();
  }

  double urenVanItem(ExtraWerkItem item) {
    if (item.startUur == null ||
        item.startMinuut == null ||
        item.eindUur == null ||
        item.eindMinuut == null) {
      return 0;
    }

    final start = item.startUur! * 60 + item.startMinuut!;
    final eind = item.eindUur! * 60 + item.eindMinuut!;

    if (eind <= start) return 0;

    return (eind - start) / 60;
  }

  double berekenUren() {
    double totaal = 0;

    for (final item in widget.klant.extraWerkItems) {
      totaal += urenVanItem(item);
    }

    return totaal;
  }

  Future<void> voegToe() async {
    widget.klant.extraWerkItems.add(
      ExtraWerkItem(
        datum: DateTime.now(),
        startUur: 7,
        startMinuut: 0,
        eindUur: 7,
        eindMinuut: 0,
        omschrijving: '',
      ),
    );

    controllers.add(TextEditingController());

    await opslaan();
  }

  Future<void> verwijder(int index) async {
    if (widget.klant.extraWerkItems.length == 1) {
      widget.klant.extraWerkItems[index].omschrijving = '';
      controllers[index].clear();
      await opslaan();
      return;
    }

    controllers[index].dispose();
    controllers.removeAt(index);
    widget.klant.extraWerkItems.removeAt(index);

    await opslaan();
  }

  Widget groeneBalk() {
    final klantNaam = widget.klant.klantnaam.trim().isEmpty
        ? 'Klant zonder naam'
        : widget.klant.klantnaam.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
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
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Extra werk/materiaal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  klantNaam,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget infoRij({
    required IconData icoon,
    required String tekst,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icoon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 7),
          Text(
            tekst,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget momentKaart(int index) {
    final item = widget.klant.extraWerkItems[index];
    final uren = urenVanItem(item);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controllers[index],
            maxLines: 2,
            onChanged: (waarde) async {
              item.omschrijving = waarde;
              await widget.onGewijzigd();
            },
            decoration: InputDecoration(
              hintText: 'Omschrijving extra werk/materiaal...',
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.all(13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 18,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              infoRij(
                icoon: Icons.calendar_today_outlined,
                tekst: datumTekst(item.datum),
                onTap: () => kiesDatum(index),
              ),
              infoRij(
                icoon: Icons.play_arrow,
                tekst: tijdTekst(item.startUur, item.startMinuut),
                onTap: () => kiesStart(index),
              ),
              infoRij(
                icoon: Icons.stop,
                tekst: tijdTekst(item.eindUur, item.eindMinuut),
                onTap: () => kiesEinde(index),
              ),
              infoRij(
                icoon: Icons.schedule_outlined,
                tekst: '${uren.toStringAsFixed(2)} u',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Spacer(),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => verwijder(index),
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade500,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget totaalBlok() {
    final totaal = berekenUren();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time_filled, color: Colors.green),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Totale extra uren',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            '${totaal.toStringAsFixed(2)} u',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }

  Widget toevoegenKnop() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: voegToe,
        icon: const Icon(Icons.add),
        label: const Text('Extra werk/materiaal toevoegen'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF109C49),
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      bottomNavigationBar: OnderNavigatieBalk(
        huidigePagina: 'andere',
      ),
      body: SafeArea(
        child: Column(
          children: [
            groeneBalk(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 92),
                children: [
                  toevoegenKnop(),
                  const SizedBox(height: 16),
                  totaalBlok(),
                  ...List.generate(
                    widget.klant.extraWerkItems.length,
                    momentKaart,
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
