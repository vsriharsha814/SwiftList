import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_flutter_app/data/database/app_database.dart';

/// Pulse — milestones based on completed tasks.
class PulseScreen extends StatelessWidget {
  const PulseScreen({super.key});

  static const _milestoneThresholds = [1, 5, 10, 25, 50, 100];
  static const _milestoneMessages = {
    1: "First task done! Keep it up.",
    5: "5 tasks completed. You're on a roll.",
    10: "10 tasks done! Great progress.",
    25: "25 tasks completed. You're crushing it.",
    50: "50 tasks done! Half century.",
    100: "100 tasks completed! Outstanding.",
  };

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pulse'),
      ),
      body: StreamBuilder<int>(
        stream: db.watchCompletedTaskCount(),
        builder: (context, snapshot) {
          final count = snapshot.data ?? 0;
          final hasError = snapshot.hasError;
          if (hasError) {
            return Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            );
          }
          final unlocked = _milestoneThresholds.where((t) => count >= t).toList();
          final nextThreshold = _milestoneThresholds.firstWhere(
            (t) => t > count,
            orElse: () => _milestoneThresholds.last + 25,
          );
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Milestones',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _SummaryCard(completedCount: count),
                const SizedBox(height: 16),
                if (unlocked.isEmpty) ...[
                  const _MilestoneCard(
                    icon: Icons.emoji_events_outlined,
                    title: 'Complete your first task',
                    subtitle: 'Check off a task in the List to see your first milestone here.',
                    unlocked: false,
                  ),
                ] else ...[
                  ...unlocked.reversed.map((t) => _MilestoneCard(
                        icon: Icons.emoji_events,
                        title: _milestoneMessages[t]!,
                        subtitle: '$t tasks completed',
                        unlocked: true,
                      )),
                ],
                if (count > 0 && count < nextThreshold) ...[
                  const SizedBox(height: 8),
                  _MilestoneCard(
                    icon: Icons.flag_outlined,
                    title: 'Next: $nextThreshold tasks',
                    subtitle: '${nextThreshold - count} more to go',
                    unlocked: false,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int completedCount;

  const _SummaryCard({required this.completedCount});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: colorScheme.primary,
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$completedCount task${completedCount == 1 ? '' : 's'} completed',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  completedCount == 0
                      ? 'Complete tasks in the List to see milestones here.'
                      : 'Keep going!',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool unlocked;

  const _MilestoneCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unlocked ? colorScheme.surfaceContainerHighest : colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: unlocked ? null : Border.all(color: colorScheme.outline.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: unlocked ? colorScheme.primary : colorScheme.onSurfaceVariant,
            size: 36,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: unlocked ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (unlocked)
            Icon(Icons.check_circle, color: colorScheme.primary, size: 24),
        ],
      ),
    );
  }
}
