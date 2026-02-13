import 'package:flutter/material.dart';
import 'package:icmc_dorm/states/constants.dart';

class H2Text extends StatelessWidget {
  final String text;

  const H2Text({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return MediaQuery.of(context).size.width > Constants().largeScreenWidth
        ? Text(text, textAlign: TextAlign.center, style: Theme.of(context).textTheme.displayMedium)
        : Text(text, textAlign: TextAlign.center, style: Theme.of(context).textTheme.displaySmall);
  }
}
