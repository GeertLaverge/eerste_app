// THIMACO-CONTROLE: ALGEMENE-OPMETING-NIEUWE-HUISSTIJL-20260914
// THIMACO-CONTROLE: ALGEMENE-OPMETING-GEEN-LOKALE-PRIJS-PER-POSITIE-20260817
// THIMACO-CONTROLE: PRIJSARCHITECTUUR-STAP5D4B1-ALGEMENE-OPMETING-ZONDER-OUDE-VRIJE-PRIJSROUTE-20260814
// THIMACO-CONTROLE: PRIJSARCHITECTUUR-OPRUIMEN-STAP3-ANALYZERFIX-ALGEMENE-OPMETING-20260814
// THIMACO-CONTROLE: ALGEMENE-OPMETING-AANKOOP-VERKOOP-FICHE-20260802
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../app_storage.dart';
import '../../offerte/prijzen/offerte_artikel_prijs_data_model.dart';
import '../../sync/onedrive_afbeelding_kiezer_dialog.dart';
import '../../ui/thimaco_huisstijl.dart';
import '../fotos/opmeting_foto_model.dart';
import '../kader_samenstelling/opmeting_kader_samenstelling_model.dart';
import '../overzicht/opmeting_overzicht_model.dart';
import 'opmeting_algemene_opmeting_blok_model.dart';
import 'opmeting_algemene_opmeting_model.dart';
import 'opmeting_algemene_opmeting_rechterkolom.dart';
import 'opmeting_algemene_opmeting_technische_regels_helper.dart';
import 'opmeting_algemene_opmeting_tekenvlak.dart';

class OpmetingAlgemeneOpmetingFiche extends StatefulWidget {
  const OpmetingAlgemeneOpmetingFiche({
    super.key,
    this.klantNaam,
    this.bestaandeOpmeting,
  });

  final String? klantNaam;
  final OpmetingOverzichtRaamItem? bestaandeOpmeting;

  @override
  State<OpmetingAlgemeneOpmetingFiche> createState() =>
      _OpmetingAlgemeneOpmetingFicheState();
}

