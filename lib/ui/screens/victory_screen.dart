import 'package:flutter/material.dart';
import 'package:cluck_rush/game/cluck_rush_game.dart';
import 'package:cluck_rush/constants/colors.dart';
import 'package:cluck_rush/constants/typography.dart';
import 'package:cluck_rush/services/storage_service.dart';

class VictoryScreen extends StatefulWidget {
  final CluckRushGame game;

  const VictoryScreen({super.key, required this.game});

  @override
  State<VictoryScreen> createState() => _VictoryScreenState();
}

class _VictoryScreenState extends State<VictoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _eggController;
  late Animation<double> _eggScaleAnimation;
  late Animation<double> _eggBounceAnimation;

  bool get earnedEgg => widget.game.fullness > 50;
  int get starsEarned => StorageService.calculateStars(widget.game.fullness);

  @override
  void initState() {
    super.initState();
    _eggController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Scale: 0% -> 110% -> 100% (overshoot effect as per plan)
    _eggScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.1), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _eggController, curve: Curves.easeOut));

    // Bounce up animation
    _eggBounceAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _eggController, curve: Curves.bounceOut),
    );

    // Start animation if egg was earned
    if (earnedEgg) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _eggController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _eggController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Chicken with optional egg
            SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset('assets/images/chicken_jump.png', height: 150),
                  
                  // Egg pops out if meter was green (>50%)
                  if (earnedEgg)
                    AnimatedBuilder(
                      animation: _eggController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(60, _eggBounceAnimation.value),
                          child: Transform.scale(
                            scale: _eggScaleAnimation.value,
                            child: Image.asset(
                              'assets/images/collectible_egg.png',
                              width: 50,
                              height: 50,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Level Complete!', style: AppTypography.victory),
            const SizedBox(height: 10),
            
            // Stars earned display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final hasStar = index < starsEarned;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Icon(
                    hasStar ? Icons.star : Icons.star_border,
                    color: hasStar ? AppColors.pennyYellow : AppColors.offWhite.withValues(alpha: 0.4),
                    size: 40,
                  ),
                );
              }),
            ),
            
            const SizedBox(height: 10),
            ValueListenableBuilder<int>(
              valueListenable: widget.game.scoreNotifier,
              builder: (context, score, child) {
                return Text(
                  'Score: $score',
                  style: AppTypography.headline3.copyWith(color: AppColors.offWhite),
                );
              },
            ),
            if (earnedEgg)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '🥚 Egg Earned!',
                  style: AppTypography.body.copyWith(color: AppColors.pennyYellow),
                ),
              ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AppColors.inkBlack, width: 2),
                ),
              ),
              onPressed: () {
                widget.game.startGame(levelNumber: widget.game.level + 1);
              },
              child: const Text('Next Level', style: AppTypography.buttonLarge),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                widget.game.goToMainMenu();
              },
              child: Text(
                'Back to Menu', 
                style: AppTypography.buttonSmall.copyWith(color: AppColors.offWhite),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

