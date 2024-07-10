import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reports/provider/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showThemeModeModalSheet(BuildContext context) {
  const double containerHeight = 88;
  const double containerWidth = 118;
  Future<void> saveThemePreference(String theme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("themePreference", theme);
  }

  showModalBottomSheet(
    useSafeArea: true,
    isDismissible: true,
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          String selectedTheme =
              Provider.of<ThemeProvider>(context, listen: false)
                  .themeMode
                  .toString();

          bool isDarkMode(BuildContext ctx) {
            return Theme.of(context).brightness == Brightness.dark;
          }

          final dark = isDarkMode(context);

          return SizedBox(
            height: 138,
            child: Column(
              children: [
                const SizedBox(height: 6),
                Container(
                  height: 4,
                  width: 90,
                  decoration: BoxDecoration(
                    color: dark ? Colors.grey[800] : Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  //height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Provider.of<ThemeProvider>(context, listen: false)
                                .setThemeMode(ThemeMode.light);
                            setState(() {
                              selectedTheme = "ThemeMode.light";
                            });
                          },
                          child: ContainerMode(
                            containerWidth: containerWidth,
                            containerHeight: containerHeight,
                            containerIcon: Icons.light_mode_outlined,
                            containerText: "Light Mode",
                            isSelected: selectedTheme == "ThemeMode.light",
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Provider.of<ThemeProvider>(context, listen: false)
                                .setThemeMode(ThemeMode.system);
                            saveThemePreference("ThemeMode.system");
                            setState(() {
                              selectedTheme = "ThemeMode.system";
                            });
                          },
                          child: ContainerMode(
                            containerWidth: containerWidth,
                            containerHeight: containerHeight,
                            containerIcon: Icons.sync_outlined,
                            containerText: "System",
                            isSelected: selectedTheme == "ThemeMode.system",
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Provider.of<ThemeProvider>(context, listen: false)
                                .setThemeMode(ThemeMode.dark);
                            saveThemePreference("ThemeMode.dark");
                            setState(() {
                              selectedTheme = "ThemeMode.dark";
                            });
                          },
                          child: ContainerMode(
                            containerWidth: containerWidth,
                            containerHeight: containerHeight,
                            containerIcon: Icons.dark_mode_outlined,
                            containerText: "Dark Mode",
                            isSelected: selectedTheme == "ThemeMode.dark",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class ContainerMode extends StatelessWidget {
  const ContainerMode({
    super.key,
    required this.containerWidth,
    required this.containerHeight,
    required this.containerIcon,
    this.containerText = "Mode Text",
    this.isSelected = false,
  });

  final double containerWidth;
  final double containerHeight;
  final IconData containerIcon;
  final String containerText;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode(BuildContext ctx) {
      return Theme.of(context).brightness == Brightness.dark;
    }

    final dark = isDarkMode(context);

    return Container(
      decoration: BoxDecoration(
        color: dark
            ? const Color.fromARGB(100, 0, 0, 0)
            : const Color.fromARGB(213, 216, 210, 210),
        borderRadius: BorderRadius.circular(12),
      ),
      width: containerWidth,
      height: containerHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(containerIcon),
          Text(
            containerText,
            style: const TextStyle(fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 5),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isSelected ? 1 : 0,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                  parent: const AlwaysStoppedAnimation(1),
                  curve: Curves.easeInOut),
              ),
              child: Container(
                  height: 5,
                  width: 50,
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(8), right: Radius.circular(8)),
                  ),
                ),
            ),
          ),
          
        ],
      ),
    );
  }
}
