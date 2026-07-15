import '../raam/opmeting_raam_model.dart';
import 'opmeting_deurpaneel_model.dart';
import 'opmeting_deurpaneel_toewijzing_model.dart';

class OpmetingDeurpaneelActieResultaat {
  const OpmetingDeurpaneelActieResultaat({
    required this.toewijzingen,
    required this.melding,
    this.gelukt = true,
  });

  final List<OpmetingDeurpaneelToewijzing> toewijzingen;
  final String melding;
  final bool gelukt;
}

class OpmetingDeurpaneelActieHelper {
  const OpmetingDeurpaneelActieHelper._();

  static OpmetingDeurpaneelActieResultaat plaatsOfVervang({
    required OpmetingRaamVleugel deurVleugel,
    required OpmetingDeurpaneelKeuze keuze,
    required List<OpmetingDeurpaneelToewijzing> huidigeToewijzingen,
  }) {
    if (keuze.wissen) {
      return verwijderVoorVleugel(
        deurVleugel: deurVleugel,
        huidigeToewijzingen: huidigeToewijzingen,
      );
    }

    final nieuweToewijzing = OpmetingDeurpaneelToewijzing.vanKeuze(
      deurVleugelId: deurVleugel.id,
      keuze: keuze,
    );

    final nieuweLijst = <OpmetingDeurpaneelToewijzing>[];

    for (final toewijzing in huidigeToewijzingen) {
      if (toewijzing.deurVleugelId == deurVleugel.id) {
        continue;
      }

      nieuweLijst.add(toewijzing);
    }

    nieuweLijst.add(nieuweToewijzing);

    return OpmetingDeurpaneelActieResultaat(
      toewijzingen: List<OpmetingDeurpaneelToewijzing>.unmodifiable(
        nieuweLijst,
      ),
      melding:
          '${keuze.paneel.naam} (${keuze.paneel.id}) geplaatst op deurvleugel.',
    );
  }

  static OpmetingDeurpaneelActieResultaat verwijderVoorVleugel({
    required OpmetingRaamVleugel deurVleugel,
    required List<OpmetingDeurpaneelToewijzing> huidigeToewijzingen,
  }) {
    final nieuweLijst = huidigeToewijzingen
        .where((toewijzing) {
          return toewijzing.deurVleugelId != deurVleugel.id;
        })
        .toList(growable: false);

    if (nieuweLijst.length == huidigeToewijzingen.length) {
      return OpmetingDeurpaneelActieResultaat(
        toewijzingen: List<OpmetingDeurpaneelToewijzing>.unmodifiable(
          huidigeToewijzingen,
        ),
        melding: 'Er stond geen deurpaneel op deze deurvleugel.',
      );
    }

    return OpmetingDeurpaneelActieResultaat(
      toewijzingen: List<OpmetingDeurpaneelToewijzing>.unmodifiable(
        nieuweLijst,
      ),
      melding: 'Deurpaneel verwijderd van deurvleugel.',
    );
  }
}
