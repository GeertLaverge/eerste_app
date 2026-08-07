// THIMACO-CONTROLE: FINANCIELE-INVOER-DIALOGEN-FASE2A-20260807
import 'package:flutter/material.dart';

import '../model/financiele_cockpit_model.dart';

class FinancieleInvoerDialogen {
  const FinancieleInvoerDialogen._();

  static Future<FinancieleRekening?> rekening(
    BuildContext context, {
    FinancieleRekening? bestaand,
  }) {
    return showDialog<FinancieleRekening>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _RekeningDialog(bestaand: bestaand),
    );
  }

  static Future<FinancieleTeBetalen?> teBetalen(
    BuildContext context, {
    FinancieleTeBetalen? bestaand,
  }) {
    return showDialog<FinancieleTeBetalen>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _TeBetalenDialog(bestaand: bestaand),
    );
  }

  static Future<FinancieleTeOntvangen?> teOntvangen(
    BuildContext context, {
    FinancieleTeOntvangen? bestaand,
  }) {
    return showDialog<FinancieleTeOntvangen>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _TeOntvangenDialog(bestaand: bestaand),
    );
  }

  static Future<FinancieleAndereOntvangst?> andereOntvangst(
    BuildContext context, {
    FinancieleAndereOntvangst? bestaand,
  }) {
    return showDialog<FinancieleAndereOntvangst>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AndereOntvangstDialog(bestaand: bestaand),
    );
  }

  static Future<FinancieleVasteKost?> vasteKost(
    BuildContext context, {
    FinancieleVasteKost? bestaand,
  }) {
    return showDialog<FinancieleVasteKost>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _VasteKostDialog(bestaand: bestaand),
    );
  }
}

const Color _groen = Color(0xFF0B7A3B);
const Color _lichtGroen = Color(0xFFE7F6EC);
const Color _rand = Color(0xFFE5E7EB);
const Color _tekstDonker = Color(0xFF111827);
const Color _tekstGrijs = Color(0xFF6B7280);

class _RekeningDialog extends StatefulWidget {
  const _RekeningDialog({this.bestaand});

  final FinancieleRekening? bestaand;

  @override
  State<_RekeningDialog> createState() => _RekeningDialogState();
}

class _RekeningDialogState extends State<_RekeningDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _naam;
  late final TextEditingController _rekeningNummer;
  late final TextEditingController _saldo;
  late final TextEditingController _krediet;
  late final TextEditingController _opmerking;
  late DateTime _saldoDatum;
  late bool _actief;

  @override
  void initState() {
    super.initState();
    final item = widget.bestaand;
    _naam = TextEditingController(text: item?.naam ?? '');
    _rekeningNummer = TextEditingController(text: item?.rekeningNummer ?? '');
    _saldo = TextEditingController(
      text: item == null ? '' : _bedragTekst(item.saldo),
    );
    _krediet = TextEditingController(
      text: item == null || item.beschikbaarKrediet == 0
          ? ''
          : _bedragTekst(item.beschikbaarKrediet),
    );
    _opmerking = TextEditingController(text: item?.opmerking ?? '');
    _saldoDatum = item?.saldoDatum ?? DateTime.now();
    _actief = item?.actief ?? true;
  }

  @override
  void dispose() {
    _naam.dispose();
    _rekeningNummer.dispose();
    _saldo.dispose();
    _krediet.dispose();
    _opmerking.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormulierDialog(
      titel: widget.bestaand == null
          ? 'Rekening toevoegen'
          : 'Rekening bewerken',
      icoon: Icons.account_balance_outlined,
      onOpslaan: _opslaan,
      child: Form(
        key: _formKey,
        child: _VeldenWrap(
          kinderen: <Widget>[
            _TekstVeld(
              controller: _naam,
              label: 'Naam rekening',
              hint: 'KBC zichtrekening',
              verplicht: true,
            ),
            _TekstVeld(
              controller: _rekeningNummer,
              label: 'Rekeningnummer',
              hint: 'BE00 0000 0000 0000',
            ),
            _BedragVeld(
              controller: _saldo,
              label: 'Actueel saldo',
              verplicht: true,
              magNegatief: true,
            ),
            _DatumVeld(
              label: 'Saldo op datum',
              datum: _saldoDatum,
              onGewijzigd: (datum) => setState(() => _saldoDatum = datum),
            ),
            _BedragVeld(
              controller: _krediet,
              label: 'Beschikbaar krediet',
              hint: 'Optioneel',
            ),
            SwitchListTile.adaptive(
              contentPadding: const EdgeInsets.symmetric(horizontal: 2),
              title: const Text(
                'Actieve rekening',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: const Text(
                'Alleen actieve rekeningen tellen mee in het totaal.',
              ),
              value: _actief,
              activeTrackColor: _groen,
              onChanged: (waarde) => setState(() => _actief = waarde),
            ),
            _TekstVeld(
              controller: _opmerking,
              label: 'Opmerking',
              maxLines: 3,
              breed: true,
            ),
          ],
        ),
      ),
    );
  }

  void _opslaan() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    Navigator.pop(
      context,
      FinancieleRekening(
        id: widget.bestaand?.id ?? FinancieleId.maak('rekening'),
        naam: _naam.text.trim(),
        rekeningNummer: _rekeningNummer.text.trim(),
        saldo: _parseBedrag(_saldo.text)!,
        saldoDatum: _saldoDatum,
        beschikbaarKrediet: _parseBedrag(_krediet.text) ?? 0,
        opmerking: _opmerking.text.trim(),
        actief: _actief,
      ),
    );
  }
}

