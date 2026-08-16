// THIMACO-CONTROLE: TECHNISCHE-PRIJS-ALLEEN-ZELFGEMAAKTE-KEUZES-20260815
// THIMACO-CONTROLE: CENTRALE-TECHNISCHE-KEUZEPRIJZEN-UNUSED-FIELDS-FIX-20260815
// THIMACO-CONTROLE: CENTRALE-TECHNISCHE-KEUZEPRIJZEN-PAGINA-20260815
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../helpers/app_storage.dart';
import '../../../helpers/offerte/prijzen/offerte_artikel_prijs_data_model.dart';
import '../../../helpers/offerte/prijzen/offerte_artikel_prijs_koppeling_service.dart';
import '../../../helpers/offerte/prijzen/offerte_technische_keuze_laad_helper.dart';
import '../../../helpers/offerte/prijzen/offerte_technische_keuze_overeenkomst_helper.dart';
import '../../../helpers/offerte/prijzen/offerte_technische_keuze_prijs_model.dart';
import '../../../helpers/offerte/prijzen/offerte_technische_keuze_ref.dart';

class OffertePrijsTechnischeKeuzesPagina extends StatefulWidget {
  const OffertePrijsTechnischeKeuzesPagina({super.key});

  @override
  State<OffertePrijsTechnischeKeuzesPagina> createState() {
    return _OffertePrijsTechnischeKeuzesPaginaState();
  }
}

