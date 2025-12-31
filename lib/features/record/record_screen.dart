import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';
import '../../services/api_service.dart';
import '../../services/audio_service.dart';
import '../process/process_screen.dart';
import 'record_controller.dart';
import 'record_state.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final RecordController _controller = RecordController();
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final AudioService _audioService = AudioService();
  GoogleSignInAccount? _currentUser;
  bool _isPlaying = false;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerUpdate);
    _initializeGoogleSignIn();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    setState(() {});
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize();

      // Listen for authentication events
      _authSubscription = _googleSignIn.authenticationEvents.listen(
        _handleAuthenticationEvent,
        onError: (error) {
          debugPrint('Auth error: $error');
        },
      );

      // Attempt lightweight (silent) authentication
      await _googleSignIn.attemptLightweightAuthentication();
    } catch (e) {
      debugPrint('Google Sign-In initialization error: $e');
    }
  }

  void _handleAuthenticationEvent(GoogleSignInAuthenticationEvent event) {
    setState(() {
      _currentUser = switch (event) {
        GoogleSignInAuthenticationEventSignIn(:final user) => user,
        GoogleSignInAuthenticationEventSignOut() => null,
      };
    });

    // Save user if signed in
    if (_currentUser != null) {
      _saveUser(_currentUser!);
    }
  }

  Future<void> _saveUser(GoogleSignInAccount account) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', account.id);
    await prefs.setString('user_email', account.email);
    await prefs.setString('user_name', account.displayName ?? '');
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.authenticate();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in failed: $error')),
      );
    }
  }

  Future<void> _handleSignOut() async {
    try {
      await _googleSignIn.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (error) {
      debugPrint('Sign out error: $error');
    }
  }

  Future<void> _handleUpload() async {
    if (_controller.state.audioPath == null) return;

    _controller.setUploading();

    try {
      final apiService = ApiService();
      final result =
          await apiService.uploadRecording(_controller.state.audioPath!);

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProcessScreen(recordingId: result['id']),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
      setState(() {});
    }
  }

  Future<void> _togglePlayback() async {
    if (_controller.state.audioPath == null) return;

    if (_isPlaying) {
      await _audioService.stopPlayback();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await _audioService.playRecording(_controller.state.audioPath!);
      setState(() {
        _isPlaying = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NotePin'),
        actions: [
          if (_currentUser == null)
            TextButton.icon(
              onPressed: _handleSignIn,
              icon: const Icon(Icons.login, size: 18),
              label: const Text('Sign In'),
            )
          else
            PopupMenuButton(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.primaryOrange,
                      child: Text(
                        _currentUser!.displayName
                                ?.substring(0, 1)
                                .toUpperCase() ??
                            'U',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: false,
                  child: Text(_currentUser!.email),
                ),
                PopupMenuItem(
                  onTap: _handleSignOut,
                  child: const Text('Sign Out'),
                ),
              ],
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              if (state.status == RecordStatus.idle) ...[
                Text(
                  'Tap to record',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 48),
                GestureDetector(
                  onTap: _controller.startRecording,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ] else if (state.status == RecordStatus.recording ||
                  state.status == RecordStatus.paused) ...[
                Text(
                  state.formattedTime,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 64,
                        fontWeight: FontWeight.w300,
                      ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: state.status == RecordStatus.recording
                        ? AppTheme.primaryOrange
                        : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    state.status == RecordStatus.recording
                        ? Icons.mic
                        : Icons.pause,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: state.status == RecordStatus.recording
                          ? _controller.pauseRecording
                          : _controller.resumeRecording,
                      icon: Icon(
                        state.status == RecordStatus.recording
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      iconSize: 32,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      onPressed: _controller.stopRecording,
                      icon: const Icon(Icons.stop),
                      iconSize: 32,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ] else if (state.status == RecordStatus.stopped) ...[
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryOrange,
                  size: 80,
                ),
                const SizedBox(height: 24),
                Text(
                  'Recording complete',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _togglePlayback,
                  icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                  label: Text(_isPlaying ? 'Stop' : 'Preview'),
                ),
              ] else if (state.status == RecordStatus.uploading) ...[
                const CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
                ),
                const SizedBox(height: 24),
                Text(
                  'Uploading...',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
              const Spacer(),
              if (state.status == RecordStatus.stopped) ...[
                PrimaryButton(
                  text: 'Upload & Process',
                  onPressed: _handleUpload,
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  text: 'Discard',
                  onPressed: _controller.discardRecording,
                  backgroundColor: Colors.grey,
                ),
              ],
              if (state.error != null) ...[
                const SizedBox(height: 16),
                Text(
                  state.error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
