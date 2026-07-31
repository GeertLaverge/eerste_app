// THIMACO-CONTROLE: VOORZETROLLUIK-DEFINITIEF-PRIJS-MOMENTOPNAME-20260731
// THIMACO-CONTROLE: VOORZETROLLUIK-FICHE-BASIS-FASE-1-20260731
import 'package:flutter/material.dart';

import '../../../app_storage.dart';
import '../../../offerte/prijzen/offerte_artikel_prijs_data_model.dart';
import '../../fotos/opmeting_foto_model.dart';
import '../../kader_samenstelling/opmeting_kader_samenstelling_model.dart';
import '../../overzicht/opmeting_overzicht_model.dart';
import '../../raam/opmeting_raam_notities.dart';
import '../voorzetscreen/opmeting_voorzetscreen_instellingen_model.dart';
import 'opmeting_voorzetrolluik_instellingen_model.dart';
import 'opmeting_voorzetrolluik_model.dart';
import 'opmeting_voorzetrolluik_rechterkolom.dart';
import 'opmeting_voorzetrolluik_technische_regels_helper.dart';
import 'opmeting_voorzetrolluik_tekenvlak.dart';

class OpmetingVoorzetrolluikFiche extends StatefulWidget {
  const OpmetingVoorzetrolluikFiche({
    super.key,
    this.klantNaam,
    this.bestaandeOpmeting,
    this.projectKleur = '',
  });

  final String? klantNaam;
  final OpmetingOverzichtRaamItem? bestaandeOpmeting;
  final String projectKleur;

  @override
  State<OpmetingVoorzetrolluikFiche> createState() {
    return _OpmetingVoorzetrolluikFicheState();
  }
}

class _OpmetingVoorzetrolluikFicheState
    extends State<OpmetingVoorzetrolluikFiche> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);

  final TextEditingController _notitiesController = TextEditingController();

  late OpmetingVoorzetrolluikModel _model;
  OpmetingVoorzetrolluikInstellingen _instellingen =
      const OpmetingVoorzetrolluikInstellingen();
  List<OpmetingVoorzetscreenPoederkleur> _poederkleuren =
      const <OpmetingVoorzetscreenPoederkleur>[];
  bool _bewarenBezig = false;

  @override
  void initState() {
    super.initState();
    _model =
        widget.bestaandeOpmeting?.voorzetrolluikData ??
        const OpmetingVoorzetrolluikModel();
    _model = _synchroniseerProjectKleur(_model);
    _notitiesController.text = _model.notities;
    _notitiesController.addListener(_verwerkNotities);
    _laadInstellingen();
  }

  @override
  void didUpdateWidget(covariant OpmetingVoorzetrolluikFiche oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectKleur.trim() == widget.projectKleur.trim()) return;
    final bijgewerkt = _synchroniseerProjectKleur(_model);
    if (bijgewerkt != _model) {
      setState(() => _model = bijgewerkt);
    }
  }

  OpmetingVoorzetrolluikModel _synchroniseerProjectKleur(
    OpmetingVoorzetrolluikModel model,
  ) {
    if (model.kleurbron != OpmetingVoorzetrolluikKleurbron.projectKleur) {
      return model;
    }
    final projectKleur = widget.projectKleur.trim();
    if (model.projectKleurWaarde.trim() == projectKleur) return model;
    return model.copyWith(projectKleurWaarde: projectKleur);
  }

  Future<void> _laadInstellingen() async {
    final resultaten = await Future.wait<Object>(<Future<Object>>[
      AppStorage.laadOpmetingVoorzetrolluikInstellingen(),
      AppStorage.laadOpmetingVoorzetscreenInstellingen(),
    ]);
    if (!mounted) return;

    final instellingen = resultaten[0] as OpmetingVoorzetrolluikInstellingen;
    final screenInstellingen =
        resultaten[1] as OpmetingVoorzetscreenInstellingen;

    setState(() {
      _instellingen = instellingen;
      _poederkleuren = screenInstellingen.poederkleuren;
      _model = _vulStandaardKeuzesAan(_model, instellingen, _poederkleuren);
    });
  }

  OpmetingVoorzetrolluikModel _vulStandaardKeuzesAan(
    OpmetingVoorzetrolluikModel model,
    OpmetingVoorzetrolluikInstellingen instellingen,
    List<OpmetingVoorzetscreenPoederkleur> poederkleuren,
  ) {
    var resultaat = _synchroniseerProjectKleur(model);

    if (resultaat.lamelKleurNaam.trim().isEmpty &&
        instellingen.lamelkleuren.isNotEmpty) {
      final kleur = instellingen.lamelkleuren.first;
      resultaat = resultaat.copyWith(
        lamelKleurNaam: kleur.naam,
        lamelKleurCode: kleur.code,
        lamelKleurHex: kleur.hexKleur,
      );
    }

    if (resultaat.kleurbron ==
            OpmetingVoorzetrolluikKleurbron.standaardPoederlak &&
        resultaat.kleurBenaming.trim().isEmpty &&
        poederkleuren.isNotEmpty) {
      final kleur = poederkleuren.first;
      resultaat = resultaat.copyWith(
        kleurBenaming: kleur.benaming,
        poedercode: kleur.poedercode,
        poederlakMogelijk: kleur.poederlakMogelijk,
        natlakMogelijk: kleur.natlakMogelijk,
      );
    }

    final motoren = resultaat.zonnecel
        ? instellingen.zonnecelMotoren
        : instellingen.motoren;
    final huidigId = <String>[
      resultaat.motorType.trim().toLowerCase(),
      resultaat.motorMerk.trim().toLowerCase(),
      resultaat.motorOmschrijving.trim().toLowerCase(),
    ].join('|');
    final geldig = motoren.any((motor) => motor.id == huidigId);
    if (!geldig && motoren.isNotEmpty) {
      final motor = motoren.first;
      resultaat = resultaat.copyWith(
        motorType: motor.type,
        motorMerk: motor.merk,
        motorOmschrijving: motor.omschrijving,
        motorExtraInfo: motor.extraInfo,
      );
    } else if (motoren.isEmpty) {
      resultaat = resultaat.copyWith(
        motorType: '',
        motorMerk: '',
        motorOmschrijving: '',
        motorExtraInfo: '',
      );
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
          content: Text('Voorzetrolluik opslaan is niet gelukt: $fout'),
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
      titel: 'Voorzetrolluik',
      klantNaam: klantNaam,
      formulierType: 'voorzetrolluik',
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
      technischeRegels: OpmetingVoorzetrolluikTechnischeRegelsHelper.bouw(
        modelVoorOpslag,
      ),
      technischeContainers: const <OpmetingOverzichtTechnischeContainer>[],
      fotos: modelVoorOpslag.fotos,
      notities: modelVoorOpslag.notities,
      offertePrijsData: prijsData,
      voorzetrolluikData: modelVoorOpslag,
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
                ? 'Opmeting Voorzetrolluik'
                : 'Opmeting Voorzetrolluik · $klantNaam',
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
            final rechterkolom = OpmetingVoorzetrolluikRechterkolom(
              model: _model,
              instellingen: _instellingen,
              poederkleuren: _poederkleuren,
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
          Expanded(child: OpmetingVoorzetrolluikTekenvlak(model: _model)),
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