class _TeBetalenDialog extends StatefulWidget {
  const _TeBetalenDialog({this.bestaand});

  final FinancieleTeBetalen? bestaand;

  @override
  State<_TeBetalenDialog> createState() => _TeBetalenDialogState();
}

class _TeBetalenDialogState extends State<_TeBetalenDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _leverancier;
  late final TextEditingController _omschrijving;
  late final TextEditingController _bedrag;
  late final TextEditingController _factuurNummer;
  late final TextEditingController _opmerking;
  late DateTime? _factuurDatum;
  late DateTime _vervalDatum;
  late DateTime? _geplandOp;
  late FinancieleBetalingStatus _status;
  late bool _belangrijk;

  @override
  void initState() {
    super.initState();
    final item = widget.bestaand;
    _leverancier = TextEditingController(text: item?.leverancier ?? '');
    _omschrijving = TextEditingController(text: item?.omschrijving ?? '');
    _bedrag = TextEditingController(
      text: item == null ? '' : _bedragTekst(item.bedrag),
    );
    _factuurNummer = TextEditingController(text: item?.factuurNummer ?? '');
    _opmerking = TextEditingController(text: item?.opmerking ?? '');
    _factuurDatum = item?.factuurDatum;
    _vervalDatum = item?.vervalDatum ?? DateTime.now();
    _geplandOp = item?.geplandOp;
    _status = item?.status ?? FinancieleBetalingStatus.open;
    _belangrijk = item?.belangrijk ?? false;
  }

  @override
  void dispose() {
    _leverancier.dispose();
    _omschrijving.dispose();
    _bedrag.dispose();
    _factuurNummer.dispose();
    _opmerking.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormulierDialog(
      titel: widget.bestaand == null
          ? 'Te betalen toevoegen'
          : 'Te betalen bewerken',
      icoon: Icons.arrow_upward_rounded,
      onOpslaan: _opslaan,
      child: Form(
        key: _formKey,
        child: _VeldenWrap(
          kinderen: <Widget>[
            _TekstVeld(
              controller: _leverancier,
              label: 'Leverancier / begunstigde',
              verplicht: true,
            ),
            _BedragVeld(
              controller: _bedrag,
              label: 'Bedrag',
              verplicht: true,
              striktPositief: true,
            ),
            _TekstVeld(
              controller: _omschrijving,
              label: 'Omschrijving',
              verplicht: true,
              breed: true,
            ),
            _TekstVeld(controller: _factuurNummer, label: 'Factuurnummer'),
            _OptioneleDatumVeld(
              label: 'Factuurdatum',
              datum: _factuurDatum,
              onGewijzigd: (datum) => setState(() => _factuurDatum = datum),
            ),
            _DatumVeld(
              label: 'Vervaldatum',
              datum: _vervalDatum,
              onGewijzigd: (datum) => setState(() => _vervalDatum = datum),
            ),
            _OptioneleDatumVeld(
              label: 'Gepland betalen op',
              datum: _geplandOp,
              onGewijzigd: (datum) => setState(() => _geplandOp = datum),
            ),
            _EnumDropdown<FinancieleBetalingStatus>(
              label: 'Status',
              waarde: _status,
              waarden: FinancieleBetalingStatus.values,
              labelVoor: (waarde) => waarde.label,
              onGewijzigd: (waarde) => setState(() => _status = waarde),
            ),
            SwitchListTile.adaptive(
              contentPadding: const EdgeInsets.symmetric(horizontal: 2),
              title: const Text(
                'Belangrijk',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: const Text(
                'Markeer een betaling die extra aandacht vraagt.',
              ),
              value: _belangrijk,
              activeTrackColor: _groen,
              onChanged: (waarde) => setState(() => _belangrijk = waarde),
            ),
            _TekstVeld(
              controller: _opmerking,
              label: 'Opmerking',
              maxLines: 3,
              breed: true,
            ),
          ],
        ),
      ),
    );
  }

  void _opslaan() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    Navigator.pop(
      context,
      FinancieleTeBetalen(
        id: widget.bestaand?.id ?? FinancieleId.maak('betalen'),
        leverancier: _leverancier.text.trim(),
        omschrijving: _omschrijving.text.trim(),
        bedrag: _parseBedrag(_bedrag.text)!,
        factuurNummer: _factuurNummer.text.trim(),
        factuurDatum: _factuurDatum,
        vervalDatum: _vervalDatum,
        geplandOp: _geplandOp,
        status: _status,
        belangrijk: _belangrijk,
        opmerking: _opmerking.text.trim(),
      ),
    );
  }
}

