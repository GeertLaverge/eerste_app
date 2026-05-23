import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../helpers/app_storage.dart';
import '../modellen/agenda_actie.dart';
import '../modellen/agenda_actie_template.dart';
import '../helpers/widgets/onder_navigatie_balk.dart';

class AgendaActiePagina extends StatefulWidget {
  final AgendaActie? bestaandeActie;
  final Future<void> Function(AgendaActie actie) onOpslaan;
  final Future<void> Function(AgendaActie actie)? onVerwijderen;

  const AgendaActiePagina({
    super.key,
    this.bestaandeActie,
    required this.onOpslaan,
    this.onVerwijderen,
  });

  @override
  State<AgendaActiePagina> createState() => _AgendaActiePaginaState();
}

class _AgendaActiePaginaState extends State<AgendaActiePagina> {
  final TextEditingController actieNaamController = TextEditingController();

  List<AgendaActieTemplate> templates = [];
  AgendaActieTemplate? gekozenTemplate;

  String weergaveType = 'symbool';
  String agendaCategorie = 'plaatsing';

  bool toonOpDagtaak = true;
  int dagenVoorafTonen = 1;

  int startUur = 8;
  int startMinuut = 0;
  int eindUur = 10;
  int eindMinuut = 0;

  String gekozenKleurNaam = 'oranje';
  String gekozenIcoonNaam = 'delete_sweep';

  bool isLaden = true;

  final List<String> icoonOpties = [
    'delete_sweep',
    'inventory_2',
    'access_time',
    'local_shipping',
    'location_on',
    'construction',
    'warning',
    'beach_access',
    'build',
    'task_alt',
  ];

  final List<String> kleurOpties = [
    'groen',
    'blauw',
    'rood',
    'paars',
    'teal',
    'grijs',
    'lime',
    'cyan',
    'indigo',
    'pink',
    'amber',
    'brown',
    'blueGrey',
    'lightBlue',
    'lightGreen',
    'deepPurple',
    'deepOrange',
    'yellow',
    'black',
    'orange',
  ];

  @override
  void initState() {
    super.initState();

    actieNaamController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    laadTemplates();
  }

  @override
  void dispose() {
    actieNaamController.dispose();
    super.dispose();
  }

  Future<void> laadTemplates() async {
    final geladenTemplates = await AppStorage.laadAgendaActieTemplates();
    final bestaande = widget.bestaandeActie;

    AgendaActieTemplate? startTemplate;

    if (bestaande != null) {
      weergaveType = bestaande.weergaveType;
      agendaCategorie = bestaande.agendaCategorie;
      toonOpDagtaak = bestaande.toonOpDagtaak;
      dagenVoorafTonen = bestaande.dagenVoorafTonen;
      startUur = bestaande.startUur ?? 8;
      startMinuut = bestaande.startMinuut ?? 0;
      eindUur = bestaande.eindUur ?? 10;
      eindMinuut = bestaande.eindMinuut ?? 0;
      gekozenKleurNaam = bestaande.kleurNaam;
      gekozenIcoonNaam = bestaande.icoonNaam;
      actieNaamController.text =
          bestaande.titel.isNotEmpty ? bestaande.titel : bestaande.typeActie;

      for (final template in geladenTemplates) {
        if (template.naam == bestaande.typeActie ||
            template.naam == bestaande.titel) {
          startTemplate = template;
          break;
        }
      }
    } else {}

    if (mounted) {
      setState(() {
        templates = geladenTemplates;
        gekozenTemplate = startTemplate;
        isLaden = false;
      });
    }
  }

  Color kleurUitNaam(String naam) {
    switch (naam) {
      case 'blauw':
        return Colors.blue;
      case 'rood':
        return Colors.red;
      case 'paars':
        return Colors.purple;
      case 'teal':
        return Colors.teal;
      case 'grijs':
        return Colors.grey;
      case 'lime':
        return Colors.lime;
      case 'cyan':
        return Colors.cyan;
      case 'indigo':
        return Colors.indigo;
      case 'pink':
        return Colors.pink;
      case 'amber':
        return Colors.amber;
      case 'brown':
        return Colors.brown;
      case 'blueGrey':
        return Colors.blueGrey;
      case 'lightBlue':
        return Colors.lightBlue;
      case 'lightGreen':
        return Colors.lightGreen;
      case 'deepPurple':
        return Colors.deepPurple;
      case 'deepOrange':
        return Colors.deepOrange;
      case 'yellow':
        return Colors.yellow;
      case 'black':
        return Colors.black;
      case 'orange':
        return Colors.orange;
      case 'groen':
      default:
        return Colors.green;
    }
  }

