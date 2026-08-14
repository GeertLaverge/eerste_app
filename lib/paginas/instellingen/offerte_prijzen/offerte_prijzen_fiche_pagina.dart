// THIMACO-CONTROLE: PRIJSARCHITECTUUR-STAP5D4B4A-ANALYZERFIX-ONGEBRUIKTE-HELPERS-WEG-20260814
// THIMACO-CONTROLE: PRIJSARCHITECTUUR-STAP5D4B2-PRIJZENFICHE-ZONDER-OUDE-VRIJE-MODUS-20260814
// THIMACO-CONTROLE: PRIJSARCHITECTUUR-OPRUIMEN-STAP5C-FICHE-ZONDER-VERDEELKOST-20260814
// THIMACO-CONTROLE: OFFERTE-PRIJZEN-FICHE-DOWNLOADSIGNAAL-FASE17-20260805
// THIMACO-CONTROLE: VOORZETSCREEN-INBOUWSCHAKELAAR-TECHNISCHE-PRIJSBOOM-20260730-2205
// THIMACO-CONTROLE: VELUX-TECHNISCHE-PRIJSBOOM-ACTIEF-20260730
// THIMACO-CONTROLE: VELUX-GEEN-TECHNISCHE-PRIJSKEUZES-FASE-4-20260729-2257
// THIMACO-CONTROLE: SCHUIFVLIEGENDEUR-INSTELLINGEN-EN-PRIJZEN-20260728
// THIMACO-CONTROLE: GEKOPPELDE-TECHNISCHE-PRIJSREGELS-FASE-4-20260727
// THIMACO-CONTROLE: TECHNISCHE-PRIJS-OVERNEMEN-FASE-3-20260727
// THIMACO-CONTROLE: TECHNISCHE-PRIJSKEUZE-ANDERE-ARTIKELTYPES-FASE-2-20260727
// THIMACO-CONTROLE: TECHNISCHE-PRIJSKEUZE-BOOM-FASE-1-20260726
// THIMACO-CONTROLE: VRIJE-PRIJS-PER-ARTIKEL-APARTE-MODUS-20260726
// THIMACO-CONTROLE: GEDEELDE-VERDEELKOSTEN-PRIJSFICHE-20260723
import 'package:flutter/material.dart';

import '../../../helpers/app_storage.dart';
import '../../../helpers/offerte/prijzen/offerte_artikel_prijs_koppeling_service.dart';
import '../../../helpers/offerte/prijzen/offerte_prijs_categorie.dart';
import '../../../helpers/offerte/prijzen/offerte_prijsprofiel_model.dart';
import '../../../helpers/offerte/prijzen/offerte_prijsregel_model.dart';
import '../../../helpers/offerte/prijzen/offerte_technische_keuze_laad_helper.dart';
import '../../../helpers/offerte/prijzen/offerte_technische_keuze_ref.dart';
import '../../../helpers/offerte/prijzen/offerte_technische_prijs_koppeling_service.dart';
import '../../../helpers/sync/sync_navigatie_helper.dart';
import 'offerte_prijsregel_dialog.dart';
import 'offerte_technische_prijs_overnemen_dialog.dart';
import 'offerte_technische_prijskeuze_boom.dart';

class OffertePrijzenFichePagina extends StatefulWidget {
  const OffertePrijzenFichePagina({
    super.key,
    required this.formulierType,
    required this.formulierNaam,
  });

  final String formulierType;
  final String formulierNaam;

  @override
  State<OffertePrijzenFichePagina> createState() {
    return _OffertePrijzenFichePaginaState();
  }
}

