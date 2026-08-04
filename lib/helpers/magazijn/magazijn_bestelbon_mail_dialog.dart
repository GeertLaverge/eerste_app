// THIMACO-CONTROLE: MAGAZIJN-BESTELBON-MAIL-DIALOG-20260804

import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../offerte/mail/offerte_mail_tekst_model.dart';
import '../offerte/mail/offerte_mail_teksten_repository.dart';
import '../offerte/mail/offerte_mail_verzend_service.dart';
import 'magazijn_model.dart';

class MagazijnBestelbonMailDialog extends StatefulWidget {
  const MagazijnBestelbonMailDialog({
    super.key,
    required this.leverancier,
    required this.pdfBytes,
    required this.bestandsnaam,
  });

  final MagazijnLeverancier leverancier;
  final Uint8List pdfBytes;
  final String bestandsnaam;

  static Future<bool?> toon({
    required BuildContext context,
    required MagazijnLeverancier leverancier,
    required Uint8List pdfBytes,
    required String bestandsnaam,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => MagazijnBestelbonMailDialog(
        leverancier: leverancier,
        pdfBytes: pdfBytes,
        bestandsnaam: bestandsnaam,
      ),
    );
  }

  @override
  State<MagazijnBestelbonMailDialog> createState() =>
      _MagazijnBestelbonMailDialogState();
}

class _MagazijnBestelbonMailDialogState
    extends State<MagazijnBestelbonMailDialog> {
  static const Color _groen = Color(0xFF0B7A3B);

  final TextEditingController _ontvangerController = TextEditingController();
  final TextEditingController _onderwerpController = TextEditingController();
  final TextEditingController _berichtController = TextEditingController();

  List<OfferteMailTekstBlok> _sjablonen = const <OfferteMailTekstBlok>[];
  String? _geselecteerdId;
  bool _laden = true;
  bool _versturen = false;
  String _status = '';
  String _fout = '';

  @override
  void initState() {
    super.initState();
    _ontvangerController.text = widget.leverancier.email.trim();
    _laadSjablonen();
  }

  @override
  void dispose() {
    _ontvangerController.dispose();
    _onderwerpController.dispose();
    _berichtController.dispose();
    super.dispose();
  }

  Future<void> _laadSjablonen() async {
    try {
      final data = await OfferteMailTekstenRepository.laad();
      final sjablonen = data.blokken
          .where(
            (blok) =>
                blok.actief &&
                blok.gebruik.beschikbaarVoorBestelbon &&
                blok.tekst.trim().isNotEmpty,
          )
          .toList(growable: false);

      if (!mounted) return;
      setState(() {
        _sjablonen = sjablonen;
        _laden = false;
      });

      if (sjablonen.isNotEmpty) {
        _pasSjabloonToe(sjablonen.first);
      }
    } catch (fout) {
      if (!mounted) return;
      setState(() {
        _laden = false;
        _fout = 'De standaardtekst kon niet worden geladen.\n$fout';
      });
    }
  }

  void _pasSjabloonToe(OfferteMailTekstBlok sjabloon) {
    setState(() {
      _geselecteerdId = sjabloon.id;
      _onderwerpController.text = _vervangVelden(sjabloon.onderwerp);
      _berichtController.text = _vervangVelden(sjabloon.tekst);
      _fout = '';
    });
  }

  String _vervangVelden(String tekst) {
    return tekst
        .replaceAll('[leverancier]', widget.leverancier.naam.trim())
        .replaceAll('[datum]', _datum(DateTime.now()));
  }

  String _datum(DateTime datum) {
    return '${datum.day.toString().padLeft(2, '0')}/'
        '${datum.month.toString().padLeft(2, '0')}/${datum.year}';
  }

  Future<void> _verstuur() async {
    if (_versturen) return;

    final ontvanger = _ontvangerController.text.trim();
    final onderwerp = _onderwerpController.text.trim();
    final bericht = _berichtController.text.trim();

    if (ontvanger.isEmpty || onderwerp.isEmpty || bericht.isEmpty) {
      setState(() {
        _fout =
            'Vul het e-mailadres, het onderwerp en de e-mailtekst volledig in.';
      });
      return;
    }

    setState(() {
      _versturen = true;
      _fout = '';
      _status = 'E-mail voorbereiden…';
    });

    try {
      await OfferteMailVerzendService().verstuur(
        ontvanger: ontvanger,
        onderwerp: onderwerp,
        bericht: bericht,
        bijlagen: <OfferteMailBijlage>[
          OfferteMailBijlage(
            bestandsnaam: widget.bestandsnaam,
            bytes: widget.pdfBytes,
          ),
        ],
        onVoortgang: (status, _) {
          if (mounted) setState(() => _status = status);
        },
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (fout) {
      if (!mounted) return;
      setState(() {
        _versturen = false;
        _status = '';
        _fout = fout.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(
          context,
        ).colorScheme.copyWith(primary: _groen, secondary: _groen),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _groen,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Bestelbon per e-mail',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: SizedBox(
          width: 650,
          child: _laden
              ? const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextField(
                        controller: _ontvangerController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'E-mailadres leverancier',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_sjablonen.length > 1) ...<Widget>[
                        DropdownButtonFormField<String>(
                          initialValue: _geselecteerdId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Standaardtekst uit instellingen',
                            prefixIcon: Icon(Icons.text_snippet_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: _sjablonen
                              .map((sjabloon) {
                                return DropdownMenuItem<String>(
                                  value: sjabloon.id,
                                  child: Text(sjabloon.naam),
                                );
                              })
                              .toList(growable: false),
                          onChanged: (id) {
                            if (id == null) return;
                            final sjabloon = _sjablonen.firstWhere(
                              (item) => item.id == id,
                            );
                            _pasSjabloonToe(sjabloon);
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextField(
                        controller: _onderwerpController,
                        decoration: const InputDecoration(
                          labelText: 'Onderwerp',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _berichtController,
                        minLines: 10,
                        maxLines: 16,
                        decoration: const InputDecoration(
                          labelText: 'E-mailtekst',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7F6EC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFB7DEC5)),
                        ),
                        child: Row(
                          children: <Widget>[
                            const Icon(
                              Icons.picture_as_pdf_outlined,
                              color: _groen,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.bestandsnaam,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const Text('PDF-bijlage'),
                          ],
                        ),
                      ),
                      if (_status.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          color: _groen,
                          backgroundColor: const Color(0xFFE7F6EC),
                        ),
                        const SizedBox(height: 6),
                        Text(_status),
                      ],
                      if (_fout.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 12),
                        Text(
                          _fout,
                          style: const TextStyle(
                            color: Color(0xFFB91C1C),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: _versturen ? null : () => Navigator.pop(context),
            child: const Text('Annuleren'),
          ),
          FilledButton.icon(
            onPressed: _versturen ? null : _verstuur,
            icon: const Icon(Icons.send_outlined),
            label: Text(_versturen ? 'Versturen…' : 'E-mail versturen'),
          ),
        ],
      ),
    );
  }
}
