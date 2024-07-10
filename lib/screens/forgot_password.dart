import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reports/utils/alert_dialogs.dart';
import 'package:reports/utils/enum_reset_message_color.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailFormController = TextEditingController();

  String email = "";
  bool isReset = false;
  bool isLoading = false;
  String resetMessage = "";
  ResetMessageColor? resetMessageColor;

  String unicodeCheck = "\u2713";
  String xUnicode = '\u24E7';

  @override
  Widget build(BuildContext context) {
    bool isDarkMode(BuildContext ctx) {
      return Theme.of(context).brightness == Brightness.dark;
    }

    final bool dark = isDarkMode(context);

    void changeIsResetValue(bool value, String message, ResetMessageColor color) {
      setState(() {
        isReset = value;
        resetMessage = message;
        resetMessageColor = color;
      });
    }

    void resetPassword() async {
      final isValid = formKey.currentState!.validate();

      if (!isValid) {
        return;
      }

      formKey.currentState!.save();

      try {
        setState(() {
          isLoading = true;
        });

        final auth = FirebaseAuth.instance;
        await auth.sendPasswordResetEmail(email: email);
        changeIsResetValue(true, "$unicodeCheck Password reset link has been sent to your email", ResetMessageColor.green);
      
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          changeIsResetValue(true, "$xUnicode This user does not exist", ResetMessageColor.red);

        } else {
          
          if (!context.mounted) {
            return;
          }
          AlertDialogs().fatalErrorDialogMessage(context, e.toString());
        }
      } 

      setState(() {
        isLoading = false;
      });

      // close keyboard
      if (!context.mounted) {
        return;
      }
      FocusScope.of(context).unfocus();
    }

    return PopScope(
      canPop: !isLoading,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.only(top: 56, left: 24, right: 24, bottom: 24),
            child: Column(
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
                          image:
                              AssetImage("assets/images/reports_in_app_logo.png"),
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
                // text title
                Text("Forgot Password?",
                    style: Theme.of(context).textTheme.headlineMedium),
                Text("Enter your e-mail below to reset your password",
                    style: Theme.of(context).textTheme.bodyMedium),
                Form(
                  key: formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // email text form
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
                                        borderRadius: BorderRadius.circular(8))),
                                onPressed: () {
                                  resetPassword();
                                },
                                child: isLoading
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
                                    : const Text("Reset Password"),
                              ),
                            ),
                            const SizedBox(height: 16 / 2),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isLoading ?
                                      (Colors.grey)
                                      : (dark ? Colors.white : Colors.black),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  side: BorderSide(
                                      width: 2,
                                      color: isLoading
                                          ? Colors.grey
                                          : (dark ? Colors.white : Colors.black)),
                                ),
                                onPressed: () => isLoading ? null : Navigator.of(context).pop(),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.arrow_back_ios_new, size: 16),
                                    SizedBox(width: 4),
                                    Text("Go Back"),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 5),
                        Visibility(
                          visible: isReset,
                          child: Center(
                            child: Text(
                              resetMessage,
                              style: TextStyle(
                                  color:
                                      resetMessageColor == ResetMessageColor.red
                                          ? Colors.red
                                          : resetMessageColor ==
                                                  ResetMessageColor.green
                                              ? Colors.green
                                              : Colors.grey
                              ),
                            ),
                          ),
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