class _OpmetingAlgemeneOpmetingFicheState
    extends State<OpmetingAlgemeneOpmetingFiche> {
  static const Color _rand = ThimacoKleuren.rand;
  static const int _maximumFotos = 4;

  final ImagePicker _imagePicker = ImagePicker();

  late OpmetingAlgemeneOpmetingModel _model;
  bool _bewarenBezig = false;
  bool _afbeeldingBezig = false;

  @override
  void initState() {
    super.initState();
    final beginModel =
        widget.bestaandeOpmeting?.algemeneOpmetingData ??
        OpmetingAlgemeneOpmetingModel(
          titel: widget.bestaandeOpmeting?.titel ?? '',
          omschrijving: widget.bestaandeOpmeting?.notities ?? '',
          fotos: widget.bestaandeOpmeting?.fotos ?? const <OpmetingFoto>[],
        );
    _model = _normaliseerBeginModel(beginModel);
  }

  OpmetingAlgemeneOpmetingModel _normaliseerBeginModel(
    OpmetingAlgemeneOpmetingModel model,
  ) {
    final oudeOmschrijving = model.omschrijving.trim();
    if (oudeOmschrijving.isEmpty) {
      return model.copyWith(omschrijving: '');
    }

    final bestaatAl = model.blokken.any((blok) {
      return !blok.isPrijs &&
          blok.omschrijving.trim().toLowerCase() ==
              oudeOmschrijving.toLowerCase();
    });

    if (bestaatAl) {
      return model.copyWith(omschrijving: '');
    }

    return model.copyWith(
      omschrijving: '',
      blokken: <OpmetingAlgemeneOpmetingBlok>[
        OpmetingAlgemeneOpmetingBlok(
          id: 'algemene_oude_omschrijving_${DateTime.now().microsecondsSinceEpoch}',
          type: OpmetingAlgemeneOpmetingBlokType.tekst,
          omschrijving: oudeOmschrijving,
        ),
        ...model.blokken,
      ],
    );
  }

  Future<void> _neemFoto() async {
    if (_afbeeldingBezig || !_kanFotoToevoegen()) return;
    setState(() => _afbeeldingBezig = true);
    try {
      final gekozenFoto = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 70,
        requestFullMetadata: false,
      );
      if (gekozenFoto == null) return;
      final bytes = await gekozenFoto.readAsBytes();
      if (bytes.isEmpty) throw StateError('De gemaakte foto is leeg.');
      final nu = DateTime.now().toUtc();
      _voegFotoToe(
        OpmetingFoto(
          id: 'algemeen_foto_${nu.microsecondsSinceEpoch}',
          bestandsNaam: gekozenFoto.name.trim().isEmpty
              ? 'algemene_opmeting_${nu.microsecondsSinceEpoch}.jpg'
              : gekozenFoto.name,
          mimeType: _mimeTypeVoor(gekozenFoto.name),
          gemaaktOp: nu.toIso8601String(),
          base64Data: base64Encode(bytes),
        ),
      );
    } catch (fout) {
      _toonFout('Foto nemen is niet gelukt: $fout');
    } finally {
      if (mounted) setState(() => _afbeeldingBezig = false);
    }
  }

  Future<void> _laadUitOneDrive() async {
    if (_afbeeldingBezig || !_kanFotoToevoegen()) return;
    setState(() => _afbeeldingBezig = true);
    try {
      final foto = await OneDriveAfbeeldingKiezerDialog.toon(context: context);
      if (foto != null && mounted) _voegFotoToe(foto);
    } catch (fout) {
      _toonFout('Afbeelding laden is niet gelukt: $fout');
    } finally {
      if (mounted) setState(() => _afbeeldingBezig = false);
    }
  }

  bool _kanFotoToevoegen() {
    if (_model.fotos.length < _maximumFotos) return true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Er kunnen maximaal vier afbeeldingen worden toegevoegd.',
        ),
      ),
    );
    return false;
  }

  void _voegFotoToe(OpmetingFoto foto) {
    setState(() {
      _model = _model.copyWith(
        fotos: List<OpmetingFoto>.unmodifiable(<OpmetingFoto>[
          ..._model.fotos,
          foto,
        ]),
      );
    });
  }

  void _verwijderFoto(int index) {
    final fotos = List<OpmetingFoto>.from(_model.fotos);
    if (index < 0 || index >= fotos.length) return;
    fotos.removeAt(index);
    setState(() => _model = _model.copyWith(fotos: fotos));
  }

  void _verplaatsFoto(int index, int richting) {
    final fotos = List<OpmetingFoto>.from(_model.fotos);
    final doel = index + richting;
    if (index < 0 ||
        index >= fotos.length ||
        doel < 0 ||
        doel >= fotos.length) {
      return;
    }
    final foto = fotos.removeAt(index);
    fotos.insert(doel, foto);
    setState(() => _model = _model.copyWith(fotos: fotos));
  }

  Future<void> _bewaarFiche() async {
    if (_bewarenBezig) return;
    if (_model.titel.trim().isEmpty) {
      _toonFout('Vul bovenaan een titel in.');
      return;
    }
    setState(() => _bewarenBezig = true);
    try {
      final opmeting = _maakOverzichtItem();
      final resultaat = widget.bestaandeOpmeting == null
          ? await AppStorage.voegOpmetingToe(opmeting)
          : await AppStorage.werkOpmetingBij(opmeting);
      if (!mounted) return;
      Navigator.of(context).pop(resultaat);
    } catch (fout) {
      _toonFout('Algemene opmeting opslaan is niet gelukt: $fout');
    } finally {
      if (mounted) setState(() => _bewarenBezig = false);
    }
  }

  OpmetingOverzichtRaamItem _maakOverzichtItem() {
    final model = _model.copyWith(
      titel: _model.titel.trim(),
      omschrijving: _model.omschrijving.trim(),
      blokken: List<OpmetingAlgemeneOpmetingBlok>.unmodifiable(_model.blokken),
      fotos: List<OpmetingFoto>.unmodifiable(_model.fotos),
    );
    final bestaandePrijsData =
        widget.bestaandeOpmeting?.offertePrijsData ??
        const OfferteArtikelPrijsDataModel();
    final prijsData = bestaandePrijsData.copyWith(
      prijsPerStukExclBtw: model.prijsTotaalExclBtw,
      toegepasteTechnischePrijsregels: const [],
      technischePrijsSignatuur: '',
      prijsPerPositieRegels: const [],
    );
    final klantNaam =
        (widget.klantNaam ?? widget.bestaandeOpmeting?.klantNaam ?? '').trim();

    return OpmetingOverzichtRaamItem(
      id: widget.bestaandeOpmeting?.id ?? '',
      titel: model.effectieveTitel,
      klantNaam: klantNaam,
      formulierType: 'algemeneOpmeting',
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
      dagmaatBreedteMm: 1000,
      dagmaatHoogteMm: 700,
      raammaatBreedteMm: 1000,
      raammaatHoogteMm: 700,
      kaderSamenstelling: OpmetingKaderSamenstelling.basis(
        breedteMm: 1000,
        hoogteMm: 700,
      ),
      tekeningData: OpmetingOverzichtTekeningData.leeg(),
      technischeRegels: OpmetingAlgemeneOpmetingTechnischeRegelsHelper.bouw(
        model,
      ),
      technischeContainers:
          OpmetingAlgemeneOpmetingTechnischeRegelsHelper.bouwContainers(model),
      fotos: model.fotos,
      notities: model.omschrijving,
      offertePrijsData: prijsData,
      algemeneOpmetingData: model,
    );
  }

  Future<void> _sluitFiche() async {
    if (mounted) Navigator.of(context).pop();
  }

  void _toonFout(String tekst) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 8,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: ThimacoKleuren.rand),
        ),
        content: Row(
          children: <Widget>[
            const Icon(
              Icons.error_outline_rounded,
              size: 18,
              color: ThimacoKleuren.rood,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                tekst,
                style: const TextStyle(
                  color: ThimacoKleuren.antraciet,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _mimeTypeVoor(String naam) {
    final lager = naam.trim().toLowerCase();
    if (lager.endsWith('.png')) return 'image/png';
    return 'image/jpeg';
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
        backgroundColor: ThimacoKleuren.achtergrond,
        appBar: AppBar(
          toolbarHeight: 47,
          backgroundColor: Colors.white,
          foregroundColor: ThimacoKleuren.antraciet,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          leadingWidth: 46,
          leading: Center(
            child: ThimacoIcoonActie(
              icoon: Icons.arrow_back_rounded,
              tooltip: 'Terug',
              onPressed: _sluitFiche,
            ),
          ),
          titleSpacing: 0,
          title: Text(
            klantNaam.isEmpty
                ? 'Algemene opmeting'
                : 'Algemene opmeting · $klantNaam',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ThimacoKleuren.antraciet,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: <Widget>[
            Center(
              child: ThimacoTekstActie(
                tekst: 'Annuleren',
                onPressed: _sluitFiche,
              ),
            ),
            const SizedBox(width: 6),
            Center(
              child: SizedBox(
                height: 32,
                child: ElevatedButton.icon(
                  onPressed: _bewarenBezig ? null : _bewaarFiche,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: ThimacoKleuren.oranje,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        ThimacoKleuren.oranje.withValues(alpha: 0.45),
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  icon: _bewarenBezig
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          widget.bestaandeOpmeting == null
                              ? Icons.add_rounded
                              : Icons.check_rounded,
                          size: 17,
                        ),
                  label: Text(
                    widget.bestaandeOpmeting == null ? 'Toevoegen' : 'Bewaren',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(
              height: 1,
              thickness: 1,
              color: ThimacoKleuren.rand,
            ),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final liggend = constraints.maxWidth >= 900;
            final afbeeldingen = Container(
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
              child: OpmetingAlgemeneOpmetingTekenvlak(
                fotos: _model.fotos,
                onOneDrive: _afbeeldingBezig ? null : _laadUitOneDrive,
                onCamera: _afbeeldingBezig ? null : _neemFoto,
                onVerwijderen: _verwijderFoto,
                onVerplaatsen: _verplaatsFoto,
              ),
            );
            final rechterkolom = OpmetingAlgemeneOpmetingRechterkolom(
              model: _model,
              onGewijzigd: (model) => setState(() => _model = model),
            );

            return Padding(
              padding: const EdgeInsets.all(12),
              child: liggend
                  ? Row(
                      children: <Widget>[
                        Expanded(flex: 55, child: afbeeldingen),
                        const SizedBox(width: 12),
                        Expanded(flex: 45, child: rechterkolom),
                      ],
                    )
                  : Column(
                      children: <Widget>[
                        Expanded(flex: 40, child: afbeeldingen),
                        const SizedBox(height: 12),
                        Expanded(flex: 60, child: rechterkolom),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}
