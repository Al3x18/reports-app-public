import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reports/provider/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeScreen extends StatefulWidget {
  const AppThemeScreen({super.key});

  @override
  State<AppThemeScreen> createState() => _AppThemeScreenState();
}

class _AppThemeScreenState extends State<AppThemeScreen> {
  bool isSelectedSystem = false;
  bool isSelectedLight = false;
  bool isSelectedDark = false;

  void checkCurrentTheme() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeMode = themeProvider.themeMode;

    if (themeMode.toString().toLowerCase() == "thememode.system") {
      setState(() {
        isSelectedSystem = true;
      });
    }
    if (themeMode.toString().toLowerCase() == "thememode.light") {
      setState(() {
        isSelectedLight = true;
      });
    }
    if (themeMode.toString().toLowerCase() == "thememode.dark") {
      setState(() {
        isSelectedDark = true;
      });
    }
  }

  Future<void> saveThemePreference(String theme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("themePreference", theme);
  }

  @override
  Widget build(BuildContext context) {
    if (!isSelectedSystem && !isSelectedLight && !isSelectedDark) {
      checkCurrentTheme();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Theme"),
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text("Use System Settings"),
            leading: const Icon(Icons.sync_rounded),
            trailing: isSelectedSystem ? const Icon(Icons.check) : null,
            onTap: () {
              setState(() {
                isSelectedSystem = true;
                isSelectedLight = false;
                isSelectedDark = false;
              });
              Provider.of<ThemeProvider>(context, listen: false)
                  .setThemeMode(ThemeMode.system);
              saveThemePreference("ThemeMode.system");
            },
          ),
          ListTile(
            title: const Text("Light Mode"),
            leading: const Icon(Icons.wb_sunny_outlined),
            trailing: isSelectedLight ? const Icon(Icons.check) : null,
            onTap: () {
              setState(() {
                isSelectedLight = true;
                isSelectedSystem = false;
                isSelectedDark = false;
              });
              Provider.of<ThemeProvider>(context, listen: false)
                  .setThemeMode(ThemeMode.light);
              saveThemePreference("ThemeMode.light");
            },
          ),
          ListTile(
            title: const Text("Dark Mode"),
            leading: const Icon(Icons.nightlight_outlined),
            trailing: isSelectedDark ? const Icon(Icons.check) : null,
            onTap: () {
              setState(() {
                isSelectedDark = true;
                isSelectedSystem = false;
                isSelectedLight = false;
              });
              Provider.of<ThemeProvider>(context, listen: false)
                  .setThemeMode(ThemeMode.dark);
              saveThemePreference("ThemeMode.dark");
            },
          ),
        ],
      ),
    );
  }
}
