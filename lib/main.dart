import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/cluck_rush_game.dart';
import 'services/storage_service.dart';
import 'ui/screens/main_menu.dart';
import 'ui/screens/level_select.dart';
import 'ui/screens/hatchery.dart';
import 'ui/overlays/game_hud.dart';
import 'ui/overlays/pause_menu.dart';
import 'ui/screens/game_over_screen.dart';
import 'ui/screens/victory_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock orientation to portrait mode for optimal gameplay
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set fullscreen mode
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Initialize persistent storage
  await StorageService.instance.init();

  runApp(const CluckRushApp());
}

class CluckRushApp extends StatelessWidget {
  const CluckRushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cluck Rush: The Egg Dash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF9800),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final CluckRushGame _game;

  @override
  void initState() {
    super.initState();
    _game = CluckRushGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: _game,
        initialActiveOverlays: const ['MainMenu'],
        overlayBuilderMap: {
          'MainMenu': (context, CluckRushGame game) => MainMenu(game: game),
          'LevelSelect': (context, CluckRushGame game) => LevelSelect(game: game),
          'Hatchery': (context, CluckRushGame game) => Hatchery(game: game),
          'GameHud': (context, CluckRushGame game) => GameHud(game: game),
          'PauseMenu': (context, CluckRushGame game) => PauseMenu(game: game),
          'GameOver': (context, CluckRushGame game) => GameOverScreen(game: game),
          'Victory': (context, CluckRushGame game) => VictoryScreen(game: game),
        },
        loadingBuilder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF9800),
          ),
        ),
        errorBuilder: (context, error) => Center(
          child: Text(
            'Error loading game: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
