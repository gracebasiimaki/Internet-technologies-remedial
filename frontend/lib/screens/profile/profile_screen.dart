import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: MindBloomTheme.primaryBlue,
              child: Text(
                user?.fullName.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.fullName ?? 'User',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '@${user?.username ?? 'user'}',
              style: const TextStyle(color: MindBloomTheme.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _tierColor(user?.subscriptionTier).withAlpha(25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _tierLabel(user?.subscriptionTier),
                style: TextStyle(
                  color: _tierColor(user?.subscriptionTier),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Info cards
            _infoTile(Icons.email_outlined, 'Email', user?.email ?? ''),
            _infoTile(Icons.cake_outlined, 'Age Group', _ageGroupLabel(user?.ageGroup)),
            _infoTile(Icons.language, 'Country', user?.country ?? 'Not set'),
            _infoTile(Icons.wc_outlined, 'Gender', user?.gender ?? 'Not set'),

            const SizedBox(height: 24),

            // Subscription upgrade card
            if (user?.subscriptionTier == 'SEEDLING')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [MindBloomTheme.primaryBlue, MindBloomTheme.accentPurple],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 32),
                    const SizedBox(height: 8),
                    const Text(
                      'Upgrade to Blooming',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Unlimited AI therapy, no ads, 2x gems',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Subscriptions via RevenueCat coming soon!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: MindBloomTheme.primaryBlue,
                      ),
                      child: const Text('\$9.99/month'),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Settings
            _settingsTile(Icons.notifications_outlined, 'Notifications', () {}),
            _settingsTile(Icons.lock_outline, 'Privacy & Security', () {}),
            _settingsTile(Icons.help_outline, 'Help & Support', () {}),
            _settingsTile(Icons.info_outline, 'About MindBloom', () {}),

            const SizedBox(height: 16),

            // Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => ref.read(authProvider.notifier).logout(),
                icon: const Icon(Icons.logout, color: MindBloomTheme.errorRed),
                label: const Text('Sign Out',
                    style: TextStyle(color: MindBloomTheme.errorRed)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: MindBloomTheme.errorRed),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Disclaimer
            Text(
              'MindBloom v1.0.0\nNot a replacement for professional mental health treatment.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: MindBloomTheme.primaryBlue),
        title: Text(label, style: const TextStyle(fontSize: 12, color: MindBloomTheme.textSecondary)),
        subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _settingsTile(IconData icon, String label, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: MindBloomTheme.textPrimary),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right, color: MindBloomTheme.textSecondary),
        onTap: onTap,
      ),
    );
  }

  Color _tierColor(String? tier) {
    return switch (tier) {
      'BLOOMING' => MindBloomTheme.primaryBlue,
      'FLOURISHING' => MindBloomTheme.accentPurple,
      _ => MindBloomTheme.secondaryGreen,
    };
  }

  String _tierLabel(String? tier) {
    return switch (tier) {
      'BLOOMING' => 'Blooming',
      'FLOURISHING' => 'Flourishing',
      _ => 'Seedling (Free)',
    };
  }

  String _ageGroupLabel(String? ag) {
    return switch (ag) {
      'TEEN' => 'Teen (13-17)',
      'GEN_Z' => 'Gen Z (18-25)',
      'YOUNG_PROFESSIONAL' => 'Young Professional (26-35)',
      'PARENT' => 'Parent (36-45)',
      'MIDDLE_JOURNEY' => 'Middle Journey (46-60)',
      'ELDER' => 'Elder (60+)',
      _ => 'Unknown',
    };
  }
}