class _TeOntvangenDialog extends StatefulWidget {
  const _TeOntvangenDialog({this.bestaand});

  final FinancieleTeOntvangen? bestaand;

  @override
  State<_TeOntvangenDialog> createState() => _TeOntvangenDialogState();
}

class _TeOntvangenDialogState extends State<_TeOntvangenDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _klant;
  late final TextEditingController _omschrijving;
  late final TextEditingController _bedrag;
  late final TextEditingController _factuurNummer;
  late final TextEditingController _reedsOntvangen;
  late final TextEditingController _opmerking;
  late DateTime? _factuurDatum;
  late DateTime _vervalDatum;
  late DateTime? _verwachtOp;
  late FinancieleOntvangstStatus _status;

  @override
  void initState() {
    super.initState();
    final item = widget.bestaand;
    _klant = TextEditingController(text: item?.klant ?? '');
    _omschrijving = TextEditingController(text: item?.omschrijving ?? '');
    _bedrag = TextEditingController(
      text: item == null ? '' : _bedragTekst(item.bedrag),
    );
    _factuurNummer = TextEditingController(text: item?.factuurNummer ?? '');
    _reedsOntvangen = TextEditingController(
      text: item == null || item.reedsOntvangen == 0
          ? ''
          : _bedragTekst(item.reedsOntvangen),
    );
    _opmerking = TextEditingController(text: item?.opmerking ?? '');
    _factuurDatum = item?.factuurDatum;
    _vervalDatum = item?.vervalDatum ?? DateTime.now();
    _verwachtOp = item?.verwachtOp;
    _status = item?.status ?? FinancieleOntvangstStatus.verwacht;
  }

  @override
  void dispose() {
    _klant.dispose();
    _omschrijving.dispose();
    _bedrag.dispose();
    _factuurNummer.dispose();
    _reedsOntvangen.dispose();
    _opmerking.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormulierDialog(
      titel: widget.bestaand == null
          ? 'Te ontvangen toevoegen'
          : 'Te ontvangen bewerken',
      icoon: Icons.arrow_downward_rounded,
      onOpslaan: _opslaan,
      child: Form(
        key: _formKey,
        child: _VeldenWrap(
          kinderen: <Widget>[
            _TekstVeld(
              controller: _klant,
              label: 'Klant / betaler',
              verplicht: true,
            ),
            _BedragVeld(
              controller: _bedrag,
              label: 'Totaal bedrag',
              verplicht: true,
              striktPositief: true,
            ),
            _TekstVeld(
              controller: _omschrijving,
              label: 'Omschrijving',
              verplicht: true,
              breed: true,
            ),
            _TekstVeld(
              controller: _factuurNummer,
              label: 'Factuur- / referentienummer',
            ),
            _OptioneleDatumVeld(
              label: 'Factuurdatum',
              datum: _factuurDatum,
              onGewijzigd: (datum) => setState(() => _factuurDatum = datum),
            ),
            _DatumVeld(
              label: 'Vervaldatum',
              datum: _vervalDatum,
              onGewijzigd: (datum) => setState(() => _vervalDatum = datum),
            ),
            _OptioneleDatumVeld(
              label: 'Verwacht op',
              datum: _verwachtOp,
              onGewijzigd: (datum) => setState(() => _verwachtOp = datum),
            ),
            _EnumDropdown<FinancieleOntvangstStatus>(
              label: 'Status',
              waarde: _status,
              waarden: FinancieleOntvangstStatus.values,
              labelVoor: (waarde) => waarde.label,
              onGewijzigd: (waarde) => setState(() => _status = waarde),
            ),
            _BedragVeld(
              controller: _reedsOntvangen,
              label: 'Reeds ontvangen',
              hint: '0,00',
              extraValidator: (waarde) {
                final totaal = _parseBedrag(_bedrag.text);
                final reeds = _parseBedrag(waarde) ?? 0;
                if (totaal != null && reeds > totaal) {
                  return 'Kan niet hoger zijn dan totaal.';
                }
                return null;
              },
            ),
            _TekstVeld(
              controller: _opmerking,
              label: 'Opmerking',
              maxLines: 3,
              breed: true,
            ),
          ],
        ),
      ),
    );
  }

  void _opslaan() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    Navigator.pop(
      context,
      FinancieleTeOntvangen(
        id: widget.bestaand?.id ?? FinancieleId.maak('ontvangen'),
        klant: _klant.text.trim(),
        omschrijving: _omschrijving.text.trim(),
        bedrag: _parseBedrag(_bedrag.text)!,
        factuurNummer: _factuurNummer.text.trim(),
        factuurDatum: _factuurDatum,
        vervalDatum: _vervalDatum,
        verwachtOp: _verwachtOp,
        status: _status,
        reedsOntvangen: _parseBedrag(_reedsOntvangen.text) ?? 0,
        opmerking: _opmerking.text.trim(),
      ),
    );
  }
}

