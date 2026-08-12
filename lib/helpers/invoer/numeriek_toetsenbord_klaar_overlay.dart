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
      if (mounted) {
        setState(() {});
      }
    });
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
    final veiligeBovenkant = mediaQuery.padding.top;

    final knop = Material(
      color: _groen,
      elevation: 5,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _bevestigEnSluitToetsenbord,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.check_rounded, color: Colors.white, size: 19),
              SizedBox(width: 6),
              Text(
                'Klaar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        widget.child,
        if (toetsenbordHoogte > 0)
          Positioned(right: 14, bottom: toetsenbordHoogte + 8, child: knop)
        else
          Positioned(right: 14, top: veiligeBovenkant + 10, child: knop),
      ],
    );
  }
}
