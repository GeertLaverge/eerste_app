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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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

                  // Lijn over volledige breedte van geselecteerde cel
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
    );
  }
}
