// THIMACO-CONTROLE: NOTITIES-BUREAU-GEEN-VOLLEDIGE-REBUILD-PER-TOETS-20260914
// THIMACO-CONTROLE: NOTITIES-BUREAU-DEBOUNCE-VEILIG-BEWAREN-20260914
import 'dart:async';

import 'package:flutter/material.dart';

import '/helpers/notities/notitie_actie_model.dart';
import '/helpers/notities/notitie_dag_container.dart';
import '/helpers/notities/notitie_helper.dart';
import '/helpers/notities/notitie_model.dart';
import '/helpers/notities/notitie_repository.dart';
import '/helpers/sync/sync_navigatie_helper.dart';

class NotitiesBureauPagina extends StatefulWidget {
  const NotitiesBureauPagina({super.key});

  @override
  State<NotitiesBureauPagina> createState() => _NotitiesBureauPaginaState();
}

class _NotitiesBureauPaginaState extends State<NotitiesBureauPagina>
    with WidgetsBindingObserver {
  final NotitieRepository _repository = NotitieRepository();

  static const Duration _bewaarVertraging = Duration(milliseconds: 1000);

  List<NotitieModel> _notities = [];
  List<NotitieActieModel> _acties = [];

  Timer? _bewaarTimer;
  bool _heeftOnopgeslagenWijzigingen = false;
  Future<void>? _lopendeBewaring;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _laad();
  }

  @override
  void dispose() {
    _bewaarTimer?.cancel();
    _bewaarTimer = null;

    if (_heeftOnopgeslagenWijzigingen) {
      /*
       * Dispose kan niet awaiten. NotitieRepository maakt onmiddellijk
       * een snapshot en zet deze in de seriële bewaarrij, zodat de laatste
       * wijziging toch nog veilig kan worden weggeschreven.
       */
      unawaited(_repository.bewaarNotities(_notities));
    }

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      unawaited(_bewaarNu());
    }
  }

  Future<void> _laad() async {
    final notities = await _repository.laadNotities();
    final acties = await _repository.laadActies();

    if (!mounted) return;

    setState(() {
      _notities = notities;
      _acties = acties;
    });
  }

  void _planBewaren({
    bool direct = false,
  }) {
    _heeftOnopgeslagenWijzigingen = true;

    _bewaarTimer?.cancel();
    _bewaarTimer = null;

    if (direct) {
      unawaited(_bewaarNu());
      return;
    }

    /*
     * Tijdens typen niet langer na iedere letter een volledige opslag starten.
     * Pas na 1 seconde zonder nieuwe wijziging wordt de actuele toestand bewaard.
     */
    _bewaarTimer = Timer(_bewaarVertraging, () {
      _bewaarTimer = null;
      unawaited(_bewaarNu());
    });
  }

  Future<void> _bewaarNu() async {
    _bewaarTimer?.cancel();
    _bewaarTimer = null;

    final reedsBezig = _lopendeBewaring;
    if (reedsBezig != null) {
      await reedsBezig;

      if (_heeftOnopgeslagenWijzigingen) {
        await _bewaarNu();
      }
      return;
    }

    if (!_heeftOnopgeslagenWijzigingen) {
      return;
    }

    _heeftOnopgeslagenWijzigingen = false;

    late final Future<void> bewaring;

    bewaring = _repository.bewaarNotities(_notities).whenComplete(() {
      if (identical(_lopendeBewaring, bewaring)) {
        _lopendeBewaring = null;
      }
    });

    _lopendeBewaring = bewaring;

    try {
      await bewaring;
    } catch (fout, stackTrace) {
      /*
       * Bij een opslagfout blijft de wijziging gemarkeerd als niet veilig
       * bewaard. Een volgende wijziging, lifecycle-flush of Home-knop probeert
       * opnieuw.
       */
      _heeftOnopgeslagenWijzigingen = true;
      debugPrint('Notities Bureau bewaren mislukt: $fout');
      debugPrintStack(stackTrace: stackTrace);
      return;
    }

    /*
     * Als tijdens het bewaren verder werd getypt, is de flag intussen opnieuw
     * true geworden. Schrijf dan meteen nog één actuele snapshot weg.
     */
    if (_heeftOnopgeslagenWijzigingen) {
      await _bewaarNu();
    }
  }

  Future<void> _notitieToevoegen() async {
    final vandaagKey = NotitieHelper.datumKey(DateTime.now());

    setState(() {
      _notities.add(
        NotitieModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          datumKey: vandaagKey,
          titel: '',
        ),
      );
    });

    _planBewaren();
  }

  void _notitieGewijzigd(NotitieModel notitie) {
    /*
     * Geen setState van de volledige pagina bij iedere letter, checkbox,
     * actie- of detailwijziging. De betrokken regel/dag vernieuwt zichzelf.
     * Deze callback plant uitsluitend de opslag.
     */
    _planBewaren();
  }

  Future<void> _notitieVerwijderd(NotitieModel notitie) async {
    setState(() {
      _notities.removeWhere((n) => n.id == notitie.id);
    });

    _planBewaren();
  }

  Future<void> _notitieVerplaatst(
    NotitieModel notitie,
    String nieuweDatumKey,
  ) async {
    setState(() {
      notitie.datumKey = nieuweDatumKey;
      notitie.gewijzigdOp = DateTime.now();
    });

    _planBewaren();
  }

  List<String> get _datumKeys {
    final keys = _notities
        .map((n) => n.datumKey)
        .where((key) => key.isNotEmpty)
        .toSet()
        .toList();

    keys.sort((a, b) => b.compareTo(a));

    final vandaag = NotitieHelper.datumKey(DateTime.now());

    if (!keys.contains(vandaag)) {
      keys.insert(0, vandaag);
    }

    return keys;
  }

  List<NotitieModel> _notitiesVoorDag(String datumKey) {
    return _notities.where((n) => n.datumKey == datumKey).toList();
  }

  String _titelVoorLegeDag(String datumKey) {
    final vandaag = NotitieHelper.datumKey(DateTime.now());

    if (datumKey == vandaag) return 'Vandaag';

    final delen = datumKey.split('-');
    if (delen.length != 3) return datumKey;

    return '${delen[2]}/${delen[1]}/${delen[0]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B7A3B),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.home, size: 24),
          onPressed: () async {
            /*
             * De laatste getypte tekst moet lokaal opgeslagen zijn vóór de
             * pagina wordt verlaten.
             */
            await _bewaarNu();

            if (!context.mounted) return;

            if (_heeftOnopgeslagenWijzigingen) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'De laatste notitiewijziging kon niet veilig worden bewaard.',
                  ),
                ),
              );
              return;
            }

            await SyncNavigatieHelper.terugNaarHomeMetDownload(
              context: context,
            );
          },
        ),
        title: GestureDetector(
          onTap: () async {
            /*
             * Ook vóór een handmatige upload eerst de laatste lokale tekst
             * veilig wegschrijven.
             */
            await _bewaarNu();

            if (!context.mounted || _heeftOnopgeslagenWijzigingen) return;

            await SyncNavigatieHelper.uploadVanafPagina(context: context);
          },
          child: const Text(
            'Notities Bureau',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _notitieToevoegen,
            icon: const Icon(Icons.add, size: 28),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 18),
        itemCount: _datumKeys.length,
        itemBuilder: (context, index) {
          final datumKey = _datumKeys[index];
          final lijst = _notitiesVoorDag(datumKey);

          if (lijst.isEmpty) {
            return DragTarget<NotitieModel>(
              onWillAcceptWithDetails: (_) => true,
              onAcceptWithDetails: (details) {
                _notitieVerplaatst(details.data, datumKey);
              },
              builder: (context, candidateData, rejectedData) {
                final isHover = candidateData.isNotEmpty;

                return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isHover
                            ? const Color(0xFF0B7A3B)
                            : Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _titelVoorLegeDag(datumKey),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          '0 open · 0 afgewerkt',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return NotitieDagContainer(
            datumKey: datumKey,
            notities: lijst,
            acties: _acties,
            onNotitieChanged: _notitieGewijzigd,
            onNotitieVerplaatst: _notitieVerplaatst,
            onNotitieVerwijderd: _notitieVerwijderd,
          );
        },
      ),
    );
  }
}
