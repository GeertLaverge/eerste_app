// THIMACO-CONTROLE: FINANCIELE-COCKPIT-PAGINA-FASE2B-20260808
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../beveiliging/financiele_kluis_sessie_controller.dart';
import '../model/financiele_cockpit_model.dart';
import '../widgets/financiele_invoer_dialogen.dart';

enum _FinancieleSectie {
  overzicht,
  teBetalen,
  teOntvangen,
  andereOntvangsten,
  vasteKosten,
  rekeningen,
  priveRekeningen,
}

enum _ToevoegType {
  teBetalen,
  teOntvangen,
  andereOntvangst,
  vasteKost,
  rekening,
}

class FinancieleCockpitPagina extends StatefulWidget {
  const FinancieleCockpitPagina({
    required this.controller,
    required this.onMaakNoodbackup,
    super.key,
  });

  final FinancieleKluisSessieController controller;
  final VoidCallback onMaakNoodbackup;

  @override
  State<FinancieleCockpitPagina> createState() =>
      _FinancieleCockpitPaginaState();
}

class _FinancieleCockpitPaginaState extends State<FinancieleCockpitPagina> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _achtergrond = Color(0xFFF7F8FA);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);
  static const Color _rood = Color(0xFFDC2626);
  static const Color _oranje = Color(0xFFD97706);
  static const Color _blauw = Color(0xFF2563EB);

  final NumberFormat _euro = NumberFormat.currency(
    locale: 'nl_BE',
    symbol: '€',
    decimalDigits: 2,
  );
  final DateFormat _datum = DateFormat('dd/MM/yyyy');

  _FinancieleSectie _sectie = _FinancieleSectie.overzicht;

  final ScrollController _betalingenScrollController = ScrollController();
  final ScrollController _ontvangstenScrollController = ScrollController();

  @override
  void dispose() {
    _betalingenScrollController.dispose();
    _ontvangstenScrollController.dispose();
    super.dispose();
  }

  FinancieleCockpitData get _data {
    return FinancieleCockpitData.fromKluis(
      widget.controller.inhoud ?? const <String, dynamic>{},
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;

    return LayoutBuilder(
      builder: (context, constraints) {
        final breed = constraints.maxWidth >= 930;

        return ColoredBox(
          color: _achtergrond,
          child: Column(
            children: <Widget>[
              _bouwKop(data),
              Expanded(
                child: breed
                    ? Row(
                        children: <Widget>[
                          SizedBox(width: 218, child: _bouwNavigatieRail(data)),
                          const VerticalDivider(width: 1, color: _rand),
                          Expanded(child: _bouwSectie(data)),
                        ],
                      )
                    : Column(
                        children: <Widget>[
                          _bouwMobieleNavigatie(),
                          const Divider(height: 1, color: _rand),
                          Expanded(child: _bouwSectie(data)),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bouwKop(FinancieleCockpitData data) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 13, 14, 13),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _lichtGroen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: _groen,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Financieel overzicht',
                  style: TextStyle(
                    color: _tekstDonker,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Rekeningen, komende betalingen, ontvangsten en vaste kosten',
                  style: TextStyle(
                    color: _tekstGrijs,
                    fontSize: 11.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: _groen,
              side: const BorderSide(color: Color(0xFFB9E1C6)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            ),
            onPressed: widget.controller.bewerkingBezig
                ? null
                : widget.onMaakNoodbackup,
            icon: const Icon(Icons.backup_outlined, size: 18),
            label: const Text(
              'Noodback-up',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _groen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            ),
            onPressed: widget.controller.bewerkingBezig
                ? null
                : () => _toonToevoegenKeuze(data),
            icon: const Icon(Icons.add_rounded, size: 19),
            label: const Text(
              'Toevoegen',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwNavigatieRail(FinancieleCockpitData data) {
    return ColoredBox(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 16),
        children: <Widget>[
          _navItem(
            sectie: _FinancieleSectie.overzicht,
            icoon: Icons.dashboard_outlined,
            label: 'Overzicht',
          ),
          _navItem(
            sectie: _FinancieleSectie.teBetalen,
            icoon: Icons.arrow_upward_rounded,
            label: 'Te betalen',
            badge: data.teBetalen.where((item) => item.teltMee).length,
          ),
          _navItem(
            sectie: _FinancieleSectie.teOntvangen,
            icoon: Icons.arrow_downward_rounded,
            label: 'Te ontvangen',
            badge: data.teOntvangen.where((item) => item.openstaand > 0).length,
          ),
          _navItem(
            sectie: _FinancieleSectie.andereOntvangsten,
            icoon: Icons.savings_outlined,
            label: 'Andere ontvangsten',
            badge: data.andereOntvangsten.where((item) => item.teltMee).length,
          ),
          _navItem(
            sectie: _FinancieleSectie.vasteKosten,
            icoon: Icons.repeat_rounded,
            label: 'Vaste kosten',
            badge: data.vasteKosten.where((item) => item.actiefVandaag).length,
          ),
          _navItem(
            sectie: _FinancieleSectie.rekeningen,
            icoon: Icons.account_balance_outlined,
            label: 'Zakelijke rekeningen',
            badge: data.rekeningen.where((item) => item.actief).length,
          ),
          _navItem(
            sectie: _FinancieleSectie.priveRekeningen,
            icoon: Icons.account_balance_wallet_outlined,
            label: 'Privé rekeningen',
            badge: data.priveRekeningen.where((item) => item.actief).length,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAF9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD7EBDD)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.lock_outline_rounded, color: _groen, size: 17),
                    SizedBox(width: 6),
                    Text(
                      'Beveiligd',
                      style: TextStyle(
                        color: _groen,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  'Alle bedragen blijven uitsluitend in de versleutelde lokale kluis.',
                  style: TextStyle(
                    color: _tekstGrijs,
                    fontSize: 10.7,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required _FinancieleSectie sectie,
    required IconData icoon,
    required String label,
    int? badge,
  }) {
    final geselecteerd = _sectie == sectie;

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Material(
        color: geselecteerd ? _lichtGroen : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => setState(() => _sectie = sectie),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
            child: Row(
              children: <Widget>[
                Icon(
                  icoon,
                  color: geselecteerd ? _groen : _tekstGrijs,
                  size: 19,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: geselecteerd ? _groen : _tekstDonker,
                      fontSize: 12.2,
                      fontWeight: geselecteerd
                          ? FontWeight.w900
                          : FontWeight.w700,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    constraints: const BoxConstraints(minWidth: 23),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: geselecteerd
                          ? Colors.white
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$badge',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: geselecteerd ? _groen : _tekstGrijs,
                        fontSize: 10.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bouwMobieleNavigatie() {
    final opties = <(_FinancieleSectie, IconData, String)>[
      (_FinancieleSectie.overzicht, Icons.dashboard_outlined, 'Overzicht'),
      (_FinancieleSectie.teBetalen, Icons.arrow_upward_rounded, 'Te betalen'),
      (
        _FinancieleSectie.teOntvangen,
        Icons.arrow_downward_rounded,
        'Te ontvangen',
      ),
      (_FinancieleSectie.andereOntvangsten, Icons.savings_outlined, 'Andere'),
      (_FinancieleSectie.vasteKosten, Icons.repeat_rounded, 'Vaste kosten'),
      (
        _FinancieleSectie.rekeningen,
        Icons.account_balance_outlined,
        'Zakelijke rekeningen',
      ),
      (
        _FinancieleSectie.priveRekeningen,
        Icons.account_balance_wallet_outlined,
        'Privé rekeningen',
      ),
    ];

    return ColoredBox(
      color: Colors.white,
      child: SizedBox(
        height: 54,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          scrollDirection: Axis.horizontal,
          itemCount: opties.length,
          separatorBuilder: (_, _) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final optie = opties[index];
            final geselecteerd = _sectie == optie.$1;
            return ChoiceChip(
              selected: geselecteerd,
              showCheckmark: false,
              avatar: Icon(
                optie.$2,
                size: 17,
                color: geselecteerd ? _groen : _tekstGrijs,
              ),
              label: Text(optie.$3),
              selectedColor: _lichtGroen,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: geselecteerd ? const Color(0xFFB9E1C6) : _rand,
              ),
              labelStyle: TextStyle(
                color: geselecteerd ? _groen : _tekstDonker,
                fontWeight: FontWeight.w800,
              ),
              onSelected: (_) => setState(() => _sectie = optie.$1),
            );
          },
        ),
      ),
    );
  }

  Widget _bouwSectie(FinancieleCockpitData data) {
    return switch (_sectie) {
      _FinancieleSectie.overzicht => _bouwOverzicht(data),
      _FinancieleSectie.teBetalen => _bouwTeBetalen(data),
      _FinancieleSectie.teOntvangen => _bouwTeOntvangen(data),
      _FinancieleSectie.andereOntvangsten => _bouwAndereOntvangsten(data),
      _FinancieleSectie.vasteKosten => _bouwVasteKosten(data),
      _FinancieleSectie.rekeningen => _bouwRekeningen(data),
      _FinancieleSectie.priveRekeningen => _bouwPriveRekeningen(data),
    };
  }

  Widget _bouwOverzicht(FinancieleCockpitData data) {
    final betalingen = data.teBetalen.where((item) => item.teltMee).toList()
      ..sort((a, b) => a.planningDatum.compareTo(b.planningDatum));
    final ontvangsten = _volgendeOntvangsten(data);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _sectieTitel(
          titel: 'Financiële positie',
          subtitel:
              'Actuele stand op basis van de bedragen die je zelf in deze kluis bijhoudt.',
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final kolommen = constraints.maxWidth >= 1120
                ? 6
                : constraints.maxWidth >= 720
                ? 3
                : 1;
            final breedte =
                (constraints.maxWidth - ((kolommen - 1) * 10)) / kolommen;
            final kaarten = <Widget>[
              _samenvattingKaart(
                titel: 'Rekeningstanden',
                waarde: _euro.format(data.totaalRekeningen),
                icoon: Icons.account_balance_outlined,
                kleur: _groen,
                detail:
                    '${data.rekeningen.where((item) => item.actief).length} actieve rekening(en)',
              ),
              _samenvattingKaart(
                titel: 'Te ontvangen van klanten',
                waarde: _euro.format(data.totaalKlantOntvangsten),
                icoon: Icons.people_alt_outlined,
                kleur: _blauw,
                detail: 'Openstaande klantbedragen',
              ),
              _samenvattingKaart(
                titel: 'Andere te ontvangen bedragen',
                waarde: _euro.format(data.totaalAndereOntvangsten),
                icoon: Icons.savings_outlined,
                kleur: _blauw,
                detail: 'BTW, subsidies en overige ontvangsten',
              ),
              _samenvattingKaart(
                titel: 'Te betalen',
                waarde: _euro.format(data.totaalTeBetalen),
                icoon: Icons.north_east_rounded,
                kleur: _oranje,
                detail: 'Open en geplande bedragen',
              ),
              _samenvattingKaart(
                titel: 'Verwachte positie',
                waarde: _euro.format(data.verwachtePositie),
                icoon: Icons.trending_up_rounded,
                kleur: data.verwachtePositie >= 0 ? _groen : _rood,
                detail: 'Rekeningen + te ontvangen − te betalen',
              ),
              _samenvattingKaart(
                titel: 'Vaste maandkost',
                waarde: _euro.format(data.vasteMaandkost),
                icoon: Icons.repeat_rounded,
                kleur: const Color(0xFF7C3AED),
                detail: '${_euro.format(data.vasteJaarkost)} per jaar',
              ),
            ];

            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: kaarten
                  .map((kaart) => SizedBox(width: breedte, child: kaart))
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final breed = constraints.maxWidth >= 780;
            final links = _komendeKaart(
              titel: 'Eerstvolgende betalingen',
              icoon: Icons.arrow_upward_rounded,
              leegTekst: 'Geen openstaande betalingen ingevoerd.',
              kinderen: betalingen.map(_betalingCompact).toList(growable: false),
              scrollController: _betalingenScrollController,
              onAlles: () =>
                  setState(() => _sectie = _FinancieleSectie.teBetalen),
            );
            final rechts = _komendeKaart(
              titel: 'Eerstvolgende ontvangsten',
              icoon: Icons.arrow_downward_rounded,
              leegTekst: 'Geen openstaande ontvangsten ingevoerd.',
              kinderen: ontvangsten.map(_ontvangstCompact).toList(growable: false),
              scrollController: _ontvangstenScrollController,
              onAlles: () =>
                  setState(() => _sectie = _FinancieleSectie.teOntvangen),
            );

            if (!breed) {
              return Column(
                children: <Widget>[links, const SizedBox(height: 12), rechts],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(child: links),
                const SizedBox(width: 12),
                Expanded(child: rechts),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _bouwTeBetalen(FinancieleCockpitData data) {
    final items = List<FinancieleTeBetalen>.from(data.teBetalen)
      ..sort((a, b) {
        if (a.teltMee != b.teltMee) return a.teltMee ? -1 : 1;
        return a.planningDatum.compareTo(b.planningDatum);
      });

    return _lijstSectie(
      titel: 'Te betalen',
      subtitel:
          'Alles wat nog van de rekening moet vertrekken, gesorteerd op geplande of vervaldatum.',
      icoon: Icons.arrow_upward_rounded,
      actieLabel: 'Betaling toevoegen',
      onToevoegen: () => _voegTeBetalenToe(data),
      samenvatting: <Widget>[
        _miniTotaal('Openstaand', _euro.format(data.totaalTeBetalen), _oranje),
        _miniTotaal(
          'Aantal open',
          '${data.teBetalen.where((item) => item.teltMee).length}',
          _tekstDonker,
        ),
      ],
      kinderen: items.isEmpty
          ? <Widget>[
              _legeStaat(
                Icons.receipt_long_outlined,
                'Nog geen betalingen ingevoerd.',
              ),
            ]
          : items
                .map((item) => _betalingRij(data, item))
                .toList(growable: false),
    );
  }

  Widget _bouwTeOntvangen(FinancieleCockpitData data) {
    final items = List<FinancieleTeOntvangen>.from(data.teOntvangen)
      ..sort((a, b) {
        final aOpen = a.openstaand > 0;
        final bOpen = b.openstaand > 0;
        if (aOpen != bOpen) return aOpen ? -1 : 1;
        return a.planningDatum.compareTo(b.planningDatum);
      });

    return _lijstSectie(
      titel: 'Te ontvangen',
      subtitel:
          'Openstaande klantbedragen met vervaldatum en, waar bekend, de werkelijk verwachte betaaldatum.',
      icoon: Icons.arrow_downward_rounded,
      actieLabel: 'Ontvangst toevoegen',
      onToevoegen: () => _voegTeOntvangenToe(data),
      samenvatting: <Widget>[
        _miniTotaal(
          'Openstaand',
          _euro.format(data.totaalKlantOntvangsten),
          _blauw,
        ),
        _miniTotaal(
          'Aantal open',
          '${data.teOntvangen.where((item) => item.openstaand > 0).length}',
          _tekstDonker,
        ),
      ],
      kinderen: items.isEmpty
          ? <Widget>[
              _legeStaat(
                Icons.request_quote_outlined,
                'Nog geen klantontvangsten ingevoerd.',
              ),
            ]
          : items
                .map((item) => _teOntvangenRij(data, item))
                .toList(growable: false),
    );
  }

  Widget _bouwAndereOntvangsten(FinancieleCockpitData data) {
    final items = List<FinancieleAndereOntvangst>.from(data.andereOntvangsten)
      ..sort((a, b) {
        if (a.teltMee != b.teltMee) return a.teltMee ? -1 : 1;
        return a.verwachtOp.compareTo(b.verwachtOp);
      });

    return _lijstSectie(
      titel: 'Andere ontvangsten',
      subtitel:
          'BTW-teruggaven, subsidies, verzekeringen, waarborgen en andere bedragen buiten klantenfacturen.',
      icoon: Icons.savings_outlined,
      actieLabel: 'Andere ontvangst toevoegen',
      onToevoegen: () => _voegAndereOntvangstToe(data),
      samenvatting: <Widget>[
        _miniTotaal(
          'Nog verwacht',
          _euro.format(data.totaalAndereOntvangsten),
          _blauw,
        ),
        _miniTotaal(
          'Aantal open',
          '${data.andereOntvangsten.where((item) => item.teltMee).length}',
          _tekstDonker,
        ),
      ],
      kinderen: items.isEmpty
          ? <Widget>[
              _legeStaat(
                Icons.savings_outlined,
                'Nog geen andere ontvangsten ingevoerd.',
              ),
            ]
          : items
                .map((item) => _andereOntvangstRij(data, item))
                .toList(growable: false),
    );
  }

  Widget _bouwVasteKosten(FinancieleCockpitData data) {
    final items = List<FinancieleVasteKost>.from(data.vasteKosten)
      ..sort((a, b) {
        if (a.actief != b.actief) return a.actief ? -1 : 1;
        final cat = a.categorie.toLowerCase().compareTo(
          b.categorie.toLowerCase(),
        );
        return cat != 0
            ? cat
            : a.omschrijving.toLowerCase().compareTo(
                b.omschrijving.toLowerCase(),
              );
      });

    final categorieTotaal = <String, double>{};
    for (final item in items.where((item) => item.actiefVandaag)) {
      final categorie = item.categorie.trim().isEmpty
          ? 'Overige'
          : item.categorie.trim();
      categorieTotaal[categorie] =
          (categorieTotaal[categorie] ?? 0) + item.maandGemiddelde;
    }
    final categorieen = categorieTotaal.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _sectieTitelMetActie(
          titel: 'Vaste kosten',
          subtitel:
              'Breng de structurele kosten exact in kaart. Niet-maandelijkse kosten worden naar een maandgemiddelde omgerekend.',
          icoon: Icons.repeat_rounded,
          actieLabel: 'Vaste kost toevoegen',
          onToevoegen: () => _voegVasteKostToe(data),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            SizedBox(
              width: 260,
              child: _samenvattingKaart(
                titel: 'Gemiddeld per maand',
                waarde: _euro.format(data.vasteMaandkost),
                icoon: Icons.calendar_month_outlined,
                kleur: const Color(0xFF7C3AED),
                detail:
                    '${items.where((item) => item.actiefVandaag).length} actieve vaste kost(en)',
              ),
            ),
            SizedBox(
              width: 260,
              child: _samenvattingKaart(
                titel: 'Gemiddeld per jaar',
                waarde: _euro.format(data.vasteJaarkost),
                icoon: Icons.calendar_today_outlined,
                kleur: _groen,
                detail: 'Omgerekend uit alle frequenties',
              ),
            ),
          ],
        ),
        if (categorieen.isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          _kaart(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Maandkost per categorie',
                  style: TextStyle(
                    color: _tekstDonker,
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 10),
                for (
                  var index = 0;
                  index < categorieen.length;
                  index++
                ) ...<Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          categorieen[index].key,
                          style: const TextStyle(
                            color: _tekstDonker,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        _euro.format(categorieen[index].value),
                        style: const TextStyle(
                          color: _tekstDonker,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  if (index != categorieen.length - 1)
                    const Divider(height: 14, color: _rand),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        if (items.isEmpty)
          _legeStaat(Icons.repeat_rounded, 'Nog geen vaste kosten ingevoerd.')
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _vasteKostRij(data, item),
            ),
          ),
      ],
    );
  }

  Widget _bouwRekeningen(FinancieleCockpitData data) {
    final items = List<FinancieleRekening>.from(data.rekeningen)
      ..sort((a, b) {
        if (a.actief != b.actief) return a.actief ? -1 : 1;
        return a.naam.toLowerCase().compareTo(b.naam.toLowerCase());
      });

    return _lijstSectie(
      titel: 'Zakelijke rekeningen',
      subtitel:
          'Uitsluitend zakelijke rekeningstanden. Alleen deze rekeningen tellen mee in het financiële overzicht en de verwachte positie.',
      icoon: Icons.account_balance_outlined,
      actieLabel: 'Zakelijke rekening toevoegen',
      onToevoegen: () => _voegRekeningToe(data),
      samenvatting: <Widget>[
        _miniTotaal(
          'Totaal zakelijk',
          _euro.format(data.totaalRekeningen),
          _groen,
        ),
        _miniTotaal(
          'Actieve rekeningen',
          '${data.rekeningen.where((item) => item.actief).length}',
          _tekstDonker,
        ),
      ],
      kinderen: items.isEmpty
          ? <Widget>[
              _legeStaat(
                Icons.account_balance_outlined,
                'Nog geen zakelijke rekeningen ingevoerd.',
              ),
            ]
          : items
                .map((item) => _rekeningRij(data, item))
                .toList(growable: false),
    );
  }

  Widget _bouwPriveRekeningen(FinancieleCockpitData data) {
    final items = List<FinancieleRekening>.from(data.priveRekeningen)
      ..sort((a, b) {
        if (a.actief != b.actief) return a.actief ? -1 : 1;
        return a.naam.toLowerCase().compareTo(b.naam.toLowerCase());
      });

    return _lijstSectie(
      titel: 'Privé rekeningen',
      subtitel:
          'Persoonlijk overzicht. Deze rekeningen worden nergens in de zakelijke totalen, verwachte positie, betalingen of ontvangsten meegerekend.',
      icoon: Icons.account_balance_wallet_outlined,
      actieLabel: 'Privérekening toevoegen',
      onToevoegen: () => _voegPriveRekeningToe(data),
      samenvatting: <Widget>[
        _miniTotaal(
          'Totaal privé',
          _euro.format(data.totaalPriveRekeningen),
          _blauw,
        ),
        _miniTotaal(
          'Actieve privérekeningen',
          '${data.priveRekeningen.where((item) => item.actief).length}',
          _tekstDonker,
        ),
      ],
      kinderen: items.isEmpty
          ? <Widget>[
              _legeStaat(
                Icons.account_balance_wallet_outlined,
                'Nog geen privérekeningen ingevoerd.',
              ),
            ]
          : items
                .map((item) => _priveRekeningRij(data, item))
                .toList(growable: false),
    );
  }

  Widget _lijstSectie({
    required String titel,
    required String subtitel,
    required IconData icoon,
    required String actieLabel,
    required VoidCallback onToevoegen,
    required List<Widget> samenvatting,
    required List<Widget> kinderen,
  }) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _sectieTitelMetActie(
          titel: titel,
          subtitel: subtitel,
          icoon: icoon,
          actieLabel: actieLabel,
          onToevoegen: onToevoegen,
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 10, runSpacing: 10, children: samenvatting),
        const SizedBox(height: 14),
        ...kinderen.map(
          (kind) =>
              Padding(padding: const EdgeInsets.only(bottom: 8), child: kind),
        ),
      ],
    );
  }

  Widget _sectieTitel({required String titel, required String subtitel}) {
    return Column(
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
        const SizedBox(height: 3),
        Text(
          subtitel,
          style: const TextStyle(
            color: _tekstGrijs,
            fontSize: 11.6,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _sectieTitelMetActie({
    required String titel,
    required String subtitel,
    required IconData icoon,
    required String actieLabel,
    required VoidCallback onToevoegen,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: _sectieTitel(titel: titel, subtitel: subtitel),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: _groen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: widget.controller.bewerkingBezig ? null : onToevoegen,
          icon: Icon(icoon, size: 18),
          label: Text(
            actieLabel,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }

  Widget _samenvattingKaart({
    required String titel,
    required String waarde,
    required IconData icoon,
    required Color kleur,
    required String detail,
  }) {
    return _kaart(
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: kleur.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icoon, color: kleur, size: 18),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  titel,
                  style: const TextStyle(
                    color: _tekstGrijs,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              waarde,
              style: const TextStyle(
                color: _tekstDonker,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            style: const TextStyle(
              color: _tekstGrijs,
              fontSize: 10.3,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniTotaal(String label, String waarde, Color kleur) {
    return Container(
      constraints: const BoxConstraints(minWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: _rand),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: _tekstGrijs,
              fontSize: 11.3,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            waarde,
            style: TextStyle(
              color: kleur,
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _kaart({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(14),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _rand),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x09000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _legeStaat(IconData icoon, String tekst) {
    return _kaart(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Column(
            children: <Widget>[
              Icon(icoon, color: const Color(0xFF9CA3AF), size: 32),
              const SizedBox(height: 8),
              Text(
                tekst,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _tekstGrijs,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _komendeKaart({
    required String titel,
    required IconData icoon,
    required String leegTekst,
    required List<Widget> kinderen,
    required ScrollController scrollController,
    required VoidCallback onAlles,
  }) {
    return _kaart(
      child: SizedBox(
        height: 410,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icoon, color: _groen, size: 19),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    titel,
                    style: const TextStyle(
                      color: _tekstDonker,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                TextButton(onPressed: onAlles, child: const Text('Alles')),
              ],
            ),
            const SizedBox(height: 5),
            Expanded(
              child: kinderen.isEmpty
                  ? Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          leegTekst,
                          style: const TextStyle(
                            color: _tekstGrijs,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    )
                  : Scrollbar(
                      controller: scrollController,
                      thumbVisibility: true,
                      child: ListView.separated(
                        controller: scrollController,
                        primary: false,
                        padding: const EdgeInsets.only(right: 10),
                        itemCount: kinderen.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1, color: _rand),
                        itemBuilder: (_, index) => kinderen[index],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _betalingCompact(FinancieleTeBetalen item) {
    return _compactMoment(
      titel: item.leverancier,
      subtitel: item.omschrijving,
      datum: item.planningDatum,
      bedrag: item.bedrag,
      kleur: _oranje,
    );
  }

  Widget _ontvangstCompact(_CockpitOntvangstMoment item) {
    return _compactMoment(
      titel: item.titel,
      subtitel: item.subtitel,
      datum: item.datum,
      bedrag: item.bedrag,
      kleur: _blauw,
    );
  }

  Widget _compactMoment({
    required String titel,
    required String subtitel,
    required DateTime datum,
    required double bedrag,
    required Color kleur,
  }) {
    final datumKleur = _kleurVoorDatum(datum);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: <Widget>[
          Container(
            width: 4,
            height: 38,
            decoration: BoxDecoration(
              color: datumKleur,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  titel.trim().isEmpty ? subtitel : titel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _tekstDonker,
                    fontSize: 11.8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_datum.format(datum)}${subtitel.trim().isEmpty ? '' : ' · $subtitel'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _tekstGrijs, fontSize: 10.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _euro.format(bedrag),
            style: TextStyle(
              color: kleur,
              fontSize: 11.8,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _betalingRij(FinancieleCockpitData data, FinancieleTeBetalen item) {
    return _detailRij(
      icoon: Icons.arrow_upward_rounded,
      icoonKleur: item.teltMee ? _oranje : _tekstGrijs,
      titel: item.leverancier,
      omschrijving: item.omschrijving,
      bedrag: item.bedrag,
      bedragKleur: item.teltMee ? _oranje : _tekstGrijs,
      datumLabel: item.geplandOp == null ? 'Vervalt' : 'Gepland',
      datum: item.planningDatum,
      statusLabel: item.status.label,
      statusKleur: item.status == FinancieleBetalingStatus.betaald
          ? _groen
          : item.status == FinancieleBetalingStatus.gepland
          ? _blauw
          : _oranje,
      extra: <String>[
        if (item.factuurNummer.isNotEmpty) 'Factuur ${item.factuurNummer}',
        if (item.belangrijk) 'Belangrijk',
      ],
      opTap: () => _bewerkTeBetalen(data, item),
      onVerwijder: () => _verwijderTeBetalen(data, item),
    );
  }

  Widget _teOntvangenRij(
    FinancieleCockpitData data,
    FinancieleTeOntvangen item,
  ) {
    return _detailRij(
      icoon: Icons.arrow_downward_rounded,
      icoonKleur: item.openstaand > 0 ? _blauw : _tekstGrijs,
      titel: item.klant,
      omschrijving: item.omschrijving,
      bedrag: item.openstaand,
      bedragKleur: item.openstaand > 0 ? _blauw : _tekstGrijs,
      datumLabel: item.verwachtOp == null ? 'Vervalt' : 'Verwacht',
      datum: item.planningDatum,
      statusLabel: item.status.label,
      statusKleur: item.status == FinancieleOntvangstStatus.ontvangen
          ? _groen
          : item.status == FinancieleOntvangstStatus.deelsOntvangen
          ? _oranje
          : _blauw,
      extra: <String>[
        if (item.factuurNummer.isNotEmpty) 'Ref. ${item.factuurNummer}',
        if (item.reedsOntvangen > 0)
          'Reeds ${_euro.format(item.reedsOntvangen)}',
      ],
      opTap: () => _bewerkTeOntvangen(data, item),
      onVerwijder: () => _verwijderTeOntvangen(data, item),
    );
  }

  Widget _andereOntvangstRij(
    FinancieleCockpitData data,
    FinancieleAndereOntvangst item,
  ) {
    return _detailRij(
      icoon: Icons.savings_outlined,
      icoonKleur: item.teltMee ? _blauw : _tekstGrijs,
      titel: item.soort,
      omschrijving: <String>[
        if (item.van.isNotEmpty) item.van,
        if (item.omschrijving.isNotEmpty) item.omschrijving,
      ].join(' · '),
      bedrag: item.teltMee ? item.bedrag : 0,
      bedragKleur: item.teltMee ? _blauw : _tekstGrijs,
      datumLabel: 'Verwacht',
      datum: item.verwachtOp,
      statusLabel: '${item.status.label} · ${item.zekerheid.label}',
      statusKleur: item.status == FinancieleAndereOntvangstStatus.ontvangen
          ? _groen
          : item.zekerheid == FinancieleZekerheid.onzeker
          ? _oranje
          : _blauw,
      extra: const <String>[],
      opTap: () => _bewerkAndereOntvangst(data, item),
      onVerwijder: () => _verwijderAndereOntvangst(data, item),
    );
  }

  Widget _vasteKostRij(FinancieleCockpitData data, FinancieleVasteKost item) {
    final omschrijving = <String>[
      item.categorie,
      if (item.leverancier.isNotEmpty) item.leverancier,
    ].where((deel) => deel.trim().isNotEmpty).join(' · ');

    return _kaart(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _bewerkVasteKost(data, item),
        child: Row(
          children: <Widget>[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: item.actiefVandaag
                    ? const Color(0xFFF3E8FF)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.repeat_rounded,
                color: item.actiefVandaag
                    ? const Color(0xFF7C3AED)
                    : _tekstGrijs,
                size: 19,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.omschrijving,
                    style: TextStyle(
                      color: item.actiefVandaag ? _tekstDonker : _tekstGrijs,
                      fontSize: 12.2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (omschrijving.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      omschrijving,
                      style: const TextStyle(
                        color: _tekstGrijs,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    _euro.format(item.bedrag),
                    style: const TextStyle(
                      color: _tekstDonker,
                      fontSize: 12.2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.frequentie.label,
                    style: const TextStyle(color: _tekstGrijs, fontSize: 10.3),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    _euro.format(item.maandGemiddelde),
                    style: TextStyle(
                      color: item.actiefVandaag
                          ? const Color(0xFF7C3AED)
                          : _tekstGrijs,
                      fontSize: 12.2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'per maand',
                    style: TextStyle(color: _tekstGrijs, fontSize: 10.3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            PopupMenuButton<String>(
              tooltip: 'Meer',
              onSelected: (keuze) {
                if (keuze == 'bewerken') _bewerkVasteKost(data, item);
                if (keuze == 'verwijderen') _verwijderVasteKost(data, item);
              },
              itemBuilder: (_) => const <PopupMenuEntry<String>>[
                PopupMenuItem(value: 'bewerken', child: Text('Bewerken')),
                PopupMenuItem(value: 'verwijderen', child: Text('Verwijderen')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _rekeningRij(FinancieleCockpitData data, FinancieleRekening item) {
    return _kaart(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _bewerkRekening(data, item),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.actief ? _lichtGroen : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.account_balance_outlined,
                color: item.actief ? _groen : _tekstGrijs,
                size: 20,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.naam,
                    style: TextStyle(
                      color: item.actief ? _tekstDonker : _tekstGrijs,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    <String>[
                      if (item.rekeningNummer.isNotEmpty) item.rekeningNummer,
                      'Stand ${_datum.format(item.saldoDatum)}',
                    ].join(' · '),
                    style: const TextStyle(color: _tekstGrijs, fontSize: 10.5),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  _euro.format(item.saldo),
                  style: TextStyle(
                    color: item.saldo >= 0 ? _groen : _rood,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (item.beschikbaarKrediet > 0) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    'Krediet ${_euro.format(item.beschikbaarKrediet)}',
                    style: const TextStyle(color: _tekstGrijs, fontSize: 10.2),
                  ),
                ],
              ],
            ),
            const SizedBox(width: 6),
            PopupMenuButton<String>(
              tooltip: 'Meer',
              onSelected: (keuze) {
                if (keuze == 'bewerken') _bewerkRekening(data, item);
                if (keuze == 'verwijderen') _verwijderRekening(data, item);
              },
              itemBuilder: (_) => const <PopupMenuEntry<String>>[
                PopupMenuItem(value: 'bewerken', child: Text('Bewerken')),
                PopupMenuItem(value: 'verwijderen', child: Text('Verwijderen')),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _priveRekeningRij(FinancieleCockpitData data, FinancieleRekening item) {
    return _kaart(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _bewerkPriveRekening(data, item),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.actief ? _lichtGroen : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.account_balance_outlined,
                color: item.actief ? _groen : _tekstGrijs,
                size: 20,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.naam,
                    style: TextStyle(
                      color: item.actief ? _tekstDonker : _tekstGrijs,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    <String>[
                      if (item.rekeningNummer.isNotEmpty) item.rekeningNummer,
                      'Stand ${_datum.format(item.saldoDatum)}',
                    ].join(' · '),
                    style: const TextStyle(color: _tekstGrijs, fontSize: 10.5),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  _euro.format(item.saldo),
                  style: TextStyle(
                    color: item.saldo >= 0 ? _groen : _rood,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (item.beschikbaarKrediet > 0) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    'Krediet ${_euro.format(item.beschikbaarKrediet)}',
                    style: const TextStyle(color: _tekstGrijs, fontSize: 10.2),
                  ),
                ],
              ],
            ),
            const SizedBox(width: 6),
            PopupMenuButton<String>(
              tooltip: 'Meer',
              onSelected: (keuze) {
                if (keuze == 'bewerken') _bewerkPriveRekening(data, item);
                if (keuze == 'verwijderen') _verwijderPriveRekening(data, item);
              },
              itemBuilder: (_) => const <PopupMenuEntry<String>>[
                PopupMenuItem(value: 'bewerken', child: Text('Bewerken')),
                PopupMenuItem(value: 'verwijderen', child: Text('Verwijderen')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRij({
    required IconData icoon,
    required Color icoonKleur,
    required String titel,
    required String omschrijving,
    required double bedrag,
    required Color bedragKleur,
    required String datumLabel,
    required DateTime datum,
    required String statusLabel,
    required Color statusKleur,
    required List<String> extra,
    required VoidCallback opTap,
    required VoidCallback onVerwijder,
  }) {
    return _kaart(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: opTap,
        child: Row(
          children: <Widget>[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: icoonKleur.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icoon, color: icoonKleur, size: 19),
            ),
            const SizedBox(width: 11),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    titel.trim().isEmpty ? omschrijving : titel,
                    style: const TextStyle(
                      color: _tekstDonker,
                      fontSize: 12.2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    <String>[
                      if (omschrijving.trim().isNotEmpty &&
                          omschrijving.trim() != titel.trim())
                        omschrijving,
                      ...extra,
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _tekstGrijs, fontSize: 10.4),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    '$datumLabel ${_datum.format(datum)}',
                    style: TextStyle(
                      color: _kleurVoorDatum(datum),
                      fontSize: 10.6,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  _statusChip(statusLabel, statusKleur),
                ],
              ),
            ),
            const SizedBox(width: 14),
            SizedBox(
              width: 118,
              child: Text(
                _euro.format(bedrag),
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: bedragKleur,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Meer',
              onSelected: (keuze) {
                if (keuze == 'bewerken') opTap();
                if (keuze == 'verwijderen') onVerwijder();
              },
              itemBuilder: (_) => const <PopupMenuEntry<String>>[
                PopupMenuItem(value: 'bewerken', child: Text('Bewerken')),
                PopupMenuItem(value: 'verwijderen', child: Text('Verwijderen')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String label, Color kleur) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: kleur.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kleur.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: kleur,
          fontSize: 9.4,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Future<void> _toonToevoegenKeuze(FinancieleCockpitData data) async {
    final keuze = await showDialog<_ToevoegType>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _rand),
          ),
          title: const Text(
            'Wat wil je toevoegen?',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _toevoegKeuze(
                  dialogContext,
                  _ToevoegType.teBetalen,
                  Icons.arrow_upward_rounded,
                  'Te betalen',
                  'Leverancier of andere komende betaling',
                ),
                _toevoegKeuze(
                  dialogContext,
                  _ToevoegType.teOntvangen,
                  Icons.arrow_downward_rounded,
                  'Te ontvangen',
                  'Openstaand bedrag van een klant',
                ),
                _toevoegKeuze(
                  dialogContext,
                  _ToevoegType.andereOntvangst,
                  Icons.savings_outlined,
                  'Andere ontvangst',
                  'BTW-teruggave, subsidie, waarborg…',
                ),
                _toevoegKeuze(
                  dialogContext,
                  _ToevoegType.vasteKost,
                  Icons.repeat_rounded,
                  'Vaste kost',
                  'Maandelijkse, kwartaal- of jaarlijkse kost',
                ),
                _toevoegKeuze(
                  dialogContext,
                  _ToevoegType.rekening,
                  Icons.account_balance_outlined,
                  'Zakelijke rekening',
                  'Actuele zakelijke rekeningstand invoeren',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuleren'),
            ),
          ],
        );
      },
    );

    if (!mounted || keuze == null) return;

    switch (keuze) {
      case _ToevoegType.teBetalen:
        await _voegTeBetalenToe(data);
        break;
      case _ToevoegType.teOntvangen:
        await _voegTeOntvangenToe(data);
        break;
      case _ToevoegType.andereOntvangst:
        await _voegAndereOntvangstToe(data);
        break;
      case _ToevoegType.vasteKost:
        await _voegVasteKostToe(data);
        break;
      case _ToevoegType.rekening:
        await _voegRekeningToe(data);
        break;
    }
  }

  Widget _toevoegKeuze(
    BuildContext dialogContext,
    _ToevoegType type,
    IconData icoon,
    String titel,
    String subtitel,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Material(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: () => Navigator.pop(dialogContext, type),
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: Row(
              children: <Widget>[
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _lichtGroen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icoon, color: _groen, size: 19),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        titel,
                        style: const TextStyle(
                          color: _tekstDonker,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitel,
                        style: const TextStyle(
                          color: _tekstGrijs,
                          fontSize: 10.7,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: _tekstGrijs),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _voegRekeningToe(FinancieleCockpitData data) async {
    final item = await FinancieleInvoerDialogen.rekening(context);
    if (!mounted || item == null) return;
    await _bewaarData(
      data.copyWith(rekeningen: <FinancieleRekening>[...data.rekeningen, item]),
    );
  }

  Future<void> _bewerkRekening(
    FinancieleCockpitData data,
    FinancieleRekening bestaand,
  ) async {
    final item = await FinancieleInvoerDialogen.rekening(
      context,
      bestaand: bestaand,
    );
    if (!mounted || item == null) return;
    await _bewaarData(
      data.copyWith(
        rekeningen: _vervangOpId(data.rekeningen, item, (x) => x.id),
      ),
    );
  }

  Future<void> _verwijderRekening(
    FinancieleCockpitData data,
    FinancieleRekening item,
  ) async {
    final bevestigd = await _bevestigVerwijderen('rekening', item.naam);
    if (!mounted || !bevestigd) return;
    await _bewaarData(
      data.copyWith(
        rekeningen: data.rekeningen.where((x) => x.id != item.id).toList(),
      ),
    );
  }

  Future<void> _voegPriveRekeningToe(FinancieleCockpitData data) async {
    final item = await FinancieleInvoerDialogen.rekening(context);
    if (!mounted || item == null) return;
    await _bewaarData(
      data.copyWith(
        priveRekeningen: <FinancieleRekening>[...data.priveRekeningen, item],
      ),
    );
  }

  Future<void> _bewerkPriveRekening(
    FinancieleCockpitData data,
    FinancieleRekening bestaand,
  ) async {
    final item = await FinancieleInvoerDialogen.rekening(
      context,
      bestaand: bestaand,
    );
    if (!mounted || item == null) return;
    await _bewaarData(
      data.copyWith(
        priveRekeningen: _vervangOpId(
          data.priveRekeningen,
          item,
          (x) => x.id,
        ),
      ),
    );
  }

  Future<void> _verwijderPriveRekening(
    FinancieleCockpitData data,
    FinancieleRekening item,
  ) async {
    final bevestigd = await _bevestigVerwijderen('privérekening', item.naam);
    if (!mounted || !bevestigd) return;
    await _bewaarData(
      data.copyWith(
        priveRekeningen: data.priveRekeningen
            .where((x) => x.id != item.id)
            .toList(),
      ),
    );
  }

  Future<void> _voegTeBetalenToe(FinancieleCockpitData data) async {
    final item = await FinancieleInvoerDialogen.teBetalen(context);
    if (!mounted || item == null) return;
    await _bewaarData(
      data.copyWith(teBetalen: <FinancieleTeBetalen>[...data.teBetalen, item]),
    );
  }

  Future<void> _bewerkTeBetalen(
    FinancieleCockpitData data,
    FinancieleTeBetalen bestaand,
  ) async {
    final item = await FinancieleInvoerDialogen.teBetalen(
      context,
      bestaand: bestaand,
    );
    if (!mounted || item == null) return;
    await _bewaarData(
      data.copyWith(teBetalen: _vervangOpId(data.teBetalen, item, (x) => x.id)),
    );
  }

  Future<void> _verwijderTeBetalen(
    FinancieleCockpitData data,
    FinancieleTeBetalen item,
  ) async {
    final bevestigd = await _bevestigVerwijderen('betaling', item.leverancier);
    if (!mounted || !bevestigd) return;
    await _bewaarData(
      data.copyWith(
        teBetalen: data.teBetalen.where((x) => x.id != item.id).toList(),
      ),
    );
  }

  Future<void> _voegTeOntvangenToe(FinancieleCockpitData data) async {
    final item = await FinancieleInvoerDialogen.teOntvangen(context);
    if (!mounted || item == null) return;
    await _bewaarData(
      data.copyWith(
        teOntvangen: <FinancieleTeOntvangen>[...data.teOntvangen, item],
      ),
    );
  }

  Future<void> _bewerkTeOntvangen(
    FinancieleCockpitData data,
    FinancieleTeOntvangen bestaand,
  ) async {
    final item = await FinancieleInvoerDialogen.teOntvangen(
      context,
      bestaand: bestaand,
    );
    if (!mounted || item == null) return;
    await _bewaarData(
      data.copyWith(
        teOntvangen: _vervangOpId(data.teOntvangen, item, (x) => x.id),
      ),
    );
  }

  Future<void> _verwijderTeOntvangen(
    FinancieleCockpitData data,
    FinancieleTeOntvangen item,
  ) async {
    final bevestigd = await _bevestigVerwijderen('ontvangst', item.klant);
    if (!mounted || !bevestigd) return;
    await _bewaarData(
      data.copyWith(
        teOntvangen: data.teOntvangen.where((x) => x.id != item.id).toList(),
      ),
    );
  }

  Future<void> _voegAndereOntvangstToe(FinancieleCockpitData data) async {
    final item = await FinancieleInvoerDialogen.andereOntvangst(context);
    if (!mounted || item == null) return;
    await _bewaarData(
      data.copyWith(
        andereOntvangsten: <FinancieleAndereOntvangst>[
          ...data.andereOntvangsten,
          item,
        ],
      ),
    );
  }

  Future<void> _bewerkAndereOntvangst(
    FinancieleCockpitData data,
    FinancieleAndereOntvangst bestaand,
  ) async {
    final item = await FinancieleInvoerDialogen.andereOntvangst(
      context,
      bestaand: bestaand,
    );
    if (!mounted || item == null) return;
    await _bewaarData(
      data.copyWith(
        andereOntvangsten: _vervangOpId(
          data.andereOntvangsten,
          item,
          (x) => x.id,
        ),
      ),
    );
  }

  Future<void> _verwijderAndereOntvangst(
    FinancieleCockpitData data,
    FinancieleAndereOntvangst item,
  ) async {
    final bevestigd = await _bevestigVerwijderen(
      'andere ontvangst',
      item.soort,
    );
    if (!mounted || !bevestigd) return;
    await _bewaarData(
      data.copyWith(
        andereOntvangsten: data.andereOntvangsten
            .where((x) => x.id != item.id)
            .toList(),
      ),
    );
  }

  Future<void> _voegVasteKostToe(FinancieleCockpitData data) async {
    final item = await FinancieleInvoerDialogen.vasteKost(context);
    if (!mounted || item == null) return;
    await _bewaarData(
      data.copyWith(
        vasteKosten: <FinancieleVasteKost>[...data.vasteKosten, item],
      ),
    );
  }

  Future<void> _bewerkVasteKost(
    FinancieleCockpitData data,
    FinancieleVasteKost bestaand,
  ) async {
    final item = await FinancieleInvoerDialogen.vasteKost(
      context,
      bestaand: bestaand,
    );
    if (!mounted || item == null) return;
    await _bewaarData(
      data.copyWith(
        vasteKosten: _vervangOpId(data.vasteKosten, item, (x) => x.id),
      ),
    );
  }

  Future<void> _verwijderVasteKost(
    FinancieleCockpitData data,
    FinancieleVasteKost item,
  ) async {
    final bevestigd = await _bevestigVerwijderen(
      'vaste kost',
      item.omschrijving,
    );
    if (!mounted || !bevestigd) return;
    await _bewaarData(
      data.copyWith(
        vasteKosten: data.vasteKosten.where((x) => x.id != item.id).toList(),
      ),
    );
  }

  Future<void> _bewaarData(FinancieleCockpitData data) async {
    final basis = widget.controller.inhoud;
    if (basis == null) return;

    try {
      await widget.controller.bewaarInhoud(data.schrijfNaarKluis(basis));
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Financiële gegevens veilig opgeslagen.'),
            backgroundColor: _groen,
            duration: Duration(seconds: 2),
          ),
        );
    } catch (fout) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(fout.toString()), backgroundColor: _rood),
        );
    }
  }

  Future<bool> _bevestigVerwijderen(String soort, String naam) async {
    final resultaat = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: _rand),
        ),
        title: const Text(
          'Verwijderen?',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Text(
          'Wil je deze $soort${naam.trim().isEmpty ? '' : ' “${naam.trim()}”'} definitief uit de financiële kluis verwijderen?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _rood,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Verwijderen'),
          ),
        ],
      ),
    );
    return resultaat == true;
  }

  List<_CockpitOntvangstMoment> _volgendeOntvangsten(
    FinancieleCockpitData data,
  ) {
    final resultaat = <_CockpitOntvangstMoment>[
      ...data.teOntvangen
          .where((item) => item.openstaand > 0)
          .map(
            (item) => _CockpitOntvangstMoment(
              titel: item.klant,
              subtitel: item.omschrijving,
              datum: item.planningDatum,
              bedrag: item.openstaand,
            ),
          ),
      ...data.andereOntvangsten
          .where((item) => item.teltMee)
          .map(
            (item) => _CockpitOntvangstMoment(
              titel: item.soort,
              subtitel: item.van.isEmpty ? item.omschrijving : item.van,
              datum: item.verwachtOp,
              bedrag: item.bedrag,
            ),
          ),
    ];
    resultaat.sort((a, b) => a.datum.compareTo(b.datum));
    return resultaat;
  }

  Color _kleurVoorDatum(DateTime datum) {
    final vandaag = DateUtils.dateOnly(DateTime.now());
    final dag = DateUtils.dateOnly(datum);
    if (!dag.isAfter(vandaag)) return _rood;
    if (!dag.isAfter(vandaag.add(const Duration(days: 7)))) return _oranje;
    return _groen;
  }
}

class _CockpitOntvangstMoment {
  const _CockpitOntvangstMoment({
    required this.titel,
    required this.subtitel,
    required this.datum,
    required this.bedrag,
  });

  final String titel;
  final String subtitel;
  final DateTime datum;
  final double bedrag;
}

List<T> _vervangOpId<T>(
  List<T> lijst,
  T nieuwItem,
  String Function(T item) idVoor,
) {
  final nieuwId = idVoor(nieuwItem);
  return lijst
      .map((item) => idVoor(item) == nieuwId ? nieuwItem : item)
      .toList(growable: false);
}