class _OffertePrijzenFichePaginaState extends State<OffertePrijzenFichePagina> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _achtergrond = Color(0xFFF7F8FA);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  OffertePrijsprofielModel? _profiel;

  List<OfferteTechnischeKeuzeRef> _technischeKeuzes =
      const <OfferteTechnischeKeuzeRef>[];

  List<OffertePrijsregelModel> _andereTechnischePrijsregels =
      const <OffertePrijsregelModel>[];

  Map<String, int> _technischePrijsregelKoppelAantallen = const <String, int>{};

  bool _laden = true;
  bool _opslaan = false;
  bool _downloadHerladenUitgesteld = false;
  bool _herladenNaSync = false;
  bool _nogmaalsHerladenNaSync = false;
  int _laatsteVerwerkteDownloadVersie = 0;
  String? _foutmelding;

  bool get _isVasteInzethor {
    return _normaliseerFormulierType(widget.formulierType) ==
        _normaliseerFormulierType('vasteInzethor');
  }

  bool get _isVliegendeur {
    final formulierType = _normaliseerFormulierType(widget.formulierType);
    return formulierType == 'vliegendeur' || formulierType == 'vliegdeur';
  }

  bool get _isSchuifvliegendeur {
    return _normaliseerFormulierType(widget.formulierType) ==
        _normaliseerFormulierType('schuifvliegendeur');
  }

  bool get _heeftGeenTechnischeKeuzes {
    return _isVasteInzethor || _isVliegendeur || _isSchuifvliegendeur;
  }

  String get _paginaTitel {
    return 'Prijs volgens technische keuze · ${widget.formulierNaam}';
  }

  String get _paginaUitleg {
    return 'Kies rechtstreeks een technisch kenmerk van '
        '${widget.formulierNaam}. Tik op een keuze om een prijs in te stellen '
        'of de bestaande prijsregel te wijzigen.';
  }

  @override
  void initState() {
    super.initState();

    _laatsteVerwerkteDownloadVersie = SyncNavigatieHelper.downloadVersie.value;
    SyncNavigatieHelper.downloadVersie.addListener(_verwerkAchtergrondDownload);

    _laadProfiel();
  }

  @override
  void dispose() {
    SyncNavigatieHelper.downloadVersie.removeListener(
      _verwerkAchtergrondDownload,
    );
    super.dispose();
  }

  void _verwerkAchtergrondDownload() {
    final nieuweVersie = SyncNavigatieHelper.downloadVersie.value;

    if (nieuweVersie <= _laatsteVerwerkteDownloadVersie) {
      return;
    }

    _laatsteVerwerkteDownloadVersie = nieuweVersie;

    if (_opslaan) {
      _downloadHerladenUitgesteld = true;
      return;
    }

    _herlaadNaSync();
  }

  Future<void> _herlaadNaSync() async {
    if (_herladenNaSync) {
      _nogmaalsHerladenNaSync = true;
      return;
    }

    _herladenNaSync = true;

    try {
      do {
        _nogmaalsHerladenNaSync = false;
        await _laadProfiel(toonLaden: false);
      } while (_nogmaalsHerladenNaSync && mounted);
    } finally {
      _herladenNaSync = false;
    }
  }

  Future<void> _laadProfiel({bool toonLaden = true}) async {
    if (toonLaden && mounted) {
      setState(() {
        _laden = true;
        _foutmelding = null;
      });
    }

    try {
      final bestaand = await AppStorage.laadOffertePrijsProfiel(
        widget.formulierType,
      );

      final profiel =
          bestaand ??
          OffertePrijsprofielModel.leeg(
            formulierType: widget.formulierType,
            formulierNaam: widget.formulierNaam,
          );

      final technischeKeuzes = _heeftGeenTechnischeKeuzes
          ? const <OfferteTechnischeKeuzeRef>[]
          : await OfferteTechnischeKeuzeLaadHelper.laadVoorFormulierTypeInBoomVolgorde(
              widget.formulierType,
            );

      if (bestaand == null) {
        await AppStorage.bewaarOffertePrijsProfiel(profiel);
      }

      final andereTechnischePrijsregels = _heeftGeenTechnischeKeuzes
          ? const <OffertePrijsregelModel>[]
          : await _laadAndereTechnischePrijsregels(huidigProfiel: profiel);

      final technischePrijsregelKoppelAantallen = _heeftGeenTechnischeKeuzes
          ? const <String, int>{}
          : await OfferteTechnischePrijsKoppelingService.laadKoppelAantallen();

      if (!mounted) {
        return;
      }

      setState(() {
        _profiel = profiel;
        _technischeKeuzes = technischeKeuzes;
        _andereTechnischePrijsregels = andereTechnischePrijsregels;
        _technischePrijsregelKoppelAantallen =
            technischePrijsregelKoppelAantallen;
        _laden = false;
        _foutmelding = null;
        _downloadHerladenUitgesteld = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _laden = false;
        _foutmelding = 'Het prijsprofiel kon niet worden geladen: $e';
      });
    }
  }

  Future<List<OffertePrijsregelModel>> _laadAndereTechnischePrijsregels({
    required OffertePrijsprofielModel huidigProfiel,
  }) async {
    final profielen = await AppStorage.laadOffertePrijsProfielen();
    final resultaat = <OffertePrijsregelModel>[];

    for (final profiel in profielen) {
      if (_isZelfdeFormulierType(
        profiel.formulierType,
        huidigProfiel.formulierType,
      )) {
        continue;
      }

      for (final prijsregel in profiel.regelsVoorCategorie(
        OffertePrijsCategorie.technischeKeuzePerArtikel,
      )) {
        final technischeKeuze = prijsregel.technischeKeuze;

        if (!prijsregel.actief ||
            technischeKeuze == null ||
            technischeKeuze.isLeeg) {
          continue;
        }

        resultaat.add(prijsregel);
      }
    }

    resultaat.sort((eerste, tweede) {
      final eersteFormulierNaam =
          OfferteArtikelPrijsKoppelingService.formulierNaamVoor(
            eerste.formulierType,
          );
      final tweedeFormulierNaam =
          OfferteArtikelPrijsKoppelingService.formulierNaamVoor(
            tweede.formulierType,
          );

      final formulierVergelijking = eersteFormulierNaam.toLowerCase().compareTo(
        tweedeFormulierNaam.toLowerCase(),
      );

      if (formulierVergelijking != 0) {
        return formulierVergelijking;
      }

      final omschrijvingVergelijking = eerste.omschrijving
          .toLowerCase()
          .compareTo(tweede.omschrijving.toLowerCase());

      if (omschrijvingVergelijking != 0) {
        return omschrijvingVergelijking;
      }

      return eerste.id.compareTo(tweede.id);
    });

    return List<OffertePrijsregelModel>.unmodifiable(resultaat);
  }

  Future<void> _bewaarProfiel(
    OffertePrijsprofielModel profiel, {
    String? melding,
    Set<String> synchroniseerTechnischePrijsregelIds = const <String>{},
  }) async {
    if (_opslaan) {
      return;
    }

    setState(() {
      _opslaan = true;
      _profiel = profiel;
    });

    try {
      if (synchroniseerTechnischePrijsregelIds.isNotEmpty) {
        await OfferteTechnischePrijsKoppelingService.bewaarEnSynchroniseer(
          huidigProfiel: profiel,
          prijsregelIds: synchroniseerTechnischePrijsregelIds,
        );
      } else {
        await AppStorage.bewaarOffertePrijsProfiel(profiel);
      }

      final andereTechnischePrijsregels = _heeftGeenTechnischeKeuzes
          ? const <OffertePrijsregelModel>[]
          : await _laadAndereTechnischePrijsregels(huidigProfiel: profiel);
      final technischePrijsregelKoppelAantallen = _heeftGeenTechnischeKeuzes
          ? const <String, int>{}
          : await OfferteTechnischePrijsKoppelingService.laadKoppelAantallen();

      if (!mounted) {
        return;
      }

      setState(() {
        _opslaan = false;
        _profiel = profiel;
        _andereTechnischePrijsregels = andereTechnischePrijsregels;
        _technischePrijsregelKoppelAantallen =
            technischePrijsregelKoppelAantallen;
      });

      if (melding != null && melding.isNotEmpty) {
        _toonMelding(melding);
      }

      if (_downloadHerladenUitgesteld && mounted) {
        _downloadHerladenUitgesteld = false;
        await _herlaadNaSync();
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _opslaan = false;
      });

      _toonMelding('Bewaren is niet gelukt: $e', fout: true);
    }
  }

  Future<List<OfferteTechnischeKeuzeRef>>
  _laadActueleTechnischeKeuzesVoorPrijsregel() async {
    try {
      final keuzes =
          await OfferteTechnischeKeuzeLaadHelper.laadVoorFormulierTypeInBoomVolgorde(
            widget.formulierType,
          );

      if (mounted) {
        setState(() {
          _technischeKeuzes = keuzes;
        });
      }

      return keuzes;
    } catch (e) {
      if (mounted) {
        _toonMelding(
          'De actuele technische keuzes konden niet opnieuw '
          'worden geladen: $e',
          fout: true,
        );
      }

      return _technischeKeuzes;
    }
  }

  Future<void> _openTechnischeKeuze(
    OfferteTechnischeKeuzeRef keuze,
    OffertePrijsregelModel? bestaandePrijsregel,
  ) async {
    final profiel = _profiel;

    if (profiel == null || _opslaan) {
      return;
    }

    final technischeKeuzes = await _laadActueleTechnischeKeuzesVoorPrijsregel();

    if (!mounted) {
      return;
    }

    final actueleKeuze = _zoekActueleTechnischeKeuze(technischeKeuzes, keuze);

    final bestaandeRegel =
        bestaandePrijsregel ??
        _zoekTechnischePrijsregelVoorKeuze(profiel, actueleKeuze);

    if (bestaandeRegel != null &&
        _isGekoppeldeTechnischePrijsregel(bestaandeRegel)) {
      final doorgaan = await _bevestigGekoppeldePrijsregelWijzigen(
        bestaandeRegel,
      );
      if (doorgaan != true || !mounted) {
        return;
      }
    }

    final gewijzigd = await toonOffertePrijsregelDialog(
      context: context,
      categorie: OffertePrijsCategorie.technischeKeuzePerArtikel,
      formulierType: widget.formulierType,
      volgendeVolgorde:
          bestaandeRegel?.volgorde ??
          profiel.volgendeVolgordeVoorCategorie(
            OffertePrijsCategorie.technischeKeuzePerArtikel,
          ),
      technischeKeuzes: technischeKeuzes,
      beginTechnischeKeuze: actueleKeuze,
      technischeKeuzeVergrendeld: true,
      bestaandePrijsregel: bestaandeRegel,
    );

    if (gewijzigd == null || !mounted) {
      return;
    }

    final isGekoppeld = _isGekoppeldeTechnischePrijsregel(gewijzigd);

    await _bewaarProfiel(
      profiel.metPrijsregel(gewijzigd),
      synchroniseerTechnischePrijsregelIds: isGekoppeld
          ? <String>{gewijzigd.id}
          : const <String>{},
      melding: bestaandeRegel == null
          ? 'Prijs voor technische keuze ingesteld.'
          : isGekoppeld
          ? 'Gekoppelde prijsregel bij alle artikeltypes gewijzigd.'
          : 'Prijsregel gewijzigd.',
    );
  }

  Future<void> _neemTechnischePrijzenOver(
    OfferteTechnischePrijsOvernameGroep groep,
  ) async {
    final profiel = _profiel;

    if (profiel == null || _opslaan || groep.kandidaten.isEmpty) {
      return;
    }

    final resultaat = await toonOfferteTechnischePrijsOvernemenDialog(
      context: context,
      groep: groep,
    );

    if (resultaat == null || !mounted) {
      return;
    }

    final gekoppeld =
        resultaat.koppelmodus ==
        OfferteTechnischePrijsOvernameKoppelmodus.gekoppeld;
    var bijgewerktProfiel = profiel;
    var volgendeVolgorde = profiel.volgendeVolgordeVoorCategorie(
      OffertePrijsCategorie.technischeKeuzePerArtikel,
    );
    var toegevoegd = 0;
    var vervangen = 0;
    final synchroniseerIds = <String>{};
    final idBasis = DateTime.now().microsecondsSinceEpoch;
    var nieuwIdIndex = 0;

    for (final kandidaat in groep.kandidaten) {
      final doelKeuze = _zoekActueleTechnischeKeuze(
        _technischeKeuzes,
        kandidaat.doelKeuze,
      );
      final bestaandePrijsregel = _zoekTechnischePrijsregelVoorKeuze(
        bijgewerktProfiel,
        doelKeuze,
      );

      if (bestaandePrijsregel != null &&
          resultaat.conflictmodus ==
              OfferteTechnischePrijsOvernameConflictmodus.alleenOntbrekende) {
        continue;
      }

      final bronPrijsregel = kandidaat.bronPrijsregel;
      final omschrijving = doelKeuze.hoeUitschrijven.trim().isNotEmpty
          ? doelKeuze.hoeUitschrijven.trim()
          : bronPrijsregel.omschrijving;
      final isVervanging = bestaandePrijsregel != null;
      final nieuwAfzonderlijkId =
          'prijs_overgenomen_${idBasis + nieuwIdIndex++}';
      final bronId = bronPrijsregel.id.trim();
      final id = gekoppeld && bronId.isNotEmpty ? bronId : nieuwAfzonderlijkId;
      final volgorde = bestaandePrijsregel?.volgorde ?? volgendeVolgorde;

      if (bestaandePrijsregel != null) {
        bijgewerktProfiel = bijgewerktProfiel.zonderPrijsregel(
          bestaandePrijsregel.id,
        );
      }

      final overgenomenPrijsregel = bronPrijsregel.copyWith(
        id: id,
        categorie: OffertePrijsCategorie.technischeKeuzePerArtikel,
        formulierType: widget.formulierType,
        omschrijving: omschrijving,
        technischeKeuze: doelKeuze,
        actief: bronPrijsregel.actief,
        volgorde: volgorde,
        gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
      );

      bijgewerktProfiel = bijgewerktProfiel.metPrijsregel(
        overgenomenPrijsregel,
      );

      if (gekoppeld) {
        synchroniseerIds.add(id);
      }

      if (isVervanging) {
        vervangen++;
      } else {
        toegevoegd++;
        volgendeVolgorde += 10;
      }
    }

    if (toegevoegd == 0 && vervangen == 0) {
      _toonMelding('Er waren geen ontbrekende prijzen om over te nemen.');
      return;
    }

    final delen = <String>[
      if (toegevoegd > 0) '$toegevoegd toegevoegd',
      if (vervangen > 0) '$vervangen vervangen',
    ];
    final typeTekst = gekoppeld ? 'gekoppeld' : 'afzonderlijk';

    await _bewaarProfiel(
      bijgewerktProfiel,
      synchroniseerTechnischePrijsregelIds: synchroniseerIds,
      melding:
          'Technische prijzen $typeTekst overgenomen: ${delen.join(' · ')}.',
    );
  }

  OfferteTechnischeKeuzeRef _zoekActueleTechnischeKeuze(
    List<OfferteTechnischeKeuzeRef> keuzes,
    OfferteTechnischeKeuzeRef gezocht,
  ) {
    final gezochteSleutel = _technischeKeuzeSleutel(gezocht);

    for (final keuze in keuzes) {
      if (_technischeKeuzeSleutel(keuze) == gezochteSleutel) {
        return keuze;
      }
    }

    return gezocht;
  }

  OffertePrijsregelModel? _zoekTechnischePrijsregelVoorKeuze(
    OffertePrijsprofielModel profiel,
    OfferteTechnischeKeuzeRef keuze,
  ) {
    final gezochteSleutel = _technischeKeuzeSleutel(keuze);
    OffertePrijsregelModel? beste;

    for (final prijsregel in profiel.regelsVoorCategorie(
      OffertePrijsCategorie.technischeKeuzePerArtikel,
    )) {
      final technischeKeuze = prijsregel.technischeKeuze;
      if (technischeKeuze == null ||
          _technischeKeuzeSleutel(technischeKeuze) != gezochteSleutel) {
        continue;
      }

      if (beste == null ||
          (prijsregel.actief && !beste.actief) ||
          (prijsregel.actief == beste.actief &&
              _isNieuwer(prijsregel.gewijzigdOp, beste.gewijzigdOp))) {
        beste = prijsregel;
      }
    }

    return beste;
  }

  static String _technischeKeuzeSleutel(OfferteTechnischeKeuzeRef keuze) {
    return <String>[
      keuze.formulierType.trim(),
      keuze.menuId.trim(),
      keuze.submenuId.trim(),
      keuze.keuzeId.trim(),
    ].join('|');
  }

  Future<void> _wijzigPrijsregel(OffertePrijsregelModel prijsregel) async {
    final profiel = _profiel;

    if (profiel == null || _opslaan) {
      return;
    }

    final isTechnischePrijsregel =
        prijsregel.categorie == OffertePrijsCategorie.technischeKeuzePerArtikel;

    final technischeKeuzes = isTechnischePrijsregel
        ? await _laadActueleTechnischeKeuzesVoorPrijsregel()
        : const <OfferteTechnischeKeuzeRef>[];

    if (!mounted) {
      return;
    }

    if (isTechnischePrijsregel &&
        _isGekoppeldeTechnischePrijsregel(prijsregel)) {
      final doorgaan = await _bevestigGekoppeldePrijsregelWijzigen(prijsregel);
      if (doorgaan != true || !mounted) {
        return;
      }
    }

    final gewijzigd = await toonOffertePrijsregelDialog(
      context: context,
      categorie: prijsregel.categorie,
      formulierType: widget.formulierType,
      volgendeVolgorde: prijsregel.volgorde,
      technischeKeuzes: technischeKeuzes,
      bestaandePrijsregel: prijsregel,
    );

    if (gewijzigd == null || !mounted) {
      return;
    }

    final bijgewerktProfiel = profiel.metPrijsregel(gewijzigd);
    final isGekoppeldeTechnischePrijsregel =
        isTechnischePrijsregel && _isGekoppeldeTechnischePrijsregel(gewijzigd);

    await _bewaarProfiel(
      bijgewerktProfiel,
      synchroniseerTechnischePrijsregelIds: isGekoppeldeTechnischePrijsregel
          ? <String>{gewijzigd.id}
          : const <String>{},
      melding: isGekoppeldeTechnischePrijsregel
          ? 'Gekoppelde prijsregel bij alle artikeltypes gewijzigd.'
          : 'Prijsregel gewijzigd.',
    );
  }

  Future<void> _verwijderPrijsregel(OffertePrijsregelModel prijsregel) async {
    final profiel = _profiel;

    if (profiel == null || _opslaan) {
      return;
    }

    final isGekoppeldeTechnischePrijsregel = _isGekoppeldeTechnischePrijsregel(
      prijsregel,
    );

    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            isGekoppeldeTechnischePrijsregel
                ? 'Gekoppelde prijsregel verwijderen?'
                : 'Prijsregel verwijderen?',
          ),
          content: Text(
            isGekoppeldeTechnischePrijsregel
                ? '“${prijsregel.omschrijving}” wordt alleen uit '
                      '${widget.formulierNaam} verwijderd. De gekoppelde '
                      'prijsregel blijft bij de andere artikeltypes bestaan.'
                : '“${prijsregel.omschrijving}” wordt definitief '
                      'uit deze prijstabel verwijderd.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Annuleren'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Verwijderen'),
            ),
          ],
        );
      },
    );

    if (bevestigen != true || !mounted) {
      return;
    }

    await _bewaarProfiel(
      profiel.zonderPrijsregel(prijsregel.id),
      melding: isGekoppeldeTechnischePrijsregel
          ? 'Gekoppelde prijsregel uit ${widget.formulierNaam} verwijderd.'
          : 'Prijsregel verwijderd.',
    );
  }

  Future<void> _ontkoppelTechnischePrijsregel(
    OffertePrijsregelModel prijsregel,
  ) async {
    final profiel = _profiel;

    if (profiel == null ||
        _opslaan ||
        !_isGekoppeldeTechnischePrijsregel(prijsregel)) {
      return;
    }

    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Koppeling losmaken?'),
          content: Text(
            'De prijsregel voor ${widget.formulierNaam} wordt een '
            'afzonderlijke afwijking. De huidige prijs blijft behouden, maar '
            'latere wijzigingen bij andere artikeltypes worden niet meer '
            'automatisch overgenomen.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuleren'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: _groen),
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.link_off_rounded, size: 18),
              label: const Text('Koppeling losmaken'),
            ),
          ],
        );
      },
    );

    if (bevestigen != true || !mounted) {
      return;
    }

    final afzonderlijkeRegel = prijsregel.copyWith(
      id: 'prijs_afwijking_${DateTime.now().microsecondsSinceEpoch}',
      gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
    );
    final bijgewerktProfiel = profiel
        .zonderPrijsregel(prijsregel.id)
        .metPrijsregel(afzonderlijkeRegel);

    await _bewaarProfiel(
      bijgewerktProfiel,
      melding: 'Koppeling losgemaakt. Dit is nu een afzonderlijke prijsregel.',
    );
  }

  Future<bool?> _bevestigGekoppeldePrijsregelWijzigen(
    OffertePrijsregelModel prijsregel,
  ) {
    final aantalArtikeltypes =
        _technischePrijsregelKoppelAantallen[prijsregel.id] ?? 1;

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Gekoppelde prijsregel wijzigen?'),
          content: Text(
            'Deze prijsregel is gekoppeld aan $aantalArtikeltypes '
            'artikeltypes. Wijzigingen aan prijs, eenheid, uitschrijfwijze en '
            'actiefstatus worden bij alle gekoppelde artikeltypes toegepast. '
            'De lokale technische keuze en omschrijving blijven behouden.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuleren'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _groen),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Gekoppeld wijzigen'),
            ),
          ],
        );
      },
    );
  }

  bool _isGekoppeldeTechnischePrijsregel(OffertePrijsregelModel prijsregel) {
    return prijsregel.categorie ==
            OffertePrijsCategorie.technischeKeuzePerArtikel &&
        (_technischePrijsregelKoppelAantallen[prijsregel.id] ?? 0) > 1;
  }

  void _toonMelding(String tekst, {bool fout = false}) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: fout ? const Color(0xFFDC2626) : _groen,
        content: Text(tekst),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _achtergrond,
      appBar: AppBar(
        title: Text(
          _paginaTitel,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: <Widget>[
          if (_opslaan)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: _groen,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _bouwInhoud(),
    );
  }

  Widget _bouwInhoud() {
    if (_laden) {
      return const Center(child: CircularProgressIndicator(color: _groen));
    }

    if (_foutmelding != null || _profiel == null) {
      return _bouwFoutmelding();
    }

    final profiel = _profiel!;

    return RefreshIndicator(
      color: _groen,
      onRefresh: _laadProfiel,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(Icons.info_outline_rounded, color: _groen, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _paginaUitleg,
                    style: const TextStyle(
                      color: _tekstGrijs,
                      fontSize: 12.5,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ..._bouwPrijssecties(profiel),
        ],
      ),
    );
  }

  List<Widget> _bouwPrijssecties(OffertePrijsprofielModel profiel) {
    return <Widget>[
      if (_heeftGeenTechnischeKeuzes)
        _bouwGeenTechnischeKeuzesKaart()
      else
        OfferteTechnischePrijskeuzeBoom(
          keuzes: _technischeKeuzes,
          prijsregels: profiel.regelsVoorCategorie(
            OffertePrijsCategorie.technischeKeuzePerArtikel,
          ),
          andereTechnischePrijsregels: _andereTechnischePrijsregels,
          gekoppeldePrijsregelAantallen: _technischePrijsregelKoppelAantallen,
          onKeuzeOpenen: _openTechnischeKeuze,
          onPrijsregelOpenen: _wijzigPrijsregel,
          onPrijsregelVerwijderen: _verwijderPrijsregel,
          onPrijsregelOntkoppelen: _ontkoppelTechnischePrijsregel,
          onPrijsregelsOvernemen: _neemTechnischePrijzenOver,
        ),
    ];
  }

  Widget _bouwGeenTechnischeKeuzesKaart() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.info_outline_rounded, color: _groen, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Prijs volgens technische keuze',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(
                  'Niet van toepassing voor ${widget.formulierNaam}. '
                  'Dit artikeltype heeft bewust geen technische '
                  'prijskeuzeboom. Bijkomende prijzen kunnen via '
                  'Prijs per artikel rechtstreeks op de offertepositie '
                  'worden toegevoegd.',
                  style: const TextStyle(
                    color: _tekstGrijs,
                    fontSize: 12.2,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwFoutmelding() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFDC2626),
              size: 34,
            ),
            const SizedBox(height: 10),
            Text(
              _foutmelding ?? 'Het prijsprofiel kon niet worden geladen.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: _groen),
              onPressed: _laadProfiel,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Opnieuw proberen'),
            ),
          ],
        ),
      ),
    );
  }

  static bool _isZelfdeFormulierType(String eerste, String tweede) {
    return _normaliseerFormulierType(eerste) ==
        _normaliseerFormulierType(tweede);
  }

  static String _normaliseerFormulierType(String waarde) {
    return waarde.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  static bool _isNieuwer(String eerste, String tweede) {
    final eersteDatum = DateTime.tryParse(eerste);
    final tweedeDatum = DateTime.tryParse(tweede);

    if (eersteDatum == null) {
      return false;
    }

    if (tweedeDatum == null) {
      return true;
    }

    return eersteDatum.isAfter(tweedeDatum);
  }
}
