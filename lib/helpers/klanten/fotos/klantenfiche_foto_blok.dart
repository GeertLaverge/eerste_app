import 'dart:io';

import 'package:flutter/material.dart';

import '../fiche/klantenfiche_model.dart';
import 'klantenfiche_foto_service.dart';
import 'klantenfiche_foto_viewer.dart';
import 'mail/klantenfiche_foto_mail_pagina.dart';

class KlantenficheFotoBlok extends StatelessWidget {
  final String ficheId;
  final List<KlantenficheFoto> fotos;
  final Future<void> Function(List<KlantenficheFoto> nieuweFotos) onChanged;

  const KlantenficheFotoBlok({
    super.key,
    required this.ficheId,
    required this.fotos,
    required this.onChanged,
  });

  Future<void> _fotoNemen(BuildContext context) async {
    final nieuweFoto = await KlantenficheFotoService.neemFoto(
      ficheId: ficheId,
    );

    if (nieuweFoto == null) return;

    final nieuweFotos = List<KlantenficheFoto>.from(fotos)..add(nieuweFoto);

    await onChanged(nieuweFotos);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Foto opgeslagen.'),
        backgroundColor: Color(0xFF0B7A3B),
      ),
    );
  }

  Future<void> _fotoKiezen(BuildContext context) async {
    final nieuweFoto = await KlantenficheFotoService.kiesFoto(
      ficheId: ficheId,
    );

    if (nieuweFoto == null) return;

    final nieuweFotos = List<KlantenficheFoto>.from(fotos)..add(nieuweFoto);

    await onChanged(nieuweFotos);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Foto toegevoegd.'),
        backgroundColor: Color(0xFF0B7A3B),
      ),
    );
  }

  Future<void> _openMailScherm(
    BuildContext context,
  ) async {
    if (fotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Er zijn nog geen foto\'s om te mailen.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KlantenficheFotoMailPagina(
          ficheId: ficheId,
          fotos: fotos,
        ),
      ),
    );
  }

  Future<void> _verwijderFoto(
    BuildContext context,
    KlantenficheFoto foto,
  ) async {
    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Foto verwijderen?'),
          content: const Text(
            'Deze foto wordt uit deze klantenfiche verwijderd.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Annuleren'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Verwijderen',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (bevestigen != true) return;

    await KlantenficheFotoService.verwijderFoto(
      ficheId: ficheId,
      foto: foto,
    );

    final nieuweFotos = List<KlantenficheFoto>.from(fotos)..remove(foto);

    await onChanged(nieuweFotos);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _fotoNemen(context);
                },
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Foto nemen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B7A3B),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _fotoKiezen(context);
                },
                icon: const Icon(Icons.image_outlined),
                label: const Text('Kiezen'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0B7A3B),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                _openMailScherm(context);
              },
              icon: const Icon(
                Icons.email_outlined,
                color: Color(0xFF0B7A3B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (fotos.isEmpty)
          const Text(
            'Nog geen foto\'s toegevoegd.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
        if (fotos.isNotEmpty)
          Column(
            children: fotos.map((foto) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                  ),
                ),
                child: Row(
                  children: [
                    FutureBuilder<File>(
                      future: KlantenficheFotoService.fotoBestand(
                        ficheId: ficheId,
                        foto: foto,
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        }

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => KlantenficheFotoViewer(
                                  bestand: snapshot.data!,
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              snapshot.data!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            foto.bestandsNaam,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            foto.datum,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _verwijderFoto(
                          context,
                          foto,
                        );
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
