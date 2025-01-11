import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

class Pallete {
  // Colors
  static const Color blackColor = Color.fromRGBO(1, 1, 1, 1); // primary color
  static const Color greyColor =
      Color.fromRGBO(26, 39, 45, 1); // secondary color
  static const Color drawerColor = Color.fromRGBO(18, 18, 18, 1);
  static const Color whiteColor = Colors.white;
  static const Color redColor =
      Colors.red; // Use plain colors for theming consistency
  static const Color blueColor = Colors.blue;

  // Themes
  static final ThemeData darkModeAppTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: blackColor,
    cardColor: greyColor,
    colorScheme: ThemeData.dark().colorScheme.copyWith(
          primary: blueColor,
          secondary: redColor,
          surface: drawerColor,
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: drawerColor,
      iconTheme: IconThemeData(
        color: whiteColor,
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: drawerColor,
    ),
  );

  static final ThemeData lightModeAppTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: whiteColor,
    cardColor: greyColor,
    colorScheme: ThemeData.light().colorScheme.copyWith(
          primary: redColor,
          secondary: blueColor,
          surface: whiteColor,
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: whiteColor,
      elevation: 0,
      iconTheme: IconThemeData(
        color: blackColor,
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: whiteColor,
    ),
  );
}

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeMode _mode;
  ThemeNotifier({ThemeMode mode = ThemeMode.dark})
      : _mode = mode,
        super(Pallete.darkModeAppTheme) {
    getTheme();
  }

ThemeMode get mode => _mode;
  void getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme');

    if (theme == 'light') {
      _mode = ThemeMode.light;
      state = Pallete.lightModeAppTheme;
    } else {
      _mode = ThemeMode.dark;
      state = Pallete.darkModeAppTheme;
    }
  }

  void toggleTheme() async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_mode ==ThemeMode.dark) {
       _mode = ThemeMode.light;
      state = Pallete.lightModeAppTheme;
      prefs.setString('theme', 'light');
    }else{
      _mode = ThemeMode.dark;
      state = Pallete.darkModeAppTheme;
      prefs.setString('theme', 'dark');
    }
  }
}
