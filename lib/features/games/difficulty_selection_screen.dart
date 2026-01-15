import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/models.dart';

enum DifficultyLevel {
  easy,
  medium,
  hard,
  expert,
}

extension DifficultyLevelExtension on DifficultyLevel {
  String get displayName {
    switch (this) {
      case DifficultyLevel.easy:
        return 'Easy (3 rounds)';
      case DifficultyLevel.medium:
        return 'Medium (5 rounds)';
      case DifficultyLevel.hard:
        return 'Hard (7 rounds)';
      case DifficultyLevel.expert:
        return 'Expert (10 rounds)';
    }
  }

  String get description {
    switch (this) {
      case DifficultyLevel.easy:
        return 'Perfect for beginners - relaxed pace, more time to think';
      case DifficultyLevel.medium:
        return 'Comfortable challenge for regular players';
      case DifficultyLevel.hard:
        return 'Demanding pace for experienced players';
      case DifficultyLevel.expert:
        return 'Ultimate challenge for cognitive masters';
    }
  }

  Color getColor(BuildContext context) {
    switch (this) {
      case DifficultyLevel.easy:
        return Colors.green;
      case DifficultyLevel.medium:
        return Colors.blue;
      case DifficultyLevel.hard:
        return Colors.orange;
      case DifficultyLevel.expert:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case DifficultyLevel.easy:
        return Icons.looks_one;
      case DifficultyLevel.medium:
        return Icons.looks_two;
      case DifficultyLevel.hard:
        return Icons.looks_3;
      case DifficultyLevel.expert:
        return Icons.looks_4;
    }
  }
}

class DifficultySelectionScreen extends StatefulWidget {
  final GameId gameId;

  const DifficultySelectionScreen({
    super.key,
    required this.gameId,
  });

  @override
  State<DifficultySelectionScreen> createState() =>
      _DifficultySelectionScreenState();
}

class _DifficultySelectionScreenState extends State<DifficultySelectionScreen> {
  DifficultyLevel? _selectedDifficulty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '${widget.gameId.displayName} - Difficulty',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        widget.gameId.icon,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.gameId.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Choose Your Challenge Level',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Higher difficulty means faster pace and more rounds',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Difficulty Options
              Text(
                'Scroll to see all difficulty levels',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    children: DifficultyLevel.values.map((difficulty) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _DifficultyCard(
                          difficulty: difficulty,
                          isSelected: _selectedDifficulty == difficulty,
                          onTap: () {
                            setState(() {
                              _selectedDifficulty = difficulty;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Start Game Button
              ElevatedButton(
                onPressed:
                    _selectedDifficulty != null ? () => _startGame() : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Start Game',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startGame() {
    if (_selectedDifficulty != null) {
      // Navigate to game with difficulty parameter
      context.pushReplacement(
        '/game/${widget.gameId.name}?difficulty=${_selectedDifficulty!.name}',
      );
    }
  }
}

class _DifficultyCard extends StatelessWidget {
  final DifficultyLevel difficulty;
  final bool isSelected;
  final VoidCallback onTap;

  const _DifficultyCard({
    required this.difficulty,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 8 : 2,
      color: isSelected
          ? difficulty.getColor(context).withValues(alpha: 0.1)
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                difficulty.icon,
                size: 32,
                color: difficulty.getColor(context),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      difficulty.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? difficulty.getColor(context)
                                : null,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      difficulty.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: difficulty.getColor(context),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
