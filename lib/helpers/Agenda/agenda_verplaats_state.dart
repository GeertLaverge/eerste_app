import 'agenda_item.dart';

class AgendaVerplaatsState {
  final DateTime? oudeDag;
  final AgendaItem? item;

  const AgendaVerplaatsState({
    this.oudeDag,
    this.item,
  });

  bool get actief => oudeDag != null && item != null;

  AgendaVerplaatsState start({
    required DateTime oudeDag,
    required AgendaItem item,
  }) {
    return AgendaVerplaatsState(
      oudeDag: oudeDag,
      item: item,
    );
  }

  AgendaVerplaatsState stop() {
    return const AgendaVerplaatsState();
  }
}
