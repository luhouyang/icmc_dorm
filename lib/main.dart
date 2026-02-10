import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:icmc_dorm/firebase_options.dart';
import 'package:icmc_dorm/pages/auth/route_auth_page.dart';
import 'package:icmc_dorm/states/app_state.dart';
import 'package:icmc_dorm/states/user_state.dart';
import 'package:icmc_dorm/widgets/ui_color.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        ChangeNotifierProvider(create: (context) => UserState()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ICMC Dorm',
        theme: lightTheme,
        home: const RouteAuthPage(),
      ),
    );
  }
}
