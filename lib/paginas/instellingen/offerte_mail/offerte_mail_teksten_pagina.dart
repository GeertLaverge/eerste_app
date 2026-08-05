// THIMACO-CONTROLE: OFFERTE-MAILTEKSTEN-DOWNLOADSIGNAAL-FASE18-20260805
// THIMACO-CONTROLE: VOLLEDIGE-MAILBERICHTEN-INSTELLINGEN-20260802

import 'package:flutter/material.dart';

import '../../../helpers/offerte/offerte_mail_template_service.dart';
import '../../../helpers/offerte/mail/offerte_mail_tekst_model.dart';
import '../../../helpers/offerte/mail/offerte_mail_teksten_repository.dart';
import '../../../helpers/sync/sync_navigatie_helper.dart';

class OfferteMailTekstenPagina extends StatefulWidget {
  const OfferteMailTekstenPagina({super.key});

  @override
  State<OfferteMailTekstenPagina> createState() {
    return _OfferteMailTekstenPaginaState();
  }
}

class _OfferteMailTekstenPaginaState extends State<OfferteMailTekstenPagina> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _achtergrond = Color(0xFFF7F8FA);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  OfferteMailTekstenData _data = OfferteMailTekstenData.leeg();
  bool _laden = true;
  bool _bewaren = false;
  bool _editorOpen = false;
  bool _downloadHerladenUitgesteld = false;
  bool _herladenNaSync = false;
  bool _nogmaalsHerladenNaSync = false;
  int _laatsteVerwerkteDownloadVersie = 0;
  String _fout = '';

  @override
  void initState() {
    super.initState();

    _laatsteVerwerkteDownloadVersie = SyncNavigatieHelper.downloadVersie.value;
    SyncNavigatieHelper.downloadVersie.addListener(_verwerkAchtergrondDownload);

    _laad();
  }

  @override
  void dispose() {
    SyncNavigatieHelper.downloadVersie.removeListener(
      _verwerkAchtergrondDownload,
    );
    super.dispose();
  }

  void _verwerkAchtergrondDownload() {
    final nieuweVersie = SyncNavigatieHelper.downloadVersie.value;

    if (nieuweVersie <= _laatsteVerwerkteDownloadVersie) {
      return;
    }

    _laatsteVerwerkteDownloadVersie = nieuweVersie;

    if (_bewaren || _editorOpen) {
      _downloadHerladenUitgesteld = true;
      return;
    }

    _herlaadNaSync();
  }

  Future<void> _herlaadNaSync() async {
    if (_herladenNaSync) {
      _nogmaalsHerladenNaSync = true;
      return;
    }

    _herladenNaSync = true;

    try {
      do {
        _nogmaalsHerladenNaSync = false;
        await _laad(toonLaden: false);
      } while (_nogmaalsHerladenNaSync && mounted);
    } finally {
      _herladenNaSync = false;
    }
  }

  ThemeData _groenThema(BuildContext context) {
    final basis = Theme.of(context);
    return basis.copyWith(
      colorScheme: basis.colorScheme.copyWith(
        primary: _groen,
        secondary: _groen,
        surface: Colors.white,
        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: _achtergrond,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: _groen,
        selectionColor: Color(0x5534A764),
        selectionHandleColor: _groen,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        floatingLabelStyle: const TextStyle(color: _groen),
        prefixIconColor: _groen,
        suffixIconColor: _groen,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _rand),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _rand),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _groen, width: 1.6),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: _groen),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _groen,
          foregroundColor: Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _groen,
          side: const BorderSide(color: _groen),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          return states.contains(WidgetState.selected) ? Colors.white : null;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          return states.contains(WidgetState.selected) ? _groen : null;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: _groen),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        iconColor: _groen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: _rand),
        ),
      ),
    );
  }

  Future<void> _laad({bool toonLaden = true}) async {
    if (toonLaden && mounted) {
      setState(() {
        _laden = true;
        _fout = '';
      });
    }

    try {
      final data = await OfferteMailTekstenRepository.laad();
      if (!mounted) return;
      setState(() {
        _data = data;
        _fout = '';
        _downloadHerladenUitgesteld = false;
      });
    } catch (fout) {
      if (!mounted) return;
      setState(() {
        _fout =
            'De opgeslagen mailberichten konden niet worden geladen.\n$fout';
      });
    } finally {
      if (mounted && toonLaden) {
        setState(() => _laden = false);
      }
    }
  }

  Future<void> _bewaarData(OfferteMailTekstenData data) async {
    if (_bewaren) return;

    setState(() {
      _bewaren = true;
      _data = data;
    });

    var bewarenGelukt = false;

    try {
      await OfferteMailTekstenRepository.bewaar(data);
      bewarenGelukt = true;
    } catch (fout) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bewaren is niet gelukt.\n$fout'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _bewaren = false);
      }
    }

    if (bewarenGelukt &&
        _downloadHerladenUitgesteld &&
        mounted &&
        !_editorOpen) {
      _downloadHerladenUitgesteld = false;
      await _herlaadNaSync();
    }
  }

  Future<void> _openEditor([OfferteMailTekstBlok? bestaand]) async {
    _editorOpen = true;

    final resultaat = await showDialog<OfferteMailTekstBlok>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Theme(
          data: _groenThema(dialogContext),
          child: _MailBerichtEditorDialog(bestaand: bestaand),
        );
      },
    );

    _editorOpen = false;

    if (!mounted) {
      return;
    }

    if (resultaat == null) {
      if (_downloadHerladenUitgesteld) {
        _downloadHerladenUitgesteld = false;
        await _herlaadNaSync();
      }
      return;
    }

    final blokken = List<OfferteMailTekstBlok>.from(_data.blokken);
    final index = blokken.indexWhere((blok) => blok.id == resultaat.id);
    if (index < 0) {
      blokken.add(resultaat);
    } else {
      blokken[index] = resultaat;
    }
    await _bewaarData(_data.copyWith(blokken: blokken));
  }

  Future<void> _verwijder(OfferteMailTekstBlok bericht) async {
    final bevestigd = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Theme(
          data: _groenThema(dialogContext),
          child: AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            title: const Text(
              'Bericht verwijderen?',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            content: Text('“${bericht.naam}” wordt definitief verwijderd.'),
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
          ),
        );
      },
    );

    if (bevestigd != true || !mounted) return;
    await _bewaarData(
      _data.copyWith(
        blokken: _data.blokken
            .where((item) => item.id != bericht.id)
            .toList(growable: false),
      ),
    );
  }

  Future<void> _verplaats(int index, int nieuwIndex) async {
    if (nieuwIndex < 0 || nieuwIndex >= _data.blokken.length) return;
    final blokken = List<OfferteMailTekstBlok>.from(_data.blokken);
    final bericht = blokken.removeAt(index);
    blokken.insert(nieuwIndex, bericht);
    await _bewaarData(_data.copyWith(blokken: blokken));
  }

  Future<void> _wisselActief(OfferteMailTekstBlok bericht, bool actief) async {
    final blokken = _data.blokken
        .map((item) {
          return item.id == bericht.id
              ? item.metNieuweWijzigingsDatum(actief: actief)
              : item;
        })
        .toList(growable: false);
    await _bewaarData(_data.copyWith(blokken: blokken));
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _groenThema(context),
      child: Scaffold(
        backgroundColor: _achtergrond,
        appBar: AppBar(
          backgroundColor: _groen,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Teksten bij mail',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 10, top: 7, bottom: 7),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _groen,
                ),
                onPressed: _bewaren ? null : () => _openEditor(),
                icon: const Icon(Icons.add_rounded, size: 19),
                label: const Text(
                  'Bericht toevoegen',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
        body: _bouwInhoud(),
      ),
    );
  }

  Widget _bouwInhoud() {
    if (_laden) {
      return const Center(child: CircularProgressIndicator(color: _groen));
    }

    if (_fout.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFDC2626),
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(_fout, textAlign: TextAlign.center),
              const SizedBox(height: 14),
              FilledButton.icon(
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
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980),
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _lichtGroen,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFB9E0C7)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.mark_email_unread_outlined, color: _groen),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ieder item hieronder is één volledig e-mailbericht met '
                      'een onderwerp en de volledige tekst. Bij het versturen '
                      'kiest u één bericht. De bovenste passende tekst wordt '
                      'automatisch voorgesteld.',
                      style: TextStyle(
                        color: _tekstDonker,
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_data.blokken.isEmpty)
              _bouwLeeg()
            else
              ...List<Widget>.generate(_data.blokken.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _bouwKaart(_data.blokken[index], index),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _bouwLeeg() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _rand),
      ),
      child: Column(
        children: <Widget>[
          const Icon(Icons.email_outlined, size: 44, color: _groen),
          const SizedBox(height: 12),
          const Text(
            'Nog geen opgeslagen berichten',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Voeg een volledig bericht toe dat u later opnieuw kunt gebruiken.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _tekstGrijs),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _openEditor(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Eerste bericht toevoegen'),
          ),
        ],
      ),
    );
  }

  Widget _bouwKaart(OfferteMailTekstBlok bericht, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rand),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _lichtGroen,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.email_outlined, color: _groen),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    spacing: 7,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Text(
                        bericht.naam,
                        style: const TextStyle(
                          color: _tekstDonker,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      _LabelChip(tekst: bericht.gebruik.label),
                      if (!bericht.actief)
                        const _LabelChip(tekst: 'Niet actief', fout: true),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bericht.onderwerp,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _tekstDonker,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    bericht.tekst.trim().replaceAll(RegExp(r'\s+'), ' '),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _tekstGrijs, height: 1.38),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: <Widget>[
                Switch(
                  value: bericht.actief,
                  activeTrackColor: _groen,
                  onChanged: _bewaren
                      ? null
                      : (waarde) => _wisselActief(bericht, waarde),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      tooltip: 'Omhoog',
                      onPressed: index <= 0 || _bewaren
                          ? null
                          : () => _verplaats(index, index - 1),
                      icon: const Icon(
                        Icons.arrow_upward_rounded,
                        color: _groen,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Omlaag',
                      onPressed: index >= _data.blokken.length - 1 || _bewaren
                          ? null
                          : () => _verplaats(index, index + 1),
                      icon: const Icon(
                        Icons.arrow_downward_rounded,
                        color: _groen,
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (waarde) {
                        if (waarde == 'wijzigen') _openEditor(bericht);
                        if (waarde == 'verwijderen') _verwijder(bericht);
                      },
                      itemBuilder: (_) => const <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'wijzigen',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.edit_outlined, color: _groen),
                            title: Text('Wijzigen'),
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'verwijderen',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.delete_outline_rounded,
                              color: Color(0xFFDC2626),
                            ),
                            title: Text('Verwijderen'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MailBerichtEditorDialog extends StatefulWidget {
  const _MailBerichtEditorDialog({this.bestaand});

  final OfferteMailTekstBlok? bestaand;

  @override
  State<_MailBerichtEditorDialog> createState() {
    return _MailBerichtEditorDialogState();
  }
}

class _MailBerichtEditorDialogState extends State<_MailBerichtEditorDialog> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  late final TextEditingController _naamController;
  late final TextEditingController _onderwerpController;
  late final TextEditingController _tekstController;
  late OfferteMailBerichtGebruik _gebruik;
  late bool _actief;
  String _fout = '';

  @override
  void initState() {
    super.initState();
    final bestaand = widget.bestaand;
    _naamController = TextEditingController(text: bestaand?.naam ?? '');
    _onderwerpController = TextEditingController(
      text: bestaand?.onderwerp ?? '',
    );
    _tekstController = TextEditingController(text: bestaand?.tekst ?? '');
    _gebruik = bestaand?.gebruik ?? OfferteMailBerichtGebruik.offerte;
    _actief = bestaand?.actief ?? true;
  }

  @override
  void dispose() {
    _naamController.dispose();
    _onderwerpController.dispose();
    _tekstController.dispose();
    super.dispose();
  }

  void _bewaar() {
    final naam = _naamController.text.trim();
    final onderwerp = _onderwerpController.text.trim();
    final tekst = _tekstController.text.trim();
    if (naam.isEmpty || onderwerp.isEmpty || tekst.isEmpty) {
      setState(() {
        _fout = naam.isEmpty
            ? 'Geef een herkenbare naam in.'
            : onderwerp.isEmpty
            ? 'Geef het onderwerp van de e-mail in.'
            : 'Geef het volledige bericht in.';
      });
      return;
    }

    final bestaand = widget.bestaand;
    Navigator.pop(
      context,
      OfferteMailTekstBlok(
        id:
            bestaand?.id ??
            'mailbericht_${DateTime.now().microsecondsSinceEpoch}',
        naam: naam,
        onderwerp: onderwerp,
        tekst: tekst,
        gebruik: _gebruik,
        actief: _actief,
        gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        widget.bestaand == null ? 'Bericht toevoegen' : 'Bericht wijzigen',
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      content: SizedBox(
        width: 720,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              DropdownButtonFormField<OfferteMailBerichtGebruik>(
                initialValue: _gebruik,
                dropdownColor: Colors.white,
                decoration: const InputDecoration(
                  labelText: 'Gebruik bij',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: OfferteMailBerichtGebruik.values
                    .map((gebruik) {
                      return DropdownMenuItem<OfferteMailBerichtGebruik>(
                        value: gebruik,
                        child: Text(gebruik.label),
                      );
                    })
                    .toList(growable: false),
                onChanged: (waarde) {
                  if (waarde != null) setState(() => _gebruik = waarde);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _naamController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Naam van het opgeslagen bericht',
                  hintText: 'bv. Gewijzigde offerte na bespreking',
                  prefixIcon: Icon(Icons.label_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _onderwerpController,
                decoration: const InputDecoration(
                  labelText: 'Onderwerp',
                  prefixIcon: Icon(Icons.subject_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tekstController,
                minLines: 10,
                maxLines: 20,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Volledig e-mailbericht',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _lichtGroen,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: const Color(0xFFB9E0C7)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Beschikbare invulvelden',
                      style: TextStyle(
                        color: _tekstDonker,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: OfferteMailTemplateService.beschikbareVelden
                          .map(
                            (veld) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                  color: const Color(0xFFB9E0C7),
                                ),
                              ),
                              child: Text(
                                veld,
                                style: const TextStyle(
                                  color: _groen,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Deze velden worden bij het verzenden automatisch '
                      'ingevuld met de gegevens van de geopende offerte.',
                      style: TextStyle(
                        color: _tekstGrijs,
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (_fout.isNotEmpty) ...<Widget>[
                const SizedBox(height: 10),
                Text(
                  _fout,
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              SwitchListTile(
                value: _actief,
                activeTrackColor: _groen,
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Bericht actief',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text(
                  'Alleen actieve berichten verschijnen bij het versturen.',
                ),
                onChanged: (waarde) => setState(() => _actief = waarde),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuleren'),
        ),
        FilledButton.icon(
          onPressed: _bewaar,
          icon: const Icon(Icons.check_rounded),
          label: const Text('Bewaren'),
        ),
      ],
    );
  }
}

class _LabelChip extends StatelessWidget {
  const _LabelChip({required this.tekst, this.fout = false});

  final String tekst;
  final bool fout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: fout ? const Color(0xFFFFE8E8) : const Color(0xFFE7F6EC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: fout ? const Color(0xFFF3B7B7) : const Color(0xFFB9E0C7),
        ),
      ),
      child: Text(
        tekst,
        style: TextStyle(
          color: fout ? const Color(0xFFB91C1C) : const Color(0xFF0B7A3B),
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
