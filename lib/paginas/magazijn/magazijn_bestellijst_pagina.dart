// THIMACO-CONTROLE: MAGAZIJN-BESTELLIJST-PDF-CONTROLE-20260804

import 'package:flutter/material.dart';

import '../../helpers/magazijn/magazijn_bestelbon_pdf_service.dart';
import '../../helpers/magazijn/magazijn_controller.dart';
import '../../helpers/magazijn/magazijn_bestelbon_mail_dialog.dart';
import '../../helpers/magazijn/magazijn_model.dart';

class MagazijnBestellijstPagina extends StatefulWidget {
  const MagazijnBestellijstPagina({super.key, required this.controller});

  final MagazijnController controller;

  @override
  State<MagazijnBestellijstPagina> createState() =>
      _MagazijnBestellijstPaginaState();
}

class _MagazijnBestellijstPaginaState extends State<MagazijnBestellijstPagina> {
  static const Color _groen = Color(0xFF0B7A3B);

  final Map<String, bool> _meenemen = <String, bool>{};
  final Map<String, TextEditingController> _aantalControllers =
      <String, TextEditingController>{};
  final Map<String, TextEditingController> _opmerkingControllers =
      <String, TextEditingController>{};

  @override
  void dispose() {
    for (final controller in _aantalControllers.values) {
      controller.dispose();
    }
    for (final controller in _opmerkingControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerVoor(MagazijnArtikel artikel) {
    return _aantalControllers.putIfAbsent(
      artikel.id,
      () => TextEditingController(
        text: artikel.aanbevolenBestelaantal.toString(),
      ),
    );
  }

  TextEditingController _opmerkingControllerVoor(String leverancierId) {
    return _opmerkingControllers.putIfAbsent(
      leverancierId,
      TextEditingController.new,
    );
  }

  bool _wordtMeegenomen(MagazijnArtikel artikel) {
    return _meenemen[artikel.id] ?? true;
  }

  List<MagazijnBestelbonRegel> _regelsVoor(List<MagazijnArtikel> artikelen) {
    final regels = <MagazijnBestelbonRegel>[];
    for (final artikel in artikelen) {
      if (!_wordtMeegenomen(artikel)) continue;
      final aantal = int.tryParse(_controllerVoor(artikel).text.trim()) ?? 0;
      if (aantal <= 0) continue;
      regels.add(MagazijnBestelbonRegel(artikel: artikel, aantal: aantal));
    }
    return regels;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(
          context,
        ).colorScheme.copyWith(primary: _groen, secondary: _groen),
      ),
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (_, __) {
          final leverancierBlokken = <Widget>[];

          for (final leverancier in widget.controller.data.leveranciers) {
            final artikelen = widget.controller.bestelArtikelenVoorLeverancier(
              leverancier.id,
            );
            if (artikelen.isEmpty) continue;

            leverancierBlokken.add(
              _LeverancierBestelbonKaart(
                leverancier: leverancier,
                artikelen: artikelen,
                aantalControllerVoor: _controllerVoor,
                wordtMeegenomen: _wordtMeegenomen,
                onMeenemenGewijzigd: (artikel, waarde) {
                  setState(() => _meenemen[artikel.id] = waarde);
                },
                opmerkingController: _opmerkingControllerVoor(leverancier.id),
                onAfdrukken: () async {
                  final regels = _regelsVoor(artikelen);
                  if (regels.isEmpty) {
                    _toonGeenRegels();
                    return;
                  }
                  await MagazijnBestelbonPdfService.afdrukken(
                    leverancier: leverancier,
                    regels: regels,
                    opmerking: _opmerkingControllerVoor(leverancier.id).text,
                  );
                },
                onDelen: () async {
                  final regels = _regelsVoor(artikelen);
                  if (regels.isEmpty) {
                    _toonGeenRegels();
                    return;
                  }
                  if (leverancier.email.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Bij deze leverancier is nog geen e-mailadres ingevuld.',
                        ),
                      ),
                    );
                    return;
                  }

                  final pdfBytes = await MagazijnBestelbonPdfService.maakPdf(
                    leverancier: leverancier,
                    regels: regels,
                    opmerking: _opmerkingControllerVoor(leverancier.id).text,
                  );
                  if (!context.mounted) return;

                  final verzonden = await MagazijnBestelbonMailDialog.toon(
                    context: context,
                    leverancier: leverancier,
                    pdfBytes: pdfBytes,
                    bestandsnaam: MagazijnBestelbonPdfService.bestandsNaam(
                      leverancier,
                    ),
                  );
                  if (!context.mounted || verzonden != true) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Bestelbon verzonden naar ${leverancier.email}.',
                      ),
                      backgroundColor: _groen,
                    ),
                  );
                },
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              const Text(
                'Te bestellen',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              const Text(
                'Controleer per leverancier welke artikelen meegaan en pas '
                'het bestelaantal aan vóór afdrukken of doorsturen.',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 12),
              if (leverancierBlokken.isEmpty)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: const Text(
                    'Er zijn momenteel geen artikelen te bestellen.',
                  ),
                )
              else
                ...leverancierBlokken,
            ],
          );
        },
      ),
    );
  }

  void _toonGeenRegels() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Selecteer minstens één artikel met een bestelaantal groter dan nul.',
        ),
      ),
    );
  }
}

