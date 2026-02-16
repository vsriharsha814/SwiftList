import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class TodoTile extends StatelessWidget {
  final String taskName;
  final bool taskCompleted;
  final DateTime? dueDate;
  final Function(bool?)? onChanged;
  final Function(BuildContext)? deleteFunction;

  const TodoTile({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    required this.dueDate,
    required this.onChanged,
    required this.deleteFunction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 14),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.3,
          children: [
            SlidableAction(
              onPressed: deleteFunction,
              icon: Icons.delete,
              backgroundColor: Colors.red.shade300,
              borderRadius: BorderRadius.circular(12),
            )
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.deepPurple[300],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: taskCompleted,
                    onChanged: onChanged,
                    fillColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return Colors.white;
                        }
                        return Colors.transparent;
                      },
                    ),
                    checkColor: const Color.fromARGB(255, 74, 74, 74),
                    side: const BorderSide(color: Colors.white, width: 2),
                  ),
                  Text(
                    taskName,
                    style: TextStyle(
                      decoration: taskCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              
              // Display due date only if it exists
              if (dueDate != null) ...[
                const SizedBox(height: 8),
                Text(
                  DateFormat('MMM d, yyyy h:mm a').format(dueDate!),  // Format the due date
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}