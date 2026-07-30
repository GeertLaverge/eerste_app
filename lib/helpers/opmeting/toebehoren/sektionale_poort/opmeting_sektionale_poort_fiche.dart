// THIMACO-CONTROLE: SEKTIONALE-POORT-FICHE-DEFINITIEF-SCHOON-20260729
import 'package:flutter/material.dart';

import '../../../app_storage.dart';
import '../../../offerte/prijzen/offerte_artikel_prijs_data_model.dart';
import '../../fotos/opmeting_foto_model.dart';
import '../../kader_samenstelling/opmeting_kader_samenstelling_model.dart';
import '../../overzicht/opmeting_overzicht_model.dart';
import '../../raam/opmeting_raam_keuzemenu_model.dart';
import '../../raam/opmeting_raam_notities.dart';
import 'opmeting_sektionale_poort_instellingen_model.dart';
import 'opmeting_sektionale_poort_model.dart';
import 'opmeting_sektionale_poort_rechterkolom.dart';
import 'opmeting_sektionale_poort_technische_regels_helper.dart';
import 'opmeting_sektionale_poort_tekenvlak.dart';

class OpmetingSektionalePoortFiche extends StatefulWidget {
  const OpmetingSektionalePoortFiche({
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
  State<OpmetingSektionalePoortFiche> createState() {
    return _OpmetingSektionalePoortFicheState();
  }
}

class _OpmetingSektionalePoortFicheState
    extends State<OpmetingSektionalePoortFiche> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);

  final TextEditingController _notitiesController = TextEditingController();

  late OpmetingSektionalePoortModel _model;
  OpmetingSektionalePoortInstellingen _instellingen =
      const OpmetingSektionalePoortInstellingen();
  bool _bewarenBezig = false;

  @override
  void initState() {
    super.initState();
    _model = _maakStartModel();
    _model = _synchroniseerProjectKleur(_model);
    _notitiesController.text = _model.notities;
    _notitiesController.addListener(_verwerkNotities);
    _laadInstellingen();
  }

  OpmetingSektionalePoortModel _maakStartModel() {
    final bestaandModel = widget.bestaandeOpmeting?.sektionalePoortData;
    if (bestaandModel != null) {
      return bestaandModel;
    }

    return OpmetingSektionalePoortModel(
      projectKleurWaarde: widget.projectKleur.trim(),
    );
  }

  @override
  void didUpdateWidget(covariant OpmetingSektionalePoortFiche oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectKleur.trim() == widget.projectKleur.trim()) return;
    final bijgewerkt = _synchroniseerProjectKleur(_model);
    if (bijgewerkt != _model) {
      setState(() => _model = bijgewerkt);
    }
  }

  Future<void> _laadInstellingen() async {
    final instellingen =
        await AppStorage.laadOpmetingSektionalePoortInstellingen();
    if (!mounted) return;
    setState(() {
      _instellingen = instellingen;
      _model = _normaliseerKleurkeuze(
        _synchroniseerProjectKleur(_model),
        instellingen,
      );
    });
  }

  OpmetingSektionalePoortModel _normaliseerKleurkeuze(
    OpmetingSektionalePoortModel model,
    OpmetingSektionalePoortInstellingen instellingen,
  ) {
    if (model.gebruiktProjectKleur) return _synchroniseerProjectKleur(model);
    if (model.kleur.trim().isNotEmpty) return model;
    if (instellingen.kleuren.isEmpty) {
      return model.copyWith(
        kleur: OpmetingSektionalePoortModel.projectKleurKeuze,
      );
    }
    return model.copyWith(kleur: instellingen.kleuren.first);
  }

  OpmetingSektionalePoortModel _synchroniseerProjectKleur(
    OpmetingSektionalePoortModel model,
  ) {
    if (!model.gebruiktProjectKleur) return model;
    final kleur = widget.projectKleur.trim();
    if (model.projectKleurWaarde.trim() == kleur) return model;
    return model.copyWith(projectKleurWaarde: kleur);
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

  void _sluitFiche() {
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
          content: Text('Sektionale poort opslaan is niet gelukt: $fout'),
        ),
      );
    } finally {
      if (mounted) setState(() => _bewarenBezig = false);
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
    final technischeSelecties = _bouwTechnischePrijsselecties(modelVoorOpslag);

    return OpmetingOverzichtRaamItem(
      id: widget.bestaandeOpmeting?.id ?? '',
      titel: 'Sektionale poort Type ${modelVoorOpslag.modelType.label}',
      klantNaam: klantNaam,
      formulierType: 'sektionalePoort',
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
        breedteMm: modelVoorOpslag.breedteMm > 0
            ? modelVoorOpslag.breedteMm
            : 2400,
        hoogteMm: modelVoorOpslag.hoogteMm > 0
            ? modelVoorOpslag.hoogteMm
            : 2200,
      ),
      tekeningData: OpmetingOverzichtTekeningData.leeg(),
      technischeRegels: OpmetingSektionalePoortTechnischeRegelsHelper.bouw(
        modelVoorOpslag,
      ),
      technischeContainers: const <OpmetingOverzichtTechnischeContainer>[],
      keuzeSelectiesPerKader: technischeSelecties,
      fotos: modelVoorOpslag.fotos,
      notities: modelVoorOpslag.notities,
      offertePrijsData:
          widget.bestaandeOpmeting?.offertePrijsData ?? standaardPrijsData,
      sektionalePoortData: modelVoorOpslag,
    );
  }

  Map<String, Map<String, OpmetingRaamKeuzeSelectie>>
  _bouwTechnischePrijsselecties(OpmetingSektionalePoortModel model) {
    final resultaat = <String, Map<String, OpmetingRaamKeuzeSelectie>>{};

    for (final kaderEntry
        in (widget.bestaandeOpmeting?.keuzeSelectiesPerKader ??
                const <String, Map<String, OpmetingRaamKeuzeSelectie>>{})
            .entries) {
      resultaat[kaderEntry.key] = Map<String, OpmetingRaamKeuzeSelectie>.from(
        kaderEntry.value,
      );
    }

    const werkvlakId = 'sektionalePoort';
    final selecties = Map<String, OpmetingRaamKeuzeSelectie>.from(
      resultaat[werkvlakId] ?? const <String, OpmetingRaamKeuzeSelectie>{},
    );
    selecties.remove(OpmetingSektionalePoortModel.technischMenuInstallatieId);

    if (model.plaatsenEnAansluitenStopcontact) {
      selecties[OpmetingSektionalePoortModel.technischMenuInstallatieId] =
          const OpmetingRaamKeuzeSelectie(
            menuId: OpmetingSektionalePoortModel.technischMenuInstallatieId,
            optieId: OpmetingSektionalePoortModel.technischStopcontactKeuzeId,
          );
    }

    if (selecties.isEmpty) {
      resultaat.remove(werkvlakId);
    } else {
      resultaat[werkvlakId] = selecties;
    }

    return Map<String, Map<String, OpmetingRaamKeuzeSelectie>>.unmodifiable(
      resultaat.map(
        (sleutel, waarde) => MapEntry(
          sleutel,
          Map<String, OpmetingRaamKeuzeSelectie>.unmodifiable(waarde),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final klantNaam =
        (widget.klantNaam ?? widget.bestaandeOpmeting?.klantNaam ?? '').trim();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _sluitFiche();
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
                ? 'Opmeting Sektionale poorten'
                : 'Opmeting Sektionale poorten · $klantNaam',
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
            final rechterkolom = OpmetingSektionalePoortRechterkolom(
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
          Expanded(child: OpmetingSektionalePoortTekenvlak(model: _model)),
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
