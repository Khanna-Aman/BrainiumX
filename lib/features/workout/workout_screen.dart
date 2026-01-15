import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/providers.dart';
import '../../data/models/models.dart';

class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayPlan = ref.watch(todayPlanProvider);
    final sessionState = ref.watch(sessionProvider);

    if (todayPlan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Today\'s Workout')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Workout'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: sessionState.todayResults.length /
                            todayPlan.games.length,
                      ),
                      const SizedBox(height: 8),
                      Text(
                          '${sessionState.todayResults.length}/${todayPlan.games.length} games completed'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Games',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: todayPlan.games.length,
                  itemBuilder: (context, index) {
                    final gameId = todayPlan.games[index];
                    final isCompleted = sessionState.todayResults
                        .any((result) => result.gameId == gameId);

                    return Card(
                      child: ListTile(
                        leading: Icon(
                          isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isCompleted ? Colors.green : null,
                        ),
                        title: Text(gameId.displayName),
                        subtitle: Text(gameId.domains.join(', ')),
                        trailing: isCompleted
                            ? const Icon(Icons.done, color: Colors.green)
                            : const Icon(Icons.play_arrow),
                        onTap: isCompleted
                            ? null
                            : () {
                                if (!sessionState.isSessionActive) {
                                  ref
                                      .read(sessionProvider.notifier)
                                      .startSession();
                                }
                                context.push('/game/${gameId.name}');
                              },
                      ),
                    );
                  },
                ),
              ),
              if (sessionState.todayResults.length == todayPlan.games.length)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.celebration,
                            size: 48, color: Colors.green),
                        const SizedBox(height: 8),
                        Text(
                          'Workout Complete!',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.pop(),
                          child: const Text('Back to Home'),
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
