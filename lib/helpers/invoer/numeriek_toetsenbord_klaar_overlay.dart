// THIMACO-CONTROLE: NUMERIEK-INVOERVELD-ALTIJD-ZICHTBAAR-20260813
// THIMACO-CONTROLE: NUMERIEK-KLAAR-VASTE-TOETSENBORDBALK-20260813
// THIMACO-CONTROLE: NUMERIEK-TOETSENBORD-KLAAR-IOS-20260812
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Voegt op iOS/iPadOS centraal een duidelijke 'Klaar'-actie toe wanneer een
/// invoerveld een toetsenbord zonder eigen bevestigingstoets gebruikt.
///
/// Dit voorkomt dat ieder numeriek veld afzonderlijk een eigen workaround
/// nodig heeft. Number-, decimal-, phone- en datetime-keyboards vallen onder
/// dezelfde afhandeling.
class NumeriekToetsenbordKlaarOverlay extends StatefulWidget {
  const NumeriekToetsenbordKlaarOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<NumeriekToetsenbordKlaarOverlay> createState() =>
      _NumeriekToetsenbordKlaarOverlayState();
}

class _NumeriekToetsenbordKlaarOverlayState
    extends State<NumeriekToetsenbordKlaarOverlay>
    with WidgetsBindingObserver {
  static const Color _groen = Color(0xFF0B7A3B);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FocusManager.instance.addListener(_planVernieuwing);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_planVernieuwing);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _planVernieuwing();
  }

  void _planVernieuwing() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      setState(() {});

      // Wacht nog één frame zodat iPadOS de definitieve toetsenbordhoogte en
      // Flutter de nieuwe beschikbare schermruimte volledig hebben verwerkt.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _zorgDatActiefInvoerveldZichtbaarIs();
        }
      });
    });
  }

  void _zorgDatActiefInvoerveldZichtbaarIs() {
    final invoerveld = _actiefInvoerveld();
    if (invoerveld == null) return;

    final toetsenbordHoogte = MediaQuery.viewInsetsOf(context).bottom;
    if (toetsenbordHoogte <= 0) return;

    final keyboardType = invoerveld.widget.keyboardType;
    if (!_isToetsenbordZonderKlaarToets(keyboardType)) return;

    // Plaats het actieve invoerveld bewust hoger dan enkel "net zichtbaar".
    // Daardoor blijft het ook vrij van de vaste Klaar-balk boven het toetsenbord.
    Scrollable.ensureVisible(
      invoerveld.context,
      alignment: 0.35,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  EditableTextState? _actiefInvoerveld() {
    final focusContext = FocusManager.instance.primaryFocus?.context;
    if (focusContext == null) return null;

    if (focusContext is StatefulElement &&
        focusContext.state is EditableTextState) {
      return focusContext.state as EditableTextState;
    }

    return focusContext.findAncestorStateOfType<EditableTextState>();
  }

  bool _isToetsenbordZonderKlaarToets(TextInputType? type) {
    if (type == null) return false;
    return type.index == TextInputType.number.index ||
        type.index == TextInputType.phone.index ||
        type.index == TextInputType.datetime.index;
  }

  void _bevestigEnSluitToetsenbord() {
    final focus = FocusManager.instance.primaryFocus;
    final invoerveld = _actiefInvoerveld();

    if (invoerveld != null) {
      final onEditingComplete = invoerveld.widget.onEditingComplete;
      if (onEditingComplete != null) {
        onEditingComplete();
      } else {
        focus?.unfocus();
      }

      invoerveld.widget.onSubmitted?.call(invoerveld.widget.controller.text);

      // Alleen de oorspronkelijke focus loslaten. Als een specifieke callback
      // zelf al naar een volgend veld sprong, laten we die nieuwe focus staan.
      if (focus?.hasFocus == true) {
        focus?.unfocus();
      }
    } else {
      focus?.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoerveld = _actiefInvoerveld();
    final toonKlaar =
        defaultTargetPlatform == TargetPlatform.iOS &&
        _isToetsenbordZonderKlaarToets(invoerveld?.widget.keyboardType);

    if (!toonKlaar) {
      return widget.child;
    }

    final mediaQuery = MediaQuery.of(context);
    final toetsenbordHoogte = mediaQuery.viewInsets.bottom;

    // Toon de balk uitsluitend wanneer het systeemtoetsenbord effectief open is.
    // Zo kan de actie nooit los bovenaan of ergens zwevend in het scherm staan.
    if (toetsenbordHoogte <= 0) {
      return widget.child;
    }

    final toetsenbordBalk = Material(
      color: const Color(0xFFF8FAF9),
      elevation: 6,
      child: Container(
        height: 44,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFFE5E7EB)),
            bottom: BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
        child: Row(
          children: <Widget>[
            const Spacer(),
            InkWell(
              onTap: _bevestigEnSluitToetsenbord,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.check_rounded, color: _groen, size: 20),
                    SizedBox(width: 6),
                    Text(
                      'Klaar',
                      style: TextStyle(
                        color: _groen,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        widget.child,
        Positioned(
          left: 0,
          right: 0,
          bottom: toetsenbordHoogte,
          child: toetsenbordBalk,
        ),
      ],
    );
  }
}
