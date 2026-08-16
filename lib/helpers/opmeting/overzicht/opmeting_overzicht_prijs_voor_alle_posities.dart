// THIMACO-CONTROLE: PRIJS-VOOR-ALLE-POSITIES-DOELEN-OPGERUIMD-EN-GROEN-MENU-20260816
// THIMACO-CONTROLE: PRIJS-VOOR-ALLE-POSITIES-EEN-KEER-ONDERAAN-20260816
// THIMACO-CONTROLE: PRIJS-VOOR-ALLE-POSITIES-TOTAAL-OVER-GEKOZEN-FICHES-20260816
// THIMACO-CONTROLE: PRIJS-VERDEELD-OVER-NIET-IN-GEWONE-ALLE-POSITIES-EDITOR-20260815
// THIMACO-CONTROLE: PRIJS-VOOR-ALLE-POSITIES-FASE2-CURLY-BRACES-LINTFIX-20260815
// THIMACO-CONTROLE: PRIJS-VOOR-ALLE-POSITIES-FASE2-UI-EN-DOELSELECTIE-20260815
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_storage.dart';
import '../../offerte/prijzen/offerte_artikel_prijs_data_model.dart';
import '../../offerte/prijzen/offerte_prijs_verdeeld_over_service.dart';
import '../../offerte/prijzen/offerte_prijs_voor_alle_posities_regel_model.dart';
import '../../offerte/prijzen/offerte_prijs_voor_alle_posities_template_model.dart';

class OpmetingOverzichtPrijsDoelPositie {
  const OpmetingOverzichtPrijsDoelPositie({
    required this.id,
    required this.positieLabel,
    required this.artikelLabel,
    this.breedteMm = 0,
    this.hoogteMm = 0,
    this.teltMeeInHoofdofferte = true,
  });

  final String id;
  final String positieLabel;
  final String artikelLabel;
  final int breedteMm;
  final int hoogteMm;
  final bool teltMeeInHoofdofferte;

  String get label {
    final positie = positieLabel.trim();
    final artikel = artikelLabel.trim();
    if (positie.isEmpty) {
      return artikel;
    }
    if (artikel.isEmpty) {
      return positie;
    }
    return '$positie · $artikel';
  }
}

/// Projectbrede prijsregels die vanuit eender welke positie kunnen worden
/// aangemaakt en daarna op één, meerdere of alle offerteposities toegepast.
///
/// De regel zelf gebruikt exact hetzelfde eenvoudige A/V-prijsmodel als
/// "Prijs per positie". Alleen de doelposities zijn extra.
class OpmetingOverzichtPrijsVoorAllePositiesBlok extends StatelessWidget {
  const OpmetingOverzichtPrijsVoorAllePositiesBlok({
    super.key,
    required this.huidigePositieId,
    required this.breedteMm,
    required this.hoogteMm,
    required this.regels,
    required this.doelPosities,
    required this.onGewijzigd,
    this.toonAlleRegels = false,
  });

  final String huidigePositieId;
  final int breedteMm;
  final int hoogteMm;
  final List<OffertePrijsVoorAllePositiesRegelModel> regels;
  final List<OpmetingOverzichtPrijsDoelPositie> doelPosities;
  final ValueChanged<List<OffertePrijsVoorAllePositiesRegelModel>> onGewijzigd;

  /// In het projectoverzicht wordt dit blok één keer onder de laatste positie
  /// getoond. Daar moeten alle gewone projectregels zichtbaar zijn, ongeacht
  /// op welke doelpositie ze van toepassing zijn.
  final bool toonAlleRegels;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  static OffertePrijsVoorAllePositiesRegelModel? _gekopieerdeRegel;

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

  List<OffertePrijsVoorAllePositiesRegelModel> get _zichtbareRegels {
    final positieId = huidigePositieId.trim();

    final resultaat =
        regels
            .where((regel) {
              if (OffertePrijsVerdeeldOverService.isVerdeeldOverRegel(regel)) {
                return false;
              }
              if (toonAlleRegels) {
                return true;
              }
              return positieId.isNotEmpty && regel.isVanToepassingOp(positieId);
            })
            .toList(growable: true)
          ..sort((eerste, tweede) {
            final volgorde = eerste.volgorde.compareTo(tweede.volgorde);
            if (volgorde != 0) {
              return volgorde;
            }
            return eerste.id.compareTo(tweede.id);
          });
    return resultaat;
  }

