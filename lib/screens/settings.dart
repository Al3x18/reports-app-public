import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reports/provider/theme_provider.dart';
import 'package:reports/screens/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeMode = themeProvider.themeMode;
    String themeString = "";

    switch (themeMode.toString().toLowerCase()) {
      case "thememode.system":
        themeString = "Use System Settings";
        break;
      case "thememode.light":
        themeString = "Light Mode";
        break;
      case "thememode.dark":
        themeString = "Dark Mode";
        break;
      default:
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          ListTile(
            title: const Text("Set App Theme"),
            subtitle: Text(themeString),
            leading: const Icon(Icons.color_lens),
            trailing: const Icon(Icons.arrow_forward_ios, size: 19),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const AppThemeScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
