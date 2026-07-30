// THIMACO-CONTROLE: VOORZETSCREEN-TECHNISCHE-PRIJS-INVALIDATIE-BIJ-OPSLAAN-20260730-2205
// THIMACO-CONTROLE: VOORZETSCREEN-FICHE-PROJECTKLEUR-KABELGEGEVENS-20260730-2005
import 'package:flutter/material.dart';

import '../../../app_storage.dart';
import '../../../offerte/prijzen/offerte_artikel_prijs_data_model.dart';
import '../../fotos/opmeting_foto_model.dart';
import '../../kader_samenstelling/opmeting_kader_samenstelling_model.dart';
import '../../overzicht/opmeting_overzicht_model.dart';
import '../../raam/opmeting_raam_notities.dart';
import 'opmeting_voorzetscreen_instellingen_model.dart';
import 'opmeting_voorzetscreen_model.dart';
import 'opmeting_voorzetscreen_rechterkolom.dart';
import 'opmeting_voorzetscreen_technische_regels_helper.dart';
import 'opmeting_voorzetscreen_tekenvlak.dart';

class OpmetingVoorzetscreenFiche extends StatefulWidget {
  const OpmetingVoorzetscreenFiche({
    super.key,
    this.klantNaam,
    this.bestaandeOpmeting,
    this.projectKleur = '',
  });

  final String? klantNaam;
  final OpmetingOverzichtRaamItem? bestaandeOpmeting;
  final String projectKleur;

  @override
  State<OpmetingVoorzetscreenFiche> createState() {
    return _OpmetingVoorzetscreenFicheState();
  }
}

