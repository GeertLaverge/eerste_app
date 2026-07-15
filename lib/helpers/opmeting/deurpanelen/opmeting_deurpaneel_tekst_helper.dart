import 'opmeting_deurpaneel_model.dart';
import 'opmeting_deurpaneel_toewijzing_model.dart';

class OpmetingDeurpaneelTekstHelper {
  const OpmetingDeurpaneelTekstHelper._();

  static String samenvattingVoorKeuze(OpmetingDeurpaneelKeuze keuze) {
    if (keuze.wissen) {
      return 'Deurpaneel wissen';
    }

    return _bouwDeurpaneelRegel(
      paneelNaam: keuze.paneel.naam,
      paneelId: keuze.paneel.id,
      uitvoeringLabel: keuze.uitvoering.label,
      cilinderZijde: keuze.paneel.cilinderZijde,
    );
  }

  static String samenvattingVoorToewijzingen(
    List<OpmetingDeurpaneelToewijzing> toewijzingen,
  ) {
    if (toewijzingen.isEmpty) {
      return '';
    }

    final gesorteerd = List<OpmetingDeurpaneelToewijzing>.from(toewijzingen)
      ..sort((eerste, tweede) {
        return eerste.deurVleugelId.compareTo(tweede.deurVleugelId);
      });

    return gesorteerd.map(_samenvattingVoorToewijzing).join('\n');
  }

  static String _samenvattingVoorToewijzing(
    OpmetingDeurpaneelToewijzing toewijzing,
  ) {
    return _bouwDeurpaneelRegel(
      paneelNaam: toewijzing.paneelNaam,
      paneelId: toewijzing.paneelId,
      uitvoeringLabel: toewijzing.uitvoering.label,
      cilinderZijde: toewijzing.cilinderZijde,
    );
  }

  static String _bouwDeurpaneelRegel({
    required String paneelNaam,
    required String paneelId,
    required String uitvoeringLabel,
    required OpmetingDeurpaneelCilinderZijde cilinderZijde,
  }) {
    final delen = <String>[
      'Deurpaneel ${_normaliseerNaam(paneelNaam)}',
      paneelId.trim(),
      uitvoeringLabel.trim(),
    ].where((deel) => deel.trim().isNotEmpty).toList();

    if (cilinderZijde != OpmetingDeurpaneelCilinderZijde.geen) {
      delen.add('cilinder krukzijde');
    }

    return delen.join(' - ');
  }

  static String _normaliseerNaam(String naam) {
    final tekst = naam.trim();

    if (tekst.isEmpty) {
      return 'onbekend';
    }

    if (tekst.length <= 1) {
      return tekst.toUpperCase();
    }

    return tekst[0].toUpperCase() + tekst.substring(1).toLowerCase();
  }

  static String korteMeldingVoorKeuze(OpmetingDeurpaneelKeuze keuze) {
    if (keuze.wissen) {
      return 'Paneel wissen gekozen.';
    }

    return '${keuze.paneel.naam} (${keuze.paneel.id}) gekozen als ${keuze.uitvoering.label}.';
  }
}
