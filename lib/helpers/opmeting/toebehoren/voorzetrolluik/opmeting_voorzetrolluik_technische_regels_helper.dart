// THIMACO-CONTROLE: VOORZETROLLUIK-TECHNISCHE-REGELS-ELEKTRISCHE-BEDIENING-20260731-1215
import '../../overzicht/opmeting_overzicht_model.dart';
import 'opmeting_voorzetrolluik_kastmaat_helper.dart';
import 'opmeting_voorzetrolluik_model.dart';

class OpmetingVoorzetrolluikTechnischeRegelsHelper {
  const OpmetingVoorzetrolluikTechnischeRegelsHelper._();

  static List<OpmetingOverzichtTechnischeRegel> bouw(
    OpmetingVoorzetrolluikModel model,
  ) {
    final asDiameter = OpmetingVoorzetrolluikKastmaatHelper.asDiameterVoor(
      lamelType: model.lamelType,
      bediening: model.bediening,
    );

    final regels = <OpmetingOverzichtTechnischeRegel>[
      if (model.positie.trim().isNotEmpty)
        OpmetingOverzichtTechnischeRegel(
          titel: 'Positie',
          waarde: model.positie.trim(),
        ),
      OpmetingOverzichtTechnischeRegel(
        titel: 'Aantal',
        waarde: model.aantal.toString(),
      ),
      OpmetingOverzichtTechnischeRegel(
        titel: 'Breedte',
        waarde: '${model.breedteMm} mm · ${model.breedteMeetwijzeTekst}',
      ),
      OpmetingOverzichtTechnischeRegel(
        titel: 'Hoogte',
        waarde: '${model.hoogteMm} mm · ${model.hoogteMeetwijzeTekst}',
      ),
      OpmetingOverzichtTechnischeRegel(
        titel: 'Kast',
        waarde: model.kastSamenvatting,
      ),
      OpmetingOverzichtTechnischeRegel(
        titel: 'Asdiameter',
        waarde: '$asDiameter mm',
      ),
      OpmetingOverzichtTechnischeRegel(
        titel: 'Type lamel',
        waarde: model.lamelType,
      ),
      OpmetingOverzichtTechnischeRegel(
        titel: 'Kleur lamellen',
        waarde: model.lamelSamenvatting,
      ),
      OpmetingOverzichtTechnischeRegel(
        titel: 'Open lamellen',
        waarde: '${model.openLamellenPercentage}%',
      ),
      OpmetingOverzichtTechnischeRegel(
        titel: 'Borstels in de geleiders',
        waarde: model.borstelsInGeleiders ? 'Ja' : 'Neen',
      ),
      OpmetingOverzichtTechnischeRegel(
        titel: 'Kleur kast, geleiders en onderlat',
        waarde: model.kleurSamenvatting,
      ),
      OpmetingOverzichtTechnischeRegel(
        titel: 'Bediening',
        waarde: model.bediening.label,
      ),
      if (!model.isElektrisch)
        OpmetingOverzichtTechnischeRegel(
          titel: 'Uitgang lint',
          waarde: model.kantLint.label,
        ),
      if (model.isElektrisch)
        OpmetingOverzichtTechnischeRegel(
          titel: 'Zonnecel',
          waarde: model.zonnecel ? 'Ja' : 'Neen',
        ),
      if (model.isElektrisch)
        OpmetingOverzichtTechnischeRegel(
          titel: 'Type motor',
          waarde: model.motorSamenvatting,
        ),
      if (model.isElektrisch)
        OpmetingOverzichtTechnischeRegel(
          titel: 'Bediening elektrisch',
          waarde: model.elektrischeBediening,
        ),
      if (model.isElektrisch && model.uitgangKabel.trim().isNotEmpty)
        OpmetingOverzichtTechnischeRegel(
          titel: 'Uitgang kabel',
          waarde: model.uitgangKabel.trim().toUpperCase(),
        ),
      OpmetingOverzichtTechnischeRegel(
        titel: 'Geleiders',
        waarde: model.geleiderType.trim().isEmpty
            ? 'Nog te bepalen'
            : model.geleiderType.trim(),
      ),
      OpmetingOverzichtTechnischeRegel(
        titel: 'Boren geleiders',
        waarde: model.borenGeleiders.label,
      ),
    ];

    return List<OpmetingOverzichtTechnischeRegel>.unmodifiable(regels);
  }
}
