enum UserEnum {
  id("id"),
  name("name"),
  gender("gender"),
  contact("contact");

  final String value;
  const UserEnum(this.value);
}

class UserEntity {
  final String id; // firebase auth id
  final String name;
  final String gender;
  String contact;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  UserEntity({
    required this.id,
    required this.name,
    required this.gender,
    required this.contact,
  });

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: map[UserEnum.id.value],
      name: map[UserEnum.name.value],
      gender: map[UserEnum.gender.value],
      contact: map[UserEnum.contact.value],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      UserEnum.id.value: id,
      UserEnum.name.value: name,
      UserEnum.gender.value: gender,
      UserEnum.contact.value: contact,

    };
  }
}
