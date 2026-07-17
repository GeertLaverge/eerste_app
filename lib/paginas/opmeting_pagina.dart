import 'dart:async';

import 'package:flutter/material.dart';

import '../helpers/app_storage.dart';
import '../helpers/sync/onedrive_sync_service.dart';
import '../helpers/opmeting/overzicht/opmeting_overzicht_model.dart';
import '../helpers/opmeting/overzicht/opmeting_overzicht_tekening.dart';
import '../helpers/opmeting/project/opmeting_project_kleur_model.dart';
import '../helpers/opmeting/project/opmeting_project_titelhoofd_model.dart';
import '../helpers/opmeting/project/opmeting_project_titelhoofd_kaart.dart';
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

  OpmetingProjectTitelhoofd _projectTitelhoofd =
      const OpmetingProjectTitelhoofd();

  List<OpmetingProjectKleurSubmenu> _projectKleurMenus =
      <OpmetingProjectKleurSubmenu>[];

  Set<String> _verborgenFormulierTypes = <String>{};

  bool _formulierOpenenBezig = false;

  Timer? _titelhoofdBewaarTimer;

  bool get _heeftOpenBestand {
    return _klantNaam.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _laadProjectKleuren();
  }

  @override
  void dispose() {
    _titelhoofdBewaarTimer?.cancel();
    super.dispose();
  }

  Future<void> _laadOpmetingenVanOpslag({String? klantNaam}) async {
    setState(() {
      _laden = true;
    });

    final alleOpmetingen = await AppStorage.laadOpmetingen();

    final actieveKlantNaam = klantNaam ?? _klantNaam;
    final klantFilter = actieveKlantNaam.trim().toLowerCase();

    final zichtbareOpmetingen = klantFilter.isEmpty
        ? <OpmetingOverzichtRaamItem>[]
        : alleOpmetingen.where((opmeting) {
            return opmeting.klantNaam.trim().toLowerCase() == klantFilter;
          }).toList();

    final titelhoofd = await AppStorage.laadOpmetingProjectTitelhoofd(
      actieveKlantNaam,
    );

    if (!mounted) {
      return;
    }

    final bestaandeTypes = zichtbareOpmetingen
        .map((opmeting) => opmeting.formulierTypeGenormaliseerd)
        .toSet();

    setState(() {
      _klantNaam = actieveKlantNaam.trim();
      _projectTitelhoofd =
          titelhoofd.klantNaam.trim().isEmpty &&
              actieveKlantNaam.trim().isNotEmpty
          ? titelhoofd.copyWith(klantNaam: actieveKlantNaam.trim())
          : titelhoofd;
      _raamOpmetingen
        ..clear()
        ..addAll(zichtbareOpmetingen);
      _verborgenFormulierTypes = _verborgenFormulierTypes
          .where(bestaandeTypes.contains)
          .toSet();
      _laden = false;
    });
  }

  Future<void> _laadProjectKleuren() async {
    final kleuren = await AppStorage.laadOpmetingProjectKleuren();

    if (!mounted) {
      return;
    }

    setState(() {
      _projectKleurMenus = kleuren;
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

    final klantNaam = naam.trim();
    final titelhoofd = await AppStorage.laadOpmetingProjectTitelhoofd(
      klantNaam,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _klantNaam = klantNaam;
      _projectTitelhoofd = titelhoofd.klantNaam.trim().isEmpty
          ? titelhoofd.copyWith(klantNaam: klantNaam)
          : titelhoofd;
      _raamOpmetingen.clear();
      _verborgenFormulierTypes.clear();
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
        _projectTitelhoofd = const OpmetingProjectTitelhoofd();
        _raamOpmetingen.clear();
        _verborgenFormulierTypes.clear();
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

  void _verwerkTitelhoofdWijziging(OpmetingProjectTitelhoofd titelhoofd) {
    final bestaandeKlantNaam = _klantNaam.trim();
    final nieuweKlantNaam = titelhoofd.klantNaam.trim();

    final naamVoorBestand = nieuweKlantNaam.isNotEmpty
        ? nieuweKlantNaam
        : bestaandeKlantNaam;

    final titelhoofdVoorState = titelhoofd.copyWith(
      gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
    );

    setState(() {
      _projectTitelhoofd = titelhoofdVoorState;

      if (naamVoorBestand.isNotEmpty && naamVoorBestand != _klantNaam) {
        _klantNaam = naamVoorBestand;

        for (var index = 0; index < _raamOpmetingen.length; index++) {
          _raamOpmetingen[index] = _raamOpmetingen[index]
              .copyWith(klantNaam: naamVoorBestand)
              .metNieuweWijzigingsDatum();
        }
      }
    });

    _titelhoofdBewaarTimer?.cancel();
    _titelhoofdBewaarTimer = Timer(const Duration(milliseconds: 700), () {
      _bewaarTitelhoofdOpAchtergrond(titelhoofdVoorState);
    });
  }

  Future<void> _bewaarTitelhoofdOpAchtergrond(
    OpmetingProjectTitelhoofd titelhoofd,
  ) async {
    final klantNaam = titelhoofd.klantNaam.trim();

    if (klantNaam.isEmpty) {
      return;
    }

    await AppStorage.bewaarOpmetingProjectTitelhoofd(titelhoofd);

    if (_raamOpmetingen.isNotEmpty) {
      final ids = _raamOpmetingen.map((item) => item.id).toSet();
      final alleOpmetingen = await AppStorage.laadOpmetingenVoorSync();
      var gewijzigd = false;

      final bijgewerkteOpmetingen = alleOpmetingen.map((item) {
        if (!ids.contains(item.id) || item.klantNaam == klantNaam) {
          return item;
        }

        gewijzigd = true;
        return item.copyWith(klantNaam: klantNaam).metNieuweWijzigingsDatum();
      }).toList();

      if (gewijzigd) {
        await AppStorage.bewaarOpmetingenVoorSync(bijgewerkteOpmetingen);
        await OneDriveSyncService.registreerLokaleWijziging();
        OneDriveSyncService().uploadBackupOpAchtergrond();
      }
    }
  }

  Future<void> _laadKlantUitAgenda() async {
    final klanten = await AppStorage.laadAgendaKlantenVoorOpmeting();

    if (!mounted) {
      return;
    }

    if (klanten.isEmpty) {
      _toonMelding('Geen klanten gevonden in de blauwe agenda.', fout: true);
      return;
    }

    final keuze = await toonOpmetingAgendaKlantKeuzeDialog(
      context: context,
      klanten: klanten,
    );

    if (keuze == null || !mounted) {
      return;
    }

    final bestaand = await AppStorage.laadOpmetingProjectTitelhoofd(
      keuze.klantNaam,
    );

    final titelhoofd = keuze
        .naarTitelhoofd(
          bestaand: bestaand.isLeeg ? _projectTitelhoofd : bestaand,
        )
        .copyWith(klantNaam: keuze.klantNaam)
        .metWijzigingsDatum();

    await AppStorage.bewaarOpmetingProjectTitelhoofd(titelhoofd);

    if (!mounted) {
      return;
    }

    setState(() {
      _klantNaam = keuze.klantNaam;
      _projectTitelhoofd = titelhoofd;
    });

    await _laadOpmetingenVanOpslag(klantNaam: keuze.klantNaam);

    if (mounted) {
      _toonMelding('Klantgegevens geladen uit de blauwe agenda.');
    }
  }

  void _toggleFormulierTypeZichtbaarheid(String typeKey) {
    setState(() {
      final nieuweVerborgenTypes = Set<String>.from(_verborgenFormulierTypes);

      if (nieuweVerborgenTypes.contains(typeKey)) {
        nieuweVerborgenTypes.remove(typeKey);
      } else {
        nieuweVerborgenTypes.add(typeKey);
      }

      _verborgenFormulierTypes = nieuweVerborgenTypes;
    });
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
                  : !_heeftOpenBestand
                  ? _bouwGeenBestandGeopend()
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
          if (_heeftOpenBestand)
            PopupMenuButton<String>(
              tooltip: 'Formulier toevoegen',
              onSelected: (waarde) {
                if (waarde == 'pvc_raam') {
                  _openRaamopmeting(formulierType: 'pvcRaam');
                } else if (waarde == 'alu_raam') {
                  _openRaamopmeting(formulierType: 'aluRaam');
                } else if (waarde == 'pvc_schuifraam') {
                  _openRaamopmeting(formulierType: 'pvcSchuifraam');
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
                    value: 'pvc_schuifraam',
                    child: Row(
                      children: [
                        Icon(Icons.view_week_outlined, color: _groen, size: 20),
                        SizedBox(width: 10),
                        Text('PVC Schuifraam'),
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
            )
          else
            const SizedBox(width: 42, height: 42),
        ],
      ),
    );
  }

  String _titelBovenbalk() {
    if (_klantNaam.trim().isNotEmpty) {
      return _klantNaam.trim();
    }

    return 'Opmetingen';
  }

  Widget _bouwGeenBestandGeopend() {
    return const SizedBox.expand();
  }

  Widget _bouwOverzichtslijst() {
    final zichtbareItems = <_OpmetingOverzichtItemMetPositie>[];

    for (var index = 0; index < _raamOpmetingen.length; index++) {
      final item = _raamOpmetingen[index];

      if (_verborgenFormulierTypes.contains(item.formulierTypeGenormaliseerd)) {
        continue;
      }

      zichtbareItems.add(
        _OpmetingOverzichtItemMetPositie(item: item, volgnummer: index + 1),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        OpmetingProjectTitelhoofdKaart(
          titelhoofd:
              _projectTitelhoofd.klantNaam.trim().isEmpty &&
                  _klantNaam.trim().isNotEmpty
              ? _projectTitelhoofd.copyWith(klantNaam: _klantNaam.trim())
              : _projectTitelhoofd,
          opmetingen: _raamOpmetingen,
          verborgenFormulierTypes: _verborgenFormulierTypes,
          kleurMenus: _projectKleurMenus,
          onTitelhoofdGewijzigd: _verwerkTitelhoofdWijziging,
          onKlantLaden: _laadKlantUitAgenda,
          onToggleFormulierType: _toggleFormulierTypeZichtbaarheid,
        ),
        const SizedBox(height: 14),
        if (zichtbareItems.isEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _rand),
            ),
            child: Text(
              _raamOpmetingen.isEmpty
                  ? 'Nog geen posities in deze fiche. Klik rechtsboven op + om een eerste opmeting toe te voegen.'
                  : 'Alle posities zijn tijdelijk verborgen. Klik bovenaan opnieuw op het oogje om ze terug te tonen.',
              style: const TextStyle(
                color: _tekstGrijs,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          ...zichtbareItems.map((zichtbaarItem) {
            final item = zichtbaarItem.item;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _RaamOverzichtKaart(
                item: item,
                volgnummer: zichtbaarItem.volgnummer,
                onOpenen: () {
                  _bewerkRaamopmeting(item);
                },
                onVerwijderen: () {
                  _verwijderRaamopmeting(item);
                },
              ),
            );
          }),
      ],
    );
  }
}

class _OpmetingOverzichtItemMetPositie {
  const _OpmetingOverzichtItemMetPositie({
    required this.item,
    required this.volgnummer,
  });

  final OpmetingOverzichtRaamItem item;
  final int volgnummer;
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
    final basisTheme = Theme.of(context);

    return Theme(
      data: basisTheme.copyWith(
        colorScheme: basisTheme.colorScheme.copyWith(
          primary: _groen,
          secondary: _groen,
          surface: Colors.white,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: _groen,
          selectionHandleColor: _groen,
        ),
        inputDecorationTheme: basisTheme.inputDecorationTheme.copyWith(
          floatingLabelStyle: const TextStyle(
            color: _groen,
            fontWeight: FontWeight.w700,
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: _groen, width: 2),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: _groen),
        ),
      ),
      child: AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
          decoration: const BoxDecoration(
            color: Color(0xFFE7F6EC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: const Row(
            children: [
              Icon(Icons.note_add_outlined, color: _groen),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Nieuw opmeetbestand',
                  style: TextStyle(color: _groen, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
        content: TextField(
          controller: _controller,
          autofocus: true,
          cursorColor: _groen,
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
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _groen,
              foregroundColor: Colors.white,
            ),
            onPressed: _aanmaken,
            child: const Text('Aanmaken'),
          ),
        ],
      ),
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
