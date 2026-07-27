// THIMACO-CONTROLE: TECHNISCHE-KEUZE-OVEREENKOMST-HELPER-FASE-6-20260727
// THIMACO-CONTROLE: OPGELADEN-KEUZE-EXACT-KOPIE-NIET-EXACT-FASE-5-20260727
// THIMACO-CONTROLE: EXACTE-OVEREENKOMST-BEHOUDE-KEUZE-IDS-20260727
// THIMACO-CONTROLE: GEKOPPELDE-TECHNISCHE-PRIJSREGELS-FASE-4-20260727
// THIMACO-CONTROLE: TECHNISCHE-PRIJS-OVERNEMEN-FASE-3-20260727
// THIMACO-CONTROLE: TECHNISCHE-PRIJSKEUZE-ANDERE-ARTIKELTYPES-FASE-2-20260727
// THIMACO-CONTROLE: TECHNISCHE-PRIJSKEUZE-BOOM-FASE-1-20260726
import 'package:flutter/material.dart';

import '../../../helpers/offerte/prijzen/offerte_artikel_prijs_koppeling_service.dart';
import '../../../helpers/offerte/prijzen/offerte_prijs_eenheid.dart';
import '../../../helpers/offerte/prijzen/offerte_prijsregel_model.dart';
import '../../../helpers/offerte/prijzen/offerte_technische_keuze_overeenkomst_helper.dart';
import '../../../helpers/offerte/prijzen/offerte_technische_keuze_ref.dart';
import 'offerte_technische_prijs_overnemen_dialog.dart';

class OfferteTechnischePrijskeuzeBoom extends StatefulWidget {
  const OfferteTechnischePrijskeuzeBoom({
    super.key,
    required this.keuzes,
    required this.prijsregels,
    required this.andereTechnischePrijsregels,
    required this.gekoppeldePrijsregelAantallen,
    required this.onKeuzeOpenen,
    required this.onPrijsregelOpenen,
    required this.onPrijsregelVerwijderen,
    required this.onPrijsregelOntkoppelen,
    required this.onPrijsregelsOvernemen,
  });

  final List<OfferteTechnischeKeuzeRef> keuzes;
  final List<OffertePrijsregelModel> prijsregels;
  final List<OffertePrijsregelModel> andereTechnischePrijsregels;
  final Map<String, int> gekoppeldePrijsregelAantallen;

  final Future<void> Function(
    OfferteTechnischeKeuzeRef keuze,
    OffertePrijsregelModel? bestaandePrijsregel,
  )
  onKeuzeOpenen;

  final Future<void> Function(OffertePrijsregelModel prijsregel)
  onPrijsregelOpenen;

  final Future<void> Function(OffertePrijsregelModel prijsregel)
  onPrijsregelVerwijderen;

  final Future<void> Function(OffertePrijsregelModel prijsregel)
  onPrijsregelOntkoppelen;

  final Future<void> Function(OfferteTechnischePrijsOvernameGroep groep)
  onPrijsregelsOvernemen;

  @override
  State<OfferteTechnischePrijskeuzeBoom> createState() {
    return _OfferteTechnischePrijskeuzeBoomState();
  }
}

