// THIMACO-CONTROLE: OPMETING-LOCAL-FIRST-10S-FASE1-20260917
// THIMACO-CONTROLE: PROJECTBESTAND-DIALOGEN-RUSTIGE-PROGRAMMASTIJL-FASE17-20260913
// THIMACO-CONTROLE: PROJECTCONTROLLER-ZONDER-OUDE-OFFERTEWERKVERSIES-20260912
// THIMACO-CONTROLE: PROJECTOPENEN-INGEKLAPT-ZOEKEN-DATUM-VERSIES-FASE4-20260912
// THIMACO-CONTROLE: CENTRAAL-BESTANDMENU-NIEUWPROJECT-VARIANT-WISFLOW-FASE3-20260912
// THIMACO-CONTROLE: KLANT-OFFERTEBESTAND-OPENEN-OPSLAAN-ALS-FASE2-20260912
// THIMACO-CONTROLE: OUDE-PRIJSPROFIEL-MOMENTOPNAMEFLOW-UIT-PROJECTLADEN-20260815
// THIMACO-CONTROLE: GLOBALE-ATOMAIRE-OPMETINGOPSLAG-20260810
// THIMACO-CONTROLE: OPMEETBESTAND-SYNC-ALTIJD-SILENT-20260805
// THIMACO-CONTROLE: UNIFORME-OPMEETBESTAND-DIALOGEN-20260730
// THIMACO-CONTROLE: OPENEN-ZONDER-ONTERECHTE-PRIJSVRAAG-20260724
import 'package:flutter/material.dart';

import '../../app_storage.dart';
import '../../ui/thimaco_huisstijl.dart';
import '../../offerte/prijzen/offerte_artikel_prijscorrectie_controller.dart';
import '../../offerte/prijzen/offerte_prijsinstellingen_controller.dart';
import '../../sync/onedrive_sync_service.dart';
import '../overzicht/opmeting_overzicht_model.dart';
import '../opslag/opmeting_veilige_mutatie_service.dart';
import 'opmeting_project_kleur_model.dart';
import 'opmeting_project_titelhoofd_controller.dart';
import 'opmeting_project_titelhoofd_model.dart';

class OpmetingProjectBestandController {
  OpmetingProjectBestandController({
    required this.context,
    required this.isMounted,
    required this.leesKlantNaam,
    required this.leesTitelhoofd,
    required this.leesOpmetingen,
    required this.leesVerborgenFormulierTypes,
    required this.prijsinstellingenController,
    required this.projectTitelhoofdController,
    required this.artikelPrijscorrectieController,
    required this.vervangProjectState,
    required this.vervangProjectKleuren,
    required this.zetLaden,
    required this.toonMelding,
  });

  static const Color _accent = ThimacoKleuren.oranje;
  static const Color _rand = ThimacoKleuren.rand;
  static const Color _achtergrond = ThimacoKleuren.achtergrond;
  static const Color _tekstDonker = ThimacoKleuren.antraciet;
  static const Color _tekstGrijs = ThimacoKleuren.tekstGrijs;
  static const Color _rood = ThimacoKleuren.rood;

  final BuildContext context;
  final bool Function() isMounted;
  final String Function() leesKlantNaam;
  final OpmetingProjectTitelhoofd Function() leesTitelhoofd;
  final List<OpmetingOverzichtRaamItem> Function() leesOpmetingen;
  final Set<String> Function() leesVerborgenFormulierTypes;
  final OffertePrijsinstellingenController prijsinstellingenController;
  final OpmetingProjectTitelhoofdController projectTitelhoofdController;
  final OfferteArtikelPrijscorrectieController artikelPrijscorrectieController;
  final void Function(
    String klantNaam,
    OpmetingProjectTitelhoofd titelhoofd,
    List<OpmetingOverzichtRaamItem> opmetingen,
    Set<String> verborgenFormulierTypes,
    bool laden,
  )
  vervangProjectState;
  final void Function(List<OpmetingProjectKleurSubmenu> kleuren)
  vervangProjectKleuren;
  final void Function(bool laden) zetLaden;
  final void Function(String tekst, bool fout) toonMelding;

  Future<void> laadOpmetingenVanOpslag({
    String? klantNaam,
    String? projectBestandId,
    bool forceerPrijsinstellingen = false,
  }) async {
    zetLaden(true);

    final huidigeKlantNaam = leesKlantNaam().trim();
    final huidigTitelhoofd = leesTitelhoofd();
    final huidigProjectBestandId = huidigTitelhoofd.projectBestandId.trim();
    final actieveKlantNaam = (klantNaam ?? huidigeKlantNaam).trim();
    final gevraagdProjectBestandId =
        (projectBestandId ?? huidigProjectBestandId).trim();

    final opgeslagenTitelhoofd = await AppStorage.laadOpmetingProjectTitelhoofd(
      actieveKlantNaam,
      projectBestandId: gevraagdProjectBestandId,
    );
    final effectiefProjectBestandId =
        opgeslagenTitelhoofd.projectBestandId.trim().isNotEmpty
        ? opgeslagenTitelhoofd.projectBestandId.trim()
        : opmetingLegacyProjectBestandId(actieveKlantNaam);

    if (opgeslagenTitelhoofd.projectBestandVerwijderd) {
      if (isMounted()) {
        vervangProjectState(
          '',
          const OpmetingProjectTitelhoofd(),
          <OpmetingOverzichtRaamItem>[],
          <String>{},
          false,
        );
        toonMelding('Dit opmeetbestand is verwijderd.', true);
      }
      return;
    }

    final titelhoofd = await projectTitelhoofdController.vulAanUitKlantenfiche(
      klantNaam: actieveKlantNaam,
      basis: opgeslagenTitelhoofd.copyWith(
        projectBestandId: effectiefProjectBestandId,
      ),
    );

    final alleOpmetingenVoorSync = await AppStorage.laadOpmetingenVoorSync();

    final momentopnameResultaat = titelhoofd.berekenPrijzen
        ? await prijsinstellingenController.werkTechnischePrijsMomentopnamesBij(
            alleOpmetingen: alleOpmetingenVoorSync,
            klantNaam: actieveKlantNaam,
            projectBestandId: effectiefProjectBestandId,
            berekenPrijzen: true,
            forceerPrijsinstellingen: forceerPrijsinstellingen,
          )
        : OfferteTechnischePrijsMomentopnameResultaat(
            opmetingen: alleOpmetingenVoorSync,
            gewijzigd: false,
          );

    final projectkleurResultaat = projectTitelhoofdController
        .synchroniseerProjectkleurInVasteInzethorPosities(
          momentopnameResultaat.opmetingen,
          klantNaam: actieveKlantNaam,
          projectBestandId: effectiefProjectBestandId,
          projectkleur: titelhoofd.ralKleurToebehoren,
        );
    final opmetingenNaProjectkleurSynchronisatie =
        projectkleurResultaat.opmetingen;

    var definitieveOpmetingen = opmetingenNaProjectkleurSynchronisatie;

    if (momentopnameResultaat.gewijzigd || projectkleurResultaat.gewijzigd) {
      final veiligResultaat =
          await OpmetingVeiligeMutatieService.bewaarBerekendeWijzigingen(
            basis: alleOpmetingenVoorSync,
            gewijzigd: opmetingenNaProjectkleurSynchronisatie,
          );
      definitieveOpmetingen = veiligResultaat.opmetingen;
    }

    final zichtbareOpmetingen = definitieveOpmetingen
        .where((opmeting) {
          if (opmeting.isVerwijderd) return false;
          final id = opmeting.projectBestandId.trim().isNotEmpty
              ? opmeting.projectBestandId.trim()
              : opmetingLegacyProjectBestandId(opmeting.klantNaam);
          return id == effectiefProjectBestandId;
        })
        .toList(growable: false);

    if (!isMounted()) return;

    final bestaandeTypes = zichtbareOpmetingen
        .map((opmeting) => opmeting.formulierTypeGenormaliseerd)
        .toSet();
    final verborgenFormulierTypes = leesVerborgenFormulierTypes()
        .where(bestaandeTypes.contains)
        .toSet();

    final bestandGewijzigd =
        huidigProjectBestandId != effectiefProjectBestandId ||
        projectTitelhoofdController.normaliseerKlantNaam(actieveKlantNaam) !=
            projectTitelhoofdController.normaliseerKlantNaam(huidigeKlantNaam);
    if (bestandGewijzigd) {
      artikelPrijscorrectieController.wisDoelSelecties();
    }

    vervangProjectState(
      actieveKlantNaam,
      titelhoofd.klantNaam.trim().isEmpty && actieveKlantNaam.isNotEmpty
          ? titelhoofd.copyWith(klantNaam: actieveKlantNaam)
          : titelhoofd,
      zichtbareOpmetingen,
      verborgenFormulierTypes,
      false,
    );
  }

