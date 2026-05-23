import 'package:flutter/material.dart';

import '../../../../modellen/klant.dart';
import 'dart:async';

class KlantTaakBlok extends StatefulWidget {
  final bool geopend;
  final VoidCallback onToggle;

  final List<KlantTaakItem> klantTaken;

  final String geselecteerdMoment;
  final ValueChanged<String> onMomentChanged;

  final DateTime? vrijeDatum;
  final ValueChanged<DateTime> onVrijeDatumChanged;

  final Future<void> Function() onChanged;

  const KlantTaakBlok({
    super.key,
    required this.geopend,
    required this.onToggle,
    required this.klantTaken,
    required this.geselecteerdMoment,
    required this.onMomentChanged,
    required this.vrijeDatum,
    required this.onVrijeDatumChanged,
    required this.onChanged,
  });

  @override
  State<KlantTaakBlok> createState() => _KlantTaakBlokState();
}

class _KlantTaakBlokState extends State<KlantTaakBlok> {
  final List<TextEditingController> controllers = [];
  Timer? _bewaarTimer;

  @override
  void initState() {
    super.initState();
    _zorgVoorLegeLaatsteRij();
    _maakControllers();
  }

  @override
  void dispose() {
    _bewaarTimer?.cancel();

    for (final controller in controllers) {
      controller.dispose();
    }

    super.dispose();
  }

  void _zorgVoorLegeLaatsteRij() {
    if (widget.klantTaken.isEmpty) {
      widget.klantTaken.add(KlantTaakItem());
      return;
    }

    final laatste = widget.klantTaken.last.tekst.trim();

    if (laatste.isNotEmpty) {
      widget.klantTaken.add(KlantTaakItem());
    }
  }

  void _maakControllers() {
    for (final controller in controllers) {
      controller.dispose();
    }

    controllers.clear();

    for (final taak in widget.klantTaken) {
      controllers.add(TextEditingController(text: taak.tekst));
    }
  }

  bool _isAanHetBewaren = false;
  bool _moetNogEensBewaren = false;

  void _planOpslaan() {
    _bewaarTimer?.cancel();

    _bewaarTimer = Timer(const Duration(milliseconds: 900), () async {
      await _bewaarStabiel();
    });
  }

  Future<void> _bewaarStabiel() async {
    if (_isAanHetBewaren) {
      _moetNogEensBewaren = true;
      return;
    }

    _isAanHetBewaren = true;

    await widget.onChanged();

    _isAanHetBewaren = false;

    if (_moetNogEensBewaren) {
      _moetNogEensBewaren = false;
      await _bewaarStabiel();
    }
  }

  Future<void> _tekstGewijzigd(int index, String waarde) async {
    if (index >= widget.klantTaken.length) return;

    widget.klantTaken[index].tekst = waarde;

    final laatsteIsNietLeeg = widget.klantTaken.last.tekst.trim().isNotEmpty;

    if (laatsteIsNietLeeg) {
      setState(() {
        widget.klantTaken.add(KlantTaakItem());
        controllers.add(TextEditingController());
      });
    }

    _planOpslaan();
  }

  Future<void> _verwijderTaak(int index) async {
    if (widget.klantTaken.length == 1) {
      widget.klantTaken[index].tekst = '';
      widget.klantTaken[index].isAfgewerkt = false;
      controllers[index].clear();
      await widget.onChanged();
      return;
    }

    setState(() {
      controllers[index].dispose();
      controllers.removeAt(index);
      widget.klantTaken.removeAt(index);
    });

    await widget.onChanged();
  }

  String datumTekst(DateTime? datum) {
    if (datum == null) return 'Geen datum gekozen';

    return '${datum.day.toString().padLeft(2, '0')}/'
        '${datum.month.toString().padLeft(2, '0')}/'
        '${datum.year}';
  }

