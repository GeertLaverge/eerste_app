import 'dart:async';

import 'package:flutter/material.dart';

import '../helpers/notities/notitie_actie_model.dart';
import '../helpers/notities/notitie_dag_container.dart';
import '../helpers/notities/notitie_helper.dart';
import '../helpers/notities/notitie_model.dart';
import '../helpers/notities/notitie_repository.dart';
import '../helpers/sync/sync_navigatie_helper.dart';

class NotitiesBureauPagina extends StatefulWidget {
  const NotitiesBureauPagina({super.key});

  @override
  State<NotitiesBureauPagina> createState() {
    return _NotitiesBureauPaginaState();
  }
}

class _NotitiesBureauPaginaState extends State<NotitiesBureauPagina> {
  final NotitieRepository _repository = NotitieRepository();

  List<NotitieModel> _notities = [];
  List<NotitieActieModel> _acties = [];

  int _laatsteVerwerkteDownloadVersie = 0;

  bool _laden = false;
  bool _opnieuwLadenGevraagd = false;

  @override
  void initState() {
    super.initState();

    _laatsteVerwerkteDownloadVersie = SyncNavigatieHelper.downloadVersie.value;

    SyncNavigatieHelper.downloadVersie.addListener(_verwerkAchtergrondDownload);

    unawaited(_laad());
  }

  @override
  void dispose() {
    SyncNavigatieHelper.downloadVersie.removeListener(
      _verwerkAchtergrondDownload,
    );

    super.dispose();
  }

  void _verwerkAchtergrondDownload() {
    final nieuweVersie = SyncNavigatieHelper.downloadVersie.value;

    if (nieuweVersie <= _laatsteVerwerkteDownloadVersie) {
      return;
    }

    _laatsteVerwerkteDownloadVersie = nieuweVersie;

    unawaited(_laad());
  }

  Future<void> _laad() async {
    if (_laden) {
      /*
       * Wanneer een download klaar is terwijl er reeds
       * geladen wordt, laden we onmiddellijk daarna
       * nog één keer opnieuw.
       */
      _opnieuwLadenGevraagd = true;
      return;
    }

    _laden = true;

    try {
      do {
        _opnieuwLadenGevraagd = false;

        final notities = await _repository.laadNotities();

        final acties = await _repository.laadActies();

        if (!mounted) {
          return;
        }

        setState(() {
          _notities = notities;
          _acties = acties;

          if (_acties.isEmpty) {
            _acties = _standaardActies();
          }
        });
      } while (_opnieuwLadenGevraagd && mounted);
    } finally {
      _laden = false;

      /*
       * Extra beveiliging wanneer net tussen de laatste
       * controle en finally opnieuw laden gevraagd werd.
       */
      if (_opnieuwLadenGevraagd && mounted) {
        _opnieuwLadenGevraagd = false;

        unawaited(_laad());
      }
    }
  }

  List<NotitieActieModel> _standaardActies() {
    return [
      NotitieActieModel(
        id: 'offerte',
        naam: 'Offerte',
        kleurWaarde: 0xFFF97316,
      ),
      NotitieActieModel(id: 'order', naam: 'Order', kleurWaarde: 0xFF2563EB),
      NotitieActieModel(id: 'bellen', naam: 'Bellen', kleurWaarde: 0xFFEAB308),
      NotitieActieModel(
        id: 'afhalen',
        naam: 'Afhalen',
        kleurWaarde: 0xFF0B7A3B,
      ),
      NotitieActieModel(id: 'bureau', naam: 'Bureau', kleurWaarde: 0xFF9333EA),
    ];
  }

  Future<void> _bewaar() async {
    await _repository.bewaarNotities(_notities);
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

    await _bewaar();
  }

  Future<void> _notitieGewijzigd(NotitieModel notitie) async {
    if (!mounted) {
      return;
    }

    setState(() {});

    await _bewaar();
  }

  Future<void> _notitieVerwijderd(NotitieModel notitie) async {
    setState(() {
      _notities.removeWhere((item) => item.id == notitie.id);
    });

    await _bewaar();
  }

  Future<void> _notitieVerplaatst(
    NotitieModel notitie,
    String nieuweDatumKey,
  ) async {
    setState(() {
      notitie.datumKey = nieuweDatumKey;
      notitie.gewijzigdOp = DateTime.now();
    });

    await _bewaar();
  }

  List<String> get _datumKeys {
    final keys = _notities
        .map((notitie) => notitie.datumKey)
        .where((key) => key.isNotEmpty)
        .toSet()
        .toList();

    keys.sort((eerste, tweede) {
      return tweede.compareTo(eerste);
    });

    final vandaag = NotitieHelper.datumKey(DateTime.now());

    if (!keys.contains(vandaag)) {
      keys.insert(0, vandaag);
    }

    return keys;
  }

  List<NotitieModel> _notitiesVoorDag(String datumKey) {
    return _notities.where((notitie) => notitie.datumKey == datumKey).toList();
  }

  String _titelVoorLegeDag(String datumKey) {
    final vandaag = NotitieHelper.datumKey(DateTime.now());

    if (datumKey == vandaag) {
      return 'Vandaag';
    }

    final delen = datumKey.split('-');

    if (delen.length != 3) {
      return datumKey;
    }

    return '${delen[2]}/${delen[1]}/${delen[0]}';
  }

  PreferredSizeWidget _bovenBalk() {
    return AppBar(
      backgroundColor: const Color(0xFF0B7A3B),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.home, size: 24),
        onPressed: () {
          /*
           * Home wordt onmiddellijk geopend.
           * De download start pas achterliggend.
           */
          unawaited(
            SyncNavigatieHelper.terugNaarHomeMetDownload(context: context),
          );
        },
      ),
      title: GestureDetector(
        onTap: () async {
          /*
           * Dit blijft een handmatige upload.
           * Hierbij mag de gebruiker de melding afwachten.
           */
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final datumKeys = _datumKeys;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: _bovenBalk(),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 18),
        itemCount: datumKeys.length,
        itemBuilder: (context, index) {
          final datumKey = datumKeys[index];

          final lijst = _notitiesVoorDag(datumKey);

          if (lijst.isEmpty) {
            return DragTarget<NotitieModel>(
              onWillAcceptWithDetails: (_) {
                return true;
              },
              onAcceptWithDetails: (details) {
                unawaited(_notitieVerplaatst(details.data, datumKey));
              },
              builder: (context, candidateData, rejectedData) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
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