  Future<void> laadProjectKleuren() async {
    final kleuren = await AppStorage.laadOpmetingProjectKleuren();
    if (!isMounted()) return;
    vervangProjectKleuren(kleuren);
  }

  Future<List<OpmetingAgendaKlantInfo>> _laadKlantenVoorNieuweOpmeting() async {
    final bronnen = await Future.wait<List<OpmetingAgendaKlantInfo>>(
      <Future<List<OpmetingAgendaKlantInfo>>>[
        AppStorage.laadKlantenVoorOpmeting(),
        AppStorage.laadAgendaKlantenVoorOpmeting(),
      ],
    );
    final perKlant = <String, OpmetingAgendaKlantInfo>{};

    void voegToe(OpmetingAgendaKlantInfo klant) {
      final sleutel = opmetingKlantNaamSleutel(klant.klantNaam);
      if (sleutel.isEmpty) return;

      final bestaand = perKlant[sleutel];
      perKlant[sleutel] = bestaand == null
          ? klant
          : bestaand.combineerMet(klant);
    }

    // Klantenfiches worden eerst toegevoegd. Gegevens uit de blauwe agenda
    // vullen daarna alleen ontbrekende klantgegevens aan.
    for (final klant in bronnen[0]) {
      voegToe(klant);
    }
    for (final klant in bronnen[1]) {
      voegToe(klant);
    }

    final klanten = perKlant.values.toList()
      ..sort((eerste, tweede) {
        return eerste.klantNaamMetAanspreking.toLowerCase().compareTo(
          tweede.klantNaamMetAanspreking.toLowerCase(),
        );
      });

    return klanten;
  }

  Future<_NieuweOpmetingKlantResultaat?> _vraagKlantNaam({
    String beginNaam = '',
  }) async {
    final huidigeContext = context;
    final klanten = await _laadKlantenVoorNieuweOpmeting();
    if (!isMounted()) return null;
    if (!huidigeContext.mounted) return null;

    final resultaat = await showDialog<_NieuweOpmetingKlantResultaat>(
      context: huidigeContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _KlantNaamDialog(beginNaam: beginNaam, klanten: klanten);
      },
    );

    await Future<void>.delayed(Duration.zero);
    if (isMounted()) {
      await WidgetsBinding.instance.endOfFrame;
    }

