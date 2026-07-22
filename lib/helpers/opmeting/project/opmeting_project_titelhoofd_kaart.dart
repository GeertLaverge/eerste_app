// THIMACO-CONTROLE: KLANTVELDEN-VISUEEL-ALLEMAAL-27PX-20260720
// THIMACO-CONTROLE: COMPACTE-KLANTGEGEVENS-PROJECTKLEUR-ZONDER-ZWEVENDE-LABELS-20260720
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// THIMACO-CONTROLE: KLANTVELDEN-ZELFDE-HOOGTE-EN-KAART-VOLLEDIG-BENUT-20260720

import '../overzicht/opmeting_overzicht_model.dart';
import 'opmeting_project_kleur_keuze_dialoog.dart';
import 'opmeting_project_kleur_model.dart';
import 'opmeting_project_titelhoofd_model.dart';
import 'ral_classic_kleuren.dart';

class OpmetingProjectTypeSamenvatting {
  const OpmetingProjectTypeSamenvatting({
    required this.typeKey,
    required this.label,
    required this.aantal,
    required this.zichtbaar,
  });

  final String typeKey;
  final String label;
  final int aantal;
  final bool zichtbaar;
}

class OpmetingProjectTitelhoofdKaart extends StatefulWidget {
  const OpmetingProjectTitelhoofdKaart({
    super.key,
    required this.titelhoofd,
    required this.opmetingen,
    required this.verborgenFormulierTypes,
    this.kleurMenus = const <OpmetingProjectKleurSubmenu>[],
    required this.onTitelhoofdGewijzigd,
    required this.onKlantLaden,
    required this.onToggleFormulierType,
  });

  final OpmetingProjectTitelhoofd titelhoofd;
  final List<OpmetingOverzichtRaamItem> opmetingen;
  final Set<String> verborgenFormulierTypes;
  final List<OpmetingProjectKleurSubmenu> kleurMenus;
  final ValueChanged<OpmetingProjectTitelhoofd> onTitelhoofdGewijzigd;
  final VoidCallback onKlantLaden;
  final ValueChanged<String> onToggleFormulierType;

  @override
  State<OpmetingProjectTitelhoofdKaart> createState() {
    return _OpmetingProjectTitelhoofdKaartState();
  }
}