class _AndereOntvangstDialog extends StatefulWidget {
  const _AndereOntvangstDialog({this.bestaand});

  final FinancieleAndereOntvangst? bestaand;

  @override
  State<_AndereOntvangstDialog> createState() => _AndereOntvangstDialogState();
}

class _AndereOntvangstDialogState extends State<_AndereOntvangstDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _soort;
  late final TextEditingController _van;
  late final TextEditingController _omschrijving;
  late final TextEditingController _bedrag;
  late final TextEditingController _opmerking;
  late DateTime _verwachtOp;
  late FinancieleZekerheid _zekerheid;
  late FinancieleAndereOntvangstStatus _status;

  @override
  void initState() {
    super.initState();
    final item = widget.bestaand;
    _soort = TextEditingController(text: item?.soort ?? '');
    _van = TextEditingController(text: item?.van ?? '');
    _omschrijving = TextEditingController(text: item?.omschrijving ?? '');
    _bedrag = TextEditingController(
      text: item == null ? '' : _bedragTekst(item.bedrag),
    );
    _opmerking = TextEditingController(text: item?.opmerking ?? '');
    _verwachtOp = item?.verwachtOp ?? DateTime.now();
    _zekerheid = item?.zekerheid ?? FinancieleZekerheid.verwacht;
    _status = item?.status ?? FinancieleAndereOntvangstStatus.open;
  }

  @override
  void dispose() {
    _soort.dispose();
    _van.dispose();
    _omschrijving.dispose();
    _bedrag.dispose();
    _opmerking.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormulierDialog(
      titel: widget.bestaand == null
          ? 'Andere ontvangst toevoegen'
          : 'Andere ontvangst bewerken',
      icoon: Icons.savings_outlined,
      onOpslaan: _opslaan,
      child: Form(
        key: _formKey,
        child: _VeldenWrap(
          kinderen: <Widget>[
            _TekstVeld(
              controller: _soort,
              label: 'Soort',
              hint: 'BTW-teruggave, subsidie, verzekering…',
              verplicht: true,
            ),
            _TekstVeld(controller: _van, label: 'Van', hint: 'FOD Financiën'),
            _BedragVeld(
              controller: _bedrag,
              label: 'Bedrag',
              verplicht: true,
              striktPositief: true,
            ),
            _DatumVeld(
              label: 'Verwachte datum',
              datum: _verwachtOp,
              onGewijzigd: (datum) => setState(() => _verwachtOp = datum),
            ),
            _EnumDropdown<FinancieleZekerheid>(
              label: 'Zekerheid',
              waarde: _zekerheid,
              waarden: FinancieleZekerheid.values,
              labelVoor: (waarde) => waarde.label,
              onGewijzigd: (waarde) => setState(() => _zekerheid = waarde),
            ),
            _EnumDropdown<FinancieleAndereOntvangstStatus>(
              label: 'Status',
              waarde: _status,
              waarden: FinancieleAndereOntvangstStatus.values,
              labelVoor: (waarde) => waarde.label,
              onGewijzigd: (waarde) => setState(() => _status = waarde),
            ),
            _TekstVeld(
              controller: _omschrijving,
              label: 'Omschrijving',
              breed: true,
            ),
            _TekstVeld(
              controller: _opmerking,
              label: 'Opmerking',
              maxLines: 3,
              breed: true,
            ),
          ],
        ),
      ),
    );
  }

  void _opslaan() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    Navigator.pop(
      context,
      FinancieleAndereOntvangst(
        id: widget.bestaand?.id ?? FinancieleId.maak('andere-ontvangst'),
        soort: _soort.text.trim(),
        van: _van.text.trim(),
        omschrijving: _omschrijving.text.trim(),
        bedrag: _parseBedrag(_bedrag.text)!,
        verwachtOp: _verwachtOp,
        zekerheid: _zekerheid,
        status: _status,
        opmerking: _opmerking.text.trim(),
      ),
    );
  }
}

