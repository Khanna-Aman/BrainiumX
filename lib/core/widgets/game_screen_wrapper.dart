import 'package:flutter/material.dart';
import 'error_boundary.dart';

class GameScreenWrapper extends StatelessWidget {
  final Widget child;
  final String gameName;

  const GameScreenWrapper({
    super.key,
    required this.child,
    required this.gameName,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      onError: (details) {
        // Log game-specific error
        debugPrint('Error in $gameName: ${details.exception}');
      },
      fallback: _buildGameErrorWidget(context),
      child: child,
    );
  }

  Widget _buildGameErrorWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gameName),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.sports_esports_outlined,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                '$gameName Error',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'The game encountered an unexpected error. Your progress has been saved.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Restart the game by navigating back to it
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => child),
                      );
                    },
                    child: const Text('Restart Game'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text('Back to Home'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
