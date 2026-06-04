import 'dart:io';

import 'package:flutter/material.dart';

class KlantenficheFotoViewer extends StatelessWidget {
  final File bestand;

  const KlantenficheFotoViewer({
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
        elevation: 0,
        title: const Text('Foto'),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 5,
          child: Image.file(
            bestand,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
