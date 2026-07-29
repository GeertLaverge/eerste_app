// THIMACO-CONTROLE: PLOOIWERKEN-FICHE-BEWAART-TECHNISCHE-REGELS-20260728-2205
// THIMACO-CONTROLE: PLOOIWERKEN-FICHE-KLEURLIJSTEN-PROJECTKLEUR-20260728-2110
import 'package:flutter/material.dart';

import '../../../app_storage.dart';
import '../../../offerte/prijzen/offerte_artikel_prijs_data_model.dart';
import '../../fotos/opmeting_foto_model.dart';
import '../../kader_samenstelling/opmeting_kader_samenstelling_model.dart';
import '../../overzicht/opmeting_overzicht_model.dart';
import '../../raam/opmeting_raam_notities.dart';
import 'opmeting_plooiwerken_instellingen_model.dart';
import 'opmeting_plooiwerken_model.dart';
import 'opmeting_plooiwerken_technische_regels_helper.dart';
import 'opmeting_plooiwerken_rechterkolom.dart';
import 'opmeting_plooiwerken_tekenvlak.dart';

class OpmetingPlooiwerkenFiche extends StatefulWidget {
  const OpmetingPlooiwerkenFiche({
    super.key,
    this.klantNaam,
    this.bestaandeOpmeting,
    this.projectKleur = '',
    this.standaardPrijsPerStukExclBtw = 0,
    this.standaardWinstmargePercentage = 0,
    this.standaardKortingPercentage = 0,
  });

  final String? klantNaam;
  final OpmetingOverzichtRaamItem? bestaandeOpmeting;
  final String projectKleur;
  final double standaardPrijsPerStukExclBtw;
  final double standaardWinstmargePercentage;
  final double standaardKortingPercentage;

  @override
  State<OpmetingPlooiwerkenFiche> createState() {
    return _OpmetingPlooiwerkenFicheState();
  }
}

class _OpmetingPlooiwerkenFicheState extends State<OpmetingPlooiwerkenFiche> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);

  final TextEditingController _notitiesController = TextEditingController();

  late OpmetingPlooiwerkenModel _model;
  OpmetingPlooiwerkenInstellingen _instellingen =
      const OpmetingPlooiwerkenInstellingen();
  bool _bewarenBezig = false;

  @override
  void initState() {
    super.initState();
    _model =
        widget.bestaandeOpmeting?.plooiwerkenData ??
        const OpmetingPlooiwerkenModel();
    _model = _synchroniseerProjectKleur(_model);
    _notitiesController.text = _model.notities;
    _notitiesController.addListener(_verwerkNotities);
    _laadInstellingen();
  }

  @override
  void didUpdateWidget(covariant OpmetingPlooiwerkenFiche oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.projectKleur.trim() == widget.projectKleur.trim()) {
      return;
    }

    final bijgewerkt = _synchroniseerProjectKleur(_model);
    if (bijgewerkt != _model) {
      setState(() {
        _model = bijgewerkt;
      });
    }
  }

  Future<void> _laadInstellingen() async {
    final instellingen = await AppStorage.laadOpmetingPlooiwerkenInstellingen();

    if (!mounted) return;
    setState(() {
      _instellingen = instellingen;
      _model = _normaliseerKleurkeuze(
        _synchroniseerProjectKleur(_model),
        instellingen,
      );
    });
  }

  OpmetingPlooiwerkenModel _normaliseerKleurkeuze(
    OpmetingPlooiwerkenModel model,
    OpmetingPlooiwerkenInstellingen instellingen,
  ) {
    switch (model.kleursoort) {
      case OpmetingPlooiwerkenKleursoort.kleur:
        if (model.kleurWaarde.trim().isNotEmpty ||
            instellingen.kleuren.isEmpty) {
          return model;
        }
        return model.copyWith(kleurWaarde: instellingen.kleuren.first);
      case OpmetingPlooiwerkenKleursoort.folie:
        if (model.folieWaarde.trim().isNotEmpty ||
            instellingen.folies.isEmpty) {
          return model;
        }
        return model.copyWith(folieWaarde: instellingen.folies.first);
      case OpmetingPlooiwerkenKleursoort.projectKleur:
        return _synchroniseerProjectKleur(model);
      case OpmetingPlooiwerkenKleursoort.brut:
      case OpmetingPlooiwerkenKleursoort.anodise:
        return model;
    }
  }

  OpmetingPlooiwerkenModel _synchroniseerProjectKleur(
    OpmetingPlooiwerkenModel model,
  ) {
    if (!model.isProjectKleur) return model;

    final projectKleur = widget.projectKleur.trim();
    if (model.projectKleurWaarde.trim() == projectKleur) {
      return model;
    }

    return model.copyWith(projectKleurWaarde: projectKleur);
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

    setState(() {
      _model = _model.copyWith(notities: tekst);
    });
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

    setState(() {
      _bewarenBezig = true;
    });

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
          content: Text('Plooiwerken opslaan is niet gelukt: $fout'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _bewarenBezig = false;
        });
      }
    }
  }

  OpmetingOverzichtRaamItem _maakOverzichtItem() {
    final klantNaam =
        (widget.klantNaam ?? widget.bestaandeOpmeting?.klantNaam ?? '').trim();
    final modelVoorOpslag = _synchroniseerProjectKleur(_model).copyWith(
      notities: _notitiesController.text.trim(),
      fotos: List<OpmetingFoto>.unmodifiable(_model.fotos),
    );
    final standaardPrijsData = OfferteArtikelPrijsDataModel(
      prijsPerStukExclBtw: widget.standaardPrijsPerStukExclBtw,
      artikelWinstmargePercentage: widget.standaardWinstmargePercentage,
      artikelKortingPercentage: widget.standaardKortingPercentage,
    );

    return OpmetingOverzichtRaamItem(
      id: widget.bestaandeOpmeting?.id ?? '',
      titel: modelVoorOpslag.stukReferentie.trim().isEmpty
          ? 'Plooiwerken'
          : modelVoorOpslag.stukReferentie.trim(),
      klantNaam: klantNaam,
      formulierType: 'plooiwerken',
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
      dagmaatBreedteMm: 0,
      dagmaatHoogteMm: 0,
      raammaatBreedteMm: 0,
      raammaatHoogteMm: 0,
      kaderSamenstelling: OpmetingKaderSamenstelling.basis(
        breedteMm: 1000,
        hoogteMm: 1000,
      ),
      tekeningData: OpmetingOverzichtTekeningData.leeg(),
      technischeRegels: OpmetingPlooiwerkenTechnischeRegelsHelper.bouw(
        modelVoorOpslag,
      ),
      technischeContainers: const <OpmetingOverzichtTechnischeContainer>[],
      fotos: modelVoorOpslag.fotos,
      notities: modelVoorOpslag.notities,
      offertePrijsData:
          widget.bestaandeOpmeting?.offertePrijsData ?? standaardPrijsData,
      plooiwerkenData: modelVoorOpslag,
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
                ? 'Opmeting Plooiwerken'
                : 'Opmeting Plooiwerken · $klantNaam',
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
            final rechterkolom = OpmetingPlooiwerkenRechterkolom(
              model: _model,
              instellingen: _instellingen,
              projectKleur: widget.projectKleur,
              onGewijzigd: (nieuwModel) {
                setState(() {
                  _model = _synchroniseerProjectKleur(nieuwModel).copyWith(
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
          Expanded(child: OpmetingPlooiwerkenTekenvlak(model: _model)),
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
