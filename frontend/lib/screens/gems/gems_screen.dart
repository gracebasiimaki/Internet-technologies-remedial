import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class GemsScreen extends StatefulWidget {
  const GemsScreen({super.key});

  @override
  State<GemsScreen> createState() => _GemsScreenState();
}

class _GemsScreenState extends State<GemsScreen> {
  int _balance = 0;
  int _totalEarned = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    try {
      final data = await ApiService.getGemBalance();
      if (data != null && mounted) {
        setState(() {
          _balance = (data['balance'] as int?) ?? 0;
          _totalEarned = (data['totalEarned'] as int?) ?? 0;
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gems')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Balance card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withAlpha(60),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.diamond, color: Colors.white, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          '$_balance',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text('Gems Balance',
                            style: TextStyle(color: Colors.white70, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(
                          'Total earned: $_totalEarned',
                          style: const TextStyle(color: Colors.white60, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Earn gems section
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('How to Earn Gems',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  _earnCard(Icons.calendar_today, 'Daily Check-in', '+10 gems', MindBloomTheme.primaryBlue),
                  _earnCard(Icons.book, 'Complete Journal Entry', '+15 gems', MindBloomTheme.accentPurple),
                  _earnCard(Icons.self_improvement, 'Finish Meditation', '+20 gems', MindBloomTheme.secondaryGreen),
                  _earnCard(Icons.local_fire_department, '7-Day Streak', '+50 gems', Colors.orange),
                  _earnCard(Icons.emoji_events, 'Complete a Challenge', '+25 gems', const Color(0xFFE74C3C)),
                  _earnCard(Icons.share, 'Share a Quote', '+10 gems', Colors.teal),
                  _earnCard(Icons.mail, 'Write a Therapy Letter', '+30 gems', Colors.indigo),
                  _earnCard(Icons.person_add, 'Invite a Friend', '+100 gems', MindBloomTheme.gemGold),

                  const SizedBox(height: 24),

                  // Gem packages
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Buy Gems',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  _packageCard('Starter', '100 gems', '\$0.99'),
                  _packageCard('Popular', '500 gems', '\$3.99'),
                  _packageCard('Value', '1,200 gems', '\$7.99'),
                  _packageCard('Pro', '3,000 gems', '\$14.99'),
                  _packageCard('Mega', '10,000 gems', '\$39.99'),
                ],
              ),
            ),
    );
  }

  Widget _earnCard(IconData icon, String title, String reward, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: MindBloomTheme.gemGold.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(reward,
              style: const TextStyle(color: Color(0xFFB8860B), fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _packageCard(String name, String gems, String price) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.diamond, color: MindBloomTheme.gemGold),
        title: Text('$name — $gems', style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('In-app purchases coming with RevenueCat!')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: MindBloomTheme.gemGold,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(price),
        ),
      ),
    );
  }
}
