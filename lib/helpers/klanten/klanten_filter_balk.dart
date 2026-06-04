import 'package:flutter/material.dart';

class KlantenFilterBalk extends StatelessWidget {
  final List<String> opties;
  final String geselecteerd;
  final ValueChanged<String> onGekozen;

  const KlantenFilterBalk({
    super.key,
    required this.opties,
    required this.geselecteerd,
    required this.onGekozen,
  });

  static const groen = Color(0xFF0B7A3B);
  static const lichtGroen = Color(0xFF7BC67E);
  static const geel = Colors.amber;
  static const paars = Colors.purple;
  static const rood = Colors.red;
  static const blauw = Colors.blue;

  Color _kleurVoorOptie(String optie) {
    switch (optie) {
      // Klantstatus
      case 'Actief':
        return lichtGroen;

      case 'Opvolgen':
        return geel;

      case 'Nadienst':
        return paars;

      case 'Afgewerkt':
        return groen;

      // Bestelstatus
      case 'Te bestellen':
        return rood;

      case 'Besteld':
        return blauw;

      case 'Geleverd':
        return lichtGroen;

      case 'Geen artikelen':
        return groen;

      case 'Alle':
      default:
        return groen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: Row(
        children: opties.map((optie) {
          final actief = optie == geselecteerd;
          final kleur = _kleurVoorOptie(optie);

          return Expanded(
            child: InkWell(
              onTap: () => onGekozen(optie),
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              focusColor: Colors.transparent,
              overlayColor: WidgetStateProperty.all(
                Colors.transparent,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (actief)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.check,
                              size: 14,
                              color: kleur,
                            ),
                          ),
                        Flexible(
                          child: Text(
                            optie,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 2,
                    width: double.infinity,
                    color: actief ? kleur : Colors.transparent,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
