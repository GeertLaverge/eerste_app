// THIMACO-CONTROLE: WINDOWS-WERKBLADEN-SCOPE-20261114
import 'package:flutter/material.dart';

/// Herkent een tabblad-omgeving zonder de bestaande Navigator-routes te breken.
class ThimacoWerkbladenScope extends InheritedWidget {
  const ThimacoWerkbladenScope({
    super.key,
    required this.naarDashboard,
    required super.child,
  });

  final Future<void> Function() naarDashboard;

  static ThimacoWerkbladenScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThimacoWerkbladenScope>();
  }

  @override
  bool updateShouldNotify(ThimacoWerkbladenScope oldWidget) =>
      oldWidget.naarDashboard != naarDashboard;
}

