import 'package:flutter/material.dart';

class LargeProfilePage extends StatefulWidget {
  const LargeProfilePage({super.key});

  @override
  State<LargeProfilePage> createState() => _LargeProfilePageState();
}

class _LargeProfilePageState extends State<LargeProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          child: Column(
            children: [
              // Name

              // Gender & Contact
              Row(children: []),
            ],
          ),
        ),
      ),
    );
  }
}
