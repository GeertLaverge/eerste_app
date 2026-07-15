import 'package:flutter/material.dart';

import '../helpers/app_storage.dart';
import '../helpers/sync/onedrive_sync_service.dart';
import '../helpers/opmeting/overzicht/opmeting_overzicht_model.dart';
import '../helpers/opmeting/overzicht/opmeting_overzicht_tekening.dart';
import 'opmeting_raam_pagina.dart';

class OpmetingPagina extends StatefulWidget {
  const OpmetingPagina({super.key});

  @override
  State<OpmetingPagina> createState() {
    return _OpmetingPaginaState();
  }
}

class _OpmetingPaginaState extends State<OpmetingPagina> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _achtergrond = Color(0xFFF7F8FA);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  String _klantNaam = '';
  bool _laden = false;
  final List<OpmetingOverzichtRaamItem> _raamOpmetingen =
      <OpmetingOverzichtRaamItem>[];

  bool _formulierOpenenBezig = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _laadOpmetingenVanOpslag({String? klantNaam}) async {
    setState(() {
      _laden = true;
    });

    final alleOpmetingen = await AppStorage.laadOpmetingen();

    if (!mounted) {
      return;
    }

    final actieveKlantNaam = klantNaam ?? _klantNaam;
    final klantFilter = actieveKlantNaam.trim().toLowerCase();

    final zichtbareOpmetingen = klantFilter.isEmpty
        ? <OpmetingOverzichtRaamItem>[]
        : alleOpmetingen.where((opmeting) {
            return opmeting.klantNaam.trim().toLowerCase() == klantFilter;
          }).toList();

    setState(() {
      _klantNaam = actieveKlantNaam.trim();
      _raamOpmetingen
        ..clear()
        ..addAll(zichtbareOpmetingen);
      _laden = false;
    });
  }

  Future<String?> _vraagKlantNaam() async {
    final naam = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _KlantNaamDialog(beginNaam: _klantNaam);
      },
    );

    await Future<void>.delayed(Duration.zero);

    if (mounted) {
      await WidgetsBinding.instance.endOfFrame;
    }

    return naam?.trim();
  }

  Future<void> _nieuwBestand() async {
    final naam = await _vraagKlantNaam();

    if (naam == null || naam.trim().isEmpty || !mounted) {
      return;
    }

    setState(() {
      _klantNaam = naam.trim();
      _raamOpmetingen.clear();
    });
  }

  Future<void> _wachtTotPopupEnDialogGeslotenZijn() async {
    await Future<void>.delayed(Duration.zero);

    if (!mounted) {
      return;
    }

    await WidgetsBinding.instance.endOfFrame;
  }

  Map<String, List<OpmetingOverzichtRaamItem>> _groepeerOpmetingenPerKlant(
    List<OpmetingOverzichtRaamItem> opmetingen,
  ) {
    final klanten = <String, List<OpmetingOverzichtRaamItem>>{};

    for (final opmeting in opmetingen) {
      final klantNaam = opmeting.klantNaam.trim().isEmpty
          ? 'Zonder klantnaam'
          : opmeting.klantNaam.trim();

      klanten
          .putIfAbsent(klantNaam, () => <OpmetingOverzichtRaamItem>[])
          .add(opmeting);
    }

    return klanten;
  }

  List<String> _gesorteerdeKlantNamen(
    Map<String, List<OpmetingOverzichtRaamItem>> klanten,
  ) {
    return klanten.keys.toList()..sort((eerste, tweede) {
      return eerste.toLowerCase().compareTo(tweede.toLowerCase());
    });
  }

  Future<void> _openBestand() async {
    await OneDriveSyncService().slimmeSync(magLoginVragen: true);

    if (!mounted) {
      return;
    }

    final alleOpmetingen = await AppStorage.laadOpmetingen();

    if (!mounted) {
      return;
    }

    if (alleOpmetingen.isEmpty) {
      _toonMelding('Er zijn nog geen opgeslagen opmetingen.', fout: true);
      return;
    }

    final klanten = _groepeerOpmetingenPerKlant(alleOpmetingen);
    final klantNamen = _gesorteerdeKlantNamen(klanten);

    final gekozenKlant = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Klant openen',
            style: TextStyle(color: _groen, fontWeight: FontWeight.w900),
          ),
          content: SizedBox(
            width: 430,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 420),
              child: ListView(
                shrinkWrap: true,
                children: [
                  ...klantNamen.map((klantNaam) {
                    final aantal = klanten[klantNaam]?.length ?? 0;

                    return ListTile(
                      leading: const Icon(
                        Icons.description_outlined,
                        color: _groen,
                      ),
                      title: Text(
                        klantNaam,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text('$aantal opmeting(en)'),
                      onTap: () {
                        Navigator.pop(dialogContext, klantNaam);
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: _groen),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Annuleren'),
            ),
          ],
        );
      },
    );

    if (gekozenKlant == null) {
      return;
    }

    await _laadOpmetingenVanOpslag(klantNaam: gekozenKlant);

    if (!mounted) {
      return;
    }

    _toonMelding('Opmeetbestand “$gekozenKlant” is geopend.');
  }

  Future<void> _wisBestand() async {
    await OneDriveSyncService().slimmeSync(magLoginVragen: true);

    if (!mounted) {
      return;
    }

    final alleOpmetingen = await AppStorage.laadOpmetingen();

    if (!mounted) {
      return;
    }

    if (alleOpmetingen.isEmpty) {
      _toonMelding('Er zijn nog geen opgeslagen opmeetbestanden.', fout: true);
      return;
    }

    final klanten = _groepeerOpmetingenPerKlant(alleOpmetingen);
    final klantNamen = _gesorteerdeKlantNamen(klanten);

    final gekozenKlant = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Bestand wissen',
            style: TextStyle(
              color: Color(0xFFDC2626),
              fontWeight: FontWeight.w900,
            ),
          ),
          content: SizedBox(
            width: 430,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 420),
              child: ListView(
                shrinkWrap: true,
                children: [
                  ...klantNamen.map((klantNaam) {
                    final aantal = klanten[klantNaam]?.length ?? 0;

                    return ListTile(
                      leading: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFDC2626),
                      ),
                      title: Text(
                        klantNaam,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text('$aantal opmeting(en)'),
                      onTap: () {
                        Navigator.pop(dialogContext, klantNaam);
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: _groen),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Annuleren'),
            ),
          ],
        );
      },
    );

    if (gekozenKlant == null || !mounted) {
      return;
    }

    final teWissenOpmetingen =
        klanten[gekozenKlant] ?? const <OpmetingOverzichtRaamItem>[];

    if (teWissenOpmetingen.isEmpty) {
      _toonMelding('Dit bestand kon niet gevonden worden.', fout: true);
      return;
    }

    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Bestand definitief wissen?'),
          content: Text(
            'Bent u zeker dat u het volledige opmeetbestand “$gekozenKlant” wilt wissen? '
            'Alle ${teWissenOpmetingen.length} positie(s) van deze klant worden verwijderd.',
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: _groen),
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Annuleren'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Wissen'),
            ),
          ],
        );
      },
    );

    if (bevestigen != true) {
      return;
    }

    setState(() {
      _laden = true;
    });

    for (final opmeting in teWissenOpmetingen) {
      await AppStorage.verwijderOpmeting(opmeting.id);
    }

    await OneDriveSyncService.registreerLokaleWijziging();

    final syncResultaat = await OneDriveSyncService().slimmeSync(
      magLoginVragen: true,
    );

    if (!mounted) {
      return;
    }

    final gewisteKlantIsOpen =
        _klantNaam.trim().toLowerCase() == gekozenKlant.trim().toLowerCase();

    if (gewisteKlantIsOpen) {
      setState(() {
        _klantNaam = '';
        _raamOpmetingen.clear();
        _laden = false;
      });
    } else {
      await _laadOpmetingenVanOpslag(
        klantNaam: _klantNaam.trim().isEmpty ? null : _klantNaam,
      );
    }

    if (!mounted) {
      return;
    }

    final syncOk =
        !syncResultaat.startsWith('FOUT') &&
        !syncResultaat.contains('FOUT') &&
        !syncResultaat.contains('OVERGESLAGEN');

    _toonMelding(
      syncOk
          ? 'Opmeetbestand “$gekozenKlant” is gewist en gesynchroniseerd.'
          : 'Opmeetbestand “$gekozenKlant” is lokaal gewist, maar synchronisatie is niet gelukt: $syncResultaat',
      fout: !syncOk,
    );
  }

  Future<bool> _opslaanBestand({bool toonMelding = true}) async {
    final alleOpmetingen = await AppStorage.laadOpmetingenVoorSync();

    if (!mounted) {
      return false;
    }

    if (alleOpmetingen.isEmpty) {
      if (toonMelding) {
        _toonMelding(
          'Er is nog geen opmeting om op te slaan. Voeg eerst een raamopmeting toe.',
          fout: true,
        );
      }
      return false;
    }

    await AppStorage.bewaarOpmetingenVoorSync(alleOpmetingen);
    await OneDriveSyncService.registreerLokaleWijziging();

    final syncResultaat = await OneDriveSyncService().slimmeSync(
      magLoginVragen: true,
    );

    if (!mounted) {
      return false;
    }

    final syncOk =
        !syncResultaat.startsWith('FOUT') &&
        !syncResultaat.contains('FOUT') &&
        !syncResultaat.contains('OVERGESLAGEN');

    if (toonMelding) {
      _toonMelding(
        syncOk
            ? 'Bestand opgeslagen en synchronisatie uitgevoerd.'
            : 'Bestand lokaal opgeslagen, maar synchronisatie is niet gelukt: $syncResultaat',
        fout: !syncOk,
      );
    }

    return syncOk;
  }

  Future<void> _eindeOpmeting() async {
    final heeftOpmetingen =
        _raamOpmetingen.isNotEmpty ||
        (await AppStorage.laadOpmetingenVoorSync()).isNotEmpty;

    if (!mounted) {
      return;
    }

    if (!heeftOpmetingen) {
      await Navigator.of(context).maybePop();
      return;
    }

    final keuze = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Bestand opslaan?'),
          content: const Text(
            'Wilt u het bestand opslaan en synchroniseren voordat u terugkeert naar Home?',
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: _tekstGrijs),
              onPressed: () {
                Navigator.pop(dialogContext, 'annuleren');
              },
              child: const Text('Annuleren'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: _groen),
              onPressed: () {
                Navigator.pop(dialogContext, 'niet_opslaan');
              },
              child: const Text('Niet opslaan'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _groen,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, 'opslaan');
              },
              child: const Text('Opslaan'),
            ),
          ],
        );
      },
    );

    if (keuze == null || keuze == 'annuleren') {
      return;
    }

    if (keuze == 'opslaan') {
      await _opslaanBestand(toonMelding: false);

      if (!mounted) {
        return;
      }
    }

    await Navigator.of(context).maybePop();
  }

  Future<void> _openRaamopmeting({String formulierType = 'pvcRaam'}) async {
    if (_formulierOpenenBezig) {
      return;
    }

    _formulierOpenenBezig = true;

    try {
      var klantNaam = _klantNaam.trim();

      if (klantNaam.isEmpty) {
        final naam = await _vraagKlantNaam();

        if (naam == null || naam.trim().isEmpty || !mounted) {
          return;
        }

        klantNaam = naam.trim();

        setState(() {
          _klantNaam = klantNaam;
          _raamOpmetingen.clear();
        });
      }

      await _wachtTotPopupEnDialogGeslotenZijn();

      if (!mounted) {
        return;
      }

      final resultaat = await Navigator.of(context)
          .push<OpmetingOverzichtRaamItem>(
            MaterialPageRoute(
              builder: (routeContext) {
                return OpmetingRaamPagina(
                  klantNaam: klantNaam,
                  formulierType: formulierType,
                );
              },
            ),
          );

      if (resultaat == null || !mounted) {
        return;
      }

      await _laadOpmetingenVanOpslag(klantNaam: klantNaam);
    } finally {
      _formulierOpenenBezig = false;
    }
  }

  Future<void> _bewerkRaamopmeting(OpmetingOverzichtRaamItem item) async {
    final resultaat = await Navigator.push<OpmetingOverzichtRaamItem>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return OpmetingRaamPagina(
            klantNaam: item.klantNaam,
            bestaandeOpmeting: item,
            formulierType: item.formulierTypeGenormaliseerd,
          );
        },
      ),
    );

    if (resultaat == null || !mounted) {
      return;
    }

    await _laadOpmetingenVanOpslag(
      klantNaam: _klantNaam.trim().isEmpty ? null : _klantNaam,
    );
  }

  Future<void> _verwijderRaamopmeting(OpmetingOverzichtRaamItem item) async {
    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Opmeting verwijderen?'),
          content: Text('De opmeting “${item.titel}” wordt verwijderd.'),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: _groen),
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Annuleren'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Verwijderen'),
            ),
          ],
        );
      },
    );

    if (bevestigen != true) {
      return;
    }

    await AppStorage.verwijderOpmeting(item.id);

    if (!mounted) {
      return;
    }

    await _laadOpmetingenVanOpslag(
      klantNaam: _klantNaam.trim().isEmpty ? null : _klantNaam,
    );

    if (!mounted) {
      return;
    }

    _toonMelding('Opmeting verwijderd en synchronisatie gestart.');
  }

  void _toonMelding(String tekst, {bool fout = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tekst),
        backgroundColor: fout ? const Color(0xFFDC2626) : _groen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _achtergrond,
      body: SafeArea(
        child: Column(
          children: [
            _bouwBovenbalk(),
            Expanded(
              child: _laden
                  ? const Center(
                      child: CircularProgressIndicator(color: _groen),
                    )
                  : _raamOpmetingen.isEmpty
                  ? _bouwLegeFiche()
                  : _bouwOverzichtslijst(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bouwBovenbalk() {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _rand)),
      ),
      child: Row(
        children: [
          PopupMenuButton<String>(
            tooltip: 'Bestand',
            onSelected: (waarde) {
              if (waarde == 'nieuw') {
                _nieuwBestand();
              } else if (waarde == 'open') {
                _openBestand();
              } else if (waarde == 'opslaan') {
                _opslaanBestand();
              } else if (waarde == 'wissen') {
                _wisBestand();
              } else if (waarde == 'einde') {
                _eindeOpmeting();
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(value: 'nieuw', child: Text('Nieuw bestand')),
                PopupMenuItem(value: 'open', child: Text('Open bestand')),
                PopupMenuItem(value: 'opslaan', child: Text('Opslaan bestand')),
                PopupMenuItem(
                  value: 'wissen',
                  child: Text(
                    'Bestand wissen',
                    style: TextStyle(color: Color(0xFFDC2626)),
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem(value: 'einde', child: Text('Einde')),
              ];
            },
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 13),
              decoration: BoxDecoration(
                color: _lichtGroen,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: const Color(0xFFCDEBD6)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.folder_open_rounded, color: _groen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Bestand',
                    style: TextStyle(
                      color: _groen,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, color: _groen, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _titelBovenbalk(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _tekstDonker,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            tooltip: 'Formulier toevoegen',
            onSelected: (waarde) {
              if (waarde == 'pvc_raam') {
                _openRaamopmeting(formulierType: 'pvcRaam');
              } else if (waarde == 'alu_raam') {
                _openRaamopmeting(formulierType: 'aluRaam');
              } else if (waarde == 'pvc_deur') {
                _openRaamopmeting(formulierType: 'pvcDeur');
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<String>(
                  enabled: false,
                  child: Text(
                    'Ramen',
                    style: TextStyle(
                      color: _groen,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'pvc_raam',
                  child: Row(
                    children: [
                      Icon(Icons.window_rounded, color: _groen, size: 20),
                      SizedBox(width: 10),
                      Text('PVC Raam'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'alu_raam',
                  child: Row(
                    children: [
                      Icon(Icons.window_outlined, color: _groen, size: 20),
                      SizedBox(width: 10),
                      Text('ALU Raam'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  enabled: false,
                  child: Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Deuren',
                      style: TextStyle(
                        color: _groen,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'pvc_deur',
                  child: Row(
                    children: [
                      Icon(
                        Icons.door_front_door_outlined,
                        color: _groen,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text('PVC Deur'),
                    ],
                  ),
                ),
              ];
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _groen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _titelBovenbalk() {
    if (_klantNaam.trim().isNotEmpty) {
      return _klantNaam.trim();
    }

    return 'Kies een opmeetbestand';
  }

  Widget _bouwLegeFiche() {
    final heeftKlantNaam = _klantNaam.trim().isNotEmpty;

    return Center(
      child: Container(
        width: 540,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _rand),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: _lichtGroen,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: _groen,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              heeftKlantNaam
                  ? 'Nog geen opmetingen voor $_klantNaam'
                  : 'Nog geen opmeetbestand geopend',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _tekstDonker,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              heeftKlantNaam
                  ? 'Voeg rechtsboven een opmeting toe voor dit opmeetbestand.'
                  : 'Maak een nieuw bestand aan of open één klant via de knop Bestand.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _tekstGrijs,
                fontSize: 14,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: _nieuwBestand,
                  icon: const Icon(Icons.note_add_outlined),
                  label: const Text('Nieuw bestand'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _groen,
                    side: const BorderSide(color: _groen),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _openBestand,
                  icon: const Icon(Icons.folder_open_rounded),
                  label: const Text('Open bestand'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _groen,
                    side: const BorderSide(color: _groen),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Formulier toevoegen',
                  onSelected: (waarde) {
                    if (waarde == 'pvc_raam') {
                      _openRaamopmeting(formulierType: 'pvcRaam');
                    } else if (waarde == 'alu_raam') {
                      _openRaamopmeting(formulierType: 'aluRaam');
                    } else if (waarde == 'pvc_deur') {
                      _openRaamopmeting(formulierType: 'pvcDeur');
                    }
                  },
                  itemBuilder: (context) {
                    return const [
                      PopupMenuItem<String>(
                        enabled: false,
                        child: Text(
                          'Ramen',
                          style: TextStyle(
                            color: _groen,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'pvc_raam',
                        child: Text('PVC Raam'),
                      ),
                      PopupMenuItem<String>(
                        value: 'alu_raam',
                        child: Text('ALU Raam'),
                      ),
                      PopupMenuItem<String>(
                        enabled: false,
                        child: Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Deuren',
                            style: TextStyle(
                              color: _groen,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'pvc_deur',
                        child: Text('PVC Deur'),
                      ),
                    ];
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: _groen,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Formulier toevoegen',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bouwOverzichtslijst() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      itemCount: _raamOpmetingen.length,
      itemBuilder: (context, index) {
        final item = _raamOpmetingen[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _RaamOverzichtKaart(
            item: item,
            volgnummer: index + 1,
            onOpenen: () {
              _bewerkRaamopmeting(item);
            },
            onVerwijderen: () {
              _verwijderRaamopmeting(item);
            },
          ),
        );
      },
    );
  }
}

class _KlantNaamDialog extends StatefulWidget {
  const _KlantNaamDialog({required this.beginNaam});

  final String beginNaam;

  @override
  State<_KlantNaamDialog> createState() {
    return _KlantNaamDialogState();
  }
}

class _KlantNaamDialogState extends State<_KlantNaamDialog> {
  static const Color _groen = Color(0xFF0B7A3B);

  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.beginNaam);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _aanmaken() {
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nieuw opmeetbestand'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          labelText: 'Naam klant',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) {
          _aanmaken();
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Annuleren'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _groen,
            foregroundColor: Colors.white,
          ),
          onPressed: _aanmaken,
          child: const Text('Aanmaken'),
        ),
      ],
    );
  }
}

class _RaamOverzichtKaart extends StatelessWidget {
  const _RaamOverzichtKaart({
    required this.item,
    required this.volgnummer,
    required this.onOpenen,
    required this.onVerwijderen,
  });

  final OpmetingOverzichtRaamItem item;
  final int volgnummer;
  final VoidCallback onOpenen;
  final VoidCallback onVerwijderen;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final technischeRegels = _technischeRegelsZonderMaten(
      item.zichtbareTechnischeRegels,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _rand),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _lichtGroen,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Pos $volgnummer',
                  style: const TextStyle(
                    color: _groen,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.formulierTypeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _tekstDonker,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Openen',
                onPressed: onOpenen,
                icon: const Icon(Icons.open_in_new_rounded, color: _groen),
              ),
              IconButton(
                tooltip: 'Verwijderen',
                onPressed: onVerwijderen,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Raammaat: ${item.raammaatBreedteMm} × ${item.raammaatHoogteMm} mm',
            style: const TextStyle(
              color: _tekstDonker,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 330,
                child: AspectRatio(
                  aspectRatio: 1.45,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _rand),
                    ),
                    child: CustomPaint(
                      painter: OpmetingOverzichtTekening(item: item),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: technischeRegels.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          'Geen technische kenmerken ingevuld.',
                          style: TextStyle(
                            color: _tekstGrijs,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : _bouwTechnischeTekst(technischeRegels),
              ),
            ],
          ),
          if (item.notities.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _rand),
              ),
              child: Text(
                item.notities.trim(),
                style: const TextStyle(
                  color: _tekstDonker,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<OpmetingOverzichtTechnischeRegel> _technischeRegelsZonderMaten(
    List<OpmetingOverzichtTechnischeRegel> regels,
  ) {
    return regels.where((regel) {
      final titel = regel.titel.trim().toLowerCase();
      final waarde = regel.waarde.trim().toLowerCase();

      if (titel.isEmpty && waarde.isEmpty) {
        return false;
      }

      if (titel == 'maten' ||
          titel == 'maat' ||
          titel == 'afmeting' ||
          titel == 'afmetingen') {
        return false;
      }

      if (titel.contains('raammaat') ||
          titel.contains('dagmaat') ||
          waarde.startsWith('raammaat') ||
          waarde.startsWith('dagmaat')) {
        return false;
      }

      return true;
    }).toList();
  }

  Widget _bouwTechnischeTekst(
    List<OpmetingOverzichtTechnischeRegel> technischeRegels,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: technischeRegels.map((regel) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                regel.titel,
                style: const TextStyle(
                  color: _tekstGrijs,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                regel.waarde,
                style: const TextStyle(
                  color: _tekstDonker,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  height: 1.22,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
