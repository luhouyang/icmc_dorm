import 'package:flutter/material.dart';
import 'package:icmc_dorm/pages/navigator/large_router.dart';
import 'package:icmc_dorm/pages/navigator/small_router.dart';
import 'package:icmc_dorm/states/constants.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({super.key});

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return screenWidth > Constants().largeScreenWidth ? LargeRoutePage() : SmallRoutePage();
  }
}
