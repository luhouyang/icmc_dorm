import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:icmc_dorm/entities/record_entity.dart';
import 'package:icmc_dorm/entities/room_entity.dart';
import 'package:icmc_dorm/widgets/ui_color.dart';
import 'package:intl/intl.dart';

class RecordCard extends StatefulWidget {
  final BuildContext parentContext;
  final RecordEntity recordEntity;
  final List<RoomEntity> rooms;
  final String displayName; // Added to accept the pre-loaded name
  final Function(RecordEntity) onEdit;

  const RecordCard({
    super.key,
    required this.parentContext,
    required this.recordEntity,
    required this.rooms,
    required this.displayName, // Initialize here
    required this.onEdit,
  });

  @override
  State<RecordCard> createState() => _RecordCardState();
}

class _RecordCardState extends State<RecordCard> {
  @override
  Widget build(BuildContext context) {
    final room = widget.rooms.firstWhere(
      (r) => r.id == widget.recordEntity.roomId,
      orElse: () => RoomEntity(id: "N/A", name: "Unknown Room"),
    );

    final entryStr = DateFormat('yyyy-MM-dd HH:mm').format(widget.recordEntity.checkinTime.toDate());
    final exitStr = DateFormat('yyyy-MM-dd HH:mm').format(widget.recordEntity.checkoutTime.toDate());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ExpansionTile(
        // Use the passed displayName instead of a FutureBuilder
        title: Text(widget.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Stay: $entryStr\tto\t$exitStr\nRoom: ${room.name}"),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => widget.onEdit(widget.recordEntity),
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit"),
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(UIColor().primaryBlue),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () => _confirmDelete(),
                  icon: Icon(Icons.delete, color: UIColor().white),
                  label: Text("Delete", style: TextStyle(color: UIColor().white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(4)),
            backgroundColor: UIColor().lightGray,
            title: Text("Delete Record?", style: TextStyle(color: UIColor().primaryDarkRed)),
            actions: [
              TextButton(
                style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(UIColor().primaryBlue)),
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('records')
                      .doc(widget.recordEntity.id)
                      .delete()
                      .then((value) => Navigator.pop(context));
                },
                child: const Text("Delete"),
              ),
            ],
          ),
    );
  }
}
