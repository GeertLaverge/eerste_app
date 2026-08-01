import 'package:flutter/material.dart';

import '../../../app_storage.dart';
import '../../../offerte/prijzen/offerte_artikel_prijs_data_model.dart';
import '../../fotos/opmeting_foto_model.dart';
import '../../kader_samenstelling/opmeting_kader_samenstelling_model.dart';
import '../../overzicht/opmeting_overzicht_model.dart';
import '../../raam/opmeting_raam_notities.dart';
import 'opmeting_uitvalscherm_instellingen_model.dart';
import 'opmeting_uitvalscherm_model.dart';
import 'opmeting_uitvalscherm_rechterkolom.dart';
import 'opmeting_uitvalscherm_technische_regels_helper.dart';
import 'opmeting_uitvalscherm_tekenvlak.dart';

class OpmetingUitvalschermFiche extends StatefulWidget {
  const OpmetingUitvalschermFiche({
    super.key,
    this.klantNaam,
    this.bestaandeOpmeting,
    this.projectKleur = '',
  });

  final String? klantNaam;
  final OpmetingOverzichtRaamItem? bestaandeOpmeting;
  final String projectKleur;

  @override
  State<OpmetingUitvalschermFiche> createState() =>
      _OpmetingUitvalschermFicheState();
}

