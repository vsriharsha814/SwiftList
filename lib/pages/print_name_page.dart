import 'package:flutter/material.dart';

class PrintName extends StatefulWidget {
  const PrintName({super.key});

  @override
  State<PrintName> createState() => _PrintNameState();
}

class _PrintNameState extends State<PrintName> {

  // Text editing Controller
  TextEditingController myController = TextEditingController();

  String greetingMessage = "";

  // Greet User Method
  void greetUser() {
    setState(() {
      if (myController.text != "") {
        greetingMessage = "Hello, ${myController.text}";
      } else {
        greetingMessage = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Text Field
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(greetingMessage),
              TextField(
                controller: myController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Type your name...'
                ),
              ),
              // Button
              ElevatedButton(onPressed: greetUser, child: const Text("Tap"),)
            ],
          ),
        )
      ),
    );
  }
}