import 'package:flutter/material.dart';

class AgendaTopBalk extends StatelessWidget {
  final DateTime focusMaand;

  final VoidCallback onTerug;
  final VoidCallback onVorigeMaand;
  final VoidCallback onVolgendeMaand;
  final VoidCallback? onToevoegen;

  const AgendaTopBalk({
    super.key,
    required this.focusMaand,
    required this.onTerug,
    required this.onVorigeMaand,
    required this.onVolgendeMaand,
    this.onToevoegen,
  });

  String maandNaam(int maand) {
    const maanden = [
      '',
      'Januari',
      'Februari',
      'Maart',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Augustus',
      'September',
      'Oktober',
      'November',
      'December',
    ];

    return maanden[maand];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          10,
          10,
          10,
          6,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: const Color(
            0xFFF5F5F5,
          ),
          borderRadius: BorderRadius.circular(
            26,
          ),
        ),
        child: Row(
          children: [
            groeneKnop(Icons.home, onTerug),
            Expanded(
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: onVorigeMaand,
                      child: const Padding(
                        padding: EdgeInsets.all(
                          2,
                        ),
                        child: Icon(
                          Icons.chevron_left,
                          size: 24,
                          color: Color(
                            0xFF0B7A3B,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 2,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          maandNaam(
                            focusMaand.month,
                          ),
                          style: const TextStyle(
                            color: Color(
                              0xFF0B7A3B,
                            ),
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${focusMaand.year}',
                          style: const TextStyle(
                            color: Color(
                              0xFF0B7A3B,
                            ),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 2,
                    ),
                    InkWell(
                      onTap: onVolgendeMaand,
                      child: const Padding(
                        padding: EdgeInsets.all(
                          2,
                        ),
                        child: Icon(
                          Icons.chevron_right,
                          size: 24,
                          color: Color(
                            0xFF0B7A3B,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            groeneKnop(
              Icons.add,
              onToevoegen ?? () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget groeneKnop(
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        99,
      ),
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Color(
            0xFF0B7A3B,
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
