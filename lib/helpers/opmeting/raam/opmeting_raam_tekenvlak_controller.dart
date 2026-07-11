import 'package:flutter/foundation.dart';

class OpmetingRaamTekenvlakController extends ChangeNotifier {
  Object? _eigenaar;

  VoidCallback? _ongedaanMakenActie;
  VoidCallback? _herstellenActie;

  bool _kanOngedaanMaken = false;
  bool _kanHerstellen = false;

  bool get kanOngedaanMaken => _kanOngedaanMaken;

  bool get kanHerstellen => _kanHerstellen;

  void ongedaanMaken() {
    if (!_kanOngedaanMaken) {
      return;
    }

    _ongedaanMakenActie?.call();
  }

  void herstellen() {
    if (!_kanHerstellen) {
      return;
    }

    _herstellenActie?.call();
  }

  void koppel({
    required Object eigenaar,
    required VoidCallback onOngedaanMaken,
    required VoidCallback onHerstellen,
    required bool kanOngedaanMaken,
    required bool kanHerstellen,
  }) {
    _eigenaar = eigenaar;
    _ongedaanMakenActie = onOngedaanMaken;
    _herstellenActie = onHerstellen;

    _pasStatusAan(
      kanOngedaanMaken: kanOngedaanMaken,
      kanHerstellen: kanHerstellen,
    );
  }

  void werkStatusBij({
    required Object eigenaar,
    required bool kanOngedaanMaken,
    required bool kanHerstellen,
  }) {
    if (!identical(_eigenaar, eigenaar)) {
      return;
    }

    _pasStatusAan(
      kanOngedaanMaken: kanOngedaanMaken,
      kanHerstellen: kanHerstellen,
    );
  }

  void ontkoppel({required Object eigenaar}) {
    if (!identical(_eigenaar, eigenaar)) {
      return;
    }

    _eigenaar = null;
    _ongedaanMakenActie = null;
    _herstellenActie = null;

    _pasStatusAan(kanOngedaanMaken: false, kanHerstellen: false);
  }

  void _pasStatusAan({
    required bool kanOngedaanMaken,
    required bool kanHerstellen,
  }) {
    if (_kanOngedaanMaken == kanOngedaanMaken &&
        _kanHerstellen == kanHerstellen) {
      return;
    }

    _kanOngedaanMaken = kanOngedaanMaken;
    _kanHerstellen = kanHerstellen;

    notifyListeners();
  }
}
