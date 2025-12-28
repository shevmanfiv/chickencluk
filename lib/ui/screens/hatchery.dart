import 'package:flutter/material.dart';
import 'package:cluck_rush/game/cluck_rush_game.dart';
import 'package:cluck_rush/constants/colors.dart';
import 'package:cluck_rush/constants/typography.dart';
import 'package:cluck_rush/services/storage_service.dart';

/// Hatchery Screen (The Coop)
///
/// Displays collected eggs in a grid view.
/// Tap an egg to view details about the hatched chicken skin.
class Hatchery extends StatelessWidget {
  final CluckRushGame game;

  const Hatchery({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final storage = StorageService.instance;
    final totalEggs = storage.totalEggs;

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
                        game.overlays.remove('Hatchery');
                        game.overlays.add('MainMenu');
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.woodBrown,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.inkBlack,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.offWhite,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'THE COOP',
                        style: AppTypography.headline1,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Spacer for symmetry
                  ],
                ),
              ),

              // Egg count summary
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.woodBrown,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.inkBlack, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/collectible_egg.png',
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$totalEggs Eggs Collected',
                      style: AppTypography.headline3.copyWith(
                        color: AppColors.offWhite,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Eggs grid or empty state
              Expanded(
                child: totalEggs > 0
                    ? _EggGrid(totalEggs: totalEggs)
                    : _EmptyState(),
              ),

              // Hint text
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Complete levels with >50% fullness to earn eggs!',
                  style: AppTypography.tutorial,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EggGrid extends StatelessWidget {
  final int totalEggs;

  const _EggGrid({required this.totalEggs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: totalEggs,
        itemBuilder: (context, index) {
          return _EggItem(eggNumber: index + 1);
        },
      ),
    );
  }
}

class _EggItem extends StatefulWidget {
  final int eggNumber;

  const _EggItem({required this.eggNumber});

  @override
  State<_EggItem> createState() => _EggItemState();
}

class _EggItemState extends State<_EggItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    _showEggDetails(context);
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  void _showEggDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.woodBrown,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.inkBlack, width: 3),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/collectible_egg.png',
              width: 80,
              height: 80,
            ),
            const SizedBox(height: 16),
            Text(
              'Egg #${widget.eggNumber}',
              style: AppTypography.headline2.copyWith(
                color: AppColors.offWhite,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A golden reward for your chicken\'s journey!',
              style: AppTypography.body.copyWith(color: AppColors.offWhite),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'CLOSE',
              style: AppTypography.buttonMedium.copyWith(
                color: AppColors.pennyYellow,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _bounceAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.inkBlack, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    offset: const Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/collectible_egg.png',
                  width: 50,
                  height: 50,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/chicken_idle.png',
            width: 120,
            height: 120,
            color: AppColors.inkBlack.withValues(alpha: 0.3),
            colorBlendMode: BlendMode.srcIn,
          ),
          const SizedBox(height: 16),
          Text(
            'No eggs yet!',
            style: AppTypography.headline3.copyWith(
              color: AppColors.inkBlack.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Play levels to collect eggs',
            style: AppTypography.body.copyWith(
              color: AppColors.inkBlack.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
