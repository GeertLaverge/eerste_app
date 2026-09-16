// THIMACO-CONTROLE: HOME-ZIJMENU-ALLEEN-KLIKBARE-TEKST-20260914
// THIMACO-CONTROLE: MAGAZIJN-BESTELMELDING-HOME-20260808
// THIMACO-CONTROLE: FINANCIELE-KLUIS-HOME-MENU-20260806
// THIMACO-CONTROLE: MAGAZIJN-HOME-ROUTE-20260804
import 'package:flutter/material.dart';

import '../../paginas/agenda_pagina_nieuw.dart' as agenda;
import '../../paginas/bibliotheek_pagina.dart';
import '../../paginas/klanten_pagina.dart';
import '../../helpers/magazijn/magazijn_controller.dart';
import '../../helpers/sync/sync_navigatie_helper.dart';
import '../../paginas/magazijn/magazijn_pagina.dart';
import '../../paginas/notities_bureau_pagina.dart';
import '../../paginas/opmeting_pagina.dart' as opmeting;
import '../../paginas/website_showroom_pagina.dart';

class HomeZijMenu extends StatefulWidget {
  final bool compact;
  final Future<void> Function()? onAfsluiten;
  final bool afsluitenBezig;
  final bool toonFinancieleKluis;
  final Future<void> Function()? onFinancieleKluis;

  const HomeZijMenu({
    super.key,
    required this.compact,
    this.onAfsluiten,
    this.afsluitenBezig = false,
    this.toonFinancieleKluis = false,
    this.onFinancieleKluis,
  });

  @override
  State<HomeZijMenu> createState() => _HomeZijMenuState();
}

class _HomeZijMenuState extends State<HomeZijMenu> {
  static const Color _oranje = Color(0xFFF15A24);
  static const Color _antraciet = Color(0xFF22272D);
  static const Color _tekstGrijs = Color(0xFF616973);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _oranjeLicht = Color(0xFFFFF4ED);
  static const Color _meldingRood = Color(0xFFDC2626);

  bool _magazijnHeeftBestellingNodig = false;
  int _magazijnStatusVersie = 0;

  bool get compact => widget.compact;
  Future<void> Function()? get onAfsluiten => widget.onAfsluiten;
  bool get afsluitenBezig => widget.afsluitenBezig;
  bool get toonFinancieleKluis => widget.toonFinancieleKluis;
  Future<void> Function()? get onFinancieleKluis => widget.onFinancieleKluis;

  @override
  void initState() {
    super.initState();
    SyncNavigatieHelper.downloadVersie.addListener(_herlaadMagazijnNaDownload);
    _herlaadMagazijnMelding();
  }

  @override
  void dispose() {
    SyncNavigatieHelper.downloadVersie.removeListener(
      _herlaadMagazijnNaDownload,
    );
    super.dispose();
  }

  void _herlaadMagazijnNaDownload() {
    _herlaadMagazijnMelding();
  }

  Future<void> _herlaadMagazijnMelding() async {
    final versie = ++_magazijnStatusVersie;
    final controller = MagazijnController();

    try {
      await controller.laad();

      var bestellingNodig = false;
      for (final leverancier in controller.data.leveranciers) {
        if (controller
            .bestelArtikelenVoorLeverancier(leverancier.id)
            .isNotEmpty) {
          bestellingNodig = true;
          break;
        }
      }

      if (!mounted || versie != _magazijnStatusVersie) return;

      setState(() {
        _magazijnHeeftBestellingNodig = bestellingNodig;
      });
    } finally {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 126 : 178,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: _rand),
        ),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(height: compact ? 10 : 18),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 8 : 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _menuTekst(
                    context,
                    'Agenda',
                    actief: true,
                  ),
                  _menuTekst(context, 'Klanten'),
                  _menuTekst(context, 'Notitie\'s\nplaatsers'),
                  _menuTekst(context, 'Notitie\'s\nbureau'),
                  _menuTekst(context, 'Opmeting'),
                  _menuTekst(context, 'Puinzak'),
                  _menuTekst(
                    context,
                    'Magazijn',
                    toonMeldingsBol: _magazijnHeeftBestellingNodig,
                  ),
                  if (toonFinancieleKluis)
                    _menuTekst(
                      context,
                      'Financiële\nkluis',
                      onTap: onFinancieleKluis,
                    ),
                  _menuTekst(context, 'Bibliotheek'),
                  _menuTekst(context, 'Website &\nshowroom'),
                ],
              ),
            ),
          ),
          const Divider(
            height: 1,
            color: _rand,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 8 : 12,
              compact ? 8 : 12,
              compact ? 8 : 12,
              compact ? 10 : 16,
            ),
            child: _menuTekst(
              context,
              afsluitenBezig ? 'Bewaren…' : 'Afsluiten',
              onTap: afsluitenBezig ? null : onAfsluiten,
              bezig: afsluitenBezig,
              onderMarge: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuTekst(
    BuildContext context,
    String titel, {
    bool actief = false,
    Future<void> Function()? onTap,
    bool bezig = false,
    bool toonMeldingsBol = false,
    double onderMarge = 4,
  }) {
    final label = titel.replaceAll('\n', ' ');

    return Padding(
      padding: EdgeInsets.only(bottom: onderMarge),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          hoverColor: _oranjeLicht,
          highlightColor: _oranjeLicht,
          splashColor: _oranjeLicht,
          onTap: bezig
              ? null
              : () async {
                  if (onTap != null) {
                    await onTap();
                    return;
                  }

                  if (titel == 'Agenda') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const agenda.AgendaPaginaNieuw(),
                      ),
                    );
                    return;
                  }

                  if (titel == 'Klanten') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const KlantenPagina(),
                      ),
                    );
                    return;
                  }

                  if (titel.contains('bureau')) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotitiesBureauPagina(),
                      ),
                    );
                    return;
                  }

                  if (titel == 'Magazijn') {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MagazijnPagina(),
                      ),
                    );
                    if (mounted) {
                      await _herlaadMagazijnMelding();
                    }
                    return;
                  }

                  if (titel == 'Bibliotheek') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BibliotheekPagina(),
                      ),
                    );
                    return;
                  }

                  if (titel == 'Opmeting') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const opmeting.OpmetingPagina(),
                      ),
                    );
                    return;
                  }

                  if (titel == 'Website &\nshowroom') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WebsiteShowroomPagina(),
                      ),
                    );
                    return;
                  }
                },
          child: SizedBox(
            height: compact ? 42 : 40,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 8 : 10,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: bezig
                            ? _tekstGrijs
                            : actief
                                ? _oranje
                                : _antraciet,
                        fontSize: compact ? 11.5 : 13,
                        height: 1.1,
                        fontWeight:
                            actief ? FontWeight.w700 : FontWeight.w500,
                        decoration:
                            actief ? TextDecoration.underline : null,
                        decorationColor: _oranje,
                        decorationThickness: 2,
                        decorationStyle: TextDecorationStyle.solid,
                      ),
                    ),
                  ),
                  if (toonMeldingsBol) ...<Widget>[
                    const SizedBox(width: 8),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: _meldingRood,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                  if (bezig) ...<Widget>[
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.8,
                        color: _oranje,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
