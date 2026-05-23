import 'package:flutter/material.dart';

import '../helpers/app_storage.dart';
import '../modellen/notitie.dart';
import '../modellen/notitie_actie.dart';
import '../helpers/widgets/onder_navigatie_balk.dart';

class NotitiesBureauPagina extends StatefulWidget {
  const NotitiesBureauPagina({super.key});

  @override
  State<NotitiesBureauPagina> createState() => _NotitiesBureauPaginaState();
}

class _NotitiesBureauPaginaState extends State<NotitiesBureauPagina> {
  List<Notitie> notities = [];
  List<NotitieActie> opgeslagenActies = [];
  bool isLaden = true;

  @override
  void initState() {
    super.initState();
    laadData();
  }

  Future<void> laadData() async {
    final geladenNotities = await AppStorage.laadNotities();
    final geladenActies = await AppStorage.laadNotitieActies();

    if (!mounted) return;

    setState(() {
      notities = geladenNotities;
      opgeslagenActies = geladenActies;
      isLaden = false;
    });
  }

  Future<void> bewaarNotities() async {
    await AppStorage.bewaarNotities(notities);
    if (mounted) setState(() {});
  }

  bool magNaarAfgewerkt(Notitie notitie) {
    return notitie.afgewerkt;
  }

  List<Notitie> actieveNotities() {
    final lijst = notities.where((n) => !magNaarAfgewerkt(n)).toList();

    lijst.sort((a, b) {
      if (a.afgewerkt != b.afgewerkt) return a.afgewerkt ? 1 : -1;
      return b.aangemaaktOp.compareTo(a.aangemaaktOp);
    });

    return lijst;
  }

  List<Notitie> afgewerkteNotities() {
    final lijst = notities.where((n) => magNaarAfgewerkt(n)).toList();

    lijst.sort((a, b) {
      final da = a.afgewerktOp ?? a.aangemaaktOp;
      final db = b.afgewerktOp ?? b.aangemaaktOp;
      return db.compareTo(da);
    });

    return lijst;
  }

  Future<void> openNieuweNotitie() async {
    final nieuweNotitie = await Navigator.push<Notitie>(
      context,
      MaterialPageRoute(
        builder: (context) => NotitieMakenPagina(
          opgeslagenActies: opgeslagenActies,
        ),
      ),
    );

    await laadData();

    if (nieuweNotitie == null) return;

    setState(() {
      notities.insert(0, nieuweNotitie);
    });

    await bewaarNotities();
  }

  Future<void> openNotitie(Notitie notitie) async {
    final aangepasteNotitie = await Navigator.push<Notitie>(
      context,
      MaterialPageRoute(
        builder: (context) => NotitieMakenPagina(
          bestaandeNotitie: notitie,
          opgeslagenActies: opgeslagenActies,
        ),
      ),
    );

    await laadData();

    if (aangepasteNotitie == null) return;

    final index = notities.indexWhere((n) => n.id == aangepasteNotitie.id);

    setState(() {
      if (index >= 0) {
        notities[index] = aangepasteNotitie;
      }
    });

    await bewaarNotities();
  }

  Future<void> vinkNotitieAf(Notitie notitie, bool waarde) async {
    setState(() {
      notitie.afgewerkt = waarde;
      notitie.afgewerktOp = waarde ? DateTime.now() : null;
    });

    await bewaarNotities();
  }

