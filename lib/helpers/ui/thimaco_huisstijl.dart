// THIMACO-CONTROLE: SUBMENU-SELECTIESTIJL-FASE2-20260914
import 'package:flutter/material.dart';

/// Centrale visuele basis voor de nieuwe Thimaco-programmastijl.
///
/// Houdt huisstijl en interactie op één plaats zodat schermen niet elk hun
/// eigen knop-/kleurvarianten gaan bouwen.
abstract final class ThimacoKleuren {
  static const Color oranje = Color(0xFFF15A24);
  static const Color oranjeLicht = Color(0xFFFFF3EC);
  static const Color oranjeRand = Color(0xFFFFD0B8);
  static const Color antraciet = Color(0xFF22272D);
  static const Color tekstGrijs = Color(0xFF6B7280);
  static const Color rand = Color(0xFFE2E5E8);
  static const Color achtergrond = Color(0xFFF7F8F9);
  static const Color rood = Color(0xFFDC2626);
}


/// Compacte sectietitel voor de rustige programmastijl.
///
/// De titel zelf blijft antraciet. Oranje wordt alleen gebruikt als korte
/// subtiele accentlijn, zodat de interface niet opnieuw te kleurrijk wordt.
class ThimacoSectieTitel extends StatelessWidget {
  const ThimacoSectieTitel({
    super.key,
    required this.tekst,
    this.compact = true,
  });

  final String tekst;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          tekst,
          style: TextStyle(
            color: ThimacoKleuren.antraciet,
            fontSize: compact ? 11.5 : 15,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        SizedBox(height: compact ? 3 : 5),
        Container(
          width: compact ? 28 : 38,
          height: compact ? 1.5 : 2,
          decoration: BoxDecoration(
            color: ThimacoKleuren.oranje.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ],
    );
  }
}


/// Permanente tekstkeuze voor submenu's.
///
/// Geen knopvlak: de gekozen waarde krijgt alleen een rustige oranje accentlijn.
/// Zo blijft een rij met keuzes visueel licht, ook wanneer er veel opties zijn.
class ThimacoTekstKeuze extends StatefulWidget {
  const ThimacoTekstKeuze({
    super.key,
    required this.tekst,
    required this.geselecteerd,
    required this.onPressed,
    this.subtekst,
    this.compact = true,
    this.uitvullen = false,
  });

  final String tekst;
  final bool geselecteerd;
  final VoidCallback? onPressed;
  final String? subtekst;
  final bool compact;
  final bool uitvullen;

  @override
  State<ThimacoTekstKeuze> createState() => _ThimacoTekstKeuzeState();
}

class _ThimacoTekstKeuzeState extends State<ThimacoTekstKeuze> {
  bool _hover = false;
  bool _focus = false;

  bool get _actief => widget.onPressed != null;
  bool get _accent => widget.geselecteerd || (_actief && (_hover || _focus));

  @override
  Widget build(BuildContext context) {
    final inhoud = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.compact ? 5 : 7,
        vertical: widget.compact ? 4 : 6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  widget.tekst,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: !_actief
                        ? ThimacoKleuren.tekstGrijs.withValues(alpha: 0.45)
                        : ThimacoKleuren.antraciet,
                    fontSize: widget.compact ? 11.5 : 12.5,
                    height: 1.12,
                    fontWeight: widget.geselecteerd
                        ? FontWeight.w900
                        : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  curve: Curves.easeOut,
                  height: 2,
                  decoration: BoxDecoration(
                    color: _accent
                        ? ThimacoKleuren.oranje.withValues(
                            alpha: widget.geselecteerd ? 1 : 0.55,
                          )
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ],
            ),
          ),
          if ((widget.subtekst ?? '').trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              widget.subtekst!.trim(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _actief
                    ? ThimacoKleuren.tekstGrijs
                    : ThimacoKleuren.tekstGrijs.withValues(alpha: 0.42),
                fontSize: widget.compact ? 9.5 : 10.5,
                height: 1.18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );

    return MouseRegion(
      cursor: _actief ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (_actief && !_hover) setState(() => _hover = true);
      },
      onExit: (_) {
        if (_hover) setState(() => _hover = false);
      },
      child: FocusableActionDetector(
        enabled: _actief,
        onShowFocusHighlight: (waarde) {
          if (_focus != waarde) setState(() => _focus = waarde);
        },
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(5),
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          splashColor: ThimacoKleuren.oranje.withValues(alpha: 0.07),
          highlightColor: Colors.transparent,
          child: widget.uitvullen
              ? SizedBox(width: double.infinity, child: inhoud)
              : inhoud,
        ),
      ),
    );
  }
}

/// Witte visuele selectietegel voor vleugels, panelen en samenstellingen.
///
/// Selectie wordt uitsluitend aangeduid met een oranje rand en optioneel een
/// oranje vinkje; de achtergrond blijft altijd wit.
class ThimacoSelectieTegel extends StatefulWidget {
  const ThimacoSelectieTegel({
    super.key,
    required this.geselecteerd,
    required this.onTap,
    required this.child,
    this.padding = const EdgeInsets.all(8),
    this.radius = 8,
    this.toonVinkje = true,
    this.enabled = true,
  });

  final bool geselecteerd;
  final VoidCallback? onTap;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool toonVinkje;
  final bool enabled;

  @override
  State<ThimacoSelectieTegel> createState() => _ThimacoSelectieTegelState();
}

class _ThimacoSelectieTegelState extends State<ThimacoSelectieTegel> {
  bool _hover = false;

