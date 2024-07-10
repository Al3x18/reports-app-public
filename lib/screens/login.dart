import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:reports/screens/forgot_password.dart';
import 'package:reports/utils/alert_dialogs.dart';
import 'package:reports/utils/app_version_control.dart';
import 'package:reports/screens/create_account.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    getAppVersion();
    AppVersionControl().checkAppVersion(context);
    getRememberMeValue();
    super.initState();
  }

  final formKey = GlobalKey<FormState>();
  final TextEditingController emailFormController = TextEditingController();
  final TextEditingController passwordFormController = TextEditingController();

  String version = "";

  bool rememberBoxValue = true;
  bool passwordObscureText = true;
  bool isAuthenticating = false;
  bool isDownloadButtonPressed = false;

  String email = "";
  String password = "";

  void getRememberMeValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberBoxValue = prefs.getBool("rememberMePreference") ?? true;
    });
  }

  void getAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentAppVersion = packageInfo.version;
    setState(() {
      version = currentAppVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode(BuildContext ctx) {
      return Theme.of(context).brightness == Brightness.dark;
    }

    final dark = isDarkMode(context);

    void navigateToCreateAccountPage() {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const CreateAccountScreen(),
      ));
    }

    Future<void> saveRememberMePreference(bool value) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("rememberMePreference", value);
    }

    void login() async {
      final isValid = formKey.currentState!.validate();

      if (!isValid) {
        return;
      }

      formKey.currentState!.save();

      //close keyboard
      if (!context.mounted) {
        return;
      }
      FocusScope.of(context).unfocus();

      try {
        setState(() {
          isAuthenticating = true;
        });

        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
      } on FirebaseAuthException catch (error) {
        // if (error.code == "email-already-in-use")...

        // to avoid warning of not use BuildContext across async gaps.
        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(
              right: 18,
              left: 18,
            ),
            content: Text(
              error.message ?? "Authentication failed",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        );
        setState(() {
          isAuthenticating = false;
        });
      }
    }

    void downloadLatestAppVersion() async {
      if (Platform.isAndroid) {
        if (await AppVersionControl().latestVersionAvailable == version) {
          if (!context.mounted) {
            return;
          }
          AlertDialogs().snackBarAlertNotToCompile(
            context,
            "You already have the latest version installed.",
          );
        } else {
          setState(() {
            isDownloadButtonPressed = true;
          });
          if (!context.mounted) {
            return;
          }
          AppVersionControl().downloadNewVersion(context);
          await Future.delayed(const Duration(seconds: 4));
          setState(() {
            isDownloadButtonPressed = false;
          });
        }
      } else {
        AlertDialogs().snackBarAlertNotToCompile(
          context,
          "This feature is only available for Android devices.",
        );
      }
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 56, left: 24, right: 24, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // icon logo
                  Row(
                    children: [
                      SizedBox(
                        height: 60,
                        width: 60,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: const Image(
                            image: AssetImage(
                                "assets/images/reports_in_app_logo.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // reports logo
                      Expanded(
                        child: SizedBox(
                          height: 130,
                          width: double.infinity,
                          child: Image(
                            //height: 150,
                            image: AssetImage(dark
                                ? "assets/images/reports_logo_d.png"
                                : "assets/images/reports_logo_l.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // text title and subtitle
                  Text("Log In into Reports App",
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8.0),
                  Text("Enter your e-mail and password then press login",
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      // email text form field
                      TextFormField(
                        controller: emailFormController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.send_rounded),
                          labelText: "E-Mail",
                        ),
                        validator: (value) {
                          if (!EmailValidator.validate(value!)) {
                            return "Please enter a valid e-mail address";
                          }
                          return null;
                        },
                        onSaved: (newValue) => email = newValue!,
                      ),
                      const SizedBox(height: 16),
                      // password text form field
                      TextFormField(
                        controller: passwordFormController,
                        obscureText: passwordObscureText,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.key),
                          labelText: "Password",
                          suffixIcon: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {},
                            child: GestureDetector(
                              onLongPressStart: (_) {
                                setState(() {
                                  passwordObscureText = false;
                                });
                              },
                              onLongPressEnd: (_) {
                                setState(() {
                                  passwordObscureText = true;
                                });
                              },
                              child: const Icon(Icons.remove_red_eye_outlined),
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter a password";
                          }
                          return null;
                        },
                        onSaved: (newValue) => password = newValue!,
                      ),
                      const SizedBox(height: 16 / 2),
                      // remember me checkbox and forgot password button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox.adaptive(
                                  activeColor:
                                      const Color.fromARGB(255, 217, 192, 80),
                                  checkColor: Colors.black,
                                  value: rememberBoxValue,
                                  onChanged: (value) {
                                    setState(() {
                                      rememberBoxValue = value!;
                                      saveRememberMePreference(value);
                                    });
                                  }),
                              const Text("Remember Me"),
                            ],
                          ),
                          // forgot password
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 216, 185, 48)),
                              ))
                        ],
                      ),
                      const SizedBox(height: 16),
                      // login button
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor:
                                      const Color.fromARGB(255, 237, 207, 73),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  )),
                              onPressed: () {
                                login();
                              },
                              child: isAuthenticating
                                  ? const SizedBox(
                                      width: 26,
                                      height: 26,
                                      child: CircularProgressIndicator.adaptive(
                                        strokeWidth: 2,
                                        backgroundColor: Colors.black,
                                        valueColor: AlwaysStoppedAnimation(
                                            Colors.black),
                                      ),
                                    )
                                  : const Text("Log In"),
                            ),
                          ),
                          const SizedBox(height: 16 / 2),
                          // create a new account button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: !isAuthenticating
                                      ? (dark ? Colors.white : Colors.black)
                                      : (dark
                                          ? const Color.fromARGB(
                                              100, 255, 255, 255)
                                          : const Color.fromARGB(150, 0, 0, 0)),
                                  side: BorderSide(
                                    width: 2,
                                    color: !isAuthenticating
                                        ? (dark ? Colors.white : Colors.black)
                                        : (dark
                                            ? const Color.fromARGB(
                                                100, 255, 255, 255)
                                            : const Color.fromARGB(
                                                100, 0, 0, 0)),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  )),
                              onPressed: () {
                                if (!isAuthenticating) {
                                  navigateToCreateAccountPage();
                                  emailFormController.clear();
                                  passwordFormController.clear();
                                  FocusScope.of(context).unfocus();
                                }
                              },
                              child: const Text("Create an Account"),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 0.6),
                      // app version label
                      Text(
                        "App version: $version",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => downloadLatestAppVersion(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 5),
                            isDownloadButtonPressed
                                ? const SizedBox(
                                    width: 8,
                                    height: 8,
                                    child: CircularProgressIndicator.adaptive(
                                      strokeWidth: 1.2,
                                      backgroundColor: Colors.grey,
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    "Download latest app version",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                        decoration: TextDecoration.underline),
                                  ),
                            const SizedBox(width: 5),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 21.4),
              // sign in with text and divider
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                      child: Divider(
                    color: !isAuthenticating
                        ? (dark ? Colors.grey : Colors.black)
                        : (dark
                            ? const Color.fromARGB(100, 158, 158, 158)
                            : const Color.fromARGB(100, 0, 0, 0)),
                    thickness: 0.5,
                    indent: 60,
                    endIndent: 5,
                  )),
                  Text(
                    "Or Sign In With",
                    style: TextStyle(
                      fontSize: 11.5,
                      color: !isAuthenticating
                          ? (dark ? Colors.white : Colors.black)
                          : (dark
                              ? const Color.fromARGB(150, 255, 255, 255)
                              : const Color.fromARGB(150, 0, 0, 0)),
                    ),
                  ),
                  Flexible(
                      child: Divider(
                    color: !isAuthenticating
                        ? (dark ? Colors.grey : Colors.black)
                        : (dark
                            ? const Color.fromARGB(100, 158, 158, 158)
                            : const Color.fromARGB(100, 0, 0, 0)),
                    thickness: 0.5,
                    indent: 5,
                    endIndent: 60,
                  ))
                ],
              ),
              const SizedBox(height: 16),
              // google and facebook logos
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // google logo
                  InkWell(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        border: Border.all(
                            width: 0.8,
                            color: !isAuthenticating
                                ? (dark ? Colors.white : Colors.black)
                                : (dark
                                    ? const Color.fromARGB(100, 255, 255, 255)
                                    : const Color.fromARGB(100, 0, 0, 0))),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Image(
                            width: 24,
                            height: 24,
                            image: AssetImage("assets/images/google_logo.png")),
                      ),
                    ),
                    onTap: () {
                      AlertDialogs()
                          .snackBarAlertNotImplementedFeature(context);
                    },
                  ),
                  const SizedBox(width: 18),
                  // facebook logo
                  InkWell(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        border: Border.all(
                            width: 0.8,
                            color: !isAuthenticating
                                ? (dark ? Colors.white : Colors.black)
                                : (dark
                                    ? const Color.fromARGB(100, 255, 255, 255)
                                    : const Color.fromARGB(100, 0, 0, 0))),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Image(
                          width: 24,
                          height: 24,
                          image: AssetImage("assets/images/facebook_logo.png"),
                        ),
                      ),
                    ),
                    onTap: () {
                      AlertDialogs()
                          .snackBarAlertNotImplementedFeature(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