    return resultaat;
  }

  Future<OpmetingProjectTitelhoofd> _maakTitelhoofdVoorNieuweKlant(
    _NieuweOpmetingKlantResultaat keuze,
  ) async {
    final projectId = maakNieuwOpmetingProjectBestandId();
    final nu = DateTime.now().toUtc().toIso8601String();
    final basis = OpmetingProjectTitelhoofd(
      klantNaam: keuze.klantNaam.trim(),
      projectBestandId: projectId,
      bestandsNaam: keuze.bestandsNaam.trim(),
      projectReeksId: projectId,
      bestandVersieNummer: 1,
      aangemaaktOp: nu,
      offerteVersie:
          OpmetingProjectTitelhoofd.offerteVersieVoorBestandVersieNummer(1),
    );
    final uitKlantenfiche = keuze.klantFiche?.naarTitelhoofd(
      bestaand: basis,
      overschrijfKlantnummer: true,
    );

    final aangevuld =
        uitKlantenfiche ??
        await projectTitelhoofdController.vulAanUitKlantenfiche(
          klantNaam: keuze.klantNaam,
          basis: basis,
        );

    return aangevuld
        .copyWith(
          projectBestandId: basis.projectBestandId,
          bestandsNaam: keuze.bestandsNaam.trim(),
          projectReeksId: basis.projectReeksId,
          bestandVersieNummer: 1,
          aangemaaktOp: basis.aangemaaktOp,
          offerteVersie:
              OpmetingProjectTitelhoofd.offerteVersieVoorBestandVersieNummer(1),
          projectBestandVerwijderd: false,
        )
        .metWijzigingsDatum();
  }

  Future<bool> _bestandsNaamBestaat({
    required String klantNaam,
    required String bestandsNaam,
    String behalveProjectBestandId = '',
  }) async {
    final bestanden = await AppStorage.laadOpmetingProjectBestandenVoorKlant(
      klantNaam,
    );
    final naamSleutel = bestandsNaam.trim().toLowerCase();
    final behalve = behalveProjectBestandId.trim();
    return bestanden.any((bestand) {
      if (bestand.projectBestandVerwijderd) return false;
      if (behalve.isNotEmpty && bestand.projectBestandId.trim() == behalve) {
        return false;
      }
      return bestand.bestandsNaam.trim().toLowerCase() == naamSleutel;
    });
  }

  Future<int> _volgendBestandVersieNummer(
    OpmetingProjectTitelhoofd huidigTitelhoofd,
  ) async {
    final reeksId = huidigTitelhoofd.effectieveProjectReeksId;
    final alleTitelhoofden =
        await AppStorage.laadOpmetingProjectTitelhoofdenVoorSync();
    var hoogste = 0;

    for (final titelhoofd in alleTitelhoofden.values) {
      // Ook verwijderde versies blijven meetellen. Zo wordt een oud nummer
      // nooit opnieuw gebruikt en blijft de reeks V1, V2, V3, ... oplopend.
      if (titelhoofd.effectieveProjectReeksId != reeksId) continue;
      if (titelhoofd.veiligeBestandVersieNummer > hoogste) {
        hoogste = titelhoofd.veiligeBestandVersieNummer;
      }
    }

    if (hoogste < huidigTitelhoofd.veiligeBestandVersieNummer) {
      hoogste = huidigTitelhoofd.veiligeBestandVersieNummer;
    }
    return hoogste + 1;
  }

  Future<bool> _kopieerHuidigProjectAls({
    required String nieuweNaam,
    required String actieNaam,
    bool synchroniseerNaOpslaan = false,
  }) async {
    await projectTitelhoofdController.bewaarOpenstaandeWijzigingenNu();
    if (!isMounted()) return false;

    final huidigTitelhoofd = leesTitelhoofd();
    final klantNaam = leesKlantNaam().trim();
    final huidigProjectId = huidigTitelhoofd.projectBestandId.trim();
    if (klantNaam.isEmpty || huidigProjectId.isEmpty) {
      toonMelding('Open eerst een opmeetbestand.', true);
      return false;
    }

    zetLaden(true);
    try {
      final volgendVersieNummer = await _volgendBestandVersieNummer(
        huidigTitelhoofd,
      );
      if (!isMounted()) return false;

      final nieuwProjectId = maakNieuwOpmetingProjectBestandId();
      final actuelePosities = List<OpmetingOverzichtRaamItem>.from(
        leesOpmetingen().where((positie) => !positie.isVerwijderd),
      );
      final nu = DateTime.now().toUtc().toIso8601String();
      final idMap = <String, String>{};
      final basisMicro = DateTime.now().microsecondsSinceEpoch;

      for (var index = 0; index < actuelePosities.length; index++) {
        final oudId = actuelePosities[index].id.trim();
        if (oudId.isNotEmpty) {
          idMap[oudId] = 'projectkopie_${basisMicro}_$index';
        }
      }

      final gekopieerdePosities = <OpmetingOverzichtRaamItem>[];
      for (var index = 0; index < actuelePosities.length; index++) {
        final bron = actuelePosities[index];
        final nieuweId =
            idMap[bron.id.trim()] ??
            'projectkopie_${basisMicro}_${index}_nieuw';
        final oudHoofdId = bron.offerteOptieHoofdpositieId.trim();
        gekopieerdePosities.add(
          bron.copyWith(
            id: nieuweId,
            projectBestandId: nieuwProjectId,
            offerteOptieHoofdpositieId: oudHoofdId.isEmpty
                ? ''
                : idMap[oudHoofdId] ?? '',
            gewijzigdOp: nu,
            isVerwijderd: false,
          ),
        );
      }

      if (gekopieerdePosities.isNotEmpty) {
        await AppStorage.muteerOpmetingenAtomair<void>((actueel) {
          final nieuweLijst = List<OpmetingOverzichtRaamItem>.from(actueel)
            ..addAll(gekopieerdePosities);
          return AppStorageOpmetingMutatieResultaat<void>(
            resultaat: null,
            opmetingen: nieuweLijst,
            gewijzigd: true,
            startSync: false,
          );
        });
      }

      final nieuweVerborgenIds = <String>{
        for (final oudId in huidigTitelhoofd.verborgenNietRekenenPositieIds)
          if (idMap.containsKey(oudId)) idMap[oudId]!,
      };

      final nieuwTitelhoofd = huidigTitelhoofd
          .copyWith(
            projectBestandId: nieuwProjectId,
            bestandsNaam: nieuweNaam.trim(),
            projectReeksId: huidigTitelhoofd.effectieveProjectReeksId,
            bestandVersieNummer: volgendVersieNummer,
            aangemaaktOp: nu,
            projectBestandVerwijderd: false,
            verborgenNietRekenenPositieIds: nieuweVerborgenIds,
            offerteVersie:
                OpmetingProjectTitelhoofd.offerteVersieVoorBestandVersieNummer(
                  volgendVersieNummer,
                ),
          )
          .metWijzigingsDatum();
      await AppStorage.bewaarOpmetingProjectTitelhoofd(nieuwTitelhoofd);

      String? syncResultaat;
      if (synchroniseerNaOpslaan) {
        await OneDriveSyncService.registreerLokaleWijziging();
        syncResultaat = await OneDriveSyncService().slimmeSync();
        if (!isMounted()) return false;
      }

      artikelPrijscorrectieController.wisDoelSelecties();
      vervangProjectState(
        klantNaam,
        nieuwTitelhoofd,
        gekopieerdePosities,
        Set<String>.from(leesVerborgenFormulierTypes()),
        false,
      );

      final label = '${nieuwTitelhoofd.bestandsNaam} V$volgendVersieNummer';
      if (!synchroniseerNaOpslaan || syncResultaat == null) {
        toonMelding('$actieNaam “$label” is lokaal opgeslagen.', false);
        return true;
      }

      final syncOk = _isSyncGeslaagd(syncResultaat);
      toonMelding(
        syncOk
            ? '$actieNaam “$label” is opgeslagen en gesynchroniseerd.'
            : '“$label” is lokaal opgeslagen, maar synchronisatie is niet gelukt: $syncResultaat',
        !syncOk,
      );
      return true;
    } catch (fout) {
      if (isMounted()) {
        zetLaden(false);
        toonMelding('$actieNaam is niet gelukt: $fout', true);
      }
      return false;
    }
  }

  String _normaliseerZoekTekst(String waarde) {
    var tekst = waarde.toLowerCase().trim();
    const vervangingen = <String, String>{
      'à': 'a',
      'á': 'a',
      'â': 'a',
      'ä': 'a',
      'ã': 'a',
      'å': 'a',
      'ç': 'c',
      'è': 'e',
      'é': 'e',
      'ê': 'e',
      'ë': 'e',
      'ì': 'i',
      'í': 'i',
      'î': 'i',
      'ï': 'i',
      'ñ': 'n',
      'ò': 'o',
      'ó': 'o',
      'ô': 'o',
      'ö': 'o',
      'õ': 'o',
      'ù': 'u',
      'ú': 'u',
      'û': 'u',
      'ü': 'u',
      'ý': 'y',
      'ÿ': 'y',
    };
    vervangingen.forEach((van, naar) {
      tekst = tekst.replaceAll(van, naar);
    });
    return tekst
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  int _zoekAfstand(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    var vorige = List<int>.generate(b.length + 1, (index) => index);
    for (var i = 1; i <= a.length; i++) {
      final huidige = List<int>.filled(b.length + 1, 0);
      huidige[0] = i;
      for (var j = 1; j <= b.length; j++) {
        final kost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
        final verwijderen = vorige[j] + 1;
        final invoegen = huidige[j - 1] + 1;
        final vervangen = vorige[j - 1] + kost;
        huidige[j] = verwijderen < invoegen
            ? (verwijderen < vervangen ? verwijderen : vervangen)
            : (invoegen < vervangen ? invoegen : vervangen);
      }
      vorige = huidige;
    }
    return vorige[b.length];
  }

  bool _vergevingsgezindeKlantMatch(String zoektekst, String klantNaam) {
    final zoek = _normaliseerZoekTekst(zoektekst);
    if (zoek.isEmpty) return true;
    final doel = _normaliseerZoekTekst(klantNaam);
    if (doel.contains(zoek)) return true;

    final zoekWoorden = zoek.split(' ').where((deel) => deel.isNotEmpty);
    final doelWoorden = doel
        .split(' ')
        .where((deel) => deel.isNotEmpty)
        .toList();
    return zoekWoorden.every((zoekWoord) {
      if (doelWoorden.any((woord) => woord.contains(zoekWoord))) return true;
      final tolerantie = zoekWoord.length <= 4
          ? 1
          : zoekWoord.length <= 8
          ? 2
          : 3;
      return doelWoorden.any(
        (woord) => _zoekAfstand(zoekWoord, woord) <= tolerantie,
      );
    });
  }

  String _formatteerBestandDatum(String iso) {
    final datum = DateTime.tryParse(iso.trim())?.toLocal();
    if (datum == null) return '';
    String twee(int waarde) => waarde.toString().padLeft(2, '0');
    return '${twee(datum.day)}/${twee(datum.month)}/${datum.year}';
  }

  bool get _heeftOpenProject {
    return leesTitelhoofd().projectBestandId.trim().isNotEmpty ||
        leesKlantNaam().trim().isNotEmpty ||
        leesOpmetingen().isNotEmpty;
  }

  Future<bool> _bevestigBewarenVoorWissel({required String actie}) async {
    if (!_heeftOpenProject) return true;

    final huidigeContext = context;
    if (!isMounted() || !huidigeContext.mounted) return false;

    final titelhoofd = leesTitelhoofd();
    final bestandsNaam = titelhoofd.bestandsNaam.trim().isEmpty
        ? 'het huidige bestand'
        : '“${titelhoofd.bestandsNaam.trim()}”';

    final keuze = await showDialog<String>(
      context: huidigeContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _rand),
          ),
          titlePadding: EdgeInsets.zero,
          title: _bouwBestandDialoogKop(
            titel: 'Huidig bestand bewaren?',
            icoon: Icons.save_outlined,
          ),
          contentPadding: const EdgeInsets.fromLTRB(16, 15, 16, 4),
          content: SizedBox(
            width: 440,
            child: Text(
              'Je staat op het punt $actie. Wil je $bestandsNaam eerst lokaal opslaan?',
              style: const TextStyle(
                color: _tekstDonker,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          actions: <Widget>[
            ThimacoTekstActie(
              tekst: 'Annuleren',
              onPressed: () => Navigator.pop(dialogContext, 'annuleren'),
            ),
            ThimacoTekstActie(
              tekst: 'Doorgaan zonder opslaan',
              onPressed: () => Navigator.pop(dialogContext, 'doorgaan'),
            ),
            ThimacoTekstActie(
              tekst: 'Opslaan en doorgaan',
              onPressed: () => Navigator.pop(dialogContext, 'opslaan'),
            ),
          ],
        );
      },
    );

    if (keuze == null || keuze == 'annuleren') return false;
    if (keuze == 'opslaan') {
      await bewaarBestandLokaal(toonMeldingNaOpslaan: false);
      if (!isMounted()) return false;
    }
    return true;
  }

  Future<String?> zorgVoorActieveKlant() async {
    final huidigeKlantNaam = leesKlantNaam().trim();
    final huidigProjectId = leesTitelhoofd().projectBestandId.trim();
    if (huidigeKlantNaam.isNotEmpty && huidigProjectId.isNotEmpty) {
      return huidigeKlantNaam;
    }

    final keuze = await _vraagKlantNaam(beginNaam: '');
    if (keuze == null ||
        keuze.klantNaam.trim().isEmpty ||
        keuze.bestandsNaam.trim().isEmpty ||
        !isMounted()) {
      return null;
    }

    if (await _bestandsNaamBestaat(
      klantNaam: keuze.klantNaam,
      bestandsNaam: keuze.bestandsNaam,
    )) {
      if (isMounted()) {
        toonMelding(
          'Voor deze klant bestaat al een bestand met de naam “${keuze.bestandsNaam.trim()}”.',
          true,
        );
      }
      return null;
    }

    final klantNaam = keuze.klantNaam.trim();
    final titelhoofd = await _maakTitelhoofdVoorNieuweKlant(keuze);
    if (!isMounted()) return null;

    await AppStorage.bewaarOpmetingProjectTitelhoofd(titelhoofd);
    if (!isMounted()) return null;

    artikelPrijscorrectieController.wisDoelSelecties();
    vervangProjectState(
      klantNaam,
      titelhoofd,
      <OpmetingOverzichtRaamItem>[],
      Set<String>.from(leesVerborgenFormulierTypes()),
      false,
    );

    return klantNaam;
  }

  Future<void> nieuwProject() async {
    final magDoorgaan = await _bevestigBewarenVoorWissel(
      actie: 'een nieuw project te starten',
    );
    if (!magDoorgaan || !isMounted()) return;

    final keuze = await _vraagKlantNaam(beginNaam: '');
    if (keuze == null ||
        keuze.klantNaam.trim().isEmpty ||
        keuze.bestandsNaam.trim().isEmpty ||
        !isMounted()) {
      return;
    }

    if (await _bestandsNaamBestaat(
      klantNaam: keuze.klantNaam,
      bestandsNaam: keuze.bestandsNaam,
    )) {
      if (isMounted()) {
        toonMelding(
          'Voor deze klant bestaat al een bestand met de naam “${keuze.bestandsNaam.trim()}”. Kies een andere naam.',
          true,
        );
      }
      return;
    }

    final klantNaam = keuze.klantNaam.trim();
    final titelhoofd = await _maakTitelhoofdVoorNieuweKlant(keuze);
    if (!isMounted()) return;

    await AppStorage.bewaarOpmetingProjectTitelhoofd(titelhoofd);
    if (!isMounted()) return;

    artikelPrijscorrectieController.wisDoelSelecties();
    vervangProjectState(
      klantNaam,
      titelhoofd,
      <OpmetingOverzichtRaamItem>[],
      <String>{},
      false,
    );

    toonMelding(
      'Nieuw project “${titelhoofd.bestandsNaam} V${titelhoofd.veiligeBestandVersieNummer}” voor $klantNaam is aangemaakt.',
      false,
    );
  }

  Future<void> nieuweVariant() async {
    final huidigTitelhoofd = leesTitelhoofd();
    final klantNaam = leesKlantNaam().trim();
    final huidigProjectId = huidigTitelhoofd.projectBestandId.trim();
    if (klantNaam.isEmpty || huidigProjectId.isEmpty) {
      toonMelding('Open eerst een project.', true);
      return;
    }

    final magDoorgaan = await _bevestigBewarenVoorWissel(
      actie: 'een nieuwe variant te starten',
    );
    if (!magDoorgaan || !isMounted()) return;

    final nieuweNaam = await _vraagNieuweBestandsNaam(
      titel: 'Nieuwe variant',
      beginNaam: huidigTitelhoofd.bestandsNaam.trim(),
      klantNaam: klantNaam,
      bevestigTekst: 'Nieuwe variant',
    );
    if (nieuweNaam == null || nieuweNaam.isEmpty || !isMounted()) return;

    await _kopieerHuidigProjectAls(
      nieuweNaam: nieuweNaam,
      actieNaam: 'Nieuwe variant',
    );
  }

  // Tijdelijke compatibiliteit met eventuele oudere aanroepen.
  Future<void> nieuwBestand() => nieuweVariant();

  Future<List<_OpmetingProjectBestandKeuze>> _laadProjectBestandKeuzes() async {
    final resultaten = <String, _OpmetingProjectBestandKeuze>{};
    final titelhoofden =
        await AppStorage.laadOpmetingProjectTitelhoofdenVoorSync();
    final opmetingen = await AppStorage.laadOpmetingen();

    final aantallen = <String, int>{};
    final eersteKlantNaam = <String, String>{};
    final eersteDatum = <String, String>{};
    for (final opmeting in opmetingen) {
      final projectId = opmeting.projectBestandId.trim().isNotEmpty
          ? opmeting.projectBestandId.trim()
          : opmetingLegacyProjectBestandId(opmeting.klantNaam);
      aantallen[projectId] = (aantallen[projectId] ?? 0) + 1;
      eersteKlantNaam.putIfAbsent(projectId, () => opmeting.klantNaam.trim());

      final kandidaat = DateTime.tryParse(opmeting.gewijzigdOp.trim());
      final bestaand = DateTime.tryParse(eersteDatum[projectId] ?? '');
      if (kandidaat != null &&
          (bestaand == null || kandidaat.isBefore(bestaand))) {
        eersteDatum[projectId] = opmeting.gewijzigdOp.trim();
      }
    }

    for (final titelhoofd in titelhoofden.values) {
      if (titelhoofd.projectBestandVerwijderd) continue;
      final klantNaam = titelhoofd.klantNaam.trim();
      if (klantNaam.isEmpty) continue;
      final projectId = titelhoofd.projectBestandId.trim().isNotEmpty
          ? titelhoofd.projectBestandId.trim()
          : opmetingLegacyProjectBestandId(klantNaam);
      final naam = titelhoofd.bestandsNaam.trim().isNotEmpty
          ? titelhoofd.bestandsNaam.trim()
          : OpmetingProjectTitelhoofd.standaardBestaandBestandsNaam;
      final aangemaaktOp = titelhoofd.aangemaaktOp.trim().isNotEmpty
          ? titelhoofd.aangemaaktOp.trim()
          : eersteDatum[projectId]?.trim().isNotEmpty == true
          ? eersteDatum[projectId]!.trim()
          : titelhoofd.gewijzigdOp.trim();
      resultaten[projectId] = _OpmetingProjectBestandKeuze(
        klantNaam: klantNaam,
        projectBestandId: projectId,
        bestandsNaam: naam,
        projectReeksId: titelhoofd.effectieveProjectReeksId,
        versieNummer: titelhoofd.veiligeBestandVersieNummer,
        aangemaaktOp: aangemaaktOp,
        aantalPosities: aantallen[projectId] ?? 0,
      );
    }

    for (final entry in aantallen.entries) {
      if (resultaten.containsKey(entry.key)) continue;
      final klantNaam = eersteKlantNaam[entry.key]?.trim() ?? '';
      if (klantNaam.isEmpty) continue;
      resultaten[entry.key] = _OpmetingProjectBestandKeuze(
        klantNaam: klantNaam,
        projectBestandId: entry.key,
        bestandsNaam: OpmetingProjectTitelhoofd.standaardBestaandBestandsNaam,
        projectReeksId: entry.key,
        versieNummer: 1,
        aangemaaktOp: eersteDatum[entry.key] ?? '',
        aantalPosities: entry.value,
      );
    }

    final lijst = resultaten.values.toList(growable: false);
    lijst.sort((eerste, tweede) {
      final klant = eerste.klantNaam.toLowerCase().compareTo(
        tweede.klantNaam.toLowerCase(),
      );
      if (klant != 0) return klant;
      final naam = eerste.bestandsNaam.toLowerCase().compareTo(
        tweede.bestandsNaam.toLowerCase(),
      );
      if (naam != 0) return naam;
      return eerste.versieNummer.compareTo(tweede.versieNummer);
    });
    return lijst;
  }

  Future<void> openProject() async {
    final magDoorgaan = await _bevestigBewarenVoorWissel(
      actie: 'een ander project te openen',
    );
    if (!magDoorgaan || !isMounted()) return;

    final bestanden = await _laadProjectBestandKeuzes();
    if (!isMounted()) return;

    if (bestanden.isEmpty) {
      toonMelding('Er zijn nog geen opgeslagen projecten.', true);
      return;
    }

    final gekozen = await _kiesProjectBestand(
      titel: 'Project openen',
      bestanden: bestanden,
      wissen: false,
    );
    if (gekozen == null) return;

    await laadOpmetingenVanOpslag(
      klantNaam: gekozen.klantNaam,
      projectBestandId: gekozen.projectBestandId,
    );
    if (!isMounted()) return;

    toonMelding(
      '“${gekozen.bestandsNaam} V${gekozen.versieNummer}” van ${gekozen.klantNaam} is geopend.',
      false,
    );
  }

  Future<void> openHuidigProjectBestand() async {
    final klantNaam = leesKlantNaam().trim();
    final huidigProjectId = leesTitelhoofd().projectBestandId.trim();
    if (klantNaam.isEmpty || huidigProjectId.isEmpty) {
      toonMelding('Open eerst een project.', true);
      return;
    }

    final magDoorgaan = await _bevestigBewarenVoorWissel(
      actie: 'een ander bestand van $klantNaam te openen',
    );
    if (!magDoorgaan || !isMounted()) return;

    final alleBestanden = await _laadProjectBestandKeuzes();
    if (!isMounted()) return;
    final klantSleutel = opmetingKlantNaamSleutel(klantNaam);
    final bestanden = alleBestanden
        .where((bestand) {
          return opmetingKlantNaamSleutel(bestand.klantNaam) == klantSleutel &&
              bestand.projectBestandId != huidigProjectId;
        })
        .toList(growable: false);

    if (bestanden.isEmpty) {
      toonMelding(
        'Voor $klantNaam zijn geen andere bestanden opgeslagen.',
        false,
      );
      return;
    }

    final gekozen = await _kiesProjectBestand(
      titel: 'Bestand openen · $klantNaam',
      bestanden: bestanden,
      wissen: false,
    );
    if (gekozen == null) return;

    await laadOpmetingenVanOpslag(
      klantNaam: gekozen.klantNaam,
      projectBestandId: gekozen.projectBestandId,
    );
    if (!isMounted()) return;

    toonMelding(
      '“${gekozen.bestandsNaam} V${gekozen.versieNummer}” is geopend.',
      false,
    );
  }

  // Tijdelijke compatibiliteit met eventuele oudere aanroepen.
  Future<void> openBestand() => openProject();

  Widget _bouwBestandDialoogKop({
    required String titel,
    required IconData icoon,
    bool destructief = false,
  }) {
    final kleur = destructief ? _rood : _tekstDonker;
    final lijnKleur = destructief
        ? _rood.withValues(alpha: 0.72)
        : _accent.withValues(alpha: 0.72);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 11),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(bottom: BorderSide(color: _rand)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icoon, color: kleur, size: 19),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  titel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: kleur,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 34,
                  height: 1.5,
                  decoration: BoxDecoration(
                    color: lijnKleur,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<_OpmetingProjectBestandKeuze?> _kiesProjectBestand({
    required String titel,
    required List<_OpmetingProjectBestandKeuze> bestanden,
    required bool wissen,
  }) async {
    final perKlant = <String, List<_OpmetingProjectBestandKeuze>>{};
    for (final bestand in bestanden) {
      perKlant
          .putIfAbsent(
            bestand.klantNaam,
            () => <_OpmetingProjectBestandKeuze>[],
          )
          .add(bestand);
    }

    final zoekController = TextEditingController();
    var zoektekst = '';
    final openKlanten = <String>{};

    try {
      return await showDialog<_OpmetingProjectBestandKeuze>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              final klantNamen =
                  perKlant.keys
                      .where(
                        (klantNaam) =>
                            _vergevingsgezindeKlantMatch(zoektekst, klantNaam),
                      )
                      .toList()
                    ..sort(
                      (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
                    );

              return AlertDialog(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: _rand),
                ),
                titlePadding: EdgeInsets.zero,
                title: _bouwBestandDialoogKop(
                  titel: titel,
                  icoon: wissen
                      ? Icons.delete_outline_rounded
                      : Icons.folder_open_outlined,
                  destructief: wissen,
                ),
                contentPadding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
                content: SizedBox(
                  width: 560,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: zoekController,
                        autofocus: false,
                        cursorColor: _accent,
                        onChanged: (waarde) {
                          setDialogState(() {
                            zoektekst = waarde;
                          });
                        },
                        decoration: InputDecoration(
                          hintText:
                              'Zoek klantnaam · kleine typfouten zijn toegestaan',
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: _tekstDonker,
                            size: 19,
                          ),
                          suffixIcon: zoektekst.trim().isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Zoekopdracht wissen',
                                  onPressed: () {
                                    zoekController.clear();
                                    setDialogState(() {
                                      zoektekst = '';
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                  ),
                                ),
                          isDense: true,
                          filled: true,
                          fillColor: const Color(0xFFF8FAF9),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 11,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: _rand),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: _accent,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 11),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 430),
                        child: klantNamen.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 28),
                                  child: Text(
                                    'Geen klant gevonden.',
                                    style: TextStyle(
                                      color: _tekstGrijs,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                itemCount: klantNamen.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final klantNaam = klantNamen[index];
                                  final klantBestanden =
                                      List<_OpmetingProjectBestandKeuze>.from(
                                        perKlant[klantNaam]!,
                                      )..sort((a, b) {
                                        final naam = a.bestandsNaam
                                            .toLowerCase()
                                            .compareTo(
                                              b.bestandsNaam.toLowerCase(),
                                            );
                                        if (naam != 0) return naam;
                                        return a.versieNummer.compareTo(
                                          b.versieNummer,
                                        );
                                      });
                                  final isOpen = openKlanten.contains(
                                    klantNaam,
                                  );

                                  DateTime? oudsteDatum;
                                  for (final bestand in klantBestanden) {
                                    final datum = DateTime.tryParse(
                                      bestand.aangemaaktOp.trim(),
                                    );
                                    if (datum != null &&
                                        (oudsteDatum == null ||
                                            datum.isBefore(oudsteDatum))) {
                                      oudsteDatum = datum;
                                    }
                                  }
                                  final klantDatum = oudsteDatum == null
                                      ? ''
                                      : _formatteerBestandDatum(
                                          oudsteDatum.toIso8601String(),
                                        );

                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(11),
                                      border: Border.all(color: _rand),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        InkWell(
                                          onTap: () {
                                            setDialogState(() {
                                              if (isOpen) {
                                                openKlanten.remove(klantNaam);
                                              } else {
                                                openKlanten.add(klantNaam);
                                              }
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                            color: _achtergrond,
                                            child: Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.person_outline,
                                                  color: wissen
                                                      ? _rood
                                                      : _tekstDonker,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    klantNaam,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: wissen
                                                          ? _rood
                                                          : _tekstDonker,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                    ),
                                                  ),
                                                ),
                                                if (klantDatum
                                                    .isNotEmpty) ...<Widget>[
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    klantDatum,
                                                    style: const TextStyle(
                                                      color: _tekstGrijs,
                                                      fontSize: 10.5,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                                const SizedBox(width: 5),
                                                Icon(
                                                  isOpen
                                                      ? Icons
                                                            .expand_less_rounded
                                                      : Icons
                                                            .expand_more_rounded,
                                                  color: wissen
                                                      ? _rood
                                                      : _tekstGrijs,
                                                  size: 20,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (isOpen)
                                          for (
                                            var i = 0;
                                            i < klantBestanden.length;
                                            i++
                                          ) ...<Widget>[
                                            if (i > 0)
                                              const Divider(
                                                height: 1,
                                                color: _rand,
                                              ),
                                            InkWell(
                                              onTap: () => Navigator.pop(
                                                dialogContext,
                                                klantBestanden[i],
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 10,
                                                    ),
                                                child: Row(
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons
                                                          .description_outlined,
                                                      color: wissen
                                                          ? _rood
                                                          : _tekstDonker,
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 9),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Text(
                                                            '${klantBestanden[i].bestandsNaam}  V${klantBestanden[i].versieNummer}',
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: const TextStyle(
                                                              color:
                                                                  _tekstDonker,
                                                              fontSize: 12.5,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                            ),
                                                          ),
                                                          _bouwBestandDatumRegel(
                                                            klantBestanden[i],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      '${klantBestanden[i].aantalPosities} pos.',
                                                      style: const TextStyle(
                                                        color: _tekstGrijs,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Icon(
                                                      Icons
                                                          .chevron_right_rounded,
                                                      color: wissen
                                                          ? _rood
                                                          : _tekstGrijs,
                                                      size: 17,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                actionsPadding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                actions: <Widget>[
                  ThimacoTekstActie(
                    tekst: 'Annuleren',
                    onPressed: () => Navigator.pop(dialogContext),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      zoekController.dispose();
    }
  }

  Widget _bouwBestandDatumRegel(_OpmetingProjectBestandKeuze bestand) {
    final datum = _formatteerBestandDatum(bestand.aangemaaktOp);
    if (datum.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        'Aangemaakt $datum',
        style: const TextStyle(
          color: _tekstGrijs,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<String?> _vraagNieuweBestandsNaam({
    required String titel,
    required String beginNaam,
    String klantNaam = '',
    String bevestigTekst = 'Opslaan als',
  }) async {
    final controller = TextEditingController(text: beginNaam);
    final resultaat = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _rand),
          ),
          titlePadding: EdgeInsets.zero,
          title: _bouwBestandDialoogKop(
            titel: titel,
            icoon: Icons.drive_file_rename_outline,
          ),
          contentPadding: const EdgeInsets.fromLTRB(16, 15, 16, 4),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (klantNaam.trim().isNotEmpty) ...<Widget>[
                  const Text(
                    'Klant',
                    style: TextStyle(
                      color: _tekstDonker,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _achtergrond,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: _rand),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.person_outline,
                          color: _tekstDonker,
                          size: 17,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            klantNaam.trim(),
                            style: const TextStyle(
                              color: _tekstDonker,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.lock_outline,
                          color: _tekstGrijs,
                          size: 15,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  cursorColor: _accent,
                  decoration: InputDecoration(
                    labelText: 'Naam offerte',
                    hintText: 'bv. Ramen + voordeur',
                    filled: true,
                    fillColor: const Color(0xFFF8FAF9),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _rand),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _accent, width: 1.4),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onSubmitted: (waarde) {
                    final naam = waarde.trim();
                    if (naam.isNotEmpty) Navigator.pop(dialogContext, naam);
                  },
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          actions: <Widget>[
            ThimacoTekstActie(
              tekst: 'Annuleren',
              onPressed: () => Navigator.pop(dialogContext),
            ),
            ThimacoTekstActie(
              tekst: bevestigTekst,
              onPressed: () {
                final naam = controller.text.trim();
                if (naam.isNotEmpty) Navigator.pop(dialogContext, naam);
              },
            ),
          ],
        );
      },
    );
    controller.dispose();
    return resultaat?.trim();
  }

  Future<void> wisBestand() async {
    final klantNaam = leesKlantNaam().trim();
    if (klantNaam.isEmpty || leesTitelhoofd().projectBestandId.trim().isEmpty) {
      toonMelding('Open eerst een project.', true);
      return;
    }

    final alleBestanden = await _laadProjectBestandKeuzes();
    if (!isMounted()) return;
    final klantSleutel = opmetingKlantNaamSleutel(klantNaam);
    final bestanden =
        alleBestanden
            .where((bestand) {
              return opmetingKlantNaamSleutel(bestand.klantNaam) ==
                  klantSleutel;
            })
            .toList(growable: false)
          ..sort(
            (a, b) => a.bestandsNaam.toLowerCase().compareTo(
              b.bestandsNaam.toLowerCase(),
            ),
          );

    if (bestanden.isEmpty) {
      toonMelding(
        'Voor $klantNaam zijn geen opgeslagen bestanden gevonden.',
        true,
      );
      return;
    }

    final actie = await _vraagWisActie(
      klantNaam: klantNaam,
      bestanden: bestanden,
    );
    if (actie == null || !isMounted()) return;

    if (actie.wisAlleBestanden) {
      final bevestigd = await _bevestigAlleBestandenWissen(
        klantNaam: klantNaam,
        aantalBestanden: bestanden.length,
      );
      if (bevestigd != true || !isMounted()) return;
      await _wisProjectBestanden(bestanden, wisHeleKlant: true);
      return;
    }

    final gekozen = actie.bestand;
    if (gekozen == null) return;
    final bevestigd = await _bevestigBestandWissen(gekozen);
    if (bevestigd != true || !isMounted()) return;
    await _wisProjectBestanden(<_OpmetingProjectBestandKeuze>[gekozen]);
  }

  Future<_WisProjectActie?> _vraagWisActie({
    required String klantNaam,
    required List<_OpmetingProjectBestandKeuze> bestanden,
  }) {
    return showDialog<_WisProjectActie>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _rand),
          ),
          titlePadding: EdgeInsets.zero,
          title: _bouwBestandDialoogKop(
            titel: 'Wissen · $klantNaam',
            icoon: Icons.delete_outline_rounded,
            destructief: true,
          ),
          contentPadding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
          content: SizedBox(
            width: 500,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 430),
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: _achtergrond,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _rand),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.person_outline,
                          color: _tekstDonker,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            klantNaam,
                            style: const TextStyle(
                              color: _tekstDonker,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 9),
                  for (final bestand in bestanden) ...<Widget>[
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => Navigator.pop(
                        dialogContext,
                        _WisProjectActie.bestand(bestand),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Row(
                          children: <Widget>[
                            const Icon(
                              Icons.description_outlined,
                              color: _rood,
                              size: 17,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${bestand.bestandsNaam}  V${bestand.versieNummer}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _tekstDonker,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Text(
                              '${bestand.aantalPosities} pos.',
                              style: const TextStyle(
                                color: _tekstGrijs,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.delete_outline_rounded,
                              color: _rood,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                  ],
                  const SizedBox(height: 4),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => Navigator.pop(
                      dialogContext,
                      const _WisProjectActie.alleBestanden(),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7F7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Icons.delete_forever_outlined,
                            color: _rood,
                            size: 19,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Alle bestanden van $klantNaam wissen',
                              style: const TextStyle(
                                color: _rood,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
          actions: <Widget>[
            ThimacoTekstActie(
              tekst: 'Annuleren',
              onPressed: () => Navigator.pop(dialogContext),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _bevestigBestandWissen(_OpmetingProjectBestandKeuze gekozen) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _rand),
          ),
          titlePadding: EdgeInsets.zero,
          title: _bouwBestandDialoogKop(
            titel: 'Bestand definitief wissen?',
            icoon: Icons.warning_amber_rounded,
            destructief: true,
          ),
          contentPadding: const EdgeInsets.fromLTRB(16, 15, 16, 4),
          content: SizedBox(
            width: 430,
            child: Text(
              '“${gekozen.bestandsNaam} V${gekozen.versieNummer}” van ${gekozen.klantNaam} en alle ${gekozen.aantalPosities} positie(s) worden definitief verwijderd. De klantenfiche zelf blijft behouden.',
              style: const TextStyle(
                color: _tekstDonker,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          actions: <Widget>[
            ThimacoTekstActie(
              tekst: 'Annuleren',
              onPressed: () => Navigator.pop(dialogContext, false),
            ),
            ThimacoTekstActie(
              tekst: 'Definitief wissen',
              destructief: true,
              onPressed: () => Navigator.pop(dialogContext, true),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _bevestigAlleBestandenWissen({
    required String klantNaam,
    required int aantalBestanden,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _rand),
          ),
          titlePadding: EdgeInsets.zero,
          title: _bouwBestandDialoogKop(
            titel: 'Volledige klantmap wissen?',
            icoon: Icons.warning_amber_rounded,
            destructief: true,
          ),
          contentPadding: const EdgeInsets.fromLTRB(16, 15, 16, 4),
          content: SizedBox(
            width: 440,
            child: Text(
              'Alle $aantalBestanden opmeet-/offertebestanden van $klantNaam worden definitief verwijderd. De klantenfiche zelf wordt niet verwijderd.',
              style: const TextStyle(
                color: _tekstDonker,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          actions: <Widget>[
            ThimacoTekstActie(
              tekst: 'Annuleren',
              onPressed: () => Navigator.pop(dialogContext, false),
            ),
            ThimacoTekstActie(
              tekst: 'Alles definitief wissen',
              destructief: true,
              onPressed: () => Navigator.pop(dialogContext, true),
            ),
          ],
        );
      },
    );
  }

  Future<void> _wisProjectBestanden(
    List<_OpmetingProjectBestandKeuze> bestanden, {
    bool wisHeleKlant = false,
  }) async {
    if (bestanden.isEmpty) return;
    zetLaden(true);

    final projectIds = bestanden
        .map((bestand) => bestand.projectBestandId)
        .toSet();
    final alleOpmetingen = await AppStorage.laadOpmetingenVoorSync();
    final idsTeWissen = <String>{
      for (final opmeting in alleOpmetingen)
        if (!opmeting.isVerwijderd &&
            projectIds.contains(
              opmeting.projectBestandId.trim().isNotEmpty
                  ? opmeting.projectBestandId.trim()
                  : opmetingLegacyProjectBestandId(opmeting.klantNaam),
            ))
          opmeting.id,
    };

    if (idsTeWissen.isNotEmpty) {
      await AppStorage.verwijderOpmetingen(idsTeWissen, startSync: false);
    }

    for (final bestand in bestanden) {
      final titelhoofd = await AppStorage.laadOpmetingProjectTitelhoofd(
        bestand.klantNaam,
        projectBestandId: bestand.projectBestandId,
      );
      await AppStorage.bewaarOpmetingProjectTitelhoofd(
        titelhoofd
            .copyWith(projectBestandVerwijderd: true)
            .metWijzigingsDatum(),
      );
    }

    final huidigProjectId = leesTitelhoofd().projectBestandId.trim();
    if (wisHeleKlant || projectIds.contains(huidigProjectId)) {
      artikelPrijscorrectieController.wisDoelSelecties();
      vervangProjectState(
        '',
        const OpmetingProjectTitelhoofd(),
        <OpmetingOverzichtRaamItem>[],
        <String>{},
        false,
      );
    } else if (huidigProjectId.isNotEmpty) {
      await laadOpmetingenVanOpslag(
        klantNaam: leesKlantNaam(),
        projectBestandId: huidigProjectId,
      );
    }

    if (!isMounted()) return;
    final melding = wisHeleKlant
        ? 'Alle bestanden van ${bestanden.first.klantNaam} zijn lokaal gewist.'
        : '“${bestanden.first.bestandsNaam} V${bestanden.first.versieNummer}” is lokaal gewist.';
    toonMelding(melding, false);
  }

  Future<bool> bewaarBestandLokaal({bool toonMeldingNaOpslaan = false}) async {
    await projectTitelhoofdController.bewaarOpenstaandeWijzigingenNu();
    if (!isMounted()) return false;

    final titelhoofd = leesTitelhoofd();
    final klantNaam = leesKlantNaam().trim();
    final projectId = titelhoofd.projectBestandId.trim();

    if (klantNaam.isEmpty || projectId.isEmpty) {
      if (toonMeldingNaOpslaan) {
        toonMelding('Er is geen opmeetbestand geopend.', true);
      }
      return false;
    }

    await AppStorage.bewaarOpmetingProjectTitelhoofd(
      titelhoofd
          .copyWith(
            klantNaam: klantNaam,
            projectReeksId: titelhoofd.effectieveProjectReeksId,
            bestandVersieNummer: titelhoofd.veiligeBestandVersieNummer,
            aangemaaktOp: titelhoofd.aangemaaktOp.trim().isEmpty
                ? DateTime.now().toUtc().toIso8601String()
                : titelhoofd.aangemaaktOp,
            offerteVersie:
                OpmetingProjectTitelhoofd.offerteVersieVoorBestandVersieNummer(
                  titelhoofd.veiligeBestandVersieNummer,
                ),
            projectBestandVerwijderd: false,
          )
          .metWijzigingsDatum(),
    );

    if (toonMeldingNaOpslaan && isMounted()) {
      final naam = titelhoofd.bestandsNaam.trim().isEmpty
          ? 'Opmeetbestand'
          : '“${titelhoofd.bestandsNaam.trim()} V${titelhoofd.veiligeBestandVersieNummer}”';
      toonMelding('$naam lokaal opgeslagen.', false);
    }
    return true;
  }

  Future<bool> opslaanBestand({bool toonMeldingNaOpslaan = true}) async {
    final lokaalOpgeslagen = await bewaarBestandLokaal();
    if (!lokaalOpgeslagen || !isMounted()) return false;

    final titelhoofd = leesTitelhoofd();
    await OneDriveSyncService.registreerLokaleWijziging();
    final syncResultaat = await OneDriveSyncService().slimmeSync();
    if (!isMounted()) return false;

    final syncOk = _isSyncGeslaagd(syncResultaat);
    if (toonMeldingNaOpslaan) {
      final naam = titelhoofd.bestandsNaam.trim().isEmpty
          ? 'Opmeetbestand'
          : '“${titelhoofd.bestandsNaam.trim()} V${titelhoofd.veiligeBestandVersieNummer}”';
      toonMelding(
        syncOk
            ? '$naam opgeslagen en gesynchroniseerd.'
            : '$naam lokaal opgeslagen, maar synchronisatie is niet gelukt: $syncResultaat',
        !syncOk,
      );
    }
    return syncOk;
  }

  Future<void> opslaanAlsBestand() async {
    final huidigTitelhoofd = leesTitelhoofd();
    final klantNaam = leesKlantNaam().trim();
    final huidigProjectId = huidigTitelhoofd.projectBestandId.trim();
    if (klantNaam.isEmpty || huidigProjectId.isEmpty) {
      toonMelding('Open eerst een opmeetbestand.', true);
      return;
    }

    final nieuweNaam = await _vraagNieuweBestandsNaam(
      titel: 'Opslaan als',
      beginNaam: huidigTitelhoofd.bestandsNaam.trim(),
      klantNaam: klantNaam,
      bevestigTekst: 'Opslaan als',
    );
    if (nieuweNaam == null || nieuweNaam.isEmpty || !isMounted()) return;

    await _kopieerHuidigProjectAls(
      nieuweNaam: nieuweNaam,
      actieNaam: 'Opslaan als',
      synchroniseerNaOpslaan: true,
    );
  }

  bool _isSyncGeslaagd(String syncResultaat) {
    return !syncResultaat.startsWith('FOUT') &&
        !syncResultaat.contains('FOUT') &&
        !syncResultaat.contains('OVERGESLAGEN');
  }

  Future<void> eindeOpmeting() async {
    final huidigeContext = context;
    if (!isMounted() || !huidigeContext.mounted) return;

    if (_heeftOpenProject) {
      await bewaarBestandLokaal(toonMeldingNaOpslaan: false);
      if (!isMounted() || !huidigeContext.mounted) return;
    }

    await Navigator.of(huidigeContext).maybePop();
  }
}

class _NieuweOpmetingKlantResultaat {
  const _NieuweOpmetingKlantResultaat({
    required this.klantNaam,
    required this.bestandsNaam,
    this.klantFiche,
  });

  final String klantNaam;
  final String bestandsNaam;
  final OpmetingAgendaKlantInfo? klantFiche;
}

class _OpmetingProjectBestandKeuze {
  const _OpmetingProjectBestandKeuze({
    required this.klantNaam,
    required this.projectBestandId,
    required this.bestandsNaam,
    required this.projectReeksId,
    required this.versieNummer,
    required this.aangemaaktOp,
    required this.aantalPosities,
  });

  final String klantNaam;
  final String projectBestandId;
  final String bestandsNaam;
  final String projectReeksId;
  final int versieNummer;
  final String aangemaaktOp;
  final int aantalPosities;
}

class _WisProjectActie {
  const _WisProjectActie.bestand(this.bestand) : wisAlleBestanden = false;
  const _WisProjectActie.alleBestanden()
    : bestand = null,
      wisAlleBestanden = true;

  final _OpmetingProjectBestandKeuze? bestand;
  final bool wisAlleBestanden;
}

class _KlantNaamDialog extends StatefulWidget {
  const _KlantNaamDialog({required this.beginNaam, required this.klanten});

  final String beginNaam;
  final List<OpmetingAgendaKlantInfo> klanten;

  @override
  State<_KlantNaamDialog> createState() {
    return _KlantNaamDialogState();
  }
}

class _KlantNaamDialogState extends State<_KlantNaamDialog> {
  static const Color _accent = ThimacoKleuren.oranje;
  static const Color _accentLicht = ThimacoKleuren.oranjeLicht;
  static const Color _rand = ThimacoKleuren.rand;
  static const Color _veldAchtergrond = Color(0xFFF8FAF9);
  static const Color _tekstDonker = ThimacoKleuren.antraciet;
  static const Color _tekstGrijs = ThimacoKleuren.tekstGrijs;

  late final TextEditingController _controller;
  late final TextEditingController _bestandsNaamController;
  late final FocusNode _naamFocusNode;
  late final FocusNode _bestandsNaamFocusNode;
  OpmetingAgendaKlantInfo? _geselecteerdeKlant;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.beginNaam);
    _bestandsNaamController = TextEditingController();
    _naamFocusNode = FocusNode();
    _bestandsNaamFocusNode = FocusNode();
    _geselecteerdeKlant = _vindExacteKlant(widget.beginNaam);
  }

  @override
  void dispose() {
    _naamFocusNode.dispose();
    _bestandsNaamFocusNode.dispose();
    _controller.dispose();
    _bestandsNaamController.dispose();
    super.dispose();
  }

  String _normaliseerZoektekst(String waarde) {
    return waarde.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _klantWaarde(OpmetingAgendaKlantInfo klant) {
    return _normaliseerZoektekst(klant.klantNaam);
  }

  OpmetingAgendaKlantInfo? _vindExacteKlant(String waarde) {
    final sleutel = _normaliseerZoektekst(waarde);
    if (sleutel.isEmpty) return null;

    for (final klant in widget.klanten) {
      if (_klantWaarde(klant) == sleutel ||
          _normaliseerZoektekst(klant.klantNaamMetAanspreking) == sleutel) {
        return klant;
      }
    }

    return null;
  }

  Iterable<OpmetingAgendaKlantInfo> _bouwSuggesties(TextEditingValue invoer) {
    final zoektekst = _normaliseerZoektekst(invoer.text);
    if (zoektekst.isEmpty) {
      return const <OpmetingAgendaKlantInfo>[];
    }

    final zoekDelen = zoektekst.split(' ');
    final suggesties = widget.klanten.where((klant) {
      final zoekveld = _normaliseerZoektekst(
        <String>[
          klant.klantNaam,
          klant.klantNaamMetAanspreking,
          klant.klantnummer,
          klant.adresRegel,
          klant.plaats,
          klant.email,
        ].where((deel) => deel.trim().isNotEmpty).join(' '),
      );

      return zoekDelen.every(zoekveld.contains);
    }).toList();

    int score(OpmetingAgendaKlantInfo klant) {
      final naam = _klantWaarde(klant);
      if (naam == zoektekst) return 0;
      if (naam.startsWith(zoektekst)) return 1;
      if (naam.split(' ').any((deel) => deel.startsWith(zoektekst))) return 2;
      return 3;
    }

    suggesties.sort((eerste, tweede) {
      final scoreVergelijking = score(eerste).compareTo(score(tweede));
      if (scoreVergelijking != 0) return scoreVergelijking;

      return eerste.klantNaam.toLowerCase().compareTo(
        tweede.klantNaam.toLowerCase(),
      );
    });

    return suggesties.take(10);
  }

  String _klantSubtitel(OpmetingAgendaKlantInfo klant) {
    return <String>[
      klant.adresRegel,
      klant.plaats,
      if (klant.klantnummer.trim().isNotEmpty)
        'Klantnr. ${klant.klantnummer.trim()}',
    ].where((deel) => deel.trim().isNotEmpty).join(' · ');
  }

  void _selecteerKlant(OpmetingAgendaKlantInfo klant) {
    setState(() {
      _geselecteerdeKlant = klant;
      _controller.text = klant.klantNaam;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    });
  }

  void _verwerkNaamWijziging(String waarde) {
    final exacteKlant = _vindExacteKlant(waarde);
    if (identical(exacteKlant, _geselecteerdeKlant)) return;

    setState(() {
      _geselecteerdeKlant = exacteKlant;
    });
  }

  void _aanmaken() {
    final naam = _controller.text.trim();
    final bestandsNaam = _bestandsNaamController.text.trim();
    if (naam.isEmpty) {
      _naamFocusNode.requestFocus();
      return;
    }
    if (bestandsNaam.isEmpty) {
      _bestandsNaamFocusNode.requestFocus();
      return;
    }

    final klantFiche = _vindExacteKlant(naam) ?? _geselecteerdeKlant;
    final gekozenNaam =
        klantFiche == null || klantFiche.klantNaam.trim().isEmpty
        ? naam
        : klantFiche.klantNaam.trim();

    Navigator.of(context).pop(
      _NieuweOpmetingKlantResultaat(
        klantNaam: gekozenNaam,
        bestandsNaam: bestandsNaam,
        klantFiche: klantFiche,
      ),
    );
  }

  InputDecoration _compacteVeldDecoratie({
    required String hintText,
    required IconData icoon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: _tekstGrijs,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(icoon, color: _tekstGrijs, size: 17),
      prefixIconConstraints: const BoxConstraints(minWidth: 37, minHeight: 38),
      isDense: true,
      filled: true,
      fillColor: _veldAchtergrond,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: _rand),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: _accent, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: _rand),
      ),
    );
  }

  Widget _veldTitel(String tekst) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 5),
      child: Text(
        tekst,
        style: const TextStyle(
          color: _tekstDonker,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final basisTheme = Theme.of(context);
    final geselecteerde = _geselecteerdeKlant;
    final adres = geselecteerde == null
        ? ''
        : <String>[
            geselecteerde.adresRegel,
            geselecteerde.plaats,
          ].where((deel) => deel.trim().isNotEmpty).join(', ');

    return Theme(
      data: basisTheme.copyWith(
        colorScheme: basisTheme.colorScheme.copyWith(
          primary: _accent,
          secondary: _accent,
          surface: Colors.white,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: _accent,
          selectionHandleColor: _accent,
        ),
      ),
      child: AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _rand),
        ),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.fromLTRB(16, 11, 12, 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            border: Border(bottom: BorderSide(color: _rand)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.note_add_outlined,
                  color: _tekstDonker,
                  size: 19,
                ),
              ),
              SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Nieuw project',
                      style: TextStyle(
                        color: _tekstDonker,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    SizedBox(
                      width: 34,
                      child: Divider(
                        height: 1.5,
                        thickness: 1.5,
                        color: _accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _veldTitel('Klant uit klantenfiche of blauwe agenda'),
              DropdownButtonFormField<String>(
                initialValue: geselecteerde == null
                    ? null
                    : _klantWaarde(geselecteerde),
                isExpanded: true,
                menuMaxHeight: 420,
                style: const TextStyle(
                  color: _tekstDonker,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
                hint: Text(
                  widget.klanten.isEmpty
                      ? 'Geen klanten gevonden'
                      : 'Selecteer een klant',
                ),
                decoration: _compacteVeldDecoratie(
                  hintText: widget.klanten.isEmpty
                      ? 'Geen klanten gevonden'
                      : 'Selecteer een klant',
                  icoon: Icons.badge_outlined,
                ),
                items: widget.klanten
                    .map<DropdownMenuItem<String>>((klant) {
                      return DropdownMenuItem<String>(
                        value: _klantWaarde(klant),
                        child: Text(
                          klant.klantNaamMetAanspreking,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    })
                    .toList(growable: false),
                onChanged: widget.klanten.isEmpty
                    ? null
                    : (waarde) {
                        if (waarde == null) return;

                        final klant = widget.klanten.firstWhere(
                          (item) => _klantWaarde(item) == waarde,
                        );
                        _selecteerKlant(klant);
                      },
              ),
              const SizedBox(height: 11),
              _veldTitel('Naam klant'),
              LayoutBuilder(
                builder: (context, constraints) {
                  return RawAutocomplete<OpmetingAgendaKlantInfo>(
                    textEditingController: _controller,
                    focusNode: _naamFocusNode,
                    displayStringForOption: (klant) => klant.klantNaam,
                    optionsBuilder: _bouwSuggesties,
                    onSelected: _selecteerKlant,
                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            autofocus: true,
                            cursorColor: _accent,
                            textCapitalization: TextCapitalization.words,
                            style: const TextStyle(
                              color: _tekstDonker,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: _compacteVeldDecoratie(
                              hintText: widget.klanten.isEmpty
                                  ? 'Typ een nieuwe klantnaam'
                                  : 'Typ enkele letters voor suggesties',
                              icoon: Icons.search_outlined,
                            ),
                            onChanged: _verwerkNaamWijziging,
                            onSubmitted: (_) {
                              _bestandsNaamFocusNode.requestFocus();
                            },
                          );
                        },
                    optionsViewBuilder: (context, onSelected, opties) {
                      final suggesties = opties.toList(growable: false);

                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 8,
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          clipBehavior: Clip.antiAlias,
                          child: SizedBox(
                            width: constraints.maxWidth,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 280),
                              child: ListView.separated(
                                padding: const EdgeInsets.all(5),
                                shrinkWrap: true,
                                itemCount: suggesties.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 4),
                                itemBuilder: (context, index) {
                                  final klant = suggesties[index];
                                  final gemarkeerd =
                                      AutocompleteHighlightedOption.of(
                                        context,
                                      ) ==
                                      index;
                                  final subtitel = _klantSubtitel(klant);

                                  return InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () => onSelected(klant),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: gemarkeerd
                                            ? _accentLicht
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: _rand),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          const Padding(
                                            padding: EdgeInsets.only(top: 1),
                                            child: Icon(
                                              Icons.person_outline,
                                              color: _tekstDonker,
                                              size: 17,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  klant.klantNaamMetAanspreking,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: _tekstDonker,
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                                if (subtitel
                                                    .isNotEmpty) ...<Widget>[
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    subtitel,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: _tekstGrijs,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 11),
              _veldTitel('Naam offerte'),
              TextField(
                controller: _bestandsNaamController,
                focusNode: _bestandsNaamFocusNode,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(
                  color: _tekstDonker,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
                decoration: _compacteVeldDecoratie(
                  hintText: 'bv. Ramen volledige woning',
                  icoon: Icons.description_outlined,
                ),
                onSubmitted: (_) => _aanmaken(),
              ),
              if (geselecteerde != null) ...<Widget>[
                const SizedBox(height: 11),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: _veldAchtergrond,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: _rand),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(
                        Icons.person_outline,
                        color: _tekstDonker,
                        size: 17,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              geselecteerde.klantNaamMetAanspreking,
                              style: const TextStyle(
                                color: _tekstDonker,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            if (geselecteerde.klantnummer.trim().isNotEmpty)
                              Text(
                                'Klantnr. ${geselecteerde.klantnummer.trim()}',
                                style: const TextStyle(
                                  color: _tekstGrijs,
                                  fontSize: 11,
                                ),
                              ),
                            if (adres.isNotEmpty)
                              Text(
                                adres,
                                style: const TextStyle(
                                  color: _tekstGrijs,
                                  fontSize: 11,
                                ),
                              ),
                            if (geselecteerde.gsm.trim().isNotEmpty)
                              Text(
                                geselecteerde.gsm.trim(),
                                style: const TextStyle(
                                  color: _tekstGrijs,
                                  fontSize: 11,
                                ),
                              ),
                            if (geselecteerde.email.trim().isNotEmpty)
                              Text(
                                geselecteerde.email.trim(),
                                style: const TextStyle(
                                  color: _tekstGrijs,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        actions: <Widget>[
          ThimacoTekstActie(
            tekst: 'Annuleren',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ThimacoTekstActie(tekst: 'Aanmaken', onPressed: _aanmaken),
        ],
      ),
    );
  }
}
