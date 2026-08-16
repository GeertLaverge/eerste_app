// THIMACO-CONTROLE: PRIJS-VERDEELD-OVER-TOEPASSEN-DIALOOG-20260815
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_storage.dart';
import 'offerte_prijs_verdeeld_over_service.dart';
import 'offerte_prijs_verdeeld_over_template_model.dart';

class OffertePrijsVerdeeldOverPositie {
  const OffertePrijsVerdeeldOverPositie({
    required this.id,
    required this.positieLabel,
    required this.artikelLabel,
    required this.formulierType,
  });

  final String id;
  final String positieLabel;
  final String artikelLabel;
  final String formulierType;

  String get label {
    final positie = positieLabel.trim();
    final artikel = artikelLabel.trim();
    if (positie.isEmpty) {
      return artikel;
    }
    if (artikel.isEmpty) {
      return positie;
    }
    return '$positie · $artikel';
  }
}

class OffertePrijsVerdeeldOverToepassenResultaat {
  const OffertePrijsVerdeeldOverToepassenResultaat({
    required this.template,
    required this.totaalExclBtw,
    required this.geselecteerdePositieIds,
    this.bestaandeGroepId,
  });

  final OffertePrijsVerdeeldOverTemplateModel template;
  final double totaalExclBtw;
  final List<String> geselecteerdePositieIds;
  final String? bestaandeGroepId;
}

Future<OffertePrijsVerdeeldOverToepassenResultaat?>
toonOffertePrijsVerdeeldOverToepassenDialog({
  required BuildContext context,
  required List<OffertePrijsVerdeeldOverPositie> posities,
  OffertePrijsVerdeeldOverGroep? bestaandeGroep,
}) async {
  List<OffertePrijsVerdeeldOverTemplateModel> templates;
  try {
    templates = await AppStorage.laadOffertePrijsVerdeeldOverTemplates();
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text('De verdeelbibliotheek kon niet worden geladen: $e'),
        ),
      );
    }
    return null;
  }

  templates = templates.where((item) => item.isGeldig).toList(growable: true)
    ..sort((a, b) {
      final volgorde = a.volgorde.compareTo(b.volgorde);
      if (volgorde != 0) {
        return volgorde;
      }
      return a.omschrijving.toLowerCase().compareTo(
        b.omschrijving.toLowerCase(),
      );
    });

  if (bestaandeGroep != null &&
      !templates.any((item) => item.id == bestaandeGroep.templateId)) {
    templates.insert(
      0,
      OffertePrijsVerdeeldOverTemplateModel(
        id: bestaandeGroep.templateId,
        omschrijving: bestaandeGroep.omschrijving,
        type: bestaandeGroep.type,
        standaardWinstPercentage: bestaandeGroep.winstPercentage,
        offerteWeergave: bestaandeGroep.offerteWeergave,
      ),
    );
  }

  if (!context.mounted) {
    return null;
  }

  if (templates.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Maak eerst een regel aan via Instellingen → Offerteprijzen → '
          'Prijzen verdeeld over…',
        ),
      ),
    );
    return null;
  }

  if (posities.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Er zijn geen prijsbare posities om te verdelen.'),
      ),
    );
    return null;
  }

  return showDialog<OffertePrijsVerdeeldOverToepassenResultaat>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => _PrijsVerdeeldOverDialog(
      templates: templates,
      posities: posities,
      bestaandeGroep: bestaandeGroep,
    ),
  );
}

class _PrijsVerdeeldOverDialog extends StatefulWidget {
  const _PrijsVerdeeldOverDialog({
    required this.templates,
    required this.posities,
    required this.bestaandeGroep,
  });

  final List<OffertePrijsVerdeeldOverTemplateModel> templates;
  final List<OffertePrijsVerdeeldOverPositie> posities;
  final OffertePrijsVerdeeldOverGroep? bestaandeGroep;

  @override
  State<_PrijsVerdeeldOverDialog> createState() =>
      _PrijsVerdeeldOverDialogState();
}

