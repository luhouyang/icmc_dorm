import 'package:cloud_firestore/cloud_firestore.dart';

enum RecordEnum {
  id("id"),
  roomId("roomId"),
  uid("uid"),
  checkinTime("checkinTime"),
  checkoutTime("checkoutTime");

  final String value;
  const RecordEnum(this.value);
}

class RecordEntity {
  final String id; // firebase auth id
  String roomId;
  final List<dynamic> uid;
  Timestamp checkinTime;
  Timestamp checkoutTime;

  RecordEntity({
    required this.id,
    required this.roomId,
    required this.uid,
    required this.checkinTime,
    required this.checkoutTime,
  });

  factory RecordEntity.fromMap(Map<String, dynamic> map) {
    return RecordEntity(
      id: map[RecordEnum.id.value],
      roomId: map[RecordEnum.roomId.value],
      uid: map[RecordEnum.uid.value],
      checkinTime: map[RecordEnum.checkinTime.value] as Timestamp,
      checkoutTime: map[RecordEnum.checkoutTime.value] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      RecordEnum.id.value: id,
      RecordEnum.roomId.value: roomId,
      RecordEnum.uid.value: uid,
      RecordEnum.checkinTime.value: checkinTime,
      RecordEnum.checkoutTime.value: checkoutTime,
    };
  }
}
