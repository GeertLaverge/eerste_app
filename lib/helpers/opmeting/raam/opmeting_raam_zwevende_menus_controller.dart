import 'package:flutter/material.dart';

class OpmetingRaamZwevendeMenusController {
  static const Set<String> _geldigeMenuIds = <String>{
    'vleugel',
    'tstijl',
    'opvulling',
    'kleinhout',
  };

  final OverlayPortalController overlayController = OverlayPortalController();

  final GlobalKey tStijlMenuKey = GlobalKey();
  final GlobalKey opvullingMenuKey = GlobalKey();
  final GlobalKey kleinhoutMenuKey = GlobalKey();

  Offset _vleugelMenuPositie = const Offset(-1, -1);
  Offset _tStijlMenuPositie = const Offset(-1, -1);
  Offset _opvullingMenuPositie = const Offset(-1, -1);
  Offset _kleinhoutMenuPositie = const Offset(-1, -1);

  String? _actiefSleepMenuId;
  Offset? _sleepStartCursor;
  Offset? _sleepStartMenuPositie;

  Offset get vleugelMenuPositie {
    return _vleugelMenuPositie;
  }

  Offset get tStijlMenuPositie {
    return _tStijlMenuPositie;
  }

  Offset get opvullingMenuPositie {
    return _opvullingMenuPositie;
  }

  Offset get kleinhoutMenuPositie {
    return _kleinhoutMenuPositie;
  }

  void toonOverlay() {
    overlayController.show();
  }

  Size meetMenuGrootte({
    required GlobalKey menuKey,
    required double standaardBreedte,
    required double standaardHoogte,
  }) {
    final menuContext = menuKey.currentContext;
    final renderObject = menuContext?.findRenderObject();

    if (renderObject is RenderBox && renderObject.hasSize) {
      final gemetenGrootte = renderObject.size;

      if (gemetenGrootte.width > 0 &&
          gemetenGrootte.height > 0 &&
          gemetenGrootte.width.isFinite &&
          gemetenGrootte.height.isFinite) {
        return gemetenGrootte;
      }
    }

    return Size(standaardBreedte, standaardHoogte);
  }

  Offset effectieveMenuPositie({
    required BuildContext overlayContext,
    required Offset opgeslagenPositie,
    required Size schermGrootte,
    required Size menuGrootte,
  }) {
    final positieIsIngesteld =
        opgeslagenPositie.dx >= 0 && opgeslagenPositie.dy >= 0;

    final padding = MediaQuery.paddingOf(overlayContext);

    final standaardPositie = Offset(
      schermGrootte.width - padding.right - menuGrootte.width - 12,
      padding.top + kToolbarHeight + 12,
    );

    return _begrensMenuOpScherm(
      overlayContext: overlayContext,
      positie: positieIsIngesteld ? opgeslagenPositie : standaardPositie,
      schermGrootte: schermGrootte,
      menuGrootte: menuGrootte,
    );
  }

  void startMenuSleep({
    required String menuId,
    required Offset globaleCursorPositie,
    required Offset huidigeMenuPositie,
  }) {
    if (!_geldigeMenuIds.contains(menuId)) {
      return;
    }

    _actiefSleepMenuId = menuId;
    _sleepStartCursor = globaleCursorPositie;
    _sleepStartMenuPositie = huidigeMenuPositie;
  }

  void stopMenuSleep(String menuId) {
    if (_actiefSleepMenuId != menuId) {
      return;
    }

    _actiefSleepMenuId = null;
    _sleepStartCursor = null;
    _sleepStartMenuPositie = null;
  }

  bool verplaatsMenu({
    required String menuId,
    required DragUpdateDetails details,
    required BuildContext overlayContext,
    required Size schermGrootte,
    required Size menuGrootte,
  }) {
    final nieuwePositie = _berekenMenuPositieTijdensSleep(
      menuId: menuId,
      globaleCursorPositie: details.globalPosition,
      overlayContext: overlayContext,
      schermGrootte: schermGrootte,
      menuGrootte: menuGrootte,
    );

    if (nieuwePositie == null) {
      return false;
    }

    return _bewaarMenuPositie(menuId: menuId, positie: nieuwePositie);
  }

  Offset? _berekenMenuPositieTijdensSleep({
    required String menuId,
    required Offset globaleCursorPositie,
    required BuildContext overlayContext,
    required Size schermGrootte,
    required Size menuGrootte,
  }) {
    if (_actiefSleepMenuId != menuId) {
      return null;
    }

    final startCursor = _sleepStartCursor;
    final startMenuPositie = _sleepStartMenuPositie;

    if (startCursor == null || startMenuPositie == null) {
      return null;
    }

    final totaleCursorVerplaatsing = globaleCursorPositie - startCursor;

    final onbeperkteMenuPositie = Offset(
      startMenuPositie.dx + totaleCursorVerplaatsing.dx,
      startMenuPositie.dy + totaleCursorVerplaatsing.dy,
    );

    return _begrensMenuOpScherm(
      overlayContext: overlayContext,
      positie: onbeperkteMenuPositie,
      schermGrootte: schermGrootte,
      menuGrootte: menuGrootte,
    );
  }

  Offset _begrensMenuOpScherm({
    required BuildContext overlayContext,
    required Offset positie,
    required Size schermGrootte,
    required Size menuGrootte,
  }) {
    final padding = MediaQuery.paddingOf(overlayContext);

    const marge = 8.0;

    final minimaleX = padding.left + marge;

    final minimaleY = padding.top + kToolbarHeight + marge;

    final berekendeMaximaleX =
        schermGrootte.width - padding.right - menuGrootte.width - marge;

    final berekendeMaximaleY =
        schermGrootte.height - padding.bottom - menuGrootte.height - marge;

    final maximaleX = berekendeMaximaleX < minimaleX
        ? minimaleX
        : berekendeMaximaleX;

    final maximaleY = berekendeMaximaleY < minimaleY
        ? minimaleY
        : berekendeMaximaleY;

    return Offset(
      positie.dx.clamp(minimaleX, maximaleX).toDouble(),
      positie.dy.clamp(minimaleY, maximaleY).toDouble(),
    );
  }

  bool _bewaarMenuPositie({required String menuId, required Offset positie}) {
    switch (menuId) {
      case 'vleugel':
        if (_vleugelMenuPositie == positie) {
          return false;
        }

        _vleugelMenuPositie = positie;
        return true;

      case 'tstijl':
        if (_tStijlMenuPositie == positie) {
          return false;
        }

        _tStijlMenuPositie = positie;
        return true;

      case 'opvulling':
        if (_opvullingMenuPositie == positie) {
          return false;
        }

        _opvullingMenuPositie = positie;
        return true;

      case 'kleinhout':
        if (_kleinhoutMenuPositie == positie) {
          return false;
        }

        _kleinhoutMenuPositie = positie;
        return true;

      default:
        return false;
    }
  }
}
