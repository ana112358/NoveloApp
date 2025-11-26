import 'package:flutter/material.dart';

class BigCounterCard extends StatelessWidget {
  final int counter;

  const BigCounterCard({super.key, required this.counter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: CircleBorder(),
      color: theme.colorScheme.primary,
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: Text(
            '$counter',
            style: theme.textTheme.displayLarge!.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
