import 'dart:io';

import 'package:flutter/material.dart';

class KlantenficheFotoEditor extends StatelessWidget {
  final File bestand;

  const KlantenficheFotoEditor({
    super.key,
    required this.bestand,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Foto bewerken'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Opslaan',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Image.file(
          bestand,
          fit: BoxFit.contain,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 60,
          color: Colors.white,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.edit),
              Icon(Icons.text_fields),
              Icon(Icons.arrow_upward),
              Icon(Icons.circle_outlined),
              Icon(Icons.crop_square),
              Icon(Icons.delete_outline),
            ],
          ),
        ),
      ),
    );
  }
}