class _OffertePrijsTechnischeKeuzesPaginaState
    extends State<OffertePrijsTechnischeKeuzesPagina> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _achtergrond = Color(0xFFF7F8FA);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const List<String> _eenheden = <String>[
    'st',
    'uur',
    'L/M',
    'KM',
    'm²',
    '1 x B',
    '1 x H',
    '2 x B',
    '2 x H',
    '2 x H en 1 x B',
    '1 x H en 2 x B',
    'rondom',
    'oppervlakte',
  ];

  bool _laden = true;
  bool _opslaan = false;
  String? _foutmelding;
  String _zoekterm = '';

  List<_CentraleTechnischeKeuze> _keuzes = const <_CentraleTechnischeKeuze>[];
  Map<String, OfferteTechnischeKeuzePrijsModel> _prijzen =
      <String, OfferteTechnischeKeuzePrijsModel>{};

  @override
  void initState() {
    super.initState();
    _laad();
  }

  Future<void> _laad() async {
    setState(() {
      _laden = true;
      _foutmelding = null;
    });

    try {
      final opgeslagen = await AppStorage.laadOfferteTechnischeKeuzePrijzen();
      final prijzen = <String, OfferteTechnischeKeuzePrijsModel>{
        for (final prijs in opgeslagen) prijs.id: prijs,
      };

      final perSleutel = <String, _CentraleTechnischeKeuzeAccumulator>{};

      final technischeKoppelingen = OfferteArtikelPrijsKoppelingService
          .alleKoppelingen
          .where((koppeling) => koppeling.ondersteuntTechnischeKeuzeprijzen);

      for (final koppeling in technischeKoppelingen) {
        // BELANGRIJK:
        // Alleen technische keuzes die de gebruiker werkelijk via
        // "Nieuwe technische keuze" in een opmeetfiche heeft aangemaakt,
        // komen in deze centrale prijslijst.
        //
        // De opmeetfiche bewaart die zelfgemaakte keuzemenu's reeds centraal
        // per formulierType in AppStorage. We lezen dus UITSLUITEND die opslag
        // en voegen geen ingebouwde Velux/screen/rolluik/... keuzes meer toe.
        final menus = await AppStorage.laadOpmetingRaamKeuzemenusVoorFormulier(
          koppeling.formulierType,
        );
        if (menus.isEmpty) {
          continue;
        }

        final keuzes = OfferteTechnischeKeuzeLaadHelper.bouwUitKeuzemenus(
          formulierType: koppeling.formulierType,
          menus: menus,
        );

        for (final keuze in keuzes) {
          final sleutel =
              OfferteTechnischeKeuzeOvereenkomstHelper.exacteSleutelTussenArtikeltypesVan(
                keuze,
              );
          if (sleutel.isEmpty) {
            continue;
          }

          final bestaand = perSleutel[sleutel];
          if (bestaand == null) {
            perSleutel[sleutel] = _CentraleTechnischeKeuzeAccumulator(
              sleutel: sleutel,
              keuze: keuze,
              formulierNamen: <String>{koppeling.formulierNaam},
            );
          } else {
            bestaand.formulierNamen.add(koppeling.formulierNaam);
            bestaand.keuze = _besteMomentopname(bestaand.keuze, keuze);
          }
        }
      }

      final keuzes =
          perSleutel.values
              .map(
                (item) => _CentraleTechnischeKeuze(
                  sleutel: item.sleutel,
                  keuze: item.keuze,
                  formulierNamen: item.formulierNamen.toList(growable: false)
                    ..sort(),
                ),
              )
              .toList(growable: true)
            ..sort((eerste, tweede) {
              final menu = eerste.menuTitel.toLowerCase().compareTo(
                tweede.menuTitel.toLowerCase(),
              );
              if (menu != 0) {
                return menu;
              }
              final submenu = eerste.submenuTitel.toLowerCase().compareTo(
                tweede.submenuTitel.toLowerCase(),
              );
              if (submenu != 0) {
                return submenu;
              }
              return eerste.keuzeTitel.toLowerCase().compareTo(
                tweede.keuzeTitel.toLowerCase(),
              );
            });

      final beschikbareSleutels = perSleutel.keys.toSet();
      final opgeschoondePrijzen = <String, OfferteTechnischeKeuzePrijsModel>{
        for (final entry in prijzen.entries)
          if (beschikbareSleutels.contains(entry.key)) entry.key: entry.value,
      };

      // Eventuele eerder foutief aangemaakte prijsregels voor ingebouwde
      // programma-keuzes worden éénmalig verwijderd. Een technische prijs mag
      // alleen bestaan zolang de bijhorende zelfgemaakte technische keuze nog
      // in de centrale keuzemenu-opslag bestaat.
      if (opgeschoondePrijzen.length != prijzen.length) {
        await AppStorage.bewaarOfferteTechnischeKeuzePrijzen(
          opgeschoondePrijzen.values.toList(growable: false),
        );
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _prijzen = opgeschoondePrijzen;
        _keuzes = keuzes;
        _laden = false;
      });
    } catch (fout) {
      if (!mounted) {
        return;
      }
      setState(() {
        _laden = false;
        _foutmelding = 'Technische keuzes konden niet worden geladen: $fout';
      });
    }
  }

  static OfferteTechnischeKeuzeRef _besteMomentopname(
    OfferteTechnischeKeuzeRef eerste,
    OfferteTechnischeKeuzeRef tweede,
  ) {
    final eersteScore =
        (eerste.hoeUitschrijvenMomentopname.trim().isNotEmpty ? 4 : 0) +
        (eerste.keuzeTitelMomentopname.trim().isNotEmpty ? 2 : 0) +
        (eerste.submenuTitelMomentopname.trim().isNotEmpty ? 1 : 0);
    final tweedeScore =
        (tweede.hoeUitschrijvenMomentopname.trim().isNotEmpty ? 4 : 0) +
        (tweede.keuzeTitelMomentopname.trim().isNotEmpty ? 2 : 0) +
        (tweede.submenuTitelMomentopname.trim().isNotEmpty ? 1 : 0);
    return tweedeScore > eersteScore ? tweede : eerste;
  }

  List<_CentraleTechnischeKeuze> get _zichtbareKeuzes {
    final zoek = _zoekterm.trim().toLowerCase();
    if (zoek.isEmpty) {
      return _keuzes;
    }

    return _keuzes
        .where((item) {
          final tekst = <String>[
            item.menuTitel,
            item.submenuTitel,
            item.keuzeTitel,
            item.uitschrijftekst,
            ...item.formulierNamen,
          ].join(' ').toLowerCase();
          return tekst.contains(zoek);
        })
        .toList(growable: false);
  }

  OfferteTechnischeKeuzePrijsModel _prijsVoor(_CentraleTechnischeKeuze item) {
    final bestaand = _prijzen[item.sleutel];
    if (bestaand != null) {
      return bestaand.copyWith(technischeKeuze: item.keuze);
    }

    return OfferteTechnischeKeuzePrijsModel(
      id: item.sleutel,
      technischeKeuze: item.keuze,
      type: OffertePrijsPerPositieType.verkoop,
      eenheid: 'st',
      offerteWeergave: OffertePrijsPerPositieWeergave.uit,
    );
  }

  Future<void> _bewaarPrijs(
    _CentraleTechnischeKeuze item,
    OfferteTechnischeKeuzePrijsModel prijs,
  ) async {
    final bijgewerkt = prijs
        .copyWith(id: item.sleutel, technischeKeuze: item.keuze)
        .metWijzigingsDatum();

    setState(() {
      _prijzen[item.sleutel] = bijgewerkt;
      _opslaan = true;
    });

    try {
      await AppStorage.bewaarOfferteTechnischeKeuzePrijzen(
        _prijzen.values.toList(growable: false),
      );
    } finally {
      if (mounted) {
        setState(() => _opslaan = false);
      }
    }
  }

  Future<void> _wisPrijs(_CentraleTechnischeKeuze item) async {
    if (!_prijzen.containsKey(item.sleutel)) {
      return;
    }

    setState(() {
      _prijzen.remove(item.sleutel);
      _opslaan = true;
    });

    try {
      await AppStorage.bewaarOfferteTechnischeKeuzePrijzen(
        _prijzen.values.toList(growable: false),
      );
    } finally {
      if (mounted) {
        setState(() => _opslaan = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final zichtbareKeuzes = _zichtbareKeuzes;
    final aantalGeprijsd = _keuzes.where((item) {
      return _prijzen[item.sleutel]?.heeftPrijs == true;
    }).length;

    return Scaffold(
      backgroundColor: _achtergrond,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _tekstDonker,
        elevation: 0,
        title: const Text(
          'Prijs bij technische keuzes',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: <Widget>[
          if (_opslaan)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: _laden
          ? const Center(child: CircularProgressIndicator())
          : _foutmelding != null
          ? _FoutKaart(melding: _foutmelding!, onOpnieuw: _laad)
          : Align(
              alignment: Alignment.topLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _lichtGroen,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCDE9D5)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Icon(
                            Icons.tune_rounded,
                            color: _groen,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${_keuzes.length} zelf aangemaakte technische keuzes · '
                              '$aantalGeprijsd met prijs. Iedere technische keuze die '
                              'u via “Nieuwe technische keuze” in een opmeetfiche '
                              'aanmaakt, verschijnt automatisch in deze centrale lijst. '
                              'Dezelfde keuze staat hier maar één keer, ook wanneer ze '
                              'in meerdere opmeetfiches wordt gebruikt. Uit / Tekst / € '
                              'bepaalt alleen de zichtbaarheid op de klantofferte.',
                              style: const TextStyle(
                                color: _tekstDonker,
                                fontSize: 12,
                                height: 1.4,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: (waarde) {
                        setState(() => _zoekterm = waarde);
                      },
                      decoration: InputDecoration(
                        hintText: 'Zoek technische keuze…',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _zoekterm.trim().isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  setState(() => _zoekterm = '');
                                },
                                icon: const Icon(Icons.close_rounded),
                              ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: _rand),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: _rand),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: _groen,
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (zichtbareKeuzes.isEmpty)
                      const _LegeKaart()
                    else
                      ...zichtbareKeuzes.map((item) {
                        final prijs = _prijsVoor(item);
                        return Padding(
                          key: ValueKey<String>(item.sleutel),
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _TechnischePrijsKaart(
                            item: item,
                            prijs: prijs,
                            eenheden: _eenheden,
                            heeftOpgeslagenPrijs: _prijzen.containsKey(
                              item.sleutel,
                            ),
                            onGewijzigd: (gewijzigd) {
                              _bewaarPrijs(item, gewijzigd);
                            },
                            onWissen: () => _wisPrijs(item),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
    );
  }
}

class _CentraleTechnischeKeuzeAccumulator {
  _CentraleTechnischeKeuzeAccumulator({
    required this.sleutel,
    required this.keuze,
    required this.formulierNamen,
  });

  final String sleutel;
  OfferteTechnischeKeuzeRef keuze;
  final Set<String> formulierNamen;
}

class _CentraleTechnischeKeuze {
  const _CentraleTechnischeKeuze({
    required this.sleutel,
    required this.keuze,
    required this.formulierNamen,
  });

  final String sleutel;
  final OfferteTechnischeKeuzeRef keuze;
  final List<String> formulierNamen;

  String get menuTitel => keuze.menuTitelMomentopname.trim();
  String get submenuTitel => keuze.submenuTitelMomentopname.trim();

  String get keuzeTitel {
    final titel = keuze.keuzeTitelMomentopname.trim();
    if (titel.isNotEmpty) {
      return titel;
    }
    return keuze.hoeUitschrijven.trim();
  }

  String get uitschrijftekst => keuze.hoeUitschrijven.trim();

  String get pad {
    return <String>[
      menuTitel,
      submenuTitel,
    ].where((deel) => deel.isNotEmpty).join(' · ');
  }

  String get formulierLabel => formulierNamen.join(', ');
}

class _TechnischePrijsKaart extends StatelessWidget {
  const _TechnischePrijsKaart({
    required this.item,
    required this.prijs,
    required this.eenheden,
    required this.heeftOpgeslagenPrijs,
    required this.onGewijzigd,
    required this.onWissen,
  });

  final _CentraleTechnischeKeuze item;
  final OfferteTechnischeKeuzePrijsModel prijs;
  final List<String> eenheden;
  final bool heeftOpgeslagenPrijs;
  final ValueChanged<OfferteTechnischeKeuzePrijsModel> onGewijzigd;
  final VoidCallback onWissen;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _lichtGroen = Color(0xFFE7F6EC);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstDonker = Color(0xFF111827);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  List<String> get _eenhedenVoorDropdown {
    final huidige = prijs.eenheid.trim();
    if (huidige.isEmpty || eenheden.contains(huidige)) {
      return eenheden;
    }
    return <String>[huidige, ...eenheden];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: prijs.heeftPrijs ? const Color(0xFFCDE9D5) : _rand,
          width: prijs.heeftPrijs ? 1.1 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: prijs.heeftPrijs
                      ? _lichtGroen
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  prijs.heeftPrijs ? Icons.euro_rounded : Icons.tune_rounded,
                  color: prijs.heeftPrijs ? _groen : _tekstGrijs,
                  size: 17,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.keuzeTitel,
                      style: const TextStyle(
                        color: _tekstDonker,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (item.pad.isNotEmpty)
                      Text(
                        item.pad,
                        style: const TextStyle(
                          color: _tekstGrijs,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    Text(
                      'Gebruikt in: ${item.formulierLabel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _tekstGrijs,
                        fontSize: 9.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (heeftOpgeslagenPrijs)
                IconButton(
                  onPressed: onWissen,
                  tooltip: 'Prijsinstelling wissen',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFB91C1C),
                    size: 18,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 58,
                height: 40,
                child: _CompactKeuzeMenu<OffertePrijsPerPositieType>(
                  waarde: prijs.type,
                  waarden: OffertePrijsPerPositieType.values,
                  tekstVoor: (waarde) => waarde.label,
                  onGekozen: (waarde) {
                    onGewijzigd(prijs.copyWith(type: waarde));
                  },
                ),
              ),
              SizedBox(
                width: 150,
                height: 40,
                child: _CompactKeuzeMenu<String>(
                  waarde: prijs.eenheid.trim().isEmpty ? null : prijs.eenheid,
                  waarden: _eenhedenVoorDropdown,
                  tekstVoor: (waarde) => waarde,
                  hintText: 'Eenheid',
                  onGekozen: (waarde) {
                    onGewijzigd(prijs.copyWith(eenheid: waarde));
                  },
                ),
              ),
              SizedBox(
                width: 120,
                height: 40,
                child: _NummerInvoer(
                  sleutel: 'techn_prijs_${item.sleutel}',
                  beginWaarde: prijs.veiligePrijsExclBtw,
                  hintText: 'Prijs',
                  prefixText: '€ ',
                  maxGeheleCijfers: 6,
                  onBewaren: (waarde) {
                    onGewijzigd(prijs.copyWith(prijsExclBtw: waarde));
                  },
                ),
              ),
              SizedBox(
                width: 88,
                height: 40,
                child: prijs.isAankoop
                    ? _NummerInvoer(
                        sleutel: 'techn_winst_${item.sleutel}',
                        beginWaarde: prijs.veiligWinstPercentage,
                        hintText: '%',
                        suffixText: '%',
                        maxGeheleCijfers: 2,
                        onBewaren: (waarde) {
                          onGewijzigd(prijs.copyWith(winstPercentage: waarde));
                        },
                      )
                    : const _WaardeVak(tekst: '%'),
              ),
              SizedBox(
                width: 96,
                height: 40,
                child: _CompactKeuzeMenu<OffertePrijsPerPositieWeergave>(
                  waarde: prijs.offerteWeergave,
                  waarden: OffertePrijsPerPositieWeergave.values,
                  tekstVoor: (waarde) => waarde.label,
                  onGekozen: (waarde) {
                    onGewijzigd(prijs.copyWith(offerteWeergave: waarde));
                  },
                ),
              ),
              if (prijs.heeftPrijs)
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _lichtGroen,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCDE9D5)),
                  ),
                  child: Text(
                    prijs.isAankoop
                        ? 'Verkoop € ${prijs.verkoopPrijsPerEenheidExclBtw.toStringAsFixed(2).replaceAll('.', ',')}'
                        : 'Prijs ingesteld',
                    style: const TextStyle(
                      color: _groen,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactKeuzeMenu<T> extends StatelessWidget {
  const _CompactKeuzeMenu({
    required this.waarde,
    required this.waarden,
    required this.tekstVoor,
    required this.onGekozen,
    this.hintText = '',
  });

  final T? waarde;
  final List<T> waarden;
  final String Function(T waarde) tekstVoor;
  final ValueChanged<T> onGekozen;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final huidigeTekst = waarde == null ? '' : tekstVoor(waarde as T);
    return PopupMenuButton<T>(
      tooltip: hintText,
      position: PopupMenuPosition.under,
      padding: EdgeInsets.zero,
      onSelected: onGekozen,
      itemBuilder: (context) {
        return waarden
            .map(
              (item) => PopupMenuItem<T>(
                value: item,
                height: 38,
                child: Text(
                  tekstVoor(item),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: item == waarde
                        ? FontWeight.w900
                        : FontWeight.w600,
                  ),
                ),
              ),
            )
            .toList(growable: false);
      },
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                huidigeTekst.isEmpty ? hintText : huidigeTekst,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: huidigeTekst.isEmpty
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF111827),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_drop_down_rounded,
              size: 16,
              color: Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }
}

class _NummerInvoer extends StatefulWidget {
  const _NummerInvoer({
    required this.sleutel,
    required this.beginWaarde,
    required this.hintText,
    required this.onBewaren,
    required this.maxGeheleCijfers,
    this.prefixText,
    this.suffixText,
  });

  final String sleutel;
  final double beginWaarde;
  final String hintText;
  final ValueChanged<double> onBewaren;
  final int maxGeheleCijfers;
  final String? prefixText;
  final String? suffixText;

  @override
  State<_NummerInvoer> createState() => _NummerInvoerState();
}

class _NummerInvoerState extends State<_NummerInvoer> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late String _laatstBewaard;

  String _tekstVoor(double waarde) {
    if (!waarde.isFinite || waarde <= 0.0) {
      return '';
    }
    var tekst = waarde.toStringAsFixed(2).replaceAll('.', ',');
    tekst = tekst.replaceFirst(RegExp(r'0+$'), '');
    return tekst.replaceFirst(RegExp(r',$'), '');
  }

  @override
  void initState() {
    super.initState();
    _laatstBewaard = _tekstVoor(widget.beginWaarde);
    _controller = TextEditingController(text: _laatstBewaard);
    _focusNode = FocusNode()..addListener(_focusGewijzigd);
  }

  @override
  void didUpdateWidget(covariant _NummerInvoer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nieuweTekst = _tekstVoor(widget.beginWaarde);
    if (_focusNode.hasFocus || nieuweTekst == _controller.text) {
      return;
    }
    _laatstBewaard = nieuweTekst;
    _controller.text = nieuweTekst;
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_focusGewijzigd)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _focusGewijzigd() {
    if (!_focusNode.hasFocus) {
      _bewaar();
    }
  }

  void _bewaar() {
    final tekst = _controller.text.trim();
    if (tekst == _laatstBewaard) {
      return;
    }
    _laatstBewaard = tekst;
    widget.onBewaren(double.tryParse(tekst.replaceAll(',', '.')) ?? 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: <TextInputFormatter>[
        TextInputFormatter.withFunction((oud, nieuw) {
          final patroon = RegExp(
            r'^\d{0,' +
                widget.maxGeheleCijfers.toString() +
                r'}([,.]\d{0,2})?$',
          );
          return patroon.hasMatch(nieuw.text) ? nieuw : oud;
        }),
      ],
      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixText: widget.prefixText,
        suffixText: widget.suffixText,
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF0B7A3B), width: 1.2),
        ),
      ),
      onSubmitted: (_) => _bewaar(),
    );
  }
}

class _WaardeVak extends StatelessWidget {
  const _WaardeVak({required this.tekst});

  final String tekst;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        tekst,
        style: const TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FoutKaart extends StatelessWidget {
  const _FoutKaart({required this.melding, required this.onOpnieuw});

  final String melding;
  final VoidCallback onOpnieuw;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFCA5A5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(melding, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: onOpnieuw,
              child: const Text('Opnieuw laden'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegeKaart extends StatelessWidget {
  const _LegeKaart();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Text(
        'Nog geen technische keuzes aangemaakt. Maak eerst in een '
        'opmeetfiche via “Nieuwe technische keuze” een technische keuze. '
        'Daarna verschijnt ze hier automatisch zodat u prijs, eenheid, '
        'eventuele winstmarge en offerteweergave kunt instellen.',
        style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
      ),
    );
  }
}
