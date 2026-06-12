import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: TestLayout()));
}

class TestLayout extends StatelessWidget {
  const TestLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Container(height: 100, color: Colors.red),
                            Expanded(
                                child: Container(
                                    height: 50,
                                    color:
                                        Colors.blue)), // Wait! Does this fail?
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
