import 'package:flutter/material.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Tdmarkup Example',
      home: Scaffold(
        body: Center(
          child: Text('hello world'),
        ),
      ),
    );
  }
}
