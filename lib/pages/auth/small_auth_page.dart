import 'package:flutter/material.dart';
import 'package:icmc_dorm/services/auth_service/auth_service.dart';
import 'package:icmc_dorm/widgets/h1_text.dart';

class SmallAuthPage extends StatefulWidget {
  const SmallAuthPage({super.key});

  @override
  State<SmallAuthPage> createState() => _SmallAuthPageState();
}

class _SmallAuthPageState extends State<SmallAuthPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const H1Text(text: "Login"),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            onPressed: () => AuthService().signInWithGoogle(),
            child: Text("Login with Google", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 32),
          const Text("To login with another email, clear cache first."),
        ],
      ),
    );
  }
}
