import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<Map<String, dynamic>> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      final data = await ApiService.getJournalEntries();
      if (mounted) {
        setState(() {
          _entries = data.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showNewEntryDialog() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    int moodBefore = 5, moodAfter = 5;

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
                const Text('New Journal Entry',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Title (optional)',
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: contentCtrl,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'Write freely... this is your safe space.',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mood Before: $moodBefore/10',
                              style: const TextStyle(fontSize: 12)),
                          Slider(
                            value: moodBefore.toDouble(),
                            min: 1, max: 10, divisions: 9,
                            activeColor: MindBloomTheme.primaryBlue,
                            onChanged: (v) => setSheetState(() => moodBefore = v.round()),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mood After: $moodAfter/10',
                              style: const TextStyle(fontSize: 12)),
                          Slider(
                            value: moodAfter.toDouble(),
                            min: 1, max: 10, divisions: 9,
                            activeColor: MindBloomTheme.secondaryGreen,
                            onChanged: (v) => setSheetState(() => moodAfter = v.round()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (contentCtrl.text.trim().isEmpty) return;
                      await ApiService.createJournalEntry({
                        'title': titleCtrl.text.isNotEmpty ? titleCtrl.text : null,
                        'content': contentCtrl.text,
                        'moodBefore': moodBefore,
                        'moodAfter': moodAfter,
                      });
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                      _loadEntries();
                    },
                    child: const Text('Save Entry'),
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
      appBar: AppBar(title: const Text('Journal')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewEntryDialog,
        icon: const Icon(Icons.edit),
        label: const Text('New Entry'),
        backgroundColor: MindBloomTheme.accentPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? _emptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _entries.length,
                  itemBuilder: (ctx, i) => _entryCard(_entries[i]),
                ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('Your journal is empty',
              style: TextStyle(fontSize: 18, color: MindBloomTheme.textSecondary)),
          const SizedBox(height: 8),
          const Text('Start writing to unlock emotional insights',
              style: TextStyle(color: MindBloomTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _entryCard(Map<String, dynamic> entry) {
    final title = entry['title'] as String? ?? 'Untitled';
    final date = (entry['createdAt'] as String?)?.substring(0, 10) ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: MindBloomTheme.accentPurple.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.book, color: MindBloomTheme.accentPurple),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(date, style: const TextStyle(color: MindBloomTheme.textSecondary, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: MindBloomTheme.textSecondary),
      ),
    );
  }
}
