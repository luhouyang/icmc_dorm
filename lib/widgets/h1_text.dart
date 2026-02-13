import 'package:flutter/material.dart';
import 'package:icmc_dorm/states/constants.dart';

class H1Text extends StatelessWidget {
  final String text;

  const H1Text({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width > Constants().largeScreenWidth
        ? Text(text, textAlign: TextAlign.center, style: Theme.of(context).textTheme.displayLarge)
        : Text(text, textAlign: TextAlign.center, style: Theme.of(context).textTheme.displayMedium);
  }
}