class _VasteKostDialog extends StatefulWidget {
  const _VasteKostDialog({this.bestaand});

  final FinancieleVasteKost? bestaand;

  @override
  State<_VasteKostDialog> createState() => _VasteKostDialogState();
}

class _VasteKostDialogState extends State<_VasteKostDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _categorie;
  late final TextEditingController _omschrijving;
  late final TextEditingController _leverancier;
  late final TextEditingController _bedrag;
  late final TextEditingController _betaalDag;
  late final TextEditingController _opmerking;
  late FinancieleFrequentie _frequentie;
  late DateTime? _vanaf;
  late DateTime? _tot;
  late bool _actief;

  @override
  void initState() {
    super.initState();
    final item = widget.bestaand;
    _categorie = TextEditingController(text: item?.categorie ?? '');
    _omschrijving = TextEditingController(text: item?.omschrijving ?? '');
    _leverancier = TextEditingController(text: item?.leverancier ?? '');
    _bedrag = TextEditingController(
      text: item == null ? '' : _bedragTekst(item.bedrag),
    );
    _betaalDag = TextEditingController(text: item?.betaalDag?.toString() ?? '');
    _opmerking = TextEditingController(text: item?.opmerking ?? '');
    _frequentie = item?.frequentie ?? FinancieleFrequentie.maandelijks;
    _vanaf = item?.vanaf;
    _tot = item?.tot;
    _actief = item?.actief ?? true;
  }

  @override
  void dispose() {
    _categorie.dispose();
    _omschrijving.dispose();
    _leverancier.dispose();
    _bedrag.dispose();
    _betaalDag.dispose();
    _opmerking.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormulierDialog(
      titel: widget.bestaand == null
          ? 'Vaste kost toevoegen'
          : 'Vaste kost bewerken',
      icoon: Icons.repeat_rounded,
      onOpslaan: _opslaan,
      child: Form(
        key: _formKey,
        child: _VeldenWrap(
          kinderen: <Widget>[
            _TekstVeld(
              controller: _categorie,
              label: 'Categorie',
              hint: 'Personeel, leasing, verzekering…',
              verplicht: true,
            ),
            _TekstVeld(
              controller: _leverancier,
              label: 'Leverancier / begunstigde',
            ),
            _TekstVeld(
              controller: _omschrijving,
              label: 'Omschrijving',
              verplicht: true,
              breed: true,
            ),
            _BedragVeld(
              controller: _bedrag,
              label: 'Bedrag per periode',
              verplicht: true,
              striktPositief: true,
            ),
            _EnumDropdown<FinancieleFrequentie>(
              label: 'Frequentie',
              waarde: _frequentie,
              waarden: FinancieleFrequentie.values,
              labelVoor: (waarde) => waarde.label,
              onGewijzigd: (waarde) => setState(() => _frequentie = waarde),
            ),
            _TekstVeld(
              controller: _betaalDag,
              label: 'Betaaldag',
              hint: '1 t/m 31',
              keyboardType: TextInputType.number,
              extraValidator: (waarde) {
                if (waarde.trim().isEmpty) {
                  return null;
                }
                final dag = int.tryParse(waarde.trim());
                if (dag == null || dag < 1 || dag > 31) {
                  return 'Vul een dag tussen 1 en 31 in.';
                }
                return null;
              },
            ),
            _OptioneleDatumVeld(
              label: 'Vanaf',
              datum: _vanaf,
              onGewijzigd: (datum) => setState(() => _vanaf = datum),
            ),
            _OptioneleDatumVeld(
              label: 'Tot',
              datum: _tot,
              onGewijzigd: (datum) => setState(() => _tot = datum),
            ),
            SwitchListTile.adaptive(
              contentPadding: const EdgeInsets.symmetric(horizontal: 2),
              title: const Text(
                'Actieve vaste kost',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: const Text(
                'Inactieve kosten tellen niet mee in maand- en jaartotaal.',
              ),
              value: _actief,
              activeTrackColor: _groen,
              onChanged: (waarde) => setState(() => _actief = waarde),
            ),
            _TekstVeld(
              controller: _opmerking,
              label: 'Opmerking',
              maxLines: 3,
              breed: true,
            ),
          ],
        ),
      ),
    );
  }

  void _opslaan() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    if (_vanaf != null && _tot != null && _tot!.isBefore(_vanaf!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('De einddatum kan niet vóór de begindatum liggen.'),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      FinancieleVasteKost(
        id: widget.bestaand?.id ?? FinancieleId.maak('vaste-kost'),
        categorie: _categorie.text.trim(),
        omschrijving: _omschrijving.text.trim(),
        leverancier: _leverancier.text.trim(),
        bedrag: _parseBedrag(_bedrag.text)!,
        frequentie: _frequentie,
        betaalDag: int.tryParse(_betaalDag.text.trim()),
        vanaf: _vanaf,
        tot: _tot,
        actief: _actief,
        opmerking: _opmerking.text.trim(),
      ),
    );
  }
}

