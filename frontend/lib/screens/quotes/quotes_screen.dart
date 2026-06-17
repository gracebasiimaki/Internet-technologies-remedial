import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/quote_model.dart';
import '../../services/api_service.dart';

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  QuoteModel? _quote;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuote();
  }

  Future<void> _loadQuote() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getDailyQuote();
      if (data != null && mounted) {
        setState(() {
          _quote = QuoteModel.fromJson(data);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Wisdom')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _quote == null
              ? const Center(child: Text('No quotes available'))
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [MindBloomTheme.primaryBlue, MindBloomTheme.accentPurple],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: MindBloomTheme.primaryBlue.withAlpha(60),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.format_quote, color: Colors.white38, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                _quote!.content,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                '— ${_quote!.author}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _actionButton(Icons.refresh, 'New Quote', _loadQuote),
                            const SizedBox(width: 16),
                            _actionButton(Icons.share, 'Share', () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Sharing coming soon!')),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: MindBloomTheme.primaryBlue,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
