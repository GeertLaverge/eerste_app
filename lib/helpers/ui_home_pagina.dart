import 'package:flutter/material.dart';

class UiHelper {
  static Color kleurUitNaam(String naam) {
    switch (naam) {
      case 'blauw':
        return Colors.blue;
      case 'rood':
        return Colors.red;
      case 'paars':
        return Colors.purple;
      case 'teal':
        return Colors.teal;
      case 'grijs':
        return Colors.grey;
      case 'amber':
        return Colors.amber;
      case 'brown':
        return Colors.brown;
      case 'orange':
        return Colors.orange;
      case 'groen':
      default:
        return Colors.green;
    }
  }

  static IconData icoonUitNaam(String naam) {
    switch (naam) {
      case 'inventory_2':
      case 'puinzak':
        return Icons.inventory_2_outlined;
      case 'access_time':
      case 'tijd':
        return Icons.access_time;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'location_on':
        return Icons.location_on;
      case 'construction':
        return Icons.precision_manufacturing;
      case 'warning':
        return Icons.warning;
      case 'beach_access':
      case 'verlof':
        return Icons.beach_access;
      case 'build':
        return Icons.precision_manufacturing;
      case 'task_alt':
      case 'taak':
        return Icons.task_alt;
      case 'delete_sweep':
      case 'rolcontainer':
      default:
        return Icons.delete_sweep;
    }
  }
}