class _FormulierDialog extends StatelessWidget {
  const _FormulierDialog({
    required this.titel,
    required this.icoon,
    required this.child,
    required this.onOpslaan,
  });

  final String titel;
  final IconData icoon;
  final Widget child;
  final VoidCallback onOpslaan;

  @override
  Widget build(BuildContext context) {
    final grootte = MediaQuery.sizeOf(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 760,
          maxHeight: grootte.height - 40,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _rand),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 28,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _lichtGroen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icoon, color: _groen, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        titel,
                        style: const TextStyle(
                          color: _tekstDonker,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Sluiten',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: _rand),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: child,
                ),
              ),
              const Divider(height: 1, color: _rand),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuleren'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: _groen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      onPressed: onOpslaan,
                      icon: const Icon(Icons.save_outlined, size: 19),
                      label: const Text(
                        'Opslaan',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VeldenWrap extends StatelessWidget {
  const _VeldenWrap({required this.kinderen});

  final List<Widget> kinderen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tweeKolommen = constraints.maxWidth >= 620;
        final breedte = tweeKolommen
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 14,
          children: kinderen
              .map((kind) {
                final breed = kind is _TekstVeld && kind.breed;
                return SizedBox(
                  width: breed || !tweeKolommen
                      ? constraints.maxWidth
                      : breedte,
                  child: kind,
                );
              })
              .toList(growable: false),
        );
      },
    );
  }
}

