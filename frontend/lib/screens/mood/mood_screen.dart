import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/theme.dart';
import '../../models/mood_model.dart';
import '../../services/api_service.dart';

class MoodScreen extends ConsumerStatefulWidget {
  const MoodScreen({super.key});

  @override
  ConsumerState<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends ConsumerState<MoodScreen> {
  final List<MoodEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      final data = await ApiService.getMoodEntries();
      if (mounted) {
        setState(() {
          _entries.clear();
          for (final item in data) {
            _entries.add(MoodEntry.fromJson(item as Map<String, dynamic>));
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddMoodSheet() {
    int mood = 5, energy = 5, sleep = 5, anxiety = 5;
    final notesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('How are you feeling?',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                // Mood emoji row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _moodOption('😭', 'Terrible', 1, mood, (v) => setSheetState(() => mood = v)),
                    _moodOption('😢', 'Bad', 3, mood, (v) => setSheetState(() => mood = v)),
                    _moodOption('😐', 'Okay', 5, mood, (v) => setSheetState(() => mood = v)),
                    _moodOption('🙂', 'Good', 7, mood, (v) => setSheetState(() => mood = v)),
                    _moodOption('😊', 'Great', 9, mood, (v) => setSheetState(() => mood = v)),
                  ],
                ),
                const SizedBox(height: 20),

                _sliderRow('Energy', energy, (v) => setSheetState(() => energy = v)),
                _sliderRow('Sleep Quality', sleep, (v) => setSheetState(() => sleep = v)),
                _sliderRow('Anxiety', anxiety, (v) => setSheetState(() => anxiety = v)),
                const SizedBox(height: 12),

                TextField(
                  controller: notesCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Any notes about how you feel? (optional)',
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await ApiService.createMoodEntry({
                        'moodScore': mood,
                        'energyLevel': energy,
                        'sleepQuality': sleep,
                        'anxietyLevel': anxiety,
                        'notes': notesCtrl.text.isNotEmpty ? notesCtrl.text : null,
                      });
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                      _loadEntries();
                    },
                    child: const Text('Save Mood'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mood Tracker')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMoodSheet,
        icon: const Icon(Icons.add),
        label: const Text('Log Mood'),
        backgroundColor: MindBloomTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? _emptyState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chart
                      if (_entries.length >= 2) ...[
                        const Text('Mood Over Time',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: LineChart(_buildChart()),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Entries list
                      const Text('Recent Entries',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ..._entries.take(20).map((e) => _entryCard(e)),
                    ],
                  ),
                ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mood, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No mood entries yet',
              style: TextStyle(fontSize: 18, color: MindBloomTheme.textSecondary)),
          const SizedBox(height: 8),
          const Text('Tap + to log how you\'re feeling',
              style: TextStyle(color: MindBloomTheme.textSecondary)),
        ],
      ),
    );
  }

  LineChartData _buildChart() {
    final recent = _entries.take(14).toList().reversed.toList();
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(recent.length, (i) =>
            FlSpot(i.toDouble(), recent[i].moodScore.toDouble())),
          isCurved: true,
          color: MindBloomTheme.primaryBlue,
          barWidth: 3,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) =>
              FlDotCirclePainter(radius: 4, color: MindBloomTheme.primaryBlue, strokeWidth: 0),
          ),
          belowBarData: BarAreaData(
            show: true,
            color: MindBloomTheme.primaryBlue.withAlpha(30),
          ),
        ),
      ],
      minY: 0,
      maxY: 10,
    );
  }

  Widget _entryCard(MoodEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(entry.moodEmoji, style: const TextStyle(fontSize: 32)),
        title: Text(entry.moodLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          'Energy: ${entry.energyLevel}/10 • Sleep: ${entry.sleepQuality}/10',
          style: const TextStyle(color: MindBloomTheme.textSecondary, fontSize: 12),
        ),
        trailing: Text(
          entry.createdAt?.substring(0, 10) ?? '',
          style: const TextStyle(color: MindBloomTheme.textSecondary, fontSize: 12),
        ),
      ),
    );
  }

  Widget _moodOption(String emoji, String label, int value, int current, Function(int) onTap) {
    final selected = (current - value).abs() <= 1;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: selected ? MindBloomTheme.primaryBlue.withAlpha(25) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: selected ? Border.all(color: MindBloomTheme.primaryBlue, width: 2) : null,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 32)),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _sliderRow(String label, int value, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('$value/10', style: const TextStyle(color: MindBloomTheme.textSecondary)),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: MindBloomTheme.primaryBlue,
          onChanged: (v) => onChanged(v.round()),
        ),
      ],
    );
  }
}