class _PrijsVerdeeldOverDialogState extends State<_PrijsVerdeeldOverDialog> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  late final TextEditingController _bedragController;
  late String _templateId;
  late Set<String> _geselecteerdeIds;

  @override
  void initState() {
    super.initState();
    final bestaand = widget.bestaandeGroep;
    _templateId = bestaand?.templateId ?? widget.templates.first.id;
    if (!widget.templates.any((item) => item.id == _templateId)) {
      _templateId = widget.templates.first.id;
    }
    _geselecteerdeIds = <String>{
      ...?bestaand?.positieIds.where(
        (id) => widget.posities.any((positie) => positie.id == id),
      ),
    };
    _bedragController = TextEditingController(
      text: bestaand == null ? '' : _bedragTekst(bestaand.invoerTotaalExclBtw),
    )..addListener(_vernieuw);
  }

  @override
  void dispose() {
    _bedragController
      ..removeListener(_vernieuw)
      ..dispose();
    super.dispose();
  }

  void _vernieuw() {
    if (mounted) {
      setState(() {});
    }
  }

  OffertePrijsVerdeeldOverTemplateModel get _template {
    return widget.templates.firstWhere(
      (item) => item.id == _templateId,
      orElse: () => widget.templates.first,
    );
  }

  double get _bedrag {
    return double.tryParse(
          _bedragController.text.trim().replaceAll(',', '.'),
        ) ??
        0.0;
  }

  List<OffertePrijsVerdeeldOverPositie> get _geselecteerdePosities {
    return widget.posities
        .where((positie) => _geselecteerdeIds.contains(positie.id))
        .toList(growable: false);
  }

  Map<String, List<OffertePrijsVerdeeldOverPositie>> get _groepen {
    final resultaat = <String, List<OffertePrijsVerdeeldOverPositie>>{};
    for (final positie in widget.posities) {
      final label = positie.artikelLabel.trim().isEmpty
          ? positie.formulierType
          : positie.artikelLabel.trim();
      resultaat
          .putIfAbsent(label, () => <OffertePrijsVerdeeldOverPositie>[])
          .add(positie);
    }
    return resultaat;
  }

  void _toggleAlles(bool waarde) {
    setState(() {
      if (waarde) {
        _geselecteerdeIds = widget.posities.map((item) => item.id).toSet();
      } else {
        _geselecteerdeIds.clear();
      }
    });
  }

  void _toggleGroep(List<OffertePrijsVerdeeldOverPositie> groep, bool waarde) {
    setState(() {
      for (final positie in groep) {
        if (waarde) {
          _geselecteerdeIds.add(positie.id);
        } else {
          _geselecteerdeIds.remove(positie.id);
        }
      }
    });
  }

  void _togglePositie(String id, bool waarde) {
    setState(() {
      if (waarde) {
        _geselecteerdeIds.add(id);
      } else {
        _geselecteerdeIds.remove(id);
      }
    });
  }

  void _bevestig() {
    final geselecteerdePosities = _geselecteerdePosities;
    if (_bedrag <= 0.0 || geselecteerdePosities.isEmpty) {
      return;
    }

    Navigator.of(context).pop(
      OffertePrijsVerdeeldOverToepassenResultaat(
        template: _template,
        totaalExclBtw: _bedrag,
        geselecteerdePositieIds: geselecteerdePosities
            .map((positie) => positie.id)
            .toList(growable: false),
        bestaandeGroepId: widget.bestaandeGroep?.groepId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aantal = _geselecteerdeIds.length;
    final delen = OffertePrijsVerdeeldOverService.verdeelBedragExclBtw(
      totaalExclBtw: _bedrag,
      aantalPosities: aantal,
    );
    final verkoopTotaal =
        OffertePrijsVerdeeldOverService.berekenVerkoopTotaalExclBtw(
          template: _template,
          invoerTotaalExclBtw: _bedrag,
          aantalPosities: aantal,
        );

    return Dialog(
      insetPadding: const EdgeInsets.all(18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 760),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _bouwKop(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _bouwBasisInvoer(),
                    const SizedBox(height: 14),
                    _bouwSelectie(),
                    const SizedBox(height: 14),
                    _bouwSamenvatting(delen, verkoopTotaal),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: _rand)),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(18),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annuleren'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _bedrag > 0.0 && aantal > 0 ? _bevestig : null,
                    style: FilledButton.styleFrom(backgroundColor: _groen),
                    icon: const Icon(Icons.call_split_rounded, size: 18),
                    label: Text(
                      widget.bestaandeGroep == null
                          ? 'Verdelen over $aantal'
                          : 'Verdeling bijwerken',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bouwKop() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 15, 10, 14),
      decoration: const BoxDecoration(
        color: _lichtGroen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        border: Border(bottom: BorderSide(color: _rand)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _rand),
            ),
            child: const Icon(
              Icons.call_split_rounded,
              color: _groen,
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.bestaandeGroep == null
                      ? 'Prijs verdelen over…'
                      : 'Verdeling bewerken',
                  style: const TextStyle(
                    color: _tekstDonker,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Eén totaalbedrag exact verdelen over gekozen posities',
                  style: TextStyle(
                    color: _tekstGrijs,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Sluiten',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _bouwBasisInvoer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rand),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 5,
            child: DropdownButtonFormField<String>(
              initialValue: _templateId,
              isExpanded: true,
              decoration: _inputDecoratie('Prijsregel'),
              items: widget.templates
                  .map((template) {
                    return DropdownMenuItem<String>(
                      value: template.id,
                      child: Text(
                        template.omschrijving,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    );
                  })
                  .toList(growable: false),
              onChanged: (waarde) {
                if (waarde == null) {
                  return;
                }
                setState(() => _templateId = waarde);
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: _bedragController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                LengthLimitingTextInputFormatter(12),
              ],
              decoration: _inputDecoratie(
                _template.isAankoop
                    ? 'Aankoop totaal excl. btw'
                    : 'Verkoop totaal excl. btw',
                prefixText: '€ ',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwSelectie() {
    final groepen = _groepen;
    final allesGeselecteerd =
        _geselecteerdeIds.length == widget.posities.length &&
        widget.posities.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Opmeetfiches kiezen',
                  style: TextStyle(
                    color: _tekstDonker,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${_geselecteerdeIds.length} / ${widget.posities.length}',
                style: const TextStyle(
                  color: _tekstGrijs,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          CheckboxListTile(
            value: allesGeselecteerd,
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: _groen,
            title: const Text(
              'Alle beschikbare posities',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
            ),
            onChanged: (waarde) => _toggleAlles(waarde ?? false),
          ),
          const Divider(height: 8),
          ...groepen.entries.map((entry) {
            final groep = entry.value;
            final geselecteerdAantal = groep
                .where((positie) => _geselecteerdeIds.contains(positie.id))
                .length;
            final groepAlles = geselecteerdAantal == groep.length;
            final groepWaarde = geselecteerdAantal == 0
                ? false
                : groepAlles
                ? true
                : null;

            return Container(
              margin: const EdgeInsets.only(top: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: _rand),
              ),
              child: Column(
                children: <Widget>[
                  CheckboxListTile(
                    value: groepWaarde,
                    tristate: true,
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    activeColor: _groen,
                    title: Text(
                      entry.key,
                      style: const TextStyle(
                        color: _tekstDonker,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    subtitle: Text(
                      '$geselecteerdAantal van ${groep.length} geselecteerd',
                      style: const TextStyle(fontSize: 10.5),
                    ),
                    onChanged: (waarde) => _toggleGroep(groep, waarde ?? true),
                  ),
                  const Divider(height: 1),
                  ...groep.map((positie) {
                    return CheckboxListTile(
                      value: _geselecteerdeIds.contains(positie.id),
                      dense: true,
                      contentPadding: const EdgeInsets.only(left: 26, right: 8),
                      activeColor: _groen,
                      title: Text(
                        positie.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onChanged: (waarde) =>
                          _togglePositie(positie.id, waarde ?? false),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _bouwSamenvatting(List<double> delen, double verkoopTotaal) {
    final aantal = delen.length;
    final eerste = delen.isEmpty ? 0.0 : delen.first;
    final laatste = delen.isEmpty ? 0.0 : delen.last;
    final verdelingTekst = delen.isEmpty
        ? 'Kies minstens één positie en vul een bedrag in.'
        : eerste == laatste
        ? '$aantal × ${_euro(eerste)}'
        : '$aantal posities · van ${_euro(laatste)} tot ${_euro(eerste)}';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _lichtGroen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCDEBD6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'Controle verdeling',
            style: TextStyle(
              color: _groen,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            verdelingTekst,
            style: const TextStyle(
              color: _tekstDonker,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (_template.isAankoop && delen.isNotEmpty) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              'Aankoop ${_euro(_bedrag)} · winst '
              '${_percentage(_template.veiligeStandaardWinstPercentage)} · '
              'verkoop ${_euro(verkoopTotaal)}',
              style: const TextStyle(
                color: _tekstGrijs,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (delen.isNotEmpty) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              'Offerteweergave: ${_template.offerteWeergave.label}',
              style: const TextStyle(
                color: _tekstGrijs,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _inputDecoratie(String label, {String? prefixText}) {
    return InputDecoration(
      labelText: label,
      prefixText: prefixText,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: _rand),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: _groen, width: 1.4),
      ),
    );
  }

  static String _bedragTekst(double waarde) {
    if (!waarde.isFinite || waarde <= 0.0) {
      return '';
    }
    return waarde.toStringAsFixed(2).replaceAll('.', ',');
  }

  static String _euro(double waarde) {
    return '€ ${waarde.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  static String _percentage(double waarde) {
    var tekst = waarde.toStringAsFixed(2).replaceAll('.', ',');
    tekst = tekst.replaceFirst(RegExp(r'0+$'), '');
    tekst = tekst.replaceFirst(RegExp(r',$'), '');
    return '$tekst %';
  }
}
