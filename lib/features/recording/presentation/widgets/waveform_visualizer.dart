// lib/features/recording/presentation/widgets/waveform_visualizer.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class WaveformVisualizer extends StatefulWidget {
  final bool isActive;
  final Color color;
  final int barCount;
  final double height;

  const WaveformVisualizer({
    super.key,
    required this.isActive,
    this.color = AppColors.primary,
    this.barCount = 40,
    this.height = 80,
  });

  @override
  State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<WaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  late List<double> _barHeights;

  @override
  void initState() {
    super.initState();
    _barHeights = List.generate(widget.barCount, (_) => 0.2);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..addListener(() {
      if (widget.isActive) {
        setState(() {
          _updateBarHeights();
        });
      }
    });

    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(WaveformVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat();
      } else {
        _controller.stop();
        setState(() {
          _barHeights = List.generate(widget.barCount, (_) => 0.2);
        });
      }
    }
  }

  void _updateBarHeights() {
    for (int i = 0; i < _barHeights.length; i++) {
      // Create wave-like pattern with randomness
      final baseHeight = sin((i / widget.barCount) * 2 * pi + _controller.value * 2 * pi) * 0.3 + 0.4;
      final randomFactor = _random.nextDouble() * 0.3;
      _barHeights[i] = (baseHeight + randomFactor).clamp(0.2, 1.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(
          widget.barCount,
              (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 3,
            height: widget.height * _barHeights[index],
            decoration: BoxDecoration(
              color: widget.isActive
                  ? widget.color.withOpacity(0.8)
                  : widget.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}