  Future<void> verplaatsNaarAfgewerkt(Notitie notitie) async {
    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Verplaatsen'),
          content: const Text(
            'Wil je deze notitie verplaatsen naar afgewerkte notities?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Nee'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ja'),
            ),
          ],
        );
      },
    );

    if (bevestigen != true) return;

    setState(() {
      notitie.afgewerkt = true;
      notitie.afgewerktOp = DateTime.now();
    });

    await bewaarNotities();
  }

  Future<void> openAfgewerkteNotities() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AfgewerkteNotitiesPagina(
          notities: afgewerkteNotities(),
          onTerugzetten: (notitie) async {
            setState(() {
              notitie.afgewerkt = false;
              notitie.afgewerktOp = null;

              for (final actie in notitie.acties) {
                actie.afgewerkt = false;
              }
            });

            await bewaarNotities();
          },
        ),
      ),
    );

    await laadData();
  }

  String datumTekst(DateTime datum) {
    return '${datum.day.toString().padLeft(2, '0')}/'
        '${datum.month.toString().padLeft(2, '0')}/'
        '${datum.year}';
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

  Widget groeneBalk() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0B7A3B), Color(0xFF23B15F)],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Notities Bureau',
              style: TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: IconButton(
              onPressed: openNieuweNotitie,
              icon: const Icon(Icons.add),
              color: Colors.green,
              iconSize: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget notitieRij(Notitie notitie) {
    final actie = notitie.acties.isEmpty ? null : notitie.acties.first;
    final kleur = actie == null ? Colors.green : kleurUitNaam(actie.kleurNaam);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => openNotitie(notitie),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              const SizedBox(width: 4),
              Expanded(
                flex: 4,
                child: Text(
                  notitie.titel.isEmpty ? 'Geen titel' : notitie.titel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: notitie.afgewerkt
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: notitie.afgewerkt ? Colors.grey : Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: actie == null
                    ? Text(
                        'Geen actie bepaald',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: kleur.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          actie.titel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: kleur,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            decoration: notitie.afgewerkt
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 6),
              Text(
                datumTekst(notitie.aangemaaktOp),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                ),
              ),
              IconButton(
                onPressed: () => verplaatsNaarAfgewerkt(notitie),
                icon: const Icon(Icons.archive_outlined),
                color: Colors.green,
                tooltip: 'Verplaats naar afgewerkte notities',
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lijst = actieveNotities();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      bottomNavigationBar: OnderNavigatieBalk(
        huidigePagina: 'andere',
        onAgenda: () {
          Navigator.popUntil(context, (route) => route.isFirst);
          // later eventueel rechtstreeks naar agenda
        },
        onKlanten: () {
          Navigator.popUntil(context, (route) => route.isFirst);
          // later eventueel rechtstreeks naar klanten
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            groeneBalk(),
            Expanded(
              child: isLaden
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.all(18),
                      children: [
                        if (lijst.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: const Text(
                              'Nog geen notities toegevoegd.',
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          ...lijst.map(notitieRij),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: openAfgewerkteNotities,
                            icon: const Icon(Icons.archive_outlined),
                            label: const Text('Bekijk afgewerkte notities'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green,
                              side: const BorderSide(color: Colors.green),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotitieMakenPagina extends StatefulWidget {
  final Notitie? bestaandeNotitie;
  final List<NotitieActie> opgeslagenActies;

  const NotitieMakenPagina({
    super.key,
    this.bestaandeNotitie,
    required this.opgeslagenActies,
  });

  @override
  State<NotitieMakenPagina> createState() => _NotitieMakenPaginaState();
}

class _NotitieMakenPaginaState extends State<NotitieMakenPagina> {
  final titelController = TextEditingController();
  final inhoudController = TextEditingController();

  NotitieActie? gekozenActie;
  late List<NotitieActie> opgeslagenActies;

  @override
  void initState() {
    super.initState();

    opgeslagenActies = [...widget.opgeslagenActies];

    final bestaande = widget.bestaandeNotitie;

    if (bestaande != null) {
      titelController.text = bestaande.titel;
      inhoudController.text = bestaande.inhoud;

      if (bestaande.acties.isNotEmpty) {
        gekozenActie = bestaande.acties.first;
      }
    }
  }

  @override
  void dispose() {
    titelController.dispose();
    inhoudController.dispose();
    super.dispose();
  }

  Future<bool> bevestigActieWijzigen() async {
    final antwoord = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Actie wijzigen'),
          content: const Text('Wil je de huidige actie vervangen?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Nee'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Ja'),
            ),
          ],
        );
      },
    );

    return antwoord == true;
  }

  Future<void> kiesActie(NotitieActie actie) async {
    if (gekozenActie != null) {
      final magWijzigen = await bevestigActieWijzigen();
      if (!magWijzigen) return;
    }

    setState(() {
      gekozenActie = NotitieActie(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titel: actie.titel,
        toevoegenAanDagtaak: actie.toevoegenAanDagtaak,
        datum: actie.datum,
        kleurNaam: actie.kleurNaam,
        afgewerkt: false,
      );
    });
  }

  void wisGekozenActie() {
    setState(() {
      gekozenActie = null;
    });
  }

  void sluitEnBewaar() {
    final titel = titelController.text.trim();
    final inhoud = inhoudController.text.trim();

    if (titel.isEmpty && inhoud.isEmpty && gekozenActie == null) {
      Navigator.pop(context);
      return;
    }

    final bestaande = widget.bestaandeNotitie;

    final notitie = Notitie(
      id: bestaande?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      titel: titel,
      inhoud: inhoud,
      acties: gekozenActie == null ? [] : [gekozenActie!],
      afgewerkt: bestaande?.afgewerkt ?? false,
      aangemaaktOp: bestaande?.aangemaaktOp ?? DateTime.now(),
      afgewerktOp: bestaande?.afgewerktOp,
    );

    Navigator.pop(context, notitie);
  }

  Future<void> openActieMaken() async {
    final actie = await Navigator.push<NotitieActie>(
      context,
      MaterialPageRoute(
        builder: (context) => NotitieActieMakenPagina(
          opgeslagenActies: opgeslagenActies,
        ),
      ),
    );

    final nieuweLijst = await AppStorage.laadNotitieActies();

    if (!mounted) return;

    setState(() {
      opgeslagenActies = nieuweLijst;
    });

    if (actie == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Actie opgeslagen bij opgeslagen acties.'),
      ),
    );
  }

  Widget groeneBalk() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0B7A3B), Color(0xFF23B15F)],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: sluitEnBewaar,
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
          ),
          Expanded(
            child: Text(
              widget.bestaandeNotitie == null
                  ? 'Notitie maken'
                  : 'Notitie aanpassen',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: IconButton(
              onPressed: openActieMaken,
              icon: const Icon(Icons.add),
              color: Colors.green,
              iconSize: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget tekstVeld({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        sluitEnBewaar();
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: SafeArea(
          child: Column(
            children: [
              groeneBalk(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    tekstVeld(
                      controller: titelController,
                      label: 'Titel',
                    ),
                    const SizedBox(height: 14),
                    tekstVeld(
                      controller: inhoudController,
                      label: 'Notitie',
                      maxLines: 7,
                    ),
                    const SizedBox(height: 16),
                    PopupMenuButton<NotitieActie?>(
                      onSelected: (actie) {
                        if (actie == null) {
                          wisGekozenActie();
                        } else {
                          kiesActie(actie);
                        }
                      },
                      itemBuilder: (context) {
                        return [
                          const PopupMenuItem<NotitieActie?>(
                            value: null,
                            child: Text(
                              'Geen actie toevoegen',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const PopupMenuDivider(),
                          if (opgeslagenActies.isEmpty)
                            const PopupMenuItem<NotitieActie?>(
                              enabled: false,
                              child: Text('Nog geen opgeslagen acties.'),
                            )
                          else
                            ...opgeslagenActies.map((actie) {
                              return PopupMenuItem<NotitieActie?>(
                                value: actie,
                                child: Text(actie.titel),
                              );
                            }),
                        ];
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                gekozenActie == null
                                    ? 'Kies hier een actie'
                                    : gekozenActie!.titel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: gekozenActie == null
                                      ? Colors.grey.shade600
                                      : Colors.black,
                                ),
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 52,
                      width: 52,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Annuleren'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                        ),
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

class NotitieActieMakenPagina extends StatefulWidget {
  final List<NotitieActie> opgeslagenActies;

  const NotitieActieMakenPagina({
    super.key,
    required this.opgeslagenActies,
  });

  @override
  State<NotitieActieMakenPagina> createState() =>
      _NotitieActieMakenPaginaState();
}

class _NotitieActieMakenPaginaState extends State<NotitieActieMakenPagina> {
  final titelController = TextEditingController();

  bool toevoegenAanDagtaak = true;
  String datumKeuze = 'morgen';
  DateTime? gekozenDatum;
  String kleurNaam = 'groen';

  late List<NotitieActie> opgeslagenActies;
  NotitieActie? actieDieWeAanpassen;

  final List<String> kleuren = [
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
    opgeslagenActies = [...widget.opgeslagenActies];
  }

  @override
  void dispose() {
    titelController.dispose();
    super.dispose();
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

  Future<void> kiesVrijeDatum() async {
    final vandaag = DateTime.now();

    final gekozen = await showDatePicker(
      context: context,
      initialDate: gekozenDatum ?? vandaag,
      firstDate: DateTime(vandaag.year - 1),
      lastDate: DateTime(vandaag.year + 5),
    );

    if (gekozen == null) return;

    setState(() {
      datumKeuze = 'vrijeDag';
      gekozenDatum = DateTime(gekozen.year, gekozen.month, gekozen.day);
    });
  }

  DateTime? actieDatum() {
    if (!toevoegenAanDagtaak) return null;

    if (datumKeuze == 'morgen') {
      final morgen = DateTime.now().add(const Duration(days: 1));
      return DateTime(morgen.year, morgen.month, morgen.day);
    }

    return gekozenDatum;
  }

  Future<void> actieOpslaan() async {
    final titel = titelController.text.trim();

    if (titel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Geef een titel voor de actie in.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (toevoegenAanDagtaak && actieDatum() == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kies eerst een datum.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final nieuweActie = NotitieActie(
      id: actieDieWeAanpassen?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      titel: titel,
      toevoegenAanDagtaak: toevoegenAanDagtaak,
      datum: actieDatum(),
      kleurNaam: kleurNaam,
      afgewerkt: false,
    );

    final index = opgeslagenActies.indexWhere(
      (a) => a.id == nieuweActie.id,
    );

    setState(() {
      if (index >= 0) {
        opgeslagenActies[index] = nieuweActie;
      } else {
        opgeslagenActies.add(nieuweActie);
      }

      actieDieWeAanpassen = null;
      titelController.clear();
      toevoegenAanDagtaak = true;
      datumKeuze = 'morgen';
      gekozenDatum = null;
      kleurNaam = 'groen';
    });

    await AppStorage.bewaarNotitieActies(opgeslagenActies);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Actie opgeslagen.'),
      ),
    );
  }

  Future<void> verwijderOpgeslagenActie(NotitieActie actie) async {
    setState(() {
      opgeslagenActies.removeWhere((a) => a.id == actie.id);
    });

    await AppStorage.bewaarNotitieActies(opgeslagenActies);
  }

  void startActieAanpassen(NotitieActie actie) {
    setState(() {
      actieDieWeAanpassen = actie;
      titelController.text = actie.titel;
      toevoegenAanDagtaak = actie.toevoegenAanDagtaak;
      gekozenDatum = actie.datum;
      datumKeuze = actie.datum == null ? 'morgen' : 'vrijeDag';
      kleurNaam = actie.kleurNaam;
    });
  }

  Widget groeneBalk() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0B7A3B), Color(0xFF23B15F)],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
          ),
          const Expanded(
            child: Text(
              'Actie maken',
              style: TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget kleurenBalk() {
    return Wrap(
      children: kleuren.map((naam) {
        final kleur = kleurUitNaam(naam);
        final actief = kleurNaam == naam;

        return InkWell(
          onTap: () {
            setState(() {
              kleurNaam = naam;
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

  Widget kaart(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gekozenKleur = kleurUitNaam(kleurNaam);

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
                  kaart([
                    TextField(
                      controller: titelController,
                      decoration: InputDecoration(
                        labelText: 'Titel actie',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ]),
                  kaart([
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: toevoegenAanDagtaak,
                      activeColor: Colors.green,
                      onChanged: (waarde) {
                        setState(() {
                          toevoegenAanDagtaak = waarde;
                        });
                      },
                      title: const Text(
                        'Toevoegen aan dagtaak',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (toevoegenAanDagtaak) ...[
                      RadioListTile<String>(
                        value: 'morgen',
                        groupValue: datumKeuze,
                        activeColor: Colors.green,
                        onChanged: (waarde) {
                          if (waarde == null) return;
                          setState(() {
                            datumKeuze = waarde;
                          });
                        },
                        title: const Text('Morgen'),
                      ),
                      RadioListTile<String>(
                        value: 'vrijeDag',
                        groupValue: datumKeuze,
                        activeColor: Colors.green,
                        onChanged: (_) => kiesVrijeDatum(),
                        title: const Text('Vrije dag kiezen'),
                        subtitle: Text(
                          gekozenDatum == null
                              ? 'Geen datum gekozen'
                              : '${gekozenDatum!.day.toString().padLeft(2, '0')}/'
                                  '${gekozenDatum!.month.toString().padLeft(2, '0')}/'
                                  '${gekozenDatum!.year}',
                        ),
                      ),
                    ],
                  ]),
                  kaart([
                    const Text(
                      'Kleur actie',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    kleurenBalk(),
                  ]),
                  if (opgeslagenActies.isNotEmpty)
                    kaart([
                      const Text(
                        'Opgeslagen acties',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...opgeslagenActies.map((actie) {
                        final kleur = kleurUitNaam(actie.kleurNaam);

                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 10,
                            backgroundColor: kleur,
                          ),
                          title: Text(actie.titel),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => startActieAanpassen(actie),
                                icon: const Icon(Icons.edit_outlined),
                                color: Colors.green,
                              ),
                              IconButton(
                                onPressed: () =>
                                    verwijderOpgeslagenActie(actie),
                                icon: const Icon(Icons.delete_outline),
                                color: Colors.red,
                              ),
                            ],
                          ),
                        );
                      }),
                    ]),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: actieOpslaan,
                      icon: const Icon(Icons.save),
                      label: Text(
                        actieDieWeAanpassen == null
                            ? 'Actie opslaan'
                            : 'Actie aanpassen',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gekozenKleur,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AfgewerkteNotitiesPagina extends StatelessWidget {
  final List<Notitie> notities;
  final Future<void> Function(Notitie) onTerugzetten;

  const AfgewerkteNotitiesPagina({
    super.key,
    required this.notities,
    required this.onTerugzetten,
  });

  String datumTekst(DateTime datum) {
    return '${datum.day.toString().padLeft(2, '0')}/'
        '${datum.month.toString().padLeft(2, '0')}/'
        '${datum.year}';
  }

  Widget groeneBalk(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0B7A3B), Color(0xFF23B15F)],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Afgewerkte notities',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            groeneBalk(context),
            Expanded(
              child: notities.isEmpty
                  ? const Center(
                      child: Text('Nog geen afgewerkte notities.'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(18),
                      itemCount: notities.length,
                      itemBuilder: (context, index) {
                        final notitie = notities[index];
                        final datum =
                            notitie.afgewerktOp ?? notitie.aangemaaktOp;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      datumTekst(datum),
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      notitie.titel,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  await onTerugzetten(notitie);
                                  if (context.mounted) Navigator.pop(context);
                                },
                                icon: const Icon(Icons.undo),
                                color: Colors.green,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
