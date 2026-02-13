import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:icmc_dorm/entities/record_entity.dart';
import 'package:icmc_dorm/entities/user_entity.dart';
import 'package:icmc_dorm/states/user_state.dart';
import 'package:icmc_dorm/widgets/snack_bar_text.dart';

class FirestoreService {
  Future<UserEntity> getUser(BuildContext context, String id, UserState userState) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      DocumentSnapshot doc = await firestore.collection('users').doc(id).get();

      if (doc.exists) {
        UserEntity userEntity = UserEntity.fromMap(doc.data() as Map<String, dynamic>);

        userState.setUserEntity(newUserEntity: userEntity);

        return userEntity;
      } else {
        UserEntity userEntity = UserEntity(id: id, name: 'username', gender: '男生', contact: 'NA');

        try {
          await firestore.collection('users').doc(id).set(userEntity.toMap());

          userState.setUserEntity(newUserEntity: userEntity);

          return userEntity;
        } catch (e) {
          context.mounted
              ? SnackBarText().showBanner(msg: e.toString(), context: context)
              : debugPrint(e.toString());
        }
      }
    } catch (e) {
      context.mounted
          ? SnackBarText().showBanner(msg: e.toString(), context: context)
          : debugPrint(e.toString());
    }

    return UserEntity(id: 'NO_ID', name: 'NO_NAME', gender: '男生', contact: 'NA');
  }

  Future<void> updateUser(BuildContext context, UserEntity userEntity, String uid) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection("users").doc(uid).set(userEntity.toMap());
    } catch (e) {
      context.mounted
          ? SnackBarText().showBanner(msg: e.toString(), context: context)
          : debugPrint(e.toString());
    }
  }

  Future<void> addRecord(BuildContext context, RecordEntity recordEntity) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection("records").doc(recordEntity.id).set(recordEntity.toMap());
    } catch (e) {
      context.mounted
          ? SnackBarText().showBanner(msg: e.toString(), context: context)
          : debugPrint(e.toString());
    }
  }
}
