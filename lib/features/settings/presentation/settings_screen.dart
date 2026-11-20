import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/providers/backend_provider.dart';
import '../../../data/providers/progress_provider.dart';
import '../../../shared/widgets/neo_button.dart';
import '../../../shared/widgets/neo_card.dart';
import '../../../shared/widgets/neo_icon.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  bool _hapticsEnabled = true;

  @override
  void initState() {
    super.initState();
    final audioHaptic = ref.read(audioHapticServiceProvider);
    _musicEnabled = audioHaptic.isMusicEnabled;
    _sfxEnabled = audioHaptic.isSfxEnabled;
    _hapticsEnabled = audioHaptic.isHapticsEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: NeoButton.icon(
          icon: NeoIconType.chevronLeft,
          onPressed: () => context.pop(),
        ),
        title: const Text('SETTINGS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text('v1.0.0', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('AUDIO & HAPTICS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          NeoCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildToggleRow('Music', _musicEnabled, (val) {
                  setState(() => _musicEnabled = val);
                  ref.read(audioHapticServiceProvider).isMusicEnabled = val;
                }),
                const Divider(height: 1),
                _buildToggleRow('Sound Effects (SFX)', _sfxEnabled, (val) {
                  setState(() => _sfxEnabled = val);
                  ref.read(audioHapticServiceProvider).isSfxEnabled = val;
                }),
                const Divider(height: 1),
                _buildToggleRow('Haptic Feedback (Vibration)', _hapticsEnabled, (val) {
                  setState(() => _hapticsEnabled = val);
                  ref.read(audioHapticServiceProvider).isHapticsEnabled = val;
                }),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text('ACCOUNT & CLOUD PROGRESS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          NeoCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const NeoIcon(type: NeoIconType.checkmark, size: 22, color: AppColors.accentSecondary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cloud Progress Sync', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(
                        'Connected as ${ref.watch(playerProfileProvider).displayName}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await ref.read(playerProfileProvider.notifier).syncWithCloud();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cloud Progress Synchronized Successfully!')),
                      );
                    }
                  },
                  child: const Text('Sync Now', style: TextStyle(color: AppColors.brandPrimary, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text('SUPPORT & ABOUT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          NeoCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildNavRow('How to Play / Rules', () {}),
                const Divider(height: 1),
                _buildNavRow('Privacy Policy & Terms', () {}),
                const Divider(height: 1),
                _buildNavRow('Restore Purchases', () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          Switch(
            value: value,
            activeColor: AppColors.brandPrimary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildNavRow(String title, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        trailing: const NeoIcon(type: NeoIconType.chevronRight, size: 16, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
