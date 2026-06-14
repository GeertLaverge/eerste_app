import 'package:flutter/material.dart';

import 'notitie_actie_model.dart';
import 'notitie_detail_popup.dart';
import 'notitie_model.dart';

class NotitieRegel extends StatefulWidget {
  const NotitieRegel({
    super.key,
    required this.notitie,
    required this.acties,
    required this.onChanged,
    required this.onDelete,
  });

  final NotitieModel notitie;
  final List<NotitieActieModel> acties;

  final ValueChanged<NotitieModel> onChanged;
  final ValueChanged<NotitieModel> onDelete;

  @override
  State<NotitieRegel> createState() => _NotitieRegelState();
}

class _NotitieRegelState extends State<NotitieRegel> {
  late final TextEditingController _titelController;
  final FocusNode _titelFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _titelController = TextEditingController(text: widget.notitie.titel);
  }

  @override
  void didUpdateWidget(covariant NotitieRegel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.notitie.id != widget.notitie.id) {
      _titelController.text = widget.notitie.titel;
    }
  }

  @override
  void dispose() {
    _titelController.dispose();
    _titelFocusNode.dispose();
    super.dispose();
  }

  Future<void> _openDetail() async {
    _titelFocusNode.unfocus();

    final nieuweDetail = await showDialog<String>(
      context: context,
      builder: (context) {
        return NotitieDetailPopup(
          titel:
              widget.notitie.titel.isEmpty ? 'Notitie' : widget.notitie.titel,
          detail: widget.notitie.detail,
        );
      },
    );

    if (nieuweDetail == null) return;

    widget.notitie.detail = nieuweDetail;
    widget.notitie.gewijzigdOp = DateTime.now();
    widget.onChanged(widget.notitie);
  }

  NotitieActieModel? _gekozenActie() {
    for (final actie in widget.acties) {
      if (actie.id == widget.notitie.actieId) return actie;
    }
    return null;
  }

  void _bewaarWijziging() {
    widget.notitie.gewijzigdOp = DateTime.now();
    widget.onChanged(widget.notitie);
  }

  @override
  Widget build(BuildContext context) {
    final actie = _gekozenActie();

    final tekstKleur = widget.notitie.afgewerkt
        ? const Color(0xFF9CA3AF)
        : const Color(0xFF111827);

    return KeyedSubtree(
      key: ValueKey(widget.notitie.id),
      child: Draggable<NotitieModel>(
        data: widget.notitie,
        feedback: Material(
          color: Colors.transparent,
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Text(widget.notitie.titel),
          ),
        ),
        child: Container(
          height: 42,
          padding: const EdgeInsets.only(left: 4, right: 4),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Transform.scale(
                  scale: 0.72,
                  child: Checkbox(
                    key: ValueKey('check_${widget.notitie.id}'),
                    value: widget.notitie.afgewerkt,
                    activeColor: const Color(0xFF0B7A3B),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (waarde) {
                      _titelFocusNode.unfocus();
                      widget.notitie.afgewerkt = waarde ?? false;
                      _bewaarWijziging();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: TextField(
                  key: ValueKey('titel_${widget.notitie.id}'),
                  focusNode: _titelFocusNode,
                  controller: _titelController,
                  decoration: const InputDecoration(
                    hintText: 'Titel notitie...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: tekstKleur,
                    decoration: widget.notitie.afgewerkt
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                  onChanged: (waarde) {
                    widget.notitie.titel = waarde;
                    _bewaarWijziging();
                  },
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                key: ValueKey('actie_${widget.notitie.id}'),
                tooltip: 'Actie kiezen',
                padding: EdgeInsets.zero,
                color: Colors.white,
                constraints: const BoxConstraints(
                  minWidth: 160,
                ),
                onOpened: () {
                  _titelFocusNode.unfocus();
                },
                onSelected: (waarde) {
                  widget.notitie.actieId = waarde == '_geen_' ? '' : waarde;
                  _bewaarWijziging();
                },
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem<String>(
                      value: '_geen_',
                      child: Text(
                        'Geen actie',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ...widget.acties.map((actie) {
                      return PopupMenuItem<String>(
                        value: actie.id,
                        child: Text(
                          actie.naam,
                          style: TextStyle(
                            color: Color(actie.kleurWaarde),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }),
                  ];
                },
                child: SizedBox(
                  width: 86,
                  child: Text(
                    actie?.naam ?? 'Geen actie',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: actie == null
                          ? const Color(0xFF6B7280)
                          : Color(actie.kleurWaarde),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: _openDetail,
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Icon(
                    widget.notitie.detail.trim().isEmpty
                        ? Icons.sticky_note_2_outlined
                        : Icons.sticky_note_2,
                    size: 17,
                    color: const Color(0xFF0B7A3B),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              InkWell(
                onTap: () {
                  _titelFocusNode.unfocus();
                  widget.onDelete(widget.notitie);
                },
                child: const Padding(
                  padding: EdgeInsets.all(3),
                  child: Icon(
                    Icons.delete_outline,
                    size: 17,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
