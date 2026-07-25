// THIMACO-CONTROLE: VERDEELKOST-DOELMARKERING-20260724-INZETHOR
import 'dart:convert';

import '../../opmeting/toebehoren/vaste_inzethor/opmeting_vaste_inzethor_model.dart';
import 'offerte_berekening_resultaat.dart';
import 'offerte_prijs_categorie.dart';
import 'offerte_prijsprofiel_model.dart';
import 'offerte_prijsregel_model.dart';
import 'offerte_toegepaste_prijsregel_model.dart';
import 'offerte_vrije_prijs_selectie_model.dart';

class OffertePrijsBerekeningService {
  const OffertePrijsBerekeningService._();

  static const String _tijdelijkeVrijePrijsPrefix = 'tijdelijk_vrij_';
  static const String _toegepasteProjectPrijsPrefix = 'toegepast_project_';

  static bool moetTechnischeMomentopnameBijwerken(
    OpmetingVasteInzethorModel model,
  ) {
    return model.toegepasteTechnischePrijsregels.isNotEmpty ||
        model.technischePrijsSignatuur != model.prijsBerekeningSignatuur;
  }

  static OpmetingVasteInzethorModel maakTechnischeMomentopname({
    required OpmetingVasteInzethorModel model,
  }) {
    return model.copyWithPrijsData(
      model.prijsData.copyWith(
        toegepasteTechnischePrijsregels:
            const <OfferteToegepastePrijsregelModel>[],
        technischePrijsSignatuur: model.prijsBerekeningSignatuur,
      ),
    );
  }

  static bool moetVrijeArtikelMomentopnameBijwerken({
    required OpmetingVasteInzethorModel model,
    required OffertePrijsprofielModel profiel,
    bool forceer = false,
  }) {
    if (forceer) return true;

    return model.vrijeArtikelPrijsSignatuur !=
        _maakVrijeArtikelPrijsSignatuur(model: model, profiel: profiel);
  }

  /// Bouwt de automatische momentopname opnieuw op, maar bewaart de
  /// eenmalige regels die vanuit het zwevende menu bij deze positie werden
  /// toegevoegd.
  static OpmetingVasteInzethorModel maakVrijeArtikelMomentopname({
    required OpmetingVasteInzethorModel model,
    required OffertePrijsprofielModel profiel,
  }) {
    final berekendOp = DateTime.now().toUtc().toIso8601String();
    final tijdelijkeSelecties = model.vrijeArtikelPrijsSelecties
        .where(_isTijdelijkeVrijePrijsSelectie)
        .toList(growable: false);

    final tijdelijkePrijsregelIds = tijdelijkeSelecties
        .map((selectie) => selectie.bronPrijsregelId)
        .where((id) => id.isNotEmpty)
        .toSet();

    final automatischeSelecties = _geldigeAutomatischeArtikelRegels(profiel)
        .where((regel) => !tijdelijkePrijsregelIds.contains(regel.id))
        .map((regel) {
          return OfferteVrijePrijsSelectieModel(
            id: 'automatisch_${regel.id}',
            bronPrijsregelId: regel.id,
            omschrijving: regel.omschrijving,
            bedragPerStukExclBtw: regel.prijsExclBtw,
            eenheid: regel.eenheid,
            uitschrijfmodus: regel.uitschrijfmodus,
            bronPrijsPerStukExclBtw: regel.prijsExclBtw,
            bronGewijzigdOp: regel.gewijzigdOp,
            geselecteerdOp: berekendOp,
            actief: true,
          );
        })
        .toList(growable: false);

    return model.copyWithPrijsData(
      model.prijsData.copyWith(
        vrijeArtikelPrijsSelecties: <OfferteVrijePrijsSelectieModel>[
          ...automatischeSelecties,
          ...tijdelijkeSelecties,
        ],
        vrijeArtikelPrijsSignatuur: _maakVrijeArtikelPrijsSignatuur(
          model: model,
          profiel: profiel,
        ),
      ),
    );
  }

