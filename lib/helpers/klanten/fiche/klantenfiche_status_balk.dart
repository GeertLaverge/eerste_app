import 'package:flutter/material.dart';

class KlantenficheStatusBalk extends StatelessWidget {
  final String geselecteerd;
  final ValueChanged<String> onGekozen;

  const KlantenficheStatusBalk({
    super.key,
    required this.geselecteerd,
    required this.onGekozen,
  });

  static const groen = Color(0xFF0B7A3B);

  @override
  Widget build(BuildContext context) {
    const opties = [
      'Actief',
      'Opvolgen',
      'Afgewerkt',
    ];

    return Container(
      color: Colors.white,
      child: SizedBox(
        height: 46,
        child: Row(
          children: opties.map((optie) {
            final actief = optie == geselecteerd;

            return Expanded(
              child: InkWell(
                onTap: () => onGekozen(optie),
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                focusColor: Colors.transparent,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (actief)
                            const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(
                                Icons.check,
                                size: 14,
                                color: groen,
                              ),
                            ),
                          Flexible(
                            child: Text(
                              optie,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
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
                      color: actief ? groen : Colors.transparent,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
