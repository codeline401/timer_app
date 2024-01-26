import 'package:flutter/material.dart';
import 'package:flutter_timer/timer/timer.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Timer',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Color.fromRGBO(72, 74, 126, 1)
        ),
      ),
      home: const TimerPage(),
    );
  }
}