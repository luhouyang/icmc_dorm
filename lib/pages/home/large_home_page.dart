import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:icmc_dorm/entities/record_entity.dart';
import 'package:icmc_dorm/states/app_state.dart';
import 'package:icmc_dorm/states/user_state.dart';
import 'package:icmc_dorm/widgets/loading_widget_large.dart';
import 'package:icmc_dorm/widgets/record_card.dart';
import 'package:icmc_dorm/widgets/ui_color.dart';
import 'package:provider/provider.dart';

class LargeHomePage extends StatefulWidget {
  const LargeHomePage({super.key});

  @override
  State<LargeHomePage> createState() => _LargeHomePageState();
}

class _LargeHomePageState extends State<LargeHomePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<AppState, UserState>(
      builder: (context, appState, userState, child) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                if (userState.userEntity.name == "username" ||
                    userState.userEntity.gender == "NA" ||
                    userState.userEntity.contact == "NA")
                  Container(
                    decoration: BoxDecoration(
                      color: UIColor().transparentPrimaryOrange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    width: 375,
                    height: 120,
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Welcome to the family", style: TextStyle(fontSize: 32)),
                        SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Introduce yourself", style: TextStyle(fontSize: 16)),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => appState.setBottomNavIndex(1),
                              child: Text("here", style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 16),
                if (userState.userEntity.name != "username" &&
                    userState.userEntity.gender != "NA" &&
                    userState.userEntity.contact != "NA")
                  // Add record form
                  Form(child: Text("data")),
                SizedBox(height: 16),
                StreamBuilder(
                  stream:
                      FirebaseFirestore.instance
                          .collection('records')
                          .where("uid", arrayContains: userState.userEntity.id)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const LoadingWidgetLarge();
                    } else if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingWidgetLarge();
                    }

                    if (snapshot.data!.size == 0) {
                      return Center(child: Text("No data yet 👾"));
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.size,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return RecordCard(
                          parentContext: context,
                          recordEntity: RecordEntity.fromMap(snapshot.data!.docs[index].data()),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
