// THIMACO-CONTROLE: ALGEMENE-OPMETING-A-V-RESULTAATREGELS-20260802
import '../overzicht/opmeting_overzicht_model.dart';
import 'opmeting_algemene_opmeting_blok_model.dart';
import 'opmeting_algemene_opmeting_model.dart';

class OpmetingAlgemeneOpmetingTechnischeRegelsHelper {
  const OpmetingAlgemeneOpmetingTechnischeRegelsHelper._();

  static List<OpmetingOverzichtTechnischeRegel> bouw(
    OpmetingAlgemeneOpmetingModel model,
  ) {
    final regels = <OpmetingOverzichtTechnischeRegel>[];

    for (final blok in model.blokken) {
      if (blok.isPrijs) {
        final titel = blok.titel.trim();
        if (titel.isEmpty) continue;
        regels.add(
          OpmetingOverzichtTechnischeRegel(
            titel: '${blok.prijsSoort.cirkelTeken} $titel',
            waarde: prijsSamenvatting(blok, toonBedrag: false),
          ),
        );
        continue;
      }

      final tekst = blok.omschrijving.trim();
      if (tekst.isEmpty) continue;
      regels.add(OpmetingOverzichtTechnischeRegel(titel: '', waarde: tekst));
    }

    return List<OpmetingOverzichtTechnischeRegel>.unmodifiable(regels);
  }

  static List<OpmetingOverzichtTechnischeContainer> bouwContainers(
    OpmetingAlgemeneOpmetingModel model,
  ) {
    final containers = <OpmetingOverzichtTechnischeContainer>[];

    for (final blok in model.blokken) {
      if (blok.isPrijs) {
        final titel = blok.titel.trim();
        if (titel.isEmpty) continue;
        containers.add(
          OpmetingOverzichtTechnischeContainer(
            titel: '${blok.prijsSoort.cirkelTeken} $titel',
            afmeting: prijsSamenvatting(blok),
            regels: const <OpmetingOverzichtTechnischeRegel>[],
          ),
        );
        continue;
      }

      final tekst = blok.omschrijving.trim();
      if (tekst.isEmpty) continue;
      containers.add(
        OpmetingOverzichtTechnischeContainer(
          titel: '',
          afmeting: '',
          regels: <OpmetingOverzichtTechnischeRegel>[
            OpmetingOverzichtTechnischeRegel(titel: '', waarde: tekst),
          ],
        ),
      );
    }

    return List<OpmetingOverzichtTechnischeContainer>.unmodifiable(containers);
  }

  static String prijsSamenvatting(
    OpmetingAlgemeneOpmetingBlok blok, {
    bool toonBedrag = true,
  }) {
    if (blok.eenheid == OpmetingAlgemenePrijsEenheid.vastBedrag) {
      if (!toonBedrag) return 'Vast bedrag';
      return 'Vast bedrag · € ${_bedrag(blok.totaalExclBtw)} excl. btw';
    }

    final hoeveelheid = _getal(blok.veiligeHoeveelheid);
    final basis = '$hoeveelheid ${blok.eenheid.label}';
    if (!toonBedrag) return basis;

    return '$basis × € ${_bedrag(blok.veiligeEenheidsprijs)} '
        '= € ${_bedrag(blok.totaalExclBtw)} excl. btw';
  }

  static String _bedrag(double waarde) {
    return waarde.toStringAsFixed(2).replaceAll('.', ',');
  }

  static String _getal(double waarde) {
    if (waarde == waarde.roundToDouble()) return waarde.toInt().toString();
    return waarde
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'[.,]$'), '')
        .replaceAll('.', ',');
  }
}
