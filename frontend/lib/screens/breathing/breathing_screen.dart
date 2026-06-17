import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  String _phase = 'Ready';
  String _technique = '4-7-8';
  bool _isActive = false;
  Timer? _phaseTimer;
  int _cycleCount = 0;
  int _totalSeconds = 0;

  final _techniques = {
    '4-7-8': {'inhale': 4, 'hold': 7, 'exhale': 8},
    'Box': {'inhale': 4, 'hold': 4, 'exhale': 4},
    'Deep': {'inhale': 5, 'hold': 2, 'exhale': 5},
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _phaseTimer?.cancel();
    super.dispose();
  }

  void _startBreathing() {
    setState(() {
      _isActive = true;
      _cycleCount = 0;
      _totalSeconds = 0;
    });
    _runCycle();
  }

  void _stopBreathing() {
    _phaseTimer?.cancel();
    _controller.stop();
    setState(() {
      _isActive = false;
      _phase = 'Done';
    });

    // Log session
    ApiService.logBreathingSession({
      'technique': _technique,
      'durationSeconds': _totalSeconds,
      'triggeredBySos': true,
    });
  }

  void _runCycle() {
    if (!_isActive) return;
    final t = _techniques[_technique]!;
    _doPhase('Breathe In...', t['inhale']!, true, () {
      _doPhase('Hold...', t['hold']!, false, () {
        _doPhase('Breathe Out...', t['exhale']!, false, () {
          _cycleCount++;
          if (_cycleCount < 4 && _isActive) {
            _runCycle();
          } else {
            _stopBreathing();
          }
        });
      });
    });
  }

  void _doPhase(String label, int seconds, bool expand, VoidCallback onDone) {
    setState(() => _phase = label);
    _totalSeconds += seconds;

    if (expand) {
      _controller.duration = Duration(seconds: seconds);
      _controller.forward(from: 0);
    } else if (label.contains('Out')) {
      _controller.duration = Duration(seconds: seconds);
      _controller.reverse(from: 1);
    }

    _phaseTimer = Timer(Duration(seconds: seconds), onDone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Breathing SOS', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Technique selector
            if (!_isActive)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _techniques.keys.map((t) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ChoiceChip(
                    label: Text(t),
                    selected: _technique == t,
                    onSelected: (v) => setState(() => _technique = t),
                    selectedColor: MindBloomTheme.primaryBlue,
                    labelStyle: TextStyle(
                      color: _technique == t ? Colors.white : Colors.white70,
                    ),
                    backgroundColor: Colors.white12,
                  ),
                )).toList(),
              ),
            const SizedBox(height: 40),

            // Breathing circle
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Container(
                  width: 200 * _scaleAnimation.value,
                  height: 200 * _scaleAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        MindBloomTheme.primaryBlue.withAlpha(180),
                        MindBloomTheme.accentPurple.withAlpha(100),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: MindBloomTheme.primaryBlue.withAlpha(60),
                        blurRadius: 40,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Phase text
            Text(
              _phase,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            if (_isActive)
              Text(
                'Cycle ${_cycleCount + 1} of 4',
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
            const SizedBox(height: 48),

            // Start/Stop button
            ElevatedButton(
              onPressed: _isActive ? _stopBreathing : _startBreathing,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isActive ? MindBloomTheme.errorRed : MindBloomTheme.secondaryGreen,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                _isActive ? 'Stop' : 'Start Breathing',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),

            if (!_isActive && _phase == 'Done')
              Text(
                'Great job! You completed $_cycleCount cycles.',
                style: const TextStyle(color: MindBloomTheme.secondaryGreen, fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