  String _nieuwRegelId() {
    return 'allepos_${DateTime.now().microsecondsSinceEpoch}';
  }

  void _voegHandmatigeRegelToe() {
    final positieId = huidigePositieId.trim();
    if (positieId.isEmpty) {
      return;
    }

    final nieuweRegel = OffertePrijsVoorAllePositiesRegelModel(
      prijsregel: OffertePrijsPerPositieRegelModel(
        id: _nieuwRegelId(),
        omschrijving: '',
        type: OffertePrijsPerPositieType.verkoop,
        aantal: 0,
        eenheid: '',
        eenheidsPrijsExclBtw: 0,
        winstPercentage: 0,
        offerteWeergave: OffertePrijsPerPositieWeergave.uit,
      ),
      geselecteerdePositieIds: <String>{positieId},
      toepassenOpAllePosities: false,
      volgorde: regels.length,
    );

    onGewijzigd(<OffertePrijsVoorAllePositiesRegelModel>[
      ...regels,
      nieuweRegel,
    ]);
  }

  void _kopieerRegel(
    BuildContext context,
    OffertePrijsVoorAllePositiesRegelModel regel,
  ) {
    _gekopieerdeRegel = regel;
    final omschrijving = regel.omschrijving.trim();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          omschrijving.isEmpty
              ? 'Prijsregel voor alle posities gekopieerd.'
              : '“$omschrijving” gekopieerd.',
        ),
      ),
    );
  }

  void _plakGekopieerdeRegelToe(BuildContext context) {
    final bron = _gekopieerdeRegel;
    if (bron == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 2),
          content: Text('Kopieer eerst een prijsregel voor alle posities.'),
        ),
      );
      return;
    }

    final nieuwePrijsregel = bron.prijsregel.kopieMetNieuwId(_nieuwRegelId());
    final positieId = huidigePositieId.trim();
    final nieuweDoelen = bron.toepassenOpAllePosities
        ? bron.geselecteerdePositieIds
        : <String>{
            ...bron.geselecteerdePositieIds,
            if (positieId.isNotEmpty) positieId,
          };

    final nieuweRegel = bron.copyWith(
      prijsregel: nieuwePrijsregel,
      geselecteerdePositieIds: nieuweDoelen,
      volgorde: regels.length,
    );

    onGewijzigd(<OffertePrijsVoorAllePositiesRegelModel>[
      ...regels,
      nieuweRegel,
    ]);
  }

  void _vervangRegel(OffertePrijsVoorAllePositiesRegelModel gewijzigdeRegel) {
    onGewijzigd(
      regels
          .map(
            (regel) => regel.id == gewijzigdeRegel.id ? gewijzigdeRegel : regel,
          )
          .toList(growable: false),
    );
  }

  void _pasTemplateToeOpRegel(
    OffertePrijsVoorAllePositiesRegelModel regel,
    OffertePrijsVoorAllePositiesTemplateModel template,
  ) {
    final uitTemplate = template.maakProjectRegel(nieuwId: regel.id);
    final bron = regel.prijsregel;
    final templatePrijsregel = uitTemplate.prijsregel;

    final bijgewerktePrijsregel = templatePrijsregel.copyWith(
      aantal: bron.aantal > 0 ? bron.aantal : templatePrijsregel.aantal,
      eenheid: bron.eenheid.trim().isNotEmpty
          ? bron.eenheid
          : templatePrijsregel.eenheid,
      eenheidsPrijsExclBtw: bron.eenheidsPrijsExclBtw,
      offerteWeergave: bron.offerteWeergave,
    );

    _vervangRegel(regel.copyWith(prijsregel: bijgewerktePrijsregel));
  }

  Future<void> _verwijderRegel(
    BuildContext context,
    OffertePrijsVoorAllePositiesRegelModel regel,
  ) async {
    final bevestigd = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Prijsregel verwijderen?'),
          content: Text(
            regel.omschrijving.trim().isEmpty
                ? 'Deze prijsregel wordt uit de volledige offerte verwijderd.'
                : '“${regel.omschrijving.trim()}” wordt uit de volledige offerte verwijderd.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuleren'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Verwijderen'),
            ),
          ],
        );
      },
    );

    if (bevestigd != true) {
      return;
    }
    onGewijzigd(
      regels.where((item) => item.id != regel.id).toList(growable: false),
    );
  }

  Future<void> _kiesDoelPosities(
    BuildContext context,
    OffertePrijsVoorAllePositiesRegelModel regel,
  ) async {
    var alles = regel.toepassenOpAllePosities;
    final geldigeDoelIds = doelPosities
        .map((positie) => positie.id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();
    final gekozen = <String>{
      ...regel.geselecteerdePositieIds.where(geldigeDoelIds.contains),
    };

    final resultaat = await showDialog<_DoelPositieSelectie>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Prijs toepassen op',
                style: TextStyle(color: _groen, fontWeight: FontWeight.w900),
              ),
              content: SizedBox(
                width: 520,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 520),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      CheckboxListTile(
                        value: alles,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        activeColor: _groen,
                        title: const Text(
                          'Alle posities',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        subtitle: const Text(
                          'Ook posities die later aan deze offerte worden toegevoegd.',
                        ),
                        onChanged: (waarde) {
                          setDialogState(() {
                            alles = waarde ?? false;
                          });
                        },
                      ),
                      const Divider(height: 14, color: _rand),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: doelPosities.length,
                          itemBuilder: (context, index) {
                            final positie = doelPosities[index];
                            return CheckboxListTile(
                              value: alles || gekozen.contains(positie.id),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              activeColor: _groen,
                              title: Text(
                                positie.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              onChanged: alles
                                  ? null
                                  : (waarde) {
                                      setDialogState(() {
                                        if (waarde == true) {
                                          gekozen.add(positie.id);
                                        } else {
                                          gekozen.remove(positie.id);
                                        }
                                      });
                                    },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: _groen),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annuleren'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _groen,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: alles || gekozen.isNotEmpty
                      ? () {
                          Navigator.of(dialogContext).pop(
                            _DoelPositieSelectie(
                              allePosities: alles,
                              positieIds: alles
                                  ? const <String>{}
                                  : Set<String>.unmodifiable(gekozen),
                            ),
                          );
                        }
                      : null,
                  child: const Text('Toepassen'),
                ),
              ],
            );
          },
        );
      },
    );

    if (resultaat == null) {
      return;
    }
    _vervangRegel(
      regel.copyWith(
        toepassenOpAllePosities: resultaat.allePosities,
        geselecteerdePositieIds: resultaat.positieIds,
      ),
    );
  }

  String _doelSamenvatting(OffertePrijsVoorAllePositiesRegelModel regel) {
    if (regel.toepassenOpAllePosities) {
      return 'Alle posities';
    }
    final geldigeDoelIds = doelPosities
        .map((positie) => positie.id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();
    final aantal = regel.geselecteerdePositieIds
        .where(geldigeDoelIds.contains)
        .length;
    if (aantal == 0) {
      return 'Toepassen op...';
    }
    if (aantal == 1) {
      return '1 positie';
    }
    return '$aantal posities';
  }

  @override
  Widget build(BuildContext context) {
    final zichtbareRegels = _zichtbareRegels;

    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _rand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Prijs voor alle posities',
                  style: TextStyle(
                    color: _groen,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _voegHandmatigeRegelToe,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Regel'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _plakGekopieerdeRegelToe(context),
                tooltip: 'Gekopieerde regel plakken',
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.content_paste_rounded,
                  size: 17,
                  color: _groen,
                ),
              ),
            ],
          ),
          if (zichtbareRegels.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(2, 2, 2, 5),
              child: Text(
                'Nog geen regel voor alle posities op deze positie.',
                style: TextStyle(
                  color: _tekstGrijs,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            ...zichtbareRegels.map((regel) {
              return Padding(
                key: ValueKey<String>(regel.id),
                padding: const EdgeInsets.only(top: 7),
                child: _PrijsVoorAllePositiesRegelKaart(
                  regel: regel,
                  breedteMm: breedteMm,
                  hoogteMm: hoogteMm,
                  doelPosities: doelPosities,
                  eenheden: _eenheden,
                  doelSamenvatting: _doelSamenvatting(regel),
                  onGewijzigd: (prijsregel) {
                    _vervangRegel(regel.copyWith(prijsregel: prijsregel));
                  },
                  onTemplateGekozen: (template) {
                    _pasTemplateToeOpRegel(regel, template);
                  },
                  onDoelenKiezen: () => _kiesDoelPosities(context, regel),
                  onKopieren: () => _kopieerRegel(context, regel),
                  onVerwijderen: () => _verwijderRegel(context, regel),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _DoelPositieSelectie {
  const _DoelPositieSelectie({
    required this.allePosities,
    required this.positieIds,
  });

  final bool allePosities;
  final Set<String> positieIds;
}

class _PrijsVoorAllePositiesRegelKaart extends StatelessWidget {
  const _PrijsVoorAllePositiesRegelKaart({
    required this.regel,
    required this.breedteMm,
    required this.hoogteMm,
    required this.doelPosities,
    required this.eenheden,
    required this.doelSamenvatting,
    required this.onGewijzigd,
    required this.onTemplateGekozen,
    required this.onDoelenKiezen,
    required this.onKopieren,
    required this.onVerwijderen,
  });

  final OffertePrijsVoorAllePositiesRegelModel regel;
  final int breedteMm;
  final int hoogteMm;
  final List<OpmetingOverzichtPrijsDoelPositie> doelPosities;
  final List<String> eenheden;
  final String doelSamenvatting;
  final ValueChanged<OffertePrijsPerPositieRegelModel> onGewijzigd;
  final ValueChanged<OffertePrijsVoorAllePositiesTemplateModel>
  onTemplateGekozen;
  final VoidCallback onDoelenKiezen;
  final VoidCallback onKopieren;
  final VoidCallback onVerwijderen;

  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _rand = Color(0xFFE5E7EB);
  static const Color _achtergrond = Color(0xFFF9FAFB);

  OffertePrijsPerPositieRegelModel get prijsregel => regel.prijsregel;

  List<String> get _eenhedenVoorDropdown {
    final huidige = prijsregel.eenheid.trim();
    if (huidige.isEmpty || eenheden.contains(huidige)) {
      return eenheden;
    }
    return <String>[huidige, ...eenheden];
  }

  double _leesDouble(String tekst) {
    return double.tryParse(tekst.trim().replaceAll(',', '.')) ?? 0.0;
  }

  String _getal(double waarde, {int decimalen = 2}) {
    if (!waarde.isFinite || waarde <= 0) {
      return '';
    }
    var tekst = waarde.toStringAsFixed(decimalen).replaceAll('.', ',');
    tekst = tekst.replaceFirst(RegExp(r'0+$'), '');
    return tekst.replaceFirst(RegExp(r',$'), '');
  }

  String _bedrag(double waarde) {
    return '€ ${waarde.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  List<OpmetingOverzichtPrijsDoelPositie> _actieveDoelen() {
    if (regel.toepassenOpAllePosities) {
      return doelPosities
          .where((doel) => doel.teltMeeInHoofdofferte)
          .toList(growable: false);
    }

    return doelPosities
        .where((doel) => regel.geselecteerdePositieIds.contains(doel.id))
        .toList(growable: false);
  }

  double _somOverDoelen(double Function(int breedteMm, int hoogteMm) bereken) {
    final doelen = _actieveDoelen();
    if (doelen.isEmpty) {
      return bereken(breedteMm, hoogteMm);
    }

    var totaal = 0.0;
    for (final doel in doelen) {
      totaal += bereken(doel.breedteMm, doel.hoogteMm);
    }
    return (totaal * 100.0).roundToDouble() / 100.0;
  }

  @override
  Widget build(BuildContext context) {
    final basisTotaal = _somOverDoelen(
      (breedte, hoogte) => prijsregel.basisTotaalExclBtwVoorMaten(
        breedteMm: breedte,
        hoogteMm: hoogte,
      ),
    );
    final winstBedrag = _somOverDoelen(
      (breedte, hoogte) => prijsregel.winstBedragExclBtwVoorMaten(
        breedteMm: breedte,
        hoogteMm: hoogte,
      ),
    );
    final eindTotaal = _somOverDoelen(
      (breedte, hoogte) => prijsregel.eindTotaalExclBtwVoorMaten(
        breedteMm: breedte,
        hoogteMm: hoogte,
      ),
    );

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _achtergrond,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _rand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _PrijsVoorAllePositiesOmschrijvingMenu(
                onGekozen: onTemplateGekozen,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: _PrijsRegelInvoerVeld(
                    sleutel: 'allepos_omschrijving_${prijsregel.id}',
                    beginTekst: prijsregel.omschrijving,
                    hintText: 'Omschrijving',
                    onBewaren: (waarde) {
                      onGewijzigd(
                        prijsregel.copyWith(omschrijving: waarde.trim()),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 82,
                height: 40,
                child: DropdownButtonFormField<OffertePrijsPerPositieWeergave>(
                  key: ValueKey<String>(
                    'allepos_weergave_${prijsregel.id}_${prijsregel.offerteWeergave.name}',
                  ),
                  initialValue: prijsregel.offerteWeergave,
                  isDense: false,
                  isExpanded: true,
                  decoration: _regelDropdownDecoratie(),
                  items: OffertePrijsPerPositieWeergave.values
                      .map(
                        (waarde) =>
                            DropdownMenuItem<OffertePrijsPerPositieWeergave>(
                              value: waarde,
                              child: Text(
                                waarde.label,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                      )
                      .toList(growable: false),
                  onChanged: (waarde) {
                    if (waarde == null ||
                        waarde == prijsregel.offerteWeergave) {
                      return;
                    }
                    onGewijzigd(prijsregel.copyWith(offerteWeergave: waarde));
                  },
                ),
              ),
              SizedBox(
                width: 38,
                height: 40,
                child: IconButton(
                  onPressed: onKopieren,
                  tooltip: 'Prijsregel kopiëren',
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.copy_rounded, size: 17, color: _groen),
                ),
              ),
              SizedBox(
                width: 38,
                height: 40,
                child: IconButton(
                  onPressed: onVerwijderen,
                  tooltip: 'Prijsregel verwijderen',
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: Color(0xFFB91C1C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          LayoutBuilder(
            builder: (context, constraints) {
              const tussenruimte = 4.0;

              Widget cel({required Widget child, required int flex}) {
                return Expanded(
                  flex: flex,
                  child: SizedBox(height: 40, child: child),
                );
              }

              Widget ruimte() => const SizedBox(width: tussenruimte);
              final huidigeEenheid = prijsregel.eenheid.trim();

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  cel(
                    flex: 4,
                    child:
                        _PrijsRegelCompactKeuzeMenu<OffertePrijsPerPositieType>(
                          waarde: prijsregel.type,
                          waarden: OffertePrijsPerPositieType.values,
                          hintText: 'V',
                          tekstVoor: (waarde) => waarde.label,
                          tekstGrootte: 13,
                          tekstVet: true,
                          onGekozen: (waarde) {
                            if (waarde == prijsregel.type) {
                              return;
                            }
                            onGewijzigd(prijsregel.copyWith(type: waarde));
                          },
                        ),
                  ),
                  ruimte(),
                  cel(
                    flex: 6,
                    child: _PrijsRegelInvoerVeld(
                      sleutel: 'allepos_aantal_${prijsregel.id}',
                      beginTekst: _getal(prijsregel.aantal, decimalen: 4),
                      hintText: 'Aantal',
                      numeriek: true,
                      maxGeheleCijfers: 3,
                      maxDecimalen: 2,
                      onBewaren: (waarde) {
                        onGewijzigd(
                          prijsregel.copyWith(aantal: _leesDouble(waarde)),
                        );
                      },
                    ),
                  ),
                  ruimte(),
                  cel(
                    flex: 12,
                    child: _PrijsRegelCompactKeuzeMenu<String>(
                      waarde: huidigeEenheid.isEmpty ? null : huidigeEenheid,
                      waarden: _eenhedenVoorDropdown,
                      hintText: 'Eenheid',
                      tekstVoor: (waarde) => waarde,
                      tekstGrootte: 11.5,
                      onGekozen: (waarde) {
                        if (waarde == prijsregel.eenheid) {
                          return;
                        }
                        onGewijzigd(prijsregel.copyWith(eenheid: waarde));
                      },
                    ),
                  ),
                  ruimte(),
                  cel(
                    flex: 8,
                    child: _PrijsRegelInvoerVeld(
                      sleutel: 'allepos_prijs_${prijsregel.id}',
                      beginTekst: _getal(prijsregel.eenheidsPrijsExclBtw),
                      hintText: 'Prijs',
                      numeriek: true,
                      maxGeheleCijfers: 4,
                      maxDecimalen: 2,
                      prefixText: '€ ',
                      onBewaren: (waarde) {
                        onGewijzigd(
                          prijsregel.copyWith(
                            eenheidsPrijsExclBtw: _leesDouble(waarde),
                          ),
                        );
                      },
                    ),
                  ),
                  ruimte(),
                  cel(
                    flex: 8,
                    child: _PrijsRegelWaardeVak(
                      tekst: basisTotaal > 0 ? _bedrag(basisTotaal) : 'Totaal',
                      hint: basisTotaal <= 0,
                    ),
                  ),
                  ruimte(),
                  cel(
                    flex: 4,
                    child: prijsregel.isAankoop
                        ? _PrijsRegelInvoerVeld(
                            sleutel: 'allepos_winst_${prijsregel.id}',
                            beginTekst: _getal(prijsregel.winstPercentage),
                            hintText: '%',
                            numeriek: true,
                            maxGeheleCijfers: 2,
                            maxDecimalen: 2,
                            suffixText: '%',
                            onBewaren: (waarde) {
                              onGewijzigd(
                                prijsregel.copyWith(
                                  winstPercentage: _leesDouble(waarde),
                                ),
                              );
                            },
                          )
                        : const _PrijsRegelWaardeVak(tekst: '%', hint: true),
                  ),
                  ruimte(),
                  cel(
                    flex: 8,
                    child: _PrijsRegelWaardeVak(
                      tekst: winstBedrag > 0 ? _bedrag(winstBedrag) : '€',
                      hint: winstBedrag <= 0,
                    ),
                  ),
                  ruimte(),
                  cel(
                    flex: 9,
                    child: _PrijsRegelWaardeVak(
                      tekst: eindTotaal > 0
                          ? _bedrag(eindTotaal)
                          : 'Eindtotaal',
                      vet: eindTotaal > 0,
                      hint: eindTotaal <= 0,
                      achtergrond: const Color(0xFFE7F6EC),
                      randKleur: const Color(0xFFCDE9D5),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 7),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onDoelenKiezen,
              icon: const Icon(Icons.checklist_rounded, size: 16),
              label: Text(doelSamenvatting),
              style: OutlinedButton.styleFrom(
                foregroundColor: _groen,
                side: const BorderSide(color: Color(0xFFCDE9D5)),
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrijsVoorAllePositiesOmschrijvingMenu extends StatefulWidget {
  const _PrijsVoorAllePositiesOmschrijvingMenu({required this.onGekozen});

  final ValueChanged<OffertePrijsVoorAllePositiesTemplateModel> onGekozen;

  @override
  State<_PrijsVoorAllePositiesOmschrijvingMenu> createState() =>
      _PrijsVoorAllePositiesOmschrijvingMenuState();
}

class _PrijsVoorAllePositiesOmschrijvingMenuState
    extends State<_PrijsVoorAllePositiesOmschrijvingMenu> {
  static const Color _groen = Color(0xFF0B7A3B);
  static const Color _tekstGrijs = Color(0xFF6B7280);

  List<OffertePrijsVoorAllePositiesTemplateModel> _templates =
      const <OffertePrijsVoorAllePositiesTemplateModel>[];
  bool _laden = true;

  @override
  void initState() {
    super.initState();
    _laadTemplates();
  }

  Future<void> _laadTemplates() async {
    try {
      final templates =
          await AppStorage.laadOffertePrijsVoorAllePositiesTemplates();
      if (!mounted) {
        return;
      }
      setState(() {
        _templates = templates;
        _laden = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _templates = const <OffertePrijsVoorAllePositiesTemplateModel>[];
        _laden = false;
      });
    }
  }

  static String _percentage(double waarde) {
    var tekst = waarde.toStringAsFixed(2).replaceAll('.', ',');
    tekst = tekst.replaceFirst(RegExp(r'0+$'), '');
    return tekst.replaceFirst(RegExp(r',$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: PopupMenuButton<OffertePrijsVoorAllePositiesTemplateModel>(
        tooltip: 'Omschrijving kiezen uit Instellingen',
        position: PopupMenuPosition.under,
        padding: EdgeInsets.zero,
        onOpened: _laadTemplates,
        onSelected: widget.onGekozen,
        icon: const Icon(
          Icons.arrow_drop_down_circle_outlined,
          size: 19,
          color: _groen,
        ),
        itemBuilder: (context) {
          if (_laden) {
            return const <
              PopupMenuEntry<OffertePrijsVoorAllePositiesTemplateModel>
            >[
              PopupMenuItem<OffertePrijsVoorAllePositiesTemplateModel>(
                enabled: false,
                child: Text('Prijsregels laden…'),
              ),
            ];
          }

          if (_templates.isEmpty) {
            return const <
              PopupMenuEntry<OffertePrijsVoorAllePositiesTemplateModel>
            >[
              PopupMenuItem<OffertePrijsVoorAllePositiesTemplateModel>(
                enabled: false,
                child: Text(
                  'Geen regels in Instellingen > Prijs voor alle posities',
                ),
              ),
            ];
          }

          return _templates
              .map((template) {
                final winstTekst = template.isAankoop
                    ? ' · winst ${_percentage(template.veiligeStandaardWinstPercentage)} %'
                    : '';
                return PopupMenuItem<OffertePrijsVoorAllePositiesTemplateModel>(
                  value: template,
                  child: SizedBox(
                    width: 360,
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7F6EC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            template.type.label,
                            style: const TextStyle(
                              color: _groen,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                template.omschrijving,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${template.eenheid}$winstTekst',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _tekstGrijs,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              })
              .toList(growable: false);
        },
      ),
    );
  }
}

class _PrijsRegelCompactKeuzeMenu<T> extends StatelessWidget {
  const _PrijsRegelCompactKeuzeMenu({
    required this.waarde,
    required this.waarden,
    required this.hintText,
    required this.tekstVoor,
    required this.onGekozen,
    this.tekstGrootte = 10,
    this.tekstVet = false,
  });

  final T? waarde;
  final List<T> waarden;
  final String hintText;
  final String Function(T waarde) tekstVoor;
  final ValueChanged<T> onGekozen;
  final double tekstGrootte;
  final bool tekstVet;

  @override
  Widget build(BuildContext context) {
    final huidigeTekst = waarde == null ? '' : tekstVoor(waarde as T).trim();
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
                height: 36,
                child: Text(
                  tekstVoor(item),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
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
        padding: const EdgeInsets.only(left: 5, right: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(7),
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
                  fontSize: tekstGrootte,
                  fontWeight: tekstVet ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_drop_down_rounded,
              size: 15,
              color: Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrijsRegelWaardeVak extends StatelessWidget {
  const _PrijsRegelWaardeVak({
    required this.tekst,
    this.vet = false,
    this.hint = false,
    this.achtergrond = Colors.white,
    this.randKleur = const Color(0xFFE5E7EB),
  });

  final String tekst;
  final bool vet;
  final bool hint;
  final Color achtergrond;
  final Color randKleur;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: achtergrond,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: randKleur),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: Text(
          tekst,
          maxLines: 1,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: hint ? const Color(0xFF9CA3AF) : const Color(0xFF111827),
            fontSize: vet ? 13 : 12.5,
            fontWeight: hint
                ? FontWeight.w600
                : (vet ? FontWeight.w900 : FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _PrijsRegelInvoerVeld extends StatefulWidget {
  const _PrijsRegelInvoerVeld({
    required this.sleutel,
    required this.beginTekst,
    required this.hintText,
    required this.onBewaren,
    this.numeriek = false,
    this.maxGeheleCijfers,
    this.maxDecimalen = 2,
    this.prefixText,
    this.suffixText,
  });

  final String sleutel;
  final String beginTekst;
  final String hintText;
  final ValueChanged<String> onBewaren;
  final bool numeriek;
  final int? maxGeheleCijfers;
  final int maxDecimalen;
  final String? prefixText;
  final String? suffixText;

  @override
  State<_PrijsRegelInvoerVeld> createState() => _PrijsRegelInvoerVeldState();
}

class _PrijsRegelInvoerVeldState extends State<_PrijsRegelInvoerVeld> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late String _laatstBewaard;

  @override
  void initState() {
    super.initState();
    _laatstBewaard = widget.beginTekst;
    _controller = TextEditingController(text: widget.beginTekst);
    _focusNode = FocusNode()..addListener(_focusGewijzigd);
  }

  @override
  void didUpdateWidget(covariant _PrijsRegelInvoerVeld oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.beginTekst == widget.beginTekst) {
      return;
    }
    _laatstBewaard = widget.beginTekst;
    if (_controller.text != widget.beginTekst) {
      _controller.value = TextEditingValue(
        text: widget.beginTekst,
        selection: TextSelection.collapsed(offset: widget.beginTekst.length),
      );
    }
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
    final waarde = _controller.text.trim();
    if (waarde == _laatstBewaard.trim()) {
      return;
    }
    _laatstBewaard = waarde;
    widget.onBewaren(waarde);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: ValueKey<String>(widget.sleutel),
      controller: _controller,
      focusNode: _focusNode,
      expands: true,
      maxLines: null,
      minLines: null,
      textAlignVertical: TextAlignVertical.center,
      keyboardType: widget.numeriek
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      inputFormatters: widget.numeriek
          ? <TextInputFormatter>[
              TextInputFormatter.withFunction((oudeWaarde, nieuweWaarde) {
                final maxGeheleCijfers = widget.maxGeheleCijfers;
                final maxDecimalen = widget.maxDecimalen < 0
                    ? 0
                    : widget.maxDecimalen;
                final patroon = maxGeheleCijfers == null
                    ? RegExp(
                        r'^\d*([,.]\d{0,' + maxDecimalen.toString() + r'})?$',
                      )
                    : RegExp(
                        r'^\d{0,' +
                            maxGeheleCijfers.toString() +
                            r'}([,.]\d{0,' +
                            maxDecimalen.toString() +
                            r'})?$',
                      );
                return patroon.hasMatch(nieuweWaarde.text)
                    ? nieuweWaarde
                    : oudeWaarde;
              }),
            ]
          : null,
      style: const TextStyle(
        color: Color(0xFF111827),
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
      ),
      decoration: _regelDecoratie(
        hintText: widget.hintText,
        prefixText: widget.prefixText,
        suffixText: widget.suffixText,
      ),
      onSubmitted: (_) => _bewaar(),
    );
  }
}

InputDecoration _regelDropdownDecoratie() {
  return _regelDecoratie().copyWith(
    isDense: false,
    constraints: const BoxConstraints.tightFor(height: 40),
    contentPadding: const EdgeInsets.symmetric(horizontal: 9),
  );
}

InputDecoration _regelDecoratie({
  String? hintText,
  String? prefixText,
  String? suffixText,
}) {
  return InputDecoration(
    hintText: hintText,
    prefixText: prefixText,
    suffixText: suffixText,
    hintStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Color(0xFF9CA3AF),
    ),
    prefixStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Color(0xFF111827),
    ),
    suffixStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Color(0xFF111827),
    ),
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    constraints: const BoxConstraints.tightFor(height: 40),
    contentPadding: const EdgeInsets.symmetric(horizontal: 6),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(color: Color(0xFF0B7A3B), width: 1.25),
    ),
  );
}
