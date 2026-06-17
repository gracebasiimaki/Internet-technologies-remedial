import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/quote_model.dart';
import '../breathing/breathing_screen.dart';
import '../quotes/quotes_screen.dart';
import '../gems/gems_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  QuoteModel? _dailyQuote;
  int _gemBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final quoteData = await ApiService.getDailyQuote();
      if (quoteData != null && mounted) {
        setState(() => _dailyQuote = QuoteModel.fromJson(quoteData));
      }
    } catch (_) {}

    try {
      final gems = await ApiService.getGemBalance();
      if (gems != null && mounted) {
        setState(() => _gemBalance = (gems['balance'] as int?) ?? 0);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final firstName = user?.fullName.split(' ').first ?? 'Friend';

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: MindBloomTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          firstName,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // Gems badge
                    GestureDetector(
                      onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const GemsScreen())),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.diamond, color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '$_gemBalance',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Daily Quote Card
                if (_dailyQuote != null)
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const QuotesScreen())),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [MindBloomTheme.primaryBlue, MindBloomTheme.accentPurple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.format_quote, color: Colors.white54, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            _dailyQuote!.content,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '— ${_dailyQuote!.author}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _quickAction(
                      icon: Icons.air,
                      label: 'Breathing\nSOS',
                      color: MindBloomTheme.secondaryGreen,
                      onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const BreathingScreen())),
                    ),
                    const SizedBox(width: 12),
                    _quickAction(
                      icon: Icons.chat_bubble_outline,
                      label: 'Talk to\nBloom',
                      color: MindBloomTheme.primaryBlue,
                      onTap: () {},
                    ),
                    const SizedBox(width: 12),
                    _quickAction(
                      icon: Icons.mood,
                      label: 'Log\nMood',
                      color: MindBloomTheme.accentPurple,
                      onTap: () {},
                    ),
                    const SizedBox(width: 12),
                    _quickAction(
                      icon: Icons.book_outlined,
                      label: 'Write\nJournal',
                      color: const Color(0xFFE8A87C),
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Morning Ritual Card
                _featureCard(
                  title: 'Morning Soul Ritual',
                  subtitle: 'Start your day with intention',
                  icon: Icons.wb_sunny_outlined,
                  gradient: [const Color(0xFFFFB347), const Color(0xFFFF6B6B)],
                  onTap: () {},
                ),
                const SizedBox(height: 16),

                // Mood Insights
                _featureCard(
                  title: 'Mood Insights',
                  subtitle: 'Track your emotional patterns',
                  icon: Icons.insights,
                  gradient: [MindBloomTheme.secondaryGreen, const Color(0xFF4ECDC4)],
                  onTap: () {},
                ),
                const SizedBox(height: 16),

                // Mental Health Disclaimer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MindBloomTheme.primaryBlue.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: MindBloomTheme.primaryBlue.withAlpha(50)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: MindBloomTheme.primaryBlue, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'MindBloom is not a replacement for professional mental health treatment. '
                          'If you are in crisis, please contact emergency services.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: MindBloomTheme.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18),
          ],
        ),
      ),
    );
  }
}
