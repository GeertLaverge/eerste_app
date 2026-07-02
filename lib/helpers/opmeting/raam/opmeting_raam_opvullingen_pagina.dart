import 'package:flutter/material.dart';

import '../../app_storage.dart';
import 'opmeting_raam_opvulling_model.dart';

class OpmetingRaamOpvullingenPagina extends StatefulWidget {
  const OpmetingRaamOpvullingenPagina({super.key});

  @override
  State<OpmetingRaamOpvullingenPagina> createState() =>
      _OpmetingRaamOpvullingenPaginaState();
}

class _OpmetingRaamOpvullingenPaginaState
    extends State<OpmetingRaamOpvullingenPagina> {
  static const Color groen = Color(0xFF0B7A3B);
  static const Color achtergrond = Color(0xFFF7F8FA);
  static const Color rand = Color(0xFFE5E7EB);

  static const List<Color> _beschikbareKleuren = [
    Color(0xFFFFFFFF),
    Color(0xFFF3F4F6),
    Color(0xFFD1D5DB),
    Color(0xFF9CA3AF),
    Color(0xFF6B7280),
    Color(0xFF111827),
    Color(0xFFB3E5FC),
    Color(0xFF81D4FA),
    Color(0xFF4FC3F7),
    Color(0xFF90CAF9),
    Color(0xFF64B5F6),
    Color(0xFF42A5F5),
    Color(0xFFC8E6C9),
    Color(0xFFA5D6A7),
    Color(0xFF81C784),
    Color(0xFFFFF9C4),
    Color(0xFFFFF59D),
    Color(0xFFFFEE58),
    Color(0xFFFFE0B2),
    Color(0xFFFFCC80),
    Color(0xFFFFB74D),
    Color(0xFFFFCDD2),
    Color(0xFFEF9A9A),
    Color(0xFFE57373),
    Color(0xFFE1BEE7),
    Color(0xFFCE93D8),
    Color(0xFFBA68C8),
    Color(0xFFD7CCC8),
    Color(0xFFBCAAA4),
    Color(0xFFA1887F),
  ];

  final List<OpmetingRaamOpvullingModel> _opvullingen = [];

  bool _isLaden = true;
  bool _isBewaren = false;

  @override
  void initState() {
    super.initState();
    _laadOpvullingen();
  }

  Future<void> _laadOpvullingen() async {
    final geladenOpvullingen = await AppStorage.laadOpmetingRaamOpvullingen();

    if (!mounted) {
      return;
    }

    setState(() {
      _opvullingen
        ..clear()
        ..addAll(geladenOpvullingen);

      _isLaden = false;
    });
  }

  Future<void> _bewaarOpvullingen() async {
    if (_isBewaren) {
      return;
    }

    setState(() {
      _isBewaren = true;
    });

    try {
      await AppStorage.bewaarOpmetingRaamOpvullingen(_opvullingen);
    } finally {
      if (mounted) {
        setState(() {
          _isBewaren = false;
        });
      }
    }
  }

  Future<void> _voegOpvullingToe() async {
    final resultaat = await _toonOpvullingDialog();

    if (resultaat == null) {
      return;
    }

    setState(() {
      _opvullingen.add(
        OpmetingRaamOpvullingModel(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          naam: resultaat.naam,
          kleurWaarde: resultaat.kleur.value,
          transparantie: resultaat.transparantie,
        ),
      );
    });

    await _bewaarOpvullingen();
  }

  Future<void> _bewerkOpvulling(OpmetingRaamOpvullingModel opvulling) async {
    final resultaat = await _toonOpvullingDialog(bestaandeOpvulling: opvulling);

    if (resultaat == null) {
      return;
    }

    final index = _opvullingen.indexWhere((item) => item.id == opvulling.id);

    if (index < 0) {
      return;
    }

    setState(() {
      _opvullingen[index] = opvulling.copyWith(
        naam: resultaat.naam,
        kleurWaarde: resultaat.kleur.value,
        transparantie: resultaat.transparantie,
      );
    });

    await _bewaarOpvullingen();
  }

  Future<void> _verwijderOpvulling(OpmetingRaamOpvullingModel opvulling) async {
    final bevestigd = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Opvulling verwijderen'),
          content: Text('Wil je "${opvulling.naam}" definitief verwijderen?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Annuleren'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Verwijderen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );

    if (bevestigd != true) {
      return;
    }

    setState(() {
      _opvullingen.removeWhere((item) => item.id == opvulling.id);
    });

    await _bewaarOpvullingen();
  }

  Future<_OpvullingDialogResult?> _toonOpvullingDialog({
    OpmetingRaamOpvullingModel? bestaandeOpvulling,
  }) async {
    final naamController = TextEditingController(
      text: bestaandeOpvulling?.naam ?? '',
    );

    var gekozenKleur = bestaandeOpvulling?.kleur ?? const Color(0xFFB3E5FC);

    var transparantie = bestaandeOpvulling?.transparantie ?? 0.25;

    final hexController = TextEditingController(
      text: _kleurNaarHex(gekozenKleur),
    );

    String? foutmelding;

    final resultaat = await showDialog<_OpvullingDialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void kiesKleur(Color kleur) {
              setDialogState(() {
                gekozenKleur = kleur;
                hexController.text = _kleurNaarHex(kleur);
                foutmelding = null;
              });
            }

            void bewaar() {
              final naam = naamController.text.trim();
              final kleur = _kleurUitHex(hexController.text);

              if (naam.isEmpty) {
                setDialogState(() {
                  foutmelding = 'Geef eerst een naam voor de opvulling in.';
                });
                return;
              }

              final bestaatAl = _opvullingen.any((item) {
                if (item.id == bestaandeOpvulling?.id) {
                  return false;
                }

                return item.naam.trim().toLowerCase() == naam.toLowerCase();
              });

              if (bestaatAl) {
                setDialogState(() {
                  foutmelding = 'Er bestaat al een opvulling met deze naam.';
                });
                return;
              }

              if (kleur == null) {
                setDialogState(() {
                  foutmelding =
                      'Geef een geldige HEX-kleur in, bijvoorbeeld B3E5FC.';
                });
                return;
              }

              Navigator.pop(
                dialogContext,
                _OpvullingDialogResult(
                  naam: naam,
                  kleur: kleur,
                  transparantie: transparantie,
                ),
              );
            }

            return AlertDialog(
              title: Text(
                bestaandeOpvulling == null
                    ? 'Nieuwe opvulling'
                    : 'Opvulling aanpassen',
              ),
              content: SizedBox(
                width: 470,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: naamController,
                        autofocus: bestaandeOpvulling == null,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Naam opvulling',
                          hintText: 'Bijvoorbeeld helder glas',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Kleur',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _beschikbareKleuren.map((kleur) {
                          final geselecteerd =
                              kleur.value == gekozenKleur.value;

                          return InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => kiesKleur(kleur),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 120),
                              width: 38,
                              height: 38,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: geselecteerd
                                    ? groen.withOpacity(0.12)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: geselecteerd ? groen : rand,
                                  width: geselecteerd ? 2 : 1,
                                ),
                              ),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: kleur,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: Colors.black.withOpacity(0.15),
                                  ),
                                ),
                                child: geselecteerd
                                    ? Icon(
                                        Icons.check,
                                        size: 20,
                                        color: _contrasterendeKleur(kleur),
                                      )
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: hexController,
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 8,
                        decoration: const InputDecoration(
                          labelText: 'Eigen kleurcode',
                          hintText: 'B3E5FC',
                          prefixText: '#',
                          counterText: '',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (waarde) {
                          final kleur = _kleurUitHex(waarde);

                          if (kleur == null) {
                            return;
                          }

                          setDialogState(() {
                            gekozenKleur = kleur;
                            foutmelding = null;
                          });
                        },
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Dekking / transparantie',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            '${(transparantie * 100).round()}%',
                            style: const TextStyle(
                              color: groen,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: transparantie,
                        min: 0.05,
                        max: 1,
                        divisions: 19,
                        activeColor: groen,
                        label: '${(transparantie * 100).round()}%',
                        onChanged: (waarde) {
                          setDialogState(() {
                            transparantie = waarde;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: rand),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 72,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: rand),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: gekozenKleur.withOpacity(
                                    transparantie,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: Colors.black.withOpacity(0.14),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    naamController.text.trim().isEmpty
                                        ? 'Voorbeeld opvulling'
                                        : naamController.text.trim(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '#${_kleurNaarHex(gekozenKleur)} · '
                                    '${(transparantie * 100).round()}%',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (foutmelding != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: Text(
                            foutmelding!,
                            style: const TextStyle(
                              color: Color(0xFF991B1B),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Annuleren'),
                ),
                ElevatedButton.icon(
                  onPressed: bewaar,
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Bewaren'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: groen,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    naamController.dispose();
    hexController.dispose();

    return resultaat;
  }

  static String _kleurNaarHex(Color kleur) {
    final waarde = kleur.value.toRadixString(16).padLeft(8, '0').toUpperCase();

    return waarde.substring(2);
  }

  static Color? _kleurUitHex(String invoer) {
    var waarde = invoer
        .trim()
        .replaceAll('#', '')
        .replaceAll('0x', '')
        .replaceAll('0X', '');

    if (waarde.length == 6) {
      waarde = 'FF$waarde';
    }

    if (waarde.length != 8) {
      return null;
    }

    final kleurWaarde = int.tryParse(waarde, radix: 16);

    if (kleurWaarde == null) {
      return null;
    }

    return Color(kleurWaarde);
  }

  static Color _contrasterendeKleur(Color kleur) {
    return kleur.computeLuminance() > 0.55
        ? const Color(0xFF111827)
        : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: achtergrond,
      appBar: AppBar(
        backgroundColor: groen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Opvullingen',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Nieuwe opvulling',
            onPressed: _voegOpvullingToe,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _voegOpvullingToe,
        backgroundColor: groen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Opvulling'),
      ),
      body: _isLaden
          ? const Center(child: CircularProgressIndicator(color: groen))
          : _opvullingen.isEmpty
          ? _legeLijst()
          : _gevuldeLijst(),
    );
  }

  Widget _legeLijst() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: rand),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFE7F6EC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.format_color_fill_outlined,
                  color: groen,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Nog geen opvullingen',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'Voeg bijvoorbeeld helder glas, mat glas, '
                'gelaagd glas of een paneel toe.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _voegOpvullingToe,
                icon: const Icon(Icons.add),
                label: const Text('Eerste opvulling toevoegen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: groen,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gevuldeLijst() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _opvullingen.length,
      separatorBuilder: (_, __) {
        return const SizedBox(height: 10);
      },
      itemBuilder: (context, index) {
        final opvulling = _opvullingen[index];

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: rand),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 7,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: rand),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: opvulling.weergaveKleur,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black.withOpacity(0.14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opvulling.naam,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '#${_kleurNaarHex(opvulling.kleur)} · '
                      '${opvulling.transparantiePercentage}% dekking',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Aanpassen',
                onPressed: () {
                  _bewerkOpvulling(opvulling);
                },
                icon: const Icon(Icons.edit_outlined, color: groen),
              ),
              IconButton(
                tooltip: 'Verwijderen',
                onPressed: () {
                  _verwijderOpvulling(opvulling);
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OpvullingDialogResult {
  const _OpvullingDialogResult({
    required this.naam,
    required this.kleur,
    required this.transparantie,
  });

  final String naam;
  final Color kleur;
  final double transparantie;
}
