import 'package:flutter/material.dart';

import '../Agenda/agenda_datum_helper.dart';
import '../Agenda/agenda_item.dart';
import '../Agenda/agenda_repository.dart';
import '../Agenda/agenda_tijd_picker.dart';

class KlantenficheKraanReserverenBlok extends StatelessWidget {
  final bool kraanNodig;
  final String klantNaam;
  final String klantNr;
  final String straatnaam;
  final String huisNr;
  final String gemeente;
  final String postcode;
  final String gsm;
  final String email;
  final String kraanDatum;
  final int? kraanStartUur;
  final int? kraanStartMinuut;
  final int? kraanEindUur;
  final int? kraanEindMinuut;

  final ValueChanged<bool> onKraanNodigChanged;
  final Future<void> Function({
    required String datum,
    required int startUur,
    required int startMinuut,
    required int eindUur,
    required int eindMinuut,
  }) onKraanGereserveerd;

  const KlantenficheKraanReserverenBlok({
    super.key,
    required this.kraanNodig,
    required this.klantNaam,
    required this.klantNr,
    required this.straatnaam,
    required this.huisNr,
    required this.gemeente,
    required this.postcode,
    required this.gsm,
    required this.email,
    required this.kraanDatum,
    required this.kraanStartUur,
    required this.kraanStartMinuut,
    required this.kraanEindUur,
    required this.kraanEindMinuut,
    required this.onKraanNodigChanged,
    required this.onKraanGereserveerd,
  });

  Future<List<DateTime>> ingeplandeDatums() async {
    final itemsPerDag = await AgendaRepository.laadItems();
    final naam = klantNaam.trim().toLowerCase();

    final datums = <DateTime>[];

    itemsPerDag.forEach((datumKey, items) {
      for (final item in items) {
        if (item.isVerwijderd) continue;
        if (item.type == 'kraan') continue;

        final zelfdeKlant = item.naamKlant.trim().toLowerCase() == naam ||
            item.titel.trim().toLowerCase() == naam;

        if (zelfdeKlant) {
          final datum = DateTime.tryParse(datumKey);
          if (datum != null) datums.add(datum);
        }
      }
    });

    datums.sort();
    return datums;
  }

  Future<void> reserveerKraan(
    BuildContext context,
    DateTime datum,
  ) async {
    final start = await AgendaTijdPicker.kiesTijd(
      context: context,
      titel: 'Starttijd kraan',
      beginTijd: const TimeOfDay(
        hour: 7,
        minute: 0,
      ),
    );

    if (start == null) return;

    final eind = await AgendaTijdPicker.kiesTijd(
      context: context,
      titel: 'Eindtijd kraan',
      beginTijd: TimeOfDay(
        hour: start.hour,
        minute: start.minute,
      ),
    );

    if (eind == null) return;

    final startMin = (start.hour * 60) + start.minute;
    final eindMin = (eind.hour * 60) + eind.minute;

    if (eindMin <= startMin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Eindtijd moet na starttijd liggen.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final itemsPerDag = await AgendaRepository.laadItems();

    final kraanItem = AgendaItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      updatedAt: DateTime.now().toIso8601String(),
      titel: 'Kraan - $klantNaam',
      type: 'kraan',
      klantNr: klantNr,
      naamKlant: klantNaam,
      straatnaam: straatnaam,
      huisNr: huisNr,
      gemeente: gemeente,
      postcode: postcode,
      gsm: gsm,
      email: email,
      startUur: start.hour,
      startMinuut: start.minute,
      eindUur: eind.hour,
      eindMinuut: eind.minute,
      kraanNodig: false,
      kraanIngepland: true,
    );

    final nieuweItems = await AgendaRepository.voegToe(
      dag: datum,
      item: kraanItem,
      itemsPerDag: itemsPerDag,
    );

    final naam = klantNaam.trim().toLowerCase();

    final aangepasteItems = nieuweItems.map((datumKey, items) {
      final aangepasteLijst = items.map((item) {
        final zelfdeKlant = item.naamKlant.trim().toLowerCase() == naam ||
            item.titel.trim().toLowerCase() == naam;

        if (zelfdeKlant && item.type != 'kraan') {
          return item.copyWith(
            kraanNodig: false,
            kraanIngepland: true,
          );
        }

        return item;
      }).toList();

      return MapEntry(datumKey, aangepasteLijst);
    });

    await AgendaRepository.bewaarItems(
      Map<String, List<AgendaItem>>.from(aangepasteItems),
    );

    await onKraanGereserveerd(
      datum: AgendaDatumHelper.datumKey(datum),
      startUur: start.hour,
      startMinuut: start.minute,
      eindUur: eind.hour,
      eindMinuut: eind.minute,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kraan gereserveerd.'),
        backgroundColor: Color(0xFF0B7A3B),
      ),
    );
  }

  String datumTekst(DateTime datum) {
    return '${datum.day.toString().padLeft(2, '0')}/'
        '${datum.month.toString().padLeft(2, '0')}/'
        '${datum.year}';
  }

  String tijdTekst() {
    if (kraanStartUur == null ||
        kraanStartMinuut == null ||
        kraanEindUur == null ||
        kraanEindMinuut == null) {
      return '';
    }

    return '${kraanStartUur!.toString().padLeft(2, '0')}:'
        '${kraanStartMinuut!.toString().padLeft(2, '0')} - '
        '${kraanEindUur!.toString().padLeft(2, '0')}:'
        '${kraanEindMinuut!.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final heeftKraanReservatie = kraanDatum.trim().isNotEmpty;

    return Column(
      children: [
        CheckboxListTile(
          value: kraanNodig,
          activeColor: const Color(0xFF0B7A3B),
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Kraan nodig bij deze klant',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          onChanged: (waarde) {
            onKraanNodigChanged(waarde ?? false);
          },
        ),
        if (kraanNodig && heeftKraanReservatie)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.brown.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.brown,
              ),
            ),
            child: Text(
              '🏗️ Kraan gereserveerd op $kraanDatum\n${tijdTekst()}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.brown,
              ),
            ),
          ),
        if (kraanNodig && !heeftKraanReservatie)
          FutureBuilder<List<DateTime>>(
            future: ingeplandeDatums(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                );
              }

              final datums = snapshot.data!;

              if (datums.isEmpty) {
                return const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Plan eerst de klant in. Daarna kan je hier de kraan reserveren.',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }

              return Column(
                children: datums.map((datum) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Text(
                      '🏗️',
                      style: TextStyle(fontSize: 20),
                    ),
                    title: Text(
                      datumTekst(datum),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        reserveerKraan(context, datum);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Reserveer'),
                    ),
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }
}