  Future<void> kiesVrijeDatum(BuildContext context) async {
    final vandaag = DateTime.now();

    final gekozen = await showDatePicker(
      context: context,
      initialDate: widget.vrijeDatum ?? vandaag,
      firstDate: DateTime(vandaag.year - 1),
      lastDate: DateTime(vandaag.year + 3),
    );

    if (gekozen == null) return;

    widget.onMomentChanged('vrijeDatum');

    widget.onVrijeDatumChanged(
      DateTime(
        gekozen.year,
        gekozen.month,
        gekozen.day,
      ),
    );
  }

  Widget taakRij(int index) {
    final taak = widget.klantTaken[index];
    final isLaatsteLegeRij =
        taak.tekst.trim().isEmpty && index == widget.klantTaken.length - 1;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Icon(
            taak.isAfgewerkt
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: taak.isAfgewerkt ? Colors.green : Colors.grey,
            size: 22,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controllers[index],
              minLines: 1,
              maxLines: 3,
              onChanged: (waarde) => _tekstGewijzigd(index, waarde),
              decoration: InputDecoration(
                hintText: isLaatsteLegeRij ? 'Nieuwe taak toevoegen...' : '',
                isDense: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: taak.isAfgewerkt ? Colors.grey : const Color(0xFF111827),
                decoration: taak.isAfgewerkt
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
          if (!isLaatsteLegeRij)
            IconButton(
              onPressed: () => _verwijderTaak(index),
              icon: Icon(
                Icons.close,
                size: 18,
                color: Colors.grey.shade500,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final openTaken = widget.klantTaken
        .where((taak) => taak.tekst.trim().isNotEmpty && !taak.isAfgewerkt)
        .length;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: widget.onToggle,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.task_alt,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Taak voor klant',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '$openTaken open',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      widget.geopend
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (widget.geopend)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  ...List.generate(widget.klantTaken.length, taakRij),
                  const SizedBox(height: 12),
                  _MomentKeuze(
                    titel: 'Eerste dag',
                    waarde: 'eerstePlaatsingsdag',
                    geselecteerdMoment: widget.geselecteerdMoment,
                    onMomentChanged: widget.onMomentChanged,
                  ),
                  const SizedBox(height: 8),
                  _MomentKeuze(
                    titel: '1 dag eerder',
                    waarde: 'eenDagEerder',
                    geselecteerdMoment: widget.geselecteerdMoment,
                    onMomentChanged: widget.onMomentChanged,
                  ),
                  const SizedBox(height: 8),
                  _VrijeDatumKeuze(
                    actief: widget.geselecteerdMoment == 'vrijeDatum',
                    datumTekst: datumTekst(widget.vrijeDatum),
                    onTap: () => kiesVrijeDatum(context),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MomentKeuze extends StatelessWidget {
  final String titel;
  final String waarde;
  final String geselecteerdMoment;
  final ValueChanged<String> onMomentChanged;

  const _MomentKeuze({
    required this.titel,
    required this.waarde,
    required this.geselecteerdMoment,
    required this.onMomentChanged,
  });

  @override
  Widget build(BuildContext context) {
    final actief = geselecteerdMoment == waarde;

    return Material(
      color:
          actief ? Colors.green.withValues(alpha: 0.10) : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => onMomentChanged(waarde),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: actief ? Colors.green : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              Icon(
                actief ? Icons.radio_button_checked : Icons.radio_button_off,
                color: actief ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titel,
                  style: TextStyle(
                    fontWeight: actief ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VrijeDatumKeuze extends StatelessWidget {
  final bool actief;
  final String datumTekst;
  final VoidCallback onTap;

  const _VrijeDatumKeuze({
    required this.actief,
    required this.datumTekst,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          actief ? Colors.green.withValues(alpha: 0.10) : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: actief ? Colors.green : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              Icon(
                actief ? Icons.radio_button_checked : Icons.radio_button_off,
                color: actief ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Vrije datum kiezen',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                datumTekst,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.calendar_month,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