  /// Leest uitsluitend de eenmalige regels terug die bij deze positie zijn
  /// opgeslagen. Het overzichtsscherm voegt deze samen met de regels uit
  /// Instellingen. Een tijdelijke regel met hetzelfde id overschrijft de
  /// centrale regel zonder dat de prijs dubbel wordt berekend.
  static List<OffertePrijsregelModel> tijdelijkeVrijeArtikelPrijsregels(
    OpmetingVasteInzethorModel model, {
    String formulierType = 'vasteInzethor',
  }) {
    final regels = model.vrijeArtikelPrijsSelecties
        .where(
          (selectie) =>
              _isTijdelijkeVrijePrijsSelectie(selectie) &&
              !_isGekozenProjectPrijsSelectie(selectie) &&
              !selectie.uitschrijfmodus.isVerdeeldeInterneKost,
        )
        .map((selectie) {
          return OffertePrijsregelModel(
            id: selectie.bronPrijsregelId,
            categorie: OffertePrijsCategorie.vrijPerArtikel,
            formulierType: formulierType,
            omschrijving: selectie.omschrijving,
            prijsExclBtw: selectie.prijsPerEenheidExclBtw,
            eenheid: selectie.eenheid,
            uitschrijfmodus: selectie.uitschrijfmodus,
            actief: selectie.actief,
            volgorde: _leesTijdelijkeVolgorde(selectie.id),
            gewijzigdOp: selectie.bronGewijzigdOp,
          );
        })
        .toList(growable: false);

    regels.sort((eerste, tweede) => eerste.volgorde.compareTo(tweede.volgorde));
    return List<OffertePrijsregelModel>.unmodifiable(regels);
  }

  /// Vervangt alleen de eenmalige vrije prijsregels. De automatisch vanuit
  /// Instellingen toegepaste regels blijven onaangeroerd.
  static OpmetingVasteInzethorModel metTijdelijkeVrijeArtikelPrijsregels({
    required OpmetingVasteInzethorModel model,
    required List<OffertePrijsregelModel> prijsregels,
  }) {
    final tijdelijkePrijsregelIds = prijsregels
        .where(
          (regel) =>
              regel.isGeldig &&
              regel.categorie == OffertePrijsCategorie.vrijPerArtikel,
        )
        .map((regel) => regel.id)
        .where((id) => id.isNotEmpty)
        .toSet();
    final verdeelkostMarkeringen = model.vrijeArtikelPrijsSelecties
        .where(
          (selectie) =>
              _isTijdelijkeVrijePrijsSelectie(selectie) &&
              selectie.uitschrijfmodus.isVerdeeldeInterneKost,
        )
        .toList(growable: false);
    final gekozenProjectPrijsSelecties = model.vrijeArtikelPrijsSelecties
        .where(
          (selectie) =>
              _isGekozenProjectPrijsSelectie(selectie) &&
              !selectie.uitschrijfmodus.isVerdeeldeInterneKost,
        )
        .toList(growable: false);
    final bestaandeAutomatischeSelecties = model.vrijeArtikelPrijsSelecties
        .where(
          (selectie) =>
              !_isTijdelijkeVrijePrijsSelectie(selectie) &&
              !tijdelijkePrijsregelIds.contains(selectie.bronPrijsregelId),
        )
        .toList(growable: false);
    final nu = DateTime.now().toUtc().toIso8601String();

    final tijdelijkeSelecties = <OfferteVrijePrijsSelectieModel>[];
    for (var index = 0; index < prijsregels.length; index++) {
      final regel = prijsregels[index];
      if (!regel.isGeldig ||
          regel.categorie != OffertePrijsCategorie.vrijPerArtikel) {
        continue;
      }

      tijdelijkeSelecties.add(
        OfferteVrijePrijsSelectieModel(
          id: '$_tijdelijkeVrijePrijsPrefix${index}_${regel.id}',
          bronPrijsregelId: regel.id,
          omschrijving: regel.omschrijving,
          bedragPerStukExclBtw: regel.prijsExclBtw,
          eenheid: regel.eenheid,
          uitschrijfmodus: regel.uitschrijfmodus,
          bronPrijsPerStukExclBtw: regel.prijsExclBtw,
          bronGewijzigdOp: regel.gewijzigdOp,
          geselecteerdOp: nu,
          actief: regel.actief,
        ),
      );
    }

    return model.copyWithPrijsData(
      model.prijsData.copyWith(
        vrijeArtikelPrijsSelecties: <OfferteVrijePrijsSelectieModel>[
          ...bestaandeAutomatischeSelecties,
          ...verdeelkostMarkeringen,
          ...gekozenProjectPrijsSelecties,
          ...tijdelijkeSelecties,
        ],
      ),
    );
  }

