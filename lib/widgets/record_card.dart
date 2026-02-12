import 'package:flutter/material.dart';
import 'package:icmc_dorm/entities/record_entity.dart';

class RecordCard extends StatefulWidget {
  final BuildContext parentContext;
  final RecordEntity recordEntity;

  const RecordCard({super.key, required this.parentContext, required this.recordEntity});

  @override
  State<RecordCard> createState() => _RecordCardState();
}

class _RecordCardState extends State<RecordCard> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(title: Text("data"), children: [Text("data")]);
  }
}
