import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:to_do_flutter_app/core/theme/app_colors.dart';
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
            return const Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(color: AppColors.textSecondary),
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
                const Text(
                  'Milestones',
                  style: TextStyle(
                    color: AppColors.textPrimary,
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
                const SizedBox(height: 28),
                const Text(
                  'Completion notes',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                StreamBuilder<List<CompletionLog>>(
                  stream: db.watchCompletionLogs(),
                  builder: (context, logSnapshot) {
                    final logs = logSnapshot.data ?? [];
                    if (logs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Comments you add when completing tasks will show here.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                        ),
                      );
                    }
                    return Column(
                      children: logs.map((log) => _CompletionNoteCard(log: log)).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CompletionNoteCard extends StatelessWidget {
  final CompletionLog log;

  const _CompletionNoteCard({required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.slateGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            log.taskTitle,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('MMM d, yyyy · h:mm a').format(log.completedAt),
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          if (log.comment != null && log.comment!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              log.comment!,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int completedCount;

  const _SummaryCard({required this.completedCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.slateGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.actionAccent,
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$completedCount task${completedCount == 1 ? '' : 's'} completed',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  completedCount == 0
                      ? 'Complete tasks in the List to see milestones here.'
                      : 'Keep going!',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unlocked ? AppColors.slateGray : AppColors.slateGray.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: unlocked ? null : Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: unlocked ? AppColors.actionAccent : AppColors.textSecondary,
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
                    color: unlocked ? AppColors.textPrimary : AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (unlocked)
            const Icon(Icons.check_circle, color: AppColors.actionAccent, size: 24),
        ],
      ),
    );
  }
}
