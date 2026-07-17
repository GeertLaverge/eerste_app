import 'package:flutter/material.dart';

import '../overzicht/opmeting_overzicht_model.dart';
import 'opmeting_project_kleur_keuze_dialoog.dart';
import 'opmeting_project_kleur_model.dart';
import 'opmeting_project_titelhoofd_model.dart';

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
    required this.kleurMenus,
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
  late final TextEditingController _kleurAfwijkingController;
  late final TextEditingController _opmerkingController;

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
    _kleurAfwijkingController = TextEditingController();
    _opmerkingController = TextEditingController();

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
    _kleurAfwijkingController.dispose();
    _opmerkingController.dispose();

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
    _zetControllerTekst(_kleurAfwijkingController, titelhoofd.kleurAfwijking);
    _zetControllerTekst(_opmerkingController, titelhoofd.opmerking);
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

  void _meldWijziging() {
    widget.onTitelhoofdGewijzigd(
      OpmetingProjectTitelhoofd(
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
        kleurAfwijking: _kleurAfwijkingController.text,
        opmerking: _opmerkingController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final breed = constraints.maxWidth >= 980;
        const kaartHoogte = 258.0;

        if (breed) {
          return SizedBox(
            height: kaartHoogte,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 11, child: _bouwKlantKaart()),
                const SizedBox(width: 12),
                Expanded(flex: 10, child: _bouwProjectKleurKaart()),
                const SizedBox(width: 12),
                Expanded(flex: 10, child: _bouwInhoudKaart()),
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
          ],
        );
      },
    );
  }

  Widget _bouwKlantKaart() {
    return _basisKaart(
      titel: 'Klantgegevens',
      icoon: Icons.person_outline_rounded,
      kind: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _bouwVeld(
                    controller: _klantNaamController,
                    label: 'Klantnaam',
                    icoon: Icons.badge_outlined,
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: widget.onKlantLaden,
                    icon: const Icon(Icons.event_available_outlined, size: 16),
                    label: const Text('Klant laden'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _groen,
                      side: const BorderSide(color: _groen),
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: _bouwVeld(
                    controller: _adresController,
                    label: 'Straat',
                    icoon: Icons.location_on_outlined,
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _bouwVeld(
                    controller: _huisnummerController,
                    label: 'Huisnr.',
                    keyboardType: TextInputType.streetAddress,
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _bouwVeld(
                    controller: _busNummerController,
                    label: 'Bus',
                    keyboardType: TextInputType.streetAddress,
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _bouwVeld(
                    controller: _postcodeController,
                    label: 'Postcode',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: _bouwVeld(
                    controller: _gemeenteController,
                    label: 'Gemeente',
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child: _bouwVeld(
                    controller: _contactpersoonController,
                    label: 'Contactpersoon',
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _bouwVeld(
                    controller: _gsmController,
                    label: 'Gsm',
                    icoon: Icons.phone_iphone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _bouwVeld(
                    controller: _telefoonController,
                    label: 'Telefoon',
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _bouwVeld(
              controller: _emailController,
              label: 'E-mail',
              icoon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
            ),
          ],
        ),
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
            Row(
              children: [
                Expanded(
                  child: _bouwKleurVeld(
                    controller: _kleurBinnenController,
                    label: 'Binnenkleur',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _bouwKleurVeld(
                    controller: _kleurBuitenController,
                    label: 'Buitenkleur',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _bouwVeld(
              controller: _kleurAfwijkingController,
              label: 'Afwijkende posities',
              icoon: Icons.warning_amber_rounded,
              maxLines: 3,
              hint: 'bv. Pos 4 voordeur eik motief',
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
            const SizedBox(height: 8),
            _bouwVeld(
              controller: _opmerkingController,
              label: 'Opmerking',
              icoon: Icons.notes_outlined,
              maxLines: 2,
            ),
          ],
        ),
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
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
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
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _lichtGroen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icoon, color: _groen, size: 18),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  titel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _tekstDonker,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(child: kind),
        ],
      ),
    );
  }

  Widget _bouwVeld({
    required TextEditingController controller,
    required String label,
    IconData? icoon,
    int maxLines = 1,
    String? hint,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    Color? achtergrondKleur,
    Color? randKleur,
    Color? icoonKleur,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      minLines: maxLines,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: const TextStyle(
        color: _tekstDonker,
        fontSize: 12.5,
        fontWeight: FontWeight.w800,
        height: 1.2,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: achtergrondKleur ?? const Color(0xFFF9FAFB),
        prefixIcon: icoon == null
            ? null
            : Icon(icoon, color: icoonKleur ?? _tekstGrijs, size: 17),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 34,
          minHeight: 34,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide(color: randKleur ?? _rand),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide(color: randKleur ?? _rand),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: _groen, width: 1.4),
        ),
        floatingLabelStyle: const TextStyle(
          color: _groen,
          fontWeight: FontWeight.w900,
        ),
      ),
      onChanged: (_) {
        setState(() {});
        _meldWijziging();
      },
    );
  }

  Widget _bouwKleurVeld({
    required TextEditingController controller,
    required String label,
  }) {
    final tekst = controller.text.trim();

    return TextField(
      controller: controller,
      style: const TextStyle(
        color: _tekstDonker,
        fontSize: 12.5,
        fontWeight: FontWeight.w900,
      ),
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: _kleurSwatchVoorTekst(tekst),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: const Color(0xFF9CA3AF)),
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 34,
          minHeight: 34,
        ),
        suffixIcon: IconButton(
          tooltip: 'Kleur kiezen',
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
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
            _meldWijziging();
          },
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: _rand),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: _rand),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: _groen, width: 1.4),
        ),
        floatingLabelStyle: const TextStyle(
          color: _groen,
          fontWeight: FontWeight.w900,
        ),
      ),
      onChanged: (_) {
        setState(() {});
        _meldWijziging();
      },
    );
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