class _OpmetingUitvalschermFicheState extends State<OpmetingUitvalschermFiche> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);

  final TextEditingController _notitiesController = TextEditingController();

  late OpmetingUitvalschermModel _model;
  OpmetingUitvalschermInstellingen _instellingen =
      const OpmetingUitvalschermInstellingen();
  bool _bewarenBezig = false;

  @override
  void initState() {
    super.initState();
    _model =
        widget.bestaandeOpmeting?.uitvalschermData ??
        const OpmetingUitvalschermModel();
    _model = _synchroniseerProjectKleur(_model);
    _notitiesController.text = _model.notities;
    _notitiesController.addListener(_verwerkNotities);
    _laadInstellingen();
  }

  @override
  void didUpdateWidget(covariant OpmetingUitvalschermFiche oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectKleur.trim() == widget.projectKleur.trim()) return;
    setState(() => _model = _synchroniseerProjectKleur(_model));
  }

  Future<void> _laadInstellingen() async {
    final instellingen =
        await AppStorage.laadOpmetingUitvalschermInstellingen();
    if (!mounted) return;
    setState(() {
      _instellingen = instellingen;
      _model = _vulStandaardKeuzesAan(_model, instellingen);
    });
  }

  OpmetingUitvalschermModel _synchroniseerProjectKleur(
    OpmetingUitvalschermModel model,
  ) {
    if (model.kleurbron != OpmetingUitvalschermKleurbron.projectKleur) {
      return model;
    }
    return model.copyWith(projectKleurWaarde: widget.projectKleur.trim());
  }

  OpmetingUitvalschermModel _vulStandaardKeuzesAan(
    OpmetingUitvalschermModel model,
    OpmetingUitvalschermInstellingen instellingen,
  ) {
    var resultaat = _synchroniseerProjectKleur(model);

    if (resultaat.kleurbron ==
            OpmetingUitvalschermKleurbron.standaardPoederkleur &&
        instellingen.draagstructuurKleuren.isNotEmpty &&
        resultaat.draagstructuurKleur.trim().isEmpty) {
      final kleur = instellingen.draagstructuurKleuren.first;
      resultaat = resultaat.copyWith(
        draagstructuurKleur: kleur.naam,
        draagstructuurKleurCode: kleur.code,
      );
    }

    if (instellingen.doeken.isNotEmpty &&
        !instellingen.doeken.any(
          (doek) => doek.id == resultaat.doekCode.trim().toUpperCase(),
        )) {
      final doek = instellingen.doeken.first;
      resultaat = resultaat.copyWith(
        doekCode: doek.code,
        doekKleur: doek.kleur,
        doekHex: doek.hex,
      );
    }

    final motoren = resultaat.type.is700LX
        ? instellingen.motoren.where((motor) => motor.isDraadloos).toList()
        : instellingen.motoren;
    final huidigId = <String>[
      resultaat.motorType,
      resultaat.motorMerk,
      resultaat.motorOmschrijving,
    ].map((deel) => deel.trim().toLowerCase()).join('|');
    if (motoren.isNotEmpty && !motoren.any((motor) => motor.id == huidigId)) {
      final motor = motoren.first;
      resultaat = resultaat.copyWith(
        motorType: motor.type,
        motorMerk: motor.merk,
        motorOmschrijving: motor.omschrijving,
      );
    }

    if (resultaat.type.is700LX) {
      resultaat = resultaat.copyWith(bediening: 'Handzender Somfy Situo 5 Var');
    } else if (instellingen.bedieningen.isNotEmpty &&
        !instellingen.bedieningen.contains(resultaat.bediening)) {
      resultaat = resultaat.copyWith(bediening: instellingen.bedieningen.first);
    }

    return resultaat;
  }

  @override
  void dispose() {
    _notitiesController.removeListener(_verwerkNotities);
    _notitiesController.dispose();
    super.dispose();
  }

  void _verwerkNotities() {
    if (_notitiesController.text == _model.notities) return;
    setState(
      () => _model = _model.copyWith(notities: _notitiesController.text),
    );
  }

  void _verwerkFotos(List<OpmetingFoto> fotos) {
    setState(
      () => _model = _model.copyWith(
        fotos: List<OpmetingFoto>.unmodifiable(fotos),
      ),
    );
  }

  Future<void> _sluitFiche() async {
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _bewaarFiche() async {
    if (_bewarenBezig) return;
    setState(() => _bewarenBezig = true);
    try {
      final opmeting = _maakOverzichtItem();
      final resultaat = widget.bestaandeOpmeting == null
          ? await AppStorage.voegOpmetingToe(opmeting)
          : await AppStorage.werkOpmetingBij(opmeting);
      if (!mounted) return;
      Navigator.of(context).pop(resultaat);
    } catch (fout) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text('Uitvalscherm opslaan is niet gelukt: $fout'),
        ),
      );
    } finally {
      if (mounted) setState(() => _bewarenBezig = false);
    }
  }

  OpmetingOverzichtRaamItem _maakOverzichtItem() {
    final model = _model.copyWith(
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
    final klantNaam =
        (widget.klantNaam ?? widget.bestaandeOpmeting?.klantNaam ?? '').trim();

    return OpmetingOverzichtRaamItem(
      id: widget.bestaandeOpmeting?.id ?? '',
      titel: 'Uitvalscherm',
      klantNaam: klantNaam,
      formulierType: 'uitvalscherm',
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
      dagmaatBreedteMm: model.breedteMm,
      dagmaatHoogteMm: model.uitvalMm,
      raammaatBreedteMm: model.breedteMm,
      raammaatHoogteMm: model.uitvalMm,
      kaderSamenstelling: OpmetingKaderSamenstelling.basis(
        breedteMm: model.breedteMm,
        hoogteMm: model.uitvalMm,
      ),
      tekeningData: OpmetingOverzichtTekeningData.leeg(),
      technischeRegels: OpmetingUitvalschermTechnischeRegelsHelper.bouw(model),
      technischeContainers: const <OpmetingOverzichtTechnischeContainer>[],
      fotos: model.fotos,
      notities: model.notities,
      offertePrijsData: prijsData,
      uitvalschermData: model,
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
          centerTitle: true,
          leading: IconButton(
            onPressed: _sluitFiche,
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
          title: Text(
            klantNaam.isEmpty
                ? 'Opmeting Uitvalscherm'
                : 'Opmeting Uitvalscherm · $klantNaam',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton.icon(
                onPressed: _bewarenBezig ? null : _bewaarFiche,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _groen,
                ),
                icon: _bewarenBezig
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
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
            final tekening = _bouwTekeningEnNotities();
            final rechterkolom = OpmetingUitvalschermRechterkolom(
              model: _model,
              instellingen: _instellingen,
              projectKleur: widget.projectKleur,
              onGewijzigd: (model) {
                setState(() {
                  _model = model.copyWith(
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
                        Expanded(flex: 60, child: tekening),
                        const SizedBox(width: 12),
                        Expanded(flex: 40, child: rechterkolom),
                      ],
                    )
                  : Column(
                      children: <Widget>[
                        Expanded(flex: 43, child: tekening),
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
          Expanded(child: OpmetingUitvalschermTekenvlak(model: _model)),
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
