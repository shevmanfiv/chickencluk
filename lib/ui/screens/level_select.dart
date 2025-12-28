import 'package:flutter/material.dart';
import 'package:cluck_rush/game/cluck_rush_game.dart';
import 'package:cluck_rush/constants/colors.dart';
import 'package:cluck_rush/constants/typography.dart';
import 'package:cluck_rush/services/storage_service.dart';

/// Level Select Screen
/// 
/// Displays a scrolling path of levels with:
/// - Locked levels: Gray with padlock icon
/// - Completed levels: Show 1-3 stars based on performance
class LevelSelect extends StatelessWidget {
  final CluckRushGame game;

  const LevelSelect({super.key, required this.game});

  // Total number of levels in the game
  static const int totalLevels = 14;

  @override
  Widget build(BuildContext context) {
    final storage = StorageService.instance;

    return Scaffold(
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
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () {
                        game.overlays.remove('LevelSelect');
                        game.overlays.add('MainMenu');
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.woodBrown,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.inkBlack, width: 2),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.offWhite,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'SELECT LEVEL',
                        style: AppTypography.headline1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Spacer for symmetry
                  ],
                ),
              ),

              // Level Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: totalLevels,
                    itemBuilder: (context, index) {
                      final levelNumber = index + 1;
                      final isUnlocked = storage.isLevelUnlocked(levelNumber);
                      final stars = storage.getStarsForLevel(levelNumber);

                      return _LevelButton(
                        levelNumber: levelNumber,
                        isUnlocked: isUnlocked,
                        stars: stars,
                        onTap: isUnlocked
                            ? () {
                                game.overlays.remove('LevelSelect');
                                game.startGame(levelNumber: levelNumber);
                              }
                            : null,
                      );
                    },
                  ),
                ),
              ),

              // Total Stars Summary
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.woodBrown,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.inkBlack, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: AppColors.pennyYellow, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        '${storage.totalStars} / ${totalLevels * 3}',
                        style: AppTypography.headline3.copyWith(color: AppColors.offWhite),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelButton extends StatelessWidget {
  final int levelNumber;
  final bool isUnlocked;
  final int stars;
  final VoidCallback? onTap;

  const _LevelButton({
    required this.levelNumber,
    required this.isUnlocked,
    required this.stars,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked ? AppColors.pennyYellow : AppColors.woodBrown.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked ? AppColors.inkBlack : AppColors.inkBlack.withValues(alpha: 0.3),
            width: 3,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Level number or lock icon
            if (isUnlocked)
              Text(
                '$levelNumber',
                style: AppTypography.headline1.copyWith(
                  color: AppColors.inkBlack,
                ),
              )
            else
              Icon(
                Icons.lock,
                color: AppColors.inkBlack.withValues(alpha: 0.4),
                size: 32,
              ),

            const SizedBox(height: 8),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final hasStar = index < stars;
                return Icon(
                  hasStar ? Icons.star : Icons.star_border,
                  color: hasStar
                      ? AppColors.action
                      : (isUnlocked ? AppColors.inkBlack.withValues(alpha: 0.3) : AppColors.inkBlack.withValues(alpha: 0.2)),
                  size: 20,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

