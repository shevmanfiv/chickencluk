import 'package:flutter/material.dart';
import 'package:cluck_rush/game/cluck_rush_game.dart';
import 'package:cluck_rush/constants/colors.dart';
import 'package:cluck_rush/constants/typography.dart';
import 'package:cluck_rush/services/storage_service.dart';

class MainMenu extends StatelessWidget {
  final CluckRushGame game;

  const MainMenu({super.key, required this.game});

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _SettingsDialog(game: game),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.3),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.skyBlue, AppColors.farmGreen],
            stops: [0.6, 0.6], 
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Egg Counter - Top Right
              Positioned(
                top: 16,
                right: 16,
                child: _EggCounter(),
              ),
              
              // Main Content - Centered
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo/Title
                    const Text(
                      'CLUCK\nRUSH',
                      style: AppTypography.logo,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    
                    // Chicken Image
                    Image.asset(
                      'assets/images/chicken_idle.png',
                      height: 150,
                    ),
                    const SizedBox(height: 60),

                    // Pulsating Play Button
                    _PulsatingPlayButton(
                      onTap: () {
                        game.overlays.remove('MainMenu');
                        game.overlays.add('LevelSelect');
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Coop / Settings buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _MenuButton(
                          icon: Icons.egg,
                          label: 'Coop',
                          onTap: () {
                            game.overlays.remove('MainMenu');
                            game.overlays.add('Hatchery');
                          },
                        ),
                        const SizedBox(width: 20),
                        _MenuButton(
                          icon: Icons.settings,
                          label: 'Settings',
                          onTap: () {
                            _showSettingsDialog(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EggCounter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final int eggCount = StorageService.instance.totalEggs;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.woodBrown,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inkBlack, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/collectible_egg.png',
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 6),
          Text(
            '$eggCount',
            style: AppTypography.hudText,
          ),
        ],
      ),
    );
  }
}

class _PulsatingPlayButton extends StatefulWidget {
  final VoidCallback onTap;

  const _PulsatingPlayButton({required this.onTap});

  @override
  State<_PulsatingPlayButton> createState() => _PulsatingPlayButtonState();
}

class _PulsatingPlayButtonState extends State<_PulsatingPlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/ui_button_play.png',
                  width: 120,
                  height: 120,
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'PLAY',
                    style: AppTypography.buttonLarge,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.woodBrown,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.inkBlack, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                offset: const Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, color: AppColors.offWhite, size: 30),
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.offWhite, 
            shadows: [const Shadow(offset: Offset(1,1), color: Colors.black)],
          ),
        ),
      ],
    );
  }
}

/// Settings Dialog for audio controls
class _SettingsDialog extends StatefulWidget {
  final CluckRushGame game;

  const _SettingsDialog({required this.game});