  IconData icoonUitNaam(String naam) {
    switch (naam) {
      case 'inventory_2':
      case 'puinzak':
        return Icons.inventory_2_outlined;
      case 'access_time':
      case 'tijd':
        return Icons.access_time;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'location_on':
        return Icons.location_on;
      case 'construction':
        return Icons.precision_manufacturing;
      case 'warning':
        return Icons.warning;
      case 'beach_access':
      case 'verlof':
        return Icons.beach_access;
      case 'build':
        return Icons.precision_manufacturing;
      case 'task_alt':
      case 'taak':
        return Icons.task_alt;
      case 'delete_sweep':
      case 'rolcontainer':
      default:
        return Icons.delete_sweep;
    }
  }

  String tijdTekst(int uur, int minuut) {
    return '${uur.toString().padLeft(2, '0')}:'
        '${minuut.toString().padLeft(2, '0')}';
  }

  Future<TimeOfDay?> kiesTijdScroll({
    required int startUur,
    required int startMinuut,
  }) async {
    int gekozenUur = startUur;
    int gekozenMinuut = startMinuut;

    final uurController = FixedExtentScrollController(initialItem: gekozenUur);
    final minuutController =
        FixedExtentScrollController(initialItem: gekozenMinuut);

    final resultaat = await showModalBottomSheet<TimeOfDay>(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 310,
          child: Column(
            children: [
              Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuleer'),
                    ),
                    const Spacer(),
                    const Text(
                      'Tijd kiezen',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          TimeOfDay(
                            hour: gekozenUur,
                            minute: gekozenMinuut,
                          ),
                        );
                      },
                      child: const Text('Klaar'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: uurController,
                        itemExtent: 42,
                        onSelectedItemChanged: (waarde) {
                          gekozenUur = waarde;
                        },
                        children: List.generate(
                          24,
                          (index) => Center(
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      ':',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: minuutController,
                        itemExtent: 42,
                        onSelectedItemChanged: (waarde) {
                          gekozenMinuut = waarde;
                        },
                        children: List.generate(
                          60,
                          (index) => Center(
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    uurController.dispose();
    minuutController.dispose();

    return resultaat;
  }

  Future<void> kiesStartTijd() async {
    final gekozen = await kiesTijdScroll(
      startUur: startUur,
      startMinuut: startMinuut,
    );

    if (gekozen == null) return;

    setState(() {
      startUur = gekozen.hour;
      startMinuut = gekozen.minute;
    });
  }

  Future<void> kiesEindTijd() async {
    final gekozen = await kiesTijdScroll(
      startUur: eindUur,
      startMinuut: eindMinuut,
    );

    if (gekozen == null) return;

    setState(() {
      eindUur = gekozen.hour;
      eindMinuut = gekozen.minute;
    });
  }

  void toonFout(String tekst) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tekst),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> bewaarActie() async {
    final naam = actieNaamController.text.trim();

    if (naam.isEmpty) {
      toonFout('Geef eerst een naam voor de actie in.');
      return;
    }

    if (weergaveType == 'tijdsduur') {
      final start = startUur * 60 + startMinuut;
      final eind = eindUur * 60 + eindMinuut;

      if (eind <= start) {
        toonFout('Eindtijd moet later zijn dan begintijd.');
        return;
      }
    }

    final index = templates.indexWhere(
      (template) => template.naam.toLowerCase() == naam.toLowerCase(),
    );

    final template = AgendaActieTemplate(
      id: index >= 0
          ? templates[index].id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      naam: naam,
      icoonNaam: gekozenIcoonNaam,
      kleurNaam: gekozenKleurNaam,
    );

    setState(() {
      if (index >= 0) {
        templates[index] = template;
      } else {
        templates.add(template);
      }

      gekozenTemplate = template;
    });

    await AppStorage.bewaarAgendaActieTemplates(templates);

    final actie = AgendaActie(
      id: widget.bestaandeActie?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      titel: naam,
      typeActie: naam,
      datum: DateTime.now(),
      toonOpDagtaak: toonOpDagtaak,
      dagenVoorafTonen: dagenVoorafTonen,
      weergaveType: weergaveType,
      kleurNaam: gekozenKleurNaam,
      icoonNaam: gekozenIcoonNaam,
      startUur: weergaveType == 'tijdsduur' ? startUur : null,
      startMinuut: weergaveType == 'tijdsduur' ? startMinuut : null,
      eindUur: weergaveType == 'tijdsduur' ? eindUur : null,
      eindMinuut: weergaveType == 'tijdsduur' ? eindMinuut : null,
      opmerkingen: '',
      agendaCategorie: agendaCategorie,
    );

    await widget.onOpslaan(actie);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  Widget groeneBalk() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0B7A3B),
            Color(0xFF23B15F),
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context, false),
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.bestaandeActie == null ? 'Actie maken' : 'Actie aanpassen',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget kaart({
    required String titel,
    required IconData icoon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icoon, color: Colors.green),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titel,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget actieDropdown() {
    if (templates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: templates.map((template) {
        final kleur = kleurUitNaam(template.kleurNaam);
        final actief = gekozenTemplate?.id == template.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: actief ? kleur.withValues(alpha: 0.10) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: actief ? kleur : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      gekozenTemplate = template;
                      actieNaamController.text = template.naam;
                      gekozenKleurNaam = template.kleurNaam;
                      gekozenIcoonNaam = template.icoonNaam;
                    });
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Icon(
                          icoonUitNaam(template.icoonNaam),
                          color: Colors.black,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            template.naam,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight:
                                  actief ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Opgeslagen actie verwijderen',
                icon: const Icon(Icons.delete_outline),
                color: Colors.red,
                onPressed: () async {
                  final bevestigen = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Opgeslagen actie verwijderen'),
                        content: Text(
                          'Wil je "${template.naam}" verwijderen uit je opgeslagen acties?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Nee'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context, true),
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Ja, verwijderen'),
                          ),
                        ],
                      );
                    },
                  );

                  if (bevestigen != true) return;

                  setState(() {
                    templates.removeWhere((item) => item.id == template.id);

                    if (gekozenTemplate?.id == template.id) {
                      gekozenTemplate = null;
                      actieNaamController.clear();
                    }
                  });

                  await AppStorage.bewaarAgendaActieTemplates(templates);
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget tekstVeldNaam() {
    return TextField(
      controller: actieNaamController,
      decoration: InputDecoration(
        labelText: 'Naam van de actie',
        hintText: 'bv. Rolcontainer buitenzetten',
        prefixIcon: const Icon(Icons.edit),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  Widget agendaCategorieKeuze() {
    return Column(
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: agendaCategorie == 'plaatsing',
          activeColor: Colors.green,
          onChanged: (_) {
            setState(() {
              agendaCategorie = 'plaatsing';
            });
          },
          title: const Text(
            'Plaatsing',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text('Zichtbaar voor plaatsingsplanning'),
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: agendaCategorie == 'bureau',
          activeColor: Colors.green,
          onChanged: (_) {
            setState(() {
              agendaCategorie = 'bureau';
            });
          },
          title: const Text(
            'Bureau',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text('Alleen voor bureau-afspraken'),
        ),
      ],
    );
  }

  Widget typeKnop({
    required String tekst,
    required IconData icoon,
    required String waarde,
  }) {
    final actief = weergaveType == waarde;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            weergaveType = waarde;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: actief ? Colors.green.withValues(alpha: 0.10) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: actief ? Colors.green : Colors.grey.shade300,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icoon,
                color: actief ? Colors.green : Colors.grey.shade700,
              ),
              const SizedBox(height: 4),
              Text(
                tekst,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: actief ? FontWeight.bold : FontWeight.normal,
                  color: actief ? Colors.green : Colors.black,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget icoonKeuze() {
    return Wrap(
      children: icoonOpties.map((naam) {
        final actief = gekozenIcoonNaam == naam;
        final kleur = Colors.orange;

        return InkWell(
          onTap: () {
            setState(() {
              gekozenIcoonNaam = naam;
              gekozenKleurNaam = 'orange';
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 54,
            height: 54,
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color:
                  actief ? kleur.withValues(alpha: 0.14) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: actief ? kleur : Colors.grey.shade300,
                width: actief ? 2 : 1,
              ),
            ),
            child: Icon(
              icoonUitNaam(naam),
              color: kleur,
              size: 27,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget kleurenBalk() {
    return Wrap(
      children: kleurOpties.map((naam) {
        final kleur = kleurUitNaam(naam);
        final actief = gekozenKleurNaam == naam;

        return InkWell(
          onTap: () {
            setState(() {
              gekozenKleurNaam = naam;
            });
          },
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 38,
            height: 38,
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: kleur,
              shape: BoxShape.circle,
              border: Border.all(
                color: actief ? Colors.black : Colors.grey.shade300,
                width: actief ? 3 : 1,
              ),
            ),
            child: actief
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget tijdKnop({
    required String titel,
    required String tijd,
    required VoidCallback onTap,
  }) {
    return Flexible(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              const Icon(Icons.access_time),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titel,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      tijd,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
      ),
    );
  }

  Widget actieKnop({
    required String tekst,
    required IconData icoon,
    required VoidCallback onTap,
    required bool gevuld,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: gevuld
          ? ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icoon),
              label: Text(tekst),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icoon),
              label: Text(tekst),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLaden) {
      return Scaffold(
        body: const Center(
          child: CircularProgressIndicator(),
        ),
        bottomNavigationBar: OnderNavigatieBalk(
          huidigePagina: 'andere',
          onAgenda: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          onKlanten: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      );
    }

    final naamIsIngevuld = actieNaamController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            groeneBalk(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  kaart(
                    titel: 'Geef de actie een naam',
                    icoon: Icons.edit_note,
                    children: [
                      tekstVeldNaam(),
                    ],
                  ),
                  if (naamIsIngevuld)
                    kaart(
                      titel: 'Hoe wil je deze actie tonen?',
                      icoon: Icons.calendar_view_month,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoSlidingSegmentedControl<String>(
                            groupValue: weergaveType,
                            backgroundColor: Colors.grey.shade200,
                            thumbColor: Colors.green,
                            children: const {
                              'symbool': Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 10),
                                child: Text(
                                  'Symbool',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              'tijdsduur': Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 10),
                                child: Text(
                                  'Tijdsduur',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              'volledigeDag': Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 10),
                                child: Text(
                                  'Volledige dag',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            },
                            onValueChanged: (waarde) {
                              if (waarde == null) return;

                              setState(() {
                                weergaveType = waarde;
                              });
                            },
                          ),
                        ),
                        if (weergaveType == 'symbool') ...[
                          const SizedBox(height: 24),
                          Text(
                            'Kies een symbool',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          icoonKeuze(),
                          const SizedBox(height: 14),
                          Text(
                            'Kies een kleur',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          kleurenBalk(),
                        ],
                        if (weergaveType == 'volledigeDag') ...[
                          const SizedBox(height: 18),
                          Text(
                            'Kies een kleur voor deze dag',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          kleurenBalk(),
                        ],
                        if (weergaveType == 'tijdsduur') ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              tijdKnop(
                                titel: 'Begintijd',
                                tijd: tijdTekst(startUur, startMinuut),
                                onTap: kiesStartTijd,
                              ),
                              const SizedBox(width: 10),
                              tijdKnop(
                                titel: 'Eindtijd',
                                tijd: tijdTekst(eindUur, eindMinuut),
                                onTap: kiesEindTijd,
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: toonOpDagtaak,
                          onChanged: (waarde) {
                            setState(() {
                              toonOpDagtaak = waarde;
                            });
                          },
                          title: const Text(
                            'Weergeven op dagtaak',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text(
                            'Toon deze actie op de hoofdpagina',
                          ),
                        ),
                        if (toonOpDagtaak) ...[
                          DropdownButtonFormField<int>(
                            value: dagenVoorafTonen,
                            decoration: InputDecoration(
                              labelText: 'Hoeveel dagen vooraf tonen?',
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 0,
                                child: Text('Op dezelfde dag'),
                              ),
                              DropdownMenuItem(
                                value: 1,
                                child: Text('1 dag vooraf'),
                              ),
                              DropdownMenuItem(
                                value: 2,
                                child: Text('2 dagen vooraf'),
                              ),
                              DropdownMenuItem(
                                value: 3,
                                child: Text('3 dagen vooraf'),
                              ),
                              DropdownMenuItem(
                                value: 7,
                                child: Text('1 week vooraf'),
                              ),
                            ],
                            onChanged: (waarde) {
                              if (waarde == null) return;

                              setState(() {
                                dagenVoorafTonen = waarde;
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  actieKnop(
                    tekst: 'Annuleren',
                    icoon: Icons.close,
                    gevuld: false,
                    onTap: () {
                      Navigator.pop(context, false);
                    },
                  ),
                  const SizedBox(height: 12),
                  actieKnop(
                    tekst: 'Bewaar deze actie',
                    icoon: Icons.save,
                    gevuld: true,
                    onTap: bewaarActie,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
