import 'package:flutter/material.dart';

class DomainsHelpScreen extends StatelessWidget {
  const DomainsHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Cognitive Domains',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Introduction
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.psychology,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Cognitive Domains Explained',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Cognitive domains are different areas of mental functioning. BrainiumX games target specific domains to provide comprehensive brain training and assessment.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Speed & Attention
              _buildDomainSection(
                context,
                'Speed & Attention',
                Icons.flash_on,
                'The ability to quickly process information and focus on relevant stimuli while ignoring distractions.',
                [
                  'Speed Tap: Reaction time and visual attention',
                  'Trail Connect: Visual scanning and attention switching',
                  'Color Dominance: Visual attention and frequency detection',
                ],
                'Improves: Focus, concentration, reaction time, multitasking ability',
              ),

              const SizedBox(height: 16),

              // Memory
              _buildDomainSection(
                context,
                'Memory',
                Icons.memory,
                'The capacity to encode, store, and retrieve information over different time periods.',
                [
                  'Number Sequence: Pattern recognition and working memory',
                  'Memory Grid: Spatial memory and sequence recall',
                  'Color Match: Sequential memory and visual attention',
                ],
                'Improves: Information retention, learning capacity, mental workspace',
              ),

              const SizedBox(height: 16),

              // Inhibition & Control
              _buildDomainSection(
                context,
                'Inhibition & Control',
                Icons.block,
                'The ability to suppress inappropriate responses and resist interference from irrelevant information.',
                [
                  'Stroop Match: Cognitive inhibition and interference control',
                  'Go/No-Go: Response inhibition and impulse control',
                ],
                'Improves: Self-control, decision-making, resistance to distractions',
              ),

              const SizedBox(height: 16),

              // Spatial Reasoning & Flexibility
              _buildDomainSection(
                context,
                'Spatial Reasoning & Flexibility',
                Icons.rotate_right,
                'The ability to visualize and manipulate objects in space, and switch between different cognitive tasks.',
                [
                  'Spatial Rotation: Mental rotation and spatial visualization',
                  'Focus Shift: Cognitive flexibility and task switching',
                ],
                'Improves: Navigation skills, geometry understanding, mental flexibility',
              ),

              const SizedBox(height: 16),

              // Processing Speed
              _buildDomainSection(
                context,
                'Processing Speed',
                Icons.speed,
                'The rate at which cognitive tasks are completed accurately, reflecting mental efficiency.',
                [
                  'Arithmetic Sprint: Numerical processing and mental calculation',
                ],
                'Improves: Mental agility, quick thinking, computational efficiency',
              ),

              const SizedBox(height: 16),

              // Verbal Skills
              _buildDomainSection(
                context,
                'Verbal Skills',
                Icons.chat,
                'Language-related abilities including vocabulary, word knowledge, and verbal reasoning.',
                [
                  'Word Chain: Verbal fluency and vocabulary knowledge',
                ],
                'Improves: Communication, vocabulary, language comprehension',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDomainSection(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    List<String> games,
    String benefits,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 12),
            Text(
              'Games in this domain:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...games.map((game) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• $game',
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      benefits,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
