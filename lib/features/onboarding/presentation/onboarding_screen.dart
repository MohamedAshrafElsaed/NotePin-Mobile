// lib/features/onboarding/presentation/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/primary_button.dart';
import '../providers/onboarding_provider.dart';
import 'widgets/onboarding_page.dart';
import '../../home/presentation/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      icon: Icons.mic_rounded,
      title: 'Voice in. Clarity out.',
      subtitle: 'Record meetings, voice notes, or paste any text — get instant summaries and action items.',
      iconColor: AppColors.primary,
    ),
    OnboardingPageData(
      icon: Icons.auto_awesome_rounded,
      title: 'AI extracts what matters',
      subtitle: 'Smart summaries, action items with owners and dates, all organized automatically.',
      iconColor: AppColors.primary,
    ),
    OnboardingPageData(
      icon: Icons.rocket_launch_rounded,
      title: 'Ready to get organized?',
      subtitle: 'Record your first note and see the magic in seconds.',
      isFinalPage: true,
      iconColor: AppColors.primary,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<OnboardingProvider>(
          builder: (context, provider, _) {
            return Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: TextButton(
                      onPressed: () => _skipOnboarding(provider),
                      child: Text(
                        'Skip',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),

                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: provider.goToPage,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return OnboardingPage(data: _pages[index]);
                    },
                  ),
                ),

                // Page indicators
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                          (index) => AnimatedContainer(
                        duration: Duration(
                          milliseconds: AppSpacing.animationNormal,
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                        ),
                        width: provider.currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: provider.currentPage == index
                              ? AppColors.primary
                              : AppColors.textTertiary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.xl,
                  ),
                  child: provider.isLastPage
                      ? _buildFinalPageButtons(provider)
                      : _buildContinueButton(provider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContinueButton(OnboardingProvider provider) {
    return PrimaryButton(
      text: 'Continue',
      onPressed: () {
        _pageController.nextPage(
          duration: Duration(milliseconds: AppSpacing.animationNormal),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  Widget _buildFinalPageButtons(OnboardingProvider provider) {
    return Column(
      children: [
        PrimaryButton(
          text: '🎙️  Record First Note',
          onPressed: () => _completeAndNavigate(
            provider,
            startRecording: true,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton(
          onPressed: () => _completeAndNavigate(
            provider,
            openTextInput: true,
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.border),
          ),
          child: const Text('📝  Paste Text Instead'),
        ),
      ],
    );
  }

  Future<void> _skipOnboarding(OnboardingProvider provider) async {
    await provider.skipOnboarding();
    _navigateToHome();
  }

  Future<void> _completeAndNavigate(
      OnboardingProvider provider, {
        bool startRecording = false,
        bool openTextInput = false,
      }) async {
    await provider.completeOnboarding();

    if (!mounted) return;

    _navigateToHome(
      startRecording: startRecording,
      openTextInput: openTextInput,
    );
  }

  void _navigateToHome({
    bool startRecording = false,
    bool openTextInput = false,
  }) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return HomeScreen(
            autoStartRecording: startRecording,
            autoOpenTextInput: openTextInput,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: Duration(
          milliseconds: AppSpacing.animationSlow,
        ),
      ),
    );
  }
}