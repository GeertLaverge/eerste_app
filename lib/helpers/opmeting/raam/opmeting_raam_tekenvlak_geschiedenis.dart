import 'opmeting_raam_kleinhout_model.dart';
import 'opmeting_raam_model.dart';
import 'opmeting_raam_opvulling_model.dart';

class OpmetingRaamTekeningMoment {
  const OpmetingRaamTekeningMoment({
    required this.tStijlen,
    required this.vleugels,
    required this.vullingToewijzingen,
    required this.kleinhouten,
  });

  final List<OpmetingRaamTStijl> tStijlen;
  final List<OpmetingRaamVleugel> vleugels;

  final List<OpmetingRaamVullingToewijzing> vullingToewijzingen;

  final List<OpmetingRaamKleinhout> kleinhouten;
}

class OpmetingRaamTekenvlakGeschiedenis {
  OpmetingRaamTekenvlakGeschiedenis({this.maximumAantalStappen = 50});

  final int maximumAantalStappen;

  final List<OpmetingRaamTekeningMoment> _ongedaanGeschiedenis =
      <OpmetingRaamTekeningMoment>[];

  final List<OpmetingRaamTekeningMoment> _herstelGeschiedenis =
      <OpmetingRaamTekeningMoment>[];

  bool get kanOngedaanMaken {
    return _ongedaanGeschiedenis.isNotEmpty;
  }

  bool get kanHerstellen {
    return _herstelGeschiedenis.isNotEmpty;
  }

  bool get heeftGeschiedenis {
    return _ongedaanGeschiedenis.isNotEmpty || _herstelGeschiedenis.isNotEmpty;
  }

  void bewaarVoorWijziging(OpmetingRaamTekeningMoment huidigMoment) {
    _ongedaanGeschiedenis.add(huidigMoment);

    if (_ongedaanGeschiedenis.length > maximumAantalStappen) {
      _ongedaanGeschiedenis.removeAt(0);
    }

    _herstelGeschiedenis.clear();
  }

  OpmetingRaamTekeningMoment? ongedaanMaken({
    required OpmetingRaamTekeningMoment huidigMoment,
  }) {
    if (_ongedaanGeschiedenis.isEmpty) {
      return null;
    }

    final vorigMoment = _ongedaanGeschiedenis.removeLast();

    _herstelGeschiedenis.add(huidigMoment);

    return vorigMoment;
  }

  OpmetingRaamTekeningMoment? herstellen({
    required OpmetingRaamTekeningMoment huidigMoment,
  }) {
    if (_herstelGeschiedenis.isEmpty) {
      return null;
    }

    final volgendMoment = _herstelGeschiedenis.removeLast();

    _ongedaanGeschiedenis.add(huidigMoment);

    if (_ongedaanGeschiedenis.length > maximumAantalStappen) {
      _ongedaanGeschiedenis.removeAt(0);
    }

    return volgendMoment;
  }

  void wis() {
    _ongedaanGeschiedenis.clear();
    _herstelGeschiedenis.clear();
  }
}