class _TekstVeld extends StatelessWidget {
  const _TekstVeld({
    required this.controller,
    required this.label,
    this.hint,
    this.verplicht = false,
    this.maxLines = 1,
    this.breed = false,
    this.keyboardType,
    this.extraValidator,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool verplicht;
  final int maxLines;
  final bool breed;
  final TextInputType? keyboardType;
  final String? Function(String waarde)? extraValidator;

  @override
  Widget build(BuildContext context) {
    final veld = TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textCapitalization: TextCapitalization.sentences,
      decoration: _decoratie(label, hint: hint),
      validator: (waarde) {
        final tekst = waarde?.trim() ?? '';
        if (verplicht && tekst.isEmpty) {
          return 'Dit veld is verplicht.';
        }
        return extraValidator?.call(tekst);
      },
    );
    return veld;
  }
}

class _BedragVeld extends StatelessWidget {
  const _BedragVeld({
    required this.controller,
    required this.label,
    this.hint,
    this.verplicht = false,
    this.magNegatief = false,
    this.striktPositief = false,
    this.extraValidator,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool verplicht;
  final bool magNegatief;
  final bool striktPositief;
  final String? Function(String waarde)? extraValidator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      decoration: _decoratie(label, hint: hint, prefix: '€'),
      validator: (waarde) {
        final tekst = waarde?.trim() ?? '';
        if (tekst.isEmpty) {
          if (verplicht) {
            return 'Vul een bedrag in.';
          }
          return extraValidator?.call('');
        }
        final bedrag = _parseBedrag(tekst);
        if (bedrag == null) {
          return 'Vul een geldig bedrag in.';
        }
        if (!magNegatief && bedrag < 0) {
          return 'Een negatief bedrag is hier niet toegestaan.';
        }
        if (striktPositief && bedrag <= 0) {
          return 'Vul een bedrag groter dan nul in.';
        }
        return extraValidator?.call(tekst);
      },
    );
  }
}

class _DatumVeld extends StatelessWidget {
  const _DatumVeld({
    required this.label,
    required this.datum,
    required this.onGewijzigd,
  });

  final String label;
  final DateTime datum;
  final ValueChanged<DateTime> onGewijzigd;

