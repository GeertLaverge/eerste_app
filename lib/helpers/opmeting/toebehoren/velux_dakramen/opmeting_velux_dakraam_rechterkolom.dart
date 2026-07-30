// THIMACO-CONTROLE: VELUX-ALLEEN-TOEBEHOREN-GOOTSTUKINFO-ZONDER-PRIJZEN-20260730-0531
// THIMACO-CONTROLE: VELUX-RECHTERKOLOM-FASE-1-2-20260729-2030
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'opmeting_velux_dakraam_instellingen_model.dart';
import 'opmeting_velux_dakraam_model.dart';
import 'opmeting_velux_dakraam_prijs_helper.dart';

class OpmetingVeluxDakraamRechterkolom extends StatefulWidget {
  const OpmetingVeluxDakraamRechterkolom({
    super.key,
    required this.model,
    required this.instellingen,
    required this.onGewijzigd,
  });

  final OpmetingVeluxDakraamModel model;
  final OpmetingVeluxDakraamInstellingen instellingen;
  final ValueChanged<OpmetingVeluxDakraamModel> onGewijzigd;

  @override
  State<OpmetingVeluxDakraamRechterkolom> createState() {
    return _OpmetingVeluxDakraamRechterkolomState();
  }
}

class _OpmetingVeluxDakraamRechterkolomState
    extends State<OpmetingVeluxDakraamRechterkolom> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekst = Color(0xFF111827);
  static const Color _grijs = Color(0xFF6B7280);

  final TextEditingController _aantalController = TextEditingController();
  final TextEditingController _rolluikAantalController =
      TextEditingController();
  final TextEditingController _screenAantalController = TextEditingController();
  final TextEditingController _dklAantalController = TextEditingController();
  final TextEditingController _muggengaasAantalController =
      TextEditingController();
  final TextEditingController _muggengaasBreedteController =
      TextEditingController();
  final TextEditingController _muggengaasHoogteController =
      TextEditingController();
  final TextEditingController _kuxAantalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _synchroniseerControllers(forceer: true);
  }

  @override
  void didUpdateWidget(covariant OpmetingVeluxDakraamRechterkolom oldWidget) {
    super.didUpdateWidget(oldWidget);
    _synchroniseerControllers();
  }

  @override
  void dispose() {
    _aantalController.dispose();
    _rolluikAantalController.dispose();
    _screenAantalController.dispose();
    _dklAantalController.dispose();
    _muggengaasAantalController.dispose();
    _muggengaasBreedteController.dispose();
    _muggengaasHoogteController.dispose();
    _kuxAantalController.dispose();
    super.dispose();
  }

  void _synchroniseerControllers({bool forceer = false}) {
    _zetController(
      _aantalController,
      widget.model.veiligAantal,
      forceer: forceer,
    );
    _zetController(
      _rolluikAantalController,
      widget.model.rolluikAantal,
      forceer: forceer,
    );
    _zetController(
      _screenAantalController,
      widget.model.screenAantal,
      forceer: forceer,
    );
    _zetController(
      _dklAantalController,
      widget.model.dklAantal,
      forceer: forceer,
    );
    _zetController(
      _muggengaasAantalController,
      widget.model.muggengaasAantal,
      forceer: forceer,
    );
    _zetController(
      _muggengaasBreedteController,
      widget.model.muggengaasBreedteMm,
      forceer: forceer,
    );
    _zetController(
      _muggengaasHoogteController,
      widget.model.muggengaasHoogteMm,
      forceer: forceer,
    );
    _zetController(
      _kuxAantalController,
      widget.model.kuxAantal,
      forceer: forceer,
    );
  }

  void _zetController(
    TextEditingController controller,
    int waarde, {
    required bool forceer,
  }) {
    if (controller.text.isEmpty && !forceer) return;
    final tekst = waarde.toString();
    if (controller.text == tekst) return;
    controller.value = TextEditingValue(
      text: tekst,
      selection: TextSelection.collapsed(offset: tekst.length),
    );
  }

  void _stuur(OpmetingVeluxDakraamModel model) {
    widget.onGewijzigd(
      OpmetingVeluxDakraamPrijsHelper.bereken(
        model: model,
        instellingen: widget.instellingen,
      ),
    );
  }

  int? _leesInt(String tekst) {
    if (tekst.trim().isEmpty) return null;
    return int.tryParse(tekst.trim());
  }

  bool get _toonAccessoireAantal {
    return widget.model.alleenToebehoren || widget.model.veiligAantal > 1;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rand),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            color: _lichtGroen,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: const Row(
              children: <Widget>[
                Icon(Icons.roofing_outlined, color: _groen, size: 19),
                SizedBox(width: 8),
                Text(
                  'Velux dakramen',
                  style: TextStyle(color: _groen, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: <Widget>[
                _sectie(
                  titel: 'Uitvoering',
                  children: <Widget>[
                    _keuzeRij(
                      label: 'Alleen toebehoren',
                      geselecteerd: widget.model.alleenToebehoren,
                      onTap: () {
                        _stuur(
                          widget.model.copyWith(
                            alleenToebehoren: !widget.model.alleenToebehoren,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _bouwDakvensterSectie(),
                if (!widget.model.alleenToebehoren) ...<Widget>[
                  const SizedBox(height: 8),
                  _bouwGootstukkenSectie(),
                ],
                const SizedBox(height: 8),
                _bouwRolluikenSectie(),
                const SizedBox(height: 8),
                _bouwScreensSectie(),
                const SizedBox(height: 8),
                _bouwDklSectie(),
                const SizedBox(height: 8),
                _bouwMuggengaasSectie(),
                const SizedBox(height: 8),
                _bouwStroomSectie(),
                const SizedBox(height: 8),
                _bouwAfwerkingSectie(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwDakvensterSectie() {
    final maten = widget.instellingen.prijzenVoorProduct(
      widget.model.productCode,
    );
    final alleenToebehoren = widget.model.alleenToebehoren;

    return _sectie(
      titel: alleenToebehoren ? 'Voor welk type dakvenster' : 'Dakvenster',
      subtitel: alleenToebehoren
          ? 'Deze maat bepaalt welke toebehoren bij het bestaande dakvenster passen.'
          : null,
      children: <Widget>[
        if (!alleenToebehoren) ...<Widget>[
          _nummerRij(
            label: 'Aantal',
            controller: _aantalController,
            max: 99,
            onWaarde: (waarde) {
              _stuur(
                widget.model.copyWith(aantal: waarde.clamp(1, 99).toInt()),
              );
            },
            herstelWaarde: widget.model.veiligAantal,
          ),
          const SizedBox(height: 7),
        ],
        DropdownButtonFormField<String>(
          key: ValueKey<String>('velux-maat-${widget.model.maatCode}'),
          initialValue:
              maten.any((prijs) => prijs.maatCode == widget.model.maatCode)
              ? widget.model.maatCode
              : null,
          isExpanded: true,
          decoration: _inputDecoratie(
            alleenToebehoren
                ? 'Type van het bestaande dakvenster'
                : 'Type manueel dakvenster',
          ),
          items: maten
              .map(
                (prijs) => DropdownMenuItem<String>(
                  value: prijs.maatCode,
                  child: Text(
                    '${widget.model.productCode} ${prijs.maatCode} · '
                    '${prijs.breedteCm} × ${prijs.hoogteCm} cm',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(growable: false),
          onChanged: (waarde) {
            if (waarde == null) return;
            _stuur(widget.model.copyWith(maatCode: waarde));
          },
        ),
      ],
    );
  }

  Widget _bouwGootstukkenSectie() {
    return _sectie(
      titel: 'Kies uw gootstukken',
      subtitel: 'Gootstukken voor pannen · maat volgt het dakvenster',
      actie: IconButton(
        tooltip: 'Bekijk informatie en afbeeldingen',
        onPressed: _toonGootstukkenInfo,
        visualDensity: VisualDensity.compact,
        style: IconButton.styleFrom(
          foregroundColor: _groen,
          backgroundColor: _lichtGroen,
          minimumSize: const Size(34, 34),
        ),
        icon: const Icon(Icons.info_outline_rounded, size: 20),
      ),
      children: <Widget>[
        for (final type in OpmetingVeluxGootstukType.values) ...<Widget>[
          _keuzeRij(
            label: type == OpmetingVeluxGootstukType.geen
                ? type.label
                : '${type.label} · gootstukken ${widget.model.maatCode}',
            geselecteerd: widget.model.gootstukType == type,
            onTap: () => _stuur(widget.model.copyWith(gootstukType: type)),
          ),
          if (type != OpmetingVeluxGootstukType.values.last)
            const Divider(height: 7, color: Color(0xFFE5E7EB)),
        ],
      ],
    );
  }

  Future<void> _toonGootstukkenInfo() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final scherm = MediaQuery.sizeOf(dialogContext);
        final breedte = scherm.width > 820 ? 760.0 : scherm.width - 32;
        final hoogte = scherm.height > 720 ? 640.0 : scherm.height - 32;

        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            width: breedte,
            height: hoogte,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 8, 8),
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.info_outline_rounded,
                        color: _groen,
                        size: 22,
                      ),
                      const SizedBox(width: 9),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Informatie gootstukken',
                              style: TextStyle(
                                color: _tekst,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Gootstukken voor pannen',
                              style: TextStyle(color: _grijs, fontSize: 11.5),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Sluiten',
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final kolommen = constraints.maxWidth >= 620 ? 2 : 1;
                      return GridView.count(
                        padding: const EdgeInsets.all(14),
                        crossAxisCount: kolommen,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: kolommen == 2 ? 1.18 : 1.42,
                        children: <Widget>[
                          for (final type in OpmetingVeluxGootstukType.values)
                            if (type != OpmetingVeluxGootstukType.geen)
                              _bouwGootstukInfoKaart(type),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bouwGootstukInfoKaart(OpmetingVeluxGootstukType type) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rand),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                type.assetPad,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    alignment: Alignment.center,
                    color: const Color(0xFFF3F4F6),
                    padding: const EdgeInsets.all(12),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.broken_image_outlined,
                          color: _grijs,
                          size: 34,
                        ),
                        SizedBox(height: 7),
                        Text(
                          'Afbeelding niet gevonden in assets/images.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _grijs,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            child: Text(
              '${type.label} · gootstukken ${widget.model.maatCode}',
              style: const TextStyle(
                color: _tekst,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bouwRolluikenSectie() {
    return _sectie(
      titel: 'Rolluik',
      children: <Widget>[
        for (final type in OpmetingVeluxRolluikType.values)
          _keuzeRij(
            label: type.label,
            geselecteerd: widget.model.rolluikType == type,
            onTap: () => _stuur(widget.model.copyWith(rolluikType: type)),
          ),
        if (widget.model.rolluikType != OpmetingVeluxRolluikType.geen &&
            _toonAccessoireAantal) ...<Widget>[
          const SizedBox(height: 7),
          _nummerRij(
            label: 'Aantal rolluiken',
            controller: _rolluikAantalController,
            max: widget.model.alleenToebehoren ? 99 : widget.model.veiligAantal,
            onWaarde: (waarde) =>
                _stuur(widget.model.copyWith(rolluikAantal: waarde)),
            herstelWaarde: widget.model.rolluikAantal,
          ),
        ],
      ],
    );
  }

  Widget _bouwScreensSectie() {
    return _sectie(
      titel: 'Lichttemperend buitenste zonnescherm (screen)',
      children: <Widget>[
        for (final type in OpmetingVeluxScreenType.values)
          _keuzeRij(
            label: type.label,
            geselecteerd: widget.model.screenType == type,
            onTap: () => _stuur(widget.model.copyWith(screenType: type)),
          ),
        if (widget.model.screenType != OpmetingVeluxScreenType.geen &&
            _toonAccessoireAantal) ...<Widget>[
          const SizedBox(height: 7),
          _nummerRij(
            label: 'Aantal screens',
            controller: _screenAantalController,
            max: widget.model.alleenToebehoren ? 99 : widget.model.veiligAantal,
            onWaarde: (waarde) =>
                _stuur(widget.model.copyWith(screenAantal: waarde)),
            herstelWaarde: widget.model.screenAantal,
          ),
        ],
      ],
    );
  }

  Widget _bouwDklSectie() {
    return _sectie(
      titel: 'Verduisteringsgordijn',
      children: <Widget>[
        _keuzeRij(
          label: 'Manueel DKL',
          geselecteerd: widget.model.verduisteringsgordijnDkl,
          onTap: () => _stuur(
            widget.model.copyWith(
              verduisteringsgordijnDkl: !widget.model.verduisteringsgordijnDkl,
            ),
          ),
        ),
        if (widget.model.verduisteringsgordijnDkl) ...<Widget>[
          const SizedBox(height: 8),
          const Text(
            'Kleur',
            style: TextStyle(
              color: _groen,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          for (final kleur in OpmetingVeluxDklKleur.values)
            _keuzeRij(
              label: kleur.label,
              geselecteerd: widget.model.dklKleur == kleur,
              onTap: () => _stuur(widget.model.copyWith(dklKleur: kleur)),
            ),
          if (_toonAccessoireAantal) ...<Widget>[
            const SizedBox(height: 7),
            _nummerRij(
              label: 'Aantal gordijnen',
              controller: _dklAantalController,
              max: widget.model.alleenToebehoren
                  ? 99
                  : widget.model.veiligAantal,
              onWaarde: (waarde) =>
                  _stuur(widget.model.copyWith(dklAantal: waarde)),
              herstelWaarde: widget.model.dklAantal,
            ),
          ],
        ],
      ],
    );
  }

  Widget _bouwMuggengaasSectie() {
    return _sectie(
      titel: 'Muggengaas',
      children: <Widget>[
        _keuzeRij(
          label: 'Muggengaas',
          detail: widget.model.muggengaasProductCode.trim().isEmpty
              ? null
              : widget.model.muggengaasProductCode,
          geselecteerd: widget.model.muggengaas,
          onTap: () => _stuur(
            widget.model.copyWith(muggengaas: !widget.model.muggengaas),
          ),
        ),
        if (widget.model.muggengaas) ...<Widget>[
          if (widget.model.alleenToebehoren) ...<Widget>[
            const SizedBox(height: 7),
            Row(
              children: <Widget>[
                Expanded(
                  child: _nummerRij(
                    label: 'Maat A breedte',
                    controller: _muggengaasBreedteController,
                    max: 1320,
                    eenheid: 'mm',
                    onWaarde: (waarde) => _stuur(
                      widget.model.copyWith(muggengaasBreedteMm: waarde),
                    ),
                    herstelWaarde: widget.model.muggengaasBreedteMm,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _nummerRij(
                    label: 'Maat B hoogte',
                    controller: _muggengaasHoogteController,
                    max: 2400,
                    eenheid: 'mm',
                    onWaarde: (waarde) => _stuur(
                      widget.model.copyWith(muggengaasHoogteMm: waarde),
                    ),
                    herstelWaarde: widget.model.muggengaasHoogteMm,
                  ),
                ),
              ],
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Bepaald volgens ${widget.model.maatCode}: '
                '${widget.model.muggengaasBreedteMm} × '
                '${widget.model.muggengaasHoogteMm} mm',
                style: const TextStyle(color: _grijs, fontSize: 11.5),
              ),
            ),
          if (_toonAccessoireAantal) ...<Widget>[
            const SizedBox(height: 7),
            _nummerRij(
              label: 'Aantal muggengazen',
              controller: _muggengaasAantalController,
              max: widget.model.alleenToebehoren
                  ? 99
                  : widget.model.veiligAantal,
              onWaarde: (waarde) =>
                  _stuur(widget.model.copyWith(muggengaasAantal: waarde)),
              herstelWaarde: widget.model.muggengaasAantal,
            ),
          ],
          if (widget.model.muggengaasProductCode.trim().isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'Voor deze afmetingen is geen muggengaas gevonden in de tabel.',
                style: TextStyle(
                  color: Color(0xFFB45309),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _bouwStroomSectie() {
    return _sectie(
      titel: 'Stroomvoorziening',
      children: <Widget>[
        _keuzeRij(
          label: 'Stroomvoorzieningseenheid KUX 110',
          detail: 'Tot maximaal 5 Velux-producten aansluitbaar',
          geselecteerd: widget.model.kux110,
          onTap: () =>
              _stuur(widget.model.copyWith(kux110: !widget.model.kux110)),
        ),
        if (widget.model.kux110) ...<Widget>[
          const SizedBox(height: 7),
          _nummerRij(
            label: 'Aantal KUX 110',
            controller: _kuxAantalController,
            max: 99,
            onWaarde: (waarde) =>
                _stuur(widget.model.copyWith(kuxAantal: waarde)),
            herstelWaarde: widget.model.kuxAantal,
          ),
        ],
      ],
    );
  }

  Widget _bouwAfwerkingSectie() {
    return _sectie(
      titel: 'Afwerken Velux',
      children: <Widget>[
        for (final type in OpmetingVeluxAfwerkingType.values)
          _keuzeRij(
            label: type.label,
            geselecteerd: widget.model.afwerkingType == type,
            onTap: () => _stuur(widget.model.copyWith(afwerkingType: type)),
          ),
      ],
    );
  }

  Widget _sectie({
    required String titel,
    String? subtitel,
    Widget? actie,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFD),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: _rand),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      titel,
                      style: const TextStyle(
                        color: _groen,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (subtitel != null) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        subtitel,
                        style: const TextStyle(color: _grijs, fontSize: 10.5),
                      ),
                    ],
                  ],
                ),
              ),
              if (actie != null) ...<Widget>[const SizedBox(width: 8), actie],
            ],
          ),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }

  Widget _keuzeRij({
    required String label,
    required bool geselecteerd,
    required VoidCallback onTap,
    String? detail,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: _rondje(geselecteerd),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: TextStyle(
                      color: geselecteerd ? _tekst : const Color(0xFF374151),
                      fontSize: 11.5,
                      fontWeight: geselecteerd
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                  if (detail != null)
                    Text(
                      detail,
                      style: const TextStyle(color: _grijs, fontSize: 10),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rondje(bool geselecteerd) {
    return Container(
      width: 17,
      height: 17,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: geselecteerd ? _groen : const Color(0xFF6B7280),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: geselecteerd
          ? Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: _groen,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }

  Widget _nummerRij({
    required String label,
    required TextEditingController controller,
    required int max,
    required ValueChanged<int> onWaarde,
    required int herstelWaarde,
    String eenheid = '',
  }) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: _tekst,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          width: 145,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            textAlign: TextAlign.right,
            selectAllOnFocus: true,
            onChanged: (tekst) {
              final waarde = _leesInt(tekst);
              if (waarde == null) return;
              onWaarde(waarde.clamp(1, max).toInt());
            },
            onEditingComplete: () {
              final waarde = _leesInt(controller.text);
              final definitief = (waarde ?? herstelWaarde)
                  .clamp(1, max)
                  .toInt();
              controller.text = definitief.toString();
              controller.selection = TextSelection.collapsed(
                offset: controller.text.length,
              );
              onWaarde(definitief);
              FocusScope.of(context).unfocus();
            },
            decoration: InputDecoration(
              isDense: true,
              suffixText: eenheid,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 9,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _rand),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _groen, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoratie(String label) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _rand),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _groen, width: 1.5),
      ),
    );
  }
}
