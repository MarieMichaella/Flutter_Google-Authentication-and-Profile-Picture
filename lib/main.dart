import 'package:flutter/material.dart';
import 'CalculatorView.dart';
import 'Aboutscreen.dart';
import 'homescreen.dart';
import 'signin.dart';
import 'themeprovider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      builder: (context, _) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Navigator',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.themeMode,
          home: SignInScreen(),
          
        );
      },
    );
  }
}
