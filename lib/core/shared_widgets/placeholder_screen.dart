import 'package:flutter/material.dart';

import 'package:budget_app/core/shared_widgets/app_scaffold.dart';

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({required this.title, super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      child: Center(
        child: Text(
          '$title (Implementation Ready)',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