  @override
  Widget build(BuildContext context) {
    return _DatumKnop(
      label: label,
      tekst: _datumTekst(datum),
      onTap: () async {
        final gekozen = await showDatePicker(
          context: context,
          initialDate: datum,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (gekozen != null) {
          onGewijzigd(gekozen);
        }
      },
    );
  }
}

class _OptioneleDatumVeld extends StatelessWidget {
  const _OptioneleDatumVeld({
    required this.label,
    required this.datum,
    required this.onGewijzigd,
  });

  final String label;
  final DateTime? datum;
  final ValueChanged<DateTime?> onGewijzigd;

  @override
  Widget build(BuildContext context) {
    return _DatumKnop(
      label: label,
      tekst: datum == null ? 'Niet ingevuld' : _datumTekst(datum!),
      leeg: datum == null,
      onWis: datum == null ? null : () => onGewijzigd(null),
      onTap: () async {
        final gekozen = await showDatePicker(
          context: context,
          initialDate: datum ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (gekozen != null) {
          onGewijzigd(gekozen);
        }
      },
    );
  }
}

class _DatumKnop extends StatelessWidget {
  const _DatumKnop({
    required this.label,
    required this.tekst,
    required this.onTap,
    this.leeg = false,
    this.onWis,
  });

  final String label;
  final String tekst;
  final VoidCallback onTap;
  final bool leeg;
  final VoidCallback? onWis;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(11),
      onTap: onTap,
      child: InputDecorator(
        decoration: _decoratie(label),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: leeg ? _tekstGrijs : _groen,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                tekst,
                style: TextStyle(
                  color: leeg ? _tekstGrijs : _tekstDonker,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (onWis != null)
              IconButton(
                tooltip: 'Datum wissen',
                visualDensity: VisualDensity.compact,
                onPressed: onWis,
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

class _EnumDropdown<T> extends StatelessWidget {
  const _EnumDropdown({
    required this.label,
    required this.waarde,
    required this.waarden,
    required this.labelVoor,
    required this.onGewijzigd,
  });

  final String label;
  final T waarde;
  final List<T> waarden;
  final String Function(T waarde) labelVoor;
  final ValueChanged<T> onGewijzigd;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: waarde,
      decoration: _decoratie(label),
      items: waarden
          .map(
            (item) =>
                DropdownMenuItem<T>(value: item, child: Text(labelVoor(item))),
          )
          .toList(growable: false),
      onChanged: (nieuw) {
        if (nieuw != null) {
          onGewijzigd(nieuw);
        }
      },
    );
  }
}

InputDecoration _decoratie(String label, {String? hint, String? prefix}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixText: prefix == null ? null : '$prefix ',
    filled: true,
    fillColor: const Color(0xFFFAFAFA),
    isDense: true,
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
      borderSide: const BorderSide(color: _groen, width: 1.5),
    ),
  );
}

String _datumTekst(DateTime datum) {
  String twee(int waarde) => waarde.toString().padLeft(2, '0');
  return '${twee(datum.day)}/${twee(datum.month)}/${datum.year}';
}

String _bedragTekst(double bedrag) =>
    bedrag.toStringAsFixed(2).replaceAll('.', ',');

double? _parseBedrag(String invoer) {
  var tekst = invoer
      .trim()
      .replaceAll('€', '')
      .replaceAll(' ', '')
      .replaceAll('\u00A0', '');
  if (tekst.isEmpty) {
    return null;
  }

  final komma = tekst.lastIndexOf(',');
  final punt = tekst.lastIndexOf('.');

  if (komma >= 0 && punt >= 0) {
    if (komma > punt) {
      tekst = tekst.replaceAll('.', '').replaceAll(',', '.');
    } else {
      tekst = tekst.replaceAll(',', '');
    }
  } else if (komma >= 0) {
    tekst = tekst.replaceAll('.', '').replaceAll(',', '.');
  } else if (punt >= 0) {
    final aantalPunten = '.'.allMatches(tekst).length;
    final cijfersNaPunt = tekst.length - punt - 1;
    if (aantalPunten > 1 || cijfersNaPunt == 3) {
      tekst = tekst.replaceAll('.', '');
    }
  }

  return double.tryParse(tekst);
}
