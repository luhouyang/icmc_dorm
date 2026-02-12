import 'package:flutter/material.dart';
import 'package:icmc_dorm/services/auth_service/auth_service.dart';

class SmallAuthPage extends StatefulWidget {
  const SmallAuthPage({super.key});

  @override
  State<SmallAuthPage> createState() => _SmallAuthPageState();
}

class _SmallAuthPageState extends State<SmallAuthPage> {
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
