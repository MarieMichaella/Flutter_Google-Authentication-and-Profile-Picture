import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'homescreen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'api/google_signin_api.dart';

class ThemePreference {
  static const String _themeKey = 'theme';

  Future<bool> getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  Future<void> setTheme(bool isDark) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }
}

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData;

  ThemeProvider(bool isDarkTheme) : _themeData = isDarkTheme ? darkTheme : lightTheme;

  ThemeData getTheme() => _themeData;

  void toggleTheme() async {
    _themeData = _themeData == lightTheme ? darkTheme : lightTheme;
    notifyListeners();
    ThemePreference().setTheme(_themeData == darkTheme);
  }
}

final ThemeData lightTheme = ThemeData(
  // Define your light theme data here
);

final ThemeData darkTheme = ThemeData(
  // Define your dark theme data here
);

// void main() {
//   runApp(
//     ChangeNotifierProvider<ThemeProvider>(
//       create: (_) => ThemeProvider(false),
//       child: MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ThemeProvider>(
//       builder: (context, themeProvider, child) {
//         return MaterialApp(
//           title: 'Navigator',
//           theme: themeProvider.getTheme(),
//           home: const HomeScreen(user: widget.user),
//         );
//       },
//     );
//   }
// }
