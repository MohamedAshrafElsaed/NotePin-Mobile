// lib/core/widgets/loading_view.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoadingView extends StatelessWidget {
  final String message;

  const LoadingView({
    super.key,
    this.message = 'Loading...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: Theme
                .of(context)
                .textTheme
                .bodyLarge,
          ),
        ],
      ),
    );
  }
}