class _OpmetingProjectTitelhoofdKaartState
    extends State<OpmetingProjectTitelhoofdKaart> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _achtergrondKaart = Colors.white;
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);
  static const Color _oranjeLicht = Color(0xFFFFF7ED);
  static const Color _oranje = Color(0xFFEA580C);

  late final TextEditingController _klantNaamController;
  late final TextEditingController _contactpersoonController;
  late final TextEditingController _adresController;
  late final TextEditingController _huisnummerController;
  late final TextEditingController _busNummerController;
  late final TextEditingController _postcodeController;
  late final TextEditingController _gemeenteController;
  late final TextEditingController _gsmController;
  late final TextEditingController _telefoonController;
  late final TextEditingController _emailController;
  late final TextEditingController _kleurBinnenController;
  late final TextEditingController _kleurBuitenController;
  late final TextEditingController _ralKleurToebehorenController;
  late final FocusNode _ralKleurToebehorenFocusNode;
  late final TextEditingController _kleurAfwijkingController;
  late final TextEditingController _kortingOmschrijvingController;
  late final List<TextEditingController> _offerteJaarControllers;
  late final List<TextEditingController> _klantnummerControllers;
  late final List<TextEditingController> _offerteVolgnummerControllers;
  late String _btwTarief;

  @override
  void initState() {
    super.initState();

    _klantNaamController = TextEditingController();
    _contactpersoonController = TextEditingController();
    _adresController = TextEditingController();
    _huisnummerController = TextEditingController();
    _busNummerController = TextEditingController();
    _postcodeController = TextEditingController();
    _gemeenteController = TextEditingController();
    _gsmController = TextEditingController();
    _telefoonController = TextEditingController();
    _emailController = TextEditingController();
    _kleurBinnenController = TextEditingController();
    _kleurBuitenController = TextEditingController();
    _ralKleurToebehorenController = TextEditingController();
    _ralKleurToebehorenFocusNode = FocusNode();
    _kleurAfwijkingController = TextEditingController();
    _kortingOmschrijvingController = TextEditingController();
    _offerteJaarControllers = List<TextEditingController>.generate(
      2,
      (_) => TextEditingController(),
    );
    _klantnummerControllers = List<TextEditingController>.generate(
      4,
      (_) => TextEditingController(),
    );
    _offerteVolgnummerControllers = List<TextEditingController>.generate(
      2,
      (_) => TextEditingController(),
    );
    _btwTarief = OpmetingProjectTitelhoofd.standaardBtwTarief;

    _zetControllers(widget.titelhoofd);
  }

  @override
  void didUpdateWidget(covariant OpmetingProjectTitelhoofdKaart oldWidget) {
    super.didUpdateWidget(oldWidget);

    _zetControllers(widget.titelhoofd);
  }

  @override
  void dispose() {
    _klantNaamController.dispose();
    _contactpersoonController.dispose();
    _adresController.dispose();
    _huisnummerController.dispose();
    _busNummerController.dispose();
    _postcodeController.dispose();
    _gemeenteController.dispose();
    _gsmController.dispose();
    _telefoonController.dispose();
    _emailController.dispose();
    _kleurBinnenController.dispose();
    _kleurBuitenController.dispose();
    _ralKleurToebehorenController.dispose();
    _ralKleurToebehorenFocusNode.dispose();
    _kleurAfwijkingController.dispose();
    _kortingOmschrijvingController.dispose();

    for (final controller in <TextEditingController>[
      ..._offerteJaarControllers,
      ..._klantnummerControllers,
      ..._offerteVolgnummerControllers,
    ]) {
      controller.dispose();
    }

    super.dispose();
  }

  void _zetControllers(OpmetingProjectTitelhoofd titelhoofd) {
    _zetControllerTekst(_klantNaamController, titelhoofd.klantNaam);
    _zetControllerTekst(_contactpersoonController, titelhoofd.contactpersoon);
    _zetControllerTekst(_adresController, titelhoofd.adres);
    _zetControllerTekst(_huisnummerController, titelhoofd.huisnummer);
    _zetControllerTekst(_busNummerController, titelhoofd.busNummer);
    _zetControllerTekst(_postcodeController, titelhoofd.postcode);
    _zetControllerTekst(_gemeenteController, titelhoofd.gemeente);
    _zetControllerTekst(_gsmController, titelhoofd.gsm);
    _zetControllerTekst(_telefoonController, titelhoofd.telefoon);
    _zetControllerTekst(_emailController, titelhoofd.email);
    _zetControllerTekst(_kleurBinnenController, titelhoofd.projectKleurBinnen);
    _zetControllerTekst(_kleurBuitenController, titelhoofd.projectKleurBuiten);
    _zetControllerTekst(
      _ralKleurToebehorenController,
      titelhoofd.ralKleurToebehoren,
    );
    _zetControllerTekst(_kleurAfwijkingController, titelhoofd.kleurAfwijking);
    _zetControllerTekst(
      _kortingOmschrijvingController,
      titelhoofd.kortingOmschrijving,
    );

    _btwTarief =
        OpmetingProjectTitelhoofd.btwTarieven.contains(titelhoofd.btwTarief)
        ? titelhoofd.btwTarief
        : OpmetingProjectTitelhoofd.standaardBtwTarief;

    _zetCijferControllers(
      _offerteJaarControllers,
      titelhoofd.offerteJaar,
      standaardWaarde: OpmetingProjectTitelhoofd.standaardOfferteJaar,
    );
    _zetCijferControllers(_klantnummerControllers, titelhoofd.klantnummer);
    _zetCijferControllers(
      _offerteVolgnummerControllers,
      titelhoofd.offerteVolgnummer,
      standaardWaarde: OpmetingProjectTitelhoofd.standaardOfferteVolgnummer,
    );
  }

  void _zetCijferControllers(
    List<TextEditingController> controllers,
    String waarde, {
    String standaardWaarde = '',
  }) {
    final cijfers = waarde.replaceAll(RegExp(r'\D'), '');
    final bron = cijfers.isEmpty ? standaardWaarde : cijfers;

    for (var index = 0; index < controllers.length; index++) {
      final cijfer = index < bron.length ? bron[index] : '';
      _zetControllerTekst(controllers[index], cijfer);
    }
  }

  String _combineerCijfers(List<TextEditingController> controllers) {
    return controllers.map((controller) => controller.text).join();
  }

  void _zetControllerTekst(TextEditingController controller, String tekst) {
    if (controller.text == tekst) {
      return;
    }

    controller.value = TextEditingValue(
      text: tekst,
      selection: TextSelection.collapsed(offset: tekst.length),
    );
  }

  void _meldWijziging({
    bool? berekenPrijzen,
    bool? buitenkleurGelijkAanToebehoren,
  }) {
    widget.onTitelhoofdGewijzigd(
      widget.titelhoofd.copyWith(
        klantNaam: _klantNaamController.text,
        contactpersoon: _contactpersoonController.text,
        adres: _adresController.text,
        huisnummer: _huisnummerController.text,
        busNummer: _busNummerController.text,
        postcode: _postcodeController.text,
        gemeente: _gemeenteController.text,
        gsm: _gsmController.text,
        telefoon: _telefoonController.text,
        email: _emailController.text,
        projectKleurBinnen: _kleurBinnenController.text,
        projectKleurBuiten: _kleurBuitenController.text,
        ralKleurToebehoren: _ralKleurToebehorenController.text,
        buitenkleurGelijkAanToebehoren:
            buitenkleurGelijkAanToebehoren ??
            widget.titelhoofd.buitenkleurGelijkAanToebehoren,
        kleurAfwijking: _kleurAfwijkingController.text,
        btwTarief: _btwTarief,
        offerteJaar: _combineerCijfers(_offerteJaarControllers),
        klantnummer: _combineerCijfers(_klantnummerControllers),
        offerteVolgnummer: _combineerCijfers(_offerteVolgnummerControllers),
        kortingOmschrijving: _kortingOmschrijvingController.text.trim().isEmpty
            ? OpmetingProjectTitelhoofd.standaardKortingOmschrijving
            : _kortingOmschrijvingController.text.trim(),
        berekenPrijzen: berekenPrijzen ?? widget.titelhoofd.berekenPrijzen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final breed = constraints.maxWidth >= 1050;
        const kaartHoogte = 276.0;

        if (breed) {
          return SizedBox(
            height: kaartHoogte,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 10, child: _bouwKlantKaart()),
                const SizedBox(width: 10),
                Expanded(flex: 8, child: _bouwProjectKleurKaart()),
                const SizedBox(width: 10),
                Expanded(flex: 8, child: _bouwInhoudKaart()),
                const SizedBox(width: 10),
                Expanded(flex: 7, child: _bouwOfferteInstellingenKaart()),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: kaartHoogte, child: _bouwKlantKaart()),
            const SizedBox(height: 10),
            SizedBox(height: kaartHoogte, child: _bouwProjectKleurKaart()),
            const SizedBox(height: 10),
            SizedBox(height: kaartHoogte, child: _bouwInhoudKaart()),
            const SizedBox(height: 10),
            SizedBox(
              height: kaartHoogte,
              child: _bouwOfferteInstellingenKaart(),
            ),
          ],
        );
      },
    );
  }

  Widget _bouwKlantKaart() {
    const klantVeldHoogte = 27.0;

    return _basisKaart(
      titel: 'Klantgegevens',
      icoon: Icons.person_outline_rounded,
      actie: SizedBox(
        height: 28,
        child: OutlinedButton.icon(
          onPressed: widget.onKlantLaden,
          icon: const Icon(Icons.event_available_outlined, size: 13),
          label: const Text('Klant laden'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _groen,
            side: const BorderSide(color: _groen),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: const VisualDensity(horizontal: -3, vertical: -4),
            padding: const EdgeInsets.symmetric(horizontal: 7),
            textStyle: const TextStyle(
              fontSize: 10.25,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
      kind: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _bouwVeld(
            controller: _klantNaamController,
            label: 'Klantnaam',
            icoon: Icons.badge_outlined,
            textCapitalization: TextCapitalization.words,
            extraCompact: true,
            vasteHoogte: klantVeldHoogte,
          ),
          _bouwVeld(
            controller: _contactpersoonController,
            label: 'Contactpersoon',
            textCapitalization: TextCapitalization.words,
            extraCompact: true,
            vasteHoogte: klantVeldHoogte,
          ),
          _bouwVeld(
            controller: _adresController,
            label: 'Straat',
            icoon: Icons.location_on_outlined,
            textCapitalization: TextCapitalization.words,
            extraCompact: true,
            vasteHoogte: klantVeldHoogte,
          ),
          Row(
            children: [
              Expanded(
                child: _bouwVeld(
                  controller: _huisnummerController,
                  label: 'Huisnr.',
                  keyboardType: TextInputType.streetAddress,
                  textCapitalization: TextCapitalization.characters,
                  extraCompact: true,
                  vasteHoogte: klantVeldHoogte,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _bouwVeld(
                  controller: _busNummerController,
                  label: 'Bus',
                  keyboardType: TextInputType.streetAddress,
                  textCapitalization: TextCapitalization.characters,
                  extraCompact: true,
                  vasteHoogte: klantVeldHoogte,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _bouwVeld(
                  controller: _postcodeController,
                  label: 'Postcode',
                  keyboardType: TextInputType.number,
                  extraCompact: true,
                  vasteHoogte: klantVeldHoogte,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                flex: 3,
                child: _bouwVeld(
                  controller: _gemeenteController,
                  label: 'Gemeente',
                  textCapitalization: TextCapitalization.words,
                  extraCompact: true,
                  vasteHoogte: klantVeldHoogte,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _bouwVeld(
                  controller: _gsmController,
                  label: 'Gsm',
                  icoon: Icons.phone_iphone_outlined,
                  keyboardType: TextInputType.phone,
                  extraCompact: true,
                  vasteHoogte: klantVeldHoogte,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _bouwVeld(
                  controller: _telefoonController,
                  label: 'Telefoon',
                  keyboardType: TextInputType.phone,
                  extraCompact: true,
                  vasteHoogte: klantVeldHoogte,
                ),
              ),
            ],
          ),
          _bouwVeld(
            controller: _emailController,
            label: 'E-mail',
            icoon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textCapitalization: TextCapitalization.none,
            extraCompact: true,
            vasteHoogte: klantVeldHoogte,
          ),
        ],
      ),
    );
  }

  Widget _bouwProjectKleurKaart() {
    return _basisKaart(
      titel: 'Projectkleur',
      icoon: Icons.palette_outlined,
      kind: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _bouwKleurVeld(
              controller: _kleurBinnenController,
              label: 'Binnenkleur',
            ),
            const SizedBox(height: 5),
            _bouwKleurVeld(
              controller: _kleurBuitenController,
              label: 'Buitenkleur',
              onChanged: _verwerkBuitenkleurGewijzigd,
            ),
            const SizedBox(height: 5),
            _bouwRalKleurToebehorenVeld(),
            CheckboxListTile(
              value: widget.titelhoofd.buitenkleurGelijkAanToebehoren,
              contentPadding: EdgeInsets.zero,
              dense: true,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: _groen,
              title: const Text(
                'Buitenkleur gelijk aan toebehoren',
                style: TextStyle(
                  color: _tekstDonker,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              onChanged: (waarde) {
                final gekoppeld = waarde ?? false;
                if (gekoppeld) {
                  final kleur = _kleurBuitenController.text.trim().isNotEmpty
                      ? _kleurBuitenController.text
                      : _ralKleurToebehorenController.text;
                  _zetControllerTekst(_kleurBuitenController, kleur);
                  _zetControllerTekst(_ralKleurToebehorenController, kleur);
                }
                setState(() {});
                _meldWijziging(buitenkleurGelijkAanToebehoren: gekoppeld);
              },
            ),
            const SizedBox(height: 1),
            _bouwVeld(
              controller: _kleurAfwijkingController,
              label: 'Afwijkende posities',
              icoon: Icons.warning_amber_rounded,
              minLines: 1,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              hint: 'bv. Pos 4: voordeur eik motief',
              achtergrondKleur: _kleurAfwijkingController.text.trim().isEmpty
                  ? const Color(0xFFF9FAFB)
                  : _oranjeLicht,
              randKleur: _kleurAfwijkingController.text.trim().isEmpty
                  ? _rand
                  : const Color(0xFFFED7AA),
              icoonKleur: _kleurAfwijkingController.text.trim().isEmpty
                  ? _tekstGrijs
                  : _oranje,
            ),
          ],
        ),
      ),
    );
  }

  Widget _bouwOfferteInstellingenKaart() {
    return _basisKaart(
      titel: 'Offerte-instellingen',
      icoon: Icons.receipt_long_outlined,
      titelFontSize: 12.5,
      kind: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: _bouwBtwEnOffertenummer(),
      ),
    );
  }

  Widget _bouwBtwEnOffertenummer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          value: widget.titelhoofd.berekenPrijzen,
          contentPadding: EdgeInsets.zero,
          dense: true,
          visualDensity: VisualDensity.compact,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: _groen,
          title: const Text(
            'Berekenen',
            style: TextStyle(
              color: _tekstDonker,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          subtitle: const Text(
            'Offerteprijzen en totalen berekenen',
            style: TextStyle(
              color: _tekstGrijs,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          onChanged: (waarde) {
            _meldWijziging(berekenPrijzen: waarde ?? false);
          },
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 122,
          child: DropdownButtonFormField<String>(
            value: _btwTarief,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 17),
            style: const TextStyle(
              color: _tekstDonker,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
            decoration: InputDecoration(
              labelText: 'BTW tarief',
              isDense: true,
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: const EdgeInsets.fromLTRB(9, 7, 5, 7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: _rand),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: _rand),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: _groen, width: 1.4),
              ),
              floatingLabelStyle: const TextStyle(
                color: _groen,
                fontWeight: FontWeight.w900,
              ),
            ),
            items: OpmetingProjectTitelhoofd.btwTarieven
                .map((tarief) {
                  return DropdownMenuItem<String>(
                    value: tarief,
                    child: Text(
                      tarief,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                })
                .toList(growable: false),
            onChanged: (waarde) {
              if (waarde == null) {
                return;
              }

              setState(() {
                _btwTarief = waarde;
              });
              _meldWijziging();
            },
          ),
        ),
        const SizedBox(height: 10),
        _bouwOffertenummerInvoer(),
        const SizedBox(height: 10),
        TextField(
          controller: _kortingOmschrijvingController,
          maxLines: 2,
          minLines: 1,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(
            color: _tekstDonker,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            labelText: 'Tekst korting op offerte',
            hintText: 'Korting',
            helperText: 'bv. Korting geldig tot 20/07/2026',
            helperMaxLines: 2,
            isDense: true,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.fromLTRB(9, 9, 9, 9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: _rand),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: _rand),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: _groen, width: 1.4),
            ),
            floatingLabelStyle: const TextStyle(
              color: _groen,
              fontWeight: FontWeight.w900,
            ),
          ),
          onChanged: (_) => _meldWijziging(),
        ),
      ],
    );
  }

  Widget _bouwOffertenummerInvoer() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Offertenummer',
          style: TextStyle(
            color: _tekstGrijs,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _bouwCijferGroep(
              label: 'jaar',
              controllers: _offerteJaarControllers,
            ),
            const SizedBox(width: 4),
            _bouwCijferGroep(
              label: 'klantnr.',
              controllers: _klantnummerControllers,
            ),
            const SizedBox(width: 4),
            _bouwCijferGroep(
              label: 'volgnr.',
              controllers: _offerteVolgnummerControllers,
            ),
          ],
        ),
      ],
    );
  }

  Widget _bouwCijferGroep({
    required String label,
    required List<TextEditingController> controllers,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _tekstGrijs,
            fontSize: 8,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 1),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(controllers.length, (index) {
            return Padding(
              padding: EdgeInsets.only(
                right: index == controllers.length - 1 ? 0 : 2,
              ),
              child: _bouwCijferVak(controllers[index]),
            );
          }),
        ),
      ],
    );
  }

  Widget _bouwCijferVak(TextEditingController controller) {
    return SizedBox(
      width: 20,
      height: 29,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLines: 1,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        style: const TextStyle(
          color: _tekstDonker,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          counterText: '',
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: _rand),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: _rand),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: _groen, width: 1.4),
          ),
        ),
        onChanged: (_) {
          _meldWijziging();
        },
      ),
    );
  }

  Widget _bouwInhoudKaart() {
    final samenvattingen = _samenvattingen();

    return _basisKaart(
      titel: 'Inhoud fiche',
      icoon: Icons.format_list_bulleted_rounded,
      kind: samenvattingen.isEmpty
          ? const Center(
              child: Text(
                'Nog geen posities in deze fiche.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _tekstGrijs,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          : Scrollbar(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: samenvattingen.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 12, color: _rand),
                itemBuilder: (context, index) {
                  return _inhoudRegel(samenvattingen[index]);
                },
              ),
            ),
    );
  }

  Widget _basisKaart({
    required String titel,
    required IconData icoon,
    required Widget kind,
    Widget? actie,
    double titelFontSize = 14,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(11, 10, 11, 10),
      decoration: BoxDecoration(
        color: _achtergrondKaart,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _rand),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _lichtGroen,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icoon, color: _groen, size: 17),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _tekstDonker,
                    fontSize: titelFontSize,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (actie != null) ...[const SizedBox(width: 6), actie],
            ],
          ),
          const SizedBox(height: 8),
          Expanded(child: kind),
        ],
      ),
    );
  }

  Widget _bouwVeld({
    required TextEditingController controller,
    required String label,
    IconData? icoon,
    int? maxLines = 1,
    int? minLines,
    String? hint,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    Color? achtergrondKleur,
    Color? randKleur,
    Color? icoonKleur,
    bool extraCompact = false,
    double? vasteHoogte,
  }) {
    final heeftVasteHoogte = vasteHoogte != null;

    final veld = TextField(
      controller: controller,
      maxLines: heeftVasteHoogte ? null : maxLines,
      minLines: heeftVasteHoogte
          ? null
          : minLines ?? (maxLines == null ? 1 : maxLines),
      expands: heeftVasteHoogte,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      textAlignVertical: heeftVasteHoogte ? TextAlignVertical.center : null,
      strutStyle: heeftVasteHoogte
          ? const StrutStyle(
              fontSize: 10.5,
              height: 1.0,
              forceStrutHeight: true,
            )
          : null,
      style: TextStyle(
        color: _tekstDonker,
        fontSize: extraCompact ? 10.5 : 11.25,
        fontWeight: FontWeight.w700,
        height: extraCompact ? 1.0 : 1.1,
      ),
      decoration: InputDecoration(
        hintText: hint == null ? label : '$label · $hint',
        hintStyle: const TextStyle(
          color: _tekstGrijs,
          fontSize: 10.75,
          fontWeight: FontWeight.w600,
          height: 1.0,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        constraints: heeftVasteHoogte
            ? BoxConstraints.tightFor(height: vasteHoogte)
            : null,
        isDense: true,
        filled: true,
        fillColor: achtergrondKleur ?? const Color(0xFFF9FAFB),
        prefixIcon: icoon == null
            ? null
            : Icon(
                icoon,
                color: icoonKleur ?? _tekstGrijs,
                size: extraCompact ? 14 : 15,
              ),
        prefixIconConstraints: BoxConstraints.tightFor(
          width: icoon == null ? 0 : (extraCompact ? 27 : 30),
          height: heeftVasteHoogte ? vasteHoogte : (extraCompact ? 27 : 30),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: extraCompact ? 7 : 8,
          vertical: heeftVasteHoogte ? 0 : (extraCompact ? 3 : 5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(extraCompact ? 8 : 9),
          borderSide: BorderSide(color: randKleur ?? _rand),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(extraCompact ? 8 : 9),
          borderSide: BorderSide(color: randKleur ?? _rand),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(extraCompact ? 8 : 9),
          borderSide: const BorderSide(color: _groen, width: 1.4),
        ),
      ),
      onChanged: (_) {
        setState(() {});
        _meldWijziging();
      },
    );

    if (!heeftVasteHoogte) {
      return veld;
    }

    return SizedBox(
      height: vasteHoogte,
      child: SizedBox.expand(child: veld),
    );
  }

  Widget _bouwRalKleurToebehorenVeld() {
    return RawAutocomplete<String>(
      textEditingController: _ralKleurToebehorenController,
      focusNode: _ralKleurToebehorenFocusNode,
      displayStringForOption: (optie) => optie,
      optionsBuilder: (waarde) {
        return RalClassicKleuren.zoek(waarde.text);
      },
      onSelected: (waarde) {
        _ralKleurToebehorenController.value = TextEditingValue(
          text: waarde,
          selection: TextSelection.collapsed(offset: waarde.length),
        );
        setState(() {});
        _verwerkToebehorenKleurGewijzigd(waarde);
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        final tekst = controller.text.trim();
        return TextField(
          controller: controller,
          focusNode: focusNode,
          style: const TextStyle(
            color: _tekstDonker,
            fontSize: 10.75,
            fontWeight: FontWeight.w900,
          ),
          decoration: InputDecoration(
            hintText: 'RAL-kleur toebehoren',
            hintStyle: const TextStyle(
              color: _tekstGrijs,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            isDense: true,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(7),
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _kleurSwatchVoorTekst(tekst),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: const Color(0xFF9CA3AF)),
                ),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 30,
              minHeight: 30,
            ),
            suffixIcon: IconButton(
              tooltip: 'RAL-kleuren tonen',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 30, height: 30),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
              onPressed: () {
                focusNode.requestFocus();
                controller.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: controller.text.length,
                );
              },
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 30,
              minHeight: 30,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 5,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: _rand),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: _rand),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: _groen, width: 1.4),
            ),
          ),
          onChanged: (waarde) {
            setState(() {});
            _verwerkToebehorenKleurGewijzigd(waarde);
          },
          onSubmitted: (_) => onFieldSubmitted(),
        );
      },
      optionsViewBuilder: (context, onSelected, opties) {
        final lijst = opties.toList(growable: false);
        if (lijst.isEmpty) {
          return const SizedBox.shrink();
        }

        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360, maxHeight: 280),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 6),
                shrinkWrap: true,
                itemCount: lijst.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final optie = lijst[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      optie,
                      style: const TextStyle(
                        color: _tekstDonker,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onTap: () => onSelected(optie),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _bouwKleurVeld({
    required TextEditingController controller,
    required String label,
    ValueChanged<String>? onChanged,
  }) {
    final tekst = controller.text.trim();

    return TextField(
      controller: controller,
      style: const TextStyle(
        color: _tekstDonker,
        fontSize: 10.75,
        fontWeight: FontWeight.w900,
      ),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(
          color: _tekstGrijs,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        isDense: true,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(7),
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _kleurSwatchVoorTekst(tekst),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: const Color(0xFF9CA3AF)),
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 30,
          minHeight: 30,
        ),
        suffixIcon: IconButton(
          tooltip: 'Kleur kiezen',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 30, height: 30),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
          onPressed: () async {
            final waarde = await toonOpmetingProjectKleurKeuzeDialoog(
              context: context,
              kleurMenus: widget.kleurMenus,
              huidigeWaarde: controller.text,
            );

            if (!mounted || waarde == null) {
              return;
            }

            setState(() {
              controller.text = waarde;
              controller.selection = TextSelection.collapsed(
                offset: controller.text.length,
              );
            });
            if (onChanged != null) {
              onChanged(waarde);
            } else {
              _meldWijziging();
            }
          },
        ),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 30,
          minHeight: 30,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: _rand),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: _rand),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: _groen, width: 1.4),
        ),
      ),
      onChanged: (waarde) {
        setState(() {});
        if (onChanged != null) {
          onChanged(waarde);
        } else {
          _meldWijziging();
        }
      },
    );
  }

  void _verwerkBuitenkleurGewijzigd(String waarde) {
    if (widget.titelhoofd.buitenkleurGelijkAanToebehoren) {
      _zetControllerTekst(_ralKleurToebehorenController, waarde);
    }
    _meldWijziging();
  }

  void _verwerkToebehorenKleurGewijzigd(String waarde) {
    if (widget.titelhoofd.buitenkleurGelijkAanToebehoren) {
      _zetControllerTekst(_kleurBuitenController, waarde);
    }
    _meldWijziging();
  }

  Widget _inhoudRegel(OpmetingProjectTypeSamenvatting item) {
    final kleur = item.zichtbaar ? _groen : _tekstGrijs;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        widget.onToggleFormulierType(item.typeKey);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: item.zichtbaar ? _tekstDonker : _tekstGrijs,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  decoration: item.zichtbaar
                      ? null
                      : TextDecoration.lineThrough,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${item.aantal} ${item.aantal == 1 ? 'stuk' : 'stuks'}',
              style: TextStyle(
                color: item.zichtbaar ? _tekstDonker : _tekstGrijs,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              item.zichtbaar
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: kleur,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Color _kleurSwatchVoorTekst(String tekst) {
    final lower = tekst.toLowerCase();

    if (lower.contains('wit')) {
      return Colors.white;
    }

    if (lower.contains('zwart') || lower.contains('9005')) {
      return const Color(0xFF111827);
    }

    if (lower.contains('7016') ||
        lower.contains('antraciet') ||
        lower.contains('grijs')) {
      return const Color(0xFF374151);
    }

    if (lower.contains('eik') || lower.contains('hout')) {
      return const Color(0xFFB45309);
    }

    return const Color(0xFFE5E7EB);
  }

  List<OpmetingProjectTypeSamenvatting> _samenvattingen() {
    final aantallen = <String, int>{};
    final labels = <String, String>{};

    for (final item in widget.opmetingen) {
      final typeKey = item.formulierTypeGenormaliseerd;
      aantallen[typeKey] = (aantallen[typeKey] ?? 0) + 1;
      labels[typeKey] = item.formulierTypeLabel;
    }

    final keys = aantallen.keys.toList()
      ..sort((eerste, tweede) {
        return (labels[eerste] ?? eerste).toLowerCase().compareTo(
          (labels[tweede] ?? tweede).toLowerCase(),
        );
      });

    return keys.map((key) {
      return OpmetingProjectTypeSamenvatting(
        typeKey: key,
        label: labels[key] ?? key,
        aantal: aantallen[key] ?? 0,
        zichtbaar: !widget.verborgenFormulierTypes.contains(key),
      );
    }).toList();
  }
}

Future<OpmetingAgendaKlantInfo?> toonOpmetingAgendaKlantKeuzeDialog({
  required BuildContext context,
  required List<OpmetingAgendaKlantInfo> klanten,
}) async {
  return showDialog<OpmetingAgendaKlantInfo>(
    context: context,
    builder: (dialogContext) {
      return _AgendaKlantKeuzeDialog(klanten: klanten);
    },
  );
}

class _AgendaKlantKeuzeDialog extends StatefulWidget {
  const _AgendaKlantKeuzeDialog({required this.klanten});

  final List<OpmetingAgendaKlantInfo> klanten;

  @override
  State<_AgendaKlantKeuzeDialog> createState() {
    return _AgendaKlantKeuzeDialogState();
  }
}

class _AgendaKlantKeuzeDialogState extends State<_AgendaKlantKeuzeDialog> {
  static const Color _groen = Color(0xFF0B7A3B);

  final TextEditingController _zoekController = TextEditingController();

  @override
  void dispose() {
    _zoekController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final zoek = _zoekController.text.trim().toLowerCase();
    final klanten = widget.klanten.where((klant) {
      if (zoek.isEmpty) {
        return true;
      }

      return klant.zoekTekst.contains(zoek);
    }).toList();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Klant laden uit blauwe agenda',
        style: TextStyle(color: _groen, fontWeight: FontWeight.w900),
      ),
      content: SizedBox(
        width: 560,
        height: 480,
        child: Column(
          children: [
            TextField(
              controller: _zoekController,
              autofocus: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Zoeken',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: klanten.isEmpty
                  ? const Center(
                      child: Text('Geen klanten gevonden in de blauwe agenda.'),
                    )
                  : ListView.separated(
                      itemCount: klanten.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final klant = klanten[index];
                        final adres = <String>[
                          klant.adres.trim(),
                          klant.plaats.trim(),
                        ].where((deel) => deel.isNotEmpty).join(' · ');

                        return ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.event_available_outlined,
                            color: _groen,
                          ),
                          title: Text(
                            klant.klantNaam,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          subtitle: Text(
                            <String>[
                              if (adres.isNotEmpty) adres,
                              if (klant.gsm.trim().isNotEmpty) klant.gsm.trim(),
                              if (klant.email.trim().isNotEmpty)
                                klant.email.trim(),
                              if (klant.datumKey.trim().isNotEmpty)
                                klant.datumKey.trim(),
                            ].join('\n'),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            Navigator.pop(context, klant);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Annuleren'),
        ),
      ],
    );
  }
}
