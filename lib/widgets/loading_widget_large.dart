import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingWidgetLarge extends StatelessWidget {
  const LoadingWidgetLarge({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.staggeredDotsWave(
        color: Theme.of(context).primaryColor,
        size: 50,
      ),
    );
  }
}