  @override
  State<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<_SettingsDialog> {
  late bool _musicEnabled;
  late bool _sfxEnabled;

  @override
  void initState() {
    super.initState();
    _musicEnabled = widget.game.audioManager.isMusicEnabled;
    _sfxEnabled = widget.game.audioManager.isSfxEnabled;
  }

  void _showCluckGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.woodBrown,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.inkBlack, width: 3),
        ),
        title: Row(
          children: [
            Image.asset('assets/images/chicken_idle.png', width: 40, height: 40),
            const SizedBox(width: 8),
            Text(
              'CLUCK GUIDE',
              style: AppTypography.headline2.copyWith(color: AppColors.offWhite),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _GuideSection(
                icon: Icons.sports_esports,
                title: 'How to Play',
                content: 'Help Penny the chicken run through the farm and collect food to stay full!',
              ),
              const SizedBox(height: 16),
              _GuideSection(
                icon: Icons.swipe_vertical,
                title: 'Controls',
                content: '• Drag the chicken UP or DOWN to switch lanes\n• Tap anywhere else to JUMP over obstacles',
              ),
              const SizedBox(height: 16),
              _GuideSection(
                icon: Icons.restaurant,
                title: 'Fullness Meter',
                content: 'Your fullness decreases over time. Collect food to refill it! If it reaches zero, game over.',
              ),
              const SizedBox(height: 16),
              _GuideSection(
                icon: Icons.star,
                title: 'Earning Stars & Eggs',
                content: '• Finish with >75% fullness = 3 Stars\n• Finish with >50% fullness = 2 Stars + Egg\n• Finish with >25% fullness = 1 Star',
              ),
              const SizedBox(height: 16),
              _GuideSection(
                icon: Icons.warning_amber,
                title: 'Watch Out!',
                content: '• Rocks and hay bales slow you down\n• Foxes push you back\n• Higher levels = faster & harder!',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'GOT IT!',
              style: AppTypography.buttonMedium.copyWith(color: AppColors.pennyYellow),
            ),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.woodBrown,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.inkBlack, width: 3),
        ),
        title: Text(
          'ABOUT',
          style: AppTypography.headline2.copyWith(color: AppColors.offWhite),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/chicken_jump.png', width: 80, height: 80),
            const SizedBox(height: 16),
            Text(
              'CLUCK RUSH',
              style: AppTypography.headline3.copyWith(color: AppColors.pennyYellow),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'The Egg Dash',
              style: AppTypography.body.copyWith(color: AppColors.offWhite),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Help Penny the chicken dash through the farm, collecting delicious food to stay full and healthy! Dodge obstacles, avoid hungry foxes, and make it to the coop safely.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.offWhite),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Version 1.0.0',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.offWhite.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'CLOSE',
              style: AppTypography.buttonMedium.copyWith(color: AppColors.pennyYellow),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.woodBrown,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.inkBlack, width: 3),
        ),
        title: Row(
          children: [
            Icon(Icons.privacy_tip, color: AppColors.offWhite, size: 28),
            const SizedBox(width: 8),
            Text(
              'PRIVACY',
              style: AppTypography.headline2.copyWith(color: AppColors.offWhite),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Privacy Matters',
              style: AppTypography.headline3.copyWith(color: AppColors.pennyYellow),
            ),
            const SizedBox(height: 12),
            Text(
              'Cluck Rush does NOT collect, store, or share any personal data. We respect your privacy completely.',
              style: AppTypography.body.copyWith(color: AppColors.offWhite),
            ),
            const SizedBox(height: 16),
            Text(
              '• No account required\n• No personal information collected\n• No analytics or tracking\n• All game data stays on your device',
              style: AppTypography.bodySmall.copyWith(color: AppColors.offWhite),
            ),
            const SizedBox(height: 16),
            Text(
              'Play with peace of mind! 🐔',
              style: AppTypography.body.copyWith(color: AppColors.pennyYellow),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'CLOSE',
              style: AppTypography.buttonMedium.copyWith(color: AppColors.pennyYellow),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.woodBrown,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.inkBlack, width: 3),
      ),
      title: Text(
        'SETTINGS',
        style: AppTypography.headline2.copyWith(color: AppColors.offWhite),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Music Toggle
            _SettingToggle(
              icon: Icons.music_note,
              label: 'Music',
              value: _musicEnabled,
              onChanged: (value) {
                setState(() {
                  _musicEnabled = value;
                });
                widget.game.audioManager.setMusicEnabled(value);
                if (value) {
                  widget.game.audioManager.playMenuMusic();
                }
              },
            ),
            const SizedBox(height: 12),
            // SFX Toggle
            _SettingToggle(
              icon: Icons.volume_up,
              label: 'Sound FX',
              value: _sfxEnabled,
              onChanged: (value) {
                setState(() {
                  _sfxEnabled = value;
                });
                widget.game.audioManager.setSfxEnabled(value);
              },
            ),
            
            const SizedBox(height: 20),
            Divider(color: AppColors.offWhite.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            
            // Cluck Guide
            _SettingLink(
              icon: Icons.help_outline,
              label: 'Cluck Guide',
              onTap: () => _showCluckGuide(context),
            ),
            const SizedBox(height: 12),
            
            // About
            _SettingLink(
              icon: Icons.info_outline,
              label: 'About',
              onTap: () => _showAbout(context),
            ),
            const SizedBox(height: 12),
            
            // Privacy Policy
            _SettingLink(
              icon: Icons.privacy_tip_outlined,
              label: 'Privacy Policy',
              onTap: () => _showPrivacyPolicy(context),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'DONE',
            style: AppTypography.buttonMedium.copyWith(color: AppColors.pennyYellow),
          ),
        ),
      ],
    );
  }
}

class _SettingToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingToggle({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.offWhite, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTypography.body.copyWith(color: AppColors.offWhite),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.success,
          activeTrackColor: AppColors.success.withValues(alpha: 0.5),
          inactiveThumbColor: AppColors.danger,
          inactiveTrackColor: AppColors.danger.withValues(alpha: 0.3),
        ),
      ],
    );
  }
}

class _SettingLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: AppColors.offWhite, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTypography.body.copyWith(color: AppColors.offWhite),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.offWhite.withValues(alpha: 0.6),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _GuideSection({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.pennyYellow.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.pennyYellow, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.body.copyWith(
                  color: AppColors.pennyYellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: AppTypography.bodySmall.copyWith(color: AppColors.offWhite),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

