enum RoomEnum {
  id("id"),
  name("name");

  final String value;
  const RoomEnum(this.value);
}

class RoomEntity {
  final String id; // firebase auth id
  String name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  RoomEntity({required this.id, required this.name});

  factory RoomEntity.fromMap(Map<String, dynamic> map) {
    return RoomEntity(id: map[RoomEnum.id.value], name: map[RoomEnum.name.value]);
  }

  Map<String, dynamic> toMap() {
    return {RoomEnum.id.value: id, RoomEnum.name.value: name};
  }
}
