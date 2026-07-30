// THIMACO-CONTROLE: VELUX-STANDAARDMAAT-SK06-20260730-0531
// THIMACO-CONTROLE: VELUX-DAKRAAM-FICHE-FASE-1-2-20260729-2030
import 'package:flutter/material.dart';

import '../../../app_storage.dart';
import '../../../offerte/prijzen/offerte_artikel_prijs_data_model.dart';
import '../../fotos/opmeting_foto_model.dart';
import '../../kader_samenstelling/opmeting_kader_samenstelling_model.dart';
import '../../overzicht/opmeting_overzicht_model.dart';
import '../../raam/opmeting_raam_notities.dart';
import 'opmeting_velux_dakraam_instellingen_model.dart';
import 'opmeting_velux_dakraam_model.dart';
import 'opmeting_velux_dakraam_prijs_helper.dart';
import 'opmeting_velux_dakraam_rechterkolom.dart';
import 'opmeting_velux_dakraam_technische_regels_helper.dart';
import 'opmeting_velux_dakraam_tekenvlak.dart';

class OpmetingVeluxDakraamFiche extends StatefulWidget {
  const OpmetingVeluxDakraamFiche({
    super.key,
    this.klantNaam,
    this.bestaandeOpmeting,
  });

  final String? klantNaam;
  final OpmetingOverzichtRaamItem? bestaandeOpmeting;

  @override
  State<OpmetingVeluxDakraamFiche> createState() {
    return _OpmetingVeluxDakraamFicheState();
  }
}

class _OpmetingVeluxDakraamFicheState extends State<OpmetingVeluxDakraamFiche> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);

  final TextEditingController _notitiesController = TextEditingController();

  OpmetingVeluxDakraamInstellingen? _instellingen;
  late OpmetingVeluxDakraamModel _model;
  bool _laden = true;
  bool _bewarenBezig = false;

  @override
  void initState() {
    super.initState();
    _model =
        widget.bestaandeOpmeting?.veluxDakraamData ??
        const OpmetingVeluxDakraamModel();
    _notitiesController.text = _model.notities;
    _notitiesController.addListener(_verwerkNotities);
    _laadInstellingen();
  }

  @override
  void dispose() {
    _notitiesController.removeListener(_verwerkNotities);
    _notitiesController.dispose();
    super.dispose();
  }

  Future<void> _laadInstellingen() async {
    final instellingen =
        await AppStorage.laadOpmetingVeluxDakraamInstellingen();
    if (!mounted) return;
    setState(() {
      _instellingen = instellingen;
      _model = OpmetingVeluxDakraamPrijsHelper.bereken(
        model: _model,
        instellingen: instellingen,
      );
      _laden = false;
    });
  }

  void _verwerkNotities() {
    final tekst = _notitiesController.text;
    if (tekst == _model.notities) return;
    setState(() => _model = _model.copyWith(notities: tekst));
  }

  void _verwerkFotos(List<OpmetingFoto> fotos) {
    setState(() => _model = _model.copyWith(fotos: fotos));
  }

  void _sluitFiche() {
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _voegToeAanOverzicht() async {
    if (_bewarenBezig || _instellingen == null) return;
    setState(() => _bewarenBezig = true);

    try {
      final opmeting = _maakOverzichtItem();
      final opgeslagen = widget.bestaandeOpmeting == null
          ? await AppStorage.voegOpmetingToe(opmeting)
          : await AppStorage.werkOpmetingBij(opmeting);
      if (!mounted) return;
      Navigator.of(context).pop(opgeslagen);
    } catch (fout) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFDC2626),
          content: Text('Velux dakraam opslaan is niet gelukt: $fout'),
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
      fotos: _model.fotos,
    );
    final bestaandePrijsData =
        widget.bestaandeOpmeting?.offertePrijsData ??
        const OfferteArtikelPrijsDataModel();
    final prijsData = bestaandePrijsData.copyWith(
      prijsPerStukExclBtw: modelVoorOpslag.prijsPerArtikelEquivalentExclBtw,
      toegepasteTechnischePrijsregels: const [],
      technischePrijsSignatuur: '',
    );

    final breedte = modelVoorOpslag.breedteMm > 0
        ? modelVoorOpslag.breedteMm
        : 1140;
    final hoogte = modelVoorOpslag.hoogteMm > 0
        ? modelVoorOpslag.hoogteMm
        : 1180;
    final titel = modelVoorOpslag.alleenToebehoren
        ? 'Velux accessoires'
        : 'Velux ${modelVoorOpslag.productCode} '
              '${modelVoorOpslag.maatCode}';

    return OpmetingOverzichtRaamItem(
      id: widget.bestaandeOpmeting?.id ?? '',
      titel: titel,
      klantNaam: klantNaam,
      formulierType: 'veluxDakraam',
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
      dagmaatBreedteMm: breedte,
      dagmaatHoogteMm: hoogte,
      raammaatBreedteMm: breedte,
      raammaatHoogteMm: hoogte,
      kaderSamenstelling: OpmetingKaderSamenstelling.basis(
        breedteMm: breedte,
        hoogteMm: hoogte,
      ),
      tekeningData: OpmetingOverzichtTekeningData.leeg(),
      technischeRegels: OpmetingVeluxDakraamTechnischeRegelsHelper.bouw(
        modelVoorOpslag,
      ),
      technischeContainers: const <OpmetingOverzichtTechnischeContainer>[],
      keuzeSelectiesPerKader: const {},
      fotos: modelVoorOpslag.fotos,
      notities: modelVoorOpslag.notities,
      offertePrijsData: prijsData,
      veluxDakraamData: modelVoorOpslag,
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
                ? 'Opmeting Velux dakramen'
                : 'Opmeting Velux dakramen · $klantNaam',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton.icon(
                onPressed: _laden || _bewarenBezig
                    ? null
                    : _voegToeAanOverzicht,
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
        body: _laden || _instellingen == null
            ? const Center(child: CircularProgressIndicator(color: _groen))
            : LayoutBuilder(
                builder: (context, constraints) {
                  final liggend = constraints.maxWidth >= 900;
                  final tekenKaart = _bouwTekeningEnNotities();
                  final rechterkolom = OpmetingVeluxDakraamRechterkolom(
                    model: _model,
                    instellingen: _instellingen!,
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
          Expanded(child: OpmetingVeluxDakraamTekenvlak(model: _model)),
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