  bool get _actief => widget.enabled && widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    final randKleur = widget.geselecteerd
        ? ThimacoKleuren.oranje
        : _hover && _actief
        ? ThimacoKleuren.oranjeRand
        : ThimacoKleuren.rand;

    return MouseRegion(
      cursor: _actief ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (_actief && !_hover) setState(() => _hover = true);
      },
      onExit: (_) {
        if (_hover) setState(() => _hover = false);
      },
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(widget.radius),
        child: InkWell(
          onTap: _actief ? widget.onTap : null,
          borderRadius: BorderRadius.circular(widget.radius),
          splashColor: ThimacoKleuren.oranje.withValues(alpha: 0.06),
          hoverColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            padding: widget.padding,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(widget.radius),
              border: Border.all(
                color: randKleur,
                width: widget.geselecteerd ? 1.6 : 1,
              ),
            ),
            child: Stack(
              children: <Widget>[
                widget.child,
                if (widget.geselecteerd && widget.toonVinkje)
                  const Positioned(
                    right: 0,
                    top: 0,
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: ThimacoKleuren.oranje,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Rustige programma-actie: geen knopvlak of kader, alleen tekst met een
/// subtiele lijn eronder. Hover/focus maakt de actie duidelijker zonder de
/// werkruimte visueel druk te maken.
class ThimacoTekstActie extends StatefulWidget {
  const ThimacoTekstActie({
    super.key,
    required this.tekst,
    required this.onPressed,
    this.destructief = false,
    this.compact = true,
  });

  final String tekst;
  final VoidCallback? onPressed;
  final bool destructief;
  final bool compact;

  @override
  State<ThimacoTekstActie> createState() => _ThimacoTekstActieState();
}

class _ThimacoTekstActieState extends State<ThimacoTekstActie> {
  bool _hover = false;
  bool _focus = false;

  bool get _actief => widget.onPressed != null;
  bool get _accentActief => _actief && (_hover || _focus);

  Color get _basisKleur {
    if (!_actief) return ThimacoKleuren.tekstGrijs.withValues(alpha: 0.45);
    if (widget.destructief) return ThimacoKleuren.rood;
    return _accentActief
        ? ThimacoKleuren.oranje
        : ThimacoKleuren.antraciet;
  }

  Color get _lijnKleur {
    if (!_actief) return Colors.transparent;
    final kleur = widget.destructief
        ? ThimacoKleuren.rood
        : ThimacoKleuren.oranje;
    return kleur.withValues(alpha: _accentActief ? 1 : 0.62);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: _actief ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (_actief && !_hover) setState(() => _hover = true);
      },
      onExit: (_) {
        if (_hover) setState(() => _hover = false);
      },
      child: FocusableActionDetector(
        enabled: _actief,
        mouseCursor: _actief ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onShowFocusHighlight: (waarde) {
          if (_focus != waarde) setState(() => _focus = waarde);
        },
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(4),
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          splashColor: ThimacoKleuren.oranje.withValues(alpha: 0.08),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.compact ? 5 : 7,
              vertical: widget.compact ? 4 : 6,
            ),
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeOut,
                    style: TextStyle(
                      color: _basisKleur,
                      fontSize: widget.compact ? 12 : 13,
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                    ),
                    child: Text(widget.tekst),
                  ),
                  const SizedBox(height: 3),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeOut,
                    height: _accentActief ? 2 : 1.5,
                    decoration: BoxDecoration(
                      color: _lijnKleur,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Compacte icoonactie in dezelfde rustige programmastijl.
///
/// Icoontjes zijn standaard antraciet, net als gewone tekst. Oranje verschijnt
/// alleen subtiel bij hover/focus. Destructieve acties blijven rood.
class ThimacoIcoonActie extends StatefulWidget {
  const ThimacoIcoonActie({
    super.key,
    required this.icoon,
    required this.onPressed,
    this.tooltip,
    this.destructief = false,
    this.grootte = 18,
  });

  final IconData icoon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool destructief;
  final double grootte;

  @override
  State<ThimacoIcoonActie> createState() => _ThimacoIcoonActieState();
}

class _ThimacoIcoonActieState extends State<ThimacoIcoonActie> {
  bool _hover = false;
  bool _focus = false;

  bool get _actief => widget.onPressed != null;

  Color get _kleur {
    if (!_actief) return ThimacoKleuren.tekstGrijs.withValues(alpha: 0.35);
    if (widget.destructief) return ThimacoKleuren.rood;
    if (_hover || _focus) return ThimacoKleuren.oranje;
    return ThimacoKleuren.antraciet;
  }

  @override
  Widget build(BuildContext context) {
    final knop = MouseRegion(
      cursor: _actief ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (_actief && !_hover) setState(() => _hover = true);
      },
      onExit: (_) {
        if (_hover) setState(() => _hover = false);
      },
      child: FocusableActionDetector(
        enabled: _actief,
        onShowFocusHighlight: (waarde) {
          if (_focus != waarde) setState(() => _focus = waarde);
        },
        child: IconButton(
          onPressed: widget.onPressed,
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          style: IconButton.styleFrom(
            foregroundColor: _kleur,
            hoverColor: Colors.transparent,
            focusColor: ThimacoKleuren.oranje.withValues(alpha: 0.07),
            highlightColor: ThimacoKleuren.oranje.withValues(alpha: 0.07),
          ),
          icon: Icon(widget.icoon, size: widget.grootte),
        ),
      ),
    );

    final tooltip = widget.tooltip?.trim() ?? '';
    if (tooltip.isEmpty) return knop;
    return Tooltip(message: tooltip, child: knop);
  }
}