class _OpmetingVoorzetscreenFicheState
    extends State<OpmetingVoorzetscreenFiche> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);

  final TextEditingController _notitiesController = TextEditingController();

  late OpmetingVoorzetscreenModel _model;
  OpmetingVoorzetscreenInstellingen _instellingen =
      const OpmetingVoorzetscreenInstellingen();
  bool _bewarenBezig = false;

  @override
  void initState() {
    super.initState();
    _model =
        widget.bestaandeOpmeting?.voorzetscreenData ??
        const OpmetingVoorzetscreenModel();
    _model = _synchroniseerProjectKleur(_model);
    _notitiesController.text = _model.notities;
    _notitiesController.addListener(_verwerkNotities);
    _laadInstellingen();
  }

  @override
  void didUpdateWidget(covariant OpmetingVoorzetscreenFiche oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectKleur.trim() == widget.projectKleur.trim()) return;

    final bijgewerkt = _synchroniseerProjectKleur(_model);
    if (bijgewerkt != _model) {
      setState(() => _model = bijgewerkt);
    }
  }

  OpmetingVoorzetscreenModel _synchroniseerProjectKleur(
    OpmetingVoorzetscreenModel model,
  ) {
    if (model.kleurbron != OpmetingVoorzetscreenKleurbron.projectKleur) {
      return model;
    }

    final projectKleur = widget.projectKleur.trim();
    if (model.projectKleurWaarde.trim() == projectKleur) return model;
    return model.copyWith(projectKleurWaarde: projectKleur);
  }

  Future<void> _laadInstellingen() async {
    final instellingen =
        await AppStorage.laadOpmetingVoorzetscreenInstellingen();
    if (!mounted) return;

    setState(() {
      _instellingen = instellingen;
      _model = _vulStandaardKeuzesAan(_model, instellingen);
    });
  }

  OpmetingVoorzetscreenModel _vulStandaardKeuzesAan(
    OpmetingVoorzetscreenModel model,
    OpmetingVoorzetscreenInstellingen instellingen,
  ) {
    var resultaat = model;

    if (resultaat.kleurbron ==
            OpmetingVoorzetscreenKleurbron.standaardPoederlak &&
        resultaat.kleurBenaming.trim().isEmpty &&
        instellingen.poederkleuren.isNotEmpty) {
      final kleur = instellingen.poederkleuren.first;
      resultaat = resultaat.copyWith(
        kleurBenaming: kleur.benaming,
        poedercode: kleur.poedercode,
        poederlakMogelijk: kleur.poederlakMogelijk,
        natlakMogelijk: kleur.natlakMogelijk,
      );
    }

    if (resultaat.kleurbron == OpmetingVoorzetscreenKleurbron.projectKleur) {
      resultaat = resultaat.copyWith(
        projectKleurWaarde: widget.projectKleur.trim(),
        kleurBenaming: '',
        poedercode: '',
        poederlakMogelijk: false,
        natlakMogelijk: false,
      );
    }

    if (resultaat.doekCode.trim().isEmpty &&
        instellingen.screendoeken.isNotEmpty) {
      final doek = instellingen.screendoeken.first;
      resultaat = resultaat.copyWith(
        doekCode: doek.code,
        doekKleur: doek.kleur,
        doekVoorzijdeHex: doek.voorzijdeHex,
        doekAchterzijdeHex: doek.achterzijdeHex,
      );
    }

    final motoren = _beschikbareMotoren(resultaat, instellingen);
    final huidigMotorId = <String>[
      resultaat.motorType.trim().toLowerCase(),
      resultaat.motorMerk.trim().toLowerCase(),
      resultaat.motorOmschrijving.trim().toLowerCase(),
    ].join('|');

    final heeftGeldigeMotor = motoren.any((motor) => motor.id == huidigMotorId);
    if (!heeftGeldigeMotor && motoren.isNotEmpty) {
      final motor = motoren.first;
      resultaat = resultaat.copyWith(
        motorType: motor.type,
        motorMerk: motor.merk,
        motorOmschrijving: motor.omschrijving,
      );
    } else if (motoren.isEmpty) {
      resultaat = resultaat.copyWith(
        motorType: '',
        motorMerk: '',
        motorOmschrijving: '',
      );
    }

    return resultaat;
  }

  List<OpmetingVoorzetscreenMotor> _beschikbareMotoren(
    OpmetingVoorzetscreenModel model,
    OpmetingVoorzetscreenInstellingen instellingen,
  ) {
    if (!model.zonnecel) {
      return instellingen.motoren;
    }

    if (model.kastmaat == OpmetingVoorzetscreenKastmaat.mm85) {
      return const <OpmetingVoorzetscreenMotor>[];
    }

    if (model.kastmaat == OpmetingVoorzetscreenKastmaat.mm95) {
      return instellingen.zonnecelMotoren
          .where((motor) => motor.merk.trim().toUpperCase() == 'BREL')
          .toList(growable: false);
    }

    return instellingen.zonnecelMotoren;
  }

  @override
  void dispose() {
    _notitiesController.removeListener(_verwerkNotities);
    _notitiesController.dispose();
    super.dispose();
  }

  void _verwerkNotities() {
    final tekst = _notitiesController.text;
    if (tekst == _model.notities) return;
    setState(() => _model = _model.copyWith(notities: tekst));
  }

  void _verwerkFotos(List<OpmetingFoto> fotos) {
    setState(() {
      _model = _model.copyWith(fotos: List<OpmetingFoto>.unmodifiable(fotos));
    });
  }

  Future<void> _sluitFiche() async {
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _voegToeAanOverzicht() async {
    if (_bewarenBezig) return;
    setState(() => _bewarenBezig = true);

    try {
      final opmeting = _maakOverzichtItem();
      final bewaardeOpmeting = widget.bestaandeOpmeting == null
          ? await AppStorage.voegOpmetingToe(opmeting)
          : await AppStorage.werkOpmetingBij(opmeting);

      if (!mounted) return;
      Navigator.of(context).pop(bewaardeOpmeting);
    } catch (fout) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text('Voorzetscreen opslaan is niet gelukt: $fout'),
        ),
      );
    } finally {
      if (mounted) setState(() => _bewarenBezig = false);
    }
  }

  OpmetingOverzichtRaamItem _maakOverzichtItem() {
    final klantNaam =
        (widget.klantNaam ?? widget.bestaandeOpmeting?.klantNaam ?? '').trim();
    final modelVoorOpslag = _model.copyWith(
      notities: _notitiesController.text.trim(),
      fotos: List<OpmetingFoto>.unmodifiable(_model.fotos),
    );
    final bestaandePrijsData =
        widget.bestaandeOpmeting?.offertePrijsData ??
        const OfferteArtikelPrijsDataModel();
    final prijsData = bestaandePrijsData.copyWith(
      toegepasteTechnischePrijsregels: const [],
      technischePrijsSignatuur: '',
    );

    return OpmetingOverzichtRaamItem(
      id: widget.bestaandeOpmeting?.id ?? '',
      titel: 'Voorzetscreen',
      klantNaam: klantNaam,
      formulierType: 'voorzetscreen',
      gewijzigdOp: widget.bestaandeOpmeting?.gewijzigdOp ?? '',
      isVerwijderd: widget.bestaandeOpmeting?.isVerwijderd ?? false,
      isOfferteOptie: widget.bestaandeOpmeting?.isOfferteOptie ?? false,
      isNietRekenen: widget.bestaandeOpmeting?.isNietRekenen ?? false,
      offerteOptiePlaatsing:
          widget.bestaandeOpmeting?.offerteOptiePlaatsing ??
          OfferteOptiePlaatsing.apartePagina,
      offerteOptieHoofdpositieId:
          widget.bestaandeOpmeting?.offerteOptieHoofdpositieId ?? '',
      gekopieerdVanPositieId:
          widget.bestaandeOpmeting?.gekopieerdVanPositieId ?? '',
      dagmaatBreedteMm: modelVoorOpslag.breedteMm,
      dagmaatHoogteMm: modelVoorOpslag.hoogteMm,
      raammaatBreedteMm: modelVoorOpslag.breedteMm,
      raammaatHoogteMm: modelVoorOpslag.hoogteMm,
      kaderSamenstelling: OpmetingKaderSamenstelling.basis(
        breedteMm: modelVoorOpslag.breedteMm,
        hoogteMm: modelVoorOpslag.hoogteMm,
      ),
      tekeningData: OpmetingOverzichtTekeningData.leeg(),
      technischeRegels: OpmetingVoorzetscreenTechnischeRegelsHelper.bouw(
        modelVoorOpslag,
      ),
      technischeContainers: const <OpmetingOverzichtTechnischeContainer>[],
      fotos: modelVoorOpslag.fotos,
      notities: modelVoorOpslag.notities,
      offertePrijsData: prijsData,
      voorzetscreenData: modelVoorOpslag,
    );
  }

  @override
  Widget build(BuildContext context) {
    final klantNaam =
        (widget.klantNaam ?? widget.bestaandeOpmeting?.klantNaam ?? '').trim();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) await _sluitFiche();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: _groen,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: _sluitFiche,
          ),
          title: Text(
            klantNaam.isEmpty
                ? 'Opmeting Voorzetscreen'
                : 'Opmeting Voorzetscreen · $klantNaam',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton.icon(
                onPressed: _bewarenBezig ? null : _voegToeAanOverzicht,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _groen,
                ),
                icon: _bewarenBezig
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _groen,
                        ),
                      )
                    : const Icon(Icons.add_rounded, size: 18),
                label: Text(
                  widget.bestaandeOpmeting == null ? 'Toevoegen' : 'Bewaren',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ElevatedButton.icon(
                onPressed: _sluitFiche,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _groen,
                ),
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Annuleren'),
              ),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final liggend = constraints.maxWidth >= 900;
            final tekenKaart = _bouwTekeningEnNotities();
            final rechterkolom = OpmetingVoorzetscreenRechterkolom(
              model: _model,
              instellingen: _instellingen,
              projectKleur: widget.projectKleur,
              onGewijzigd: (nieuwModel) {
                setState(() {
                  _model = nieuwModel.copyWith(
                    notities: _notitiesController.text,
                    fotos: _model.fotos,
                  );
                });
              },
            );

            return Padding(
              padding: const EdgeInsets.all(12),
              child: liggend
                  ? Row(
                      children: <Widget>[
                        Expanded(flex: 60, child: tekenKaart),
                        const SizedBox(width: 12),
                        Expanded(flex: 40, child: rechterkolom),
                      ],
                    )
                  : Column(
                      children: <Widget>[
                        Expanded(flex: 43, child: tekenKaart),
                        const SizedBox(height: 12),
                        Expanded(flex: 57, child: rechterkolom),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _bouwTekeningEnNotities() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rand),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0F111827),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Expanded(child: OpmetingVoorzetscreenTekenvlak(model: _model)),
          const SizedBox(height: 10),
          OpmetingRaamNotities(
            controller: _notitiesController,
            fotos: _model.fotos,
            onFotosGewijzigd: _verwerkFotos,
          ),
        ],
      ),
    );
  }
}
