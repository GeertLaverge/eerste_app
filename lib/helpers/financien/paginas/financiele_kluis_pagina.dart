// THIMACO-CONTROLE: FINANCIELE-KLUIS-PAGINA-FASE2A-20260807
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../beveiliging/financiele_kluis_sessie_controller.dart';
import '../beveiliging/financiele_privacy_scherm_service.dart';
import '../opslag/financiele_versleuteling_service.dart';
import 'financiele_cockpit_pagina.dart';

class FinancieleKluisPagina extends StatefulWidget {
  const FinancieleKluisPagina({super.key});

  @override
  State<FinancieleKluisPagina> createState() {
    return _FinancieleKluisPaginaState();
  }
}

class _FinancieleKluisPaginaState extends State<FinancieleKluisPagina>
    with WidgetsBindingObserver {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);
  static const Color _rood = Color(0xFFDC2626);

  final FinancieleKluisSessieController _controller =
      FinancieleKluisSessieController.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.addListener(_verwerkControllerWijziging);
    FinancielePrivacySchermService.zetFinancieelSchermActief(true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FinancielePrivacySchermService.verbergPrivacySchildNaVeiligeFrame();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_verwerkControllerWijziging);
    _controller.vergrendel();
    FinancielePrivacySchermService.zetFinancieelSchermActief(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      _controller.vergrendel();
      return;
    }

    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        setState(() {});
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        FinancielePrivacySchermService.verbergPrivacySchildNaVeiligeFrame();
      });
    }
  }

  void _verwerkControllerWijziging() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _controller.registreerActiviteit(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          foregroundColor: _tekstDonker,
          title: const Row(
            children: <Widget>[
              Icon(Icons.security_outlined, color: _groen, size: 22),
              SizedBox(width: 9),
              Text(
                'Financiële kluis',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          actions: <Widget>[
            if (_controller.isOntgrendeld)
              IconButton(
                tooltip: 'Nu vergrendelen',
                onPressed: _controller.vergrendel,
                icon: const Icon(Icons.lock_outline_rounded),
              ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Positioned.fill(child: _bouwInhoud()),
              if (_controller.bewerkingBezig)
                const Positioned.fill(child: _BeveiligdeBewerkingOverlay()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bouwInhoud() {
    switch (_controller.status) {
      case FinancieleKluisStatus.nietBeschikbaar:
        return _bouwMelding(
          icoon: Icons.block_rounded,
          titel: 'Geen toegang',
          tekst:
              'Deze pagina is op dit toestel en in deze app-build niet beschikbaar.',
          kleur: _rood,
        );

      case FinancieleKluisStatus.configuratieOntbreekt:
        return _bouwConfiguratieOntbreekt();

      case FinancieleKluisStatus.initialiseren:
        return const Center(child: CircularProgressIndicator());

      case FinancieleKluisStatus.nietGeactiveerd:
        return _bouwActivatie();

      case FinancieleKluisStatus.vergrendeld:
        return _bouwVergrendeld();

      case FinancieleKluisStatus.ontgrendeld:
        return _bouwOntgrendeld();

      case FinancieleKluisStatus.herstelNodig:
        return _bouwHerstelNodig();

      case FinancieleKluisStatus.fout:
        return _bouwMelding(
          icoon: Icons.error_outline_rounded,
          titel: 'Beveiligingsfout',
          tekst: _controller.foutBericht.isEmpty
              ? 'De financiële kluis kon niet worden gestart.'
              : _controller.foutBericht,
          kleur: _rood,
          actieTekst: 'Opnieuw controleren',
          onActie: _controller.initialiseer,
        );
    }
  }

  Widget _bouwConfiguratieOntbreekt() {
    return _bouwMelding(
      icoon: Icons.admin_panel_settings_outlined,
      titel: 'Eigenaarbuild niet volledig ingesteld',
      tekst:
          'De financiële module is wel ingeschakeld, maar de SHA-256-hash '
          'van de eigenaar-activatiecode ontbreekt. Bouw de eigenaarversie '
          'opnieuw met beide beveiligde dart-defines.',
      kleur: _rood,
    );
  }

  Widget _bouwActivatie() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: <Widget>[
        _bouwIntroKaart(
          icoon: Icons.phonelink_lock_outlined,
          titel: 'Registreer deze iPad',
          tekst:
              'Deze eigenaarbuild kan één lokale financiële kluis activeren. '
              'Na de activatie wordt de hoofdsleutel aan de huidige biometrische '
              'set van deze iPad gekoppeld.',
        ),
        const SizedBox(height: 12),
        _bouwWaarschuwing(
          'Activeer uitsluitend jouw persoonlijke iPad. '
          'Op deze iPad mogen alleen jouw Face ID- of Touch ID-gegevens staan.',
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          style: _primaireKnopStijl(),
          onPressed: _controller.bewerkingBezig
              ? null
              : _activeerEigenaarstoestel,
          icon: const Icon(Icons.verified_user_outlined),
          label: const Text('Activeer deze iPad'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          style: _secundaireKnopStijl(),
          onPressed: _controller.bewerkingBezig ? null : _herstelNoodbackup,
          icon: const Icon(Icons.settings_backup_restore_rounded),
          label: const Text('Herstel bestaande kluis'),
        ),
        if (_controller.foutBericht.isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          _bouwFoutKaart(_controller.foutBericht),
        ],
      ],
    );
  }

  Widget _bouwVergrendeld() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: <Widget>[
        _bouwIntroKaart(
          icoon: Icons.lock_outline_rounded,
          titel: 'Kluis vergrendeld',
          tekst:
              'De financiële gegevens zijn lokaal versleuteld. '
              'Face ID of Touch ID moet de toestelgebonden sleutel vrijgeven.',
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          style: _primaireKnopStijl(),
          onPressed: _controller.bewerkingBezig ? null : _ontgrendel,
          icon: const Icon(Icons.face_retouching_natural_outlined),
          label: const Text('Ontgrendel met biometrie'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          style: _secundaireKnopStijl(),
          onPressed: _controller.bewerkingBezig ? null : _herstelNoodbackup,
          icon: const Icon(Icons.settings_backup_restore_rounded),
          label: const Text('Herstel met noodback-up'),
        ),
        const SizedBox(height: 10),
        _bouwWaarschuwing(
          'Gebruik noodherstel alleen wanneer biometrisch ontgrendelen niet '
          'meer lukt, bijvoorbeeld nadat Face ID of Touch ID op deze iPad '
          'werd gewijzigd. De gekozen back-up vervangt dan de lokale kluis.',
        ),
        if (_controller.foutBericht.isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          _bouwFoutKaart(_controller.foutBericht),
        ],
      ],
    );
  }

  Widget _bouwHerstelNodig() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: <Widget>[
        _bouwIntroKaart(
          icoon: Icons.restore_page,
          titel: 'Noodback-up vereist',
          tekst:
              'Deze iPad bevat nog een eigenaarregistratie, maar het lokale '
              'kluisbestand ontbreekt. Herstel het versleutelde '
              '.thimacofin-bestand met de papieren herstelcode.',
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          style: _primaireKnopStijl(),
          onPressed: _controller.bewerkingBezig ? null : _herstelNoodbackup,
          icon: const Icon(Icons.settings_backup_restore_rounded),
          label: const Text('Noodback-up herstellen'),
        ),
        if (_controller.foutBericht.isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          _bouwFoutKaart(_controller.foutBericht),
        ],
      ],
    );
  }

  Widget _bouwOntgrendeld() {
    return FinancieleCockpitPagina(
      controller: _controller,
      onMaakNoodbackup: () => _maakNoodbackup(context),
    );
  }

  Future<void> _activeerEigenaarstoestel() async {
    final activatieCode = await _vraagGeheimeTekst(
      titel: 'Eigenaar-activatiecode',
      uitleg:
          'Voer de lange activatiecode in die uitsluitend voor jouw '
          'eigenaarbuild werd gekozen.',
      label: 'Activatiecode',
      actie: 'Activeren',
    );
    if (activatieCode == null || !mounted) {
      return;
    }

    try {
      final herstelcode = await _controller.activeer(
        activatieCode: activatieCode,
      );
      if (!mounted) return;

      final bevestigd = await _toonHerstelcode(herstelcode);
      if (bevestigd != true || !mounted) {
        _toonMelding(
          'De kluis is geactiveerd. Maak zo snel mogelijk een noodback-up '
          'met de genoteerde herstelcode.',
          fout: true,
        );
        return;
      }

      final resultaat = await _controller.maakNoodbackup(
        herstelcode: herstelcode,
        sharePositionOrigin: _schermHerkomst(),
      );
      if (!mounted) return;

      _toonShareResultaat(
        resultaat,
        succesTekst:
            'De eerste versleutelde noodback-up is aangeboden om veilig te bewaren.',
      );
    } catch (fout) {
      if (!mounted) return;
      _toonMelding(fout.toString(), fout: true);
    }
  }

  Future<void> _ontgrendel() async {
    try {
      await _controller.ontgrendel();
    } catch (fout) {
      if (!mounted) return;
      _toonMelding(fout.toString(), fout: true);
    }
  }

  Future<void> _maakNoodbackup(BuildContext knopContext) async {
    final box = knopContext.findRenderObject() as RenderBox?;
    final herkomst = box == null
        ? _schermHerkomst()
        : box.localToGlobal(Offset.zero) & box.size;

    final herstelcode = await _vraagHerstelcode();
    if (herstelcode == null || !mounted) {
      return;
    }

    try {
      final resultaat = await _controller.maakNoodbackup(
        herstelcode: herstelcode,
        sharePositionOrigin: herkomst,
      );
      if (!mounted) return;

      _toonShareResultaat(
        resultaat,
        succesTekst: 'De versleutelde noodback-up is aangeboden om te bewaren.',
      );
    } catch (fout) {
      if (!mounted) return;
      _toonMelding(fout.toString(), fout: true);
    }
  }

  Future<void> _herstelNoodbackup() async {
    if (_controller.status == FinancieleKluisStatus.vergrendeld) {
      final bevestigd = await _bevestigVervangenVergrendeldeKluis();
      if (bevestigd != true || !mounted) {
        return;
      }
    }

    final herstelcode = await _vraagHerstelcode();
    if (herstelcode == null || !mounted) {
      return;
    }

    try {
      final hersteld = await _controller.herstelVanNoodbackup(
        herstelcode: herstelcode,
      );
      if (!mounted) return;

      if (hersteld) {
        _toonMelding('De financiële kluis is veilig op deze iPad hersteld.');
      }
    } catch (fout) {
      if (!mounted) return;
      _toonMelding(fout.toString(), fout: true);
    }
  }

  Future<bool?> _bevestigVervangenVergrendeldeKluis() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _rand),
          ),
          title: const Row(
            children: <Widget>[
              Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706)),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Lokale kluis vervangen?',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          content: const SizedBox(
            width: 470,
            child: Text(
              'De huidige vergrendelde kluis op deze iPad wordt vervangen '
              'door de gekozen versleutelde noodback-up. Gebruik dit alleen '
              'wanneer je zeker bent dat de back-up de juiste en meest recente '
              'gegevens bevat. Bij een mislukte herstelpoging blijft de huidige '
              'lokale kluis behouden.',
              style: TextStyle(color: _tekstDonker, height: 1.45),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuleren'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.settings_backup_restore_rounded),
              label: const Text('Back-up herstellen'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _vraagHerstelcode() async {
    final waarde = await _vraagGeheimeTekst(
      titel: 'Papieren herstelcode',
      uitleg:
          'Voer de 12 groepen van de papieren herstelcode in. '
          'De code wordt uitsluitend voor deze bewerking gebruikt.',
      label: 'Herstelcode',
      actie: 'Doorgaan',
    );
    if (waarde == null) {
      return null;
    }

    final genormaliseerd =
        FinancieleVersleutelingService.normaliseerHerstelcode(waarde);
    if (!FinancieleVersleutelingService.isGeldigeHerstelcode(genormaliseerd)) {
      if (mounted) {
        _toonMelding(
          'De herstelcode moet uit 12 groepen van 4 tekens bestaan.',
          fout: true,
        );
      }
      return null;
    }

    return genormaliseerd;
  }

  Future<String?> _vraagGeheimeTekst({
    required String titel,
    required String uitleg,
    required String label,
    required String actie,
  }) async {
    final invoerController = TextEditingController();
    var verbergen = true;

    try {
      return await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: _rand),
                ),
                title: Text(
                  titel,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                content: SizedBox(
                  width: 460,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        uitleg,
                        style: const TextStyle(color: _tekstGrijs, height: 1.4),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: invoerController,
                        autofocus: true,
                        obscureText: verbergen,
                        autocorrect: false,
                        enableSuggestions: false,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {
                          final tekst = invoerController.text.trim();
                          if (tekst.isNotEmpty) {
                            Navigator.pop(dialogContext, tekst);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: label,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            tooltip: verbergen ? 'Tonen' : 'Verbergen',
                            onPressed: () {
                              setDialogState(() {
                                verbergen = !verbergen;
                              });
                            },
                            icon: Icon(
                              verbergen
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Annuleren'),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: _groen,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      final tekst = invoerController.text.trim();
                      if (tekst.isNotEmpty) {
                        Navigator.pop(dialogContext, tekst);
                      }
                    },
                    child: Text(actie),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      invoerController.dispose();
    }
  }

  Future<bool?> _toonHerstelcode(String herstelcode) {
    var genoteerd = false;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: _rand),
              ),
              title: const Row(
                children: <Widget>[
                  Icon(Icons.vpn_key_outlined, color: _groen),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Eenmalige herstelcode',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'Schrijf deze code nu op papier en bewaar ze in een '
                      'brandkast. De app slaat de code niet op en toont ze '
                      'na het sluiten van dit venster nooit opnieuw.',
                      style: TextStyle(color: _tekstDonker, height: 1.45),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAF9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFB9E1C6)),
                      ),
                      child: Text(
                        herstelcode,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _tekstDonker,
                          fontSize: 16,
                          height: 1.6,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Maak hiervan geen screenshot en verstuur de code niet '
                      'per e-mail of bericht.',
                      style: TextStyle(
                        color: _rood,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: _groen,
                      value: genoteerd,
                      onChanged: (waarde) {
                        setDialogState(() {
                          genoteerd = waarde == true;
                        });
                      },
                      title: const Text(
                        'Ik heb de volledige code op papier genoteerd.',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _groen,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: genoteerd
                      ? () => Navigator.pop(dialogContext, true)
                      : null,
                  icon: const Icon(Icons.backup_outlined),
                  label: const Text('Noodback-up maken'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _bouwIntroKaart({
    required IconData icoon,
    required String titel,
    required String tekst,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _rand),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _lichtGroen,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icoon, color: _groen, size: 25),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  titel,
                  style: const TextStyle(
                    color: _tekstDonker,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tekst,
                  style: const TextStyle(
                    color: _tekstGrijs,
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwWaarschuwing(String tekst) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFB45309),
            size: 20,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              tekst,
              style: const TextStyle(
                color: Color(0xFF78350F),
                fontSize: 12.2,
                height: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwFoutKaart(String tekst) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F7),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.error_outline_rounded, color: _rood, size: 19),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tekst,
              style: const TextStyle(
                color: _rood,
                fontSize: 12.2,
                height: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwMelding({
    required IconData icoon,
    required String titel,
    required String tekst,
    required Color kleur,
    String? actieTekst,
    Future<void> Function()? onActie,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _rand),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icoon, color: kleur, size: 46),
                const SizedBox(height: 13),
                Text(
                  titel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _tekstDonker,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tekst,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _tekstGrijs,
                    fontSize: 12.8,
                    height: 1.45,
                  ),
                ),
                if (actieTekst != null && onActie != null) ...<Widget>[
                  const SizedBox(height: 16),
                  FilledButton(
                    style: _primaireKnopStijl(),
                    onPressed: onActie,
                    child: Text(actieTekst),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  ButtonStyle _primaireKnopStijl() {
    return FilledButton.styleFrom(
      backgroundColor: _groen,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontWeight: FontWeight.w900),
    );
  }

  ButtonStyle _secundaireKnopStijl() {
    return OutlinedButton.styleFrom(
      foregroundColor: _groen,
      backgroundColor: Colors.white,
      minimumSize: const Size.fromHeight(46),
      side: const BorderSide(color: Color(0xFFB9E1C6)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontWeight: FontWeight.w900),
    );
  }

  Rect _schermHerkomst() {
    final grootte = MediaQuery.sizeOf(context);
    return Rect.fromLTWH(0, 0, grootte.width, grootte.height);
  }

  void _toonShareResultaat(
    ShareResult resultaat, {
    required String succesTekst,
  }) {
    switch (resultaat.status) {
      case ShareResultStatus.success:
        _toonMelding(succesTekst);
        break;
      case ShareResultStatus.dismissed:
        _toonMelding(
          'Het deelvenster werd gesloten. Controleer of de noodback-up '
          'daadwerkelijk op een veilige plaats is bewaard.',
          fout: true,
        );
        break;
      case ShareResultStatus.unavailable:
        _toonMelding(
          'Het iOS-deelvenster kon niet bevestigen of de noodback-up is bewaard. '
          'Controleer de gekozen locatie.',
          fout: true,
        );
        break;
    }
  }

  void _toonMelding(String tekst, {bool fout = false}) {
    final schoon = tekst.trim().isEmpty
        ? 'De bewerking kon niet worden uitgevoerd.'
        : tekst.trim();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(schoon), backgroundColor: fout ? _rood : _groen),
      );
  }
}

class _BeveiligdeBewerkingOverlay extends StatelessWidget {
  const _BeveiligdeBewerkingOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0x66000000),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(strokeWidth: 2.4),
              SizedBox(height: 12),
              Text(
                'Beveiligde bewerking…',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
