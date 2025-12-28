import 'package:flutter/material.dart';
import 'package:cluck_rush/game/cluck_rush_game.dart';
import 'package:cluck_rush/constants/colors.dart';
import 'package:cluck_rush/constants/typography.dart';

class GameHud extends StatelessWidget {
  final CluckRushGame game;

  const GameHud({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pause Button
                GestureDetector(
                  onTap: () {
                    game.pauseGame();
                    game.overlays.add('PauseMenu');
                  },
                  child: Image.asset(
                    'assets/images/ui_button_pause.png', 
                    width: 64, 
                    height: 64,
                    fit: BoxFit.contain,
                  ),
                ),
                
                // Level Indicator
                _LevelIndicator(game: game),
                
                // Fullness Meter
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _FullnessMeter(game: game),
                  ),
                ),
                
                // Distance Indicator
                _DistanceIndicator(game: game),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelIndicator extends StatelessWidget {
  final CluckRushGame game;

  const _LevelIndicator({required this.game});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.levelNotifier,
      builder: (context, level, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.pennyYellow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.inkBlack, width: 2),
          ),
          child: Text(
            'Lv.$level',
            style: AppTypography.hudText.copyWith(color: AppColors.inkBlack),
          ),
        );
      },
    );
  }
}

class _FullnessMeter extends StatefulWidget {
  final CluckRushGame game;

  const _FullnessMeter({required this.game});

  @override
  State<_FullnessMeter> createState() => _FullnessMeterState();
}

class _FullnessMeterState extends State<_FullnessMeter>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _shakeAnimation = Tween<double>(begin: -3, end: 3).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: widget.game.fullnessNotifier,
      builder: (context, fullness, child) {
        // Shake when below 25%
        if (fullness <= 25 && fullness > 0) {
          if (!_shakeController.isAnimating) {
            _shakeController.repeat(reverse: true);
          }
        } else {
          _shakeController.stop();
          _shakeController.reset();
        }

        return AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(fullness <= 25 ? _shakeAnimation.value : 0, 0),
              child: SizedBox(
                height: 48,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Frame - stretched to fit
                    Container(
                       width: double.infinity,
                       decoration: BoxDecoration(
                         image: const DecorationImage(
                           image: AssetImage('assets/images/ui_progress_bar_frame.png'),
                           fit: BoxFit.fill,
                         ),
                         borderRadius: BorderRadius.circular(24),
                       ),
                    ),
                    
                    // Bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 12.0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final percent = (fullness / 100).clamp(0.0, 1.0);
                          return Container(
                            width: constraints.maxWidth * percent,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.getMeterColor(fullness),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  offset: const Offset(0, 2),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          );
                        }
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _DistanceIndicator extends StatelessWidget {
  final CluckRushGame game;

  const _DistanceIndicator({required this.game});

  @override
  Widget build(BuildContext context) {
     return ValueListenableBuilder<double>(
      valueListenable: game.distanceNotifier,
      builder: (context, distance, child) {
        final remaining = (game.levelGoal - distance).clamp(0.0, game.levelGoal).toInt();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.woodBrown,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.inkBlack, width: 2),
          ),
          child: Text(
            '${remaining}m',
            style: AppTypography.hudText,
          ),
        );
      },
    );
  }
}
// End of GameHud
