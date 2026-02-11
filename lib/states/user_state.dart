import 'package:flutter/material.dart';
import 'package:icmc_dorm/entities/user_entity.dart';

class UserState extends ChangeNotifier {
  UserEntity userEntity = UserEntity(id: 'NA', name: 'NA', gender: '_', contact: 'NA');

  void setUserEntity({required UserEntity newUserEntity}) {
    userEntity = newUserEntity;
    notifyListeners();
  }

  void clearUserEntity() {
    userEntity = UserEntity(id: 'NA', name: 'NA', gender: '_', contact: 'NA');
    notifyListeners();
  }
}
