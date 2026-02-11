import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:icmc_dorm/pages/auth/large_auth_page.dart';
import 'package:icmc_dorm/pages/auth/small_auth_page.dart';
import 'package:icmc_dorm/pages/navigator/router_page.dart';
import 'package:icmc_dorm/services/firestore_service/firestore_service.dart';
import 'package:icmc_dorm/states/constants.dart';
import 'package:icmc_dorm/states/user_state.dart';
import 'package:icmc_dorm/widgets/loading_widget_large.dart';
import 'package:provider/provider.dart';

class RouteAuthPage extends StatefulWidget {
  const RouteAuthPage({super.key});

  @override
  State<RouteAuthPage> createState() => _RouteAuthPageState();
}

class _RouteAuthPageState extends State<RouteAuthPage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    UserState userState = Provider.of<UserState>(context, listen: false);

    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (screenWidth > Constants().largeScreenWidth) {
              return LargeAuthPage();
            } else {
              return SmallAuthPage();
            }
          }

          if (userState.userEntity.id == 'NA') {
            return FutureBuilder(
              future: FirestoreService().getUser(context, snapshot.data!.uid, userState),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const LoadingWidgetLarge();
                } else if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidgetLarge();
                }

                return const RoutePage();
              },
            );
          }

          return RoutePage();
        },
      ),
    );
  }
}
