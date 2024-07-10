import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const invalidPasswordWarning =
    "The password must contain:\nAt least one large letter (A,B,C...)\nAt least one small letter (a,b,c...)\nAt least one number (1,2,3...)\nAt least one special character (!,@,%...)\nAnd MUST be at least 8 characters long";

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final formKey = GlobalKey<FormState>();

  bool rememberBoxValue = true;
  bool passwordObscureText = true;
  bool isAuthenticating = false;

  String name = "";
  String email = "";
  String password = "";
  String confirmPassword = "";

  @override
  Widget build(BuildContext context) {
    bool isDarkMode(BuildContext ctx) {
      return Theme.of(context).brightness == Brightness.dark;
    }

    final dark = isDarkMode(context);

    String? validatePassword(String value) {
      // RegExp pattern explanation
      /*

      r'^
        (?=.*[A-Z])       // should contain at least one upper case
        (?=.*[a-z])       // should contain at least one lower case
        (?=.*?[0-9])      // should contain at least one digit
        (?=.*?[!@#\$&*~]) // should contain at least one Special character
        .{8,}$            // Must be at least 8 characters in length  

      */

      RegExp regex = RegExp(
          r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
      if (value.isEmpty) {
        return "empty";
      } else {
        if (!regex.hasMatch(value)) {
          return "invalid";
        } else {
          return "valid";
        }
      }
    }

    bool isPasswordMatch(String p1, String p2) {
      if (p1 == p2) {
        return true;
      }
      return false;
    }

    void createAccount() async {
      final isValid = formKey.currentState!.validate();

      if (!isValid) {
        return;
      }

      formKey.currentState!.save();

      if (!isPasswordMatch(password, confirmPassword)) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              right: 18,
              left: 18,
            ),
            content: Text(
              "The passwords entered do not match, try again.",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        );
        return;
      }

      try {
        setState(() {
          isAuthenticating = true;
        });
        // create new user...
        final userCredentials = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        await FirebaseFirestore.instance
            .collection("users")
            .doc(userCredentials.user!.uid)
            .set({
          "uid": userCredentials.user!.uid,
          "email": email,
          "name": name,
          "isAdmin": false,
          "isMasterDeletingActive": false,
          "isBlocked": false,
          "reportsList": [],
        });
        
        if (!context.mounted) {
          return;
        }
        Navigator.of(context).pop();

      } on FirebaseAuthException catch (error) {
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
              error.message ?? "Registration failed",
              style: const TextStyle(color: Colors.red),
            ),
          ),
        );
        setState(() {
          isAuthenticating = false;
        });
      }
    }

    return PopScope(
      canPop: !isAuthenticating,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.only(top: 56, left: 24, right: 24, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo title subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: 60,
                          width: 60,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: const Image(
                              image: AssetImage("assets/images/reports_in_app_logo.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
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
                    Text("Create a New Account",
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8.0),
                    Text("Complete the form below to create a new account",
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
      
                Form(
                  key: formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        // complete name text form
                        TextFormField(
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.person),
                            labelText: "Your Complete Name",
                          ),
                          validator: (value) {
                            if (value!.isEmpty || value.length < 4) {
                              return "Please enter a valid Name and Surname";
                            }
                            return null;
                          },
                          onSaved: (newValue) => name = newValue!,
                        ),
                        const SizedBox(height: 16),
                        // email form
                        TextFormField(
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
                        // password form
                        TextFormField(
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s'))
                          ], //deny spaces
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
                            switch (validatePassword(value!)) {
                              case "empty":
                                return "Please enter a password";
                              case "invalid":
                                return "Invalid password, check the field below";
                            }
                            return null;
                          },
                          onSaved: (newValue) => password = newValue!.trim(),
                        ),
                        const SizedBox(height: 16),
                        // confirm password form
                        TextFormField(
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s'))
                          ],
                          obscureText: passwordObscureText,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.key),
                            labelText: "Confirm Password",
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
                            switch (validatePassword(value!)) {
                              case "empty":
                                return "Please enter a password";
                              case "invalid":
                                return invalidPasswordWarning;
                            }
                            return null;
                          },
                          onSaved: (newValue) =>
                              confirmPassword = newValue!.trim(),
                        ),
                        const SizedBox(height: 16),
                        Column(
                          children: [
                            // sign in button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    backgroundColor: const Color.fromARGB(255, 237, 207, 73),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    )),
                                onPressed: () {
                                  createAccount();
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
                                    : const Text("Sign In"),
                              ),
                            ),
                            const SizedBox(height: 16 / 2),
                            // back button
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
                                onPressed: () => isAuthenticating
                                    ? null
                                    : Navigator.of(context).pop(),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.arrow_back_ios_new, size: 16),
                                    SizedBox(width: 4),
                                    Text("Go Back"),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
