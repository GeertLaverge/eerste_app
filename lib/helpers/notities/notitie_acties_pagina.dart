import 'package:flutter/material.dart';

import 'notitie_actie_model.dart';
import 'notitie_repository.dart';

class NotitieActiesPagina extends StatefulWidget {
  const NotitieActiesPagina({
    super.key,
  });

  @override
  State<NotitieActiesPagina> createState() => _NotitieActiesPaginaState();
}

class _NotitieActiesPaginaState extends State<NotitieActiesPagina> {
  final NotitieRepository _repository = NotitieRepository();

  List<NotitieActieModel> _acties = [];

  final List<Color> _kleuren = const [
    Color(0xFF0B7A3B), // donkergroen
    Color(0xFF22C55E), // groen
    Color(0xFF84CC16), // lime
    Color(0xFFEAB308), // geel
    Color(0xFFF59E0B), // amber
    Color(0xFFF97316), // oranje
    Color(0xFFEA580C), // donker oranje
    Color(0xFFDC2626), // rood
    Color(0xFFEF4444), // licht rood
    Color(0xFFEC4899), // roze
    Color(0xFFBE185D), // donker roze
    Color(0xFF9333EA), // paars
    Color(0xFF7C3AED), // diep paars
    Color(0xFF6366F1), // indigo
    Color(0xFF2563EB), // blauw
    Color(0xFF0284C7), // licht blauw
    Color(0xFF0891B2), // cyaan
    Color(0xFF14B8A6), // teal
    Color(0xFF6B7280), // grijs
    Color(0xFF374151), // donker grijs
  ];

  @override
  void initState() {
    super.initState();
    _laad();
  }

  Future<void> _laad() async {
    final acties = await _repository.laadActies();

    if (!mounted) return;

    setState(() {
      _acties = acties;
    });
  }

  Future<void> _bewaar() async {
    await _repository.bewaarActies(_acties);
  }

  Future<void> _actieToevoegen() async {
    final controller = TextEditingController();
    Color gekozenKleur = _kleuren.first;

    final naam = await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Actie toevoegen'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Actie',
                      hintText: 'bv. Offerte maken',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _kleuren.map((kleur) {
                      final geselecteerd = kleur == gekozenKleur;

                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            gekozenKleur = kleur;
                          });
                        },
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: kleur,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: geselecteerd
                                  ? Colors.black
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Annuleren'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final tekst = controller.text.trim();

                    if (tekst.isEmpty) return;

                    Navigator.pop(context, tekst);
                  },
                  child: const Text('Toevoegen'),
                ),
              ],
            );
          },
        );
      },
    );

    if (naam == null || naam.trim().isEmpty) {
      return;
    }

    setState(() {
      _acties.add(
        NotitieActieModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          naam: naam.trim(),
          kleurWaarde: gekozenKleur.value,
        ),
      );
    });

    await _bewaar();
  }

  Future<void> _actieVerwijderen(
    NotitieActieModel actie,
  ) async {
    setState(() {
      _acties.removeWhere(
        (a) => a.id == actie.id,
      );
    });

    await _bewaar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text(
          'Acties notities',
          style: TextStyle(
            fontWeight: FontWeight.normal,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _actieToevoegen,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _acties.isEmpty
          ? const Center(
              child: Text(
                'Nog geen acties aangemaakt.',
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _acties.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final actie = _acties[index];

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Color(actie.kleurWaarde),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          actie.naam,
                          style: TextStyle(
                            color: Color(actie.kleurWaarde),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _actieVerwijderen(actie),
                        icon: const Icon(
                          Icons.delete_outline,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
