import 'package:flutter/material.dart';
import '../models/activity.dart';
import 'activity_card.dart';

class AnimatedActivityCard extends StatelessWidget {
  final Activity activity;
  final int index;
  final Animation<double> animation;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onLongPress;

  const AnimatedActivityCard({
    super.key,
    required this.activity,
    required this.index,
    required this.animation,
    required this.onIncrement,
    required this.onDecrement,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: animation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ActivityCard(
          activity: activity,
          onIncrement: onIncrement,
          onDecrement: onDecrement,
          onLongPress: onLongPress,
        ),
      ),
    );
  }
}
