import 'package:flutter/material.dart';
import 'package:cluck_rush/game/cluck_rush_game.dart';
import 'package:cluck_rush/constants/colors.dart';
import 'package:cluck_rush/constants/typography.dart';

class PauseMenu extends StatelessWidget {
  final CluckRushGame game;

  const PauseMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.5),
      body: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.woodBrown,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.inkBlack, width: 4),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PAUSED',
                style: AppTypography.headline1.copyWith(color: AppColors.offWhite),
              ),
              const SizedBox(height: 30),
              
              _PauseButton(
                label: 'RESUME',
                onTap: () {
                  game.resumeGame();
                },
              ),
              const SizedBox(height: 16),
              
              _PauseButton(
                label: 'RESTART',
                onTap: () {
                  game.startGame(levelNumber: game.level);
                },
              ),
              const SizedBox(height: 16),
              
              _PauseButton(
                label: 'MENU',
                onTap: () {
                  game.goToMainMenu();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PauseButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PauseButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pennyYellow,
          foregroundColor: AppColors.inkBlack,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.inkBlack, width: 2),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: AppTypography.buttonMedium.copyWith(color: AppColors.inkBlack),
        ),
      ),
    );
  }
}