class _LeverancierBestelbonKaart extends StatelessWidget {
  const _LeverancierBestelbonKaart({
    required this.leverancier,
    required this.artikelen,
    required this.aantalControllerVoor,
    required this.wordtMeegenomen,
    required this.onMeenemenGewijzigd,
    required this.opmerkingController,
    required this.onAfdrukken,
    required this.onDelen,
  });

  final MagazijnLeverancier leverancier;
  final List<MagazijnArtikel> artikelen;
  final TextEditingController Function(MagazijnArtikel artikel)
  aantalControllerVoor;
  final bool Function(MagazijnArtikel artikel) wordtMeegenomen;
  final void Function(MagazijnArtikel artikel, bool waarde) onMeenemenGewijzigd;
  final TextEditingController opmerkingController;
  final VoidCallback onAfdrukken;
  final VoidCallback onDelen;

  static const Color _groen = Color(0xFF0B7A3B);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Color(0xFFE7F6EC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  leverancier.naam,
                  style: const TextStyle(
                    color: _groen,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (leverancier.email.trim().isNotEmpty)
                  Text(
                    leverancier.email,
                    style: const TextStyle(color: Color(0xFF4B5563)),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Row(
              children: const <Widget>[
                SizedBox(width: 44),
                Expanded(
                  flex: 4,
                  child: Text(
                    'Omschrijving',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Artikelnr.',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                SizedBox(
                  width: 125,
                  child: Text(
                    'Aantal',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...artikelen.map((artikel) {
            final meenemen = wordtMeegenomen(artikel);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Row(
                children: <Widget>[
                  Checkbox(
                    value: meenemen,
                    activeColor: _groen,
                    onChanged: (waarde) {
                      onMeenemenGewijzigd(artikel, waarde ?? false);
                    },
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      artikel.omschrijving,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: meenemen
                            ? const Color(0xFF111827)
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      artikel.effectiefBestelArtikelnummer.isEmpty
                          ? '—'
                          : artikel.effectiefBestelArtikelnummer,
                    ),
                  ),
                  SizedBox(
                    width: 125,
                    child: TextField(
                      controller: aantalControllerVoor(artikel),
                      enabled: meenemen,
                      keyboardType: TextInputType.number,
                      onChanged: (_) {
                        (context as Element).markNeedsBuild();
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        suffixText: artikel.eenheidVoorAantal(
                          int.tryParse(
                                aantalControllerVoor(artikel).text.trim(),
                              ) ??
                              0,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 4),
            child: TextField(
              controller: opmerkingController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Opmerking op bestelbon',
                hintText: 'Bijvoorbeeld leveringsafspraak of referentie',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: onAfdrukken,
                  icon: const Icon(Icons.print_outlined),
                  label: const Text('Afdrukken'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: _groen),
                  onPressed: onDelen,
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('E-mailen'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
