import 'package:flutter/material.dart';

class OpmetingRechthoekService {
  static Rect? maakRechthoek({
    required Offset startPunt,
    required Offset eindPunt,
    required double breedteMm,
    required double hoogteMm,
  }) {
    if (breedteMm <= 0 || hoogteMm <= 0) return null;

    final dx = eindPunt.dx - startPunt.dx;
    final dy = eindPunt.dy - startPunt.dy;

    if (dx.abs() < 1 && dy.abs() < 1) return null;

    final horizontaal = dx.abs() >= dy.abs();

    late double schermBreedte;
    late double schermHoogte;

    if (horizontaal) {
      schermBreedte = dx.abs();
      schermHoogte = schermBreedte * (hoogteMm / breedteMm);
    } else {
      schermHoogte = dy.abs();
      schermBreedte = schermHoogte * (breedteMm / hoogteMm);
    }

    if (horizontaal) {
      final left = startPunt.dx < eindPunt.dx ? startPunt.dx : eindPunt.dx;
      final top = startPunt.dy;

      return Rect.fromLTWH(
        left,
        top,
        schermBreedte,
        schermHoogte,
      );
    }

    final left = startPunt.dx;
    final top = startPunt.dy < eindPunt.dy ? startPunt.dy : eindPunt.dy;

    return Rect.fromLTWH(
      left,
      top,
      schermBreedte,
      schermHoogte,
    );
  }
}
