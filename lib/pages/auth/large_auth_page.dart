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
      child: TextButton(
        style: ButtonStyle(
          padding: WidgetStatePropertyAll(EdgeInsets.fromLTRB(16, 4, 16, 4)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          ),
        ),
        onPressed: () => AuthService().signInWithGoogle(),
        child: Text("LOGIN"),
      ),
    );
  }
}
