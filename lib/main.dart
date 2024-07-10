import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reports/firebase_options.dart';
import 'package:reports/provider/theme_provider.dart';
import 'package:reports/screens/general_loading.dart';
import 'package:reports/screens/login.dart';
import 'package:reports/screens/reports.dart';
import 'package:shared_preferences/shared_preferences.dart';

const int animationDurationInMilliseconds = 860;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Set preference at first launch of the app on new device
  if (prefs.getBool("rememberMePreference") == null) {
    prefs.setBool("rememberMePreference", true);
  }
  // Get the value of rememberMe on app launch
  bool rememberMe = prefs.getBool("rememberMePreference") ?? true;

  // Sign out the user if rememberMe is false
  if (!rememberMe) {
     await FirebaseAuth.instance.signOut();
  }

  // Retrieves the saved theme preference, if any, otherwise uses the default (system) theme.
  ThemeMode savedThemeMode = ThemeMode.values.firstWhere(
    (mode) => mode.toString() == prefs.getString("themePreference"),
    orElse: () => ThemeMode.system,
  );

// for savedThemeMode debugging purposes
//   ThemeMode savedThemeMode = ThemeMode.values.firstWhere(
//   (mode) {
//     final modeString = mode.toString();
//     final themePreference = prefs.getString("themePreference");
//     print("Mode: $modeString, Preference: $themePreference");
//     return modeString == themePreference;
//   },
//   orElse: () {
//     print("No preference found, using system theme");
//     return ThemeMode.system;
//   },
// );

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(
          savedThemeMode), // Pass the saved theme to the ThemeProvider
      child: const MyApp(),
    ),
  );

  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reports',
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: Provider.of<ThemeProvider>(context).themeMode,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return AnimatedSwitcher(
              duration:
                  const Duration(milliseconds: animationDurationInMilliseconds),
              child: const GeneralLoadingScreen(),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            );
          }

          if (snapshot.hasData) {
            return AnimatedSwitcher(
              duration:
                  const Duration(milliseconds: animationDurationInMilliseconds),
              child: const ReportsScreen(),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            );
          }

          return AnimatedSwitcher(
            duration:
                const Duration(milliseconds: animationDurationInMilliseconds),
            child: const LoginScreen(),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
        },
      ),
    );
  }
}

ThemeData buildLightTheme() {
  const Color scaffoldAndAppBarColor = Color.fromARGB(255, 255, 255, 255);
  return ThemeData.light().copyWith(
      textTheme: GoogleFonts.robotoMonoTextTheme(ThemeData.light().textTheme),
      scaffoldBackgroundColor: scaffoldAndAppBarColor,
      canvasColor: const Color.fromARGB(176, 221, 213, 213),
      appBarTheme: const AppBarTheme(
        color: scaffoldAndAppBarColor,
      ),
      cardTheme: const CardTheme(
        color: Color(0xFFe0fbfc),
        shadowColor: Colors.blueAccent,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(foregroundColor: Colors.white)));
}

ThemeData buildDarkTheme() {
  return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.black,
      textTheme: GoogleFonts.robotoMonoTextTheme(ThemeData.dark().textTheme),
      primaryColor: Colors.blue,
      iconTheme: IconThemeData(color: Colors.grey[300]),
      canvasColor: Colors.black,
      cardTheme: const CardTheme(
        color: Color.fromARGB(255, 16, 16, 16),
        shadowColor: Colors.grey,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(foregroundColor: Colors.white)));
}
