// lib/features/home/presentation/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../auth/presentation/auth_modal.dart';
import '../../auth/providers/auth_provider.dart';
import '../../notes_list/presentation/notes_list_screen.dart';
import '../../recording/presentation/recording_screen.dart';
import '../../text_input/presentation/text_input_screen.dart';
import 'widgets/recent_notes_widget.dart';
import 'widgets/record_button.dart';

class HomeScreen extends StatefulWidget {
  final bool autoStartRecording;
  final bool autoOpenTextInput;

  const HomeScreen({
    super.key,
    this.autoStartRecording = false,
    this.autoOpenTextInput = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // Handle auto-actions from onboarding
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.autoStartRecording) {
        _navigateToRecording();
      } else if (widget.autoOpenTextInput) {
        _navigateToTextInput();
      }
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
          onPressed: () {
            _showDrawer();
          },
        ),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              if (auth.isAuthenticated && auth.user != null) {
                return GestureDetector(
                  onTap: _showProfileMenu,
                  child: Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        auth.user!.name?.substring(0, 1).toUpperCase() ?? 'U',
                        style: AppTypography.labelMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return TextButton(
                onPressed: _showAuthModal,
                child: Text(
                  'Sign In',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),

              // Greeting
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    Text(
                      _getGreeting(),
                      style: AppTypography.displayMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      "What's on your mind?",
                      style: AppTypography.displayLarge.copyWith(fontSize: 28),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Recent notes (if authenticated)
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  if (auth.isAuthenticated) {
                    return Column(
                      children: const [
                        RecentNotesWidget(),
                        SizedBox(height: AppSpacing.xl),
                      ],
                    );
                  }
                  return const SizedBox(height: AppSpacing.xl);
                },
              ),

              // Main record button
              RecordButton(
                onTap: _navigateToRecording,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Secondary options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SecondaryInputButton(
                        icon: Icons.edit_note_rounded,
                        label: 'Text',
                        onTap: _navigateToTextInput,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: SecondaryInputButton(
                        icon: Icons.attach_file_rounded,
                        label: 'File',
                        onTap: _showComingSoon,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToRecording() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const RecordingScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: Duration(
          milliseconds: AppSpacing.animationNormal,
        ),
      ),
    );
  }

  void _navigateToTextInput() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TextInputScreen(),
      ),
    );
  }

  void _showAuthModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AuthModal(),
    );
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProfileMenu(),
    );
  }

  void _showDrawer() {
    final auth = context.read<AuthProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.borderRadiusLarge),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            if (auth.isAuthenticated) ...[
              ListTile(
                leading: const Icon(Icons.note_rounded),
                title: const Text('My Notes'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotesListScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
            ],

            ListTile(
              leading: const Icon(Icons.help_outline_rounded),
              title: const Text('Help & Tips'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help coming soon!')),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('About'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('About coming soon!')),
                );
              },
            ),

            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('File upload coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.borderRadiusLarge),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // User info
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primary,
            child: Text(
              auth.user?.name?.substring(0, 1).toUpperCase() ?? 'U',
              style: AppTypography.displayMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Text(
            auth.user?.name ?? 'User',
            style: AppTypography.headingLarge,
          ),

          Text(
            auth.user?.email ?? '',
            style: AppTypography.bodyMedium,
          ),

          const SizedBox(height: AppSpacing.lg),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Sign Out'),
            onTap: () async {
              await auth.signOut();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
