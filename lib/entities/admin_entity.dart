enum AdminEnum {
  admins("admins");

  final String value;
  const AdminEnum(this.value);
}

class AdminEntity {
  List<dynamic> admins; // firebase auth id

  AdminEntity({required this.admins});

  factory AdminEntity.fromMap(Map<String, dynamic> map) {
    return AdminEntity(admins: map[AdminEnum.admins.value]);
  }

  Map<String, dynamic> toMap() {
    return {AdminEnum.admins.value: admins};
  }
}
