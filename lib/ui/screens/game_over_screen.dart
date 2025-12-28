import 'package:flutter/material.dart';
import 'package:cluck_rush/game/cluck_rush_game.dart';
import 'package:cluck_rush/constants/colors.dart';
import 'package:cluck_rush/constants/typography.dart';

class GameOverScreen extends StatelessWidget {
  final CluckRushGame game;

  const GameOverScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/chicken_dizzy.png', height: 150),
            const SizedBox(height: 20),
            const Text('Too Hungry!', style: AppTypography.gameOver),
            const SizedBox(height: 10),
            ValueListenableBuilder<int>(
              valueListenable: game.scoreNotifier,
              builder: (context, score, child) {
                return Text(
                  'Score: $score',
                  style: AppTypography.headline3.copyWith(
                    color: AppColors.offWhite,
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.action,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AppColors.inkBlack, width: 2),
                ),
              ),
              onPressed: () {
                game.startGame(levelNumber: game.level);
              },
              child: const Text('Try Again', style: AppTypography.buttonLarge),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                game.goToMainMenu();
              },
              child: Text(
                'Back to Menu',
                style: AppTypography.buttonSmall.copyWith(
                  color: AppColors.offWhite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
