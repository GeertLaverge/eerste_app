// THIMACO-CONTROLE: PRIJS-PER-ARTIKEL-NIEUWE-EENHEDEN-GELIJK-AAN-PRIJS-PER-POSITIE-20260814
// THIMACO-CONTROLE: PRIJS-PER-ARTIKEL-BIBLIOTHEEK-PAGINA-20260813
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../helpers/app_storage.dart';
import '../../../helpers/offerte/prijzen/offerte_artikel_prijs_data_model.dart';
import '../../../helpers/offerte/prijzen/offerte_prijs_per_artikel_template_model.dart';

class OffertePrijsPerArtikelPagina extends StatefulWidget {
  const OffertePrijsPerArtikelPagina({super.key});

  @override
  State<OffertePrijsPerArtikelPagina> createState() {
    return _OffertePrijsPerArtikelPaginaState();
  }
}

class _OffertePrijsPerArtikelPaginaState
    extends State<OffertePrijsPerArtikelPagina> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _achtergrond = Color(0xFFF7F8FA);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  static const List<String> _eenheden = <String>[
    'st',
    'uur',
    'L/M',
    'KM',
    'm²',
    '1 x B',
    '1 x H',
    '2 x B',
    '2 x H',
    '2 x H en 1 x B',
    '1 x H en 2 x B',
    'rondom',
    'oppervlakte',
  ];

  List<OffertePrijsPerArtikelTemplateModel> _templates =
      <OffertePrijsPerArtikelTemplateModel>[];
  bool _laden = true;
  bool _opslaan = false;
  String? _foutmelding;

  @override
  void initState() {
    super.initState();
    _laad();
  }

  Future<void> _laad() async {
    try {
      final templates = await AppStorage.laadOffertePrijsPerArtikelTemplates();
      templates.sort(_vergelijkTemplates);

      if (!mounted) return;
      setState(() {
        _templates = templates;
        _laden = false;
        _foutmelding = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _laden = false;
        _foutmelding = 'De bibliotheek kon niet worden geladen: $e';
      });
    }
  }

  static int _vergelijkTemplates(
    OffertePrijsPerArtikelTemplateModel eerste,
    OffertePrijsPerArtikelTemplateModel tweede,
  ) {
    final volgorde = eerste.volgorde.compareTo(tweede.volgorde);
    if (volgorde != 0) return volgorde;
    return eerste.omschrijving.toLowerCase().compareTo(
      tweede.omschrijving.toLowerCase(),
    );
  }

  Future<bool> _bewaar(
    List<OffertePrijsPerArtikelTemplateModel> nieuweTemplates,
  ) async {
    if (_opslaan) return false;

    setState(() {
      _opslaan = true;
    });

    try {
      await AppStorage.bewaarOffertePrijsPerArtikelTemplates(nieuweTemplates);
      if (!mounted) return true;

      setState(() {
        _templates = List<OffertePrijsPerArtikelTemplateModel>.from(
          nieuweTemplates,
        )..sort(_vergelijkTemplates);
      });
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFDC2626),
            content: Text('Bewaren mislukt: $e'),
          ),
        );
      }
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _opslaan = false;
        });
      }
    }
  }

  Future<void> _voegToe() async {
    final volgendeVolgorde = _templates.isEmpty
        ? 10
        : (_templates
                  .map((item) => item.volgorde)
                  .reduce((a, b) => a > b ? a : b) +
              10);

    final nieuw = await _toonTemplateDialog(
      begin: OffertePrijsPerArtikelTemplateModel(
        id: 'prijs_artikel_${DateTime.now().microsecondsSinceEpoch}',
        omschrijving: '',
        type: OffertePrijsPerPositieType.verkoop,
        eenheid: 'st',
        standaardWinstPercentage: 0,
        volgorde: volgendeVolgorde,
      ),
      nieuw: true,
    );

    if (nieuw == null) return;
    await _bewaar(<OffertePrijsPerArtikelTemplateModel>[..._templates, nieuw]);
  }

  Future<void> _wijzig(OffertePrijsPerArtikelTemplateModel template) async {
    final gewijzigd = await _toonTemplateDialog(begin: template, nieuw: false);
    if (gewijzigd == null) return;

    final nieuweLijst = _templates
        .map((item) => item.id == template.id ? gewijzigd : item)
        .toList(growable: false);
    await _bewaar(nieuweLijst);
  }

  Future<void> _verwijder(OffertePrijsPerArtikelTemplateModel template) async {
    final bevestigd = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Prijsregel verwijderen?',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            '“${template.omschrijving}” wordt uit de bibliotheek verwijderd. '
            'Reeds gekopieerde regels in bestaande offertes blijven ongewijzigd.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuleren'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Verwijderen'),
            ),
          ],
        );
      },
    );

    if (bevestigd != true) return;
    await _bewaar(
      _templates
          .where((item) => item.id != template.id)
          .toList(growable: false),
    );
  }

  Future<void> _verplaats(int oudIndex, int nieuwIndex) async {
    if (_opslaan) return;

    final lijst = List<OffertePrijsPerArtikelTemplateModel>.from(_templates);
    if (nieuwIndex > oudIndex) nieuwIndex -= 1;
    final item = lijst.removeAt(oudIndex);
    lijst.insert(nieuwIndex, item);

    final nu = DateTime.now().toUtc().toIso8601String();
    final hernummerd = List<OffertePrijsPerArtikelTemplateModel>.generate(
      lijst.length,
      (index) => lijst[index].copyWith(
        volgorde: (index + 1) * 10,
        gewijzigdOp: lijst[index].id == item.id ? nu : lijst[index].gewijzigdOp,
      ),
      growable: false,
    );

    setState(() {
      _templates = hernummerd;
    });

    final gelukt = await _bewaar(hernummerd);
    if (!gelukt) {
      await _laad();
    }
  }

  Future<OffertePrijsPerArtikelTemplateModel?> _toonTemplateDialog({
    required OffertePrijsPerArtikelTemplateModel begin,
    required bool nieuw,
  }) async {
    final omschrijvingController = TextEditingController(
      text: begin.omschrijving,
    );
    final winstController = TextEditingController(
      text: begin.veiligeStandaardWinstPercentage <= 0
          ? ''
          : _getal(begin.veiligeStandaardWinstPercentage),
    );

    var type = begin.type;
    var eenheid = begin.eenheid.trim().isEmpty ? 'st' : begin.eenheid.trim();

    try {
      return await showDialog<OffertePrijsPerArtikelTemplateModel>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              final beschikbareEenheden = _eenheden.contains(eenheid)
                  ? _eenheden
                  : <String>[eenheid, ..._eenheden];

              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  nieuw
                      ? 'Prijs per artikel toevoegen'
                      : 'Prijs per artikel wijzigen',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                content: SizedBox(
                  width: 560,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const Text(
                          'Deze regel is een herbruikbaar sjabloon. De prijs zelf '
                          'wordt later per offertepositie ingevuld. Na overnemen is '
                          'de regel volledig onafhankelijk van deze bibliotheek.',
                          style: TextStyle(
                            color: _tekstGrijs,
                            fontSize: 12.3,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: omschrijvingController,
                          autofocus: nieuw,
                          maxLines: 2,
                          minLines: 1,
                          decoration: _invoerDecoratie(
                            label: 'Omschrijving',
                            hint: 'Bijv. Leveren en plaatsen',
                          ),
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final breed = constraints.maxWidth >= 430;
                            final typeVeld =
                                DropdownButtonFormField<
                                  OffertePrijsPerPositieType
                                >(
                                  key: ValueKey<String>('type_${type.name}'),
                                  initialValue: type,
                                  isExpanded: true,
                                  decoration: _invoerDecoratie(label: 'Type'),
                                  items: OffertePrijsPerPositieType.values
                                      .map(
                                        (waarde) =>
                                            DropdownMenuItem<
                                              OffertePrijsPerPositieType
                                            >(
                                              value: waarde,
                                              child: Text(
                                                waarde.isAankoop
                                                    ? 'A · Aankoopprijs'
                                                    : 'V · Verkoopprijs',
                                              ),
                                            ),
                                      )
                                      .toList(growable: false),
                                  onChanged: (waarde) {
                                    if (waarde == null) return;
                                    setDialogState(() {
                                      type = waarde;
                                      if (type.isVerkoop) {
                                        winstController.clear();
                                      }
                                    });
                                  },
                                );
                            final eenheidVeld = DropdownButtonFormField<String>(
                              key: ValueKey<String>('eenheid_$eenheid'),
                              initialValue: eenheid,
                              isExpanded: true,
                              decoration: _invoerDecoratie(label: 'Eenheid'),
                              items: beschikbareEenheden
                                  .map(
                                    (waarde) => DropdownMenuItem<String>(
                                      value: waarde,
                                      child: Text(waarde),
                                    ),
                                  )
                                  .toList(growable: false),
                              onChanged: (waarde) {
                                if (waarde == null) return;
                                setDialogState(() {
                                  eenheid = waarde;
                                });
                              },
                            );

                            if (!breed) {
                              return Column(
                                children: <Widget>[
                                  typeVeld,
                                  const SizedBox(height: 12),
                                  eenheidVeld,
                                ],
                              );
                            }

                            return Row(
                              children: <Widget>[
                                Expanded(child: typeVeld),
                                const SizedBox(width: 12),
                                Expanded(child: eenheidVeld),
                              ],
                            );
                          },
                        ),
                        if (type.isAankoop) ...<Widget>[
                          const SizedBox(height: 12),
                          TextField(
                            controller: winstController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9,.]'),
                              ),
                            ],
                            decoration: _invoerDecoratie(
                              label: 'Standaard winst %',
                              hint: 'Bijv. 30',
                              suffix: '%',
                            ),
                          ),
                        ] else ...<Widget>[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _rand),
                            ),
                            child: const Text(
                              'Verkoopprijs (V): geen winstmarge van toepassing.',
                              style: TextStyle(
                                color: _tekstGrijs,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Annuleren'),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: _groen),
                    onPressed: () {
                      final omschrijving = omschrijvingController.text.trim();
                      if (omschrijving.isEmpty) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(
                            content: Text('Vul eerst een omschrijving in.'),
                          ),
                        );
                        return;
                      }

                      final winst = type.isAankoop
                          ? _leesDouble(
                              winstController.text,
                            ).clamp(0.0, 500.0).toDouble()
                          : 0.0;

                      Navigator.pop(
                        dialogContext,
                        begin.copyWith(
                          omschrijving: omschrijving,
                          type: type,
                          eenheid: eenheid,
                          standaardWinstPercentage: winst,
                          gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Bewaren'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      omschrijvingController.dispose();
      winstController.dispose();
    }
  }

  static InputDecoration _invoerDecoratie({
    required String label,
    String? hint,
    String? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixText: suffix,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _rand),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _rand),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _groen, width: 1.4),
      ),
    );
  }

  static double _leesDouble(String tekst) {
    return double.tryParse(tekst.trim().replaceAll(',', '.')) ?? 0.0;
  }

  static String _getal(double waarde) {
    var tekst = waarde.toStringAsFixed(2).replaceAll('.', ',');
    tekst = tekst.replaceFirst(RegExp(r'0+$'), '');
    return tekst.replaceFirst(RegExp(r',$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _achtergrond,
      appBar: AppBar(
        title: const Text(
          'Prijs per artikel',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: <Widget>[
          if (_opslaan)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 19,
                  height: 19,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.3,
                    color: _groen,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _laden || _foutmelding != null
          ? null
          : FloatingActionButton.extended(
              backgroundColor: _groen,
              foregroundColor: Colors.white,
              onPressed: _opslaan ? null : _voegToe,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Prijsregel',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
      body: _bouwInhoud(),
    );
  }

  Widget _bouwInhoud() {
    if (_laden) {
      return const Center(child: CircularProgressIndicator(color: _groen));
    }

    if (_foutmelding != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.error_outline_rounded,
                size: 34,
                color: _tekstGrijs,
              ),
              const SizedBox(height: 10),
              Text(
                _foutmelding!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _tekstGrijs),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _laad,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Opnieuw proberen'),
              ),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _lichtGroen,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: const Color(0xFFB9E1C6)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.copy_all_outlined, color: _groen, size: 21),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Bibliotheek met herbruikbare prijsregels. Bij gebruik in '
                        'een offerte wordt een zelfstandige kopie gemaakt. Een '
                        'latere wijziging hier verandert dus nooit een bestaande '
                        'offerte. De werkelijke prijs wordt per positie ingevuld.',
                        style: TextStyle(
                          color: _tekstDonker,
                          fontSize: 12.4,
                          height: 1.4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_templates.isEmpty)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(
                          Icons.price_change_outlined,
                          size: 42,
                          color: _tekstGrijs,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Nog geen prijsregels',
                          style: TextStyle(
                            color: _tekstDonker,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Voeg uw eerste herbruikbare prijsregel toe.',
                          style: TextStyle(color: _tekstGrijs),
                        ),
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: _groen,
                          ),
                          onPressed: _opslaan ? null : _voegToe,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Prijsregel toevoegen'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 90),
                  itemCount: _templates.length,
                  onReorder: _verplaats,
                  buildDefaultDragHandles: false,
                  proxyDecorator: (child, index, animation) {
                    return Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(12),
                      child: child,
                    );
                  },
                  itemBuilder: (context, index) {
                    final template = _templates[index];
                    return Padding(
                      key: ValueKey<String>(template.id),
                      padding: const EdgeInsets.only(bottom: 9),
                      child: _TemplateKaart(
                        template: template,
                        onWijzigen: _opslaan ? null : () => _wijzig(template),
                        onVerwijderen: _opslaan
                            ? null
                            : () => _verwijder(template),
                        index: index,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TemplateKaart extends StatelessWidget {
  const _TemplateKaart({
    required this.template,
    required this.onWijzigen,
    required this.onVerwijderen,
    required this.index,
  });

  final OffertePrijsPerArtikelTemplateModel template;
  final VoidCallback? onWijzigen;
  final VoidCallback? onVerwijderen;
  final int index;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _rand),
        ),
        child: Row(
          children: <Widget>[
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 3, vertical: 10),
                child: Icon(Icons.drag_indicator_rounded, color: _tekstGrijs),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: template.isAankoop
                    ? const Color(0xFFFFF7ED)
                    : const Color(0xFFE7F6EC),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                template.type.label,
                style: TextStyle(
                  color: template.isAankoop ? const Color(0xFFC2410C) : _groen,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    template.omschrijving,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _tekstDonker,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    template.isAankoop
                        ? '${template.eenheid} · standaard winst ${_percentage(template.veiligeStandaardWinstPercentage)} %'
                        : '${template.eenheid} · verkoopprijs · geen winst',
                    style: const TextStyle(
                      color: _tekstGrijs,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Wijzigen',
              onPressed: onWijzigen,
              icon: const Icon(Icons.edit_outlined, color: _groen, size: 20),
            ),
            IconButton(
              tooltip: 'Verwijderen',
              onPressed: onVerwijderen,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFB91C1C),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _percentage(double waarde) {
    if (waarde <= 0.0) return '0';
    var tekst = waarde.toStringAsFixed(2).replaceAll('.', ',');
    tekst = tekst.replaceFirst(RegExp(r'0+$'), '');
    return tekst.replaceFirst(RegExp(r',$'), '');
  }
}
