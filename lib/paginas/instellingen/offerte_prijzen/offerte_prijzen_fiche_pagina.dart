// THIMACO-CONTROLE: GEDEELDE-VERDEELKOSTEN-PRIJSFICHE-20260723
import 'package:flutter/material.dart';

import '../../../helpers/app_storage.dart';
import '../../../helpers/offerte/prijzen/offerte_artikel_prijs_koppeling_service.dart';
import '../../../helpers/offerte/prijzen/offerte_prijs_categorie.dart';
import '../../../helpers/offerte/prijzen/offerte_prijsprofiel_model.dart';
import '../../../helpers/offerte/prijzen/offerte_prijsregel_model.dart';
import '../../../helpers/offerte/prijzen/offerte_technische_keuze_laad_helper.dart';
import '../../../helpers/offerte/prijzen/offerte_technische_keuze_ref.dart';
import 'offerte_prijsregel_dialog.dart';
import 'offerte_prijstabel_widget.dart';

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

  List<OffertePrijsregelModel> _verdeelgroepOpties =
      const <OffertePrijsregelModel>[];

  bool _laden = true;
  bool _opslaan = false;
  String? _foutmelding;

  bool get _isVasteInzethor {
    return _normaliseerFormulierType(widget.formulierType) ==
        _normaliseerFormulierType('vasteInzethor');
  }

  @override
  void initState() {
    super.initState();
    _laadProfiel();
  }

  Future<void> _laadProfiel() async {
    if (mounted) {
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

      final technischeKeuzes =
          await OfferteTechnischeKeuzeLaadHelper.laadVoorFormulierType(
            widget.formulierType,
          );

      if (bestaand == null) {
        await AppStorage.bewaarOffertePrijsProfiel(profiel);
      }

      final verdeelgroepOpties = await _laadVerdeelgroepOpties(
        huidigProfiel: profiel,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _profiel = profiel;
        _technischeKeuzes = technischeKeuzes;
        _verdeelgroepOpties = verdeelgroepOpties;
        _laden = false;
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

  Future<List<OffertePrijsregelModel>> _laadVerdeelgroepOpties({
    OffertePrijsprofielModel? huidigProfiel,
  }) async {
    final groepenPerId = <String, OffertePrijsregelModel>{};

    for (final formulierType in _ondersteundeFormulierTypes()) {
      OffertePrijsprofielModel? profiel;

      if (huidigProfiel != null &&
          _isZelfdeFormulierType(formulierType, huidigProfiel.formulierType)) {
        profiel = huidigProfiel;
      } else {
        try {
          profiel = await AppStorage.laadOffertePrijsProfiel(formulierType);
        } catch (_) {
          // Een ontbrekend of tijdelijk onleesbaar ander prijsprofiel
          // mag de geopende prijsfiche niet blokkeren.
          profiel = null;
        }
      }

      if (profiel == null) {
        continue;
      }

      for (final prijsregel in profiel.prijsregels) {
        if (!prijsregel.isVerdeeldeProjectkost ||
            prijsregel.id.trim().isEmpty) {
          continue;
        }

        final bestaandeGroep = groepenPerId[prijsregel.id];

        if (bestaandeGroep == null ||
            _isNieuwer(prijsregel.gewijzigdOp, bestaandeGroep.gewijzigdOp)) {
          groepenPerId[prijsregel.id] = prijsregel;
        }
      }
    }

    final resultaat = groepenPerId.values.toList(growable: false)
      ..sort((eerste, tweede) {
        final omschrijvingVergelijking = eerste.omschrijving
            .toLowerCase()
            .compareTo(tweede.omschrijving.toLowerCase());

        if (omschrijvingVergelijking != 0) {
          return omschrijvingVergelijking;
        }

        return eerste.id.compareTo(tweede.id);
      });

    return resultaat;
  }

  Future<void> _bewaarProfiel(
    OffertePrijsprofielModel profiel, {
    String? melding,
    String? synchroniseerVerdeelgroepId,
  }) async {
    if (_opslaan) {
      return;
    }

    setState(() {
      _opslaan = true;
      _profiel = profiel;
    });

    try {
      final gedeeldeVerdeelgroep = synchroniseerVerdeelgroepId == null
          ? null
          : _zoekPrijsregel(profiel, synchroniseerVerdeelgroepId);

      if (gedeeldeVerdeelgroep != null &&
          gedeeldeVerdeelgroep.isVerdeeldeProjectkost) {
        await _bewaarEnSynchroniseerVerdeelgroep(
          huidigProfiel: profiel,
          verdeelgroep: gedeeldeVerdeelgroep,
        );
      } else {
        await AppStorage.bewaarOffertePrijsProfiel(profiel);
      }

      final verdeelgroepOpties = await _laadVerdeelgroepOpties(
        huidigProfiel: profiel,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _opslaan = false;
        _profiel = profiel;
        _verdeelgroepOpties = verdeelgroepOpties;
      });

      if (melding != null && melding.isNotEmpty) {
        _toonMelding(melding);
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

  Future<void> _bewaarEnSynchroniseerVerdeelgroep({
    required OffertePrijsprofielModel huidigProfiel,
    required OffertePrijsregelModel verdeelgroep,
  }) async {
    await AppStorage.bewaarOffertePrijsProfiel(huidigProfiel);

    for (final formulierType in _ondersteundeFormulierTypes()) {
      if (_isZelfdeFormulierType(formulierType, huidigProfiel.formulierType)) {
        continue;
      }

      final anderProfiel = await AppStorage.laadOffertePrijsProfiel(
        formulierType,
      );

      if (anderProfiel == null) {
        continue;
      }

      final heeftGekoppeldeVerdeelgroep = anderProfiel.prijsregels.any((
        prijsregel,
      ) {
        return prijsregel.id == verdeelgroep.id &&
            prijsregel.isVerdeeldeProjectkost;
      });

      if (!heeftGekoppeldeVerdeelgroep) {
        continue;
      }

      final bijgewerktProfiel = _synchroniseerVerdeelgroepInProfiel(
        profiel: anderProfiel,
        bronVerdeelgroep: verdeelgroep,
      );

      await AppStorage.bewaarOffertePrijsProfiel(bijgewerktProfiel);
    }
  }

  OffertePrijsprofielModel _synchroniseerVerdeelgroepInProfiel({
    required OffertePrijsprofielModel profiel,
    required OffertePrijsregelModel bronVerdeelgroep,
  }) {
    final bijgewerktePrijsregels = profiel.prijsregels
        .map((prijsregel) {
          if (prijsregel.id != bronVerdeelgroep.id ||
              !prijsregel.isVerdeeldeProjectkost) {
            return prijsregel;
          }

          return prijsregel.copyWith(
            categorie: bronVerdeelgroep.categorie,
            formulierType: profiel.formulierType,
            omschrijving: bronVerdeelgroep.omschrijving,
            prijsExclBtw: bronVerdeelgroep.prijsExclBtw,
            eenheid: bronVerdeelgroep.eenheid,
            uitschrijfmodus: bronVerdeelgroep.uitschrijfmodus,
            technischeKeuzeWissen: true,
            verdeelLimietmodus: bronVerdeelgroep.verdeelLimietmodus,
            verdeelLimietBedragExclBtw:
                bronVerdeelgroep.verdeelLimietBedragExclBtw,
            actief: bronVerdeelgroep.actief,
            gewijzigdOp: bronVerdeelgroep.gewijzigdOp,
          );
        })
        .toList(growable: false);

    return profiel.copyWith(
      prijsregels: bijgewerktePrijsregels,
      gewijzigdOp: bronVerdeelgroep.gewijzigdOp,
    );
  }

  Future<List<OfferteTechnischeKeuzeRef>>
  _laadActueleTechnischeKeuzesVoorPrijsregel() async {
    try {
      final keuzes =
          await OfferteTechnischeKeuzeLaadHelper.laadVoorFormulierType(
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

  Future<void> _voegPrijsregelToe(OffertePrijsCategorie categorie) async {
    final profiel = _profiel;

    if (profiel == null || _opslaan) {
      return;
    }

    final isTechnischePrijsregel =
        categorie == OffertePrijsCategorie.technischeKeuzePerArtikel;

    final technischeKeuzes = isTechnischePrijsregel
        ? await _laadActueleTechnischeKeuzesVoorPrijsregel()
        : const <OfferteTechnischeKeuzeRef>[];

    if (!mounted) {
      return;
    }

    final prijsregel = await toonOffertePrijsregelDialog(
      context: context,
      categorie: categorie,
      formulierType: widget.formulierType,
      volgendeVolgorde: profiel.volgendeVolgordeVoorCategorie(categorie),
      technischeKeuzes: technischeKeuzes,
      verdeelgroepOpties: _verdeelgroepOpties,
    );

    if (prijsregel == null || !mounted) {
      return;
    }

    final bijgewerktProfiel = profiel.metPrijsregel(prijsregel);

    await _bewaarProfiel(
      bijgewerktProfiel,
      synchroniseerVerdeelgroepId: prijsregel.isVerdeeldeProjectkost
          ? prijsregel.id
          : null,
      melding: prijsregel.isVerdeeldeProjectkost
          ? 'Gedeelde verdeelkost gekoppeld.'
          : 'Prijsregel toegevoegd.',
    );
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

    final gewijzigd = await toonOffertePrijsregelDialog(
      context: context,
      categorie: prijsregel.categorie,
      formulierType: widget.formulierType,
      volgendeVolgorde: prijsregel.volgorde,
      technischeKeuzes: technischeKeuzes,
      verdeelgroepOpties: _verdeelgroepOpties,
      bestaandePrijsregel: prijsregel,
    );

    if (gewijzigd == null || !mounted) {
      return;
    }

    final bijgewerktProfiel = profiel.metPrijsregel(gewijzigd);

    await _bewaarProfiel(
      bijgewerktProfiel,
      synchroniseerVerdeelgroepId: gewijzigd.isVerdeeldeProjectkost
          ? gewijzigd.id
          : null,
      melding: gewijzigd.isVerdeeldeProjectkost
          ? 'Gedeelde verdeelkost gewijzigd.'
          : 'Prijsregel gewijzigd.',
    );
  }

  Future<void> _verwijderPrijsregel(OffertePrijsregelModel prijsregel) async {
    final profiel = _profiel;

    if (profiel == null || _opslaan) {
      return;
    }

    final isGedeeldeVerdeelgroep = prijsregel.isVerdeeldeProjectkost;

    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            isGedeeldeVerdeelgroep
                ? 'Verdeelkost ontkoppelen?'
                : 'Prijsregel verwijderen?',
          ),
          content: Text(
            isGedeeldeVerdeelgroep
                ? '“${prijsregel.omschrijving}” wordt uit '
                      '${widget.formulierNaam} verwijderd. '
                      'Dezelfde verdeelkost blijft bestaan bij '
                      'andere gekoppelde artikelgroepen.'
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
              child: Text(
                isGedeeldeVerdeelgroep ? 'Ontkoppelen' : 'Verwijderen',
              ),
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
      melding: isGedeeldeVerdeelgroep
          ? 'Verdeelkost ontkoppeld van '
                '${widget.formulierNaam}.'
          : 'Prijsregel verwijderd.',
    );
  }

  Future<void> _zetPrijsregelActief(
    OffertePrijsregelModel prijsregel,
    bool actief,
  ) async {
    final profiel = _profiel;

    if (profiel == null || _opslaan) {
      return;
    }

    final gewijzigd = prijsregel.copyWith(
      actief: actief,
      gewijzigdOp: DateTime.now().toUtc().toIso8601String(),
    );

    final bijgewerktProfiel = profiel.metPrijsregel(gewijzigd);

    await _bewaarProfiel(
      bijgewerktProfiel,
      synchroniseerVerdeelgroepId: gewijzigd.isVerdeeldeProjectkost
          ? gewijzigd.id
          : null,
    );
  }

  Future<void> _verplaatsPrijsregel(
    OffertePrijsregelModel prijsregel,
    int richting,
  ) async {
    final profiel = _profiel;

    if (profiel == null || _opslaan || richting == 0) {
      return;
    }

    final regels = profiel
        .regelsVoorCategorie(prijsregel.categorie)
        .toList(growable: true);

    final huidigIndex = regels.indexWhere((regel) => regel.id == prijsregel.id);

    final nieuwIndex = huidigIndex + richting;

    if (huidigIndex < 0 || nieuwIndex < 0 || nieuwIndex >= regels.length) {
      return;
    }

    final verplaatsteRegel = regels.removeAt(huidigIndex);

    regels.insert(nieuwIndex, verplaatsteRegel);

    await _bewaarProfiel(
      profiel.metCategorieVolgorde(
        categorie: prijsregel.categorie,
        prijsregelIds: regels.map((regel) => regel.id).toList(growable: false),
      ),
    );
  }

  OffertePrijsregelModel? _zoekPrijsregel(
    OffertePrijsprofielModel profiel,
    String prijsregelId,
  ) {
    for (final prijsregel in profiel.prijsregels) {
      if (prijsregel.id == prijsregelId) {
        return prijsregel;
      }
    }

    return null;
  }

  List<String> _ondersteundeFormulierTypes() {
    final formulierTypesPerSleutel = <String, String>{};

    void voegToe(String formulierType) {
      final canoniek =
          OfferteArtikelPrijsKoppelingService.canoniekFormulierType(
            formulierType,
          ).trim();

      final sleutel = _normaliseerFormulierType(canoniek);

      if (sleutel.isEmpty) {
        return;
      }

      formulierTypesPerSleutel.putIfAbsent(sleutel, () => canoniek);
    }

    for (final formulierType
        in OfferteArtikelPrijsKoppelingService.ondersteundeFormulierTypes) {
      voegToe(formulierType);
    }

    voegToe(widget.formulierType);

    return formulierTypesPerSleutel.values.toList(growable: false);
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
          'Offerteprijzen · ${widget.formulierNaam}',
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
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.info_outline_rounded, color: _groen, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Voeg hier prijsregels toe, wijzig de volgorde '
                    'en zet regels tijdelijk actief of inactief. '
                    'Bij een interne verdeelkost kunt u een bestaande '
                    'omschrijving uit een andere artikelgroep kiezen. '
                    'Bedrag, aankooplimiet en actiefstatus blijven dan '
                    'automatisch gelijk bij alle gekoppelde groepen.',
                    style: TextStyle(
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
          if (_isVasteInzethor)
            _bouwGeenTechnischeKeuzesKaart()
          else
            _bouwTabel(
              profiel,
              categorie: OffertePrijsCategorie.technischeKeuzePerArtikel,
              uitleg:
                  'Koppel een prijsregel aan een keuze die u '
                  'zelf via Nieuwe technische keuze hebt '
                  'samengesteld. De regel wordt automatisch '
                  'toegepast zodra die keuze in een positie '
                  'geselecteerd is.',
            ),
          const SizedBox(height: 14),
          _bouwTabel(
            profiel,
            categorie: OffertePrijsCategorie.vrijPerArtikel,
            uitleg:
                'Vrije bijkomende kosten die later bij één '
                'afzonderlijk artikel kunnen worden ingevuld.',
          ),
          const SizedBox(height: 14),
          _bouwTabel(
            profiel,
            categorie: OffertePrijsCategorie.alleArtikelen,
            uitleg:
                'Projectbrede prijsregels. Kies bij een interne '
                'verdeelkost een bestaande omschrijving om deze '
                'artikelgroep aan dezelfde verdeelkost te koppelen. '
                'De gedeelde kost wordt slechts één keer over alle '
                'gekoppelde artikelen verdeeld.',
          ),
        ],
      ),
    );
  }

  Widget _bouwGeenTechnischeKeuzesKaart() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.info_outline_rounded, color: _groen, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Prijs volgens technische keuze',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 5),
                Text(
                  'Niet van toepassing voor Vaste inzethor. '
                  'Alleen keuzes die u zelf via het menu Nieuwe '
                  'technische keuze samenstelt, mogen later aan '
                  'een technische prijsregel worden gekoppeld. '
                  'Dit menu bestaat bij de vaste inzethor bewust niet.',
                  style: TextStyle(
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

  Widget _bouwTabel(
    OffertePrijsprofielModel profiel, {
    required OffertePrijsCategorie categorie,
    required String uitleg,
  }) {
    return OffertePrijstabelWidget(
      categorie: categorie,
      prijsregels: profiel.regelsVoorCategorie(categorie),
      uitleg: uitleg,
      onToevoegen: () {
        _voegPrijsregelToe(categorie);
      },
      onWijzigen: _wijzigPrijsregel,
      onVerwijderen: _verwijderPrijsregel,
      onActiefGewijzigd: _zetPrijsregelActief,
      onVerplaats: _verplaatsPrijsregel,
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
