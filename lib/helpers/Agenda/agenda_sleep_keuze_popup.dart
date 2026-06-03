import 'package:flutter/material.dart';

enum AgendaSleepActie {
  verplaatsen,
  kopieren,
  tijdAanpassen,
  verwijderen,
}

class AgendaSleepKeuzeResultaat {
  final AgendaSleepActie actie;

  const AgendaSleepKeuzeResultaat({
    required this.actie,
  });
}

class AgendaSleepKeuzePopup {
  static Future<AgendaSleepKeuzeResultaat?> toon(
    BuildContext context,
  ) async {
    return showDialog<AgendaSleepKeuzeResultaat>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              22,
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 420,
            ),
            child: Padding(
              padding: const EdgeInsets.all(
                18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.open_with,
                        color: Color(
                          0xFF0B7A3B,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Expanded(
                        child: Text(
                          'Taak verplaatsen',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                          );
                        },
                        icon: const Icon(
                          Icons.close,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          const AgendaSleepKeuzeResultaat(
                            actie: AgendaSleepActie.verplaatsen,
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.drive_file_move,
                      ),
                      label: const Text(
                        'Verplaatsen',
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(
                          0,
                          52,
                        ),
                        backgroundColor: const Color(
                          0xFF0B7A3B,
                        ),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          const AgendaSleepKeuzeResultaat(
                            actie: AgendaSleepActie.kopieren,
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.copy,
                      ),
                      label: const Text(
                        'Kopiëren',
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(
                          0,
                          52,
                        ),
                        foregroundColor: const Color(
                          0xFF0B7A3B,
                        ),
                        side: const BorderSide(
                          color: Color(
                            0xFF0B7A3B,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          const AgendaSleepKeuzeResultaat(
                            actie: AgendaSleepActie.tijdAanpassen,
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.access_time,
                      ),
                      label: const Text(
                        'Tijd aanpassen',
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(
                          0,
                          52,
                        ),
                        foregroundColor: const Color(
                          0xFF0B7A3B,
                        ),
                        side: const BorderSide(
                          color: Color(
                            0xFF0B7A3B,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          const AgendaSleepKeuzeResultaat(
                            actie: AgendaSleepActie.verwijderen,
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                      ),
                      label: const Text(
                        'Verwijderen',
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(
                          0,
                          52,
                        ),
                        foregroundColor: Colors.red,
                        side: const BorderSide(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
