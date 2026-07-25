import 'package:flutter/material.dart';

import '../../../helpers/app_storage.dart';
import '../../../helpers/offerte/prijzen/offerte_algemene_prijsregel_model.dart';
import '../../../helpers/offerte/prijzen/offerte_algemene_prijsregels_model.dart';
import '../../../helpers/offerte/prijzen/offerte_artikel_prijs_koppeling_service.dart';
import '../../../helpers/offerte/prijzen/offerte_prijs_eenheid.dart';
import '../../../helpers/offerte/prijzen/offerte_prijs_uitschrijfmodus.dart';
import 'offerte_algemene_prijsregel_dialog.dart';

class OfferteAlgemenePrijzenPagina extends StatefulWidget {
  const OfferteAlgemenePrijzenPagina({super.key});

  @override
  State<OfferteAlgemenePrijzenPagina> createState() {
    return _OfferteAlgemenePrijzenPaginaState();
  }
}

class _OfferteAlgemenePrijzenPaginaState
    extends State<OfferteAlgemenePrijzenPagina> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _achtergrond = Color(0xFFF7F8FA);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);
  static const Color _rood = Color(0xFFDC2626);
  static const Color _blauw = Color(0xFF2563EB);

  OfferteAlgemenePrijsregelsModel? _opslag;
  bool _laden = true;
  bool _opslaan = false;
  String? _foutmelding;

  @override
  void initState() {
    super.initState();
    _laadPrijsregels();
  }

  Future<void> _laadPrijsregels() async {
    if (mounted) {
      setState(() {
        _laden = true;
        _foutmelding = null;
      });
    }

    try {
      final opslag = await AppStorage.laadOfferteAlgemenePrijsregels();

      if (!mounted) {
        return;
      }

      setState(() {
        _opslag = opslag;
        _laden = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _laden = false;
        _foutmelding = 'De algemene prijsregels konden niet worden geladen: $e';
      });
    }
  }

  Future<void> _bewaarOpslag(
    OfferteAlgemenePrijsregelsModel opslag, {
    String? melding,
  }) async {
    if (_opslaan) {
      return;
    }

    final bijgewerkt = opslag.metWijzigingsDatum();

    setState(() {
      _opslaan = true;
      _opslag = bijgewerkt;
    });

    try {
      await AppStorage.bewaarOfferteAlgemenePrijsregels(bijgewerkt);

      if (!mounted) {
        return;
      }

      setState(() {
        _opslaan = false;
        _opslag = bijgewerkt;
      });

      if (melding != null && melding.isNotEmpty) {
        _toonMelding(melding);
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _opslaan = false;
      });

      _toonMelding(
        'Bewaren van de algemene prijsregels is niet gelukt: $e',
        fout: true,
      );
    }
  }

  Future<void> _voegPrijsregelToe() async {
    final opslag = _opslag;

    if (opslag == null || _opslaan) {
      return;
    }

    final prijsregel = await toonOfferteAlgemenePrijsregelDialog(
      context: context,
      volgendeVolgorde: _volgendeVolgorde(opslag),
    );

    if (prijsregel == null || !mounted) {
      return;
    }

    await _bewaarOpslag(
      opslag.metPrijsregel(prijsregel),
      melding: 'Algemene prijsregel toegevoegd.',
    );
  }

  Future<void> _wijzigPrijsregel(
    OfferteAlgemenePrijsregelModel prijsregel,
  ) async {
    final opslag = _opslag;

    if (opslag == null || _opslaan) {
      return;
    }

    final gewijzigd = await toonOfferteAlgemenePrijsregelDialog(
      context: context,
      volgendeVolgorde: prijsregel.volgorde,
      bestaandePrijsregel: prijsregel,
    );

    if (gewijzigd == null || !mounted) {
      return;
    }

    await _bewaarOpslag(
      opslag.metPrijsregel(gewijzigd),
      melding: 'Algemene prijsregel gewijzigd.',
    );
  }

  Future<void> _verwijderPrijsregel(
    OfferteAlgemenePrijsregelModel prijsregel,
  ) async {
    final opslag = _opslag;

    if (opslag == null || _opslaan) {
      return;
    }

    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Algemene prijsregel verwijderen?'),
          content: Text(
            '“${prijsregel.omschrijving}” wordt definitief uit de '
            'onafhankelijke algemene prijslijst verwijderd.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuleren'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _rood),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Verwijderen'),
            ),
          ],
        );
      },
    );

    if (bevestigen != true || !mounted) {
      return;
    }

    await _bewaarOpslag(
      opslag.zonderPrijsregel(prijsregel.id),
      melding: 'Algemene prijsregel verwijderd.',
    );
  }

  Future<void> _zetPrijsregelActief(
    OfferteAlgemenePrijsregelModel prijsregel,
    bool actief,
  ) async {
    final opslag = _opslag;

    if (opslag == null || _opslaan) {
      return;
    }

    await _bewaarOpslag(
      opslag.metPrijsregel(
        prijsregel.copyWith(
          actief: actief,
          gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
        ),
      ),
    );
  }

  Future<void> _verplaatsPrijsregel(
    OfferteAlgemenePrijsregelModel prijsregel,
    int richting,
  ) async {
    final opslag = _opslag;

    if (opslag == null || _opslaan || richting == 0) {
      return;
    }

    final regels = opslag.prijsregels.toList(growable: true);
    final huidigIndex = regels.indexWhere(
      (bestaand) => bestaand.id == prijsregel.id,
    );
    final nieuwIndex = huidigIndex + richting;

    if (huidigIndex < 0 || nieuwIndex < 0 || nieuwIndex >= regels.length) {
      return;
    }

    final verplaatste = regels.removeAt(huidigIndex);
    regels.insert(nieuwIndex, verplaatste);

    final nu = DateTime.now().toUtc().toIso8601String();
    final hernummerd = <OfferteAlgemenePrijsregelModel>[];

    for (var index = 0; index < regels.length; index++) {
      final regel = regels[index];

      hernummerd.add(
        regel.copyWith(
          volgorde: index,
          gewijzigdOp: regel.id == prijsregel.id ? nu : regel.gewijzigdOp,
        ),
      );
    }

    await _bewaarOpslag(opslag.copyWith(prijsregels: hernummerd));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _achtergrond,
      appBar: AppBar(
        title: const Text(
          'Prijzen geldig voor alle artikelen',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: <Widget>[
          if (_opslaan)
            const Padding(
              padding: EdgeInsets.only(right: 10),
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
          IconButton(
            tooltip: 'Prijsregel toevoegen',
            onPressed: _opslaan ? null : _voegPrijsregelToe,
            icon: const Icon(Icons.add_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: _laden || _opslag == null
          ? null
          : FloatingActionButton.extended(
              backgroundColor: _groen,
              foregroundColor: Colors.white,
              onPressed: _opslaan ? null : _voegPrijsregelToe,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Prijsregel toevoegen',
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

    if (_foutmelding != null || _opslag == null) {
      return _bouwFoutmelding();
    }

    final opslag = _opslag!;

    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: RefreshIndicator(
          color: _groen,
          onRefresh: _laadPrijsregels,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: _lichtGroen,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _groen, width: 1.1),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: _groen,
                      size: 22,
                    ),
                    SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Onafhankelijke algemene prijsregels',
                            style: TextStyle(
                              color: _tekstDonker,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Deze regels staan volledig los van de technische '
                            'keuzeprijzen en vrije prijzen per artikel. '
                            'De toepassing op concrete offerteposities wordt '
                            'in een volgende fase op het overzicht aangesloten.',
                            style: TextStyle(
                              color: _tekstGrijs,
                              fontSize: 12.5,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _bouwOpslagSamenvatting(opslag),
              const SizedBox(height: 14),
              if (opslag.isLeeg)
                _bouwLegeToestand()
              else
                ...List<Widget>.generate(opslag.prijsregels.length, (index) {
                  final prijsregel = opslag.prijsregels[index];

                  return _bouwPrijsregelTegel(
                    prijsregel,
                    kanOmhoog: index > 0,
                    kanOmlaag: index < opslag.prijsregels.length - 1,
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bouwOpslagSamenvatting(OfferteAlgemenePrijsregelsModel opslag) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rand),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _lichtGroen,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.storage_rounded, color: _groen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Afzonderlijke opslag actief',
                  style: TextStyle(
                    color: _tekstDonker,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${opslag.prijsregels.length} prijsregels · '
                  '${opslag.aantalActievePrijsregels} actief',
                  style: const TextStyle(
                    color: _tekstGrijs,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: _groen),
            onPressed: _opslaan ? null : _voegPrijsregelToe,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Toevoegen'),
          ),
        ],
      ),
    );
  }

  Widget _bouwLegeToestand() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rand),
      ),
      child: Column(
        children: <Widget>[
          const Icon(Icons.rule_folder_outlined, color: _groen, size: 34),
          const SizedBox(height: 10),
          const Text(
            'Nog geen algemene prijsregels',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _tekstDonker,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Voeg de eerste onafhankelijke prijsregel toe. Er wordt nog '
            'niets automatisch op een offerte toegepast.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _tekstGrijs,
              fontSize: 12.5,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: _groen),
            onPressed: _opslaan ? null : _voegPrijsregelToe,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Eerste prijsregel toevoegen'),
          ),
        ],
      ),
    );
  }

  Widget _bouwPrijsregelTegel(
    OfferteAlgemenePrijsregelModel prijsregel, {
    required bool kanOmhoog,
    required bool kanOmlaag,
  }) {
    final artikelLabels = _artikelLabels(prijsregel);
    final verdeeldePrijs = prijsregel.uitschrijfmodus.isVerdeeldeInterneKost;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rand),
      ),
      child: Column(
        children: <Widget>[
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            onTap: _opslaan ? null : () => _wijzigPrijsregel(prijsregel),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 14, 10, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: prijsregel.actief
                          ? _lichtGroen
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      verdeeldePrijs
                          ? Icons.account_tree_outlined
                          : Icons.euro_rounded,
                      color: prijsregel.actief ? _groen : _tekstGrijs,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                prijsregel.omschrijving,
                                style: TextStyle(
                                  color: prijsregel.actief
                                      ? _tekstDonker
                                      : _tekstGrijs,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            if (!prijsregel.actief)
                              _bouwStatusLabel(
                                tekst: 'Inactief',
                                kleur: _tekstGrijs,
                                achtergrond: const Color(0xFFF3F4F6),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: <Widget>[
                            _bouwInfoLabel(
                              icoon: Icons.calculate_outlined,
                              tekst: _prijsEnFormuleTekst(prijsregel),
                              kleur: _groen,
                            ),
                            _bouwInfoLabel(
                              icoon: verdeeldePrijs
                                  ? Icons.account_tree_outlined
                                  : _icoonVoorUitschrijfmodus(
                                      prijsregel.uitschrijfmodus,
                                    ),
                              tekst: _benamingVoorUitschrijfmodus(
                                prijsregel.uitschrijfmodus,
                              ),
                              kleur: verdeeldePrijs ? _blauw : _groen,
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Text(
                          artikelLabels,
                          style: const TextStyle(
                            color: _tekstGrijs,
                            fontSize: 11.3,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Acties',
                    enabled: !_opslaan,
                    onSelected: (actie) {
                      switch (actie) {
                        case 'wijzigen':
                          _wijzigPrijsregel(prijsregel);
                          break;
                        case 'verwijderen':
                          _verwijderPrijsregel(prijsregel);
                          break;
                      }
                    },
                    itemBuilder: (_) {
                      return const <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'wijzigen',
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.edit_outlined),
                            title: Text('Wijzigen'),
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'verwijderen',
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.delete_outline_rounded,
                              color: _rood,
                            ),
                            title: Text(
                              'Verwijderen',
                              style: TextStyle(color: _rood),
                            ),
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: _rand),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
            child: Row(
              children: <Widget>[
                IconButton(
                  tooltip: 'Omhoog',
                  onPressed: !_opslaan && kanOmhoog
                      ? () => _verplaatsPrijsregel(prijsregel, -1)
                      : null,
                  icon: const Icon(Icons.keyboard_arrow_up_rounded),
                ),
                IconButton(
                  tooltip: 'Omlaag',
                  onPressed: !_opslaan && kanOmlaag
                      ? () => _verplaatsPrijsregel(prijsregel, 1)
                      : null,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                ),
                const Spacer(),
                const Text(
                  'Actief',
                  style: TextStyle(
                    color: _tekstGrijs,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Switch.adaptive(
                  value: prijsregel.actief,
                  activeThumbColor: _groen,
                  onChanged: _opslaan
                      ? null
                      : (waarde) {
                          _zetPrijsregelActief(prijsregel, waarde);
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwInfoLabel({
    required IconData icoon,
    required String tekst,
    required Color kleur,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: kleur.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kleur.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icoon, size: 14, color: kleur),
          const SizedBox(width: 5),
          Text(
            tekst,
            style: TextStyle(
              color: kleur,
              fontSize: 10.7,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwStatusLabel({
    required String tekst,
    required Color kleur,
    required Color achtergrond,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: achtergrond,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        tekst,
        style: TextStyle(
          color: kleur,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _bouwFoutmelding() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline_rounded, color: _rood, size: 34),
            const SizedBox(height: 10),
            Text(
              _foutmelding ??
                  'De algemene prijsregels konden niet worden geladen.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: _groen),
              onPressed: _laadPrijsregels,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Opnieuw proberen'),
            ),
          ],
        ),
      ),
    );
  }

  String _prijsEnFormuleTekst(OfferteAlgemenePrijsregelModel prijsregel) {
    final bedrag = _formatteerEuro(prijsregel.prijsExclBtw);

    if (prijsregel.uitschrijfmodus.isVerdeeldeInterneKost) {
      return '$bedrag totaal te verdelen';
    }

    if (prijsregel.eenheid == OffertePrijsEenheid.vast) {
      return '$bedrag vast';
    }

    return '$bedrag × ${prijsregel.eenheid.formuleBenaming}';
  }

  String _artikelLabels(OfferteAlgemenePrijsregelModel prijsregel) {
    if (prijsregel.toepasselijkeFormulierTypes.isEmpty) {
      return 'Geen artikeltypes geselecteerd';
    }

    final labels = prijsregel.toepasselijkeFormulierTypes
        .map((formulierType) {
          return OfferteArtikelPrijsKoppelingService.formulierNaamVoor(
            formulierType,
          );
        })
        .toList(growable: false);

    return 'Artikeltypes: ${labels.join(' · ')}';
  }

  int _volgendeVolgorde(OfferteAlgemenePrijsregelsModel opslag) {
    var hoogste = -1;

    for (final prijsregel in opslag.prijsregels) {
      if (prijsregel.volgorde > hoogste) {
        hoogste = prijsregel.volgorde;
      }
    }

    return hoogste + 1;
  }

  void _toonMelding(String tekst, {bool fout = false}) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: fout ? _rood : _groen, content: Text(tekst)),
    );
  }

  static String _formatteerEuro(double bedrag) {
    return '€ ${bedrag.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  static String _benamingVoorUitschrijfmodus(
    OffertePrijsUitschrijfmodus modus,
  ) {
    return switch (modus) {
      OffertePrijsUitschrijfmodus.overzichtEnOfferteMetPrijs =>
        'Prijs zichtbaar',
      OffertePrijsUitschrijfmodus.invullenEnOfferteZonderPrijs =>
        'Omschrijving zichtbaar',
      OffertePrijsUitschrijfmodus.alleenOverzicht => 'Verborgen op offerte',
      OffertePrijsUitschrijfmodus.verdelenOverArtikelenAlleenOverzicht =>
        'Verdelen over artikelen',
      _ => modus.benaming,
    };
  }

  static IconData _icoonVoorUitschrijfmodus(OffertePrijsUitschrijfmodus modus) {
    return switch (modus) {
      OffertePrijsUitschrijfmodus.overzichtEnOfferteMetPrijs =>
        Icons.visibility_outlined,
      OffertePrijsUitschrijfmodus.invullenEnOfferteZonderPrijs =>
        Icons.edit_note_rounded,
      OffertePrijsUitschrijfmodus.alleenOverzicht =>
        Icons.visibility_off_outlined,
      OffertePrijsUitschrijfmodus.verdelenOverArtikelenAlleenOverzicht =>
        Icons.account_tree_outlined,
      _ => Icons.rule_outlined,
    };
  }
}
