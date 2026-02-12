import 'package:flutter/material.dart';
import 'package:icmc_dorm/services/auth_service/auth_service.dart';

class LargeAuthPage extends StatefulWidget {
  const LargeAuthPage({super.key});

  @override
  State<LargeAuthPage> createState() => _LargeAuthPageState();
}

class _LargeAuthPageState extends State<LargeAuthPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => AuthService().signInWithGoogle(),
        child: Text("LOGIN", style: TextStyle(fontWeight: FontWeight.bold),),
      ),
    );
  }
}
