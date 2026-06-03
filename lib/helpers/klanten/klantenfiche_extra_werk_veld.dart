import 'package:flutter/material.dart';

import 'fiche/klantenfiche_model.dart';
import '../Agenda/agenda_tijd_picker.dart';

class KlantenficheExtraWerkVeld extends StatelessWidget {
  final List<KlantenficheExtraWerk> extraWerken;
  final VoidCallback? onChanged;

  const KlantenficheExtraWerkVeld({
    super.key,
    required this.extraWerken,
    this.onChanged,
  });

  int get totaalMinuten {
    return extraWerken.fold(
      0,
      (totaal, werk) => totaal + werk.aantalMinuten,
    );
  }

  String get totaalTekst {
    final uren = totaalMinuten ~/ 60;
    final minuten = totaalMinuten % 60;

    return '${uren}u${minuten.toString().padLeft(2, '0')}';
  }

  void _extraWerkToevoegen() {
    extraWerken.add(
      KlantenficheExtraWerk(
        datum: DateTime.now(),
        startUur: 8,
        startMinuut: 0,
        eindUur: 10,
        eindMinuut: 0,
      ),
    );

    onChanged?.call();
  }

  void _extraWerkVerwijderen(int index) {
    extraWerken.removeAt(index);
    onChanged?.call();
  }

  Future<void> _kiesDatum(
    BuildContext context,
    KlantenficheExtraWerk werk,
  ) async {
    final gekozen = await showDatePicker(
      context: context,
      initialDate: werk.datum ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (gekozen == null) return;

    werk.datum = gekozen;
    onChanged?.call();
  }

  Future<void> _kiesStartTijd(
    BuildContext context,
    KlantenficheExtraWerk werk,
  ) async {
    final gekozen = await AgendaTijdPicker.kiesTijd(
      context: context,
      titel: 'Starttijd',
      beginTijd: TimeOfDay(
        hour: werk.startUur ?? 8,
        minute: werk.startMinuut ?? 0,
      ),
    );

    if (gekozen == null) return;

    werk.startUur = gekozen.hour;
    werk.startMinuut = gekozen.minute;

    onChanged?.call();
  }

  Future<void> _kiesEindTijd(
    BuildContext context,
    KlantenficheExtraWerk werk,
  ) async {
    final gekozen = await AgendaTijdPicker.kiesTijd(
      context: context,
      titel: 'Eindtijd',
      beginTijd: TimeOfDay(
        hour: werk.eindUur ?? 10,
        minute: werk.eindMinuut ?? 0,
      ),
    );

    if (gekozen == null) return;

    werk.eindUur = gekozen.hour;
    werk.eindMinuut = gekozen.minute;

    onChanged?.call();
  }

  String _datumTekst(DateTime? datum) {
    if (datum == null) return 'Datum';

    return '${datum.day.toString().padLeft(2, '0')}/'
        '${datum.month.toString().padLeft(2, '0')}/'
        '${datum.year}';
  }

  String _tijdTekst(int? uur, int? minuut) {
    if (uur == null || minuut == null) {
      return '--:--';
    }

    return '${uur.toString().padLeft(2, '0')}:'
        '${minuut.toString().padLeft(2, '0')}';
  }

  String _duurTekst(int minutenTotaal) {
    final uren = minutenTotaal ~/ 60;
    final minuten = minutenTotaal % 60;

    return '${uren}u${minuten.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (extraWerken.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'Nog geen extra werk toegevoegd.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ...List.generate(extraWerken.length, (index) {
          final werk = extraWerken[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0B7A3B),
                          side: const BorderSide(
                            color: Color(0xFF0B7A3B),
                          ),
                        ),
                        onPressed: () {
                          _kiesDatum(context, werk);
                        },
                        icon: const Icon(
                          Icons.calendar_today,
                          size: 16,
                        ),
                        label: Text(
                          _datumTekst(werk.datum),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        _extraWerkVerwijderen(index);
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0B7A3B),
                          side: const BorderSide(
                            color: Color(0xFF0B7A3B),
                          ),
                        ),
                        onPressed: () {
                          _kiesStartTijd(context, werk);
                        },
                        child: Text(
                          _tijdTekst(
                            werk.startUur,
                            werk.startMinuut,
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'tot',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0B7A3B),
                          side: const BorderSide(
                            color: Color(0xFF0B7A3B),
                          ),
                        ),
                        onPressed: () {
                          _kiesEindTijd(context, werk);
                        },
                        child: Text(
                          _tijdTekst(
                            werk.eindUur,
                            werk.eindMinuut,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: TextEditingController(
                    text: werk.omschrijving,
                  )..selection = TextSelection.collapsed(
                      offset: werk.omschrijving.length,
                    ),
                  onChanged: (waarde) {
                    werk.omschrijving = waarde;
                    onChanged?.call();
                  },
                  decoration: InputDecoration(
                    hintText: 'Omschrijving extra werk...',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFE5E7EB),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFE5E7EB),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF0B7A3B),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Duur: ${_duurTekst(werk.aantalMinuten)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE7F6EC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Totaal extra werk: $totaalTekst',
            style: const TextStyle(
              color: Color(0xFF0B7A3B),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _extraWerkToevoegen,
            icon: const Icon(Icons.add),
            label: const Text('Extra werk toevoegen'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0B7A3B),
              side: const BorderSide(
                color: Color(0xFF0B7A3B),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