  static OfferteBerekeningResultaat resultaatUitMomentopname(
    OpmetingVasteInzethorModel model, {
    bool kortingToestaan = true,
  }) {
    final int aantal = model.aantal < 1 ? 1 : model.aantal;
    final double basisTotaal = _rondBedragAf(
      model.prijsPerStukExclBtw * aantal.toDouble(),
    );

    final vrijeArtikelPrijsregels = model.vrijeArtikelPrijsSelecties
        .where(
          (selectie) =>
              selectie.actief &&
              selectie.isGeldig &&
              selectie.heeftBedrag &&
              !selectie.uitschrijfmodus.isVerdeeldeInterneKost,
        )
        .map((selectie) {
          final hoeveelheid = selectie.hoeveelheidVoorMaten(
            aantal: aantal,
            breedteMm: model.breedteMm,
            hoogteMm: model.hoogteMm,
          );
          final totaal = selectie.totaalExclBtwVoorMaten(
            aantal: aantal,
            breedteMm: model.breedteMm,
            hoogteMm: model.hoogteMm,
          );

          return OfferteToegepastePrijsregelModel(
            bronPrijsregelId: selectie.bronPrijsregelId,
            categorie: OffertePrijsCategorie.vrijPerArtikel,
            omschrijving: selectie.omschrijving,
            prijsExclBtw: selectie.prijsPerEenheidExclBtw,
            eenheid: selectie.eenheid,
            hoeveelheid: hoeveelheid,
            totaalExclBtw: totaal,
            uitschrijfmodus: selectie.uitschrijfmodus,
            bronGewijzigdOp: selectie.bronGewijzigdOp,
            berekendOp: selectie.geselecteerdOp,
          );
        })
        .where((regel) => regel.isGeldig && regel.totaalExclBtw > 0.0)
        .toList(growable: false);

    return OfferteBerekeningResultaat(
      basisTotaalExclBtw: basisTotaal,
      aantalArtikelen: aantal,
      basisPrijsPerStukExclBtw: model.prijsPerStukExclBtw,
      technischePrijsregels: model.toegepasteTechnischePrijsregels
          .where((regel) => regel.toonOpOverzicht && regel.isGeldig)
          .toList(growable: false),
      vrijeArtikelPrijsregels: vrijeArtikelPrijsregels,
      verdeeldePrijsregels: model.toegepasteVerdeeldePrijsregels
          .where((regel) => regel.toonOpOverzicht && regel.isGeldig)
          .toList(growable: false),
      winstmargePercentage: model.artikelWinstmargePercentage,
      winstmargeOmschrijving: model.artikelWinstmargeOmschrijving,
      kortingPercentage: kortingToestaan ? model.artikelKortingPercentage : 0.0,
      kortingOmschrijving: model.artikelKortingOmschrijving,
    );
  }

  static List<OffertePrijsregelModel> _geldigeAutomatischeArtikelRegels(
    OffertePrijsprofielModel profiel,
  ) {
    return profiel
        .regelsVoorCategorie(OffertePrijsCategorie.vrijPerArtikel)
        .where((regel) {
          return regel.actief &&
              regel.isGeldig &&
              regel.prijsExclBtw > 0.0 &&
              _isZelfdeFormulierType(
                regel.formulierType,
                profiel.formulierType,
              );
        })
        .toList(growable: false);
  }

  static String _maakVrijeArtikelPrijsSignatuur({
    required OpmetingVasteInzethorModel model,
    required OffertePrijsprofielModel profiel,
  }) {
    final regels = _geldigeAutomatischeArtikelRegels(profiel)
        .map(
          (regel) => <String, Object?>{
            'id': regel.id,
            'omschrijving': regel.omschrijving,
            'prijsExclBtw': regel.prijsExclBtw,
            'eenheid': regel.eenheid.jsonWaarde,
            'uitschrijfmodus': regel.uitschrijfmodus.jsonWaarde,
            'actief': regel.actief,
            'volgorde': regel.volgorde,
            'gewijzigdOp': regel.gewijzigdOp,
          },
        )
        .toList(growable: false);

    return jsonEncode(<String, Object?>{
      'artikel': model.prijsBerekeningSignatuur,
      'regels': regels,
    });
  }

  static bool _isTijdelijkeVrijePrijsSelectie(
    OfferteVrijePrijsSelectieModel selectie,
  ) {
    return selectie.id.startsWith(_tijdelijkeVrijePrijsPrefix);
  }

  static bool _isGekozenProjectPrijsSelectie(
    OfferteVrijePrijsSelectieModel selectie,
  ) {
    return selectie.bronPrijsregelId.startsWith(_toegepasteProjectPrijsPrefix);
  }

  static int _leesTijdelijkeVolgorde(String id) {
    if (!id.startsWith(_tijdelijkeVrijePrijsPrefix)) return 0;
    final rest = id.substring(_tijdelijkeVrijePrijsPrefix.length);
    final scheiding = rest.indexOf('_');
    if (scheiding <= 0) return 0;
    final index = int.tryParse(rest.substring(0, scheiding)) ?? 0;
    return index * 10;
  }

  static bool _isZelfdeFormulierType(String eerste, String tweede) {
    return _normaliseerFormulierType(eerste) ==
        _normaliseerFormulierType(tweede);
  }

  static String _normaliseerFormulierType(String waarde) {
    return waarde.trim().toLowerCase().replaceAll('_', '').replaceAll(' ', '');
  }

  static double _rondBedragAf(double waarde) {
    if (!waarde.isFinite || waarde < 0.0) return 0.0;
    return (waarde * 100.0).roundToDouble() / 100.0;
  }
}