class _OfferteTechnischePrijskeuzeBoomState
    extends State<OfferteTechnischePrijskeuzeBoom> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstGrijs = Color(0xFF6B7280);
  static const Color _rood = Color(0xFFDC2626);
  static const Color _blauw = Color(0xFF2563EB);
  static const Color _lichtBlauw = Color(0xFFEFF6FF);
  static const Color _blauweRand = Color(0xFFBFDBFE);
  static const Color _oranje = Color(0xFFB45309);
  static const Color _lichtOranje = Color(0xFFFFFBEB);
  static const Color _oranjeRand = Color(0xFFFDE68A);

  final Set<String> _openKnopen = <String>{};

  @override
  Widget build(BuildContext context) {
    final gegevens = _bouwBoomGegevens();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _bouwUitlegKaart(),
        const SizedBox(height: 12),
        if (gegevens.menus.isEmpty)
          _bouwLegeBoomKaart()
        else
          ...gegevens.menus.map(_bouwMenu),
        if (gegevens.lossePrijsregels.isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          _bouwLossePrijsregels(gegevens.lossePrijsregels),
        ],
      ],
    );
  }

  Widget _bouwUitlegKaart() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rand),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.account_tree_outlined, color: _groen, size: 21),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Open een hoofdtitel en daarna een submenu. Groen betekent '
              'dat dit artikeltype zelf een prijs heeft. Een blauw '
              'koppelingssymbool betekent dat dezelfde prijsregel door meerdere '
              'artikeltypes wordt gedeeld. Blauw bij een ongeprijsde keuze '
              'betekent dat een exacte prijsbron beschikbaar is. Oranje blijft '
              'alleen een mogelijke tekstuele overeenkomst.',
              style: TextStyle(
                color: _tekstGrijs,
                fontSize: 12.2,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwLegeBoomKaart() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rand),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.info_outline_rounded, color: _groen, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Voor dit artikeltype zijn nog geen actieve technische keuzes '
              'gevonden. Maak of activeer eerst keuzes via “Nieuwe technische '
              'keuze”.',
              style: TextStyle(
                color: _tekstGrijs,
                fontSize: 12.2,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwMenu(_TechnischMenuNode menu) {
    final open = _openKnopen.contains(menu.sleutel);
    final geprijsd = menu.aantalMetPrijs;
    final kanOvernemen = menu.aantalExactBeschikbaar > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rand),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(7, 6, 8, 6),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _wisselOpen(menu.sleutel),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 6, 5, 6),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            open
                                ? Icons.keyboard_arrow_down_rounded
                                : Icons.keyboard_arrow_right_rounded,
                            color: _groen,
                            size: 23,
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              menu.titel,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          _bouwTeller(
                            totaal: menu.aantalKeuzes,
                            geprijsd: geprijsd,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (kanOvernemen) ...<Widget>[
                  const SizedBox(width: 7),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _blauw,
                      side: const BorderSide(color: _blauweRand),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () async {
                      await widget.onPrijsregelsOvernemen(
                        _maakOvernameGroep(
                          titel: menu.titel,
                          keuzes: menu.alleKeuzes,
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_all_rounded, size: 16),
                    label: const Text(
                      'Alles overnemen',
                      style: TextStyle(
                        fontSize: 10.8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (open) ...<Widget>[
            const Divider(height: 1, color: _rand),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ...menu.submenus.map(
                    (submenu) => _bouwSubmenu(submenu, diepte: 0),
                  ),
                  ...menu.keuzes.map(
                    (keuze) => _bouwKeuzeRij(keuze, inspringing: 0),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bouwSubmenu(_TechnischSubmenuNode submenu, {required int diepte}) {
    final open = _openKnopen.contains(submenu.sleutel);
    final linkerMarge = diepte * 14.0;
    final kanOvernemen = submenu.aantalExactBeschikbaar > 0;

    return Padding(
      padding: EdgeInsets.only(left: linkerMarge, bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Material(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 3, 5, 3),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _wisselOpen(submenu.sleutel),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 6,
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              open
                                  ? Icons.keyboard_arrow_down_rounded
                                  : Icons.keyboard_arrow_right_rounded,
                              color: _groen,
                              size: 21,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                submenu.titel,
                                style: const TextStyle(
                                  fontSize: 12.8,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            _bouwTeller(
                              totaal: submenu.aantalKeuzes,
                              geprijsd: submenu.aantalMetPrijs,
                              compact: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (kanOvernemen) ...<Widget>[
                    const SizedBox(width: 5),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: _blauw,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () async {
                        await widget.onPrijsregelsOvernemen(
                          _maakOvernameGroep(
                            titel: submenu.titel,
                            keuzes: submenu.alleKeuzes,
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_all_rounded, size: 15),
                      label: const Text(
                        'Overnemen',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (open) ...<Widget>[
            const SizedBox(height: 5),
            ...submenu.submenus.map(
              (kind) => _bouwSubmenu(kind, diepte: diepte + 1),
            ),
            ...submenu.keuzes.map(
              (keuze) => _bouwKeuzeRij(keuze, inspringing: (diepte + 1) * 14.0),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bouwKeuzeRij(
    _TechnischeKeuzeMetPrijs keuze, {
    required double inspringing,
  }) {
    final prijsregel = keuze.prijsregel;
    final heeftPrijs = prijsregel != null;
    final actief = prijsregel?.actief ?? false;
    final gekoppeldAantal = prijsregel == null
        ? 0
        : widget.gekoppeldePrijsregelAantallen[prijsregel.id] ?? 0;
    final isGekoppeld = gekoppeldAantal > 1;
    final heeftExacteBron =
        !heeftPrijs &&
        keuze.bronOvereenkomst == _BronOvereenkomst.exacteSleutel;
    final heeftMogelijkeBron =
        !heeftPrijs &&
        keuze.bronOvereenkomst == _BronOvereenkomst.mogelijkeTekst;

    final rijKleur = heeftExacteBron
        ? _lichtBlauw
        : heeftMogelijkeBron
        ? _lichtOranje
        : Colors.white;
    final randKleur = heeftExacteBron
        ? _blauweRand
        : heeftMogelijkeBron
        ? _oranjeRand
        : _rand;
    final symboolKleur = heeftPrijs
        ? actief
              ? _groen
              : _tekstGrijs
        : heeftExacteBron
        ? _blauw
        : heeftMogelijkeBron
        ? _oranje
        : const Color(0xFF9CA3AF);
    final symboolAchtergrond = heeftPrijs && actief
        ? _lichtGroen
        : heeftExacteBron
        ? const Color(0xFFDBEAFE)
        : heeftMogelijkeBron
        ? const Color(0xFFFEF3C7)
        : const Color(0xFFF3F4F6);

    return Padding(
      padding: EdgeInsets.only(left: inspringing, bottom: 5),
      child: Material(
        color: rijKleur,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () async {
            if (heeftExacteBron && keuze.bronPrijsregel != null) {
              await widget.onPrijsregelsOvernemen(
                _maakOvernameGroep(
                  titel: keuze.keuze.keuzeTitelMomentopname.trim().isEmpty
                      ? keuze.keuze.hoeUitschrijven
                      : keuze.keuze.keuzeTitelMomentopname.trim(),
                  keuzes: <_TechnischeKeuzeMetPrijs>[keuze],
                  enkeleKeuze: true,
                ),
              );
              return;
            }

            await widget.onKeuzeOpenen(keuze.keuze, prijsregel);
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 9, 4, 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: randKleur),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 29,
                  height: 29,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: symboolAchtergrond,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: heeftPrijs
                      ? Text(
                          '€',
                          style: TextStyle(
                            color: symboolKleur,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      : Icon(
                          heeftExacteBron
                              ? Icons.call_received_rounded
                              : heeftMogelijkeBron
                              ? Icons.warning_amber_rounded
                              : Icons.circle_outlined,
                          color: symboolKleur,
                          size: heeftMogelijkeBron ? 18 : 16,
                        ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        keuze.keuze.keuzeTitelMomentopname.trim().isEmpty
                            ? keuze.keuze.hoeUitschrijven
                            : keuze.keuze.keuzeTitelMomentopname.trim(),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        prijsregel != null
                            ? _prijsStatusTekst(
                                prijsregel,
                                gekoppeldAantal: gekoppeldAantal,
                              )
                            : keuze.bronPrijsregel != null
                            ? _bronStatusTekst(keuze)
                            : 'Nog geen prijs ingesteld',
                        style: TextStyle(
                          color: prijsregel != null
                              ? isGekoppeld && actief
                                    ? _blauw
                                    : actief
                                    ? _groen
                                    : _tekstGrijs
                              : heeftExacteBron
                              ? _blauw
                              : heeftMogelijkeBron
                              ? _oranje
                              : _tekstGrijs,
                          fontSize: 10.8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (prijsregel != null) ...<Widget>[
                  if (isGekoppeld)
                    Tooltip(
                      message: 'Gekoppeld met $gekoppeldAantal artikeltypes',
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3),
                        child: Icon(
                          Icons.link_rounded,
                          color: _blauw,
                          size: 18,
                        ),
                      ),
                    ),
                  PopupMenuButton<_KeuzeActie>(
                    tooltip: 'Prijsregelacties',
                    onSelected: (actie) async {
                      if (actie == _KeuzeActie.ontkoppelen) {
                        await widget.onPrijsregelOntkoppelen(prijsregel);
                      } else if (actie == _KeuzeActie.verwijderen) {
                        await widget.onPrijsregelVerwijderen(prijsregel);
                      }
                    },
                    itemBuilder: (context) {
                      return <PopupMenuEntry<_KeuzeActie>>[
                        if (isGekoppeld)
                          const PopupMenuItem<_KeuzeActie>(
                            value: _KeuzeActie.ontkoppelen,
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.link_off_rounded,
                                  color: _blauw,
                                  size: 19,
                                ),
                                SizedBox(width: 9),
                                Text('Koppeling losmaken'),
                              ],
                            ),
                          ),
                        const PopupMenuItem<_KeuzeActie>(
                          value: _KeuzeActie.verwijderen,
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.delete_outline_rounded,
                                color: _rood,
                                size: 19,
                              ),
                              SizedBox(width: 9),
                              Text('Prijsregel verwijderen'),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(right: 9),
                    child: Icon(
                      heeftExacteBron
                          ? Icons.download_rounded
                          : Icons.chevron_right_rounded,
                      color: heeftExacteBron ? _blauw : _tekstGrijs,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  OfferteTechnischePrijsOvernameGroep _maakOvernameGroep({
    required String titel,
    required List<_TechnischeKeuzeMetPrijs> keuzes,
    bool enkeleKeuze = false,
  }) {
    final kandidaten = <OfferteTechnischePrijsOvernameKandidaat>[];
    var aantalMogelijkeTekstOvereenkomsten = 0;
    var aantalZonderBron = 0;

    for (final keuze in keuzes) {
      final bronPrijsregel = keuze.bronPrijsregel;

      if (bronPrijsregel != null &&
          keuze.bronOvereenkomst == _BronOvereenkomst.exacteSleutel) {
        kandidaten.add(
          OfferteTechnischePrijsOvernameKandidaat(
            doelKeuze: keuze.keuze,
            bronPrijsregel: bronPrijsregel,
            bestaandePrijsregel: keuze.prijsregel,
          ),
        );
        continue;
      }

      if (bronPrijsregel != null &&
          keuze.bronOvereenkomst == _BronOvereenkomst.mogelijkeTekst) {
        aantalMogelijkeTekstOvereenkomsten++;
      } else {
        aantalZonderBron++;
      }
    }

    return OfferteTechnischePrijsOvernameGroep(
      titel: titel,
      kandidaten: kandidaten,
      aantalKeuzes: keuzes.length,
      aantalMogelijkeTekstOvereenkomsten: aantalMogelijkeTekstOvereenkomsten,
      aantalZonderBron: aantalZonderBron,
      enkeleKeuze: enkeleKeuze,
    );
  }

  Widget _bouwLossePrijsregels(List<OffertePrijsregelModel> prijsregels) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(Icons.warning_amber_rounded, color: Color(0xFFB45309)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Niet meer gevonden of dubbele prijsregels',
                  style: TextStyle(
                    color: Color(0xFF92400E),
                    fontSize: 13.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            'Deze bestaande regels worden niet verborgen. Open een regel om '
            'de technische keuze opnieuw te koppelen of verwijder ze bewust.',
            style: TextStyle(
              color: Color(0xFF92400E),
              fontSize: 11.2,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ...prijsregels.map(_bouwLossePrijsregelRij),
        ],
      ),
    );
  }

  Widget _bouwLossePrijsregelRij(OffertePrijsregelModel prijsregel) {
    final technischeKeuze = prijsregel.technischeKeuze;
    final gekoppeldAantal =
        widget.gekoppeldePrijsregelAantallen[prijsregel.id] ?? 0;
    final isGekoppeld = gekoppeldAantal > 1;
    final pad = technischeKeuze == null
        ? ''
        : <String>[
            technischeKeuze.menuTitelMomentopname.trim(),
            technischeKeuze.submenuTitelMomentopname.trim(),
            technischeKeuze.keuzeTitelMomentopname.trim(),
          ].where((deel) => deel.isNotEmpty).join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () async {
            await widget.onPrijsregelOpenen(prijsregel);
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 9, 4, 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  isGekoppeld ? Icons.link_rounded : Icons.link_off_rounded,
                  color: isGekoppeld ? _blauw : const Color(0xFFB45309),
                  size: 19,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        prijsregel.omschrijving,
                        style: const TextStyle(
                          fontSize: 12.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (pad.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 2),
                        Text(
                          pad,
                          style: const TextStyle(
                            color: _tekstGrijs,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (isGekoppeld) ...<Widget>[
                        const SizedBox(height: 2),
                        Text(
                          'Gekoppeld met $gekoppeldAantal artikeltypes',
                          style: const TextStyle(
                            color: _blauw,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<_KeuzeActie>(
                  tooltip: 'Prijsregelacties',
                  onSelected: (actie) async {
                    if (actie == _KeuzeActie.ontkoppelen) {
                      await widget.onPrijsregelOntkoppelen(prijsregel);
                    } else if (actie == _KeuzeActie.verwijderen) {
                      await widget.onPrijsregelVerwijderen(prijsregel);
                    }
                  },
                  itemBuilder: (context) {
                    return <PopupMenuEntry<_KeuzeActie>>[
                      if (isGekoppeld)
                        const PopupMenuItem<_KeuzeActie>(
                          value: _KeuzeActie.ontkoppelen,
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.link_off_rounded,
                                color: _blauw,
                                size: 19,
                              ),
                              SizedBox(width: 9),
                              Text('Koppeling losmaken'),
                            ],
                          ),
                        ),
                      const PopupMenuItem<_KeuzeActie>(
                        value: _KeuzeActie.verwijderen,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.delete_outline_rounded,
                              color: _rood,
                              size: 19,
                            ),
                            SizedBox(width: 9),
                            Text('Prijsregel verwijderen'),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bouwTeller({
    required int totaal,
    required int geprijsd,
    bool compact = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: geprijsd > 0 ? _lichtGroen : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$geprijsd/$totaal',
        style: TextStyle(
          color: geprijsd > 0 ? _groen : _tekstGrijs,
          fontSize: compact ? 9.8 : 10.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  void _wisselOpen(String sleutel) {
    setState(() {
      if (!_openKnopen.add(sleutel)) {
        _openKnopen.remove(sleutel);
      }
    });
  }

  _TechnischeBoomGegevens _bouwBoomGegevens() {
    final prijsregelsPerSleutel = <String, List<OffertePrijsregelModel>>{};
    final zonderGeldigeKeuze = <OffertePrijsregelModel>[];
    final anderePerExacteSleutel = <String, List<OffertePrijsregelModel>>{};
    final anderePerTekstSleutel = <String, List<OffertePrijsregelModel>>{};

    for (final prijsregel in widget.andereTechnischePrijsregels) {
      final technischeKeuze = prijsregel.technischeKeuze;

      if (!prijsregel.actief ||
          technischeKeuze == null ||
          technischeKeuze.isLeeg) {
        continue;
      }

      final exacteSleutel =
          OfferteTechnischeKeuzeOvereenkomstHelper.exacteSleutelTussenArtikeltypesVan(
            technischeKeuze,
          );
      if (exacteSleutel.isNotEmpty) {
        anderePerExacteSleutel
            .putIfAbsent(exacteSleutel, () => <OffertePrijsregelModel>[])
            .add(prijsregel);
      }

      final tekstSleutel =
          OfferteTechnischeKeuzeOvereenkomstHelper.tekstSuggestieSleutelVan(
            technischeKeuze,
          );
      if (tekstSleutel.isNotEmpty) {
        anderePerTekstSleutel
            .putIfAbsent(tekstSleutel, () => <OffertePrijsregelModel>[])
            .add(prijsregel);
      }
    }

    for (final prijsregel in widget.prijsregels) {
      final technischeKeuze = prijsregel.technischeKeuze;
      if (technischeKeuze == null || technischeKeuze.isLeeg) {
        zonderGeldigeKeuze.add(prijsregel);
        continue;
      }

      final lokaleSleutel =
          OfferteTechnischeKeuzeOvereenkomstHelper.lokaleExacteSleutelVan(
            technischeKeuze,
          );
      if (lokaleSleutel.isEmpty) {
        zonderGeldigeKeuze.add(prijsregel);
        continue;
      }

      prijsregelsPerSleutel
          .putIfAbsent(lokaleSleutel, () => <OffertePrijsregelModel>[])
          .add(prijsregel);
    }

    final gekozenPrijsregels = <OffertePrijsregelModel>{};
    final menusPerSleutel = <String, _TechnischMenuNode>{};

    for (final keuze in widget.keuzes) {
      final keuzeSleutel =
          OfferteTechnischeKeuzeOvereenkomstHelper.lokaleExacteSleutelVan(
            keuze,
          );
      final kandidaten = keuzeSleutel.isEmpty
          ? const <OffertePrijsregelModel>[]
          : prijsregelsPerSleutel[keuzeSleutel] ??
                const <OffertePrijsregelModel>[];
      final prijsregel = _bestePrijsregel(kandidaten);
      OffertePrijsregelModel? bronPrijsregel;
      var bronOvereenkomst = _BronOvereenkomst.geen;

      if (prijsregel != null) {
        gekozenPrijsregels.add(prijsregel);
      }

      final exacteSleutel =
          OfferteTechnischeKeuzeOvereenkomstHelper.exacteSleutelTussenArtikeltypesVan(
            keuze,
          );
      final exacteKandidaten = exacteSleutel.isEmpty
          ? const <OffertePrijsregelModel>[]
          : anderePerExacteSleutel[exacteSleutel] ??
                const <OffertePrijsregelModel>[];

      bronPrijsregel = _bestePrijsregel(exacteKandidaten);

      if (bronPrijsregel != null) {
        bronOvereenkomst = _BronOvereenkomst.exacteSleutel;
      } else {
        final tekstSleutel =
            OfferteTechnischeKeuzeOvereenkomstHelper.tekstSuggestieSleutelVan(
              keuze,
            );
        final tekstKandidaten = tekstSleutel.isEmpty
            ? const <OffertePrijsregelModel>[]
            : anderePerTekstSleutel[tekstSleutel] ??
                  const <OffertePrijsregelModel>[];

        bronPrijsregel = _bestePrijsregel(tekstKandidaten);

        if (bronPrijsregel != null) {
          bronOvereenkomst = _BronOvereenkomst.mogelijkeTekst;
        }
      }

      final menuId = keuze.menuId.trim().isEmpty
          ? keuze.menuTitelMomentopname.trim()
          : keuze.menuId.trim();
      final menuSleutel = 'menu|$menuId';
      final menu = menusPerSleutel.putIfAbsent(
        menuSleutel,
        () => _TechnischMenuNode(
          sleutel: menuSleutel,
          titel: keuze.menuTitelMomentopname.trim().isEmpty
              ? 'Technische keuzes'
              : keuze.menuTitelMomentopname.trim(),
        ),
      );

      final keuzeMetPrijs = _TechnischeKeuzeMetPrijs(
        keuze: keuze,
        prijsregel: prijsregel,
        bronPrijsregel: bronPrijsregel,
        bronOvereenkomst: bronOvereenkomst,
      );

      final submenuIds = keuze.submenuId
          .split('/')
          .map((deel) => deel.trim())
          .where((deel) => deel.isNotEmpty)
          .toList(growable: false);
      final submenuTitels = keuze.submenuTitelMomentopname
          .split(' · ')
          .map((deel) => deel.trim())
          .where((deel) => deel.isNotEmpty)
          .toList(growable: false);

      if (submenuIds.isEmpty && submenuTitels.isEmpty) {
        menu.keuzes.add(keuzeMetPrijs);
        continue;
      }

      final aantalNiveaus = submenuIds.length > submenuTitels.length
          ? submenuIds.length
          : submenuTitels.length;
      var huidigeSubmenus = menu.submenusPerSleutel;
      _TechnischSubmenuNode? huidigSubmenu;
      final padSleutels = <String>[menuSleutel];

      for (var index = 0; index < aantalNiveaus; index++) {
        final id = index < submenuIds.length ? submenuIds[index] : '';
        final titel = index < submenuTitels.length ? submenuTitels[index] : id;
        final onderdeel = id.isNotEmpty ? id : titel;
        padSleutels.add(onderdeel);
        final submenuSleutel = padSleutels.join('|');

        huidigSubmenu = huidigeSubmenus.putIfAbsent(
          submenuSleutel,
          () => _TechnischSubmenuNode(
            sleutel: submenuSleutel,
            titel: titel.isEmpty ? 'Submenu' : titel,
          ),
        );

        huidigeSubmenus = huidigSubmenu.submenusPerSleutel;
      }

      if (huidigSubmenu == null) {
        menu.keuzes.add(keuzeMetPrijs);
      } else {
        huidigSubmenu.keuzes.add(keuzeMetPrijs);
      }
    }

    final lossePrijsregels = <OffertePrijsregelModel>[
      ...zonderGeldigeKeuze,
      ...widget.prijsregels.where(
        (prijsregel) => !gekozenPrijsregels.contains(prijsregel),
      ),
    ];

    final uniekeLosseRegels = <String, OffertePrijsregelModel>{};
    for (final prijsregel in lossePrijsregels) {
      final sleutel = prijsregel.id.trim().isEmpty
          ? '${prijsregel.omschrijving}|${prijsregel.gewijzigdOp}'
          : prijsregel.id.trim();
      uniekeLosseRegels.putIfAbsent(sleutel, () => prijsregel);
    }

    return _TechnischeBoomGegevens(
      menus: menusPerSleutel.values.toList(growable: false),
      lossePrijsregels: uniekeLosseRegels.values.toList(growable: false),
    );
  }

  OffertePrijsregelModel? _bestePrijsregel(
    List<OffertePrijsregelModel> kandidaten,
  ) {
    OffertePrijsregelModel? beste;

    for (final kandidaat in kandidaten) {
      if (beste == null) {
        beste = kandidaat;
        continue;
      }

      if (kandidaat.actief && !beste.actief) {
        beste = kandidaat;
        continue;
      }

      if (kandidaat.actief == beste.actief &&
          _isNieuwer(kandidaat.gewijzigdOp, beste.gewijzigdOp)) {
        beste = kandidaat;
      }
    }

    return beste;
  }

  String _prijsStatusTekst(
    OffertePrijsregelModel prijsregel, {
    int gekoppeldAantal = 0,
  }) {
    final bedrag = prijsregel.prijsExclBtw
        .toStringAsFixed(2)
        .replaceAll('.', ',');
    final status = prijsregel.actief ? '' : ' · Inactief';
    final koppeling = gekoppeldAantal > 1
        ? ' · Gekoppeld met $gekoppeldAantal artikeltypes'
        : '';
    return '€ $bedrag · ${_eenheidBenaming(prijsregel.eenheid)}$status$koppeling';
  }

  String _bronStatusTekst(_TechnischeKeuzeMetPrijs keuze) {
    final bronPrijsregel = keuze.bronPrijsregel;

    if (bronPrijsregel == null) {
      return 'Nog geen prijs ingesteld';
    }

    final formulierNaam = OfferteArtikelPrijsKoppelingService.formulierNaamVoor(
      bronPrijsregel.formulierType,
    );
    final prefix = keuze.bronOvereenkomst == _BronOvereenkomst.exacteSleutel
        ? 'Beschikbaar uit'
        : 'Mogelijke overeenkomst met';

    return '$prefix $formulierNaam · ${_prijsStatusTekst(bronPrijsregel)}';
  }

  static String _eenheidBenaming(OffertePrijsEenheid eenheid) {
    return eenheid.benaming;
  }

  static bool _isNieuwer(String eerste, String tweede) {
    final eersteDatum = DateTime.tryParse(eerste);
    final tweedeDatum = DateTime.tryParse(tweede);

    if (eersteDatum == null) {
      return false;
    }

    if (tweedeDatum == null) {
      return true;
    }

    return eersteDatum.isAfter(tweedeDatum);
  }
}

enum _KeuzeActie { ontkoppelen, verwijderen }

enum _BronOvereenkomst { geen, exacteSleutel, mogelijkeTekst }

class _TechnischeBoomGegevens {
  const _TechnischeBoomGegevens({
    required this.menus,
    required this.lossePrijsregels,
  });

  final List<_TechnischMenuNode> menus;
  final List<OffertePrijsregelModel> lossePrijsregels;
}

class _TechnischMenuNode {
  _TechnischMenuNode({required this.sleutel, required this.titel});

  final String sleutel;
  final String titel;
  final Map<String, _TechnischSubmenuNode> submenusPerSleutel =
      <String, _TechnischSubmenuNode>{};
  final List<_TechnischeKeuzeMetPrijs> keuzes = <_TechnischeKeuzeMetPrijs>[];

  List<_TechnischSubmenuNode> get submenus {
    return submenusPerSleutel.values.toList(growable: false);
  }

  List<_TechnischeKeuzeMetPrijs> get alleKeuzes {
    return <_TechnischeKeuzeMetPrijs>[
      ...keuzes,
      ...submenus.expand((submenu) => submenu.alleKeuzes),
    ];
  }

  int get aantalExactBeschikbaar {
    return alleKeuzes.where((keuze) {
      return keuze.bronPrijsregel != null &&
          keuze.bronOvereenkomst == _BronOvereenkomst.exacteSleutel;
    }).length;
  }

  int get aantalKeuzes {
    return keuzes.length +
        submenus.fold<int>(
          0,
          (totaal, submenu) => totaal + submenu.aantalKeuzes,
        );
  }

  int get aantalMetPrijs {
    return keuzes.where((keuze) => keuze.prijsregel != null).length +
        submenus.fold<int>(
          0,
          (totaal, submenu) => totaal + submenu.aantalMetPrijs,
        );
  }
}

class _TechnischSubmenuNode {
  _TechnischSubmenuNode({required this.sleutel, required this.titel});

  final String sleutel;
  final String titel;
  final Map<String, _TechnischSubmenuNode> submenusPerSleutel =
      <String, _TechnischSubmenuNode>{};
  final List<_TechnischeKeuzeMetPrijs> keuzes = <_TechnischeKeuzeMetPrijs>[];

  List<_TechnischSubmenuNode> get submenus {
    return submenusPerSleutel.values.toList(growable: false);
  }

  List<_TechnischeKeuzeMetPrijs> get alleKeuzes {
    return <_TechnischeKeuzeMetPrijs>[
      ...keuzes,
      ...submenus.expand((submenu) => submenu.alleKeuzes),
    ];
  }

  int get aantalExactBeschikbaar {
    return alleKeuzes.where((keuze) {
      return keuze.bronPrijsregel != null &&
          keuze.bronOvereenkomst == _BronOvereenkomst.exacteSleutel;
    }).length;
  }

  int get aantalKeuzes {
    return keuzes.length +
        submenus.fold<int>(
          0,
          (totaal, submenu) => totaal + submenu.aantalKeuzes,
        );
  }

  int get aantalMetPrijs {
    return keuzes.where((keuze) => keuze.prijsregel != null).length +
        submenus.fold<int>(
          0,
          (totaal, submenu) => totaal + submenu.aantalMetPrijs,
        );
  }
}

class _TechnischeKeuzeMetPrijs {
  const _TechnischeKeuzeMetPrijs({
    required this.keuze,
    required this.prijsregel,
    required this.bronPrijsregel,
    required this.bronOvereenkomst,
  });

  final OfferteTechnischeKeuzeRef keuze;
  final OffertePrijsregelModel? prijsregel;
  final OffertePrijsregelModel? bronPrijsregel;
  final _BronOvereenkomst bronOvereenkomst;
}
