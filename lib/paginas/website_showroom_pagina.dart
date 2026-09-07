import 'package:flutter/material.dart';

import '../helpers/website/thimaco_website_service.dart';

const Color _thimacoGroen = Color(0xFF0B7A3B);
const Color _thimacoLichtGroen = Color(0xFFE7F6EC);
const Color _thimacoDonkerGroen = Color(0xFF07552A);

class WebsiteShowroomPagina extends StatefulWidget {
  const WebsiteShowroomPagina({super.key});

  @override
  State<WebsiteShowroomPagina> createState() => _WebsiteShowroomPaginaState();
}

class _WebsiteShowroomPaginaState extends State<WebsiteShowroomPagina> {
  final ThimacoWebsiteService _service = ThimacoWebsiteService();

  DateTime _maand = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _geselecteerdeDag = DateTime.now();

  WebsiteShowroomData? _data;
  bool _laden = true;
  String? _fout;

  @override
  void initState() {
    super.initState();
    _laadMaand();
  }

  Future<void> _laadMaand() async {
    setState(() {
      _laden = true;
      _fout = null;
    });

    try {
      final data = await _service.laadMaand(_maand);
      if (!mounted) return;
      setState(() {
        _data = data;
        _laden = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _fout = error.toString();
        _laden = false;
      });
    }
  }

  void _vorigeMaand() {
    setState(() {
      _maand = DateTime(_maand.year, _maand.month - 1, 1);
      _geselecteerdeDag = _maand;
    });
    _laadMaand();
  }

  void _volgendeMaand() {
    setState(() {
      _maand = DateTime(_maand.year, _maand.month + 1, 1);
      _geselecteerdeDag = _maand;
    });
    _laadMaand();
  }

