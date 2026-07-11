import 'dart:async';
import 'dart:ui';

class OpmetingRaamSchaalWijziging {
  const OpmetingRaamSchaalWijziging({
    required this.oudeTekenvlakGrootte,
    required this.nieuweTekenvlakGrootte,
    required this.oudeBreedteMm,
    required this.oudeHoogteMm,
    required this.nieuweBreedteMm,
    required this.nieuweHoogteMm,
  });

  final Size oudeTekenvlakGrootte;
  final Size nieuweTekenvlakGrootte;

  final int oudeBreedteMm;
  final int oudeHoogteMm;

  final int nieuweBreedteMm;
  final int nieuweHoogteMm;
}

class OpmetingRaamSchaalController {
  Timer? _timer;

  int _huidigeBreedteMm = 0;
  int _huidigeHoogteMm = 0;

  int _laatsteGeldigeBreedteMm = 0;
  int _laatsteGeldigeHoogteMm = 0;

  Size _laatsteTekenvlakGrootte = Size.zero;
  Size _zichtbareTekenvlakGrootte = Size.zero;

  Size? get actueleTekenvlakGrootte {
    if (!_isGeldigeTekenvlakGrootte(_laatsteTekenvlakGrootte)) {
      return null;
    }

    return _laatsteTekenvlakGrootte;
  }

  OpmetingRaamSchaalWijziging? get huidigeWijziging {
    if (!_volledigeSchaalAanpassingNodig) {
      return null;
    }

    return OpmetingRaamSchaalWijziging(
      oudeTekenvlakGrootte: _laatsteTekenvlakGrootte,
      nieuweTekenvlakGrootte: _zichtbareTekenvlakGrootte,
      oudeBreedteMm: _laatsteGeldigeBreedteMm,
      oudeHoogteMm: _laatsteGeldigeHoogteMm,
      nieuweBreedteMm: _huidigeBreedteMm,
      nieuweHoogteMm: _huidigeHoogteMm,
    );
  }

  void initialiseer({required int breedteMm, required int hoogteMm}) {
    _huidigeBreedteMm = breedteMm;
    _huidigeHoogteMm = hoogteMm;

    if (breedteMm > 0 && hoogteMm > 0) {
      _laatsteGeldigeBreedteMm = breedteMm;
      _laatsteGeldigeHoogteMm = hoogteMm;
    }
  }

  void werkMatenBij({
    required int breedteMm,
    required int hoogteMm,
    required void Function() onAanpassen,
  }) {
    _huidigeBreedteMm = breedteMm;
    _huidigeHoogteMm = hoogteMm;

    if (_volledigeSchaalAanpassingNodig) {
      _planAanpassing(onAanpassen);
    }
  }

  void registreerTekenvlakGrootte({
    required Size size,
    required int breedteMm,
    required int hoogteMm,
    required void Function() onAanpassen,
  }) {
    if (!_isGeldigeTekenvlakGrootte(size)) {
      return;
    }

    _huidigeBreedteMm = breedteMm;
    _huidigeHoogteMm = hoogteMm;
    _zichtbareTekenvlakGrootte = size;

    if (!_isGeldigeTekenvlakGrootte(_laatsteTekenvlakGrootte)) {
      _laatsteTekenvlakGrootte = size;

      if (breedteMm > 0 && hoogteMm > 0) {
        _laatsteGeldigeBreedteMm = breedteMm;
        _laatsteGeldigeHoogteMm = hoogteMm;
      }

      return;
    }

    if (_volledigeSchaalAanpassingNodig) {
      _planAanpassing(onAanpassen);
    }
  }

  void bevestigWijziging(OpmetingRaamSchaalWijziging wijziging) {
    _laatsteTekenvlakGrootte = wijziging.nieuweTekenvlakGrootte;
    _zichtbareTekenvlakGrootte = wijziging.nieuweTekenvlakGrootte;

    _laatsteGeldigeBreedteMm = wijziging.nieuweBreedteMm;
    _laatsteGeldigeHoogteMm = wijziging.nieuweHoogteMm;

    _huidigeBreedteMm = wijziging.nieuweBreedteMm;
    _huidigeHoogteMm = wijziging.nieuweHoogteMm;
  }

  bool get _volledigeSchaalAanpassingNodig {
    if (!_isGeldigeTekenvlakGrootte(_laatsteTekenvlakGrootte) ||
        !_isGeldigeTekenvlakGrootte(_zichtbareTekenvlakGrootte)) {
      return false;
    }

    if (_huidigeBreedteMm <= 0 || _huidigeHoogteMm <= 0) {
      return false;
    }

    final maatGewijzigd =
        _laatsteGeldigeBreedteMm != _huidigeBreedteMm ||
        _laatsteGeldigeHoogteMm != _huidigeHoogteMm;

    final tekenvlakGewijzigd = !_zelfdeTekenvlakGrootte(
      _laatsteTekenvlakGrootte,
      _zichtbareTekenvlakGrootte,
    );

    return maatGewijzigd || tekenvlakGewijzigd;
  }

  void _planAanpassing(void Function() onAanpassen) {
    _timer?.cancel();

    _timer = Timer(const Duration(milliseconds: 350), onAanpassen);
  }

  bool _zelfdeTekenvlakGrootte(Size eerste, Size tweede) {
    const tolerantie = 0.5;

    return (eerste.width - tweede.width).abs() <= tolerantie &&
        (eerste.height - tweede.height).abs() <= tolerantie;
  }

  bool _isGeldigeTekenvlakGrootte(Size size) {
    return size.width > 0 &&
        size.height > 0 &&
        size.width.isFinite &&
        size.height.isFinite;
  }

  void dispose() {
    _timer?.cancel();
  }
}
