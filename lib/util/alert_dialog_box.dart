import 'package:flutter/material.dart';
import 'package:to_do_flutter_app/util/my_button.dart';
import 'package:to_do_flutter_app/util/my_text_box.dart';
import 'package:intl/intl.dart';

class AlertDialogBox extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final Function(DateTime?) onDateSelected;  // Now accepts nullable DateTime

  const AlertDialogBox({
    super.key,
    required this.controller,
    required this.onSave,
    required this.onCancel,
    required this.onDateSelected,
  });

  @override
  State<AlertDialogBox> createState() => _AlertDialogBoxState();
}

class _AlertDialogBoxState extends State<AlertDialogBox> {
  DateTime? selectedDate;

  Future<void> pickDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null && mounted) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null && mounted) {
        setState(() {
          selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
        widget.onDateSelected(selectedDate);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.deepPurple[300],
        content: SizedBox(
        height: 180,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            MyTextField(controller: widget.controller),

            // Button to pick date/time (optional)
            ElevatedButton(
              onPressed: pickDateTime,
              child: Text(
                selectedDate == null
                  ? 'Add Due Date (Optional)'
                  : DateFormat('MMM d, yyyy h:mm a').format(selectedDate!),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MyButton(text: "Save", onPressed: widget.onSave),
                const SizedBox(width: 6),
                MyButton(text: "Cancel", onPressed: widget.onCancel),
              ],
            ),
          ],
        ),
      ),
    );
  }
}