  @override
  Widget build(BuildContext context) {
    final basisTheme = Theme.of(context);
    final thimacoScheme = basisTheme.colorScheme.copyWith(
      primary: _thimacoGroen,
      secondary: _thimacoGroen,
      primaryContainer: _thimacoLichtGroen,
      onPrimary: Colors.white,
      onPrimaryContainer: _thimacoDonkerGroen,
    );

    return Theme(
      data: basisTheme.copyWith(
        colorScheme: thimacoScheme,
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: _thimacoGroen,
        ),
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Website & showroom'),
            bottom: const TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.calendar_month_outlined),
                  text: 'Showroomagenda',
                ),
                Tab(
                  icon: Icon(Icons.campaign_outlined),
                  text: 'Websitebericht',
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _bouwAgendaTab(),
              WebsiteBerichtTab(
                service: _service,
                initieelBericht: _data?.bericht,
                onOpgeslagen: _laadMaand,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bouwAgendaTab() {
    if (_laden) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_fout != null) {
      return _FoutPaneel(
        tekst: _fout!,
        onOpnieuw: _laadMaand,
      );
    }

    final data = _data ??
        const WebsiteShowroomData(
          bookings: [],
          blocks: [],
          bericht: null,
        );

    final dagBookings = data.bookings
        .where((item) => _zelfdeDag(item.datum, _geselecteerdeDag))
        .toList()
      ..sort((a, b) => a.startTijd.compareTo(b.startTijd));

    final dagBlocks = data.blocks
        .where((item) => _zelfdeDag(item.datum, _geselecteerdeDag))
        .toList()
      ..sort((a, b) => a.startMinuut.compareTo(b.startMinuut));

    return RefreshIndicator(
      onRefresh: _laadMaand,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _MaandKop(
            maand: _maand,
            onVorige: _vorigeMaand,
            onVolgende: _volgendeMaand,
          ),
          const SizedBox(height: 12),
          _MaandRaster(
            maand: _maand,
            geselecteerdeDag: _geselecteerdeDag,
            bookings: data.bookings,
            blocks: data.blocks,
            onDagGekozen: (dag) {
              setState(() => _geselecteerdeDag = dag);
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  _volledigeDatum(_geselecteerdeDag),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              FilledButton.icon(
                onPressed: () => _toonNieuweBlokkering(_geselecteerdeDag),
                icon: const Icon(Icons.block_outlined),
                label: const Text('Blokkeren'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (dagBookings.isEmpty && dagBlocks.isEmpty)
            const _LegeDagKaart()
          else ...[
            if (dagBookings.isNotEmpty) ...[
              _SectieTitel(
                icoon: Icons.people_alt_outlined,
                titel: 'Showroomafspraken',
                aantal: dagBookings.length,
              ),
              const SizedBox(height: 8),
              ...dagBookings.map(_bouwBookingKaart),
              const SizedBox(height: 16),
            ],
            if (dagBlocks.isNotEmpty) ...[
              _SectieTitel(
                icoon: Icons.block_outlined,
                titel: 'Blokkeringen',
                aantal: dagBlocks.length,
              ),
              const SizedBox(height: 8),
              ...dagBlocks.map(_bouwBlockKaart),
            ],
          ],
        ],
      ),
    );
  }

  Widget _bouwBookingKaart(WebsiteShowroomBooking booking) {
    final details = <String>[
      if (booking.reference.trim().isNotEmpty) booking.reference.trim(),
      if (booking.projecten.isNotEmpty) booking.projecten.join(' · '),
      if (booking.locatie.trim().isNotEmpty) booking.locatie.trim(),
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${booking.startTijd} – ${booking.eindTijd}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    booking.klantNaam.trim().isEmpty
                        ? 'Showroomadvies'
                        : booking.klantNaam,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            if (details.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(details.join('  •  ')),
            ],
            if (booking.gsm.trim().isNotEmpty ||
                booking.email.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 14,
                runSpacing: 6,
                children: [
                  if (booking.gsm.trim().isNotEmpty)
                    _InfoRegel(
                      icoon: Icons.phone_outlined,
                      tekst: booking.gsm,
                    ),
                  if (booking.email.trim().isNotEmpty)
                    _InfoRegel(
                      icoon: Icons.email_outlined,
                      tekst: booking.email,
                    ),
                ],
              ),
            ],
            if (booking.notitie.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                booking.notitie,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _bouwBlockKaart(WebsiteShowroomBlock block) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.block_outlined),
        ),
        title: Text(
          '${_tijdVanMinuten(block.startMinuut)} – '
          '${_tijdVanMinuten(block.eindMinuut)} · ${block.reden}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle:
            block.notitie.trim().isEmpty ? null : Text(block.notitie.trim()),
        trailing: IconButton(
          tooltip: 'Blokkering verwijderen',
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _verwijderBlokkering(block),
        ),
      ),
    );
  }

  Future<void> _verwijderBlokkering(WebsiteShowroomBlock block) async {
    final akkoord = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Blokkering verwijderen?'),
        content: Text(
          '${_tijdVanMinuten(block.startMinuut)} – '
          '${_tijdVanMinuten(block.eindMinuut)} · ${block.reden}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Verwijderen'),
          ),
        ],
      ),
    );

    if (akkoord != true) return;

    try {
      await _service.verwijderBlokkering(block.id);
      await _laadMaand();
      if (!mounted) return;
      _toonMelding('Blokkering verwijderd.');
    } catch (error) {
      if (!mounted) return;
      _toonMelding(error.toString(), fout: true);
    }
  }

  Future<void> _toonNieuweBlokkering(DateTime dag) async {
    final resultaat = await showDialog<_NieuweBlokkering>(
      context: context,
      builder: (context) => _NieuweBlokkeringDialog(datum: dag),
    );

    if (resultaat == null) return;

    try {
      await _service.voegBlokkeringToe(
        datum: dag,
        startMinuut: resultaat.startMinuut,
        eindMinuut: resultaat.eindMinuut,
        reden: resultaat.reden,
        notitie: resultaat.notitie,
      );
      await _laadMaand();
      if (!mounted) return;
      _toonMelding('Showroomblokkering opgeslagen.');
    } catch (error) {
      if (!mounted) return;
      _toonMelding(error.toString(), fout: true);
    }
  }

  void _toonMelding(String tekst, {bool fout = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tekst),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class WebsiteBerichtTab extends StatefulWidget {
  const WebsiteBerichtTab({
    super.key,
    required this.service,
    required this.initieelBericht,
    required this.onOpgeslagen,
  });

  final ThimacoWebsiteService service;
  final WebsiteBericht? initieelBericht;
  final Future<void> Function() onOpgeslagen;

  @override
  State<WebsiteBerichtTab> createState() => _WebsiteBerichtTabState();
}

class _WebsiteBerichtTabState extends State<WebsiteBerichtTab> {
  final TextEditingController _tekstController = TextEditingController();

  String _id = '';
  String _type = 'Mededeling';
  DateTime _vanaf = DateTime.now();
  DateTime _tot = DateTime.now().add(const Duration(days: 7));
  bool _actief = false;
  bool _bezig = false;

  bool get _heeftOpgeslagenBericht => _id.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _vulVanBericht(widget.initieelBericht);
  }

  @override
  void didUpdateWidget(covariant WebsiteBerichtTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oud = oldWidget.initieelBericht;
    final nieuw = widget.initieelBericht;

    if (oud?.id != nieuw?.id ||
        oud?.tekst != nieuw?.tekst ||
        oud?.type != nieuw?.type ||
        oud?.actief != nieuw?.actief ||
        oud?.vanaf != nieuw?.vanaf ||
        oud?.tot != nieuw?.tot) {
      _vulVanBericht(nieuw);
    }
  }

  void _vulVanBericht(WebsiteBericht? bericht) {
    if (bericht == null) {
      _id = '';
      _type = 'Mededeling';
      _tekstController.clear();
      _vanaf = DateTime.now();
      _tot = DateTime.now().add(const Duration(days: 7));
      _actief = false;
      return;
    }

    _id = bericht.id;
    _type = bericht.type;
    _tekstController.text = bericht.tekst;
    _vanaf = bericht.vanaf;
    _tot = bericht.tot;
    _actief = bericht.actief;
  }

  @override
  void dispose() {
    _tekstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onOpgeslagen,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
        children: [
          Text(
            'Websitebericht',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: _thimacoDonkerGroen,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sla de tekst op en bepaal daarna apart of het bericht op de '
            'website zichtbaar is. Uitschakelen wist de tekst niet.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _WebsiteBerichtStatus(
            titel: _statusTitel(),
            uitleg: _statusUitleg(),
            zichtbaar: _isNuZichtbaar(),
            actief: _actief,
            heeftBericht: _heeftOpgeslagenBericht,
          ),
          const SizedBox(height: 18),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(
              labelText: 'Type',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'Mededeling',
                child: Text('Mededeling'),
              ),
              DropdownMenuItem(
                value: 'Gesloten',
                child: Text('Gesloten'),
              ),
              DropdownMenuItem(
                value: 'Verlof',
                child: Text('Verlof'),
              ),
              DropdownMenuItem(
                value: 'Actie',
                child: Text('Actie'),
              ),
            ],
            onChanged: _bezig
                ? null
                : (value) {
                    if (value != null) setState(() => _type = value);
                  },
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _tekstController,
            enabled: !_bezig,
            maxLength: 180,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Bericht',
              hintText: 'Bijvoorbeeld: zaterdag uitzonderlijk gesloten.',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _DatumKnop(
                  titel: 'Van',
                  datum: _vanaf,
                  onTap: _bezig ? () {} : () => _kiesDatum(vanaf: true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DatumKnop(
                  titel: 'Tot',
                  datum: _tot,
                  onTap: _bezig ? () {} : () => _kiesDatum(vanaf: false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: _thimacoLichtGroen,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _thimacoGroen.withValues(alpha: 0.25),
              ),
            ),
            child: SwitchListTile.adaptive(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 4,
              ),
              title: const Text(
                'Tonen op website',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: _thimacoDonkerGroen,
                ),
              ),
              subtitle: Text(
                !_heeftOpgeslagenBericht
                    ? 'Sla het bericht eerst op. Daarna kunt u het hier aanzetten.'
                    : _actief
                        ? 'AAN: het bericht is geactiveerd. De datums bepalen wanneer het zichtbaar is.'
                        : 'UIT: het bericht blijft opgeslagen, maar wordt niet op de website getoond.',
              ),
              value: _actief,
              onChanged: _bezig || !_heeftOpgeslagenBericht
                  ? null
                  : _wijzigZichtbaarheid,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _thimacoGroen,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: _bezig ? null : _bewaar,
            icon: _bezig
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_bezig ? 'Even wachten…' : 'Bericht opslaan'),
          ),
          if (_heeftOpgeslagenBericht) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: _bezig ? null : _verwijderDefinitief,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Bericht definitief wissen'),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            'Aan/uit verandert alleen de zichtbaarheid. '
            'Alleen "Bericht definitief wissen" verwijdert de opgeslagen tekst.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  bool _isNuZichtbaar() {
    if (!_heeftOpgeslagenBericht || !_actief) return false;

    final nu = DateTime.now();
    return !nu.isBefore(_vanaf) && !nu.isAfter(_tot);
  }

  String _statusTitel() {
    if (!_heeftOpgeslagenBericht) {
      return 'Nog geen opgeslagen websitebericht';
    }

    if (!_actief) {
      return 'NIET ZICHTBAAR OP WEBSITE';
    }

    final nu = DateTime.now();

    if (nu.isBefore(_vanaf)) {
      return 'INGEPLAND - NOG NIET ZICHTBAAR';
    }

    if (nu.isAfter(_tot)) {
      return 'NIET ZICHTBAAR - EINDDATUM VERSTREKEN';
    }

    return 'ZICHTBAAR OP WEBSITE';
  }

  String _statusUitleg() {
    if (!_heeftOpgeslagenBericht) {
      return 'Vul een bericht in en druk eerst op "Bericht opslaan".';
    }

    if (!_actief) {
      return 'Het bericht blijft bewaard. Zet "Tonen op website" aan om het zichtbaar te maken.';
    }

    final nu = DateTime.now();

    if (nu.isBefore(_vanaf)) {
      return 'Het bericht staat aan en verschijnt automatisch vanaf ${_korteDatum(_vanaf)}.';
    }

    if (nu.isAfter(_tot)) {
      return 'Het bericht staat nog aan, maar de einddatum ${_korteDatum(_tot)} is voorbij.';
    }

    return 'Het bericht staat aan en valt binnen de ingestelde periode.';
  }

  Future<void> _kiesDatum({required bool vanaf}) async {
    final huidige = vanaf ? _vanaf : _tot;
    final gekozen = await showDatePicker(
      context: context,
      initialDate: huidige,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (gekozen == null) return;

    setState(() {
      if (vanaf) {
        _vanaf = DateTime(gekozen.year, gekozen.month, gekozen.day, 0, 0);
        if (!_tot.isAfter(_vanaf)) {
          _tot = _vanaf.add(const Duration(days: 1));
        }
      } else {
        _tot = DateTime(gekozen.year, gekozen.month, gekozen.day, 23, 59);
      }
    });
  }

  Future<void> _bewaar() async {
    final tekst = _tekstController.text.trim();

    if (tekst.isEmpty) {
      _toonMelding('Vul eerst een websitebericht in.', fout: true);
      return;
    }

    if (!_tot.isAfter(_vanaf)) {
      _toonMelding(
        'De einddatum moet na de begindatum liggen.',
        fout: true,
      );
      return;
    }

    setState(() => _bezig = true);

    try {
      final opgeslagen = await widget.service.bewaarWebsiteBericht(
        id: _id,
        type: _type,
        tekst: tekst,
        vanaf: _vanaf,
        tot: _tot,
        // Nieuwe tekst wordt eerst veilig opgeslagen en niet automatisch getoond.
        actief: _heeftOpgeslagenBericht ? _actief : false,
      );

      if (!mounted) return;

      setState(() {
        _id = opgeslagen.id;
        _type = opgeslagen.type;
        _tekstController.text = opgeslagen.tekst;
        _vanaf = opgeslagen.vanaf;
        _tot = opgeslagen.tot;
        _actief = opgeslagen.actief;
      });

      await widget.onOpgeslagen();
      if (!mounted) return;

      _toonMelding(
        _actief
            ? 'Bericht opgeslagen en blijft actief.'
            : 'Bericht opgeslagen. Het staat niet zichtbaar op de website.',
      );
    } catch (error) {
      if (!mounted) return;
      _toonMelding(error.toString(), fout: true);
    } finally {
      if (mounted) setState(() => _bezig = false);
    }
  }

  Future<void> _wijzigZichtbaarheid(bool zichtbaar) async {
    if (!_heeftOpgeslagenBericht) return;

    final vorigeWaarde = _actief;

    setState(() {
      _actief = zichtbaar;
      _bezig = true;
    });

    try {
      final opgeslagen = await widget.service.stelWebsiteBerichtActief(
        id: _id,
        actief: zichtbaar,
      );

      if (!mounted) return;

      setState(() {
        _id = opgeslagen.id;
        _type = opgeslagen.type;
        _tekstController.text = opgeslagen.tekst;
        _vanaf = opgeslagen.vanaf;
        _tot = opgeslagen.tot;
        _actief = opgeslagen.actief;
      });

      await widget.onOpgeslagen();
      if (!mounted) return;

      if (_isNuZichtbaar()) {
        _toonMelding('Websitebericht staat nu zichtbaar op de website.');
      } else if (_actief) {
        _toonMelding(
          'Websitebericht staat aan. Het valt momenteel buiten de ingestelde periode.',
        );
      } else {
        _toonMelding('Websitebericht staat uit. De tekst blijft opgeslagen.');
      }
    } catch (error) {
      if (!mounted) return;

      setState(() => _actief = vorigeWaarde);
      _toonMelding(error.toString(), fout: true);
    } finally {
      if (mounted) setState(() => _bezig = false);
    }
  }

  Future<void> _verwijderDefinitief() async {
    if (!_heeftOpgeslagenBericht) return;

    final akkoord = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.delete_outline,
            color: Colors.red,
          ),
          title: const Text('Websitebericht definitief wissen?'),
          content: const Text(
            'De opgeslagen tekst wordt volledig verwijderd. '
            'Als het bericht zichtbaar is, verdwijnt het van de website. '
            'Dit kan niet ongedaan worden gemaakt.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuleren'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Definitief wissen'),
            ),
          ],
        );
      },
    );

    if (akkoord != true) return;

    setState(() => _bezig = true);

    try {
      await widget.service.verwijderWebsiteBericht(_id);
      await widget.onOpgeslagen();

      if (!mounted) return;

      setState(() {
        _id = '';
        _type = 'Mededeling';
        _tekstController.clear();
        _vanaf = DateTime.now();
        _tot = DateTime.now().add(const Duration(days: 7));
        _actief = false;
      });

      _toonMelding('Websitebericht is definitief gewist.');
    } catch (error) {
      if (!mounted) return;
      _toonMelding(error.toString(), fout: true);
    } finally {
      if (mounted) setState(() => _bezig = false);
    }
  }

  void _toonMelding(String tekst, {bool fout = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tekst),
        behavior: SnackBarBehavior.floating,
        backgroundColor: fout ? Colors.red : _thimacoGroen,
      ),
    );
  }
}

class _WebsiteBerichtStatus extends StatelessWidget {
  const _WebsiteBerichtStatus({
    required this.titel,
    required this.uitleg,
    required this.zichtbaar,
    required this.actief,
    required this.heeftBericht,
  });

  final String titel;
  final String uitleg;
  final bool zichtbaar;
  final bool actief;
  final bool heeftBericht;

  @override
  Widget build(BuildContext context) {
    final Color kleur;
    final IconData icoon;

    if (zichtbaar) {
      kleur = _thimacoGroen;
      icoon = Icons.visibility_outlined;
    } else if (actief && heeftBericht) {
      kleur = Colors.orange;
      icoon = Icons.schedule_outlined;
    } else {
      kleur = Theme.of(context).colorScheme.onSurfaceVariant;
      icoon = Icons.visibility_off_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kleur.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: kleur.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icoon, color: kleur),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titel,
                  style: TextStyle(
                    color: kleur,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(uitleg),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MaandKop extends StatelessWidget {
  const _MaandKop({
    required this.maand,
    required this.onVorige,
    required this.onVolgende,
  });

  final DateTime maand;
  final VoidCallback onVorige;
  final VoidCallback onVolgende;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Vorige maand',
          onPressed: onVorige,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Text(
            _maandNaam(maand),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        IconButton(
          tooltip: 'Volgende maand',
          onPressed: onVolgende,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _MaandRaster extends StatelessWidget {
  const _MaandRaster({
    required this.maand,
    required this.geselecteerdeDag,
    required this.bookings,
    required this.blocks,
    required this.onDagGekozen,
  });

  final DateTime maand;
  final DateTime geselecteerdeDag;
  final List<WebsiteShowroomBooking> bookings;
  final List<WebsiteShowroomBlock> blocks;
  final ValueChanged<DateTime> onDagGekozen;

  @override
  Widget build(BuildContext context) {
    final eerste = DateTime(maand.year, maand.month, 1);
    final aantalDagen = DateTime(maand.year, maand.month + 1, 0).day;
    final legeCellen = eerste.weekday - 1;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const Row(
              children: [
                _Weekdag('ma'),
                _Weekdag('di'),
                _Weekdag('wo'),
                _Weekdag('do'),
                _Weekdag('vr'),
                _Weekdag('za'),
                _Weekdag('zo'),
              ],
            ),
            const SizedBox(height: 6),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: legeCellen + aantalDagen,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: 0.92,
              ),
              itemBuilder: (context, index) {
                if (index < legeCellen) return const SizedBox.shrink();

                final dagnummer = index - legeCellen + 1;
                final dag = DateTime(maand.year, maand.month, dagnummer);

                final aantalBookings =
                    bookings.where((item) => _zelfdeDag(item.datum, dag)).length;
                final aantalBlocks =
                    blocks.where((item) => _zelfdeDag(item.datum, dag)).length;

                final geselecteerd = _zelfdeDag(dag, geselecteerdeDag);
                final vandaag = _zelfdeDag(dag, DateTime.now());

                return InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => onDagGekozen(dag),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: geselecteerd
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      border: vandaag && !geselecteerd
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$dagnummer',
                          style: TextStyle(
                            fontWeight: geselecteerd || vandaag
                                ? FontWeight.w800
                                : FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        if (aantalBookings > 0)
                          _DagBadge(
                            icoon: Icons.person_outline,
                            aantal: aantalBookings,
                          ),
                        if (aantalBlocks > 0)
                          _DagBadge(
                            icoon: Icons.block_outlined,
                            aantal: aantalBlocks,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Weekdag extends StatelessWidget {
  const _Weekdag(this.tekst);

  final String tekst;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        tekst,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _DagBadge extends StatelessWidget {
  const _DagBadge({
    required this.icoon,
    required this.aantal,
  });

  final IconData icoon;
  final int aantal;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icoon, size: 11),
        const SizedBox(width: 2),
        Text(
          '$aantal',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _NieuweBlokkeringDialog extends StatefulWidget {
  const _NieuweBlokkeringDialog({required this.datum});

  final DateTime datum;

  @override
  State<_NieuweBlokkeringDialog> createState() =>
      _NieuweBlokkeringDialogState();
}

class _NieuweBlokkeringDialogState extends State<_NieuweBlokkeringDialog> {
  final TextEditingController _notitieController = TextEditingController();

  String _periode = 'Hele dag';
  String _reden = 'Afwezig';
  TimeOfDay _start = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _einde = const TimeOfDay(hour: 18, minute: 0);

  @override
  void dispose() {
    _notitieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eigenUren = _periode == 'Eigen uren';

    return AlertDialog(
      title: Text('Blokkeer ${_korteDatum(widget.datum)}'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _periode,
                decoration: const InputDecoration(
                  labelText: 'Periode',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Hele dag',
                    child: Text('Hele dag'),
                  ),
                  DropdownMenuItem(
                    value: 'Voormiddag',
                    child: Text('Voormiddag'),
                  ),
                  DropdownMenuItem(
                    value: 'Namiddag',
                    child: Text('Namiddag'),
                  ),
                  DropdownMenuItem(
                    value: 'Eigen uren',
                    child: Text('Eigen uren'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _periode = value);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _reden,
                decoration: const InputDecoration(
                  labelText: 'Reden',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Verlof', child: Text('Verlof')),
                  DropdownMenuItem(value: 'Afwezig', child: Text('Afwezig')),
                  DropdownMenuItem(value: 'Volzet', child: Text('Volzet')),
                  DropdownMenuItem(value: 'Gesloten', child: Text('Gesloten')),
                  DropdownMenuItem(value: 'Andere', child: Text('Andere')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _reden = value);
                },
              ),
              if (eigenUren) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _kiesTijd(start: true),
                        child: Text('Van ${_formatTimeOfDay(_start)}'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _kiesTijd(start: false),
                        child: Text('Tot ${_formatTimeOfDay(_einde)}'),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: _notitieController,
                maxLength: 300,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notitie (optioneel)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuleren'),
        ),
        FilledButton(
          onPressed: _bewaar,
          child: const Text('Blokkeren'),
        ),
      ],
    );
  }

  Future<void> _kiesTijd({required bool start}) async {
    final gekozen = await showTimePicker(
      context: context,
      initialTime: start ? _start : _einde,
    );
    if (gekozen == null) return;

    setState(() {
      if (start) {
        _start = gekozen;
      } else {
        _einde = gekozen;
      }
    });
  }

  void _bewaar() {
    int startMinuut;
    int eindMinuut;

    switch (_periode) {
      case 'Voormiddag':
        startMinuut = 9 * 60;
        eindMinuut = 12 * 60;
      case 'Namiddag':
        startMinuut = 13 * 60 + 30;
        eindMinuut = 18 * 60;
      case 'Eigen uren':
        startMinuut = _start.hour * 60 + _start.minute;
        eindMinuut = _einde.hour * 60 + _einde.minute;
      default:
        startMinuut = 9 * 60;
        eindMinuut =
            widget.datum.weekday == DateTime.saturday ? 12 * 60 : 18 * 60;
    }

    if (eindMinuut <= startMinuut) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('De eindtijd moet na de begintijd liggen.'),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      _NieuweBlokkering(
        startMinuut: startMinuut,
        eindMinuut: eindMinuut,
        reden: _reden,
        notitie: _notitieController.text.trim(),
      ),
    );
  }
}

class _NieuweBlokkering {
  const _NieuweBlokkering({
    required this.startMinuut,
    required this.eindMinuut,
    required this.reden,
    required this.notitie,
  });

  final int startMinuut;
  final int eindMinuut;
  final String reden;
  final String notitie;
}

class _SectieTitel extends StatelessWidget {
  const _SectieTitel({
    required this.icoon,
    required this.titel,
    required this.aantal,
  });

  final IconData icoon;
  final String titel;
  final int aantal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icoon, size: 20),
        const SizedBox(width: 8),
        Text(
          titel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(width: 8),
        Text('($aantal)'),
      ],
    );
  }
}

class _InfoRegel extends StatelessWidget {
  const _InfoRegel({
    required this.icoon,
    required this.tekst,
  });

  final IconData icoon;
  final String tekst;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icoon, size: 16),
        const SizedBox(width: 5),
        Text(tekst),
      ],
    );
  }
}

class _DatumKnop extends StatelessWidget {
  const _DatumKnop({
    required this.titel,
    required this.datum,
    required this.onTap,
  });

  final String titel;
  final DateTime datum;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      child: Column(
        children: [
          Text(
            titel,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 3),
          Text(
            _korteDatum(datum),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _FoutPaneel extends StatelessWidget {
  const _FoutPaneel({
    required this.tekst,
    required this.onOpnieuw,
  });

  final String tekst;
  final VoidCallback onOpnieuw;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 46),
              const SizedBox(height: 12),
              Text(
                'Websitebeheer kon niet worden geladen',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                tekst,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onOpnieuw,
                icon: const Icon(Icons.refresh),
                label: const Text('Opnieuw proberen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegeDagKaart extends StatelessWidget {
  const _LegeDagKaart();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Icon(Icons.event_available_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Geen showroomafspraken of blokkeringen op deze dag.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool _zelfdeDag(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _tijdVanMinuten(int minuten) {
  final uur = minuten ~/ 60;
  final min = minuten % 60;
  return '${uur.toString().padLeft(2, '0')}:'
      '${min.toString().padLeft(2, '0')}';
}

String _formatTimeOfDay(TimeOfDay tijd) {
  return '${tijd.hour.toString().padLeft(2, '0')}:'
      '${tijd.minute.toString().padLeft(2, '0')}';
}

String _korteDatum(DateTime datum) {
  return '${datum.day.toString().padLeft(2, '0')}/'
      '${datum.month.toString().padLeft(2, '0')}/${datum.year}';
}

String _volledigeDatum(DateTime datum) {
  const dagen = [
    'maandag',
    'dinsdag',
    'woensdag',
    'donderdag',
    'vrijdag',
    'zaterdag',
    'zondag',
  ];
  const maanden = [
    'januari',
    'februari',
    'maart',
    'april',
    'mei',
    'juni',
    'juli',
    'augustus',
    'september',
    'oktober',
    'november',
    'december',
  ];
  return '${dagen[datum.weekday - 1]} ${datum.day} '
      '${maanden[datum.month - 1]} ${datum.year}';
}

String _maandNaam(DateTime datum) {
  const maanden = [
    'Januari',
    'Februari',
    'Maart',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Augustus',
    'September',
    'Oktober',
    'November',
    'December',
  ];
  return '${maanden[datum.month - 1]} ${datum.year}';
}
